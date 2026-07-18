import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'fake_tls.dart';
import 'obfuscation.dart';
import 'proxy.dart';
import 'transport.dart';
import 'transport_mode.dart';

/// A transport-level error frame (4-byte negative int32). The [code] is the
/// positive spec error code, e.g. 404 (auth_key not found), 429 (transport
/// flood), 400 (bad request).
class TransportError implements Exception {
  final int code;
  const TransportError(this.code);
  @override
  String toString() => 'TransportError($code)';
}

/// Low-level TCP transport for MTProto.
///
/// A single reader/writer pair over a [Socket]. Frames follow the selected
/// [TransportModeVariant] (abridged, intermediate, padded-intermediate, full).
///
/// Lifecycle: [connect] → many [writeMsg] / [readMsg] → [close]. Once [close]
/// runs the transport is single-use; construct a new one to reconnect.
///
/// The reader tolerates silently-dead sockets via [readIdleTimeout]: if the
/// far end stops responding without an FIN/RST (NAT drop, mobile handoff),
/// [readMsg] surfaces a [TimeoutException] instead of hanging forever, which
/// lets the client's poll loop react.
class TcpTransport implements Transport {
  final String host;
  final int port;
  final TransportModeVariant modeVariant;

  /// Timeout for `connect()` and `writeMsg()`.
  final Duration timeout;

  /// If a read is blocked with zero bytes arriving for this long, [readMsg]
  /// throws a [TimeoutException] so the caller can trigger a reconnect. Set
  /// to `Duration.zero` to disable (not recommended). Default: 75s — larger
  /// than the client's 30s ping so a live idle connection stays quiet.
  final Duration readIdleTimeout;

  Socket? _socket;
  late TransportMode _mode;
  StreamSubscription<Uint8List>? _subscription;
  final _readBuffer = BytesBuilder(copy: false);
  final _readCompleter = <Completer<void>>[];
  bool _closed = false;
  Object? _closeReason;

  final Proxy? proxy;

  final ObfuscationConfig? obfuscation;
  final String? fakeTlsDomain;
  final Uint8List? fakeTlsSecret;
  Obfuscation? _obf;
  _ObfSink? _obfSink;
  final _tlsInBuffer = BytesBuilder(copy: false);

  TcpTransport({
    required this.host,
    required this.port,
    this.modeVariant = TransportModeVariant.abridged,
    this.timeout = const Duration(seconds: 15),
    this.readIdleTimeout = const Duration(seconds: 75),
    this.proxy,
    this.obfuscation,
    this.fakeTlsDomain,
    this.fakeTlsSecret,
  });

  IOSink get _sink => _obfSink ?? _baseSink ?? _socket!;
  bool get _fakeTls => fakeTlsDomain != null;

  DateTime _lastReadAt = DateTime.now();
  @override
  DateTime get lastReadAt => _lastReadAt;
  @override
  bool get isConnected => _socket != null && !_closed;

  @override
  Future<void> connect() async {
    _mode = TransportMode(modeVariant);
    _closed = false;
    _closeReason = null;
    _lastReadAt = DateTime.now();
    _obf = obfuscation != null ? Obfuscation.create(obfuscation!) : null;
    final obf = _obf;
    _tlsInBuffer.clear();

    void ingest(Uint8List raw) {
      _lastReadAt = DateTime.now();
      Uint8List payload;
      if (_fakeTls) {
        final rec = _unwrapTlsRecords(raw);
        if (rec.isEmpty) {
          _wakeReaders(null);
          return;
        }
        payload = rec;
      } else {
        payload = raw;
      }
      _readBuffer.add(obf != null ? obf.decrypt(payload) : payload);
      _wakeReaders(null);
    }

    void onErr(Object e, [StackTrace? st]) => _fail(e);
    void onDone() => _fail(const SocketException('Peer closed connection'));

    Uint8List? leftover;
    if (proxy != null) {
      final ps = await connectViaProxy(proxy!, host, port, timeout: timeout);
      _socket = ps.socket;
      if (ps.leftover.isNotEmpty) leftover = ps.leftover;
      _subscription = ps.subscription
        ..onError(onErr)
        ..onDone(onDone);
    } else {
      _socket = await Socket.connect(host, port, timeout: timeout);
      _socket!.setOption(SocketOption.tcpNoDelay, true);
      _subscription = _socket!.listen(null, onError: onErr, onDone: onDone,
          cancelOnError: true);
    }

    if (_fakeTls) {
      await _fakeTlsHandshake(leftover);
      leftover = null;
    }

    _subscription!
      ..onData(ingest)
      ..resume();

    IOSink baseSink = _socket!;
    if (_fakeTls) {
      baseSink = _TlsRecordSink(_socket!);
    }

    if (obf != null) {
      _obfSink = _ObfSink(baseSink, obf);
      final framed = _fakeTls ? wrapTlsRecord(obf.initFrame) : obf.initFrame;
      _socket!.add(framed);
      await _socket!.flush();
    } else if (_fakeTls) {
      _obfSink = null;
    }
    _baseSink = baseSink;

    if (leftover != null && leftover.isNotEmpty) {
      _readBuffer.add(obf != null ? obf.decrypt(leftover) : leftover);
    }

    if (obf != null) {
      return;
    }

    final announcement = _mode.announcement;
    if (announcement.isNotEmpty) {
      _sink.add(announcement);
      await _socket!.flush();
    }
  }

  IOSink? _baseSink;

  Future<void> _fakeTlsHandshake(Uint8List? seed) async {
    final hello = FakeTlsHello.build(fakeTlsSecret ?? Uint8List(0), fakeTlsDomain!);
    _socket!.add(hello.bytes);
    await _socket!.flush();

    if (seed != null && seed.isNotEmpty) _tlsInBuffer.add(seed);

    Completer<void>? tick;
    _subscription!
      ..onData((chunk) {
        _tlsInBuffer.add(chunk);
        final t = tick;
        tick = null;
        if (t != null && !t.isCompleted) t.complete();
      })
      ..resume();

    final deadline = DateTime.now().add(timeout);
    try {
      while (true) {
        if (_extractedAppData()) return;
        if (DateTime.now().isAfter(deadline)) {
          throw const SocketException('fakeTLS handshake timeout');
        }
        tick = Completer<void>();
        await tick!.future.timeout(timeout, onTimeout: () {
          throw const SocketException('fakeTLS handshake timeout');
        });
      }
    } finally {
      _subscription!.pause();
      _subscription!.onData(null);
    }
  }

  bool _extractedAppData() {
    final buf = _tlsInBuffer.takeBytes();
    var pos = 0;
    var appDataStart = -1;
    while (pos + 5 <= buf.length) {
      final type = buf[pos];
      final len = (buf[pos + 3] << 8) | buf[pos + 4];
      if (pos + 5 + len > buf.length) break;
      if (type == 0x17) {
        appDataStart = pos;
        break;
      }
      pos += 5 + len;
    }
    if (appDataStart < 0) {
      _tlsInBuffer.add(buf);
      return false;
    }
    _tlsInBuffer.add(Uint8List.sublistView(buf, appDataStart));
    return true;
  }

  Uint8List _unwrapTlsRecords(Uint8List raw) {
    _tlsInBuffer.add(raw);
    final buf = _tlsInBuffer.takeBytes();
    var pos = 0;
    final out = BytesBuilder(copy: false);
    while (pos + 5 <= buf.length) {
      final type = buf[pos];
      final len = (buf[pos + 3] << 8) | buf[pos + 4];
      if (pos + 5 + len > buf.length) break;
      final body = Uint8List.sublistView(buf, pos + 5, pos + 5 + len);
      pos += 5 + len;
      if (type == 0x17) out.add(body);
    }
    if (pos < buf.length) {
      _tlsInBuffer.add(Uint8List.sublistView(buf, pos));
    }
    return out.toBytes();
  }

  void _wakeReaders(Object? error) {
    if (_readCompleter.isEmpty) return;
    final pending = List.of(_readCompleter);
    _readCompleter.clear();
    for (final c in pending) {
      if (c.isCompleted) continue;
      if (error != null) {
        c.completeError(error);
      } else {
        c.complete();
      }
    }
  }

  void _fail(Object reason) {
    if (_closed) return;
    _closed = true;
    _closeReason = reason;
    _wakeReaders(reason);
  }

  Future<Uint8List> _readExact(int count) async {
    while (_readBuffer.length < count) {
      if (_closed) {
        throw _closeReason ?? const SocketException('Connection closed');
      }
      final completer = Completer<void>();
      _readCompleter.add(completer);
      try {
        if (readIdleTimeout > Duration.zero) {
          await completer.future.timeout(readIdleTimeout);
        } else {
          await completer.future;
        }
      } on TimeoutException {
        _readCompleter.remove(completer);
        // Idle read timeout — mark dead so callers reconnect promptly.
        _fail(TimeoutException('read idle timeout', readIdleTimeout));
        rethrow;
      }
      if (_closed && _readBuffer.length < count) {
        throw _closeReason ?? const SocketException('Connection closed');
      }
    }
    final full = _readBuffer.takeBytes();
    if (full.length == count) return Uint8List.fromList(full);
    final result = Uint8List.fromList(full.sublist(0, count));
    if (full.length > count) {
      _readBuffer.add(Uint8List.sublistView(full, count));
    }
    return result;
  }

  @override
  Future<void> writeMsg(Uint8List data, {bool quickAck = false}) async {
    if (_socket == null || _closed) {
      throw _closeReason ?? const SocketException('Not connected');
    }
    try {
      await _mode.writeMsg(data, _sink, quickAck: quickAck).timeout(timeout);
      await _socket!.flush().timeout(timeout);
    } catch (e) {
      _fail(e);
      rethrow;
    }
  }

  void Function(int token)? onQuickAck;

  @override
  Future<Uint8List> readMsg() async {
    if (_socket == null || _closed) {
      throw _closeReason ?? const SocketException('Not connected');
    }

    while (true) {
      Uint8List data;
      if (_mode is AbridgedMode) {
        data = await _readAbridged();
      } else if (_mode is IntermediateMode || _mode is PaddedIntermediateMode) {
        data = await _readIntermediate();
      } else if (_mode is FullMode) {
        data = await _readFull();
      } else {
        throw UnsupportedError('Unknown transport mode');
      }

      if (data.length == 4) {
        final u = ByteData.view(data.buffer, data.offsetInBytes)
            .getUint32(0, Endian.little);
        if (u & 0x80000000 != 0) {
          onQuickAck?.call(u);
          continue;
        }
        final code = ByteData.view(data.buffer, data.offsetInBytes)
            .getInt32(0, Endian.little);
        if (code < 0) {
          final err = TransportError(-code);
          _fail(err);
          throw err;
        }
      }
      return data;
    }
  }

  Future<Uint8List> _readAbridged() async {
    final first = await _readExact(1);
    if (first[0] & 0x80 != 0) {
      final rest = await _readExact(3);
      return Uint8List.fromList([first[0], rest[0], rest[1], rest[2]]);
    }
    var size = first[0];

    if (size == 0x7f) {
      final sizeBuf = await _readExact(3);
      size = sizeBuf[0] | (sizeBuf[1] << 8) | (sizeBuf[2] << 16);
    }

    return _readExact(size * 4);
  }

  Future<Uint8List> _readIntermediate() async {
    final lenBuf = await _readExact(4);
    final raw = ByteData.view(lenBuf.buffer).getUint32(0, Endian.little);
    if (raw & 0x80000000 != 0) {
      return lenBuf;
    }
    return _readExact(raw);
  }

  Future<Uint8List> _readFull() async {
    final lenBuf = await _readExact(4);
    final length = ByteData.view(lenBuf.buffer).getUint32(0, Endian.little);
    // length includes the 4-byte length prefix itself
    final rest = await _readExact(length - 4);
    // skip seqno (4 bytes), return payload without CRC (last 4 bytes)
    return Uint8List.fromList(rest.sublist(4, rest.length - 4));
  }

  @override
  Future<void> close() async {
    if (_closed && _socket == null) return;
    _closed = true;
    _closeReason ??= const SocketException('Closed by caller');
    _wakeReaders(_closeReason);
    final sub = _subscription;
    _subscription = null;
    try {
      await sub?.cancel();
    } catch (_) {}
    final sock = _socket;
    _socket = null;
    _obfSink = null;
    _baseSink = null;
    _obf = null;
    try {
      sock?.destroy();
    } catch (_) {}
    _readBuffer.clear();
    _tlsInBuffer.clear();
  }
}

abstract class _WrapSink implements IOSink {
  IOSink get _inner;

  @override
  Encoding encoding = utf8;

  @override
  void write(Object? obj) => add(utf8.encode(obj.toString()));

  @override
  void writeAll(Iterable objects, [String separator = '']) =>
      write(objects.join(separator));

  @override
  void writeln([Object? obj = '']) => write('$obj\n');

  @override
  void writeCharCode(int charCode) => write(String.fromCharCode(charCode));

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      _inner.addError(error, stackTrace);

  @override
  Future addStream(Stream<List<int>> stream) => stream.forEach(add);

  @override
  Future flush() => _inner.flush();

  @override
  Future close() => _inner.close();

  @override
  Future get done => _inner.done;
}

class _ObfSink extends _WrapSink {
  @override
  final IOSink _inner;
  final Obfuscation _obf;
  _ObfSink(this._inner, this._obf);

  @override
  void add(List<int> data) {
    final bytes = data is Uint8List ? data : Uint8List.fromList(data);
    _inner.add(_obf.encrypt(bytes));
  }
}

class _TlsRecordSink extends _WrapSink {
  @override
  final IOSink _inner;
  _TlsRecordSink(this._inner);

  @override
  void add(List<int> data) {
    var bytes = data is Uint8List ? data : Uint8List.fromList(data);
    var off = 0;
    const maxRecord = 16384;
    while (off < bytes.length) {
      final end = (off + maxRecord < bytes.length) ? off + maxRecord : bytes.length;
      _inner.add(wrapTlsRecord(Uint8List.sublistView(bytes, off, end)));
      off = end;
    }
  }
}
