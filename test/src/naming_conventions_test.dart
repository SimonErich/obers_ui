// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Returns all `.dart` files under [dir] recursively.
List<File> _dartFiles(Directory dir) {
  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();
}

void main() {
  group('Naming conventions – boolean parameters', () {
    // Matches public `final bool isXxx` or `final bool hasXxx` field
    // declarations in class bodies (also catches required named params that
    // appear as field declarations).
    final badBoolPattern = RegExp(
      r'^\s*(?:required\s+)?(?:final\s+)?bool\s+(is[A-Z]|has[A-Z])',
      multiLine: true,
    );

    // Matches public constructor parameter patterns like
    //   `required this.isXxx` / `required this.hasXxx`
    //   `this.isXxx` / `this.hasXxx`
    final badCtorParamPattern = RegExp(
      r'\bthis\.(is[A-Z][a-zA-Z0-9]*|has[A-Z][a-zA-Z0-9]*)\b',
    );

    final libDir = Directory('lib/src');

    test('no public bool field is prefixed with "is" or "has"', () {
      final violations = <String>[];

      for (final file in _dartFiles(libDir)) {
        final content = file.readAsStringSync();
        final matches = badBoolPattern.allMatches(content);
        for (final m in matches) {
          final line = content.substring(0, m.start).split('\n').length;
          violations.add('${file.path}:$line — ${m.group(0)?.trim()}');
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Boolean parameters must use descriptive adjective names (e.g. '
            '"enabled", "loading", "moreAvailable") instead of is/has-prefixed '
            'names. Violations:\n${violations.join('\n')}',
      );
    });

    test('no constructor parameter uses this.isXxx or this.hasXxx', () {
      final violations = <String>[];

      for (final file in _dartFiles(libDir)) {
        final content = file.readAsStringSync();
        final lines = content.split('\n');
        for (var i = 0; i < lines.length; i++) {
          if (badCtorParamPattern.hasMatch(lines[i])) {
            violations.add('${file.path}:${i + 1} — ${lines[i].trim()}');
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Constructor parameters must not use is/has-prefixed boolean '
            'names. Violations:\n${violations.join('\n')}',
      );
    });
  });
}
