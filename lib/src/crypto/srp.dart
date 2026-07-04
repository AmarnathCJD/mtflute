import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;
import 'package:pointycastle/export.dart';
import 'mtproto_crypto.dart';

class SrpAnswer {
  final Uint8List ga;
  final Uint8List m1;
  SrpAnswer({required this.ga, required this.m1});
}

SrpAnswer? computeSrpCheck({
  required String password,
  required Uint8List srpB,
  required Uint8List salt1,
  required Uint8List salt2,
  required int g,
  required Uint8List p,
}) {
  if (password.isEmpty) return null;

  final pBig = bytesToBigInt(p);
  final gBig = BigInt.from(g);
  final gBytes = _pad256(bigIntToUnsignedBytes(gBig));
  final a = bytesToBigInt(randomBytes(256));
  final ga = _pad256(bigIntToUnsignedBytes(gBig.modPow(a, pBig)));
  final gb = _pad256(srpB);

  final u = bytesToBigInt(_sha256Multi([ga, gb]));
  final x = bytesToBigInt(
    _passwordHash2(Uint8List.fromList(password.codeUnits), salt1, salt2),
  );
  final v = gBig.modPow(x, pBig);
  final k = bytesToBigInt(_sha256Multi([p, gBytes]));

  var kv = (k * v) % pBig;
  var t = bytesToBigInt(srpB) - kv;
  if (t < BigInt.zero) t += pBig;

  final sa = _pad256(bigIntToUnsignedBytes(t.modPow(u * x + a, pBig)));
  final ka = _sha256Multi([sa]);

  final m1 = _sha256Multi([
    _xorBytes(_sha256Multi([p]), _sha256Multi([gBytes])),
    _sha256Multi([salt1]),
    _sha256Multi([salt2]),
    ga,
    gb,
    ka,
  ]);

  return SrpAnswer(ga: ga, m1: m1);
}

Uint8List _pad256(Uint8List b) {
  if (b.length >= 256) return Uint8List.fromList(b.sublist(b.length - 256));
  final tmp = Uint8List(256);
  tmp.setRange(256 - b.length, 256, b);
  return tmp;
}

Uint8List _sha256Multi(List<Uint8List> arrays) {
  final all = <int>[];
  for (final arr in arrays) {
    all.addAll(arr);
  }
  return Uint8List.fromList(crypto.sha256.convert(all).bytes);
}

Uint8List _saltHash(Uint8List data, Uint8List salt) {
  return _sha256Multi([salt, data, salt]);
}

Uint8List _passwordHash1(Uint8List password, Uint8List salt1, Uint8List salt2) {
  return _saltHash(_saltHash(password, salt1), salt2);
}

Uint8List _passwordHash2(Uint8List password, Uint8List salt1, Uint8List salt2) {
  final hash1 = _passwordHash1(password, salt1, salt2);
  final pbkdf = _pbkdf2Sha512(hash1, salt1, 100000);
  return _saltHash(pbkdf, salt2);
}

Uint8List _pbkdf2Sha512(Uint8List password, Uint8List salt, int iterations) {
  final derivator = PBKDF2KeyDerivator(HMac(SHA512Digest(), 128))
    ..init(Pbkdf2Parameters(salt, iterations, 64));
  return derivator.process(password);
}

Uint8List _xorBytes(Uint8List a, Uint8List b) {
  final result = Uint8List(a.length);
  for (var i = 0; i < a.length; i++) {
    result[i] = a[i] ^ b[i];
  }
  return result;
}
