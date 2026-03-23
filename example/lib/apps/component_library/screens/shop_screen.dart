import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_example/apps/component_library/shared/component_showcase_section.dart';

/// Showcase screen for shop / e-commerce widgets.
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _quantity = 1;
  bool _wishlisted = false;

  static const _sampleProduct = OiProductData(
    key: 'alpine-jacket',
    name: 'Alpine Jacket',
    price: 199.99,
    description: 'Premium waterproof jacket for mountain adventures.',
    rating: 4.5,
    reviewCount: 128,
  );

  static const _saleProduct = OiProductData(
    key: 'trail-boots',
    name: 'Trail Boots',
    price: 129.99,
    compareAtPrice: 179.99,
    description: 'Durable hiking boots with ankle support.',
    rating: 4.2,
    reviewCount: 86,
  );

  static const _outOfStockProduct = OiProductData(
    key: 'summit-pack',
    name: 'Summit Backpack',
    price: 89.99,
    description: 'Lightweight 40L backpack for day hikes.',
    inStock: false,
    rating: 4.8,
    reviewCount: 214,
  );

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── OiProductCard ─────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Product Card',
            widgetName: 'OiProductCard',
            description:
                'A product display card showing image, name, price, rating, '
                'and quick-action buttons. Supports vertical, horizontal, '
                'and compact layouts.',
            examples: [
              ComponentExample(
                title: 'Vertical Cards',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: 200,
                      child: OiProductCard(
                        product: _sampleProduct,
                        label: 'Alpine Jacket product card',
                        onTap: () {},
                        onAddToCart: () {},
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: OiProductCard(
                        product: _saleProduct,
                        label: 'Trail Boots product card',
                        onTap: () {},
                        onAddToCart: () {},
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: OiProductCard(
                        product: _outOfStockProduct,
                        label: 'Summit Backpack product card',
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
              ComponentExample(
                title: 'Horizontal Card',
                child: OiProductCard.horizontal(
                  product: _sampleProduct,
                  label: 'Alpine Jacket horizontal card',
                  onTap: () {},
                  onAddToCart: () {},
                ),
              ),
            ],
          ),

          // ── OiPriceTag ────────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Price Tag',
            widgetName: 'OiPriceTag',
            description:
                'A formatted price display with optional compare-at '
                '(strikethrough) price and currency symbol.',
            examples: [
              ComponentExample(
                title: 'Regular & Discounted',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OiPriceTag(
                      price: 49.99,
                      label: 'Regular price',
                      currencyCode: 'USD',
                    ),
                    OiPriceTag(
                      price: 49.99,
                      compareAtPrice: 79.99,
                      label: 'Discounted price',
                      currencyCode: 'USD',
                    ),
                    OiPriceTag(
                      price: 0,
                      label: 'Free item',
                      currencyCode: 'USD',
                    ),
                  ],
                ),
              ),
              ComponentExample(
                title: 'Sizes',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OiPriceTag(
                      price: 29.99,
                      label: 'Small price',
                      size: OiPriceTagSize.small,
                    ),
                    OiPriceTag(
                      price: 29.99,
                      label: 'Medium price',
                    ),
                    OiPriceTag(
                      price: 29.99,
                      label: 'Large price',
                      size: OiPriceTagSize.large,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── OiStockBadge ──────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Stock Badge',
            widgetName: 'OiStockBadge',
            description:
                'A colored badge indicating product availability: green for '
                'in stock, amber for low stock, red for out of stock.',
            examples: [
              ComponentExample(
                title: 'Stock Levels',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OiStockBadge.fromCount(
                      stockCount: 15,
                      label: 'In stock badge',
                    ),
                    OiStockBadge.fromCount(
                      stockCount: 3,
                      label: 'Low stock badge',
                    ),
                    OiStockBadge.fromCount(
                      stockCount: 0,
                      label: 'Out of stock badge',
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── OiOrderStatusBadge ────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Order Status Badge',
            widgetName: 'OiOrderStatusBadge',
            description:
                'A badge displaying the current lifecycle status of an order '
                'with semantic colors.',
            examples: [
              ComponentExample(
                title: 'Order Statuses',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OiOrderStatusBadge(
                      status: OiOrderStatus.pending,
                      label: 'Pending order',
                    ),
                    OiOrderStatusBadge(
                      status: OiOrderStatus.confirmed,
                      label: 'Confirmed order',
                    ),
                    OiOrderStatusBadge(
                      status: OiOrderStatus.processing,
                      label: 'Processing order',
                    ),
                    OiOrderStatusBadge(
                      status: OiOrderStatus.shipped,
                      label: 'Shipped order',
                    ),
                    OiOrderStatusBadge(
                      status: OiOrderStatus.delivered,
                      label: 'Delivered order',
                    ),
                    OiOrderStatusBadge(
                      status: OiOrderStatus.cancelled,
                      label: 'Cancelled order',
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── OiCartItemRow ─────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Cart Item Row',
            widgetName: 'OiCartItemRow',
            description:
                'A single line item row for the shopping cart showing '
                'thumbnail, name, quantity selector, line total, and '
                'remove button.',
            examples: [
              ComponentExample(
                title: 'Cart Items',
                child: Column(
                  children: [
                    OiCartItemRow(
                      item: const OiCartItem(
                        productKey: 'alpine-jacket',
                        name: 'Alpine Jacket',
                        unitPrice: 199.99,
                        quantity: 2,
                      ),
                      label: 'Alpine Jacket cart item',
                      onQuantityChange: (_) {},
                      onRemove: () {},
                    ),
                    OiCartItemRow(
                      item: const OiCartItem(
                        productKey: 'trail-boots',
                        name: 'Trail Boots',
                        unitPrice: 129.99,
                        variantLabel: 'Brown / Size 10',
                      ),
                      label: 'Trail Boots cart item',
                      onQuantityChange: (_) {},
                      onRemove: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── OiQuantitySelector ────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Quantity Selector',
            widgetName: 'OiQuantitySelector',
            description:
                'A compact, touch-friendly number stepper for product '
                'quantities with min/max boundaries.',
            examples: [
              ComponentExample(
                title: 'Interactive',
                child: OiQuantitySelector(
                  value: _quantity,
                  label: 'Product quantity',
                  onChange: (value) => setState(() => _quantity = value),
                ),
              ),
              const ComponentExample(
                title: 'Disabled',
                child: OiQuantitySelector(
                  value: 3,
                  label: 'Disabled quantity',
                  disabled: true,
                ),
              ),
            ],
          ),

          // ── OiWishlistButton ──────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Wishlist Button',
            widgetName: 'OiWishlistButton',
            description:
                'A heart toggle button for adding or removing a product '
                'from a wishlist. Filled heart when active.',
            examples: [
              ComponentExample(
                title: 'Interactive Toggle',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OiWishlistButton(
                      active: _wishlisted,
                      label: 'Toggle wishlist',
                      onToggle: () =>
                          setState(() => _wishlisted = !_wishlisted),
                    ),
                    const OiWishlistButton(
                      active: true,
                      label: 'Wishlisted item',
                    ),
                    const OiWishlistButton(
                      loading: true,
                      label: 'Loading wishlist',
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── OiOrderSummaryLine ────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Order Summary Line',
            widgetName: 'OiOrderSummaryLine',
            description:
                'A single summary row showing a label and amount. Used for '
                'subtotal, discount, shipping, tax, and total lines.',
            examples: [
              ComponentExample(
                title: 'Summary Lines',
                child: const Column(
                  children: [
                    OiOrderSummaryLine(
                      label: 'Subtotal',
                      amount: 329.98,
                      currencyCode: 'USD',
                    ),
                    OiOrderSummaryLine(
                      label: 'Discount',
                      amount: 50,
                      currencyCode: 'USD',
                      negative: true,
                      subtitle: 'SUMMER20',
                    ),
                    OiOrderSummaryLine(
                      label: 'Shipping',
                      amount: 9.99,
                      currencyCode: 'USD',
                    ),
                    OiDivider(),
                    OiOrderSummaryLine(
                      label: 'Total',
                      amount: 289.97,
                      currencyCode: 'USD',
                      bold: true,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── OiCouponInput ─────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Coupon Input',
            widgetName: 'OiCouponInput',
            description:
                'A text input with apply button for entering discount '
                'coupon codes during checkout. \n\n'
                'OiCouponInput combines a text field and apply button '
                  'for coupon code entry. Key parameters: onApply, '
                  'appliedCode, onRemove, loading, error.',
            examples: [
              ComponentExample(
                title: 'Apply Coupon',
                child: OiCouponInput(
                  label: 'Coupon code',
                  onApply: (code) async => OiCouponResult(
                    valid: code == 'SUMMER20',
                    message: code == 'SUMMER20'
                        ? '20% off applied!'
                        : 'Invalid code',
                    discountAmount: code == 'SUMMER20' ? 50.0 : null,
                  ),
                ),
              ),
            ],
          ),

          // ── OiCartPanel ─────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Cart Panel',
            widgetName: 'OiCartPanel',
            description:
                'A slide-out panel displaying the full shopping cart with '
                'item list, summary, and checkout button. \n\n'
                'OiCartPanel combines OiCartItemRow, OiOrderSummaryLine, '
                  'and OiCouponInput into a complete cart experience. '
                  'Key parameters: items, onCheckout, onQuantityChange, '
                  'onRemove, currencyCode. Best experienced in the '
                  'Shop mini-app.',
            examples: [
              ComponentExample(
                title: 'Shopping Cart',
                child: SizedBox(
                  height: 600,
                  child: SingleChildScrollView(
                    child: OiCartPanel(
                    label: 'Shopping cart',
                    items: const [
                      OiCartItem(
                        productKey: 'alpine-jacket',
                        name: 'Alpine Jacket',
                        unitPrice: 199.99,
                        quantity: 2,
                      ),
                      OiCartItem(
                        productKey: 'trail-boots',
                        name: 'Trail Boots',
                        unitPrice: 129.99,
                        variantLabel: 'Brown / Size 10',
                      ),
                    ],
                    summary: const OiCartSummary(
                      subtotal: 529.97,
                      shipping: 9.99,
                      tax: 42.40,
                      total: 582.36,
                    ),
                    onQuantityChange: (_) {},
                    onRemove: (_) {},
                    onCheckout: () {},
                  ),
                  ),
                ),
              ),
            ],
          ),

          // ── OiProductGallery ────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Product Gallery',
            widgetName: 'OiProductGallery',
            description:
                'An image gallery with thumbnails and zoom for product '
                'detail pages. \n\n'
                'OiProductGallery displays product images with thumbnail '
                  'navigation and pinch-to-zoom. Key parameters: imageUrls, '
                  'selectedIndex, onIndexChanged. Best experienced in the '
                  'Shop mini-app.',
            examples: [
              ComponentExample(
                title: 'Gallery (No Images)',
                child: OiProductGallery(
                  label: 'Product gallery',
                  imageUrls: [],
                ),
              ),
            ],
          ),

          // ── OiProductFilters ────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Product Filters',
            widgetName: 'OiProductFilters',
            description:
                'A filter panel for product catalog with price range, '
                'categories, and attribute filters. \n\n'
                'OiProductFilters provides faceted filtering for product '
                  'catalogs. Supports price range sliders, category '
                  'checkboxes, and attribute selectors. Key parameters: '
                  'filters, onFilterChange, availableFilters.',
            examples: [
              ComponentExample(
                title: 'Catalog Filters',
                child: OiProductFilters(
                  label: 'Product filters',
                  availableCategories: const [
                    'Jackets',
                    'Boots',
                    'Backpacks',
                    'Accessories',
                  ],
                  priceRangeMax: 500,
                  onChanged: (_) {},
                ),
              ),
            ],
          ),

          // ── OiOrderSummary ──────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Order Summary',
            widgetName: 'OiOrderSummary',
            description:
                'A complete order summary card combining multiple '
                'OiOrderSummaryLine widgets with totals. \n\n'
                'OiOrderSummary aggregates cart items into a summary '
                  'card with subtotal, discounts, shipping, tax, and '
                  'total. Key parameters: cartSummary, currencyCode, '
                  'onCheckout.',
            examples: [
              ComponentExample(
                title: 'Summary Card',
                child: OiOrderSummary(
                  label: 'Order summary',
                  summary: OiCartSummary(
                    subtotal: 329.98,
                    discount: 50,
                    shipping: 9.99,
                    tax: 22.40,
                    total: 312.37,
                  ),
                  items: [
                    OiCartItem(
                      productKey: 'alpine-jacket',
                      name: 'Alpine Jacket',
                      unitPrice: 199.99,
                      quantity: 1,
                    ),
                    OiCartItem(
                      productKey: 'trail-boots',
                      name: 'Trail Boots',
                      unitPrice: 129.99,
                    ),
                  ],
                  currencyCode: 'USD',
                ),
              ),
            ],
          ),

          // ── OiOrderTracker ──────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Order Tracker',
            widgetName: 'OiOrderTracker',
            description:
                'A visual timeline showing order progress through its '
                'lifecycle stages. \n\n'
                'OiOrderTracker displays order status as a step-by-step '
                  'timeline from placement through delivery. Key parameters: '
                  'order (OiOrderData), steps, currentStep.',
            examples: [
              ComponentExample(
                title: 'Shipped Order',
                child: OiOrderTracker(
                  label: 'Order tracker',
                  currentStatus: OiOrderStatus.shipped,
                  showTimeline: true,
                  timeline: [
                    OiOrderEvent(
                      timestamp: DateTime(2026, 3, 20, 10),
                      title: 'Order placed',
                      status: OiOrderStatus.pending,
                    ),
                    OiOrderEvent(
                      timestamp: DateTime(2026, 3, 20, 11, 30),
                      title: 'Order confirmed',
                      status: OiOrderStatus.confirmed,
                    ),
                    OiOrderEvent(
                      timestamp: DateTime(2026, 3, 21, 9),
                      title: 'Shipped',
                      status: OiOrderStatus.shipped,
                      description: 'Tracking: 1Z999AA10123456784',
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── OiPaymentMethodPicker ───────────────────────────────────
          ComponentShowcaseSection(
            title: 'Payment Method Picker',
            widgetName: 'OiPaymentMethodPicker',
            description:
                'A selection UI for choosing a payment method during '
                'checkout. \n\n'
                'OiPaymentMethodPicker renders available payment methods '
                  '(credit card, PayPal, bank transfer, etc.) as selectable '
                  'cards. Key parameters: methods, selectedMethod, '
                  'onMethodSelected.',
            examples: [
              ComponentExample(
                title: 'Payment Methods',
                child: OiPaymentMethodPicker(
                  label: 'Payment methods',
                  methods: const [
                    OiPaymentMethod(
                      key: 'visa',
                      label: 'Visa',
                      lastFour: '4242',
                      expiryDate: '12/27',
                    ),
                    OiPaymentMethod(
                      key: 'mastercard',
                      label: 'Mastercard',
                      lastFour: '8888',
                      expiryDate: '06/26',
                    ),
                    OiPaymentMethod(
                      key: 'paypal',
                      label: 'PayPal',
                      description: 'user@example.com',
                    ),
                  ],
                  selectedKey: 'visa',
                  onSelect: (_) {},
                ),
              ),
            ],
          ),

          // ── OiShippingMethodPicker ──────────────────────────────────
          ComponentShowcaseSection(
            title: 'Shipping Method Picker',
            widgetName: 'OiShippingMethodPicker',
            description:
                'A selection UI for choosing a shipping method during '
                'checkout. \n\n'
                'OiShippingMethodPicker renders available shipping '
                  'options with estimated delivery times and prices. '
                  'Key parameters: methods, selectedMethod, '
                  'onMethodSelected.',
            examples: [
              ComponentExample(
                title: 'Shipping Options',
                child: OiShippingMethodPicker(
                  label: 'Shipping methods',
                  methods: const [
                    OiShippingMethod(
                      key: 'standard',
                      label: 'Standard Shipping',
                      price: 5.99,
                      description: '5-7 business days',
                    ),
                    OiShippingMethod(
                      key: 'express',
                      label: 'Express Shipping',
                      price: 14.99,
                      description: '2-3 business days',
                    ),
                    OiShippingMethod(
                      key: 'overnight',
                      label: 'Overnight',
                      price: 29.99,
                      description: 'Next business day',
                    ),
                  ],
                  selectedKey: 'standard',
                  onSelect: (_) {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
