@Tags(['live'])
library;

import 'dart:async';
import 'dart:io';
import 'package:test/test.dart';
import 'package:mtflute/mtflute.dart';

const _botToken = 'YOUR_BOT_TOKEN_HERE';
const _appId = 0; // YOUR_API_ID from https://my.telegram.org
const _appHash = 'YOUR_API_HASH_HERE';

void main() {
  test(
    'download file received from user (cross-DC test)',
    () async {
      final client = MtpClient(
        appId: _appId,
        appHash: _appHash,
        sessionFile: 'bot.session',
      );
      client.logger.level = LogLevel.debug;

      await client.loginBot(_botToken);
      print(
        'Bot online on DC${client.dcId}. Send a file/photo to the bot now.',
      );

      final fileGot =
          Completer<({InputFileLocation loc, int dc, int size, String name})>();

      client.onMessage((msg) {
        print(
          'msg in chat=${msg.chatId}: "${msg.text}" media=${msg.message.media?.runtimeType}',
        );
        final m = msg.message;
        final media = m.media;
        if (media == null) return;
        print('got media: ${media.runtimeType}');

        if (media is MessageMediaPhoto) {
          final photo = media.photo;
          if (photo is PhotoObj) {
            final largest = photo.sizes.last;
            int size = 0;
            String type = '';
            if (largest is PhotoSizeObj) {
              size = largest.size;
              type = largest.type;
            } else if (largest is PhotoSizeProgressive) {
              size = largest.sizes.reduce((a, b) => a > b ? a : b);
              type = largest.type;
            }
            if (fileGot.isCompleted) return;
            fileGot.complete((
              loc: InputPhotoFileLocation(
                id: photo.id,
                accessHash: photo.accessHash,
                fileReference: photo.fileReference,
                thumbSize: type,
              ),
              dc: photo.dcId,
              size: size,
              name: 'photo_${photo.id}.jpg',
            ));
          }
        } else if (media is MessageMediaDocument) {
          final doc = media.document;
          if (doc is DocumentObj) {
            if (fileGot.isCompleted) return;
            fileGot.complete((
              loc: InputDocumentFileLocation(
                id: doc.id,
                accessHash: doc.accessHash,
                fileReference: doc.fileReference,
                thumbSize: '',
              ),
              dc: doc.dcId,
              size: doc.size,
              name: 'doc_${doc.id}',
            ));
          }
        }
      });

      final info = await fileGot.future.timeout(const Duration(minutes: 2));
      print(
        'file on DC${info.dc}, bot on DC${client.dcId}, size=${info.size} bytes',
      );
      print('  cross-DC: ${info.dc != client.dcId}');

      final outPath = '${Directory.systemTemp.path}/${info.name}';
      var lastReport = 0;
      final start = DateTime.now();

      await client.downloadToFile(
        info.loc,
        outPath,
        dcId: info.dc,
        size: info.size,
        onProgress: (cur, total) {
          if (cur - lastReport >= 128 * 1024 || cur == total) {
            print('downloaded: $cur / $total bytes');
            lastReport = cur;
          }
        },
      );

      final elapsed = DateTime.now().difference(start);
      final stat = await File(outPath).stat();
      print('done in ${elapsed.inSeconds}s, file size on disk: ${stat.size}');
      expect(stat.size, greaterThan(0));

      await File(outPath).delete();
      await client.close();
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
