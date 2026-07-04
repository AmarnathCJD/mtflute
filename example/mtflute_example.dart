// Quickstart: a bot that handles /start with an inline keyboard.
// Replace the constants below with your own credentials from
// https://my.telegram.org and https://t.me/BotFather.

import 'package:mtflute/mtflute.dart';

const _appId = 12345;
const _appHash = 'your_api_hash_here';
const _botToken = '12345:your_bot_token_here';

Future<void> main() async {
  final client = MtpClient(
    appId: _appId,
    appHash: _appHash,
    sessionFile: 'bot.session', // auto-resumes next run
  );

  await client.loginBot(_botToken);
  print('Bot online.');

  // Reply to /start with a Markdown message + inline buttons.
  client.onMessage((msg) async {
    if (msg.text == '/start') {
      await msg.reply(
        '**Welcome!** Pick an option:',
        parseMode: 'md',
        buttons:
            (Keyboard()
                  ..row([
                    Button.callback('Say hi', 'cb:hi'),
                    Button.url('Docs', 'https://pub.dev/packages/mtflute'),
                  ])
                  ..row([Button.callback('Cancel', 'cb:cancel')]))
                .inline(),
      );
    } else if (msg.text == '/ping') {
      await msg.reply('pong');
    } else {
      await msg.reply('echo: ${msg.text}');
    }
  });

  // Respond to callback button taps.
  client.onCallbackQuery((cq) async {
    final data = String.fromCharCodes(cq.data ?? []);
    if (data == 'cb:hi') {
      await cq.answer(message: 'Hi there!');
    } else {
      await cq.answer();
    }
  });

  // Run until Ctrl+C.
  await client.idle();
}
