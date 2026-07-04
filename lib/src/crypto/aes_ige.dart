import 'dart:typed_data';

import 'package:pointycastle/export.dart';

void _xor(Uint8List dst, Uint8List src, [int length = -1]) {
  final len = length < 0 ? dst.length : length;
  for (var i = 0; i < len; i++) {
    dst[i] ^= src[i];
  }
}

const _blockSize = 16;

/// AES-256-IGE encryption as used by MTProto.
Uint8List aesIgeEncrypt(Uint8List data, Uint8List key, Uint8List iv) {
  if (data.length % _blockSize != 0) {
    throw ArgumentError('Data length must be a multiple of $_blockSize');
  }
  if (key.length != 32) {
    throw ArgumentError('Key must be 32 bytes');
  }
  if (iv.length != 32) {
    throw ArgumentError('IV must be 32 bytes');
  }

  final cipher = AESEngine()..init(true, KeyParameter(key));
  final out = Uint8List(data.length);

  final xPrev = Uint8List.fromList(iv.sublist(0, _blockSize));
  final yPrev = Uint8List.fromList(iv.sublist(_blockSize));

  for (var i = 0; i < data.length; i += _blockSize) {
    final block = Uint8List.fromList(data.sublist(i, i + _blockSize));

    _xor(xPrev, block);
    final encrypted = Uint8List(_blockSize);
    cipher.processBlock(xPrev, 0, encrypted, 0);
    _xor(encrypted, yPrev);

    out.setRange(i, i + _blockSize, encrypted);

    xPrev.setRange(0, _blockSize, encrypted);
    yPrev.setRange(0, _blockSize, block);
  }

  return out;
}

/// AES-256-IGE decryption as used by MTProto.
Uint8List aesIgeDecrypt(Uint8List data, Uint8List key, Uint8List iv) {
  if (data.length % _blockSize != 0) {
    throw ArgumentError('Data length must be a multiple of $_blockSize');
  }
  if (key.length != 32) {
    throw ArgumentError('Key must be 32 bytes');
  }
  if (iv.length != 32) {
    throw ArgumentError('IV must be 32 bytes');
  }

  final cipher = AESEngine()..init(false, KeyParameter(key));
  final out = Uint8List(data.length);

  final xPrev = Uint8List.fromList(iv.sublist(_blockSize));
  final yPrev = Uint8List.fromList(iv.sublist(0, _blockSize));

  for (var i = 0; i < data.length; i += _blockSize) {
    final block = Uint8List.fromList(data.sublist(i, i + _blockSize));

    _xor(xPrev, block);
    final decrypted = Uint8List(_blockSize);
    cipher.processBlock(xPrev, 0, decrypted, 0);
    _xor(decrypted, yPrev);

    out.setRange(i, i + _blockSize, decrypted);

    xPrev.setRange(0, _blockSize, decrypted);
    yPrev.setRange(0, _blockSize, block);
  }

  return out;
}
