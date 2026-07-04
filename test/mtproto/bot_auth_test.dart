@Tags(['live'])
library;

import 'package:test/test.dart';
import 'package:mtflute/src/mtproto/client.dart';
import 'package:mtflute/src/tg/types.dart';

void main() {
  test('bot login', () async {
    final client = MtpClient(
      appId: 0 /* YOUR_API_ID */,
      appHash: 'YOUR_API_HASH_HERE',
      dcId: 4,
    );

    final auth = await client.loginBot('YOUR_BOT_TOKEN_HERE');

    if (auth is AuthAuthorizationObj && auth.user is UserObj) {
      final user = auth.user as UserObj;
      print(
        'Logged in as ${user.firstName} (id: ${user.id}, bot: ${user.bot})',
      );
    }

    expect(await client.isAuthorized(), true);
    await client.close();
  }, timeout: const Timeout(Duration(seconds: 30)));

  test('bot login via login() helper', () async {
    final client = MtpClient(
      appId: 0 /* YOUR_API_ID */,
      appHash: 'YOUR_API_HASH_HERE',
      dcId: 4,
    );

    await client.login(botToken: 'YOUR_BOT_TOKEN_HERE');
    expect(await client.isAuthorized(), true);

    await client.close();
  }, timeout: const Timeout(Duration(seconds: 30)));
}
