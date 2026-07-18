import 'dart:typed_data';

import '../crypto/math.dart';
import '../crypto/mtproto_crypto.dart';
import '../crypto/aes_ige.dart';
import '../tl/tl_encoder.dart';
import '../tl/tl_decoder.dart';
import '../tg/tg.dart';
import 'client.dart';

const secretChatLayer = 143;

const _crcDecryptedMessage = 0x91cc4674;
const _crcDecryptedMessageLayer = 0x1be31789;
const _crcDecryptedMessageMediaEmpty = 0x089f5c4a;

class SecretChat {
  final int id;
  final int accessHash;
  final int adminId;
  final int participantId;
  Uint8List key;
  final Uint8List keyFingerprint;
  final bool isOutgoing;
  int inSeqNo;
  int outSeqNo;

  SecretChat({
    required this.id,
    required this.accessHash,
    required this.adminId,
    required this.participantId,
    required this.key,
    required this.keyFingerprint,
    required this.isOutgoing,
    this.inSeqNo = 0,
    this.outSeqNo = 0,
  });

  InputEncryptedChat get input =>
      InputEncryptedChatObj(chatId: id, accessHash: accessHash);
}

class SecretMessage {
  final SecretChat chat;
  final int randomId;
  final String text;
  SecretMessage({required this.chat, required this.randomId, required this.text});
}

extension SecretChats on MtpClient {
  static final Map<int, SecretChat> _chats = {};

  Map<int, SecretChat> get secretChats => _chats;

  Future<SecretChat> startSecretChat(InputUser peer) async {
    final dh = await _getDh();
    final a = bytesToBigInt(randomBytes(256));
    final gA = dh.g.modPow(a, dh.p);
    validateGB(gA, dh.p);

    final res = await invoke(
      MessagesRequestEncryptionRequest(
        userId: peer,
        randomId:
            randomBytes(4).buffer.asByteData().getInt32(0, Endian.little),
        gA: bigIntToUnsignedBytes(gA),
      ),
    );
    if (res is! EncryptedChatWaiting) {
      throw StateError('unexpected requestEncryption result: ${res.runtimeType}');
    }
    final pending = _PendingChat(
      id: res.id,
      accessHash: res.accessHash,
      adminId: res.adminId,
      participantId: res.participantId,
      a: a,
      p: dh.p,
    );
    _pending[res.id] = pending;
    return SecretChat(
      id: res.id,
      accessHash: res.accessHash,
      adminId: res.adminId,
      participantId: res.participantId,
      key: Uint8List(0),
      keyFingerprint: Uint8List(0),
      isOutgoing: true,
    );
  }

  Future<SecretChat> acceptSecretChat(EncryptedChatRequested req) async {
    final dh = await _getDh();
    final gA = bytesToBigInt(req.gA);
    validateGB(gA, dh.p);
    final b = bytesToBigInt(randomBytes(256));
    final gB = dh.g.modPow(b, dh.p);
    validateGB(gB, dh.p);

    final key = _padKey256(bigIntToUnsignedBytes(gA.modPow(b, dh.p)));
    final fingerprint = _keyFingerprintInt(key);

    final res = await invoke(
      MessagesAcceptEncryptionRequest(
        peer: InputEncryptedChatObj(chatId: req.id, accessHash: req.accessHash),
        gB: bigIntToUnsignedBytes(gB),
        keyFingerprint: fingerprint,
      ),
    );
    if (res is! EncryptedChatObj) {
      throw StateError('unexpected acceptEncryption result: ${res.runtimeType}');
    }
    final chat = SecretChat(
      id: res.id,
      accessHash: res.accessHash,
      adminId: res.adminId,
      participantId: res.participantId,
      key: key,
      keyFingerprint: _fpToBytes(res.keyFingerprint),
      isOutgoing: false,
    );
    _chats[res.id] = chat;
    return chat;
  }

  SecretChat? completeSecretChat(EncryptedChatObj chat) {
    final pending = _pending.remove(chat.id);
    if (pending == null) return null;
    final gB = bytesToBigInt(chat.gAOrB);
    validateGB(gB, pending.p);
    final key = _padKey256(bigIntToUnsignedBytes(gB.modPow(pending.a, pending.p)));
    final fp = _keyFingerprint(key);
    if (!_bytesEq(fp, _fpToBytes(chat.keyFingerprint))) {
      throw StateError('secret chat key fingerprint mismatch');
    }
    final sc = SecretChat(
      id: chat.id,
      accessHash: chat.accessHash,
      adminId: chat.adminId,
      participantId: chat.participantId,
      key: key,
      keyFingerprint: fp,
      isOutgoing: true,
    );
    _chats[chat.id] = sc;
    return sc;
  }

  Future<void> discardSecretChat(SecretChat chat) async {
    _chats.remove(chat.id);
    _pending.remove(chat.id);
    await invoke(MessagesDiscardEncryptionRequest(chatId: chat.id));
  }

  Future<void> sendSecretMessage(SecretChat chat, String text) async {
    final randomId =
        randomBytes(8).buffer.asByteData().getInt64(0, Endian.little);

    final inner = TlEncoder();
    inner.writeCrc(_crcDecryptedMessage);
    inner.writeUint32(0);
    inner.writeInt64(randomId);
    inner.writeInt32(0);
    inner.writeString(text);
    inner.writeCrc(_crcDecryptedMessageMediaEmpty);

    final layer = TlEncoder();
    layer.writeCrc(_crcDecryptedMessageLayer);
    layer.writeBytes(randomBytes(16));
    layer.writeInt32(secretChatLayer);
    layer.writeInt32(chat.isOutgoing ? chat.inSeqNo * 2 : chat.inSeqNo * 2 + 1);
    layer.writeInt32(chat.isOutgoing ? chat.outSeqNo * 2 + 1 : chat.outSeqNo * 2);
    layer.writeRaw(inner.toBytes());
    chat.outSeqNo++;

    final encrypted = _encryptSecret(chat, layer.toBytes());

    await invoke(
      MessagesSendEncryptedRequest(
        peer: chat.input,
        randomId: randomId,
        data: encrypted,
      ),
    );
  }

  SecretMessage? decryptSecretMessage(int chatId, Uint8List blob) {
    final chat = _chats[chatId];
    if (chat == null) return null;
    final decrypted = _decryptSecret(chat, blob);
    final d = TlDecoder(decrypted);
    var crc = d.readCrc();
    if (crc == _crcDecryptedMessageLayer) {
      d.readBytes();
      d.readInt32();
      d.readInt32();
      d.readInt32();
      crc = d.readCrc();
    }
    if (crc == _crcDecryptedMessage) {
      d.readUint32();
      final randomId = d.readInt64();
      d.readInt32();
      final text = d.readString();
      chat.inSeqNo++;
      return SecretMessage(chat: chat, randomId: randomId, text: text);
    }
    return null;
  }

  Uint8List _encryptSecret(SecretChat chat, Uint8List payload) {
    final withLen = TlEncoder();
    withLen.writeUint32(payload.length);
    withLen.writeRaw(payload);
    var data = withLen.toBytes();
    final pad = (16 - (data.length % 16)) % 16;
    if (pad > 0) {
      final padded = Uint8List(data.length + pad);
      padded.setRange(0, data.length, data);
      padded.setRange(data.length, padded.length, randomBytes(pad));
      data = padded;
    }

    final msgKeyLarge = sha256(Uint8List.fromList(
        [...chat.key.sublist(88, 88 + 32), ...data]));
    final msgKey = msgKeyLarge.sublist(8, 24);
    final keys = _secretAesKeys(chat.key, msgKey, outgoing: chat.isOutgoing);
    final enc = aesIgeEncrypt(data, keys.$1, keys.$2);

    final out = BytesBuilder();
    out.add(_fpToBytes(_keyFingerprintInt(chat.key)));
    out.add(msgKey);
    out.add(enc);
    return out.toBytes();
  }

  Uint8List _decryptSecret(SecretChat chat, Uint8List blob) {
    final msgKey = blob.sublist(8, 24);
    final enc = blob.sublist(24);
    final keys = _secretAesKeys(chat.key, msgKey, outgoing: !chat.isOutgoing);
    final dec = aesIgeDecrypt(enc, keys.$1, keys.$2);
    final len = ByteData.view(dec.buffer, dec.offsetInBytes).getUint32(0, Endian.little);
    return Uint8List.sublistView(dec, 4, 4 + len);
  }

  (Uint8List, Uint8List) _secretAesKeys(Uint8List key, Uint8List msgKey,
      {required bool outgoing}) {
    final x = outgoing ? 0 : 8;
    final a = sha256(Uint8List.fromList([...msgKey, ...key.sublist(x, x + 36)]));
    final b = sha256(Uint8List.fromList([...key.sublist(40 + x, 40 + x + 36), ...msgKey]));
    final aesKey = Uint8List(32)
      ..setRange(0, 8, a.sublist(0, 8))
      ..setRange(8, 24, b.sublist(8, 24))
      ..setRange(24, 32, a.sublist(24, 32));
    final aesIv = Uint8List(32)
      ..setRange(0, 8, b.sublist(0, 8))
      ..setRange(8, 24, a.sublist(8, 24))
      ..setRange(24, 32, b.sublist(24, 32));
    return (aesKey, aesIv);
  }

  Future<_Dh> _getDh() async {
    final r = await invoke(MessagesGetDhConfigRequest(version: 0, randomLength: 256));
    if (r is MessagesDhConfigObj) {
      return _Dh(bytesToBigInt(r.p), BigInt.from(r.g));
    }
    throw StateError('unexpected getDhConfig result: ${r.runtimeType}');
  }
}

final _pending = <int, _PendingChat>{};

class _PendingChat {
  final int id;
  final int accessHash;
  final int adminId;
  final int participantId;
  final BigInt a;
  final BigInt p;
  _PendingChat({
    required this.id,
    required this.accessHash,
    required this.adminId,
    required this.participantId,
    required this.a,
    required this.p,
  });
}

class _Dh {
  final BigInt p;
  final BigInt g;
  _Dh(this.p, this.g);
}

Uint8List _padKey256(Uint8List b) {
  if (b.length >= 256) return Uint8List.fromList(b.sublist(b.length - 256));
  final out = Uint8List(256);
  out.setRange(256 - b.length, 256, b);
  return out;
}

Uint8List _keyFingerprint(Uint8List key) {
  final h = sha1(key);
  return Uint8List.fromList(h.sublist(h.length - 8));
}

int _keyFingerprintInt(Uint8List key) {
  final fp = _keyFingerprint(key);
  return ByteData.view(fp.buffer, fp.offsetInBytes).getInt64(0, Endian.little);
}

Uint8List _fpToBytes(int fp) {
  final b = Uint8List(8);
  ByteData.view(b.buffer).setInt64(0, fp, Endian.little);
  return b;
}

bool _bytesEq(Uint8List a, Uint8List b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
