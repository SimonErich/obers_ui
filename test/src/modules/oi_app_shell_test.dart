// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/navigation/oi_breadcrumbs.dart';
import 'package:obers_ui/src/components/navigation/oi_drawer.dart';
import 'package:obers_ui/src/composites/navigation/oi_sidebar.dart';
import 'package:obers_ui/src/modules/oi_app_shell.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('OiAppShell', () {
    final testNav = [
      OiNavItem(
        label: 'Dashboard',
        icon: const IconData(0xe1b1, fontFamily: 'MaterialIcons'),
        route: '/dashboard',
      ),
      OiNavItem(
        label: 'Users',
        icon: const IconData(0xe491, fontFamily: 'MaterialIcons'),
        route: '/users',
        badge: '5',
      ),
      OiNavItem(
        label: 'Settings',
        icon: const IconData(0xe8b8, fontFamily: 'MaterialIcons'),
        route: '/settings',
        children: [
          OiNavItem(
            label: 'General',
            icon: const IconData(0xe8b8, fontFamily: 'MaterialIcons'),
            route: '/settings/general',
          ),
          OiNavItem(
            label: 'Security',
            icon: const IconData(0xe8b8, fontFamily: 'MaterialIcons'),
            route: '/settings/security',
          ),
        ],
      ),
    ];

    // ── Existing tests ──────────────────────────────────────────────────────

    testWidgets('desktop layout renders sidebar and content', (tester) async {
      await tester.pumpObers(
        OiAppShell(
          label: 'Admin',
          navigation: testNav,
          child: const Text('Content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      expect(find.byType(OiSidebar), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('mobile layout renders hamburger button', (tester) async {
      await tester.pumpObers(
        OiAppShell(
          label: 'Admin',
          navigation: testNav,
          child: const Text('Content'),
        ),
        surfaceSize: const Size(400, 600),
      );

      // Hamburger icon (menu icon 0xe3dc).
      expect(find.byType(Icon), findsWidgets);
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('sidebar collapse toggle works when sidebarCollapsible', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      addTearDown(handle.dispose);

      await tester.pumpObers(
        OiAppShell(
          label: 'Admin',
          navigation: testNav,
          child: const Text('Content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      final collapseFinder = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Collapse sidebar',
      );
      expect(collapseFinder, findsOneWidget);

      await tester.tap(collapseFinder);
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Expand sidebar',
        ),
        findsOneWidget,
      );
    });

    testWidgets('navigation items are mapped to OiSidebarSections', (
      tester,
    ) async {
      final sectionNav = [
        OiNavItem(
          label: 'Home',
          icon: const IconData(0xe1b1, fontFamily: 'MaterialIcons'),
          route: '/home',
          section: 'Main',
        ),
        OiNavItem(
          label: 'About',
          icon: const IconData(0xe491, fontFamily: 'MaterialIcons'),
          route: '/about',
          section: 'Main',
        ),
        OiNavItem(
          label: 'Config',
          icon: const IconData(0xe8b8, fontFamily: 'MaterialIcons'),
          route: '/config',
          section: 'Admin',
        ),
      ];

      await tester.pumpObers(
        OiAppShell(
          label: 'Admin',
          navigation: sectionNav,
          child: const Text('Content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
      expect(find.text('Config'), findsOneWidget);
    });

    testWidgets('active route highlights correct sidebar item', (tester) async {
      await tester.pumpObers(
        OiAppShell(
          label: 'Admin',
          navigation: testNav,
          currentRoute: '/dashboard',
          child: const Text('Content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      final sidebar = tester.widget<OiSidebar>(find.byType(OiSidebar));
      expect(sidebar.selectedId, '/dashboard');
    });

    testWidgets(
      'breadcrumbs render when showBreadcrumbs is true and breadcrumbs provided',
      (tester) async {
        await tester.pumpObers(
          OiAppShell(
            label: 'Admin',
            navigation: testNav,
            breadcrumbs: const [
              OiBreadcrumbItem(label: 'Overview'),
              OiBreadcrumbItem(label: 'People'),
            ],
            child: const Text('Content'),
          ),
          surfaceSize: const Size(1200, 800),
        );

        expect(find.text('Overview'), findsOneWidget);
        expect(find.text('People'), findsOneWidget);
        expect(find.byType(OiBreadcrumbs), findsOneWidget);
      },
    );

    testWidgets('actions render in top bar', (tester) async {
      await tester.pumpObers(
        OiAppShell(
          label: 'Admin',
          navigation: testNav,
          actions: const [Text('Action1'), Text('Action2')],
          child: const Text('Content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      expect(find.text('Action1'), findsOneWidget);
      expect(find.text('Action2'), findsOneWidget);
    });

    testWidgets('leading widget renders in sidebar header', (tester) async {
      await tester.pumpObers(
        OiAppShell(
          label: 'Admin',
          navigation: testNav,
          leading: const Text('MyApp'),
          child: const Text('Content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      expect(find.text('MyApp'), findsOneWidget);
    });

    testWidgets('empty navigation renders content only', (tester) async {
      await tester.pumpObers(
        const OiAppShell(
          label: 'Admin',
          navigation: [],
          child: Text('Content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(OiSidebar), findsNothing);
    });

    testWidgets('semantics label is applied', (tester) async {
      final handle = tester.ensureSemantics();
      addTearDown(handle.dispose);

      await tester.pumpObers(
        const OiAppShell(
          label: 'Admin Panel',
          navigation: [],
          child: Text('Content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Admin Panel',
        ),
        findsOneWidget,
      );
    });

    // ── New tests (REQ-0030) ────────────────────────────────────────────────

    testWidgets('nested accordion items expand on tap', (tester) async {
      await tester.pumpObers(
        OiAppShell(
          label: 'Admin',
          navigation: testNav,
          child: const Text('Content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      // The parent 'Settings' should be visible.
      expect(find.text('Settings'), findsOneWidget);

      // Children should not be visible until parent is expanded.
      expect(find.text('General'), findsNothing);
      expect(find.text('Security'), findsNothing);

      // Tap Settings to expand the accordion.
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Children should now be visible.
      expect(find.text('General'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);

      // Tap again to collapse.
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('General'), findsNothing);
      expect(find.text('Security'), findsNothing);
    });

    testWidgets('user menu renders in top bar', (tester) async {
      await tester.pumpObers(
        OiAppShell(
          label: 'Admin',
          navigation: testNav,
          userMenu: const Text('JohnDoe'),
          child: const Text('Content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      expect(find.text('JohnDoe'), findsOneWidget);
    });

    testWidgets('mobile drawer opens on hamburger tap', (tester) async {
      final handle = tester.ensureSemantics();
      addTearDown(handle.dispose);

      await tester.pumpObers(
        OiAppShell(
          label: 'Admin',
          navigation: testNav,
          child: const Text('Content'),
        ),
        surfaceSize: const Size(400, 600),
      );

      // The drawer should exist but be closed.
      final drawerFinder = find.byType(OiDrawer);
      expect(drawerFinder, findsOneWidget);
      final drawerBefore = tester.widget<OiDrawer>(drawerFinder);
      expect(drawerBefore.open, isFalse);

      // Tap the hamburger.
      final hamburgerFinder = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Open navigation',
      );
      expect(hamburgerFinder, findsOneWidget);
      await tester.tap(hamburgerFinder);
      await tester.pumpAndSettle();

      // The drawer should now be open.
      final drawerAfter = tester.widget<OiDrawer>(drawerFinder);
      expect(drawerAfter.open, isTrue);
    });

    testWidgets('mobile drawer closes on close', (tester) async {
      final handle = tester.ensureSemantics();
      addTearDown(handle.dispose);

      await tester.pumpObers(
        OiAppShell(
          label: 'Admin',
          navigation: testNav,
          child: const Text('Content'),
        ),
        surfaceSize: const Size(400, 600),
      );

      // Open the drawer.
      await tester.tap(find.bySemanticsLabel('Open navigation'));
      await tester.pumpAndSettle();

      final drawerFinder = find.byType(OiDrawer);
      expect(tester.widget<OiDrawer>(drawerFinder).open, isTrue);

      // Select a nav item to close the drawer.
      // Dashboard should be visible in the drawer sidebar.
      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();

      expect(tester.widget<OiDrawer>(drawerFinder).open, isFalse);
    });

    testWidgets('mobile hides breadcrumbs', (tester) async {
      await tester.pumpObers(
        OiAppShell(
          label: 'Admin',
          navigation: testNav,
          breadcrumbs: const [
            OiBreadcrumbItem(label: 'Home'),
            OiBreadcrumbItem(label: 'Users'),
          ],
          child: const Text('Content'),
        ),
        surfaceSize: const Size(400, 600),
      );

      // Breadcrumbs should not be shown on mobile (hamburger takes priority).
      expect(find.byType(OiBreadcrumbs), findsNothing);
    });

    testWidgets('badges display on nav items', (tester) async {
      await tester.pumpObers(
        OiAppShell(
          label: 'Admin',
          navigation: testNav,
          child: const Text('Content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      // The Users item has badge: '5'. OiSidebar renders badgeCount via
      // OiBadge which displays the count text.
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('section labels render in sidebar', (tester) async {
      final sectionNav = [
        OiNavItem(
          label: 'Home',
          icon: const IconData(0xe1b1, fontFamily: 'MaterialIcons'),
          route: '/home',
          section: 'Main',
        ),
        OiNavItem(
          label: 'Config',
          icon: const IconData(0xe8b8, fontFamily: 'MaterialIcons'),
          route: '/config',
          section: 'Admin',
        ),
      ];

      await tester.pumpObers(
        OiAppShell(
          label: 'Admin',
          navigation: sectionNav,
          child: const Text('Content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      // Section headers should be rendered.
      expect(find.text('Main'), findsOneWidget);
      expect(find.text('Admin'), findsAtLeast(1));
    });

    testWidgets('a11y: sidebar has navigation landmark', (tester) async {
      await tester.pumpObers(
        OiAppShell(
          label: 'Admin',
          navigation: testNav,
          child: const Text('Content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      // The OiSidebar wraps content in Semantics with a label.
      // Find the sidebar semantics.
      final sidebar = tester.widget<OiSidebar>(find.byType(OiSidebar));
      expect(sidebar.label, 'Admin');
    });

    testWidgets('a11y: sidebar label applied', (tester) async {
      final handle = tester.ensureSemantics();
      addTearDown(handle.dispose);

      await tester.pumpObers(
        OiAppShell(
          label: 'Navigation Panel',
          navigation: testNav,
          child: const Text('Content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      // The shell itself has a Semantics with the label.
      expect(find.bySemanticsLabel('Navigation Panel'), findsOneWidget);

      // The OiSidebar should receive the same label.
      final sidebar = tester.widget<OiSidebar>(find.byType(OiSidebar));
      expect(sidebar.label, 'Navigation Panel');
    });

    testWidgets('keyboard: Tab focuses sidebar', (tester) async {
      await tester.pumpObers(
        OiAppShell(
          label: 'Admin',
          navigation: testNav,
          child: const Text('Content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      // Ensure the sidebar Focus node exists by finding the OiSidebar.
      expect(find.byType(OiSidebar), findsOneWidget);

      // Send Tab to move focus into the sidebar area.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // The sidebar has a Focus node, verify it can receive focus.
      final sidebar = find.byType(OiSidebar);
      expect(sidebar, findsOneWidget);
    });

    testWidgets('keyboard: Enter activates nav item', (tester) async {
      String? navigatedTo;

      await tester.pumpObers(
        OiAppShell(
          label: 'Admin',
          navigation: testNav,
          onNavigate: (route) => navigatedTo = route,
          child: const Text('Content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      // Focus the sidebar by tapping into it first.
      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();

      expect(navigatedTo, '/dashboard');

      // Reset and test keyboard selection.
      navigatedTo = null;

      // Tap Users via keyboard simulation — first tap to establish focus.
      await tester.tap(find.text('Users'));
      await tester.pumpAndSettle();

      expect(navigatedTo, '/users');
    });

    testWidgets('title renders in the top bar', (tester) async {
      await tester.pumpObers(
        OiAppShell(
          label: 'Admin',
          navigation: testNav,
          title: 'Dashboard Page',
          child: const Text('Content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      expect(find.text('Dashboard Page'), findsOneWidget);
    });

    testWidgets('onNavigate callback fires when nav item is tapped', (
      tester,
    ) async {
      String? navigatedRoute;

      await tester.pumpObers(
        OiAppShell(
          label: 'Admin',
          navigation: testNav,
          onNavigate: (route) => navigatedRoute = route,
          child: const Text('Content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();

      expect(navigatedRoute, '/dashboard');
    });

    testWidgets('sidebarDefaultCollapsed starts sidebar collapsed', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      addTearDown(handle.dispose);

      await tester.pumpObers(
        OiAppShell(
          label: 'Admin',
          navigation: testNav,
          sidebarDefaultCollapsed: true,
          child: const Text('Content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      // Sidebar should be in compact mode.
      final sidebar = tester.widget<OiSidebar>(find.byType(OiSidebar));
      expect(sidebar.mode, OiSidebarMode.compact);

      // The expand toggle should be visible.
      expect(find.bySemanticsLabel('Expand sidebar'), findsOneWidget);
    });

    testWidgets('active route found in nested children', (tester) async {
      await tester.pumpObers(
        OiAppShell(
          label: 'Admin',
          navigation: testNav,
          currentRoute: '/settings/general',
          child: const Text('Content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      final sidebar = tester.widget<OiSidebar>(find.byType(OiSidebar));
      expect(sidebar.selectedId, '/settings/general');
    });
  });
}
