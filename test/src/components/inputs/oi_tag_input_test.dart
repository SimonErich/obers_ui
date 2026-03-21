// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inputs/oi_tag_input.dart';
import 'package:obers_ui/src/primitives/animation/oi_shimmer.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders without error', (tester) async {
    await tester.pumpObers(const OiTagInput(tags: []));
    expect(find.byType(OiTagInput), findsOneWidget);
  });

  testWidgets('existing tags are shown as chips', (tester) async {
    await tester.pumpObers(const OiTagInput(tags: ['dart', 'flutter']));
    expect(find.text('dart'), findsOneWidget);
    expect(find.text('flutter'), findsOneWidget);
  });

  testWidgets('label is shown', (tester) async {
    await tester.pumpObers(const OiTagInput(tags: [], label: 'Skills'));
    expect(find.text('Skills'), findsOneWidget);
  });

  testWidgets('removing a tag calls onChanged', (tester) async {
    List<String>? result;
    await tester.pumpObers(
      OiTagInput(tags: const ['dart', 'flutter'], onChanged: (v) => result = v),
    );
    // Tap the first '×' remove icon.
    await tester.tap(
      find.byIcon(const IconData(0xe5cd, fontFamily: 'MaterialIcons')).first,
    );
    await tester.pump();
    expect(result, isNotNull);
    expect(result!.length, 1);
  });

  testWidgets('adding a tag via Enter calls onChanged', (tester) async {
    List<String>? result;
    await tester.pumpObers(
      OiTagInput(tags: const [], onChanged: (v) => result = v),
    );
    await tester.enterText(find.byType(EditableText), 'newtag');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(result, contains('newtag'));
  });

  testWidgets('maxTags enforces limit', (tester) async {
    List<String>? result;
    await tester.pumpObers(
      OiTagInput(
        tags: const ['a', 'b'],
        maxTags: 2,
        onChanged: (v) => result = v,
      ),
    );
    // Should not accept more tags when at limit.
    await tester.enterText(find.byType(EditableText), 'c');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    // result stays null (no change fired) because maxTags reached.
    expect(result, isNull);
  });

  // ── Autocomplete suggestion tests ──────────────────────────────────────────

  group('autocomplete suggestions', () {
    testWidgets('static suggestions dropdown appears when typing', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiTagInput(
          tags: [],
          suggestions: ['dart', 'flutter', 'database'],
        ),
      );
      await tester.enterText(find.byType(EditableText), 'da');
      await tester.pump();
      expect(find.text('dart'), findsOneWidget);
      expect(find.text('database'), findsOneWidget);
      // 'flutter' does not match 'da'.
      expect(find.text('flutter'), findsNothing);
    });

    testWidgets('selecting a suggestion adds tag', (tester) async {
      List<String>? result;
      await tester.pumpObers(
        OiTagInput(
          tags: const [],
          suggestions: const ['dart', 'flutter'],
          onChanged: (v) => result = v,
        ),
      );
      await tester.enterText(find.byType(EditableText), 'da');
      await tester.pump();
      await tester.tap(find.text('dart'));
      await tester.pump();
      expect(result, contains('dart'));
    });

    testWidgets('suggestions filtered by query', (tester) async {
      await tester.pumpObers(
        const OiTagInput(tags: [], suggestions: ['apple', 'banana', 'avocado']),
      );
      await tester.enterText(find.byType(EditableText), 'a');
      await tester.pump();
      expect(find.text('apple'), findsOneWidget);
      expect(find.text('avocado'), findsOneWidget);
      expect(find.text('banana'), findsNothing);
    });

    testWidgets('allowCustomTags=false rejects non-matching Enter', (
      tester,
    ) async {
      List<String>? result;
      await tester.pumpObers(
        OiTagInput(
          tags: const [],
          suggestions: const ['dart', 'flutter'],
          allowCustomTags: false,
          onChanged: (v) => result = v,
        ),
      );
      await tester.enterText(find.byType(EditableText), 'rust');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(result, isNull);
    });

    testWidgets('allowCustomTags=false allows suggestion selection', (
      tester,
    ) async {
      List<String>? result;
      await tester.pumpObers(
        OiTagInput(
          tags: const [],
          suggestions: const ['dart', 'flutter'],
          allowCustomTags: false,
          onChanged: (v) => result = v,
        ),
      );
      await tester.enterText(find.byType(EditableText), 'da');
      await tester.pump();
      await tester.tap(find.text('dart'));
      await tester.pump();
      expect(result, contains('dart'));
    });

    testWidgets('async suggestions show shimmer while loading', (tester) async {
      final completer = Completer<List<String>>();
      await tester.pumpObers(
        OiTagInput(
          tags: const [],
          asyncSuggestions: (_) => completer.future,
          suggestionDebounce: const Duration(milliseconds: 50),
        ),
      );
      await tester.enterText(find.byType(EditableText), 'da');
      await tester.pump();
      // Wait for debounce to trigger.
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.byType(OiShimmer), findsOneWidget);
      // Complete the future.
      completer.complete(['dart', 'database']);
      await tester.pump();
      expect(find.text('dart'), findsOneWidget);
      expect(find.text('database'), findsOneWidget);
    });

    testWidgets('dropdown closes after tag selected', (tester) async {
      await tester.pumpObers(
        OiTagInput(
          tags: const [],
          suggestions: const ['dart', 'flutter'],
          onChanged: (_) {},
        ),
      );
      await tester.enterText(find.byType(EditableText), 'da');
      await tester.pump();
      expect(find.text('dart'), findsOneWidget);
      await tester.tap(find.text('dart'));
      await tester.pump();
      // The suggestion dropdown should be hidden.
      expect(find.byKey(const ValueKey('suggestion_dart')), findsNothing);
    });

    testWidgets('existing tags excluded from suggestions', (tester) async {
      await tester.pumpObers(
        const OiTagInput(
          tags: ['dart'],
          suggestions: ['dart', 'flutter', 'database'],
        ),
      );
      await tester.enterText(find.byType(EditableText), 'da');
      await tester.pump();
      // 'dart' is already a tag — it should not appear in suggestions.
      expect(find.byKey(const ValueKey('suggestion_dart')), findsNothing);
      expect(find.text('database'), findsOneWidget);
    });

    testWidgets('empty query hides dropdown', (tester) async {
      await tester.pumpObers(
        const OiTagInput(tags: [], suggestions: ['dart', 'flutter']),
      );
      // Type something to show dropdown.
      await tester.enterText(find.byType(EditableText), 'da');
      await tester.pump();
      expect(find.text('dart'), findsOneWidget);
      // Clear to hide.
      await tester.enterText(find.byType(EditableText), '');
      await tester.pump();
      expect(find.byKey(const ValueKey('suggestion_dart')), findsNothing);
    });
  });
}
