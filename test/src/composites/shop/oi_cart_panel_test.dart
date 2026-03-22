// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_icon_button.dart';
import 'package:obers_ui/src/components/display/oi_empty_state.dart';
import 'package:obers_ui/src/components/shop/oi_cart_item_row.dart';
import 'package:obers_ui/src/components/shop/oi_coupon_input.dart';
import 'package:obers_ui/src/components/shop/oi_order_summary_line.dart';
import 'package:obers_ui/src/composites/shop/oi_cart_panel.dart';
import 'package:obers_ui/src/models/oi_cart_item.dart';
import 'package:obers_ui/src/models/oi_cart_summary.dart';
import 'package:obers_ui/src/models/oi_coupon_result.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

const _items = [
  OiCartItem(productKey: 'p1', name: 'Widget A', unitPrice: 50),
  OiCartItem(productKey: 'p2', name: 'Widget B', unitPrice: 25, quantity: 2),
];

const _summary = OiCartSummary(
  subtotal: 100,
  discount: 10,
  discountLabel: 'SAVE10',
  shipping: 5,
  tax: 19,
  total: 114,
);

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('OiCartPanel', () {
    testWidgets('renders list of OiCartItemRow widgets', (tester) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: OiCartPanel(items: _items, summary: _summary, label: 'Cart'),
        ),
      );

      expect(find.byType(OiCartItemRow), findsNWidgets(2));
    });

    testWidgets('shows OiEmptyState when items list is empty', (tester) async {
      await tester.pumpObers(
        const OiCartPanel(items: [], summary: _summary, label: 'Cart'),
      );

      expect(find.byType(OiEmptyState), findsOneWidget);
    });

    testWidgets('empty state shows correct message', (tester) async {
      await tester.pumpObers(
        const OiCartPanel(items: [], summary: _summary, label: 'Cart'),
      );

      expect(find.text('Your cart is empty'), findsOneWidget);
    });

    testWidgets('shows coupon input when onApplyCoupon provided', (
      tester,
    ) async {
      await tester.pumpObers(
        SingleChildScrollView(
          child: OiCartPanel(
            items: _items,
            summary: _summary,
            label: 'Cart',
            onApplyCoupon: (code) async => const OiCouponResult(valid: true),
          ),
        ),
      );

      expect(find.byType(OiCouponInput), findsOneWidget);
    });

    testWidgets('hides coupon input when onApplyCoupon is null', (
      tester,
    ) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: OiCartPanel(items: _items, summary: _summary, label: 'Cart'),
        ),
      );

      expect(find.byType(OiCouponInput), findsNothing);
    });

    testWidgets('shows checkout button with default label', (tester) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: OiCartPanel(items: _items, summary: _summary, label: 'Cart'),
        ),
      );

      expect(find.text('Proceed to Checkout'), findsOneWidget);
    });

    testWidgets('shows custom checkoutLabel', (tester) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: OiCartPanel(
            items: _items,
            summary: _summary,
            label: 'Cart',
            checkoutLabel: 'Buy Now',
          ),
        ),
      );

      expect(find.text('Buy Now'), findsOneWidget);
    });

    testWidgets('fires onCheckout when checkout button tapped', (tester) async {
      var fired = false;
      await tester.pumpObers(
        SingleChildScrollView(
          child: OiCartPanel(
            items: _items,
            summary: _summary,
            label: 'Cart',
            onCheckout: () => fired = true,
          ),
        ),
      );

      await tester.tap(find.text('Proceed to Checkout'));
      expect(fired, isTrue);
    });

    testWidgets('shows continue shopping link when callback provided', (
      tester,
    ) async {
      await tester.pumpObers(
        SingleChildScrollView(
          child: OiCartPanel(
            items: _items,
            summary: _summary,
            label: 'Cart',
            onContinueShopping: () {},
          ),
        ),
      );

      expect(find.text('Continue Shopping'), findsOneWidget);
    });

    testWidgets('hides continue shopping link when callback is null', (
      tester,
    ) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: OiCartPanel(items: _items, summary: _summary, label: 'Cart'),
        ),
      );

      // Only the checkout button, no continue shopping.
      expect(find.text('Continue Shopping'), findsNothing);
    });

    testWidgets('shows shimmer on summary lines when loading', (tester) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: OiCartPanel(
            items: _items,
            summary: _summary,
            label: 'Cart',
            loading: true,
          ),
        ),
      );

      final lines = tester
          .widgetList<OiOrderSummaryLine>(find.byType(OiOrderSummaryLine))
          .toList();

      for (final line in lines) {
        expect(line.loading, isTrue);
      }
    });

    testWidgets('fires onRemove with productKey when item removed', (
      tester,
    ) async {
      Object? removedKey;
      await tester.pumpObers(
        SingleChildScrollView(
          child: OiCartPanel(
            items: _items,
            summary: _summary,
            label: 'Cart',
            onRemove: (key) => removedKey = key,
          ),
        ),
      );

      // Find the first Remove button and tap it.
      final removeButtons = find.text('Remove');
      await tester.tap(removeButtons.first);

      expect(removedKey, 'p1');
    });

    testWidgets('fires onQuantityChange with productKey and quantity', (
      tester,
    ) async {
      ({Object productKey, int quantity})? change;
      await tester.pumpObers(
        SingleChildScrollView(
          child: OiCartPanel(
            items: _items,
            summary: _summary,
            label: 'Cart',
            onQuantityChange: (record) => change = record,
          ),
        ),
      );

      // OiQuantitySelector uses OiIconButton with semanticLabel
      // 'Increase quantity'. Find and tap the first one.
      final increaseButtons = find.byWidgetPredicate(
        (w) => w is OiIconButton && w.semanticLabel == 'Increase quantity',
      );
      expect(increaseButtons, findsWidgets);
      await tester.tap(increaseButtons.first);
      expect(change, isNotNull);
      expect(change!.productKey, 'p1');
      expect(change!.quantity, 2);
    });

    testWidgets('semantic label present', (tester) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: OiCartPanel(
            items: _items,
            summary: _summary,
            label: 'Shopping cart',
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Shopping cart',
        ),
        findsOneWidget,
      );
    });
  });
}
