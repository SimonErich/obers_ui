// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inputs/oi_switch_tile.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/modules/oi_settings_page.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

import '../../helpers/pump_app.dart';

void main() {
  final testGroups = [
    const OiSettingsGroup(
      key: 'general',
      title: 'General',
      description: 'General application settings',
      icon: OiIcons.settings,
      items: [
        OiSettingsItem(
          key: 'notifications',
          title: 'Enable Notifications',
          type: OiSettingsItemType.toggle,
          subtitle: 'Receive push notifications',
          value: true,
        ),
        OiSettingsItem(
          key: 'dark_mode',
          title: 'Dark Mode',
          type: OiSettingsItemType.toggle,
          value: false,
          searchKeywords: ['theme', 'appearance'],
        ),
        OiSettingsItem(
          key: 'account',
          title: 'Account Settings',
          type: OiSettingsItemType.navigation,
          subtitle: 'Manage your account',
          icon: OiIcons.user,
        ),
      ],
    ),
    const OiSettingsGroup(
      key: 'appearance',
      title: 'Appearance',
      items: [
        OiSettingsItem(
          key: 'language',
          title: 'Language',
          type: OiSettingsItemType.select,
          value: 'English',
          options: ['English', 'German', 'French'],
        ),
        OiSettingsItem(
          key: 'font_size',
          title: 'Font Size',
          type: OiSettingsItemType.slider,
          value: 16.0,
          min: 10,
          max: 24,
        ),
      ],
    ),
    const OiSettingsGroup(
      key: 'privacy',
      title: 'Privacy',
      items: [
        OiSettingsItem(
          key: 'analytics',
          title: 'Analytics',
          type: OiSettingsItemType.toggle,
          subtitle: 'Help improve the app',
          value: true,
        ),
      ],
    ),
  ];

  Widget buildPage({
    List<OiSettingsGroup>? groups,
    void Function(String, String, dynamic)? onSettingChanged,
    void Function(OiSettingsItem)? onNavigate,
    void Function(String)? onResetGroup,
    VoidCallback? onResetAll,
    bool searchEnabled = true,
    bool showResetButtons = true,
  }) {
    return SizedBox(
      width: 800,
      height: 600,
      child: OiSettingsPage(
        groups: groups ?? testGroups,
        label: 'Settings',
        onSettingChanged: onSettingChanged,
        onNavigate: onNavigate,
        onResetGroup: onResetGroup,
        onResetAll: onResetAll,
        searchEnabled: searchEnabled,
        showResetButtons: showResetButtons,
      ),
    );
  }

  testWidgets('renders group titles', (tester) async {
    await tester.pumpObers(buildPage(), surfaceSize: const Size(800, 600));

    expect(find.text('General'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Privacy'), findsOneWidget);
  });

  testWidgets('renders toggle items with OiSwitchTile', (tester) async {
    await tester.pumpObers(buildPage(), surfaceSize: const Size(800, 600));

    // There are 3 toggle items across all groups.
    expect(find.byType(OiSwitchTile), findsNWidgets(3));
    expect(find.text('Enable Notifications'), findsOneWidget);
    expect(find.text('Dark Mode'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
  });

  testWidgets('toggle change calls onSettingChanged', (tester) async {
    String? capturedGroup;
    String? capturedKey;
    dynamic capturedValue;

    await tester.pumpObers(
      buildPage(
        onSettingChanged: (group, key, value) {
          capturedGroup = group;
          capturedKey = key;
          capturedValue = value;
        },
      ),
      surfaceSize: const Size(800, 600),
    );

    // Tap the "Enable Notifications" switch tile.
    // OiSwitchTile taps toggle the value.
    final switchTile = find.byType(OiSwitchTile).first;
    await tester.tap(switchTile);
    await tester.pump();

    expect(capturedGroup, 'general');
    expect(capturedKey, 'notifications');
    // Current value is true, tapping should pass false.
    expect(capturedValue, false);
  });

  testWidgets('navigation items show chevron and call onNavigate', (
    tester,
  ) async {
    OiSettingsItem? navigatedItem;

    await tester.pumpObers(
      buildPage(onNavigate: (item) => navigatedItem = item),
      surfaceSize: const Size(800, 600),
    );

    // The navigation item should show a chevron right icon.
    expect(find.text('Account Settings'), findsOneWidget);
    expect(find.byIcon(OiIcons.chevronRight), findsOneWidget);

    // Tap the navigation item.
    await tester.tap(find.text('Account Settings'));
    await tester.pump();

    expect(navigatedItem, isNotNull);
    expect(navigatedItem!.key, 'account');
    expect(navigatedItem!.title, 'Account Settings');
  });

  testWidgets('search filters items by title', (tester) async {
    await tester.pumpObers(buildPage(), surfaceSize: const Size(800, 600));

    // All items visible initially.
    expect(find.text('Enable Notifications'), findsOneWidget);
    expect(find.text('Dark Mode'), findsOneWidget);
    expect(find.text('Account Settings'), findsOneWidget);

    // Type in search.
    final searchInput = find.byType(OiTextInput);
    expect(searchInput, findsOneWidget);

    await tester.enterText(searchInput, 'Dark');
    await tester.pump();

    // Only "Dark Mode" should be visible; others hidden.
    expect(find.text('Dark Mode'), findsOneWidget);
    // "Enable Notifications" should be gone since it doesn't match.
    expect(find.text('Enable Notifications'), findsNothing);
    // The "Account Settings" navigation item should also be hidden.
    expect(find.text('Account Settings'), findsNothing);
  });

  testWidgets('search auto-expands groups with matches', (tester) async {
    await tester.pumpObers(buildPage(), surfaceSize: const Size(800, 600));

    // Collapse the Privacy group first.
    // Find the header for "Privacy" and tap to collapse.
    final privacyHeader = find.text('Privacy');
    expect(privacyHeader, findsOneWidget);

    // The privacy group header is inside an OiTappable.
    // Find the OiTappable that is an ancestor of the "Privacy" text.
    final privacyTappable = find.ancestor(
      of: privacyHeader,
      matching: find.byType(OiTappable),
    );
    await tester.tap(privacyTappable.first);
    await tester.pump();

    // "Analytics" should now be hidden since the group is collapsed.
    // The OiSwitchTile for "Analytics" should be gone.
    expect(find.byType(OiSwitchTile), findsNWidgets(2));

    // Search for "Analytics" — the group should auto-expand.
    final searchInput = find.byType(OiTextInput);
    await tester.enterText(searchInput, 'Analytics');
    await tester.pump();

    // "Analytics" switch tile should now be visible again (auto-expanded).
    expect(find.byType(OiSwitchTile), findsOneWidget);
  });

  testWidgets('reset group button calls onResetGroup', (tester) async {
    String? resetGroupKey;

    await tester.pumpObers(
      buildPage(onResetGroup: (key) => resetGroupKey = key),
      surfaceSize: const Size(800, 600),
    );

    // There should be a "Reset" button for each group (3 groups).
    final resetButtons = find.text('Reset');
    expect(resetButtons, findsNWidgets(3));

    // Tap the first "Reset" button (General group).
    await tester.tap(resetButtons.first);
    await tester.pump();

    expect(resetGroupKey, 'general');
  });

  testWidgets('reset all button calls onResetAll', (tester) async {
    var resetAllCalled = false;

    await tester.pumpObers(
      buildPage(onResetAll: () => resetAllCalled = true),
      surfaceSize: const Size(800, 600),
    );

    final resetAllButton = find.text('Reset All Settings');
    expect(resetAllButton, findsOneWidget);

    await tester.tap(resetAllButton);
    await tester.pump();

    expect(resetAllCalled, isTrue);
  });

  testWidgets('groups can be collapsed and expanded', (tester) async {
    await tester.pumpObers(buildPage(), surfaceSize: const Size(800, 600));

    // Initially all groups are expanded — items are visible.
    expect(find.text('Enable Notifications'), findsOneWidget);

    // Collapse the General group by tapping its header.
    final generalHeader = find.text('General');
    final generalTappable = find.ancestor(
      of: generalHeader,
      matching: find.byType(OiTappable),
    );
    await tester.tap(generalTappable.first);
    await tester.pump();

    // Items of the General group should be hidden.
    expect(find.text('Enable Notifications'), findsNothing);
    expect(find.text('Dark Mode'), findsNothing);
    expect(find.text('Account Settings'), findsNothing);

    // Other groups should remain expanded.
    expect(find.text('Analytics'), findsOneWidget);

    // Expand again.
    await tester.tap(generalTappable.first);
    await tester.pump();

    expect(find.text('Enable Notifications'), findsOneWidget);
  });

  testWidgets('semantics label is applied', (tester) async {
    await tester.pumpObers(buildPage(), surfaceSize: const Size(800, 600));

    final semantics = find.bySemanticsLabel('Settings');
    expect(semantics, findsOneWidget);
  });

  testWidgets('description renders for groups', (tester) async {
    await tester.pumpObers(buildPage(), surfaceSize: const Size(800, 600));

    // The General group has a description.
    expect(find.text('General application settings'), findsOneWidget);
  });

  testWidgets('renders without search bar when searchEnabled is false', (
    tester,
  ) async {
    await tester.pumpObers(
      buildPage(searchEnabled: false),
      surfaceSize: const Size(800, 600),
    );

    expect(find.byType(OiTextInput), findsNothing);
  });

  testWidgets('hides reset buttons when showResetButtons is false', (
    tester,
  ) async {
    await tester.pumpObers(
      buildPage(
        showResetButtons: false,
        onResetAll: () {},
        onResetGroup: (_) {},
      ),
      surfaceSize: const Size(800, 600),
    );

    expect(find.text('Reset All Settings'), findsNothing);
    expect(find.text('Reset'), findsNothing);
  });
}
