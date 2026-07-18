# mtflute

[![pub package](https://img.shields.io/pub/v/mtflute.svg)](https://pub.dev/packages/mtflute)
[![sdk](https://img.shields.io/badge/dart-%3E%3D3.8-blue)](https://dart.dev)
[![license](https://img.shields.io/badge/license-MIT-green)](LICENSE)

A pure-Dart Telegram MTProto client. Targets Telegram API **layer 228** and
speaks the protocol directly — no Bot API dependency, no native libraries,
no platform channels. Supports both bot and user accounts through the same
API.

---

## Features

**Authentication**
- Bot login via bot token.
- User login via phone number, one-time code, and 2FA (SRP) password.
- File-based and string-based sessions. String sessions are
  byte-compatible with gogram's `1BvE` format; the legacy `1BvX` format
  is also read on import.

**Session and peer persistence**
- Peer cache (users, channels, usernames, access hashes) is serialized
  into the session file and reloaded on startup, removing the need to
  re-resolve peers after an app restart.
- Atomic writes (unique temporary file + POSIX rename), asynchronous
  debounced flush, guaranteed flush on `close()`.

**Reliability**
- Single-flight reconnect with exponential backoff and jitter.
- Idle-connection detection for silently-dropped sockets after Android
  background suspension.
- Transparent recovery on `bad_msg_notification` (codes 16, 17, 32, 33, 48)
  and `bad_server_salt`.
- Terminal auth errors disable auto-reconnect until the next successful
  login.

**Files**
- Parallel worker pool with cached cross-DC senders.
- Transparent handling of `FILE_MIGRATE_X` and `FILE_REFERENCE_EXPIRED`.
- `FLOOD_WAIT` is respected per part; retries are bounded.
- `downloadStream` and `downloadRange` for direct programmatic access.

**Local HTTP media server** (optional)
- `TelegramFileStreamServer` serves Telegram files over HTTP with
  `Range` / `206 Partial Content` support, a per-entry LRU chunk cache,
  seek-aware prefetch, and per-request cancellation on client disconnect.
- `MediaLocationCache` — LRU keyed by `(peerId, msgId)` avoids re-fetching
  the source message on repeated stream requests; auto-refreshes on
  `FILE_REFERENCE_EXPIRED`.
- Useful for feeding Telegram media into HTTP-aware players
  (`media_kit`, `video_player`, `<video>`) without buffering the whole
  file to disk.

**Messaging and updates**
- Send, edit, delete, forward, pin. Markdown and HTML parse modes.
- Inline button builder.
- Update dispatch via socket push and `getDifference` polling, with
  `FLOOD_WAIT` backoff and 16K-message deduplication.
- Conversation API for chained prompts.

**Platform**
- Pure `dart:io`. No `Isolate.spawn`, `dart:mirrors`, or `dart:ffi`.
- Ships with a reference `TgEngine` class demonstrating Flutter Android
  integration.

---

## Installation

```yaml
dependencies:
  mtflute: ^0.2.0
```

---

## Usage

### Bot

```dart
final client = MtpClient(
  appId: yourApiId,
  appHash: 'your-api-hash',
  sessionFile: 'bot.session',
);
await client.loginBot('your-bot-token');

client.onMessage((msg) async {
  if (msg.text == '/start') {
    await msg.reply(
      '**Welcome.**',
      parseMode: 'md',
      buttons: (Keyboard()
            ..row([Button.callback('Yes', 'cb:yes'), Button.url('Docs', 'https://t.me')]))
          .inline(),
    );
  }
});

client.onCallbackQuery((cq) => cq.answer(message: 'Received.'));

await client.idle();
```

### User account

```dart
final client = MtpClient(
  appId: yourApiId,
  appHash: 'your-api-hash',
  sessionFile: 'user.session',
);

await client.login(
  codeCallback: (prompt) => promptUserForCode(prompt),
  passwordCallback: (prompt) => promptUserForPassword(prompt),
);
```

On Android and iOS, the default stdin-based prompt is disabled. Supply
your own `codeCallback` and `passwordCallback`.

### Files

```dart
// Upload and send
await client.sendFile(
  peer: peer,
  file: File('photo.jpg'),
  caption: 'caption',
  onProgress: (current, total) => print('${current * 100 ~/ total}%'),
);

// Whole-file download
await client.downloadToFile(location, 'out.bin', dcId: 4, size: 12345);

// Streaming download
await for (final chunk in client.downloadStream(location, dcId: 4, size: 12345)) {
  // consume chunk
}

// Arbitrary byte range
final bytes = await client.downloadRange(
  location,
  start: 1000000,
  end: 2000000,
  dcId: 4,
);
```

### Conversation

```dart
final conv = client.conversation(peer);
final reply = await conv.ask('Your name?');
await conv.respond('Hello, ${reply.text}.');
conv.close();
```

### Sessions

```dart
// File session, reloaded automatically on next construction.
final client = MtpClient(
  appId: id,
  appHash: hash,
  sessionFile: '${docs.path}/mtflute.session',
);

// String session, byte-compatible with gogram.
final s = client.exportSession();
final restored = MtpClient(appId: id, appHash: hash, stringSession: s);
```

Peer metadata (users, channels, usernames, access hashes) is persisted
alongside the auth key, so no re-resolution is required after an app
restart.

### Media streaming (optional)

`TelegramFileStreamServer` publishes any Telegram file over a local HTTP
endpoint that supports `Range` requests. Feed the returned URL to any
HTTP-aware player.

```dart
final server = TelegramFileStreamServer(client);
await server.start();
await server.warmup(dcId: client.dcId, workers: 4);

final url = await server.publishMessage(peer: peer, msgId: msgId);
// Hand `url` to media_kit / video_player / <video>.
```

---

## Flutter example

A complete Flutter Android application demonstrating login, message
handling, and video playback via the local HTTP server.

**`pubspec.yaml`**

```yaml
dependencies:
  flutter:
    sdk: flutter
  mtflute: ^0.2.0
  path_provider: ^2.1.0
  media_kit: ^1.1.10
  media_kit_video: ^1.2.4
  media_kit_libs_video: ^1.0.4
```

**`lib/tg_engine.dart`**

```dart
import 'package:mtflute/mtflute.dart';

class TgEngine {
  late final MtpClient client;
  late final TelegramFileStreamServer server;
  bool _started = false;

  Future<void> start({
    required String sessionPath,
    required int appId,
    required String appHash,
    required String botToken,
    int dcId = 4,
  }) async {
    if (_started) return;

    client = MtpClient(
      appId: appId,
      appHash: appHash,
      dcId: dcId,
      sessionFile: sessionPath,
      timeout: const Duration(seconds: 20),
    );
    await client.loginBot(botToken);

    server = TelegramFileStreamServer(client);
    await server.start();
    try {
      await server.warmup(dcId: client.dcId, workers: 4);
    } catch (_) {
      // Non-fatal: warmup is a latency optimization.
    }

    _started = true;
  }

  Future<String> urlForMessage({
    required InputPeer peer,
    required int msgId,
  }) {
    return server.publishMessage(peer: peer, msgId: msgId);
  }

  Future<ResolvedMedia?> metadataForMessage({
    required InputPeer peer,
    required int msgId,
  }) {
    return client.resolveMediaByMessage(peer: peer, msgId: msgId);
  }

  Future<void> stop() async {
    if (!_started) return;
    _started = false;
    await server.stop();
    await client.close();
  }
}
```

**`lib/main.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:mtflute/mtflute.dart';
import 'package:path_provider/path_provider.dart';

import 'tg_engine.dart';

late final TgEngine engine;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  final docs = await getApplicationDocumentsDirectory();
  engine = TgEngine();
  await engine.start(
    sessionPath: '${docs.path}/mtflute.session',
    appId: 2040,                            // your api_id
    appHash: 'your-api-hash-here',          // your api_hash
    botToken: 'your-bot-token-here',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mtflute demo',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('mtflute demo')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Replace with a real (peer, msgId) resolved from your handlers.
            final peer = InputPeerUser(userId: 12345, accessHash: 67890);
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => PlayerPage(peer: peer, msgId: 42),
            ));
          },
          child: const Text('Play sample'),
        ),
      ),
    );
  }
}

class PlayerPage extends StatefulWidget {
  final InputPeer peer;
  final int msgId;
  const PlayerPage({super.key, required this.peer, required this.msgId});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late final Player player = Player();
  late final VideoController controller = VideoController(player);
  String? _url;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final url = await engine.urlForMessage(peer: widget.peer, msgId: widget.msgId);
      await player.open(Media(url));
      await player.play();
      if (mounted) setState(() => _url = url);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_url ?? 'loading…')),
      body: _error != null
          ? Center(child: Text(_error!))
          : _url == null
              ? const Center(child: CircularProgressIndicator())
              : Video(controller: controller),
    );
  }
}
```

The player issues standard HTTP `Range` requests against the URL returned
by `urlForMessage`. Seeking, resuming, and background prefetch are all
handled by the server transparently.

The [`example/flutter_engine.dart`](example/flutter_engine.dart) file in
the repository contains this pattern in a single, ready-to-drop file.

---

## Platform notes

**Session paths on Android.** Pass an absolute path obtained from
`path_provider`. Relative paths resolve to the app root, which is not
writable on modern Android.

**Cleartext to loopback.** The stream server binds to `127.0.0.1` by
default. Android 9+ permits cleartext access to loopback without any
manifest configuration.

**Background suspension.** After long periods in the background, mobile
sockets can be silently killed by the platform. mtflute detects this on
the next request via a read-idle timeout and reconnects transparently.

---

## Status

Version `0.2.0`. The public API is largely stable. Contributions are
welcome.

---

## License

MIT. See [LICENSE](LICENSE).
