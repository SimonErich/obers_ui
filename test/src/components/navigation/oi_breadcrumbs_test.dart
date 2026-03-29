// Tests do not require documentation comments.

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/navigation/oi_breadcrumbs.dart';

import '../../../helpers/pump_app.dart';

void main() {
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
