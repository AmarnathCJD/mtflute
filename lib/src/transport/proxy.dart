import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

enum ProxyType { socks5, socks4, http }

class Proxy {
  final ProxyType type;
  final String host;
  final int port;
  final String? username;
  final String? password;

  const Proxy({
    required this.type,
    required this.host,
    required this.port,
    this.username,
    this.password,
  });

  const Proxy.socks5(this.host, this.port, {this.username, this.password})
      : type = ProxyType.socks5;
  const Proxy.socks4(this.host, this.port, {this.username})
      : type = ProxyType.socks4,
        password = null;
  const Proxy.http(this.host, this.port, {this.username, this.password})
      : type = ProxyType.http;
}

class ProxiedSocket {
  final Socket socket;
  final Uint8List leftover;
  final StreamSubscription<Uint8List> subscription;
  ProxiedSocket(this.socket, this.leftover, this.subscription);
}

Future<ProxiedSocket> connectViaProxy(
  Proxy proxy,
  String targetHost,
  int targetPort, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  final socket = await Socket.connect(proxy.host, proxy.port, timeout: timeout);
  socket.setOption(SocketOption.tcpNoDelay, true);
  final reader = _Reader(socket);
  try {
    switch (proxy.type) {
      case ProxyType.socks5:
        await _socks5(socket, proxy, targetHost, targetPort, reader);
      case ProxyType.socks4:
        await _socks4(socket, proxy, targetHost, targetPort, reader);
      case ProxyType.http:
        await _httpConnect(socket, proxy, targetHost, targetPort, reader);
    }
    final (leftover, sub) = reader.detach();
    return ProxiedSocket(socket, leftover, sub);
  } catch (_) {
    await reader.cancel();
    socket.destroy();
    rethrow;
  }
}

class _Reader {
  final _buf = BytesBuilder(copy: false);
  final _waiters = <Completer<void>>[];
  StreamSubscription<Uint8List>? _sub;
  Object? _error;

  _Reader(Stream<Uint8List> s) {
    _sub = s.listen(
      (data) {
        _buf.add(data);
        _wake(null);
      },
      onError: (Object e) => _wake(e),
      onDone: () => _wake(const SocketException('proxy closed')),
      cancelOnError: true,
    );
  }

  void _wake(Object? err) {
    if (err != null) _error = err;
    final w = List.of(_waiters);
    _waiters.clear();
    for (final c in w) {
      if (!c.isCompleted) c.complete();
    }
  }

  Future<Uint8List> exact(int n) async {
    while (_buf.length < n) {
      if (_error != null) throw _error!;
      final c = Completer<void>();
      _waiters.add(c);
      await c.future;
    }
    final all = _buf.takeBytes();
    final out = Uint8List.fromList(all.sublist(0, n));
    if (all.length > n) _buf.add(Uint8List.sublistView(all, n));
    return out;
  }

  (Uint8List, StreamSubscription<Uint8List>) detach() {
    final sub = _sub!;
    sub.pause();
    sub.onData(null);
    sub.onError(null);
    sub.onDone(null);
    _sub = null;
    return (_buf.takeBytes(), sub);
  }

  Future<void> cancel() async {
    await _sub?.cancel();
    _sub = null;
  }
}

Future<void> _socks5(
    Socket s, Proxy p, String host, int port, _Reader reader) async {
  final hasAuth = p.username != null && p.username!.isNotEmpty;
  s.add(hasAuth ? [0x05, 0x02, 0x00, 0x02] : [0x05, 0x01, 0x00]);
  await s.flush();

  final greeting = await reader.exact(2);
  if (greeting[0] != 0x05) throw const SocketException('bad SOCKS5 version');
  final method = greeting[1];
  if (method == 0x02) {
    final u = utf8.encode(p.username ?? '');
    final pw = utf8.encode(p.password ?? '');
    final auth = BytesBuilder();
    auth.addByte(0x01);
    auth.addByte(u.length);
    auth.add(u);
    auth.addByte(pw.length);
    auth.add(pw);
    s.add(auth.toBytes());
    await s.flush();
    final ar = await reader.exact(2);
    if (ar[1] != 0x00) throw const SocketException('SOCKS5 auth failed');
  } else if (method != 0x00) {
    throw const SocketException('SOCKS5 no acceptable auth method');
  }

  final req = BytesBuilder();
  req.add([0x05, 0x01, 0x00]);
  final ip = _tryParseIp(host);
  if (ip != null && ip.type == InternetAddressType.IPv4) {
    req.addByte(0x01);
    req.add(ip.rawAddress);
  } else if (ip != null && ip.type == InternetAddressType.IPv6) {
    req.addByte(0x04);
    req.add(ip.rawAddress);
  } else {
    final hb = utf8.encode(host);
    req.addByte(0x03);
    req.addByte(hb.length);
    req.add(hb);
  }
  req.addByte((port >> 8) & 0xff);
  req.addByte(port & 0xff);
  s.add(req.toBytes());
  await s.flush();

  final rep = await reader.exact(4);
  if (rep[1] != 0x00) {
    throw SocketException('SOCKS5 connect failed (code ${rep[1]})');
  }
  final atyp = rep[3];
  final skip = atyp == 0x01
      ? 4
      : atyp == 0x04
          ? 16
          : (await reader.exact(1))[0];
  await reader.exact(skip + 2);
}

Future<void> _socks4(
    Socket s, Proxy p, String host, int port, _Reader reader) async {
  final ip = _tryParseIp(host);
  final req = BytesBuilder();
  req.add([0x04, 0x01]);
  req.addByte((port >> 8) & 0xff);
  req.addByte(port & 0xff);
  final user = utf8.encode(p.username ?? '');
  if (ip != null && ip.type == InternetAddressType.IPv4) {
    req.add(ip.rawAddress);
    req.add(user);
    req.addByte(0x00);
  } else {
    req.add([0x00, 0x00, 0x00, 0x01]); // SOCKS4a
    req.add(user);
    req.addByte(0x00);
    req.add(utf8.encode(host));
    req.addByte(0x00);
  }
  s.add(req.toBytes());
  await s.flush();

  final rep = await reader.exact(8);
  if (rep[1] != 0x5a) {
    throw SocketException('SOCKS4 connect failed (code ${rep[1]})');
  }
}

Future<void> _httpConnect(
    Socket s, Proxy p, String host, int port, _Reader reader) async {
  final target = host.contains(':') ? '[$host]:$port' : '$host:$port';
  final sb = StringBuffer()
    ..write('CONNECT $target HTTP/1.1\r\n')
    ..write('Host: $target\r\n');
  if (p.username != null && p.username!.isNotEmpty) {
    final cred = base64.encode(utf8.encode('${p.username}:${p.password ?? ''}'));
    sb.write('Proxy-Authorization: Basic $cred\r\n');
  }
  sb.write('\r\n');
  s.add(utf8.encode(sb.toString()));
  await s.flush();

  final header = BytesBuilder();
  while (true) {
    final b = await reader.exact(1);
    header.add(b);
    final bytes = header.toBytes();
    if (bytes.length >= 4 &&
        bytes[bytes.length - 4] == 0x0d &&
        bytes[bytes.length - 3] == 0x0a &&
        bytes[bytes.length - 2] == 0x0d &&
        bytes[bytes.length - 1] == 0x0a) {
      break;
    }
    if (bytes.length > 8192) {
      throw const SocketException('HTTP CONNECT header too long');
    }
  }
  final statusLine = ascii.decode(header.toBytes()).split('\r\n').first;
  final parts = statusLine.split(' ');
  if (parts.length < 2 || parts[1] != '200') {
    throw SocketException('HTTP CONNECT failed: $statusLine');
  }
}

InternetAddress? _tryParseIp(String host) {
  try {
    return InternetAddress(host);
  } catch (_) {
    return null;
  }
}
