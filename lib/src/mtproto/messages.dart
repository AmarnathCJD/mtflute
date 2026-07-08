import 'dart:typed_data';

import '../crypto/mtproto_crypto.dart';
import '../tl/tl_encoder.dart';
import '../tl/tl_decoder.dart';

class MtpMessage {
  final Uint8List msg;
  final int msgId;
  final int seqNo;

  MtpMessage({required this.msg, required this.msgId, this.seqNo = 0});
}

Uint8List serializeUnencrypted(Uint8List msg, int msgId) {
  final encoder = TlEncoder();
  encoder.writeInt64(0); // authKeyHash = 0
  encoder.writeInt64(msgId);
  encoder.writeInt32(msg.length);
  encoder.writeRaw(msg);
  return encoder.toBytes();
}

MtpMessage deserializeUnencrypted(Uint8List data) {
  final d = TlDecoder(data);
  d.readInt64(); // authKeyHash, always 0
  final msgId = d.readInt64();
  final msgLen = d.readUint32();
  final msg = d.readRawBytes(msgLen);
  return MtpMessage(msg: msg, msgId: msgId);
}

Uint8List serializeEncrypted({
  required Uint8List msg,
  required int msgId,
  required int seqNo,
  required Uint8List authKey,
  required int serverSalt,
  required int sessionId,
}) {
  final inner = TlEncoder();

  final saltBytes = Uint8List(8);
  ByteData.view(saltBytes.buffer).setInt64(0, serverSalt, Endian.little);
  inner.writeRaw(saltBytes);

  inner.writeInt64(sessionId);
  inner.writeInt64(msgId);
  inner.writeInt32(seqNo);
  inner.writeInt32(msg.length);
  inner.writeRaw(msg);

  final encrypted = encryptMessage(inner.toBytes(), authKey);

  final outer = TlEncoder();
  outer.writeRaw(authKeyHash(authKey));
  outer.writeRaw(encrypted.msgKey);
  outer.writeRaw(encrypted.data);
  return outer.toBytes();
}

MtpMessage deserializeEncrypted(Uint8List data, Uint8List authKey) {
  final d = TlDecoder(data);

  final keyHash = d.readRawBytes(8);
  final expectedHash = authKeyHash(authKey);
  for (var i = 0; i < 8; i++) {
    if (keyHash[i] != expectedHash[i]) {
      throw StateError('Wrong encryption key');
    }
  }

  final msgKey = d.readRawBytes(16);
  final encryptedData = d.readRawBytes(d.remaining);

  final decrypted = decryptMessage(encryptedData, authKey, msgKey);
  return _finishDecrypted(decrypted, authKey, msgKey);
}

Future<MtpMessage> deserializeEncryptedAsync(
    Uint8List data, Uint8List authKey) async {
  final d = TlDecoder(data);

  final keyHash = d.readRawBytes(8);
  final expectedHash = authKeyHash(authKey);
  for (var i = 0; i < 8; i++) {
    if (keyHash[i] != expectedHash[i]) {
      throw StateError('Wrong encryption key');
    }
  }

  final msgKey = d.readRawBytes(16);
  final encryptedData = d.readRawBytes(d.remaining);

  final decrypted = await decryptMessageAsync(encryptedData, authKey, msgKey);
  return _finishDecrypted(decrypted, authKey, msgKey);
}

MtpMessage _finishDecrypted(
    Uint8List decrypted, Uint8List authKey, Uint8List msgKey) {
  final dd = TlDecoder(decrypted);
  dd.readInt64(); // salt
  dd.readInt64(); // sessionId
  final msgId = dd.readInt64();
  final seqNo = dd.readInt32();
  final msgLen = dd.readUint32();

  final verifyKey = messageKey(
    authKey,
    Uint8List.fromList(decrypted),
    decode: true,
  );
  for (var i = 0; i < 16; i++) {
    if (verifyKey[i] != msgKey[i]) {
      throw StateError('Wrong message key');
    }
  }

  final msg = dd.readRawBytes(msgLen);
  return MtpMessage(msg: msg, msgId: msgId, seqNo: seqNo);
}

bool isPacketEncrypted(Uint8List data) {
  if (data.length < 8) return false;
  return ByteData.view(
        data.buffer,
        data.offsetInBytes,
      ).getInt64(0, Endian.little) !=
      0;
}
