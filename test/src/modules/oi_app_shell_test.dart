// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/navigation/oi_breadcrumbs.dart';
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
        ],
      ),
    ];

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
      // No sidebar visible initially on mobile.
      // The sidebar is inside a Drawer which is off-screen.
    });

    testWidgets('sidebar collapse toggle works when sidebarCollapsible', (
      tester,
    ) async {
      await tester.pumpObers(
        OiAppShell(
          label: 'Admin',
          navigation: testNav,
          child: const Text('Content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      // Find the collapse toggle by its semantics label.
      final collapseFinder = find.bySemanticsLabel('Collapse sidebar');
      expect(collapseFinder, findsOneWidget);

      await tester.tap(collapseFinder);
      await tester.pumpAndSettle();

      // After collapse, the expand toggle should appear.
      expect(find.bySemanticsLabel('Expand sidebar'), findsOneWidget);
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

      // Items from both sections should be rendered.
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

      // The sidebar should have selectedId set to '/dashboard'.
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
              OiBreadcrumbItem(label: 'Home'),
              OiBreadcrumbItem(label: 'Users'),
            ],
            child: const Text('Content'),
          ),
          surfaceSize: const Size(1200, 800),
        );

        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Users'), findsOneWidget);
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
      await tester.pumpObers(
        const OiAppShell(
          label: 'Admin Panel',
          navigation: [],
          child: Text('Content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      expect(find.bySemanticsLabel('Admin Panel'), findsOneWidget);
    });
  });
}
