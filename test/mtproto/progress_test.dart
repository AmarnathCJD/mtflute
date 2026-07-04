import 'package:test/test.dart';
import 'package:mtflute/mtflute.dart';

void main() {
  group('humanizeBytes', () {
    test('formats bytes', () {
      expect(humanizeBytes(500), '500.0 B');
      expect(humanizeBytes(1024), '1.00 KB');
      expect(humanizeBytes(1536), '1.50 KB');
      expect(humanizeBytes(1024 * 1024), '1.00 MB');
      expect(humanizeBytes(15 * 1024 * 1024), '15.0 MB');
    });
  });

  group('ProgressManager', () {
    test('calls listener on update + completion', () async {
      final calls = <ProgressInfo>[];
      final pm = ProgressManager(
        fileName: 'x.bin',
        totalBytes: 1000,
        listener: calls.add,
        interval: const Duration(milliseconds: 10),
      );

      pm.update(500);
      pm.update(1000);
      pm.stop();

      // At least the initial emit + completion emit
      expect(calls.length, greaterThanOrEqualTo(2));
      expect(calls.last.isComplete, isTrue);
      expect(calls.last.percentage, 100);
    });
  });
}
