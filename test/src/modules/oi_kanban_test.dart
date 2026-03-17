// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/modules/oi_kanban.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('OiKanban', () {
    testWidgets('columns render', (tester) async {
      await tester.pumpObers(
        OiKanban<String>(
          columns: const [
            OiKanbanColumn(key: 'todo', title: 'To Do', items: []),
            OiKanbanColumn(key: 'done', title: 'Done', items: []),
          ],
          label: 'Board',
        ),
        surfaceSize: const Size(800, 600),
      );

      expect(find.text('To Do'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('cards in columns render', (tester) async {
      await tester.pumpObers(
        OiKanban<String>(
          columns: const [
            OiKanbanColumn(
              key: 'col1',
              title: 'Column',
              items: ['Card A', 'Card B'],
            ),
          ],
          label: 'Board',
        ),
        surfaceSize: const Size(800, 600),
      );

      expect(find.text('Card A'), findsOneWidget);
      expect(find.text('Card B'), findsOneWidget);
    });

    testWidgets('column titles show', (tester) async {
      await tester.pumpObers(
        OiKanban<String>(
          columns: const [
            OiKanbanColumn(key: 'a', title: 'Alpha Column', items: []),
          ],
          label: 'Board',
        ),
        surfaceSize: const Size(800, 600),
      );

      expect(find.text('Alpha Column'), findsOneWidget);
    });

    testWidgets('custom cardBuilder renders', (tester) async {
      await tester.pumpObers(
        OiKanban<String>(
          columns: const [
            OiKanbanColumn(key: 'col', title: 'Col', items: ['item']),
          ],
          label: 'Board',
          cardBuilder: (item) => Text('Custom: $item'),
        ),
        surfaceSize: const Size(800, 600),
      );

      expect(find.text('Custom: item'), findsOneWidget);
    });

    testWidgets('collapsible columns toggle', (tester) async {
      await tester.pumpObers(
        OiKanban<String>(
          columns: const [
            OiKanbanColumn(key: 'c', title: 'Col', items: ['Visible']),
          ],
          label: 'Board',
          collapsibleColumns: true,
        ),
        surfaceSize: const Size(800, 600),
      );

      // Card is visible initially.
      expect(find.text('Visible'), findsOneWidget);

      // Tap the column header to collapse.
      await tester.tap(find.text('Col'));
      await tester.pump();

      // Card should be hidden.
      expect(find.text('Visible'), findsNothing);

      // Tap again to expand.
      await tester.tap(find.text('Col'));
      await tester.pump();

      expect(find.text('Visible'), findsOneWidget);
    });

    testWidgets('add column button renders and fires callback', (tester) async {
      var addCalled = false;
      await tester.pumpObers(
        OiKanban<String>(
          columns: const [OiKanbanColumn(key: 'a', title: 'A', items: [])],
          label: 'Board',
          addColumn: true,
          onAddColumn: () => addCalled = true,
        ),
        surfaceSize: const Size(800, 600),
      );

      expect(find.text('Add column'), findsOneWidget);

      await tester.tap(find.text('Add column'));
      await tester.pump();
      expect(addCalled, isTrue);
    });

    testWidgets('WIP limit warning shows count', (tester) async {
      await tester.pumpObers(
        OiKanban<String>(
          columns: const [
            OiKanbanColumn(
              key: 'wip',
              title: 'WIP Col',
              items: ['a', 'b', 'c'],
            ),
          ],
          label: 'Board',
          wipLimits: const {'wip': 2},
        ),
        surfaceSize: const Size(800, 600),
      );

      // Should show "3/2" indicating over-limit.
      expect(find.text('3/2'), findsOneWidget);
    });

    testWidgets('semantics label is applied', (tester) async {
      await tester.pumpObers(
        OiKanban<String>(
          columns: const [OiKanbanColumn(key: 'a', title: 'A', items: [])],
          label: 'My Board',
        ),
        surfaceSize: const Size(800, 600),
      );

      expect(find.bySemanticsLabel('My Board'), findsOneWidget);
    });
  });
}
