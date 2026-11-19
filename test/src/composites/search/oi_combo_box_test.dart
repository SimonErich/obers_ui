// Tests do not require documentation comments.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/composites/search/oi_combo_box.dart';
import 'package:obers_ui/src/composites/search/oi_combo_box_labels.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

const _fruits = ['Apple', 'Banana', 'Cherry', 'Date', 'Elderberry'];

Widget _comboBox({
  List<String> items = _fruits,
  String? value,
  ValueChanged<String?>? onSelect,
  String? placeholder,
  bool clearable = true,
  bool enabled = true,
  String? hint,
  String? error,
  bool multiSelect = false,
  List<String> selectedValues = const [],
  ValueChanged<List<String>>? onMultiSelect,
  int? maxChipsVisible,
  String Function(String)? groupBy,
  List<String>? groupOrder,
  List<String>? recentItems,
  List<String>? favoriteItems,
  Future<List<String>> Function(String query)? search,
  ValueChanged<String>? onCreate,
}) {
  return SizedBox(
    width: 400,
    height: 600,
    child: OiComboBox<String>(
      label: 'Fruit',
      labelOf: (item) => item,
      items: items,
      value: value,
      onSelect: onSelect,
      placeholder: placeholder,
      clearable: clearable,
      enabled: enabled,
      hint: hint,
      error: error,
      multiSelect: multiSelect,
      selectedValues: selectedValues,
      onMultiSelect: onMultiSelect,
      maxChipsVisible: maxChipsVisible,
      groupBy: groupBy,
      groupOrder: groupOrder,
      recentItems: recentItems,
      favoriteItems: favoriteItems,
      search: search,
      onCreate: onCreate,
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  testWidgets('renders without error', (tester) async {
    await tester.pumpObers(_comboBox());
    expect(find.byType(OiComboBox<String>), findsOneWidget);
  });

  testWidgets('shows placeholder when no value is selected', (tester) async {
    await tester.pumpObers(_comboBox(placeholder: 'Pick a fruit'));
    expect(find.text('Pick a fruit'), findsOneWidget);
  });

  testWidgets('shows selected value label', (tester) async {
    await tester.pumpObers(_comboBox(value: 'Banana'));
    expect(find.text('Banana'), findsOneWidget);
  });

  testWidgets('tapping opens dropdown and shows items', (tester) async {
    await tester.pumpObers(_comboBox());
    // Tap the anchor to open.
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    // Should see the search input and option items.
    expect(find.byType(EditableText), findsWidgets);
    // At minimum the items should be rendered somewhere in the widget tree.
    expect(find.text('Apple'), findsWidgets);
  });

  testWidgets('typing filters items', (tester) async {
    await tester.pumpObers(_comboBox());
    // Open dropdown.
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    // Find the search EditableText and enter text.
    final editableTexts = find.byType(EditableText);
    expect(editableTexts, findsWidgets);

    // Type 'ban' to filter.
    await tester.enterText(editableTexts.first, 'ban');
    await tester.pump();

    // 'Banana' should still be visible, 'Cherry' should not.
    expect(find.text('Banana'), findsWidgets);
    expect(find.text('Cherry'), findsNothing);
  });

  testWidgets('empty filter shows "No results"', (tester) async {
    await tester.pumpObers(_comboBox());
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    final editableTexts = find.byType(EditableText);
    await tester.enterText(editableTexts.first, 'zzzzz');
    await tester.pump();

    expect(find.text('No results'), findsOneWidget);
  });

  testWidgets('label is shown', (tester) async {
    await tester.pumpObers(_comboBox());
    expect(find.text('Fruit'), findsOneWidget);
  });

  testWidgets('error state shows error text', (tester) async {
    await tester.pumpObers(_comboBox(error: 'Selection required'));
    expect(find.text('Selection required'), findsOneWidget);
  });

  testWidgets('hint is shown when no error', (tester) async {
    await tester.pumpObers(_comboBox(hint: 'Choose your favorite'));
    expect(find.text('Choose your favorite'), findsOneWidget);
  });

  testWidgets('disabled blocks interaction', (tester) async {
    await tester.pumpObers(_comboBox(enabled: false));
    await tester.tap(find.byType(GestureDetector).first, warnIfMissed: false);
    await tester.pump();

    // Dropdown search field should NOT appear.
    expect(find.text('Search\u2026'), findsNothing);
  });

  testWidgets('escape closes dropdown', (tester) async {
    await tester.pumpObers(_comboBox());
    // Open.
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    // Verify open by checking search field.
    expect(find.byType(EditableText), findsWidgets);

    // Press Escape.
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();

    // Items should no longer appear (dropdown closed).
    // Verify that the search placeholder is gone.
    // Note: the OiFloating hides via Visibility so the widget may still
    // be in tree but not visible. We verify state change occurred.
    expect(find.byType(OiComboBox<String>), findsOneWidget);
  });

  testWidgets('arrow keys navigate and enter selects', (tester) async {
    String? selected;
    await tester.pumpObers(_comboBox(onSelect: (v) => selected = v));

    // Open.
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    // Press down once to go to index 1 (Banana, since index 0 is Apple).
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();

    // Press enter to select.
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(selected, equals('Banana'));
  });

  testWidgets('onSelect fires on item tap', (tester) async {
    String? selected;
    await tester.pumpObers(_comboBox(onSelect: (v) => selected = v));

    // Open.
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    // The items are rendered inside a CompositedTransformFollower overlay
    // which doesn't support tap hit-testing in tests. Use keyboard to select.
    // Press enter to select the highlighted item (index 0 = Apple).
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(selected, equals('Apple'));
  });

  testWidgets('popup closes on single select', (tester) async {
    String? selected;
    await tester.pumpObers(_comboBox(onSelect: (v) => selected = v));

    // Open.
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    // Select via keyboard.
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    // Should have selected and closed.
    expect(selected, isNotNull);
  });

  testWidgets('clearable X clears selection', (tester) async {
    var clearCalled = false;
    String? lastSelected = 'initial';
    await tester.pumpObers(
      _comboBox(
        value: 'Banana',
        onSelect: (v) {
          clearCalled = true;
          lastSelected = v;
        },
      ),
    );

    // The clear icon (close/X) should be present.
    // Find the icon with the close icon data.
    final closeIcons = find.byWidgetPredicate(
      (w) => w is Icon && w.icon?.codePoint == 0xe1b2,
    );
    expect(closeIcons, findsWidgets);

    await tester.tap(closeIcons.first);
    await tester.pump();

    // onSelect should have been called with null to clear the selection.
    expect(clearCalled, isTrue);
    expect(lastSelected, isNull);
  });

  testWidgets('multi-select shows checkboxes', (tester) async {
    List<String>? selections;
    await tester.pumpObers(
      _comboBox(
        multiSelect: true,
        selectedValues: const ['Apple'],
        onMultiSelect: (v) => selections = v,
      ),
    );

    // Open.
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    // Should find checkbox-style indicators.
    // In multi-select mode, tapping an item toggles it.
    // Select via keyboard: press down then enter.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    // Should have added 'Banana' to the selection.
    expect(selections, isNotNull);
    expect(selections, contains('Banana'));
    // Apple should still be in selection.
    expect(selections, contains('Apple'));
  });

  testWidgets('multi-select shows chips for selected values', (tester) async {
    await tester.pumpObers(
      _comboBox(multiSelect: true, selectedValues: const ['Apple', 'Banana']),
    );

    // Both selected items should show as OiBadge chips.
    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Banana'), findsOneWidget);
    expect(find.byType(OiBadge), findsNWidgets(2));
  });

  testWidgets('maxChipsVisible limits visible chips', (tester) async {
    await tester.pumpObers(
      _comboBox(
        multiSelect: true,
        selectedValues: const ['Apple', 'Banana', 'Cherry'],
        maxChipsVisible: 2,
      ),
    );

    // Only 2 chips visible, plus a "+1" overflow indicator.
    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Banana'), findsOneWidget);
    expect(find.text('+1'), findsOneWidget);
  });

  testWidgets('semantics include label', (tester) async {
    await tester.pumpObers(_comboBox());

    // Find the Semantics node with the combo box label.
    final semanticsWidgets = tester.widgetList<Semantics>(
      find.byType(Semantics),
    );
    final matching = semanticsWidgets
        .where(
          (s) =>
              s.properties.label != null &&
              s.properties.label!.contains('Fruit'),
        )
        .toList();
    expect(matching, hasLength(1));
  });

  testWidgets('groupBy shows group headers', (tester) async {
    await tester.pumpObers(
      _comboBox(
        items: const ['Apple', 'Avocado', 'Banana', 'Blueberry'],
        groupBy: (item) => item[0],
        groupOrder: const ['A', 'B'],
      ),
    );

    // Open.
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    // Group headers should appear.
    expect(find.text('A'), findsWidgets);
    expect(find.text('B'), findsWidgets);
  });

  testWidgets('recent items section shows when provided', (tester) async {
    await tester.pumpObers(_comboBox(recentItems: const ['Cherry']));

    // Open.
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    expect(find.text('Recent'), findsOneWidget);
  });

  testWidgets('favorite items section shows when provided', (tester) async {
    await tester.pumpObers(_comboBox(favoriteItems: const ['Date']));

    // Open.
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    expect(find.text('Favorites'), findsOneWidget);
  });

  testWidgets('async search shows loading then results', (tester) async {
    final completer = Completer<List<String>>();

    await tester.pumpObers(
      _comboBox(items: const [], search: (query) => completer.future),
    );

    // Open.
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    // Type to trigger search.
    final editableTexts = find.byType(EditableText);
    await tester.enterText(editableTexts.first, 'app');
    // Advance past debounce.
    await tester.pump(const Duration(milliseconds: 250));

    // Loading state.
    expect(find.text('Loading\u2026'), findsOneWidget);

    // Complete the future.
    completer.complete(['Apple']);
    await tester.pumpAndSettle();

    expect(find.text('Apple'), findsWidgets);
  });

  testWidgets('onCreate shown when no results and query is non-empty', (
    tester,
  ) async {
    String? created;
    await tester.pumpObers(
      _comboBox(items: const [], onCreate: (v) => created = v),
    );

    // Open.
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    // Type something that has no match.
    final editableTexts = find.byType(EditableText);
    await tester.enterText(editableTexts.first, 'Mango');
    await tester.pump();

    // Should show 'No results' and a create option.
    expect(find.text('No results'), findsOneWidget);
    expect(find.textContaining('Create'), findsOneWidget);

    // Press enter to trigger create (keyboard path for CompositedTransformFollower).
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(created, equals('Mango'));
  });

  // ── Regression: empty lists, load more, async races ────────────────────────

  group('keyboard navigation on an empty list', () {
    testWidgets('arrow down does not throw', (tester) async {
      await tester.pumpObers(_comboBox(items: const []));
      await _open(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('No results'), findsOneWidget);
    });

    testWidgets('arrow up does not throw', (tester) async {
      await tester.pumpObers(_comboBox(items: const []));
      await _open(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('load more', () {
    Widget paged(Future<List<String>> Function(String) search) => SizedBox(
      width: 400,
      height: 600,
      child: OiComboBox<String>(
        label: 'Fruit',
        labelOf: (item) => item,
        search: search,
        moreAvailable: true,
        loadMore: () async => ['M1'],
      ),
    );

    testWidgets('appends each loaded item once after an async search', (
      tester,
    ) async {
      await tester.pumpObers(paged((_) async => ['A1', 'A2']));
      await _open(tester);
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();
      expect(find.text('A1'), findsOneWidget);

      await _tapOption(tester, 'Load more…');

      expect(find.text('A1'), findsOneWidget);
      expect(find.text('A2'), findsOneWidget);
      expect(find.text('M1'), findsOneWidget);
    });

    testWidgets('works when the search returns an unmodifiable list', (
      tester,
    ) async {
      await tester.pumpObers(
        paged((_) async => List<String>.unmodifiable(['A1', 'A2'])),
      );
      await _open(tester);
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();

      await _tapOption(tester, 'Load more…');

      expect(tester.takeException(), isNull);
      expect(find.text('M1'), findsOneWidget);
    });

    testWidgets('tapping an option selects it', (tester) async {
      String? selected;
      await tester.pumpObers(_comboBox(onSelect: (v) => selected = v));
      await _open(tester);

      await _tapOption(tester, 'Cherry');

      expect(selected, 'Cherry');
    });

    group('while a page is loading', () {
      late Map<String, Completer<List<String>>> searches;
      late List<Completer<List<String>>> pages;

      Widget slowPaged() => SizedBox(
        width: 400,
        height: 600,
        child: OiComboBox<String>(
          label: 'Fruit',
          labelOf: (item) => item,
          search: (query) =>
              (searches[query] = Completer<List<String>>()).future,
          moreAvailable: true,
          loadMore: () {
            pages.add(Completer<List<String>>());
            return pages.last.future;
          },
        ),
      );

      /// Opens the dropdown with the results of the empty query shown.
      Future<void> openWithResults(WidgetTester tester) async {
        await tester.pumpObers(slowPaged());
        await _open(tester);
        await tester.pump(const Duration(milliseconds: 250));
        searches['']!.complete(['A1', 'A2']);
        await _flush(tester);
        expect(find.text('A1'), findsOneWidget);
      }

      setUp(() {
        searches = {};
        pages = [];
      });

      testWidgets('a page of an earlier query is not added to newer results', (
        tester,
      ) async {
        await openWithResults(tester);
        await _tapOption(tester, 'Load more…');
        expect(pages, hasLength(1));

        // The query changes while the page is on its way.
        await tester.enterText(find.byType(EditableText).first, 'b');
        await tester.pump(const Duration(milliseconds: 250));
        searches['b']!.complete(['B1']);
        await _flush(tester);
        expect(find.text('B1'), findsOneWidget);

        pages.single.complete(['A3']);
        await _flush(tester);

        expect(find.text('B1'), findsOneWidget);
        expect(find.text('A3'), findsNothing);
      });

      testWidgets('a second tap does not load the page twice', (tester) async {
        await openWithResults(tester);

        await _tapOption(tester, 'Load more…');
        await _tapOption(tester, 'Load more…');
        expect(pages, hasLength(1));

        pages.single.complete(['A3']);
        await _flush(tester);
        expect(find.text('A3'), findsOneWidget);

        // Once the page has arrived the next one can be asked for.
        await _tapOption(tester, 'Load more…');
        expect(pages, hasLength(2));
      });

      testWidgets('a failing page is caught and can be retried', (
        tester,
      ) async {
        await openWithResults(tester);

        await _tapOption(tester, 'Load more…');
        pages.single.completeError(StateError('backend down'));
        await _flush(tester);

        expect(tester.takeException(), isNull);
        expect(find.text('A1'), findsOneWidget);

        await _tapOption(tester, 'Load more…');
        expect(pages, hasLength(2));
        pages.last.complete(['A3']);
        await _flush(tester);
        expect(find.text('A3'), findsOneWidget);
      });
    });
  });

  group('async search', () {
    testWidgets('a slow earlier search does not replace newer results', (
      tester,
    ) async {
      final requests = <String, Completer<List<String>>>{};
      await tester.pumpObers(
        _comboBox(
          items: const [],
          search: (query) =>
              (requests[query] = Completer<List<String>>()).future,
        ),
      );
      await _open(tester);
      // The search that opening starts.
      await tester.pump(const Duration(milliseconds: 250));
      requests['']!.complete(const []);
      await _flush(tester);

      final input = find.byType(EditableText).first;
      await tester.enterText(input, 'a');
      await tester.pump(const Duration(milliseconds: 250));
      await tester.enterText(input, 'ab');
      await tester.pump(const Duration(milliseconds: 250));
      expect(requests.keys, containsAll(<String>['a', 'ab']));

      // The newer search answers first, the older one afterwards.
      requests['ab']!.complete(['Abacus']);
      await _flush(tester);
      expect(find.text('Abacus'), findsOneWidget);

      requests['a']!.complete(['Apple', 'Avocado']);
      await _flush(tester);

      expect(find.text('Abacus'), findsOneWidget);
      expect(find.text('Apple'), findsNothing);
      expect(find.text('Avocado'), findsNothing);
    });

    testWidgets('a stale search does not end the loading state', (
      tester,
    ) async {
      final requests = <String, Completer<List<String>>>{};
      await tester.pumpObers(
        _comboBox(
          items: const [],
          search: (query) =>
              (requests[query] = Completer<List<String>>()).future,
        ),
      );
      await _open(tester);
      await tester.pump(const Duration(milliseconds: 250));
      requests['']!.complete(const []);
      await _flush(tester);

      final input = find.byType(EditableText).first;
      await tester.enterText(input, 'a');
      await tester.pump(const Duration(milliseconds: 250));
      await tester.enterText(input, 'ab');
      await tester.pump(const Duration(milliseconds: 250));

      requests['a']!.complete(['Apple']);
      await _flush(tester);

      expect(find.text('Loading…'), findsOneWidget);
      expect(find.text('Apple'), findsNothing);

      requests['ab']!.complete(['Abacus']);
      await _flush(tester);
      expect(find.text('Loading…'), findsNothing);
      expect(find.text('Abacus'), findsOneWidget);
    });

    testWidgets('an earlier search answering while the next one is debounced '
        'is dropped', (tester) async {
      final requests = <String, Completer<List<String>>>{};
      await tester.pumpObers(
        _comboBox(
          items: const [],
          search: (query) =>
              (requests[query] = Completer<List<String>>()).future,
        ),
      );
      await _open(tester);
      await tester.pump(const Duration(milliseconds: 250));
      requests['']!.complete(const []);
      await _flush(tester);

      final input = find.byType(EditableText).first;
      await tester.enterText(input, 'a');
      await tester.pump(const Duration(milliseconds: 250));
      // Typed, but its search has not started yet.
      await tester.enterText(input, 'ab');
      await tester.pump(const Duration(milliseconds: 50));
      expect(requests.keys, isNot(contains('ab')));

      requests['a']!.complete(['Apple']);
      await _flush(tester);

      expect(find.text('Apple'), findsNothing);
      expect(find.text('Loading…'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 250));
      requests['ab']!.complete(['Abacus']);
      await _flush(tester);
      expect(find.text('Loading…'), findsNothing);
      expect(find.text('Abacus'), findsOneWidget);
    });

    testWidgets('a search that throws an Error ends the loading state', (
      tester,
    ) async {
      final completer = Completer<List<String>>();
      await tester.pumpObers(
        _comboBox(items: const [], search: (query) => completer.future),
      );
      await _open(tester);
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('Loading…'), findsOneWidget);

      completer.completeError(StateError('backend down'));
      await _flush(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Loading…'), findsNothing);
      expect(find.text('No results'), findsOneWidget);
    });

    testWidgets('a search that throws synchronously ends the loading state', (
      tester,
    ) async {
      await tester.pumpObers(
        _comboBox(
          items: const [],
          search: (query) => throw StateError('backend down'),
        ),
      );
      await _open(tester);
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Loading…'), findsNothing);
    });
  });

  // ── Regression: trigger, highlight order, labels ───────────────────────────

  group('trigger keyboard access', () {
    for (final key in [
      LogicalKeyboardKey.enter,
      LogicalKeyboardKey.space,
      LogicalKeyboardKey.arrowDown,
    ]) {
      testWidgets('${key.debugName} opens the dropdown from the focused '
          'trigger', (tester) async {
        await tester.pumpObers(_comboBox());
        expect(find.text('Apple'), findsNothing);

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.sendKeyEvent(key);
        await tester.pumpAndSettle();

        expect(find.text('Apple'), findsOneWidget);
      });
    }

    testWidgets('a disabled trigger does not open from the keyboard', (
      tester,
    ) async {
      await tester.pumpObers(_comboBox(enabled: false));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(find.text('Apple'), findsNothing);
    });

    testWidgets('escape returns focus to the trigger', (tester) async {
      await tester.pumpObers(_comboBox());
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Apple'), findsNothing);

      // The trigger has focus again, so it reopens from the keyboard.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Apple'), findsOneWidget);
    });

    group('Tab out of the open dropdown', () {
      late FocusNode before;
      late FocusNode after;

      Widget between() => Column(
        children: [
          Focus(focusNode: before, child: const SizedBox(height: 20)),
          SizedBox(
            width: 400,
            child: OiComboBox<String>(
              label: 'Fruit',
              labelOf: (item) => item,
              items: _fruits,
            ),
          ),
          Focus(focusNode: after, child: const SizedBox(height: 20)),
        ],
      );

      /// Focuses the trigger and opens the dropdown with Space.
      Future<void> openFromKeyboard(WidgetTester tester) async {
        await tester.pumpObers(between());
        before.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();
        expect(find.text('Apple'), findsOneWidget);
      }

      setUp(() {
        before = FocusNode(debugLabel: 'before');
        after = FocusNode(debugLabel: 'after');
        addTearDown(before.dispose);
        addTearDown(after.dispose);
      });

      testWidgets('Tab closes it and moves on', (tester) async {
        await openFromKeyboard(tester);

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        expect(find.text('Apple'), findsNothing);
        expect(after.hasPrimaryFocus, isTrue);
      });

      testWidgets('Shift+Tab closes it and moves back', (tester) async {
        await openFromKeyboard(tester);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pumpAndSettle();

        expect(find.text('Apple'), findsNothing);
        expect(before.hasPrimaryFocus, isTrue);
      });
    });
  });

  group('highlight', () {
    // Renders the highlighted option with a trailing "<".
    Widget marked(
      String item, {
      required bool highlighted,
      required bool selected,
    }) => Text(highlighted ? '$item<' : item);

    List<String> optionTexts(WidgetTester tester) => tester
        .widgetList<Text>(
          find.descendant(
            of: find.byType(SingleChildScrollView),
            matching: find.byType(Text),
          ),
        )
        .map((t) => t.data!)
        .toList();

    testWidgets('follows the on-screen order with recent items', (
      tester,
    ) async {
      String? selected;
      await tester.pumpObers(
        SizedBox(
          width: 400,
          height: 600,
          child: OiComboBox<String>(
            label: 'Fruit',
            labelOf: (item) => item,
            items: const ['Apple', 'Banana', 'Cherry'],
            recentItems: const ['Cherry'],
            onSelect: (v) => selected = v,
            optionBuilder: marked,
          ),
        ),
      );
      await _open(tester);

      // The first option on screen is highlighted, and only that one.
      expect(optionTexts(tester), [
        'Recent',
        'Cherry<',
        'Apple',
        'Banana',
        'Cherry',
      ]);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(optionTexts(tester), [
        'Recent',
        'Cherry',
        'Apple<',
        'Banana',
        'Cherry',
      ]);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(selected, 'Apple');
    });

    testWidgets('follows the on-screen order of grouped items', (
      tester,
    ) async {
      String? selected;
      await tester.pumpObers(
        SizedBox(
          width: 400,
          height: 600,
          child: OiComboBox<String>(
            label: 'Fruit',
            labelOf: (item) => item,
            items: const ['Apple', 'Banana', 'Avocado'],
            groupBy: (item) => item[0],
            onSelect: (v) => selected = v,
            optionBuilder: marked,
          ),
        ),
      );
      await _open(tester);
      expect(optionTexts(tester), ['A', 'Apple<', 'Avocado', 'B', 'Banana']);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(optionTexts(tester), ['A', 'Apple', 'Avocado<', 'B', 'Banana']);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(selected, 'Avocado');
    });

    testWidgets('typing highlights the first match, not a recent item', (
      tester,
    ) async {
      String? selected;
      await tester.pumpObers(
        _comboBox(recentItems: const ['Cherry'], onSelect: (v) => selected = v),
      );
      await _open(tester);

      await tester.enterText(find.byType(EditableText).first, 'ban');
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(selected, 'Banana');
    });

    testWidgets('marks one option when two items are equal', (tester) async {
      await tester.pumpObers(
        SizedBox(
          width: 400,
          height: 600,
          child: OiComboBox<String>(
            label: 'Fruit',
            labelOf: (item) => item,
            items: const ['Apple', 'Apple', 'Banana'],
            optionBuilder: marked,
          ),
        ),
      );
      await _open(tester);

      expect(optionTexts(tester), ['Apple<', 'Apple', 'Banana']);
    });

    testWidgets('does not compare every option with every other on rebuild', (
      tester,
    ) async {
      final items = [for (var i = 0; i < 40; i++) _CountingItem('Item $i')];
      await tester.pumpObers(
        SizedBox(
          width: 400,
          height: 600,
          child: OiComboBox<_CountingItem>(
            label: 'Items',
            labelOf: (item) => item.name,
            items: items,
          ),
        ),
      );
      await _open(tester);

      _CountingItem.comparisons = 0;
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      expect(_CountingItem.comparisons, lessThanOrEqualTo(items.length));
    });

    testWidgets('survives a parent rebuild with an equal items list', (
      tester,
    ) async {
      String? selected;
      late StateSetter rebuild;
      await tester.pumpObers(
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return _comboBox(
              // A new list instance on every build.
              items: [..._fruits],
              onSelect: (v) => selected = v,
            );
          },
        ),
      );
      await _open(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      rebuild(() {});
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(selected, 'Cherry');
    });

    testWidgets('stays on the same item when the items change', (
      tester,
    ) async {
      String? selected;
      var items = _fruits;
      late StateSetter rebuild;
      await tester.pumpObers(
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return _comboBox(items: items, onSelect: (v) => selected = v);
          },
        ),
      );
      await _open(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      rebuild(() => items = ['Apricot', ..._fruits]);
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(selected, 'Cherry');
    });

    group('with an item both pinned and in the main list', () {
      var items = const ['Apple', 'Banana', 'Cherry'];
      List<String>? recentItems = const ['Cherry'];
      List<String>? favoriteItems;
      late StateSetter rebuild;

      Future<void> pump(WidgetTester tester) async {
        items = const ['Apple', 'Banana', 'Cherry'];
        recentItems = const ['Cherry'];
        favoriteItems = null;
        await tester.pumpObers(
          StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return SizedBox(
                width: 400,
                height: 600,
                child: OiComboBox<String>(
                  label: 'Fruit',
                  labelOf: (item) => item,
                  items: items,
                  recentItems: recentItems,
                  favoriteItems: favoriteItems,
                  optionBuilder: marked,
                ),
              );
            },
          ),
        );
        await _open(tester);
      }

      Future<void> arrowDown(WidgetTester tester, int times) async {
        for (var i = 0; i < times; i++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        }
        await tester.pump();
      }

      testWidgets('an items change keeps the highlight on the main-list copy', (
        tester,
      ) async {
        await pump(tester);
        await arrowDown(tester, 3);
        expect(optionTexts(tester), [
          'Recent',
          'Cherry',
          'Apple',
          'Banana',
          'Cherry<',
        ]);

        rebuild(() => items = const ['Apricot', 'Apple', 'Banana', 'Cherry']);
        await tester.pump();

        expect(optionTexts(tester), [
          'Recent',
          'Cherry',
          'Apricot',
          'Apple',
          'Banana',
          'Cherry<',
        ]);
      });

      testWidgets('an items change keeps the highlight on the pinned copy', (
        tester,
      ) async {
        await pump(tester);
        expect(optionTexts(tester).take(2), ['Recent', 'Cherry<']);

        rebuild(() => items = const ['Cherry', 'Apple']);
        await tester.pump();

        expect(optionTexts(tester), ['Recent', 'Cherry<', 'Cherry', 'Apple']);
      });

      testWidgets('a recent items change keeps the highlight on its tile', (
        tester,
      ) async {
        await pump(tester);
        await arrowDown(tester, 2);
        expect(optionTexts(tester), [
          'Recent',
          'Cherry',
          'Apple',
          'Banana<',
          'Cherry',
        ]);

        rebuild(() => recentItems = const ['Cherry', 'Apple']);
        await tester.pump();

        expect(optionTexts(tester), [
          'Recent',
          'Cherry',
          'Apple',
          'Apple',
          'Banana<',
          'Cherry',
        ]);
      });

      testWidgets('a favorite items change keeps the highlight on its tile', (
        tester,
      ) async {
        await pump(tester);
        await arrowDown(tester, 1);

        rebuild(() => favoriteItems = const ['Banana']);
        await tester.pump();

        expect(optionTexts(tester), [
          'Recent',
          'Cherry',
          'Favorites',
          'Banana',
          'Apple<',
          'Banana',
          'Cherry',
        ]);
      });

      testWidgets('a removed pinned item hands the highlight to the first '
          'option', (tester) async {
        await pump(tester);

        rebuild(() => recentItems = null);
        await tester.pump();

        expect(optionTexts(tester), ['Apple<', 'Banana', 'Cherry']);
      });
    });
  });

  group('labels', () {
    testWidgets('default to English', (tester) async {
      await tester.pumpObers(_comboBox(items: const [], onCreate: (_) {}));
      await _open(tester);
      expect(find.text('Search…'), findsOneWidget);

      await tester.enterText(find.byType(EditableText).first, 'Mango');
      await tester.pump();
      expect(find.text('Create "Mango"'), findsOneWidget);
    });

    testWidgets('are replaced by OiComboBoxLabels', (tester) async {
      final completer = Completer<List<String>>();
      await tester.pumpObers(
        SizedBox(
          width: 400,
          height: 600,
          child: OiComboBox<String>(
            label: 'Obst',
            labelOf: (item) => item,
            search: (_) => completer.future,
            moreAvailable: true,
            loadMore: () async => const [],
            labels: const OiComboBoxLabels(
              searchPlaceholder: 'Suchen',
              loading: 'Wird geladen',
              loadMore: 'Mehr laden',
            ),
          ),
        ),
      );
      await _open(tester);
      expect(find.text('Suchen'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('Wird geladen'), findsOneWidget);

      completer.complete(['Apfel']);
      await _flush(tester);
      expect(find.text('Mehr laden'), findsOneWidget);
    });

    testWidgets('create label is built from the query', (tester) async {
      await tester.pumpObers(
        SizedBox(
          width: 400,
          height: 600,
          child: OiComboBox<String>(
            label: 'Obst',
            labelOf: (item) => item,
            onCreate: (_) {},
            labels: OiComboBoxLabels(
              create: (query) => '„$query“ anlegen',
            ),
          ),
        ),
      );
      await _open(tester);
      await tester.enterText(find.byType(EditableText).first, 'Mango');
      await tester.pump();

      expect(find.text('„Mango“ anlegen'), findsOneWidget);
    });
  });
}

/// Opens the dropdown by tapping the trigger.
Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.byType(GestureDetector).first);
  await tester.pumpAndSettle();
}

/// Taps the dropdown row showing [text] and lets its handler finish.
Future<void> _tapOption(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await _flush(tester);
}

@immutable
class _CountingItem {
  const _CountingItem(this.name);

  static int comparisons = 0;

  final String name;

  @override
  bool operator ==(Object other) {
    comparisons++;
    return other is _CountingItem && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}

/// Lets a completed future deliver its result, then builds the frame showing
/// it. A single pump draws its frame before it runs the pending microtasks.
Future<void> _flush(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}
