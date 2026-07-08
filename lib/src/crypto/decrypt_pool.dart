import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'aes_ige.dart';

class DecryptPool {
  DecryptPool._();
  static final DecryptPool instance = DecryptPool._();

  static const int _size = 2;
  final List<_Worker> _workers = [];
  int _rr = 0;
  bool _spawning = false;
  Completer<void>? _ready;

  Future<void> _ensure() {
    if (_workers.length == _size) return Future.value();
    if (_ready != null) return _ready!.future;
    _ready = Completer<void>();
    _spawn();
    return _ready!.future;
  }

  Future<void> _spawn() async {
    if (_spawning) return;
    _spawning = true;
    try {
      while (_workers.length < _size) {
        final w = await _Worker.spawn();
        _workers.add(w);
      }
      _ready?.complete();
    } catch (e) {
      _ready?.completeError(e);
    } finally {
      _spawning = false;
    }
  }

  Future<Uint8List> decrypt(Uint8List data, Uint8List key, Uint8List iv) async {
    await _ensure();
    if (_workers.isEmpty) {
      return aesIgeDecrypt(data, key, iv);
    }
    final w = _workers[_rr++ % _workers.length];
    return w.decrypt(data, key, iv);
  }
}

class _Worker {
  final SendPort _send;
  final ReceivePort _recv;
  final Map<int, Completer<Uint8List>> _pending = {};
  int _nextId = 0;

  _Worker(this._send, this._recv) {
    _recv.listen((msg) {
      final id = msg[0] as int;
      final result = msg[1];
      final c = _pending.remove(id);
      if (c == null) return;
      if (result is Uint8List) {
        c.complete(result);
      } else {
        c.completeError(StateError('decrypt worker error: $result'));
      }
    });
  }

  static Future<_Worker> spawn() async {
    final recv = ReceivePort();
    final ready = Completer<SendPort>();
    final handshake = ReceivePort();
    handshake.listen((m) {
      if (m is SendPort) ready.complete(m);
    });
    await Isolate.spawn(_entry, handshake.sendPort);
    final sendPort = await ready.future;
    handshake.close();
    return _Worker(sendPort, recv);
  }

  Future<Uint8List> decrypt(Uint8List data, Uint8List key, Uint8List iv) {
    final id = _nextId++;
    final c = Completer<Uint8List>();
    _pending[id] = c;
    _send.send([id, data, key, iv, _recv.sendPort]);
    return c.future;
  }

  static void _entry(SendPort handshake) {
    final port = ReceivePort();
    handshake.send(port.sendPort);
    port.listen((msg) {
      final id = msg[0] as int;
      final data = msg[1] as Uint8List;
      final key = msg[2] as Uint8List;
      final iv = msg[3] as Uint8List;
      final reply = msg[4] as SendPort;
      try {
        final out = aesIgeDecrypt(data, key, iv);
        reply.send([id, out]);
      } catch (e) {
        reply.send([id, e.toString()]);
      }
    });
  }
}
