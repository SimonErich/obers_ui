// Golden tests have no public API.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:obers_ui/src/composites/navigation/oi_sidebar.dart';
import 'package:obers_ui/src/modules/oi_app_shell.dart';

import '../../helpers/pump_app.dart';

void main() {
  final testNav = [
    const OiNavItem(
      label: 'Dashboard',
      icon: IconData(0xe1b1, fontFamily: 'MaterialIcons'),
      route: '/dashboard',
    ),
    const OiNavItem(
      label: 'Users',
      icon: IconData(0xe491, fontFamily: 'MaterialIcons'),
      route: '/users',
      badge: '5',
    ),
    const OiNavItem(
      label: 'Settings',
      icon: IconData(0xe8b8, fontFamily: 'MaterialIcons'),
      route: '/settings',
      children: [
        OiNavItem(
          label: 'General',
          icon: IconData(0xe8b8, fontFamily: 'MaterialIcons'),
          route: '/settings/general',
        ),
        OiNavItem(
          label: 'Security',
          icon: IconData(0xe8b8, fontFamily: 'MaterialIcons'),
          route: '/settings/security',
        ),
      ],
    ),
  ];

  testGoldens('OiAppShell — desktop expanded', (tester) async {
    await tester.pumpObers(
      OiAppShell(
        label: 'Admin',
        navigation: testNav,
        currentRoute: '/dashboard',
        title: 'Dashboard',
        leading: const Text('MyApp'),
        actions: const [Text('Action')],
        userMenu: const Text('JohnDoe'),
        child: const Center(child: Text('Page content')),
      ),
      surfaceSize: const Size(1200, 800),
    );
    await tester.pumpAndSettle();

    await screenMatchesGolden(tester, 'oi_app_shell_desktop_expanded');
  });

  testGoldens('OiAppShell — desktop collapsed', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpObers(
      OiAppShell(
        label: 'Admin',
        navigation: testNav,
        currentRoute: '/dashboard',
        title: 'Dashboard',
        leading: const Text('MyApp'),
        child: const Center(child: Text('Page content')),
      ),
      surfaceSize: const Size(1200, 800),
    );

    // Collapse the sidebar.
    final collapseFinder = find.byWidgetPredicate(
      (w) => w is Semantics && w.properties.label == 'Collapse sidebar',
    );
    await tester.tap(collapseFinder);
    await tester.pumpAndSettle();

    // Verify collapsed state before snapshot.
    final sidebar = tester.widget<OiSidebar>(find.byType(OiSidebar));
    assert(
      sidebar.mode == OiSidebarMode.compact,
      'sidebar should be in compact mode after collapse',
    );

    await screenMatchesGolden(tester, 'oi_app_shell_desktop_collapsed');

    handle.dispose();
  });

  testGoldens('OiAppShell — mobile drawer open', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpObers(
      OiAppShell(
        label: 'Admin',
        navigation: testNav,
        currentRoute: '/dashboard',
        title: 'Dashboard',
        child: const Center(child: Text('Page content')),
      ),
      surfaceSize: const Size(400, 600),
    );

    // Open the drawer via hamburger.
    final hamburgerFinder = find.byWidgetPredicate(
      (w) => w is Semantics && w.properties.label == 'Open navigation',
    );
    await tester.tap(hamburgerFinder);
    await tester.pumpAndSettle();

    await screenMatchesGolden(tester, 'oi_app_shell_mobile_drawer_open');

    handle.dispose();
  });
}
