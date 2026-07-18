# Changelog

## 0.2.6

- Updated Telegram API to layer 228 (from TDesktop dev).
- README rewritten for clarity, with an expanded Flutter integration example.

## 0.2.5

- New `client.downloadBlock(peer:, msgId:, blockIndex:)` — a streaming-optimized
  single-block fetch for local range servers. Downloads one aligned block
  (default 1 MB) clamped to the file's real size, over the primary connection
  with the 512 KB pipelined sub-chunk config that benchmarked fastest and most
  drop-resistant for serialized byte-range streaming (a local HTTP shim feeding
  a player: 512 KB sub-chunks pipeline two `Upload.getFile` per block ≈ 1.4 MB/s
  vs ≈ 0.9 MB/s for a single 1 MB request). Wraps `downloadMessageRange` with
  the offset/clamp math a range server would otherwise repeat, sharing the same
  media cache and `file_reference` refresher. Returns an empty list past EOF.

## 0.2.4

- `downloadRange` worker pool now puts the primary (main) connection first and
  always includes it. The primary connection is the most stable; exported
  sub-DC senders can be dropped by the DC under concurrent load, so preferring
  the primary eliminates the "Peer closed connection" reconnect churn that was
  tanking sustained throughput. Retuned `_countWorkers` / `_pipelinePerWorker`
  for pipelined reads on the primary connection.

## 0.2.3

- Tuned `downloadRange` concurrency: 4 connections x 4 pipelined requests each,
  retuned `_countWorkers` thresholds. Balances throughput against the DC's
  connection-drop anti-abuse on high-latency mobile paths.

## 0.2.2

Fixes video playback stability + eliminates player jank. Validated end-to-end
with ffprobe/ffmpeg against a real streamed file (clean decode mid-file, no
corruption, faster than realtime).

- **Off-isolate decryption.** Large ciphertexts (file chunks, ≥128 KB) now
  decrypt in a persistent worker-isolate pool (`decrypt_pool.dart`) instead of
  on the main isolate. The AES-IGE block loop no longer blocks UI rendering /
  the local stream server — measured main-isolate stalls dropped from ~90 ms to
  ~38 ms during sustained streaming. `_processIncoming` / `deserializeEncrypted`
  gained async variants; small messages still decrypt inline. Dispatch is by
  msgId so the isolate hop cannot reorder RPC results.
- **Reconnect no longer crashes downloads.** Transient "pending request
  invalidated" reconnect errors are retried instead of surfacing as an
  unhandled async exception (which previously killed the serving connection —
  the "nothing plays" symptom for HTTP-streamed media).

## 0.2.1

Streaming throughput + smoothness fixes (benchmarked on a high-RTT mobile path).

### downloadRange / worker pool
- Per-connection request **pipelining** (up to 3 concurrent `upload.getFile`
  per connection, demuxed by msgId) — the previous 1-request-per-worker model
  capped throughput at ~1 MB/s on high-RTT paths. Measured ~10x improvement
  (0.3 → 3+ MB/s sustained). Connection count kept low because DCs drop many
  simultaneous fresh connections; pipelining supplies the concurrency instead.
- Transient reconnect errors ("reconnect: pending request invalidated",
  "Not connected", timeouts) are now **retryable** in the part-fetch loop
  instead of fatally aborting the whole range download.
- `Future.wait(eagerError: false)` on part fetches so a fast-failing part can't
  orphan sibling in-flight parts (which previously surfaced as an unhandled
  async exception during a reconnect storm).
- `_countWorkers` retuned; retries per part raised to 20 with capped backoff.

### crypto
- AES-IGE encrypt/decrypt rewritten to be **allocation-free per block** (was
  ~3 `Uint8List` allocations per 16-byte block → ~96k allocations + heavy GC
  per 512 KB chunk on the single Dart isolate, a major source of video-player
  jank / frozen spinners). Verified byte-identical to the previous output.

## 0.2.0

Streaming engine release. Three deep-audit rounds against a gogram reference (150+ raw findings, ~80 confirmed, ~50 fixed).

### Layer + codegen
- Bumped Telegram API to **layer 227** (from TDesktop dev).
- Fixed `tool/tlgen.dart` handling of `{X:Type}` generics and `!X` template refs.

### File streaming
- New `client.downloadStream(location)` returns `Stream<Uint8List>` (in-order, parallel workers under the hood).
- New `client.downloadRange(location, start, end)` for arbitrary byte ranges with parallel workers, FILE_MIGRATE + FILE_REFERENCE_EXPIRED handling.
- New `client.streamMessage(peer, msgId)` and `client.downloadMessageRange(peer, msgId, start, end)` — resolve media via the built-in cache and yield bytes.
- New `TelegramFileStreamServer` — local HTTP server that publishes any Telegram file as a URL with full **HTTP Range 206** support, HEAD, CORS, seek-aware prefetch, per-entry LRU chunk cache, and per-request cancellation on client disconnect. Feed the URL to `mediakit` / `video_player` / `<video>`.
- `server.publishMessage(peer, msgId)` returns a stable URL; the chunk cache lives across HTTP requests.
- `server.warmup(dcId, workers)` pre-opens cross-DC senders so first fetch doesn't pay exportAuth latency.
- `MediaLocationCache` — LRU keyed by `(peerId, msgId)` → `ResolvedMedia(location, size, mime, dcId, fileName, duration)` with 20h TTL under Telegram's 24h `file_reference` window.

### Session + peer persistence
- Peer cache (users, channels, chats, usernames) now serialized inside `SessionData` and reloaded on next start — no more re-resolve after app restart.
- Atomic session write (unique tmp filename + POSIX rename, no delete-then-rename data-loss window).
- Async debounced flush (2s window) + guaranteed flush on `close()`.
- String session format now byte-compatible with gogram (`1BvE` + RawURL base64 JSON; legacy `1BvX` also parsed correctly for binary keys via latin1).
- `SessionData.dcId` always round-trips.

### Reconnect + transport
- `_ensureReady` waits for in-flight reconnect (bounded by client `timeout`); no more racing double-dials.
- `_reconnect` is single-flight, uses persisted auth key, exponential backoff with jitter.
- Ping is fire-and-forget — no leaked pending completers.
- `bad_msg` codes 32/33/48 drain all pending requests and let `invoke()` transparently retry on the fresh session.
- `bad_server_salt` transparently retries only the affected request (was killing all pending).
- Terminal auth errors (AUTH_KEY_UNREGISTERED, etc.) disable autoReconnect; a subsequent successful `loginBot` / `signIn` / `checkPassword` re-enables it.
- Transport now tracks `lastReadAt`; `_ensureReady` force-reconnects if the socket has been idle >90s (catches silently-dead sockets after Android backgrounding).
- Transport `close()` wakes stuck reads instead of hanging.
- Read-idle timeout on transport (75s) surfaces silently-dead peers.

### File upload/download
- Upload closes RAF only after all worker futures resolve (was closing while siblings still reading).
- `chunkSize` validated as power-of-2 multiple of 1024 that divides 512 KB.
- FLOOD_WAIT respected per part.
- Retries bounded, non-retryable errors (StateError, UnimplementedError) fail fast instead of looping 5 times.
- Parallel `downloadStream` stops correctly on last chunk (not on any short chunk).

### Crypto + TL correctness
- TL strings are now UTF-8 (was UTF-16 code units — broke every non-ASCII payload).
- `bigIntToBytes` fixed: big-endian left-pad, high-order trim (was truncating low bytes / padding wrong side).
- `auth_key` left-padded to exactly 256 bytes.
- `writeBytes` refuses payloads > 16 MiB instead of silently truncating.

### Android/Flutter
- No default relative `sessionFile` — you must pass an absolute path (from `path_provider`).
- Login callback prompts throw a clear error on mobile instead of using stdin.
- SIGINT handler uses logger instead of print.
- Everything runs on `dart:io` only — no `dart:mirrors`/`dart:ffi`/isolates. See `example/flutter_engine.dart` for a ready-to-drop `TgEngine` singleton.

### Cache correctness
- Access hash preserved when server sends minimal peer without hash.
- Reverse username mappings pruned on rename.
- LRU eviction (default 100k users / 20k channels) prevents unbounded growth in long-running engines.
- `getDifference` backs off on FLOOD_WAIT instead of hammering every 3s.

## 0.1.3

- Fixed DC migration loop: migrate now kills the old poll loop before reconnecting, preventing duplicate pollers and repeated migrations.
- Migration depth capped at 5 (matching gogram) to prevent infinite recursion.
- Poll loop and reconnect logic bail immediately during active migration instead of racing.

## 0.1.2

- Fixed reconnect-spam loop: long-poll TCP reads no longer time out at 15s and trigger false reconnects.
- Reconnect is now single-flight (mutex-guarded), capped at 20 attempts, with exponential backoff (1s → 30s max).
- Poll loop runs once per client lifetime — no more concurrent pollers spawned per reconnect.

## 0.1.1

- Shorter pub.dev description.
- Replaced stub example with a real bot quickstart (inline buttons + callback handler).
- Bumped `pointycastle` to `^4.0.0` and `lints` to `^6.0.0`.
- Added dartdoc coverage on generated TL types and the main client surface.

## 0.1.0 — first publish

Initial release. Pure-Dart MTProto client against Telegram API layer 225.

- Auth: bot tokens, phone + OTP + 2FA (SRP), string + file sessions
- Messaging: send/edit/delete/forward/pin, Markdown + HTML parse modes, inline button builder
- Updates: socket push + getDifference polling, dedup, auto-reconnect with backoff
- Files: multi-worker parallel up/download, cross-DC sender pool with caching
- DC migration: transparent on USER/PHONE/FILE/NETWORK_MIGRATE
- Conversation API, channels admin ops, participant iteration, bot commands, callback/inline answers
- Logger with TRACE/DEBUG/INFO/WARN/ERROR levels
- 64 tests: 55 unit + 9 live against Telegram
