import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:pointycastle/export.dart';

import 'aes_ige.dart';
import 'decrypt_pool.dart';

Uint8List sha1(Uint8List data) =>
    Uint8List.fromList(crypto.sha1.convert(data).bytes);

Uint8List sha256(Uint8List data) =>
    Uint8List.fromList(crypto.sha256.convert(data).bytes);

Uint8List randomBytes(int length) {
  final rng = Random.secure();
  return Uint8List.fromList(List.generate(length, (_) => rng.nextInt(256)));
}

Uint8List authKeyHash(Uint8List authKey) {
  final hash = sha1(authKey);
  return hash.sublist(hash.length - 8);
}

Uint8List messageKey(
  Uint8List authKey,
  Uint8List msgPadded, {
  bool decode = false,
}) {
  final x = decode ? 8 : 0;
  final h = crypto.sha256.convert([
    ...authKey.sublist(88 + x, 88 + x + 32),
    ...msgPadded,
  ]);
  return Uint8List.fromList(h.bytes.sublist(8, 24));
}

({Uint8List aesKey, Uint8List aesIv}) aesKeys(
  Uint8List msgKey,
  Uint8List authKey, {
  bool decode = false,
}) {
  final x = decode ? 8 : 0;

  final sha256a = sha256(
    Uint8List.fromList([...msgKey, ...authKey.sublist(x, x + 36)]),
  );

  final sha256b = sha256(
    Uint8List.fromList([...authKey.sublist(40 + x, 40 + x + 36), ...msgKey]),
  );

  final aesKey = Uint8List(32);
  aesKey.setRange(0, 8, sha256a.sublist(0, 8));
  aesKey.setRange(8, 24, sha256b.sublist(8, 24));
  aesKey.setRange(24, 32, sha256a.sublist(24, 32));

  final aesIv = Uint8List(32);
  aesIv.setRange(0, 8, sha256b.sublist(0, 8));
  aesIv.setRange(8, 24, sha256a.sublist(8, 24));
  aesIv.setRange(24, 32, sha256b.sublist(24, 32));

  return (aesKey: aesKey, aesIv: aesIv);
}

({Uint8List aesKey, Uint8List aesIv}) aesKeysV1(
  Uint8List msgKey,
  Uint8List authKey, {
  bool decode = false,
}) {
  final x = decode ? 8 : 0;

  final sha1a = sha1(
    Uint8List.fromList([...msgKey, ...authKey.sublist(x, x + 32)]),
  );
  final sha1b = sha1(
    Uint8List.fromList([
      ...authKey.sublist(32 + x, 32 + x + 16),
      ...msgKey,
      ...authKey.sublist(48 + x, 48 + x + 16),
    ]),
  );
  final sha1c = sha1(
    Uint8List.fromList([...authKey.sublist(64 + x, 64 + x + 32), ...msgKey]),
  );
  final sha1d = sha1(
    Uint8List.fromList([...msgKey, ...authKey.sublist(96 + x, 96 + x + 32)]),
  );

  final aesKey = Uint8List(32);
  aesKey.setRange(0, 8, sha1a.sublist(0, 8));
  aesKey.setRange(8, 20, sha1b.sublist(8, 20));
  aesKey.setRange(20, 32, sha1c.sublist(4, 16));

  final aesIv = Uint8List(32);
  aesIv.setRange(0, 12, sha1a.sublist(8, 20));
  aesIv.setRange(12, 20, sha1b.sublist(0, 8));
  aesIv.setRange(20, 24, sha1c.sublist(16, 20));
  aesIv.setRange(24, 32, sha1d.sublist(0, 8));

  return (aesKey: aesKey, aesIv: aesIv);
}

({Uint8List data, Uint8List msgKey}) encryptMessage(
  Uint8List msg,
  Uint8List authKey,
) {
  final padding = 16 + ((16 - (msg.length % 16)) & 15);
  final padded = Uint8List(msg.length + padding);
  padded.setRange(0, msg.length, msg);
  padded.setRange(msg.length, padded.length, randomBytes(padding));

  final msgK = messageKey(authKey, padded);
  final keys = aesKeys(msgK, authKey);
  final encrypted = aesIgeEncrypt(padded, keys.aesKey, keys.aesIv);

  return (data: encrypted, msgKey: msgK);
}

Uint8List decryptMessage(Uint8List msg, Uint8List authKey, Uint8List msgKey) {
  final keys = aesKeys(msgKey, authKey, decode: true);
  return aesIgeDecrypt(msg, keys.aesKey, keys.aesIv);
}

const int kOffloadDecryptBytes = 128 * 1024;

Future<Uint8List> decryptMessageAsync(
    Uint8List msg, Uint8List authKey, Uint8List msgKey) async {
  final keys = aesKeys(msgKey, authKey, decode: true);
  if (msg.length < kOffloadDecryptBytes) {
    return aesIgeDecrypt(msg, keys.aesKey, keys.aesIv);
  }
  return DecryptPool.instance.decrypt(msg, keys.aesKey, keys.aesIv);
}

({Uint8List data, Uint8List msgKey}) encryptV1(
  Uint8List plaintext,
  Uint8List authKey,
) {
  final hash = sha1(plaintext);
  final msgK = Uint8List.fromList(hash.sublist(4, 20));
  final keys = aesKeysV1(msgK, authKey);

  final padding = (16 - (plaintext.length % 16)) % 16;
  final padded = Uint8List(plaintext.length + padding);
  padded.setRange(0, plaintext.length, plaintext);
  if (padding > 0) {
    padded.setRange(plaintext.length, padded.length, randomBytes(padding));
  }

  final encrypted = aesIgeEncrypt(padded, keys.aesKey, keys.aesIv);
  return (data: encrypted, msgKey: msgK);
}

({Uint8List key, Uint8List iv}) generateTempKeys(
  BigInt nonceSecond,
  BigInt nonceServer,
) {
  final ns = bigIntToBytes(nonceSecond, 32);
  final sn = bigIntToBytes(nonceServer, 16);

  final t1 = Uint8List(48);
  t1.setRange(0, 32, ns);
  t1.setRange(32, 48, sn);
  final hash1 = sha1(t1);

  final t2 = Uint8List(48);
  t2.setRange(0, 16, sn);
  t2.setRange(16, 48, ns);
  final hash2 = sha1(t2);

  final t3 = Uint8List(64);
  t3.setRange(0, 32, ns);
  t3.setRange(32, 64, ns);
  final hash3 = sha1(t3);

  final tmpKey = Uint8List(32);
  tmpKey.setRange(0, 20, hash1);
  tmpKey.setRange(20, 32, hash2.sublist(0, 12));

  final tmpIv = Uint8List(32);
  tmpIv.setRange(0, 8, hash2.sublist(12, 20));
  tmpIv.setRange(8, 28, hash3);
  tmpIv.setRange(28, 32, ns.sublist(0, 4));

  return (key: tmpKey, iv: tmpIv);
}

Uint8List decryptHandshakeMessage(
  Uint8List msg,
  BigInt nonceSecond,
  BigInt nonceServer,
) {
  final keys = generateTempKeys(nonceSecond, nonceServer);
  final decoded = aesIgeDecrypt(msg, keys.key, keys.iv);

  final decodedHash = decoded.sublist(0, 20);
  final decodedMessage = decoded.sublist(20);

  for (var i = decodedMessage.length; i > decodedMessage.length - 16; i--) {
    final candidateHash = sha1(
      Uint8List.fromList(decodedMessage.sublist(0, i)),
    );
    if (_bytesEqual(decodedHash, candidateHash)) {
      return Uint8List.fromList(decodedMessage.sublist(0, i));
    }
  }

  throw StateError('Could not trim handshake message: hashes incompatible');
}

Uint8List encryptHandshakeMessage(
  Uint8List msg,
  BigInt nonceSecond,
  BigInt nonceServer,
) {
  final hash = sha1(msg);
  final totalLen = hash.length + msg.length;
  final overflow = totalLen % 16;
  final pad = overflow == 0 ? 0 : 16 - overflow;

  final combined = Uint8List(totalLen + pad);
  combined.setRange(0, hash.length, hash);
  combined.setRange(hash.length, hash.length + msg.length, msg);
  if (pad > 0) {
    combined.setRange(totalLen, totalLen + pad, randomBytes(pad));
  }

  final keys = generateTempKeys(nonceSecond, nonceServer);
  return aesIgeEncrypt(combined, keys.key, keys.iv);
}

Uint8List rsaEncrypt(Uint8List block, RSAPublicKey key) {
  if (block.length != 255) {
    throw ArgumentError('Block must be exactly 255 bytes');
  }

  final z = bytesToBigInt(block);
  final c = z.modPow(key.publicExponent!, key.modulus!);

  final result = Uint8List(256);
  final cBytes = bigIntToUnsignedBytes(c);
  result.setRange(0, cBytes.length, cBytes);
  return result;
}

Uint8List bigIntToBytes(BigInt value, int length) {
  final bytes = bigIntToUnsignedBytes(value);
  if (bytes.length >= length) {
    return Uint8List.fromList(bytes.sublist(bytes.length - length, bytes.length));
  }
  final padded = Uint8List(length);
  padded.setRange(length - bytes.length, length, bytes);
  return padded;
}

Uint8List bigIntToUnsignedBytes(BigInt value) {
  if (value == BigInt.zero) return Uint8List(1);

  var hex = value.toRadixString(16);
  if (hex.length.isOdd) hex = '0$hex';

  final bytes = Uint8List(hex.length ~/ 2);
  for (var i = 0; i < bytes.length; i++) {
    bytes[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return bytes;
}

BigInt bytesToBigInt(Uint8List bytes) {
  var result = BigInt.zero;
  for (final b in bytes) {
    result = (result << 8) | BigInt.from(b);
  }
  return result;
}

bool _bytesEqual(Uint8List a, Uint8List b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

Uint8List aesCbcEncrypt(Uint8List data, Uint8List key) {
  final iv = randomBytes(16);
  final padding = 16 - (data.length % 16);
  final padded = Uint8List(data.length + padding);
  padded.setRange(0, data.length, data);
  for (var i = data.length; i < padded.length; i++) {
    padded[i] = padding;
  }

  final cipher = CBCBlockCipher(AESEngine())
    ..init(true, ParametersWithIV(KeyParameter(key), iv));

  final encrypted = Uint8List(padded.length);
  for (var offset = 0; offset < padded.length; offset += 16) {
    cipher.processBlock(padded, offset, encrypted, offset);
  }

  return Uint8List.fromList([...iv, ...encrypted]);
}

Uint8List aesCbcDecrypt(Uint8List data, Uint8List key) {
  if (data.length < 32 || data.length % 16 != 0) {
    throw ArgumentError('Invalid encrypted data');
  }

  final iv = data.sublist(0, 16);
  final encrypted = data.sublist(16);

  final cipher = CBCBlockCipher(AESEngine())
    ..init(false, ParametersWithIV(KeyParameter(key), iv));

  final decrypted = Uint8List(encrypted.length);
  for (var offset = 0; offset < encrypted.length; offset += 16) {
    cipher.processBlock(encrypted, offset, decrypted, offset);
  }

  final padding = decrypted.last;
  if (padding < 1 || padding > 16) {
    throw StateError('Invalid PKCS7 padding');
  }
  return Uint8List.fromList(decrypted.sublist(0, decrypted.length - padding));
}
