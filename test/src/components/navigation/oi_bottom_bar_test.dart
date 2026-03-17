// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/navigation/oi_bottom_bar.dart';

import '../../../helpers/pump_app.dart';

const _kIcon = IconData(0xe318, fontFamily: 'MaterialIcons');
const _kIcon2 = IconData(0xe8b6, fontFamily: 'MaterialIcons');
const _kIcon3 = IconData(0xe7fd, fontFamily: 'MaterialIcons');

const _kItems = [
  OiBottomBarItem(icon: _kIcon, label: 'Home'),
  OiBottomBarItem(icon: _kIcon2, label: 'Search'),
  OiBottomBarItem(icon: _kIcon3, label: 'Profile'),
];

void main() {
  // ── Rendering ──────────────────────────────────────────────────────────────

  testWidgets('renders all item labels', (tester) async {
    await tester.pumpObers(
      OiBottomBar(items: _kItems, selectedIndex: 0, onSelected: (_) {}),
    );
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('renders all item icons', (tester) async {
    await tester.pumpObers(
      OiBottomBar(items: _kItems, selectedIndex: 0, onSelected: (_) {}),
    );
    expect(find.byIcon(_kIcon), findsOneWidget);
    expect(find.byIcon(_kIcon2), findsOneWidget);
    expect(find.byIcon(_kIcon3), findsOneWidget);
  });

  // ── Selection ──────────────────────────────────────────────────────────────

  testWidgets('onSelected fires with correct index when item tapped', (
    tester,
  ) async {
    int? selected;
    await tester.pumpObers(
      OiBottomBar(
        items: _kItems,
        selectedIndex: 0,
        onSelected: (i) => selected = i,
      ),
    );
    await tester.tap(find.text('Search'));
    await tester.pump();
    expect(selected, 1);
  });

  testWidgets('tapping third item calls onSelected(2)', (tester) async {
    int? selected;
    await tester.pumpObers(
      OiBottomBar(
        items: _kItems,
        selectedIndex: 0,
        onSelected: (i) => selected = i,
      ),
    );
    await tester.tap(find.text('Profile'));
    await tester.pump();
    expect(selected, 2);
  });

  testWidgets('selected item label uses a different colour from unselected', (
    tester,
  ) async {
    await tester.pumpObers(
      OiBottomBar(items: _kItems, selectedIndex: 0, onSelected: (_) {}),
    );
    // Retrieve the Text widgets for Home (selected) and Search (not selected).
    final homeText = tester.widget<Text>(find.text('Home'));
    final searchText = tester.widget<Text>(find.text('Search'));
    final homeColor = homeText.style?.color;
    final searchColor = searchText.style?.color;
    expect(homeColor, isNotNull);
    expect(searchColor, isNotNull);
    expect(homeColor, isNot(equals(searchColor)));
  });

  // ── Badge ──────────────────────────────────────────────────────────────────

  testWidgets('badge count renders as text overlay when non-zero', (
    tester,
  ) async {
    await tester.pumpObers(
      OiBottomBar(
        items: const [
          OiBottomBarItem(icon: _kIcon, label: 'Home', badgeCount: 5),
          OiBottomBarItem(icon: _kIcon2, label: 'Search'),
        ],
        selectedIndex: 0,
        onSelected: (_) {},
      ),
    );
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('badge count 99+ truncates to "99+"', (tester) async {
    await tester.pumpObers(
      OiBottomBar(
        items: const [
          OiBottomBarItem(icon: _kIcon, label: 'Home', badgeCount: 150),
        ],
        selectedIndex: 0,
        onSelected: (_) {},
      ),
    );
    expect(find.text('99+'), findsOneWidget);
  });

  testWidgets('zero badge count renders no badge text', (tester) async {
    await tester.pumpObers(
      OiBottomBar(
        items: const [OiBottomBarItem(icon: _kIcon, label: 'Home')],
        selectedIndex: 0,
        onSelected: (_) {},
      ),
    );
    // Only "Home" text should be present, no badge digit.
    expect(find.text('0'), findsNothing);
  });

  // ── Floating style ─────────────────────────────────────────────────────────

  testWidgets('floating style renders without error', (tester) async {
    await tester.pumpObers(
      OiBottomBar(
        items: _kItems,
        selectedIndex: 0,
        onSelected: (_) {},
        style: OiBottomBarStyle.floating,
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('floating style wraps bar in a DecoratedBox with border radius', (
    tester,
  ) async {
    await tester.pumpObers(
      OiBottomBar(
        items: _kItems,
        selectedIndex: 0,
        onSelected: (_) {},
        style: OiBottomBarStyle.floating,
      ),
    );
    final decorated = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((d) => d.decoration)
        .whereType<BoxDecoration>()
        .where((d) => d.borderRadius != null)
        .toList();
    expect(decorated, isNotEmpty);
  });
}
