import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import 'transport_mode.dart';

int _magicFor(TransportModeVariant v) {
  switch (v) {
    case TransportModeVariant.abridged:
      return 0xefefefef;
    case TransportModeVariant.intermediate:
      return 0xeeeeeeee;
    case TransportModeVariant.paddedIntermediate:
      return 0xdddddddd;
    case TransportModeVariant.full:
      return 0xeeeeeeee;
  }
}

class ObfuscationConfig {
  final TransportModeVariant variant;
  final Uint8List? secret;
  final int? dcId;
  const ObfuscationConfig({
    required this.variant,
    this.secret,
    this.dcId,
  });
}

class MtProxy {
  final String host;
  final int port;
  final Uint8List secret;

  const MtProxy({
    required this.host,
    required this.port,
    required this.secret,
  });

  factory MtProxy.fromSecret({
    required String host,
    required int port,
    required String secret,
  }) {
    return MtProxy(host: host, port: port, secret: _parseSecret(secret));
  }

  bool get isFakeTls => secret.isNotEmpty && secret[0] == 0xee;
  bool get isDd => secret.isNotEmpty && secret[0] == 0xdd;

  String? get fakeTlsDomain {
    if (!isFakeTls) return null;
    return String.fromCharCodes(secret.sublist(17));
  }

  Uint8List get rawSecret {
    if (isFakeTls) return Uint8List.fromList(secret.sublist(1, 17));
    if (isDd) return Uint8List.fromList(secret.sublist(1, 17));
    if (secret.length >= 16) return Uint8List.fromList(secret.sublist(0, 16));
    return secret;
  }

  static Uint8List _parseSecret(String s) {
    var v = s.trim();
    if (v.length.isEven && RegExp(r'^[0-9a-fA-F]+$').hasMatch(v)) {
      final out = Uint8List(v.length ~/ 2);
      for (var i = 0; i < out.length; i++) {
        out[i] = int.parse(v.substring(i * 2, i * 2 + 2), radix: 16);
      }
      return out;
    }
    var b64 = v.replaceAll('-', '+').replaceAll('_', '/');
    while (b64.length % 4 != 0) {
      b64 += '=';
    }
    return base64.decode(b64);
  }
}

class Obfuscation {
  final CTRStreamCipher _encryptor;
  final CTRStreamCipher _decryptor;
  final Uint8List initFrame;

  Obfuscation._(this._encryptor, this._decryptor, this.initFrame);

  Uint8List encrypt(Uint8List data) {
    final out = Uint8List(data.length);
    _encryptor.processBytes(data, 0, data.length, out, 0);
    return out;
  }

  Uint8List decrypt(Uint8List data) {
    final out = Uint8List(data.length);
    _decryptor.processBytes(data, 0, data.length, out, 0);
    return out;
  }

  static Obfuscation create(ObfuscationConfig config) {
    final rng = Random.secure();
    final init = Uint8List(64);
    while (true) {
      for (var i = 0; i < 64; i++) {
        init[i] = rng.nextInt(256);
      }
      if (init[0] == 0xef) continue;
      final first = ByteData.view(init.buffer).getUint32(0, Endian.little);
      if (first == 0x44414548 ||
          first == 0x54534f50 ||
          first == 0x20544547 ||
          first == 0x4954504f ||
          first == 0x02010316 ||
          first == 0xdddddddd ||
          first == 0xeeeeeeee) {
        continue;
      }
      if (ByteData.view(init.buffer).getUint32(4, Endian.little) == 0) continue;
      break;
    }

    final magic = _magicFor(config.variant);
    final bd = ByteData.view(init.buffer);
    bd.setUint32(56, magic, Endian.little);
    if (config.dcId != null) {
      bd.setInt16(60, config.dcId!, Endian.little);
    }

    return _build(init, config, isServer: false);
  }

  static Obfuscation fromInit(
    Uint8List scrambledInit,
    ObfuscationConfig config, {
    bool isServer = false,
  }) {
    return _build(Uint8List.fromList(scrambledInit), config,
        isServer: isServer);
  }

  static Obfuscation _build(
    Uint8List init,
    ObfuscationConfig config, {
    required bool isServer,
  }) {
    var encKey = Uint8List.fromList(init.sublist(8, 40));
    final encIv = Uint8List.fromList(init.sublist(40, 56));

    final reversed = Uint8List.fromList(init.reversed.toList());
    var decKey = Uint8List.fromList(reversed.sublist(8, 40));
    final decIv = Uint8List.fromList(reversed.sublist(40, 56));

    final secret = config.secret;
    if (secret != null && secret.isNotEmpty) {
      final s = _trimSecret(secret);
      encKey = _sha256Concat(encKey, s);
      decKey = _sha256Concat(decKey, s);
    }

    if (isServer) {
      final t = encKey;
      encKey = decKey;
      decKey = t;
    }
    final ivEnc = isServer ? decIv : encIv;
    final ivDec = isServer ? encIv : decIv;

    final encryptor = CTRStreamCipher(AESEngine())
      ..init(true, ParametersWithIV(KeyParameter(encKey), ivEnc));
    final decryptor = CTRStreamCipher(AESEngine())
      ..init(false, ParametersWithIV(KeyParameter(decKey), ivDec));

    final scrambled = Uint8List(64);
    if (!isServer) {
      final tmp = Uint8List(64);
      encryptor.processBytes(init, 0, 64, tmp, 0);
      scrambled.setRange(0, 56, init.sublist(0, 56));
      scrambled.setRange(56, 64, tmp.sublist(56, 64));
    } else {
      final tmp = Uint8List(64);
      decryptor.processBytes(init, 0, 64, tmp, 0);
    }

    return Obfuscation._(encryptor, decryptor, scrambled);
  }

  static Uint8List _trimSecret(Uint8List secret) {
    if (secret.length == 17 && (secret[0] == 0xdd || secret[0] == 0xee)) {
      return Uint8List.fromList(secret.sublist(1));
    }
    if (secret.length > 16) {
      return Uint8List.fromList(secret.sublist(0, 16));
    }
    return secret;
  }

  static Uint8List _sha256Concat(Uint8List a, Uint8List b) {
    final d = SHA256Digest();
    d.update(a, 0, a.length);
    d.update(b, 0, b.length);
    final out = Uint8List(32);
    d.doFinal(out, 0);
    return out;
  }
}
