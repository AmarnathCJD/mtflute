import 'dart:io';

// TL Schema Parser + Dart Code Generator for MTFlute
// Parses .tl schema files and generates Dart encode/decode classes

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tool/tlgen.dart <schema1.tl> [schema2.tl ...] -o <output_dir>',
    );
    exit(1);
  }

  var outputDir = 'lib/src/tg';
  final schemaFiles = <String>[];

  for (var i = 0; i < args.length; i++) {
    if (args[i] == '-o' && i + 1 < args.length) {
      outputDir = args[++i];
    } else {
      schemaFiles.add(args[i]);
    }
  }

  final allObjects = <TlObject>[];
  final allMethods = <TlMethod>[];

  for (final file in schemaFiles) {
    final source = File(file).readAsStringSync();
    final schema = parseSchema(source);
    allObjects.addAll(schema.objects);
    allMethods.addAll(schema.methods);
  }

  // Deduplicate by CRC (mtproto.tl + api.tl may overlap)
  final seenCrcs = <int>{};
  allObjects.removeWhere((o) => !seenCrcs.add(o.crc));
  allMethods.removeWhere((m) => !seenCrcs.add(m.crc));

  print(
    'Parsed ${allObjects.length} types, ${allMethods.length} methods (after dedup)',
  );

  Directory(outputDir).createSync(recursive: true);

  generateTypes(allObjects, allMethods, outputDir);
  generateMethods(allMethods, outputDir);
  generateRegistry(allObjects, allMethods, outputDir);
  generateBarrel(outputDir);

  print('Generated code in $outputDir');
}

// --- Schema Types ---

class TlParam {
  final String name;
  final String type;
  final bool isOptional;
  final int bitIndex;
  final bool isVector;
  final int flagVersion; // 1 = flags, 2 = flags2

  TlParam({
    required this.name,
    required this.type,
    this.isOptional = false,
    this.bitIndex = 0,
    this.isVector = false,
    this.flagVersion = 1,
  });
}

class TlObject {
  final String name;
  final int crc;
  final List<TlParam> params;
  final String interface_;

  TlObject({
    required this.name,
    required this.crc,
    required this.params,
    required this.interface_,
  });
}

class TlMethod {
  final String name;
  final int crc;
  final List<TlParam> params;
  final String responseType;
  final bool responseIsList;

  TlMethod({
    required this.name,
    required this.crc,
    required this.params,
    required this.responseType,
    this.responseIsList = false,
  });
}

class TlSchema {
  final List<TlObject> objects;
  final List<TlMethod> methods;
  TlSchema({required this.objects, required this.methods});
}

// --- Parser ---

TlSchema parseSchema(String source) {
  final objects = <TlObject>[];
  final methods = <TlMethod>[];
  var isFunctions = false;

  final lines = source.split('\n');
  for (var line in lines) {
    line = line.trim();
    if (line.isEmpty || line.startsWith('//')) continue;

    if (line == '---functions---') {
      isFunctions = true;
      continue;
    }
    if (line == '---types---') {
      isFunctions = false;
      continue;
    }

    if (!line.contains('#') || !line.contains('=') || !line.endsWith(';')) {
      continue;
    }

    final parsed = _parseLine(line);
    if (parsed == null) continue;

    if (isFunctions) {
      methods.add(
        TlMethod(
          name: parsed.name,
          crc: parsed.crc,
          params: parsed.params,
          responseType: parsed.eqType,
          responseIsList: parsed.isEqVector,
        ),
      );
    } else {
      objects.add(
        TlObject(
          name: parsed.name,
          crc: parsed.crc,
          params: parsed.params,
          interface_: parsed.eqType,
        ),
      );
    }
  }

  return TlSchema(objects: objects, methods: methods);
}

class _ParsedDef {
  final String name;
  final int crc;
  final List<TlParam> params;
  final String eqType;
  final bool isEqVector;
  _ParsedDef({
    required this.name,
    required this.crc,
    required this.params,
    required this.eqType,
    this.isEqVector = false,
  });
}

final _excludedNames = {
  'int',
  'long',
  'double',
  'string',
  'vector',
  'int128',
  'int256',
  'true',
  'boolTrue',
  'boolFalse',
  'null',
  'msg_copy',
  'error',
  'msg_container',
};

_ParsedDef? _parseLine(String line) {
  line = line.trimRight();
  if (line.endsWith(';')) line = line.substring(0, line.length - 1).trimRight();

  final hashIdx = line.indexOf('#');
  if (hashIdx < 0) return null;

  final name = line.substring(0, hashIdx).trim();
  if (_excludedNames.contains(name)) return null;

  final spaceAfterCrc = line.indexOf(' ', hashIdx);
  final eqIdx = line.lastIndexOf('=');
  if (eqIdx < 0) return null;

  final crcStr = line
      .substring(hashIdx + 1, spaceAfterCrc > 0 ? spaceAfterCrc : eqIdx)
      .trim();
  if (crcStr.isEmpty || !RegExp(r'^[0-9a-fA-F]+$').hasMatch(crcStr)) {
    return null;
  }
  final crc = int.parse(crcStr, radix: 16);

  var paramStr = spaceAfterCrc > 0
      ? line.substring(spaceAfterCrc, eqIdx).trim()
      : '';
  // Strip TL type-parameter declarations like `{X:Type}` — they are generics,
  // not fields. The parameter that references them (e.g. `query:!X`) will be
  // resolved to `TlObject` below.
  paramStr = paramStr.replaceAll(RegExp(r'\{[A-Za-z_]+:[A-Za-z_]+\}\s*'), '');
  var eqType = line.substring(eqIdx + 1).trim();
  // If the result type is a template variable like `X`, treat it as any TlObject.
  if (RegExp(r'^[A-Za-z_]$').hasMatch(eqType)) eqType = 'TlObject';

  var isEqVector = false;
  var resolvedEqType = eqType;
  if (eqType.startsWith('Vector<')) {
    isEqVector = true;
    resolvedEqType = eqType.substring(7, eqType.length - 1);
  }

  final params = <TlParam>[];
  if (paramStr.isNotEmpty) {
    final parts = paramStr.split(RegExp(r'\s+'));
    for (final part in parts) {
      if (part.isEmpty) continue;
      final colonIdx = part.indexOf(':');
      if (colonIdx < 0) continue;

      final pName = part.substring(0, colonIdx);
      var pType = part.substring(colonIdx + 1);

      var isOptional = false;
      var bitIndex = 0;
      var flagVersion = 1;
      var isVector = false;

      if (pType.startsWith('flags2.')) {
        flagVersion = 2;
        final qIdx = pType.indexOf('?');
        bitIndex = int.parse(pType.substring(7, qIdx));
        pType = pType.substring(qIdx + 1);
        isOptional = true;
      } else if (pType.startsWith('flags.')) {
        flagVersion = 1;
        final qIdx = pType.indexOf('?');
        bitIndex = int.parse(pType.substring(6, qIdx));
        pType = pType.substring(qIdx + 1);
        isOptional = true;
      }

      if (pType.startsWith('Vector<') || pType.startsWith('vector<')) {
        isVector = true;
        pType = pType.substring(7, pType.length - 1);
      }
      // Strip bare-type prefix '%'
      if (pType.startsWith('%')) pType = pType.substring(1);
      // `!X` (template-var reference, e.g. query:!X) → TlObject at runtime.
      if (pType.startsWith('!')) pType = 'TlObject';

      if (pName == 'flags' && pType == '#') pType = 'bitflags';
      if (pName == 'flags2' && pType == '#') pType = 'bitflags';

      params.add(
        TlParam(
          name: pName,
          type: pType,
          isOptional: isOptional,
          bitIndex: bitIndex,
          isVector: isVector,
          flagVersion: flagVersion,
        ),
      );
    }
  }

  return _ParsedDef(
    name: name,
    crc: crc,
    params: params,
    eqType: resolvedEqType,
    isEqVector: isEqVector,
  );
}

// --- Code Generation ---

String _toDartClassName(String tlName) {
  // Handle dots (e.g. auth.sendCode -> AuthSendCode), underscores, camelCase to PascalCase
  return tlName
      .split(RegExp(r'[._]'))
      .map((p) => p.isEmpty ? '' : p[0].toUpperCase() + p.substring(1))
      .join();
}

const _dartKeywords = {
  'default',
  'static',
  'class',
  'switch',
  'case',
  'new',
  'return',
  'void',
  'var',
  'final',
  'const',
  'is',
  'in',
  'this',
  'super',
  'true',
  'false',
  'null',
  'abstract',
  'enum',
  'extends',
  'implements',
  'import',
  'export',
  'assert',
  'do',
  'else',
  'for',
  'if',
  'try',
  'catch',
  'throw',
  'while',
  'with',
  'break',
  'continue',
  'operator',
};

String _toDartFieldName(String tlName) {
  final parts = tlName.split('_');
  String result;
  if (parts.length == 1) {
    result = parts[0];
  } else {
    result =
        parts[0] +
        parts
            .sublist(1)
            .map((p) => p.isEmpty ? '' : p[0].toUpperCase() + p.substring(1))
            .join();
  }
  if (_dartKeywords.contains(result)) return '${result}_';
  return result;
}

String _dartType(
  String tlType, {
  bool isVector = false,
  bool isOptional = false,
}) {
  String base;
  switch (tlType) {
    case 'int':
      base = 'int';
    case 'long':
      base = 'int';
    case 'double':
      base = 'double';
    case 'string':
      base = 'String';
    case 'bytes':
      base = 'Uint8List';
    case 'Bool':
    case 'true':
      base = 'bool';
    case 'int128':
      base = 'BigInt';
    case 'int256':
      base = 'BigInt';
    case 'Object':
    case '!X':
    case 'X':
      base = 'TlObject';
    case 'bitflags':
      base = 'int';
    default:
      base = _toDartClassName(tlType);
  }

  if (isVector) base = 'List<$base>';
  if (isOptional) base += '?';
  return base;
}

String _encodeField(TlParam p, String varName) {
  final t = p.type;
  if (p.isVector) {
    return 'e.writeCrc(0x1cb5c415); e.writeInt32($varName.length); for (final item in $varName) { ${_encodeSingle(t, 'item')} }';
  }
  return _encodeSingle(t, varName);
}

String _encodeSingle(String tlType, String varName) {
  switch (tlType) {
    case 'int':
      return 'e.writeInt32($varName);';
    case 'long':
      return 'e.writeInt64($varName);';
    case 'double':
      return 'e.writeDouble($varName);';
    case 'string':
      return 'e.writeString($varName);';
    case 'bytes':
      return 'e.writeBytes($varName);';
    case 'Bool':
      return 'e.writeBool($varName);';
    case 'true':
      return ''; // encoded in bitflag
    case 'int128':
      return 'e.writeRaw(bigIntToBytes($varName, 16));';
    case 'int256':
      return 'e.writeRaw(bigIntToBytes($varName, 32));';
    case 'bitflags':
      return ''; // computed and written separately
    default:
      return '$varName.encode(e);';
  }
}

String _decodeField(TlParam p) {
  final t = p.type;
  if (p.isVector) {
    return '() { d.readCrc(); final len = d.readUint32(); return List.generate(len, (_) => ${_decodeSingle(t)}); }()';
  }
  return _decodeSingle(t);
}

String _decodeSingle(String tlType) {
  switch (tlType) {
    case 'int':
      return 'd.readInt32()';
    case 'long':
      return 'd.readInt64()';
    case 'double':
      return 'd.readDouble()';
    case 'string':
      return 'd.readString()';
    case 'bytes':
      return 'd.readBytes()';
    case 'Bool':
      return 'd.readBool()';
    case 'true':
      return 'true';
    case 'int128':
      return 'bytesToBigInt(d.readRawBytes(16))';
    case 'int256':
      return 'bytesToBigInt(d.readRawBytes(32))';
    case 'bitflags':
      return 'd.readUint32()';
    default:
      return 'decodeObject(d) as ${_toDartClassName(tlType)}';
  }
}

void generateTypes(List<TlObject> objects, List<TlMethod> methods, String dir) {
  // Group objects by interface
  final interfaces = <String, List<TlObject>>{};
  for (final obj in objects) {
    interfaces.putIfAbsent(obj.interface_, () => []).add(obj);
  }

  final buf = StringBuffer();
  buf.writeln("// GENERATED CODE - DO NOT MODIFY BY HAND");
  buf.writeln(
    "// ignore_for_file: non_constant_identifier_names, unused_local_variable",
  );
  buf.writeln("import 'dart:typed_data';");
  buf.writeln("import '../tl/tl_encoder.dart';");
  buf.writeln("import '../tl/tl_decoder.dart';");
  buf.writeln("import '../crypto/mtproto_crypto.dart';");
  buf.writeln("import 'registry.dart';");
  buf.writeln();

  buf.writeln('abstract class TlObject {');
  buf.writeln('  int get crc;');
  buf.writeln('  void encode(TlEncoder e);');
  buf.writeln('}');
  buf.writeln();

  // Generate abstract interfaces for all TL interfaces
  for (final entry in interfaces.entries) {
    final ifaceName = _toDartClassName(entry.key);
    buf.writeln('abstract class $ifaceName extends TlObject {}');
    buf.writeln();
  }

  // All interface names (every interface gets an abstract class now)
  final allIfaceNames = interfaces.keys.map(_toDartClassName).toSet();

  // Generate concrete classes
  for (final obj in objects) {
    var className = _toDartClassName(obj.name);
    final iface = _toDartClassName(obj.interface_);

    // Avoid name collision: if concrete name == interface name, append Obj
    if (allIfaceNames.contains(className) && className == iface) {
      className = '${className}Obj';
    }

    final realParams = obj.params.where((p) => p.type != 'bitflags').toList();
    final hasFlags1 = obj.params.any(
      (p) => p.type == 'bitflags' && p.name == 'flags',
    );
    final hasFlags2 = obj.params.any(
      (p) => p.type == 'bitflags' && p.name == 'flags2',
    );

    buf.writeln('class $className extends $iface {');

    // Fields
    for (final p in realParams) {
      final isBoolFlag = p.isOptional && p.type == 'true';
      final dartType = isBoolFlag
          ? 'bool'
          : _dartType(p.type, isVector: p.isVector, isOptional: p.isOptional);
      buf.writeln('  final $dartType ${_toDartFieldName(p.name)};');
    }

    // Constructor
    if (realParams.isEmpty) {
      buf.writeln('  $className();');
    } else {
      buf.write('  $className({');
      for (final p in realParams) {
        final fname = _toDartFieldName(p.name);
        if (p.isOptional && p.type == 'true') {
          buf.write('this.$fname = false, ');
        } else if (p.isOptional) {
          buf.write('this.$fname, ');
        } else {
          buf.write('required this.$fname, ');
        }
      }
      buf.writeln('});');
    }

    // CRC
    buf.writeln('  @override');
    buf.writeln('  int get crc => 0x${obj.crc.toRadixString(16)};');

    buf.writeln('  @override');
    buf.writeln('  void encode(TlEncoder e) {');
    buf.writeln('    e.writeCrc(crc);');

    if (hasFlags1) {
      buf.write('    int flags = 0');
      for (final p in realParams.where(
        (p) => p.isOptional && p.flagVersion == 1,
      )) {
        final fname = _toDartFieldName(p.name);
        buf.write(
          p.type == 'true'
              ? ' | ($fname == true ? (1 << ${p.bitIndex}) : 0)'
              : ' | ($fname != null ? (1 << ${p.bitIndex}) : 0)',
        );
      }
      buf.writeln(';');
      buf.writeln('    e.writeUint32(flags);');
    }

    for (final p in obj.params) {
      if (p.type == 'bitflags' && p.name == 'flags') continue;
      if (p.type == 'bitflags' && p.name == 'flags2') {
        if (hasFlags2) {
          buf.write('    int flags2 = 0');
          for (final p2 in realParams.where(
            (p) => p.isOptional && p.flagVersion == 2,
          )) {
            final fname = _toDartFieldName(p2.name);
            buf.write(
              p2.type == 'true'
                  ? ' | ($fname == true ? (1 << ${p2.bitIndex}) : 0)'
                  : ' | ($fname != null ? (1 << ${p2.bitIndex}) : 0)',
            );
          }
          buf.writeln(';');
          buf.writeln('    e.writeUint32(flags2);');
        }
        continue;
      }
      final fname = _toDartFieldName(p.name);
      if (p.type == 'true') continue;
      if (p.isOptional) {
        buf.writeln(
          '    if ($fname != null) { ${_encodeField(p, '$fname!')} }',
        );
      } else {
        buf.writeln('    ${_encodeField(p, fname)}');
      }
    }
    buf.writeln('  }');

    buf.writeln('  static $className decode(TlDecoder d) {');
    if (hasFlags1) {
      buf.writeln('    final flags = d.readUint32();');
    }

    for (final p in obj.params) {
      if (p.type == 'bitflags' && p.name == 'flags') continue;
      if (p.type == 'bitflags' && p.name == 'flags2') {
        buf.writeln('    final flags2 = d.readUint32();');
        continue;
      }

      final fname = _toDartFieldName(p.name);
      final flagVar = p.flagVersion == 2 ? 'flags2' : 'flags';

      if (p.type == 'true') {
        buf.writeln(
          '    final $fname = ($flagVar & (1 << ${p.bitIndex})) != 0;',
        );
      } else if (p.isOptional) {
        final dartType = _dartType(
          p.type,
          isVector: p.isVector,
          isOptional: true,
        );
        buf.writeln(
          '    final $dartType $fname = ($flagVar & (1 << ${p.bitIndex})) != 0 ? ${_decodeField(p)} : null;',
        );
      } else {
        buf.writeln('    final $fname = ${_decodeField(p)};');
      }
    }

    buf.write('    return $className(');
    for (final p in realParams) {
      buf.write('${_toDartFieldName(p.name)}: ${_toDartFieldName(p.name)}, ');
    }
    buf.writeln(');');
    buf.writeln('  }');

    buf.writeln('}');
    buf.writeln();
  }

  File('$dir/types.dart').writeAsStringSync(buf.toString());
  print('  Generated ${objects.length} types');
}

void generateMethods(List<TlMethod> methods, String dir) {
  final buf = StringBuffer();
  buf.writeln("// GENERATED CODE - DO NOT MODIFY BY HAND");
  buf.writeln("// ignore_for_file: non_constant_identifier_names");
  buf.writeln("import 'dart:typed_data';");
  buf.writeln("import '../tl/tl_encoder.dart';");
  buf.writeln("import '../crypto/mtproto_crypto.dart';");
  buf.writeln("import 'types.dart';");
  buf.writeln();

  for (final m in methods) {
    final className = '${_toDartClassName(m.name)}Request';
    final realParams = m.params.where((p) => p.type != 'bitflags').toList();
    final hasFlags1 = m.params.any(
      (p) => p.type == 'bitflags' && p.name == 'flags',
    );
    final hasFlags2 = m.params.any(
      (p) => p.type == 'bitflags' && p.name == 'flags2',
    );

    buf.writeln('class $className extends TlObject {');
    for (final p in realParams) {
      final isBoolFlag = p.isOptional && p.type == 'true';
      final dartType = isBoolFlag
          ? 'bool'
          : _dartType(p.type, isVector: p.isVector, isOptional: p.isOptional);
      buf.writeln('  final $dartType ${_toDartFieldName(p.name)};');
    }

    if (realParams.isEmpty) {
      buf.writeln('  $className();');
    } else {
      buf.write('  $className({');
      for (final p in realParams) {
        final fname = _toDartFieldName(p.name);
        if (p.isOptional && p.type == 'true') {
          buf.write('this.$fname = false, ');
        } else if (p.isOptional) {
          buf.write('this.$fname, ');
        } else {
          buf.write('required this.$fname, ');
        }
      }
      buf.writeln('});');
    }

    buf.writeln('  @override');
    buf.writeln('  int get crc => 0x${m.crc.toRadixString(16)};');

    buf.writeln('  @override');
    buf.writeln('  void encode(TlEncoder e) {');
    buf.writeln('    e.writeCrc(crc);');

    if (hasFlags1) {
      buf.write('    int flags = 0');
      for (final p in realParams.where(
        (p) => p.isOptional && p.flagVersion == 1,
      )) {
        final fname = _toDartFieldName(p.name);
        buf.write(
          p.type == 'true'
              ? ' | ($fname == true ? (1 << ${p.bitIndex}) : 0)'
              : ' | ($fname != null ? (1 << ${p.bitIndex}) : 0)',
        );
      }
      buf.writeln(';');
      buf.writeln('    e.writeUint32(flags);');
    }

    for (final p in m.params) {
      if (p.type == 'bitflags' && p.name == 'flags') continue;
      if (p.type == 'bitflags' && p.name == 'flags2') {
        if (hasFlags2) {
          buf.write('    int flags2 = 0');
          for (final p2 in realParams.where(
            (p) => p.isOptional && p.flagVersion == 2,
          )) {
            final fname = _toDartFieldName(p2.name);
            buf.write(
              p2.type == 'true'
                  ? ' | ($fname == true ? (1 << ${p2.bitIndex}) : 0)'
                  : ' | ($fname != null ? (1 << ${p2.bitIndex}) : 0)',
            );
          }
          buf.writeln(';');
          buf.writeln('    e.writeUint32(flags2);');
        }
        continue;
      }
      final fname = _toDartFieldName(p.name);
      if (p.type == 'true') continue;
      if (p.isOptional) {
        buf.writeln(
          '    if ($fname != null) { ${_encodeField(p, '$fname!')} }',
        );
      } else {
        buf.writeln('    ${_encodeField(p, fname)}');
      }
    }
    buf.writeln('  }');

    buf.writeln('}');
    buf.writeln();
  }

  File('$dir/methods.dart').writeAsStringSync(buf.toString());
  print('  Generated ${methods.length} methods');
}

void generateRegistry(
  List<TlObject> objects,
  List<TlMethod> methods,
  String dir,
) {
  final interfaces = <String, List<TlObject>>{};
  for (final obj in objects) {
    interfaces.putIfAbsent(obj.interface_, () => []).add(obj);
  }
  final allIfaceNames = interfaces.keys.map(_toDartClassName).toSet();

  final buf = StringBuffer();
  buf.writeln("// GENERATED CODE - DO NOT MODIFY BY HAND");
  buf.writeln("import '../tl/tl_decoder.dart';");
  buf.writeln("import 'types.dart';");
  buf.writeln();

  buf.writeln('TlObject decodeObject(TlDecoder d) {');
  buf.writeln('  final crc = d.readCrc();');
  buf.writeln('  switch (crc) {');

  for (final obj in objects) {
    if (obj.params.isEmpty && obj.name.startsWith('bool')) continue;
    var className = _toDartClassName(obj.name);
    final iface = _toDartClassName(obj.interface_);
    if (allIfaceNames.contains(iface) && className == iface) {
      className = '${className}Obj';
    }
    buf.writeln('    case 0x${obj.crc.toRadixString(16)}:');
    buf.writeln('      return $className.decode(d);');
  }

  buf.writeln('    default:');
  buf.writeln(
    "      throw FormatException('Unknown TL object CRC: 0x\${crc.toRadixString(16)}');",
  );
  buf.writeln('  }');
  buf.writeln('}');

  File('$dir/registry.dart').writeAsStringSync(buf.toString());
  print('  Generated registry with ${objects.length} entries');
}

void generateBarrel(String dir) {
  final tgFile = File('$dir/tg.dart');
  if (tgFile.existsSync()) return; // don't overwrite hand-edited tg.dart

  final buf = StringBuffer();
  buf.writeln("export 'types.dart';");
  buf.writeln("export 'methods.dart';");
  buf.writeln("export 'registry.dart';");

  tgFile.writeAsStringSync(buf.toString());
}
