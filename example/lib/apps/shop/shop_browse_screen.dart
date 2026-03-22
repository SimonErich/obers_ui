import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/data/mock_shop.dart';

/// Product browse grid showing all products with a mini-cart at the top.
class ShopBrowseScreen extends StatelessWidget {
  const ShopBrowseScreen({
    required this.cartItems,
    required this.cartSummary,
    required this.onSelectProduct,
    required this.onAddToCart,
    required this.onViewCart,
    required this.onCheckout,
    super.key,
  });

  final List<OiCartItem> cartItems;
  final OiCartSummary cartSummary;
  final ValueChanged<OiProductData> onSelectProduct;
  final ValueChanged<OiProductData> onAddToCart;
  final VoidCallback onViewCart;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final bp = context.breakpoint;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mini cart row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const OiLabel.h3('Products'),
              OiMiniCart(
                items: cartItems,
                summary: cartSummary,
                label: 'Shopping cart',
                onViewCart: onViewCart,
                onCheckout: onCheckout,
              ),
            ],
          ),
          SizedBox(height: spacing.lg),
          // Product grid
          OiGrid(
            breakpoint: bp,
            columns: OiResponsive.breakpoints({
              OiBreakpoint.compact: 1,
              OiBreakpoint.medium: 2,
              OiBreakpoint.expanded: 3,
              OiBreakpoint.large: 4,
            }),
            gap: OiResponsive<double>(spacing.md),
            children: kProducts.map((product) {
              return OiProductCard(
                product: product,
                label: product.name,
                onTap: () => onSelectProduct(product),
                onAddToCart:
                    product.inStock ? () => onAddToCart(product) : null,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
