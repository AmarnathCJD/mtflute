import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

enum TransportModeVariant { abridged, intermediate, paddedIntermediate, full }

final _padRng = Random.secure();

abstract class TransportMode {
  Future<void> writeMsg(Uint8List data, IOSink sink, {bool quickAck = false});
  Future<Uint8List> readMsg(Stream<Uint8List> stream);
  Uint8List get announcement;

  factory TransportMode(TransportModeVariant variant) {
    switch (variant) {
      case TransportModeVariant.abridged:
        return AbridgedMode();
      case TransportModeVariant.intermediate:
        return IntermediateMode();
      case TransportModeVariant.paddedIntermediate:
        return PaddedIntermediateMode();
      case TransportModeVariant.full:
        return FullMode();
    }
  }
}

class AbridgedMode implements TransportMode {
  @override
  Uint8List get announcement => Uint8List.fromList([0xef]);

  @override
  Future<void> writeMsg(Uint8List data, IOSink sink,
      {bool quickAck = false}) async {
    if (data.length % 4 != 0) {
      throw ArgumentError('Message length must be a multiple of 4');
    }

    final msgLength = data.length ~/ 4;
    if (msgLength < 0x7f) {
      final b = quickAck ? (msgLength | 0x80) : msgLength;
      sink.add(Uint8List.fromList([b]));
    } else {
      final buf = Uint8List(4);
      var word = (msgLength << 8) | 0x7f;
      if (quickAck) word |= 0x80000000;
      ByteData.view(buf.buffer).setUint32(0, word, Endian.little);
      sink.add(buf);
    }
    sink.add(data);
  }

  @override
  Future<Uint8List> readMsg(Stream<Uint8List> stream) async {
    throw UnimplementedError('Use MtpTransport.readMsg instead');
  }
}

class IntermediateMode implements TransportMode {
  @override
  Uint8List get announcement => Uint8List.fromList([0xee, 0xee, 0xee, 0xee]);

  @override
  Future<void> writeMsg(Uint8List data, IOSink sink,
      {bool quickAck = false}) async {
    final lengthBuf = Uint8List(4);
    var len = data.length;
    if (quickAck) len |= 0x80000000;
    ByteData.view(lengthBuf.buffer).setUint32(0, len, Endian.little);
    sink.add(lengthBuf);
    sink.add(data);
  }

  @override
  Future<Uint8List> readMsg(Stream<Uint8List> stream) async {
    throw UnimplementedError('Use MtpTransport.readMsg instead');
  }
}

class PaddedIntermediateMode implements TransportMode {
  @override
  Uint8List get announcement => Uint8List.fromList([0xdd, 0xdd, 0xdd, 0xdd]);

  @override
  Future<void> writeMsg(Uint8List data, IOSink sink,
      {bool quickAck = false}) async {
    final padLen = _padRng.nextInt(16);
    final padded = Uint8List(data.length + padLen);
    padded.setRange(0, data.length, data);
    for (var i = data.length; i < padded.length; i++) {
      padded[i] = _padRng.nextInt(256);
    }
    final lengthBuf = Uint8List(4);
    var len = padded.length;
    if (quickAck) len |= 0x80000000;
    ByteData.view(lengthBuf.buffer).setUint32(0, len, Endian.little);
    sink.add(lengthBuf);
    sink.add(padded);
  }

  @override
  Future<Uint8List> readMsg(Stream<Uint8List> stream) async {
    throw UnimplementedError('Use MtpTransport.readMsg instead');
  }
}

class FullMode implements TransportMode {
  int _seqNo = 0;

  @override
  Uint8List get announcement => Uint8List(0);

  @override
  Future<void> writeMsg(Uint8List data, IOSink sink,
      {bool quickAck = false}) async {
    final length = data.length + 12; // 4 (len) + 4 (seqno) + data + 4 (crc)
    final buf = Uint8List(length);
    final bd = ByteData.view(buf.buffer);

    bd.setUint32(0, length, Endian.little);
    bd.setUint32(4, _seqNo++, Endian.little);
    buf.setRange(8, 8 + data.length, data);

    var crc = _crc32(buf.sublist(0, length - 4));
    bd.setUint32(length - 4, crc, Endian.little);

    sink.add(buf);
  }

  @override
  Future<Uint8List> readMsg(Stream<Uint8List> stream) async {
    throw UnimplementedError('Use MtpTransport.readMsg instead');
  }

  static int _crc32(Uint8List data) {
    var crc = 0xFFFFFFFF;
    for (final b in data) {
      crc ^= b;
      for (var j = 0; j < 8; j++) {
        if ((crc & 1) != 0) {
          crc = (crc >>> 1) ^ 0xEDB88320;
        } else {
          crc >>>= 1;
        }
      }
    }
    return crc ^ 0xFFFFFFFF;
  }
}
