# Commerce & Shop

These widgets cover the parts of a store: product cards, prices, carts, checkout
steps, and order tracking. Most of them take a small model object (`OiProductData`,
`OiCartItem`, `OiCartSummary`, `OiAddressData`) so you pass data in one place and
the widget handles the layout. Every price and color reads from the theme, so a
product grid and its cart match without extra work.

| Widget | What it does |
| --- | --- |
| `OiProductCard` | A product tile with image, price, rating, and actions. |
| `OiPriceTag` | A formatted price, with an optional strikethrough "was" price. |
| `OiQuantitySelector` | A compact minus/value/plus stepper for quantities. |
| `OiWishlistButton` | A heart toggle for saving a product. |
| `OiStockBadge` | A colored badge for in-stock, low-stock, or out-of-stock. |
| `OiOrderStatusBadge` | A color-coded badge for an order's status. |
| `OiCartItemRow` | A single cart line: thumbnail, name, quantity, total, remove. |
| `OiCouponInput` | A discount-code field with an Apply button and feedback. |
| `OiAddressForm` | A standard shipping or billing address form. |
| `OiPaymentMethodPicker` | A selector for saved cards and payment methods. |
| `OiShippingMethodPicker` | A radio list of shipping methods with price and ETA. |
| `OiOrderSummaryLine` | One summary row: label on the left, amount on the right. |
| `OiCartPanel` | A full cart view: items, coupon, summary, checkout button. |
| `OiMiniCart` | A header cart icon with a badge and a popover preview. |
| `OiOrderSummary` | A summary card with all line items and totals. |
| `OiOrderTracker` | A stepper showing an order moving through its statuses. |
| `OiProductFilters` | A filter panel: price range, categories, rating, in stock. |
| `OiProductGallery` | A product image gallery with thumbnails and a lightbox. |

## OiProductCard

The tile you show in a product grid or listing. Pass an `OiProductData` and it
renders the image, name, price, and rating, plus optional add-to-cart and wishlist
actions.

```dart
OiProductCard(
  label: 'Wool runner shoe',
  product: const OiProductData(
    key: 'sku-1',
    name: 'Wool Runner',
    price: 98,
    compareAtPrice: 120,
    currencyCode: 'USD',
    rating: 4.5,
    reviewCount: 214,
  ),
  onTap: () => openDetail('sku-1'),
  onAddToCart: () => addToCart('sku-1'),
)
```

### Variants

The default is a vertical card for grids. Use `.horizontal()` for list views where
the image sits on the left and details on the right.

```dart
OiProductCard.horizontal(
  label: 'Wool runner shoe',
  product: product,
  onTap: () => openDetail(product.key),
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `product` | `OiProductData` | **required** | The product to display. |
| `label` | `String` | **required** | Accessibility label for the card. |
| `onTap` | `VoidCallback?` | `null` | Called when the card is tapped. Opens the detail view. |
| `onAddToCart` | `VoidCallback?` | `null` | Called when the add-to-cart action fires. |
| `onWishlist` | `VoidCallback?` | `null` | Called when the wishlist heart is toggled. |
| `showRating` | `bool` | `true` | Show the star rating and review count. |
| `showAddToCart` | `bool` | `true` | Show the add-to-cart button. |
| `showWishlist` | `bool` | `false` | Show the wishlist heart. |
| `loading` | `bool` | `false` | Show a skeleton placeholder. |
| `variant` | `OiProductCardVariant` | `vertical` | `vertical`, `horizontal`, or `compact`. |

!!! tip
    Lay cards out in an `OiGrid` for a catalog, or an `OiListView` for a dense
    list. The card handles its own internal spacing.

## OiPriceTag

A formatted price. Reach for it any time you show money in the store. Set
`compareAtPrice` to add a strikethrough "was" price next to the current one.

```dart
OiPriceTag(
  label: 'Price',
  price: 98,
  compareAtPrice: 120,
  currencyCode: 'USD',
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `price` | `double` | **required** | The current price. |
| `label` | `String` | **required** | Accessibility label. |
| `compareAtPrice` | `double?` | `null` | Shows a strikethrough original price. |
| `currencyCode` | `String?` | `null` | ISO 4217 code, for example `USD`. |
| `currencySymbol` | `String?` | `null` | Explicit symbol if you do not use a code. |
| `decimalPlaces` | `int` | `2` | Digits after the decimal point. |
| `size` | `OiPriceTagSize` | `medium` | `small`, `medium`, or `large`. |

!!! note
    For a read-only currency field in a data view, use
    `OiFieldDisplay(type: currency)` instead. `OiPriceTag` is for store prices.

## OiQuantitySelector

A compact stepper with minus, value, and plus. Use it for cart quantities and the
add-to-cart control on a product page. You own the `value` and update it in
`onChange`.

```dart
int _qty = 1;

OiQuantitySelector(
  label: 'Quantity',
  value: _qty,
  min: 1,
  max: 10,
  onChange: (value) => setState(() => _qty = value),
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `int` | **required** | The current quantity. |
| `label` | `String` | **required** | Accessibility label. |
| `onChange` | `ValueChanged<int>?` | `null` | Fires with the new value. |
| `min` | `int` | `1` | Lowest allowed value. |
| `max` | `int` | `99` | Highest allowed value. |
| `compact` | `bool` | `false` | Tighter layout for dense rows. |
| `disabled` | `bool` | `false` | Set `true` to disable both buttons. |

!!! note
    For a general number field outside the shop, use `OiNumberInput`.

## OiWishlistButton

A heart toggle for saving a product. It shows a filled red heart when active and
an outline when not. You own `active` and flip it in `onToggle`.

```dart
bool _saved = false;

OiWishlistButton(
  label: 'Save to wishlist',
  active: _saved,
  onToggle: () => setState(() => _saved = !_saved),
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label. |
| `active` | `bool` | `false` | Whether the product is wishlisted. |
| `onToggle` | `VoidCallback?` | `null` | Called when the heart is tapped. |
| `loading` | `bool` | `false` | Disables the button and reduces opacity. |

## OiStockBadge

A small colored badge for availability. Green means in stock, amber means low
stock, red means out of stock.

```dart
OiStockBadge(
  label: 'In stock',
  status: OiStockStatus.inStock,
  count: 42,
)
```

### From a count

Pass a stock number and let the badge pick the status for you. Anything at or
below `lowStockThreshold` reads as low stock, zero reads as out of stock.

```dart
OiStockBadge.fromCount(
  label: 'Availability',
  stockCount: 3,
  lowStockThreshold: 5,
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `status` | `OiStockStatus` | **required** | `inStock`, `lowStock`, or `outOfStock`. |
| `label` | `String` | **required** | Accessibility label. |
| `count` | `int?` | `null` | Optional remaining quantity shown in the badge. |

## OiOrderStatusBadge

A color-coded badge for an order's status. It maps each status to a theme color:
pending to warning, shipped to primary, delivered to success, cancelled to error,
and so on.

```dart
OiOrderStatusBadge(
  label: 'Order status',
  status: OiOrderStatus.shipped,
)
```

### Variants

The default badge uses a soft fill. Use `.soft()` and `.filled()` to pick the look
directly.

```dart
OiOrderStatusBadge.soft(label: 'Status', status: OiOrderStatus.delivered)
OiOrderStatusBadge.filled(label: 'Status', status: OiOrderStatus.cancelled)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `status` | `OiOrderStatus` | **required** | `pending`, `confirmed`, `processing`, `shipped`, `delivered`, `cancelled`, or `refunded`. |
| `label` | `String` | **required** | Accessibility label. |
| `statusLabels` | `Map<OiOrderStatus, String>?` | `null` | Override the visible text per status, for translations. |
| `statusColors` | `Map<OiOrderStatus, Color>?` | `null` | Override the color per status. |
| `size` | `OiBadgeSize` | `small` | Badge size. |

## OiCartItemRow

One line in a cart. It shows the thumbnail, name, variant, a quantity stepper, the
line total, and a remove control. Pass an `OiCartItem`.

```dart
OiCartItemRow(
  label: 'Wool Runner, size 42',
  item: const OiCartItem(
    productKey: 'sku-1',
    name: 'Wool Runner',
    variantLabel: 'Size 42',
    unitPrice: 98,
    quantity: 2,
  ),
  onQuantityChange: (qty) => updateQuantity('sku-1', qty),
  onRemove: () => removeFromCart('sku-1'),
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `item` | `OiCartItem` | **required** | The cart line to display. |
| `label` | `String` | **required** | Accessibility label. |
| `onQuantityChange` | `ValueChanged<int>?` | `null` | Fires with the new quantity. |
| `onRemove` | `VoidCallback?` | `null` | Called when the item is removed. |
| `onTap` | `VoidCallback?` | `null` | Called when the row is tapped. |
| `editable` | `bool` | `true` | Show the quantity stepper and remove control. |
| `compact` | `bool` | `false` | Tighter layout for a mini cart. |
| `currencyCode` | `String` | `'EUR'` | ISO 4217 code for the totals. |

## OiCouponInput

A discount-code field with an Apply button. Your `onApply` returns an
`OiCouponResult`, and the field shows success or error feedback from it.

```dart
OiCouponInput(
  label: 'Discount code',
  onApply: (code) async {
    final ok = await validateCoupon(code);
    return OiCouponResult(
      valid: ok,
      message: ok ? 'Applied' : 'Invalid code',
    );
  },
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Field label. |
| `onApply` | `Future<OiCouponResult> Function(String)` | **required** | Validates the code. The field shows a spinner while it awaits. |
| `onRemove` | `VoidCallback?` | `null` | Called when an applied code is cleared. |
| `appliedCode` | `String?` | `null` | Shows an already-applied code. |
| `loading` | `bool` | `false` | Force the loading state. |

## OiAddressForm

A standard address form: name, company, address lines, city, state, postal code,
country, and phone. It reads and writes an `OiAddressData`.

```dart
OiAddressForm(
  label: 'Shipping address',
  onChange: (address) => setState(() => _shipTo = address),
  onSubmit: (address) => saveAddress(address),
)
```

### Variants

Use `.shipping()` and `.billing()` for pre-labelled forms in a checkout flow.

```dart
OiAddressForm.shipping(onChange: (a) => _shipTo = a)
OiAddressForm.billing(onChange: (a) => _billTo = a)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Form accessibility label. |
| `initialValue` | `OiAddressData?` | `null` | Pre-fill the fields. |
| `onChange` | `ValueChanged<OiAddressData>?` | `null` | Fires on every edit. |
| `onSubmit` | `ValueChanged<OiAddressData>?` | `null` | Fires when the form is submitted. |
| `countries` | `List<OiCountryOption>?` | `null` | Country and state options. Each has `code`, `name`, `states`. |
| `showName` | `bool` | `true` | Show the name fields. |
| `showCompany` | `bool` | `true` | Show the company field. |
| `showPhone` | `bool` | `true` | Show the phone field. |
| `readOnly` | `bool` | `false` | Render as a read-only summary. |
| `error` | `String?` | `null` | Form-level error message. |

## OiPaymentMethodPicker

A selector for payment methods: saved cards, PayPal, bank transfer. Pass a list of
`OiPaymentMethod` and track the choice with `selectedKey`.

```dart
OiPaymentMethodPicker(
  label: 'Payment method',
  selectedKey: _payKey,
  methods: const [
    OiPaymentMethod(key: 'visa', label: 'Visa', lastFour: '4242'),
    OiPaymentMethod(key: 'paypal', label: 'PayPal'),
  ],
  onSelect: (method) => setState(() => _payKey = method.key),
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `methods` | `List<OiPaymentMethod>` | **required** | The payment options. Each has `key`, `label`, `icon`, `lastFour`, `expiryDate`, `logo`. |
| `label` | `String` | **required** | Accessibility label. |
| `selectedKey` | `Object?` | `null` | The selected method's key. |
| `onSelect` | `ValueChanged<OiPaymentMethod>?` | `null` | Fires with the chosen method. |
| `addNewCard` | `Widget?` | `null` | Widget shown below the list, for example an "Add card" button. |

## OiShippingMethodPicker

A radio-style list of shipping methods. Each row shows a label, price, and delivery
estimate. Pass a list of `OiShippingMethod`.

```dart
OiShippingMethodPicker(
  label: 'Shipping method',
  selectedKey: _shipKey,
  methods: const [
    OiShippingMethod(
      key: 'standard',
      label: 'Standard',
      price: 0,
      estimatedDelivery: '3 to 5 days',
    ),
    OiShippingMethod(
      key: 'express',
      label: 'Express',
      price: 12,
      estimatedDelivery: 'Next day',
    ),
  ],
  onSelect: (method) => setState(() => _shipKey = method.key),
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `methods` | `List<OiShippingMethod>` | **required** | The shipping options. Each has `key`, `label`, `price`, `description`, `estimatedDelivery`, `icon`. |
| `label` | `String` | **required** | Accessibility label. |
| `selectedKey` | `Object?` | `null` | The selected method's key. |
| `onSelect` | `ValueChanged<OiShippingMethod>?` | `null` | Fires with the chosen method. |
| `currencyCode` | `String` | `'EUR'` | ISO 4217 code for the prices. |
| `emptyLabel` | `String` | `'No shipping methods available'` | Text shown when `methods` is empty. |
| `loading` | `bool` | `false` | Show a loading state. |

## OiOrderSummaryLine

One row of a totals block: a label on the left, an amount on the right. Stack a few
to build a subtotal, discount, shipping, tax, and total.

```dart
OiColumn(
  children: [
    OiOrderSummaryLine(label: 'Subtotal', amount: 196, currencyCode: 'USD'),
    OiOrderSummaryLine(
      label: 'Discount',
      amount: 20,
      negative: true,
      subtitle: 'WELCOME10',
      currencyCode: 'USD',
    ),
    OiOrderSummaryLine(label: 'Total', amount: 176, bold: true, currencyCode: 'USD'),
  ],
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Row label. |
| `amount` | `double` | **required** | The amount to show. |
| `currencyCode` | `String?` | `null` | ISO 4217 code. |
| `bold` | `bool` | `false` | Emphasize the row, for the total. |
| `negative` | `bool` | `false` | Show the amount as a deduction, for a discount. |
| `subtitle` | `String?` | `null` | Small secondary text, for example a coupon code. |
| `loading` | `bool` | `false` | Show a shimmer placeholder. |

!!! tip
    You rarely build these by hand. `OiCartPanel` and `OiOrderSummary` already
    render the full totals block from an `OiCartSummary`.

## OiCartPanel

The full cart view in one widget: the item list, a coupon input, the order summary,
and a checkout button. Pass the `items` and an `OiCartSummary`.

```dart
OiCartPanel(
  label: 'Your cart',
  items: cartItems,
  summary: const OiCartSummary(subtotal: 196, total: 176, discount: 20),
  onQuantityChange: (item, qty) => updateQuantity(item.productKey, qty),
  onRemove: (item) => removeFromCart(item.productKey),
  onCheckout: () => goToCheckout(),
  currencyCode: 'USD',
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `List<OiCartItem>` | **required** | The cart lines. |
| `summary` | `OiCartSummary` | **required** | Totals for the summary block. |
| `label` | `String` | **required** | Accessibility label. |
| `onQuantityChange` | `void Function(OiCartItem, int)?` | `null` | Fires with the item and its new quantity. |
| `onRemove` | `ValueChanged<OiCartItem>?` | `null` | Called when an item is removed. |
| `onApplyCoupon` | `Future<OiCouponResult> Function(String)?` | `null` | Validates a coupon code. Omit to hide the coupon field. |
| `onRemoveCoupon` | `VoidCallback?` | `null` | Clears the applied coupon. |
| `appliedCouponCode` | `String?` | `null` | Shows an already-applied code. |
| `onCheckout` | `VoidCallback?` | `null` | Called by the checkout button. |
| `onContinueShopping` | `VoidCallback?` | `null` | Called by the continue-shopping link. |
| `checkoutLabel` | `String` | `'Proceed to Checkout'` | Text on the checkout button. |
| `currencyCode` | `String` | `'EUR'` | ISO 4217 code for all amounts. |
| `loading` | `bool` | `false` | Show a loading state. |

!!! note
    Use `OiCartPanel` for a full cart page or a side sheet. For a small header
    preview, use `OiMiniCart` instead.

## OiMiniCart

A cart icon with an item-count badge. Tapping it opens a popover (or a sheet) that
previews the first few items and links to the full cart or checkout.

```dart
OiMiniCart(
  label: 'Cart',
  items: cartItems,
  summary: const OiCartSummary(subtotal: 196, total: 196),
  onViewCart: () => openCart(),
  onCheckout: () => goToCheckout(),
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `List<OiCartItem>` | **required** | The cart lines. |
| `summary` | `OiCartSummary` | **required** | Totals shown in the preview. |
| `label` | `String` | **required** | Accessibility label. |
| `onViewCart` | `VoidCallback?` | `null` | Called by the view-cart link. |
| `onCheckout` | `VoidCallback?` | `null` | Called by the checkout button. |
| `onRemove` | `ValueChanged<OiCartItem>?` | `null` | Called when an item is removed. |
| `onQuantityChange` | `void Function(OiCartItem, int)?` | `null` | Fires with the item and its new quantity. |
| `maxVisibleItems` | `int` | `3` | How many items the preview shows before it truncates. |
| `display` | `OiMiniCartDisplay` | `popover` | `popover` or `sheet`. |
| `currencyCode` | `String` | `'EUR'` | ISO 4217 code for the totals. |

!!! tip
    Put `OiMiniCart` in your app shell header or bottom bar. It is the entry point
    to the cart, not the cart itself.

## OiOrderSummary

A summary card with the totals and an expandable list of items. Good for a checkout
sidebar or an order confirmation page. Pass an `OiCartSummary`.

```dart
OiOrderSummary(
  label: 'Order summary',
  summary: const OiCartSummary(
    subtotal: 196,
    discount: 20,
    shipping: 0,
    tax: 14,
    total: 190,
  ),
  items: cartItems,
  currencyCode: 'USD',
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `summary` | `OiCartSummary` | **required** | Totals for the line block. |
| `label` | `String` | **required** | Accessibility label. |
| `items` | `List<OiCartItem>?` | `null` | Optional items shown in an expandable list. |
| `showItems` | `bool` | `true` | Show the item list when items are given. |
| `expandedByDefault` | `bool` | `false` | Start with the item list open. |
| `currencyCode` | `String` | `'EUR'` | ISO 4217 code for all amounts. |

## OiOrderTracker

A stepper that shows an order moving from pending to confirmed to shipped to
delivered. Turn on `showTimeline` to list the detailed event history.

```dart
OiOrderTracker(
  label: 'Order status',
  currentStatus: OiOrderStatus.shipped,
  showTimeline: true,
  timeline: const [
    OiOrderEvent(
      timestamp: null,
      title: 'Order placed',
      status: OiOrderStatus.pending,
    ),
  ],
)
```

### From an order

If you already have an `OiOrderData`, use `.compact()` to build the stepper from
its status and timeline.

```dart
OiOrderTracker.compact(order: order)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `currentStatus` | `OiOrderStatus` | **required** | The status to highlight in the stepper. |
| `label` | `String` | **required** | Accessibility label. |
| `timeline` | `List<OiOrderEvent>?` | `null` | Detailed event history. Each event has `timestamp`, `title`, `status`, `description`. |
| `showTimeline` | `bool` | `false` | Show the event list below the stepper. |
| `statusLabels` | `Map<OiOrderStatus, String>?` | `null` | Override the visible text per status. |

## OiProductFilters

A filter panel for a catalog: a price-range slider, category checkboxes, a rating
filter, and an in-stock toggle. It reads and writes one `OiProductFilterData`.

```dart
OiProductFilterData _filters = const OiProductFilterData();

OiProductFilters(
  label: 'Filters',
  value: _filters,
  availableCategories: const ['Shoes', 'Apparel', 'Accessories'],
  priceRangeMin: 0,
  priceRangeMax: 500,
  currencyCode: 'USD',
  onChanged: (value) => setState(() => _filters = value),
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label. |
| `value` | `OiProductFilterData?` | `null` | Current filter state. Fields: `minPrice`, `maxPrice`, `categories`, `minRating`, `inStockOnly`. |
| `onChanged` | `ValueChanged<OiProductFilterData>?` | `null` | Fires with the updated filter state. |
| `availableCategories` | `List<String>` | `[]` | Categories to offer as checkboxes. |
| `currencyCode` | `String` | `'EUR'` | ISO 4217 code for the price slider. |
| `priceRangeMin` | `double` | `0` | Lowest value on the price slider. |
| `priceRangeMax` | `double` | `1000` | Highest value on the price slider. |

!!! tip
    Put `OiProductFilters` in an `OiSidebar` next to a product `OiGrid`, and rebuild
    the grid from the `OiProductFilterData` you get in `onChanged`.

## OiProductGallery

A product image gallery. It shows one main image with thumbnails, and opens a
lightbox when tapped. Pass a list of image URLs.

```dart
OiProductGallery(
  label: 'Product images',
  imageUrls: const [
    'https://example.com/shoe-1.jpg',
    'https://example.com/shoe-2.jpg',
  ],
  onIndexChanged: (index) => setState(() => _active = index),
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `imageUrls` | `List<String>` | **required** | The gallery images. |
| `label` | `String` | **required** | Accessibility label. |
| `initialIndex` | `int` | `0` | Which image starts selected. |
| `onIndexChanged` | `ValueChanged<int>?` | `null` | Fires when the selected image changes. |
| `showThumbnails` | `bool` | `true` | Show the thumbnail strip. |

## Related

- [Forms & Selection](forms.md) for the inputs behind an address or checkout form.
- [Media](media.md) for standalone image galleries and lightboxes.
- [Modules](../modules/commerce.md) for `OiCheckout` and `OiShopProductDetail`,
  which assemble these widgets into full flows.
