// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/navigation/oi_navigation_rail.dart';
import 'package:obers_ui/src/models/oi_navigation_item.dart';

import '../../../helpers/pump_app.dart';

const _kIcon = IconData(0xe88a, fontFamily: 'MaterialIcons');
const _kIcon2 = IconData(0xe8b6, fontFamily: 'MaterialIcons');
const _kIcon3 = IconData(0xe7fd, fontFamily: 'MaterialIcons');

const _kItems = [
  OiNavigationItem(icon: _kIcon, label: 'Home'),
  OiNavigationItem(icon: _kIcon2, label: 'Search'),
  OiNavigationItem(icon: _kIcon3, label: 'Profile'),
];

void main() {
  // ── Rendering ──────────────────────────────────────────────────────────────

  group('OiNavigationRail', () {
    testWidgets('renders all item labels', (tester) async {
      await tester.pumpObers(
        OiNavigationRail(items: _kItems, currentIndex: 0, onTap: (_) {}),
        surfaceSize: const Size(400, 600),
      );
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('renders all item icons', (tester) async {
      await tester.pumpObers(
        OiNavigationRail(items: _kItems, currentIndex: 0, onTap: (_) {}),
        surfaceSize: const Size(400, 600),
      );
      expect(find.byIcon(_kIcon), findsOneWidget);
      expect(find.byIcon(_kIcon2), findsOneWidget);
      expect(find.byIcon(_kIcon3), findsOneWidget);
    });

    // ── Selection ────────────────────────────────────────────────────────────

    testWidgets('onTap fires with correct index when item tapped', (
      tester,
    ) async {
      int? tapped;
      await tester.pumpObers(
        OiNavigationRail(
          items: _kItems,
          currentIndex: 0,
          onTap: (i) => tapped = i,
        ),
        surfaceSize: const Size(400, 600),
      );
      await tester.tap(find.text('Search'));
      await tester.pump();
      expect(tapped, 1);
    });

    testWidgets('tapping third item calls onTap(2)', (tester) async {
      int? tapped;
      await tester.pumpObers(
        OiNavigationRail(
          items: _kItems,
          currentIndex: 0,
          onTap: (i) => tapped = i,
        ),
        surfaceSize: const Size(400, 600),
      );
      await tester.tap(find.text('Profile'));
      await tester.pump();
      expect(tapped, 2);
    });

    // ── Leading & trailing ───────────────────────────────────────────────────

    testWidgets('leading widget is rendered', (tester) async {
      await tester.pumpObers(
        OiNavigationRail(
          items: _kItems,
          currentIndex: 0,
          onTap: (_) {},
          leading: const Text('Logo'),
        ),
        surfaceSize: const Size(400, 600),
      );
      expect(find.text('Logo'), findsOneWidget);
    });

    testWidgets('trailing widget is rendered', (tester) async {
      await tester.pumpObers(
        OiNavigationRail(
          items: _kItems,
          currentIndex: 0,
          onTap: (_) {},
          trailing: const Text('Settings'),
        ),
        surfaceSize: const Size(400, 600),
      );
      expect(find.text('Settings'), findsOneWidget);
    });

    // ── Badge ────────────────────────────────────────────────────────────────

    testWidgets('badge is displayed when set on an item', (tester) async {
      const items = [
        OiNavigationItem(icon: _kIcon, label: 'Home', badge: '5'),
        OiNavigationItem(icon: _kIcon2, label: 'Search'),
      ];
      await tester.pumpObers(
        OiNavigationRail(items: items, currentIndex: 0, onTap: (_) {}),
        surfaceSize: const Size(400, 600),
      );
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('no badge text when badge is null', (tester) async {
      await tester.pumpObers(
        OiNavigationRail(items: _kItems, currentIndex: 0, onTap: (_) {}),
        surfaceSize: const Size(400, 600),
      );
      // No badge numbers should appear.
      expect(find.text('5'), findsNothing);
      expect(find.text('99+'), findsNothing);
    });

    // ── Label behavior ───────────────────────────────────────────────────────

    testWidgets('labelBehavior none hides all labels', (tester) async {
      await tester.pumpObers(
        OiNavigationRail(
          items: _kItems,
          currentIndex: 0,
          onTap: (_) {},
          labelBehavior: OiRailLabelBehavior.none,
        ),
        surfaceSize: const Size(400, 600),
      );
      expect(find.text('Home'), findsNothing);
      expect(find.text('Search'), findsNothing);
      expect(find.text('Profile'), findsNothing);
    });

    testWidgets('labelBehavior selected shows only selected label', (
      tester,
    ) async {
      await tester.pumpObers(
        OiNavigationRail(
          items: _kItems,
          currentIndex: 1,
          onTap: (_) {},
          labelBehavior: OiRailLabelBehavior.selected,
        ),
        surfaceSize: const Size(400, 600),
      );
      // Only 'Search' (index 1) should be visible.
      expect(find.text('Home'), findsNothing);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Profile'), findsNothing);
    });

    testWidgets('labelBehavior all shows all labels', (tester) async {
      await tester.pumpObers(
        OiNavigationRail(
          items: _kItems,
          currentIndex: 0,
          onTap: (_) {},
        ),
        surfaceSize: const Size(400, 600),
      );
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    // ── Custom width ─────────────────────────────────────────────────────────

    testWidgets('custom width is applied', (tester) async {
      await tester.pumpObers(
        OiNavigationRail(
          items: _kItems,
          currentIndex: 0,
          onTap: (_) {},
          width: 100,
        ),
        surfaceSize: const Size(400, 600),
      );
      // Find the SizedBox that constrains the rail width.
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final railBox = sizedBoxes.where((b) => b.width == 100);
      expect(railBox, isNotEmpty, reason: 'Rail should have a 100px width');
    });

    // ── Default width ────────────────────────────────────────────────────────

    testWidgets('default width is 72', (tester) async {
      await tester.pumpObers(
        OiNavigationRail(items: _kItems, currentIndex: 0, onTap: (_) {}),
        surfaceSize: const Size(400, 600),
      );
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final railBox = sizedBoxes.where((b) => b.width == 72);
      expect(railBox, isNotEmpty, reason: 'Rail should default to 72px width');
    });

    // ── Semantics ────────────────────────────────────────────────────────────

    testWidgets('default semantic label is Navigation', (tester) async {
      await tester.pumpObers(
        OiNavigationRail(items: _kItems, currentIndex: 0, onTap: (_) {}),
        surfaceSize: const Size(400, 600),
      );
      expect(find.bySemanticsLabel('Navigation'), findsOneWidget);
    });

    testWidgets('custom semantic label is applied', (tester) async {
      await tester.pumpObers(
        OiNavigationRail(
          items: _kItems,
          currentIndex: 0,
          onTap: (_) {},
          semanticLabel: 'Main menu',
        ),
        surfaceSize: const Size(400, 600),
      );
      expect(find.bySemanticsLabel('Main menu'), findsOneWidget);
    });
  });
}
