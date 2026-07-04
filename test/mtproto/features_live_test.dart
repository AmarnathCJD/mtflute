@Tags(['live'])
library;

import 'package:test/test.dart';
import 'package:mtflute/mtflute.dart';

const _botToken = 'YOUR_BOT_TOKEN_HERE';
const _appId = 0; // YOUR_API_ID from https://my.telegram.org
const _appHash = 'YOUR_API_HASH_HERE';
const _testChatId = 5435244538;

void main() {
  test(
    'send formatted message with inline buttons',
    () async {
      final client = MtpClient(
        appId: _appId,
        appHash: _appHash,
        dcId: 4,
        sessionFile: 'bot.session',
      );

      await client.loginBot(_botToken);

      final peer = InputPeerUser(userId: _testChatId, accessHash: 0);

      final kb = Keyboard()
        ..row([
          Button.callback('Click me', 'cb:hello'),
          Button.url('Visit', 'https://t.me'),
        ])
        ..row([Button.switchInline('Share', query: 'shared!')]);

      final result = await client.sendMessage(
        peer: peer,
        text:
            '**Markdown bold**, `inline code`, and a [link](https://example.com).\n'
            'Try `__italic__` too.',
        parseMode: 'md',
        buttons: kb.inline(),
      );

      print('sent: ${result.runtimeType}');
      await client.close();
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );

  test('getMe + getDialogs', () async {
    final client = MtpClient(
      appId: _appId,
      appHash: _appHash,
      dcId: 4,
      sessionFile: 'bot.session',
    );

    await client.loginBot(_botToken);

    final me = await client.getMe();
    expect(me, isNotNull);
    final u = me as UserObj;
    print('getMe: ${u.firstName} (id=${u.id}, bot=${u.bot})');
    expect(u.bot, isTrue);

    // Note: messages.getDialogs is a user-only API; skipping for bot.

    await client.close();
  }, timeout: const Timeout(Duration(seconds: 30)));
}
