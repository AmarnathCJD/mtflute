import '../tg/tg.dart';

class ParsedText {
  final String text;
  final List<MessageEntity>? entities;
  ParsedText(this.text, this.entities);
}

ParsedText parseText(String input, String mode) {
  switch (mode.toLowerCase()) {
    case 'md':
    case 'markdown':
      return parseMarkdown(input);
    case 'html':
      return parseHtml(input);
    default:
      return ParsedText(input, null);
  }
}

ParsedText parseMarkdown(String input) {
  final entities = <MessageEntity>[];
  final out = StringBuffer();
  var i = 0;

  while (i < input.length) {
    if (input.startsWith('**', i)) {
      final end = input.indexOf('**', i + 2);
      if (end > 0) {
        final start = out.length;
        out.write(input.substring(i + 2, end));
        entities.add(MessageEntityBold(offset: start, length: end - i - 2));
        i = end + 2;
        continue;
      }
    }
    if (input.startsWith('__', i)) {
      final end = input.indexOf('__', i + 2);
      if (end > 0) {
        final start = out.length;
        out.write(input.substring(i + 2, end));
        entities.add(MessageEntityItalic(offset: start, length: end - i - 2));
        i = end + 2;
        continue;
      }
    }
    if (input[i] == '~' && input.startsWith('~~', i)) {
      final end = input.indexOf('~~', i + 2);
      if (end > 0) {
        final start = out.length;
        out.write(input.substring(i + 2, end));
        entities.add(MessageEntityStrike(offset: start, length: end - i - 2));
        i = end + 2;
        continue;
      }
    }
    if (input[i] == '`') {
      if (input.startsWith('```', i)) {
        final end = input.indexOf('```', i + 3);
        if (end > 0) {
          final start = out.length;
          var body = input.substring(i + 3, end);
          var language = '';
          final nl = body.indexOf('\n');
          if (nl >= 0 && nl < 30 && !body.substring(0, nl).contains(' ')) {
            language = body.substring(0, nl);
            body = body.substring(nl + 1);
          }
          out.write(body);
          entities.add(
            MessageEntityPre(
              offset: start,
              length: body.length,
              language: language,
            ),
          );
          i = end + 3;
          continue;
        }
      } else {
        final end = input.indexOf('`', i + 1);
        if (end > 0) {
          final start = out.length;
          out.write(input.substring(i + 1, end));
          entities.add(MessageEntityCode(offset: start, length: end - i - 1));
          i = end + 1;
          continue;
        }
      }
    }
    if (input[i] == '[') {
      final closeBracket = input.indexOf(']', i + 1);
      if (closeBracket > 0 &&
          closeBracket + 1 < input.length &&
          input[closeBracket + 1] == '(') {
        final closeParen = input.indexOf(')', closeBracket + 2);
        if (closeParen > 0) {
          final label = input.substring(i + 1, closeBracket);
          final url = input.substring(closeBracket + 2, closeParen);
          final start = out.length;
          out.write(label);
          entities.add(
            MessageEntityTextUrl(offset: start, length: label.length, url: url),
          );
          i = closeParen + 1;
          continue;
        }
      }
    }
    out.write(input[i]);
    i++;
  }

  return ParsedText(out.toString(), entities.isEmpty ? null : entities);
}

ParsedText parseHtml(String input) {
  final entities = <MessageEntity>[];
  final out = StringBuffer();
  final stack = <_TagOpen>[];
  var i = 0;

  while (i < input.length) {
    if (input[i] == '<') {
      final close = input.indexOf('>', i);
      if (close < 0) {
        out.write(input[i]);
        i++;
        continue;
      }
      var tag = input.substring(i + 1, close).trim();
      final isClose = tag.startsWith('/');
      if (isClose) tag = tag.substring(1).trim();

      String name;
      final spIdx = tag.indexOf(' ');
      if (spIdx > 0) {
        name = tag.substring(0, spIdx).toLowerCase();
      } else {
        name = tag.toLowerCase();
      }

      if (isClose) {
        final idx = stack.lastIndexWhere((o) => o.name == name);
        if (idx >= 0) {
          final open = stack.removeAt(idx);
          final length = out.length - open.start;
          final e = _toEntity(name, open.start, length, open.attrs);
          if (e != null) entities.add(e);
        }
      } else {
        final attrs = _parseAttrs(tag.substring(name.length));
        stack.add(_TagOpen(name, out.length, attrs));
        if (name == 'br') {
          out.writeln();
          stack.removeLast();
        }
      }

      i = close + 1;
      continue;
    }
    if (input[i] == '&') {
      final sc = input.indexOf(';', i);
      if (sc > 0 && sc - i <= 8) {
        final entity = input.substring(i + 1, sc);
        final ch = _htmlEntities[entity];
        if (ch != null) {
          out.write(ch);
          i = sc + 1;
          continue;
        }
      }
    }
    out.write(input[i]);
    i++;
  }

  return ParsedText(out.toString(), entities.isEmpty ? null : entities);
}

class _TagOpen {
  final String name;
  final int start;
  final Map<String, String> attrs;
  _TagOpen(this.name, this.start, this.attrs);
}

Map<String, String> _parseAttrs(String s) {
  final result = <String, String>{};
  final re = RegExp(r'''(\w+)\s*=\s*(?:"([^"]*)"|'([^']*)')''');
  for (final m in re.allMatches(s)) {
    result[m.group(1)!.toLowerCase()] = m.group(2) ?? m.group(3) ?? '';
  }
  return result;
}

MessageEntity? _toEntity(
  String tag,
  int offset,
  int length,
  Map<String, String> attrs,
) {
  switch (tag) {
    case 'b':
    case 'strong':
      return MessageEntityBold(offset: offset, length: length);
    case 'i':
    case 'em':
      return MessageEntityItalic(offset: offset, length: length);
    case 'u':
      return MessageEntityUnderline(offset: offset, length: length);
    case 's':
    case 'strike':
    case 'del':
      return MessageEntityStrike(offset: offset, length: length);
    case 'code':
      return MessageEntityCode(offset: offset, length: length);
    case 'pre':
      return MessageEntityPre(
        offset: offset,
        length: length,
        language: attrs['language'] ?? '',
      );
    case 'spoiler':
    case 'tg-spoiler':
      return MessageEntitySpoiler(offset: offset, length: length);
    case 'blockquote':
      return MessageEntityBlockquote(
        offset: offset,
        length: length,
        collapsed: attrs['expandable'] != null,
      );
    case 'a':
      final href = attrs['href'] ?? '';
      if (href.startsWith('tg://user?id=')) {
        final uid = int.tryParse(href.substring('tg://user?id='.length));
        if (uid != null) {
          return InputMessageEntityMentionName(
            offset: offset,
            length: length,
            userId: InputUserObj(userId: uid, accessHash: 0),
          );
        }
      }
      return MessageEntityTextUrl(offset: offset, length: length, url: href);
  }
  return null;
}

const _htmlEntities = {
  'lt': '<',
  'gt': '>',
  'amp': '&',
  'quot': '"',
  'apos': "'",
  'nbsp': ' ',
};
