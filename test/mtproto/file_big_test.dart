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
    'upload 15MB file with multi-worker',
    () async {
      final tmp = File('${Directory.systemTemp.path}/mtflute_big.bin');
      final size = 15 * 1024 * 1024;
      final sink = tmp.openWrite();
      final chunk = List<int>.generate(1024, (i) => i & 0xff);
      for (var i = 0; i < size ~/ 1024; i++) {
        sink.add(chunk);
      }
      await sink.close();
      print('created ${size ~/ 1024} KB test file');

      final client = MtpClient(
        appId: _appId,
        appHash: _appHash,
        dcId: 4,
        sessionFile: 'bot.session',
      );

      await client.loginBot(_botToken);

      InputPeer peer;
      try {
        peer = client.cache.getInputPeer(_testChatId);
      } catch (_) {
        peer = InputPeerUser(userId: _testChatId, accessHash: 0);
      }

      var lastReport = 0;
      final start = DateTime.now();
      final result = await client.sendFile(
        peer: peer,
        file: tmp,
        caption: 'big upload test (15MB, multi-worker)',
        onProgress: (current, total) {
          if (current - lastReport >= 2 * 1024 * 1024 || current == total) {
            final pct = (current / total * 100).toStringAsFixed(1);
            print('upload: ${current ~/ 1024} / ${total ~/ 1024} KB ($pct%)');
            lastReport = current;
          }
        },
      );

      final elapsed = DateTime.now().difference(start);
      final mbps = (size / 1024 / 1024) / (elapsed.inMilliseconds / 1000);
      print('done in ${elapsed.inSeconds}s (${mbps.toStringAsFixed(2)} MB/s)');
      print('result: ${result.runtimeType}');

      await client.close();
      await tmp.delete();
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
