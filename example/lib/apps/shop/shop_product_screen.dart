import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

/// Product detail screen wrapping [OiShopProductDetail].
class ShopProductScreen extends StatelessWidget {
  const ShopProductScreen({
    required this.product,
    required this.onAddToCart,
    required this.onBack,
    super.key,
  });

  final OiProductData product;
  final ValueChanged<OiCartItem> onAddToCart;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OiButton.ghost(
            label: 'Back to Products',
            icon: OiIcons.chevronLeft,
            onTap: onBack,
          ),
          SizedBox(height: spacing.md),
          OiShopProductDetail(
            product: product,
            label: product.name,
            onAddToCart: (item) {
              onAddToCart(item);
              OiToast.show(
                context,
                message: '${product.name} added to cart',
                level: OiToastLevel.success,
              );
            },
            description: product.description != null
                ? OiLabel.body(product.description!)
                : null,
          ),
        ],
      ),
    );
  }
}
