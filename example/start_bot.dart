import 'package:mtflute/mtflute.dart';

const _botToken = 'YOUR_BOT_TOKEN_HERE';
const _appId = 0; // YOUR_API_ID from https://my.telegram.org
const _appHash = 'YOUR_API_HASH_HERE';

Future<void> main() async {
  final client = MtpClient(
    appId: _appId,
    appHash: _appHash,
    dcId: 4,
    sessionFile: 'bot.session',
  );

  await client.loginBot(_botToken);
  print('Bot online. Waiting for /start ... (Ctrl+C to stop)');

  client.onMessage((msg) async {
    final text = msg.text.trim();
    print('[msg] chat=${msg.chatId}: $text');

    if (text == '/start' || text.startsWith('/start ')) {
      await msg.reply(
        'Hi! I am running on mtflute, a pure-Dart MTProto client.\n'
        'Send me anything and I will echo it.',
      );
    } else if (text == '/ping') {
      await msg.reply('pong');
    } else if (text.isNotEmpty && !text.startsWith('/')) {
      await msg.reply('echo: $text');
    }
  });

  await client.idle();
  print('Bye.');
}
