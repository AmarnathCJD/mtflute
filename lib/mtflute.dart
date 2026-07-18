/// Pure-Dart Telegram MTProto client (API layer 225).
///
/// Supports bots and user accounts. Headline features:
/// - Bot login (`loginBot`) and user login (`login`) with phone + OTP + 2FA SRP.
/// - Markdown and HTML parse modes (`parseMode: 'md' | 'html'`).
/// - Inline button builder ([Keyboard], [Button]).
/// - Multi-worker file upload/download with cross-DC sender pool.
/// - Auto-reconnect with exponential backoff.
/// - Conversation API (`client.conversation(peer).ask(...)`).
/// - Rich error type ([TgError]) with descriptions, migrate/flood helpers.
///
/// Quickstart: see `example/mtflute_example.dart`.
library;

export 'src/crypto/aes_ige.dart';
export 'src/crypto/mtproto_crypto.dart';
export 'src/crypto/rsa_keys.dart';
export 'src/crypto/math.dart';
export 'src/crypto/srp.dart';
export 'src/tl/tl_encoder.dart';
export 'src/tl/tl_decoder.dart';
export 'src/tg/tg.dart' hide DcOption;
export 'src/transport/dc_options.dart';
export 'src/transport/transport_mode.dart';
export 'src/transport/transport.dart';
export 'src/transport/tcp_transport.dart';
export 'src/transport/proxy.dart';
export 'src/transport/obfuscation.dart';
export 'src/transport/fake_tls.dart';
export 'src/transport/websocket_transport.dart';
export 'src/mtproto/messages.dart';
export 'src/mtproto/handshake.dart';
export 'src/mtproto/client.dart';
export 'src/mtproto/events.dart';
export 'src/mtproto/cache.dart';
export 'src/mtproto/session.dart';
export 'src/mtproto/files.dart';
export 'src/mtproto/stream_server.dart';
export 'src/mtproto/media_cache.dart';
export 'src/mtproto/secret_chats.dart';
export 'src/mtproto/dc_migrate.dart';
export 'src/mtproto/errors.dart';
export 'src/mtproto/buttons.dart';
export 'src/mtproto/parsing.dart';
export 'src/mtproto/helpers.dart';
export 'src/mtproto/conversation.dart';
export 'src/mtproto/bot_helpers.dart';
export 'src/mtproto/channels.dart';
export 'src/mtproto/participants.dart';
export 'src/mtproto/progress.dart';
export 'src/mtproto/logger.dart';
