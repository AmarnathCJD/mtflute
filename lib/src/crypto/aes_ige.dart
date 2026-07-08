import 'dart:typed_data';

import 'package:pointycastle/export.dart';

const _blockSize = 16;

@pragma('vm:prefer-inline')
void _xorInto(Uint8List dst, Uint8List src, int srcOff) {
  for (var i = 0; i < _blockSize; i++) {
    dst[i] ^= src[srcOff + i];
  }
}

Uint8List aesIgeEncrypt(Uint8List data, Uint8List key, Uint8List iv) {
  if (data.length % _blockSize != 0) {
    throw ArgumentError('Data length must be a multiple of $_blockSize');
  }
  if (key.length != 32) throw ArgumentError('Key must be 32 bytes');
  if (iv.length != 32) throw ArgumentError('IV must be 32 bytes');

  final cipher = AESEngine()..init(true, KeyParameter(key));
  final out = Uint8List(data.length);

  final xPrev = Uint8List(_blockSize)..setRange(0, _blockSize, iv, 0);
  final yPrev = Uint8List(_blockSize)..setRange(0, _blockSize, iv, _blockSize);
  final enc = Uint8List(_blockSize);
  final blockCopy = Uint8List(_blockSize);

  for (var i = 0; i < data.length; i += _blockSize) {
    blockCopy.setRange(0, _blockSize, data, i);
    _xorInto(xPrev, data, i);
    cipher.processBlock(xPrev, 0, enc, 0);
    for (var j = 0; j < _blockSize; j++) {
      enc[j] ^= yPrev[j];
    }
    out.setRange(i, i + _blockSize, enc);
    xPrev.setRange(0, _blockSize, enc);
    yPrev.setRange(0, _blockSize, blockCopy);
  }
  return out;
}

Uint8List aesIgeDecrypt(Uint8List data, Uint8List key, Uint8List iv) {
  if (data.length % _blockSize != 0) {
    throw ArgumentError('Data length must be a multiple of $_blockSize');
  }
  if (key.length != 32) throw ArgumentError('Key must be 32 bytes');
  if (iv.length != 32) throw ArgumentError('IV must be 32 bytes');

  final cipher = AESEngine()..init(false, KeyParameter(key));
  final out = Uint8List(data.length);

  final xPrev = Uint8List(_blockSize)..setRange(0, _blockSize, iv, _blockSize);
  final yPrev = Uint8List(_blockSize)..setRange(0, _blockSize, iv, 0);
  final dec = Uint8List(_blockSize);
  final blockCopy = Uint8List(_blockSize);

  for (var i = 0; i < data.length; i += _blockSize) {
    blockCopy.setRange(0, _blockSize, data, i);
    _xorInto(xPrev, data, i);
    cipher.processBlock(xPrev, 0, dec, 0);
    for (var j = 0; j < _blockSize; j++) {
      dec[j] ^= yPrev[j];
    }
    out.setRange(i, i + _blockSize, dec);
    xPrev.setRange(0, _blockSize, dec);
    yPrev.setRange(0, _blockSize, blockCopy);
  }
  return out;
}
