import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_empty_state.dart';
import 'package:obers_ui/src/components/shop/oi_cart_item_row.dart';
import 'package:obers_ui/src/components/shop/oi_coupon_input.dart';
import 'package:obers_ui/src/components/shop/oi_order_summary_line.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_cart_item.dart';
import 'package:obers_ui/src/models/oi_cart_summary.dart';
import 'package:obers_ui/src/models/oi_coupon_result.dart';
import 'package:obers_ui/src/primitives/display/oi_divider.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/layout/oi_column.dart';

// Material Icons codepoints.
const IconData _kCartIcon = OiIcons.shoppingCart;

/// A full shopping cart view with item list, optional coupon input, order
/// summary lines, checkout button, and continue-shopping link.
///
/// Coverage: REQ-0059
///
/// Shows [OiEmptyState] when the cart is empty. Supports shimmer loading on
/// summary lines. Usable as the content of a side panel, full page, or sheet.
///
/// Composes [OiColumn], [OiCartItemRow], [OiDivider], [OiCouponInput],
/// [OiOrderSummaryLine], [OiButton.primary], [OiEmptyState].
///
/// {@category Composites}
class OiCartPanel extends StatelessWidget {
  /// Creates an [OiCartPanel].
  const OiCartPanel({
    required this.items,
    required this.summary,
    required this.label,
    this.onQuantityChange,
    this.onRemove,
    this.onApplyCoupon,
    this.onRemoveCoupon,
    this.appliedCouponCode,
    this.onCheckout,
    this.onContinueShopping,
    this.checkoutLabel = 'Proceed to Checkout',
    this.currencyCode = 'EUR',
    this.loading = false,
    super.key,
  });

  /// The list of cart items to display.
  final List<OiCartItem> items;

  /// The cart summary with subtotal, discount, shipping, tax, and total.
  final OiCartSummary summary;

  /// Accessibility label announced by screen readers.
  final String label;

  /// Called when the user changes an item's quantity.
  ///
  /// Provides a record with the `productKey` of the changed item and the
  /// new `quantity` value.
  final ValueChanged<({Object productKey, int quantity})>? onQuantityChange;

  /// Called when the user removes an item, with the item's `productKey`.
  final ValueChanged<Object>? onRemove;

  /// Called when the user applies a coupon code. Must return an
  /// [OiCouponResult] indicating success or failure.
  final Future<OiCouponResult> Function(String)? onApplyCoupon;

  /// Called when the user removes the currently applied coupon.
  final VoidCallback? onRemoveCoupon;

  /// The currently applied coupon code, if any.
  final String? appliedCouponCode;

  /// Called when the user taps the checkout button.
  final VoidCallback? onCheckout;

  /// Called when the user taps the continue-shopping link.
  final VoidCallback? onContinueShopping;

  /// Label for the checkout button. Defaults to `'Proceed to Checkout'`.
  final String checkoutLabel;

  /// ISO 4217 currency code. Defaults to `'EUR'`.
  final String currencyCode;

  /// Whether to show shimmer loading on summary lines.
  ///
  /// Defaults to `false`.
  final bool loading;

  Widget _buildItemList(BuildContext context) {
    final breakpoint = context.breakpoint;
    final sp = context.spacing;

    return OiColumn(
      breakpoint: breakpoint,
      gap: OiResponsive(sp.sm),
      children: [
        for (final item in items)
          OiCartItemRow(
            item: item,
            label: '${item.name} × ${item.quantity}',
            currencyCode: currencyCode,
            onQuantityChange: onQuantityChange != null
                ? (qty) => onQuantityChange!((
                    productKey: item.productKey,
                    quantity: qty,
                  ))
                : null,
            onRemove: onRemove != null
                ? () => onRemove!(item.productKey)
                : null,
          ),
      ],
    );
  }

  Widget _buildCouponSection(BuildContext context) {
    return OiCouponInput(
      label: 'Coupon code',
      onApply: onApplyCoupon!,
      onRemove: onRemoveCoupon,
      appliedCode: appliedCouponCode,
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    final breakpoint = context.breakpoint;
    final sp = context.spacing;

    return OiColumn(
      breakpoint: breakpoint,
      gap: OiResponsive(sp.sm),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OiOrderSummaryLine(
          label: 'Subtotal',
          amount: summary.subtotal,
          currencyCode: currencyCode,
          loading: loading,
        ),
        if (summary.discount != null)
          OiOrderSummaryLine(
            label: summary.discountLabel ?? 'Discount',
            amount: summary.discount!,
            currencyCode: currencyCode,
            negative: true,
            loading: loading,
          ),
        if (summary.shipping != null)
          OiOrderSummaryLine(
            label: summary.shippingLabel ?? 'Shipping',
            amount: summary.shipping!,
            currencyCode: currencyCode,
            loading: loading,
          ),
        if (summary.tax != null)
          OiOrderSummaryLine(
            label: summary.taxLabel ?? 'Tax',
            amount: summary.tax!,
            currencyCode: currencyCode,
            loading: loading,
          ),
        const OiDivider(),
        OiOrderSummaryLine(
          label: 'Total',
          amount: summary.total,
          currencyCode: currencyCode,
          bold: true,
          loading: loading,
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final breakpoint = context.breakpoint;
    final sp = context.spacing;

    return OiColumn(
      breakpoint: breakpoint,
      gap: OiResponsive(sp.sm),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OiButton.primary(
          label: checkoutLabel,
          onTap: onCheckout,
          enabled: onCheckout != null,
          fullWidth: true,
          semanticLabel: checkoutLabel,
        ),
        if (onContinueShopping != null)
          Center(
            child: OiButton.ghost(
              label: 'Continue Shopping',
              onTap: onContinueShopping,
              semanticLabel: 'Continue Shopping',
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return OiEmptyState(
      title: 'Your cart is empty',
      icon: _kCartIcon,
      description: 'Add items to your cart to get started.',
      action: onContinueShopping != null
          ? OiButton.primary(
              label: 'Continue Shopping',
              onTap: onContinueShopping,
              semanticLabel: 'Continue Shopping',
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Semantics(label: label, child: _buildEmptyState(context));
    }

    final breakpoint = context.breakpoint;
    final sp = context.spacing;

    return Semantics(
      label: label,
      child: OiColumn(
        breakpoint: breakpoint,
        gap: OiResponsive(sp.md),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OiLabel.bodyStrong('Shopping Cart (${items.length})'),
          _buildItemList(context),
          const OiDivider(),
          if (onApplyCoupon != null) _buildCouponSection(context),
          _buildSummarySection(context),
          SizedBox(height: sp.sm),
          _buildActions(context),
        ],
      ),
    );
  }
}
