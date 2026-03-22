import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/navigation/oi_drawer.dart';
import 'package:obers_ui/src/modules/oi_app_shell.dart';

import '../../helpers/pump_app.dart';

void main() {
  final testNav = [
    const OiNavItem(
      label: 'Dashboard',
      icon: IconData(0xe1b1, fontFamily: 'MaterialIcons'),
      route: '/dashboard',
    ),
  ];

  testWidgets('diag: mobile drawer presence', (tester) async {
    await tester.pumpObers(
      OiAppShell(
        label: 'Admin',
        navigation: testNav,
        child: const Text('Content'),
      ),
      surfaceSize: const Size(400, 600),
    );
    await tester.pumpAndSettle();

    final allTypes = tester.allWidgets
        .map((w) => w.runtimeType.toString())
        .toSet();
    // Why: Diagnostic test intentionally prints widget-tree presence info to stdout for manual inspection during development; no assertion replaces this output.
    // ignore: avoid_print
    print('Has OiDrawer: ${allTypes.contains("OiDrawer")}');

    final context = tester.element(find.text('Content'));
    final size = MediaQuery.sizeOf(context);
    // Why: Diagnostic test intentionally prints the resolved MediaQuery size to stdout so the developer can confirm breakpoint behaviour during manual inspection.
    // ignore: avoid_print
    print('MediaQuery size: $size');

    // Why: Diagnostic test intentionally prints the OiDrawer finder count to stdout so the developer can see whether the drawer is rendered at the given viewport size.
    // ignore: avoid_print
    print('OiDrawer finder: ${find.byType(OiDrawer).evaluate().length}');
  });

  testWidgets('diag: semantics label with ensureSemantics', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpObers(
      OiAppShell(
        label: 'Admin',
        navigation: testNav,
        child: const Text('Content'),
      ),
      surfaceSize: const Size(1200, 800),
    );
    await tester.pumpAndSettle();

    // Why: Diagnostic test intentionally prints the semantics-label match count to stdout for manual inspection of the accessibility tree; no automated assertion captures this detail.
    // ignore: avoid_print
    print(
      'bySemanticsLabel Admin: ${find.bySemanticsLabel('Admin').evaluate().length}',
    );
    // Why: Diagnostic test intentionally prints the semantics-label match count to stdout so the developer can verify the collapse-sidebar button is exposed to the accessibility tree.
    // ignore: avoid_print
    print(
      'bySemanticsLabel Collapse sidebar: ${find.bySemanticsLabel('Collapse sidebar').evaluate().length}',
    );

    // Check all semantics nodes
    final semanticsOwner =
        tester.binding.renderViews.first.owner!.semanticsOwner!;
    void walkSemantics(SemanticsNode node, int depth) {
      final indent = '  ' * depth;
      // Why: Diagnostic walk of the semantics tree intentionally prints every non-empty node label to stdout so the developer can inspect the full accessibility hierarchy.
      // ignore: avoid_print
      if (node.label.isNotEmpty) print('${indent}label: "${node.label}"');
      node.visitChildren((child) {
        walkSemantics(child, depth + 1);
        return true;
      });
    }

    walkSemantics(semanticsOwner.rootSemanticsNode!, 0);

    handle.dispose();
  });

  testWidgets('diag: semantics label without ensureSemantics', (tester) async {
    await tester.pumpObers(
      OiAppShell(
        label: 'Admin',
        navigation: testNav,
        child: const Text('Content'),
      ),
      surfaceSize: const Size(1200, 800),
    );
    await tester.pumpAndSettle();

    // Why: Diagnostic test intentionally prints the semantics-label match count without an active semantics handle to stdout, contrasting the result against the ensureSemantics variant above.
    // ignore: avoid_print
    print(
      'bySemanticsLabel Admin (no handle): ${find.bySemanticsLabel('Admin').evaluate().length}',
    );
  });
}
