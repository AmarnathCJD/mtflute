import 'dart:async';

class ProgressInfo {
  final String fileName;
  final int current;
  final int total;
  final double currentSpeedBps;
  final double averageSpeedBps;
  final Duration eta;
  final Duration elapsed;

  ProgressInfo({
    required this.fileName,
    required this.current,
    required this.total,
    required this.currentSpeedBps,
    required this.averageSpeedBps,
    required this.eta,
    required this.elapsed,
  });

  double get percentage => total == 0 ? 0 : (current / total) * 100;
  bool get isComplete => total > 0 && current >= total;

  String get speedHuman => '${humanizeBytes(averageSpeedBps.round())}/s';
  String get sizeHuman => '${humanizeBytes(current)} / ${humanizeBytes(total)}';

  String render({int width = 30}) {
    final pct = percentage.clamp(0, 100).toInt();
    final filled = (pct * width / 100).round();
    final bar = '█' * filled + '░' * (width - filled);
    return '$fileName  [$bar] ${pct.toString().padLeft(3)}%  $sizeHuman  $speedHuman  ETA ${_formatDuration(eta)}';
  }
}

typedef ProgressListener = void Function(ProgressInfo info);

class ProgressManager {
  final String fileName;
  final int totalBytes;
  final ProgressListener listener;
  final Duration interval;

  int _current = 0;
  late final DateTime _start;
  DateTime? _lastCallback;
  int _lastBytes = 0;
  DateTime? _lastTick;

  Timer? _timer;

  ProgressManager({
    required this.fileName,
    required this.totalBytes,
    required this.listener,
    this.interval = const Duration(seconds: 1),
  }) {
    _start = DateTime.now();
    _lastTick = _start;
    _emit(force: true);
    _timer = Timer.periodic(interval, (_) => _emit());
  }

  void update(int current) {
    _current = current;
    if (_current >= totalBytes && totalBytes > 0) {
      _emit(force: true);
      stop();
    }
  }

  void _emit({bool force = false}) {
    final now = DateTime.now();
    if (!force &&
        _lastCallback != null &&
        now.difference(_lastCallback!) < interval) {
      return;
    }
    _lastCallback = now;

    final elapsed = now.difference(_start);
    final dt = now.difference(_lastTick ?? _start).inMicroseconds / 1e6;
    final dBytes = _current - _lastBytes;
    final curSpeed = dt > 0 ? dBytes / dt : 0.0;
    final avgSpeed = elapsed.inMicroseconds > 0
        ? _current / (elapsed.inMicroseconds / 1e6)
        : 0.0;
    final remaining = totalBytes - _current;
    final eta = avgSpeed > 0 && remaining > 0
        ? Duration(seconds: (remaining / avgSpeed).round())
        : Duration.zero;

    _lastTick = now;
    _lastBytes = _current;

    listener(
      ProgressInfo(
        fileName: fileName,
        current: _current,
        total: totalBytes,
        currentSpeedBps: curSpeed.toDouble(),
        averageSpeedBps: avgSpeed,
        eta: eta,
        elapsed: elapsed,
      ),
    );
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}

String humanizeBytes(int bytes) {
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var v = bytes.toDouble();
  var idx = 0;
  while (v >= 1024 && idx < units.length - 1) {
    v /= 1024;
    idx++;
  }
  return '${v.toStringAsFixed(v < 10 && idx > 0 ? 2 : 1)} ${units[idx]}';
}

String _formatDuration(Duration d) {
  if (d == Duration.zero) return '--';
  final s = d.inSeconds;
  if (s < 60) return '${s}s';
  if (s < 3600) return '${s ~/ 60}m${(s % 60).toString().padLeft(2, '0')}s';
  return '${s ~/ 3600}h${(s % 3600 ~/ 60).toString().padLeft(2, '0')}m';
}
