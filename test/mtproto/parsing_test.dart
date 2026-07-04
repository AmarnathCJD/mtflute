import 'package:test/test.dart';
import 'package:mtflute/mtflute.dart';

void main() {
  group('Markdown', () {
    test('bold', () {
      final p = parseMarkdown('hello **world**!');
      expect(p.text, 'hello world!');
      expect(p.entities, isNotNull);
      expect(p.entities!.length, 1);
      final e = p.entities!.first as MessageEntityBold;
      expect(e.offset, 6);
      expect(e.length, 5);
    });

    test('italic with underscores', () {
      final p = parseMarkdown('__abc__');
      expect(p.text, 'abc');
      expect(p.entities!.first, isA<MessageEntityItalic>());
    });

    test('inline code', () {
      final p = parseMarkdown('use `print()` here');
      expect(p.text, 'use print() here');
      expect(p.entities!.first, isA<MessageEntityCode>());
    });

    test('code block with language', () {
      final p = parseMarkdown('```dart\nprint(1);\n```');
      expect(p.text, 'print(1);\n');
      final e = p.entities!.first as MessageEntityPre;
      expect(e.language, 'dart');
    });

    test('link', () {
      final p = parseMarkdown('see [docs](https://x.com) now');
      expect(p.text, 'see docs now');
      final e = p.entities!.first as MessageEntityTextUrl;
      expect(e.url, 'https://x.com');
      expect(e.offset, 4);
      expect(e.length, 4);
    });

    test('strikethrough', () {
      final p = parseMarkdown('~~gone~~');
      expect(p.text, 'gone');
      expect(p.entities!.first, isA<MessageEntityStrike>());
    });

    test('plain text', () {
      final p = parseMarkdown('just plain');
      expect(p.text, 'just plain');
      expect(p.entities, isNull);
    });
  });

  group('HTML', () {
    test('bold and italic', () {
      final p = parseHtml('hi <b>bold</b> and <i>italic</i>');
      expect(p.text, 'hi bold and italic');
      expect(p.entities!.length, 2);
      expect(p.entities!.any((e) => e is MessageEntityBold), true);
      expect(p.entities!.any((e) => e is MessageEntityItalic), true);
    });

    test('anchor', () {
      final p = parseHtml('go <a href="https://x.com">here</a>');
      expect(p.text, 'go here');
      final e = p.entities!.first as MessageEntityTextUrl;
      expect(e.url, 'https://x.com');
    });

    test('entities', () {
      final p = parseHtml('a &lt; b &amp; c &gt; d');
      expect(p.text, 'a < b & c > d');
    });

    test('user mention', () {
      final p = parseHtml('hello <a href="tg://user?id=12345">friend</a>');
      expect(p.text, 'hello friend');
      expect(p.entities!.first, isA<InputMessageEntityMentionName>());
    });
  });
}
