// One-off: prepend a minimal dartdoc to every top-level class/abstract class
// in the generated TL files. Improves pub.dev documentation coverage score.
import 'dart:io';

void main() {
  for (final path in const [
    'lib/src/tg/types.dart',
    'lib/src/tg/methods.dart',
  ]) {
    final file = File(path);
    final lines = file.readAsLinesSync();
    final out = <String>[];

    final reClass = RegExp(r'^(abstract )?class (\w+)');
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final m = reClass.firstMatch(line);
      if (m != null && (i == 0 || !lines[i - 1].trimLeft().startsWith('///'))) {
        final name = m.group(2)!;
        out.add('/// TL object: `$name`.');
      }
      out.add(line);
    }

    file.writeAsStringSync('${out.join('\n')}\n');
    print('updated $path');
  }
}
