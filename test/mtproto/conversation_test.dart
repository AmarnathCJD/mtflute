@Tags(['live'])
library;

import 'package:test/test.dart';
import 'package:mtflute/mtflute.dart';

const _botToken = 'YOUR_BOT_TOKEN_HERE';
const _appId = 0; // YOUR_API_ID from https://my.telegram.org
const _appHash = 'YOUR_API_HASH_HERE';
const _testChatId = 5435244538;

void main() {
  test('conversation: ask + getResponse', () async {
    final client = MtpClient(
      appId: _appId,
      appHash: _appHash,
      sessionFile: 'bot.session',
    );

    await client.loginBot(_botToken);

    final peer = InputPeerUser(userId: _testChatId, accessHash: 0);

    final conv = client.conversation(peer, timeout: const Duration(minutes: 2));
    print(
      'Bot is asking — please reply with anything (text message) in Telegram',
    );

    final reply = await conv.ask(
      'Conversation test: please type any message and send it back to me.',
    );
    print('Bot received reply: "${reply.text}" from chat=${reply.chatId}');

    await conv.respond('Thanks! Conversation API working. ✅');

    conv.close();
    await client.close();
  }, timeout: const Timeout(Duration(minutes: 3)));
}
