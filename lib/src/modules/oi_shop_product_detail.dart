import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/display/oi_card.dart';
import 'package:obers_ui/src/components/feedback/oi_star_rating.dart';
import 'package:obers_ui/src/components/inputs/oi_select.dart';
import 'package:obers_ui/src/components/navigation/oi_accordion.dart';
import 'package:obers_ui/src/components/navigation/oi_tabs.dart';
import 'package:obers_ui/src/components/shop/oi_price_tag.dart';
import 'package:obers_ui/src/components/shop/oi_quantity_selector.dart';
import 'package:obers_ui/src/components/shop/oi_stock_badge.dart';
import 'package:obers_ui/src/components/shop/oi_wishlist_button.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_cart_item.dart';
import 'package:obers_ui/src/models/oi_product_data.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/layout/oi_column.dart';
import 'package:obers_ui/src/primitives/layout/oi_row.dart';

/// A complete product detail page layout showing gallery, title, price,
/// description, variant selectors, quantity, add to cart, and related info.
///
/// Coverage: REQ-0069
///
/// Composes [OiColumn]/[OiRow], [OiLabel], [OiPriceTag], [OiStarRating],
/// [OiBadge], [OiSelect], [OiQuantitySelector], [OiButton], [OiAccordion],
/// [OiTabs].
///
/// Desktop (≥840 dp): side-by-side (gallery left, info right).
/// Mobile (<840 dp): stacked (gallery top, info below).
///
/// {@category Modules}
class OiShopProductDetail extends StatefulWidget {
  /// Creates an [OiShopProductDetail].
  const OiShopProductDetail({
    required this.product,
    required this.label,
    this.onAddToCart,
    this.onVariantChange,
    this.onQuantityChange,
    this.onWishlist,
    this.wishlisted = false,
    this.selectedVariant,
    this.quantity = 1,
    this.description,
    this.reviews,
    this.specifications,
    this.related,
    this.onRelatedProductTap,
    super.key,
  });

  /// The product to display.
  final OiProductData product;

  /// Accessibility label announced by screen readers.
  final String label;

  /// Called when the user taps "Add to Cart".
  final ValueChanged<OiCartItem>? onAddToCart;

  /// Called when the user selects a different variant.
  final ValueChanged<OiProductVariant>? onVariantChange;

  /// Called when the user changes the quantity.
  final ValueChanged<int>? onQuantityChange;

  /// Called when the user taps the wishlist button.
  final VoidCallback? onWishlist;

  /// Whether the product is currently in the wishlist.
  final bool wishlisted;

  /// The currently selected variant, if any.
  final OiProductVariant? selectedVariant;

  /// The current quantity. Defaults to `1`.
  final int quantity;

  /// An optional description widget rendered in the content tabs.
  final Widget? description;

  /// An optional reviews widget rendered in the content tabs.
  final Widget? reviews;

  /// An optional specifications widget rendered in the content tabs.
  final Widget? specifications;

  /// Optional related products to display below the main content.
  final List<OiProductData>? related;

  /// Called when the user taps a related product.
  final ValueChanged<OiProductData>? onRelatedProductTap;

  @override
  State<OiShopProductDetail> createState() => _OiShopProductDetailState();
}

class _OiShopProductDetailState extends State<OiShopProductDetail> {
  late OiProductVariant? _selectedVariant;
  late int _quantity;
  int _galleryIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedVariant = widget.selectedVariant;
    _quantity = widget.quantity;
  }

  @override
  void didUpdateWidget(OiShopProductDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedVariant != oldWidget.selectedVariant) {
      _selectedVariant = widget.selectedVariant;
    }
    if (widget.quantity != oldWidget.quantity) {
      _quantity = widget.quantity;
    }
  }

  // ---------------------------------------------------------------------------
  // Derived data
  // ---------------------------------------------------------------------------

  double get _effectivePrice => _selectedVariant?.price ?? widget.product.price;

  bool get _isInStock => _selectedVariant?.inStock ?? widget.product.inStock;

  List<String> get _galleryImages {
    final images = <String>[];
    // Add variant-specific image first if available.
    if (_selectedVariant?.imageUrl != null) {
      images.add(_selectedVariant!.imageUrl!);
    }
    // Add primary product image.
    if (widget.product.imageUrl != null) {
      images.add(widget.product.imageUrl!);
    }
    // Add gallery images.
    images.addAll(widget.product.imageUrls);
    // Deduplicate while preserving order.
    final seen = <String>{};
    return images.where(seen.add).toList();
  }

  // ---------------------------------------------------------------------------
  // Callbacks
  // ---------------------------------------------------------------------------

  void _handleVariantChange(OiProductVariant variant) {
    setState(() {
      _selectedVariant = variant;
      // Reset gallery to show variant image.
      _galleryIndex = 0;
    });
    widget.onVariantChange?.call(variant);
  }

  void _handleQuantityChange(int qty) {
    setState(() {
      _quantity = qty;
    });
    widget.onQuantityChange?.call(qty);
  }

  void _handleAddToCart() {
    final item = OiCartItem(
      productKey: widget.product.key,
      name: widget.product.name,
      unitPrice: _effectivePrice,
      variantKey: _selectedVariant?.key,
      variantLabel: _selectedVariant?.label,
      quantity: _quantity,
      imageUrl: _galleryImages.isNotEmpty ? _galleryImages.first : null,
    );
    widget.onAddToCart?.call(item);
  }

  // ---------------------------------------------------------------------------
  // Product gallery
  // ---------------------------------------------------------------------------

  Widget _buildProductGallery(BuildContext context) {
    return _OiProductGallery(
      imageUrls: _galleryImages,
      selectedIndex: _galleryIndex,
      onIndexChange: (i) {
        setState(() {
          _galleryIndex = i;
        });
      },
      label: '${widget.product.name} gallery',
    );
  }

  // ---------------------------------------------------------------------------
  // Product info
  // ---------------------------------------------------------------------------

  Widget _buildProductInfo(BuildContext context) {
    final sp = context.spacing;
    final breakpoint = context.breakpoint;
    final colors = context.colors;

    return OiColumn(
      breakpoint: breakpoint,
      gap: OiResponsive(sp.sm),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title.
        OiLabel.h2(widget.product.name),

        // Rating.
        if (widget.product.rating != null)
          OiRow(
            breakpoint: breakpoint,
            gap: OiResponsive(sp.xs),
            children: [
              OiStarRating(
                readOnly: true,
                value: widget.product.rating!,
                label: '${widget.product.rating} out of 5 stars',
              ),
              if (widget.product.reviewCount != null)
                OiLabel.small(
                  '(${widget.product.reviewCount} reviews)',
                  color: colors.textMuted,
                ),
            ],
          ),
        SizedBox(height: sp.sm),

        // Price, stock badge, and wishlist.
        Row(
          children: [
            OiPriceTag(
              size: OiPriceTagSize.large,
              price: _effectivePrice,
              label: 'Product price',
              compareAtPrice: widget.product.compareAtPrice,
              currencyCode: widget.product.currencyCode,
            ),
            const Spacer(),
            if (!_isInStock)
              const OiBadge.soft(label: 'Out of Stock')
            else
              OiStockBadge.fromCount(
                stockCount: _selectedVariant?.stockCount,
                label: 'Stock status',
              ),
            SizedBox(width: sp.sm),
            OiWishlistButton(
              label: 'Toggle wishlist for ${widget.product.name}',
              active: widget.wishlisted,
              onToggle: widget.onWishlist,
            ),
          ],
        ),

        // SKU.
        if (widget.product.sku != null)
          OiLabel.small('SKU: ${widget.product.sku}', color: colors.textMuted),

        // Variant selectors.
        if (widget.product.variants.isNotEmpty) _buildVariantSelectors(context),

        // Quantity.
        SizedBox(height: sp.xs),
        OiQuantitySelector(
          value: _quantity,
          label: 'Quantity',
          onChange: _handleQuantityChange,
          max: _selectedVariant?.stockCount ?? 99,
          disabled: !_isInStock,
        ),

        // Action buttons.
        SizedBox(height: sp.sm),
        OiRow(
          breakpoint: breakpoint,
          gap: OiResponsive(sp.sm),
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OiButton.primary(
              label: 'Add to Cart',
              onTap: _isInStock ? _handleAddToCart : null,
            ),
            if (widget.onWishlist != null)
              OiButton.outline(label: 'Wishlist', onTap: widget.onWishlist),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Variant selectors
  // ---------------------------------------------------------------------------

  Widget _buildVariantSelectors(BuildContext context) {
    final variants = widget.product.variants;
    // Group variants by attribute keys.
    final attributeKeys = <String>{};
    for (final v in variants) {
      attributeKeys.addAll(v.attributes.keys);
    }

    if (attributeKeys.isEmpty) {
      // Simple variant list without attributes.
      return OiSelect<Object>(
        options: variants
            .map(
              (v) => OiSelectOption<Object>(
                value: v.key,
                label: v.label,
                enabled: v.inStock,
              ),
            )
            .toList(),
        value: _selectedVariant?.key,
        label: 'Variant',
        placeholder: 'Select variant',
        onChanged: (key) {
          final variant = variants.firstWhere((v) => v.key == key);
          _handleVariantChange(variant);
        },
      );
    }

    // One selector per attribute group.
    final sp = context.spacing;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final attrKey in attributeKeys) ...[
          SizedBox(height: sp.xs),
          OiSelect<String>(
            options: variants
                .where((v) => v.attributes.containsKey(attrKey))
                .map(
                  (v) => OiSelectOption<String>(
                    value: v.attributes[attrKey]!,
                    label: v.attributes[attrKey]!,
                    enabled: v.inStock,
                  ),
                )
                .toList(),
            value: _selectedVariant?.attributes[attrKey],
            label: attrKey,
            placeholder: 'Select $attrKey',
            onChanged: (val) {
              // Find the matching variant.
              final match = variants.where((v) {
                return v.attributes[attrKey] == val;
              }).firstOrNull;
              if (match != null) {
                _handleVariantChange(match);
              }
            },
          ),
        ],
      ],
    );
  }

  int _selectedTabIndex = 0;

  // ---------------------------------------------------------------------------
  // Content tabs
  // ---------------------------------------------------------------------------

  Widget _buildContentTabs(BuildContext context) {
    final tabItems = <OiTabItem>[];
    final tabContents = <Widget>[];

    if (widget.description != null) {
      tabItems.add(const OiTabItem(label: 'Description'));
      tabContents.add(widget.description!);
    }
    if (widget.specifications != null) {
      tabItems.add(const OiTabItem(label: 'Specifications'));
      tabContents.add(widget.specifications!);
    }
    if (widget.reviews != null) {
      tabItems.add(const OiTabItem(label: 'Reviews'));
      tabContents.add(widget.reviews!);
    }
    if (tabItems.isEmpty) return const SizedBox.shrink();

    final safeTab = _selectedTabIndex.clamp(0, tabItems.length - 1);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OiTabs(
          tabs: tabItems,
          selectedIndex: safeTab,
          onSelected: (i) => setState(() => _selectedTabIndex = i),
        ),
        SizedBox(height: context.spacing.sm),
        tabContents[safeTab],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Layouts
  // ---------------------------------------------------------------------------

  Widget _buildDesktopLayout(BuildContext context) {
    final sp = context.spacing;
    final breakpoint = context.breakpoint;

    return OiColumn(
      breakpoint: breakpoint,
      gap: OiResponsive(sp.lg),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildProductGallery(context)),
            SizedBox(width: sp.xl),
            Expanded(child: _buildProductInfo(context)),
          ],
        ),
        _buildContentTabs(context),
        if (widget.related != null && widget.related!.isNotEmpty)
          _buildRelatedProducts(context),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final sp = context.spacing;
    final breakpoint = context.breakpoint;

    return OiColumn(
      breakpoint: breakpoint,
      gap: OiResponsive(sp.md),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildProductGallery(context),
        _buildProductInfo(context),
        _buildContentTabs(context),
        if (widget.related != null && widget.related!.isNotEmpty)
          _buildRelatedProducts(context),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Related products
  // ---------------------------------------------------------------------------

  Widget _buildRelatedProducts(BuildContext context) {
    final sp = context.spacing;
    final breakpoint = context.breakpoint;
    final colors = context.colors;

    return OiColumn(
      breakpoint: breakpoint,
      gap: OiResponsive(sp.sm),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const OiLabel.h3('Related Products'),
        SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.related!.length,
            separatorBuilder: (_, _) => SizedBox(width: sp.sm),
            itemBuilder: (context, index) {
              final product = widget.related![index];
              return GestureDetector(
                onTap: widget.onRelatedProductTap != null
                    ? () => widget.onRelatedProductTap!(product)
                    : null,
                child: SizedBox(
                  width: 160,
                  child: OiCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Placeholder for product image.
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: colors.surfaceSubtle,
                            borderRadius: context.radius.sm,
                          ),
                          child: product.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: context.radius.sm,
                                  child: Image.network(
                                    product.imageUrl!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (_, _, _) =>
                                        const SizedBox.expand(),
                                  ),
                                )
                              : const SizedBox.expand(),
                        ),
                        SizedBox(height: sp.xs),
                        OiLabel.small(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: sp.xs),
                        OiPriceTag(
                          price: product.price,
                          label: 'Price',
                          currencyCode: product.currencyCode,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final breakpoint = context.breakpoint;
    final isDesktop = breakpoint.compareTo(OiBreakpoint.expanded) >= 0;

    return Semantics(
      label: widget.label,
      child: isDesktop
          ? _buildDesktopLayout(context)
          : _buildMobileLayout(context),
    );
  }
}

// ── Product Gallery ─────────────────────────────────────────────────────────

/// An image carousel with thumbnail strip for product images.
class _OiProductGallery extends StatelessWidget {
  const _OiProductGallery({
    required this.imageUrls,
    required this.selectedIndex,
    required this.label,
    this.onIndexChange,
  });

  /// The list of image URLs to display.
  final List<String> imageUrls;

  /// The index of the currently displayed image.
  final int selectedIndex;

  /// Called when the user taps a thumbnail.
  final ValueChanged<int>? onIndexChange;

  /// Accessibility label for the gallery.
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sp = context.spacing;

    if (imageUrls.isEmpty) {
      return Semantics(
        label: label,
        child: Container(
          height: 400,
          decoration: BoxDecoration(
            color: colors.surfaceSubtle,
            borderRadius: context.radius.md,
          ),
          child: const Center(child: OiLabel.body('No image available')),
        ),
      );
    }

    final safeIndex = selectedIndex.clamp(0, imageUrls.length - 1);

    return Semantics(
      label: label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main image.
          ClipRRect(
            borderRadius: context.radius.md,
            child: Container(
              height: 400,
              width: double.infinity,
              color: colors.surfaceSubtle,
              child: Image.network(
                imageUrls[safeIndex],
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Center(
                  child: OiLabel.body(
                    'Image not available',
                    color: colors.textMuted,
                  ),
                ),
              ),
            ),
          ),

          // Thumbnail strip.
          if (imageUrls.length > 1) ...[
            SizedBox(height: sp.sm),
            SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: imageUrls.length,
                separatorBuilder: (_, _) => SizedBox(width: sp.xs),
                itemBuilder: (context, index) {
                  final isSelected = index == safeIndex;
                  return GestureDetector(
                    onTap: () => onIndexChange?.call(index),
                    child: Semantics(
                      label:
                          'Product image ${index + 1} of ${imageUrls.length}',
                      selected: isSelected,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? colors.primary.base
                                : colors.border,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: context.radius.sm,
                        ),
                        child: ClipRRect(
                          borderRadius: context.radius.sm,
                          child: Image.network(
                            imageUrls[index],
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                Container(color: colors.surfaceSubtle),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
