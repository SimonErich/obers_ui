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
    required this.onSelectProduct,
    required this.cartItems,
    required this.cartSummary,
    required this.onViewCart,
    required this.onCheckout,
    required this.wishlistCount,
    required this.onViewWishlist,
    super.key,
  });

  final OiProductData product;
  final ValueChanged<OiCartItem> onAddToCart;
  final VoidCallback onBack;
  final bool isWishlisted;
  final VoidCallback onWishlistToggle;
  final ValueChanged<OiProductData> onSelectProduct;
  final List<OiCartItem> cartItems;
  final OiCartSummary cartSummary;
  final VoidCallback onViewCart;
  final VoidCallback onCheckout;
  final int wishlistCount;
  final VoidCallback onViewWishlist;

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
          // Navigation bar: back link + wishlist & cart icons
          Row(
            children: [
              OiTappable(
                onTap: widget.onBack,
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
                        'Wishlist (${widget.wishlistCount} items)',
                    onTap: widget.onViewWishlist,
                  ),
                  if (widget.wishlistCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: OiBadge.filled(
                        label: '${widget.wishlistCount}',
                        color: OiBadgeColor.error,
                        size: OiBadgeSize.small,
                      ),
                    ),
                ],
              ),
              SizedBox(width: spacing.sm),
              OiMiniCart(
                items: widget.cartItems,
                summary: widget.cartSummary,
                label: 'Shopping cart',
                onViewCart: widget.onViewCart,
                onCheckout: widget.onCheckout,
              ),
            ],
          ),
          SizedBox(height: spacing.lg),

          // Product detail with related products and reviews
          OiShopProductDetail(
            product: product,
            label: product.name,
            isWishlisted: widget.isWishlisted,
            onWishlist: widget.onWishlistToggle,
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
            onRelatedProductTap: widget.onSelectProduct,
            reviews: _buildReviewsWidget(context),
          ),
        ],
      ),
    );
  }
}
