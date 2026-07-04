import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import '../crypto/mtproto_crypto.dart';

const _sessionPrefix = '1BvE';
const _sessionPrefixLegacy = '1BvX';
const _legacySeparator = ':_:';
const _legacyOldSeparator = '::';

class SessionData {
  Uint8List? authKey;
  Uint8List? authKeyHash;
  int dcId;
  String ipAddr;
  int appId;
  int serverSalt;
  Map<String, dynamic>? peers;

  SessionData({
    this.authKey,
    this.authKeyHash,
    this.dcId = 4,
    this.ipAddr = '',
    this.appId = 0,
    this.serverSalt = 0,
    this.peers,
  });

  Map<String, dynamic> _publicJson() {
    final m = <String, dynamic>{};
    if (authKey != null && authKey!.isNotEmpty) m['key'] = base64.encode(authKey!);
    if (authKeyHash != null && authKeyHash!.isNotEmpty) m['hash'] = base64.encode(authKeyHash!);
    m['dc_id'] = dcId;
    if (ipAddr.isNotEmpty) m['ip_addr'] = ipAddr;
    if (appId != 0) m['app_id'] = appId;
    return m;
  }

  String encodeString() {
    final jsonStr = jsonEncode(_publicJson());
    final encoded = _rawUrlBase64Encode(utf8.encode(jsonStr));
    return '$_sessionPrefix$encoded';
  }

  static SessionData decodeString(String encoded) {
    if (encoded.startsWith(_sessionPrefix)) {
      final body = _rawUrlBase64Decode(encoded.substring(_sessionPrefix.length));
      final map = jsonDecode(utf8.decode(body)) as Map<String, dynamic>;
      return SessionData(
        authKey: map['key'] is String ? base64.decode(map['key'] as String) : null,
        authKeyHash: map['hash'] is String ? base64.decode(map['hash'] as String) : null,
        dcId: (map['dc_id'] as int?) ?? 4,
        ipAddr: (map['ip_addr'] as String?) ?? '',
        appId: (map['app_id'] as int?) ?? 0,
      );
    }
    if (encoded.startsWith(_sessionPrefixLegacy)) {
      final bytes = _rawUrlBase64Decode(encoded.substring(_sessionPrefixLegacy.length));
      final s = latin1.decode(bytes, allowInvalid: true);
      var parts = s.split(_legacySeparator);
      if (parts.length != 5) parts = s.split(_legacyOldSeparator);
      if (parts.length != 5) {
        throw const FormatException('Invalid legacy session string');
      }
      Uint8List asBytes(String part) =>
          Uint8List.fromList(latin1.encode(part));
      return SessionData(
        authKey: asBytes(parts[0]),
        authKeyHash: asBytes(parts[1]),
        ipAddr: parts[2],
        dcId: int.parse(parts[3]),
        appId: int.parse(parts[4]),
      );
    }
    throw const FormatException('Invalid session string prefix');
  }

  void saveToFile(String path, {String aesKey = ''}) {
    _writeFileAtomicSync(path, _fileBytes(aesKey));
  }

  Future<void> saveToFileAsync(String path, {String aesKey = ''}) async {
    await _writeFileAtomicAsync(path, _fileBytes(aesKey));
  }

  Uint8List _fileBytes(String aesKey) {
    final j = jsonEncode({
      'key': authKey != null ? base64Encode(authKey!) : null,
      'hash': authKeyHash != null ? base64Encode(authKeyHash!) : null,
      'salt': serverSalt,
      'hostname': ipAddr,
      'app_id': appId,
      'dc_id': dcId,
      if (peers != null) 'peers': peers,
    });
    final bytes = utf8.encode(j);
    if (aesKey.isNotEmpty) {
      final keyBytes = _padKey(aesKey);
      return aesCbcEncrypt(Uint8List.fromList(bytes), keyBytes);
    }
    return Uint8List.fromList(bytes);
  }

  static SessionData loadFromFile(String path, {String aesKey = ''}) {
    final file = File(path);
    if (!file.existsSync()) {
      throw FileSystemException('Session file not found', path);
    }
    var bytes = file.readAsBytesSync();
    if (aesKey.isNotEmpty) {
      final keyBytes = _padKey(aesKey);
      bytes = aesCbcDecrypt(bytes, keyBytes);
    }
    return _fromBytes(bytes);
  }

  static SessionData _fromBytes(Uint8List bytes) {
    final map = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    return SessionData(
      authKey: map['key'] != null ? base64Decode(map['key'] as String) : null,
      authKeyHash: map['hash'] != null
          ? base64Decode(map['hash'] as String)
          : null,
      serverSalt: map['salt'] is String
          ? _decodeBase64Int64(map['salt'] as String)
          : (map['salt'] as int? ?? 0),
      ipAddr: map['hostname'] as String? ?? '',
      appId: map['app_id'] as int? ?? 0,
      dcId: map['dc_id'] as int? ?? 4,
      peers: map['peers'] as Map<String, dynamic>?,
    );
  }

  static Uint8List _padKey(String key) {
    final bytes = utf8.encode(key);
    if (bytes.length >= 16) return Uint8List.fromList(bytes.sublist(0, 16));
    final padded = Uint8List(16);
    padded.setRange(0, bytes.length, bytes);
    return padded;
  }

  static int _decodeBase64Int64(String b64) {
    final bytes = base64Decode(b64);
    return ByteData.view(
      Uint8List.fromList(bytes).buffer,
    ).getInt64(0, Endian.little);
  }
}

String _uniqueTmpPath(String path) {
  final t = DateTime.now().microsecondsSinceEpoch;
  final pid = pidHash();
  return '$path.$pid.$t.tmp';
}

int pidHash() {
  try {
    return pid & 0xffff;
  } catch (_) {
    return 0;
  }
}

void _writeFileAtomicSync(String path, Uint8List bytes) {
  final tmpPath = _uniqueTmpPath(path);
  final tmp = File(tmpPath);
  final raf = tmp.openSync(mode: FileMode.write);
  try {
    raf.writeFromSync(bytes);
    raf.flushSync();
  } finally {
    raf.closeSync();
  }
  if (Platform.isWindows) {
    final target = File(path);
    if (target.existsSync()) {
      try { target.deleteSync(); } catch (_) {}
    }
  }
  try {
    tmp.renameSync(path);
  } catch (_) {
    try { tmp.deleteSync(); } catch (_) {}
    rethrow;
  }
}

Future<void> _writeFileAtomicAsync(String path, Uint8List bytes) async {
  final tmpPath = _uniqueTmpPath(path);
  final tmp = File(tmpPath);
  final raf = await tmp.open(mode: FileMode.write);
  try {
    await raf.writeFrom(bytes);
    await raf.flush();
  } finally {
    await raf.close();
  }
  if (Platform.isWindows) {
    final target = File(path);
    if (await target.exists()) {
      try { await target.delete(); } catch (_) {}
    }
  }
  try {
    await tmp.rename(path);
  } catch (_) {
    try { await tmp.delete(); } catch (_) {}
    rethrow;
  }
}

String _rawUrlBase64Encode(List<int> data) {
  var s = base64Url.encode(data);
  final pad = s.indexOf('=');
  if (pad >= 0) s = s.substring(0, pad);
  return s;
}

Uint8List _rawUrlBase64Decode(String s) {
  final padded = s + ('=' * ((4 - s.length % 4) % 4));
  return base64Url.decode(padded);
}
