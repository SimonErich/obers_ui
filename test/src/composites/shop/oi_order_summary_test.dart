// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/navigation/oi_accordion.dart';
import 'package:obers_ui/src/components/shop/oi_cart_item_row.dart';
import 'package:obers_ui/src/components/shop/oi_order_summary_line.dart';
import 'package:obers_ui/src/composites/shop/oi_order_summary.dart';
import 'package:obers_ui/src/models/oi_cart_item.dart';
import 'package:obers_ui/src/models/oi_cart_summary.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

const _summary = OiCartSummary(
  subtotal: 100,
  discount: 10,
  discountLabel: 'SAVE10',
  shipping: 5,
  shippingLabel: 'Standard',
  tax: 19,
  taxLabel: 'VAT 19%',
  total: 114,
);

const _summaryNoDiscount = OiCartSummary(
  subtotal: 100,
  shipping: 5,
  tax: 19,
  total: 124,
);

const _items = [
  OiCartItem(productKey: 'p1', name: 'Widget A', unitPrice: 50),
  OiCartItem(productKey: 'p2', name: 'Widget B', unitPrice: 25, quantity: 2),
];

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('OiOrderSummary', () {
    testWidgets('renders all summary lines', (tester) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: OiOrderSummary(summary: _summary, label: 'Order summary'),
        ),
      );

      final lines = tester
          .widgetList<OiOrderSummaryLine>(find.byType(OiOrderSummaryLine))
          .toList();

      // subtotal, discount, shipping, tax, total = 5 lines
      expect(lines.length, 5);
    });

    testWidgets('shows total in bold', (tester) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: OiOrderSummary(summary: _summary, label: 'Order summary'),
        ),
      );

      final lines = tester
          .widgetList<OiOrderSummaryLine>(find.byType(OiOrderSummaryLine))
          .toList();

      final totalLine = lines.last;
      expect(totalLine.bold, isTrue);
      expect(totalLine.label, 'Total');
    });

    testWidgets('shows discount as negative', (tester) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: OiOrderSummary(summary: _summary, label: 'Order summary'),
        ),
      );

      final lines = tester
          .widgetList<OiOrderSummaryLine>(find.byType(OiOrderSummaryLine))
          .toList();

      final discountLine = lines.firstWhere((l) => l.label == 'SAVE10');
      expect(discountLine.negative, isTrue);
    });

    testWidgets('renders item list inside OiAccordion when items provided', (
      tester,
    ) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: OiOrderSummary(
            summary: _summary,
            label: 'Order summary',
            items: _items,
          ),
        ),
      );

      expect(find.byType(OiAccordion), findsOneWidget);
      expect(find.byType(OiCartItemRow), findsNWidgets(2));
    });

    testWidgets('hides item list when items is null', (tester) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: OiOrderSummary(summary: _summary, label: 'Order summary'),
        ),
      );

      expect(find.byType(OiAccordion), findsNothing);
      expect(find.byType(OiCartItemRow), findsNothing);
    });

    testWidgets('hides item list when showItems is false', (tester) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: OiOrderSummary(
            summary: _summary,
            label: 'Order summary',
            items: _items,
            showItems: false,
          ),
        ),
      );

      expect(find.byType(OiAccordion), findsNothing);
    });

    testWidgets('items rendered as read-only OiCartItemRow', (tester) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: OiOrderSummary(
            summary: _summary,
            label: 'Order summary',
            items: _items,
            expandedByDefault: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final rows = tester
          .widgetList<OiCartItemRow>(find.byType(OiCartItemRow))
          .toList();

      for (final row in rows) {
        expect(row.editable, isFalse);
      }
    });

    testWidgets(
      'accordion expanded by default when expandedByDefault is true',
      (tester) async {
        await tester.pumpObers(
          const SingleChildScrollView(
            child: OiOrderSummary(
              summary: _summary,
              label: 'Order summary',
              items: _items,
              expandedByDefault: true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Items should be visible when expanded by default.
        expect(find.byType(OiCartItemRow), findsNWidgets(2));
      },
    );

    testWidgets('uses provided currencyCode', (tester) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: OiOrderSummary(
            summary: _summary,
            label: 'Order summary',
            currencyCode: 'USD',
          ),
        ),
      );

      final lines = tester
          .widgetList<OiOrderSummaryLine>(find.byType(OiOrderSummaryLine))
          .toList();

      for (final line in lines) {
        expect(line.currencyCode, 'USD');
      }
    });

    testWidgets('semantic label present', (tester) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: OiOrderSummary(summary: _summary, label: 'Order summary'),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Order summary',
        ),
        findsOneWidget,
      );
    });

    testWidgets('omits discount line when discount is zero', (tester) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: OiOrderSummary(
            summary: _summaryNoDiscount,
            label: 'Order summary',
          ),
        ),
      );

      final lines = tester
          .widgetList<OiOrderSummaryLine>(find.byType(OiOrderSummaryLine))
          .toList();

      // subtotal, shipping, tax, total = 4 lines (no discount)
      expect(lines.length, 4);
      expect(lines.any((l) => l.negative), isFalse);
    });
  });
}
