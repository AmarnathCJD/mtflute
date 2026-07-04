import 'dart:math';
import 'dart:typed_data';

import 'mtproto_crypto.dart';

void xorBytes(Uint8List dst, Uint8List src) {
  for (var i = 0; i < dst.length; i++) {
    dst[i] ^= src[i];
  }
}

({BigInt p, BigInt q}) factorize(BigInt pq) {
  if (pq.bitLength <= 64) {
    final pqInt = pq.toInt();
    final (p, q) = _factorizeInt(pqInt);
    if (p == 0 || q == 0) return splitPQ(pq);
    return (p: BigInt.from(p), q: BigInt.from(q));
  }
  return splitPQ(pq);
}

(int, int) _factorizeInt(int n) {
  if (n % 2 == 0) return (2, n ~/ 2);
  if (n < 3) return (1, n);

  const maxIterPerTry = 1000000;

  for (var c = 1; c < 32; c++) {
    var y = 2;
    var r = 1;
    var g = 1;
    var q = 1;
    var iter = 0;

    while (g == 1 && iter < maxIterPerTry) {
      final x = y;
      for (var i = 0; i < r; i++) {
        y = _fStep(y, c, n);
      }

      var k = 0;
      while (k < r && g == 1 && iter < maxIterPerTry) {
        final ys = y;
        final limit = (r - k) < 128 ? (r - k) : 128;

        for (var j = 0; j < limit; j++) {
          y = _fStep(y, c, n);
          var diff = x - y;
          if (diff < 0) diff = -diff;
          if (diff == 0) break;
          q = _mulmod(q, diff, n);
          iter++;
          if (iter >= maxIterPerTry) break;
        }

        if (q != 0) {
          g = q.gcd(n);
        } else {
          var diff = x - ys;
          if (diff < 0) diff = -diff;
          g = diff.gcd(n);
        }

        k += limit;
      }

      r <<= 1;
    }

    if (g == n || g == 1) continue;

    var p = g;
    var qr = n ~/ g;
    if (p > qr) {
      final tmp = p;
      p = qr;
      qr = tmp;
    }
    return (p, qr);
  }

  return (0, 0);
}

int _fStep(int x, int c, int n) {
  x = _mulmod(x, x, n);
  x += c;
  if (x >= n) x -= n;
  return x;
}

int _mulmod(int a, int b, int mod) {
  // Dart's int is 64-bit, use BigInt for overflow safety
  final result = (BigInt.from(a) * BigInt.from(b)) % BigInt.from(mod);
  return result.toInt();
}

({BigInt p, BigInt q}) splitPQ(BigInt pq) {
  var p = BigInt.from(pq.toInt());
  var q = BigInt.one;

  var x = BigInt.two;
  var y = BigInt.two;
  var d = BigInt.one;

  while (d == BigInt.one) {
    x = _f(x, pq);
    y = _f(_f(y, pq), pq);

    var temp = x - y;
    if (temp < BigInt.zero) temp = -temp;
    d = temp.gcd(pq);
  }

  p = d;
  q = pq ~/ d;

  if (p > q) {
    final tmp = p;
    p = q;
    q = tmp;
  }

  return (p: p, q: q);
}

BigInt _f(BigInt x, BigInt n) {
  return (x * x + BigInt.one) % n;
}

({BigInt b, BigInt gB, BigInt gAB}) makeGAB(int g, BigInt gA, BigInt dhPrime) {
  final rng = Random.secure();
  final randBytes = Uint8List(256);
  for (var i = 0; i < 256; i++) {
    randBytes[i] = rng.nextInt(256);
  }
  final b = bytesToBigInt(randBytes) % (BigInt.one << 2048);
  final gB = BigInt.from(g).modPow(b, dhPrime);
  final gAB = gA.modPow(b, dhPrime);

  return (b: b, gB: gB, gAB: gAB);
}

void validateDHParams(int g, BigInt gA, BigInt dhPrime) {
  if (dhPrime.bitLength != 2048) {
    throw ArgumentError('dh_prime is not 2048 bits (got ${dhPrime.bitLength})');
  }
  if (g < 2 || g > 7) {
    throw ArgumentError('g out of range [2, 7]: $g');
  }

  final two = BigInt.two;
  final upper = dhPrime - two;
  if (gA < two || gA > upper) {
    throw ArgumentError('g_a out of range [2, dh_prime-2]');
  }

  final lowerSafe = BigInt.one << 1984;
  final upperSafe = dhPrime - lowerSafe;
  if (gA < lowerSafe || gA > upperSafe) {
    throw ArgumentError('g_a outside recommended range');
  }
}

void validateGB(BigInt gB, BigInt dhPrime) {
  final two = BigInt.two;
  final upper = dhPrime - two;
  if (gB < two || gB > upper) {
    throw ArgumentError('g_b out of range [2, dh_prime-2]');
  }
}
