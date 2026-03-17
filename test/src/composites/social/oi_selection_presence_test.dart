// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/social/oi_selection_presence.dart';

import '../../../helpers/pump_app.dart';

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  testWidgets('renders child widget', (tester) async {
    await tester.pumpObers(
      const OiSelectionPresence(
        selections: [],
        child: Text('Hello'),
      ),
    );

    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('handles empty selection list without errors', (tester) async {
    await tester.pumpObers(
      const OiSelectionPresence(
        selections: [],
        child: SizedBox(width: 100, height: 100),
      ),
    );

    expect(find.byType(OiSelectionPresence), findsOneWidget);
  });

  testWidgets('selections data is accessible via selectionsOf helper',
      (tester) async {
    const key1 = 'item-1';
    const key2 = 'item-2';

    const selections = [
      OiRemoteSelection(
        userId: 'u1',
        name: 'Alice',
        color: Color(0xFFFF0000),
        selectedKeys: {key1, key2},
      ),
      OiRemoteSelection(
        userId: 'u2',
        name: 'Bob',
        color: Color(0xFF00FF00),
        selectedKeys: {key2},
      ),
    ];

    // selectionsOf returns selections whose selectedKeys contain the key.
    final forKey1 = OiSelectionPresence.selectionsOf(selections, key1);
    expect(forKey1.length, 1);
    expect(forKey1.first.name, 'Alice');

    final forKey2 = OiSelectionPresence.selectionsOf(selections, key2);
    expect(forKey2.length, 2);

    final forUnknown = OiSelectionPresence.selectionsOf(selections, 'nope');
    expect(forUnknown, isEmpty);
  });

  testWidgets('renders with multiple selections', (tester) async {
    const selections = [
      OiRemoteSelection(
        userId: 'u1',
        name: 'Alice',
        color: Color(0xFFFF0000),
        textRange: TextRange(start: 0, end: 10),
      ),
      OiRemoteSelection(
        userId: 'u2',
        name: 'Bob',
        color: Color(0xFF00FF00),
        textRange: TextRange(start: 5, end: 15),
      ),
    ];

    await tester.pumpObers(
      const OiSelectionPresence(
        selections: selections,
        child: Text('Shared document'),
      ),
    );

    expect(find.text('Shared document'), findsOneWidget);
    expect(find.byType(OiSelectionPresence), findsOneWidget);
  });

  testWidgets('selection with null selectedKeys is not matched by selectionsOf',
      (tester) async {
    const selections = [
      OiRemoteSelection(
        userId: 'u1',
        name: 'Alice',
        color: Color(0xFFFF0000),
      ),
    ];

    final result = OiSelectionPresence.selectionsOf(selections, 'any-key');
    expect(result, isEmpty);
  });
}
