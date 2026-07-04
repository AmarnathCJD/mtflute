@Tags(['live'])
library;

import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:mtflute/src/mtproto/client.dart';
import 'package:mtflute/src/mtproto/session.dart';

void main() {
  test(
    'export and import string session',
    () async {
      final client = MtpClient(
        appId: 0 /* YOUR_API_ID */,
        appHash: 'YOUR_API_HASH_HERE',
        dcId: 4,
      );

      await client.loginBot('YOUR_BOT_TOKEN_HERE');
      expect(await client.isAuthorized(), true);

      final exported = client.exportSession();
      print('Session: ${exported.substring(0, 20)}...');
      expect(exported.startsWith('1BvE'), true);

      await client.close();

      final client2 = MtpClient(
        appId: 0 /* YOUR_API_ID */,
        appHash: 'YOUR_API_HASH_HERE',
        dcId: 4,
        stringSession: exported,
      );

      await client2.connect();
      expect(await client2.isAuthorized(), true);
      print('Session reimport works');

      await client2.close();
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );

  test('SessionData encode/decode roundtrip', () {
    final s = SessionData(
      authKey: Uint8List.fromList(List.generate(256, (i) => i)),
      dcId: 4,
      ipAddr: '149.154.167.91:443',
      appId: 0 /* YOUR_API_ID */,
      serverSalt: 123456789,
    );

    final encoded = s.encodeString();
    final decoded = SessionData.decodeString(encoded);

    expect(decoded.dcId, 4);
    expect(decoded.ipAddr, '149.154.167.91:443');
    expect(decoded.appId, 0);
    expect(decoded.serverSalt, 123456789);
  });
}
