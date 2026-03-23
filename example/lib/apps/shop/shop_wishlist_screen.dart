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
          // Back button
          OiButton.ghost(
            label: 'Back to Products',
            icon: OiIcons.chevronLeft,
            onTap: onBack,
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
