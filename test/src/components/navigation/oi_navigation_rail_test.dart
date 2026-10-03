// Tests do not require documentation comments.

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/navigation/oi_navigation_rail.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_navigation_rail_theme_data.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';
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

    testWidgets('hover preserves contrast on a custom dark rail', (
      tester,
    ) async {
      const unselected = Color(0xffc2c1ce);
      const selected = Color(0xff22212a);
      final base = OiThemeData.light();
      await tester.pumpObers(
        OiNavigationRail(
          items: _kItems,
          currentIndex: 1,
          onTap: (_) {},
          labelBehavior: OiRailLabelBehavior.none,
        ),
        theme: base.copyWith(
          components: base.components.copyWith(
            navigationRail: const OiNavigationRailThemeData(
              backgroundColor: Color(0xff1e1e28),
              indicatorColor: Color(0xffc4c1ef),
              selectedIconColor: selected,
              unselectedIconColor: unselected,
            ),
          ),
        ),
        surfaceSize: const Size(400, 600),
      );
      Color? color(IconData icon) =>
          tester.widget<Icon>(find.byIcon(icon)).color;
      expect(color(_kIcon), unselected);
      expect(color(_kIcon2), selected);
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(390, 590));
      await mouse.moveTo(tester.getCenter(find.byIcon(_kIcon)));
      await tester.pumpAndSettle();
      expect(color(_kIcon), unselected);
      expect(color(_kIcon2), selected);
      await mouse.moveTo(const Offset(390, 590));
      await tester.pumpAndSettle();
      expect(color(_kIcon), unselected);
      await mouse.removePointer();
    });

    for (final expanded in <bool?>[null, true]) {
      testWidgets(
        'hover styling remains independent of selection ($expanded)',
        (
          tester,
        ) async {
          const selectedForeground = Color(0xff16161e);
          const hoverForeground = Color(0xffeeeeff);
          const hoverBackground = Color(0xff333340);
          const selectedBackground = Color(0xffbfbde9);
          final base = OiThemeData.light();
          await tester.pumpObers(
            OiNavigationRail(
              items: _kItems,
              currentIndex: 1,
              onTap: (_) {},
              expanded: expanded,
              width: 160,
            ),
            theme: base.copyWith(
              components: base.components.copyWith(
                navigationRail: const OiNavigationRailThemeData(
                  backgroundColor: Color(0xff1e1e28),
                  indicatorColor: selectedBackground,
                  selectedIconColor: selectedForeground,
                  unselectedIconColor: Color(0xffaaaaaa),
                  hoverIconColor: hoverForeground,
                  hoverColor: hoverBackground,
                  selectedLabelStyle: TextStyle(color: selectedForeground),
                  unselectedLabelStyle: TextStyle(color: Color(0xffaaaaaa)),
                  hoverLabelStyle: TextStyle(color: hoverForeground),
                ),
              ),
            ),
            surfaceSize: const Size(400, 600),
          );
          Color? iconColor(IconData icon) =>
              tester.widget<Icon>(find.byIcon(icon)).color;
          Color? backgroundFor(IconData icon) => tester
              .widgetList<DecoratedBox>(
                find.ancestor(
                  of: find.byIcon(icon),
                  matching: find.byType(DecoratedBox),
                ),
              )
              .map((box) => box.decoration)
              .whereType<ShapeDecoration>()
              .firstOrNull
              ?.color;
          final mouse = await tester.createGesture(
            kind: PointerDeviceKind.mouse,
          );
          await mouse.addPointer(location: const Offset(390, 590));
          await mouse.moveTo(tester.getCenter(find.byIcon(_kIcon)));
          await tester.pumpAndSettle();
          expect(iconColor(_kIcon), hoverForeground);
          expect(
            tester.widget<Text>(find.text('Home')).style?.color,
            hoverForeground,
          );
          expect(backgroundFor(_kIcon), hoverBackground);
          expect(backgroundFor(_kIcon2), selectedBackground);
          await mouse.moveTo(tester.getCenter(find.byIcon(_kIcon2)));
          await tester.pumpAndSettle();
          expect(iconColor(_kIcon2), selectedForeground);
          expect(backgroundFor(_kIcon2), selectedBackground);
          expect(
            tester.widget<Text>(find.text('Search')).style?.color,
            selectedForeground,
          );
          expect(backgroundFor(_kIcon), isNull);
          await mouse.removePointer();
        },
      );
    }

    testWidgets('keyboard entry paints and exit removes the rail focus ring', (
      tester,
    ) async {
      await tester.pumpObers(
        Column(
          children: [
            Expanded(
              child: OiNavigationRail(
                items: _kItems,
                currentIndex: 1,
                onTap: (_) {},
              ),
            ),
            const Focus(child: SizedBox(width: 20, height: 20)),
          ],
        ),
        surfaceSize: const Size(400, 600),
      );
      final ring = find.descendant(
        of: find.byType(OiNavigationRail),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is DecoratedBox &&
              widget.position == DecorationPosition.foreground,
        ),
      );
      expect(ring, findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      final railFocus = tester
          .widget<Focus>(
            find
                .descendant(
                  of: find.byType(OiNavigationRail),
                  matching: find.byType(Focus),
                )
                .first,
          )
          .focusNode!;
      expect(railFocus.hasFocus, isTrue);
      expect(ring, findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(railFocus.hasFocus, isFalse);
      expect(ring, findsNothing);
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
