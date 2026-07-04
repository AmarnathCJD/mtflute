@Tags(['live'])
library;

import 'package:test/test.dart';
import 'package:mtflute/mtflute.dart';

const _botToken = 'YOUR_BOT_TOKEN_HERE';
const _appId = 0; // YOUR_API_ID from https://my.telegram.org
const _appHash = 'YOUR_API_HASH_HERE';

void main() {
  test(
    'auto-reconnect after forced transport close',
    () async {
      final client = MtpClient(
        appId: _appId,
        appHash: _appHash,
        sessionFile: 'bot.session',
      );
      client.logger.level = LogLevel.info;

      await client.loginBot(_botToken);

      final me1 = await client.getMe();
      expect(me1, isNotNull);
      print('before drop: ${(me1 as UserObj).id}');

      // Force-close the transport to simulate a network drop
      print('forcing transport close...');
      await client.transport?.close();

      // Wait for reconnect to engage
      await Future.delayed(const Duration(seconds: 3));

      // This call should trigger reconnect and succeed
      final me2 = await client.getMe();
      expect(me2, isNotNull);
      print('after reconnect: ${(me2 as UserObj).id}');
      expect(me2.id, me1.id);

      await client.close();
    },
    timeout: const Timeout(Duration(seconds: 60)),
  );
}
