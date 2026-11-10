// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/navigation/oi_breadcrumbs.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('icon separator allocates its size and two declared gaps', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiBreadcrumbs(
        items: [
          OiBreadcrumbItem(label: 'Orders'),
          OiBreadcrumbItem(label: 'ORD-1'),
        ],
        separatorIcon: IconData(1),
        separatorSpacing: 8,
      ),
    );
    expect(
      tester.getTopLeft(find.text('ORD-1')).dx -
          tester.getTopRight(find.text('Orders')).dx,
      32,
    );
    expect(find.text('/'), findsNothing);
  });

  testWidgets('breadcrumb honors plain link role and current code label', (
    tester,
  ) async {
    final base = OiThemeData.light();
    await tester.pumpObers(
      OiBreadcrumbs(
        items: [
          OiBreadcrumbItem(label: 'Orders', onTap: () {}),
          const OiBreadcrumbItem(label: 'ORD-1', monospace: true),
        ],
        linkStyle: const TextStyle(
          color: Color(0xff123456),
          fontWeight: FontWeight.w400,
        ),
      ),
      theme: base.copyWith(
        textTheme: base.textTheme.copyWith(link: const TextStyle(fontSize: 14)),
      ),
    );
    final link = tester.widget<Text>(find.text('Orders')).style!;
    expect(link.decoration, isNull);
    expect(link.color, const Color(0xff123456));
    expect(
      tester.widget<Text>(find.text('ORD-1')).style!.fontFamily,
      'monospace',
    );
  });

  // ── Rendering ──────────────────────────────────────────────────────────────

  testWidgets('renders all item labels', (tester) async {
    await tester.pumpObers(
      const OiBreadcrumbs(
        items: [
          OiBreadcrumbItem(label: 'Home'),
          OiBreadcrumbItem(label: 'Products'),
          OiBreadcrumbItem(label: 'Widget'),
        ],
      ),
    );
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Widget'), findsOneWidget);
  });

  testWidgets('renders default separator between items', (tester) async {
    await tester.pumpObers(
      const OiBreadcrumbs(
        items: [
          OiBreadcrumbItem(label: 'Home'),
          OiBreadcrumbItem(label: 'Current'),
        ],
      ),
    );
    expect(find.text('/'), findsOneWidget);
  });

  testWidgets('renders custom separator', (tester) async {
    await tester.pumpObers(
      const OiBreadcrumbs(
        items: [
          OiBreadcrumbItem(label: 'Home'),
          OiBreadcrumbItem(label: 'Current'),
        ],
        separator: '>',
      ),
    );
    expect(find.text('>'), findsOneWidget);
  });

  // ── Tappability ────────────────────────────────────────────────────────────

  testWidgets('non-last item with onTap fires callback', (tester) async {
    var tapped = false;
    await tester.pumpObers(
      OiBreadcrumbs(
        items: [
          OiBreadcrumbItem(label: 'Home', onTap: () => tapped = true),
          const OiBreadcrumbItem(label: 'Current'),
        ],
      ),
    );
    await tester.tap(find.text('Home'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('last item does not fire onTap', (tester) async {
    var tapped = false;
    await tester.pumpObers(
      OiBreadcrumbs(
        items: [
          const OiBreadcrumbItem(label: 'Home'),
          OiBreadcrumbItem(label: 'Current', onTap: () => tapped = true),
        ],
      ),
    );
    // The last item is rendered as plain Text, not OiTappable — no tap fires.
    await tester.tap(find.text('Current'));
    await tester.pump();
    expect(tapped, isFalse);
  });

  // ── maxVisible ─────────────────────────────────────────────────────────────

  testWidgets('maxVisible collapses middle items to ellipsis', (tester) async {
    await tester.pumpObers(
      const OiBreadcrumbs(
        items: [
          OiBreadcrumbItem(label: 'Home'),
          OiBreadcrumbItem(label: 'Section'),
          OiBreadcrumbItem(label: 'Sub'),
          OiBreadcrumbItem(label: 'Current'),
        ],
        maxVisible: 2,
      ),
    );
    // First and last are visible; middle two are collapsed.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Current'), findsOneWidget);
    expect(find.text('…'), findsOneWidget);
    // Middle items should not be directly visible.
    expect(find.text('Section'), findsNothing);
    expect(find.text('Sub'), findsNothing);
  });

  testWidgets('tapping ellipsis reveals hidden items', (tester) async {
    await tester.pumpObers(
      const OiBreadcrumbs(
        items: [
          OiBreadcrumbItem(label: 'Home'),
          OiBreadcrumbItem(label: 'Hidden'),
          OiBreadcrumbItem(label: 'Current'),
        ],
        maxVisible: 2,
      ),
    );
    await tester.tap(find.text('…'));
    await tester.pumpAndSettle();
    expect(find.text('Hidden'), findsOneWidget);
  });

  testWidgets('maxVisible not exceeded shows all items normally', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiBreadcrumbs(
        items: [
          OiBreadcrumbItem(label: 'Home'),
          OiBreadcrumbItem(label: 'Current'),
        ],
        maxVisible: 5,
      ),
    );
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Current'), findsOneWidget);
    expect(find.text('…'), findsNothing);
  });
}
