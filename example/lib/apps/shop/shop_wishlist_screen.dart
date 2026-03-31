import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

/// Wishlist screen showing wishlisted products in a grid.
class ShopWishlistScreen extends StatelessWidget {
  const ShopWishlistScreen({
    required this.wishlistedKeys,
    required this.products,
    required this.onRemoveFromWishlist,
    required this.onSelectProduct,
    required this.onBack,
    required this.cartItems,
    required this.cartSummary,
    required this.onViewCart,
    required this.onCheckout,
    required this.onCartQuantityChange,
    super.key,
  });

  /// The set of wishlisted product keys.
  final Set<Object> wishlistedKeys;

  /// All available products.
  final List<OiProductData> products;

  /// Called when the user removes a product from the wishlist.
  final ValueChanged<Object> onRemoveFromWishlist;

  /// Called when the user taps a product card.
  final ValueChanged<OiProductData> onSelectProduct;

  /// Called when the user taps the back button.
  final VoidCallback onBack;

  /// Cart items for the mini cart.
  final List<OiCartItem> cartItems;

  /// Cart summary for the mini cart.
  final OiCartSummary cartSummary;

  /// Called when the user taps view cart.
  final VoidCallback onViewCart;

  /// Called when the user taps checkout.
  final VoidCallback onCheckout;

  /// Called when the user changes the quantity of a cart item.
  final void Function(({Object productKey, int quantity})) onCartQuantityChange;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final bp = context.breakpoint;

    final wishlistedProducts =
        products.where((p) => wishlistedKeys.contains(p.key)).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Navigation bar: back link + cart icon
          Row(
            children: [
              OiTappable(
                onTap: onBack,
                semanticLabel: 'Back to Products',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      OiIcons.chevronLeft,
                      size: 16,
                      color: context.colors.accent.base,
                    ),
                    const SizedBox(width: 4),
                    const OiLabel.link('Back to Products'),
                  ],
                ),
              ),
              const Spacer(),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  OiIconButton(
                    icon: OiIcons.heart,
                    semanticLabel:
                        'Wishlist (${wishlistedKeys.length} items)',
                    onTap: () {},
                  ),
                  if (wishlistedKeys.isNotEmpty)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: OiBadge.filled(
                        label: '${wishlistedKeys.length}',
                        color: OiBadgeColor.error,
                        size: OiBadgeSize.small,
                      ),
                    ),
                ],
              ),
              SizedBox(width: spacing.sm),
              OiMiniCart(
                items: cartItems,
                summary: cartSummary,
                label: 'Shopping cart',
                onViewCart: onViewCart,
                onCheckout: onCheckout,
                onQuantityChange: onCartQuantityChange,
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          Row(
            children: [
              const OiLabel.h3('Wishlist'),
              SizedBox(width: spacing.sm),
              if (wishlistedProducts.isNotEmpty)
                OiBadge.soft(
                  label: '${wishlistedProducts.length}',
                ),
            ],
          ),
          SizedBox(height: spacing.lg),
          if (wishlistedProducts.isEmpty)
            const OiEmptyState(
              icon: OiIcons.heart,
              title: 'Your wishlist is empty',
              description:
                  'Browse products and tap the heart icon to save items '
                  'you love for later.',
            )
          else
            OiGrid(
              breakpoint: bp,
              columns: OiResponsive.breakpoints({
                OiBreakpoint.compact: 1,
                OiBreakpoint.medium: 2,
                OiBreakpoint.expanded: 3,
                OiBreakpoint.large: 4,
              }),
              gap: OiResponsive<double>(spacing.md),
              children: wishlistedProducts.map((product) {
                return OiProductCard(
                  product: product,
                  label: product.name,
                  onTap: () => onSelectProduct(product),
                  showWishlist: true,
                  onWishlist: () => onRemoveFromWishlist(product.key),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
