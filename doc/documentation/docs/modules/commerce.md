# Commerce Screens

These modules are full commerce pages, not single widgets. You give each one a
data model and a set of callbacks, and it renders the whole screen: a multi-step
checkout, a product detail page, or a pricing comparison. They handle the layout,
the responsive switch between desktop and mobile, and the step or tab state for
you. Your job is to pass the data in and react to the callbacks.

| Widget | What it does |
| --- | --- |
| `OiCheckout` | A multi-step checkout: address, shipping, payment, review. |
| `OiShopProductDetail` | A product detail page with a gallery, variants, and add to cart. |
| `OiPricingTable` | A pricing plan comparison with tiers and a feature matrix. |

All three read colors, spacing, and radius from the theme, so they match the rest
of your app without extra styling. For the smaller building blocks they compose
(`OiPriceTag`, `OiQuantitySelector`, `OiStockBadge`, and so on), see
[Widgets > Commerce](../widgets/commerce.md).

## OiCheckout

A complete checkout wizard. It walks the user through four steps by default:
address entry, shipping selection, payment selection, and a read-only review. On
desktop it shows the wizard on the left and a persistent order summary on the
right. On mobile it stacks into a single column with a collapsible summary.

You feed it the cart items, a summary of the totals, and the available shipping
and payment methods. When the user places the order, `onPlaceOrder` runs with an
aggregated `OiCheckoutData` and returns the finished `OiOrderData`.

```dart
OiCheckout(
  label: 'Checkout',
  items: const [
    OiCartItem(
      productKey: 'sku-1',
      name: 'Wool Sweater',
      unitPrice: 89.0,
      quantity: 2,
    ),
  ],
  summary: const OiCartSummary(
    subtotal: 178.0,
    shipping: 5.0,
    tax: 36.6,
    total: 219.6,
  ),
  shippingMethods: const [
    OiShippingMethod(
      key: 'standard',
      label: 'Standard Shipping',
      price: 5.0,
      estimatedDelivery: '5 to 7 days',
    ),
    OiShippingMethod(
      key: 'express',
      label: 'Express Shipping',
      price: 15.0,
      estimatedDelivery: '1 to 2 days',
    ),
  ],
  paymentMethods: const [
    OiPaymentMethod(
      key: 'card',
      label: 'Credit Card',
      description: 'Visa ending in 4242',
      defaultMethod: true,
    ),
  ],
  onPlaceOrder: (checkoutData) async {
    return placeOrder(checkoutData);
  },
  onCancel: () => Navigator.of(context).pop(),
)
```

### The models

`OiCheckout` is driven by plain data classes. You build these from your own cart
and pass them in. Nothing is coupled to a backend.

- `OiCartItem`: one line in the cart. Needs `productKey`, `name`, and `unitPrice`.
  Optional `variantKey`, `variantLabel`, `quantity` (default `1`), `imageUrl`,
  and `maxQuantity`. The getter `totalPrice` returns `unitPrice * quantity`.
- `OiCartSummary`: the totals shown in the summary panel. Needs `subtotal` and
  `total`. Optional `discount`, `shipping`, `tax`, and matching label strings.
  A `null` field means "not applicable", which is different from a zero value.
- `OiShippingMethod`: one shipping choice. Needs `key`, `label`, and `price`.
- `OiPaymentMethod`: one payment choice. Needs `key` and `label`. Set
  `defaultMethod: true` on the one you want pre-selected.
- `OiAddressData`: the shipping and billing address. Every field is optional, so
  you can pass an empty `const OiAddressData()` and let the user fill it in.
- `OiCheckoutData`: the aggregate passed to `onPlaceOrder`. It carries
  `shippingAddress`, `billingAddress`, `shippingMethod`, and `paymentMethod`.
- `OiOrderData`: what your `onPlaceOrder` returns once the order is placed.

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `List<OiCartItem>` | **required** | The cart lines being checked out. An empty list shows an empty-cart message. |
| `summary` | `OiCartSummary` | **required** | The totals shown in the summary panel. |
| `label` | `String` | **required** | Accessibility label for the whole flow. |
| `steps` | `List<OiCheckoutStep>` | address, shipping, payment, review | The steps, in order. |
| `shippingMethods` | `List<OiShippingMethod>?` | `null` | Choices for the shipping step. |
| `paymentMethods` | `List<OiPaymentMethod>?` | `null` | Choices for the payment step. |
| `countries` | `List<OiCountryOption>?` | `null` | When set, the country field becomes a dropdown. |
| `initialShippingAddress` | `OiAddressData?` | `null` | Pre-fills the shipping address fields. |
| `initialBillingAddress` | `OiAddressData?` | `null` | Pre-fills the billing address fields. |
| `onShippingAddressChange` | `ValueChanged<OiAddressData>?` | `null` | Fires when the shipping address changes. |
| `onBillingAddressChange` | `ValueChanged<OiAddressData>?` | `null` | Fires when the billing address changes. |
| `onShippingMethodChange` | `ValueChanged<OiShippingMethod>?` | `null` | Fires when the shipping method changes. |
| `onPaymentMethodChange` | `ValueChanged<OiPaymentMethod>?` | `null` | Fires when the payment method changes. |
| `onPlaceOrder` | `Future<OiOrderData> Function(OiCheckoutData)?` | `null` | Runs on submit. Return the order or throw to show an error. |
| `onCancel` | `VoidCallback?` | `null` | Called when the user cancels. |
| `showSummary` | `bool` | `true` | Show the order summary panel. |
| `sameBillingDefault` | `bool` | `true` | Start with "same as shipping" checked. |
| `currencyCode` | `String` | `'USD'` | ISO 4217 currency code. |
| `placeOrderLabel` | `String?` | `null` | Custom place-order button text. Falls back to `Place Order`. |

!!! note
    `OiCheckout` validates each step before it lets the user advance. The address
    step checks its required fields, and the shipping and payment steps require a
    selection. You do not wire this up yourself.

## OiShopProductDetail

A product detail page. It shows an image gallery with a thumbnail strip, the
title, price, rating, stock badge, variant selectors, a quantity stepper, and an
add-to-cart button. On desktop the gallery sits left and the info sits right. On
mobile they stack.

You pass a single `OiProductData`. The page derives the effective price and stock
from the selected variant, so switching a variant updates the price and the
gallery on its own.

```dart
OiShopProductDetail(
  label: 'Wool Sweater detail',
  product: const OiProductData(
    key: 'sku-1',
    name: 'Wool Sweater',
    price: 89.0,
    compareAtPrice: 119.0,
    sku: 'WS-001',
    rating: 4.5,
    reviewCount: 128,
    imageUrl: 'https://example.com/sweater.jpg',
    variants: [
      OiProductVariant(
        key: 'red-l',
        label: 'Red / Large',
        attributes: {'Color': 'Red', 'Size': 'Large'},
      ),
      OiProductVariant(
        key: 'blue-m',
        label: 'Blue / Medium',
        price: 79.0,
        attributes: {'Color': 'Blue', 'Size': 'Medium'},
      ),
    ],
  ),
  onAddToCart: (item) => cart.add(item),
  onVariantChange: (variant) => track(variant),
)
```

### The models

- `OiProductData`: the product. Needs `key`, `name`, and `price`. Common optional
  fields are `compareAtPrice` (the strikethrough "was" price), `currencyCode`
  (default `'USD'`), `imageUrl`, `imageUrls` (the gallery), `variants`, `rating`,
  `reviewCount`, `sku`, `inStock`, and `stockCount`.
- `OiProductVariant`: one variant, like "Red / Large". Needs `key` and `label`.
  A `null` `price` means the parent product price applies. Use `attributes`
  (for example `{'Color': 'Red'}`) to get one dropdown per attribute group.
- `OiCartItem`: what `onAddToCart` hands you. The page builds it from the product,
  the selected variant, and the current quantity.

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `product` | `OiProductData` | **required** | The product to display. |
| `label` | `String` | **required** | Accessibility label for the page. |
| `onAddToCart` | `ValueChanged<OiCartItem>?` | `null` | Fires with the built cart item on add. |
| `onVariantChange` | `ValueChanged<OiProductVariant>?` | `null` | Fires when the user picks a variant. |
| `onQuantityChange` | `ValueChanged<int>?` | `null` | Fires when the quantity changes. |
| `onWishlist` | `VoidCallback?` | `null` | Called on the wishlist toggle. Also shows a Wishlist button. |
| `wishlisted` | `bool` | `false` | Whether the product is in the wishlist. |
| `selectedVariant` | `OiProductVariant?` | `null` | The pre-selected variant. |
| `quantity` | `int` | `1` | The starting quantity. |
| `description` | `Widget?` | `null` | Content for the Description tab. |
| `specifications` | `Widget?` | `null` | Content for the Specifications tab. |
| `reviews` | `Widget?` | `null` | Content for the Reviews tab. |
| `related` | `List<OiProductData>?` | `null` | Related products shown below the main content. |
| `onRelatedProductTap` | `ValueChanged<OiProductData>?` | `null` | Fires when a related product is tapped. |

!!! note
    The Description, Specifications, and Reviews tabs only appear when you pass a
    widget for them. Leave them `null` to hide the whole tab strip.

## OiPricingTable

A pricing plan comparison. It lays out one card per plan, highlights a recommended
plan, and can show a monthly-to-yearly billing toggle. Below the cards it can draw
a feature matrix that compares plans row by row. On narrow screens the cards stack
and the whole table scrolls.

```dart
OiPricingTable(
  label: 'Plans',
  yearlyDiscount: 'Save 20%',
  plans: const [
    OiPricingPlan(
      key: 'starter',
      name: 'Starter',
      monthlyPrice: 9,
      description: 'For individuals getting started.',
      features: ['1 project', 'Community support'],
    ),
    OiPricingPlan(
      key: 'pro',
      name: 'Pro',
      monthlyPrice: 29,
      yearlyPrice: 278,
      description: 'For growing teams.',
      features: ['Unlimited projects', 'Priority support'],
      recommended: true,
      badge: 'Popular',
    ),
    OiPricingPlan(
      key: 'enterprise',
      name: 'Enterprise',
      monthlyPrice: 0,
      contactSales: true,
      features: ['SSO', 'Dedicated manager'],
    ),
  ],
  features: const [
    OiPricingFeature(
      label: 'Projects',
      included: {'starter': '1', 'pro': 'Unlimited', 'enterprise': 'Unlimited'},
    ),
    OiPricingFeature(
      label: 'SSO',
      included: {'starter': false, 'pro': false, 'enterprise': true},
    ),
  ],
  onPlanSelect: (plan, cycle) => subscribe(plan, cycle),
)
```

### The models

- `OiPricingPlan`: one plan card. Needs `key`, `name`, and `monthlyPrice`. Set
  `yearlyPrice` for the yearly cycle, or leave it `null` to assume monthly times
  twelve. `features` is the bullet list on the card. Set `recommended: true` to
  highlight it, `currentPlan: true` to mark the user's plan, `contactSales: true`
  to show "Contact Sales" instead of a price, and `badge` for a small label.
- `OiPricingFeature`: one row in the comparison matrix. Needs `label` and
  `included`, a map from plan `key` to a value. Use `true` for a check, `false`
  for a cross, or a `String` for custom text like "5 GB".

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `plans` | `List<OiPricingPlan>` | **required** | The plans, left to right. |
| `label` | `String` | **required** | Accessibility label for the table. |
| `features` | `List<OiPricingFeature>` | `[]` | Rows for the comparison matrix. |
| `onPlanSelect` | `void Function(OiPricingPlan, OiBillingCycle)?` | `null` | Fires when a plan's button is tapped. |
| `onBillingCycleChange` | `ValueChanged<OiBillingCycle>?` | `null` | Fires when the toggle flips. |
| `billingCycle` | `OiBillingCycle` | `monthly` | The starting cycle. |
| `showBillingToggle` | `bool` | `true` | Show the monthly/yearly toggle. |
| `yearlyDiscount` | `String?` | `null` | Badge next to the yearly option, like "Save 20%". |
| `currencySymbol` | `String` | `'$'` | Prefix for prices. |
| `showFeatureMatrix` | `bool` | `true` | Draw the comparison matrix. Needs `features` too. |
| `maxWidth` | `double` | `1200` | Maximum table width. |
| `mobileBreakpoint` | `OiBreakpoint` | `expanded` | Below this width the cards stack. |

!!! note
    The matrix only shows when `showFeatureMatrix` is `true` and you passed a
    non-empty `features` list. A plan key that is missing from a feature's
    `included` map renders as "not included".

## Related

- [Widgets > Commerce](../widgets/commerce.md) for the building blocks these pages compose.
- [App Shell](app-shell.md) for the navigation frame around a store.
- [Data Views](data-views.md) for tables and lists of orders or products.
