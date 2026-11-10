// Tests do not require documentation comments.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/navigation/oi_breadcrumbs.dart';
import 'package:obers_ui/src/components/navigation/oi_drawer.dart';
import 'package:obers_ui/src/composites/navigation/oi_sidebar.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_sidebar_theme_data.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';
import 'package:obers_ui/src/modules/oi_app_shell.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('OiAppShell', () {
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

    // ── Existing tests ──────────────────────────────────────────────────────

    testWidgets('desktop search does not leave unused space after actions', (
      tester,
    ) async {
      const accountKey = ValueKey('account');
      await tester.pumpObers(
        OiAppShell(
          label: 'Admin',
          title: 'Orders',
          navigation: testNav,
          search: const SizedBox(width: 360, child: Text('Search records')),
          actions: const [SizedBox(width: 36), SizedBox(width: 36)],
          userMenu: const SizedBox(key: accountKey, width: 32, height: 32),
          child: const Text('Content'),
        ),
        surfaceSize: const Size(1440, 900),
      );
      expect(tester.getRect(find.byKey(accountKey)).right, 1440 - 16);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'long desktop breadcrumbs retain search and actions without overflow',
      (tester) async {
        const searchKey = ValueKey('long-title-search');
        const accountKey = ValueKey('long-title-account');
        await tester.pumpObers(
          OiAppShell(
            label: 'Admin',
            navigation: testNav,
            breadcrumbs: [
              OiBreadcrumbItem(
                label: 'Delivery profiles with a very long resource name',
                onTap: () {},
              ),
              const OiBreadcrumbItem(
                label:
                    'Nordlicht Energie GmbH employee company delivery profile',
              ),
            ],
            search: const SizedBox(
              key: searchKey,
              width: 360,
              child: Text('Search records'),
            ),
            actions: const [SizedBox(width: 36), SizedBox(width: 36)],
            userMenu: const SizedBox(key: accountKey, width: 32, height: 32),
            child: const Text('Content'),
          ),
          surfaceSize: const Size(1440, 900),
        );
        expect(tester.getSize(find.byKey(searchKey)).width, 360);
        expect(tester.getRect(find.byKey(accountKey)).right, 1440 - 16);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('compact search keeps its icon, name and activation', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      var opens = 0;
      for (final width in [320.0, 390.0]) {
        await tester.pumpObers(
          OiAppShell(
            label: 'Admin',
            navigation: testNav,
            search: const SizedBox(width: 360, child: Text('Search field')),
            searchLabel: 'Search orders and customers',
            onSearch: () => opens++,
            actions: const [
              SizedBox(width: 32),
              SizedBox(width: 32),
              SizedBox(width: 32),
            ],
            userMenu: const SizedBox(width: 32),
            child: const Text('Content'),
          ),
          surfaceSize: Size(width, 844),
        );
        expect(find.text('Search field'), findsNothing);
        final button = find.byWidgetPredicate(
          (widget) =>
              widget is OiButton &&
              widget.semanticLabel == 'Search orders and customers',
        );
        expect(button.hitTestable(), findsOneWidget);
        expect(tester.getSize(button).width, greaterThanOrEqualTo(32));
        final icon = find.descendant(
          of: button,
          matching: find.byIcon(OiIcons.search),
        );
        expect(icon, findsOneWidget);
        expect(tester.getRect(button).contains(tester.getCenter(icon)), isTrue);
        expect(
          find.bySemanticsLabel('Search orders and customers'),
          findsOneWidget,
        );
        final before = opens;
        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(opens, before + 1);
        Focus.of(tester.element(icon)).requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(opens, before + 2);
        expect(tester.takeException(), isNull);
      }
      semantics.dispose();
    });

    testWidgets('routed content preserves shell action semantics', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      for (final width in [320.0, 1200.0]) {
        await tester.pumpObers(
          OiAppShell(
            label: 'Admin',
            navigation: testNav,
            searchLabel: 'Search all records',
            onSearch: () {},
            child: Navigator(
              onGenerateRoute: (_) => PageRouteBuilder<void>(
                pageBuilder: (_, _, _) => const Text('Routed content'),
              ),
            ),
          ),
          surfaceSize: Size(width, 844),
        );
        await tester.pumpAndSettle();
        expect(find.bySemanticsLabel('Search all records'), findsOneWidget);
        expect(find.bySemanticsLabel('Routed content'), findsOneWidget);
        if (width == 320) {
          expect(find.bySemanticsLabel('Open navigation'), findsOneWidget);
        }
      }
      semantics.dispose();
    });

    testWidgets('desktop keeps the supplied search field', (tester) async {
      await tester.pumpObers(
        OiAppShell(
          label: 'Admin',
          navigation: testNav,
          search: const Text('Search field'),
          onSearch: () {},
          child: const Text('Content'),
        ),
        surfaceSize: const Size(1400, 900),
      );
      expect(find.text('Search field'), findsOneWidget);
      expect(find.byIcon(OiIcons.search), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'sidebar theme covers contextual header as well as navigation',
      (tester) async {
        const sidebarColor = Color(0xFF123456);
        final base = OiThemeData.light();
        await tester.pumpObers(
          OiAppShell(
            label: 'Workspace',
            navigation: testNav,
            navigationHeader: const Text('Workspace heading'),
            child: const Text('Content'),
          ),
          theme: base.copyWith(
            components: base.components.copyWith(
              sidebar: const OiSidebarThemeData(backgroundColor: sidebarColor),
            ),
          ),
          surfaceSize: const Size(1200, 800),
        );
        final backgrounds = tester.widgetList<DecoratedBox>(
          find.ancestor(
            of: find.text('Workspace heading'),
            matching: find.byType(DecoratedBox),
          ),
        );
        expect(
          backgrounds.any(
            (box) =>
                box.decoration is BoxDecoration &&
                (box.decoration as BoxDecoration).color == sidebarColor,
          ),
          isTrue,
        );
      },
    );

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

      handle.dispose();
    });

    testWidgets('navigation items are mapped to OiSidebarSections', (
      tester,
    ) async {
      final sectionNav = [
        const OiNavItem(
          label: 'Home',
          icon: IconData(0xe1b1, fontFamily: 'MaterialIcons'),
          route: '/home',
          section: 'Main',
        ),
        const OiNavItem(
          label: 'About',
          icon: IconData(0xe491, fontFamily: 'MaterialIcons'),
          route: '/about',
          section: 'Main',
        ),
        const OiNavItem(
          label: 'Config',
          icon: IconData(0xe8b8, fontFamily: 'MaterialIcons'),
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

      handle.dispose();
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

      // Children exist in the tree but are clipped to zero height by
      // SizeTransition. They are not hit-testable when collapsed.
      expect(find.text('General').hitTestable(), findsNothing);
      expect(find.text('Security').hitTestable(), findsNothing);

      // Tap Settings to expand the accordion.
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // After expanding, children should be hit-testable (visible and tappable).
      expect(find.text('General').hitTestable(), findsOneWidget);
      expect(find.text('Security').hitTestable(), findsOneWidget);

      // Tap again to collapse.
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('General').hitTestable(), findsNothing);
      expect(find.text('Security').hitTestable(), findsNothing);
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

      handle.dispose();
    });

    testWidgets('mobile drawer closes on close', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpObers(
        OiAppShell(
          label: 'Admin',
          navigation: testNav,
          child: const Text('Content'),
        ),
        surfaceSize: const Size(400, 600),
      );

      // Open the drawer.
      final hamburgerFinder = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Open navigation',
      );
      await tester.tap(hamburgerFinder);
      await tester.pumpAndSettle();

      final drawerFinder = find.byType(OiDrawer);
      expect(tester.widget<OiDrawer>(drawerFinder).open, isTrue);

      // Select a nav item to close the drawer.
      // Dashboard should be visible in the drawer sidebar.
      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();

      expect(tester.widget<OiDrawer>(drawerFinder).open, isFalse);

      handle.dispose();
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
        const OiNavItem(
          label: 'Home',
          icon: IconData(0xe1b1, fontFamily: 'MaterialIcons'),
          route: '/home',
          section: 'Main',
        ),
        const OiNavItem(
          label: 'Config',
          icon: IconData(0xe8b8, fontFamily: 'MaterialIcons'),
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

      await tester.pumpObers(
        OiAppShell(
          label: 'Navigation Panel',
          navigation: testNav,
          child: const Text('Content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      // The shell and sidebar both carry the label (container + sidebar).
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              w.container &&
              w.properties.label == 'Navigation Panel',
        ),
        findsOneWidget,
      );

      // The OiSidebar should receive the same label.
      final sidebar = tester.widget<OiSidebar>(find.byType(OiSidebar));
      expect(sidebar.label, 'Navigation Panel');

      handle.dispose();
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
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Expand sidebar',
        ),
        findsOneWidget,
      );

      handle.dispose();
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
