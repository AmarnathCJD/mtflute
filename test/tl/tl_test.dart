import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:mtflute/src/tl/tl_encoder.dart';
import 'package:mtflute/src/tl/tl_decoder.dart';

void main() {
  group('TlEncoder/TlDecoder', () {
    test('uint32 roundtrip', () {
      final e = TlEncoder();
      e.writeUint32(0xdeadbeef);
      final d = TlDecoder(e.toBytes());
      expect(d.readUint32(), 0xdeadbeef);
    });

    test('int32 roundtrip', () {
      final e = TlEncoder();
      e.writeInt32(-42);
      final d = TlDecoder(e.toBytes());
      expect(d.readInt32(), -42);
    });

    test('int64 roundtrip', () {
      final e = TlEncoder();
      e.writeInt64(0x123456789abcdef0);
      final d = TlDecoder(e.toBytes());
      expect(d.readInt64(), 0x123456789abcdef0);
    });

    test('double roundtrip', () {
      final e = TlEncoder();
      e.writeDouble(3.14159);
      final d = TlDecoder(e.toBytes());
      expect(d.readDouble(), closeTo(3.14159, 1e-10));
    });

    test('bool roundtrip', () {
      final e = TlEncoder();
      e.writeBool(true);
      e.writeBool(false);
      final d = TlDecoder(e.toBytes());
      expect(d.readBool(), true);
      expect(d.readBool(), false);
    });

    test('bytes roundtrip - short message', () {
      final e = TlEncoder();
      final data = Uint8List.fromList([1, 2, 3, 4, 5]);
      e.writeBytes(data);
      final d = TlDecoder(e.toBytes());
      expect(d.readBytes(), equals(data));
    });

    test('bytes roundtrip - empty', () {
      final e = TlEncoder();
      e.writeBytes(Uint8List(0));
      final d = TlDecoder(e.toBytes());
      expect(d.readBytes(), equals(Uint8List(0)));
    });

    test('bytes roundtrip - long message (>= 254 bytes)', () {
      final e = TlEncoder();
      final data = Uint8List(300);
      for (var i = 0; i < 300; i++) {
        data[i] = i & 0xff;
      }
      e.writeBytes(data);
      final d = TlDecoder(e.toBytes());
      expect(d.readBytes(), equals(data));
    });

    test('string roundtrip', () {
      final e = TlEncoder();
      e.writeString('hello');
      final d = TlDecoder(e.toBytes());
      expect(d.readString(), 'hello');
    });

    test('crc roundtrip', () {
      final e = TlEncoder();
      e.writeCrc(crcVector);
      final d = TlDecoder(e.toBytes());
      expect(d.readCrc(), crcVector);
    });

    test('multiple fields sequential', () {
      final e = TlEncoder();
      e.writeUint32(42);
      e.writeInt64(12345678);
      e.writeString('test');
      e.writeBool(true);

      final d = TlDecoder(e.toBytes());
      expect(d.readUint32(), 42);
      expect(d.readInt64(), 12345678);
      expect(d.readString(), 'test');
      expect(d.readBool(), true);
    });

    test('raw bytes', () {
      final e = TlEncoder();
      e.writeRaw([0xaa, 0xbb, 0xcc, 0xdd]);
      final d = TlDecoder(e.toBytes());
      expect(d.readRawBytes(4), equals([0xaa, 0xbb, 0xcc, 0xdd]));
    });

    test('readRestOfMessage', () {
      final e = TlEncoder();
      e.writeUint32(1);
      e.writeRaw([0x10, 0x20, 0x30]);
      final d = TlDecoder(e.toBytes());
      d.readUint32();
      final rest = d.readRestOfMessage();
      expect(rest, equals([0x10, 0x20, 0x30]));
    });
  });
}
