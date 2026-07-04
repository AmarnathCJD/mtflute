import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:mtflute/src/crypto/aes_ige.dart';

void main() {
  group('AES-IGE', () {
    test('encrypt then decrypt roundtrip', () {
      final key = Uint8List(32);
      final iv = Uint8List(32);
      for (var i = 0; i < 32; i++) {
        key[i] = i;
        iv[i] = i + 32;
      }

      final plaintext = Uint8List(64);
      for (var i = 0; i < 64; i++) {
        plaintext[i] = i & 0xff;
      }

      final encrypted = aesIgeEncrypt(plaintext, key, iv);
      expect(encrypted.length, plaintext.length);
      expect(encrypted, isNot(equals(plaintext)));

      final decrypted = aesIgeDecrypt(encrypted, key, iv);
      expect(decrypted, equals(plaintext));
    });

    test('different keys produce different ciphertext', () {
      final key1 = Uint8List(32)..fillRange(0, 32, 0xaa);
      final key2 = Uint8List(32)..fillRange(0, 32, 0xbb);
      final iv = Uint8List(32)..fillRange(0, 32, 0xcc);
      final data = Uint8List(32)..fillRange(0, 32, 0xdd);

      final enc1 = aesIgeEncrypt(data, key1, iv);
      final enc2 = aesIgeEncrypt(data, key2, iv);
      expect(enc1, isNot(equals(enc2)));
    });

    test('rejects non-block-aligned data', () {
      final key = Uint8List(32);
      final iv = Uint8List(32);
      final data = Uint8List(17);
      expect(() => aesIgeEncrypt(data, key, iv), throwsArgumentError);
      expect(() => aesIgeDecrypt(data, key, iv), throwsArgumentError);
    });

    test('rejects wrong key size', () {
      final key = Uint8List(16);
      final iv = Uint8List(32);
      final data = Uint8List(16);
      expect(() => aesIgeEncrypt(data, key, iv), throwsArgumentError);
    });

    test('rejects wrong iv size', () {
      final key = Uint8List(32);
      final iv = Uint8List(16);
      final data = Uint8List(16);
      expect(() => aesIgeEncrypt(data, key, iv), throwsArgumentError);
    });

    test('single block roundtrip', () {
      final key = Uint8List(32)..fillRange(0, 32, 0x42);
      final iv = Uint8List(32)..fillRange(0, 32, 0x13);
      final data = Uint8List(16)..fillRange(0, 16, 0x07);

      final encrypted = aesIgeEncrypt(data, key, iv);
      final decrypted = aesIgeDecrypt(encrypted, key, iv);
      expect(decrypted, equals(data));
    });
  });
}
