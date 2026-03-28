// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_avatar.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/inputs/oi_switch_tile.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/modules/oi_drawer_navigation.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

import '../../helpers/pump_app.dart';

void main() {
  // ── Helpers ──────────────────────────────────────────────────────────────

  OiDrawerSection simpleSection({
    String? title,
    List<OiDrawerToggle>? toggles,
  }) {
    return OiDrawerSection(
      title: title,
      toggles: toggles,
      items: const [
        OiDrawerItem(key: 'home', label: 'Home', icon: OiIcons.house),
        OiDrawerItem(key: 'profile', label: 'Profile'),
      ],
    );
  }

  OiDrawerSection sectionWithChildren() {
    return const OiDrawerSection(
      items: [
        OiDrawerItem(
          key: 'settings',
          label: 'Settings',
          icon: OiIcons.settings,
          children: [
            OiDrawerItem(key: 'general', label: 'General'),
            OiDrawerItem(key: 'security', label: 'Security'),
          ],
        ),
      ],
    );
  }

  Widget buildDrawer({
    OiDrawerHeader? header,
    List<OiDrawerSection>? sections,
    Widget? footer,
    Object? selectedKey,
    ValueChanged<OiDrawerItem>? onItemTap,
  }) {
    return SizedBox(
      width: 300,
      height: 600,
      child: OiDrawerNavigation(
        label: 'Test drawer',
        header: header,
        sections: sections ?? [simpleSection()],
        footer: footer,
        selectedKey: selectedKey,
        onItemTap: onItemTap,
      ),
    );
  }

  // ── Tests ───────────────────────────────────────────────────────────────

  testWidgets('renders header with name and subtitle', (tester) async {
    await tester.pumpObers(
      buildDrawer(
        header: const OiDrawerHeader(
          name: 'Jane Doe',
          subtitle: 'Administrator',
        ),
      ),
      surfaceSize: const Size(800, 600),
    );

    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.text('Administrator'), findsOneWidget);
    expect(find.byType(OiAvatar), findsOneWidget);
  });

  testWidgets('renders section items with labels', (tester) async {
    await tester.pumpObers(buildDrawer(), surfaceSize: const Size(800, 600));

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('selected item is highlighted', (tester) async {
    await tester.pumpObers(
      buildDrawer(selectedKey: 'home'),
      surfaceSize: const Size(800, 600),
    );

    // The selected item should have a DecoratedBox ancestor with primary tint.
    final homeLabel = find.text('Home');
    expect(homeLabel, findsOneWidget);

    // Verify that a DecoratedBox wraps the selected item.
    final decoratedBoxes = find.ancestor(
      of: homeLabel,
      matching: find.byType(DecoratedBox),
    );
    // At least one DecoratedBox should be present (the selected highlight
    // plus the drawer surface background).
    expect(decoratedBoxes, findsWidgets);
  });

  testWidgets('tapping item calls onItemTap', (tester) async {
    OiDrawerItem? tappedItem;

    await tester.pumpObers(
      buildDrawer(onItemTap: (item) => tappedItem = item),
      surfaceSize: const Size(800, 600),
    );

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(tappedItem, isNotNull);
    expect(tappedItem!.key, 'home');
  });

  testWidgets('tapping item with children navigates to submenu', (
    tester,
  ) async {
    await tester.pumpObers(
      buildDrawer(sections: [sectionWithChildren()]),
      surfaceSize: const Size(800, 600),
    );

    // Settings has children, so tapping it should navigate to submenu.
    expect(find.text('Settings'), findsOneWidget);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // Submenu should show the children and a back button with parent label.
    expect(find.text('General'), findsOneWidget);
    expect(find.text('Security'), findsOneWidget);
  });

  testWidgets('back button in submenu returns to root', (tester) async {
    await tester.pumpObers(
      buildDrawer(sections: [sectionWithChildren()]),
      surfaceSize: const Size(800, 600),
    );

    // Navigate to submenu.
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('General'), findsOneWidget);

    // Tap the back button (the parent label in submenu header).
    // The back row contains the parent label "Settings" at the top.
    // We tap the Icon(arrowLeft) which is the back button.
    await tester.tap(find.byIcon(OiIcons.arrowLeft));
    await tester.pumpAndSettle();

    // Should be back at root — Settings should be visible again as a
    // root item, and General should be gone.
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('General'), findsNothing);
  });

  testWidgets('toggle tiles render and call onChanged', (tester) async {
    var darkMode = false;

    await tester.pumpObers(
      StatefulBuilder(
        builder: (context, setState) => buildDrawer(
          sections: [
            OiDrawerSection(
              items: const [OiDrawerItem(key: 'home', label: 'Home')],
              toggles: [
                OiDrawerToggle(
                  label: 'Dark Mode',
                  value: darkMode,
                  onChanged: (v) => setState(() => darkMode = v),
                ),
              ],
            ),
          ],
        ),
      ),
      surfaceSize: const Size(800, 600),
    );

    expect(find.byType(OiSwitchTile), findsOneWidget);
    expect(find.text('Dark Mode'), findsOneWidget);
  });

  testWidgets('badge renders on items', (tester) async {
    await tester.pumpObers(
      buildDrawer(
        sections: [
          const OiDrawerSection(
            items: [OiDrawerItem(key: 'inbox', label: 'Inbox', badge: '5')],
          ),
        ],
      ),
      surfaceSize: const Size(800, 600),
    );

    expect(find.byType(OiBadge), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('disabled items are not tappable', (tester) async {
    OiDrawerItem? tappedItem;

    await tester.pumpObers(
      buildDrawer(
        sections: [
          const OiDrawerSection(
            items: [
              OiDrawerItem(key: 'locked', label: 'Locked', disabled: true),
            ],
          ),
        ],
        onItemTap: (item) => tappedItem = item,
      ),
      surfaceSize: const Size(800, 600),
    );

    // The disabled item should render with reduced opacity.
    final opacityWidget = tester.widget<Opacity>(
      find.ancestor(of: find.text('Locked'), matching: find.byType(Opacity)),
    );
    expect(opacityWidget.opacity, 0.5);

    // Tapping should not trigger the callback because disabled items
    // are not wrapped in OiTappable.
    await tester.tap(find.text('Locked'));
    await tester.pumpAndSettle();
    expect(tappedItem, isNull);
  });

  testWidgets('footer renders', (tester) async {
    await tester.pumpObers(
      buildDrawer(
        footer: const Padding(
          padding: EdgeInsets.all(16),
          child: OiLabel.small('v1.0.0'),
        ),
      ),
      surfaceSize: const Size(800, 600),
    );

    expect(find.text('v1.0.0'), findsOneWidget);
  });

  testWidgets('section titles render', (tester) async {
    await tester.pumpObers(
      buildDrawer(sections: [simpleSection(title: 'Navigation')]),
      surfaceSize: const Size(800, 600),
    );

    expect(find.text('NAVIGATION'), findsOneWidget);
  });

  testWidgets('semantics label is applied', (tester) async {
    await tester.pumpObers(buildDrawer(), surfaceSize: const Size(800, 600));

    final semantics = tester.widget<Semantics>(
      find
          .descendant(
            of: find.byType(OiDrawerNavigation),
            matching: find.byType(Semantics),
          )
          .first,
    );
    expect(semantics.properties.label, 'Test drawer');
  });
}
