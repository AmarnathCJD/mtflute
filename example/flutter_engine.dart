// Reference pattern for running mtflute as an in-process engine inside a
// Flutter Android app. Wire this into your service/singleton and hand out
// URLs from `urlForMessage` to any HTTP-aware player (mediakit, video_player).
//
// From Flutter, resolve the session path once at boot:
//
//   final dir = await getApplicationDocumentsDirectory();
//   final engine = TgEngine();
//   await engine.start(
//     sessionPath: '${dir.path}/mtflute.session',
//     botToken: '...',
//   );
//   final url = await engine.urlForMessage(peer: ..., msgId: ...);
//   Player().open(Media(url));
//
// When the app terminates, call `engine.stop()` to flush the session and
// tear down the HTTP server.

import 'package:mtflute/mtflute.dart';

class TgEngine {
  late final MtpClient client;
  late final TelegramFileStreamServer server;
  bool _running = false;

  Future<void> start({
    required String sessionPath,
    required int appId,
    required String appHash,
    String? botToken,
    int dcId = 4,
    int warmupWorkers = 4,
  }) async {
    if (_running) return;
    client = MtpClient(
      appId: appId,
      appHash: appHash,
      dcId: dcId,
      sessionFile: sessionPath,
      timeout: const Duration(seconds: 20),
    );
    if (botToken != null) {
      await client.loginBot(botToken);
    }
    server = TelegramFileStreamServer(client);
    await server.start();
    try {
      await server.warmup(dcId: client.dcId, workers: warmupWorkers);
    } catch (_) {}
    _running = true;
  }

  Future<String> urlForMessage({
    required InputPeer peer,
    required int msgId,
    String? mimeOverride,
    String? fileNameOverride,
  }) {
    return server.publishMessage(
      peer: peer,
      msgId: msgId,
      mimeOverride: mimeOverride,
      fileNameOverride: fileNameOverride,
    );
  }

  Future<ResolvedMedia?> resolveMedia({
    required InputPeer peer,
    required int msgId,
    bool forceRefresh = false,
  }) {
    return client.resolveMediaByMessage(
      peer: peer,
      msgId: msgId,
      forceRefresh: forceRefresh,
    );
  }

  bool get isRunning => _running;

  Future<void> stop() async {
    if (!_running) return;
    _running = false;
    try {
      await server.stop();
    } catch (_) {}
    try {
      await client.close();
    } catch (_) {}
  }
}

Future<void> main() async {
  print('This file is a reference pattern, not a runnable example on desktop.');
  print('Copy TgEngine into your Flutter app.');
}
