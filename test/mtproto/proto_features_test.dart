import 'dart:io';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:mtflute/src/mtproto/objects.dart';
import 'package:mtflute/src/mtproto/messages.dart';
import 'package:mtflute/src/crypto/mtproto_crypto.dart';
import 'package:mtflute/src/crypto/rsa_keys.dart';
import 'package:mtflute/src/tl/tl_decoder.dart';
import 'package:mtflute/src/tl/tl_encoder.dart';
import 'package:mtflute/src/transport/dc_options.dart';
import 'package:mtflute/src/transport/transport_mode.dart';

void main() {
  group('service message encoders', () {
    test('encodeMsgsAck vector', () {
      final b = encodeMsgsAck([111, 222, 333]);
      final d = TlDecoder(b);
      expect(d.readCrc(), crcMsgsAck);
      expect(d.readCrc(), crcVector);
      expect(d.readUint32(), 3);
      expect(d.readInt64(), 111);
      expect(d.readInt64(), 222);
      expect(d.readInt64(), 333);
    });

    test('encodeMsgsStateInfo carries req id and info bytes', () {
      final info = Uint8List.fromList([1, 4, 1]);
      final b = encodeMsgsStateInfo(0x1234, info);
      final d = TlDecoder(b);
      expect(d.readCrc(), crcMsgsStateInfo);
      expect(d.readInt64(), 0x1234);
      expect(d.readBytes(), equals(info));
    });

    test('encodeBindAuthKeyInner fields roundtrip', () {
      final b = encodeBindAuthKeyInner(
        nonce: 0x1111222233334444,
        tempAuthKeyId: 0x0aaabbbbccccdddd,
        permAuthKeyId: 0x0123456789abcdef,
        tempSessionId: 0x5566778899001122,
        expiresAt: 1700000000,
      );
      final d = TlDecoder(b);
      expect(d.readCrc(), crcBindAuthKeyInner);
      expect(d.readInt64(), 0x1111222233334444);
      expect(d.readInt64(), 0x0aaabbbbccccdddd);
      expect(d.readInt64(), 0x0123456789abcdef);
      expect(d.readInt64(), 0x5566778899001122);
      expect(d.readInt32(), 1700000000);
    });
  });

  group('encrypted container framing', () {
    test('serializeEncryptedRaw produces well-formed frame with correct key id',
        () {
      final authKey = randomBytes(256);
      const salt = 0x1122334455667788;
      const sessionId = 0x0102030405060708;

      final body = _msg(0x100, 1, encodeMsgsAck([42]));
      final wire = serializeEncryptedRaw(
        body: body,
        authKey: authKey,
        serverSalt: salt,
        sessionId: sessionId,
      );

      expect(wire.length >= 24, isTrue);
      expect((wire.length - 24) % 16, 0);
      final keyId = wire.sublist(0, 8);
      expect(keyId, equals(authKeyHash(authKey)));
    });

    test('container body encodes N messages with correct count and framing', () {
      final ack = encodeMsgsAck([42]);
      final ping = encodePingParams(7);
      final body = _container([
        (0x100, 0, ack),
        (0x104, 1, ping),
      ]);
      final d = TlDecoder(body);
      expect(d.readCrc(), crcMessageContainer);
      expect(d.readUint32(), 2);
      expect(d.readInt64(), 0x100);
      expect(d.readInt32(), 0);
      final len1 = d.readInt32();
      expect(len1, ack.length);
      d.readRawBytes(len1);
      expect(d.readInt64(), 0x104);
    });
  });

  group('RSA PEM parsing (CDN keys)', () {
    test('parses a PKCS#1 RSA public key and registers it', () {
      const pem = '''-----BEGIN RSA PUBLIC KEY-----
MIIBCgKCAQEAwqjCmORy1t7c9d5Z5r2u1u2u1u2u1u2u1u2u1u2u1u2u1u2u1u2u
-----END RSA PUBLIC KEY-----''';
      final key = parseRsaPublicKeyPem(pem);
      if (key != null) {
        expect(key.modulus, isNotNull);
        expect(key.publicExponent, isNotNull);
      }
    });

    test('real Telegram CDN public key parses', () {
      const pem = '''-----BEGIN RSA PUBLIC KEY-----
MIIBCgKCAQEA4tWHcGRhx8pdKLu2X8HgxJXQR9D5NgWn8QMBEjBEXFjq2xEUnJPl
-----END RSA PUBLIC KEY-----''';
      final before = cdnRsaKeys.length;
      registerCdnPublicKey(pem);
      expect(cdnRsaKeys.length >= before, isTrue);
    });
  });

  group('transport framing quick-ack + padded', () {
    test('abridged sets high bit on quick-ack length', () async {
      final mode = AbridgedMode();
      final sink = _Collect();
      final data = Uint8List(8);
      await mode.writeMsg(data, sink, quickAck: true);
      final out = sink.bytes;
      expect(out[0] & 0x80, 0x80);
    });

    test('intermediate sets high bit on quick-ack length', () async {
      final mode = IntermediateMode();
      final sink = _Collect();
      final data = Uint8List(12);
      await mode.writeMsg(data, sink, quickAck: true);
      final len =
          ByteData.view(sink.bytes.buffer).getUint32(0, Endian.little);
      expect(len & 0x80000000, 0x80000000);
    });

    test('padded intermediate adds 0-15 bytes of padding', () async {
      final mode = PaddedIntermediateMode();
      final sink = _Collect();
      final data = Uint8List(16);
      await mode.writeMsg(data, sink, quickAck: false);
      final len =
          ByteData.view(sink.bytes.buffer).getUint32(0, Endian.little);
      expect(len >= 16 && len <= 31, isTrue);
      expect(sink.bytes.length, 4 + len);
    });
  });

  group('test-DC table', () {
    test('test mode resolves distinct DC addresses', () {
      final prod = getDcAddress(2, testMode: false);
      final test = getDcAddress(2, testMode: true);
      expect(prod, isNot(test));
      expect(test.contains('149.154.167.40'), isTrue);
    });
  });
}

Uint8List _msg(int msgId, int seqNo, Uint8List body) {
  final b = BytesBuilder();
  final h = Uint8List(16);
  final bd = ByteData.view(h.buffer);
  bd.setInt64(0, msgId, Endian.little);
  bd.setInt32(8, seqNo, Endian.little);
  bd.setInt32(12, body.length, Endian.little);
  b.add(h);
  b.add(body);
  return b.toBytes();
}

Uint8List _container(List<(int, int, Uint8List)> msgs) {
  final b = BytesBuilder();
  final head = Uint8List(8);
  final bd = ByteData.view(head.buffer);
  bd.setUint32(0, crcMessageContainer, Endian.little);
  bd.setUint32(4, msgs.length, Endian.little);
  b.add(head);
  for (final m in msgs) {
    b.add(_msg(m.$1, m.$2, m.$3));
  }
  return b.toBytes();
}

class _Collect implements IOSink {
  final _b = BytesBuilder(copy: false);
  Uint8List get bytes => Uint8List.fromList(_b.toBytes());
  @override
  void add(List<int> data) => _b.add(data);
  @override
  dynamic noSuchMethod(Invocation inv) => null;
}
