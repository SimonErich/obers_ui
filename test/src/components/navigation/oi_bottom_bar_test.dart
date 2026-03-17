// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/navigation/oi_bottom_bar.dart';

import '../../../helpers/pump_app.dart';

const _kIcon = IconData(0xe318, fontFamily: 'MaterialIcons');
const _kIcon2 = IconData(0xe8b6, fontFamily: 'MaterialIcons');
const _kIcon3 = IconData(0xe7fd, fontFamily: 'MaterialIcons');
const _kActiveIcon = IconData(0xe88a, fontFamily: 'MaterialIcons');

const _kItems = [
  OiBottomBarItem(icon: _kIcon, label: 'Home'),
  OiBottomBarItem(icon: _kIcon2, label: 'Search'),
  OiBottomBarItem(icon: _kIcon3, label: 'Profile'),
];

// Wrap child in a compact MediaQuery so the bar passes breakpoint checks.
// Using a nested MediaQuery is more reliable than setSurfaceSize when
// OiApp's WidgetsApp creates its own MediaQuery from the platform view.
const _kCompact = MediaQueryData(size: Size(375, 812));
const _kExpanded = MediaQueryData(size: Size(1024, 768));
const _kMedium = MediaQueryData(size: Size(700, 900));

Widget _wrapMQ(Widget child, MediaQueryData data) =>
    MediaQuery(data: data, child: child);

void main() {
  // ── Rendering ──────────────────────────────────────────────────────────────

  testWidgets('renders all item labels', (tester) async {
    await tester.pumpObers(
      _wrapMQ(
        OiBottomBar(items: _kItems, currentIndex: 0, onTap: (_) {}),
        _kCompact,
      ),
    );
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('renders all item icons', (tester) async {
    await tester.pumpObers(
      _wrapMQ(
        OiBottomBar(items: _kItems, currentIndex: 0, onTap: (_) {}),
        _kCompact,
      ),
    );
    expect(find.byIcon(_kIcon), findsOneWidget);
    expect(find.byIcon(_kIcon2), findsOneWidget);
    expect(find.byIcon(_kIcon3), findsOneWidget);
  });

  // ── Selection ──────────────────────────────────────────────────────────────

  testWidgets('onTap fires with correct index when item tapped', (
    tester,
  ) async {
    int? tapped;
    await tester.pumpObers(
      _wrapMQ(
        OiBottomBar(
          items: _kItems,
          currentIndex: 0,
          onTap: (i) => tapped = i,
        ),
        _kCompact,
      ),
    );
    await tester.tap(find.text('Search'));
    await tester.pump();
    expect(tapped, 1);
  });

  testWidgets('tapping third item calls onTap(2)', (tester) async {
    int? tapped;
    await tester.pumpObers(
      _wrapMQ(
        OiBottomBar(
          items: _kItems,
          currentIndex: 0,
          onTap: (i) => tapped = i,
        ),
        _kCompact,
      ),
    );
    await tester.tap(find.text('Profile'));
    await tester.pump();
    expect(tapped, 2);
  });

  testWidgets('selected item label uses a different colour from unselected', (
    tester,
  ) async {
    await tester.pumpObers(
      _wrapMQ(
        OiBottomBar(items: _kItems, currentIndex: 0, onTap: (_) {}),
        _kCompact,
      ),
    );
    final homeText = tester.widget<Text>(find.text('Home'));
    final searchText = tester.widget<Text>(find.text('Search'));
    expect(homeText.style?.color, isNotNull);
    expect(searchText.style?.color, isNotNull);
    expect(homeText.style?.color, isNot(equals(searchText.style?.color)));
  });

  // ── Active icon ────────────────────────────────────────────────────────────

  testWidgets('uses activeIcon for selected item when provided', (tester) async {
    await tester.pumpObers(
      _wrapMQ(
        OiBottomBar(
          items: const [
            OiBottomBarItem(icon: _kIcon, label: 'Home', activeIcon: _kActiveIcon),
            OiBottomBarItem(icon: _kIcon2, label: 'Search'),
          ],
          currentIndex: 0,
          onTap: (_) {},
        ),
        _kCompact,
      ),
    );
    expect(find.byIcon(_kActiveIcon), findsOneWidget);
    // Regular icon not shown for selected item.
    expect(find.byIcon(_kIcon), findsNothing);
  });

  // ── Badge ──────────────────────────────────────────────────────────────────

  testWidgets('badge count renders as text overlay when non-zero', (
    tester,
  ) async {
    await tester.pumpObers(
      _wrapMQ(
        OiBottomBar(
          items: const [
            OiBottomBarItem(icon: _kIcon, label: 'Home', badgeCount: 5),
            OiBottomBarItem(icon: _kIcon2, label: 'Search'),
          ],
          currentIndex: 0,
          onTap: (_) {},
        ),
        _kCompact,
      ),
    );
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('badge count 99+ truncates to "99+"', (tester) async {
    await tester.pumpObers(
      _wrapMQ(
        OiBottomBar(
          items: const [
            OiBottomBarItem(icon: _kIcon, label: 'Home', badgeCount: 150),
          ],
          currentIndex: 0,
          onTap: (_) {},
        ),
        _kCompact,
      ),
    );
    expect(find.text('99+'), findsOneWidget);
  });

  testWidgets('null badge count renders no badge text', (tester) async {
    await tester.pumpObers(
      _wrapMQ(
        OiBottomBar(
          items: const [OiBottomBarItem(icon: _kIcon, label: 'Home')],
          currentIndex: 0,
          onTap: (_) {},
        ),
        _kCompact,
      ),
    );
    expect(find.text('0'), findsNothing);
  });

  testWidgets('showBadge=false hides badge even when badgeCount > 0',
      (tester) async {
    await tester.pumpObers(
      _wrapMQ(
        OiBottomBar(
          items: const [
            OiBottomBarItem(
              icon: _kIcon,
              label: 'Home',
              badgeCount: 5,
              showBadge: false,
            ),
          ],
          currentIndex: 0,
          onTap: (_) {},
        ),
        _kCompact,
      ),
    );
    expect(find.text('5'), findsNothing);
  });

  // ── Styles ─────────────────────────────────────────────────────────────────

  testWidgets('fixed style renders labels for all items', (tester) async {
    await tester.pumpObers(
      _wrapMQ(
        OiBottomBar(
          items: _kItems,
          currentIndex: 0,
          onTap: (_) {},
          style: OiBottomBarStyle.fixed,
        ),
        _kCompact,
      ),
    );
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('shifting style shows label only for selected item',
      (tester) async {
    await tester.pumpObers(
      _wrapMQ(
        OiBottomBar(
          items: _kItems,
          currentIndex: 0,
          onTap: (_) {},
          style: OiBottomBarStyle.shifting,
        ),
        _kCompact,
      ),
    );
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsNothing);
    expect(find.text('Profile'), findsNothing);
  });

  testWidgets('iconOnly style hides all labels visually', (tester) async {
    await tester.pumpObers(
      _wrapMQ(
        OiBottomBar(
          items: _kItems,
          currentIndex: 0,
          onTap: (_) {},
          style: OiBottomBarStyle.iconOnly,
        ),
        _kCompact,
      ),
    );
    expect(find.text('Home'), findsNothing);
    expect(find.text('Search'), findsNothing);
    expect(find.text('Profile'), findsNothing);
  });

  testWidgets('labeled style renders labels for all items', (tester) async {
    await tester.pumpObers(
      _wrapMQ(
        OiBottomBar(
          items: _kItems,
          currentIndex: 0,
          onTap: (_) {},
          style: OiBottomBarStyle.labeled,
        ),
        _kCompact,
      ),
    );
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  // ── showLabels override ────────────────────────────────────────────────────

  testWidgets('showLabels=false hides labels regardless of fixed style',
      (tester) async {
    await tester.pumpObers(
      _wrapMQ(
        OiBottomBar(
          items: _kItems,
          currentIndex: 0,
          onTap: (_) {},
          showLabels: false,
        ),
        _kCompact,
      ),
    );
    expect(find.text('Home'), findsNothing);
    expect(find.text('Search'), findsNothing);
    expect(find.text('Profile'), findsNothing);
  });

  // ── floatingAction ─────────────────────────────────────────────────────────

  testWidgets('floatingAction is rendered when provided', (tester) async {
    await tester.pumpObers(
      _wrapMQ(
        OiBottomBar(
          items: const [
            OiBottomBarItem(icon: _kIcon, label: 'Home'),
            OiBottomBarItem(icon: _kIcon2, label: 'Search'),
          ],
          currentIndex: 0,
          onTap: (_) {},
          floatingAction: const Text('FAB'),
        ),
        _kCompact,
      ),
    );
    expect(find.text('FAB'), findsOneWidget);
  });

  // ── Responsive visibility ──────────────────────────────────────────────────

  testWidgets('hidden on expanded breakpoints (>=840dp width)', (tester) async {
    await tester.pumpObers(
      _wrapMQ(
        OiBottomBar(items: _kItems, currentIndex: 0, onTap: (_) {}),
        _kExpanded,
      ),
    );
    expect(find.text('Home'), findsNothing);
    expect(find.text('Search'), findsNothing);
  });

  testWidgets('hidden on medium when showOnMedium=false (default)',
      (tester) async {
    await tester.pumpObers(
      _wrapMQ(
        OiBottomBar(items: _kItems, currentIndex: 0, onTap: (_) {}),
        _kMedium,
      ),
    );
    expect(find.text('Home'), findsNothing);
  });

  testWidgets('visible on medium when showOnMedium=true', (tester) async {
    await tester.pumpObers(
      _wrapMQ(
        OiBottomBar(
          items: _kItems,
          currentIndex: 0,
          onTap: (_) {},
          showOnMedium: true,
        ),
        _kMedium,
      ),
    );
    expect(find.text('Home'), findsOneWidget);
  });

  // ── Keyboard visibility ────────────────────────────────────────────────────

  testWidgets('bar hides when virtual keyboard is visible', (tester) async {
    await tester.pumpObers(
      _wrapMQ(
        OiBottomBar(items: _kItems, currentIndex: 0, onTap: (_) {}),
        const MediaQueryData(
          size: Size(375, 812),
          viewInsets: EdgeInsets.only(bottom: 300),
        ),
      ),
    );
    expect(find.text('Home'), findsNothing);
  });

  // ── Landscape mode ─────────────────────────────────────────────────────────

  testWidgets('landscape+compact+hidden: bar returns empty', (tester) async {
    // Landscape compact: width=500 (compact), width>height → landscape.
    await tester.pumpObers(
      _wrapMQ(
        OiBottomBar(
          items: _kItems,
          currentIndex: 0,
          onTap: (_) {},
          landscapeMode: OiBottomBarLandscapeMode.hidden,
        ),
        const MediaQueryData(size: Size(500, 300)),
      ),
    );
    // 500×300 → width>height → landscape. isCompact (500 < 600).
    // landscapeMode=hidden → SizedBox.shrink → no labels.
    expect(find.text('Home'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('landscape mode enum values exist', (tester) async {
    expect(
      OiBottomBarLandscapeMode.values,
      contains(OiBottomBarLandscapeMode.compact),
    );
    expect(
      OiBottomBarLandscapeMode.values,
      contains(OiBottomBarLandscapeMode.rail),
    );
    expect(
      OiBottomBarLandscapeMode.values,
      contains(OiBottomBarLandscapeMode.hidden),
    );
  });

  // ── Safe area ─────────────────────────────────────────────────────────────

  testWidgets('bar renders without error with non-zero safe area insets',
      (tester) async {
    await tester.pumpObers(
      _wrapMQ(
        OiBottomBar(items: _kItems, currentIndex: 0, onTap: (_) {}),
        const MediaQueryData(
          size: Size(375, 812),
          padding: EdgeInsets.only(bottom: 34),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Home'), findsOneWidget);
  });
}
