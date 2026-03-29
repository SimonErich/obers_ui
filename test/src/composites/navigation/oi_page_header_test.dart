// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/navigation/oi_page_header.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiPageHeader', () {
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
