import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/data/mock_shop.dart';

/// Product detail screen wrapping [OiShopProductDetail].
class ShopProductScreen extends StatefulWidget {
  const ShopProductScreen({
    required this.product,
    required this.onAddToCart,
    required this.onBack,
    required this.isWishlisted,
    required this.onWishlistToggle,
    super.key,
  });

  final OiProductData product;
  final ValueChanged<OiCartItem> onAddToCart;
  final VoidCallback onBack;
  final bool isWishlisted;
  final VoidCallback onWishlistToggle;

  @override
  State<ShopProductScreen> createState() => _ShopProductScreenState();
}

class _ShopProductScreenState extends State<ShopProductScreen> {
  // Track thumbs state per review index.
  final Map<int, OiThumbsValue> _thumbsState = {};

  Widget _buildReviewsWidget(BuildContext context) {
    final reviews = kProductReviews[widget.product.key];
    if (reviews == null || reviews.isEmpty) {
      return const OiLabel.body('No reviews yet.');
    }

    final spacing = context.spacing;
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        OiLabel.caption(
          '${reviews.length} review${reviews.length == 1 ? '' : 's'}',
        ),
        SizedBox(height: spacing.sm),
        for (var i = 0; i < reviews.length; i++) ...[
          if (i > 0) SizedBox(height: spacing.md),
          OiCard(
            child: Padding(
              padding: EdgeInsets.all(spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header: avatar + name + rating
                  Row(
                    children: [
                      OiAvatar(
                        semanticLabel: reviews[i].reviewerName,
                        initials: _initials(reviews[i].reviewerName),
                        size: OiAvatarSize.sm,
                      ),
                      SizedBox(width: spacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OiLabel.body(reviews[i].reviewerName),
                            OiRelativeTime(dateTime: reviews[i].date),
                          ],
                        ),
                      ),
                      OiStarRating(
                        value: reviews[i].rating,
                        readOnly: true,
                        size: 18,
                        label:
                            '${reviews[i].rating} out of 5 stars',
                      ),
                    ],
                  ),
                  SizedBox(height: spacing.sm),
                  // Review text
                  OiLabel.body(
                    reviews[i].text,
                    color: colors.textMuted,
                  ),
                  SizedBox(height: spacing.sm),
                  // Helpful thumbs
                  Row(
                    children: [
                      OiLabel.caption(
                        'Was this helpful?',
                        color: colors.textMuted,
                      ),
                      SizedBox(width: spacing.sm),
                      OiThumbs(
                        label: 'Rate review by ${reviews[i].reviewerName}',
                        value: _thumbsState[i] ?? OiThumbsValue.none,
                        showCount: true,
                        upCount: reviews[i].helpfulCount,
                        downCount: reviews[i].unhelpfulCount,
                        onChanged: (value) {
                          setState(() {
                            _thumbsState[i] = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _initials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final product = widget.product;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          OiButton.ghost(
            label: 'Back to Products',
            icon: OiIcons.chevronLeft,
            onTap: widget.onBack,
          ),
          SizedBox(height: spacing.md),

          // Quick info strip: price, rating, stock, wishlist
          Wrap(
            spacing: spacing.md,
            runSpacing: spacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OiPriceTag(
                price: product.price,
                compareAtPrice: product.compareAtPrice,
                currencyCode: product.currencyCode,
                label: 'Product price',
                size: OiPriceTagSize.large,
              ),
              if (product.rating != null)
                OiStarRating(
                  value: product.rating!,
                  readOnly: true,
                  label: '${product.rating} out of 5 stars',
                ),
              OiStockBadge.fromCount(
                stockCount: product.stockCount,
                label: 'Stock status',
              ),
              OiWishlistButton(
                label: 'Toggle wishlist for ${product.name}',
                active: widget.isWishlisted,
                onToggle: widget.onWishlistToggle,
              ),
            ],
          ),
          SizedBox(height: spacing.md),

          // Product detail with related products and reviews
          OiShopProductDetail(
            product: product,
            label: product.name,
            onAddToCart: (item) {
              widget.onAddToCart(item);
              OiToast.show(
                context,
                message: '${product.name} added to cart',
                level: OiToastLevel.success,
              );
            },
            description: product.description != null
                ? OiMarkdown(data: product.description!)
                : null,
            related: getRelatedProducts(product.key),
            reviews: _buildReviewsWidget(context),
          ),
        ],
      ),
    );
  }
}
