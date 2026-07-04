// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: non_constant_identifier_names
import 'dart:typed_data';
import '../tl/tl_encoder.dart';
import '../crypto/mtproto_crypto.dart';
import 'types.dart';

class ReqPqRequest extends TlObject {
  final BigInt nonce;
  ReqPqRequest({required this.nonce, });
  @override
  int get crc => 0x60469778;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeRaw(bigIntToBytes(nonce, 16));
  }
}

class ReqDHParamsRequest extends TlObject {
  final BigInt nonce;
  final BigInt serverNonce;
  final Uint8List p;
  final Uint8List q;
  final int publicKeyFingerprint;
  final Uint8List encryptedData;
  ReqDHParamsRequest({required this.nonce, required this.serverNonce, required this.p, required this.q, required this.publicKeyFingerprint, required this.encryptedData, });
  @override
  int get crc => 0xd712e4be;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeRaw(bigIntToBytes(nonce, 16));
    e.writeRaw(bigIntToBytes(serverNonce, 16));
    e.writeBytes(p);
    e.writeBytes(q);
    e.writeInt64(publicKeyFingerprint);
    e.writeBytes(encryptedData);
  }
}

class SetClientDHParamsRequest extends TlObject {
  final BigInt nonce;
  final BigInt serverNonce;
  final Uint8List encryptedData;
  SetClientDHParamsRequest({required this.nonce, required this.serverNonce, required this.encryptedData, });
  @override
  int get crc => 0xf5045f1f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeRaw(bigIntToBytes(nonce, 16));
    e.writeRaw(bigIntToBytes(serverNonce, 16));
    e.writeBytes(encryptedData);
  }
}

class RpcDropAnswerRequest extends TlObject {
  final int reqMsgId;
  RpcDropAnswerRequest({required this.reqMsgId, });
  @override
  int get crc => 0x58e4a740;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(reqMsgId);
  }
}

class GetFutureSaltsRequest extends TlObject {
  final int num;
  GetFutureSaltsRequest({required this.num, });
  @override
  int get crc => 0xb921bd04;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(num);
  }
}

class PingRequest extends TlObject {
  final int pingId;
  PingRequest({required this.pingId, });
  @override
  int get crc => 0x7abe77ec;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(pingId);
  }
}

class PingDelayDisconnectRequest extends TlObject {
  final int pingId;
  final int disconnectDelay;
  PingDelayDisconnectRequest({required this.pingId, required this.disconnectDelay, });
  @override
  int get crc => 0xf3427b8c;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(pingId);
    e.writeInt32(disconnectDelay);
  }
}

class DestroySessionRequest extends TlObject {
  final int sessionId;
  DestroySessionRequest({required this.sessionId, });
  @override
  int get crc => 0xe7512126;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(sessionId);
  }
}

class HttpWaitRequest extends TlObject {
  final int maxDelay;
  final int waitAfter;
  final int maxWait;
  HttpWaitRequest({required this.maxDelay, required this.waitAfter, required this.maxWait, });
  @override
  int get crc => 0x9299359f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(maxDelay);
    e.writeInt32(waitAfter);
    e.writeInt32(maxWait);
  }
}

class InvokeAfterMsgRequest extends TlObject {
  final int msgId;
  final TlObject query;
  InvokeAfterMsgRequest({required this.msgId, required this.query, });
  @override
  int get crc => 0xcb9f372d;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(msgId);
    query.encode(e);
  }
}

class InvokeAfterMsgsRequest extends TlObject {
  final List<int> msgIds;
  final TlObject query;
  InvokeAfterMsgsRequest({required this.msgIds, required this.query, });
  @override
  int get crc => 0x3dc4b4f0;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeCrc(0x1cb5c415); e.writeInt32(msgIds.length); for (final item in msgIds) { e.writeInt64(item); }
    query.encode(e);
  }
}

class InitConnectionRequest extends TlObject {
  final int apiId;
  final String deviceModel;
  final String systemVersion;
  final String appVersion;
  final String systemLangCode;
  final String langPack;
  final String langCode;
  final InputClientProxy? proxy;
  final JSONValue? params;
  final TlObject query;
  InitConnectionRequest({required this.apiId, required this.deviceModel, required this.systemVersion, required this.appVersion, required this.systemLangCode, required this.langPack, required this.langCode, this.proxy, this.params, required this.query, });
  @override
  int get crc => 0xc1cd5ea9;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (proxy != null ? (1 << 0) : 0) | (params != null ? (1 << 1) : 0);
    e.writeUint32(flags);
    e.writeInt32(apiId);
    e.writeString(deviceModel);
    e.writeString(systemVersion);
    e.writeString(appVersion);
    e.writeString(systemLangCode);
    e.writeString(langPack);
    e.writeString(langCode);
    if (proxy != null) { proxy!.encode(e); }
    if (params != null) { params!.encode(e); }
    query.encode(e);
  }
}

class InvokeWithLayerRequest extends TlObject {
  final int layer;
  final TlObject query;
  InvokeWithLayerRequest({required this.layer, required this.query, });
  @override
  int get crc => 0xda9b0d0d;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(layer);
    query.encode(e);
  }
}

class InvokeWithoutUpdatesRequest extends TlObject {
  final TlObject query;
  InvokeWithoutUpdatesRequest({required this.query, });
  @override
  int get crc => 0xbf9459b7;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    query.encode(e);
  }
}

class InvokeWithMessagesRangeRequest extends TlObject {
  final MessageRange range;
  final TlObject query;
  InvokeWithMessagesRangeRequest({required this.range, required this.query, });
  @override
  int get crc => 0x365275f2;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    range.encode(e);
    query.encode(e);
  }
}

class InvokeWithTakeoutRequest extends TlObject {
  final int takeoutId;
  final TlObject query;
  InvokeWithTakeoutRequest({required this.takeoutId, required this.query, });
  @override
  int get crc => 0xaca9fd2e;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(takeoutId);
    query.encode(e);
  }
}

class InvokeWithBusinessConnectionRequest extends TlObject {
  final String connectionId;
  final TlObject query;
  InvokeWithBusinessConnectionRequest({required this.connectionId, required this.query, });
  @override
  int get crc => 0xdd289f8e;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(connectionId);
    query.encode(e);
  }
}

class InvokeWithGooglePlayIntegrityRequest extends TlObject {
  final String nonce;
  final String token;
  final TlObject query;
  InvokeWithGooglePlayIntegrityRequest({required this.nonce, required this.token, required this.query, });
  @override
  int get crc => 0x1df92984;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(nonce);
    e.writeString(token);
    query.encode(e);
  }
}

class InvokeWithApnsSecretRequest extends TlObject {
  final String nonce;
  final String secret;
  final TlObject query;
  InvokeWithApnsSecretRequest({required this.nonce, required this.secret, required this.query, });
  @override
  int get crc => 0xdae54f8;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(nonce);
    e.writeString(secret);
    query.encode(e);
  }
}

class InvokeWithReCaptchaRequest extends TlObject {
  final String token;
  final TlObject query;
  InvokeWithReCaptchaRequest({required this.token, required this.query, });
  @override
  int get crc => 0xadbb0f94;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(token);
    query.encode(e);
  }
}

class AuthSendCodeRequest extends TlObject {
  final String phoneNumber;
  final int apiId;
  final String apiHash;
  final CodeSettings settings;
  AuthSendCodeRequest({required this.phoneNumber, required this.apiId, required this.apiHash, required this.settings, });
  @override
  int get crc => 0xa677244f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(phoneNumber);
    e.writeInt32(apiId);
    e.writeString(apiHash);
    settings.encode(e);
  }
}

class AuthSignUpRequest extends TlObject {
  final bool noJoinedNotifications;
  final String phoneNumber;
  final String phoneCodeHash;
  final String firstName;
  final String lastName;
  AuthSignUpRequest({this.noJoinedNotifications = false, required this.phoneNumber, required this.phoneCodeHash, required this.firstName, required this.lastName, });
  @override
  int get crc => 0xaac7b717;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (noJoinedNotifications == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    e.writeString(phoneNumber);
    e.writeString(phoneCodeHash);
    e.writeString(firstName);
    e.writeString(lastName);
  }
}

class AuthSignInRequest extends TlObject {
  final String phoneNumber;
  final String phoneCodeHash;
  final String? phoneCode;
  final EmailVerification? emailVerification;
  AuthSignInRequest({required this.phoneNumber, required this.phoneCodeHash, this.phoneCode, this.emailVerification, });
  @override
  int get crc => 0x8d52a951;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (phoneCode != null ? (1 << 0) : 0) | (emailVerification != null ? (1 << 1) : 0);
    e.writeUint32(flags);
    e.writeString(phoneNumber);
    e.writeString(phoneCodeHash);
    if (phoneCode != null) { e.writeString(phoneCode!); }
    if (emailVerification != null) { emailVerification!.encode(e); }
  }
}

class AuthLogOutRequest extends TlObject {
  AuthLogOutRequest();
  @override
  int get crc => 0x3e72ba19;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class AuthResetAuthorizationsRequest extends TlObject {
  AuthResetAuthorizationsRequest();
  @override
  int get crc => 0x9fab0d1a;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class AuthExportAuthorizationRequest extends TlObject {
  final int dcId;
  AuthExportAuthorizationRequest({required this.dcId, });
  @override
  int get crc => 0xe5bfffcd;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(dcId);
  }
}

class AuthImportAuthorizationRequest extends TlObject {
  final int id;
  final Uint8List bytes;
  AuthImportAuthorizationRequest({required this.id, required this.bytes, });
  @override
  int get crc => 0xa57a7dad;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(id);
    e.writeBytes(bytes);
  }
}

class AuthBindTempAuthKeyRequest extends TlObject {
  final int permAuthKeyId;
  final int nonce;
  final int expiresAt;
  final Uint8List encryptedMessage;
  AuthBindTempAuthKeyRequest({required this.permAuthKeyId, required this.nonce, required this.expiresAt, required this.encryptedMessage, });
  @override
  int get crc => 0xcdd42a05;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(permAuthKeyId);
    e.writeInt64(nonce);
    e.writeInt32(expiresAt);
    e.writeBytes(encryptedMessage);
  }
}

class AuthImportBotAuthorizationRequest extends TlObject {
  final int flags;
  final int apiId;
  final String apiHash;
  final String botAuthToken;
  AuthImportBotAuthorizationRequest({required this.flags, required this.apiId, required this.apiHash, required this.botAuthToken, });
  @override
  int get crc => 0x67a3ff2c;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(flags);
    e.writeInt32(apiId);
    e.writeString(apiHash);
    e.writeString(botAuthToken);
  }
}

class AuthCheckPasswordRequest extends TlObject {
  final InputCheckPasswordSRP password;
  AuthCheckPasswordRequest({required this.password, });
  @override
  int get crc => 0xd18b4d16;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    password.encode(e);
  }
}

class AuthRequestPasswordRecoveryRequest extends TlObject {
  AuthRequestPasswordRecoveryRequest();
  @override
  int get crc => 0xd897bc66;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class AuthRecoverPasswordRequest extends TlObject {
  final String code;
  final AccountPasswordInputSettings? newSettings;
  AuthRecoverPasswordRequest({required this.code, this.newSettings, });
  @override
  int get crc => 0x37096c70;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (newSettings != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    e.writeString(code);
    if (newSettings != null) { newSettings!.encode(e); }
  }
}

class AuthResendCodeRequest extends TlObject {
  final String phoneNumber;
  final String phoneCodeHash;
  final String? reason;
  AuthResendCodeRequest({required this.phoneNumber, required this.phoneCodeHash, this.reason, });
  @override
  int get crc => 0xcae47523;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (reason != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    e.writeString(phoneNumber);
    e.writeString(phoneCodeHash);
    if (reason != null) { e.writeString(reason!); }
  }
}

class AuthCancelCodeRequest extends TlObject {
  final String phoneNumber;
  final String phoneCodeHash;
  AuthCancelCodeRequest({required this.phoneNumber, required this.phoneCodeHash, });
  @override
  int get crc => 0x1f040578;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(phoneNumber);
    e.writeString(phoneCodeHash);
  }
}

class AuthDropTempAuthKeysRequest extends TlObject {
  final List<int> exceptAuthKeys;
  AuthDropTempAuthKeysRequest({required this.exceptAuthKeys, });
  @override
  int get crc => 0x8e48a188;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeCrc(0x1cb5c415); e.writeInt32(exceptAuthKeys.length); for (final item in exceptAuthKeys) { e.writeInt64(item); }
  }
}

class AuthExportLoginTokenRequest extends TlObject {
  final int apiId;
  final String apiHash;
  final List<int> exceptIds;
  AuthExportLoginTokenRequest({required this.apiId, required this.apiHash, required this.exceptIds, });
  @override
  int get crc => 0xb7e085fe;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(apiId);
    e.writeString(apiHash);
    e.writeCrc(0x1cb5c415); e.writeInt32(exceptIds.length); for (final item in exceptIds) { e.writeInt64(item); }
  }
}

class AuthImportLoginTokenRequest extends TlObject {
  final Uint8List token;
  AuthImportLoginTokenRequest({required this.token, });
  @override
  int get crc => 0x95ac5ce4;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeBytes(token);
  }
}

class AuthAcceptLoginTokenRequest extends TlObject {
  final Uint8List token;
  AuthAcceptLoginTokenRequest({required this.token, });
  @override
  int get crc => 0xe894ad4d;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeBytes(token);
  }
}

class AuthCheckRecoveryPasswordRequest extends TlObject {
  final String code;
  AuthCheckRecoveryPasswordRequest({required this.code, });
  @override
  int get crc => 0xd36bf79;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(code);
  }
}

class AuthImportWebTokenAuthorizationRequest extends TlObject {
  final int apiId;
  final String apiHash;
  final String webAuthToken;
  AuthImportWebTokenAuthorizationRequest({required this.apiId, required this.apiHash, required this.webAuthToken, });
  @override
  int get crc => 0x2db873a9;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(apiId);
    e.writeString(apiHash);
    e.writeString(webAuthToken);
  }
}

class AuthRequestFirebaseSmsRequest extends TlObject {
  final String phoneNumber;
  final String phoneCodeHash;
  final String? safetyNetToken;
  final String? playIntegrityToken;
  final String? iosPushSecret;
  AuthRequestFirebaseSmsRequest({required this.phoneNumber, required this.phoneCodeHash, this.safetyNetToken, this.playIntegrityToken, this.iosPushSecret, });
  @override
  int get crc => 0x8e39261e;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (safetyNetToken != null ? (1 << 0) : 0) | (playIntegrityToken != null ? (1 << 2) : 0) | (iosPushSecret != null ? (1 << 1) : 0);
    e.writeUint32(flags);
    e.writeString(phoneNumber);
    e.writeString(phoneCodeHash);
    if (safetyNetToken != null) { e.writeString(safetyNetToken!); }
    if (playIntegrityToken != null) { e.writeString(playIntegrityToken!); }
    if (iosPushSecret != null) { e.writeString(iosPushSecret!); }
  }
}

class AuthResetLoginEmailRequest extends TlObject {
  final String phoneNumber;
  final String phoneCodeHash;
  AuthResetLoginEmailRequest({required this.phoneNumber, required this.phoneCodeHash, });
  @override
  int get crc => 0x7e960193;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(phoneNumber);
    e.writeString(phoneCodeHash);
  }
}

class AuthReportMissingCodeRequest extends TlObject {
  final String phoneNumber;
  final String phoneCodeHash;
  final String mnc;
  AuthReportMissingCodeRequest({required this.phoneNumber, required this.phoneCodeHash, required this.mnc, });
  @override
  int get crc => 0xcb9deff6;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(phoneNumber);
    e.writeString(phoneCodeHash);
    e.writeString(mnc);
  }
}

class AuthCheckPaidAuthRequest extends TlObject {
  final String phoneNumber;
  final String phoneCodeHash;
  final int formId;
  AuthCheckPaidAuthRequest({required this.phoneNumber, required this.phoneCodeHash, required this.formId, });
  @override
  int get crc => 0x56e59f9c;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(phoneNumber);
    e.writeString(phoneCodeHash);
    e.writeInt64(formId);
  }
}

class AuthInitPasskeyLoginRequest extends TlObject {
  final int apiId;
  final String apiHash;
  AuthInitPasskeyLoginRequest({required this.apiId, required this.apiHash, });
  @override
  int get crc => 0x518ad0b7;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(apiId);
    e.writeString(apiHash);
  }
}

class AuthFinishPasskeyLoginRequest extends TlObject {
  final InputPasskeyCredential credential;
  final int? fromDcId;
  final int? fromAuthKeyId;
  AuthFinishPasskeyLoginRequest({required this.credential, this.fromDcId, this.fromAuthKeyId, });
  @override
  int get crc => 0x9857ad07;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (fromDcId != null ? (1 << 0) : 0) | (fromAuthKeyId != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    credential.encode(e);
    if (fromDcId != null) { e.writeInt32(fromDcId!); }
    if (fromAuthKeyId != null) { e.writeInt64(fromAuthKeyId!); }
  }
}

class AccountRegisterDeviceRequest extends TlObject {
  final bool noMuted;
  final int tokenType;
  final String token;
  final bool appSandbox;
  final Uint8List secret;
  final List<int> otherUids;
  AccountRegisterDeviceRequest({this.noMuted = false, required this.tokenType, required this.token, required this.appSandbox, required this.secret, required this.otherUids, });
  @override
  int get crc => 0xec86017a;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (noMuted == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    e.writeInt32(tokenType);
    e.writeString(token);
    e.writeBool(appSandbox);
    e.writeBytes(secret);
    e.writeCrc(0x1cb5c415); e.writeInt32(otherUids.length); for (final item in otherUids) { e.writeInt64(item); }
  }
}

class AccountUnregisterDeviceRequest extends TlObject {
  final int tokenType;
  final String token;
  final List<int> otherUids;
  AccountUnregisterDeviceRequest({required this.tokenType, required this.token, required this.otherUids, });
  @override
  int get crc => 0x6a0d3206;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(tokenType);
    e.writeString(token);
    e.writeCrc(0x1cb5c415); e.writeInt32(otherUids.length); for (final item in otherUids) { e.writeInt64(item); }
  }
}

class AccountUpdateNotifySettingsRequest extends TlObject {
  final InputNotifyPeer peer;
  final InputPeerNotifySettings settings;
  AccountUpdateNotifySettingsRequest({required this.peer, required this.settings, });
  @override
  int get crc => 0x84be5b93;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    settings.encode(e);
  }
}

class AccountGetNotifySettingsRequest extends TlObject {
  final InputNotifyPeer peer;
  AccountGetNotifySettingsRequest({required this.peer, });
  @override
  int get crc => 0x12b3ad31;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
  }
}

class AccountResetNotifySettingsRequest extends TlObject {
  AccountResetNotifySettingsRequest();
  @override
  int get crc => 0xdb7e1747;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class AccountUpdateProfileRequest extends TlObject {
  final String? firstName;
  final String? lastName;
  final String? about;
  AccountUpdateProfileRequest({this.firstName, this.lastName, this.about, });
  @override
  int get crc => 0x78515775;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (firstName != null ? (1 << 0) : 0) | (lastName != null ? (1 << 1) : 0) | (about != null ? (1 << 2) : 0);
    e.writeUint32(flags);
    if (firstName != null) { e.writeString(firstName!); }
    if (lastName != null) { e.writeString(lastName!); }
    if (about != null) { e.writeString(about!); }
  }
}

class AccountUpdateStatusRequest extends TlObject {
  final bool offline;
  AccountUpdateStatusRequest({required this.offline, });
  @override
  int get crc => 0x6628562c;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeBool(offline);
  }
}

class AccountGetWallPapersRequest extends TlObject {
  final int hash;
  AccountGetWallPapersRequest({required this.hash, });
  @override
  int get crc => 0x7967d36;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(hash);
  }
}

class AccountReportPeerRequest extends TlObject {
  final InputPeer peer;
  final ReportReason reason;
  final String message;
  AccountReportPeerRequest({required this.peer, required this.reason, required this.message, });
  @override
  int get crc => 0xc5ba3d86;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    reason.encode(e);
    e.writeString(message);
  }
}

class AccountCheckUsernameRequest extends TlObject {
  final String username;
  AccountCheckUsernameRequest({required this.username, });
  @override
  int get crc => 0x2714d86c;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(username);
  }
}

class AccountUpdateUsernameRequest extends TlObject {
  final String username;
  AccountUpdateUsernameRequest({required this.username, });
  @override
  int get crc => 0x3e0bdd7c;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(username);
  }
}

class AccountGetPrivacyRequest extends TlObject {
  final InputPrivacyKey key;
  AccountGetPrivacyRequest({required this.key, });
  @override
  int get crc => 0xdadbc950;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    key.encode(e);
  }
}

class AccountSetPrivacyRequest extends TlObject {
  final InputPrivacyKey key;
  final List<InputPrivacyRule> rules;
  AccountSetPrivacyRequest({required this.key, required this.rules, });
  @override
  int get crc => 0xc9f81ce8;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    key.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(rules.length); for (final item in rules) { item.encode(e); }
  }
}

class AccountDeleteAccountRequest extends TlObject {
  final String reason;
  final InputCheckPasswordSRP? password;
  AccountDeleteAccountRequest({required this.reason, this.password, });
  @override
  int get crc => 0xa2c0cf74;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (password != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    e.writeString(reason);
    if (password != null) { password!.encode(e); }
  }
}

class AccountGetAccountTTLRequest extends TlObject {
  AccountGetAccountTTLRequest();
  @override
  int get crc => 0x8fc711d;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class AccountSetAccountTTLRequest extends TlObject {
  final AccountDaysTTL ttl;
  AccountSetAccountTTLRequest({required this.ttl, });
  @override
  int get crc => 0x2442485e;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    ttl.encode(e);
  }
}

class AccountSendChangePhoneCodeRequest extends TlObject {
  final String phoneNumber;
  final CodeSettings settings;
  AccountSendChangePhoneCodeRequest({required this.phoneNumber, required this.settings, });
  @override
  int get crc => 0x82574ae5;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(phoneNumber);
    settings.encode(e);
  }
}

class AccountChangePhoneRequest extends TlObject {
  final String phoneNumber;
  final String phoneCodeHash;
  final String phoneCode;
  AccountChangePhoneRequest({required this.phoneNumber, required this.phoneCodeHash, required this.phoneCode, });
  @override
  int get crc => 0x70c32edb;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(phoneNumber);
    e.writeString(phoneCodeHash);
    e.writeString(phoneCode);
  }
}

class AccountUpdateDeviceLockedRequest extends TlObject {
  final int period;
  AccountUpdateDeviceLockedRequest({required this.period, });
  @override
  int get crc => 0x38df3532;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(period);
  }
}

class AccountGetAuthorizationsRequest extends TlObject {
  AccountGetAuthorizationsRequest();
  @override
  int get crc => 0xe320c158;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class AccountResetAuthorizationRequest extends TlObject {
  final int hash;
  AccountResetAuthorizationRequest({required this.hash, });
  @override
  int get crc => 0xdf77f3bc;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(hash);
  }
}

class AccountGetPasswordRequest extends TlObject {
  AccountGetPasswordRequest();
  @override
  int get crc => 0x548a30f5;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class AccountGetPasswordSettingsRequest extends TlObject {
  final InputCheckPasswordSRP password;
  AccountGetPasswordSettingsRequest({required this.password, });
  @override
  int get crc => 0x9cd4eaf9;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    password.encode(e);
  }
}

class AccountUpdatePasswordSettingsRequest extends TlObject {
  final InputCheckPasswordSRP password;
  final AccountPasswordInputSettings newSettings;
  AccountUpdatePasswordSettingsRequest({required this.password, required this.newSettings, });
  @override
  int get crc => 0xa59b102f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    password.encode(e);
    newSettings.encode(e);
  }
}

class AccountSendConfirmPhoneCodeRequest extends TlObject {
  final String hash;
  final CodeSettings settings;
  AccountSendConfirmPhoneCodeRequest({required this.hash, required this.settings, });
  @override
  int get crc => 0x1b3faa88;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(hash);
    settings.encode(e);
  }
}

class AccountConfirmPhoneRequest extends TlObject {
  final String phoneCodeHash;
  final String phoneCode;
  AccountConfirmPhoneRequest({required this.phoneCodeHash, required this.phoneCode, });
  @override
  int get crc => 0x5f2178c3;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(phoneCodeHash);
    e.writeString(phoneCode);
  }
}

class AccountGetTmpPasswordRequest extends TlObject {
  final InputCheckPasswordSRP password;
  final int period;
  AccountGetTmpPasswordRequest({required this.password, required this.period, });
  @override
  int get crc => 0x449e0b51;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    password.encode(e);
    e.writeInt32(period);
  }
}

class AccountGetWebAuthorizationsRequest extends TlObject {
  AccountGetWebAuthorizationsRequest();
  @override
  int get crc => 0x182e6d6f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class AccountResetWebAuthorizationRequest extends TlObject {
  final int hash;
  AccountResetWebAuthorizationRequest({required this.hash, });
  @override
  int get crc => 0x2d01b9ef;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(hash);
  }
}

class AccountResetWebAuthorizationsRequest extends TlObject {
  AccountResetWebAuthorizationsRequest();
  @override
  int get crc => 0x682d2594;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class AccountGetAllSecureValuesRequest extends TlObject {
  AccountGetAllSecureValuesRequest();
  @override
  int get crc => 0xb288bc7d;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class AccountGetSecureValueRequest extends TlObject {
  final List<SecureValueType> types;
  AccountGetSecureValueRequest({required this.types, });
  @override
  int get crc => 0x73665bc2;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeCrc(0x1cb5c415); e.writeInt32(types.length); for (final item in types) { item.encode(e); }
  }
}

class AccountSaveSecureValueRequest extends TlObject {
  final InputSecureValue value;
  final int secureSecretId;
  AccountSaveSecureValueRequest({required this.value, required this.secureSecretId, });
  @override
  int get crc => 0x899fe31d;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    value.encode(e);
    e.writeInt64(secureSecretId);
  }
}

class AccountDeleteSecureValueRequest extends TlObject {
  final List<SecureValueType> types;
  AccountDeleteSecureValueRequest({required this.types, });
  @override
  int get crc => 0xb880bc4b;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeCrc(0x1cb5c415); e.writeInt32(types.length); for (final item in types) { item.encode(e); }
  }
}

class AccountGetAuthorizationFormRequest extends TlObject {
  final int botId;
  final String scope;
  final String publicKey;
  AccountGetAuthorizationFormRequest({required this.botId, required this.scope, required this.publicKey, });
  @override
  int get crc => 0xa929597a;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(botId);
    e.writeString(scope);
    e.writeString(publicKey);
  }
}

class AccountAcceptAuthorizationRequest extends TlObject {
  final int botId;
  final String scope;
  final String publicKey;
  final List<SecureValueHash> valueHashes;
  final SecureCredentialsEncrypted credentials;
  AccountAcceptAuthorizationRequest({required this.botId, required this.scope, required this.publicKey, required this.valueHashes, required this.credentials, });
  @override
  int get crc => 0xf3ed4c73;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(botId);
    e.writeString(scope);
    e.writeString(publicKey);
    e.writeCrc(0x1cb5c415); e.writeInt32(valueHashes.length); for (final item in valueHashes) { item.encode(e); }
    credentials.encode(e);
  }
}

class AccountSendVerifyPhoneCodeRequest extends TlObject {
  final String phoneNumber;
  final CodeSettings settings;
  AccountSendVerifyPhoneCodeRequest({required this.phoneNumber, required this.settings, });
  @override
  int get crc => 0xa5a356f9;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(phoneNumber);
    settings.encode(e);
  }
}

class AccountVerifyPhoneRequest extends TlObject {
  final String phoneNumber;
  final String phoneCodeHash;
  final String phoneCode;
  AccountVerifyPhoneRequest({required this.phoneNumber, required this.phoneCodeHash, required this.phoneCode, });
  @override
  int get crc => 0x4dd3a7f6;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(phoneNumber);
    e.writeString(phoneCodeHash);
    e.writeString(phoneCode);
  }
}

class AccountSendVerifyEmailCodeRequest extends TlObject {
  final EmailVerifyPurpose purpose;
  final String email;
  AccountSendVerifyEmailCodeRequest({required this.purpose, required this.email, });
  @override
  int get crc => 0x98e037bb;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    purpose.encode(e);
    e.writeString(email);
  }
}

class AccountVerifyEmailRequest extends TlObject {
  final EmailVerifyPurpose purpose;
  final EmailVerification verification;
  AccountVerifyEmailRequest({required this.purpose, required this.verification, });
  @override
  int get crc => 0x32da4cf;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    purpose.encode(e);
    verification.encode(e);
  }
}

class AccountInitTakeoutSessionRequest extends TlObject {
  final bool contacts;
  final bool messageUsers;
  final bool messageChats;
  final bool messageMegagroups;
  final bool messageChannels;
  final bool files;
  final int? fileMaxSize;
  AccountInitTakeoutSessionRequest({this.contacts = false, this.messageUsers = false, this.messageChats = false, this.messageMegagroups = false, this.messageChannels = false, this.files = false, this.fileMaxSize, });
  @override
  int get crc => 0x8ef3eab0;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (contacts == true ? (1 << 0) : 0) | (messageUsers == true ? (1 << 1) : 0) | (messageChats == true ? (1 << 2) : 0) | (messageMegagroups == true ? (1 << 3) : 0) | (messageChannels == true ? (1 << 4) : 0) | (files == true ? (1 << 5) : 0) | (fileMaxSize != null ? (1 << 5) : 0);
    e.writeUint32(flags);
    if (fileMaxSize != null) { e.writeInt64(fileMaxSize!); }
  }
}

class AccountFinishTakeoutSessionRequest extends TlObject {
  final bool success;
  AccountFinishTakeoutSessionRequest({this.success = false, });
  @override
  int get crc => 0x1d2652ee;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (success == true ? (1 << 0) : 0);
    e.writeUint32(flags);
  }
}

class AccountConfirmPasswordEmailRequest extends TlObject {
  final String code;
  AccountConfirmPasswordEmailRequest({required this.code, });
  @override
  int get crc => 0x8fdf1920;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(code);
  }
}

class AccountResendPasswordEmailRequest extends TlObject {
  AccountResendPasswordEmailRequest();
  @override
  int get crc => 0x7a7f2a15;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class AccountCancelPasswordEmailRequest extends TlObject {
  AccountCancelPasswordEmailRequest();
  @override
  int get crc => 0xc1cbd5b6;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class AccountGetContactSignUpNotificationRequest extends TlObject {
  AccountGetContactSignUpNotificationRequest();
  @override
  int get crc => 0x9f07c728;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class AccountSetContactSignUpNotificationRequest extends TlObject {
  final bool silent;
  AccountSetContactSignUpNotificationRequest({required this.silent, });
  @override
  int get crc => 0xcff43f61;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeBool(silent);
  }
}

class AccountGetNotifyExceptionsRequest extends TlObject {
  final bool compareSound;
  final bool compareStories;
  final InputNotifyPeer? peer;
  AccountGetNotifyExceptionsRequest({this.compareSound = false, this.compareStories = false, this.peer, });
  @override
  int get crc => 0x53577479;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (compareSound == true ? (1 << 1) : 0) | (compareStories == true ? (1 << 2) : 0) | (peer != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    if (peer != null) { peer!.encode(e); }
  }
}

class AccountGetWallPaperRequest extends TlObject {
  final InputWallPaper wallpaper;
  AccountGetWallPaperRequest({required this.wallpaper, });
  @override
  int get crc => 0xfc8ddbea;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    wallpaper.encode(e);
  }
}

class AccountUploadWallPaperRequest extends TlObject {
  final bool forChat;
  final InputFile file;
  final String mimeType;
  final WallPaperSettings settings;
  AccountUploadWallPaperRequest({this.forChat = false, required this.file, required this.mimeType, required this.settings, });
  @override
  int get crc => 0xe39a8f03;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (forChat == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    file.encode(e);
    e.writeString(mimeType);
    settings.encode(e);
  }
}

class AccountSaveWallPaperRequest extends TlObject {
  final InputWallPaper wallpaper;
  final bool unsave;
  final WallPaperSettings settings;
  AccountSaveWallPaperRequest({required this.wallpaper, required this.unsave, required this.settings, });
  @override
  int get crc => 0x6c5a5b37;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    wallpaper.encode(e);
    e.writeBool(unsave);
    settings.encode(e);
  }
}

class AccountInstallWallPaperRequest extends TlObject {
  final InputWallPaper wallpaper;
  final WallPaperSettings settings;
  AccountInstallWallPaperRequest({required this.wallpaper, required this.settings, });
  @override
  int get crc => 0xfeed5769;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    wallpaper.encode(e);
    settings.encode(e);
  }
}

class AccountResetWallPapersRequest extends TlObject {
  AccountResetWallPapersRequest();
  @override
  int get crc => 0xbb3b9804;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class AccountGetAutoDownloadSettingsRequest extends TlObject {
  AccountGetAutoDownloadSettingsRequest();
  @override
  int get crc => 0x56da0b3f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class AccountSaveAutoDownloadSettingsRequest extends TlObject {
  final bool low;
  final bool high;
  final AutoDownloadSettings settings;
  AccountSaveAutoDownloadSettingsRequest({this.low = false, this.high = false, required this.settings, });
  @override
  int get crc => 0x76f36233;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (low == true ? (1 << 0) : 0) | (high == true ? (1 << 1) : 0);
    e.writeUint32(flags);
    settings.encode(e);
  }
}

class AccountUploadThemeRequest extends TlObject {
  final InputFile file;
  final InputFile? thumb;
  final String fileName;
  final String mimeType;
  AccountUploadThemeRequest({required this.file, this.thumb, required this.fileName, required this.mimeType, });
  @override
  int get crc => 0x1c3db333;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (thumb != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    file.encode(e);
    if (thumb != null) { thumb!.encode(e); }
    e.writeString(fileName);
    e.writeString(mimeType);
  }
}

class AccountCreateThemeRequest extends TlObject {
  final String slug;
  final String title;
  final InputDocument? document;
  final List<InputThemeSettings>? settings;
  AccountCreateThemeRequest({required this.slug, required this.title, this.document, this.settings, });
  @override
  int get crc => 0x652e4400;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (document != null ? (1 << 2) : 0) | (settings != null ? (1 << 3) : 0);
    e.writeUint32(flags);
    e.writeString(slug);
    e.writeString(title);
    if (document != null) { document!.encode(e); }
    if (settings != null) { e.writeCrc(0x1cb5c415); e.writeInt32(settings!.length); for (final item in settings!) { item.encode(e); } }
  }
}

class AccountUpdateThemeRequest extends TlObject {
  final String format;
  final InputTheme theme;
  final String? slug;
  final String? title;
  final InputDocument? document;
  final List<InputThemeSettings>? settings;
  AccountUpdateThemeRequest({required this.format, required this.theme, this.slug, this.title, this.document, this.settings, });
  @override
  int get crc => 0x2bf40ccc;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (slug != null ? (1 << 0) : 0) | (title != null ? (1 << 1) : 0) | (document != null ? (1 << 2) : 0) | (settings != null ? (1 << 3) : 0);
    e.writeUint32(flags);
    e.writeString(format);
    theme.encode(e);
    if (slug != null) { e.writeString(slug!); }
    if (title != null) { e.writeString(title!); }
    if (document != null) { document!.encode(e); }
    if (settings != null) { e.writeCrc(0x1cb5c415); e.writeInt32(settings!.length); for (final item in settings!) { item.encode(e); } }
  }
}

class AccountSaveThemeRequest extends TlObject {
  final InputTheme theme;
  final bool unsave;
  AccountSaveThemeRequest({required this.theme, required this.unsave, });
  @override
  int get crc => 0xf257106c;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    theme.encode(e);
    e.writeBool(unsave);
  }
}

class AccountInstallThemeRequest extends TlObject {
  final bool dark;
  final InputTheme? theme;
  final String? format;
  final BaseTheme? baseTheme;
  AccountInstallThemeRequest({this.dark = false, this.theme, this.format, this.baseTheme, });
  @override
  int get crc => 0xc727bb3b;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (dark == true ? (1 << 0) : 0) | (theme != null ? (1 << 1) : 0) | (format != null ? (1 << 2) : 0) | (baseTheme != null ? (1 << 3) : 0);
    e.writeUint32(flags);
    if (theme != null) { theme!.encode(e); }
    if (format != null) { e.writeString(format!); }
    if (baseTheme != null) { baseTheme!.encode(e); }
  }
}

class AccountGetThemeRequest extends TlObject {
  final String format;
  final InputTheme theme;
  AccountGetThemeRequest({required this.format, required this.theme, });
  @override
  int get crc => 0x3a5869ec;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(format);
    theme.encode(e);
  }
}

class AccountGetThemesRequest extends TlObject {
  final String format;
  final int hash;
  AccountGetThemesRequest({required this.format, required this.hash, });
  @override
  int get crc => 0x7206e458;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(format);
    e.writeInt64(hash);
  }
}

class AccountSetContentSettingsRequest extends TlObject {
  final bool sensitiveEnabled;
  AccountSetContentSettingsRequest({this.sensitiveEnabled = false, });
  @override
  int get crc => 0xb574b16b;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (sensitiveEnabled == true ? (1 << 0) : 0);
    e.writeUint32(flags);
  }
}

class AccountGetContentSettingsRequest extends TlObject {
  AccountGetContentSettingsRequest();
  @override
  int get crc => 0x8b9b4dae;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class AccountGetMultiWallPapersRequest extends TlObject {
  final List<InputWallPaper> wallpapers;
  AccountGetMultiWallPapersRequest({required this.wallpapers, });
  @override
  int get crc => 0x65ad71dc;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeCrc(0x1cb5c415); e.writeInt32(wallpapers.length); for (final item in wallpapers) { item.encode(e); }
  }
}

class AccountGetGlobalPrivacySettingsRequest extends TlObject {
  AccountGetGlobalPrivacySettingsRequest();
  @override
  int get crc => 0xeb2b4cf6;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class AccountSetGlobalPrivacySettingsRequest extends TlObject {
  final GlobalPrivacySettings settings;
  AccountSetGlobalPrivacySettingsRequest({required this.settings, });
  @override
  int get crc => 0x1edaaac2;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    settings.encode(e);
  }
}

class AccountReportProfilePhotoRequest extends TlObject {
  final InputPeer peer;
  final InputPhoto photoId;
  final ReportReason reason;
  final String message;
  AccountReportProfilePhotoRequest({required this.peer, required this.photoId, required this.reason, required this.message, });
  @override
  int get crc => 0xfa8cc6f5;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    photoId.encode(e);
    reason.encode(e);
    e.writeString(message);
  }
}

class AccountResetPasswordRequest extends TlObject {
  AccountResetPasswordRequest();
  @override
  int get crc => 0x9308ce1b;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class AccountDeclinePasswordResetRequest extends TlObject {
  AccountDeclinePasswordResetRequest();
  @override
  int get crc => 0x4c9409f6;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class AccountGetChatThemesRequest extends TlObject {
  final int hash;
  AccountGetChatThemesRequest({required this.hash, });
  @override
  int get crc => 0xd638de89;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(hash);
  }
}

class AccountSetAuthorizationTTLRequest extends TlObject {
  final int authorizationTtlDays;
  AccountSetAuthorizationTTLRequest({required this.authorizationTtlDays, });
  @override
  int get crc => 0xbf899aa0;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(authorizationTtlDays);
  }
}

class AccountChangeAuthorizationSettingsRequest extends TlObject {
  final bool confirmed;
  final int hash;
  final bool? encryptedRequestsDisabled;
  final bool? callRequestsDisabled;
  AccountChangeAuthorizationSettingsRequest({this.confirmed = false, required this.hash, this.encryptedRequestsDisabled, this.callRequestsDisabled, });
  @override
  int get crc => 0x40f48462;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (confirmed == true ? (1 << 3) : 0) | (encryptedRequestsDisabled != null ? (1 << 0) : 0) | (callRequestsDisabled != null ? (1 << 1) : 0);
    e.writeUint32(flags);
    e.writeInt64(hash);
    if (encryptedRequestsDisabled != null) { e.writeBool(encryptedRequestsDisabled!); }
    if (callRequestsDisabled != null) { e.writeBool(callRequestsDisabled!); }
  }
}

class AccountGetSavedRingtonesRequest extends TlObject {
  final int hash;
  AccountGetSavedRingtonesRequest({required this.hash, });
  @override
  int get crc => 0xe1902288;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(hash);
  }
}

class AccountSaveRingtoneRequest extends TlObject {
  final InputDocument id;
  final bool unsave;
  AccountSaveRingtoneRequest({required this.id, required this.unsave, });
  @override
  int get crc => 0x3dea5b03;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    id.encode(e);
    e.writeBool(unsave);
  }
}

class AccountUploadRingtoneRequest extends TlObject {
  final InputFile file;
  final String fileName;
  final String mimeType;
  AccountUploadRingtoneRequest({required this.file, required this.fileName, required this.mimeType, });
  @override
  int get crc => 0x831a83a2;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    file.encode(e);
    e.writeString(fileName);
    e.writeString(mimeType);
  }
}

class AccountUpdateEmojiStatusRequest extends TlObject {
  final EmojiStatus emojiStatus;
  AccountUpdateEmojiStatusRequest({required this.emojiStatus, });
  @override
  int get crc => 0xfbd3de6b;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    emojiStatus.encode(e);
  }
}

class AccountGetDefaultEmojiStatusesRequest extends TlObject {
  final int hash;
  AccountGetDefaultEmojiStatusesRequest({required this.hash, });
  @override
  int get crc => 0xd6753386;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(hash);
  }
}

class AccountGetRecentEmojiStatusesRequest extends TlObject {
  final int hash;
  AccountGetRecentEmojiStatusesRequest({required this.hash, });
  @override
  int get crc => 0xf578105;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(hash);
  }
}

class AccountClearRecentEmojiStatusesRequest extends TlObject {
  AccountClearRecentEmojiStatusesRequest();
  @override
  int get crc => 0x18201aae;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class AccountReorderUsernamesRequest extends TlObject {
  final List<String> order;
  AccountReorderUsernamesRequest({required this.order, });
  @override
  int get crc => 0xef500eab;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeCrc(0x1cb5c415); e.writeInt32(order.length); for (final item in order) { e.writeString(item); }
  }
}

class AccountToggleUsernameRequest extends TlObject {
  final String username;
  final bool active;
  AccountToggleUsernameRequest({required this.username, required this.active, });
  @override
  int get crc => 0x58d6b376;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(username);
    e.writeBool(active);
  }
}

class AccountGetDefaultProfilePhotoEmojisRequest extends TlObject {
  final int hash;
  AccountGetDefaultProfilePhotoEmojisRequest({required this.hash, });
  @override
  int get crc => 0xe2750328;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(hash);
  }
}

class AccountGetDefaultGroupPhotoEmojisRequest extends TlObject {
  final int hash;
  AccountGetDefaultGroupPhotoEmojisRequest({required this.hash, });
  @override
  int get crc => 0x915860ae;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(hash);
  }
}

class AccountGetAutoSaveSettingsRequest extends TlObject {
  AccountGetAutoSaveSettingsRequest();
  @override
  int get crc => 0xadcbbcda;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class AccountSaveAutoSaveSettingsRequest extends TlObject {
  final bool users;
  final bool chats;
  final bool broadcasts;
  final InputPeer? peer;
  final AutoSaveSettings settings;
  AccountSaveAutoSaveSettingsRequest({this.users = false, this.chats = false, this.broadcasts = false, this.peer, required this.settings, });
  @override
  int get crc => 0xd69b8361;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (users == true ? (1 << 0) : 0) | (chats == true ? (1 << 1) : 0) | (broadcasts == true ? (1 << 2) : 0) | (peer != null ? (1 << 3) : 0);
    e.writeUint32(flags);
    if (peer != null) { peer!.encode(e); }
    settings.encode(e);
  }
}

class AccountDeleteAutoSaveExceptionsRequest extends TlObject {
  AccountDeleteAutoSaveExceptionsRequest();
  @override
  int get crc => 0x53bc0020;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class AccountInvalidateSignInCodesRequest extends TlObject {
  final List<String> codes;
  AccountInvalidateSignInCodesRequest({required this.codes, });
  @override
  int get crc => 0xca8ae8ba;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeCrc(0x1cb5c415); e.writeInt32(codes.length); for (final item in codes) { e.writeString(item); }
  }
}

class AccountUpdateColorRequest extends TlObject {
  final bool forProfile;
  final PeerColor? color;
  AccountUpdateColorRequest({this.forProfile = false, this.color, });
  @override
  int get crc => 0x684d214e;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (forProfile == true ? (1 << 1) : 0) | (color != null ? (1 << 2) : 0);
    e.writeUint32(flags);
    if (color != null) { color!.encode(e); }
  }
}

class AccountGetDefaultBackgroundEmojisRequest extends TlObject {
  final int hash;
  AccountGetDefaultBackgroundEmojisRequest({required this.hash, });
  @override
  int get crc => 0xa60ab9ce;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(hash);
  }
}

class AccountGetChannelDefaultEmojiStatusesRequest extends TlObject {
  final int hash;
  AccountGetChannelDefaultEmojiStatusesRequest({required this.hash, });
  @override
  int get crc => 0x7727a7d5;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(hash);
  }
}

class AccountGetChannelRestrictedStatusEmojisRequest extends TlObject {
  final int hash;
  AccountGetChannelRestrictedStatusEmojisRequest({required this.hash, });
  @override
  int get crc => 0x35a9e0d5;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(hash);
  }
}

class AccountUpdateBusinessWorkHoursRequest extends TlObject {
  final BusinessWorkHours? businessWorkHours;
  AccountUpdateBusinessWorkHoursRequest({this.businessWorkHours, });
  @override
  int get crc => 0x4b00e066;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (businessWorkHours != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    if (businessWorkHours != null) { businessWorkHours!.encode(e); }
  }
}

class AccountUpdateBusinessLocationRequest extends TlObject {
  final InputGeoPoint? geoPoint;
  final String? address;
  AccountUpdateBusinessLocationRequest({this.geoPoint, this.address, });
  @override
  int get crc => 0x9e6b131a;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (geoPoint != null ? (1 << 1) : 0) | (address != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    if (geoPoint != null) { geoPoint!.encode(e); }
    if (address != null) { e.writeString(address!); }
  }
}

class AccountUpdateBusinessGreetingMessageRequest extends TlObject {
  final InputBusinessGreetingMessage? message;
  AccountUpdateBusinessGreetingMessageRequest({this.message, });
  @override
  int get crc => 0x66cdafc4;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (message != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    if (message != null) { message!.encode(e); }
  }
}

class AccountUpdateBusinessAwayMessageRequest extends TlObject {
  final InputBusinessAwayMessage? message;
  AccountUpdateBusinessAwayMessageRequest({this.message, });
  @override
  int get crc => 0xa26a7fa5;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (message != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    if (message != null) { message!.encode(e); }
  }
}

class AccountUpdateConnectedBotRequest extends TlObject {
  final bool deleted;
  final BusinessBotRights? rights;
  final InputUser bot;
  final InputBusinessBotRecipients recipients;
  AccountUpdateConnectedBotRequest({this.deleted = false, this.rights, required this.bot, required this.recipients, });
  @override
  int get crc => 0x66a08c7e;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (deleted == true ? (1 << 1) : 0) | (rights != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    if (rights != null) { rights!.encode(e); }
    bot.encode(e);
    recipients.encode(e);
  }
}

class AccountGetConnectedBotsRequest extends TlObject {
  AccountGetConnectedBotsRequest();
  @override
  int get crc => 0x4ea4c80f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class AccountGetBotBusinessConnectionRequest extends TlObject {
  final String connectionId;
  AccountGetBotBusinessConnectionRequest({required this.connectionId, });
  @override
  int get crc => 0x76a86270;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(connectionId);
  }
}

class AccountUpdateBusinessIntroRequest extends TlObject {
  final InputBusinessIntro? intro;
  AccountUpdateBusinessIntroRequest({this.intro, });
  @override
  int get crc => 0xa614d034;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (intro != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    if (intro != null) { intro!.encode(e); }
  }
}

class AccountToggleConnectedBotPausedRequest extends TlObject {
  final InputPeer peer;
  final bool paused;
  AccountToggleConnectedBotPausedRequest({required this.peer, required this.paused, });
  @override
  int get crc => 0x646e1097;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeBool(paused);
  }
}

class AccountDisablePeerConnectedBotRequest extends TlObject {
  final InputPeer peer;
  AccountDisablePeerConnectedBotRequest({required this.peer, });
  @override
  int get crc => 0x5e437ed9;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
  }
}

class AccountUpdateBirthdayRequest extends TlObject {
  final Birthday? birthday;
  AccountUpdateBirthdayRequest({this.birthday, });
  @override
  int get crc => 0xcc6e0c11;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (birthday != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    if (birthday != null) { birthday!.encode(e); }
  }
}

class AccountCreateBusinessChatLinkRequest extends TlObject {
  final InputBusinessChatLink link;
  AccountCreateBusinessChatLinkRequest({required this.link, });
  @override
  int get crc => 0x8851e68e;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    link.encode(e);
  }
}

class AccountEditBusinessChatLinkRequest extends TlObject {
  final String slug;
  final InputBusinessChatLink link;
  AccountEditBusinessChatLinkRequest({required this.slug, required this.link, });
  @override
  int get crc => 0x8c3410af;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(slug);
    link.encode(e);
  }
}

class AccountDeleteBusinessChatLinkRequest extends TlObject {
  final String slug;
  AccountDeleteBusinessChatLinkRequest({required this.slug, });
  @override
  int get crc => 0x60073674;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(slug);
  }
}

class AccountGetBusinessChatLinksRequest extends TlObject {
  AccountGetBusinessChatLinksRequest();
  @override
  int get crc => 0x6f70dde1;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class AccountResolveBusinessChatLinkRequest extends TlObject {
  final String slug;
  AccountResolveBusinessChatLinkRequest({required this.slug, });
  @override
  int get crc => 0x5492e5ee;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(slug);
  }
}

class AccountUpdatePersonalChannelRequest extends TlObject {
  final InputChannel channel;
  AccountUpdatePersonalChannelRequest({required this.channel, });
  @override
  int get crc => 0xd94305e0;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
  }
}

class AccountToggleSponsoredMessagesRequest extends TlObject {
  final bool enabled;
  AccountToggleSponsoredMessagesRequest({required this.enabled, });
  @override
  int get crc => 0xb9d9a38d;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeBool(enabled);
  }
}

class AccountGetReactionsNotifySettingsRequest extends TlObject {
  AccountGetReactionsNotifySettingsRequest();
  @override
  int get crc => 0x6dd654c;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class AccountSetReactionsNotifySettingsRequest extends TlObject {
  final ReactionsNotifySettings settings;
  AccountSetReactionsNotifySettingsRequest({required this.settings, });
  @override
  int get crc => 0x316ce548;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    settings.encode(e);
  }
}

class AccountGetCollectibleEmojiStatusesRequest extends TlObject {
  final int hash;
  AccountGetCollectibleEmojiStatusesRequest({required this.hash, });
  @override
  int get crc => 0x2e7b4543;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(hash);
  }
}

class AccountGetPaidMessagesRevenueRequest extends TlObject {
  final InputPeer? parentPeer;
  final InputUser userId;
  AccountGetPaidMessagesRevenueRequest({this.parentPeer, required this.userId, });
  @override
  int get crc => 0x19ba4a67;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (parentPeer != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    if (parentPeer != null) { parentPeer!.encode(e); }
    userId.encode(e);
  }
}

class AccountToggleNoPaidMessagesExceptionRequest extends TlObject {
  final bool refundCharged;
  final bool requirePayment;
  final InputPeer? parentPeer;
  final InputUser userId;
  AccountToggleNoPaidMessagesExceptionRequest({this.refundCharged = false, this.requirePayment = false, this.parentPeer, required this.userId, });
  @override
  int get crc => 0xfe2eda76;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (refundCharged == true ? (1 << 0) : 0) | (requirePayment == true ? (1 << 2) : 0) | (parentPeer != null ? (1 << 1) : 0);
    e.writeUint32(flags);
    if (parentPeer != null) { parentPeer!.encode(e); }
    userId.encode(e);
  }
}

class AccountSetMainProfileTabRequest extends TlObject {
  final ProfileTab tab;
  AccountSetMainProfileTabRequest({required this.tab, });
  @override
  int get crc => 0x5dee78b0;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    tab.encode(e);
  }
}

class AccountSaveMusicRequest extends TlObject {
  final bool unsave;
  final InputDocument id;
  final InputDocument? afterId;
  AccountSaveMusicRequest({this.unsave = false, required this.id, this.afterId, });
  @override
  int get crc => 0xb26732a9;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (unsave == true ? (1 << 0) : 0) | (afterId != null ? (1 << 1) : 0);
    e.writeUint32(flags);
    id.encode(e);
    if (afterId != null) { afterId!.encode(e); }
  }
}

class AccountGetSavedMusicIdsRequest extends TlObject {
  final int hash;
  AccountGetSavedMusicIdsRequest({required this.hash, });
  @override
  int get crc => 0xe09d5faf;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(hash);
  }
}

class AccountGetUniqueGiftChatThemesRequest extends TlObject {
  final String offset;
  final int limit;
  final int hash;
  AccountGetUniqueGiftChatThemesRequest({required this.offset, required this.limit, required this.hash, });
  @override
  int get crc => 0xe42ce9c9;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(offset);
    e.writeInt32(limit);
    e.writeInt64(hash);
  }
}

class AccountInitPasskeyRegistrationRequest extends TlObject {
  AccountInitPasskeyRegistrationRequest();
  @override
  int get crc => 0x429547e8;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class AccountRegisterPasskeyRequest extends TlObject {
  final InputPasskeyCredential credential;
  AccountRegisterPasskeyRequest({required this.credential, });
  @override
  int get crc => 0x55b41fd6;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    credential.encode(e);
  }
}

class AccountGetPasskeysRequest extends TlObject {
  AccountGetPasskeysRequest();
  @override
  int get crc => 0xea1f0c52;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class AccountDeletePasskeyRequest extends TlObject {
  final String id;
  AccountDeletePasskeyRequest({required this.id, });
  @override
  int get crc => 0xf5b5563f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(id);
  }
}

class AccountConfirmBotConnectionRequest extends TlObject {
  final InputUser botId;
  AccountConfirmBotConnectionRequest({required this.botId, });
  @override
  int get crc => 0x67ed1f68;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    botId.encode(e);
  }
}

class AccountGetWebBrowserSettingsRequest extends TlObject {
  final int hash;
  AccountGetWebBrowserSettingsRequest({required this.hash, });
  @override
  int get crc => 0x56655768;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(hash);
  }
}

class AccountUpdateWebBrowserSettingsRequest extends TlObject {
  final bool openExternalBrowser;
  final bool displayCloseButton;
  AccountUpdateWebBrowserSettingsRequest({this.openExternalBrowser = false, this.displayCloseButton = false, });
  @override
  int get crc => 0x9adf82fe;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (openExternalBrowser == true ? (1 << 0) : 0) | (displayCloseButton == true ? (1 << 1) : 0);
    e.writeUint32(flags);
  }
}

class AccountToggleWebBrowserSettingsExceptionRequest extends TlObject {
  final bool delete;
  final bool? openExternalBrowser;
  final String url;
  AccountToggleWebBrowserSettingsExceptionRequest({this.delete = false, this.openExternalBrowser, required this.url, });
  @override
  int get crc => 0x60ed4229;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (delete == true ? (1 << 1) : 0) | (openExternalBrowser != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    if (openExternalBrowser != null) { e.writeBool(openExternalBrowser!); }
    e.writeString(url);
  }
}

class AccountDeleteWebBrowserSettingsExceptionsRequest extends TlObject {
  AccountDeleteWebBrowserSettingsExceptionsRequest();
  @override
  int get crc => 0x86a0765d;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class UsersGetUsersRequest extends TlObject {
  final List<InputUser> id;
  UsersGetUsersRequest({required this.id, });
  @override
  int get crc => 0xd91a548;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { item.encode(e); }
  }
}

class UsersGetFullUserRequest extends TlObject {
  final InputUser id;
  UsersGetFullUserRequest({required this.id, });
  @override
  int get crc => 0xb60f5918;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    id.encode(e);
  }
}

class UsersSetSecureValueErrorsRequest extends TlObject {
  final InputUser id;
  final List<SecureValueError> errors;
  UsersSetSecureValueErrorsRequest({required this.id, required this.errors, });
  @override
  int get crc => 0x90c894b5;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    id.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(errors.length); for (final item in errors) { item.encode(e); }
  }
}

class UsersGetRequirementsToContactRequest extends TlObject {
  final List<InputUser> id;
  UsersGetRequirementsToContactRequest({required this.id, });
  @override
  int get crc => 0xd89a83a3;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { item.encode(e); }
  }
}

class UsersGetSavedMusicRequest extends TlObject {
  final InputUser id;
  final int offset;
  final int limit;
  final int hash;
  UsersGetSavedMusicRequest({required this.id, required this.offset, required this.limit, required this.hash, });
  @override
  int get crc => 0x788d7fe3;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    id.encode(e);
    e.writeInt32(offset);
    e.writeInt32(limit);
    e.writeInt64(hash);
  }
}

class UsersGetSavedMusicByIDRequest extends TlObject {
  final InputUser id;
  final List<InputDocument> documents;
  UsersGetSavedMusicByIDRequest({required this.id, required this.documents, });
  @override
  int get crc => 0x7573a4e9;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    id.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(documents.length); for (final item in documents) { item.encode(e); }
  }
}

class UsersSuggestBirthdayRequest extends TlObject {
  final InputUser id;
  final Birthday birthday;
  UsersSuggestBirthdayRequest({required this.id, required this.birthday, });
  @override
  int get crc => 0xfc533372;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    id.encode(e);
    birthday.encode(e);
  }
}

class ContactsGetContactIDsRequest extends TlObject {
  final int hash;
  ContactsGetContactIDsRequest({required this.hash, });
  @override
  int get crc => 0x7adc669d;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(hash);
  }
}

class ContactsGetStatusesRequest extends TlObject {
  ContactsGetStatusesRequest();
  @override
  int get crc => 0xc4a353ee;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class ContactsGetContactsRequest extends TlObject {
  final int hash;
  ContactsGetContactsRequest({required this.hash, });
  @override
  int get crc => 0x5dd69e12;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(hash);
  }
}

class ContactsImportContactsRequest extends TlObject {
  final List<InputContact> contacts;
  ContactsImportContactsRequest({required this.contacts, });
  @override
  int get crc => 0x2c800be5;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeCrc(0x1cb5c415); e.writeInt32(contacts.length); for (final item in contacts) { item.encode(e); }
  }
}

class ContactsDeleteContactsRequest extends TlObject {
  final List<InputUser> id;
  ContactsDeleteContactsRequest({required this.id, });
  @override
  int get crc => 0x96a0e00;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { item.encode(e); }
  }
}

class ContactsDeleteByPhonesRequest extends TlObject {
  final List<String> phones;
  ContactsDeleteByPhonesRequest({required this.phones, });
  @override
  int get crc => 0x1013fd9e;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeCrc(0x1cb5c415); e.writeInt32(phones.length); for (final item in phones) { e.writeString(item); }
  }
}

class ContactsBlockRequest extends TlObject {
  final bool myStoriesFrom;
  final InputPeer id;
  ContactsBlockRequest({this.myStoriesFrom = false, required this.id, });
  @override
  int get crc => 0x2e2e8734;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (myStoriesFrom == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    id.encode(e);
  }
}

class ContactsUnblockRequest extends TlObject {
  final bool myStoriesFrom;
  final InputPeer id;
  ContactsUnblockRequest({this.myStoriesFrom = false, required this.id, });
  @override
  int get crc => 0xb550d328;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (myStoriesFrom == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    id.encode(e);
  }
}

class ContactsGetBlockedRequest extends TlObject {
  final bool myStoriesFrom;
  final int offset;
  final int limit;
  ContactsGetBlockedRequest({this.myStoriesFrom = false, required this.offset, required this.limit, });
  @override
  int get crc => 0x9a868f80;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (myStoriesFrom == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    e.writeInt32(offset);
    e.writeInt32(limit);
  }
}

class ContactsSearchRequest extends TlObject {
  final bool broadcasts;
  final bool bots;
  final String q;
  final int limit;
  ContactsSearchRequest({this.broadcasts = false, this.bots = false, required this.q, required this.limit, });
  @override
  int get crc => 0x5f58d0f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (broadcasts == true ? (1 << 0) : 0) | (bots == true ? (1 << 1) : 0);
    e.writeUint32(flags);
    e.writeString(q);
    e.writeInt32(limit);
  }
}

class ContactsResolveUsernameRequest extends TlObject {
  final String username;
  final String? referer;
  ContactsResolveUsernameRequest({required this.username, this.referer, });
  @override
  int get crc => 0x725afbbc;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (referer != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    e.writeString(username);
    if (referer != null) { e.writeString(referer!); }
  }
}

class ContactsGetTopPeersRequest extends TlObject {
  final bool correspondents;
  final bool botsPm;
  final bool botsInline;
  final bool phoneCalls;
  final bool forwardUsers;
  final bool forwardChats;
  final bool groups;
  final bool channels;
  final bool botsApp;
  final bool botsGuestchat;
  final int offset;
  final int limit;
  final int hash;
  ContactsGetTopPeersRequest({this.correspondents = false, this.botsPm = false, this.botsInline = false, this.phoneCalls = false, this.forwardUsers = false, this.forwardChats = false, this.groups = false, this.channels = false, this.botsApp = false, this.botsGuestchat = false, required this.offset, required this.limit, required this.hash, });
  @override
  int get crc => 0x973478b6;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (correspondents == true ? (1 << 0) : 0) | (botsPm == true ? (1 << 1) : 0) | (botsInline == true ? (1 << 2) : 0) | (phoneCalls == true ? (1 << 3) : 0) | (forwardUsers == true ? (1 << 4) : 0) | (forwardChats == true ? (1 << 5) : 0) | (groups == true ? (1 << 10) : 0) | (channels == true ? (1 << 15) : 0) | (botsApp == true ? (1 << 16) : 0) | (botsGuestchat == true ? (1 << 17) : 0);
    e.writeUint32(flags);
    e.writeInt32(offset);
    e.writeInt32(limit);
    e.writeInt64(hash);
  }
}

class ContactsResetTopPeerRatingRequest extends TlObject {
  final TopPeerCategory category;
  final InputPeer peer;
  ContactsResetTopPeerRatingRequest({required this.category, required this.peer, });
  @override
  int get crc => 0x1ae373ac;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    category.encode(e);
    peer.encode(e);
  }
}

class ContactsResetSavedRequest extends TlObject {
  ContactsResetSavedRequest();
  @override
  int get crc => 0x879537f1;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class ContactsGetSavedRequest extends TlObject {
  ContactsGetSavedRequest();
  @override
  int get crc => 0x82f1e39f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class ContactsToggleTopPeersRequest extends TlObject {
  final bool enabled;
  ContactsToggleTopPeersRequest({required this.enabled, });
  @override
  int get crc => 0x8514bdda;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeBool(enabled);
  }
}

class ContactsAddContactRequest extends TlObject {
  final bool addPhonePrivacyException;
  final InputUser id;
  final String firstName;
  final String lastName;
  final String phone;
  final TextWithEntities? note;
  ContactsAddContactRequest({this.addPhonePrivacyException = false, required this.id, required this.firstName, required this.lastName, required this.phone, this.note, });
  @override
  int get crc => 0xd9ba2e54;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (addPhonePrivacyException == true ? (1 << 0) : 0) | (note != null ? (1 << 1) : 0);
    e.writeUint32(flags);
    id.encode(e);
    e.writeString(firstName);
    e.writeString(lastName);
    e.writeString(phone);
    if (note != null) { note!.encode(e); }
  }
}

class ContactsAcceptContactRequest extends TlObject {
  final InputUser id;
  ContactsAcceptContactRequest({required this.id, });
  @override
  int get crc => 0xf831a20f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    id.encode(e);
  }
}

class ContactsGetLocatedRequest extends TlObject {
  final bool background;
  final InputGeoPoint geoPoint;
  final int? selfExpires;
  ContactsGetLocatedRequest({this.background = false, required this.geoPoint, this.selfExpires, });
  @override
  int get crc => 0xd348bc44;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (background == true ? (1 << 1) : 0) | (selfExpires != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    geoPoint.encode(e);
    if (selfExpires != null) { e.writeInt32(selfExpires!); }
  }
}

class ContactsBlockFromRepliesRequest extends TlObject {
  final bool deleteMessage;
  final bool deleteHistory;
  final bool reportSpam;
  final int msgId;
  ContactsBlockFromRepliesRequest({this.deleteMessage = false, this.deleteHistory = false, this.reportSpam = false, required this.msgId, });
  @override
  int get crc => 0x29a8962c;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (deleteMessage == true ? (1 << 0) : 0) | (deleteHistory == true ? (1 << 1) : 0) | (reportSpam == true ? (1 << 2) : 0);
    e.writeUint32(flags);
    e.writeInt32(msgId);
  }
}

class ContactsResolvePhoneRequest extends TlObject {
  final String phone;
  ContactsResolvePhoneRequest({required this.phone, });
  @override
  int get crc => 0x8af94344;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(phone);
  }
}

class ContactsExportContactTokenRequest extends TlObject {
  ContactsExportContactTokenRequest();
  @override
  int get crc => 0xf8654027;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class ContactsImportContactTokenRequest extends TlObject {
  final String token;
  ContactsImportContactTokenRequest({required this.token, });
  @override
  int get crc => 0x13005788;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(token);
  }
}

class ContactsEditCloseFriendsRequest extends TlObject {
  final List<int> id;
  ContactsEditCloseFriendsRequest({required this.id, });
  @override
  int get crc => 0xba6705f0;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { e.writeInt64(item); }
  }
}

class ContactsSetBlockedRequest extends TlObject {
  final bool myStoriesFrom;
  final List<InputPeer> id;
  final int limit;
  ContactsSetBlockedRequest({this.myStoriesFrom = false, required this.id, required this.limit, });
  @override
  int get crc => 0x94c65c76;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (myStoriesFrom == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { item.encode(e); }
    e.writeInt32(limit);
  }
}

class ContactsGetBirthdaysRequest extends TlObject {
  ContactsGetBirthdaysRequest();
  @override
  int get crc => 0xdaeda864;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class ContactsGetSponsoredPeersRequest extends TlObject {
  final String q;
  ContactsGetSponsoredPeersRequest({required this.q, });
  @override
  int get crc => 0xb6c8c393;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(q);
  }
}

class ContactsUpdateContactNoteRequest extends TlObject {
  final InputUser id;
  final TextWithEntities note;
  ContactsUpdateContactNoteRequest({required this.id, required this.note, });
  @override
  int get crc => 0x139f63fb;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    id.encode(e);
    note.encode(e);
  }
}

class MessagesGetMessagesRequest extends TlObject {
  final List<InputMessage> id;
  MessagesGetMessagesRequest({required this.id, });
  @override
  int get crc => 0x63c66506;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { item.encode(e); }
  }
}

class MessagesGetDialogsRequest extends TlObject {
  final bool excludePinned;
  final int? folderId;
  final int offsetDate;
  final int offsetId;
  final InputPeer offsetPeer;
  final int limit;
  final int hash;
  MessagesGetDialogsRequest({this.excludePinned = false, this.folderId, required this.offsetDate, required this.offsetId, required this.offsetPeer, required this.limit, required this.hash, });
  @override
  int get crc => 0xa0f4cb4f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (excludePinned == true ? (1 << 0) : 0) | (folderId != null ? (1 << 1) : 0);
    e.writeUint32(flags);
    if (folderId != null) { e.writeInt32(folderId!); }
    e.writeInt32(offsetDate);
    e.writeInt32(offsetId);
    offsetPeer.encode(e);
    e.writeInt32(limit);
    e.writeInt64(hash);
  }
}

class MessagesGetHistoryRequest extends TlObject {
  final InputPeer peer;
  final int offsetId;
  final int offsetDate;
  final int addOffset;
  final int limit;
  final int maxId;
  final int minId;
  final int hash;
  MessagesGetHistoryRequest({required this.peer, required this.offsetId, required this.offsetDate, required this.addOffset, required this.limit, required this.maxId, required this.minId, required this.hash, });
  @override
  int get crc => 0x4423e6c5;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(offsetId);
    e.writeInt32(offsetDate);
    e.writeInt32(addOffset);
    e.writeInt32(limit);
    e.writeInt32(maxId);
    e.writeInt32(minId);
    e.writeInt64(hash);
  }
}

class MessagesSearchRequest extends TlObject {
  final InputPeer peer;
  final String q;
  final InputPeer? fromId;
  final InputPeer? savedPeerId;
  final List<Reaction>? savedReaction;
  final int? topMsgId;
  final MessagesFilter filter;
  final int minDate;
  final int maxDate;
  final int offsetId;
  final int addOffset;
  final int limit;
  final int maxId;
  final int minId;
  final int hash;
  MessagesSearchRequest({required this.peer, required this.q, this.fromId, this.savedPeerId, this.savedReaction, this.topMsgId, required this.filter, required this.minDate, required this.maxDate, required this.offsetId, required this.addOffset, required this.limit, required this.maxId, required this.minId, required this.hash, });
  @override
  int get crc => 0x29ee847a;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (fromId != null ? (1 << 0) : 0) | (savedPeerId != null ? (1 << 2) : 0) | (savedReaction != null ? (1 << 3) : 0) | (topMsgId != null ? (1 << 1) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeString(q);
    if (fromId != null) { fromId!.encode(e); }
    if (savedPeerId != null) { savedPeerId!.encode(e); }
    if (savedReaction != null) { e.writeCrc(0x1cb5c415); e.writeInt32(savedReaction!.length); for (final item in savedReaction!) { item.encode(e); } }
    if (topMsgId != null) { e.writeInt32(topMsgId!); }
    filter.encode(e);
    e.writeInt32(minDate);
    e.writeInt32(maxDate);
    e.writeInt32(offsetId);
    e.writeInt32(addOffset);
    e.writeInt32(limit);
    e.writeInt32(maxId);
    e.writeInt32(minId);
    e.writeInt64(hash);
  }
}

class MessagesReadHistoryRequest extends TlObject {
  final InputPeer peer;
  final int maxId;
  MessagesReadHistoryRequest({required this.peer, required this.maxId, });
  @override
  int get crc => 0xe306d3a;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(maxId);
  }
}

class MessagesDeleteHistoryRequest extends TlObject {
  final bool justClear;
  final bool revoke;
  final InputPeer peer;
  final int maxId;
  final int? minDate;
  final int? maxDate;
  MessagesDeleteHistoryRequest({this.justClear = false, this.revoke = false, required this.peer, required this.maxId, this.minDate, this.maxDate, });
  @override
  int get crc => 0xb08f922a;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (justClear == true ? (1 << 0) : 0) | (revoke == true ? (1 << 1) : 0) | (minDate != null ? (1 << 2) : 0) | (maxDate != null ? (1 << 3) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeInt32(maxId);
    if (minDate != null) { e.writeInt32(minDate!); }
    if (maxDate != null) { e.writeInt32(maxDate!); }
  }
}

class MessagesDeleteMessagesRequest extends TlObject {
  final bool revoke;
  final List<int> id;
  MessagesDeleteMessagesRequest({this.revoke = false, required this.id, });
  @override
  int get crc => 0xe58e95d2;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (revoke == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { e.writeInt32(item); }
  }
}

class MessagesReceivedMessagesRequest extends TlObject {
  final int maxId;
  MessagesReceivedMessagesRequest({required this.maxId, });
  @override
  int get crc => 0x5a954c0;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(maxId);
  }
}

class MessagesSetTypingRequest extends TlObject {
  final InputPeer peer;
  final int? topMsgId;
  final SendMessageAction action;
  MessagesSetTypingRequest({required this.peer, this.topMsgId, required this.action, });
  @override
  int get crc => 0x58943ee2;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (topMsgId != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    if (topMsgId != null) { e.writeInt32(topMsgId!); }
    action.encode(e);
  }
}

class MessagesSendMessageRequest extends TlObject {
  final bool noWebpage;
  final bool silent;
  final bool background;
  final bool clearDraft;
  final bool noforwards;
  final bool updateStickersetsOrder;
  final bool invertMedia;
  final bool allowPaidFloodskip;
  final InputPeer peer;
  final InputReplyTo? replyTo;
  final String message;
  final int randomId;
  final ReplyMarkup? replyMarkup;
  final List<MessageEntity>? entities;
  final int? scheduleDate;
  final int? scheduleRepeatPeriod;
  final InputPeer? sendAs;
  final InputQuickReplyShortcut? quickReplyShortcut;
  final int? effect;
  final int? allowPaidStars;
  final SuggestedPost? suggestedPost;
  final InputRichMessage? richMessage;
  MessagesSendMessageRequest({this.noWebpage = false, this.silent = false, this.background = false, this.clearDraft = false, this.noforwards = false, this.updateStickersetsOrder = false, this.invertMedia = false, this.allowPaidFloodskip = false, required this.peer, this.replyTo, required this.message, required this.randomId, this.replyMarkup, this.entities, this.scheduleDate, this.scheduleRepeatPeriod, this.sendAs, this.quickReplyShortcut, this.effect, this.allowPaidStars, this.suggestedPost, this.richMessage, });
  @override
  int get crc => 0xfef48f62;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (noWebpage == true ? (1 << 1) : 0) | (silent == true ? (1 << 5) : 0) | (background == true ? (1 << 6) : 0) | (clearDraft == true ? (1 << 7) : 0) | (noforwards == true ? (1 << 14) : 0) | (updateStickersetsOrder == true ? (1 << 15) : 0) | (invertMedia == true ? (1 << 16) : 0) | (allowPaidFloodskip == true ? (1 << 19) : 0) | (replyTo != null ? (1 << 0) : 0) | (replyMarkup != null ? (1 << 2) : 0) | (entities != null ? (1 << 3) : 0) | (scheduleDate != null ? (1 << 10) : 0) | (scheduleRepeatPeriod != null ? (1 << 24) : 0) | (sendAs != null ? (1 << 13) : 0) | (quickReplyShortcut != null ? (1 << 17) : 0) | (effect != null ? (1 << 18) : 0) | (allowPaidStars != null ? (1 << 21) : 0) | (suggestedPost != null ? (1 << 22) : 0) | (richMessage != null ? (1 << 23) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    if (replyTo != null) { replyTo!.encode(e); }
    e.writeString(message);
    e.writeInt64(randomId);
    if (replyMarkup != null) { replyMarkup!.encode(e); }
    if (entities != null) { e.writeCrc(0x1cb5c415); e.writeInt32(entities!.length); for (final item in entities!) { item.encode(e); } }
    if (scheduleDate != null) { e.writeInt32(scheduleDate!); }
    if (scheduleRepeatPeriod != null) { e.writeInt32(scheduleRepeatPeriod!); }
    if (sendAs != null) { sendAs!.encode(e); }
    if (quickReplyShortcut != null) { quickReplyShortcut!.encode(e); }
    if (effect != null) { e.writeInt64(effect!); }
    if (allowPaidStars != null) { e.writeInt64(allowPaidStars!); }
    if (suggestedPost != null) { suggestedPost!.encode(e); }
    if (richMessage != null) { richMessage!.encode(e); }
  }
}

class MessagesSendMediaRequest extends TlObject {
  final bool silent;
  final bool background;
  final bool clearDraft;
  final bool noforwards;
  final bool updateStickersetsOrder;
  final bool invertMedia;
  final bool allowPaidFloodskip;
  final InputPeer peer;
  final InputReplyTo? replyTo;
  final InputMedia media;
  final String message;
  final int randomId;
  final ReplyMarkup? replyMarkup;
  final List<MessageEntity>? entities;
  final int? scheduleDate;
  final int? scheduleRepeatPeriod;
  final InputPeer? sendAs;
  final InputQuickReplyShortcut? quickReplyShortcut;
  final int? effect;
  final int? allowPaidStars;
  final SuggestedPost? suggestedPost;
  MessagesSendMediaRequest({this.silent = false, this.background = false, this.clearDraft = false, this.noforwards = false, this.updateStickersetsOrder = false, this.invertMedia = false, this.allowPaidFloodskip = false, required this.peer, this.replyTo, required this.media, required this.message, required this.randomId, this.replyMarkup, this.entities, this.scheduleDate, this.scheduleRepeatPeriod, this.sendAs, this.quickReplyShortcut, this.effect, this.allowPaidStars, this.suggestedPost, });
  @override
  int get crc => 0x330e77f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (silent == true ? (1 << 5) : 0) | (background == true ? (1 << 6) : 0) | (clearDraft == true ? (1 << 7) : 0) | (noforwards == true ? (1 << 14) : 0) | (updateStickersetsOrder == true ? (1 << 15) : 0) | (invertMedia == true ? (1 << 16) : 0) | (allowPaidFloodskip == true ? (1 << 19) : 0) | (replyTo != null ? (1 << 0) : 0) | (replyMarkup != null ? (1 << 2) : 0) | (entities != null ? (1 << 3) : 0) | (scheduleDate != null ? (1 << 10) : 0) | (scheduleRepeatPeriod != null ? (1 << 24) : 0) | (sendAs != null ? (1 << 13) : 0) | (quickReplyShortcut != null ? (1 << 17) : 0) | (effect != null ? (1 << 18) : 0) | (allowPaidStars != null ? (1 << 21) : 0) | (suggestedPost != null ? (1 << 22) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    if (replyTo != null) { replyTo!.encode(e); }
    media.encode(e);
    e.writeString(message);
    e.writeInt64(randomId);
    if (replyMarkup != null) { replyMarkup!.encode(e); }
    if (entities != null) { e.writeCrc(0x1cb5c415); e.writeInt32(entities!.length); for (final item in entities!) { item.encode(e); } }
    if (scheduleDate != null) { e.writeInt32(scheduleDate!); }
    if (scheduleRepeatPeriod != null) { e.writeInt32(scheduleRepeatPeriod!); }
    if (sendAs != null) { sendAs!.encode(e); }
    if (quickReplyShortcut != null) { quickReplyShortcut!.encode(e); }
    if (effect != null) { e.writeInt64(effect!); }
    if (allowPaidStars != null) { e.writeInt64(allowPaidStars!); }
    if (suggestedPost != null) { suggestedPost!.encode(e); }
  }
}

class MessagesForwardMessagesRequest extends TlObject {
  final bool silent;
  final bool background;
  final bool withMyScore;
  final bool dropAuthor;
  final bool dropMediaCaptions;
  final bool noforwards;
  final bool allowPaidFloodskip;
  final InputPeer fromPeer;
  final List<int> id;
  final List<int> randomId;
  final InputPeer toPeer;
  final int? topMsgId;
  final InputReplyTo? replyTo;
  final int? scheduleDate;
  final int? scheduleRepeatPeriod;
  final InputPeer? sendAs;
  final InputQuickReplyShortcut? quickReplyShortcut;
  final int? effect;
  final int? videoTimestamp;
  final int? allowPaidStars;
  final SuggestedPost? suggestedPost;
  MessagesForwardMessagesRequest({this.silent = false, this.background = false, this.withMyScore = false, this.dropAuthor = false, this.dropMediaCaptions = false, this.noforwards = false, this.allowPaidFloodskip = false, required this.fromPeer, required this.id, required this.randomId, required this.toPeer, this.topMsgId, this.replyTo, this.scheduleDate, this.scheduleRepeatPeriod, this.sendAs, this.quickReplyShortcut, this.effect, this.videoTimestamp, this.allowPaidStars, this.suggestedPost, });
  @override
  int get crc => 0x13704a7c;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (silent == true ? (1 << 5) : 0) | (background == true ? (1 << 6) : 0) | (withMyScore == true ? (1 << 8) : 0) | (dropAuthor == true ? (1 << 11) : 0) | (dropMediaCaptions == true ? (1 << 12) : 0) | (noforwards == true ? (1 << 14) : 0) | (allowPaidFloodskip == true ? (1 << 19) : 0) | (topMsgId != null ? (1 << 9) : 0) | (replyTo != null ? (1 << 22) : 0) | (scheduleDate != null ? (1 << 10) : 0) | (scheduleRepeatPeriod != null ? (1 << 24) : 0) | (sendAs != null ? (1 << 13) : 0) | (quickReplyShortcut != null ? (1 << 17) : 0) | (effect != null ? (1 << 18) : 0) | (videoTimestamp != null ? (1 << 20) : 0) | (allowPaidStars != null ? (1 << 21) : 0) | (suggestedPost != null ? (1 << 23) : 0);
    e.writeUint32(flags);
    fromPeer.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { e.writeInt32(item); }
    e.writeCrc(0x1cb5c415); e.writeInt32(randomId.length); for (final item in randomId) { e.writeInt64(item); }
    toPeer.encode(e);
    if (topMsgId != null) { e.writeInt32(topMsgId!); }
    if (replyTo != null) { replyTo!.encode(e); }
    if (scheduleDate != null) { e.writeInt32(scheduleDate!); }
    if (scheduleRepeatPeriod != null) { e.writeInt32(scheduleRepeatPeriod!); }
    if (sendAs != null) { sendAs!.encode(e); }
    if (quickReplyShortcut != null) { quickReplyShortcut!.encode(e); }
    if (effect != null) { e.writeInt64(effect!); }
    if (videoTimestamp != null) { e.writeInt32(videoTimestamp!); }
    if (allowPaidStars != null) { e.writeInt64(allowPaidStars!); }
    if (suggestedPost != null) { suggestedPost!.encode(e); }
  }
}

class MessagesReportSpamRequest extends TlObject {
  final InputPeer peer;
  MessagesReportSpamRequest({required this.peer, });
  @override
  int get crc => 0xcf1592db;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
  }
}

class MessagesGetPeerSettingsRequest extends TlObject {
  final InputPeer peer;
  MessagesGetPeerSettingsRequest({required this.peer, });
  @override
  int get crc => 0xefd9a6a2;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
  }
}

class MessagesReportRequest extends TlObject {
  final InputPeer peer;
  final List<int> id;
  final Uint8List option;
  final String message;
  MessagesReportRequest({required this.peer, required this.id, required this.option, required this.message, });
  @override
  int get crc => 0xfc78af9b;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { e.writeInt32(item); }
    e.writeBytes(option);
    e.writeString(message);
  }
}

class MessagesGetChatsRequest extends TlObject {
  final List<int> id;
  MessagesGetChatsRequest({required this.id, });
  @override
  int get crc => 0x49e9528f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { e.writeInt64(item); }
  }
}

class MessagesGetFullChatRequest extends TlObject {
  final int chatId;
  MessagesGetFullChatRequest({required this.chatId, });
  @override
  int get crc => 0xaeb00b34;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(chatId);
  }
}

class MessagesEditChatTitleRequest extends TlObject {
  final int chatId;
  final String title;
  MessagesEditChatTitleRequest({required this.chatId, required this.title, });
  @override
  int get crc => 0x73783ffd;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(chatId);
    e.writeString(title);
  }
}

class MessagesEditChatPhotoRequest extends TlObject {
  final int chatId;
  final InputChatPhoto photo;
  MessagesEditChatPhotoRequest({required this.chatId, required this.photo, });
  @override
  int get crc => 0x35ddd674;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(chatId);
    photo.encode(e);
  }
}

class MessagesAddChatUserRequest extends TlObject {
  final int chatId;
  final InputUser userId;
  final int fwdLimit;
  MessagesAddChatUserRequest({required this.chatId, required this.userId, required this.fwdLimit, });
  @override
  int get crc => 0xcbc6d107;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(chatId);
    userId.encode(e);
    e.writeInt32(fwdLimit);
  }
}

class MessagesDeleteChatUserRequest extends TlObject {
  final bool revokeHistory;
  final int chatId;
  final InputUser userId;
  MessagesDeleteChatUserRequest({this.revokeHistory = false, required this.chatId, required this.userId, });
  @override
  int get crc => 0xa2185cab;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (revokeHistory == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    e.writeInt64(chatId);
    userId.encode(e);
  }
}

class MessagesCreateChatRequest extends TlObject {
  final List<InputUser> users;
  final String title;
  final int? ttlPeriod;
  MessagesCreateChatRequest({required this.users, required this.title, this.ttlPeriod, });
  @override
  int get crc => 0x92ceddd4;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (ttlPeriod != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    e.writeCrc(0x1cb5c415); e.writeInt32(users.length); for (final item in users) { item.encode(e); }
    e.writeString(title);
    if (ttlPeriod != null) { e.writeInt32(ttlPeriod!); }
  }
}

class MessagesGetDhConfigRequest extends TlObject {
  final int version;
  final int randomLength;
  MessagesGetDhConfigRequest({required this.version, required this.randomLength, });
  @override
  int get crc => 0x26cf8950;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(version);
    e.writeInt32(randomLength);
  }
}

class MessagesRequestEncryptionRequest extends TlObject {
  final InputUser userId;
  final int randomId;
  final Uint8List gA;
  MessagesRequestEncryptionRequest({required this.userId, required this.randomId, required this.gA, });
  @override
  int get crc => 0xf64daf43;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    userId.encode(e);
    e.writeInt32(randomId);
    e.writeBytes(gA);
  }
}

class MessagesAcceptEncryptionRequest extends TlObject {
  final InputEncryptedChat peer;
  final Uint8List gB;
  final int keyFingerprint;
  MessagesAcceptEncryptionRequest({required this.peer, required this.gB, required this.keyFingerprint, });
  @override
  int get crc => 0x3dbc0415;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeBytes(gB);
    e.writeInt64(keyFingerprint);
  }
}

class MessagesDiscardEncryptionRequest extends TlObject {
  final bool deleteHistory;
  final int chatId;
  MessagesDiscardEncryptionRequest({this.deleteHistory = false, required this.chatId, });
  @override
  int get crc => 0xf393aea0;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (deleteHistory == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    e.writeInt32(chatId);
  }
}

class MessagesSetEncryptedTypingRequest extends TlObject {
  final InputEncryptedChat peer;
  final bool typing;
  MessagesSetEncryptedTypingRequest({required this.peer, required this.typing, });
  @override
  int get crc => 0x791451ed;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeBool(typing);
  }
}

class MessagesReadEncryptedHistoryRequest extends TlObject {
  final InputEncryptedChat peer;
  final int maxDate;
  MessagesReadEncryptedHistoryRequest({required this.peer, required this.maxDate, });
  @override
  int get crc => 0x7f4b690a;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(maxDate);
  }
}

class MessagesSendEncryptedRequest extends TlObject {
  final bool silent;
  final InputEncryptedChat peer;
  final int randomId;
  final Uint8List data;
  MessagesSendEncryptedRequest({this.silent = false, required this.peer, required this.randomId, required this.data, });
  @override
  int get crc => 0x44fa7a15;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (silent == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeInt64(randomId);
    e.writeBytes(data);
  }
}

class MessagesSendEncryptedFileRequest extends TlObject {
  final bool silent;
  final InputEncryptedChat peer;
  final int randomId;
  final Uint8List data;
  final InputEncryptedFile file;
  MessagesSendEncryptedFileRequest({this.silent = false, required this.peer, required this.randomId, required this.data, required this.file, });
  @override
  int get crc => 0x5559481d;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (silent == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeInt64(randomId);
    e.writeBytes(data);
    file.encode(e);
  }
}

class MessagesSendEncryptedServiceRequest extends TlObject {
  final InputEncryptedChat peer;
  final int randomId;
  final Uint8List data;
  MessagesSendEncryptedServiceRequest({required this.peer, required this.randomId, required this.data, });
  @override
  int get crc => 0x32d439a4;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt64(randomId);
    e.writeBytes(data);
  }
}

class MessagesReceivedQueueRequest extends TlObject {
  final int maxQts;
  MessagesReceivedQueueRequest({required this.maxQts, });
  @override
  int get crc => 0x55a5bb66;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(maxQts);
  }
}

class MessagesReportEncryptedSpamRequest extends TlObject {
  final InputEncryptedChat peer;
  MessagesReportEncryptedSpamRequest({required this.peer, });
  @override
  int get crc => 0x4b0c8c0f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
  }
}

class MessagesReadMessageContentsRequest extends TlObject {
  final List<int> id;
  MessagesReadMessageContentsRequest({required this.id, });
  @override
  int get crc => 0x36a73f77;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { e.writeInt32(item); }
  }
}

class MessagesGetStickersRequest extends TlObject {
  final String emoticon;
  final int hash;
  MessagesGetStickersRequest({required this.emoticon, required this.hash, });
  @override
  int get crc => 0xd5a5d3a1;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(emoticon);
    e.writeInt64(hash);
  }
}

class MessagesGetAllStickersRequest extends TlObject {
  final int hash;
  MessagesGetAllStickersRequest({required this.hash, });
  @override
  int get crc => 0xb8a0a1a8;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(hash);
  }
}

class MessagesGetWebPagePreviewRequest extends TlObject {
  final String message;
  final List<MessageEntity>? entities;
  MessagesGetWebPagePreviewRequest({required this.message, this.entities, });
  @override
  int get crc => 0x570d6f6f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (entities != null ? (1 << 3) : 0);
    e.writeUint32(flags);
    e.writeString(message);
    if (entities != null) { e.writeCrc(0x1cb5c415); e.writeInt32(entities!.length); for (final item in entities!) { item.encode(e); } }
  }
}

class MessagesExportChatInviteRequest extends TlObject {
  final bool legacyRevokePermanent;
  final bool requestNeeded;
  final InputPeer peer;
  final int? expireDate;
  final int? usageLimit;
  final String? title;
  final StarsSubscriptionPricing? subscriptionPricing;
  MessagesExportChatInviteRequest({this.legacyRevokePermanent = false, this.requestNeeded = false, required this.peer, this.expireDate, this.usageLimit, this.title, this.subscriptionPricing, });
  @override
  int get crc => 0xa455de90;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (legacyRevokePermanent == true ? (1 << 2) : 0) | (requestNeeded == true ? (1 << 3) : 0) | (expireDate != null ? (1 << 0) : 0) | (usageLimit != null ? (1 << 1) : 0) | (title != null ? (1 << 4) : 0) | (subscriptionPricing != null ? (1 << 5) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    if (expireDate != null) { e.writeInt32(expireDate!); }
    if (usageLimit != null) { e.writeInt32(usageLimit!); }
    if (title != null) { e.writeString(title!); }
    if (subscriptionPricing != null) { subscriptionPricing!.encode(e); }
  }
}

class MessagesCheckChatInviteRequest extends TlObject {
  final String hash;
  MessagesCheckChatInviteRequest({required this.hash, });
  @override
  int get crc => 0x3eadb1bb;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(hash);
  }
}

class MessagesImportChatInviteRequest extends TlObject {
  final String hash;
  MessagesImportChatInviteRequest({required this.hash, });
  @override
  int get crc => 0xde91436e;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(hash);
  }
}

class MessagesGetStickerSetRequest extends TlObject {
  final InputStickerSet stickerset;
  final int hash;
  MessagesGetStickerSetRequest({required this.stickerset, required this.hash, });
  @override
  int get crc => 0xc8a0ec74;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    stickerset.encode(e);
    e.writeInt32(hash);
  }
}

class MessagesInstallStickerSetRequest extends TlObject {
  final InputStickerSet stickerset;
  final bool archived;
  MessagesInstallStickerSetRequest({required this.stickerset, required this.archived, });
  @override
  int get crc => 0xc78fe460;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    stickerset.encode(e);
    e.writeBool(archived);
  }
}

class MessagesUninstallStickerSetRequest extends TlObject {
  final InputStickerSet stickerset;
  MessagesUninstallStickerSetRequest({required this.stickerset, });
  @override
  int get crc => 0xf96e55de;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    stickerset.encode(e);
  }
}

class MessagesStartBotRequest extends TlObject {
  final InputUser bot;
  final InputPeer peer;
  final int randomId;
  final String startParam;
  MessagesStartBotRequest({required this.bot, required this.peer, required this.randomId, required this.startParam, });
  @override
  int get crc => 0xe6df7378;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    bot.encode(e);
    peer.encode(e);
    e.writeInt64(randomId);
    e.writeString(startParam);
  }
}

class MessagesGetMessagesViewsRequest extends TlObject {
  final InputPeer peer;
  final List<int> id;
  final bool increment;
  MessagesGetMessagesViewsRequest({required this.peer, required this.id, required this.increment, });
  @override
  int get crc => 0x5784d3e1;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { e.writeInt32(item); }
    e.writeBool(increment);
  }
}

class MessagesEditChatAdminRequest extends TlObject {
  final int chatId;
  final InputUser userId;
  final bool isAdmin;
  MessagesEditChatAdminRequest({required this.chatId, required this.userId, required this.isAdmin, });
  @override
  int get crc => 0xa85bd1c2;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(chatId);
    userId.encode(e);
    e.writeBool(isAdmin);
  }
}

class MessagesMigrateChatRequest extends TlObject {
  final int chatId;
  MessagesMigrateChatRequest({required this.chatId, });
  @override
  int get crc => 0xa2875319;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(chatId);
  }
}

class MessagesSearchGlobalRequest extends TlObject {
  final bool broadcastsOnly;
  final bool groupsOnly;
  final bool usersOnly;
  final int? folderId;
  final String q;
  final MessagesFilter filter;
  final int minDate;
  final int maxDate;
  final int offsetRate;
  final InputPeer offsetPeer;
  final int offsetId;
  final int limit;
  MessagesSearchGlobalRequest({this.broadcastsOnly = false, this.groupsOnly = false, this.usersOnly = false, this.folderId, required this.q, required this.filter, required this.minDate, required this.maxDate, required this.offsetRate, required this.offsetPeer, required this.offsetId, required this.limit, });
  @override
  int get crc => 0x4bc6589a;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (broadcastsOnly == true ? (1 << 1) : 0) | (groupsOnly == true ? (1 << 2) : 0) | (usersOnly == true ? (1 << 3) : 0) | (folderId != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    if (folderId != null) { e.writeInt32(folderId!); }
    e.writeString(q);
    filter.encode(e);
    e.writeInt32(minDate);
    e.writeInt32(maxDate);
    e.writeInt32(offsetRate);
    offsetPeer.encode(e);
    e.writeInt32(offsetId);
    e.writeInt32(limit);
  }
}

class MessagesReorderStickerSetsRequest extends TlObject {
  final bool masks;
  final bool emojis;
  final List<int> order;
  MessagesReorderStickerSetsRequest({this.masks = false, this.emojis = false, required this.order, });
  @override
  int get crc => 0x78337739;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (masks == true ? (1 << 0) : 0) | (emojis == true ? (1 << 1) : 0);
    e.writeUint32(flags);
    e.writeCrc(0x1cb5c415); e.writeInt32(order.length); for (final item in order) { e.writeInt64(item); }
  }
}

class MessagesGetDocumentByHashRequest extends TlObject {
  final Uint8List sha256;
  final int size;
  final String mimeType;
  MessagesGetDocumentByHashRequest({required this.sha256, required this.size, required this.mimeType, });
  @override
  int get crc => 0xb1f2061f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeBytes(sha256);
    e.writeInt64(size);
    e.writeString(mimeType);
  }
}

class MessagesGetSavedGifsRequest extends TlObject {
  final int hash;
  MessagesGetSavedGifsRequest({required this.hash, });
  @override
  int get crc => 0x5cf09635;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(hash);
  }
}

class MessagesSaveGifRequest extends TlObject {
  final InputDocument id;
  final bool unsave;
  MessagesSaveGifRequest({required this.id, required this.unsave, });
  @override
  int get crc => 0x327a30cb;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    id.encode(e);
    e.writeBool(unsave);
  }
}

class MessagesGetInlineBotResultsRequest extends TlObject {
  final InputUser bot;
  final InputPeer peer;
  final InputGeoPoint? geoPoint;
  final String query;
  final String offset;
  MessagesGetInlineBotResultsRequest({required this.bot, required this.peer, this.geoPoint, required this.query, required this.offset, });
  @override
  int get crc => 0x514e999d;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (geoPoint != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    bot.encode(e);
    peer.encode(e);
    if (geoPoint != null) { geoPoint!.encode(e); }
    e.writeString(query);
    e.writeString(offset);
  }
}

class MessagesSetInlineBotResultsRequest extends TlObject {
  final bool gallery;
  final bool private;
  final int queryId;
  final List<InputBotInlineResult> results;
  final int cacheTime;
  final String? nextOffset;
  final InlineBotSwitchPM? switchPm;
  final InlineBotWebView? switchWebview;
  MessagesSetInlineBotResultsRequest({this.gallery = false, this.private = false, required this.queryId, required this.results, required this.cacheTime, this.nextOffset, this.switchPm, this.switchWebview, });
  @override
  int get crc => 0xbb12a419;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (gallery == true ? (1 << 0) : 0) | (private == true ? (1 << 1) : 0) | (nextOffset != null ? (1 << 2) : 0) | (switchPm != null ? (1 << 3) : 0) | (switchWebview != null ? (1 << 4) : 0);
    e.writeUint32(flags);
    e.writeInt64(queryId);
    e.writeCrc(0x1cb5c415); e.writeInt32(results.length); for (final item in results) { item.encode(e); }
    e.writeInt32(cacheTime);
    if (nextOffset != null) { e.writeString(nextOffset!); }
    if (switchPm != null) { switchPm!.encode(e); }
    if (switchWebview != null) { switchWebview!.encode(e); }
  }
}

class MessagesSendInlineBotResultRequest extends TlObject {
  final bool silent;
  final bool background;
  final bool clearDraft;
  final bool hideVia;
  final InputPeer peer;
  final InputReplyTo? replyTo;
  final int randomId;
  final int queryId;
  final String id;
  final int? scheduleDate;
  final InputPeer? sendAs;
  final InputQuickReplyShortcut? quickReplyShortcut;
  final int? allowPaidStars;
  MessagesSendInlineBotResultRequest({this.silent = false, this.background = false, this.clearDraft = false, this.hideVia = false, required this.peer, this.replyTo, required this.randomId, required this.queryId, required this.id, this.scheduleDate, this.sendAs, this.quickReplyShortcut, this.allowPaidStars, });
  @override
  int get crc => 0xc0cf7646;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (silent == true ? (1 << 5) : 0) | (background == true ? (1 << 6) : 0) | (clearDraft == true ? (1 << 7) : 0) | (hideVia == true ? (1 << 11) : 0) | (replyTo != null ? (1 << 0) : 0) | (scheduleDate != null ? (1 << 10) : 0) | (sendAs != null ? (1 << 13) : 0) | (quickReplyShortcut != null ? (1 << 17) : 0) | (allowPaidStars != null ? (1 << 21) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    if (replyTo != null) { replyTo!.encode(e); }
    e.writeInt64(randomId);
    e.writeInt64(queryId);
    e.writeString(id);
    if (scheduleDate != null) { e.writeInt32(scheduleDate!); }
    if (sendAs != null) { sendAs!.encode(e); }
    if (quickReplyShortcut != null) { quickReplyShortcut!.encode(e); }
    if (allowPaidStars != null) { e.writeInt64(allowPaidStars!); }
  }
}

class MessagesGetMessageEditDataRequest extends TlObject {
  final InputPeer peer;
  final int id;
  MessagesGetMessageEditDataRequest({required this.peer, required this.id, });
  @override
  int get crc => 0xfda68d36;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(id);
  }
}

class MessagesEditMessageRequest extends TlObject {
  final bool noWebpage;
  final bool invertMedia;
  final InputPeer peer;
  final int id;
  final String? message;
  final InputMedia? media;
  final ReplyMarkup? replyMarkup;
  final List<MessageEntity>? entities;
  final int? scheduleDate;
  final int? scheduleRepeatPeriod;
  final int? quickReplyShortcutId;
  final InputRichMessage? richMessage;
  MessagesEditMessageRequest({this.noWebpage = false, this.invertMedia = false, required this.peer, required this.id, this.message, this.media, this.replyMarkup, this.entities, this.scheduleDate, this.scheduleRepeatPeriod, this.quickReplyShortcutId, this.richMessage, });
  @override
  int get crc => 0xb106e66c;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (noWebpage == true ? (1 << 1) : 0) | (invertMedia == true ? (1 << 16) : 0) | (message != null ? (1 << 11) : 0) | (media != null ? (1 << 14) : 0) | (replyMarkup != null ? (1 << 2) : 0) | (entities != null ? (1 << 3) : 0) | (scheduleDate != null ? (1 << 15) : 0) | (scheduleRepeatPeriod != null ? (1 << 18) : 0) | (quickReplyShortcutId != null ? (1 << 17) : 0) | (richMessage != null ? (1 << 23) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeInt32(id);
    if (message != null) { e.writeString(message!); }
    if (media != null) { media!.encode(e); }
    if (replyMarkup != null) { replyMarkup!.encode(e); }
    if (entities != null) { e.writeCrc(0x1cb5c415); e.writeInt32(entities!.length); for (final item in entities!) { item.encode(e); } }
    if (scheduleDate != null) { e.writeInt32(scheduleDate!); }
    if (scheduleRepeatPeriod != null) { e.writeInt32(scheduleRepeatPeriod!); }
    if (quickReplyShortcutId != null) { e.writeInt32(quickReplyShortcutId!); }
    if (richMessage != null) { richMessage!.encode(e); }
  }
}

class MessagesEditInlineBotMessageRequest extends TlObject {
  final bool noWebpage;
  final bool invertMedia;
  final InputBotInlineMessageID id;
  final String? message;
  final InputMedia? media;
  final ReplyMarkup? replyMarkup;
  final List<MessageEntity>? entities;
  final InputRichMessage? richMessage;
  MessagesEditInlineBotMessageRequest({this.noWebpage = false, this.invertMedia = false, required this.id, this.message, this.media, this.replyMarkup, this.entities, this.richMessage, });
  @override
  int get crc => 0xa423bb51;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (noWebpage == true ? (1 << 1) : 0) | (invertMedia == true ? (1 << 16) : 0) | (message != null ? (1 << 11) : 0) | (media != null ? (1 << 14) : 0) | (replyMarkup != null ? (1 << 2) : 0) | (entities != null ? (1 << 3) : 0) | (richMessage != null ? (1 << 23) : 0);
    e.writeUint32(flags);
    id.encode(e);
    if (message != null) { e.writeString(message!); }
    if (media != null) { media!.encode(e); }
    if (replyMarkup != null) { replyMarkup!.encode(e); }
    if (entities != null) { e.writeCrc(0x1cb5c415); e.writeInt32(entities!.length); for (final item in entities!) { item.encode(e); } }
    if (richMessage != null) { richMessage!.encode(e); }
  }
}

class MessagesGetBotCallbackAnswerRequest extends TlObject {
  final bool game;
  final InputPeer peer;
  final int msgId;
  final Uint8List? data;
  final InputCheckPasswordSRP? password;
  MessagesGetBotCallbackAnswerRequest({this.game = false, required this.peer, required this.msgId, this.data, this.password, });
  @override
  int get crc => 0x9342ca07;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (game == true ? (1 << 1) : 0) | (data != null ? (1 << 0) : 0) | (password != null ? (1 << 2) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeInt32(msgId);
    if (data != null) { e.writeBytes(data!); }
    if (password != null) { password!.encode(e); }
  }
}

class MessagesSetBotCallbackAnswerRequest extends TlObject {
  final bool alert;
  final int queryId;
  final String? message;
  final String? url;
  final int cacheTime;
  MessagesSetBotCallbackAnswerRequest({this.alert = false, required this.queryId, this.message, this.url, required this.cacheTime, });
  @override
  int get crc => 0xd58f130a;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (alert == true ? (1 << 1) : 0) | (message != null ? (1 << 0) : 0) | (url != null ? (1 << 2) : 0);
    e.writeUint32(flags);
    e.writeInt64(queryId);
    if (message != null) { e.writeString(message!); }
    if (url != null) { e.writeString(url!); }
    e.writeInt32(cacheTime);
  }
}

class MessagesGetPeerDialogsRequest extends TlObject {
  final List<InputDialogPeer> peers;
  MessagesGetPeerDialogsRequest({required this.peers, });
  @override
  int get crc => 0xe470bcfd;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeCrc(0x1cb5c415); e.writeInt32(peers.length); for (final item in peers) { item.encode(e); }
  }
}

class MessagesSaveDraftRequest extends TlObject {
  final bool noWebpage;
  final bool invertMedia;
  final InputReplyTo? replyTo;
  final InputPeer peer;
  final String message;
  final List<MessageEntity>? entities;
  final InputMedia? media;
  final int? effect;
  final SuggestedPost? suggestedPost;
  final InputRichMessage? richMessage;
  MessagesSaveDraftRequest({this.noWebpage = false, this.invertMedia = false, this.replyTo, required this.peer, required this.message, this.entities, this.media, this.effect, this.suggestedPost, this.richMessage, });
  @override
  int get crc => 0xad0fa15c;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (noWebpage == true ? (1 << 1) : 0) | (invertMedia == true ? (1 << 6) : 0) | (replyTo != null ? (1 << 4) : 0) | (entities != null ? (1 << 3) : 0) | (media != null ? (1 << 5) : 0) | (effect != null ? (1 << 7) : 0) | (suggestedPost != null ? (1 << 8) : 0) | (richMessage != null ? (1 << 9) : 0);
    e.writeUint32(flags);
    if (replyTo != null) { replyTo!.encode(e); }
    peer.encode(e);
    e.writeString(message);
    if (entities != null) { e.writeCrc(0x1cb5c415); e.writeInt32(entities!.length); for (final item in entities!) { item.encode(e); } }
    if (media != null) { media!.encode(e); }
    if (effect != null) { e.writeInt64(effect!); }
    if (suggestedPost != null) { suggestedPost!.encode(e); }
    if (richMessage != null) { richMessage!.encode(e); }
  }
}

class MessagesGetAllDraftsRequest extends TlObject {
  MessagesGetAllDraftsRequest();
  @override
  int get crc => 0x6a3f8d65;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class MessagesGetFeaturedStickersRequest extends TlObject {
  final int hash;
  MessagesGetFeaturedStickersRequest({required this.hash, });
  @override
  int get crc => 0x64780b14;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(hash);
  }
}

class MessagesReadFeaturedStickersRequest extends TlObject {
  final List<int> id;
  MessagesReadFeaturedStickersRequest({required this.id, });
  @override
  int get crc => 0x5b118126;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { e.writeInt64(item); }
  }
}

class MessagesGetRecentStickersRequest extends TlObject {
  final bool attached;
  final int hash;
  MessagesGetRecentStickersRequest({this.attached = false, required this.hash, });
  @override
  int get crc => 0x9da9403b;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (attached == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    e.writeInt64(hash);
  }
}

class MessagesSaveRecentStickerRequest extends TlObject {
  final bool attached;
  final InputDocument id;
  final bool unsave;
  MessagesSaveRecentStickerRequest({this.attached = false, required this.id, required this.unsave, });
  @override
  int get crc => 0x392718f8;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (attached == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    id.encode(e);
    e.writeBool(unsave);
  }
}

class MessagesClearRecentStickersRequest extends TlObject {
  final bool attached;
  MessagesClearRecentStickersRequest({this.attached = false, });
  @override
  int get crc => 0x8999602d;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (attached == true ? (1 << 0) : 0);
    e.writeUint32(flags);
  }
}

class MessagesGetArchivedStickersRequest extends TlObject {
  final bool masks;
  final bool emojis;
  final int offsetId;
  final int limit;
  MessagesGetArchivedStickersRequest({this.masks = false, this.emojis = false, required this.offsetId, required this.limit, });
  @override
  int get crc => 0x57f17692;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (masks == true ? (1 << 0) : 0) | (emojis == true ? (1 << 1) : 0);
    e.writeUint32(flags);
    e.writeInt64(offsetId);
    e.writeInt32(limit);
  }
}

class MessagesGetMaskStickersRequest extends TlObject {
  final int hash;
  MessagesGetMaskStickersRequest({required this.hash, });
  @override
  int get crc => 0x640f82b8;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(hash);
  }
}

class MessagesGetAttachedStickersRequest extends TlObject {
  final InputStickeredMedia media;
  MessagesGetAttachedStickersRequest({required this.media, });
  @override
  int get crc => 0xcc5b67cc;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    media.encode(e);
  }
}

class MessagesSetGameScoreRequest extends TlObject {
  final bool editMessage;
  final bool force;
  final InputPeer peer;
  final int id;
  final InputUser userId;
  final int score;
  MessagesSetGameScoreRequest({this.editMessage = false, this.force = false, required this.peer, required this.id, required this.userId, required this.score, });
  @override
  int get crc => 0x8ef8ecc0;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (editMessage == true ? (1 << 0) : 0) | (force == true ? (1 << 1) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeInt32(id);
    userId.encode(e);
    e.writeInt32(score);
  }
}

class MessagesSetInlineGameScoreRequest extends TlObject {
  final bool editMessage;
  final bool force;
  final InputBotInlineMessageID id;
  final InputUser userId;
  final int score;
  MessagesSetInlineGameScoreRequest({this.editMessage = false, this.force = false, required this.id, required this.userId, required this.score, });
  @override
  int get crc => 0x15ad9f64;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (editMessage == true ? (1 << 0) : 0) | (force == true ? (1 << 1) : 0);
    e.writeUint32(flags);
    id.encode(e);
    userId.encode(e);
    e.writeInt32(score);
  }
}

class MessagesGetGameHighScoresRequest extends TlObject {
  final InputPeer peer;
  final int id;
  final InputUser userId;
  MessagesGetGameHighScoresRequest({required this.peer, required this.id, required this.userId, });
  @override
  int get crc => 0xe822649d;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(id);
    userId.encode(e);
  }
}

class MessagesGetInlineGameHighScoresRequest extends TlObject {
  final InputBotInlineMessageID id;
  final InputUser userId;
  MessagesGetInlineGameHighScoresRequest({required this.id, required this.userId, });
  @override
  int get crc => 0xf635e1b;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    id.encode(e);
    userId.encode(e);
  }
}

class MessagesGetCommonChatsRequest extends TlObject {
  final InputUser userId;
  final int maxId;
  final int limit;
  MessagesGetCommonChatsRequest({required this.userId, required this.maxId, required this.limit, });
  @override
  int get crc => 0xe40ca104;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    userId.encode(e);
    e.writeInt64(maxId);
    e.writeInt32(limit);
  }
}

class MessagesGetWebPageRequest extends TlObject {
  final String url;
  final int hash;
  MessagesGetWebPageRequest({required this.url, required this.hash, });
  @override
  int get crc => 0x8d9692a3;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(url);
    e.writeInt32(hash);
  }
}

class MessagesToggleDialogPinRequest extends TlObject {
  final bool pinned;
  final InputDialogPeer peer;
  MessagesToggleDialogPinRequest({this.pinned = false, required this.peer, });
  @override
  int get crc => 0xa731e257;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (pinned == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
  }
}

class MessagesReorderPinnedDialogsRequest extends TlObject {
  final bool force;
  final int folderId;
  final List<InputDialogPeer> order;
  MessagesReorderPinnedDialogsRequest({this.force = false, required this.folderId, required this.order, });
  @override
  int get crc => 0x3b1adf37;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (force == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    e.writeInt32(folderId);
    e.writeCrc(0x1cb5c415); e.writeInt32(order.length); for (final item in order) { item.encode(e); }
  }
}

class MessagesGetPinnedDialogsRequest extends TlObject {
  final int folderId;
  MessagesGetPinnedDialogsRequest({required this.folderId, });
  @override
  int get crc => 0xd6b94df2;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(folderId);
  }
}

class MessagesSetBotShippingResultsRequest extends TlObject {
  final int queryId;
  final String? error;
  final List<ShippingOption>? shippingOptions;
  MessagesSetBotShippingResultsRequest({required this.queryId, this.error, this.shippingOptions, });
  @override
  int get crc => 0xe5f672fa;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (error != null ? (1 << 0) : 0) | (shippingOptions != null ? (1 << 1) : 0);
    e.writeUint32(flags);
    e.writeInt64(queryId);
    if (error != null) { e.writeString(error!); }
    if (shippingOptions != null) { e.writeCrc(0x1cb5c415); e.writeInt32(shippingOptions!.length); for (final item in shippingOptions!) { item.encode(e); } }
  }
}

class MessagesSetBotPrecheckoutResultsRequest extends TlObject {
  final bool success;
  final int queryId;
  final String? error;
  MessagesSetBotPrecheckoutResultsRequest({this.success = false, required this.queryId, this.error, });
  @override
  int get crc => 0x9c2dd95;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (success == true ? (1 << 1) : 0) | (error != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    e.writeInt64(queryId);
    if (error != null) { e.writeString(error!); }
  }
}

class MessagesUploadMediaRequest extends TlObject {
  final String? businessConnectionId;
  final InputPeer peer;
  final InputMedia media;
  MessagesUploadMediaRequest({this.businessConnectionId, required this.peer, required this.media, });
  @override
  int get crc => 0x14967978;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (businessConnectionId != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    if (businessConnectionId != null) { e.writeString(businessConnectionId!); }
    peer.encode(e);
    media.encode(e);
  }
}

class MessagesSendScreenshotNotificationRequest extends TlObject {
  final InputPeer peer;
  final InputReplyTo replyTo;
  final int randomId;
  MessagesSendScreenshotNotificationRequest({required this.peer, required this.replyTo, required this.randomId, });
  @override
  int get crc => 0xa1405817;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    replyTo.encode(e);
    e.writeInt64(randomId);
  }
}

class MessagesGetFavedStickersRequest extends TlObject {
  final int hash;
  MessagesGetFavedStickersRequest({required this.hash, });
  @override
  int get crc => 0x4f1aaa9;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(hash);
  }
}

class MessagesFaveStickerRequest extends TlObject {
  final InputDocument id;
  final bool unfave;
  MessagesFaveStickerRequest({required this.id, required this.unfave, });
  @override
  int get crc => 0xb9ffc55b;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    id.encode(e);
    e.writeBool(unfave);
  }
}

class MessagesGetUnreadMentionsRequest extends TlObject {
  final InputPeer peer;
  final int? topMsgId;
  final int offsetId;
  final int addOffset;
  final int limit;
  final int maxId;
  final int minId;
  MessagesGetUnreadMentionsRequest({required this.peer, this.topMsgId, required this.offsetId, required this.addOffset, required this.limit, required this.maxId, required this.minId, });
  @override
  int get crc => 0xf107e790;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (topMsgId != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    if (topMsgId != null) { e.writeInt32(topMsgId!); }
    e.writeInt32(offsetId);
    e.writeInt32(addOffset);
    e.writeInt32(limit);
    e.writeInt32(maxId);
    e.writeInt32(minId);
  }
}

class MessagesReadMentionsRequest extends TlObject {
  final InputPeer peer;
  final int? topMsgId;
  MessagesReadMentionsRequest({required this.peer, this.topMsgId, });
  @override
  int get crc => 0x36e5bf4d;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (topMsgId != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    if (topMsgId != null) { e.writeInt32(topMsgId!); }
  }
}

class MessagesGetRecentLocationsRequest extends TlObject {
  final InputPeer peer;
  final int limit;
  final int hash;
  MessagesGetRecentLocationsRequest({required this.peer, required this.limit, required this.hash, });
  @override
  int get crc => 0x702a40e0;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(limit);
    e.writeInt64(hash);
  }
}

class MessagesSendMultiMediaRequest extends TlObject {
  final bool silent;
  final bool background;
  final bool clearDraft;
  final bool noforwards;
  final bool updateStickersetsOrder;
  final bool invertMedia;
  final bool allowPaidFloodskip;
  final InputPeer peer;
  final InputReplyTo? replyTo;
  final List<InputSingleMedia> multiMedia;
  final int? scheduleDate;
  final InputPeer? sendAs;
  final InputQuickReplyShortcut? quickReplyShortcut;
  final int? effect;
  final int? allowPaidStars;
  MessagesSendMultiMediaRequest({this.silent = false, this.background = false, this.clearDraft = false, this.noforwards = false, this.updateStickersetsOrder = false, this.invertMedia = false, this.allowPaidFloodskip = false, required this.peer, this.replyTo, required this.multiMedia, this.scheduleDate, this.sendAs, this.quickReplyShortcut, this.effect, this.allowPaidStars, });
  @override
  int get crc => 0x1bf89d74;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (silent == true ? (1 << 5) : 0) | (background == true ? (1 << 6) : 0) | (clearDraft == true ? (1 << 7) : 0) | (noforwards == true ? (1 << 14) : 0) | (updateStickersetsOrder == true ? (1 << 15) : 0) | (invertMedia == true ? (1 << 16) : 0) | (allowPaidFloodskip == true ? (1 << 19) : 0) | (replyTo != null ? (1 << 0) : 0) | (scheduleDate != null ? (1 << 10) : 0) | (sendAs != null ? (1 << 13) : 0) | (quickReplyShortcut != null ? (1 << 17) : 0) | (effect != null ? (1 << 18) : 0) | (allowPaidStars != null ? (1 << 21) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    if (replyTo != null) { replyTo!.encode(e); }
    e.writeCrc(0x1cb5c415); e.writeInt32(multiMedia.length); for (final item in multiMedia) { item.encode(e); }
    if (scheduleDate != null) { e.writeInt32(scheduleDate!); }
    if (sendAs != null) { sendAs!.encode(e); }
    if (quickReplyShortcut != null) { quickReplyShortcut!.encode(e); }
    if (effect != null) { e.writeInt64(effect!); }
    if (allowPaidStars != null) { e.writeInt64(allowPaidStars!); }
  }
}

class MessagesUploadEncryptedFileRequest extends TlObject {
  final InputEncryptedChat peer;
  final InputEncryptedFile file;
  MessagesUploadEncryptedFileRequest({required this.peer, required this.file, });
  @override
  int get crc => 0x5057c497;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    file.encode(e);
  }
}

class MessagesSearchStickerSetsRequest extends TlObject {
  final bool excludeFeatured;
  final String q;
  final int hash;
  MessagesSearchStickerSetsRequest({this.excludeFeatured = false, required this.q, required this.hash, });
  @override
  int get crc => 0x35705b8a;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (excludeFeatured == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    e.writeString(q);
    e.writeInt64(hash);
  }
}

class MessagesGetSplitRangesRequest extends TlObject {
  MessagesGetSplitRangesRequest();
  @override
  int get crc => 0x1cff7e08;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class MessagesMarkDialogUnreadRequest extends TlObject {
  final bool unread;
  final InputPeer? parentPeer;
  final InputDialogPeer peer;
  MessagesMarkDialogUnreadRequest({this.unread = false, this.parentPeer, required this.peer, });
  @override
  int get crc => 0x8c5006f8;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (unread == true ? (1 << 0) : 0) | (parentPeer != null ? (1 << 1) : 0);
    e.writeUint32(flags);
    if (parentPeer != null) { parentPeer!.encode(e); }
    peer.encode(e);
  }
}

class MessagesGetDialogUnreadMarksRequest extends TlObject {
  final InputPeer? parentPeer;
  MessagesGetDialogUnreadMarksRequest({this.parentPeer, });
  @override
  int get crc => 0x21202222;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (parentPeer != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    if (parentPeer != null) { parentPeer!.encode(e); }
  }
}

class MessagesClearAllDraftsRequest extends TlObject {
  MessagesClearAllDraftsRequest();
  @override
  int get crc => 0x7e58ee9c;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class MessagesUpdatePinnedMessageRequest extends TlObject {
  final bool silent;
  final bool unpin;
  final bool pmOneside;
  final InputPeer peer;
  final int id;
  MessagesUpdatePinnedMessageRequest({this.silent = false, this.unpin = false, this.pmOneside = false, required this.peer, required this.id, });
  @override
  int get crc => 0xd2aaf7ec;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (silent == true ? (1 << 0) : 0) | (unpin == true ? (1 << 1) : 0) | (pmOneside == true ? (1 << 2) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeInt32(id);
  }
}

class MessagesSendVoteRequest extends TlObject {
  final InputPeer peer;
  final int msgId;
  final List<Uint8List> options;
  MessagesSendVoteRequest({required this.peer, required this.msgId, required this.options, });
  @override
  int get crc => 0x10ea6184;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(msgId);
    e.writeCrc(0x1cb5c415); e.writeInt32(options.length); for (final item in options) { e.writeBytes(item); }
  }
}

class MessagesGetPollResultsRequest extends TlObject {
  final InputPeer peer;
  final int msgId;
  final int pollHash;
  MessagesGetPollResultsRequest({required this.peer, required this.msgId, required this.pollHash, });
  @override
  int get crc => 0xeda3e33b;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(msgId);
    e.writeInt64(pollHash);
  }
}

class MessagesGetOnlinesRequest extends TlObject {
  final InputPeer peer;
  MessagesGetOnlinesRequest({required this.peer, });
  @override
  int get crc => 0x6e2be050;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
  }
}

class MessagesEditChatAboutRequest extends TlObject {
  final InputPeer peer;
  final String about;
  MessagesEditChatAboutRequest({required this.peer, required this.about, });
  @override
  int get crc => 0xdef60797;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeString(about);
  }
}

class MessagesEditChatDefaultBannedRightsRequest extends TlObject {
  final InputPeer peer;
  final ChatBannedRights bannedRights;
  MessagesEditChatDefaultBannedRightsRequest({required this.peer, required this.bannedRights, });
  @override
  int get crc => 0xa5866b41;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    bannedRights.encode(e);
  }
}

class MessagesGetEmojiKeywordsRequest extends TlObject {
  final String langCode;
  MessagesGetEmojiKeywordsRequest({required this.langCode, });
  @override
  int get crc => 0x35a0e062;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(langCode);
  }
}

class MessagesGetEmojiKeywordsDifferenceRequest extends TlObject {
  final String langCode;
  final int fromVersion;
  MessagesGetEmojiKeywordsDifferenceRequest({required this.langCode, required this.fromVersion, });
  @override
  int get crc => 0x1508b6af;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(langCode);
    e.writeInt32(fromVersion);
  }
}

class MessagesGetEmojiKeywordsLanguagesRequest extends TlObject {
  final List<String> langCodes;
  MessagesGetEmojiKeywordsLanguagesRequest({required this.langCodes, });
  @override
  int get crc => 0x4e9963b2;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeCrc(0x1cb5c415); e.writeInt32(langCodes.length); for (final item in langCodes) { e.writeString(item); }
  }
}

class MessagesGetEmojiURLRequest extends TlObject {
  final String langCode;
  MessagesGetEmojiURLRequest({required this.langCode, });
  @override
  int get crc => 0xd5b10c26;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(langCode);
  }
}

class MessagesGetSearchCountersRequest extends TlObject {
  final InputPeer peer;
  final InputPeer? savedPeerId;
  final int? topMsgId;
  final List<MessagesFilter> filters;
  MessagesGetSearchCountersRequest({required this.peer, this.savedPeerId, this.topMsgId, required this.filters, });
  @override
  int get crc => 0x1bbcf300;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (savedPeerId != null ? (1 << 2) : 0) | (topMsgId != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    if (savedPeerId != null) { savedPeerId!.encode(e); }
    if (topMsgId != null) { e.writeInt32(topMsgId!); }
    e.writeCrc(0x1cb5c415); e.writeInt32(filters.length); for (final item in filters) { item.encode(e); }
  }
}

class MessagesRequestUrlAuthRequest extends TlObject {
  final InputPeer? peer;
  final int? msgId;
  final int? buttonId;
  final String? url;
  final String? inAppOrigin;
  MessagesRequestUrlAuthRequest({this.peer, this.msgId, this.buttonId, this.url, this.inAppOrigin, });
  @override
  int get crc => 0x894cc99c;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (peer != null ? (1 << 1) : 0) | (msgId != null ? (1 << 1) : 0) | (buttonId != null ? (1 << 1) : 0) | (url != null ? (1 << 2) : 0) | (inAppOrigin != null ? (1 << 3) : 0);
    e.writeUint32(flags);
    if (peer != null) { peer!.encode(e); }
    if (msgId != null) { e.writeInt32(msgId!); }
    if (buttonId != null) { e.writeInt32(buttonId!); }
    if (url != null) { e.writeString(url!); }
    if (inAppOrigin != null) { e.writeString(inAppOrigin!); }
  }
}

class MessagesAcceptUrlAuthRequest extends TlObject {
  final bool writeAllowed;
  final bool sharePhoneNumber;
  final InputPeer? peer;
  final int? msgId;
  final int? buttonId;
  final String? url;
  final String? matchCode;
  MessagesAcceptUrlAuthRequest({this.writeAllowed = false, this.sharePhoneNumber = false, this.peer, this.msgId, this.buttonId, this.url, this.matchCode, });
  @override
  int get crc => 0x67a3f0de;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (writeAllowed == true ? (1 << 0) : 0) | (sharePhoneNumber == true ? (1 << 3) : 0) | (peer != null ? (1 << 1) : 0) | (msgId != null ? (1 << 1) : 0) | (buttonId != null ? (1 << 1) : 0) | (url != null ? (1 << 2) : 0) | (matchCode != null ? (1 << 4) : 0);
    e.writeUint32(flags);
    if (peer != null) { peer!.encode(e); }
    if (msgId != null) { e.writeInt32(msgId!); }
    if (buttonId != null) { e.writeInt32(buttonId!); }
    if (url != null) { e.writeString(url!); }
    if (matchCode != null) { e.writeString(matchCode!); }
  }
}

class MessagesHidePeerSettingsBarRequest extends TlObject {
  final InputPeer peer;
  MessagesHidePeerSettingsBarRequest({required this.peer, });
  @override
  int get crc => 0x4facb138;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
  }
}

class MessagesGetScheduledHistoryRequest extends TlObject {
  final InputPeer peer;
  final int hash;
  MessagesGetScheduledHistoryRequest({required this.peer, required this.hash, });
  @override
  int get crc => 0xf516760b;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt64(hash);
  }
}

class MessagesGetScheduledMessagesRequest extends TlObject {
  final InputPeer peer;
  final List<int> id;
  MessagesGetScheduledMessagesRequest({required this.peer, required this.id, });
  @override
  int get crc => 0xbdbb0464;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { e.writeInt32(item); }
  }
}

class MessagesSendScheduledMessagesRequest extends TlObject {
  final InputPeer peer;
  final List<int> id;
  MessagesSendScheduledMessagesRequest({required this.peer, required this.id, });
  @override
  int get crc => 0xbd38850a;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { e.writeInt32(item); }
  }
}

class MessagesDeleteScheduledMessagesRequest extends TlObject {
  final InputPeer peer;
  final List<int> id;
  MessagesDeleteScheduledMessagesRequest({required this.peer, required this.id, });
  @override
  int get crc => 0x59ae2b16;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { e.writeInt32(item); }
  }
}

class MessagesGetPollVotesRequest extends TlObject {
  final InputPeer peer;
  final int id;
  final Uint8List? option;
  final String? offset;
  final int limit;
  MessagesGetPollVotesRequest({required this.peer, required this.id, this.option, this.offset, required this.limit, });
  @override
  int get crc => 0xb86e380e;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (option != null ? (1 << 0) : 0) | (offset != null ? (1 << 1) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeInt32(id);
    if (option != null) { e.writeBytes(option!); }
    if (offset != null) { e.writeString(offset!); }
    e.writeInt32(limit);
  }
}

class MessagesToggleStickerSetsRequest extends TlObject {
  final bool uninstall;
  final bool archive;
  final bool unarchive;
  final List<InputStickerSet> stickersets;
  MessagesToggleStickerSetsRequest({this.uninstall = false, this.archive = false, this.unarchive = false, required this.stickersets, });
  @override
  int get crc => 0xb5052fea;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (uninstall == true ? (1 << 0) : 0) | (archive == true ? (1 << 1) : 0) | (unarchive == true ? (1 << 2) : 0);
    e.writeUint32(flags);
    e.writeCrc(0x1cb5c415); e.writeInt32(stickersets.length); for (final item in stickersets) { item.encode(e); }
  }
}

class MessagesGetDialogFiltersRequest extends TlObject {
  MessagesGetDialogFiltersRequest();
  @override
  int get crc => 0xefd48c89;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class MessagesGetSuggestedDialogFiltersRequest extends TlObject {
  MessagesGetSuggestedDialogFiltersRequest();
  @override
  int get crc => 0xa29cd42c;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class MessagesUpdateDialogFilterRequest extends TlObject {
  final int id;
  final DialogFilter? filter;
  MessagesUpdateDialogFilterRequest({required this.id, this.filter, });
  @override
  int get crc => 0x1ad4a04a;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (filter != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    e.writeInt32(id);
    if (filter != null) { filter!.encode(e); }
  }
}

class MessagesUpdateDialogFiltersOrderRequest extends TlObject {
  final List<int> order;
  MessagesUpdateDialogFiltersOrderRequest({required this.order, });
  @override
  int get crc => 0xc563c1e4;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeCrc(0x1cb5c415); e.writeInt32(order.length); for (final item in order) { e.writeInt32(item); }
  }
}

class MessagesGetOldFeaturedStickersRequest extends TlObject {
  final int offset;
  final int limit;
  final int hash;
  MessagesGetOldFeaturedStickersRequest({required this.offset, required this.limit, required this.hash, });
  @override
  int get crc => 0x7ed094a1;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(offset);
    e.writeInt32(limit);
    e.writeInt64(hash);
  }
}

class MessagesGetRepliesRequest extends TlObject {
  final InputPeer peer;
  final int msgId;
  final int offsetId;
  final int offsetDate;
  final int addOffset;
  final int limit;
  final int maxId;
  final int minId;
  final int hash;
  MessagesGetRepliesRequest({required this.peer, required this.msgId, required this.offsetId, required this.offsetDate, required this.addOffset, required this.limit, required this.maxId, required this.minId, required this.hash, });
  @override
  int get crc => 0x22ddd30c;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(msgId);
    e.writeInt32(offsetId);
    e.writeInt32(offsetDate);
    e.writeInt32(addOffset);
    e.writeInt32(limit);
    e.writeInt32(maxId);
    e.writeInt32(minId);
    e.writeInt64(hash);
  }
}

class MessagesGetDiscussionMessageRequest extends TlObject {
  final InputPeer peer;
  final int msgId;
  MessagesGetDiscussionMessageRequest({required this.peer, required this.msgId, });
  @override
  int get crc => 0x446972fd;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(msgId);
  }
}

class MessagesReadDiscussionRequest extends TlObject {
  final InputPeer peer;
  final int msgId;
  final int readMaxId;
  MessagesReadDiscussionRequest({required this.peer, required this.msgId, required this.readMaxId, });
  @override
  int get crc => 0xf731a9f4;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(msgId);
    e.writeInt32(readMaxId);
  }
}

class MessagesUnpinAllMessagesRequest extends TlObject {
  final InputPeer peer;
  final int? topMsgId;
  final InputPeer? savedPeerId;
  MessagesUnpinAllMessagesRequest({required this.peer, this.topMsgId, this.savedPeerId, });
  @override
  int get crc => 0x62dd747;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (topMsgId != null ? (1 << 0) : 0) | (savedPeerId != null ? (1 << 1) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    if (topMsgId != null) { e.writeInt32(topMsgId!); }
    if (savedPeerId != null) { savedPeerId!.encode(e); }
  }
}

class MessagesDeleteChatRequest extends TlObject {
  final int chatId;
  MessagesDeleteChatRequest({required this.chatId, });
  @override
  int get crc => 0x5bd0ee50;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(chatId);
  }
}

class MessagesDeletePhoneCallHistoryRequest extends TlObject {
  final bool revoke;
  MessagesDeletePhoneCallHistoryRequest({this.revoke = false, });
  @override
  int get crc => 0xf9cbe409;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (revoke == true ? (1 << 0) : 0);
    e.writeUint32(flags);
  }
}

class MessagesCheckHistoryImportRequest extends TlObject {
  final String importHead;
  MessagesCheckHistoryImportRequest({required this.importHead, });
  @override
  int get crc => 0x43fe19f3;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(importHead);
  }
}

class MessagesInitHistoryImportRequest extends TlObject {
  final InputPeer peer;
  final InputFile file;
  final int mediaCount;
  MessagesInitHistoryImportRequest({required this.peer, required this.file, required this.mediaCount, });
  @override
  int get crc => 0x34090c3b;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    file.encode(e);
    e.writeInt32(mediaCount);
  }
}

class MessagesUploadImportedMediaRequest extends TlObject {
  final InputPeer peer;
  final int importId;
  final String fileName;
  final InputMedia media;
  MessagesUploadImportedMediaRequest({required this.peer, required this.importId, required this.fileName, required this.media, });
  @override
  int get crc => 0x2a862092;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt64(importId);
    e.writeString(fileName);
    media.encode(e);
  }
}

class MessagesStartHistoryImportRequest extends TlObject {
  final InputPeer peer;
  final int importId;
  MessagesStartHistoryImportRequest({required this.peer, required this.importId, });
  @override
  int get crc => 0xb43df344;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt64(importId);
  }
}

class MessagesGetExportedChatInvitesRequest extends TlObject {
  final bool revoked;
  final InputPeer peer;
  final InputUser adminId;
  final int? offsetDate;
  final String? offsetLink;
  final int limit;
  MessagesGetExportedChatInvitesRequest({this.revoked = false, required this.peer, required this.adminId, this.offsetDate, this.offsetLink, required this.limit, });
  @override
  int get crc => 0xa2b5a3f6;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (revoked == true ? (1 << 3) : 0) | (offsetDate != null ? (1 << 2) : 0) | (offsetLink != null ? (1 << 2) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    adminId.encode(e);
    if (offsetDate != null) { e.writeInt32(offsetDate!); }
    if (offsetLink != null) { e.writeString(offsetLink!); }
    e.writeInt32(limit);
  }
}

class MessagesGetExportedChatInviteRequest extends TlObject {
  final InputPeer peer;
  final String link;
  MessagesGetExportedChatInviteRequest({required this.peer, required this.link, });
  @override
  int get crc => 0x73746f5c;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeString(link);
  }
}

class MessagesEditExportedChatInviteRequest extends TlObject {
  final bool revoked;
  final InputPeer peer;
  final String link;
  final int? expireDate;
  final int? usageLimit;
  final bool? requestNeeded;
  final String? title;
  MessagesEditExportedChatInviteRequest({this.revoked = false, required this.peer, required this.link, this.expireDate, this.usageLimit, this.requestNeeded, this.title, });
  @override
  int get crc => 0xbdca2f75;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (revoked == true ? (1 << 2) : 0) | (expireDate != null ? (1 << 0) : 0) | (usageLimit != null ? (1 << 1) : 0) | (requestNeeded != null ? (1 << 3) : 0) | (title != null ? (1 << 4) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeString(link);
    if (expireDate != null) { e.writeInt32(expireDate!); }
    if (usageLimit != null) { e.writeInt32(usageLimit!); }
    if (requestNeeded != null) { e.writeBool(requestNeeded!); }
    if (title != null) { e.writeString(title!); }
  }
}

class MessagesDeleteRevokedExportedChatInvitesRequest extends TlObject {
  final InputPeer peer;
  final InputUser adminId;
  MessagesDeleteRevokedExportedChatInvitesRequest({required this.peer, required this.adminId, });
  @override
  int get crc => 0x56987bd5;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    adminId.encode(e);
  }
}

class MessagesDeleteExportedChatInviteRequest extends TlObject {
  final InputPeer peer;
  final String link;
  MessagesDeleteExportedChatInviteRequest({required this.peer, required this.link, });
  @override
  int get crc => 0xd464a42b;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeString(link);
  }
}

class MessagesGetAdminsWithInvitesRequest extends TlObject {
  final InputPeer peer;
  MessagesGetAdminsWithInvitesRequest({required this.peer, });
  @override
  int get crc => 0x3920e6ef;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
  }
}

class MessagesGetChatInviteImportersRequest extends TlObject {
  final bool requested;
  final bool subscriptionExpired;
  final InputPeer peer;
  final String? link;
  final String? q;
  final int offsetDate;
  final InputUser offsetUser;
  final int limit;
  MessagesGetChatInviteImportersRequest({this.requested = false, this.subscriptionExpired = false, required this.peer, this.link, this.q, required this.offsetDate, required this.offsetUser, required this.limit, });
  @override
  int get crc => 0xdf04dd4e;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (requested == true ? (1 << 0) : 0) | (subscriptionExpired == true ? (1 << 3) : 0) | (link != null ? (1 << 1) : 0) | (q != null ? (1 << 2) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    if (link != null) { e.writeString(link!); }
    if (q != null) { e.writeString(q!); }
    e.writeInt32(offsetDate);
    offsetUser.encode(e);
    e.writeInt32(limit);
  }
}

class MessagesSetHistoryTTLRequest extends TlObject {
  final InputPeer peer;
  final int period;
  MessagesSetHistoryTTLRequest({required this.peer, required this.period, });
  @override
  int get crc => 0xb80e5fe4;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(period);
  }
}

class MessagesCheckHistoryImportPeerRequest extends TlObject {
  final InputPeer peer;
  MessagesCheckHistoryImportPeerRequest({required this.peer, });
  @override
  int get crc => 0x5dc60f03;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
  }
}

class MessagesSetChatThemeRequest extends TlObject {
  final InputPeer peer;
  final InputChatTheme theme;
  MessagesSetChatThemeRequest({required this.peer, required this.theme, });
  @override
  int get crc => 0x81202c9;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    theme.encode(e);
  }
}

class MessagesGetMessageReadParticipantsRequest extends TlObject {
  final InputPeer peer;
  final int msgId;
  MessagesGetMessageReadParticipantsRequest({required this.peer, required this.msgId, });
  @override
  int get crc => 0x31c1c44f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(msgId);
  }
}

class MessagesGetSearchResultsCalendarRequest extends TlObject {
  final InputPeer peer;
  final InputPeer? savedPeerId;
  final MessagesFilter filter;
  final int offsetId;
  final int offsetDate;
  MessagesGetSearchResultsCalendarRequest({required this.peer, this.savedPeerId, required this.filter, required this.offsetId, required this.offsetDate, });
  @override
  int get crc => 0x6aa3f6bd;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (savedPeerId != null ? (1 << 2) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    if (savedPeerId != null) { savedPeerId!.encode(e); }
    filter.encode(e);
    e.writeInt32(offsetId);
    e.writeInt32(offsetDate);
  }
}

class MessagesGetSearchResultsPositionsRequest extends TlObject {
  final InputPeer peer;
  final InputPeer? savedPeerId;
  final MessagesFilter filter;
  final int offsetId;
  final int limit;
  MessagesGetSearchResultsPositionsRequest({required this.peer, this.savedPeerId, required this.filter, required this.offsetId, required this.limit, });
  @override
  int get crc => 0x9c7f2f10;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (savedPeerId != null ? (1 << 2) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    if (savedPeerId != null) { savedPeerId!.encode(e); }
    filter.encode(e);
    e.writeInt32(offsetId);
    e.writeInt32(limit);
  }
}

class MessagesHideChatJoinRequestRequest extends TlObject {
  final bool approved;
  final InputPeer peer;
  final InputUser userId;
  MessagesHideChatJoinRequestRequest({this.approved = false, required this.peer, required this.userId, });
  @override
  int get crc => 0x7fe7e815;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (approved == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    userId.encode(e);
  }
}

class MessagesHideAllChatJoinRequestsRequest extends TlObject {
  final bool approved;
  final InputPeer peer;
  final String? link;
  MessagesHideAllChatJoinRequestsRequest({this.approved = false, required this.peer, this.link, });
  @override
  int get crc => 0xe085f4ea;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (approved == true ? (1 << 0) : 0) | (link != null ? (1 << 1) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    if (link != null) { e.writeString(link!); }
  }
}

class MessagesToggleNoForwardsRequest extends TlObject {
  final InputPeer peer;
  final bool enabled;
  final int? requestMsgId;
  MessagesToggleNoForwardsRequest({required this.peer, required this.enabled, this.requestMsgId, });
  @override
  int get crc => 0xb2081a35;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (requestMsgId != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeBool(enabled);
    if (requestMsgId != null) { e.writeInt32(requestMsgId!); }
  }
}

class MessagesSaveDefaultSendAsRequest extends TlObject {
  final InputPeer peer;
  final InputPeer sendAs;
  MessagesSaveDefaultSendAsRequest({required this.peer, required this.sendAs, });
  @override
  int get crc => 0xccfddf96;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    sendAs.encode(e);
  }
}

class MessagesSendReactionRequest extends TlObject {
  final bool big;
  final bool addToRecent;
  final InputPeer peer;
  final int msgId;
  final List<Reaction>? reaction;
  MessagesSendReactionRequest({this.big = false, this.addToRecent = false, required this.peer, required this.msgId, this.reaction, });
  @override
  int get crc => 0xd30d78d4;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (big == true ? (1 << 1) : 0) | (addToRecent == true ? (1 << 2) : 0) | (reaction != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeInt32(msgId);
    if (reaction != null) { e.writeCrc(0x1cb5c415); e.writeInt32(reaction!.length); for (final item in reaction!) { item.encode(e); } }
  }
}

class MessagesGetMessagesReactionsRequest extends TlObject {
  final InputPeer peer;
  final List<int> id;
  MessagesGetMessagesReactionsRequest({required this.peer, required this.id, });
  @override
  int get crc => 0x8bba90e6;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { e.writeInt32(item); }
  }
}

class MessagesGetMessageReactionsListRequest extends TlObject {
  final InputPeer peer;
  final int id;
  final Reaction? reaction;
  final String? offset;
  final int limit;
  MessagesGetMessageReactionsListRequest({required this.peer, required this.id, this.reaction, this.offset, required this.limit, });
  @override
  int get crc => 0x461b3f48;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (reaction != null ? (1 << 0) : 0) | (offset != null ? (1 << 1) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeInt32(id);
    if (reaction != null) { reaction!.encode(e); }
    if (offset != null) { e.writeString(offset!); }
    e.writeInt32(limit);
  }
}

class MessagesSetChatAvailableReactionsRequest extends TlObject {
  final InputPeer peer;
  final ChatReactions availableReactions;
  final int? reactionsLimit;
  final bool? paidEnabled;
  MessagesSetChatAvailableReactionsRequest({required this.peer, required this.availableReactions, this.reactionsLimit, this.paidEnabled, });
  @override
  int get crc => 0x864b2581;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (reactionsLimit != null ? (1 << 0) : 0) | (paidEnabled != null ? (1 << 1) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    availableReactions.encode(e);
    if (reactionsLimit != null) { e.writeInt32(reactionsLimit!); }
    if (paidEnabled != null) { e.writeBool(paidEnabled!); }
  }
}

class MessagesGetAvailableReactionsRequest extends TlObject {
  final int hash;
  MessagesGetAvailableReactionsRequest({required this.hash, });
  @override
  int get crc => 0x18dea0ac;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(hash);
  }
}

class MessagesSetDefaultReactionRequest extends TlObject {
  final Reaction reaction;
  MessagesSetDefaultReactionRequest({required this.reaction, });
  @override
  int get crc => 0x4f47a016;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    reaction.encode(e);
  }
}

class MessagesTranslateTextRequest extends TlObject {
  final InputPeer? peer;
  final List<int>? id;
  final List<TextWithEntities>? text;
  final String toLang;
  final String? tone;
  MessagesTranslateTextRequest({this.peer, this.id, this.text, required this.toLang, this.tone, });
  @override
  int get crc => 0xa5eec345;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (peer != null ? (1 << 0) : 0) | (id != null ? (1 << 0) : 0) | (text != null ? (1 << 1) : 0) | (tone != null ? (1 << 2) : 0);
    e.writeUint32(flags);
    if (peer != null) { peer!.encode(e); }
    if (id != null) { e.writeCrc(0x1cb5c415); e.writeInt32(id!.length); for (final item in id!) { e.writeInt32(item); } }
    if (text != null) { e.writeCrc(0x1cb5c415); e.writeInt32(text!.length); for (final item in text!) { item.encode(e); } }
    e.writeString(toLang);
    if (tone != null) { e.writeString(tone!); }
  }
}

class MessagesGetUnreadReactionsRequest extends TlObject {
  final InputPeer peer;
  final int? topMsgId;
  final InputPeer? savedPeerId;
  final int offsetId;
  final int addOffset;
  final int limit;
  final int maxId;
  final int minId;
  MessagesGetUnreadReactionsRequest({required this.peer, this.topMsgId, this.savedPeerId, required this.offsetId, required this.addOffset, required this.limit, required this.maxId, required this.minId, });
  @override
  int get crc => 0xbd7f90ac;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (topMsgId != null ? (1 << 0) : 0) | (savedPeerId != null ? (1 << 1) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    if (topMsgId != null) { e.writeInt32(topMsgId!); }
    if (savedPeerId != null) { savedPeerId!.encode(e); }
    e.writeInt32(offsetId);
    e.writeInt32(addOffset);
    e.writeInt32(limit);
    e.writeInt32(maxId);
    e.writeInt32(minId);
  }
}

class MessagesReadReactionsRequest extends TlObject {
  final InputPeer peer;
  final int? topMsgId;
  final InputPeer? savedPeerId;
  MessagesReadReactionsRequest({required this.peer, this.topMsgId, this.savedPeerId, });
  @override
  int get crc => 0x9ec44f93;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (topMsgId != null ? (1 << 0) : 0) | (savedPeerId != null ? (1 << 1) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    if (topMsgId != null) { e.writeInt32(topMsgId!); }
    if (savedPeerId != null) { savedPeerId!.encode(e); }
  }
}

class MessagesSearchSentMediaRequest extends TlObject {
  final String q;
  final MessagesFilter filter;
  final int limit;
  MessagesSearchSentMediaRequest({required this.q, required this.filter, required this.limit, });
  @override
  int get crc => 0x107e31a0;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(q);
    filter.encode(e);
    e.writeInt32(limit);
  }
}

class MessagesGetAttachMenuBotsRequest extends TlObject {
  final int hash;
  MessagesGetAttachMenuBotsRequest({required this.hash, });
  @override
  int get crc => 0x16fcc2cb;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(hash);
  }
}

class MessagesGetAttachMenuBotRequest extends TlObject {
  final InputUser bot;
  MessagesGetAttachMenuBotRequest({required this.bot, });
  @override
  int get crc => 0x77216192;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    bot.encode(e);
  }
}

class MessagesToggleBotInAttachMenuRequest extends TlObject {
  final bool writeAllowed;
  final InputUser bot;
  final bool enabled;
  MessagesToggleBotInAttachMenuRequest({this.writeAllowed = false, required this.bot, required this.enabled, });
  @override
  int get crc => 0x69f59d69;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (writeAllowed == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    bot.encode(e);
    e.writeBool(enabled);
  }
}

class MessagesRequestWebViewRequest extends TlObject {
  final bool fromBotMenu;
  final bool silent;
  final bool compact;
  final bool fullscreen;
  final InputPeer peer;
  final InputUser bot;
  final String? url;
  final String? startParam;
  final DataJSON? themeParams;
  final String platform;
  final InputReplyTo? replyTo;
  final InputPeer? sendAs;
  MessagesRequestWebViewRequest({this.fromBotMenu = false, this.silent = false, this.compact = false, this.fullscreen = false, required this.peer, required this.bot, this.url, this.startParam, this.themeParams, required this.platform, this.replyTo, this.sendAs, });
  @override
  int get crc => 0x269dc2c1;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (fromBotMenu == true ? (1 << 4) : 0) | (silent == true ? (1 << 5) : 0) | (compact == true ? (1 << 7) : 0) | (fullscreen == true ? (1 << 8) : 0) | (url != null ? (1 << 1) : 0) | (startParam != null ? (1 << 3) : 0) | (themeParams != null ? (1 << 2) : 0) | (replyTo != null ? (1 << 0) : 0) | (sendAs != null ? (1 << 13) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    bot.encode(e);
    if (url != null) { e.writeString(url!); }
    if (startParam != null) { e.writeString(startParam!); }
    if (themeParams != null) { themeParams!.encode(e); }
    e.writeString(platform);
    if (replyTo != null) { replyTo!.encode(e); }
    if (sendAs != null) { sendAs!.encode(e); }
  }
}

class MessagesProlongWebViewRequest extends TlObject {
  final bool silent;
  final InputPeer peer;
  final InputUser bot;
  final int queryId;
  final InputReplyTo? replyTo;
  final InputPeer? sendAs;
  MessagesProlongWebViewRequest({this.silent = false, required this.peer, required this.bot, required this.queryId, this.replyTo, this.sendAs, });
  @override
  int get crc => 0xb0d81a83;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (silent == true ? (1 << 5) : 0) | (replyTo != null ? (1 << 0) : 0) | (sendAs != null ? (1 << 13) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    bot.encode(e);
    e.writeInt64(queryId);
    if (replyTo != null) { replyTo!.encode(e); }
    if (sendAs != null) { sendAs!.encode(e); }
  }
}

class MessagesRequestSimpleWebViewRequest extends TlObject {
  final bool fromSwitchWebview;
  final bool fromSideMenu;
  final bool compact;
  final bool fullscreen;
  final InputUser bot;
  final String? url;
  final String? startParam;
  final DataJSON? themeParams;
  final String platform;
  MessagesRequestSimpleWebViewRequest({this.fromSwitchWebview = false, this.fromSideMenu = false, this.compact = false, this.fullscreen = false, required this.bot, this.url, this.startParam, this.themeParams, required this.platform, });
  @override
  int get crc => 0x413a3e73;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (fromSwitchWebview == true ? (1 << 1) : 0) | (fromSideMenu == true ? (1 << 2) : 0) | (compact == true ? (1 << 7) : 0) | (fullscreen == true ? (1 << 8) : 0) | (url != null ? (1 << 3) : 0) | (startParam != null ? (1 << 4) : 0) | (themeParams != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    bot.encode(e);
    if (url != null) { e.writeString(url!); }
    if (startParam != null) { e.writeString(startParam!); }
    if (themeParams != null) { themeParams!.encode(e); }
    e.writeString(platform);
  }
}

class MessagesSendWebViewResultMessageRequest extends TlObject {
  final String botQueryId;
  final InputBotInlineResult result;
  MessagesSendWebViewResultMessageRequest({required this.botQueryId, required this.result, });
  @override
  int get crc => 0xa4314f5;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(botQueryId);
    result.encode(e);
  }
}

class MessagesSendWebViewDataRequest extends TlObject {
  final InputUser bot;
  final int randomId;
  final String buttonText;
  final String data;
  MessagesSendWebViewDataRequest({required this.bot, required this.randomId, required this.buttonText, required this.data, });
  @override
  int get crc => 0xdc0242c8;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    bot.encode(e);
    e.writeInt64(randomId);
    e.writeString(buttonText);
    e.writeString(data);
  }
}

class MessagesTranscribeAudioRequest extends TlObject {
  final InputPeer peer;
  final int msgId;
  MessagesTranscribeAudioRequest({required this.peer, required this.msgId, });
  @override
  int get crc => 0x269e9a49;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(msgId);
  }
}

class MessagesRateTranscribedAudioRequest extends TlObject {
  final InputPeer peer;
  final int msgId;
  final int transcriptionId;
  final bool good;
  MessagesRateTranscribedAudioRequest({required this.peer, required this.msgId, required this.transcriptionId, required this.good, });
  @override
  int get crc => 0x7f1d072f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(msgId);
    e.writeInt64(transcriptionId);
    e.writeBool(good);
  }
}

class MessagesGetCustomEmojiDocumentsRequest extends TlObject {
  final List<int> documentId;
  MessagesGetCustomEmojiDocumentsRequest({required this.documentId, });
  @override
  int get crc => 0xd9ab0f54;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeCrc(0x1cb5c415); e.writeInt32(documentId.length); for (final item in documentId) { e.writeInt64(item); }
  }
}

class MessagesGetEmojiStickersRequest extends TlObject {
  final int hash;
  MessagesGetEmojiStickersRequest({required this.hash, });
  @override
  int get crc => 0xfbfca18f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(hash);
  }
}

class MessagesGetFeaturedEmojiStickersRequest extends TlObject {
  final int hash;
  MessagesGetFeaturedEmojiStickersRequest({required this.hash, });
  @override
  int get crc => 0xecf6736;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(hash);
  }
}

class MessagesReportReactionRequest extends TlObject {
  final InputPeer peer;
  final int id;
  final InputPeer reactionPeer;
  MessagesReportReactionRequest({required this.peer, required this.id, required this.reactionPeer, });
  @override
  int get crc => 0x3f64c076;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(id);
    reactionPeer.encode(e);
  }
}

class MessagesGetTopReactionsRequest extends TlObject {
  final int limit;
  final int hash;
  MessagesGetTopReactionsRequest({required this.limit, required this.hash, });
  @override
  int get crc => 0xbb8125ba;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(limit);
    e.writeInt64(hash);
  }
}

class MessagesGetRecentReactionsRequest extends TlObject {
  final int limit;
  final int hash;
  MessagesGetRecentReactionsRequest({required this.limit, required this.hash, });
  @override
  int get crc => 0x39461db2;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(limit);
    e.writeInt64(hash);
  }
}

class MessagesClearRecentReactionsRequest extends TlObject {
  MessagesClearRecentReactionsRequest();
  @override
  int get crc => 0x9dfeefb4;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class MessagesGetExtendedMediaRequest extends TlObject {
  final InputPeer peer;
  final List<int> id;
  MessagesGetExtendedMediaRequest({required this.peer, required this.id, });
  @override
  int get crc => 0x84f80814;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { e.writeInt32(item); }
  }
}

class MessagesSetDefaultHistoryTTLRequest extends TlObject {
  final int period;
  MessagesSetDefaultHistoryTTLRequest({required this.period, });
  @override
  int get crc => 0x9eb51445;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(period);
  }
}

class MessagesGetDefaultHistoryTTLRequest extends TlObject {
  MessagesGetDefaultHistoryTTLRequest();
  @override
  int get crc => 0x658b7188;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class MessagesSendBotRequestedPeerRequest extends TlObject {
  final InputPeer peer;
  final int? msgId;
  final String? webappReqId;
  final int buttonId;
  final List<InputPeer> requestedPeers;
  MessagesSendBotRequestedPeerRequest({required this.peer, this.msgId, this.webappReqId, required this.buttonId, required this.requestedPeers, });
  @override
  int get crc => 0x6c5cf2a7;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (msgId != null ? (1 << 0) : 0) | (webappReqId != null ? (1 << 1) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    if (msgId != null) { e.writeInt32(msgId!); }
    if (webappReqId != null) { e.writeString(webappReqId!); }
    e.writeInt32(buttonId);
    e.writeCrc(0x1cb5c415); e.writeInt32(requestedPeers.length); for (final item in requestedPeers) { item.encode(e); }
  }
}

class MessagesGetEmojiGroupsRequest extends TlObject {
  final int hash;
  MessagesGetEmojiGroupsRequest({required this.hash, });
  @override
  int get crc => 0x7488ce5b;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(hash);
  }
}

class MessagesGetEmojiStatusGroupsRequest extends TlObject {
  final int hash;
  MessagesGetEmojiStatusGroupsRequest({required this.hash, });
  @override
  int get crc => 0x2ecd56cd;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(hash);
  }
}

class MessagesGetEmojiProfilePhotoGroupsRequest extends TlObject {
  final int hash;
  MessagesGetEmojiProfilePhotoGroupsRequest({required this.hash, });
  @override
  int get crc => 0x21a548f3;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(hash);
  }
}

class MessagesSearchCustomEmojiRequest extends TlObject {
  final String emoticon;
  final int hash;
  MessagesSearchCustomEmojiRequest({required this.emoticon, required this.hash, });
  @override
  int get crc => 0x2c11c0d7;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(emoticon);
    e.writeInt64(hash);
  }
}

class MessagesTogglePeerTranslationsRequest extends TlObject {
  final bool disabled;
  final InputPeer peer;
  MessagesTogglePeerTranslationsRequest({this.disabled = false, required this.peer, });
  @override
  int get crc => 0xe47cb579;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (disabled == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
  }
}

class MessagesGetBotAppRequest extends TlObject {
  final InputBotApp app;
  final int hash;
  MessagesGetBotAppRequest({required this.app, required this.hash, });
  @override
  int get crc => 0x34fdc5c3;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    app.encode(e);
    e.writeInt64(hash);
  }
}

class MessagesRequestAppWebViewRequest extends TlObject {
  final bool writeAllowed;
  final bool compact;
  final bool fullscreen;
  final InputPeer peer;
  final InputBotApp app;
  final String? startParam;
  final DataJSON? themeParams;
  final String platform;
  MessagesRequestAppWebViewRequest({this.writeAllowed = false, this.compact = false, this.fullscreen = false, required this.peer, required this.app, this.startParam, this.themeParams, required this.platform, });
  @override
  int get crc => 0x53618bce;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (writeAllowed == true ? (1 << 0) : 0) | (compact == true ? (1 << 7) : 0) | (fullscreen == true ? (1 << 8) : 0) | (startParam != null ? (1 << 1) : 0) | (themeParams != null ? (1 << 2) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    app.encode(e);
    if (startParam != null) { e.writeString(startParam!); }
    if (themeParams != null) { themeParams!.encode(e); }
    e.writeString(platform);
  }
}

class MessagesSetChatWallPaperRequest extends TlObject {
  final bool forBoth;
  final bool revert;
  final InputPeer peer;
  final InputWallPaper? wallpaper;
  final WallPaperSettings? settings;
  final int? id;
  MessagesSetChatWallPaperRequest({this.forBoth = false, this.revert = false, required this.peer, this.wallpaper, this.settings, this.id, });
  @override
  int get crc => 0x8ffacae1;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (forBoth == true ? (1 << 3) : 0) | (revert == true ? (1 << 4) : 0) | (wallpaper != null ? (1 << 0) : 0) | (settings != null ? (1 << 2) : 0) | (id != null ? (1 << 1) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    if (wallpaper != null) { wallpaper!.encode(e); }
    if (settings != null) { settings!.encode(e); }
    if (id != null) { e.writeInt32(id!); }
  }
}

class MessagesSearchEmojiStickerSetsRequest extends TlObject {
  final bool excludeFeatured;
  final String q;
  final int hash;
  MessagesSearchEmojiStickerSetsRequest({this.excludeFeatured = false, required this.q, required this.hash, });
  @override
  int get crc => 0x92b4494c;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (excludeFeatured == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    e.writeString(q);
    e.writeInt64(hash);
  }
}

class MessagesGetSavedDialogsRequest extends TlObject {
  final bool excludePinned;
  final InputPeer? parentPeer;
  final int offsetDate;
  final int offsetId;
  final InputPeer offsetPeer;
  final int limit;
  final int hash;
  MessagesGetSavedDialogsRequest({this.excludePinned = false, this.parentPeer, required this.offsetDate, required this.offsetId, required this.offsetPeer, required this.limit, required this.hash, });
  @override
  int get crc => 0x1e91fc99;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (excludePinned == true ? (1 << 0) : 0) | (parentPeer != null ? (1 << 1) : 0);
    e.writeUint32(flags);
    if (parentPeer != null) { parentPeer!.encode(e); }
    e.writeInt32(offsetDate);
    e.writeInt32(offsetId);
    offsetPeer.encode(e);
    e.writeInt32(limit);
    e.writeInt64(hash);
  }
}

class MessagesGetSavedHistoryRequest extends TlObject {
  final InputPeer? parentPeer;
  final InputPeer peer;
  final int offsetId;
  final int offsetDate;
  final int addOffset;
  final int limit;
  final int maxId;
  final int minId;
  final int hash;
  MessagesGetSavedHistoryRequest({this.parentPeer, required this.peer, required this.offsetId, required this.offsetDate, required this.addOffset, required this.limit, required this.maxId, required this.minId, required this.hash, });
  @override
  int get crc => 0x998ab009;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (parentPeer != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    if (parentPeer != null) { parentPeer!.encode(e); }
    peer.encode(e);
    e.writeInt32(offsetId);
    e.writeInt32(offsetDate);
    e.writeInt32(addOffset);
    e.writeInt32(limit);
    e.writeInt32(maxId);
    e.writeInt32(minId);
    e.writeInt64(hash);
  }
}

class MessagesDeleteSavedHistoryRequest extends TlObject {
  final InputPeer? parentPeer;
  final InputPeer peer;
  final int maxId;
  final int? minDate;
  final int? maxDate;
  MessagesDeleteSavedHistoryRequest({this.parentPeer, required this.peer, required this.maxId, this.minDate, this.maxDate, });
  @override
  int get crc => 0x4dc5085f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (parentPeer != null ? (1 << 0) : 0) | (minDate != null ? (1 << 2) : 0) | (maxDate != null ? (1 << 3) : 0);
    e.writeUint32(flags);
    if (parentPeer != null) { parentPeer!.encode(e); }
    peer.encode(e);
    e.writeInt32(maxId);
    if (minDate != null) { e.writeInt32(minDate!); }
    if (maxDate != null) { e.writeInt32(maxDate!); }
  }
}

class MessagesGetPinnedSavedDialogsRequest extends TlObject {
  MessagesGetPinnedSavedDialogsRequest();
  @override
  int get crc => 0xd63d94e0;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class MessagesToggleSavedDialogPinRequest extends TlObject {
  final bool pinned;
  final InputDialogPeer peer;
  MessagesToggleSavedDialogPinRequest({this.pinned = false, required this.peer, });
  @override
  int get crc => 0xac81bbde;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (pinned == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
  }
}

class MessagesReorderPinnedSavedDialogsRequest extends TlObject {
  final bool force;
  final List<InputDialogPeer> order;
  MessagesReorderPinnedSavedDialogsRequest({this.force = false, required this.order, });
  @override
  int get crc => 0x8b716587;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (force == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    e.writeCrc(0x1cb5c415); e.writeInt32(order.length); for (final item in order) { item.encode(e); }
  }
}

class MessagesGetSavedReactionTagsRequest extends TlObject {
  final InputPeer? peer;
  final int hash;
  MessagesGetSavedReactionTagsRequest({this.peer, required this.hash, });
  @override
  int get crc => 0x3637e05b;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (peer != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    if (peer != null) { peer!.encode(e); }
    e.writeInt64(hash);
  }
}

class MessagesUpdateSavedReactionTagRequest extends TlObject {
  final Reaction reaction;
  final String? title;
  MessagesUpdateSavedReactionTagRequest({required this.reaction, this.title, });
  @override
  int get crc => 0x60297dec;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (title != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    reaction.encode(e);
    if (title != null) { e.writeString(title!); }
  }
}

class MessagesGetDefaultTagReactionsRequest extends TlObject {
  final int hash;
  MessagesGetDefaultTagReactionsRequest({required this.hash, });
  @override
  int get crc => 0xbdf93428;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(hash);
  }
}

class MessagesGetOutboxReadDateRequest extends TlObject {
  final InputPeer peer;
  final int msgId;
  MessagesGetOutboxReadDateRequest({required this.peer, required this.msgId, });
  @override
  int get crc => 0x8c4bfe5d;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(msgId);
  }
}

class MessagesGetQuickRepliesRequest extends TlObject {
  final int hash;
  MessagesGetQuickRepliesRequest({required this.hash, });
  @override
  int get crc => 0xd483f2a8;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(hash);
  }
}

class MessagesReorderQuickRepliesRequest extends TlObject {
  final List<int> order;
  MessagesReorderQuickRepliesRequest({required this.order, });
  @override
  int get crc => 0x60331907;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeCrc(0x1cb5c415); e.writeInt32(order.length); for (final item in order) { e.writeInt32(item); }
  }
}

class MessagesCheckQuickReplyShortcutRequest extends TlObject {
  final String shortcut;
  MessagesCheckQuickReplyShortcutRequest({required this.shortcut, });
  @override
  int get crc => 0xf1d0fbd3;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(shortcut);
  }
}

class MessagesEditQuickReplyShortcutRequest extends TlObject {
  final int shortcutId;
  final String shortcut;
  MessagesEditQuickReplyShortcutRequest({required this.shortcutId, required this.shortcut, });
  @override
  int get crc => 0x5c003cef;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(shortcutId);
    e.writeString(shortcut);
  }
}

class MessagesDeleteQuickReplyShortcutRequest extends TlObject {
  final int shortcutId;
  MessagesDeleteQuickReplyShortcutRequest({required this.shortcutId, });
  @override
  int get crc => 0x3cc04740;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(shortcutId);
  }
}

class MessagesGetQuickReplyMessagesRequest extends TlObject {
  final int shortcutId;
  final List<int>? id;
  final int hash;
  MessagesGetQuickReplyMessagesRequest({required this.shortcutId, this.id, required this.hash, });
  @override
  int get crc => 0x94a495c3;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (id != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    e.writeInt32(shortcutId);
    if (id != null) { e.writeCrc(0x1cb5c415); e.writeInt32(id!.length); for (final item in id!) { e.writeInt32(item); } }
    e.writeInt64(hash);
  }
}

class MessagesSendQuickReplyMessagesRequest extends TlObject {
  final InputPeer peer;
  final int shortcutId;
  final List<int> id;
  final List<int> randomId;
  MessagesSendQuickReplyMessagesRequest({required this.peer, required this.shortcutId, required this.id, required this.randomId, });
  @override
  int get crc => 0x6c750de1;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(shortcutId);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { e.writeInt32(item); }
    e.writeCrc(0x1cb5c415); e.writeInt32(randomId.length); for (final item in randomId) { e.writeInt64(item); }
  }
}

class MessagesDeleteQuickReplyMessagesRequest extends TlObject {
  final int shortcutId;
  final List<int> id;
  MessagesDeleteQuickReplyMessagesRequest({required this.shortcutId, required this.id, });
  @override
  int get crc => 0xe105e910;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(shortcutId);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { e.writeInt32(item); }
  }
}

class MessagesToggleDialogFilterTagsRequest extends TlObject {
  final bool enabled;
  MessagesToggleDialogFilterTagsRequest({required this.enabled, });
  @override
  int get crc => 0xfd2dda49;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeBool(enabled);
  }
}

class MessagesGetMyStickersRequest extends TlObject {
  final int offsetId;
  final int limit;
  MessagesGetMyStickersRequest({required this.offsetId, required this.limit, });
  @override
  int get crc => 0xd0b5e1fc;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(offsetId);
    e.writeInt32(limit);
  }
}

class MessagesGetEmojiStickerGroupsRequest extends TlObject {
  final int hash;
  MessagesGetEmojiStickerGroupsRequest({required this.hash, });
  @override
  int get crc => 0x1dd840f5;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(hash);
  }
}

class MessagesGetAvailableEffectsRequest extends TlObject {
  final int hash;
  MessagesGetAvailableEffectsRequest({required this.hash, });
  @override
  int get crc => 0xdea20a39;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(hash);
  }
}

class MessagesEditFactCheckRequest extends TlObject {
  final InputPeer peer;
  final int msgId;
  final TextWithEntities text;
  MessagesEditFactCheckRequest({required this.peer, required this.msgId, required this.text, });
  @override
  int get crc => 0x589ee75;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(msgId);
    text.encode(e);
  }
}

class MessagesDeleteFactCheckRequest extends TlObject {
  final InputPeer peer;
  final int msgId;
  MessagesDeleteFactCheckRequest({required this.peer, required this.msgId, });
  @override
  int get crc => 0xd1da940c;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(msgId);
  }
}

class MessagesGetFactCheckRequest extends TlObject {
  final InputPeer peer;
  final List<int> msgId;
  MessagesGetFactCheckRequest({required this.peer, required this.msgId, });
  @override
  int get crc => 0xb9cdc5ee;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(msgId.length); for (final item in msgId) { e.writeInt32(item); }
  }
}

class MessagesRequestMainWebViewRequest extends TlObject {
  final bool compact;
  final bool fullscreen;
  final InputPeer peer;
  final InputUser bot;
  final String? startParam;
  final DataJSON? themeParams;
  final String platform;
  MessagesRequestMainWebViewRequest({this.compact = false, this.fullscreen = false, required this.peer, required this.bot, this.startParam, this.themeParams, required this.platform, });
  @override
  int get crc => 0xc9e01e7b;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (compact == true ? (1 << 7) : 0) | (fullscreen == true ? (1 << 8) : 0) | (startParam != null ? (1 << 1) : 0) | (themeParams != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    bot.encode(e);
    if (startParam != null) { e.writeString(startParam!); }
    if (themeParams != null) { themeParams!.encode(e); }
    e.writeString(platform);
  }
}

class MessagesSendPaidReactionRequest extends TlObject {
  final InputPeer peer;
  final int msgId;
  final int count;
  final int randomId;
  final PaidReactionPrivacy? private;
  MessagesSendPaidReactionRequest({required this.peer, required this.msgId, required this.count, required this.randomId, this.private, });
  @override
  int get crc => 0x58bbcb50;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (private != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeInt32(msgId);
    e.writeInt32(count);
    e.writeInt64(randomId);
    if (private != null) { private!.encode(e); }
  }
}

class MessagesTogglePaidReactionPrivacyRequest extends TlObject {
  final InputPeer peer;
  final int msgId;
  final PaidReactionPrivacy private;
  MessagesTogglePaidReactionPrivacyRequest({required this.peer, required this.msgId, required this.private, });
  @override
  int get crc => 0x435885b5;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(msgId);
    private.encode(e);
  }
}

class MessagesGetPaidReactionPrivacyRequest extends TlObject {
  MessagesGetPaidReactionPrivacyRequest();
  @override
  int get crc => 0x472455aa;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class MessagesViewSponsoredMessageRequest extends TlObject {
  final Uint8List randomId;
  MessagesViewSponsoredMessageRequest({required this.randomId, });
  @override
  int get crc => 0x269e3643;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeBytes(randomId);
  }
}

class MessagesClickSponsoredMessageRequest extends TlObject {
  final bool media;
  final bool fullscreen;
  final Uint8List randomId;
  MessagesClickSponsoredMessageRequest({this.media = false, this.fullscreen = false, required this.randomId, });
  @override
  int get crc => 0x8235057e;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (media == true ? (1 << 0) : 0) | (fullscreen == true ? (1 << 1) : 0);
    e.writeUint32(flags);
    e.writeBytes(randomId);
  }
}

class MessagesReportSponsoredMessageRequest extends TlObject {
  final Uint8List randomId;
  final Uint8List option;
  MessagesReportSponsoredMessageRequest({required this.randomId, required this.option, });
  @override
  int get crc => 0x12cbf0c4;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeBytes(randomId);
    e.writeBytes(option);
  }
}

class MessagesGetSponsoredMessagesRequest extends TlObject {
  final InputPeer peer;
  final int? msgId;
  MessagesGetSponsoredMessagesRequest({required this.peer, this.msgId, });
  @override
  int get crc => 0x3d6ce850;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (msgId != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    if (msgId != null) { e.writeInt32(msgId!); }
  }
}

class MessagesSavePreparedInlineMessageRequest extends TlObject {
  final InputBotInlineResult result;
  final InputUser userId;
  final List<InlineQueryPeerType>? peerTypes;
  MessagesSavePreparedInlineMessageRequest({required this.result, required this.userId, this.peerTypes, });
  @override
  int get crc => 0xf21f7f2f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (peerTypes != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    result.encode(e);
    userId.encode(e);
    if (peerTypes != null) { e.writeCrc(0x1cb5c415); e.writeInt32(peerTypes!.length); for (final item in peerTypes!) { item.encode(e); } }
  }
}

class MessagesGetPreparedInlineMessageRequest extends TlObject {
  final InputUser bot;
  final String id;
  MessagesGetPreparedInlineMessageRequest({required this.bot, required this.id, });
  @override
  int get crc => 0x857ebdb8;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    bot.encode(e);
    e.writeString(id);
  }
}

class MessagesSearchStickersRequest extends TlObject {
  final bool emojis;
  final String q;
  final String emoticon;
  final List<String> langCode;
  final int offset;
  final int limit;
  final int hash;
  MessagesSearchStickersRequest({this.emojis = false, required this.q, required this.emoticon, required this.langCode, required this.offset, required this.limit, required this.hash, });
  @override
  int get crc => 0x29b1c66a;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (emojis == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    e.writeString(q);
    e.writeString(emoticon);
    e.writeCrc(0x1cb5c415); e.writeInt32(langCode.length); for (final item in langCode) { e.writeString(item); }
    e.writeInt32(offset);
    e.writeInt32(limit);
    e.writeInt64(hash);
  }
}

class MessagesReportMessagesDeliveryRequest extends TlObject {
  final bool push;
  final InputPeer peer;
  final List<int> id;
  MessagesReportMessagesDeliveryRequest({this.push = false, required this.peer, required this.id, });
  @override
  int get crc => 0x5a6d7395;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (push == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { e.writeInt32(item); }
  }
}

class MessagesGetSavedDialogsByIDRequest extends TlObject {
  final InputPeer? parentPeer;
  final List<InputPeer> ids;
  MessagesGetSavedDialogsByIDRequest({this.parentPeer, required this.ids, });
  @override
  int get crc => 0x6f6f9c96;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (parentPeer != null ? (1 << 1) : 0);
    e.writeUint32(flags);
    if (parentPeer != null) { parentPeer!.encode(e); }
    e.writeCrc(0x1cb5c415); e.writeInt32(ids.length); for (final item in ids) { item.encode(e); }
  }
}

class MessagesReadSavedHistoryRequest extends TlObject {
  final InputPeer parentPeer;
  final InputPeer peer;
  final int maxId;
  MessagesReadSavedHistoryRequest({required this.parentPeer, required this.peer, required this.maxId, });
  @override
  int get crc => 0xba4a3b5b;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    parentPeer.encode(e);
    peer.encode(e);
    e.writeInt32(maxId);
  }
}

class MessagesToggleTodoCompletedRequest extends TlObject {
  final InputPeer peer;
  final int msgId;
  final List<int> completed;
  final List<int> incompleted;
  MessagesToggleTodoCompletedRequest({required this.peer, required this.msgId, required this.completed, required this.incompleted, });
  @override
  int get crc => 0xd3e03124;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(msgId);
    e.writeCrc(0x1cb5c415); e.writeInt32(completed.length); for (final item in completed) { e.writeInt32(item); }
    e.writeCrc(0x1cb5c415); e.writeInt32(incompleted.length); for (final item in incompleted) { e.writeInt32(item); }
  }
}

class MessagesAppendTodoListRequest extends TlObject {
  final InputPeer peer;
  final int msgId;
  final List<TodoItem> list;
  MessagesAppendTodoListRequest({required this.peer, required this.msgId, required this.list, });
  @override
  int get crc => 0x21a61057;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(msgId);
    e.writeCrc(0x1cb5c415); e.writeInt32(list.length); for (final item in list) { item.encode(e); }
  }
}

class MessagesToggleSuggestedPostApprovalRequest extends TlObject {
  final bool reject;
  final InputPeer peer;
  final int msgId;
  final int? scheduleDate;
  final String? rejectComment;
  MessagesToggleSuggestedPostApprovalRequest({this.reject = false, required this.peer, required this.msgId, this.scheduleDate, this.rejectComment, });
  @override
  int get crc => 0x8107455c;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (reject == true ? (1 << 1) : 0) | (scheduleDate != null ? (1 << 0) : 0) | (rejectComment != null ? (1 << 2) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeInt32(msgId);
    if (scheduleDate != null) { e.writeInt32(scheduleDate!); }
    if (rejectComment != null) { e.writeString(rejectComment!); }
  }
}

class MessagesGetForumTopicsRequest extends TlObject {
  final InputPeer peer;
  final String? q;
  final int offsetDate;
  final int offsetId;
  final int offsetTopic;
  final int limit;
  MessagesGetForumTopicsRequest({required this.peer, this.q, required this.offsetDate, required this.offsetId, required this.offsetTopic, required this.limit, });
  @override
  int get crc => 0x3ba47bff;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (q != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    if (q != null) { e.writeString(q!); }
    e.writeInt32(offsetDate);
    e.writeInt32(offsetId);
    e.writeInt32(offsetTopic);
    e.writeInt32(limit);
  }
}

class MessagesGetForumTopicsByIDRequest extends TlObject {
  final InputPeer peer;
  final List<int> topics;
  MessagesGetForumTopicsByIDRequest({required this.peer, required this.topics, });
  @override
  int get crc => 0xaf0a4a08;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(topics.length); for (final item in topics) { e.writeInt32(item); }
  }
}

class MessagesEditForumTopicRequest extends TlObject {
  final InputPeer peer;
  final int topicId;
  final String? title;
  final int? iconEmojiId;
  final bool? closed;
  final bool? hidden;
  MessagesEditForumTopicRequest({required this.peer, required this.topicId, this.title, this.iconEmojiId, this.closed, this.hidden, });
  @override
  int get crc => 0xcecc1134;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (title != null ? (1 << 0) : 0) | (iconEmojiId != null ? (1 << 1) : 0) | (closed != null ? (1 << 2) : 0) | (hidden != null ? (1 << 3) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeInt32(topicId);
    if (title != null) { e.writeString(title!); }
    if (iconEmojiId != null) { e.writeInt64(iconEmojiId!); }
    if (closed != null) { e.writeBool(closed!); }
    if (hidden != null) { e.writeBool(hidden!); }
  }
}

class MessagesUpdatePinnedForumTopicRequest extends TlObject {
  final InputPeer peer;
  final int topicId;
  final bool pinned;
  MessagesUpdatePinnedForumTopicRequest({required this.peer, required this.topicId, required this.pinned, });
  @override
  int get crc => 0x175df251;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(topicId);
    e.writeBool(pinned);
  }
}

class MessagesReorderPinnedForumTopicsRequest extends TlObject {
  final bool force;
  final InputPeer peer;
  final List<int> order;
  MessagesReorderPinnedForumTopicsRequest({this.force = false, required this.peer, required this.order, });
  @override
  int get crc => 0xe7841f0;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (force == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(order.length); for (final item in order) { e.writeInt32(item); }
  }
}

class MessagesCreateForumTopicRequest extends TlObject {
  final bool titleMissing;
  final InputPeer peer;
  final String title;
  final int? iconColor;
  final int? iconEmojiId;
  final int randomId;
  final InputPeer? sendAs;
  MessagesCreateForumTopicRequest({this.titleMissing = false, required this.peer, required this.title, this.iconColor, this.iconEmojiId, required this.randomId, this.sendAs, });
  @override
  int get crc => 0x2f98c3d5;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (titleMissing == true ? (1 << 4) : 0) | (iconColor != null ? (1 << 0) : 0) | (iconEmojiId != null ? (1 << 3) : 0) | (sendAs != null ? (1 << 2) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeString(title);
    if (iconColor != null) { e.writeInt32(iconColor!); }
    if (iconEmojiId != null) { e.writeInt64(iconEmojiId!); }
    e.writeInt64(randomId);
    if (sendAs != null) { sendAs!.encode(e); }
  }
}

class MessagesDeleteTopicHistoryRequest extends TlObject {
  final InputPeer peer;
  final int topMsgId;
  MessagesDeleteTopicHistoryRequest({required this.peer, required this.topMsgId, });
  @override
  int get crc => 0xd2816f10;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(topMsgId);
  }
}

class MessagesGetEmojiGameInfoRequest extends TlObject {
  MessagesGetEmojiGameInfoRequest();
  @override
  int get crc => 0xfb7e8ca7;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class MessagesSummarizeTextRequest extends TlObject {
  final InputPeer peer;
  final int id;
  final String? toLang;
  final String? tone;
  MessagesSummarizeTextRequest({required this.peer, required this.id, this.toLang, this.tone, });
  @override
  int get crc => 0xabbbd346;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (toLang != null ? (1 << 0) : 0) | (tone != null ? (1 << 2) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeInt32(id);
    if (toLang != null) { e.writeString(toLang!); }
    if (tone != null) { e.writeString(tone!); }
  }
}

class MessagesEditChatCreatorRequest extends TlObject {
  final InputPeer peer;
  final InputUser userId;
  final InputCheckPasswordSRP password;
  MessagesEditChatCreatorRequest({required this.peer, required this.userId, required this.password, });
  @override
  int get crc => 0xf743b857;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    userId.encode(e);
    password.encode(e);
  }
}

class MessagesGetFutureChatCreatorAfterLeaveRequest extends TlObject {
  final InputPeer peer;
  MessagesGetFutureChatCreatorAfterLeaveRequest({required this.peer, });
  @override
  int get crc => 0x3b7d0ea6;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
  }
}

class MessagesEditChatParticipantRankRequest extends TlObject {
  final InputPeer peer;
  final InputPeer participant;
  final String rank;
  MessagesEditChatParticipantRankRequest({required this.peer, required this.participant, required this.rank, });
  @override
  int get crc => 0xa00f32b0;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    participant.encode(e);
    e.writeString(rank);
  }
}

class MessagesDeclineUrlAuthRequest extends TlObject {
  final String url;
  MessagesDeclineUrlAuthRequest({required this.url, });
  @override
  int get crc => 0x35436bbc;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(url);
  }
}

class MessagesCheckUrlAuthMatchCodeRequest extends TlObject {
  final String url;
  final String matchCode;
  MessagesCheckUrlAuthMatchCodeRequest({required this.url, required this.matchCode, });
  @override
  int get crc => 0xc9a47b0b;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(url);
    e.writeString(matchCode);
  }
}

class MessagesComposeMessageWithAIRequest extends TlObject {
  final bool proofread;
  final bool emojify;
  final TextWithEntities text;
  final String? translateToLang;
  final InputAiComposeTone? tone;
  MessagesComposeMessageWithAIRequest({this.proofread = false, this.emojify = false, required this.text, this.translateToLang, this.tone, });
  @override
  int get crc => 0xdaecc589;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (proofread == true ? (1 << 0) : 0) | (emojify == true ? (1 << 3) : 0) | (translateToLang != null ? (1 << 1) : 0) | (tone != null ? (1 << 2) : 0);
    e.writeUint32(flags);
    text.encode(e);
    if (translateToLang != null) { e.writeString(translateToLang!); }
    if (tone != null) { tone!.encode(e); }
  }
}

class MessagesReportReadMetricsRequest extends TlObject {
  final InputPeer peer;
  final List<InputMessageReadMetric> metrics;
  MessagesReportReadMetricsRequest({required this.peer, required this.metrics, });
  @override
  int get crc => 0x4067c5e6;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(metrics.length); for (final item in metrics) { item.encode(e); }
  }
}

class MessagesReportMusicListenRequest extends TlObject {
  final InputDocument id;
  final int listenedDuration;
  MessagesReportMusicListenRequest({required this.id, required this.listenedDuration, });
  @override
  int get crc => 0xddbcd819;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    id.encode(e);
    e.writeInt32(listenedDuration);
  }
}

class MessagesAddPollAnswerRequest extends TlObject {
  final InputPeer peer;
  final int msgId;
  final PollAnswer answer;
  MessagesAddPollAnswerRequest({required this.peer, required this.msgId, required this.answer, });
  @override
  int get crc => 0x19bc4b6d;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(msgId);
    answer.encode(e);
  }
}

class MessagesDeletePollAnswerRequest extends TlObject {
  final InputPeer peer;
  final int msgId;
  final Uint8List option;
  MessagesDeletePollAnswerRequest({required this.peer, required this.msgId, required this.option, });
  @override
  int get crc => 0xac8505a5;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(msgId);
    e.writeBytes(option);
  }
}

class MessagesGetUnreadPollVotesRequest extends TlObject {
  final InputPeer peer;
  final int? topMsgId;
  final int offsetId;
  final int addOffset;
  final int limit;
  final int maxId;
  final int minId;
  MessagesGetUnreadPollVotesRequest({required this.peer, this.topMsgId, required this.offsetId, required this.addOffset, required this.limit, required this.maxId, required this.minId, });
  @override
  int get crc => 0x43286cf2;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (topMsgId != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    if (topMsgId != null) { e.writeInt32(topMsgId!); }
    e.writeInt32(offsetId);
    e.writeInt32(addOffset);
    e.writeInt32(limit);
    e.writeInt32(maxId);
    e.writeInt32(minId);
  }
}

class MessagesReadPollVotesRequest extends TlObject {
  final InputPeer peer;
  final int? topMsgId;
  MessagesReadPollVotesRequest({required this.peer, this.topMsgId, });
  @override
  int get crc => 0x1720b4d8;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (topMsgId != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    if (topMsgId != null) { e.writeInt32(topMsgId!); }
  }
}

class MessagesSetBotGuestChatResultRequest extends TlObject {
  final int queryId;
  final InputBotInlineResult result;
  MessagesSetBotGuestChatResultRequest({required this.queryId, required this.result, });
  @override
  int get crc => 0xb8f106e3;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(queryId);
    result.encode(e);
  }
}

class MessagesDeleteParticipantReactionsRequest extends TlObject {
  final InputPeer peer;
  final InputPeer participant;
  MessagesDeleteParticipantReactionsRequest({required this.peer, required this.participant, });
  @override
  int get crc => 0xa0b80cf8;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    participant.encode(e);
  }
}

class MessagesDeleteParticipantReactionRequest extends TlObject {
  final InputPeer peer;
  final int msgId;
  final InputPeer participant;
  MessagesDeleteParticipantReactionRequest({required this.peer, required this.msgId, required this.participant, });
  @override
  int get crc => 0xe3b7f82c;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(msgId);
    participant.encode(e);
  }
}

class MessagesGetPersonalChannelHistoryRequest extends TlObject {
  final InputUser userId;
  final int limit;
  final int maxId;
  final int minId;
  final int hash;
  MessagesGetPersonalChannelHistoryRequest({required this.userId, required this.limit, required this.maxId, required this.minId, required this.hash, });
  @override
  int get crc => 0x55fb0996;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    userId.encode(e);
    e.writeInt32(limit);
    e.writeInt32(maxId);
    e.writeInt32(minId);
    e.writeInt64(hash);
  }
}

class MessagesGetRichMessageRequest extends TlObject {
  final InputPeer peer;
  final int id;
  MessagesGetRichMessageRequest({required this.peer, required this.id, });
  @override
  int get crc => 0x501569cf;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(id);
  }
}

class UpdatesGetStateRequest extends TlObject {
  UpdatesGetStateRequest();
  @override
  int get crc => 0xedd4882a;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class UpdatesGetDifferenceRequest extends TlObject {
  final int pts;
  final int? ptsLimit;
  final int? ptsTotalLimit;
  final int date;
  final int qts;
  final int? qtsLimit;
  UpdatesGetDifferenceRequest({required this.pts, this.ptsLimit, this.ptsTotalLimit, required this.date, required this.qts, this.qtsLimit, });
  @override
  int get crc => 0x19c2f763;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (ptsLimit != null ? (1 << 1) : 0) | (ptsTotalLimit != null ? (1 << 0) : 0) | (qtsLimit != null ? (1 << 2) : 0);
    e.writeUint32(flags);
    e.writeInt32(pts);
    if (ptsLimit != null) { e.writeInt32(ptsLimit!); }
    if (ptsTotalLimit != null) { e.writeInt32(ptsTotalLimit!); }
    e.writeInt32(date);
    e.writeInt32(qts);
    if (qtsLimit != null) { e.writeInt32(qtsLimit!); }
  }
}

class UpdatesGetChannelDifferenceRequest extends TlObject {
  final bool force;
  final InputChannel channel;
  final ChannelMessagesFilter filter;
  final int pts;
  final int limit;
  UpdatesGetChannelDifferenceRequest({this.force = false, required this.channel, required this.filter, required this.pts, required this.limit, });
  @override
  int get crc => 0x3173d78;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (force == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    channel.encode(e);
    filter.encode(e);
    e.writeInt32(pts);
    e.writeInt32(limit);
  }
}

class PhotosUpdateProfilePhotoRequest extends TlObject {
  final bool fallback;
  final InputUser? bot;
  final InputPhoto id;
  PhotosUpdateProfilePhotoRequest({this.fallback = false, this.bot, required this.id, });
  @override
  int get crc => 0x9e82039;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (fallback == true ? (1 << 0) : 0) | (bot != null ? (1 << 1) : 0);
    e.writeUint32(flags);
    if (bot != null) { bot!.encode(e); }
    id.encode(e);
  }
}

class PhotosUploadProfilePhotoRequest extends TlObject {
  final bool fallback;
  final InputUser? bot;
  final InputFile? file;
  final InputFile? video;
  final double? videoStartTs;
  final VideoSize? videoEmojiMarkup;
  PhotosUploadProfilePhotoRequest({this.fallback = false, this.bot, this.file, this.video, this.videoStartTs, this.videoEmojiMarkup, });
  @override
  int get crc => 0x388a3b5;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (fallback == true ? (1 << 3) : 0) | (bot != null ? (1 << 5) : 0) | (file != null ? (1 << 0) : 0) | (video != null ? (1 << 1) : 0) | (videoStartTs != null ? (1 << 2) : 0) | (videoEmojiMarkup != null ? (1 << 4) : 0);
    e.writeUint32(flags);
    if (bot != null) { bot!.encode(e); }
    if (file != null) { file!.encode(e); }
    if (video != null) { video!.encode(e); }
    if (videoStartTs != null) { e.writeDouble(videoStartTs!); }
    if (videoEmojiMarkup != null) { videoEmojiMarkup!.encode(e); }
  }
}

class PhotosDeletePhotosRequest extends TlObject {
  final List<InputPhoto> id;
  PhotosDeletePhotosRequest({required this.id, });
  @override
  int get crc => 0x87cf7f2f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { item.encode(e); }
  }
}

class PhotosGetUserPhotosRequest extends TlObject {
  final InputUser userId;
  final int offset;
  final int maxId;
  final int limit;
  PhotosGetUserPhotosRequest({required this.userId, required this.offset, required this.maxId, required this.limit, });
  @override
  int get crc => 0x91cd32a8;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    userId.encode(e);
    e.writeInt32(offset);
    e.writeInt64(maxId);
    e.writeInt32(limit);
  }
}

class PhotosUploadContactProfilePhotoRequest extends TlObject {
  final bool suggest;
  final bool save;
  final InputUser userId;
  final InputFile? file;
  final InputFile? video;
  final double? videoStartTs;
  final VideoSize? videoEmojiMarkup;
  PhotosUploadContactProfilePhotoRequest({this.suggest = false, this.save = false, required this.userId, this.file, this.video, this.videoStartTs, this.videoEmojiMarkup, });
  @override
  int get crc => 0xe14c4a71;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (suggest == true ? (1 << 3) : 0) | (save == true ? (1 << 4) : 0) | (file != null ? (1 << 0) : 0) | (video != null ? (1 << 1) : 0) | (videoStartTs != null ? (1 << 2) : 0) | (videoEmojiMarkup != null ? (1 << 5) : 0);
    e.writeUint32(flags);
    userId.encode(e);
    if (file != null) { file!.encode(e); }
    if (video != null) { video!.encode(e); }
    if (videoStartTs != null) { e.writeDouble(videoStartTs!); }
    if (videoEmojiMarkup != null) { videoEmojiMarkup!.encode(e); }
  }
}

class UploadSaveFilePartRequest extends TlObject {
  final int fileId;
  final int filePart;
  final Uint8List bytes;
  UploadSaveFilePartRequest({required this.fileId, required this.filePart, required this.bytes, });
  @override
  int get crc => 0xb304a621;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(fileId);
    e.writeInt32(filePart);
    e.writeBytes(bytes);
  }
}

class UploadGetFileRequest extends TlObject {
  final bool precise;
  final bool cdnSupported;
  final InputFileLocation location;
  final int offset;
  final int limit;
  UploadGetFileRequest({this.precise = false, this.cdnSupported = false, required this.location, required this.offset, required this.limit, });
  @override
  int get crc => 0xbe5335be;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (precise == true ? (1 << 0) : 0) | (cdnSupported == true ? (1 << 1) : 0);
    e.writeUint32(flags);
    location.encode(e);
    e.writeInt64(offset);
    e.writeInt32(limit);
  }
}

class UploadSaveBigFilePartRequest extends TlObject {
  final int fileId;
  final int filePart;
  final int fileTotalParts;
  final Uint8List bytes;
  UploadSaveBigFilePartRequest({required this.fileId, required this.filePart, required this.fileTotalParts, required this.bytes, });
  @override
  int get crc => 0xde7b673d;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(fileId);
    e.writeInt32(filePart);
    e.writeInt32(fileTotalParts);
    e.writeBytes(bytes);
  }
}

class UploadGetWebFileRequest extends TlObject {
  final InputWebFileLocation location;
  final int offset;
  final int limit;
  UploadGetWebFileRequest({required this.location, required this.offset, required this.limit, });
  @override
  int get crc => 0x24e6818d;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    location.encode(e);
    e.writeInt32(offset);
    e.writeInt32(limit);
  }
}

class UploadGetCdnFileRequest extends TlObject {
  final Uint8List fileToken;
  final int offset;
  final int limit;
  UploadGetCdnFileRequest({required this.fileToken, required this.offset, required this.limit, });
  @override
  int get crc => 0x395f69da;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeBytes(fileToken);
    e.writeInt64(offset);
    e.writeInt32(limit);
  }
}

class UploadReuploadCdnFileRequest extends TlObject {
  final Uint8List fileToken;
  final Uint8List requestToken;
  UploadReuploadCdnFileRequest({required this.fileToken, required this.requestToken, });
  @override
  int get crc => 0x9b2754a8;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeBytes(fileToken);
    e.writeBytes(requestToken);
  }
}

class UploadGetCdnFileHashesRequest extends TlObject {
  final Uint8List fileToken;
  final int offset;
  UploadGetCdnFileHashesRequest({required this.fileToken, required this.offset, });
  @override
  int get crc => 0x91dc3f31;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeBytes(fileToken);
    e.writeInt64(offset);
  }
}

class UploadGetFileHashesRequest extends TlObject {
  final InputFileLocation location;
  final int offset;
  UploadGetFileHashesRequest({required this.location, required this.offset, });
  @override
  int get crc => 0x9156982a;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    location.encode(e);
    e.writeInt64(offset);
  }
}

class HelpGetConfigRequest extends TlObject {
  HelpGetConfigRequest();
  @override
  int get crc => 0xc4f9186b;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class HelpGetNearestDcRequest extends TlObject {
  HelpGetNearestDcRequest();
  @override
  int get crc => 0x1fb33026;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class HelpGetAppUpdateRequest extends TlObject {
  final String source;
  HelpGetAppUpdateRequest({required this.source, });
  @override
  int get crc => 0x522d5a7d;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(source);
  }
}

class HelpGetInviteTextRequest extends TlObject {
  HelpGetInviteTextRequest();
  @override
  int get crc => 0x4d392343;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class HelpGetSupportRequest extends TlObject {
  HelpGetSupportRequest();
  @override
  int get crc => 0x9cdf08cd;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class HelpSetBotUpdatesStatusRequest extends TlObject {
  final int pendingUpdatesCount;
  final String message;
  HelpSetBotUpdatesStatusRequest({required this.pendingUpdatesCount, required this.message, });
  @override
  int get crc => 0xec22cfcd;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(pendingUpdatesCount);
    e.writeString(message);
  }
}

class HelpGetCdnConfigRequest extends TlObject {
  HelpGetCdnConfigRequest();
  @override
  int get crc => 0x52029342;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class HelpGetRecentMeUrlsRequest extends TlObject {
  final String referer;
  HelpGetRecentMeUrlsRequest({required this.referer, });
  @override
  int get crc => 0x3dc0f114;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(referer);
  }
}

class HelpGetTermsOfServiceUpdateRequest extends TlObject {
  HelpGetTermsOfServiceUpdateRequest();
  @override
  int get crc => 0x2ca51fd1;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class HelpAcceptTermsOfServiceRequest extends TlObject {
  final DataJSON id;
  HelpAcceptTermsOfServiceRequest({required this.id, });
  @override
  int get crc => 0xee72f79a;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    id.encode(e);
  }
}

class HelpGetDeepLinkInfoRequest extends TlObject {
  final String path;
  HelpGetDeepLinkInfoRequest({required this.path, });
  @override
  int get crc => 0x3fedc75f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(path);
  }
}

class HelpGetAppConfigRequest extends TlObject {
  final int hash;
  HelpGetAppConfigRequest({required this.hash, });
  @override
  int get crc => 0x61e3f854;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(hash);
  }
}

class HelpSaveAppLogRequest extends TlObject {
  final List<InputAppEvent> events;
  HelpSaveAppLogRequest({required this.events, });
  @override
  int get crc => 0x6f02f748;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeCrc(0x1cb5c415); e.writeInt32(events.length); for (final item in events) { item.encode(e); }
  }
}

class HelpGetPassportConfigRequest extends TlObject {
  final int hash;
  HelpGetPassportConfigRequest({required this.hash, });
  @override
  int get crc => 0xc661ad08;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(hash);
  }
}

class HelpGetSupportNameRequest extends TlObject {
  HelpGetSupportNameRequest();
  @override
  int get crc => 0xd360e72c;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class HelpGetUserInfoRequest extends TlObject {
  final InputUser userId;
  HelpGetUserInfoRequest({required this.userId, });
  @override
  int get crc => 0x38a08d3;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    userId.encode(e);
  }
}

class HelpEditUserInfoRequest extends TlObject {
  final InputUser userId;
  final String message;
  final List<MessageEntity> entities;
  HelpEditUserInfoRequest({required this.userId, required this.message, required this.entities, });
  @override
  int get crc => 0x66b91b70;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    userId.encode(e);
    e.writeString(message);
    e.writeCrc(0x1cb5c415); e.writeInt32(entities.length); for (final item in entities) { item.encode(e); }
  }
}

class HelpGetPromoDataRequest extends TlObject {
  HelpGetPromoDataRequest();
  @override
  int get crc => 0xc0977421;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class HelpHidePromoDataRequest extends TlObject {
  final InputPeer peer;
  HelpHidePromoDataRequest({required this.peer, });
  @override
  int get crc => 0x1e251c95;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
  }
}

class HelpDismissSuggestionRequest extends TlObject {
  final InputPeer peer;
  final String suggestion;
  HelpDismissSuggestionRequest({required this.peer, required this.suggestion, });
  @override
  int get crc => 0xf50dbaa1;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeString(suggestion);
  }
}

class HelpGetCountriesListRequest extends TlObject {
  final String langCode;
  final int hash;
  HelpGetCountriesListRequest({required this.langCode, required this.hash, });
  @override
  int get crc => 0x735787a8;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(langCode);
    e.writeInt32(hash);
  }
}

class HelpGetPremiumPromoRequest extends TlObject {
  HelpGetPremiumPromoRequest();
  @override
  int get crc => 0xb81b93d4;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class HelpGetPeerColorsRequest extends TlObject {
  final int hash;
  HelpGetPeerColorsRequest({required this.hash, });
  @override
  int get crc => 0xda80f42f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(hash);
  }
}

class HelpGetPeerProfileColorsRequest extends TlObject {
  final int hash;
  HelpGetPeerProfileColorsRequest({required this.hash, });
  @override
  int get crc => 0xabcfa9fd;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(hash);
  }
}

class HelpGetTimezonesListRequest extends TlObject {
  final int hash;
  HelpGetTimezonesListRequest({required this.hash, });
  @override
  int get crc => 0x49b30240;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(hash);
  }
}

class ChannelsReadHistoryRequest extends TlObject {
  final InputChannel channel;
  final int maxId;
  ChannelsReadHistoryRequest({required this.channel, required this.maxId, });
  @override
  int get crc => 0xcc104937;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    e.writeInt32(maxId);
  }
}

class ChannelsDeleteMessagesRequest extends TlObject {
  final InputChannel channel;
  final List<int> id;
  ChannelsDeleteMessagesRequest({required this.channel, required this.id, });
  @override
  int get crc => 0x84c1fd4e;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { e.writeInt32(item); }
  }
}

class ChannelsReportSpamRequest extends TlObject {
  final InputChannel channel;
  final InputPeer participant;
  final List<int> id;
  ChannelsReportSpamRequest({required this.channel, required this.participant, required this.id, });
  @override
  int get crc => 0xf44a8315;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    participant.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { e.writeInt32(item); }
  }
}

class ChannelsGetMessagesRequest extends TlObject {
  final InputChannel channel;
  final List<InputMessage> id;
  ChannelsGetMessagesRequest({required this.channel, required this.id, });
  @override
  int get crc => 0xad8c9a23;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { item.encode(e); }
  }
}

class ChannelsGetParticipantsRequest extends TlObject {
  final InputChannel channel;
  final ChannelParticipantsFilter filter;
  final int offset;
  final int limit;
  final int hash;
  ChannelsGetParticipantsRequest({required this.channel, required this.filter, required this.offset, required this.limit, required this.hash, });
  @override
  int get crc => 0x77ced9d0;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    filter.encode(e);
    e.writeInt32(offset);
    e.writeInt32(limit);
    e.writeInt64(hash);
  }
}

class ChannelsGetParticipantRequest extends TlObject {
  final InputChannel channel;
  final InputPeer participant;
  ChannelsGetParticipantRequest({required this.channel, required this.participant, });
  @override
  int get crc => 0xa0ab6cc6;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    participant.encode(e);
  }
}

class ChannelsGetChannelsRequest extends TlObject {
  final List<InputChannel> id;
  ChannelsGetChannelsRequest({required this.id, });
  @override
  int get crc => 0xa7f6bbb;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { item.encode(e); }
  }
}

class ChannelsGetFullChannelRequest extends TlObject {
  final InputChannel channel;
  ChannelsGetFullChannelRequest({required this.channel, });
  @override
  int get crc => 0x8736a09;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
  }
}

class ChannelsCreateChannelRequest extends TlObject {
  final bool broadcast;
  final bool megagroup;
  final bool forImport;
  final bool forum;
  final String title;
  final String about;
  final InputGeoPoint? geoPoint;
  final String? address;
  final int? ttlPeriod;
  ChannelsCreateChannelRequest({this.broadcast = false, this.megagroup = false, this.forImport = false, this.forum = false, required this.title, required this.about, this.geoPoint, this.address, this.ttlPeriod, });
  @override
  int get crc => 0x91006707;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (broadcast == true ? (1 << 0) : 0) | (megagroup == true ? (1 << 1) : 0) | (forImport == true ? (1 << 3) : 0) | (forum == true ? (1 << 5) : 0) | (geoPoint != null ? (1 << 2) : 0) | (address != null ? (1 << 2) : 0) | (ttlPeriod != null ? (1 << 4) : 0);
    e.writeUint32(flags);
    e.writeString(title);
    e.writeString(about);
    if (geoPoint != null) { geoPoint!.encode(e); }
    if (address != null) { e.writeString(address!); }
    if (ttlPeriod != null) { e.writeInt32(ttlPeriod!); }
  }
}

class ChannelsEditAdminRequest extends TlObject {
  final InputChannel channel;
  final InputUser userId;
  final ChatAdminRights adminRights;
  final String? rank;
  ChannelsEditAdminRequest({required this.channel, required this.userId, required this.adminRights, this.rank, });
  @override
  int get crc => 0x9a98ad68;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (rank != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    channel.encode(e);
    userId.encode(e);
    adminRights.encode(e);
    if (rank != null) { e.writeString(rank!); }
  }
}

class ChannelsEditTitleRequest extends TlObject {
  final InputChannel channel;
  final String title;
  ChannelsEditTitleRequest({required this.channel, required this.title, });
  @override
  int get crc => 0x566decd0;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    e.writeString(title);
  }
}

class ChannelsEditPhotoRequest extends TlObject {
  final InputChannel channel;
  final InputChatPhoto photo;
  ChannelsEditPhotoRequest({required this.channel, required this.photo, });
  @override
  int get crc => 0xf12e57c9;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    photo.encode(e);
  }
}

class ChannelsCheckUsernameRequest extends TlObject {
  final InputChannel channel;
  final String username;
  ChannelsCheckUsernameRequest({required this.channel, required this.username, });
  @override
  int get crc => 0x10e6bd2c;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    e.writeString(username);
  }
}

class ChannelsUpdateUsernameRequest extends TlObject {
  final InputChannel channel;
  final String username;
  ChannelsUpdateUsernameRequest({required this.channel, required this.username, });
  @override
  int get crc => 0x3514b3de;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    e.writeString(username);
  }
}

class ChannelsJoinChannelRequest extends TlObject {
  final InputChannel channel;
  ChannelsJoinChannelRequest({required this.channel, });
  @override
  int get crc => 0x7f6a1e22;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
  }
}

class ChannelsLeaveChannelRequest extends TlObject {
  final InputChannel channel;
  ChannelsLeaveChannelRequest({required this.channel, });
  @override
  int get crc => 0xf836aa95;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
  }
}

class ChannelsInviteToChannelRequest extends TlObject {
  final InputChannel channel;
  final List<InputUser> users;
  ChannelsInviteToChannelRequest({required this.channel, required this.users, });
  @override
  int get crc => 0xc9e33d54;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(users.length); for (final item in users) { item.encode(e); }
  }
}

class ChannelsDeleteChannelRequest extends TlObject {
  final InputChannel channel;
  ChannelsDeleteChannelRequest({required this.channel, });
  @override
  int get crc => 0xc0111fe3;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
  }
}

class ChannelsExportMessageLinkRequest extends TlObject {
  final bool grouped;
  final bool thread;
  final InputChannel channel;
  final int id;
  ChannelsExportMessageLinkRequest({this.grouped = false, this.thread = false, required this.channel, required this.id, });
  @override
  int get crc => 0xe63fadeb;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (grouped == true ? (1 << 0) : 0) | (thread == true ? (1 << 1) : 0);
    e.writeUint32(flags);
    channel.encode(e);
    e.writeInt32(id);
  }
}

class ChannelsToggleSignaturesRequest extends TlObject {
  final bool signaturesEnabled;
  final bool profilesEnabled;
  final InputChannel channel;
  ChannelsToggleSignaturesRequest({this.signaturesEnabled = false, this.profilesEnabled = false, required this.channel, });
  @override
  int get crc => 0x418d549c;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (signaturesEnabled == true ? (1 << 0) : 0) | (profilesEnabled == true ? (1 << 1) : 0);
    e.writeUint32(flags);
    channel.encode(e);
  }
}

class ChannelsGetAdminedPublicChannelsRequest extends TlObject {
  final bool byLocation;
  final bool checkLimit;
  final bool forPersonal;
  ChannelsGetAdminedPublicChannelsRequest({this.byLocation = false, this.checkLimit = false, this.forPersonal = false, });
  @override
  int get crc => 0xf8b036af;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (byLocation == true ? (1 << 0) : 0) | (checkLimit == true ? (1 << 1) : 0) | (forPersonal == true ? (1 << 2) : 0);
    e.writeUint32(flags);
  }
}

class ChannelsEditBannedRequest extends TlObject {
  final InputChannel channel;
  final InputPeer participant;
  final ChatBannedRights bannedRights;
  ChannelsEditBannedRequest({required this.channel, required this.participant, required this.bannedRights, });
  @override
  int get crc => 0x96e6cd81;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    participant.encode(e);
    bannedRights.encode(e);
  }
}

class ChannelsGetAdminLogRequest extends TlObject {
  final InputChannel channel;
  final String q;
  final ChannelAdminLogEventsFilter? eventsFilter;
  final List<InputUser>? admins;
  final int maxId;
  final int minId;
  final int limit;
  ChannelsGetAdminLogRequest({required this.channel, required this.q, this.eventsFilter, this.admins, required this.maxId, required this.minId, required this.limit, });
  @override
  int get crc => 0x33ddf480;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (eventsFilter != null ? (1 << 0) : 0) | (admins != null ? (1 << 1) : 0);
    e.writeUint32(flags);
    channel.encode(e);
    e.writeString(q);
    if (eventsFilter != null) { eventsFilter!.encode(e); }
    if (admins != null) { e.writeCrc(0x1cb5c415); e.writeInt32(admins!.length); for (final item in admins!) { item.encode(e); } }
    e.writeInt64(maxId);
    e.writeInt64(minId);
    e.writeInt32(limit);
  }
}

class ChannelsSetStickersRequest extends TlObject {
  final InputChannel channel;
  final InputStickerSet stickerset;
  ChannelsSetStickersRequest({required this.channel, required this.stickerset, });
  @override
  int get crc => 0xea8ca4f9;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    stickerset.encode(e);
  }
}

class ChannelsReadMessageContentsRequest extends TlObject {
  final InputChannel channel;
  final List<int> id;
  ChannelsReadMessageContentsRequest({required this.channel, required this.id, });
  @override
  int get crc => 0xeab5dc38;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { e.writeInt32(item); }
  }
}

class ChannelsDeleteHistoryRequest extends TlObject {
  final bool forEveryone;
  final InputChannel channel;
  final int maxId;
  ChannelsDeleteHistoryRequest({this.forEveryone = false, required this.channel, required this.maxId, });
  @override
  int get crc => 0x9baa9647;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (forEveryone == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    channel.encode(e);
    e.writeInt32(maxId);
  }
}

class ChannelsTogglePreHistoryHiddenRequest extends TlObject {
  final InputChannel channel;
  final bool enabled;
  ChannelsTogglePreHistoryHiddenRequest({required this.channel, required this.enabled, });
  @override
  int get crc => 0xeabbb94c;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    e.writeBool(enabled);
  }
}

class ChannelsGetLeftChannelsRequest extends TlObject {
  final int offset;
  ChannelsGetLeftChannelsRequest({required this.offset, });
  @override
  int get crc => 0x8341ecc0;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(offset);
  }
}

class ChannelsGetGroupsForDiscussionRequest extends TlObject {
  ChannelsGetGroupsForDiscussionRequest();
  @override
  int get crc => 0xf5dad378;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class ChannelsSetDiscussionGroupRequest extends TlObject {
  final InputChannel broadcast;
  final InputChannel group;
  ChannelsSetDiscussionGroupRequest({required this.broadcast, required this.group, });
  @override
  int get crc => 0x40582bb2;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    broadcast.encode(e);
    group.encode(e);
  }
}

class ChannelsEditLocationRequest extends TlObject {
  final InputChannel channel;
  final InputGeoPoint geoPoint;
  final String address;
  ChannelsEditLocationRequest({required this.channel, required this.geoPoint, required this.address, });
  @override
  int get crc => 0x58e63f6d;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    geoPoint.encode(e);
    e.writeString(address);
  }
}

class ChannelsToggleSlowModeRequest extends TlObject {
  final InputChannel channel;
  final int seconds;
  ChannelsToggleSlowModeRequest({required this.channel, required this.seconds, });
  @override
  int get crc => 0xedd49ef0;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    e.writeInt32(seconds);
  }
}

class ChannelsGetInactiveChannelsRequest extends TlObject {
  ChannelsGetInactiveChannelsRequest();
  @override
  int get crc => 0x11e831ee;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class ChannelsConvertToGigagroupRequest extends TlObject {
  final InputChannel channel;
  ChannelsConvertToGigagroupRequest({required this.channel, });
  @override
  int get crc => 0xb290c69;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
  }
}

class ChannelsGetSendAsRequest extends TlObject {
  final bool forPaidReactions;
  final bool forLiveStories;
  final InputPeer peer;
  ChannelsGetSendAsRequest({this.forPaidReactions = false, this.forLiveStories = false, required this.peer, });
  @override
  int get crc => 0xe785a43f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (forPaidReactions == true ? (1 << 0) : 0) | (forLiveStories == true ? (1 << 1) : 0);
    e.writeUint32(flags);
    peer.encode(e);
  }
}

class ChannelsDeleteParticipantHistoryRequest extends TlObject {
  final InputChannel channel;
  final InputPeer participant;
  ChannelsDeleteParticipantHistoryRequest({required this.channel, required this.participant, });
  @override
  int get crc => 0x367544db;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    participant.encode(e);
  }
}

class ChannelsToggleJoinToSendRequest extends TlObject {
  final InputChannel channel;
  final bool enabled;
  ChannelsToggleJoinToSendRequest({required this.channel, required this.enabled, });
  @override
  int get crc => 0xe4cb9580;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    e.writeBool(enabled);
  }
}

class ChannelsToggleJoinRequestRequest extends TlObject {
  final bool applyToInvites;
  final InputChannel channel;
  final bool enabled;
  final InputUser? guardBot;
  ChannelsToggleJoinRequestRequest({this.applyToInvites = false, required this.channel, required this.enabled, this.guardBot, });
  @override
  int get crc => 0xecc2618;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (applyToInvites == true ? (1 << 1) : 0) | (guardBot != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    channel.encode(e);
    e.writeBool(enabled);
    if (guardBot != null) { guardBot!.encode(e); }
  }
}

class ChannelsReorderUsernamesRequest extends TlObject {
  final InputChannel channel;
  final List<String> order;
  ChannelsReorderUsernamesRequest({required this.channel, required this.order, });
  @override
  int get crc => 0xb45ced1d;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(order.length); for (final item in order) { e.writeString(item); }
  }
}

class ChannelsToggleUsernameRequest extends TlObject {
  final InputChannel channel;
  final String username;
  final bool active;
  ChannelsToggleUsernameRequest({required this.channel, required this.username, required this.active, });
  @override
  int get crc => 0x50f24105;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    e.writeString(username);
    e.writeBool(active);
  }
}

class ChannelsDeactivateAllUsernamesRequest extends TlObject {
  final InputChannel channel;
  ChannelsDeactivateAllUsernamesRequest({required this.channel, });
  @override
  int get crc => 0xa245dd3;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
  }
}

class ChannelsToggleForumRequest extends TlObject {
  final InputChannel channel;
  final bool enabled;
  final bool tabs;
  ChannelsToggleForumRequest({required this.channel, required this.enabled, required this.tabs, });
  @override
  int get crc => 0x3ff75734;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    e.writeBool(enabled);
    e.writeBool(tabs);
  }
}

class ChannelsToggleAntiSpamRequest extends TlObject {
  final InputChannel channel;
  final bool enabled;
  ChannelsToggleAntiSpamRequest({required this.channel, required this.enabled, });
  @override
  int get crc => 0x68f3e4eb;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    e.writeBool(enabled);
  }
}

class ChannelsReportAntiSpamFalsePositiveRequest extends TlObject {
  final InputChannel channel;
  final int msgId;
  ChannelsReportAntiSpamFalsePositiveRequest({required this.channel, required this.msgId, });
  @override
  int get crc => 0xa850a693;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    e.writeInt32(msgId);
  }
}

class ChannelsToggleParticipantsHiddenRequest extends TlObject {
  final InputChannel channel;
  final bool enabled;
  ChannelsToggleParticipantsHiddenRequest({required this.channel, required this.enabled, });
  @override
  int get crc => 0x6a6e7854;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    e.writeBool(enabled);
  }
}

class ChannelsUpdateColorRequest extends TlObject {
  final bool forProfile;
  final InputChannel channel;
  final int? color;
  final int? backgroundEmojiId;
  ChannelsUpdateColorRequest({this.forProfile = false, required this.channel, this.color, this.backgroundEmojiId, });
  @override
  int get crc => 0xd8aa3671;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (forProfile == true ? (1 << 1) : 0) | (color != null ? (1 << 2) : 0) | (backgroundEmojiId != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    channel.encode(e);
    if (color != null) { e.writeInt32(color!); }
    if (backgroundEmojiId != null) { e.writeInt64(backgroundEmojiId!); }
  }
}

class ChannelsToggleViewForumAsMessagesRequest extends TlObject {
  final InputChannel channel;
  final bool enabled;
  ChannelsToggleViewForumAsMessagesRequest({required this.channel, required this.enabled, });
  @override
  int get crc => 0x9738bb15;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    e.writeBool(enabled);
  }
}

class ChannelsGetChannelRecommendationsRequest extends TlObject {
  final InputChannel? channel;
  ChannelsGetChannelRecommendationsRequest({this.channel, });
  @override
  int get crc => 0x25a71742;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (channel != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    if (channel != null) { channel!.encode(e); }
  }
}

class ChannelsUpdateEmojiStatusRequest extends TlObject {
  final InputChannel channel;
  final EmojiStatus emojiStatus;
  ChannelsUpdateEmojiStatusRequest({required this.channel, required this.emojiStatus, });
  @override
  int get crc => 0xf0d3e6a8;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    emojiStatus.encode(e);
  }
}

class ChannelsSetBoostsToUnblockRestrictionsRequest extends TlObject {
  final InputChannel channel;
  final int boosts;
  ChannelsSetBoostsToUnblockRestrictionsRequest({required this.channel, required this.boosts, });
  @override
  int get crc => 0xad399cee;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    e.writeInt32(boosts);
  }
}

class ChannelsSetEmojiStickersRequest extends TlObject {
  final InputChannel channel;
  final InputStickerSet stickerset;
  ChannelsSetEmojiStickersRequest({required this.channel, required this.stickerset, });
  @override
  int get crc => 0x3cd930b7;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    stickerset.encode(e);
  }
}

class ChannelsRestrictSponsoredMessagesRequest extends TlObject {
  final InputChannel channel;
  final bool restricted;
  ChannelsRestrictSponsoredMessagesRequest({required this.channel, required this.restricted, });
  @override
  int get crc => 0x9ae91519;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    e.writeBool(restricted);
  }
}

class ChannelsSearchPostsRequest extends TlObject {
  final String? hashtag;
  final String? query;
  final int offsetRate;
  final InputPeer offsetPeer;
  final int offsetId;
  final int limit;
  final int? allowPaidStars;
  ChannelsSearchPostsRequest({this.hashtag, this.query, required this.offsetRate, required this.offsetPeer, required this.offsetId, required this.limit, this.allowPaidStars, });
  @override
  int get crc => 0xf2c4f24d;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (hashtag != null ? (1 << 0) : 0) | (query != null ? (1 << 1) : 0) | (allowPaidStars != null ? (1 << 2) : 0);
    e.writeUint32(flags);
    if (hashtag != null) { e.writeString(hashtag!); }
    if (query != null) { e.writeString(query!); }
    e.writeInt32(offsetRate);
    offsetPeer.encode(e);
    e.writeInt32(offsetId);
    e.writeInt32(limit);
    if (allowPaidStars != null) { e.writeInt64(allowPaidStars!); }
  }
}

class ChannelsUpdatePaidMessagesPriceRequest extends TlObject {
  final bool broadcastMessagesAllowed;
  final InputChannel channel;
  final int sendPaidMessagesStars;
  ChannelsUpdatePaidMessagesPriceRequest({this.broadcastMessagesAllowed = false, required this.channel, required this.sendPaidMessagesStars, });
  @override
  int get crc => 0x4b12327b;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (broadcastMessagesAllowed == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    channel.encode(e);
    e.writeInt64(sendPaidMessagesStars);
  }
}

class ChannelsToggleAutotranslationRequest extends TlObject {
  final InputChannel channel;
  final bool enabled;
  ChannelsToggleAutotranslationRequest({required this.channel, required this.enabled, });
  @override
  int get crc => 0x167fc0a1;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    e.writeBool(enabled);
  }
}

class ChannelsGetMessageAuthorRequest extends TlObject {
  final InputChannel channel;
  final int id;
  ChannelsGetMessageAuthorRequest({required this.channel, required this.id, });
  @override
  int get crc => 0xece2a0e6;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    e.writeInt32(id);
  }
}

class ChannelsCheckSearchPostsFloodRequest extends TlObject {
  final String? query;
  ChannelsCheckSearchPostsFloodRequest({this.query, });
  @override
  int get crc => 0x22567115;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (query != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    if (query != null) { e.writeString(query!); }
  }
}

class ChannelsSetMainProfileTabRequest extends TlObject {
  final InputChannel channel;
  final ProfileTab tab;
  ChannelsSetMainProfileTabRequest({required this.channel, required this.tab, });
  @override
  int get crc => 0x3583fcb1;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    tab.encode(e);
  }
}

class BotsSendCustomRequestRequest extends TlObject {
  final String customMethod;
  final DataJSON params;
  BotsSendCustomRequestRequest({required this.customMethod, required this.params, });
  @override
  int get crc => 0xaa2769ed;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(customMethod);
    params.encode(e);
  }
}

class BotsAnswerWebhookJSONQueryRequest extends TlObject {
  final int queryId;
  final DataJSON data;
  BotsAnswerWebhookJSONQueryRequest({required this.queryId, required this.data, });
  @override
  int get crc => 0xe6213f4d;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(queryId);
    data.encode(e);
  }
}

class BotsSetBotCommandsRequest extends TlObject {
  final BotCommandScope scope;
  final String langCode;
  final List<BotCommand> commands;
  BotsSetBotCommandsRequest({required this.scope, required this.langCode, required this.commands, });
  @override
  int get crc => 0x517165a;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    scope.encode(e);
    e.writeString(langCode);
    e.writeCrc(0x1cb5c415); e.writeInt32(commands.length); for (final item in commands) { item.encode(e); }
  }
}

class BotsResetBotCommandsRequest extends TlObject {
  final BotCommandScope scope;
  final String langCode;
  BotsResetBotCommandsRequest({required this.scope, required this.langCode, });
  @override
  int get crc => 0x3d8de0f9;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    scope.encode(e);
    e.writeString(langCode);
  }
}

class BotsGetBotCommandsRequest extends TlObject {
  final BotCommandScope scope;
  final String langCode;
  BotsGetBotCommandsRequest({required this.scope, required this.langCode, });
  @override
  int get crc => 0xe34c0dd6;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    scope.encode(e);
    e.writeString(langCode);
  }
}

class BotsSetBotMenuButtonRequest extends TlObject {
  final InputUser userId;
  final BotMenuButton button;
  BotsSetBotMenuButtonRequest({required this.userId, required this.button, });
  @override
  int get crc => 0x4504d54f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    userId.encode(e);
    button.encode(e);
  }
}

class BotsGetBotMenuButtonRequest extends TlObject {
  final InputUser userId;
  BotsGetBotMenuButtonRequest({required this.userId, });
  @override
  int get crc => 0x9c60eb28;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    userId.encode(e);
  }
}

class BotsSetBotBroadcastDefaultAdminRightsRequest extends TlObject {
  final ChatAdminRights adminRights;
  BotsSetBotBroadcastDefaultAdminRightsRequest({required this.adminRights, });
  @override
  int get crc => 0x788464e1;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    adminRights.encode(e);
  }
}

class BotsSetBotGroupDefaultAdminRightsRequest extends TlObject {
  final ChatAdminRights adminRights;
  BotsSetBotGroupDefaultAdminRightsRequest({required this.adminRights, });
  @override
  int get crc => 0x925ec9ea;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    adminRights.encode(e);
  }
}

class BotsSetBotInfoRequest extends TlObject {
  final InputUser? bot;
  final String langCode;
  final String? name;
  final String? about;
  final String? description;
  BotsSetBotInfoRequest({this.bot, required this.langCode, this.name, this.about, this.description, });
  @override
  int get crc => 0x10cf3123;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (bot != null ? (1 << 2) : 0) | (name != null ? (1 << 3) : 0) | (about != null ? (1 << 0) : 0) | (description != null ? (1 << 1) : 0);
    e.writeUint32(flags);
    if (bot != null) { bot!.encode(e); }
    e.writeString(langCode);
    if (name != null) { e.writeString(name!); }
    if (about != null) { e.writeString(about!); }
    if (description != null) { e.writeString(description!); }
  }
}

class BotsGetBotInfoRequest extends TlObject {
  final InputUser? bot;
  final String langCode;
  BotsGetBotInfoRequest({this.bot, required this.langCode, });
  @override
  int get crc => 0xdcd914fd;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (bot != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    if (bot != null) { bot!.encode(e); }
    e.writeString(langCode);
  }
}

class BotsReorderUsernamesRequest extends TlObject {
  final InputUser bot;
  final List<String> order;
  BotsReorderUsernamesRequest({required this.bot, required this.order, });
  @override
  int get crc => 0x9709b1c2;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    bot.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(order.length); for (final item in order) { e.writeString(item); }
  }
}

class BotsToggleUsernameRequest extends TlObject {
  final InputUser bot;
  final String username;
  final bool active;
  BotsToggleUsernameRequest({required this.bot, required this.username, required this.active, });
  @override
  int get crc => 0x53ca973;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    bot.encode(e);
    e.writeString(username);
    e.writeBool(active);
  }
}

class BotsCanSendMessageRequest extends TlObject {
  final InputUser bot;
  BotsCanSendMessageRequest({required this.bot, });
  @override
  int get crc => 0x1359f4e6;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    bot.encode(e);
  }
}

class BotsAllowSendMessageRequest extends TlObject {
  final InputUser bot;
  BotsAllowSendMessageRequest({required this.bot, });
  @override
  int get crc => 0xf132e3ef;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    bot.encode(e);
  }
}

class BotsInvokeWebViewCustomMethodRequest extends TlObject {
  final InputUser bot;
  final String customMethod;
  final DataJSON params;
  BotsInvokeWebViewCustomMethodRequest({required this.bot, required this.customMethod, required this.params, });
  @override
  int get crc => 0x87fc5e7;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    bot.encode(e);
    e.writeString(customMethod);
    params.encode(e);
  }
}

class BotsGetPopularAppBotsRequest extends TlObject {
  final String offset;
  final int limit;
  BotsGetPopularAppBotsRequest({required this.offset, required this.limit, });
  @override
  int get crc => 0xc2510192;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(offset);
    e.writeInt32(limit);
  }
}

class BotsAddPreviewMediaRequest extends TlObject {
  final InputUser bot;
  final String langCode;
  final InputMedia media;
  BotsAddPreviewMediaRequest({required this.bot, required this.langCode, required this.media, });
  @override
  int get crc => 0x17aeb75a;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    bot.encode(e);
    e.writeString(langCode);
    media.encode(e);
  }
}

class BotsEditPreviewMediaRequest extends TlObject {
  final InputUser bot;
  final String langCode;
  final InputMedia media;
  final InputMedia newMedia;
  BotsEditPreviewMediaRequest({required this.bot, required this.langCode, required this.media, required this.newMedia, });
  @override
  int get crc => 0x8525606f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    bot.encode(e);
    e.writeString(langCode);
    media.encode(e);
    newMedia.encode(e);
  }
}

class BotsDeletePreviewMediaRequest extends TlObject {
  final InputUser bot;
  final String langCode;
  final List<InputMedia> media;
  BotsDeletePreviewMediaRequest({required this.bot, required this.langCode, required this.media, });
  @override
  int get crc => 0x2d0135b3;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    bot.encode(e);
    e.writeString(langCode);
    e.writeCrc(0x1cb5c415); e.writeInt32(media.length); for (final item in media) { item.encode(e); }
  }
}

class BotsReorderPreviewMediasRequest extends TlObject {
  final InputUser bot;
  final String langCode;
  final List<InputMedia> order;
  BotsReorderPreviewMediasRequest({required this.bot, required this.langCode, required this.order, });
  @override
  int get crc => 0xb627f3aa;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    bot.encode(e);
    e.writeString(langCode);
    e.writeCrc(0x1cb5c415); e.writeInt32(order.length); for (final item in order) { item.encode(e); }
  }
}

class BotsGetPreviewInfoRequest extends TlObject {
  final InputUser bot;
  final String langCode;
  BotsGetPreviewInfoRequest({required this.bot, required this.langCode, });
  @override
  int get crc => 0x423ab3ad;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    bot.encode(e);
    e.writeString(langCode);
  }
}

class BotsGetPreviewMediasRequest extends TlObject {
  final InputUser bot;
  BotsGetPreviewMediasRequest({required this.bot, });
  @override
  int get crc => 0xa2a5594d;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    bot.encode(e);
  }
}

class BotsUpdateUserEmojiStatusRequest extends TlObject {
  final InputUser userId;
  final EmojiStatus emojiStatus;
  BotsUpdateUserEmojiStatusRequest({required this.userId, required this.emojiStatus, });
  @override
  int get crc => 0xed9f30c5;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    userId.encode(e);
    emojiStatus.encode(e);
  }
}

class BotsToggleUserEmojiStatusPermissionRequest extends TlObject {
  final InputUser bot;
  final bool enabled;
  BotsToggleUserEmojiStatusPermissionRequest({required this.bot, required this.enabled, });
  @override
  int get crc => 0x6de6392;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    bot.encode(e);
    e.writeBool(enabled);
  }
}

class BotsCheckDownloadFileParamsRequest extends TlObject {
  final InputUser bot;
  final String fileName;
  final String url;
  BotsCheckDownloadFileParamsRequest({required this.bot, required this.fileName, required this.url, });
  @override
  int get crc => 0x50077589;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    bot.encode(e);
    e.writeString(fileName);
    e.writeString(url);
  }
}

class BotsGetAdminedBotsRequest extends TlObject {
  BotsGetAdminedBotsRequest();
  @override
  int get crc => 0xb0711d83;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class BotsUpdateStarRefProgramRequest extends TlObject {
  final InputUser bot;
  final int commissionPermille;
  final int? durationMonths;
  BotsUpdateStarRefProgramRequest({required this.bot, required this.commissionPermille, this.durationMonths, });
  @override
  int get crc => 0x778b5ab3;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (durationMonths != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    bot.encode(e);
    e.writeInt32(commissionPermille);
    if (durationMonths != null) { e.writeInt32(durationMonths!); }
  }
}

class BotsSetCustomVerificationRequest extends TlObject {
  final bool enabled;
  final InputUser? bot;
  final InputPeer peer;
  final String? customDescription;
  BotsSetCustomVerificationRequest({this.enabled = false, this.bot, required this.peer, this.customDescription, });
  @override
  int get crc => 0x8b89dfbd;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (enabled == true ? (1 << 1) : 0) | (bot != null ? (1 << 0) : 0) | (customDescription != null ? (1 << 2) : 0);
    e.writeUint32(flags);
    if (bot != null) { bot!.encode(e); }
    peer.encode(e);
    if (customDescription != null) { e.writeString(customDescription!); }
  }
}

class BotsGetBotRecommendationsRequest extends TlObject {
  final InputUser bot;
  BotsGetBotRecommendationsRequest({required this.bot, });
  @override
  int get crc => 0xa1b70815;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    bot.encode(e);
  }
}

class BotsCheckUsernameRequest extends TlObject {
  final String username;
  BotsCheckUsernameRequest({required this.username, });
  @override
  int get crc => 0x87f2219b;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(username);
  }
}

class BotsCreateBotRequest extends TlObject {
  final bool viaDeeplink;
  final String name;
  final String username;
  final InputUser managerId;
  BotsCreateBotRequest({this.viaDeeplink = false, required this.name, required this.username, required this.managerId, });
  @override
  int get crc => 0xe5b17f2b;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (viaDeeplink == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    e.writeString(name);
    e.writeString(username);
    managerId.encode(e);
  }
}

class BotsExportBotTokenRequest extends TlObject {
  final InputUser bot;
  final bool revoke;
  BotsExportBotTokenRequest({required this.bot, required this.revoke, });
  @override
  int get crc => 0xbd0d99eb;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    bot.encode(e);
    e.writeBool(revoke);
  }
}

class BotsRequestWebViewButtonRequest extends TlObject {
  final InputUser userId;
  final KeyboardButton button;
  BotsRequestWebViewButtonRequest({required this.userId, required this.button, });
  @override
  int get crc => 0x31a2a35e;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    userId.encode(e);
    button.encode(e);
  }
}

class BotsGetRequestedWebViewButtonRequest extends TlObject {
  final InputUser bot;
  final String webappReqId;
  BotsGetRequestedWebViewButtonRequest({required this.bot, required this.webappReqId, });
  @override
  int get crc => 0xbf25b7f3;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    bot.encode(e);
    e.writeString(webappReqId);
  }
}

class BotsGetAccessSettingsRequest extends TlObject {
  final InputUser bot;
  BotsGetAccessSettingsRequest({required this.bot, });
  @override
  int get crc => 0x213853a3;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    bot.encode(e);
  }
}

class BotsEditAccessSettingsRequest extends TlObject {
  final bool restricted;
  final InputUser bot;
  final List<InputUser>? addUsers;
  BotsEditAccessSettingsRequest({this.restricted = false, required this.bot, this.addUsers, });
  @override
  int get crc => 0x31813cd8;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (restricted == true ? (1 << 0) : 0) | (addUsers != null ? (1 << 1) : 0);
    e.writeUint32(flags);
    bot.encode(e);
    if (addUsers != null) { e.writeCrc(0x1cb5c415); e.writeInt32(addUsers!.length); for (final item in addUsers!) { item.encode(e); } }
  }
}

class BotsSetJoinChatResultsRequest extends TlObject {
  final int queryId;
  final JoinChatBotResult result;
  BotsSetJoinChatResultsRequest({required this.queryId, required this.result, });
  @override
  int get crc => 0xe71a4810;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(queryId);
    result.encode(e);
  }
}

class PaymentsGetPaymentFormRequest extends TlObject {
  final InputInvoice invoice;
  final DataJSON? themeParams;
  PaymentsGetPaymentFormRequest({required this.invoice, this.themeParams, });
  @override
  int get crc => 0x37148dbb;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (themeParams != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    invoice.encode(e);
    if (themeParams != null) { themeParams!.encode(e); }
  }
}

class PaymentsGetPaymentReceiptRequest extends TlObject {
  final InputPeer peer;
  final int msgId;
  PaymentsGetPaymentReceiptRequest({required this.peer, required this.msgId, });
  @override
  int get crc => 0x2478d1cc;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(msgId);
  }
}

class PaymentsValidateRequestedInfoRequest extends TlObject {
  final bool save;
  final InputInvoice invoice;
  final PaymentRequestedInfo info;
  PaymentsValidateRequestedInfoRequest({this.save = false, required this.invoice, required this.info, });
  @override
  int get crc => 0xb6c8f12b;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (save == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    invoice.encode(e);
    info.encode(e);
  }
}

class PaymentsSendPaymentFormRequest extends TlObject {
  final int formId;
  final InputInvoice invoice;
  final String? requestedInfoId;
  final String? shippingOptionId;
  final InputPaymentCredentials credentials;
  final int? tipAmount;
  PaymentsSendPaymentFormRequest({required this.formId, required this.invoice, this.requestedInfoId, this.shippingOptionId, required this.credentials, this.tipAmount, });
  @override
  int get crc => 0x2d03522f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (requestedInfoId != null ? (1 << 0) : 0) | (shippingOptionId != null ? (1 << 1) : 0) | (tipAmount != null ? (1 << 2) : 0);
    e.writeUint32(flags);
    e.writeInt64(formId);
    invoice.encode(e);
    if (requestedInfoId != null) { e.writeString(requestedInfoId!); }
    if (shippingOptionId != null) { e.writeString(shippingOptionId!); }
    credentials.encode(e);
    if (tipAmount != null) { e.writeInt64(tipAmount!); }
  }
}

class PaymentsGetSavedInfoRequest extends TlObject {
  PaymentsGetSavedInfoRequest();
  @override
  int get crc => 0x227d824b;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class PaymentsClearSavedInfoRequest extends TlObject {
  final bool credentials;
  final bool info;
  PaymentsClearSavedInfoRequest({this.credentials = false, this.info = false, });
  @override
  int get crc => 0xd83d70c1;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (credentials == true ? (1 << 0) : 0) | (info == true ? (1 << 1) : 0);
    e.writeUint32(flags);
  }
}

class PaymentsGetBankCardDataRequest extends TlObject {
  final String number;
  PaymentsGetBankCardDataRequest({required this.number, });
  @override
  int get crc => 0x2e79d779;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(number);
  }
}

class PaymentsExportInvoiceRequest extends TlObject {
  final InputMedia invoiceMedia;
  PaymentsExportInvoiceRequest({required this.invoiceMedia, });
  @override
  int get crc => 0xf91b065;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    invoiceMedia.encode(e);
  }
}

class PaymentsAssignAppStoreTransactionRequest extends TlObject {
  final Uint8List receipt;
  final InputStorePaymentPurpose purpose;
  PaymentsAssignAppStoreTransactionRequest({required this.receipt, required this.purpose, });
  @override
  int get crc => 0x80ed747d;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeBytes(receipt);
    purpose.encode(e);
  }
}

class PaymentsAssignPlayMarketTransactionRequest extends TlObject {
  final DataJSON receipt;
  final InputStorePaymentPurpose purpose;
  PaymentsAssignPlayMarketTransactionRequest({required this.receipt, required this.purpose, });
  @override
  int get crc => 0xdffd50d3;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    receipt.encode(e);
    purpose.encode(e);
  }
}

class PaymentsGetPremiumGiftCodeOptionsRequest extends TlObject {
  final InputPeer? boostPeer;
  PaymentsGetPremiumGiftCodeOptionsRequest({this.boostPeer, });
  @override
  int get crc => 0x2757ba54;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (boostPeer != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    if (boostPeer != null) { boostPeer!.encode(e); }
  }
}

class PaymentsCheckGiftCodeRequest extends TlObject {
  final String slug;
  PaymentsCheckGiftCodeRequest({required this.slug, });
  @override
  int get crc => 0x8e51b4c1;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(slug);
  }
}

class PaymentsApplyGiftCodeRequest extends TlObject {
  final String slug;
  PaymentsApplyGiftCodeRequest({required this.slug, });
  @override
  int get crc => 0xf6e26854;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(slug);
  }
}

class PaymentsGetGiveawayInfoRequest extends TlObject {
  final InputPeer peer;
  final int msgId;
  PaymentsGetGiveawayInfoRequest({required this.peer, required this.msgId, });
  @override
  int get crc => 0xf4239425;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(msgId);
  }
}

class PaymentsLaunchPrepaidGiveawayRequest extends TlObject {
  final InputPeer peer;
  final int giveawayId;
  final InputStorePaymentPurpose purpose;
  PaymentsLaunchPrepaidGiveawayRequest({required this.peer, required this.giveawayId, required this.purpose, });
  @override
  int get crc => 0x5ff58f20;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt64(giveawayId);
    purpose.encode(e);
  }
}

class PaymentsGetStarsTopupOptionsRequest extends TlObject {
  PaymentsGetStarsTopupOptionsRequest();
  @override
  int get crc => 0xc00ec7d3;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class PaymentsGetStarsStatusRequest extends TlObject {
  final bool ton;
  final InputPeer peer;
  PaymentsGetStarsStatusRequest({this.ton = false, required this.peer, });
  @override
  int get crc => 0x4ea9b3bf;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (ton == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
  }
}

class PaymentsGetStarsTransactionsRequest extends TlObject {
  final bool inbound;
  final bool outbound;
  final bool ascending;
  final bool ton;
  final String? subscriptionId;
  final InputPeer peer;
  final String offset;
  final int limit;
  PaymentsGetStarsTransactionsRequest({this.inbound = false, this.outbound = false, this.ascending = false, this.ton = false, this.subscriptionId, required this.peer, required this.offset, required this.limit, });
  @override
  int get crc => 0x69da4557;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (inbound == true ? (1 << 0) : 0) | (outbound == true ? (1 << 1) : 0) | (ascending == true ? (1 << 2) : 0) | (ton == true ? (1 << 4) : 0) | (subscriptionId != null ? (1 << 3) : 0);
    e.writeUint32(flags);
    if (subscriptionId != null) { e.writeString(subscriptionId!); }
    peer.encode(e);
    e.writeString(offset);
    e.writeInt32(limit);
  }
}

class PaymentsSendStarsFormRequest extends TlObject {
  final int formId;
  final InputInvoice invoice;
  PaymentsSendStarsFormRequest({required this.formId, required this.invoice, });
  @override
  int get crc => 0x7998c914;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(formId);
    invoice.encode(e);
  }
}

class PaymentsRefundStarsChargeRequest extends TlObject {
  final InputUser userId;
  final String chargeId;
  PaymentsRefundStarsChargeRequest({required this.userId, required this.chargeId, });
  @override
  int get crc => 0x25ae8f4a;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    userId.encode(e);
    e.writeString(chargeId);
  }
}

class PaymentsGetStarsRevenueStatsRequest extends TlObject {
  final bool dark;
  final bool ton;
  final InputPeer peer;
  PaymentsGetStarsRevenueStatsRequest({this.dark = false, this.ton = false, required this.peer, });
  @override
  int get crc => 0xd91ffad6;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (dark == true ? (1 << 0) : 0) | (ton == true ? (1 << 1) : 0);
    e.writeUint32(flags);
    peer.encode(e);
  }
}

class PaymentsGetStarsRevenueWithdrawalUrlRequest extends TlObject {
  final bool ton;
  final InputPeer peer;
  final int? amount;
  final InputCheckPasswordSRP password;
  PaymentsGetStarsRevenueWithdrawalUrlRequest({this.ton = false, required this.peer, this.amount, required this.password, });
  @override
  int get crc => 0x2433dc92;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (ton == true ? (1 << 0) : 0) | (amount != null ? (1 << 1) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    if (amount != null) { e.writeInt64(amount!); }
    password.encode(e);
  }
}

class PaymentsGetStarsRevenueAdsAccountUrlRequest extends TlObject {
  final InputPeer peer;
  PaymentsGetStarsRevenueAdsAccountUrlRequest({required this.peer, });
  @override
  int get crc => 0xd1d7efc5;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
  }
}

class PaymentsGetStarsTransactionsByIDRequest extends TlObject {
  final bool ton;
  final InputPeer peer;
  final List<InputStarsTransaction> id;
  PaymentsGetStarsTransactionsByIDRequest({this.ton = false, required this.peer, required this.id, });
  @override
  int get crc => 0x2dca16b8;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (ton == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { item.encode(e); }
  }
}

class PaymentsGetStarsGiftOptionsRequest extends TlObject {
  final InputUser? userId;
  PaymentsGetStarsGiftOptionsRequest({this.userId, });
  @override
  int get crc => 0xd3c96bc8;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (userId != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    if (userId != null) { userId!.encode(e); }
  }
}

class PaymentsGetStarsSubscriptionsRequest extends TlObject {
  final bool missingBalance;
  final InputPeer peer;
  final String offset;
  PaymentsGetStarsSubscriptionsRequest({this.missingBalance = false, required this.peer, required this.offset, });
  @override
  int get crc => 0x32512c5;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (missingBalance == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeString(offset);
  }
}

class PaymentsChangeStarsSubscriptionRequest extends TlObject {
  final InputPeer peer;
  final String subscriptionId;
  final bool? canceled;
  PaymentsChangeStarsSubscriptionRequest({required this.peer, required this.subscriptionId, this.canceled, });
  @override
  int get crc => 0xc7770878;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (canceled != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeString(subscriptionId);
    if (canceled != null) { e.writeBool(canceled!); }
  }
}

class PaymentsFulfillStarsSubscriptionRequest extends TlObject {
  final InputPeer peer;
  final String subscriptionId;
  PaymentsFulfillStarsSubscriptionRequest({required this.peer, required this.subscriptionId, });
  @override
  int get crc => 0xcc5bebb3;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeString(subscriptionId);
  }
}

class PaymentsGetStarsGiveawayOptionsRequest extends TlObject {
  PaymentsGetStarsGiveawayOptionsRequest();
  @override
  int get crc => 0xbd1efd3e;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class PaymentsGetStarGiftsRequest extends TlObject {
  final int hash;
  PaymentsGetStarGiftsRequest({required this.hash, });
  @override
  int get crc => 0xc4563590;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(hash);
  }
}

class PaymentsSaveStarGiftRequest extends TlObject {
  final bool unsave;
  final InputSavedStarGift stargift;
  PaymentsSaveStarGiftRequest({this.unsave = false, required this.stargift, });
  @override
  int get crc => 0x2a2a697c;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (unsave == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    stargift.encode(e);
  }
}

class PaymentsConvertStarGiftRequest extends TlObject {
  final InputSavedStarGift stargift;
  PaymentsConvertStarGiftRequest({required this.stargift, });
  @override
  int get crc => 0x74bf076b;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    stargift.encode(e);
  }
}

class PaymentsBotCancelStarsSubscriptionRequest extends TlObject {
  final bool restore;
  final InputUser userId;
  final String chargeId;
  PaymentsBotCancelStarsSubscriptionRequest({this.restore = false, required this.userId, required this.chargeId, });
  @override
  int get crc => 0x6dfa0622;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (restore == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    userId.encode(e);
    e.writeString(chargeId);
  }
}

class PaymentsGetConnectedStarRefBotsRequest extends TlObject {
  final InputPeer peer;
  final int? offsetDate;
  final String? offsetLink;
  final int limit;
  PaymentsGetConnectedStarRefBotsRequest({required this.peer, this.offsetDate, this.offsetLink, required this.limit, });
  @override
  int get crc => 0x5869a553;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (offsetDate != null ? (1 << 2) : 0) | (offsetLink != null ? (1 << 2) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    if (offsetDate != null) { e.writeInt32(offsetDate!); }
    if (offsetLink != null) { e.writeString(offsetLink!); }
    e.writeInt32(limit);
  }
}

class PaymentsGetConnectedStarRefBotRequest extends TlObject {
  final InputPeer peer;
  final InputUser bot;
  PaymentsGetConnectedStarRefBotRequest({required this.peer, required this.bot, });
  @override
  int get crc => 0xb7d998f0;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    bot.encode(e);
  }
}

class PaymentsGetSuggestedStarRefBotsRequest extends TlObject {
  final bool orderByRevenue;
  final bool orderByDate;
  final InputPeer peer;
  final String offset;
  final int limit;
  PaymentsGetSuggestedStarRefBotsRequest({this.orderByRevenue = false, this.orderByDate = false, required this.peer, required this.offset, required this.limit, });
  @override
  int get crc => 0xd6b48f7;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (orderByRevenue == true ? (1 << 0) : 0) | (orderByDate == true ? (1 << 1) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeString(offset);
    e.writeInt32(limit);
  }
}

class PaymentsConnectStarRefBotRequest extends TlObject {
  final InputPeer peer;
  final InputUser bot;
  PaymentsConnectStarRefBotRequest({required this.peer, required this.bot, });
  @override
  int get crc => 0x7ed5348a;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    bot.encode(e);
  }
}

class PaymentsEditConnectedStarRefBotRequest extends TlObject {
  final bool revoked;
  final InputPeer peer;
  final String link;
  PaymentsEditConnectedStarRefBotRequest({this.revoked = false, required this.peer, required this.link, });
  @override
  int get crc => 0xe4fca4a3;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (revoked == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeString(link);
  }
}

class PaymentsGetStarGiftUpgradePreviewRequest extends TlObject {
  final int giftId;
  PaymentsGetStarGiftUpgradePreviewRequest({required this.giftId, });
  @override
  int get crc => 0x9c9abcb1;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(giftId);
  }
}

class PaymentsUpgradeStarGiftRequest extends TlObject {
  final bool keepOriginalDetails;
  final InputSavedStarGift stargift;
  PaymentsUpgradeStarGiftRequest({this.keepOriginalDetails = false, required this.stargift, });
  @override
  int get crc => 0xaed6e4f5;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (keepOriginalDetails == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    stargift.encode(e);
  }
}

class PaymentsTransferStarGiftRequest extends TlObject {
  final InputSavedStarGift stargift;
  final InputPeer toId;
  PaymentsTransferStarGiftRequest({required this.stargift, required this.toId, });
  @override
  int get crc => 0x7f18176a;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    stargift.encode(e);
    toId.encode(e);
  }
}

class PaymentsGetUniqueStarGiftRequest extends TlObject {
  final String slug;
  PaymentsGetUniqueStarGiftRequest({required this.slug, });
  @override
  int get crc => 0xa1974d72;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(slug);
  }
}

class PaymentsGetSavedStarGiftsRequest extends TlObject {
  final bool excludeUnsaved;
  final bool excludeSaved;
  final bool excludeUnlimited;
  final bool excludeUnique;
  final bool sortByValue;
  final bool excludeUpgradable;
  final bool excludeUnupgradable;
  final bool peerColorAvailable;
  final bool excludeHosted;
  final InputPeer peer;
  final int? collectionId;
  final String offset;
  final int limit;
  PaymentsGetSavedStarGiftsRequest({this.excludeUnsaved = false, this.excludeSaved = false, this.excludeUnlimited = false, this.excludeUnique = false, this.sortByValue = false, this.excludeUpgradable = false, this.excludeUnupgradable = false, this.peerColorAvailable = false, this.excludeHosted = false, required this.peer, this.collectionId, required this.offset, required this.limit, });
  @override
  int get crc => 0xa319e569;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (excludeUnsaved == true ? (1 << 0) : 0) | (excludeSaved == true ? (1 << 1) : 0) | (excludeUnlimited == true ? (1 << 2) : 0) | (excludeUnique == true ? (1 << 4) : 0) | (sortByValue == true ? (1 << 5) : 0) | (excludeUpgradable == true ? (1 << 7) : 0) | (excludeUnupgradable == true ? (1 << 8) : 0) | (peerColorAvailable == true ? (1 << 9) : 0) | (excludeHosted == true ? (1 << 10) : 0) | (collectionId != null ? (1 << 6) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    if (collectionId != null) { e.writeInt32(collectionId!); }
    e.writeString(offset);
    e.writeInt32(limit);
  }
}

class PaymentsGetSavedStarGiftRequest extends TlObject {
  final List<InputSavedStarGift> stargift;
  PaymentsGetSavedStarGiftRequest({required this.stargift, });
  @override
  int get crc => 0xb455a106;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeCrc(0x1cb5c415); e.writeInt32(stargift.length); for (final item in stargift) { item.encode(e); }
  }
}

class PaymentsGetStarGiftWithdrawalUrlRequest extends TlObject {
  final InputSavedStarGift stargift;
  final InputCheckPasswordSRP password;
  PaymentsGetStarGiftWithdrawalUrlRequest({required this.stargift, required this.password, });
  @override
  int get crc => 0xd06e93a8;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    stargift.encode(e);
    password.encode(e);
  }
}

class PaymentsToggleChatStarGiftNotificationsRequest extends TlObject {
  final bool enabled;
  final InputPeer peer;
  PaymentsToggleChatStarGiftNotificationsRequest({this.enabled = false, required this.peer, });
  @override
  int get crc => 0x60eaefa1;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (enabled == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
  }
}

class PaymentsToggleStarGiftsPinnedToTopRequest extends TlObject {
  final InputPeer peer;
  final List<InputSavedStarGift> stargift;
  PaymentsToggleStarGiftsPinnedToTopRequest({required this.peer, required this.stargift, });
  @override
  int get crc => 0x1513e7b0;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(stargift.length); for (final item in stargift) { item.encode(e); }
  }
}

class PaymentsCanPurchaseStoreRequest extends TlObject {
  final InputStorePaymentPurpose purpose;
  PaymentsCanPurchaseStoreRequest({required this.purpose, });
  @override
  int get crc => 0x4fdc5ea7;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    purpose.encode(e);
  }
}

class PaymentsGetResaleStarGiftsRequest extends TlObject {
  final bool sortByPrice;
  final bool sortByNum;
  final bool forCraft;
  final bool starsOnly;
  final int? attributesHash;
  final int giftId;
  final List<StarGiftAttributeId>? attributes;
  final String offset;
  final int limit;
  PaymentsGetResaleStarGiftsRequest({this.sortByPrice = false, this.sortByNum = false, this.forCraft = false, this.starsOnly = false, this.attributesHash, required this.giftId, this.attributes, required this.offset, required this.limit, });
  @override
  int get crc => 0x7a5fa236;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (sortByPrice == true ? (1 << 1) : 0) | (sortByNum == true ? (1 << 2) : 0) | (forCraft == true ? (1 << 4) : 0) | (starsOnly == true ? (1 << 5) : 0) | (attributesHash != null ? (1 << 0) : 0) | (attributes != null ? (1 << 3) : 0);
    e.writeUint32(flags);
    if (attributesHash != null) { e.writeInt64(attributesHash!); }
    e.writeInt64(giftId);
    if (attributes != null) { e.writeCrc(0x1cb5c415); e.writeInt32(attributes!.length); for (final item in attributes!) { item.encode(e); } }
    e.writeString(offset);
    e.writeInt32(limit);
  }
}

class PaymentsUpdateStarGiftPriceRequest extends TlObject {
  final InputSavedStarGift stargift;
  final StarsAmount resellAmount;
  PaymentsUpdateStarGiftPriceRequest({required this.stargift, required this.resellAmount, });
  @override
  int get crc => 0xedbe6ccb;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    stargift.encode(e);
    resellAmount.encode(e);
  }
}

class PaymentsCreateStarGiftCollectionRequest extends TlObject {
  final InputPeer peer;
  final String title;
  final List<InputSavedStarGift> stargift;
  PaymentsCreateStarGiftCollectionRequest({required this.peer, required this.title, required this.stargift, });
  @override
  int get crc => 0x1f4a0e87;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeString(title);
    e.writeCrc(0x1cb5c415); e.writeInt32(stargift.length); for (final item in stargift) { item.encode(e); }
  }
}

class PaymentsUpdateStarGiftCollectionRequest extends TlObject {
  final InputPeer peer;
  final int collectionId;
  final String? title;
  final List<InputSavedStarGift>? deleteStargift;
  final List<InputSavedStarGift>? addStargift;
  final List<InputSavedStarGift>? order;
  PaymentsUpdateStarGiftCollectionRequest({required this.peer, required this.collectionId, this.title, this.deleteStargift, this.addStargift, this.order, });
  @override
  int get crc => 0x4fddbee7;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (title != null ? (1 << 0) : 0) | (deleteStargift != null ? (1 << 1) : 0) | (addStargift != null ? (1 << 2) : 0) | (order != null ? (1 << 3) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeInt32(collectionId);
    if (title != null) { e.writeString(title!); }
    if (deleteStargift != null) { e.writeCrc(0x1cb5c415); e.writeInt32(deleteStargift!.length); for (final item in deleteStargift!) { item.encode(e); } }
    if (addStargift != null) { e.writeCrc(0x1cb5c415); e.writeInt32(addStargift!.length); for (final item in addStargift!) { item.encode(e); } }
    if (order != null) { e.writeCrc(0x1cb5c415); e.writeInt32(order!.length); for (final item in order!) { item.encode(e); } }
  }
}

class PaymentsReorderStarGiftCollectionsRequest extends TlObject {
  final InputPeer peer;
  final List<int> order;
  PaymentsReorderStarGiftCollectionsRequest({required this.peer, required this.order, });
  @override
  int get crc => 0xc32af4cc;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(order.length); for (final item in order) { e.writeInt32(item); }
  }
}

class PaymentsDeleteStarGiftCollectionRequest extends TlObject {
  final InputPeer peer;
  final int collectionId;
  PaymentsDeleteStarGiftCollectionRequest({required this.peer, required this.collectionId, });
  @override
  int get crc => 0xad5648e8;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(collectionId);
  }
}

class PaymentsGetStarGiftCollectionsRequest extends TlObject {
  final InputPeer peer;
  final int hash;
  PaymentsGetStarGiftCollectionsRequest({required this.peer, required this.hash, });
  @override
  int get crc => 0x981b91dd;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt64(hash);
  }
}

class PaymentsGetUniqueStarGiftValueInfoRequest extends TlObject {
  final String slug;
  PaymentsGetUniqueStarGiftValueInfoRequest({required this.slug, });
  @override
  int get crc => 0x4365af6b;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(slug);
  }
}

class PaymentsCheckCanSendGiftRequest extends TlObject {
  final int giftId;
  PaymentsCheckCanSendGiftRequest({required this.giftId, });
  @override
  int get crc => 0xc0c4edc9;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(giftId);
  }
}

class PaymentsGetStarGiftAuctionStateRequest extends TlObject {
  final InputStarGiftAuction auction;
  final int version;
  PaymentsGetStarGiftAuctionStateRequest({required this.auction, required this.version, });
  @override
  int get crc => 0x5c9ff4d6;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    auction.encode(e);
    e.writeInt32(version);
  }
}

class PaymentsGetStarGiftAuctionAcquiredGiftsRequest extends TlObject {
  final int giftId;
  PaymentsGetStarGiftAuctionAcquiredGiftsRequest({required this.giftId, });
  @override
  int get crc => 0x6ba2cbec;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(giftId);
  }
}

class PaymentsGetStarGiftActiveAuctionsRequest extends TlObject {
  final int hash;
  PaymentsGetStarGiftActiveAuctionsRequest({required this.hash, });
  @override
  int get crc => 0xa5d0514d;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(hash);
  }
}

class PaymentsResolveStarGiftOfferRequest extends TlObject {
  final bool decline;
  final int offerMsgId;
  PaymentsResolveStarGiftOfferRequest({this.decline = false, required this.offerMsgId, });
  @override
  int get crc => 0xe9ce781c;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (decline == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    e.writeInt32(offerMsgId);
  }
}

class PaymentsSendStarGiftOfferRequest extends TlObject {
  final InputPeer peer;
  final String slug;
  final StarsAmount price;
  final int duration;
  final int randomId;
  final int? allowPaidStars;
  PaymentsSendStarGiftOfferRequest({required this.peer, required this.slug, required this.price, required this.duration, required this.randomId, this.allowPaidStars, });
  @override
  int get crc => 0x8fb86b41;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (allowPaidStars != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeString(slug);
    price.encode(e);
    e.writeInt32(duration);
    e.writeInt64(randomId);
    if (allowPaidStars != null) { e.writeInt64(allowPaidStars!); }
  }
}

class PaymentsGetStarGiftUpgradeAttributesRequest extends TlObject {
  final int giftId;
  PaymentsGetStarGiftUpgradeAttributesRequest({required this.giftId, });
  @override
  int get crc => 0x6d038b58;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(giftId);
  }
}

class PaymentsGetCraftStarGiftsRequest extends TlObject {
  final int giftId;
  final String offset;
  final int limit;
  PaymentsGetCraftStarGiftsRequest({required this.giftId, required this.offset, required this.limit, });
  @override
  int get crc => 0xfd05dd00;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(giftId);
    e.writeString(offset);
    e.writeInt32(limit);
  }
}

class PaymentsCraftStarGiftRequest extends TlObject {
  final List<InputSavedStarGift> stargift;
  PaymentsCraftStarGiftRequest({required this.stargift, });
  @override
  int get crc => 0xb0f9684f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeCrc(0x1cb5c415); e.writeInt32(stargift.length); for (final item in stargift) { item.encode(e); }
  }
}

class StickersCreateStickerSetRequest extends TlObject {
  final bool masks;
  final bool emojis;
  final bool textColor;
  final InputUser userId;
  final String title;
  final String shortName;
  final InputDocument? thumb;
  final List<InputStickerSetItem> stickers;
  final String? software;
  StickersCreateStickerSetRequest({this.masks = false, this.emojis = false, this.textColor = false, required this.userId, required this.title, required this.shortName, this.thumb, required this.stickers, this.software, });
  @override
  int get crc => 0x9021ab67;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (masks == true ? (1 << 0) : 0) | (emojis == true ? (1 << 5) : 0) | (textColor == true ? (1 << 6) : 0) | (thumb != null ? (1 << 2) : 0) | (software != null ? (1 << 3) : 0);
    e.writeUint32(flags);
    userId.encode(e);
    e.writeString(title);
    e.writeString(shortName);
    if (thumb != null) { thumb!.encode(e); }
    e.writeCrc(0x1cb5c415); e.writeInt32(stickers.length); for (final item in stickers) { item.encode(e); }
    if (software != null) { e.writeString(software!); }
  }
}

class StickersRemoveStickerFromSetRequest extends TlObject {
  final InputDocument sticker;
  StickersRemoveStickerFromSetRequest({required this.sticker, });
  @override
  int get crc => 0xf7760f51;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    sticker.encode(e);
  }
}

class StickersChangeStickerPositionRequest extends TlObject {
  final InputDocument sticker;
  final int position;
  StickersChangeStickerPositionRequest({required this.sticker, required this.position, });
  @override
  int get crc => 0xffb6d4ca;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    sticker.encode(e);
    e.writeInt32(position);
  }
}

class StickersAddStickerToSetRequest extends TlObject {
  final InputStickerSet stickerset;
  final InputStickerSetItem sticker;
  StickersAddStickerToSetRequest({required this.stickerset, required this.sticker, });
  @override
  int get crc => 0x8653febe;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    stickerset.encode(e);
    sticker.encode(e);
  }
}

class StickersSetStickerSetThumbRequest extends TlObject {
  final InputStickerSet stickerset;
  final InputDocument? thumb;
  final int? thumbDocumentId;
  StickersSetStickerSetThumbRequest({required this.stickerset, this.thumb, this.thumbDocumentId, });
  @override
  int get crc => 0xa76a5392;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (thumb != null ? (1 << 0) : 0) | (thumbDocumentId != null ? (1 << 1) : 0);
    e.writeUint32(flags);
    stickerset.encode(e);
    if (thumb != null) { thumb!.encode(e); }
    if (thumbDocumentId != null) { e.writeInt64(thumbDocumentId!); }
  }
}

class StickersCheckShortNameRequest extends TlObject {
  final String shortName;
  StickersCheckShortNameRequest({required this.shortName, });
  @override
  int get crc => 0x284b3639;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(shortName);
  }
}

class StickersSuggestShortNameRequest extends TlObject {
  final String title;
  StickersSuggestShortNameRequest({required this.title, });
  @override
  int get crc => 0x4dafc503;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(title);
  }
}

class StickersChangeStickerRequest extends TlObject {
  final InputDocument sticker;
  final String? emoji;
  final MaskCoords? maskCoords;
  final String? keywords;
  StickersChangeStickerRequest({required this.sticker, this.emoji, this.maskCoords, this.keywords, });
  @override
  int get crc => 0xf5537ebc;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (emoji != null ? (1 << 0) : 0) | (maskCoords != null ? (1 << 1) : 0) | (keywords != null ? (1 << 2) : 0);
    e.writeUint32(flags);
    sticker.encode(e);
    if (emoji != null) { e.writeString(emoji!); }
    if (maskCoords != null) { maskCoords!.encode(e); }
    if (keywords != null) { e.writeString(keywords!); }
  }
}

class StickersRenameStickerSetRequest extends TlObject {
  final InputStickerSet stickerset;
  final String title;
  StickersRenameStickerSetRequest({required this.stickerset, required this.title, });
  @override
  int get crc => 0x124b1c00;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    stickerset.encode(e);
    e.writeString(title);
  }
}

class StickersDeleteStickerSetRequest extends TlObject {
  final InputStickerSet stickerset;
  StickersDeleteStickerSetRequest({required this.stickerset, });
  @override
  int get crc => 0x87704394;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    stickerset.encode(e);
  }
}

class StickersReplaceStickerRequest extends TlObject {
  final InputDocument sticker;
  final InputStickerSetItem newSticker;
  StickersReplaceStickerRequest({required this.sticker, required this.newSticker, });
  @override
  int get crc => 0x4696459a;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    sticker.encode(e);
    newSticker.encode(e);
  }
}

class PhoneGetCallConfigRequest extends TlObject {
  PhoneGetCallConfigRequest();
  @override
  int get crc => 0x55451fa9;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class PhoneRequestCallRequest extends TlObject {
  final bool video;
  final InputUser userId;
  final int randomId;
  final Uint8List gAHash;
  final PhoneCallProtocol protocol;
  PhoneRequestCallRequest({this.video = false, required this.userId, required this.randomId, required this.gAHash, required this.protocol, });
  @override
  int get crc => 0x42ff96ed;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (video == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    userId.encode(e);
    e.writeInt32(randomId);
    e.writeBytes(gAHash);
    protocol.encode(e);
  }
}

class PhoneAcceptCallRequest extends TlObject {
  final InputPhoneCall peer;
  final Uint8List gB;
  final PhoneCallProtocol protocol;
  PhoneAcceptCallRequest({required this.peer, required this.gB, required this.protocol, });
  @override
  int get crc => 0x3bd2b4a0;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeBytes(gB);
    protocol.encode(e);
  }
}

class PhoneConfirmCallRequest extends TlObject {
  final InputPhoneCall peer;
  final Uint8List gA;
  final int keyFingerprint;
  final PhoneCallProtocol protocol;
  PhoneConfirmCallRequest({required this.peer, required this.gA, required this.keyFingerprint, required this.protocol, });
  @override
  int get crc => 0x2efe1722;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeBytes(gA);
    e.writeInt64(keyFingerprint);
    protocol.encode(e);
  }
}

class PhoneReceivedCallRequest extends TlObject {
  final InputPhoneCall peer;
  PhoneReceivedCallRequest({required this.peer, });
  @override
  int get crc => 0x17d54f61;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
  }
}

class PhoneDiscardCallRequest extends TlObject {
  final bool video;
  final InputPhoneCall peer;
  final int duration;
  final PhoneCallDiscardReason reason;
  final int connectionId;
  PhoneDiscardCallRequest({this.video = false, required this.peer, required this.duration, required this.reason, required this.connectionId, });
  @override
  int get crc => 0xb2cbc1c0;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (video == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeInt32(duration);
    reason.encode(e);
    e.writeInt64(connectionId);
  }
}

class PhoneSetCallRatingRequest extends TlObject {
  final bool userInitiative;
  final InputPhoneCall peer;
  final int rating;
  final String comment;
  PhoneSetCallRatingRequest({this.userInitiative = false, required this.peer, required this.rating, required this.comment, });
  @override
  int get crc => 0x59ead627;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (userInitiative == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeInt32(rating);
    e.writeString(comment);
  }
}

class PhoneSaveCallDebugRequest extends TlObject {
  final InputPhoneCall peer;
  final DataJSON debug;
  PhoneSaveCallDebugRequest({required this.peer, required this.debug, });
  @override
  int get crc => 0x277add7e;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    debug.encode(e);
  }
}

class PhoneSendSignalingDataRequest extends TlObject {
  final InputPhoneCall peer;
  final Uint8List data;
  PhoneSendSignalingDataRequest({required this.peer, required this.data, });
  @override
  int get crc => 0xff7a9383;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeBytes(data);
  }
}

class PhoneCreateGroupCallRequest extends TlObject {
  final bool rtmpStream;
  final InputPeer peer;
  final int randomId;
  final String? title;
  final int? scheduleDate;
  PhoneCreateGroupCallRequest({this.rtmpStream = false, required this.peer, required this.randomId, this.title, this.scheduleDate, });
  @override
  int get crc => 0x48cdc6d8;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (rtmpStream == true ? (1 << 2) : 0) | (title != null ? (1 << 0) : 0) | (scheduleDate != null ? (1 << 1) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeInt32(randomId);
    if (title != null) { e.writeString(title!); }
    if (scheduleDate != null) { e.writeInt32(scheduleDate!); }
  }
}

class PhoneJoinGroupCallRequest extends TlObject {
  final bool muted;
  final bool videoStopped;
  final InputGroupCall call;
  final InputPeer joinAs;
  final String? inviteHash;
  final BigInt? publicKey;
  final Uint8List? block;
  final DataJSON params;
  PhoneJoinGroupCallRequest({this.muted = false, this.videoStopped = false, required this.call, required this.joinAs, this.inviteHash, this.publicKey, this.block, required this.params, });
  @override
  int get crc => 0x8fb53057;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (muted == true ? (1 << 0) : 0) | (videoStopped == true ? (1 << 2) : 0) | (inviteHash != null ? (1 << 1) : 0) | (publicKey != null ? (1 << 3) : 0) | (block != null ? (1 << 3) : 0);
    e.writeUint32(flags);
    call.encode(e);
    joinAs.encode(e);
    if (inviteHash != null) { e.writeString(inviteHash!); }
    if (publicKey != null) { e.writeRaw(bigIntToBytes(publicKey!, 32)); }
    if (block != null) { e.writeBytes(block!); }
    params.encode(e);
  }
}

class PhoneLeaveGroupCallRequest extends TlObject {
  final InputGroupCall call;
  final int source;
  PhoneLeaveGroupCallRequest({required this.call, required this.source, });
  @override
  int get crc => 0x500377f9;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    call.encode(e);
    e.writeInt32(source);
  }
}

class PhoneInviteToGroupCallRequest extends TlObject {
  final InputGroupCall call;
  final List<InputUser> users;
  PhoneInviteToGroupCallRequest({required this.call, required this.users, });
  @override
  int get crc => 0x7b393160;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    call.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(users.length); for (final item in users) { item.encode(e); }
  }
}

class PhoneDiscardGroupCallRequest extends TlObject {
  final InputGroupCall call;
  PhoneDiscardGroupCallRequest({required this.call, });
  @override
  int get crc => 0x7a777135;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    call.encode(e);
  }
}

class PhoneToggleGroupCallSettingsRequest extends TlObject {
  final bool resetInviteHash;
  final InputGroupCall call;
  final bool? joinMuted;
  final bool? messagesEnabled;
  final int? sendPaidMessagesStars;
  PhoneToggleGroupCallSettingsRequest({this.resetInviteHash = false, required this.call, this.joinMuted, this.messagesEnabled, this.sendPaidMessagesStars, });
  @override
  int get crc => 0x974392f2;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (resetInviteHash == true ? (1 << 1) : 0) | (joinMuted != null ? (1 << 0) : 0) | (messagesEnabled != null ? (1 << 2) : 0) | (sendPaidMessagesStars != null ? (1 << 3) : 0);
    e.writeUint32(flags);
    call.encode(e);
    if (joinMuted != null) { e.writeBool(joinMuted!); }
    if (messagesEnabled != null) { e.writeBool(messagesEnabled!); }
    if (sendPaidMessagesStars != null) { e.writeInt64(sendPaidMessagesStars!); }
  }
}

class PhoneGetGroupCallRequest extends TlObject {
  final InputGroupCall call;
  final int limit;
  PhoneGetGroupCallRequest({required this.call, required this.limit, });
  @override
  int get crc => 0x41845db;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    call.encode(e);
    e.writeInt32(limit);
  }
}

class PhoneGetGroupParticipantsRequest extends TlObject {
  final InputGroupCall call;
  final List<InputPeer> ids;
  final List<int> sources;
  final String offset;
  final int limit;
  PhoneGetGroupParticipantsRequest({required this.call, required this.ids, required this.sources, required this.offset, required this.limit, });
  @override
  int get crc => 0xc558d8ab;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    call.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(ids.length); for (final item in ids) { item.encode(e); }
    e.writeCrc(0x1cb5c415); e.writeInt32(sources.length); for (final item in sources) { e.writeInt32(item); }
    e.writeString(offset);
    e.writeInt32(limit);
  }
}

class PhoneCheckGroupCallRequest extends TlObject {
  final InputGroupCall call;
  final List<int> sources;
  PhoneCheckGroupCallRequest({required this.call, required this.sources, });
  @override
  int get crc => 0xb59cf977;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    call.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(sources.length); for (final item in sources) { e.writeInt32(item); }
  }
}

class PhoneToggleGroupCallRecordRequest extends TlObject {
  final bool start;
  final bool video;
  final InputGroupCall call;
  final String? title;
  final bool? videoPortrait;
  PhoneToggleGroupCallRecordRequest({this.start = false, this.video = false, required this.call, this.title, this.videoPortrait, });
  @override
  int get crc => 0xf128c708;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (start == true ? (1 << 0) : 0) | (video == true ? (1 << 2) : 0) | (title != null ? (1 << 1) : 0) | (videoPortrait != null ? (1 << 2) : 0);
    e.writeUint32(flags);
    call.encode(e);
    if (title != null) { e.writeString(title!); }
    if (videoPortrait != null) { e.writeBool(videoPortrait!); }
  }
}

class PhoneEditGroupCallParticipantRequest extends TlObject {
  final InputGroupCall call;
  final InputPeer participant;
  final bool? muted;
  final int? volume;
  final bool? raiseHand;
  final bool? videoStopped;
  final bool? videoPaused;
  final bool? presentationPaused;
  PhoneEditGroupCallParticipantRequest({required this.call, required this.participant, this.muted, this.volume, this.raiseHand, this.videoStopped, this.videoPaused, this.presentationPaused, });
  @override
  int get crc => 0xa5273abf;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (muted != null ? (1 << 0) : 0) | (volume != null ? (1 << 1) : 0) | (raiseHand != null ? (1 << 2) : 0) | (videoStopped != null ? (1 << 3) : 0) | (videoPaused != null ? (1 << 4) : 0) | (presentationPaused != null ? (1 << 5) : 0);
    e.writeUint32(flags);
    call.encode(e);
    participant.encode(e);
    if (muted != null) { e.writeBool(muted!); }
    if (volume != null) { e.writeInt32(volume!); }
    if (raiseHand != null) { e.writeBool(raiseHand!); }
    if (videoStopped != null) { e.writeBool(videoStopped!); }
    if (videoPaused != null) { e.writeBool(videoPaused!); }
    if (presentationPaused != null) { e.writeBool(presentationPaused!); }
  }
}

class PhoneEditGroupCallTitleRequest extends TlObject {
  final InputGroupCall call;
  final String title;
  PhoneEditGroupCallTitleRequest({required this.call, required this.title, });
  @override
  int get crc => 0x1ca6ac0a;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    call.encode(e);
    e.writeString(title);
  }
}

class PhoneGetGroupCallJoinAsRequest extends TlObject {
  final InputPeer peer;
  PhoneGetGroupCallJoinAsRequest({required this.peer, });
  @override
  int get crc => 0xef7c213a;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
  }
}

class PhoneExportGroupCallInviteRequest extends TlObject {
  final bool canSelfUnmute;
  final InputGroupCall call;
  PhoneExportGroupCallInviteRequest({this.canSelfUnmute = false, required this.call, });
  @override
  int get crc => 0xe6aa647f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (canSelfUnmute == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    call.encode(e);
  }
}

class PhoneToggleGroupCallStartSubscriptionRequest extends TlObject {
  final InputGroupCall call;
  final bool subscribed;
  PhoneToggleGroupCallStartSubscriptionRequest({required this.call, required this.subscribed, });
  @override
  int get crc => 0x219c34e6;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    call.encode(e);
    e.writeBool(subscribed);
  }
}

class PhoneStartScheduledGroupCallRequest extends TlObject {
  final InputGroupCall call;
  PhoneStartScheduledGroupCallRequest({required this.call, });
  @override
  int get crc => 0x5680e342;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    call.encode(e);
  }
}

class PhoneSaveDefaultGroupCallJoinAsRequest extends TlObject {
  final InputPeer peer;
  final InputPeer joinAs;
  PhoneSaveDefaultGroupCallJoinAsRequest({required this.peer, required this.joinAs, });
  @override
  int get crc => 0x575e1f8c;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    joinAs.encode(e);
  }
}

class PhoneJoinGroupCallPresentationRequest extends TlObject {
  final InputGroupCall call;
  final DataJSON params;
  PhoneJoinGroupCallPresentationRequest({required this.call, required this.params, });
  @override
  int get crc => 0xcbea6bc4;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    call.encode(e);
    params.encode(e);
  }
}

class PhoneLeaveGroupCallPresentationRequest extends TlObject {
  final InputGroupCall call;
  PhoneLeaveGroupCallPresentationRequest({required this.call, });
  @override
  int get crc => 0x1c50d144;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    call.encode(e);
  }
}

class PhoneGetGroupCallStreamChannelsRequest extends TlObject {
  final InputGroupCall call;
  PhoneGetGroupCallStreamChannelsRequest({required this.call, });
  @override
  int get crc => 0x1ab21940;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    call.encode(e);
  }
}

class PhoneGetGroupCallStreamRtmpUrlRequest extends TlObject {
  final bool liveStory;
  final InputPeer peer;
  final bool revoke;
  PhoneGetGroupCallStreamRtmpUrlRequest({this.liveStory = false, required this.peer, required this.revoke, });
  @override
  int get crc => 0x5af4c73a;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (liveStory == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeBool(revoke);
  }
}

class PhoneSaveCallLogRequest extends TlObject {
  final InputPhoneCall peer;
  final InputFile file;
  PhoneSaveCallLogRequest({required this.peer, required this.file, });
  @override
  int get crc => 0x41248786;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    file.encode(e);
  }
}

class PhoneCreateConferenceCallRequest extends TlObject {
  final bool muted;
  final bool videoStopped;
  final bool join;
  final int randomId;
  final BigInt? publicKey;
  final Uint8List? block;
  final DataJSON? params;
  PhoneCreateConferenceCallRequest({this.muted = false, this.videoStopped = false, this.join = false, required this.randomId, this.publicKey, this.block, this.params, });
  @override
  int get crc => 0x7d0444bb;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (muted == true ? (1 << 0) : 0) | (videoStopped == true ? (1 << 2) : 0) | (join == true ? (1 << 3) : 0) | (publicKey != null ? (1 << 3) : 0) | (block != null ? (1 << 3) : 0) | (params != null ? (1 << 3) : 0);
    e.writeUint32(flags);
    e.writeInt32(randomId);
    if (publicKey != null) { e.writeRaw(bigIntToBytes(publicKey!, 32)); }
    if (block != null) { e.writeBytes(block!); }
    if (params != null) { params!.encode(e); }
  }
}

class PhoneDeleteConferenceCallParticipantsRequest extends TlObject {
  final bool onlyLeft;
  final bool kick;
  final InputGroupCall call;
  final List<int> ids;
  final Uint8List block;
  PhoneDeleteConferenceCallParticipantsRequest({this.onlyLeft = false, this.kick = false, required this.call, required this.ids, required this.block, });
  @override
  int get crc => 0x8ca60525;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (onlyLeft == true ? (1 << 0) : 0) | (kick == true ? (1 << 1) : 0);
    e.writeUint32(flags);
    call.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(ids.length); for (final item in ids) { e.writeInt64(item); }
    e.writeBytes(block);
  }
}

class PhoneSendConferenceCallBroadcastRequest extends TlObject {
  final InputGroupCall call;
  final Uint8List block;
  PhoneSendConferenceCallBroadcastRequest({required this.call, required this.block, });
  @override
  int get crc => 0xc6701900;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    call.encode(e);
    e.writeBytes(block);
  }
}

class PhoneInviteConferenceCallParticipantRequest extends TlObject {
  final bool video;
  final InputGroupCall call;
  final InputUser userId;
  PhoneInviteConferenceCallParticipantRequest({this.video = false, required this.call, required this.userId, });
  @override
  int get crc => 0xbcf22685;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (video == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    call.encode(e);
    userId.encode(e);
  }
}

class PhoneDeclineConferenceCallInviteRequest extends TlObject {
  final int msgId;
  PhoneDeclineConferenceCallInviteRequest({required this.msgId, });
  @override
  int get crc => 0x3c479971;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt32(msgId);
  }
}

class PhoneGetGroupCallChainBlocksRequest extends TlObject {
  final InputGroupCall call;
  final int subChainId;
  final int offset;
  final int limit;
  PhoneGetGroupCallChainBlocksRequest({required this.call, required this.subChainId, required this.offset, required this.limit, });
  @override
  int get crc => 0xee9f88a6;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    call.encode(e);
    e.writeInt32(subChainId);
    e.writeInt32(offset);
    e.writeInt32(limit);
  }
}

class PhoneSendGroupCallMessageRequest extends TlObject {
  final InputGroupCall call;
  final int randomId;
  final TextWithEntities message;
  final int? allowPaidStars;
  final InputPeer? sendAs;
  PhoneSendGroupCallMessageRequest({required this.call, required this.randomId, required this.message, this.allowPaidStars, this.sendAs, });
  @override
  int get crc => 0xb1d11410;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (allowPaidStars != null ? (1 << 0) : 0) | (sendAs != null ? (1 << 1) : 0);
    e.writeUint32(flags);
    call.encode(e);
    e.writeInt64(randomId);
    message.encode(e);
    if (allowPaidStars != null) { e.writeInt64(allowPaidStars!); }
    if (sendAs != null) { sendAs!.encode(e); }
  }
}

class PhoneSendGroupCallEncryptedMessageRequest extends TlObject {
  final InputGroupCall call;
  final Uint8List encryptedMessage;
  PhoneSendGroupCallEncryptedMessageRequest({required this.call, required this.encryptedMessage, });
  @override
  int get crc => 0xe5afa56d;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    call.encode(e);
    e.writeBytes(encryptedMessage);
  }
}

class PhoneDeleteGroupCallMessagesRequest extends TlObject {
  final bool reportSpam;
  final InputGroupCall call;
  final List<int> messages;
  PhoneDeleteGroupCallMessagesRequest({this.reportSpam = false, required this.call, required this.messages, });
  @override
  int get crc => 0xf64f54f7;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (reportSpam == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    call.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(messages.length); for (final item in messages) { e.writeInt32(item); }
  }
}

class PhoneDeleteGroupCallParticipantMessagesRequest extends TlObject {
  final bool reportSpam;
  final InputGroupCall call;
  final InputPeer participant;
  PhoneDeleteGroupCallParticipantMessagesRequest({this.reportSpam = false, required this.call, required this.participant, });
  @override
  int get crc => 0x1dbfeca0;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (reportSpam == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    call.encode(e);
    participant.encode(e);
  }
}

class PhoneGetGroupCallStarsRequest extends TlObject {
  final InputGroupCall call;
  PhoneGetGroupCallStarsRequest({required this.call, });
  @override
  int get crc => 0x6f636302;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    call.encode(e);
  }
}

class PhoneSaveDefaultSendAsRequest extends TlObject {
  final InputGroupCall call;
  final InputPeer sendAs;
  PhoneSaveDefaultSendAsRequest({required this.call, required this.sendAs, });
  @override
  int get crc => 0x4167add1;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    call.encode(e);
    sendAs.encode(e);
  }
}

class LangpackGetLangPackRequest extends TlObject {
  final String langPack;
  final String langCode;
  LangpackGetLangPackRequest({required this.langPack, required this.langCode, });
  @override
  int get crc => 0xf2f2330a;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(langPack);
    e.writeString(langCode);
  }
}

class LangpackGetStringsRequest extends TlObject {
  final String langPack;
  final String langCode;
  final List<String> keys;
  LangpackGetStringsRequest({required this.langPack, required this.langCode, required this.keys, });
  @override
  int get crc => 0xefea3803;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(langPack);
    e.writeString(langCode);
    e.writeCrc(0x1cb5c415); e.writeInt32(keys.length); for (final item in keys) { e.writeString(item); }
  }
}

class LangpackGetDifferenceRequest extends TlObject {
  final String langPack;
  final String langCode;
  final int fromVersion;
  LangpackGetDifferenceRequest({required this.langPack, required this.langCode, required this.fromVersion, });
  @override
  int get crc => 0xcd984aa5;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(langPack);
    e.writeString(langCode);
    e.writeInt32(fromVersion);
  }
}

class LangpackGetLanguagesRequest extends TlObject {
  final String langPack;
  LangpackGetLanguagesRequest({required this.langPack, });
  @override
  int get crc => 0x42c6978f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(langPack);
  }
}

class LangpackGetLanguageRequest extends TlObject {
  final String langPack;
  final String langCode;
  LangpackGetLanguageRequest({required this.langPack, required this.langCode, });
  @override
  int get crc => 0x6a596502;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(langPack);
    e.writeString(langCode);
  }
}

class FoldersEditPeerFoldersRequest extends TlObject {
  final List<InputFolderPeer> folderPeers;
  FoldersEditPeerFoldersRequest({required this.folderPeers, });
  @override
  int get crc => 0x6847d0ab;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeCrc(0x1cb5c415); e.writeInt32(folderPeers.length); for (final item in folderPeers) { item.encode(e); }
  }
}

class StatsGetBroadcastStatsRequest extends TlObject {
  final bool dark;
  final InputChannel channel;
  StatsGetBroadcastStatsRequest({this.dark = false, required this.channel, });
  @override
  int get crc => 0xab42441a;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (dark == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    channel.encode(e);
  }
}

class StatsLoadAsyncGraphRequest extends TlObject {
  final String token;
  final int? x;
  StatsLoadAsyncGraphRequest({required this.token, this.x, });
  @override
  int get crc => 0x621d5fa0;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (x != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    e.writeString(token);
    if (x != null) { e.writeInt64(x!); }
  }
}

class StatsGetMegagroupStatsRequest extends TlObject {
  final bool dark;
  final InputChannel channel;
  StatsGetMegagroupStatsRequest({this.dark = false, required this.channel, });
  @override
  int get crc => 0xdcdf8607;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (dark == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    channel.encode(e);
  }
}

class StatsGetMessagePublicForwardsRequest extends TlObject {
  final InputChannel channel;
  final int msgId;
  final String offset;
  final int limit;
  StatsGetMessagePublicForwardsRequest({required this.channel, required this.msgId, required this.offset, required this.limit, });
  @override
  int get crc => 0x5f150144;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    channel.encode(e);
    e.writeInt32(msgId);
    e.writeString(offset);
    e.writeInt32(limit);
  }
}

class StatsGetMessageStatsRequest extends TlObject {
  final bool dark;
  final InputChannel channel;
  final int msgId;
  StatsGetMessageStatsRequest({this.dark = false, required this.channel, required this.msgId, });
  @override
  int get crc => 0xb6e0a3f5;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (dark == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    channel.encode(e);
    e.writeInt32(msgId);
  }
}

class StatsGetStoryStatsRequest extends TlObject {
  final bool dark;
  final InputPeer peer;
  final int id;
  StatsGetStoryStatsRequest({this.dark = false, required this.peer, required this.id, });
  @override
  int get crc => 0x374fef40;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (dark == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeInt32(id);
  }
}

class StatsGetStoryPublicForwardsRequest extends TlObject {
  final InputPeer peer;
  final int id;
  final String offset;
  final int limit;
  StatsGetStoryPublicForwardsRequest({required this.peer, required this.id, required this.offset, required this.limit, });
  @override
  int get crc => 0xa6437ef6;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(id);
    e.writeString(offset);
    e.writeInt32(limit);
  }
}

class StatsGetPollStatsRequest extends TlObject {
  final bool dark;
  final InputPeer peer;
  final int msgId;
  StatsGetPollStatsRequest({this.dark = false, required this.peer, required this.msgId, });
  @override
  int get crc => 0xc27dfa68;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (dark == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeInt32(msgId);
  }
}

class ChatlistsExportChatlistInviteRequest extends TlObject {
  final InputChatlist chatlist;
  final String title;
  final List<InputPeer> peers;
  ChatlistsExportChatlistInviteRequest({required this.chatlist, required this.title, required this.peers, });
  @override
  int get crc => 0x8472478e;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    chatlist.encode(e);
    e.writeString(title);
    e.writeCrc(0x1cb5c415); e.writeInt32(peers.length); for (final item in peers) { item.encode(e); }
  }
}

class ChatlistsDeleteExportedInviteRequest extends TlObject {
  final InputChatlist chatlist;
  final String slug;
  ChatlistsDeleteExportedInviteRequest({required this.chatlist, required this.slug, });
  @override
  int get crc => 0x719c5c5e;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    chatlist.encode(e);
    e.writeString(slug);
  }
}

class ChatlistsEditExportedInviteRequest extends TlObject {
  final InputChatlist chatlist;
  final String slug;
  final String? title;
  final List<InputPeer>? peers;
  ChatlistsEditExportedInviteRequest({required this.chatlist, required this.slug, this.title, this.peers, });
  @override
  int get crc => 0x653db63d;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (title != null ? (1 << 1) : 0) | (peers != null ? (1 << 2) : 0);
    e.writeUint32(flags);
    chatlist.encode(e);
    e.writeString(slug);
    if (title != null) { e.writeString(title!); }
    if (peers != null) { e.writeCrc(0x1cb5c415); e.writeInt32(peers!.length); for (final item in peers!) { item.encode(e); } }
  }
}

class ChatlistsGetExportedInvitesRequest extends TlObject {
  final InputChatlist chatlist;
  ChatlistsGetExportedInvitesRequest({required this.chatlist, });
  @override
  int get crc => 0xce03da83;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    chatlist.encode(e);
  }
}

class ChatlistsCheckChatlistInviteRequest extends TlObject {
  final String slug;
  ChatlistsCheckChatlistInviteRequest({required this.slug, });
  @override
  int get crc => 0x41c10fff;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(slug);
  }
}

class ChatlistsJoinChatlistInviteRequest extends TlObject {
  final String slug;
  final List<InputPeer> peers;
  ChatlistsJoinChatlistInviteRequest({required this.slug, required this.peers, });
  @override
  int get crc => 0xa6b1e39a;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(slug);
    e.writeCrc(0x1cb5c415); e.writeInt32(peers.length); for (final item in peers) { item.encode(e); }
  }
}

class ChatlistsGetChatlistUpdatesRequest extends TlObject {
  final InputChatlist chatlist;
  ChatlistsGetChatlistUpdatesRequest({required this.chatlist, });
  @override
  int get crc => 0x89419521;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    chatlist.encode(e);
  }
}

class ChatlistsJoinChatlistUpdatesRequest extends TlObject {
  final InputChatlist chatlist;
  final List<InputPeer> peers;
  ChatlistsJoinChatlistUpdatesRequest({required this.chatlist, required this.peers, });
  @override
  int get crc => 0xe089f8f5;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    chatlist.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(peers.length); for (final item in peers) { item.encode(e); }
  }
}

class ChatlistsHideChatlistUpdatesRequest extends TlObject {
  final InputChatlist chatlist;
  ChatlistsHideChatlistUpdatesRequest({required this.chatlist, });
  @override
  int get crc => 0x66e486fb;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    chatlist.encode(e);
  }
}

class ChatlistsGetLeaveChatlistSuggestionsRequest extends TlObject {
  final InputChatlist chatlist;
  ChatlistsGetLeaveChatlistSuggestionsRequest({required this.chatlist, });
  @override
  int get crc => 0xfdbcd714;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    chatlist.encode(e);
  }
}

class ChatlistsLeaveChatlistRequest extends TlObject {
  final InputChatlist chatlist;
  final List<InputPeer> peers;
  ChatlistsLeaveChatlistRequest({required this.chatlist, required this.peers, });
  @override
  int get crc => 0x74fae13a;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    chatlist.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(peers.length); for (final item in peers) { item.encode(e); }
  }
}

class StoriesCanSendStoryRequest extends TlObject {
  final InputPeer peer;
  StoriesCanSendStoryRequest({required this.peer, });
  @override
  int get crc => 0x30eb63f0;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
  }
}

class StoriesSendStoryRequest extends TlObject {
  final bool pinned;
  final bool noforwards;
  final bool fwdModified;
  final InputPeer peer;
  final InputMedia media;
  final List<MediaArea>? mediaAreas;
  final String? caption;
  final List<MessageEntity>? entities;
  final List<InputPrivacyRule> privacyRules;
  final int randomId;
  final int? period;
  final InputPeer? fwdFromId;
  final int? fwdFromStory;
  final List<int>? albums;
  final InputDocument? music;
  StoriesSendStoryRequest({this.pinned = false, this.noforwards = false, this.fwdModified = false, required this.peer, required this.media, this.mediaAreas, this.caption, this.entities, required this.privacyRules, required this.randomId, this.period, this.fwdFromId, this.fwdFromStory, this.albums, this.music, });
  @override
  int get crc => 0x8f9e6898;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (pinned == true ? (1 << 2) : 0) | (noforwards == true ? (1 << 4) : 0) | (fwdModified == true ? (1 << 7) : 0) | (mediaAreas != null ? (1 << 5) : 0) | (caption != null ? (1 << 0) : 0) | (entities != null ? (1 << 1) : 0) | (period != null ? (1 << 3) : 0) | (fwdFromId != null ? (1 << 6) : 0) | (fwdFromStory != null ? (1 << 6) : 0) | (albums != null ? (1 << 8) : 0) | (music != null ? (1 << 9) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    media.encode(e);
    if (mediaAreas != null) { e.writeCrc(0x1cb5c415); e.writeInt32(mediaAreas!.length); for (final item in mediaAreas!) { item.encode(e); } }
    if (caption != null) { e.writeString(caption!); }
    if (entities != null) { e.writeCrc(0x1cb5c415); e.writeInt32(entities!.length); for (final item in entities!) { item.encode(e); } }
    e.writeCrc(0x1cb5c415); e.writeInt32(privacyRules.length); for (final item in privacyRules) { item.encode(e); }
    e.writeInt64(randomId);
    if (period != null) { e.writeInt32(period!); }
    if (fwdFromId != null) { fwdFromId!.encode(e); }
    if (fwdFromStory != null) { e.writeInt32(fwdFromStory!); }
    if (albums != null) { e.writeCrc(0x1cb5c415); e.writeInt32(albums!.length); for (final item in albums!) { e.writeInt32(item); } }
    if (music != null) { music!.encode(e); }
  }
}

class StoriesEditStoryRequest extends TlObject {
  final InputPeer peer;
  final int id;
  final InputMedia? media;
  final List<MediaArea>? mediaAreas;
  final String? caption;
  final List<MessageEntity>? entities;
  final List<InputPrivacyRule>? privacyRules;
  final InputDocument? music;
  StoriesEditStoryRequest({required this.peer, required this.id, this.media, this.mediaAreas, this.caption, this.entities, this.privacyRules, this.music, });
  @override
  int get crc => 0x2c63a72b;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (media != null ? (1 << 0) : 0) | (mediaAreas != null ? (1 << 3) : 0) | (caption != null ? (1 << 1) : 0) | (entities != null ? (1 << 1) : 0) | (privacyRules != null ? (1 << 2) : 0) | (music != null ? (1 << 4) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeInt32(id);
    if (media != null) { media!.encode(e); }
    if (mediaAreas != null) { e.writeCrc(0x1cb5c415); e.writeInt32(mediaAreas!.length); for (final item in mediaAreas!) { item.encode(e); } }
    if (caption != null) { e.writeString(caption!); }
    if (entities != null) { e.writeCrc(0x1cb5c415); e.writeInt32(entities!.length); for (final item in entities!) { item.encode(e); } }
    if (privacyRules != null) { e.writeCrc(0x1cb5c415); e.writeInt32(privacyRules!.length); for (final item in privacyRules!) { item.encode(e); } }
    if (music != null) { music!.encode(e); }
  }
}

class StoriesDeleteStoriesRequest extends TlObject {
  final InputPeer peer;
  final List<int> id;
  StoriesDeleteStoriesRequest({required this.peer, required this.id, });
  @override
  int get crc => 0xae59db5f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { e.writeInt32(item); }
  }
}

class StoriesTogglePinnedRequest extends TlObject {
  final InputPeer peer;
  final List<int> id;
  final bool pinned;
  StoriesTogglePinnedRequest({required this.peer, required this.id, required this.pinned, });
  @override
  int get crc => 0x9a75a1ef;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { e.writeInt32(item); }
    e.writeBool(pinned);
  }
}

class StoriesGetAllStoriesRequest extends TlObject {
  final bool next;
  final bool hidden;
  final String? state;
  StoriesGetAllStoriesRequest({this.next = false, this.hidden = false, this.state, });
  @override
  int get crc => 0xeeb0d625;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (next == true ? (1 << 1) : 0) | (hidden == true ? (1 << 2) : 0) | (state != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    if (state != null) { e.writeString(state!); }
  }
}

class StoriesGetPinnedStoriesRequest extends TlObject {
  final InputPeer peer;
  final int offsetId;
  final int limit;
  StoriesGetPinnedStoriesRequest({required this.peer, required this.offsetId, required this.limit, });
  @override
  int get crc => 0x5821a5dc;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(offsetId);
    e.writeInt32(limit);
  }
}

class StoriesGetStoriesArchiveRequest extends TlObject {
  final InputPeer peer;
  final int offsetId;
  final int limit;
  StoriesGetStoriesArchiveRequest({required this.peer, required this.offsetId, required this.limit, });
  @override
  int get crc => 0xb4352016;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(offsetId);
    e.writeInt32(limit);
  }
}

class StoriesGetStoriesByIDRequest extends TlObject {
  final InputPeer peer;
  final List<int> id;
  StoriesGetStoriesByIDRequest({required this.peer, required this.id, });
  @override
  int get crc => 0x5774ca74;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { e.writeInt32(item); }
  }
}

class StoriesToggleAllStoriesHiddenRequest extends TlObject {
  final bool hidden;
  StoriesToggleAllStoriesHiddenRequest({required this.hidden, });
  @override
  int get crc => 0x7c2557c4;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeBool(hidden);
  }
}

class StoriesReadStoriesRequest extends TlObject {
  final InputPeer peer;
  final int maxId;
  StoriesReadStoriesRequest({required this.peer, required this.maxId, });
  @override
  int get crc => 0xa556dac8;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(maxId);
  }
}

class StoriesIncrementStoryViewsRequest extends TlObject {
  final InputPeer peer;
  final List<int> id;
  StoriesIncrementStoryViewsRequest({required this.peer, required this.id, });
  @override
  int get crc => 0xb2028afb;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { e.writeInt32(item); }
  }
}

class StoriesGetStoryViewsListRequest extends TlObject {
  final bool justContacts;
  final bool reactionsFirst;
  final bool forwardsFirst;
  final InputPeer peer;
  final String? q;
  final int id;
  final String offset;
  final int limit;
  StoriesGetStoryViewsListRequest({this.justContacts = false, this.reactionsFirst = false, this.forwardsFirst = false, required this.peer, this.q, required this.id, required this.offset, required this.limit, });
  @override
  int get crc => 0x7ed23c57;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (justContacts == true ? (1 << 0) : 0) | (reactionsFirst == true ? (1 << 2) : 0) | (forwardsFirst == true ? (1 << 3) : 0) | (q != null ? (1 << 1) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    if (q != null) { e.writeString(q!); }
    e.writeInt32(id);
    e.writeString(offset);
    e.writeInt32(limit);
  }
}

class StoriesGetStoriesViewsRequest extends TlObject {
  final InputPeer peer;
  final List<int> id;
  StoriesGetStoriesViewsRequest({required this.peer, required this.id, });
  @override
  int get crc => 0x28e16cc8;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { e.writeInt32(item); }
  }
}

class StoriesExportStoryLinkRequest extends TlObject {
  final InputPeer peer;
  final int id;
  StoriesExportStoryLinkRequest({required this.peer, required this.id, });
  @override
  int get crc => 0x7b8def20;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(id);
  }
}

class StoriesReportRequest extends TlObject {
  final InputPeer peer;
  final List<int> id;
  final Uint8List option;
  final String message;
  StoriesReportRequest({required this.peer, required this.id, required this.option, required this.message, });
  @override
  int get crc => 0x19d8eb45;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { e.writeInt32(item); }
    e.writeBytes(option);
    e.writeString(message);
  }
}

class StoriesActivateStealthModeRequest extends TlObject {
  final bool past;
  final bool future;
  StoriesActivateStealthModeRequest({this.past = false, this.future = false, });
  @override
  int get crc => 0x57bbd166;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (past == true ? (1 << 0) : 0) | (future == true ? (1 << 1) : 0);
    e.writeUint32(flags);
  }
}

class StoriesSendReactionRequest extends TlObject {
  final bool addToRecent;
  final InputPeer peer;
  final int storyId;
  final Reaction reaction;
  StoriesSendReactionRequest({this.addToRecent = false, required this.peer, required this.storyId, required this.reaction, });
  @override
  int get crc => 0x7fd736b2;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (addToRecent == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeInt32(storyId);
    reaction.encode(e);
  }
}

class StoriesGetPeerStoriesRequest extends TlObject {
  final InputPeer peer;
  StoriesGetPeerStoriesRequest({required this.peer, });
  @override
  int get crc => 0x2c4ada50;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
  }
}

class StoriesGetAllReadPeerStoriesRequest extends TlObject {
  StoriesGetAllReadPeerStoriesRequest();
  @override
  int get crc => 0x9b5ae7f9;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class StoriesGetPeerMaxIDsRequest extends TlObject {
  final List<InputPeer> id;
  StoriesGetPeerMaxIDsRequest({required this.id, });
  @override
  int get crc => 0x78499170;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { item.encode(e); }
  }
}

class StoriesGetChatsToSendRequest extends TlObject {
  StoriesGetChatsToSendRequest();
  @override
  int get crc => 0xa56a8b60;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class StoriesTogglePeerStoriesHiddenRequest extends TlObject {
  final InputPeer peer;
  final bool hidden;
  StoriesTogglePeerStoriesHiddenRequest({required this.peer, required this.hidden, });
  @override
  int get crc => 0xbd0415c4;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeBool(hidden);
  }
}

class StoriesGetStoryReactionsListRequest extends TlObject {
  final bool forwardsFirst;
  final InputPeer peer;
  final int id;
  final Reaction? reaction;
  final String? offset;
  final int limit;
  StoriesGetStoryReactionsListRequest({this.forwardsFirst = false, required this.peer, required this.id, this.reaction, this.offset, required this.limit, });
  @override
  int get crc => 0xb9b2881f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (forwardsFirst == true ? (1 << 2) : 0) | (reaction != null ? (1 << 0) : 0) | (offset != null ? (1 << 1) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeInt32(id);
    if (reaction != null) { reaction!.encode(e); }
    if (offset != null) { e.writeString(offset!); }
    e.writeInt32(limit);
  }
}

class StoriesTogglePinnedToTopRequest extends TlObject {
  final InputPeer peer;
  final List<int> id;
  StoriesTogglePinnedToTopRequest({required this.peer, required this.id, });
  @override
  int get crc => 0xb297e9b;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(id.length); for (final item in id) { e.writeInt32(item); }
  }
}

class StoriesSearchPostsRequest extends TlObject {
  final String? hashtag;
  final MediaArea? area;
  final InputPeer? peer;
  final String offset;
  final int limit;
  StoriesSearchPostsRequest({this.hashtag, this.area, this.peer, required this.offset, required this.limit, });
  @override
  int get crc => 0xd1810907;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (hashtag != null ? (1 << 0) : 0) | (area != null ? (1 << 1) : 0) | (peer != null ? (1 << 2) : 0);
    e.writeUint32(flags);
    if (hashtag != null) { e.writeString(hashtag!); }
    if (area != null) { area!.encode(e); }
    if (peer != null) { peer!.encode(e); }
    e.writeString(offset);
    e.writeInt32(limit);
  }
}

class StoriesCreateAlbumRequest extends TlObject {
  final InputPeer peer;
  final String title;
  final List<int> stories;
  StoriesCreateAlbumRequest({required this.peer, required this.title, required this.stories, });
  @override
  int get crc => 0xa36396e5;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeString(title);
    e.writeCrc(0x1cb5c415); e.writeInt32(stories.length); for (final item in stories) { e.writeInt32(item); }
  }
}

class StoriesUpdateAlbumRequest extends TlObject {
  final InputPeer peer;
  final int albumId;
  final String? title;
  final List<int>? deleteStories;
  final List<int>? addStories;
  final List<int>? order;
  StoriesUpdateAlbumRequest({required this.peer, required this.albumId, this.title, this.deleteStories, this.addStories, this.order, });
  @override
  int get crc => 0x5e5259b6;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (title != null ? (1 << 0) : 0) | (deleteStories != null ? (1 << 1) : 0) | (addStories != null ? (1 << 2) : 0) | (order != null ? (1 << 3) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeInt32(albumId);
    if (title != null) { e.writeString(title!); }
    if (deleteStories != null) { e.writeCrc(0x1cb5c415); e.writeInt32(deleteStories!.length); for (final item in deleteStories!) { e.writeInt32(item); } }
    if (addStories != null) { e.writeCrc(0x1cb5c415); e.writeInt32(addStories!.length); for (final item in addStories!) { e.writeInt32(item); } }
    if (order != null) { e.writeCrc(0x1cb5c415); e.writeInt32(order!.length); for (final item in order!) { e.writeInt32(item); } }
  }
}

class StoriesReorderAlbumsRequest extends TlObject {
  final InputPeer peer;
  final List<int> order;
  StoriesReorderAlbumsRequest({required this.peer, required this.order, });
  @override
  int get crc => 0x8535fbd9;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeCrc(0x1cb5c415); e.writeInt32(order.length); for (final item in order) { e.writeInt32(item); }
  }
}

class StoriesDeleteAlbumRequest extends TlObject {
  final InputPeer peer;
  final int albumId;
  StoriesDeleteAlbumRequest({required this.peer, required this.albumId, });
  @override
  int get crc => 0x8d3456d0;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(albumId);
  }
}

class StoriesGetAlbumsRequest extends TlObject {
  final InputPeer peer;
  final int hash;
  StoriesGetAlbumsRequest({required this.peer, required this.hash, });
  @override
  int get crc => 0x25b3eac7;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt64(hash);
  }
}

class StoriesGetAlbumStoriesRequest extends TlObject {
  final InputPeer peer;
  final int albumId;
  final int offset;
  final int limit;
  StoriesGetAlbumStoriesRequest({required this.peer, required this.albumId, required this.offset, required this.limit, });
  @override
  int get crc => 0xac806d61;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    e.writeInt32(albumId);
    e.writeInt32(offset);
    e.writeInt32(limit);
  }
}

class StoriesStartLiveRequest extends TlObject {
  final bool pinned;
  final bool noforwards;
  final bool rtmpStream;
  final InputPeer peer;
  final String? caption;
  final List<MessageEntity>? entities;
  final List<InputPrivacyRule> privacyRules;
  final int randomId;
  final bool? messagesEnabled;
  final int? sendPaidMessagesStars;
  StoriesStartLiveRequest({this.pinned = false, this.noforwards = false, this.rtmpStream = false, required this.peer, this.caption, this.entities, required this.privacyRules, required this.randomId, this.messagesEnabled, this.sendPaidMessagesStars, });
  @override
  int get crc => 0xd069ccde;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (pinned == true ? (1 << 2) : 0) | (noforwards == true ? (1 << 4) : 0) | (rtmpStream == true ? (1 << 5) : 0) | (caption != null ? (1 << 0) : 0) | (entities != null ? (1 << 1) : 0) | (messagesEnabled != null ? (1 << 6) : 0) | (sendPaidMessagesStars != null ? (1 << 7) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    if (caption != null) { e.writeString(caption!); }
    if (entities != null) { e.writeCrc(0x1cb5c415); e.writeInt32(entities!.length); for (final item in entities!) { item.encode(e); } }
    e.writeCrc(0x1cb5c415); e.writeInt32(privacyRules.length); for (final item in privacyRules) { item.encode(e); }
    e.writeInt64(randomId);
    if (messagesEnabled != null) { e.writeBool(messagesEnabled!); }
    if (sendPaidMessagesStars != null) { e.writeInt64(sendPaidMessagesStars!); }
  }
}

class PremiumGetBoostsListRequest extends TlObject {
  final bool gifts;
  final InputPeer peer;
  final String offset;
  final int limit;
  PremiumGetBoostsListRequest({this.gifts = false, required this.peer, required this.offset, required this.limit, });
  @override
  int get crc => 0x60f67660;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (gifts == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    peer.encode(e);
    e.writeString(offset);
    e.writeInt32(limit);
  }
}

class PremiumGetMyBoostsRequest extends TlObject {
  PremiumGetMyBoostsRequest();
  @override
  int get crc => 0xbe77b4a;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class PremiumApplyBoostRequest extends TlObject {
  final List<int>? slots;
  final InputPeer peer;
  PremiumApplyBoostRequest({this.slots, required this.peer, });
  @override
  int get crc => 0x6b7da746;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (slots != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    if (slots != null) { e.writeCrc(0x1cb5c415); e.writeInt32(slots!.length); for (final item in slots!) { e.writeInt32(item); } }
    peer.encode(e);
  }
}

class PremiumGetBoostsStatusRequest extends TlObject {
  final InputPeer peer;
  PremiumGetBoostsStatusRequest({required this.peer, });
  @override
  int get crc => 0x42f1f61;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
  }
}

class PremiumGetUserBoostsRequest extends TlObject {
  final InputPeer peer;
  final InputUser userId;
  PremiumGetUserBoostsRequest({required this.peer, required this.userId, });
  @override
  int get crc => 0x39854d1f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    peer.encode(e);
    userId.encode(e);
  }
}

class SmsjobsIsEligibleToJoinRequest extends TlObject {
  SmsjobsIsEligibleToJoinRequest();
  @override
  int get crc => 0xedc39d0;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class SmsjobsJoinRequest extends TlObject {
  SmsjobsJoinRequest();
  @override
  int get crc => 0xa74ece2d;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class SmsjobsLeaveRequest extends TlObject {
  SmsjobsLeaveRequest();
  @override
  int get crc => 0x9898ad73;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class SmsjobsUpdateSettingsRequest extends TlObject {
  final bool allowInternational;
  SmsjobsUpdateSettingsRequest({this.allowInternational = false, });
  @override
  int get crc => 0x93fa0bf;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (allowInternational == true ? (1 << 0) : 0);
    e.writeUint32(flags);
  }
}

class SmsjobsGetStatusRequest extends TlObject {
  SmsjobsGetStatusRequest();
  @override
  int get crc => 0x10a698e8;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
  }
}

class SmsjobsGetSmsJobRequest extends TlObject {
  final String jobId;
  SmsjobsGetSmsJobRequest({required this.jobId, });
  @override
  int get crc => 0x778d902f;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeString(jobId);
  }
}

class SmsjobsFinishJobRequest extends TlObject {
  final String jobId;
  final String? error;
  SmsjobsFinishJobRequest({required this.jobId, this.error, });
  @override
  int get crc => 0x4f1ebf24;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (error != null ? (1 << 0) : 0);
    e.writeUint32(flags);
    e.writeString(jobId);
    if (error != null) { e.writeString(error!); }
  }
}

class FragmentGetCollectibleInfoRequest extends TlObject {
  final InputCollectible collectible;
  FragmentGetCollectibleInfoRequest({required this.collectible, });
  @override
  int get crc => 0xbe1e85ba;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    collectible.encode(e);
  }
}

class AicomposeCreateToneRequest extends TlObject {
  final bool displayAuthor;
  final int emojiId;
  final String title;
  final String prompt;
  AicomposeCreateToneRequest({this.displayAuthor = false, required this.emojiId, required this.title, required this.prompt, });
  @override
  int get crc => 0x4aa83913;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (displayAuthor == true ? (1 << 0) : 0);
    e.writeUint32(flags);
    e.writeInt64(emojiId);
    e.writeString(title);
    e.writeString(prompt);
  }
}

class AicomposeUpdateToneRequest extends TlObject {
  final InputAiComposeTone tone;
  final bool? displayAuthor;
  final int? emojiId;
  final String? title;
  final String? prompt;
  AicomposeUpdateToneRequest({required this.tone, this.displayAuthor, this.emojiId, this.title, this.prompt, });
  @override
  int get crc => 0x903bcf59;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    int flags = 0 | (displayAuthor != null ? (1 << 0) : 0) | (emojiId != null ? (1 << 1) : 0) | (title != null ? (1 << 2) : 0) | (prompt != null ? (1 << 3) : 0);
    e.writeUint32(flags);
    tone.encode(e);
    if (displayAuthor != null) { e.writeBool(displayAuthor!); }
    if (emojiId != null) { e.writeInt64(emojiId!); }
    if (title != null) { e.writeString(title!); }
    if (prompt != null) { e.writeString(prompt!); }
  }
}

class AicomposeSaveToneRequest extends TlObject {
  final InputAiComposeTone tone;
  final bool unsave;
  AicomposeSaveToneRequest({required this.tone, required this.unsave, });
  @override
  int get crc => 0x1782cbb1;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    tone.encode(e);
    e.writeBool(unsave);
  }
}

class AicomposeDeleteToneRequest extends TlObject {
  final InputAiComposeTone tone;
  AicomposeDeleteToneRequest({required this.tone, });
  @override
  int get crc => 0xdd39316a;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    tone.encode(e);
  }
}

class AicomposeGetToneRequest extends TlObject {
  final InputAiComposeTone tone;
  AicomposeGetToneRequest({required this.tone, });
  @override
  int get crc => 0xb2e8ba03;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    tone.encode(e);
  }
}

class AicomposeGetTonesRequest extends TlObject {
  final int hash;
  AicomposeGetTonesRequest({required this.hash, });
  @override
  int get crc => 0xabd59201;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    e.writeInt64(hash);
  }
}

class AicomposeGetToneExampleRequest extends TlObject {
  final InputAiComposeTone tone;
  final int num;
  AicomposeGetToneExampleRequest({required this.tone, required this.num, });
  @override
  int get crc => 0xd1b4ab14;
  @override
  void encode(TlEncoder e) {
    e.writeCrc(crc);
    tone.encode(e);
    e.writeInt32(num);
  }
}

