import 'dart:io';

enum LogLevel { trace, debug, info, warn, error, off }

class Logger {
  String prefix;
  LogLevel level;
  IOSink? sink;
  bool useColor;
  bool showTimestamp;

  Logger({
    this.prefix = 'mtflute',
    this.level = LogLevel.info,
    this.sink,
    this.useColor = true,
    this.showTimestamp = true,
  });

  static final Logger root = Logger();

  Logger child(String name) => Logger(
    prefix: '$prefix:$name',
    level: level,
    sink: sink,
    useColor: useColor,
    showTimestamp: showTimestamp,
  );

  void trace(String msg) => _log(LogLevel.trace, msg);
  void debug(String msg) => _log(LogLevel.debug, msg);
  void info(String msg) => _log(LogLevel.info, msg);
  void warn(String msg) => _log(LogLevel.warn, msg);
  void error(String msg, [Object? err, StackTrace? st]) {
    _log(LogLevel.error, msg);
    if (err != null) _log(LogLevel.error, '  $err');
    if (st != null) _log(LogLevel.error, '  $st');
  }

  void _log(LogLevel l, String msg) {
    if (l.index < level.index) return;
    final tag = _tag(l);
    final ts = showTimestamp ? '${_now()} ' : '';
    final out = '$ts[$tag] $prefix: $msg';
    if (sink != null) {
      sink!.writeln(out);
    } else {
      stderr.writeln(out);
    }
  }

  static String _now() {
    final n = DateTime.now();
    String p2(int v) => v.toString().padLeft(2, '0');
    String p3(int v) => v.toString().padLeft(3, '0');
    return '${p2(n.hour)}:${p2(n.minute)}:${p2(n.second)}.${p3(n.millisecond)}';
  }

  String _tag(LogLevel l) {
    final raw = switch (l) {
      LogLevel.trace => 'TRC',
      LogLevel.debug => 'DBG',
      LogLevel.info => 'INF',
      LogLevel.warn => 'WRN',
      LogLevel.error => 'ERR',
      LogLevel.off => '',
    };
    if (!useColor) return raw;
    final color = switch (l) {
      LogLevel.trace => '\x1B[90m',
      LogLevel.debug => '\x1B[36m',
      LogLevel.info => '\x1B[32m',
      LogLevel.warn => '\x1B[33m',
      LogLevel.error => '\x1B[31m',
      LogLevel.off => '',
    };
    return '$color$raw\x1B[0m';
  }
}
