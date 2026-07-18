import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import '../crypto/mtproto_crypto.dart';
import '../crypto/rsa_keys.dart';
import '../crypto/math.dart';
import '../tl/tl_decoder.dart';
import 'objects.dart';

typedef SendAndReceive = Future<Uint8List> Function(Uint8List request);

class AuthKeyResult {
  final Uint8List authKey;
  final Uint8List authKeyHash;
  final int serverSalt;
  final int serverTime;

  AuthKeyResult({
    required this.authKey,
    required this.authKeyHash,
    required this.serverSalt,
    required this.serverTime,
  });
}

Future<AuthKeyResult> performHandshake({
  required SendAndReceive sendAndReceive,
  int expiresIn = 0,
  int dcId = 2,
}) async {
  final isTemp = expiresIn > 0;
  final nonce = randomInt128();

  // Step 1: req_pq_multi
  final reqPqData = encodeReqPQMulti(nonce);
  final resPqRaw = await sendAndReceive(reqPqData);

  final resPqDecoder = TlDecoder(resPqRaw);
  final resPqCrc = resPqDecoder.readCrc();
  if (resPqCrc != crcResPQ) {
    throw StateError('Expected ResPQ, got CRC 0x${resPqCrc.toRadixString(16)}');
  }
  final resPq = ResPQ.decode(resPqDecoder);

  if (resPq.nonce != nonce) {
    throw StateError('Nonce mismatch in ResPQ');
  }

  // Find matching RSA key
  final keys = [...telegramRsaKeys, ...cdnRsaKeys];
  late final RSAPublicKey rsaKey;
  var found = false;
  for (final fp in resPq.fingerprints) {
    for (final key in keys) {
      final kfp = rsaFingerprint(key);
      final fpBytes = Uint8List(8);
      ByteData.view(fpBytes.buffer).setInt64(0, fp, Endian.little);
      if (_bytesEqual(kfp, fpBytes)) {
        rsaKey = key;
        found = true;
        break;
      }
    }
    if (found) break;
  }
  if (!found) throw StateError('No matching RSA key fingerprint');

  // Step 2: Factorize PQ
  final pq = bytesToBigInt(resPq.pq);
  final factors = factorize(pq);
  final p = factors.p;
  final q = factors.q;

  final newNonce = randomInt256();

  // Build PQ inner data
  Uint8List innerData;
  if (isTemp) {
    innerData = encodePQInnerDataTempDc(
      pq: resPq.pq,
      p: bigIntToUnsignedBytes(p),
      q: bigIntToUnsignedBytes(q),
      nonce: nonce,
      serverNonce: resPq.serverNonce,
      newNonce: newNonce,
      dc: dcId,
      expiresIn: expiresIn,
    );
  } else {
    innerData = encodePQInnerData(
      pq: resPq.pq,
      p: bigIntToUnsignedBytes(p),
      q: bigIntToUnsignedBytes(q),
      nonce: nonce,
      serverNonce: resPq.serverNonce,
      newNonce: newNonce,
    );
  }

  final hashAndMsg = Uint8List(255);
  final innerHash = sha1(innerData);
  hashAndMsg.setRange(0, innerHash.length, innerHash);
  hashAndMsg.setRange(
      innerHash.length, innerHash.length + innerData.length, innerData);
  final encryptedInner = rsaEncrypt(hashAndMsg, rsaKey);

  // Step 3: req_DH_params
  final kfp = rsaFingerprint(rsaKey);
  final fingerprint = ByteData.view(
    kfp.buffer,
    kfp.offsetInBytes,
  ).getInt64(0, Endian.little);

  final dhReqData = encodeReqDHParams(
    nonce: nonce,
    serverNonce: resPq.serverNonce,
    p: bigIntToUnsignedBytes(p),
    q: bigIntToUnsignedBytes(q),
    fingerprint: fingerprint,
    encryptedData: encryptedInner,
  );

  final dhParamsRaw = await sendAndReceive(dhReqData);
  final dhDecoder = TlDecoder(dhParamsRaw);
  final dhCrc = dhDecoder.readCrc();
  if (dhCrc != crcServerDHParamsOk) {
    throw StateError(
      'Expected ServerDHParamsOk, got CRC 0x${dhCrc.toRadixString(16)}',
    );
  }

  final dhNonce = _readInt128(dhDecoder);
  final dhServerNonce = _readInt128(dhDecoder);
  if (dhNonce != nonce || dhServerNonce != resPq.serverNonce) {
    throw StateError('Nonce mismatch in DH params');
  }

  final encryptedAnswer = dhDecoder.readBytes();
  final decryptedAnswer = decryptHandshakeMessage(
    encryptedAnswer,
    newNonce,
    resPq.serverNonce,
  );

  // Parse server DH inner data
  final innerDecoder = TlDecoder(decryptedAnswer);
  final innerCrc = innerDecoder.readCrc();
  if (innerCrc != crcServerDHInnerData) {
    throw StateError(
      'Expected ServerDHInnerData, got CRC 0x${innerCrc.toRadixString(16)}',
    );
  }
  final dhInner = ServerDHInnerData.decode(innerDecoder);

  if (dhInner.nonce != nonce || dhInner.serverNonce != resPq.serverNonce) {
    throw StateError('Nonce mismatch in DH inner data');
  }

  final dhPrime = bytesToBigInt(dhInner.dhPrime);
  final gA = bytesToBigInt(dhInner.gA);
  validateDHParams(dhInner.g, gA, dhPrime);

  // Step 4: Generate auth key via DH exchange
  const maxAttempts = 5;
  var retryId = 0;

  for (var attempt = 0; attempt < maxAttempts; attempt++) {
    final dh = makeGAB(dhInner.g, gA, dhPrime);
    validateGB(dh.gB, dhPrime);

    var authKeyBytes = bigIntToUnsignedBytes(dh.gAB);
    // auth_key must be exactly 256 bytes; left-pad with zeros if BigInt was smaller.
    if (authKeyBytes.length < 256) {
      final padded = Uint8List(256);
      padded.setRange(256 - authKeyBytes.length, 256, authKeyBytes);
      authKeyBytes = padded;
    } else if (authKeyBytes.length > 256) {
      // Trim any spurious leading zero from BigInt's two's-complement output.
      authKeyBytes = Uint8List.fromList(
          authKeyBytes.sublist(authKeyBytes.length - 256));
    }

    // Compute nonce_hash_1
    final t4 = Uint8List(32 + 1 + 8);
    t4.setRange(0, 32, bigIntToBytes(newNonce, 32));
    t4[32] = 1;
    t4.setRange(33, 41, sha1(authKeyBytes).sublist(0, 8));
    final nonceHash1 = sha1(t4).sublist(4, 20);

    // Compute server salt
    final salt = Uint8List(8);
    salt.setRange(0, 8, bigIntToBytes(newNonce, 32).sublist(0, 8));
    xorBytes(salt, bigIntToBytes(resPq.serverNonce, 16).sublist(0, 8));
    final serverSalt = ByteData.view(salt.buffer).getInt64(0, Endian.little);

    // Send client DH params
    final clientDHData = encodeClientDHInnerData(
      nonce: nonce,
      serverNonce: resPq.serverNonce,
      retryId: retryId,
      gB: bigIntToUnsignedBytes(dh.gB),
    );

    final encryptedDH = encryptHandshakeMessage(
      clientDHData,
      newNonce,
      resPq.serverNonce,
    );

    final setDhData = encodeSetClientDHParams(
      nonce: nonce,
      serverNonce: resPq.serverNonce,
      encryptedData: encryptedDH,
    );

    final dhGenRaw = await sendAndReceive(setDhData);
    final genDecoder = TlDecoder(dhGenRaw);
    final genCrc = genDecoder.readCrc();

    if (genCrc == crcDhGenOk) {
      final genNonce = _readInt128(genDecoder);
      final genServerNonce = _readInt128(genDecoder);
      final genNonceHash1 = genDecoder.readRawBytes(16);

      if (genNonce != nonce || genServerNonce != resPq.serverNonce) {
        throw StateError('Nonce mismatch in DhGenOk');
      }
      if (!_bytesEqual(Uint8List.fromList(nonceHash1), genNonceHash1)) {
        throw StateError('NonceHash1 mismatch');
      }

      return AuthKeyResult(
        authKey: authKeyBytes,
        authKeyHash: authKeyHash(authKeyBytes),
        serverSalt: serverSalt,
        serverTime: dhInner.serverTime,
      );
    } else if (genCrc == crcDhGenRetry) {
      final authKeyAuxHash = sha1(authKeyBytes).sublist(0, 8);
      retryId = ByteData.view(
        Uint8List.fromList(authKeyAuxHash).buffer,
      ).getInt64(0, Endian.little);
      continue;
    } else if (genCrc == crcDhGenFail) {
      throw StateError('Server rejected DH key generation');
    } else {
      throw StateError(
        'Unexpected DH gen response: 0x${genCrc.toRadixString(16)}',
      );
    }
  }

  throw StateError('DH key generation exhausted $maxAttempts attempts');
}

BigInt _readInt128(TlDecoder d) {
  final bytes = d.readRawBytes(16);
  return bytesToBigInt(bytes);
}

bool _bytesEqual(Uint8List a, Uint8List b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
