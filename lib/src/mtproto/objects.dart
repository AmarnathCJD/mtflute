import 'dart:typed_data';

import '../tl/tl_encoder.dart';
import '../tl/tl_decoder.dart';
import '../crypto/mtproto_crypto.dart';

// CRC constants for MTProto handshake objects
const crcReqPQ = 0x60469778;
const crcReqPQMulti = 0xbe7e8ef1;
const crcResPQ = 0x05162463;
const crcPQInnerData = 0x83c95aec;
const crcPQInnerDataTempDc = 0xa9f55f95;
const crcReqDHParams = 0xd712e4be;
const crcServerDHParamsOk = 0xd0e8075c;
const crcServerDHInnerData = 0xb5890dba;
const crcClientDHInnerData = 0x6643b654;
const crcSetClientDHParams = 0xf5045f1f;
const crcDhGenOk = 0x3bcbf734;
const crcDhGenRetry = 0x46dc1fb9;
const crcDhGenFail = 0xa69dae02;
const crcMsgsAck = 0x62d6b459;
const crcPong = 0x347773c5;
const crcPingParams = 0x7abe77ec;
const crcBadServerSalt = 0xedab447b;
const crcBadMsgNotification = 0xa7eff811;
const crcNewSessionCreated = 0x9ec20908;
const crcMessageContainer = 0x73f1f8dc;
const crcRpcResult = 0xf35c6d01;
const crcRpcError = 0x2144ca19;
const crcGzipPacked = 0x3072cfa1;
const crcMsgDetailedInfo = 0x276d3ec6;
const crcMsgNewDetailedInfo = 0x809db6df;
const crcMsgsStateReq = 0xda69fb52;
const crcMsgsStateInfo = 0x04deb57d;
const crcMsgsAllInfo = 0x8cc0d131;
const crcMsgResendReq = 0x7d861a08;
const crcMsgResendAnsReq = 0x8610baeb;
const crcDestroySessionOk = 0xe22045fc;
const crcDestroySessionNone = 0x62d350c9;
const crcRpcAnswerUnknown = 0x5e2ad36e;
const crcRpcAnswerDroppedRunning = 0xcd78e586;
const crcRpcAnswerDropped = 0xa43ad8b7;
const crcFutureSalts = 0xae500895;
const crcPingDelayDisconnect = 0xf3427b8c;

class ResPQ {
  final BigInt nonce;
  final BigInt serverNonce;
  final Uint8List pq;
  final List<int> fingerprints;

  ResPQ({
    required this.nonce,
    required this.serverNonce,
    required this.pq,
    required this.fingerprints,
  });

  factory ResPQ.decode(TlDecoder d) {
    final nonce = _readInt128(d);
    final serverNonce = _readInt128(d);
    final pq = d.readBytes();
    d.readCrc(); // vector crc
    final count = d.readUint32();
    final fps = <int>[];
    for (var i = 0; i < count; i++) {
      fps.add(d.readInt64());
    }
    return ResPQ(
      nonce: nonce,
      serverNonce: serverNonce,
      pq: pq,
      fingerprints: fps,
    );
  }
}

Uint8List encodeReqPQ(BigInt nonce) {
  final e = TlEncoder();
  e.writeCrc(crcReqPQ);
  _writeInt128(e, nonce);
  return e.toBytes();
}

Uint8List encodeReqPQMulti(BigInt nonce) {
  final e = TlEncoder();
  e.writeCrc(crcReqPQMulti);
  _writeInt128(e, nonce);
  return e.toBytes();
}

Uint8List encodePQInnerData({
  required Uint8List pq,
  required Uint8List p,
  required Uint8List q,
  required BigInt nonce,
  required BigInt serverNonce,
  required BigInt newNonce,
}) {
  final e = TlEncoder();
  e.writeCrc(crcPQInnerData);
  e.writeBytes(pq);
  e.writeBytes(p);
  e.writeBytes(q);
  _writeInt128(e, nonce);
  _writeInt128(e, serverNonce);
  _writeInt256(e, newNonce);
  return e.toBytes();
}

Uint8List encodePQInnerDataTempDc({
  required Uint8List pq,
  required Uint8List p,
  required Uint8List q,
  required BigInt nonce,
  required BigInt serverNonce,
  required BigInt newNonce,
  required int dc,
  required int expiresIn,
}) {
  final e = TlEncoder();
  e.writeCrc(crcPQInnerDataTempDc);
  e.writeBytes(pq);
  e.writeBytes(p);
  e.writeBytes(q);
  _writeInt128(e, nonce);
  _writeInt128(e, serverNonce);
  _writeInt256(e, newNonce);
  e.writeInt32(dc);
  e.writeInt32(expiresIn);
  return e.toBytes();
}

Uint8List encodeReqDHParams({
  required BigInt nonce,
  required BigInt serverNonce,
  required Uint8List p,
  required Uint8List q,
  required int fingerprint,
  required Uint8List encryptedData,
}) {
  final e = TlEncoder();
  e.writeCrc(crcReqDHParams);
  _writeInt128(e, nonce);
  _writeInt128(e, serverNonce);
  e.writeBytes(p);
  e.writeBytes(q);
  e.writeInt64(fingerprint);
  e.writeBytes(encryptedData);
  return e.toBytes();
}

class ServerDHInnerData {
  final BigInt nonce;
  final BigInt serverNonce;
  final int g;
  final Uint8List dhPrime;
  final Uint8List gA;
  final int serverTime;

  ServerDHInnerData({
    required this.nonce,
    required this.serverNonce,
    required this.g,
    required this.dhPrime,
    required this.gA,
    required this.serverTime,
  });

  factory ServerDHInnerData.decode(TlDecoder d) {
    final nonce = _readInt128(d);
    final serverNonce = _readInt128(d);
    final g = d.readInt32();
    final dhPrime = d.readBytes();
    final gA = d.readBytes();
    final serverTime = d.readInt32();
    return ServerDHInnerData(
      nonce: nonce,
      serverNonce: serverNonce,
      g: g,
      dhPrime: dhPrime,
      gA: gA,
      serverTime: serverTime,
    );
  }
}

Uint8List encodeClientDHInnerData({
  required BigInt nonce,
  required BigInt serverNonce,
  required int retryId,
  required Uint8List gB,
}) {
  final e = TlEncoder();
  e.writeCrc(crcClientDHInnerData);
  _writeInt128(e, nonce);
  _writeInt128(e, serverNonce);
  e.writeInt64(retryId);
  e.writeBytes(gB);
  return e.toBytes();
}

Uint8List encodeSetClientDHParams({
  required BigInt nonce,
  required BigInt serverNonce,
  required Uint8List encryptedData,
}) {
  final e = TlEncoder();
  e.writeCrc(crcSetClientDHParams);
  _writeInt128(e, nonce);
  _writeInt128(e, serverNonce);
  e.writeBytes(encryptedData);
  return e.toBytes();
}

Uint8List encodePingParams(int pingId) {
  final e = TlEncoder();
  e.writeCrc(crcPingParams);
  e.writeInt64(pingId);
  return e.toBytes();
}

Uint8List encodeMsgsAck(List<int> msgIds) {
  final e = TlEncoder();
  e.writeCrc(crcMsgsAck);
  e.writeCrc(crcVector);
  e.writeUint32(msgIds.length);
  for (final id in msgIds) {
    e.writeInt64(id);
  }
  return e.toBytes();
}

Uint8List encodeMsgsStateInfo(int reqMsgId, Uint8List info) {
  final e = TlEncoder();
  e.writeCrc(crcMsgsStateInfo);
  e.writeInt64(reqMsgId);
  e.writeBytes(info);
  return e.toBytes();
}

const crcBindAuthKeyInner = 0x75a3f765;

Uint8List encodeBindAuthKeyInner({
  required int nonce,
  required int tempAuthKeyId,
  required int permAuthKeyId,
  required int tempSessionId,
  required int expiresAt,
}) {
  final e = TlEncoder();
  e.writeCrc(crcBindAuthKeyInner);
  e.writeInt64(nonce);
  e.writeInt64(tempAuthKeyId);
  e.writeInt64(permAuthKeyId);
  e.writeInt64(tempSessionId);
  e.writeInt32(expiresAt);
  return e.toBytes();
}

// Int128/Int256 are serialized as big-endian raw bytes in MTProto TL
BigInt _readInt128(TlDecoder d) {
  final bytes = d.readRawBytes(16);
  return bytesToBigInt(bytes);
}

void _writeInt128(TlEncoder e, BigInt value) {
  e.writeRaw(bigIntToBytes(value, 16));
}

void _writeInt256(TlEncoder e, BigInt value) {
  e.writeRaw(bigIntToBytes(value, 32));
}

BigInt randomInt128() {
  final bytes = randomBytes(16);
  return bytesToBigInt(bytes);
}

BigInt randomInt256() {
  final bytes = randomBytes(32);
  return bytesToBigInt(bytes);
}
