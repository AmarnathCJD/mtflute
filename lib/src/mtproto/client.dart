import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../crypto/mtproto_crypto.dart';
import '../crypto/srp.dart';
import '../transport/tcp_transport.dart';
import '../transport/transport_mode.dart';
import '../transport/dc_options.dart';
import '../tl/tl_encoder.dart';
import '../tl/tl_decoder.dart';
import '../tg/tg.dart';
import 'cache.dart';
import 'errors.dart';
import 'logger.dart';
import 'handshake.dart';
import 'parsing.dart';
import 'messages.dart';
import 'objects.dart';
import 'session.dart';
import 'events.dart';

/// Telegram API layer this client targets. Updated when the TL schema is regenerated.
const apiLayer = 227;

/// Async prompt for credentials (OTP, 2FA password). Used by [MtpClient.login].
typedef InputCallback = Future<String> Function(String prompt);

/// Backwards-compatibility alias for [TgError].
typedef MtpRpcError = TgError;

/// Backwards-compatibility alias for [BoolValue].
typedef BoolResult = BoolValue;

class _RetryWithNewSalt implements Exception {}

/// Pure-Dart Telegram MTProto client.
///
/// Construct with your `appId` + `appHash` (from https://my.telegram.org),
/// then call [loginBot] or [login], register handlers with [onMessage] /
/// [onCallbackQuery] / [onInlineQuery] / [onUpdate], and finally [idle] to
/// run the event loop.
///
/// Sessions are auto-saved to [sessionFile] (default `session.dat`) and
/// reused on next startup — no need to log in twice.
class MtpClient {
  /// Telegram API ID from https://my.telegram.org.
  final int appId;

  /// Telegram API hash from https://my.telegram.org.
  final String appHash;

  /// Current data center the client is connected to (1–5). Updated on migrate.
  int dcId;

  /// Prefer IPv6 endpoints when connecting.
  final bool ipv6;

  /// Device model string sent in `initConnection`.
  final String deviceModel;

  /// System version string sent in `initConnection`.
  final String systemVersion;

  /// App version string sent in `initConnection`.
  final String appVersion;

  /// Language code sent in `initConnection`.
  final String langCode;

  /// Per-request timeout.
  final Duration timeout;

  /// Path to a persistent session file. Pass an ABSOLUTE path on Android
  /// (e.g. `${(await getApplicationDocumentsDirectory()).path}/mtflute.session`).
  /// Set to null to run without persistence.
  final String? sessionFile;

  /// String session (alternative to file session). See [exportSession].
  final String? stringSession;

  TcpTransport? _transport;
  Uint8List? _authKey;
  int _serverSalt = 0;
  int _sessionId = 0;
  int _seqNo = 0;
  int _timeOffset = 0;
  bool _initialized = false;
  bool _authorizedOnce = false;
  final _pendingRequests = <int, Completer<Uint8List>>{};
  final _updateHandlers = <void Function(TlObject update)>[];

  /// In-memory peer cache (users, chats, channels with access hashes).
  /// Auto-populated from incoming updates and RPC responses.
  final PeerCache cache = PeerCache();

  /// Logger for this client. Set [Logger.level] to change verbosity.
  final Logger logger = Logger(prefix: 'mtflute');

  final Map<int, List<MtpClient>> _senderPool = {};
  final Map<int, DateTime> _senderLastUsed = {};

  MtpClient({
    required this.appId,
    required this.appHash,
    this.dcId = 4,
    this.ipv6 = false,
    this.deviceModel = 'MTFlute',
    this.systemVersion = '1.0',
    this.appVersion = '0.1.0',
    this.langCode = 'en',
    this.timeout = const Duration(seconds: 15),
    this.sessionFile,
    this.stringSession,
  }) {
    _sessionId = randomBytes(8).buffer.asByteData().getInt64(0, Endian.little);
    _loadSession();
  }

  void _loadSession() {
    if (stringSession != null) {
      final s = SessionData.decodeString(stringSession!);
      _authKey = s.authKey;
      _serverSalt = s.serverSalt;
      if (s.dcId > 0) dcId = s.dcId;
    } else if (sessionFile != null) {
      try {
        final s = SessionData.loadFromFile(sessionFile!);
        _authKey = s.authKey;
        _serverSalt = s.serverSalt;
        if (s.dcId > 0) dcId = s.dcId;
        if (s.peers != null) cache.loadJson(s.peers!);
      } catch (_) {}
    }
    cache.onDirty = _markSessionDirty;
  }

  Timer? _saveDebounce;
  bool _sessionDirty = false;
  Duration saveDebounce = const Duration(seconds: 2);

  void _markSessionDirty() {
    if (_authKey == null || sessionFile == null) return;
    _sessionDirty = true;
    if (_closing) return;
    _saveDebounce ??= Timer(saveDebounce, () {
      _saveDebounce = null;
      if (_sessionDirty) unawaited(_flushSession());
    });
  }

  void _saveSession() {
    _markSessionDirty();
  }

  Future<void> _flushSession() async {
    if (_authKey == null || sessionFile == null) return;
    final data = SessionData(
      authKey: _authKey,
      authKeyHash: authKeyHash(_authKey!),
      dcId: dcId,
      ipAddr: getDcAddress(dcId, ipv6: ipv6),
      appId: appId,
      serverSalt: _serverSalt,
      peers: cache.toJson(),
    );
    try {
      await data.saveToFileAsync(sessionFile!);
      _sessionDirty = false;
    } catch (e) {
      logger.warn('session write failed: $e');
      _saveDebounce ??= Timer(saveDebounce, () {
        _saveDebounce = null;
        if (_sessionDirty) unawaited(_flushSession());
      });
    }
  }

  String exportSession() {
    return SessionData(
      authKey: _authKey,
      authKeyHash: _authKey != null ? authKeyHash(_authKey!) : null,
      dcId: dcId,
      ipAddr: getDcAddress(dcId, ipv6: ipv6),
      appId: appId,
      serverSalt: _serverSalt,
    ).encodeString();
  }

  void copyAuthFrom(MtpClient other) {
    _authKey = other._authKey;
    _serverSalt = other._serverSalt;
  }

  List<MtpClient> getSendersFor(int dcId) {
    final list = _senderPool[dcId];
    if (list == null) return const [];
    _senderLastUsed[dcId] = DateTime.now();
    return List.unmodifiable(list);
  }

  void addSenderFor(int dcId, MtpClient sender) {
    final list = _senderPool.putIfAbsent(dcId, () => []);
    list.add(sender);
    _senderLastUsed[dcId] = DateTime.now();
  }

  Future<void> evictIdleSenders({
    Duration after = const Duration(minutes: 30),
  }) async {
    final now = DateTime.now();
    final toRemove = <int>[];
    for (final entry in _senderLastUsed.entries) {
      if (now.difference(entry.value) > after) toRemove.add(entry.key);
    }
    for (final dc in toRemove) {
      final list = _senderPool.remove(dc) ?? const [];
      _senderLastUsed.remove(dc);
      for (final s in list) {
        try {
          await s.close();
        } catch (_) {}
      }
    }
  }

  bool get isConnected => _transport?.isConnected ?? false;

  TcpTransport? get transport => _transport;

  bool _pollLoopRunning = false;
  Completer<void>? _connectInFlight;

  Future<void> connect() async {
    if (_closing) throw StateError('Client is closed');
    final inflight = _connectInFlight;
    if (inflight != null) return inflight.future;
    final gate = Completer<void>();
    _connectInFlight = gate;
    try {
      await _doConnect();
      gate.complete();
    } catch (e, st) {
      gate.completeError(e, st);
      rethrow;
    } finally {
      _connectInFlight = null;
    }
  }

  Future<void> _doConnect() async {
    final addr = getDcAddress(dcId, ipv6: ipv6);
    final parts = addr.split(':');

    final oldTransport = _transport;
    _transport = null;
    if (oldTransport != null) {
      try {
        await oldTransport.close();
      } catch (_) {}
    }

    _transport = TcpTransport(
      host: parts[0],
      port: int.parse(parts[1]),
      modeVariant: TransportModeVariant.abridged,
      timeout: timeout,
    );
    await _transport!.connect();

    if (_authKey == null) {
      final result = await performHandshake(
        sendAndReceive: _sendUnencrypted,
        dcId: dcId,
      );
      _authKey = result.authKey;
      _serverSalt = result.serverSalt;
      _timeOffset =
          result.serverTime - (DateTime.now().millisecondsSinceEpoch ~/ 1000);
      _saveSession();
      _initialized = false;
    }

    if (!_pollLoopRunning) {
      _pollLoopRunning = true;
      unawaited(_pollResponses());
    }
  }

  Future<void>? _ensureReadyInFlight;

  Future<void> _ensureReady() async {
    if (_closing) throw StateError('Client is closed');
    final inflight = _ensureReadyInFlight;
    if (inflight != null) return inflight;
    final work = _ensureReadyImpl();
    _ensureReadyInFlight = work;
    try {
      await work;
    } finally {
      _ensureReadyInFlight = null;
    }
  }

  Future<void> _ensureReadyImpl() async {
    final deadline = DateTime.now().add(timeout);
    while (_reconnectInProgress && !_closing && !_migrateInProgress) {
      if (DateTime.now().isAfter(deadline)) {
        throw TimeoutException('reconnect in progress', timeout);
      }
      await Future.delayed(const Duration(milliseconds: 50));
    }
    if (_closing) throw StateError('Client is closed');
    final t = _transport;
    if (t != null && t.isConnected) {
      final idle = DateTime.now().difference(t.lastReadAt);
      if (idle > const Duration(seconds: 90)) {
        logger.warn('transport idle ${idle.inSeconds}s — forcing reconnect');
        try { await t.close(); } catch (_) {}
      }
    }
    if (!isConnected) await connect();
    if (!_initialized) {
      await _sendTlObject(
        InvokeWithLayerRequest(
          layer: apiLayer,
          query: InitConnectionRequest(
            apiId: appId,
            deviceModel: deviceModel,
            systemVersion: systemVersion,
            appVersion: appVersion,
            systemLangCode: langCode,
            langPack: '',
            langCode: langCode,
            query: HelpGetConfigRequest(),
          ),
        ),
      );
      _initialized = true;
      if (_authKey != null && _pingTimer == null) {
        unawaited(_startUpdatesLoop());
      }
    }
  }

  int _migrateDepth = 0;

  static final _terminalAuthErrors = <String>{
    'AUTH_KEY_UNREGISTERED',
    'AUTH_KEY_INVALID',
    'USER_DEACTIVATED',
    'SESSION_REVOKED',
    'SESSION_EXPIRED',
  };

  /// How many times [invoke] transparently retries after a network blip
  /// (transport error, reconnect-invalidated pending request, timeout).
  /// Server-side errors are never retried — only local disconnects.
  int invokeRetries = 3;

  Future<TlObject> invoke(TlObject request) async {
    if (_closing) throw StateError('Client is closed');

    dynamic lastNetworkErr;
    for (var attempt = 0; attempt <= invokeRetries; attempt++) {
      if (_reconnectInProgress) {
        while (_reconnectInProgress && !_closing) {
          await Future.delayed(const Duration(milliseconds: 50));
        }
      }
      if (_closing) throw StateError('Client is closed');

      try {
        await _ensureReady();
      } catch (e) {
        lastNetworkErr = e;
        if (autoReconnect && !_closing && attempt < invokeRetries) {
          await Future.delayed(Duration(milliseconds: 100 * (1 << attempt)));
          continue;
        }
        rethrow;
      }

      try {
        final raw = await _sendTlObject(request);
        final result = _decodeResponse(raw);
        _cacheFromResponse(result);
        return result;
      } on TgError catch (e) {
        if (e.isMigrate && e.migrateDc != null) {
          if (_migrateDepth >= 5) {
            _migrateDepth = 0;
            throw StateError(
              'DC migration depth exceeded (target DC${e.migrateDc})',
            );
          }
          _migrateDepth++;
          try {
            await _migrateTo(e.migrateDc!);
            return invoke(request);
          } finally {
            _migrateDepth--;
          }
        }
        if (_authorizedOnce && _terminalAuthErrors.any(e.matches)) {
          autoReconnect = false;
          _stopBackgroundTimers();
        }
        rethrow;
      } on _RetryWithNewSalt catch (e) {
        lastNetworkErr = e;
      } on BadMsgError catch (e) {
        lastNetworkErr = e;
      } on StateError catch (e) {
        lastNetworkErr = e;
      } on SocketException catch (e) {
        lastNetworkErr = e;
      } on TimeoutException catch (e) {
        lastNetworkErr = e;
      }

      if (attempt < invokeRetries && autoReconnect && !_closing) {
        await Future.delayed(Duration(milliseconds: 100 * (1 << attempt)));
        continue;
      }
      break;
    }
    throw (lastNetworkErr ?? StateError('invoke failed with no error')) as Object;
  }

  Future<void> _migrateTo(int newDc) async {
    logger.info('migrating to DC$newDc');
    _migrateInProgress = true;

    try {
      _stopBackgroundTimers();
      _updatesRunning = false;

      try {
        await _transport?.close();
      } catch (_) {}
      _transport = null;

      final pending = List.of(_pendingRequests.entries);
      _pendingRequests.clear();
      for (final e in pending) {
        if (!e.value.isCompleted) {
          e.value.completeError(StateError('DC migration in progress'));
        }
      }

      // Wait for the old poll loop to exit; it observes _migrateInProgress.
      final deadline = DateTime.now().add(const Duration(seconds: 5));
      while (_pollLoopRunning && DateTime.now().isBefore(deadline)) {
        await Future.delayed(const Duration(milliseconds: 50));
      }

      _authKey = null;
      _serverSalt = 0;
      _initialized = false;
      _seqNo = 0;
      _lastMsgId = 0;
      _sessionId =
          randomBytes(8).buffer.asByteData().getInt64(0, Endian.little);
      dcId = newDc;
    } finally {
      _migrateInProgress = false;
    }

    await connect();
    _saveSession();
  }

  void _cacheFromResponse(TlObject obj) {
    if (obj is MessagesDialogsObj) {
      cache.updateFromUsers(obj.users);
      cache.updateFromChats(obj.chats);
    } else if (obj is MessagesMessagesObj) {
      cache.updateFromUsers(obj.users);
      cache.updateFromChats(obj.chats);
    } else if (obj is MessagesChatsObj) {
      cache.updateFromChats(obj.chats);
    } else if (obj is ContactsContactsObj) {
      cache.updateFromUsers(obj.users);
    }
  }

  // ---------- Auth: Bot ----------

  Future<AuthAuthorization?> loginBot(String botToken) async {
    if (await isAuthorized()) {
      logger.debug('reusing existing session');
      return null;
    }
    final raw = await invoke(
      AuthImportBotAuthorizationRequest(
        flags: 1,
        apiId: appId,
        apiHash: appHash,
        botAuthToken: botToken,
      ),
    );
    logger.debug('loginBot result: ${raw.runtimeType}');
    final result = raw as AuthAuthorization;
    _authorizedOnce = true;
    autoReconnect = true;
    _saveSession();
    await Future.delayed(const Duration(milliseconds: 500));
    await _startUpdatesLoop();
    return result;
  }

  Timer? _pingTimer;
  Timer? _diffTimer;
  int _pts = 0;
  int _qts = 0;
  int _date = 0;
  bool _updatesRunning = false;
  bool _diffInFlight = false;
  bool _timersPaused = false;
  DateTime? _diffBackoffUntil;

  Future<void> _startUpdatesLoop() async {
    if (_updatesRunning) return;
    _updatesRunning = true;

    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final state = await invoke(UpdatesGetStateRequest());
        if (state is UpdatesStateObj) {
          _pts = state.pts;
          _qts = state.qts;
          _date = state.date;
          logger.debug('initial state pts=$_pts qts=$_qts date=$_date');
          break;
        }
      } catch (e) {
        logger.debug('getState attempt ${attempt + 1} failed: $e');
        if (attempt < 2) {
          await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
        }
      }
    }
    _startBackgroundTimers();
  }

  void _startBackgroundTimers() {
    _pingTimer?.cancel();
    _diffTimer?.cancel();
    _timersPaused = false;

    _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (_timersPaused || _closing || !isConnected || _reconnectInProgress ||
          _migrateInProgress) {
        return;
      }
      await _fireAndForget(
        PingRequest(
          pingId:
              randomBytes(8).buffer.asByteData().getInt64(0, Endian.little),
        ),
      );
    });

    _diffTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (_timersPaused || _closing || !isConnected || _reconnectInProgress ||
          _migrateInProgress) {
        return;
      }
      if (_pts == 0 || _date == 0) return;
      if (_diffInFlight) return;
      if (_diffBackoffUntil != null &&
          DateTime.now().isBefore(_diffBackoffUntil!)) {
        return;
      }
      _diffInFlight = true;
      try {
        final diff = await invoke(
          UpdatesGetDifferenceRequest(pts: _pts, date: _date, qts: _qts),
        );
        _applyDifference(diff);
        _diffBackoffUntil = null;
      } on TgError catch (e) {
        if (e.isFlood && e.waitDuration != null) {
          _diffBackoffUntil = DateTime.now().add(e.waitDuration!);
        }
      } catch (_) {
      } finally {
        _diffInFlight = false;
      }
    });
  }

  void _stopBackgroundTimers() {
    _timersPaused = true;
    _pingTimer?.cancel();
    _pingTimer = null;
    _diffTimer?.cancel();
    _diffTimer = null;
    _updatesRunning = false;
  }

  void _applyDifference(TlObject diff) {
    if (diff is UpdatesDifferenceEmpty) {
      _date = diff.date;
      _seqOrDate(diff.seq);
    } else if (diff is UpdatesDifferenceObj) {
      cache.updateFromUsers(diff.users);
      cache.updateFromChats(diff.chats);
      for (final m in diff.newMessages) {
        _handleNewMessage(m);
      }
      for (final u in diff.otherUpdates) {
        _dispatchUpdate(u);
      }
      final s = diff.state;
      if (s is UpdatesStateObj) {
        _pts = s.pts;
        _qts = s.qts;
        _date = s.date;
      }
    } else if (diff is UpdatesDifferenceSlice) {
      cache.updateFromUsers(diff.users);
      cache.updateFromChats(diff.chats);
      for (final m in diff.newMessages) {
        _handleNewMessage(m);
      }
      for (final u in diff.otherUpdates) {
        _dispatchUpdate(u);
      }
      final s = diff.intermediateState;
      if (s is UpdatesStateObj) {
        _pts = s.pts;
        _qts = s.qts;
        _date = s.date;
      }
    } else if (diff is UpdatesDifferenceTooLong) {
      _pts = diff.pts;
    }
  }

  void _seqOrDate(int _) {}

  // ---------- Auth: Phone ----------

  Future<AuthSentCode> sendCode(String phoneNumber) async {
    return (await invoke(
          AuthSendCodeRequest(
            phoneNumber: phoneNumber,
            apiId: appId,
            apiHash: appHash,
            settings: CodeSettingsObj(),
          ),
        ))
        as AuthSentCode;
  }

  Future<AuthAuthorization> signIn({
    required String phone,
    required String codeHash,
    required String code,
  }) async {
    return (await invoke(
          AuthSignInRequest(
            phoneNumber: phone,
            phoneCodeHash: codeHash,
            phoneCode: code,
          ),
        ))
        as AuthAuthorization;
  }

  Future<AuthAuthorization> checkPassword(String password) async {
    final pwd =
        (await invoke(AccountGetPasswordRequest())) as AccountPasswordObj;
    final inputPwd = _computeSrpPassword(password, pwd);
    return (await invoke(AuthCheckPasswordRequest(password: inputPwd)))
        as AuthAuthorization;
  }

  InputCheckPasswordSRP _computeSrpPassword(
    String password,
    AccountPasswordObj pwd,
  ) {
    final algo = pwd.currentAlgo;
    if (algo
        is! PasswordKdfAlgoSHA256SHA256PBKDF2HMACSHA512iter100000SHA256ModPow) {
      throw StateError('Unsupported password algorithm: ${algo.runtimeType}');
    }

    final result = computeSrpCheck(
      password: password,
      srpB: pwd.srpB!,
      salt1: algo.salt1,
      salt2: algo.salt2,
      g: algo.g,
      p: algo.p,
    );

    if (result == null) return InputCheckPasswordEmpty();

    return InputCheckPasswordSRPObj(
      srpId: pwd.srpId!,
      A: result.ga,
      M1: result.m1,
    );
  }

  Future<bool> isAuthorized() async {
    try {
      final s = await invoke(UpdatesGetStateRequest());
      if (s is UpdatesStateObj) {
        _pts = s.pts;
        _qts = s.qts;
        _date = s.date;
      }
      _authorizedOnce = true;
      unawaited(_startUpdatesLoop());
      return true;
    } catch (_) {
      return false;
    }
  }

  // ---------- Auth: Interactive ----------

  Future<void> login({
    String? botToken,
    String? phone,
    InputCallback? codeCallback,
    InputCallback? passwordCallback,
    int maxRetries = 3,
  }) async {
    await _ensureReady();

    if (await isAuthorized()) return;

    if (botToken != null) {
      await loginBot(botToken);
      return;
    }

    codeCallback ??= _stdinPrompt;
    passwordCallback ??= _stdinPrompt;

    phone ??= (await codeCallback('Enter phone number: ')).trim();

    final sent = await sendCode(phone);
    String? codeHash;
    if (sent is AuthSentCodeObj) {
      codeHash = sent.phoneCodeHash;
    }
    if (codeHash == null) throw StateError('Failed to get code hash');

    for (var attempt = 0; attempt < maxRetries; attempt++) {
      final code = (await codeCallback('Enter OTP code: ')).trim();
      if (code.isEmpty) continue;

      try {
        await signIn(phone: phone, codeHash: codeHash, code: code);
        _authorizedOnce = true;
        autoReconnect = true;
        _saveSession();
        await _startUpdatesLoop();
        return;
      } on MtpRpcError catch (e) {
        if (e.matches('PHONE_CODE_INVALID')) {
          if (attempt < maxRetries - 1) continue;
          rethrow;
        }
        if (e.matches('SESSION_PASSWORD_NEEDED')) {
          for (var pwAttempt = 0; pwAttempt < maxRetries; pwAttempt++) {
            final pw = (await passwordCallback('Enter 2FA password: ')).trim();
            try {
              await checkPassword(pw);
              _authorizedOnce = true;
              autoReconnect = true;
              _saveSession();
              await _startUpdatesLoop();
              return;
            } on MtpRpcError catch (e2) {
              if (e2.matches('PASSWORD_HASH_INVALID') &&
                  pwAttempt < maxRetries - 1) {
                continue;
              }
              rethrow;
            }
          }
        }
        rethrow;
      }
    }
  }

  static Future<String> _stdinPrompt(String prompt) async {
    if (Platform.isAndroid || Platform.isIOS) {
      throw StateError(
        'login() called without a codeCallback/passwordCallback on mobile; '
        'stdin is not available. Pass codeCallback and passwordCallback.',
      );
    }
    stdout.write(prompt);
    return stdin.readLineSync() ?? '';
  }

  // ---------- Updates ----------

  final _messageHandlers = <void Function(NewMessage msg)>[];
  final _callbackQueryHandlers = <void Function(CallbackQuery query)>[];
  final _inlineQueryHandlers = <void Function(InlineQuery query)>[];

  void onMessage(void Function(NewMessage msg) handler) {
    _messageHandlers.add(handler);
  }

  void removeMessageHandler(void Function(NewMessage msg) handler) {
    _messageHandlers.remove(handler);
  }

  void onCallbackQuery(void Function(CallbackQuery query) handler) {
    _callbackQueryHandlers.add(handler);
  }

  void removeCallbackQueryHandler(void Function(CallbackQuery query) handler) {
    _callbackQueryHandlers.remove(handler);
  }

  void onInlineQuery(void Function(InlineQuery query) handler) {
    _inlineQueryHandlers.add(handler);
  }

  void removeInlineQueryHandler(void Function(InlineQuery query) handler) {
    _inlineQueryHandlers.remove(handler);
  }

  void onUpdate(void Function(TlObject update) handler) {
    _updateHandlers.add(handler);
  }

  void removeUpdateHandler(void Function(TlObject update) handler) {
    _updateHandlers.remove(handler);
  }

  void _dispatchUpdate(TlObject update) {
    for (final handler in _updateHandlers) {
      handler(update);
    }

    if (update is UpdateNewMessage) {
      _handleNewMessage(update.message);
    } else if (update is UpdateNewChannelMessage) {
      _handleNewMessage(update.message);
    } else if (update is UpdateBotCallbackQuery &&
        _callbackQueryHandlers.isNotEmpty) {
      final cq = CallbackQuery(client: this, update: update);
      for (final h in _callbackQueryHandlers) {
        h(cq);
      }
    } else if (update is UpdateBotInlineQuery &&
        _inlineQueryHandlers.isNotEmpty) {
      final iq = InlineQuery(client: this, update: update);
      for (final h in _inlineQueryHandlers) {
        h(iq);
      }
    } else if (update is UpdatesObj) {
      cache.updateFromUsers(update.users);
      cache.updateFromChats(update.chats);
      for (final u in update.updates) {
        _dispatchUpdate(u);
      }
    } else if (update is UpdatesCombined) {
      cache.updateFromUsers(update.users);
      cache.updateFromChats(update.chats);
      for (final u in update.updates) {
        _dispatchUpdate(u);
      }
    } else if (update is UpdateShortMessage) {
      _handleNewMessage(
        MessageObj(
          id: update.id,
          peerId: PeerUser(userId: update.userId),
          message: update.message,
          date: update.date,
          out: update.out,
        ),
      );
    } else if (update is UpdateShortChatMessage) {
      _handleNewMessage(
        MessageObj(
          id: update.id,
          peerId: PeerChat(chatId: update.chatId),
          message: update.message,
          date: update.date,
          out: update.out,
        ),
      );
    }
  }

  void _handleNewMessage(Message msg) {
    if (msg is! MessageObj || _messageHandlers.isEmpty) return;
    if (msg.out) return;
    if (!_markProcessed(msg.id)) return;

    final peerId = msg.peerId;
    InputPeer peer;
    int chatId;

    if (peerId is PeerUser) {
      chatId = peerId.userId;
      peer = InputPeerUser(
        userId: peerId.userId,
        accessHash: cache.getUserAccessHash(peerId.userId),
      );
    } else if (peerId is PeerChat) {
      chatId = -peerId.chatId;
      peer = InputPeerChat(chatId: peerId.chatId);
    } else if (peerId is PeerChannel) {
      chatId = -peerId.channelId;
      peer = InputPeerChannel(
        channelId: peerId.channelId,
        accessHash: cache.getChannelAccessHash(peerId.channelId),
      );
    } else {
      return;
    }

    final nm = NewMessage(
      client: this,
      message: msg,
      chatId: chatId,
      peer: peer,
    );

    for (final h in _messageHandlers) {
      h(nm);
    }
  }

  // ---------- Common API Helpers ----------

  Future<TlObject> sendMessage({
    required InputPeer peer,
    required String text,
    int? replyToMsgId,
    ReplyMarkup? buttons,
    List<MessageEntity>? entities,
    String? parseMode,
    bool silent = false,
    bool noWebpage = false,
  }) async {
    if (parseMode != null && entities == null) {
      final parsed = parseText(text, parseMode);
      text = parsed.text;
      entities = parsed.entities;
    }
    return invoke(
      MessagesSendMessageRequest(
        peer: peer,
        message: text,
        randomId: randomBytes(8).buffer.asByteData().getInt64(0, Endian.little),
        replyTo: replyToMsgId != null
            ? InputReplyToMessage(replyToMsgId: replyToMsgId)
            : null,
        replyMarkup: buttons,
        entities: entities,
        silent: silent,
        noWebpage: noWebpage,
      ),
    );
  }

  Future<void> logOut() async {
    await invoke(AuthLogOutRequest());
  }

  // ---------- Transport internals ----------

  Future<Uint8List> _sendTlObject(TlObject obj) async {
    final encoder = TlEncoder();
    obj.encode(encoder);
    return _sendRawRequest(encoder.toBytes());
  }

  Future<void> _fireAndForget(TlObject obj, {bool contentRelated = false}) async {
    if (_transport == null || !_transport!.isConnected || _authKey == null) {
      return;
    }
    final encoder = TlEncoder();
    obj.encode(encoder);
    final msgId = _genMsgId();
    final seqNo = _nextSeqNo(contentRelated: contentRelated);
    final serialized = serializeEncrypted(
      msg: encoder.toBytes(),
      msgId: msgId,
      seqNo: seqNo,
      authKey: _authKey!,
      serverSalt: _serverSalt,
      sessionId: _sessionId,
    );
    final prev = _writeLock;
    final next = Completer<void>();
    _writeLock = next.future;
    try {
      await prev;
      await _transport!.writeMsg(serialized);
    } catch (_) {} finally {
      next.complete();
    }
  }

  Future<void> _writeLock = Future.value();

  Future<Uint8List> _sendRawRequest(Uint8List data) async {
    if (_transport == null || !_transport!.isConnected) {
      throw StateError('Not connected');
    }

    final msgId = _genMsgId();
    final seqNo = _nextSeqNo(contentRelated: true);

    final serialized = serializeEncrypted(
      msg: data,
      msgId: msgId,
      seqNo: seqNo,
      authKey: _authKey!,
      serverSalt: _serverSalt,
      sessionId: _sessionId,
    );

    final completer = Completer<Uint8List>();
    _pendingRequests[msgId] = completer;

    final prev = _writeLock;
    final next = Completer<void>();
    _writeLock = next.future;
    await prev;
    try {
      await _transport!.writeMsg(serialized);
    } finally {
      next.complete();
    }

    return completer.future.timeout(
      timeout,
      onTimeout: () {
        _pendingRequests.remove(msgId);
        throw TimeoutException('Request timed out', timeout);
      },
    );
  }

  TlObject _decodeResponse(Uint8List data) {
    final crc = ByteData.view(
      data.buffer,
      data.offsetInBytes,
    ).getUint32(0, Endian.little);

    if (crc == crcRpcError) {
      final d = TlDecoder(data);
      d.readCrc();
      throw rpcErrorFromCode(d.readInt32(), d.readString());
    }

    if (crc == crcGzipPacked) {
      final d = TlDecoder(data);
      d.readCrc();
      final packed = d.readBytes();
      final unpacked = Uint8List.fromList(gzip.decode(packed));
      return _decodeResponse(unpacked);
    }

    if (crc == 0x1cb5c415) {
      final d = TlDecoder(data);
      d.readCrc();
      return VectorResult.decode(d);
    }

    if (crc == BoolValue.trueCrc) return BoolValue(true);
    if (crc == BoolValue.falseCrc) return BoolValue(false);

    return decodeObject(TlDecoder(data));
  }

  bool _closing = false;
  bool autoReconnect = true;

  /// Max reconnect attempts before giving up. 0 = infinite (not recommended).
  int maxReconnectAttempts = 20;

  /// Backoff cap (max wait between reconnect tries).
  Duration maxReconnectDelay = const Duration(seconds: 30);

  bool _reconnectInProgress = false;
  bool _migrateInProgress = false;

  Future<void> _pollResponses() async {
    try {
      while (!_closing && !_migrateInProgress) {
        final t = _transport;
        if (t == null || !t.isConnected) {
          if (!autoReconnect) break;
          final ok = await _reconnect();
          if (!ok) break;
          continue;
        }
        try {
          final data = await t.readMsg();
          await _processIncoming(data);
        } catch (e) {
          if (_closing || _migrateInProgress) break;
          if (!autoReconnect) break;
          logger.warn('read error: $e — reconnecting');
          final ok = await _reconnect();
          if (!ok) break;
        }
      }
    } finally {
      _pollLoopRunning = false;
      logger.debug('poll loop exited');
    }
  }

  /// Single-flight reconnect: only one reconnect runs at a time, with capped
  /// exponential backoff and jitter. Returns true on success, false if we
  /// gave up (max attempts reached, or client is closing/migrating).
  ///
  /// Reuses the persisted auth_key — no fresh handshake unless the key was
  /// discarded (e.g. via AUTH_KEY_UNREGISTERED / bad_msg auth error).
  Future<bool> _reconnect() async {
    if (_migrateInProgress || _closing) return false;
    if (_reconnectInProgress) {
      // Wait for the in-flight reconnect to finish, then reflect its outcome.
      while (_reconnectInProgress && !_closing && !_migrateInProgress) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _transport?.isConnected ?? false;
    }
    _reconnectInProgress = true;
    _stopBackgroundTimers();
    _initialized = false;

    try {
      // Drain pending requests once — they'll surface a clean error to callers
      // instead of hanging on the old socket. Callers may retry themselves.
      final pending = List.of(_pendingRequests.entries);
      _pendingRequests.clear();
      for (final e in pending) {
        if (!e.value.isCompleted) {
          e.value.completeError(
            StateError('reconnect: pending request invalidated'),
          );
        }
      }

      for (
        var attempt = 1;
        maxReconnectAttempts == 0 || attempt <= maxReconnectAttempts;
        attempt++
      ) {
        if (_closing || _migrateInProgress) return false;

        // Exponential backoff, capped at maxReconnectDelay. Attempt 1 has no
        // wait so we recover instantly from a fluke disconnect; from attempt 2
        // onwards it's 1s, 2s, 4s, 8s, 16s, then capped.
        if (attempt > 1) {
          final base = 1 << (attempt - 2).clamp(0, 6); // 1,2,4,8,16,32,64
          final capped = base.clamp(1, maxReconnectDelay.inSeconds);
          final jitterMs =
              (randomBytes(2).buffer.asByteData().getUint16(0, Endian.little) %
                  500);
          final delay =
              Duration(seconds: capped, milliseconds: jitterMs);
          logger.info('reconnect attempt $attempt (wait $delay)');
          await Future.delayed(delay);
        }
        if (_closing || _migrateInProgress) return false;

        // Defense in depth: another path may have restored the transport
        // (e.g. a stray _ensureReady call). If so, skip teardown and reuse.
        if (_transport?.isConnected == true) {
          logger.info('reconnect: transport already healthy on attempt $attempt');
          if (_authKey != null) _startBackgroundTimers();
          return true;
        }

        // Reset per-connection state, keep auth_key + serverSalt.
        _seqNo = 0;
        _sessionId =
            randomBytes(8).buffer.asByteData().getInt64(0, Endian.little);
        _lastMsgId = 0;

        try {
          // Route through the same single-flight gate as connect() so a
          // concurrent _ensureReady() caller can't spin up a second socket.
          await connect();
          logger.info('reconnected on attempt $attempt');
          if (_authKey != null) {
            _startBackgroundTimers();
          }
          return true;
        } catch (e) {
          logger.warn('reconnect attempt $attempt failed: $e');
        }
      }
      logger.error('reconnect: giving up after $maxReconnectAttempts attempts');
      return false;
    } finally {
      _reconnectInProgress = false;
    }
  }

  Future<void> _processIncoming(Uint8List data) async {
    if (!isPacketEncrypted(data)) {
      final msg = deserializeUnencrypted(data);
      _dispatchResponse(msg.msgId, msg.msg);
      return;
    }

    // Large ciphertexts (file chunks) decrypt in a worker isolate so the AES
    // loop never blocks the main isolate; small ones stay inline. Dispatch is
    // by msgId into per-request completers, so the isolate hop can't reorder
    // RPC results.
    final msg = await deserializeEncryptedAsync(data, _authKey!);
    final d = TlDecoder(msg.msg);
    final crc = d.readCrc();

    if (crc == crcRpcResult) {
      _dispatchResponse(d.readInt64(), d.readRestOfMessage());
      return;
    }

    if (crc == crcMessageContainer) {
      final count = d.readUint32();
      for (var i = 0; i < count; i++) {
        d.readInt64();
        d.readInt32();
        final innerLen = d.readUint32();
        _processInnerMessage(d.readRawBytes(innerLen));
      }
      return;
    }

    switch (crc) {
      case crcBadServerSalt:
        final badMsgId = d.readInt64();
        d.readInt32();
        d.readInt32();
        _serverSalt = d.readInt64();
        _saveSession();
        final pending = _pendingRequests.remove(badMsgId);
        if (pending != null && !pending.isCompleted) {
          pending.completeError(_RetryWithNewSalt());
        }

      case crcNewSessionCreated:
        d.readInt64();
        d.readInt64();
        _serverSalt = d.readInt64();
        _saveSession();

      case crcBadMsgNotification:
        final badMsgId = d.readInt64();
        d.readInt32();
        final errorCode = d.readInt32();
        if (errorCode == 16 || errorCode == 17) {
          _timeOffset = (msg.msgId >> 32) -
              (DateTime.now().millisecondsSinceEpoch ~/ 1000);
        }
        if (errorCode == 32 || errorCode == 33) {
          _seqNo = 0;
          _sessionId = randomBytes(8).buffer.asByteData().getInt64(0, Endian.little);
          _lastMsgId = 0;
          final drained = List.of(_pendingRequests.entries);
          _pendingRequests.clear();
          for (final e in drained) {
            if (!e.value.isCompleted) {
              e.value.completeError(_RetryWithNewSalt());
            }
          }
          return;
        }
        final pending = _pendingRequests.remove(badMsgId);
        if (pending != null && !pending.isCompleted) {
          if (errorCode == 16 || errorCode == 17 || errorCode == 48) {
            pending.completeError(_RetryWithNewSalt());
          } else {
            pending.completeError(
              BadMsgError(code: errorCode, msgId: badMsgId));
          }
        }

      case crcMsgsAck || crcPong:
        break;

      default:
        _tryDispatchAsUpdate(crc, msg.msg);
    }
  }

  void _processInnerMessage(Uint8List data) {
    final d = TlDecoder(data);
    final crc = d.readCrc();

    if (crc == crcRpcResult) {
      _dispatchResponse(d.readInt64(), d.readRestOfMessage());
      return;
    }

    _tryDispatchAsUpdate(crc, data);
  }

  bool _debugUpdates = false;
  bool get debugUpdates => _debugUpdates;
  set debugUpdates(bool v) {
    _debugUpdates = v;
    logger.level = v ? LogLevel.trace : LogLevel.info;
  }

  final _processedMsgIds = <int>{};
  final _processedOrder = <int>[];
  static const _processedCap = 16384;

  bool _markProcessed(int id) {
    if (_processedMsgIds.contains(id)) return false;
    _processedMsgIds.add(id);
    _processedOrder.add(id);
    if (_processedOrder.length > _processedCap) {
      final old = _processedOrder.removeAt(0);
      _processedMsgIds.remove(old);
    }
    return true;
  }

  void _tryDispatchAsUpdate(int crc, Uint8List data) {
    logger.trace('incoming crc=0x${crc.toRadixString(16)} len=${data.length}');
    if (_updateHandlers.isEmpty &&
        _messageHandlers.isEmpty &&
        _callbackQueryHandlers.isEmpty &&
        _inlineQueryHandlers.isEmpty) {
      return;
    }
    try {
      final obj = decodeObject(TlDecoder(data));
      logger.debug('decoded ${obj.runtimeType}');
      _dispatchUpdate(obj);
    } catch (e) {
      logger.trace('decode failed: $e');
    }
  }

  void _dispatchResponse(int msgId, Uint8List data) {
    final completer = _pendingRequests.remove(msgId);
    if (completer != null && !completer.isCompleted) {
      completer.complete(data);
    }
  }

  Future<Uint8List> _sendUnencrypted(Uint8List request) async {
    final serialized = serializeUnencrypted(request, _genMsgId());
    await _transport!.writeMsg(serialized);
    final response = await _transport!.readMsg();
    return deserializeUnencrypted(response).msg;
  }

  int _lastMsgId = 0;

  int _genMsgId() {
    // Port of gogram's NewMsgIDGenerator (utils.go):
    // msg_id = (unix_seconds << 32) | (nanos & ~3)
    // Force monotonicity by bumping +4 if not strictly greater than last.
    final nowMicros =
        DateTime.now().microsecondsSinceEpoch + _timeOffset * 1000000;
    final nowSec = nowMicros ~/ 1000000;
    final nowNano = ((nowMicros % 1000000) * 1000) & -4; // mod 4
    var msgId = (nowSec << 32) | nowNano;
    if (msgId <= _lastMsgId) {
      msgId = _lastMsgId + 4;
    }
    _lastMsgId = msgId;
    return msgId;
  }

  int _nextSeqNo({bool contentRelated = false}) {
    if (contentRelated) {
      final result = _seqNo * 2 + 1;
      _seqNo++;
      return result;
    }
    return _seqNo * 2;
  }

  Future<void> close() async {
    _closing = true;
    _saveDebounce?.cancel();
    _saveDebounce = null;
    _stopBackgroundTimers();
    _updatesRunning = false;
    if (!(_idleCompleter?.isCompleted ?? true)) {
      _idleCompleter?.complete();
    }
    _idleCompleter = null;

    // Fail any in-flight callers so awaits unwind rather than hang.
    for (final entry in _pendingRequests.entries) {
      if (!entry.value.isCompleted) {
        entry.value.completeError(StateError('Client closed'));
      }
    }
    _pendingRequests.clear();

    for (final list in _senderPool.values) {
      for (final s in list) {
        try {
          await s.close();
        } catch (_) {}
      }
    }
    _senderPool.clear();
    _senderLastUsed.clear();
    try {
      await _transport?.close();
    } catch (_) {}
    _transport = null;
    _updateHandlers.clear();
    _messageHandlers.clear();
    _callbackQueryHandlers.clear();
    _inlineQueryHandlers.clear();
    if (_sessionDirty) {
      try {
        await _flushSession();
      } catch (_) {}
    }
  }

  Completer<void>? _idleCompleter;
  StreamSubscription<ProcessSignal>? _sigintSub;
  StreamSubscription<ProcessSignal>? _sigtermSub;

  Future<void> idle({bool handleSignals = true}) async {
    _idleCompleter ??= Completer<void>();

    if (handleSignals) {
      try {
        _sigintSub = ProcessSignal.sigint.watch().listen((_) {
          logger.info('SIGINT received, shutting down');
          if (!(_idleCompleter?.isCompleted ?? true)) {
            _idleCompleter!.complete();
          }
        });
      } catch (_) {}
      if (!Platform.isWindows) {
        try {
          _sigtermSub = ProcessSignal.sigterm.watch().listen((_) {
            if (!(_idleCompleter?.isCompleted ?? true)) {
              _idleCompleter!.complete();
            }
          });
        } catch (_) {}
      }
    }

    await _idleCompleter!.future;
    await _sigintSub?.cancel();
    await _sigtermSub?.cancel();
    await close();
  }

  void stop() {
    if (!(_idleCompleter?.isCompleted ?? true)) _idleCompleter!.complete();
  }
}
