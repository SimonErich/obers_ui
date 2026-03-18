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
            final line = content.substring(0, m.start).split('\n').length;
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

    test('all public classes use the Oi prefix', () {
      // Matches any public class declaration: class, abstract class,
      // sealed class, base class, final class, mixin class, abstract
      // mixin class — that extends or implements something.
      final publicClassPattern = RegExp(
        r'(?:abstract\s+|sealed\s+|base\s+|final\s+|mixin\s+)*'
        r'class\s+([A-Z]\w+)',
      );

      final violations = <String>[];

      for (final file in allFiles) {
        // Skip _internal directory — private implementation classes.
        if (file.path.contains('/_internal/')) continue;

        final content = _stripComments(file.readAsStringSync());
        final matches = publicClassPattern.allMatches(content);

        for (final m in matches) {
          final className = m.group(1)!;
          // Private classes (starting with _) are fine.
          if (className.startsWith('_')) continue;
          // State<X> subclasses are widget implementation details.
          // Check if the class extends State<...>.
          final afterClass = content.substring(m.end);
          if (RegExp(r'^\s+extends\s+State\s*<').hasMatch(afterClass)) {
            continue;
          }
          if (!className.startsWith('Oi')) {
            final line = content.substring(0, m.start).split('\n').length;
            violations.add('${file.path}:$line — $className');
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'All public classes must start with the Oi prefix '
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
            final line = content.substring(0, m.start).split('\n').length;
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
      // For each file containing Oi widget classes, the file name should
      // match (at least one of) the class names in snake_case.
      final violations = <String>[];

      for (final file in allFiles) {
        final content = _stripComments(file.readAsStringSync());
        final matches = widgetClassPattern.allMatches(content).toList();

        if (matches.isEmpty) continue;

        final fileName = file.path.split('/').last.replaceAll('.dart', '');

        // Convert PascalCase class name to expected snake_case file name.
        // OiButton → oi_button, OiRichEditor → oi_rich_editor
        String toSnake(String className) {
          return className
              .replaceAllMapped(
                RegExp(r'[A-Z]'),
                (m) => '_${m.group(0)!.toLowerCase()}',
              )
              .substring(1); // remove leading underscore
        }

        // The file name must match at least one of the widget class names.
        final matchesAny = matches.any((m) => toSnake(m.group(1)!) == fileName);

        if (!matchesAny) {
          final classNames = matches.map((m) => m.group(1)!).join(', ');
          violations.add(
            '${file.path} — contains [$classNames] but file name '
            '"$fileName.dart" does not match any of them',
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
      final nonOiEnumPattern = RegExp(r'enum\s+([A-Z]\w+)\s*\{');

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
      final nonOiExtensionPattern = RegExp(r'extension\s+([A-Z]\w+)\s+on\s+');

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
      final buttonFile = File('lib/src/components/buttons/oi_button.dart');
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
      final sidebarFile = File('lib/src/composites/navigation/oi_sidebar.dart');
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
        reason: 'OiSidebarItem should use "disabled" (reads as English)',
      );

      // OiTableColumn
      expect(
        tableContent,
        contains('this.sortable'),
        reason: 'OiTableColumn should use "sortable" (reads as English)',
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

  // ── REQ-0017: Booleans are descriptive ──────────────────────────────────────

  group('REQ-0017 – Booleans are descriptive', () {
    // Matches public bool-returning methods (non-getters) with is/has prefix.
    // e.g. `bool isBreakpointActive(…)` or `bool hasPermission(…)`.
    // Excludes: getters (bool get isXxx), private methods (bool _isXxx),
    // and static utility methods in utils/ files.
    final badBoolMethodPattern = RegExp(
      r'^\s*bool\s+(is[A-Z]\w*|has[A-Z]\w*)\s*\(',
      multiLine: true,
    );

    test('no public bool method uses is/has prefix (except utils)', () {
      final violations = <String>[];

      for (final file in allFiles) {
        // Static utility methods (isImage, isToday, etc.) are acceptable
        // in utils/ files — these are pure classification helpers, not
        // widget API surface.
        if (file.path.contains('/utils/')) continue;
        // Skip _internal directory — private implementation.
        if (file.path.contains('/_internal/')) continue;

        final content = _stripComments(file.readAsStringSync());
        final matches = badBoolMethodPattern.allMatches(content);
        for (final m in matches) {
          final name = m.group(1)!;
          // Private methods are fine.
          if (name.startsWith('_')) continue;
          final line = content.substring(0, m.start).split('\n').length;
          violations.add('${file.path}:$line — $name()');
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Public bool-returning methods must use descriptive names '
            '(e.g. "breakpointActive", "atLeast") instead of is/has-prefixed '
            'names. Violations:\n${violations.join('\n')}',
      );
    });

    test('key widgets use descriptive single-word boolean adjectives', () {
      // Spot-check that core widgets use descriptive adjective-form booleans
      // as specified by REQ-0017: enabled, dismissible, searchable, loading.

      // OiButton — enabled, loading
      final buttonFile = File('lib/src/components/buttons/oi_button.dart');
      final buttonContent = buttonFile.readAsStringSync();
      expect(
        buttonContent,
        contains('this.enabled'),
        reason: 'OiButton should use "enabled" (descriptive adjective)',
      );
      expect(
        buttonContent,
        contains('this.loading'),
        reason: 'OiButton should use "loading" (descriptive adjective)',
      );

      // OiDialog — dismissible
      final dialogFile = File('lib/src/components/overlays/oi_dialog.dart');
      final dialogContent = dialogFile.readAsStringSync();
      expect(
        dialogContent,
        contains('this.dismissible'),
        reason: 'OiDialog should use "dismissible" (descriptive adjective)',
      );

      // OiSelect — searchable
      final selectFile = File('lib/src/components/inputs/oi_select.dart');
      final selectContent = selectFile.readAsStringSync();
      expect(
        selectContent,
        contains('this.searchable'),
        reason: 'OiSelect should use "searchable" (descriptive adjective)',
      );

      // OiTappable — enabled, focusable
      final tappableFile = File(
        'lib/src/primitives/interaction/oi_tappable.dart',
      );
      final tappableContent = tappableFile.readAsStringSync();
      expect(
        tappableContent,
        contains('this.enabled'),
        reason: 'OiTappable should use "enabled" (descriptive adjective)',
      );
      expect(
        tappableContent,
        contains('this.focusable'),
        reason: 'OiTappable should use "focusable" (descriptive adjective)',
      );

      // OiSheet — dismissible
      final sheetFile = File('lib/src/components/overlays/oi_sheet.dart');
      final sheetContent = sheetFile.readAsStringSync();
      expect(
        sheetContent,
        contains('this.dismissible'),
        reason: 'OiSheet should use "dismissible" (descriptive adjective)',
      );

      // OiTextInput — enabled, readOnly, obscureText, autofocus
      final textInputFile = File(
        'lib/src/components/inputs/oi_text_input.dart',
      );
      final textInputContent = textInputFile.readAsStringSync();
      expect(
        textInputContent,
        contains('this.enabled'),
        reason: 'OiTextInput should use "enabled" (descriptive adjective)',
      );
      expect(
        textInputContent,
        contains('this.readOnly'),
        reason: 'OiTextInput should use "readOnly" (descriptive adjective)',
      );
      expect(
        textInputContent,
        contains('this.obscureText'),
        reason: 'OiTextInput should use "obscureText" (descriptive adjective)',
      );
      expect(
        textInputContent,
        contains('this.autofocus'),
        reason: 'OiTextInput should use "autofocus" (descriptive adjective)',
      );

      // OiSwitch — enabled
      final switchFile = File('lib/src/components/inputs/oi_switch.dart');
      final switchContent = switchFile.readAsStringSync();
      expect(
        switchContent,
        contains('this.enabled'),
        reason: 'OiSwitch should use "enabled" (descriptive adjective)',
      );

      // OiCheckbox — enabled
      final checkboxFile = File('lib/src/components/inputs/oi_checkbox.dart');
      final checkboxContent = checkboxFile.readAsStringSync();
      expect(
        checkboxContent,
        contains('this.enabled'),
        reason: 'OiCheckbox should use "enabled" (descriptive adjective)',
      );

      // OiPanel — dismissible
      final panelFile = File('lib/src/components/panels/oi_panel.dart');
      final panelContent = panelFile.readAsStringSync();
      expect(
        panelContent,
        contains('this.dismissible'),
        reason: 'OiPanel should use "dismissible" (descriptive adjective)',
      );

      // OiCard — collapsible
      final cardFile = File('lib/src/components/display/oi_card.dart');
      final cardContent = cardFile.readAsStringSync();
      expect(
        cardContent,
        contains('this.collapsible'),
        reason: 'OiCard should use "collapsible" (descriptive adjective)',
      );

      // OiTree — selectable, multiSelect
      final treeFile = File('lib/src/composites/data/oi_tree.dart');
      final treeContent = treeFile.readAsStringSync();
      expect(
        treeContent,
        contains('this.selectable'),
        reason: 'OiTree should use "selectable" (descriptive adjective)',
      );
      expect(
        treeContent,
        contains('this.multiSelect'),
        reason: 'OiTree should use "multiSelect" (descriptive adjective)',
      );

      // OiSwipeable — dismissible
      final swipeableFile = File(
        'lib/src/primitives/gesture/oi_swipeable.dart',
      );
      final swipeableContent = swipeableFile.readAsStringSync();
      expect(
        swipeableContent,
        contains('this.dismissible'),
        reason: 'OiSwipeable should use "dismissible" (descriptive adjective)',
      );

      // OiTabs — scrollable
      final tabsFile = File('lib/src/components/navigation/oi_tabs.dart');
      final tabsContent = tabsFile.readAsStringSync();
      expect(
        tabsContent,
        contains('this.scrollable'),
        reason: 'OiTabs should use "scrollable" (descriptive adjective)',
      );

      // OiRichEditor — readOnly
      final richEditorFile = File(
        'lib/src/composites/editors/oi_rich_editor.dart',
      );
      final richEditorContent = richEditorFile.readAsStringSync();
      expect(
        richEditorContent,
        contains('this.readOnly'),
        reason: 'OiRichEditor should use "readOnly" (descriptive adjective)',
      );

      // OiRawInput — enabled, readOnly, obscureText, autofocus
      final rawInputFile = File(
        'lib/src/primitives/input/oi_raw_input.dart',
      );
      final rawInputContent = rawInputFile.readAsStringSync();
      expect(
        rawInputContent,
        contains('this.enabled'),
        reason: 'OiRawInput should use "enabled" (descriptive adjective)',
      );
      expect(
        rawInputContent,
        contains('this.readOnly'),
        reason: 'OiRawInput should use "readOnly" (descriptive adjective)',
      );
      expect(
        rawInputContent,
        contains('this.obscureText'),
        reason: 'OiRawInput should use "obscureText" (descriptive adjective)',
      );
      expect(
        rawInputContent,
        contains('this.autofocus'),
        reason: 'OiRawInput should use "autofocus" (descriptive adjective)',
      );
    });

    test('boolean fields use consistent adjective form', () {
      // Verify no common non-adjective patterns exist as bool fields.
      // e.g. `bool doX`, `bool canX`, `bool shouldX` in public API.
      // These are procedural, not descriptive.
      final proceduralBoolPattern = RegExp(
        r'^\s*(?:final\s+)?bool\s+(do[A-Z]\w*|should[A-Z]\w*)(?=\s*[;,=)\]])',
        multiLine: true,
      );

      final violations = <String>[];

      for (final file in allFiles) {
        if (file.path.contains('/_internal/')) continue;

        final content = _stripComments(file.readAsStringSync());
        final matches = proceduralBoolPattern.allMatches(content);
        for (final m in matches) {
          final name = m.group(1)!;
          if (name.startsWith('_')) continue;
          final line = content.substring(0, m.start).split('\n').length;
          violations.add('${file.path}:$line — $name');
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Boolean fields should use adjective form (e.g. "enabled", '
            '"dismissible", "loading") instead of procedural prefixes like '
            '"do" or "should". Violations:\n${violations.join('\n')}',
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
        reason: 'OiImage (primitives) must require "alt" for accessibility',
      );
    });

    test('OiImage (components) default constructor requires alt', () {
      final file = File('lib/src/components/display/oi_image.dart');
      final content = file.readAsStringSync();

      expect(
        content,
        contains('required this.alt'),
        reason: 'OiImage (components) must require "alt" for accessibility',
      );
    });

    test('OiImage.decorative does not require alt', () {
      final primitivesFile = File('lib/src/primitives/display/oi_image.dart');
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
        r'OiImage\.decorative\(\{[^}]*\}\)\s*:\s*alt\s*=\s*'
        "''",
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
        expect(ctorMatch, isNotNull, reason: '$variant constructor must exist');
        final ctorStart = ctorMatch!.start;

        // Find the closing parenthesis of the constructor parameter list.
        final paramStart = content.indexOf('({', ctorStart);
        final paramEnd = content.indexOf('})', paramStart);
        final paramBlock = content.substring(paramStart, paramEnd);

        // Every variant must require either `label` or (for icon-only)
        // map it to semanticLabel.
        final requiresLabel = paramBlock.contains('required String label');
        final requiresIcon = paramBlock.contains('required IconData icon');

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
            reason: '$variant must mark label as required at compile time',
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
        reason: 'OiGalleryItem must require "alt" for image accessibility',
      );
    });

    test('all image-bearing widgets require alt or exclude from a11y tree', () {
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
    });

    test('all button-like widgets require label or semanticLabel', () {
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
    });
  });

  // ── REQ-0015: Factories for variants ──────────────────────────────────────

  group('REQ-0015 – Widgets with variants use factory/named constructors', () {
    // General: any widget file that defines an OiXxxStyle enum must use a
    // private base constructor and provide a named constructor for each
    // enum value.
    test(
      'widgets with private base constructors cover all style enum values',
      () {
        // If a widget uses the factory/named-constructor pattern (private
        // base constructor + OiXxxStyle enum), every enum value must have a
        // corresponding named constructor.
        final styleEnumPattern = RegExp(
          r'enum\s+(Oi\w+Style)\s*\{([^}]*)\}',
          dotAll: true,
        );
        final enumValuePattern = RegExp(r'^\s*([a-z]\w*)', multiLine: true);

        final violations = <String>[];

        for (final file in allFiles) {
          final content = _stripComments(file.readAsStringSync());
          final styleMatches = styleEnumPattern.allMatches(content);

          for (final styleMatch in styleMatches) {
            final enumName = styleMatch.group(1)!;
            final enumBody = styleMatch.group(2)!;

            // Derive widget class name: OiBadgeStyle → OiBadge.
            final widgetName = enumName.replaceFirst('Style', '');

            // Only check widgets that opted into the factory pattern.
            final privateCtor = RegExp(RegExp.escape(widgetName) + r'\._\s*\(');
            if (!privateCtor.hasMatch(content)) continue;

            // Extract enum value names.
            final values = enumValuePattern
                .allMatches(enumBody)
                .map((m) => m.group(1)!)
                .toList();

            // Verify a named constructor exists for each style value.
            for (final value in values) {
              if (!content.contains('$widgetName.$value(')) {
                violations.add(
                  '${file.path} — $widgetName missing named constructor '
                  '.$value() for $enumName.$value',
                );
              }
            }
          }
        }

        expect(
          violations,
          isEmpty,
          reason:
              'Widgets using the factory pattern (private base constructor) '
              'must provide named constructors for every style enum value. '
              'Violations:\n${violations.join('\n')}',
        );
      },
    );

    test('OiBadge provides factory constructors for each style', () {
      final file = File('lib/src/components/display/oi_badge.dart');
      final content = file.readAsStringSync();

      expect(
        content,
        contains('OiBadge._({'),
        reason: 'OiBadge must use a private base constructor',
      );

      for (final variant in ['filled', 'soft', 'outline']) {
        expect(
          content,
          contains('OiBadge.$variant({'),
          reason: 'OiBadge must provide .$variant() named constructor',
        );
      }
    });

    test('OiProgress provides factory constructors for each style', () {
      final file = File('lib/src/components/display/oi_progress.dart');
      final content = file.readAsStringSync();

      expect(
        content,
        contains('OiProgress._({'),
        reason: 'OiProgress must use a private base constructor',
      );

      for (final variant in ['linear', 'circular', 'steps']) {
        expect(
          content,
          contains('OiProgress.$variant('),
          reason: 'OiProgress must provide .$variant() named constructor',
        );
      }
    });

    test('OiSpacer.flex() named constructor exists', () {
      final file = File('lib/src/primitives/layout/oi_spacer.dart');
      final content = file.readAsStringSync();

      expect(
        content,
        contains('OiSpacer.flex('),
        reason: 'OiSpacer must provide a .flex() named constructor',
      );
    });

    test('OiCard provides factory constructors for each variant', () {
      final file = File('lib/src/components/display/oi_card.dart');
      final content = file.readAsStringSync();

      expect(
        content,
        contains('OiCard._({'),
        reason: 'OiCard must use a private base constructor',
      );

      const variants = ['flat', 'outlined', 'interactive', 'compact'];
      for (final variant in variants) {
        expect(
          content,
          contains('OiCard.$variant('),
          reason: 'OiCard must provide .$variant() named constructor',
        );
      }
    });

    test('OiDivider provides named constructors for content variants', () {
      final file = File('lib/src/primitives/display/oi_divider.dart');
      final content = file.readAsStringSync();

      expect(
        content,
        contains('OiDivider.withLabel('),
        reason: 'OiDivider must provide a .withLabel() named constructor',
      );
      expect(
        content,
        contains('OiDivider.withContent('),
        reason: 'OiDivider must provide a .withContent() named constructor',
      );
    });

    test('OiButton provides factory constructors for each variant', () {
      final file = File('lib/src/components/buttons/oi_button.dart');
      final content = file.readAsStringSync();

      expect(
        content,
        contains('OiButton._({'),
        reason: 'OiButton must use a private base constructor',
      );

      const variants = [
        'primary',
        'secondary',
        'outline',
        'ghost',
        'destructive',
        'soft',
        'icon',
        'split',
        'countdown',
        'confirm',
      ];
      for (final variant in variants) {
        expect(
          content,
          contains('OiButton.$variant('),
          reason: 'OiButton must provide .$variant() named constructor',
        );
      }
    });
  });
}
