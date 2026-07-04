import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'transport_mode.dart';

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
class TcpTransport {
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

  TcpTransport({
    required this.host,
    required this.port,
    this.modeVariant = TransportModeVariant.abridged,
    this.timeout = const Duration(seconds: 15),
    this.readIdleTimeout = const Duration(seconds: 75),
  });

  DateTime _lastReadAt = DateTime.now();
  DateTime get lastReadAt => _lastReadAt;
  bool get isConnected => _socket != null && !_closed;

  Future<void> connect() async {
    _socket = await Socket.connect(host, port, timeout: timeout);
    _socket!.setOption(SocketOption.tcpNoDelay, true);
    _mode = TransportMode(modeVariant);
    _closed = false;
    _closeReason = null;

    _lastReadAt = DateTime.now();
    _subscription = _socket!.listen(
      (data) {
        _lastReadAt = DateTime.now();
        _readBuffer.add(data);
        _wakeReaders(null);
      },
      onError: (Object e, StackTrace st) {
        _fail(e);
      },
      onDone: () {
        _fail(const SocketException('Peer closed connection'));
      },
      cancelOnError: true,
    );

    final announcement = _mode.announcement;
    if (announcement.isNotEmpty) {
      _socket!.add(announcement);
      await _socket!.flush();
    }
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

  Future<void> writeMsg(Uint8List data) async {
    if (_socket == null || _closed) {
      throw _closeReason ?? const SocketException('Not connected');
    }
    try {
      await _mode.writeMsg(data, _socket!).timeout(timeout);
      await _socket!.flush().timeout(timeout);
    } catch (e) {
      _fail(e);
      rethrow;
    }
  }

  Future<Uint8List> readMsg() async {
    if (_socket == null || _closed) {
      throw _closeReason ?? const SocketException('Not connected');
    }

    if (_mode is AbridgedMode) {
      return _readAbridged();
    } else if (_mode is IntermediateMode || _mode is PaddedIntermediateMode) {
      return _readIntermediate();
    } else if (_mode is FullMode) {
      return _readFull();
    }
    throw UnsupportedError('Unknown transport mode');
  }

  Future<Uint8List> _readAbridged() async {
    final first = await _readExact(1);
    var size = first[0];

    if (size == 0x7f) {
      final sizeBuf = await _readExact(3);
      size = sizeBuf[0] | (sizeBuf[1] << 8) | (sizeBuf[2] << 16);
    }

    return _readExact(size * 4);
  }

  Future<Uint8List> _readIntermediate() async {
    final lenBuf = await _readExact(4);
    final length = ByteData.view(lenBuf.buffer).getUint32(0, Endian.little);
    return _readExact(length);
  }

  Future<Uint8List> _readFull() async {
    final lenBuf = await _readExact(4);
    final length = ByteData.view(lenBuf.buffer).getUint32(0, Endian.little);
    // length includes the 4-byte length prefix itself
    final rest = await _readExact(length - 4);
    // skip seqno (4 bytes), return payload without CRC (last 4 bytes)
    return Uint8List.fromList(rest.sublist(4, rest.length - 4));
  }

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
    try {
      sock?.destroy();
    } catch (_) {}
    _readBuffer.clear();
  }
}
