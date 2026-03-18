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

/// Strips single-line (`// …`) and multi-line (`/* … */`) comments from
/// [source] so that naming-convention checks do not flag commented-out code.
String _stripComments(String source) {
  // Remove multi-line comments (non-greedy).
  var result = source.replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');
  // Remove single-line comments.
  result = result.replaceAll(RegExp(r'//[^\n]*'), '');
  return result;
}

void main() {
  final libDir = Directory('lib/src');
  final allFiles = _dartFiles(libDir);

  // ── REQ-0012: Name by what it _is_ in the UI ──────────────────────────────

  group('REQ-0012 – Widget classes named by what they are in the UI', () {
    // Matches `class OiFoo extends Stateless/StatefulWidget`.
    final widgetClassPattern = RegExp(
      r'class\s+(Oi\w+)\s+extends\s+State(?:ful|less)Widget',
    );

    // Matches any public class that extends Stateless/StatefulWidget but does
    // NOT start with the Oi prefix.
    final nonOiWidgetPattern = RegExp(
      r'class\s+([A-Z]\w+)\s+extends\s+State(?:ful|less)Widget',
    );

    test('all public widgets use the Oi prefix', () {
      final violations = <String>[];

      for (final file in allFiles) {
        // Skip _internal directory — private implementation widgets.
        if (file.path.contains('/_internal/')) continue;

        final content = _stripComments(file.readAsStringSync());
        final allWidgets = nonOiWidgetPattern.allMatches(content);

        for (final m in allWidgets) {
          final className = m.group(1)!;
          // Private classes (starting with _) are fine.
          if (className.startsWith('_')) continue;
          if (!className.startsWith('Oi')) {
            final line =
                content.substring(0, m.start).split('\n').length;
            violations.add('${file.path}:$line — $className');
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'All public widget classes must start with the Oi prefix '
            '(e.g. OiButton, OiTable, OiSidebar). '
            'Violations:\n${violations.join('\n')}',
      );
    });

    test('Oi-prefixed widget names are descriptive nouns', () {
      // After the Oi prefix, the remaining name should start with an
      // uppercase letter and be at least 2 characters (e.g. OiButton,
      // not OiB or Oi).
      final violations = <String>[];

      for (final file in allFiles) {
        final content = _stripComments(file.readAsStringSync());
        final matches = widgetClassPattern.allMatches(content);

        for (final m in matches) {
          final className = m.group(1)!;
          final suffix = className.substring(2); // after "Oi"
          if (suffix.length < 2 || !RegExp(r'^[A-Z]').hasMatch(suffix)) {
            final line =
                content.substring(0, m.start).split('\n').length;
            violations.add(
              '${file.path}:$line — $className '
              '(name after Oi must be ≥2 chars and start with uppercase)',
            );
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Widget names after the Oi prefix must be descriptive nouns that '
            'start with an uppercase letter (e.g. OiButton, OiTable). '
            'Violations:\n${violations.join('\n')}',
      );
    });

    test('file names match their primary Oi widget class', () {
      // For each file containing a single primary Oi widget class, the
      // file should be named oi_<snake_case>.dart matching the class name.
      final violations = <String>[];

      for (final file in allFiles) {
        final content = _stripComments(file.readAsStringSync());
        final matches = widgetClassPattern.allMatches(content).toList();

        // Only check files that contain exactly one primary widget class.
        // Files with multiple widgets (e.g. skeleton_group) are valid.
        if (matches.length != 1) continue;

        final className = matches.first.group(1)!;
        final fileName =
            file.path.split('/').last.replaceAll('.dart', '');

        // Convert PascalCase class name to expected snake_case file name.
        // OiButton → oi_button, OiRichEditor → oi_rich_editor
        final expected = className
            .replaceAllMapped(
              RegExp(r'[A-Z]'),
              (m) => '_${m.group(0)!.toLowerCase()}',
            )
            .substring(1); // remove leading underscore

        if (fileName != expected) {
          violations.add(
            '${file.path} — class $className expected file $expected.dart',
          );
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'File names must match their primary Oi widget class in '
            'snake_case (e.g. OiButton → oi_button.dart). '
            'Violations:\n${violations.join('\n')}',
      );
    });

    test('all public enums use the Oi prefix', () {
      final nonOiEnumPattern = RegExp(
        r'enum\s+([A-Z]\w+)\s*\{',
      );

      final violations = <String>[];

      for (final file in allFiles) {
        if (file.path.contains('/_internal/')) continue;

        final content = _stripComments(file.readAsStringSync());
        final matches = nonOiEnumPattern.allMatches(content);

        for (final m in matches) {
          final enumName = m.group(1)!;
          if (enumName.startsWith('_')) continue;
          if (!enumName.startsWith('Oi')) {
            final line = content.substring(0, m.start).split('\n').length;
            violations.add('${file.path}:$line — $enumName');
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'All public enum types must start with the Oi prefix '
            '(e.g. OiThemeMode, OiDensity). '
            'Violations:\n${violations.join('\n')}',
      );
    });

    test('all public extensions use the Oi prefix', () {
      final nonOiExtensionPattern = RegExp(
        r'extension\s+([A-Z]\w+)\s+on\s+',
      );

      final violations = <String>[];

      for (final file in allFiles) {
        if (file.path.contains('/_internal/')) continue;

        final content = _stripComments(file.readAsStringSync());
        final matches = nonOiExtensionPattern.allMatches(content);

        for (final m in matches) {
          final extensionName = m.group(1)!;
          if (extensionName.startsWith('_')) continue;
          if (!extensionName.startsWith('Oi')) {
            final line = content.substring(0, m.start).split('\n').length;
            violations.add('${file.path}:$line — $extensionName');
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'All public extension types must start with the Oi prefix '
            '(e.g. OiBuildContextThemeExt, OiThemeExt). '
            'Violations:\n${violations.join('\n')}',
      );
    });
  });

  // ── REQ-0013: Props read like English ──────────────────────────────────────

  group('REQ-0013 – Boolean props read like English', () {
    // Matches public `final bool isXxx` or `final bool hasXxx` field
    // declarations and parameters (also catches required named params that
    // appear as field declarations).
    // Excludes method declarations (where bool is a return type) by
    // requiring the identifier to be followed by [;,=)] — not `(`.
    final badBoolPattern = RegExp(
      r'^\s*(?:required\s+)?(?:final\s+)?bool\s+((?:is|has)[A-Z]\w*)(?=\s*[;,=)\]])',
      multiLine: true,
    );

    // Matches public constructor parameter patterns like
    //   `required this.isXxx` / `required this.hasXxx`
    //   `this.isXxx` / `this.hasXxx`
    final badCtorParamPattern = RegExp(
      r'\bthis\.(is[A-Z][a-zA-Z0-9]*|has[A-Z][a-zA-Z0-9]*)\b',
    );

    test('no public bool field is prefixed with "is" or "has"', () {
      final violations = <String>[];

      for (final file in allFiles) {
        final content = _stripComments(file.readAsStringSync());
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

      for (final file in allFiles) {
        final content = _stripComments(file.readAsStringSync());
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

    test('boolean params use descriptive names, not single letters', () {
      // Catches single-character boolean field names like `bool b`, `bool x`.
      final singleCharBoolPattern = RegExp(
        r'(?:final\s+)?bool\s+([a-z])\b(?:\s*[;,=)])',
        multiLine: true,
      );

      final violations = <String>[];

      for (final file in allFiles) {
        final content = _stripComments(file.readAsStringSync());
        final matches = singleCharBoolPattern.allMatches(content);
        for (final m in matches) {
          final line = content.substring(0, m.start).split('\n').length;
          violations.add(
            '${file.path}:$line — bool ${m.group(1)} '
            '(use a descriptive name)',
          );
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Boolean parameters must have descriptive names that read like '
            'English (e.g. "multiSelect: true", "stickyHeader: true"). '
            'Single-character names are not allowed. '
            'Violations:\n${violations.join('\n')}',
      );
    });

    test('key widgets have English-readable boolean prop names', () {
      // Spot-check that core widgets use idiomatic English prop names
      // rather than terse abbreviations.

      // OiTable
      final tableFile = File('lib/src/composites/data/oi_table.dart');
      final tableContent = tableFile.readAsStringSync();
      expect(
        tableContent,
        contains('this.multiSelect'),
        reason: 'OiTable should use "multiSelect" (reads as English)',
      );
      expect(
        tableContent,
        contains('this.selectable'),
        reason: 'OiTable should use "selectable" (reads as English)',
      );
      expect(
        tableContent,
        contains('this.reorderable'),
        reason: 'OiTable should use "reorderable" (reads as English)',
      );
      expect(
        tableContent,
        contains('this.striped'),
        reason: 'OiTable should use "striped" (reads as English)',
      );

      // OiButton
      final buttonFile =
          File('lib/src/components/buttons/oi_button.dart');
      final buttonContent = buttonFile.readAsStringSync();
      expect(
        buttonContent,
        contains('this.enabled'),
        reason: 'OiButton should use "enabled" (reads as English)',
      );
      expect(
        buttonContent,
        contains('this.loading'),
        reason: 'OiButton should use "loading" (reads as English)',
      );
      expect(
        buttonContent,
        contains('this.fullWidth'),
        reason: 'OiButton should use "fullWidth" (reads as English)',
      );

      // OiSidebar
      final sidebarFile =
          File('lib/src/composites/navigation/oi_sidebar.dart');
      final sidebarContent = sidebarFile.readAsStringSync();
      expect(
        sidebarContent,
        contains('this.collapsible'),
        reason:
            'OiSidebarSection should use "collapsible" '
            '(reads as English)',
      );
      expect(
        sidebarContent,
        contains('this.disabled'),
        reason:
            'OiSidebarItem should use "disabled" (reads as English)',
      );

      // OiTableColumn
      expect(
        tableContent,
        contains('this.sortable'),
        reason:
            'OiTableColumn should use "sortable" (reads as English)',
      );
      expect(
        tableContent,
        contains('this.filterable'),
        reason:
            'OiTableColumn should use "filterable" '
            '(reads as English)',
      );
      expect(
        tableContent,
        contains('this.resizable'),
        reason:
            'OiTableColumn should use "resizable" '
            '(reads as English)',
      );
    });
  });

  // ── REQ-0014: Required props enforce correctness ───────────────────────────

  group('REQ-0014 – Required props enforce correctness', () {
    test('OiImage (primitives) default constructor requires alt', () {
      final file = File('lib/src/primitives/display/oi_image.dart');
      final content = file.readAsStringSync();

      expect(
        content,
        contains('required this.alt'),
        reason:
            'OiImage (primitives) must require "alt" for accessibility',
      );
    });

    test('OiImage (components) default constructor requires alt', () {
      final file = File('lib/src/components/display/oi_image.dart');
      final content = file.readAsStringSync();

      expect(
        content,
        contains('required this.alt'),
        reason:
            'OiImage (components) must require "alt" for accessibility',
      );
    });

    test('OiImage.decorative does not require alt', () {
      final primitivesFile =
          File('lib/src/primitives/display/oi_image.dart');
      final primitivesContent = primitivesFile.readAsStringSync();

      // The decorative constructor should exist and NOT require alt.
      expect(
        primitivesContent,
        contains('OiImage.decorative'),
        reason:
            'OiImage must provide a .decorative constructor for images '
            'that need no alt text',
      );

      // Verify decorative constructor sets alt to empty.
      final decorativeCtorRegex = RegExp(
        r'OiImage\.decorative\(\{[^}]*\}\)\s*:\s*alt\s*=\s*' "''",
        dotAll: true,
      );
      expect(
        decorativeCtorRegex.hasMatch(primitivesContent),
        isTrue,
        reason:
            'OiImage.decorative must set alt to empty string '
            'automatically',
      );
    });

    test('OiButton variant constructors require label', () {
      final file = File('lib/src/components/buttons/oi_button.dart');
      final content = file.readAsStringSync();

      // Each named variant constructor must have `required String label`.
      const variants = [
        'OiButton.primary',
        'OiButton.secondary',
        'OiButton.outline',
        'OiButton.ghost',
        'OiButton.destructive',
        'OiButton.soft',
        'OiButton.icon',
        'OiButton.split',
        'OiButton.countdown',
        'OiButton.confirm',
      ];

      for (final variant in variants) {
        // Search for the actual constructor declaration (not doc comments).
        final ctorPattern = RegExp(RegExp.escape(variant) + r'\s*\(\{');
        final ctorMatch = ctorPattern.firstMatch(content);
        expect(
          ctorMatch,
          isNotNull,
          reason: '$variant constructor must exist',
        );
        final ctorStart = ctorMatch!.start;

        // Find the closing parenthesis of the constructor parameter list.
        final paramStart = content.indexOf('({', ctorStart);
        final paramEnd = content.indexOf('})', paramStart);
        final paramBlock = content.substring(paramStart, paramEnd);

        // Every variant must require either `label` or (for icon-only)
        // map it to semanticLabel.
        final requiresLabel = paramBlock.contains('required String label');
        final requiresIcon =
            paramBlock.contains('required IconData icon');

        expect(
          requiresLabel || requiresIcon,
          isTrue,
          reason:
              '$variant must require "label" (or "icon" + "label" '
              'for icon-only buttons) to enforce correctness',
        );

        if (requiresLabel) {
          expect(
            paramBlock.contains('required String label'),
            isTrue,
            reason:
                '$variant must mark label as required at compile time',
          );
        }
      }
    });

    test('OiIconButton requires semanticLabel', () {
      final file = File('lib/src/components/buttons/oi_icon_button.dart');
      final content = file.readAsStringSync();

      expect(
        content,
        contains('required this.semanticLabel'),
        reason:
            'OiIconButton must require "semanticLabel" so icon-only '
            'buttons remain accessible to screen readers',
      );
    });

    test('OiGalleryItem requires alt', () {
      final file = File('lib/src/composites/media/oi_gallery.dart');
      final content = file.readAsStringSync();

      expect(
        content,
        contains('required this.alt'),
        reason:
            'OiGalleryItem must require "alt" for image accessibility',
      );
    });

    test(
      'all image-bearing widgets require alt or exclude from a11y tree',
      () {
        // Any class with an `alt` field should mark it as `required`.
        // This prevents accidentally making alt text optional.
        final altFieldPattern = RegExp(
          r'final\s+String\s+alt\b',
          multiLine: true,
        );

        final violations = <String>[];

        for (final file in allFiles) {
          final content = file.readAsStringSync();
          if (!altFieldPattern.hasMatch(content)) continue;

          // This file has an `alt` field. Verify it's required in
          // at least one constructor (the default/primary one).
          // Decorative constructors may skip alt.
          final hasRequiredAlt =
              content.contains('required this.alt') ||
              content.contains('required String alt');

          if (!hasRequiredAlt) {
            violations.add(
              '${file.path} — has "alt" field but never requires it',
            );
          }
        }

        expect(
          violations,
          isEmpty,
          reason:
              'Widgets with an "alt" field must require it in their '
              'primary constructor. Violations:\n'
              '${violations.join('\n')}',
        );
      },
    );

    test(
      'all button-like widgets require label or semanticLabel',
      () {
        // Any class whose name contains "Button" should require a label
        // or semanticLabel for accessibility.
        final buttonClassPattern = RegExp(
          r'class\s+(Oi\w*Button\w*)\s+extends\s+State(?:ful|less)Widget',
        );

        final violations = <String>[];

        for (final file in allFiles) {
          final content = file.readAsStringSync();
          final matches = buttonClassPattern.allMatches(content);

          for (final m in matches) {
            final className = m.group(1)!;
            final hasRequiredLabel =
                content.contains('required this.label') ||
                content.contains('required String label') ||
                content.contains('required this.semanticLabel') ||
                content.contains('required String semanticLabel');

            if (!hasRequiredLabel) {
              violations.add(
                '${file.path} — $className must require "label" '
                'or "semanticLabel"',
              );
            }
          }
        }

        expect(
          violations,
          isEmpty,
          reason:
              'All button widgets must require "label" or '
              '"semanticLabel" for accessibility. '
              'Violations:\n${violations.join('\n')}',
        );
      },
    );
  });
}
