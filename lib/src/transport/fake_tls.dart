import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

Uint8List _hmacSha256(Uint8List key, Uint8List data) {
  final h = HMac(SHA256Digest(), 64)..init(KeyParameter(key));
  h.update(data, 0, data.length);
  final out = Uint8List(32);
  h.doFinal(out, 0);
  return out;
}

class FakeTlsHello {
  final Uint8List bytes;
  FakeTlsHello(this.bytes);

  static FakeTlsHello build(Uint8List secret, String domain) {
    final rng = Random.secure();
    final greaseSeed = List.generate(7, (_) => rng.nextInt(256));
    Uint8List grease(int i) {
      final b = (greaseSeed[i] & 0xf0) | 0x0a;
      return Uint8List.fromList([b, b]);
    }

    final sessionId = Uint8List(32);
    for (var i = 0; i < 32; i++) {
      sessionId[i] = rng.nextInt(256);
    }

    final domainBytes = Uint8List.fromList(domain.codeUnits);

    final b = BytesBuilder();
    void bytes(List<int> v) => b.add(v);

    bytes(grease(0));
    bytes([
      0x13, 0x01, 0x13, 0x02, 0x13, 0x03, 0xc0, 0x2b, 0xc0, 0x2f, 0xc0, 0x2c,
      0xc0, 0x30, 0xcc, 0xa9, 0xcc, 0xa8, 0xc0, 0x13, 0xc0, 0x14, 0x00, 0x9c,
      0x00, 0x9d, 0x00, 0x2f, 0x00, 0x35,
    ]);

    final cipherSuites = b.toBytes();
    b.clear();

    final ext = BytesBuilder();
    void extU16(int v) => ext.add([(v >> 8) & 0xff, v & 0xff]);
    void extBytes(List<int> v) => ext.add(v);

    extBytes(grease(1));
    extU16(0);

    extU16(0x0000);
    final sni = BytesBuilder();
    sni.add([0x00]);
    sni.add([(domainBytes.length >> 8) & 0xff, domainBytes.length & 0xff]);
    sni.add(domainBytes);
    final sniList = sni.toBytes();
    extU16(sniList.length + 2);
    extU16(sniList.length);
    extBytes(sniList);

    extU16(0x0017);
    extU16(0);

    extU16(0xff01);
    extU16(1);
    extBytes([0x00]);

    extU16(0x000a);
    extU16(8);
    extU16(6);
    extBytes(grease(2));
    extBytes([0x00, 0x1d, 0x00, 0x17, 0x00, 0x18]);

    extU16(0x000b);
    extU16(2);
    extBytes([0x01, 0x00]);

    extU16(0x0023);
    extU16(0);

    extU16(0x0010);
    extU16(14);
    extU16(12);
    extBytes([0x02, 0x68, 0x32, 0x08, 0x68, 0x74, 0x74, 0x70, 0x2f, 0x31, 0x2e, 0x31]);

    extU16(0x0005);
    extU16(5);
    extBytes([0x01, 0x00, 0x00, 0x00, 0x00]);

    extU16(0x000d);
    extU16(18);
    extU16(16);
    extBytes([
      0x04, 0x03, 0x08, 0x04, 0x04, 0x01, 0x05, 0x03,
      0x08, 0x05, 0x05, 0x01, 0x08, 0x06, 0x06, 0x01,
    ]);

    extU16(0x0012);
    extU16(0);

    extU16(0x0033);
    final keyShare = Uint8List(32);
    for (var i = 0; i < 32; i++) {
      keyShare[i] = rng.nextInt(256);
    }
    final ks = BytesBuilder();
    ks.add(grease(4));
    ks.add([0x00, 0x01, 0x00]);
    ks.add([0x00, 0x1d, 0x00, 0x20]);
    ks.add(keyShare);
    final ksBody = ks.toBytes();
    extU16(ksBody.length + 2);
    extU16(ksBody.length);
    extBytes(ksBody);

    extU16(0x002d);
    extU16(2);
    extBytes([0x01, 0x01]);

    extU16(0x002b);
    extU16(7);
    extBytes([0x06]);
    extBytes(grease(5));
    extBytes([0x03, 0x04, 0x03, 0x03]);

    extU16(0x001b);
    extU16(3);
    extBytes([0x02, 0x00, 0x02]);

    extBytes(grease(6));
    extU16(1);
    extBytes([0x00]);

    final extensions = ext.toBytes();

    final body = BytesBuilder();
    body.add([0x03, 0x03]);
    body.add(Uint8List(32));
    body.add([sessionId.length]);
    body.add(sessionId);
    body.add([(cipherSuites.length >> 8) & 0xff, cipherSuites.length & 0xff]);
    body.add(cipherSuites);
    body.add([0x01, 0x00]);
    body.add([(extensions.length >> 8) & 0xff, extensions.length & 0xff]);
    body.add(extensions);
    final helloBody = body.toBytes();

    final handshake = BytesBuilder();
    handshake.add([0x01]);
    handshake.add([
      (helloBody.length >> 16) & 0xff,
      (helloBody.length >> 8) & 0xff,
      helloBody.length & 0xff,
    ]);
    handshake.add(helloBody);
    final hsBytes = handshake.toBytes();

    final record = BytesBuilder();
    record.add([0x16, 0x03, 0x01]);
    record.add([(hsBytes.length >> 8) & 0xff, hsBytes.length & 0xff]);
    record.add(hsBytes);
    final full = record.toBytes();

    final digest = _hmacSha256(secret, full);
    for (var i = 0; i < 32; i++) {
      full[11 + i] = digest[i];
    }

    return FakeTlsHello(full);
  }
}

Uint8List wrapTlsRecord(Uint8List data) {
  final out = Uint8List(5 + data.length);
  out[0] = 0x17;
  out[1] = 0x03;
  out[2] = 0x03;
  out[3] = (data.length >> 8) & 0xff;
  out[4] = data.length & 0xff;
  out.setRange(5, out.length, data);
  return out;
}
