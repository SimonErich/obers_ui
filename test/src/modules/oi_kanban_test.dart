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
        const OiKanban<String>(
          columns: [
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
        const OiKanban<String>(
          columns: [
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
        const OiKanban<String>(
          columns: [
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
        const OiKanban<String>(
          columns: [
            OiKanbanColumn(key: 'c', title: 'Col', items: ['Visible']),
          ],
          label: 'Board',
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
        const OiKanban<String>(
          columns: [
            OiKanbanColumn(
              key: 'wip',
              title: 'WIP Col',
              items: ['a', 'b', 'c'],
            ),
          ],
          label: 'Board',
          wipLimits: {'wip': 2},
        ),
        surfaceSize: const Size(800, 600),
      );

      // Should show "3/2" indicating over-limit.
      expect(find.text('3/2'), findsOneWidget);
    });

    testWidgets('semantics label is applied', (tester) async {
      await tester.pumpObers(
        const OiKanban<String>(
          columns: [OiKanbanColumn(key: 'a', title: 'A', items: [])],
          label: 'My Board',
        ),
        surfaceSize: const Size(800, 600),
      );

      expect(find.bySemanticsLabel('My Board'), findsOneWidget);
    });

    testWidgets(
        'compact forward navigation uses jumpToPage when reducedMotion',
        (tester) async {
      await tester.pumpObers(
        const MediaQuery(
          data: MediaQueryData(
            disableAnimations: true,
            size: Size(400, 600),
          ),
          child: OiKanban<String>(
            columns: [
              OiKanbanColumn(key: 'a', title: 'Col A', items: ['A1']),
              OiKanbanColumn(key: 'b', title: 'Col B', items: ['B1']),
            ],
            label: 'Board',
          ),
        ),
        surfaceSize: const Size(400, 600),
      );
      await tester.pumpAndSettle();

      expect(find.text('1 / 2'), findsOneWidget);

      // Tap the forward arrow to navigate to the next column.
      final forwardArrow = find.byIcon(
        const IconData(0xe5cc, fontFamily: 'MaterialIcons'),
      );
      await tester.tap(forwardArrow);
      // A single pump is sufficient — jumpToPage completes synchronously.
      await tester.pump();

      expect(find.text('2 / 2'), findsOneWidget);
    });

    testWidgets(
        'compact backward navigation uses jumpToPage when reducedMotion',
        (tester) async {
      await tester.pumpObers(
        const MediaQuery(
          data: MediaQueryData(
            disableAnimations: true,
            size: Size(400, 600),
          ),
          child: OiKanban<String>(
            columns: [
              OiKanbanColumn(key: 'a', title: 'Col A', items: ['A1']),
              OiKanbanColumn(key: 'b', title: 'Col B', items: ['B1']),
            ],
            label: 'Board',
          ),
        ),
        surfaceSize: const Size(400, 600),
      );
      await tester.pumpAndSettle();

      // Navigate forward first.
      final forwardArrow = find.byIcon(
        const IconData(0xe5cc, fontFamily: 'MaterialIcons'),
      );
      await tester.tap(forwardArrow);
      await tester.pump();
      expect(find.text('2 / 2'), findsOneWidget);

      // Tap the backward arrow to navigate back.
      final backwardArrow = find.byIcon(
        const IconData(0xe5cb, fontFamily: 'MaterialIcons'),
      );
      await tester.tap(backwardArrow);
      // A single pump is sufficient — jumpToPage completes synchronously.
      await tester.pump();

      expect(find.text('1 / 2'), findsOneWidget);
    });
  });
}
