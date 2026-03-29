// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/buttons/oi_icon_button.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/display/oi_popover.dart';
import 'package:obers_ui/src/components/shop/oi_cart_item_row.dart';
import 'package:obers_ui/src/components/shop/oi_price_tag.dart';
import 'package:obers_ui/src/composites/shop/oi_mini_cart.dart';
import 'package:obers_ui/src/models/oi_cart_item.dart';
import 'package:obers_ui/src/models/oi_cart_summary.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

const _items = [
  OiCartItem(productKey: 'p1', name: 'Widget A', unitPrice: 50),
  OiCartItem(productKey: 'p2', name: 'Widget B', unitPrice: 25, quantity: 2),
  OiCartItem(productKey: 'p3', name: 'Widget C', unitPrice: 10),
  OiCartItem(productKey: 'p4', name: 'Widget D', unitPrice: 15, quantity: 3),
];

const _summary = OiCartSummary(subtotal: 155, shipping: 5, tax: 30, total: 190);

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('OiMiniCart', () {
    testWidgets('renders OiIconButton anchor', (tester) async {
      await tester.pumpObers(
        const Center(
          child: OiMiniCart(items: _items, summary: _summary, label: 'Cart'),
        ),
      );

      expect(find.byType(OiIconButton), findsOneWidget);
    });

    testWidgets('shows OiBadge with item count', (tester) async {
      await tester.pumpObers(
        const Center(
          child: OiMiniCart(items: _items, summary: _summary, label: 'Cart'),
        ),
      );

      expect(find.byType(OiBadge), findsOneWidget);
      // Total quantity: 1 + 2 + 1 + 3 = 7
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('hides badge when items is empty', (tester) async {
      await tester.pumpObers(
        const Center(
          child: OiMiniCart(items: [], summary: _summary, label: 'Cart'),
        ),
      );

      expect(find.byType(OiBadge), findsNothing);
    });

    testWidgets('opens popover when display is popover', (tester) async {
      await tester.pumpObers(
        const Center(
          child: OiMiniCart(items: _items, summary: _summary, label: 'Cart'),
        ),
      );

      expect(find.byType(OiPopover), findsOneWidget);

      // Tap the icon to open.
      await tester.tap(find.byType(OiIconButton));
      await tester.pumpAndSettle();

      // Popover should now be open with cart items visible.
      expect(find.byType(OiCartItemRow), findsWidgets);
    });

    testWidgets('shows limited items based on maxVisibleItems', (tester) async {
      await tester.pumpObers(
        const Center(
          child: OiMiniCart(
            items: _items,
            summary: _summary,
            label: 'Cart',
            maxVisibleItems: 2,
          ),
        ),
      );

      await tester.tap(find.byType(OiIconButton));
      await tester.pumpAndSettle();

      expect(find.byType(OiCartItemRow), findsNWidgets(2));
    });

    testWidgets('shows overflow text', (tester) async {
      await tester.pumpObers(
        const Center(
          child: OiMiniCart(
            items: _items,
            summary: _summary,
            label: 'Cart',
            maxVisibleItems: 2,
          ),
        ),
      );

      await tester.tap(find.byType(OiIconButton));
      await tester.pumpAndSettle();

      expect(find.text('2 more items'), findsOneWidget);
    });

    testWidgets('shows total price via OiPriceTag', (tester) async {
      await tester.pumpObers(
        const Center(
          child: OiMiniCart(items: _items, summary: _summary, label: 'Cart'),
        ),
      );

      await tester.tap(find.byType(OiIconButton));
      await tester.pumpAndSettle();

      expect(find.byType(OiPriceTag), findsWidgets);
    });

    testWidgets('shows View Cart and Checkout buttons', (tester) async {
      await tester.pumpObers(
        const Center(
          child: OiMiniCart(items: _items, summary: _summary, label: 'Cart'),
        ),
      );

      await tester.tap(find.byType(OiIconButton));
      await tester.pumpAndSettle();

      expect(find.text('View Cart'), findsOneWidget);
      expect(find.text('Checkout'), findsOneWidget);
    });

    testWidgets('fires onViewCart callback', (tester) async {
      var fired = false;
      await tester.pumpObers(
        Center(
          child: OiMiniCart(
            items: _items,
            summary: _summary,
            label: 'Cart',
            onViewCart: () => fired = true,
          ),
        ),
      );

      await tester.tap(find.byType(OiIconButton));
      await tester.pumpAndSettle();

      // Content is in a CompositedTransformFollower overlay — invoke the
      // button callback directly to avoid hit-test offset limitations.
      final viewCartBtn = tester.widget<OiButton>(
        find.byWidgetPredicate((w) => w is OiButton && w.label == 'View Cart'),
      );
      viewCartBtn.onTap!();
      expect(fired, isTrue);
    });

    testWidgets('fires onCheckout callback', (tester) async {
      var fired = false;
      await tester.pumpObers(
        Center(
          child: OiMiniCart(
            items: _items,
            summary: _summary,
            label: 'Cart',
            onCheckout: () => fired = true,
          ),
        ),
      );

      await tester.tap(find.byType(OiIconButton));
      await tester.pumpAndSettle();

      final checkoutBtn = tester.widget<OiButton>(
        find.byWidgetPredicate((w) => w is OiButton && w.label == 'Checkout'),
      );
      checkoutBtn.onTap!();
      expect(fired, isTrue);
    });

    testWidgets('shows empty state when items is empty', (tester) async {
      await tester.pumpObers(
        const Center(
          child: OiMiniCart(items: [], summary: _summary, label: 'Cart'),
        ),
      );

      await tester.tap(find.byType(OiIconButton));
      await tester.pumpAndSettle();

      expect(find.text('Cart is empty'), findsOneWidget);
    });

    testWidgets('fires onRemove when item removed', (tester) async {
      Object? removedKey;
      await tester.pumpObers(
        Center(
          child: OiMiniCart(
            items: _items,
            summary: _summary,
            label: 'Cart',
            onRemove: (key) => removedKey = key,
          ),
        ),
      );

      await tester.tap(find.byType(OiIconButton));
      await tester.pumpAndSettle();

      // Content is in a CompositedTransformFollower overlay — invoke the
      // remove callback directly to avoid hit-test offset limitations.
      final removeBtns = find.byWidgetPredicate(
        (w) => w is OiButton && w.label == 'Remove',
      );
      expect(removeBtns, findsWidgets);
      final removeBtn = tester.widget<OiButton>(removeBtns.first);
      removeBtn.onTap!();
      expect(removedKey, isNotNull);
    });

    testWidgets('semantic label present', (tester) async {
      await tester.pumpObers(
        const Center(
          child: OiMiniCart(
            items: _items,
            summary: _summary,
            label: 'Mini cart',
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Mini cart',
        ),
        findsWidgets,
      );
    });
  });
}
