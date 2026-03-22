import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/data/mock_shop.dart';

/// Cart screen wrapping [OiCartPanel] with quantity controls and coupon input.
class ShopCartScreen extends StatelessWidget {
  const ShopCartScreen({
    required this.cartItems,
    required this.cartSummary,
    required this.onQuantityChange,
    required this.onRemove,
    required this.onApplyCoupon,
    required this.onRemoveCoupon,
    required this.onCheckout,
    required this.onContinueShopping,
    this.appliedCouponCode,
    super.key,
  });

  final List<OiCartItem> cartItems;
  final OiCartSummary cartSummary;
  final ValueChanged<({Object productKey, int quantity})> onQuantityChange;
  final ValueChanged<Object> onRemove;
  final Future<OiCouponResult> Function(String) onApplyCoupon;
  final VoidCallback onRemoveCoupon;
  final VoidCallback onCheckout;
  final VoidCallback onContinueShopping;
  final String? appliedCouponCode;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;

    final subtotal =
        cartItems.fold<double>(0, (sum, item) => sum + item.totalPrice);
    final remaining = kFreeShippingThreshold - subtotal;
    final progress = (subtotal / kFreeShippingThreshold).clamp(0.0, 1.0);
    final hasFreeShipping = remaining <= 0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Free shipping progress bar
              if (cartItems.isNotEmpty) ...[
                OiCard(
                  child: Padding(
                    padding: EdgeInsets.all(spacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasFreeShipping)
                          Row(
                            children: [
                              Icon(
                                OiIcons.check,
                                size: 16,
                                color: colors.success.base,
                              ),
                              SizedBox(width: spacing.xs),
                              OiLabel.body(
                                'You qualify for free shipping!',
                                color: colors.success.base,
                              ),
                            ],
                          )
                        else
                          OiLabel.body(
                            'EUR ${remaining.toStringAsFixed(2)} more '
                            'for free shipping!',
                          ),
                        SizedBox(height: spacing.sm),
                        OiProgress.linear(
                          value: progress,
                          label: hasFreeShipping
                              ? 'Free shipping unlocked'
                              : 'EUR ${subtotal.toStringAsFixed(2)} '
                                  'of EUR '
                                  '${kFreeShippingThreshold.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: spacing.md),
              ],
              // Cart panel
              OiCartPanel(
                items: cartItems,
                summary: cartSummary,
                label: 'Shopping cart',
                onQuantityChange: onQuantityChange,
                onRemove: onRemove,
                onApplyCoupon: onApplyCoupon,
                onRemoveCoupon: onRemoveCoupon,
                appliedCouponCode: appliedCouponCode,
                onCheckout: onCheckout,
                onContinueShopping: onContinueShopping,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
