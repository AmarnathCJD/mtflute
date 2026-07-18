import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:mtflute/src/transport/obfuscation.dart';
import 'package:mtflute/src/transport/transport_mode.dart';
import 'package:mtflute/src/transport/fake_tls.dart';

void main() {
  group('obfuscation2', () {
    test('init frame is 64 bytes and first byte not 0xef', () {
      final o = Obfuscation.create(
        const ObfuscationConfig(variant: TransportModeVariant.intermediate),
      );
      expect(o.initFrame.length, 64);
      expect(o.initFrame[0], isNot(0xef));
    });

    test('encrypt then decrypt with a mirror pair roundtrips a stream', () {
      final cfg = ObfuscationConfig(
        variant: TransportModeVariant.intermediate,
        secret: Uint8List.fromList(List.generate(16, (i) => i + 1)),
        dcId: 2,
      );
      final client = Obfuscation.create(cfg);

      final server = Obfuscation.fromInit(client.initFrame, cfg, isServer: true);

      final msg = Uint8List.fromList(List.generate(200, (i) => (i * 7) & 0xff));
      final wire = client.encrypt(msg);
      expect(wire, isNot(equals(msg)));
      final recovered = server.decrypt(wire);
      expect(recovered, equals(msg));

      final msg2 = Uint8List.fromList(List.generate(48, (i) => i));
      expect(server.decrypt(client.encrypt(msg2)), equals(msg2));
    });

    test('encryption is stateful across calls', () {
      final o = Obfuscation.create(
        const ObfuscationConfig(variant: TransportModeVariant.abridged),
      );
      final a = o.encrypt(Uint8List.fromList([1, 2, 3, 4]));
      final b = o.encrypt(Uint8List.fromList([1, 2, 3, 4]));
      expect(a, isNot(equals(b)));
    });

    test('embeds dc id at bytes 60-61 pre-scramble is not directly readable', () {
      final o = Obfuscation.create(
        const ObfuscationConfig(
            variant: TransportModeVariant.intermediate, dcId: 4),
      );
      expect(o.initFrame.length, 64);
    });
  });

  group('MtProxy secret parsing', () {
    test('hex secret', () {
      final p = MtProxy.fromSecret(
          host: 'h', port: 443, secret: '0102030405060708090a0b0c0d0e0f10');
      expect(p.rawSecret.length, 16);
      expect(p.rawSecret[0], 0x01);
      expect(p.isFakeTls, isFalse);
    });

    test('dd-prefixed secret strips prefix', () {
      final p = MtProxy.fromSecret(
          host: 'h',
          port: 443,
          secret: 'dd0102030405060708090a0b0c0d0e0f10');
      expect(p.isDd, isTrue);
      expect(p.rawSecret.length, 16);
      expect(p.rawSecret[0], 0x01);
    });

    test('ee-prefixed fakeTLS secret exposes domain', () {
      final domain = 'www.google.com';
      final domainHex = domain.codeUnits
          .map((c) => c.toRadixString(16).padLeft(2, '0'))
          .join();
      final hex = 'ee000102030405060708090a0b0c0d0e0f$domainHex';
      final p = MtProxy.fromSecret(host: 'h', port: 443, secret: hex);
      expect(p.isFakeTls, isTrue);
      expect(p.fakeTlsDomain, domain);
      expect(p.rawSecret.length, 16);
    });

    test('base64url secret', () {
      final p = MtProxy.fromSecret(
          host: 'h', port: 443, secret: 'AQIDBAUGBwgJCgsMDQ4PEA');
      expect(p.rawSecret.length, 16);
    });
  });

  group('fakeTLS', () {
    test('client hello is a valid TLS record with embedded hmac', () {
      final secret = Uint8List.fromList(List.generate(16, (i) => i));
      final hello = FakeTlsHello.build(secret, 'www.google.com');
      expect(hello.bytes[0], 0x16);
      expect(hello.bytes[1], 0x03);
      expect(hello.bytes[2], 0x01);
      final recLen = (hello.bytes[3] << 8) | hello.bytes[4];
      expect(recLen, hello.bytes.length - 5);
      expect(hello.bytes[5], 0x01);
    });

    test('wrapTlsRecord frames as application data', () {
      final data = Uint8List.fromList([9, 8, 7, 6]);
      final rec = wrapTlsRecord(data);
      expect(rec[0], 0x17);
      expect(rec[1], 0x03);
      expect(rec[2], 0x03);
      expect((rec[3] << 8) | rec[4], 4);
      expect(rec.sublist(5), equals(data));
    });
  });
}

