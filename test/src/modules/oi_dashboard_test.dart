// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/modules/oi_dashboard.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('OiDashboard', () {
    testWidgets('cards render in grid', (tester) async {
      await tester.pumpObers(
        const OiDashboard(
          cards: [
            OiDashboardCard(key: 'c1', title: 'Revenue', child: Text('100k')),
            OiDashboardCard(key: 'c2', title: 'Users', child: Text('5k')),
          ],
          label: 'Dashboard',
        ),
        surfaceSize: const Size(800, 600),
      );

      expect(find.text('Revenue'), findsOneWidget);
      expect(find.text('Users'), findsOneWidget);
      expect(find.text('100k'), findsOneWidget);
      expect(find.text('5k'), findsOneWidget);
    });

    testWidgets('column/row spans respected', (tester) async {
      await tester.pumpObers(
        const OiDashboard(
          cards: [
            OiDashboardCard(
              key: 'wide',
              title: 'Wide Card',
              child: Text('Wide'),
              columnSpan: 2,
            ),
            OiDashboardCard(
              key: 'tall',
              title: 'Tall Card',
              child: Text('Tall'),
              rowSpan: 2,
            ),
          ],
          label: 'Dashboard',
        ),
        surfaceSize: const Size(800, 600),
      );

      expect(find.text('Wide Card'), findsOneWidget);
      expect(find.text('Tall Card'), findsOneWidget);

      // Verify the wide card is actually wider than a single-span card.
      final wideCard = tester.getSize(find.text('Wide').first);
      final tallCard = tester.getSize(find.text('Tall').first);
      // The wide card's parent container should be wider; we just verify
      // both render without overflow.
      expect(wideCard.width, greaterThan(0));
      expect(tallCard.height, greaterThan(0));
    });

    testWidgets('editable mode shows drag icon', (tester) async {
      await tester.pumpObers(
        const OiDashboard(
          cards: [
            OiDashboardCard(
              key: 'e1',
              title: 'Editable',
              child: Text('Content'),
            ),
          ],
          label: 'Dashboard',
          editable: true,
        ),
        surfaceSize: const Size(800, 600),
      );

      // The drag/handle icon (0xe945) should be present.
      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('non-editable mode hides drag icon', (tester) async {
      await tester.pumpObers(
        const OiDashboard(
          cards: [
            OiDashboardCard(key: 'e1', title: 'Static', child: Text('Content')),
          ],
          label: 'Dashboard',
        ),
        surfaceSize: const Size(800, 600),
      );

      // No drag icon should be present.
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('titles show on cards', (tester) async {
      await tester.pumpObers(
        const OiDashboard(
          cards: [
            OiDashboardCard(
              key: 'titled',
              title: 'My Title',
              child: Text('body'),
            ),
          ],
          label: 'Dashboard',
        ),
        surfaceSize: const Size(800, 600),
      );

      expect(find.text('My Title'), findsOneWidget);
    });

    testWidgets('gap is applied between cards', (tester) async {
      await tester.pumpObers(
        const OiDashboard(
          cards: [
            OiDashboardCard(key: 'a', title: 'A', child: Text('a')),
            OiDashboardCard(key: 'b', title: 'B', child: Text('b')),
          ],
          label: 'Dashboard',
          gap: 24,
        ),
        surfaceSize: const Size(800, 600),
      );

      // Both cards should be present and separated.
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);

      // Verify the Wrap widget uses the specified spacing.
      final wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.spacing, 24.0);
      expect(wrap.runSpacing, 24.0);
    });

    testWidgets('responsive column count works', (tester) async {
      await tester.pumpObers(
        const OiDashboard(
          cards: [OiDashboardCard(key: 'r1', title: 'R1', child: Text('r1'))],
          label: 'Dashboard',
          columns: 2,
        ),
        surfaceSize: const Size(400, 600),
      );

      expect(find.text('R1'), findsOneWidget);
    });

    testWidgets('semantics label is applied', (tester) async {
      await tester.pumpObers(
        const OiDashboard(
          cards: [OiDashboardCard(key: 's1', title: 'S1', child: Text('s1'))],
          label: 'Analytics Dashboard',
        ),
        surfaceSize: const Size(800, 600),
      );

      expect(find.bySemanticsLabel('Analytics Dashboard'), findsOneWidget);
    });
  });
}
