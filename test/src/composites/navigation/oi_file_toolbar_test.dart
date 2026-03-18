// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/components/navigation/oi_breadcrumbs.dart';
import 'package:obers_ui/src/composites/navigation/oi_file_toolbar.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

const _breadcrumbs = [
  OiBreadcrumbItem(label: 'Root'),
  OiBreadcrumbItem(label: 'Documents'),
  OiBreadcrumbItem(label: 'Photos'),
];

Widget _toolbar({
  List<OiBreadcrumbItem>? breadcrumbs,
  int selectedCount = 0,
  List<Widget> bulkActions = const [],
  ValueChanged<String>? onSearch,
}) {
  return SizedBox(
    width: 600,
    height: 60,
    child: OiFileToolbar(
      breadcrumbs: breadcrumbs ?? _breadcrumbs,
      selectedCount: selectedCount,
      bulkActions: bulkActions,
      onSearch: onSearch,
      label: 'Test toolbar',
    ),
  );
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  // ── Selection mode (REQ-0944) ────────────────────────────────────────────

  group('Selection mode (REQ-0944)', () {
    testWidgets('renders breadcrumbs when selectedCount is 0', (tester) async {
      await tester.pumpObers(_toolbar());

      expect(find.text('Root'), findsOneWidget);
      expect(find.text('Documents'), findsOneWidget);
      expect(find.text('Photos'), findsOneWidget);
      expect(find.textContaining('selected'), findsNothing);
    });

    testWidgets('shows selection bar when selectedCount > 0', (tester) async {
      await tester.pumpObers(_toolbar(selectedCount: 3));

      expect(find.text('3 selected'), findsOneWidget);
      expect(find.text('Root'), findsNothing);
    });

    testWidgets('renders bulk action widgets in selection mode', (
      tester,
    ) async {
      await tester.pumpObers(
        _toolbar(
          selectedCount: 2,
          bulkActions: const [Text('Delete'), Text('Move')],
        ),
      );

      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Move'), findsOneWidget);
    });

    testWidgets('transitions from selection back to normal when count drops', (
      tester,
    ) async {
      await tester.pumpObers(_toolbar(selectedCount: 3));
      expect(find.text('3 selected'), findsOneWidget);

      // ignore: avoid_redundant_argument_values, explicitly testing transition.
      await tester.pumpObers(_toolbar(selectedCount: 0));
      await tester.pumpAndSettle();

      expect(find.text('Root'), findsOneWidget);
      expect(find.textContaining('selected'), findsNothing);
    });
  });

  // ── Search toggle (REQ-0945) ─────────────────────────────────────────────

  group('Search toggle (REQ-0945)', () {
    testWidgets('search icon visible when onSearch provided', (tester) async {
      await tester.pumpObers(_toolbar(onSearch: (_) {}));

      expect(find.bySemanticsLabel('Search'), findsOneWidget);
    });

    testWidgets('search icon hidden when onSearch is null', (tester) async {
      await tester.pumpObers(_toolbar());

      expect(find.bySemanticsLabel('Search'), findsNothing);
    });

    testWidgets('tapping search icon shows text input', (tester) async {
      await tester.pumpObers(_toolbar(onSearch: (_) {}));

      await tester.tap(find.bySemanticsLabel('Search'));
      await tester.pumpAndSettle();

      expect(find.byType(EditableText), findsOneWidget);
    });

    testWidgets('tapping close icon hides text input and shows breadcrumbs', (
      tester,
    ) async {
      await tester.pumpObers(_toolbar(onSearch: (_) {}));

      // Open search.
      await tester.tap(find.bySemanticsLabel('Search'));
      await tester.pumpAndSettle();
      expect(find.byType(EditableText), findsOneWidget);

      // Close search.
      await tester.tap(find.bySemanticsLabel('Close search'));
      await tester.pumpAndSettle();

      expect(find.byType(EditableText), findsNothing);
      expect(find.text('Root'), findsOneWidget);
    });

    testWidgets('search toggle crossfades via OiMorph', (tester) async {
      await tester.pumpObers(_toolbar(onSearch: (_) {}));

      // Open search and pump a single frame to start the transition.
      await tester.tap(find.bySemanticsLabel('Search'));
      await tester.pump();

      // During the crossfade both a FadeTransition (from the inner OiMorph)
      // and the incoming EditableText should be present.
      expect(find.byType(FadeTransition), findsWidgets);
      expect(find.byType(EditableText), findsOneWidget);

      // Let the animation settle.
      await tester.pumpAndSettle();

      // Close search and verify the reverse crossfade.
      await tester.tap(find.bySemanticsLabel('Close search'));
      await tester.pump();

      expect(find.byType(FadeTransition), findsWidgets);

      await tester.pumpAndSettle();
      expect(find.text('Root'), findsOneWidget);
    });

    testWidgets('search field gets autofocus when opened', (tester) async {
      await tester.pumpObers(_toolbar(onSearch: (_) {}));

      await tester.tap(find.bySemanticsLabel('Search'));
      await tester.pumpAndSettle();

      final editableText = tester.widget<EditableText>(
        find.byType(EditableText),
      );
      expect(editableText.focusNode.hasFocus, isTrue);
    });
  });

  // ── Debounced search (REQ-0946) ──────────────────────────────────────────

  group('Debounced search (REQ-0946)', () {
    testWidgets('onSearch not called before debounce elapses', (tester) async {
      final calls = <String>[];
      await tester.pumpObers(_toolbar(onSearch: calls.add));

      // Open search.
      await tester.tap(find.bySemanticsLabel('Search'));
      await tester.pumpAndSettle();

      // Type text.
      await tester.enterText(find.byType(EditableText), 'hello');
      await tester.pump(const Duration(milliseconds: 200));

      expect(calls, isEmpty);
    });

    testWidgets('onSearch called after 300ms debounce', (tester) async {
      final calls = <String>[];
      await tester.pumpObers(_toolbar(onSearch: calls.add));

      await tester.tap(find.bySemanticsLabel('Search'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(EditableText), 'hello');
      await tester.pump(const Duration(milliseconds: 300));

      expect(calls, ['hello']);
    });

    testWidgets('rapid typing resets debounce', (tester) async {
      final calls = <String>[];
      await tester.pumpObers(_toolbar(onSearch: calls.add));

      await tester.tap(find.bySemanticsLabel('Search'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(EditableText), 'a');
      await tester.pump(const Duration(milliseconds: 200));

      await tester.enterText(find.byType(EditableText), 'ab');
      await tester.pump(const Duration(milliseconds: 300));

      expect(calls, ['ab']);
    });

    testWidgets('clearing text does not fire onSearch', (tester) async {
      final calls = <String>[];
      await tester.pumpObers(_toolbar(onSearch: calls.add));

      await tester.tap(find.bySemanticsLabel('Search'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(EditableText), 'test');
      await tester.pump(const Duration(milliseconds: 300));
      calls.clear();

      await tester.enterText(find.byType(EditableText), '');
      await tester.pump(const Duration(milliseconds: 300));

      expect(calls, isEmpty);
    });
  });

  // ── OiTextInput.search constructor ───────────────────────────────────────

  group('OiTextInput.search constructor', () {
    testWidgets('renders search icon and placeholder', (tester) async {
      await tester.pumpObers(
        const SizedBox(width: 300, height: 60, child: OiTextInput.search()),
      );

      // Search icon (MaterialIcons 0xe8b6).
      expect(find.byType(Icon), findsOneWidget);

      // Placeholder text.
      expect(find.text('Search\u2026'), findsOneWidget);
    });
  });
}
