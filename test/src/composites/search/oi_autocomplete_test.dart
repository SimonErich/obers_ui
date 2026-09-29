// Tests do not require documentation comments.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/search/oi_autocomplete.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

const _fruits = ['Apple', 'Apricot', 'Banana'];

Future<List<String>> _searchFruits(String query) async => [
  for (final fruit in _fruits)
    if (fruit.toLowerCase().contains(query.toLowerCase())) fruit,
];

Future<List<String>> _pump(
  WidgetTester tester, {
  Future<List<String>> Function(String query) search = _searchFruits,
  String? emptyLabel = 'Nothing found',
}) async {
  final selected = <String>[];
  await tester.pumpObers(
    Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: 400,
        child: OiAutocomplete<String>(
          label: 'Fruit',
          placeholder: 'Search fruit',
          emptyLabel: emptyLabel,
          search: search,
          labelOf: (fruit) => fruit,
          onSelect: selected.add,
        ),
      ),
    ),
    surfaceSize: const Size(800, 600),
  );
  return selected;
}

Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(EditableText), text);
  await tester.pumpAndSettle();
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  testWidgets('shows no list until something is typed', (tester) async {
    await _pump(tester);
    await tester.tap(find.byType(EditableText));
    await tester.pumpAndSettle();

    expect(find.text('Apple'), findsNothing);

    await _type(tester, 'ap');

    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Apricot'), findsOneWidget);
    expect(find.text('Banana'), findsNothing);
  });

  testWidgets('closes again when the query is cleared', (tester) async {
    await _pump(tester);
    await _type(tester, 'ap');
    await _type(tester, '');

    expect(find.text('Apple'), findsNothing);
  });

  testWidgets('shows the empty label when nothing matches', (tester) async {
    await _pump(tester);
    await _type(tester, 'kiwi');

    expect(find.text('Nothing found'), findsOneWidget);
  });

  testWidgets('stays closed on no match when there is no empty label', (
    tester,
  ) async {
    await _pump(tester, emptyLabel: null);
    await _type(tester, 'kiwi');

    expect(find.byType(ListView), findsNothing);
  });

  testWidgets('tapping a suggestion selects it and resets the field', (
    tester,
  ) async {
    final selected = await _pump(tester);
    await _type(tester, 'ap');
    await tester.tap(find.text('Apricot'));
    await tester.pumpAndSettle();

    expect(selected, ['Apricot']);
    expect(find.text('Apple'), findsNothing);
    expect(find.text('ap'), findsNothing, reason: 'the query is cleared');
  });

  testWidgets('arrow keys move the highlight and Enter selects it', (
    tester,
  ) async {
    final selected = await _pump(tester);
    await _type(tester, 'ap');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(selected, ['Apricot']);
  });

  testWidgets('arrow up wraps to the last suggestion', (tester) async {
    final selected = await _pump(tester);
    await _type(tester, 'ap');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(selected, ['Apricot']);
  });

  testWidgets('Escape closes the list without selecting', (tester) async {
    final selected = await _pump(tester);
    await _type(tester, 'ap');

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.text('Apple'), findsNothing);
    expect(selected, isEmpty);
  });

  testWidgets('a tap outside closes the list', (tester) async {
    await _pump(tester);
    await _type(tester, 'ap');

    await tester.tapAt(const Offset(10, 590));
    await tester.pumpAndSettle();

    expect(find.text('Apple'), findsNothing);
  });

  testWidgets('a slow earlier search cannot overwrite a newer one', (
    tester,
  ) async {
    final slow = Completer<List<String>>();
    await _pump(
      tester,
      search: (query) => query == 'a' ? slow.future : Future.value(['Banana']),
    );

    await tester.enterText(find.byType(EditableText), 'a');
    await _type(tester, 'ba');
    slow.complete(['Apple']);
    await tester.pumpAndSettle();

    expect(find.text('Banana'), findsOneWidget);
    expect(find.text('Apple'), findsNothing);
  });
}
