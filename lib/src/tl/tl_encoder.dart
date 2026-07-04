import 'dart:convert';
import 'dart:typed_data';

const _wordLen = 4;
const _longLen = 8;
const _magicNumber = 0xfe;

/// TL binary encoder — writes MTProto TL-serialized data to a byte buffer.
class TlEncoder {
  final BytesBuilder _buf = BytesBuilder(copy: false);

  /// Returns the accumulated bytes.
  Uint8List toBytes() => _buf.toBytes();

  /// Current buffer length.
  int get length => _buf.length;

  /// Writes a raw byte list without length prefix.
  void writeRaw(List<int> bytes) => _buf.add(bytes);

  /// Writes a 32-bit unsigned integer (little-endian).
  void writeUint32(int value) {
    final bytes = Uint8List(_wordLen);
    ByteData.view(bytes.buffer).setUint32(0, value, Endian.little);
    _buf.add(bytes);
  }

  /// Writes a 32-bit signed integer (little-endian).
  void writeInt32(int value) {
    final bytes = Uint8List(_wordLen);
    ByteData.view(bytes.buffer).setInt32(0, value, Endian.little);
    _buf.add(bytes);
  }

  /// Writes a 64-bit signed integer (little-endian).
  void writeInt64(int value) {
    final bytes = Uint8List(_longLen);
    ByteData.view(bytes.buffer).setInt64(0, value, Endian.little);
    _buf.add(bytes);
  }

  /// Writes a CRC code (alias for writeUint32).
  void writeCrc(int crc) => writeUint32(crc);

  /// Writes a boolean as CRC_TRUE / CRC_FALSE.
  void writeBool(bool value) {
    writeCrc(value ? crcTrue : crcFalse);
  }

  /// Writes a 64-bit float (little-endian).
  void writeDouble(double value) {
    final bytes = Uint8List(_longLen);
    ByteData.view(bytes.buffer).setFloat64(0, value, Endian.little);
    _buf.add(bytes);
  }

  /// Writes a TL-serialized byte string (with length prefix and padding).
  void writeBytes(Uint8List data) {
    final size = data.length;

    if (size == 0) {
      writeUint32(0);
      return;
    }

    if (size > 0xffffff) {
      throw ArgumentError('TL bytes payload too large: $size > 16777215');
    }

    int lenNumberSize;
    if (size < _magicNumber) {
      _buf.addByte(size);
      lenNumberSize = 1;
    } else {
      writeUint32((size << 8) | _magicNumber);
      lenNumberSize = _wordLen;
    }

    _buf.add(data);

    final readLen = lenNumberSize + size;
    final pad = (readLen % _wordLen == 0) ? 0 : _wordLen - (readLen % _wordLen);
    if (pad > 0) {
      _buf.add(Uint8List(pad));
    }
  }

  /// Writes a TL-serialized string. TL strings are UTF-8.
  void writeString(String value) {
    writeBytes(Uint8List.fromList(utf8.encode(value)));
  }
}

/// TL CRC constants.
const int crcTrue = 0x997275b5;
const int crcFalse = 0xbc799737;
const int crcNull = 0x56730bcc;
const int crcVector = 0x1cb5c415;
