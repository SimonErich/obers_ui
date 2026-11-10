// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/navigation/oi_page_header.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiPageHeader', () {
    testWidgets('actions align with the subtitle and stack on narrow screens', (
      tester,
    ) async {
      Future<void> show(double width) => tester.pumpObers(
        const Center(
          child: OiPageHeader(
            title: 'Orders',
            subtitle: '412 orders for today',
            actionAlignment: CrossAxisAlignment.end,
            padding: EdgeInsets.zero,
            actions: [SizedBox(key: Key('action'), width: 100, height: 32)],
          ),
        ),
        surfaceSize: Size(width, 400),
      );
      await show(900);
      final action = find.byKey(const Key('action'));
      final subtitle = find.text('412 orders for today');
      expect(
        tester.getBottomRight(action).dy,
        tester.getBottomRight(subtitle).dy,
      );
      await show(390);
      expect(
        tester.getTopLeft(action).dy,
        greaterThan(tester.getBottomRight(subtitle).dy),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders title', (tester) async {
      await tester.pumpObers(
        const OiPageHeader(title: 'Dashboard'),
        surfaceSize: const Size(600, 200),
      );

      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('renders actions', (tester) async {
      await tester.pumpObers(
        OiPageHeader(
          title: 'Users',
          actions: [
            Container(key: const ValueKey('action1')),
            Container(key: const ValueKey('action2')),
          ],
        ),
        surfaceSize: const Size(600, 200),
      );

      expect(find.byKey(const ValueKey('action1')), findsOneWidget);
      expect(find.byKey(const ValueKey('action2')), findsOneWidget);
    });

    testWidgets('renders bottom slot', (tester) async {
      await tester.pumpObers(
        OiPageHeader(
          title: 'Settings',
          bottom: Container(key: const ValueKey('tabs'), height: 40),
        ),
        surfaceSize: const Size(600, 200),
      );

      expect(find.byKey(const ValueKey('tabs')), findsOneWidget);
    });

    testWidgets('renders status badge', (tester) async {
      await tester.pumpObers(
        OiPageHeader(
          title: 'Deploy',
          statusBadge: Container(key: const ValueKey('badge')),
        ),
        surfaceSize: const Size(600, 200),
      );

      expect(find.byKey(const ValueKey('badge')), findsOneWidget);
    });

    testWidgets('degrades cleanly to title only', (tester) async {
      await tester.pumpObers(
        const OiPageHeader(title: 'Minimal'),
        surfaceSize: const Size(600, 200),
      );

      expect(find.text('Minimal'), findsOneWidget);
    });
  });
}
