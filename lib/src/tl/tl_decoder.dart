import 'dart:convert';
import 'dart:typed_data';

import 'tl_encoder.dart';

class TlDecoder {
  final ByteData _data;
  int _offset = 0;

  TlDecoder(Uint8List bytes)
    : _data = ByteData.view(
        bytes.buffer,
        bytes.offsetInBytes,
        bytes.lengthInBytes,
      );

  int get remaining => _data.lengthInBytes - _offset;
  int get offset => _offset;

  int readUint32() {
    final val = _data.getUint32(_offset, Endian.little);
    _offset += 4;
    return val;
  }

  int readInt32() {
    final val = _data.getInt32(_offset, Endian.little);
    _offset += 4;
    return val;
  }

  int readInt64() {
    final val = _data.getInt64(_offset, Endian.little);
    _offset += 8;
    return val;
  }

  double readDouble() {
    final val = _data.getFloat64(_offset, Endian.little);
    _offset += 8;
    return val;
  }

  int readCrc() => readUint32();

  bool readBool() {
    final crc = readUint32();
    if (crc == crcTrue) return true;
    if (crc == crcFalse) return false;
    throw FormatException('Not a bool CRC: 0x${crc.toRadixString(16)}');
  }

  Uint8List readRawBytes(int count) {
    final bytes = Uint8List.view(
      _data.buffer,
      _data.offsetInBytes + _offset,
      count,
    );
    _offset += count;
    return Uint8List.fromList(bytes);
  }

  Uint8List readBytes() {
    final firstByte = _data.getUint8(_offset);
    _offset += 1;

    int size;
    int lenNumberSize;

    if (firstByte != 0xfe) {
      size = firstByte;
      lenNumberSize = 1;
    } else {
      size =
          _data.getUint8(_offset) |
          (_data.getUint8(_offset + 1) << 8) |
          (_data.getUint8(_offset + 2) << 16);
      _offset += 3;
      lenNumberSize = 4;
    }

    final bytes = readRawBytes(size);

    final readLen = lenNumberSize + size;
    final pad = (readLen % 4 == 0) ? 0 : 4 - (readLen % 4);
    if (pad > 0) _offset += pad;

    return bytes;
  }

  String readString() {
    final bytes = readBytes();
    try {
      return utf8.decode(bytes);
    } on FormatException {
      return utf8.decode(bytes, allowMalformed: true);
    }
  }

  Uint8List readRestOfMessage() {
    final rest = Uint8List.view(
      _data.buffer,
      _data.offsetInBytes + _offset,
      remaining,
    );
    _offset = _data.lengthInBytes;
    return Uint8List.fromList(rest);
  }

  void skip(int bytes) => _offset += bytes;
}
