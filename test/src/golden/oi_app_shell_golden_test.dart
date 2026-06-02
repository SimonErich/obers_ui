// Golden tests have no public API.

import 'package:alchemist/alchemist.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/navigation/oi_sidebar.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';
import 'package:obers_ui/src/modules/oi_app_shell.dart';

Future<void> main() async {
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

  Widget shell({List<Widget>? actions, Widget? userMenu}) => OiAppShell(
    label: 'Admin',
    navigation: testNav,
    currentRoute: '/dashboard',
    title: 'Dashboard',
    leading: const Text('MyApp'),
    actions: actions,
    userMenu: userMenu,
    child: const Center(child: Text('Page content')),
  );

  await goldenTest(
    'OiAppShell — desktop expanded',
    fileName: 'oi_app_shell_desktop_expanded',
    constraints: const BoxConstraints.tightFor(width: 1200, height: 800),
    pumpBeforeTest: (tester) async {
      await _setSurface(tester, const Size(1200, 800));
    },
    builder: () => _OiAppShellHarness(
      child: shell(
        actions: const [Text('Action')],
        userMenu: const Text('JohnDoe'),
      ),
    ),
  );

  await goldenTest(
    'OiAppShell — desktop collapsed',
    fileName: 'oi_app_shell_desktop_collapsed',
    constraints: const BoxConstraints.tightFor(width: 1200, height: 800),
    pumpBeforeTest: (tester) async {
      await _setSurface(tester, const Size(1200, 800));
      final handle = tester.ensureSemantics();
      // Collapse the sidebar before snapshotting.
      final collapseFinder = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Collapse sidebar',
      );
      await tester.tap(collapseFinder);
      await tester.pumpAndSettle();

      final sidebar = tester.widget<OiSidebar>(find.byType(OiSidebar));
      assert(
        sidebar.mode == OiSidebarMode.compact,
        'sidebar should be in compact mode after collapse',
      );
      handle.dispose();
    },
    builder: () => _OiAppShellHarness(child: shell()),
  );

  await goldenTest(
    'OiAppShell — mobile drawer open',
    fileName: 'oi_app_shell_mobile_drawer_open',
    // 480 (still below the mobile breakpoint) gives the CI-variant Ahem text,
    // which is wider than real glyphs, room to fit the top bar without a
    // RenderFlex overflow. Real-font (Linux) goldens are unaffected.
    constraints: const BoxConstraints.tightFor(width: 480, height: 600),
    pumpBeforeTest: (tester) async {
      await _setSurface(tester, const Size(480, 600));
      final handle = tester.ensureSemantics();
      // Open the drawer via the hamburger before snapshotting.
      final hamburgerFinder = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Open navigation',
      );
      await tester.tap(hamburgerFinder);
      await tester.pumpAndSettle();
      handle.dispose();
    },
    builder: () => _OiAppShellHarness(child: shell()),
  );
}

/// Sets the test surface + view size so OiAppShell's MediaQuery-driven
/// mobile/desktop breakpoint resolves correctly. Reset after the test.
Future<void> _setSurface(WidgetTester tester, Size size) async {
  await tester.binding.setSurfaceSize(size);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpAndSettle();
}

/// Wraps a full-screen [OiAppShell] in [OiApp] for golden capture. The shell
/// fills the bounded surface set via `goldenTest`'s `constraints`.
class _OiAppShellHarness extends StatelessWidget {
  const _OiAppShellHarness({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return OiApp(theme: OiThemeData.light(), home: child);
  }
}
