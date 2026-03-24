import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/data/mock_shop.dart';

/// Product browse grid with sidebar filters, sort, and command bar search.
class ShopBrowseScreen extends StatefulWidget {
  const ShopBrowseScreen({
    required this.cartItems,
    required this.cartSummary,
    required this.onSelectProduct,
    required this.onAddToCart,
    required this.onViewCart,
    required this.onCheckout,
    required this.wishlistCount,
    required this.onViewWishlist,
    super.key,
  });

  final List<OiCartItem> cartItems;
  final OiCartSummary cartSummary;
  final ValueChanged<OiProductData> onSelectProduct;
  final ValueChanged<OiProductData> onAddToCart;
  final VoidCallback onViewCart;
  final VoidCallback onCheckout;
  final int wishlistCount;
  final VoidCallback onViewWishlist;

  @override
  State<ShopBrowseScreen> createState() => _ShopBrowseScreenState();
}

class _ShopBrowseScreenState extends State<ShopBrowseScreen> {
  OiProductFilterData _filterData = const OiProductFilterData();
  OiSortOption _currentSort = const OiSortOption(
    field: 'name',
    label: 'Name',
  );

  late List<OiProductData> _displayedProducts = List.of(kProducts);

  static const _availableCategories = [
    'food',
    'clothing',
    'footwear',
    'beverage',
    'coffee',
    'lifestyle',
  ];

  void _applyFiltersAndSort() {
    var result = List.of(kProducts);

    // Price range
    if (_filterData.minPrice != null) {
      result = result.where((p) => p.price >= _filterData.minPrice!).toList();
    }
    if (_filterData.maxPrice != null) {
      result = result.where((p) => p.price <= _filterData.maxPrice!).toList();
    }

    // Categories
    if (_filterData.categories.isNotEmpty) {
      result =
          result
              .where(
                (p) => p.tags.any((t) => _filterData.categories.contains(t)),
              )
              .toList();
    }

    // Rating
    if (_filterData.minRating != null) {
      result =
          result
              .where(
                (p) => (p.rating ?? 0) >= _filterData.minRating!,
              )
              .toList();
    }

    // In stock only
    if (_filterData.inStockOnly) {
      result = result.where((p) => p.inStock).toList();
    }

    // Sort
    switch (_currentSort.field) {
      case 'price':
        result.sort((a, b) => a.price.compareTo(b.price));
      case 'rating':
        result.sort(
          (a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0),
        );
      case 'name':
      default:
        result.sort((a, b) => a.name.compareTo(b.name));
    }

    if (_currentSort.direction == OiSortDirection.desc) {
      result = result.reversed.toList();
    }

    _displayedProducts = result;
  }

  void _openCommandBar() {
    late final OiOverlayHandle handle;
    handle = OiOverlays.of(context).show(
      label: 'Product search',
      builder: (_) => OiCommandBar(
        label: 'Search products',
        onDismiss: () => handle.dismiss(),
        commands:
            kProducts
                .map(
                  (p) => OiCommand(
                    id: p.key,
                    label: p.name,
                    description:
                        '${p.currencyCode} ${p.price.toStringAsFixed(2)}',
                    category: 'Products',
                    onExecute: () {
                      handle.dismiss();
                      widget.onSelectProduct(p);
                    },
                  ),
                )
                .toList(),
      ),
      zOrder: OiOverlayZOrder.panel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final bp = context.breakpoint;
    final isCompact = bp == OiBreakpoint.compact;

    _applyFiltersAndSort();

    final grid = SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row: title, search, sort, mini cart
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const OiLabel.h3('Products'),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OiIconButton(
                    icon: OiIcons.search,
                    semanticLabel: 'Search products',
                    onTap: _openCommandBar,
                  ),
                  SizedBox(width: spacing.sm),
                  OiSortButton(
                    options: const [
                      OiSortOption(field: 'name', label: 'Name'),
                      OiSortOption(field: 'price', label: 'Price'),
                      OiSortOption(field: 'rating', label: 'Rating'),
                    ],
                    currentSort: _currentSort,
                    label: 'Sort products',
                    onSortChange: (sort) =>
                        setState(() => _currentSort = sort),
                  ),
                  SizedBox(width: spacing.sm),
                  // Wishlist button with badge count
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
            ],
          ),
          SizedBox(height: spacing.lg),

          // Empty state or product grid
          if (_displayedProducts.isEmpty)
            const OiEmptyState(
              title: 'No products match your filters',
              description: 'Try adjusting your filter criteria.',
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
              children:
                  _displayedProducts.map((product) {
                    return OiProductCard(
                      product: product,
                      label: product.name,
                      onTap: () => widget.onSelectProduct(product),
                      onAddToCart: product.inStock
                          ? () => widget.onAddToCart(product)
                          : null,
                    );
                  }).toList(),
            ),
        ],
      ),
    );

    // On compact screens, skip the split pane
    if (isCompact) return grid;

    return OiSplitPane(
      leading: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.md),
        child: OiProductFilters(
          label: 'Product filters',
          value: _filterData,
          onChanged: (data) => setState(() => _filterData = data),
          availableCategories: _availableCategories,
          priceRangeMax: 400,
        ),
      ),
      trailing: grid,
      initialRatio: 0.22,
      minRatio: 0.15,
      maxRatio: 0.35,
    );
  }
}
