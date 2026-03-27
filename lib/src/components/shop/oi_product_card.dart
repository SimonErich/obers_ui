import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/display/oi_card.dart';
import 'package:obers_ui/src/components/display/oi_image.dart';
import 'package:obers_ui/src/components/feedback/oi_star_rating.dart';
import 'package:obers_ui/src/components/shop/oi_price_tag.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_product_data.dart';
import 'package:obers_ui/src/primitives/animation/oi_shimmer.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';
import 'package:obers_ui/src/primitives/layout/oi_column.dart';
import 'package:obers_ui/src/primitives/layout/oi_row.dart';

// Material Icons codepoints.
const IconData _kCartIcon = OiIcons.shoppingCart;
const IconData _kWishlistIcon = OiIcons.heart;
const IconData _kImageIcon = OiIcons.image;

/// The layout variant for an [OiProductCard].
///
/// {@category Components}
enum OiProductCardVariant {
  /// Image on top, details below. Used in grids.
  vertical,

  /// Image on the left, details on the right. Used in list views.
  horizontal,

  /// Condensed single-row layout for dense lists.
  compact,
}

/// A product display card for grid/list layouts showing image, name, price,
/// rating, and quick-action buttons.
///
/// Coverage: REQ-0029
///
/// Shows badges: "Sale" when [OiProductData.compareAtPrice] exists and is
/// greater than [OiProductData.price], "Out of Stock" when
/// [OiProductData.inStock] is `false`. Supports skeleton loading via
/// [OiShimmer] when [loading] is `true`.
///
/// Use [OiProductCard.horizontal] for list views with image on the left.
///
/// Composes [OiCard], [OiImage], [OiLabel], [OiPriceTag], [OiStarRating],
/// [OiBadge], [OiButton], [OiTappable].
///
/// {@category Components}
class OiProductCard extends StatelessWidget {
  /// Creates a product card with the given [variant].
  const OiProductCard({
    required this.product,
    required this.label,
    this.onTap,
    this.onAddToCart,
    this.onWishlist,
    this.showRating = true,
    this.showAddToCart = true,
    this.showWishlist = false,
    this.loading = false,
    this.variant = OiProductCardVariant.vertical,
    super.key,
  });

  // ── Private base constructor ──────────────────────────────────────────────

  const OiProductCard._({
    required this.product,
    required this.label,
    required this.variant,
    this.onTap,
    this.onAddToCart,
    this.onWishlist,
    this.showRating = true,
    this.showAddToCart = true,
    this.showWishlist = false,
    this.loading = false,
    super.key,
  });

  /// Creates a horizontal product card (image left, details right).
  const OiProductCard.horizontal({
    required OiProductData product,
    required String label,
    VoidCallback? onTap,
    VoidCallback? onAddToCart,
    VoidCallback? onWishlist,
    bool showRating = true,
    bool showAddToCart = true,
    bool showWishlist = false,
    bool loading = false,
    Key? key,
  }) : this._(
         product: product,
         label: label,
         onTap: onTap,
         onAddToCart: onAddToCart,
         onWishlist: onWishlist,
         showRating: showRating,
         showAddToCart: showAddToCart,
         showWishlist: showWishlist,
         loading: loading,
         variant: OiProductCardVariant.horizontal,
         key: key,
       );

  /// The product data to display.
  final OiProductData product;

  /// Accessibility label announced by screen readers.
  final String label;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  /// Called when the add-to-cart button is tapped.
  final VoidCallback? onAddToCart;

  /// Called when the wishlist button is tapped.
  final VoidCallback? onWishlist;

  /// Whether to show the star rating. Defaults to `true`.
  final bool showRating;

  /// Whether to show the add-to-cart button. Defaults to `true`.
  final bool showAddToCart;

  /// Whether to show the wishlist button. Defaults to `false`.
  final bool showWishlist;

  /// Whether to display a skeleton loading state.
  final bool loading;

  /// The layout variant.
  final OiProductCardVariant variant;

  /// Whether the product is on sale.
  bool get _isOnSale =>
      product.compareAtPrice != null && product.compareAtPrice! > product.price;

  /// Whether the product is out of stock.
  bool get _isOutOfStock => !product.inStock;

  // ── Shared builders ───────────────────────────────────────────────────────

  Widget _buildImage(BuildContext context, {double? width, double? height}) {
    if (product.imageUrl == null) {
      return OiShimmer(
        child: Container(
          width: width,
          height: height ?? 160,
          color: context.colors.surfaceSubtle,
          child: Center(
            child: Icon(_kImageIcon, size: 32, color: context.colors.textMuted),
          ),
        ),
      );
    }

    return OiImage(
      src: product.imageUrl!,
      alt: product.name,
      width: width,
      height: height ?? 160,
      fit: BoxFit.cover,
    );
  }

  Widget _buildBadges(BuildContext context) {
    final badges = <Widget>[];

    if (_isOnSale) {
      badges.add(
        const OiBadge.filled(
          label: 'Sale',
          color: OiBadgeColor.error,
          size: OiBadgeSize.small,
        ),
      );
    }

    if (_isOutOfStock) {
      badges.add(
        const OiBadge.filled(
          label: 'Out of Stock',
          color: OiBadgeColor.neutral,
          size: OiBadgeSize.small,
        ),
      );
    }

    if (badges.isEmpty) return const SizedBox.shrink();

    return Positioned(
      top: 8,
      left: 8,
      child: OiRow(
        breakpoint: context.breakpoint,
        gap: OiResponsive(context.spacing.xs),
        children: badges,
      ),
    );
  }

  Widget _buildDetails(BuildContext context) {
    final breakpoint = context.breakpoint;
    final sp = context.spacing;
    final isCompact = variant == OiProductCardVariant.compact;

    final children = <Widget>[
      OiLabel.bodyStrong(
        product.name,
        maxLines: isCompact ? 1 : 2,
        overflow: TextOverflow.ellipsis,
      ),
      OiPriceTag(
        price: product.price,
        label: 'Price for ${product.name}',
        compareAtPrice: product.compareAtPrice,
        currencyCode: product.currencyCode,
        size: isCompact ? OiPriceTagSize.small : OiPriceTagSize.medium,
      ),
    ];

    if (showRating && product.rating != null) {
      children.add(
        OiRow(
          breakpoint: breakpoint,
          gap: OiResponsive(sp.xs),
          children: [
            OiStarRating(
              value: product.rating!,
              readOnly: true,
              size: isCompact ? 14 : 16,
            ),
            if (product.reviewCount != null)
              OiLabel.small('(${product.reviewCount})'),
          ],
        ),
      );
    }

    if (!isCompact) {
      final actions = _buildActions(context);
      if (actions != null) children.add(actions);
    }

    return OiColumn(
      breakpoint: breakpoint,
      gap: OiResponsive(isCompact ? sp.xs : sp.sm),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget? _buildActions(BuildContext context) {
    final breakpoint = context.breakpoint;
    final sp = context.spacing;
    final actions = <Widget>[];

    if (showAddToCart) {
      actions.add(
        OiButton.primary(
          label: 'Add to Cart',
          icon: _kCartIcon,
          size: OiButtonSize.small,
          onTap: _isOutOfStock ? null : onAddToCart,
          enabled: !_isOutOfStock,
        ),
      );
    }

    if (showWishlist) {
      actions.add(
        OiButton.ghost(
          label: 'Wishlist',
          icon: _kWishlistIcon,
          size: OiButtonSize.small,
          onTap: onWishlist,
        ),
      );
    }

    if (actions.isEmpty) return null;

    return OiRow(
      breakpoint: breakpoint,
      gap: OiResponsive(sp.sm),
      children: actions,
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final sp = context.spacing;
    final breakpoint = context.breakpoint;

    final shimmerBlock = OiShimmer(
      child: Container(height: 160, color: context.colors.surfaceSubtle),
    );
    final shimmerLine = OiShimmer(
      child: Container(height: 14, color: context.colors.surfaceSubtle),
    );
    final shimmerShort = OiShimmer(
      child: Container(
        height: 14,
        width: 80,
        color: context.colors.surfaceSubtle,
      ),
    );

    return OiCard.flat(
      padding: EdgeInsets.zero,
      child: OiColumn(
        breakpoint: breakpoint,
        gap: OiResponsive(sp.sm),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [shimmerBlock, shimmerLine, shimmerShort],
      ),
    );
  }

  // ── Variant builders ──────────────────────────────────────────────────────

  Widget _buildVertical(BuildContext context) {
    final sp = context.spacing;

    return OiCard.flat(
      label: label,
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: Stack(
              children: [_buildImage(context), _buildBadges(context)],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(sp.sm),
            child: _buildDetails(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontal(BuildContext context) {
    final sp = context.spacing;
    final breakpoint = context.breakpoint;

    return OiCard.flat(
      label: label,
      onTap: onTap,
      padding: EdgeInsets.all(sp.sm),
      child: OiRow(
        breakpoint: breakpoint,
        gap: OiResponsive(sp.md),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                _buildImage(context, width: 120, height: 120),
                _buildBadges(context),
              ],
            ),
          ),
          Expanded(child: _buildDetails(context)),
        ],
      ),
    );
  }

  Widget _buildCompact(BuildContext context) {
    final sp = context.spacing;
    final breakpoint = context.breakpoint;

    return OiTappable(
      onTap: onTap,
      semanticLabel: label,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: sp.xs, horizontal: sp.sm),
        child: OiRow(
          breakpoint: breakpoint,
          gap: OiResponsive(sp.sm),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: _buildImage(context, width: 48, height: 48),
            ),
            Expanded(child: _buildDetails(context)),
            if (showAddToCart)
              OiButton.primary(
                label: 'Add',
                icon: _kCartIcon,
                size: OiButtonSize.small,
                onTap: _isOutOfStock ? null : onAddToCart,
                enabled: !_isOutOfStock,
              ),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (loading) return _buildSkeleton(context);

    switch (variant) {
      case OiProductCardVariant.vertical:
        return _buildVertical(context);
      case OiProductCardVariant.horizontal:
        return _buildHorizontal(context);
      case OiProductCardVariant.compact:
        return _buildCompact(context);
    }
  }
}
