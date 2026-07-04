import '_errors_map.dart';

const _numericSuffixes = <(String, String)>[
  ('EMAIL_UNCONFIRMED_', ''),
  ('FILE_MIGRATE_', ''),
  ('FILE_PART_', '_MISSING'),
  ('FLOOD_TEST_PHONE_WAIT_', ''),
  ('FLOOD_WAIT_', ''),
  ('FLOOD_PREMIUM_WAIT_', ''),
  ('INPUT_FETCH_ERROR_', ''),
  ('INTERDC_', '_CALL_ERROR'),
  ('INTERDC_', '_CALL_RICH_ERROR'),
  ('NETWORK_MIGRATE_', ''),
  ('PASSWORD_TOO_FRESH_', ''),
  ('PHONE_MIGRATE_', ''),
  ('SESSION_TOO_FRESH_', ''),
  ('SLOWMODE_WAIT_', ''),
  ('STATS_MIGRATE_', ''),
  ('TAKEOUT_INIT_DELAY_', ''),
  ('USER_MIGRATE_', ''),
];

class TgError implements Exception {
  final int code;
  final String message;
  final String? description;
  final String method;
  final int? numericValue;

  TgError({
    required this.code,
    required this.message,
    this.description,
    this.method = '',
    this.numericValue,
  });

  bool matches(String pattern) => message.contains(pattern);

  bool get isFlood =>
      message.startsWith('FLOOD_WAIT_') ||
      message.startsWith('FLOOD_PREMIUM_WAIT_');
  bool get isMigrate =>
      message.startsWith('USER_MIGRATE_') ||
      message.startsWith('PHONE_MIGRATE_') ||
      message.startsWith('NETWORK_MIGRATE_') ||
      message.startsWith('FILE_MIGRATE_');

  int? get migrateDc => isMigrate ? numericValue : null;
  Duration? get waitDuration =>
      isFlood && numericValue != null ? Duration(seconds: numericValue!) : null;

  @override
  String toString() {
    final desc = description ?? message;
    final m = method.isEmpty ? '' : ' (in $method)';
    return '[$message]$m $desc (code $code)';
  }
}

(String name, int? value) expandError(String raw) {
  for (final entry in _numericSuffixes) {
    final prefix = entry.$1;
    final suffix = entry.$2;
    if (raw.startsWith(prefix) && raw.endsWith(suffix)) {
      final trimmed = raw.substring(prefix.length, raw.length - suffix.length);
      final n = int.tryParse(trimmed);
      if (n != null) return ('${prefix}X$suffix', n);
    }
  }
  return (raw, null);
}

TgError rpcErrorFromCode(int code, String message, {String method = ''}) {
  final (name, value) = expandError(message);
  final desc = rpcErrorDescriptions[name];
  return TgError(
    code: code,
    message: message,
    description: desc,
    method: method,
    numericValue: value,
  );
}

const Map<int, String> badMsgErrorCodes = {
  16: 'msg_id too low',
  17: 'msg_id too high',
  18: 'incorrect two lower order msg_id bits',
  19: 'container msg_id is the same as a previous message',
  20: 'message too old',
  32: 'msg_seqno too low',
  33: 'msg_seqno too high',
  34: 'an even msg_seqno expected, but odd received',
  35: 'odd msg_seqno expected, but even received',
  48: 'incorrect server salt',
  64: 'invalid container',
};

class BadMsgError implements Exception {
  final int code;
  final int msgId;
  BadMsgError({required this.code, required this.msgId});

  String get description => badMsgErrorCodes[code] ?? 'unknown bad msg code';

  @override
  String toString() =>
      'bad msg notification: code=$code msg_id=$msgId ($description)';
}
