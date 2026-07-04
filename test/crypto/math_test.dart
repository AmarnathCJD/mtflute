import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:mtflute/src/crypto/math.dart';

void main() {
  group('factorize', () {
    test('factors small composite', () {
      final result = factorize(BigInt.from(15));
      expect(result.p, BigInt.from(3));
      expect(result.q, BigInt.from(5));
    });

    test('factors typical MTProto PQ', () {
      final pq = BigInt.from(1724114033281923457);
      final result = factorize(pq);
      expect(result.p * result.q, pq);
      expect(result.p < result.q, true);
    });

    test('factors even number', () {
      final result = factorize(BigInt.from(100));
      expect(result.p * result.q, BigInt.from(100));
      expect(result.p <= result.q, true);
    });

    test('factors product of two primes', () {
      final p = BigInt.from(1229);
      final q = BigInt.from(2687);
      final pq = p * q;
      final result = factorize(pq);
      expect(result.p, p);
      expect(result.q, q);
    });
  });

  group('splitPQ', () {
    test('splits composite', () {
      final pq = BigInt.from(35);
      final result = splitPQ(pq);
      expect(result.p * result.q, pq);
      expect(result.p <= result.q, true);
    });
  });

  group('DH validation', () {
    test('validateDHParams rejects bad g', () {
      final prime = BigInt.two.pow(2048) - BigInt.one;
      expect(
        () => validateDHParams(1, BigInt.from(100), prime),
        throwsArgumentError,
      );
      expect(
        () => validateDHParams(8, BigInt.from(100), prime),
        throwsArgumentError,
      );
    });

    test('validateGB rejects out of range', () {
      final prime = BigInt.from(1000);
      expect(() => validateGB(BigInt.one, prime), throwsArgumentError);
      expect(() => validateGB(prime - BigInt.one, prime), throwsArgumentError);
    });

    test('validateGB accepts valid value', () {
      final prime = BigInt.from(1000);
      expect(() => validateGB(BigInt.from(500), prime), returnsNormally);
    });
  });

  group('xorBytes', () {
    test('xors correctly', () {
      final a = [0xff, 0x00, 0xaa, 0x55].map((e) => e).toList();
      final aTyped = Uint8List.fromList(a);
      final b = Uint8List.fromList([0x0f, 0xf0, 0x55, 0xaa]);
      xorBytes(aTyped, b);
      expect(aTyped, equals([0xf0, 0xf0, 0xff, 0xff]));
    });
  });
}
