// Tests do not require documentation comments.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Source-level contract for the theme data classes.
///
/// A theme class whose `==` skips a field makes `OiTheme` treat two different
/// themes as equal (no rebuild), and one that compares a collection by
/// identity makes two equal themes look different (a rebuild on every
/// parent build). Neither shows up in a widget test, so this test reads the
/// sources under `lib/src/foundation/theme` and checks every class that
/// declares `operator ==`:
///
/// * every instance field is mentioned in `==` and in `hashCode`;
/// * every `Map`, `List` or `Set` field is compared by content.
void main() {
  final classes = _collectThemeClasses();

  test('theme classes were found', () {
    expect(classes.length, greaterThan(40));
    expect(
      classes.map((c) => c.name),
      containsAll(<String>[
        'OiThemeData',
        'OiColorScheme',
        'OiDecorationTheme',
        'OiFileExplorerThemeData',
      ]),
    );
  });

  test('every field takes part in == and hashCode', () {
    final problems = <String>[];
    for (final c in classes) {
      for (final field in c.fields) {
        final word = RegExp('\\b${RegExp.escape(field.name)}\\b');
        if (!word.hasMatch(c.equalsSource)) {
          problems.add('${c.name}.${field.name} is missing from ==');
        }
        if (!word.hasMatch(c.hashCodeSource)) {
          problems.add('${c.name}.${field.name} is missing from hashCode');
        }
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('no collection field is compared by identity', () {
    final problems = <String>[];
    for (final c in classes) {
      for (final field in c.fields.where((f) => f.isCollection)) {
        final name = RegExp.escape(field.name);
        // Signs of a comparison by content: a foundation *Equals helper, or
        // a manual walk over length / elements / keys / entries.
        final byContent = RegExp(
          '(Equals\\([^)]*\\b$name\\b)|'
          '(\\b$name!?\\s*(\\.length|\\[|\\.keys|\\.entries))',
        );
        if (!byContent.hasMatch(c.equalsSource)) {
          problems.add(
            '${c.name}.${field.name} (${field.type}) is compared by '
            'identity; use mapEquals / listEquals / setEquals',
          );
        }
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('every theme data class with fields declares ==', () {
    final missing = _collectThemeClasses(requireEquals: false)
        .where((c) => c.equalsSource.isEmpty && c.fields.isNotEmpty)
        .where((c) => !_identityClasses.contains(c.name))
        .map((c) => c.name)
        .toList();
    expect(missing, isEmpty);
  });
}

/// Classes that are deliberately compared by identity.
///
/// Widgets, inherited widgets and their states are not theme data.
const _identityClasses = <String>{};

class _Field {
  _Field(this.type, this.name);

  final String type;
  final String name;

  bool get isCollection =>
      type.startsWith('Map<') ||
      type.startsWith('List<') ||
      type.startsWith('Set<');
}

class _ThemeClass {
  _ThemeClass({
    required this.name,
    required this.fields,
    required this.equalsSource,
    required this.hashCodeSource,
  });

  final String name;
  final List<_Field> fields;
  final String equalsSource;
  final String hashCodeSource;
}

List<_ThemeClass> _collectThemeClasses({bool requireEquals = true}) {
  final dir = Directory('lib/src/foundation/theme');
  final classHeader = RegExp(
    r'^(?:abstract |final |base |sealed )*class (\w+)([^{]*)\{',
    multiLine: true,
  );
  final fieldPattern = RegExp(
    r'^  (?:late )?final ([^=;()]+?)\s+(\w+);',
    multiLine: true,
  );

  final result = <_ThemeClass>[];
  final files =
      dir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  for (final file in files) {
    final source = file.readAsStringSync();
    for (final match in classHeader.allMatches(source)) {
      final header = match.group(2)!;
      // Widgets and their State classes are not data classes.
      if (RegExp(
        r'extends\s+(\w*Widget|State<|Inherited\w*)',
      ).hasMatch(header)) {
        continue;
      }
      final body = _blockAt(source, match.end - 1);
      final equalsSource = _memberSource(body, 'bool operator ==');
      final hashCodeSource = _memberSource(body, 'int get hashCode');
      if (requireEquals && equalsSource.isEmpty) continue;

      result.add(
        _ThemeClass(
          name: match.group(1)!,
          fields: [
            for (final f in fieldPattern.allMatches(body))
              _Field(f.group(1)!.trim(), f.group(2)!),
          ],
          equalsSource: equalsSource,
          hashCodeSource: hashCodeSource,
        ),
      );
    }
  }
  return result;
}

/// Returns the `{ ... }` block that starts at [openBrace] in [source].
String _blockAt(String source, int openBrace) {
  var depth = 0;
  for (var i = openBrace; i < source.length; i++) {
    final char = source[i];
    if (char == '{') depth++;
    if (char == '}') {
      depth--;
      if (depth == 0) return source.substring(openBrace, i + 1);
    }
  }
  return source.substring(openBrace);
}

/// Returns the source of the member of [body] whose declaration starts with
/// [signature], or an empty string when there is none.
String _memberSource(String body, String signature) {
  final start = body.indexOf(signature);
  if (start < 0) return '';
  final brace = body.indexOf('{', start);
  final arrow = body.indexOf('=>', start);
  if (arrow >= 0 && (brace < 0 || arrow < brace)) {
    // Expression body: ends at the first `;` outside any bracket.
    var depth = 0;
    for (var i = arrow; i < body.length; i++) {
      final char = body[i];
      if ('([{'.contains(char)) depth++;
      if (')]}'.contains(char)) depth--;
      if (char == ';' && depth == 0) return body.substring(start, i + 1);
    }
    return body.substring(start);
  }
  if (brace < 0) return '';
  return body.substring(start, brace) + _blockAt(body, brace);
}
