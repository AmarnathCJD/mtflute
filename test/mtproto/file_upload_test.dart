@Tags(['live'])
library;

import 'dart:io';
import 'package:test/test.dart';
import 'package:mtflute/mtflute.dart';

const _botToken = 'YOUR_BOT_TOKEN_HERE';
const _appId = 0; // YOUR_API_ID from https://my.telegram.org
const _appHash = 'YOUR_API_HASH_HERE';
const _testChatId = 5435244538;

void main() {
  test(
    'upload small file and send to user',
    () async {
      final tmp = File('${Directory.systemTemp.path}/mtflute_test.txt');
      await tmp.writeAsString('Hello from mtflute! ${DateTime.now()}');

      final client = MtpClient(
        appId: _appId,
        appHash: _appHash,
        dcId: 4,
        sessionFile: 'bot.session',
      );

      await client.loginBot(_botToken);

      // Wait for any update to populate cache, or use access_hash=0 (bot DMs work this way)
      InputPeer peer;
      try {
        peer = client.cache.getInputPeer(_testChatId);
      } catch (_) {
        peer = InputPeerUser(userId: _testChatId, accessHash: 0);
      }

      var lastReport = 0;
      final result = await client.sendFile(
        peer: peer,
        file: tmp,
        caption: 'small upload test',
        onProgress: (current, total) {
          if (current - lastReport > 100 * 1024 || current == total) {
            print('upload: $current / $total bytes');
            lastReport = current;
          }
        },
      );

      print('sendFile result: ${result.runtimeType}');
      await client.close();
      await tmp.delete();
    },
    timeout: const Timeout(Duration(seconds: 60)),
  );
}
