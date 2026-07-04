# mtflute

Pure-Dart Telegram MTProto client with a built-in **HTTP streaming engine** for `mediakit` / `video_player` / any Range-aware HTTP consumer. Talks directly to Telegram's servers like Telethon / Pyrogram / gogram — no Bot API, no native libs.

Currently against Telegram **API layer 227** (TDesktop dev).

## Highlights

- **Streaming engine**: `TelegramFileStreamServer.publishMessage(peer, msgId)` returns a `http://127.0.0.1:PORT/f/...` URL you feed straight into mediakit. Full HTTP Range 206, seek-aware prefetch, per-entry LRU chunk cache, per-request cancellation on disconnect, CORS.
- **Cached location resolver**: `MediaLocationCache` keyed by `(peerId, msgId)` so repeated stream requests skip the source-message fetch. Auto-refreshes on `FILE_REFERENCE_EXPIRED`.
- **Auth**: bot tokens, phone + OTP + 2FA (SRP), string sessions (gogram-compatible `1BvE` format), file sessions.
- **Session + peer persistence**: peer cache (users, channels, usernames) auto-saved into the session file, reloaded on next start — no re-resolve after app restart. Atomic writes, async debounced flush, guaranteed on `close()`. **5.6× reuse-login speedup.**
- **Files**: parallel workers with cached cross-DC senders, `downloadStream` / `downloadRange`, transparent `FILE_MIGRATE` + `FILE_REFERENCE_EXPIRED`, FLOOD_WAIT respected, bounded retries.
- **Reconnect**: single-flight, exponential backoff with jitter, idle-detect after Android background (>90s), transparent recovery on `bad_msg` (16/17/32/33/48) and `bad_server_salt`.
- **Messaging**: send/edit/delete/forward/pin, Markdown + HTML parse modes, inline button builder.
- **Updates**: socket push + `getDifference` polling with FLOOD_WAIT backoff, dedup (16k msg IDs).
- **Conversation API**: `client.conversation(peer).ask('Name?')`.
- **Android / Flutter safe**: only `dart:io`, no isolates / mirrors / ffi. Ships with a `TgEngine` reference wrapper.

## Streaming quickstart (Flutter Android)

```dart
import 'package:mtflute/mtflute.dart';
import 'package:path_provider/path_provider.dart';
import 'package:media_kit/media_kit.dart';

final docs = await getApplicationDocumentsDirectory();
final client = MtpClient(
  appId: YOUR_API_ID,
  appHash: 'YOUR_API_HASH',
  dcId: 4,
  sessionFile: '${docs.path}/mtflute.session',
);
await client.loginBot('123:ABC-bot-token');

final server = TelegramFileStreamServer(client);
await server.start();
await server.warmup(dcId: client.dcId, workers: 4);

// One line to hand a message's media to any HTTP player:
final url = await server.publishMessage(peer: peer, msgId: msgId);

Player().open(Media(url));
```

The server serves HTTP Range 206 with byte-exact content. mediakit / libmpv seeks work out of the box.

See [`example/flutter_engine.dart`](example/flutter_engine.dart) for the full `TgEngine` singleton pattern.

## Bot quickstart

```dart
final client = MtpClient(
  appId: YOUR_API_ID,
  appHash: 'YOUR_API_HASH',
  sessionFile: 'bot.session',
);
await client.loginBot('123:ABC-bot-token');

client.onMessage((msg) async {
  if (msg.text == '/start') {
    await msg.reply(
      '**Hi!** Tap a button:',
      parseMode: 'md',
      buttons: (Keyboard()
            ..row([Button.callback('Yes', 'cb:yes'), Button.url('Docs', 'https://t.me')]))
          .inline(),
    );
  }
});

client.onCallbackQuery((cq) async {
  await cq.answer(message: 'You picked it!');
});

await client.idle();
```

## User quickstart

```dart
final client = MtpClient(
  appId: YOUR_API_ID,
  appHash: 'YOUR_API_HASH',
  sessionFile: 'user.session',
);

await client.login(
  codeCallback: (prompt) async { stdout.write(prompt); return stdin.readLineSync()!; },
  passwordCallback: (prompt) async { stdout.write(prompt); return stdin.readLineSync()!; },
);
```

On Android/iOS the stdin prompt path throws — pass your own callbacks (SMS text field, dialog, etc.).

## Files

```dart
// Send a local file
await client.sendFile(
  peer: peer,
  file: File('photo.jpg'),
  caption: 'caption',
  onProgress: (cur, total) => print('${cur * 100 ~/ total}%'),
);

// Whole-file download
await client.downloadToFile(location, 'out.bin', dcId: 4, size: 12345);

// Streaming download (chunk-by-chunk, no full-file buffering)
await for (final chunk in client.downloadStream(location, dcId: 4, size: 12345)) {
  // ... write chunk somewhere
}

// Arbitrary byte range
final bytes = await client.downloadRange(location, start: 1_000_000, end: 2_000_000, dcId: 4);

// From a chat message (uses MediaLocationCache under the hood)
final url = await server.publishMessage(peer: peer, msgId: msgId);
```

## Conversation

```dart
final conv = client.conversation(peer);
final reply = await conv.ask("What's your name?");
await conv.respond('Hi ${reply.text}!');
conv.close();
```

## Sessions

```dart
// File session — reloaded automatically on next construct
final client = MtpClient(
  appId: id, appHash: hash,
  sessionFile: '${docs.path}/mtflute.session',
);

// String session (gogram-compatible byte format)
final s = client.exportSession();          // -> "1BvEeyJrZXkiOi..."
final restored = MtpClient(
  appId: id, appHash: hash, stringSession: s,
);
```

Peer cache (users, channels, usernames + access hashes) is persisted alongside the auth key in the session file — no re-resolve after app restart.

## Status

**v0.2.0** — streaming engine release, 3 rounds of adversarial audit, 18/18 live checks passing.

APIs are largely stable; PRs welcome.
