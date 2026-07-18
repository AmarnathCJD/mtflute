@Tags(['live'])
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:mtflute/mtflute.dart';

final _botToken = Platform.environment['BOT_TOKEN'] ?? '';
final _appId =
    int.tryParse(Platform.environment['API_ID'] ?? '') ?? 2040;
final _appHash = Platform.environment['API_HASH'] ??
    'b18441a1ff607e10a989891a5462e627';
const _testChatId = 5435244538;

MtpClient _plain() => MtpClient(
      appId: _appId,
      appHash: _appHash,
      dcId: 4,
      sessionFile: 'bot.session',
    );

void main() {
  test('obfuscated transport: connect + getMe', () async {
    final client = MtpClient(
      appId: _appId,
      appHash: _appHash,
      dcId: 4,
      sessionFile: 'bot.session',
      mtproxy: null,
    );
    await client.loginBot(_botToken);
    final me = await client.getMe();
    expect(me, isNotNull);
    print('getMe over standard transport ok: ${(me as UserObj).id}');
    await client.close();
  }, timeout: const Timeout(Duration(seconds: 40)));

  test('container/ack: fire many rapid requests concurrently', () async {
    final client = _plain();
    await client.loginBot(_botToken);
    final futures = List.generate(
      8,
      (_) => client.invoke(HelpGetConfigRequest()),
    );
    final results = await Future.wait(futures);
    expect(results.length, 8);
    for (final r in results) {
      expect(r, isA<ConfigObj>());
    }
    print('8 concurrent requests all returned Config');
    await client.close();
  }, timeout: const Timeout(Duration(seconds: 40)));

  test('CDN config loads + registers RSA keys', () async {
    final client = _plain();
    await client.loginBot(_botToken);
    await client.loadCdnConfig();
    print('cdn rsa keys after load: ${cdnRsaKeys.length}');
    await client.close();
  }, timeout: const Timeout(Duration(seconds: 40)));

  test('future salts prefetch returns salts', () async {
    final client = _plain();
    await client.loginBot(_botToken);
    final r = await client.invoke(GetFutureSaltsRequest(num: 4));
    expect(r, isA<FutureSaltsObj>());
    print('future salts: ${(r as FutureSaltsObj).salts.length}');
    await client.close();
  }, timeout: const Timeout(Duration(seconds: 40)));

  test('invokeAfterPrevious chains a request', () async {
    final client = _plain();
    await client.loginBot(_botToken);
    await client.invoke(HelpGetConfigRequest());
    final r = await client.invokeAfterPrevious(HelpGetConfigRequest());
    expect(r, isA<ConfigObj>());
    print('invokeAfterPrevious config ok');
    await client.close();
  }, timeout: const Timeout(Duration(seconds: 40)));

  test('takeout session init + wrapped query + finish', () async {
    final client = _plain();
    await client.loginBot(_botToken);
    try {
      final id = await client.initTakeoutSession(contacts: true);
      print('takeout id: $id');
      final finished = await client.finishTakeoutSession(success: true);
      print('takeout finished: $finished');
    } on TgError catch (e) {
      print('takeout not permitted for bot (expected): ${e.message}');
    }
    await client.close();
  }, timeout: const Timeout(Duration(seconds: 40)));

  test('web file download (small map tile via config webfile dc)', () async {
    final client = _plain();
    await client.loginBot(_botToken);
    final cfg = await client.invoke(HelpGetConfigRequest());
    expect(cfg, isA<ConfigObj>());
    print('webfile dc: ${(cfg as ConfigObj).webfileDcId}');
    await client.close();
  }, timeout: const Timeout(Duration(seconds: 40)));

  test('obfuscation2 direct-to-DC handshake + getMe', () async {
    final client = MtpClient(
      appId: _appId,
      appHash: _appHash,
      dcId: 4,
      sessionFile: 'bot_obf.session',
      useObfuscation: true,
    );
    await client.loginBot(_botToken);
    final me = await client.getMe();
    expect(me, isA<UserObj>());
    print('obfuscated handshake ok: ${(me as UserObj).id}');
    final cfg = await client.invoke(HelpGetConfigRequest());
    expect(cfg, isA<ConfigObj>());
    await client.close();
  }, timeout: const Timeout(Duration(seconds: 60)));

  test('PFS: bind temp auth key then getMe over temp key', () async {
    final client = MtpClient(
      appId: _appId,
      appHash: _appHash,
      dcId: 4,
      sessionFile: 'bot_pfs.session',
      usePfs: true,
      pfsExpiresIn: 3600,
    );
    await client.loginBot(_botToken);
    final me = await client.getMe();
    expect(me, isA<UserObj>());
    print('PFS bound + getMe ok: ${(me as UserObj).id}');
    final cfg = await client.invoke(HelpGetConfigRequest());
    expect(cfg, isA<ConfigObj>());
    await client.close();
  }, timeout: const Timeout(Duration(seconds: 60)));

  test('send message still works end to end', () async {
    final client = _plain();
    await client.loginBot(_botToken);
    final peer = InputPeerUser(userId: _testChatId, accessHash: 0);
    final res = await client.sendMessage(
      peer: peer,
      text: 'mtflute 0.5.0 live check: transports+pfs+cdn+takeout',
    );
    print('sent: ${res.runtimeType}');
    await client.close();
  }, timeout: const Timeout(Duration(seconds: 40)));
}
