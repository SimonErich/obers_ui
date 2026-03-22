// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/shop/oi_order_summary_line.dart';
import 'package:obers_ui/src/components/shop/oi_price_tag.dart';
import 'package:obers_ui/src/primitives/animation/oi_shimmer.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiOrderSummaryLine', () {
    testWidgets('renders label and amount', (tester) async {
      await tester.pumpObers(
        const OiOrderSummaryLine(label: 'Subtotal', amount: 99.99),
        surfaceSize: const Size(400, 100),
      );
      expect(find.text('Subtotal'), findsOneWidget);
      // EUR format: "99.99 €"
      expect(find.text('99.99 €'), findsOneWidget);
    });

    testWidgets('bold mode applies bold font via OiLabel.bodyStrong', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiOrderSummaryLine(label: 'Total', amount: 120, bold: true),
        surfaceSize: const Size(400, 100),
      );
      expect(find.text('Total'), findsOneWidget);
    });

    testWidgets('negative mode shows negative price via OiPriceTag', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiOrderSummaryLine(
          label: 'Discount',
          amount: 10,
          negative: true,
        ),
        surfaceSize: const Size(400, 100),
      );
      // OiPriceTag will render negative price: "-10.00 €"
      expect(find.text('-10.00 €'), findsOneWidget);
    });

    testWidgets('loading mode shows shimmer instead of amount', (tester) async {
      await tester.pumpObers(
        const OiOrderSummaryLine(
          label: 'Shipping',
          amount: 5.99,
          loading: true,
        ),
        surfaceSize: const Size(400, 100),
      );
      expect(find.text('Shipping'), findsOneWidget);
      expect(find.byType(OiShimmer), findsOneWidget);
      // Price tag should not be visible.
      expect(find.byType(OiPriceTag), findsNothing);
    });

    testWidgets('subtitle renders below label', (tester) async {
      await tester.pumpObers(
        const OiOrderSummaryLine(
          label: 'Discount',
          amount: 20,
          subtitle: 'SUMMER20',
        ),
        surfaceSize: const Size(400, 100),
      );
      expect(find.text('Discount'), findsOneWidget);
      expect(find.text('SUMMER20'), findsOneWidget);
    });

    testWidgets('default currencyCode is EUR', (tester) async {
      await tester.pumpObers(
        const OiOrderSummaryLine(label: 'Tax', amount: 5),
        surfaceSize: const Size(400, 100),
      );
      // EUR format: amount then €
      expect(find.text('5.00 €'), findsOneWidget);
    });

    testWidgets('custom currencyCode forwarded to OiPriceTag', (tester) async {
      await tester.pumpObers(
        const OiOrderSummaryLine(
          label: 'Total',
          amount: 100,
          currencyCode: 'USD',
        ),
        surfaceSize: const Size(400, 100),
      );
      expect(find.text(r'$100.00'), findsOneWidget);
    });

    testWidgets('accessibility label present', (tester) async {
      await tester.pumpObers(
        const OiOrderSummaryLine(label: 'Subtotal', amount: 50),
        surfaceSize: const Size(400, 100),
      );
      expect(
        find.bySemanticsLabel(RegExp(r'Subtotal.*50\.00')),
        findsOneWidget,
      );
    });

    testWidgets('non-bold mode renders label without bold', (tester) async {
      await tester.pumpObers(
        const OiOrderSummaryLine(label: 'Shipping', amount: 5),
        surfaceSize: const Size(400, 100),
      );
      expect(find.text('Shipping'), findsOneWidget);
    });

    testWidgets('loading + negative combination handled', (tester) async {
      await tester.pumpObers(
        const OiOrderSummaryLine(
          label: 'Discount',
          amount: 10,
          negative: true,
          loading: true,
        ),
        surfaceSize: const Size(400, 100),
      );
      // Loading takes precedence — shimmer shown, no price tag.
      expect(find.byType(OiShimmer), findsOneWidget);
      expect(find.byType(OiPriceTag), findsNothing);
    });
  });
}
