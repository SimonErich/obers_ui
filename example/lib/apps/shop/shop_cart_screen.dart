import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

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

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: OiCartPanel(
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
        ),
      ),
    );
  }
}
