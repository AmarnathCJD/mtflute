import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'obfuscation.dart';
import 'transport.dart';
import 'transport_mode.dart';

class WebSocketTransport implements Transport {
  final String url;
  final TransportModeVariant modeVariant;
  final Duration timeout;
  final Duration readIdleTimeout;
  final ObfuscationConfig? obfuscation;

  WebSocket? _ws;
  StreamSubscription? _sub;
  late TransportMode _mode;
  Obfuscation? _obf;
  bool _closed = false;
  Object? _closeReason;

  final _readBuffer = BytesBuilder(copy: false);
  final _readCompleter = <Completer<void>>[];
  DateTime _lastReadAt = DateTime.now();

  WebSocketTransport({
    required this.url,
    this.modeVariant = TransportModeVariant.intermediate,
    this.timeout = const Duration(seconds: 15),
    this.readIdleTimeout = const Duration(seconds: 75),
    this.obfuscation,
  });

  @override
  DateTime get lastReadAt => _lastReadAt;

  @override
  bool get isConnected => _ws != null && !_closed;

  @override
  Future<void> connect() async {
    _mode = TransportMode(modeVariant);
    _closed = false;
    _closeReason = null;
    _lastReadAt = DateTime.now();
    _obf = obfuscation != null ? Obfuscation.create(obfuscation!) : null;
    final obf = _obf;

    _ws = await WebSocket.connect(url, protocols: ['binary']).timeout(timeout);

    _sub = _ws!.listen(
      (data) {
        _lastReadAt = DateTime.now();
        if (data is! List<int>) return;
        final bytes = data is Uint8List ? data : Uint8List.fromList(data);
        _readBuffer.add(obf != null ? obf.decrypt(bytes) : bytes);
        _wakeReaders(null);
      },
      onError: (Object e, [StackTrace? st]) => _fail(e),
      onDone: () => _fail(const SocketException('WebSocket closed')),
      cancelOnError: true,
    );

    if (obf != null) {
      _ws!.add(obf.initFrame);
    }

    final announcement = _mode.announcement;
    if (announcement.isNotEmpty) {
      _send(announcement);
    }
  }

  void _send(Uint8List data) {
    final obf = _obf;
    _ws!.add(obf != null ? obf.encrypt(data) : data);
  }

  @override
  Future<void> writeMsg(Uint8List data, {bool quickAck = false}) async {
    if (_ws == null || _closed) {
      throw _closeReason ?? const SocketException('Not connected');
    }
    final sink = _CollectSink();
    await _mode.writeMsg(data, sink, quickAck: quickAck);
    _send(sink.takeBytes());
  }

  @override
  Future<Uint8List> readMsg() async {
    if (_ws == null || _closed) {
      throw _closeReason ?? const SocketException('Not connected');
    }
    while (true) {
      Uint8List data;
      if (_mode is AbridgedMode) {
        data = await _readAbridged();
      } else {
        data = await _readIntermediate();
      }
      if (data.length == 4) {
        final u = ByteData.view(data.buffer, data.offsetInBytes)
            .getUint32(0, Endian.little);
        if (u & 0x80000000 != 0) continue;
        final code = ByteData.view(data.buffer, data.offsetInBytes)
            .getInt32(0, Endian.little);
        if (code < 0) {
          _fail(SocketException('transport error $code'));
          throw SocketException('transport error $code');
        }
      }
      return data;
    }
  }

  Future<Uint8List> _readAbridged() async {
    final first = await _readExact(1);
    var size = first[0];
    if (size == 0x7f) {
      final s = await _readExact(3);
      size = s[0] | (s[1] << 8) | (s[2] << 16);
    }
    return _readExact(size * 4);
  }

  Future<Uint8List> _readIntermediate() async {
    final lenBuf = await _readExact(4);
    final raw = ByteData.view(lenBuf.buffer).getUint32(0, Endian.little);
    if (raw & 0x80000000 != 0) return lenBuf;
    return _readExact(raw);
  }

  Future<Uint8List> _readExact(int count) async {
    while (_readBuffer.length < count) {
      if (_closed) {
        throw _closeReason ?? const SocketException('Connection closed');
      }
      final c = Completer<void>();
      _readCompleter.add(c);
      try {
        if (readIdleTimeout > Duration.zero) {
          await c.future.timeout(readIdleTimeout);
        } else {
          await c.future;
        }
      } on TimeoutException {
        _readCompleter.remove(c);
        _fail(TimeoutException('read idle timeout', readIdleTimeout));
        rethrow;
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

  @override
  Future<void> close() async {
    if (_closed && _ws == null) return;
    _closed = true;
    _closeReason ??= const SocketException('Closed by caller');
    _wakeReaders(_closeReason);
    try {
      await _sub?.cancel();
    } catch (_) {}
    _sub = null;
    try {
      await _ws?.close();
    } catch (_) {}
    _ws = null;
    _readBuffer.clear();
  }
}

class _CollectSink implements IOSink {
  final _b = BytesBuilder(copy: false);
  Uint8List takeBytes() => _b.takeBytes();

  @override
  void add(List<int> data) => _b.add(data);

  @override
  Encoding encoding = SystemEncoding();

  @override
  void write(Object? obj) {}
  @override
  void writeAll(Iterable objects, [String separator = '']) {}
  @override
  void writeln([Object? obj = '']) {}
  @override
  void writeCharCode(int charCode) {}
  @override
  void addError(Object error, [StackTrace? stackTrace]) {}
  @override
  Future addStream(Stream<List<int>> stream) => stream.forEach(add);
  @override
  Future flush() async {}
  @override
  Future close() async {}
  @override
  Future get done => Future.value();
}
