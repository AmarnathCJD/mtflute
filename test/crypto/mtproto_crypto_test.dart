import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:mtflute/src/crypto/mtproto_crypto.dart';

void main() {
  group('SHA', () {
    test('sha1 produces 20 bytes', () {
      final hash = sha1(Uint8List.fromList([1, 2, 3]));
      expect(hash.length, 20);
    });

    test('sha256 produces 32 bytes', () {
      final hash = sha256(Uint8List.fromList([1, 2, 3]));
      expect(hash.length, 32);
    });

    test('sha1 is deterministic', () {
      final data = Uint8List.fromList([0x41, 0x42, 0x43]);
      expect(sha1(data), equals(sha1(data)));
    });
  });

  group('randomBytes', () {
    test('returns correct length', () {
      expect(randomBytes(16).length, 16);
      expect(randomBytes(32).length, 32);
      expect(randomBytes(0).length, 0);
    });
  });

  group('authKeyHash', () {
    test('returns last 8 bytes of sha1', () {
      final key = Uint8List(256);
      for (var i = 0; i < 256; i++) {
        key[i] = i;
      }

      final hash = authKeyHash(key);
      expect(hash.length, 8);

      final fullHash = sha1(key);
      expect(hash, equals(fullHash.sublist(12)));
    });
  });

  group('MTProto 2.0 encrypt/decrypt', () {
    test('encrypt produces different output than input', () {
      final authKey = randomBytes(256);
      final msg = Uint8List.fromList(List.generate(64, (i) => i));

      final enc = encryptMessage(msg, authKey);
      expect(enc.data.isNotEmpty, true);
      expect(enc.data, isNot(equals(msg)));
      expect(enc.msgKey.length, 16);
      // Encrypted data is at least as long as padded input
      expect(enc.data.length >= msg.length, true);
      expect(enc.data.length % 16, 0);
    });

    test('AES key derivation differs for encode vs decode', () {
      final authKey = randomBytes(256);
      final msgKey = randomBytes(16);

      final enc = aesKeys(msgKey, authKey);
      final dec = aesKeys(msgKey, authKey, decode: true);
      expect(enc.aesKey, isNot(equals(dec.aesKey)));
    });

    test('message key is 16 bytes', () {
      final authKey = randomBytes(256);
      final msg = Uint8List.fromList(List.generate(32, (i) => i));
      final enc = encryptMessage(msg, authKey);
      expect(enc.msgKey.length, 16);
    });
  });

  group('MTProto 1.0 encrypt', () {
    test('encryptV1 produces data and msgKey', () {
      final authKey = randomBytes(256);
      final plaintext = Uint8List.fromList(List.generate(48, (i) => i * 3));

      final result = encryptV1(plaintext, authKey);
      expect(result.data.isNotEmpty, true);
      expect(result.msgKey.length, 16);
    });
  });

  group('temp keys for handshake', () {
    test('generateTempKeys produces 32-byte key and iv', () {
      final ns = BigInt.parse('12345678901234567890123456789012', radix: 16);
      final sn = BigInt.parse('abcdef0123456789', radix: 16);

      final keys = generateTempKeys(ns, sn);
      expect(keys.key.length, 32);
      expect(keys.iv.length, 32);
    });

    test('handshake encrypt/decrypt roundtrip', () {
      final ns = BigInt.parse(
        'aabbccdd11223344556677889900aabb11223344556677889900aabbccddeeff',
        radix: 16,
      );
      final sn = BigInt.parse('1122334455667788aabbccdd', radix: 16);

      final msg = Uint8List.fromList(List.generate(100, (i) => i));
      final encrypted = encryptHandshakeMessage(msg, ns, sn);
      final decrypted = decryptHandshakeMessage(encrypted, ns, sn);
      expect(decrypted, equals(msg));
    });
  });

  group('AES CBC', () {
    test('encrypt/decrypt roundtrip', () {
      final key = Uint8List(16)..fillRange(0, 16, 0x42);
      final data = Uint8List.fromList('Hello MTProto World!'.codeUnits);

      final encrypted = aesCbcEncrypt(data, key);
      final decrypted = aesCbcDecrypt(encrypted, key);
      expect(decrypted, equals(data));
    });
  });

  group('bigInt conversions', () {
    test('roundtrip', () {
      final original = BigInt.parse('deadbeef01234567', radix: 16);
      final bytes = bigIntToUnsignedBytes(original);
      final recovered = bytesToBigInt(bytes);
      expect(recovered, equals(original));
    });

    test('bigIntToBytes pads correctly', () {
      final val = BigInt.from(0xff);
      final bytes = bigIntToBytes(val, 8);
      expect(bytes.length, 8);
      expect(bytes[0], 0xff);
    });
  });
}
