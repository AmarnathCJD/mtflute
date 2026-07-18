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

bool _millerRabin(BigInt n, {int rounds = 30}) {
  if (n < BigInt.two) return false;
  if (n == BigInt.two || n == BigInt.from(3)) return true;
  if (n.isEven) return false;

  var d = n - BigInt.one;
  var r = 0;
  while (d.isEven) {
    d >>= 1;
    r++;
  }

  final rng = Random.secure();
  final nMinus2 = n - BigInt.two;
  for (var i = 0; i < rounds; i++) {
    BigInt a;
    do {
      final bytes = List<int>.generate(
          (n.bitLength + 7) ~/ 8, (_) => rng.nextInt(256));
      var x = BigInt.zero;
      for (final b in bytes) {
        x = (x << 8) | BigInt.from(b);
      }
      a = BigInt.two + (x % nMinus2);
    } while (a < BigInt.two || a > nMinus2);

    var x = a.modPow(d, n);
    if (x == BigInt.one || x == n - BigInt.one) continue;
    var composite = true;
    for (var j = 0; j < r - 1; j++) {
      x = x.modPow(BigInt.two, n);
      if (x == n - BigInt.one) {
        composite = false;
        break;
      }
    }
    if (composite) return false;
  }
  return true;
}

BigInt? _cachedGoodPrime;

void validateDHParams(int g, BigInt gA, BigInt dhPrime) {
  if (dhPrime.bitLength != 2048) {
    throw ArgumentError('dh_prime is not 2048 bits (got ${dhPrime.bitLength})');
  }
  if (g < 2 || g > 7) {
    throw ArgumentError('g out of range [2, 7]: $g');
  }

  // dh_prime must be a safe prime: both p and (p-1)/2 prime. This is
  // expensive, so cache the last verified prime (the server reuses it).
  if (_cachedGoodPrime != dhPrime) {
    if (!_millerRabin(dhPrime) || !_millerRabin((dhPrime - BigInt.one) >> 1)) {
      throw ArgumentError('dh_prime is not a safe prime');
    }
    _cachedGoodPrime = dhPrime;
  }

  _checkGeneratorResidue(g, dhPrime);

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

// Per the spec, g must be a quadratic residue mod p (so it generates the
// full 2q-order subgroup). For the fixed generators Telegram uses, the
// condition depends on p mod {8, 12, ...}.
void _checkGeneratorResidue(int g, BigInt p) {
  final BigInt r;
  switch (g) {
    case 2:
      r = p % BigInt.from(8);
      if (r != BigInt.from(7)) throw ArgumentError('bad g=2 for this dh_prime');
    case 3:
      r = p % BigInt.from(3);
      if (r != BigInt.two) throw ArgumentError('bad g=3 for this dh_prime');
    case 4:
      break; // 4 is a square; always a QR
    case 5:
      r = p % BigInt.from(5);
      if (r != BigInt.one && r != BigInt.from(4)) {
        throw ArgumentError('bad g=5 for this dh_prime');
      }
    case 6:
      r = p % BigInt.from(24);
      if (r != BigInt.from(19) && r != BigInt.from(23)) {
        throw ArgumentError('bad g=6 for this dh_prime');
      }
    case 7:
      r = p % BigInt.from(7);
      if (r != BigInt.from(3) && r != BigInt.from(5) && r != BigInt.from(6)) {
        throw ArgumentError('bad g=7 for this dh_prime');
      }
    default:
      throw ArgumentError('unsupported g=$g');
  }
}

void validateGB(BigInt gB, BigInt dhPrime) {
  final two = BigInt.two;
  final upper = dhPrime - two;
  if (gB < two || gB > upper) {
    throw ArgumentError('g_b out of range [2, dh_prime-2]');
  }
  final lowerSafe = BigInt.one << 1984;
  final upperSafe = dhPrime - lowerSafe;
  if (gB < lowerSafe || gB > upperSafe) {
    throw ArgumentError('g_b outside recommended range');
  }
}
