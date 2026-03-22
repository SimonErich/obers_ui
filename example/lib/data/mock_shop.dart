import 'package:obers_ui/obers_ui.dart';

// ── Products ─────────────────────────────────────────────────────────────────

/// Ten curated Austrian products for the showcase shop.
const kProducts = <OiProductData>[
  // 1 — Original Sacher-Torte
  OiProductData(
    key: 'prod-sachertorte',
    name: 'Original Sacher-Torte',
    price: 39.90,
    currencyCode: 'EUR',
    description:
        'The legendary chocolate cake that launched a thousand lawsuits. '
        'Hand-glazed with apricot jam and dark chocolate — because '
        'Viennese bakers do not compromise.',
    sku: 'SAC-001',
    rating: 4.9,
    reviewCount: 1842,
    tags: ['food', 'chocolate', 'vienna', 'gift', 'classic'],
    attributes: {'Origin': 'Vienna', 'Shelf Life': '14 days'},
    variants: [
      OiProductVariant(
        key: 'sacher-small',
        label: 'Small (500 g)',
        price: 39.90,
        attributes: {'Weight': '500 g'},
      ),
      OiProductVariant(
        key: 'sacher-grand',
        label: 'Grand (1 kg)',
        price: 69.90,
        attributes: {'Weight': '1 kg'},
      ),
      OiProductVariant(
        key: 'sacher-kaiserlich',
        label: 'Kaiserlich (2 kg)',
        price: 119.90,
        attributes: {'Weight': '2 kg'},
      ),
    ],
  ),

  // 2 — Wiener Schnitzel Home Kit
  OiProductData(
    key: 'prod-schnitzel-kit',
    name: 'Wiener Schnitzel Home Kit',
    price: 34.50,
    currencyCode: 'EUR',
    description:
        'Everything you need to pound, bread, and fry your way to '
        'Schnitzel perfection. Comes with a tiny Austrian flag to '
        'plant in the finished masterpiece.',
    sku: 'SCH-001',
    rating: 4.7,
    reviewCount: 623,
    tags: ['food', 'cooking', 'vienna', 'diy'],
    attributes: {'Serves': '4 persons'},
    variants: [
      OiProductVariant(
        key: 'schnitzel-veal',
        label: 'Veal',
        price: 34.50,
        attributes: {'Meat': 'Veal'},
      ),
      OiProductVariant(
        key: 'schnitzel-pork',
        label: 'Pork',
        price: 28.50,
        attributes: {'Meat': 'Pork'},
      ),
      OiProductVariant(
        key: 'schnitzel-chicken',
        label: 'Chicken',
        price: 26.90,
        attributes: {'Meat': 'Chicken'},
      ),
    ],
  ),

  // 3 — Alpine Hiking Boot "Gipfelstürmer"
  OiProductData(
    key: 'prod-hiking-boot',
    name: 'Alpine Hiking Boot "Gipfelstürmer"',
    price: 289,
    currencyCode: 'EUR',
    description:
        'Conquers peaks so you can post summit selfies. Waterproof '
        'leather, Vibram sole, and an attitude that says "I was hiking '
        'before it was cool." Made in Tyrol.',
    sku: 'HIK-001',
    rating: 4.8,
    reviewCount: 347,
    tags: ['footwear', 'hiking', 'outdoor', 'tyrol'],
    attributes: {'Material': 'Full-grain leather', 'Sole': 'Vibram'},
    variants: [
      OiProductVariant(
        key: 'boot-38',
        label: 'EU 38',
        attributes: {'Size': '38'},
      ),
      OiProductVariant(
        key: 'boot-39',
        label: 'EU 39',
        attributes: {'Size': '39'},
      ),
      OiProductVariant(
        key: 'boot-40',
        label: 'EU 40',
        attributes: {'Size': '40'},
      ),
      OiProductVariant(
        key: 'boot-41',
        label: 'EU 41',
        attributes: {'Size': '41'},
      ),
      OiProductVariant(
        key: 'boot-42',
        label: 'EU 42',
        attributes: {'Size': '42'},
      ),
      OiProductVariant(
        key: 'boot-43',
        label: 'EU 43',
        attributes: {'Size': '43'},
      ),
      OiProductVariant(
        key: 'boot-44',
        label: 'EU 44',
        attributes: {'Size': '44'},
      ),
      OiProductVariant(
        key: 'boot-45',
        label: 'EU 45',
        attributes: {'Size': '45'},
      ),
      OiProductVariant(
        key: 'boot-46',
        label: 'EU 46',
        attributes: {'Size': '46'},
      ),
    ],
  ),

  // 4 — Viennese Coffee Set "Kaffeehauskultur"
  OiProductData(
    key: 'prod-coffee-set',
    name: 'Viennese Coffee Set "Kaffeehauskultur"',
    price: 89,
    currencyCode: 'EUR',
    description:
        'Two porcelain cups, a silver tray, a glass of water on the side, '
        'and a small existential crisis — just like in a real Kaffeehaus. '
        'Newspaper and judgmental waiter not included.',
    sku: 'KAF-001',
    rating: 4.6,
    reviewCount: 215,
    tags: ['coffee', 'porcelain', 'vienna', 'gift', 'lifestyle'],
    attributes: {'Material': 'Porcelain', 'Pieces': '5'},
  ),

  // 5 — Mozartkugeln Gift Box 24 pcs
  OiProductData(
    key: 'prod-mozartkugeln',
    name: 'Mozartkugeln Gift Box 24 pcs',
    price: 28.50,
    currencyCode: 'EUR',
    description:
        'Spheres of marzipan, nougat, and dark chocolate named after a '
        'man who never tasted them. Mozart would have approved — he was '
        'famously fond of sweets and dramatic packaging.',
    sku: 'MOZ-001',
    rating: 4.5,
    reviewCount: 982,
    tags: ['food', 'chocolate', 'salzburg', 'gift', 'classic'],
    attributes: {'Pieces': '24', 'Origin': 'Salzburg'},
  ),

  // 6 — Dirndl "Almsommer"
  OiProductData(
    key: 'prod-dirndl',
    name: 'Dirndl "Almsommer"',
    price: 249,
    compareAtPrice: 329,
    currencyCode: 'EUR',
    description:
        'Traditional meets Instagram-ready. Hand-stitched bodice, '
        'swishy apron, and a neckline that has launched a thousand '
        'Oktoberfest debates. Available in alpine-meadow green.',
    sku: 'DIR-001',
    rating: 4.7,
    reviewCount: 178,
    tags: ['clothing', 'tracht', 'dirndl', 'fashion', 'tradition'],
    attributes: {'Color': 'Alpine Green', 'Material': 'Cotton / Linen'},
    variants: [
      OiProductVariant(
        key: 'dirndl-s',
        label: 'S',
        attributes: {'Size': 'S'},
      ),
      OiProductVariant(
        key: 'dirndl-m',
        label: 'M',
        attributes: {'Size': 'M'},
      ),
      OiProductVariant(
        key: 'dirndl-l',
        label: 'L',
        attributes: {'Size': 'L'},
      ),
      OiProductVariant(
        key: 'dirndl-xl',
        label: 'XL',
        attributes: {'Size': 'XL'},
      ),
    ],
  ),

  // 7 — Lederhosen "Bergkönig"
  OiProductData(
    key: 'prod-lederhosen',
    name: 'Lederhosen "Bergkönig"',
    price: 389,
    currencyCode: 'EUR',
    description:
        'Genuine deer leather, hand-embroidered edelweiss motif, and '
        'suspenders strong enough to survive a Schuhplattler competition. '
        'Your thighs will thank you — eventually.',
    sku: 'LED-001',
    rating: 4.8,
    reviewCount: 134,
    tags: ['clothing', 'tracht', 'lederhosen', 'fashion', 'tradition'],
    attributes: {'Color': 'Walnut Brown', 'Material': 'Deer leather'},
  ),

  // 8 — Zillertaler Graukäse
  OiProductData(
    key: 'prod-graukaese',
    name: 'Zillertaler Graukäse',
    price: 14.90,
    currencyCode: 'EUR',
    description:
        'The cheese that clears a room — and wins your heart. This low-fat '
        'sour-milk cheese from the Zillertal Valley is an acquired taste '
        'that separates cheese tourists from cheese connoisseurs.',
    sku: 'GRK-001',
    rating: 4.2,
    reviewCount: 89,
    tags: ['food', 'cheese', 'tyrol', 'regional'],
    attributes: {'Weight': '250 g', 'Region': 'Zillertal'},
  ),

  // 9 — Almdudler Party Pack 12x0.5L
  OiProductData(
    key: 'prod-almdudler',
    name: 'Almdudler Party Pack 12x0.5L',
    price: 18.90,
    currencyCode: 'EUR',
    description:
        'Austria\u2019s answer to everything that is not beer. This herbal '
        'lemonade has fuelled Alpine hikes and Heurigen evenings since 1957. '
        'Mix with white wine for a Almspritzer and unlock peak Austrian energy.',
    sku: 'ALM-001',
    rating: 4.4,
    reviewCount: 456,
    tags: ['beverage', 'lemonade', 'party', 'classic'],
    attributes: {'Volume': '12 x 0.5 L', 'Type': 'Herbal lemonade'},
  ),

  // 10 — Manner Schnitten Tower 12 packs (out of stock)
  OiProductData(
    key: 'prod-manner',
    name: 'Manner Schnitten Tower 12 packs',
    price: 24.90,
    currencyCode: 'EUR',
    description:
        'The pink wafer towers of Vienna — stacked, snapped, and devoured '
        'at an alarming rate since 1898. Currently sold out because someone '
        'ordered the entire warehouse. We are looking at you, Franz.',
    sku: 'MAN-001',
    inStock: false,
    stockCount: 0,
    rating: 4.6,
    reviewCount: 721,
    tags: ['food', 'wafer', 'vienna', 'snack', 'classic'],
    attributes: {'Packs': '12', 'Flavor': 'Hazelnut'},
  ),
];

// ── Cart ─────────────────────────────────────────────────────────────────────

/// Initial cart items for the showcase checkout flow.
const kInitialCartItems = <OiCartItem>[
  OiCartItem(
    productKey: 'prod-sachertorte',
    name: 'Original Sacher-Torte',
    unitPrice: 39.90,
    variantKey: 'sacher-small',
    variantLabel: 'Small (500 g)',
    quantity: 2,
  ),
  OiCartItem(
    productKey: 'prod-mozartkugeln',
    name: 'Mozartkugeln Gift Box 24 pcs',
    unitPrice: 28.50,
  ),
];

/// Computes a cart summary with 20 % Austrian VAT.
OiCartSummary computeCartSummary(
  List<OiCartItem> items, {
  double? shippingCost,
  String? discountLabel,
  double? discountAmount,
}) {
  final subtotal =
      items.fold<double>(0, (sum, item) => sum + item.totalPrice);

  final afterDiscount = subtotal - (discountAmount ?? 0);
  final taxableAmount = afterDiscount + (shippingCost ?? 0);
  final tax = taxableAmount * 0.20;
  final total = taxableAmount + tax;

  return OiCartSummary(
    subtotal: subtotal,
    discount: discountAmount,
    discountLabel: discountLabel,
    shipping: shippingCost,
    shippingLabel: shippingCost != null ? 'Shipping' : null,
    tax: tax,
    taxLabel: 'VAT 20 %',
    total: total,
    currencyCode: 'EUR',
  );
}

// ── Shipping ─────────────────────────────────────────────────────────────────

/// Available shipping methods.
const kShippingMethods = <OiShippingMethod>[
  OiShippingMethod(
    key: 'shipping-standard',
    label: 'Austrian Post Standard',
    price: 5.90,
    description: 'Reliable as a Viennese tram — mostly on time.',
    estimatedDelivery: '3-5 business days',
    currencyCode: 'EUR',
  ),
  OiShippingMethod(
    key: 'shipping-express',
    label: 'Express',
    price: 12.90,
    description: 'For when your Sachertorte craving cannot wait.',
    estimatedDelivery: '1-2 business days',
    currencyCode: 'EUR',
  ),
  OiShippingMethod(
    key: 'shipping-almbote',
    label: 'Alm-Bote Mountain Courier',
    price: 24.90,
    description:
        'Hand-delivered by a lederhosen-clad courier. Yodelling on arrival '
        'included at no extra charge.',
    estimatedDelivery: 'Next day',
    currencyCode: 'EUR',
  ),
];

// ── Payment ──────────────────────────────────────────────────────────────────

/// Available payment methods.
const kPaymentMethods = <OiPaymentMethod>[
  OiPaymentMethod(
    key: 'pay-visa',
    label: 'Kreditkarte',
    description: 'Visa ending in 4242',
    lastFour: '4242',
    expiryDate: '12/27',
    isDefault: true,
  ),
  OiPaymentMethod(
    key: 'pay-eps',
    label: 'EPS Online Transfer',
    description: 'Direct bank transfer via Austrian EPS.',
  ),
  OiPaymentMethod(
    key: 'pay-klarna',
    label: 'Klarna',
    description: 'Buy now, pay later — guilt sold separately.',
  ),
  OiPaymentMethod(
    key: 'pay-nachnahme',
    label: 'Nachnahme',
    description: 'Cash on delivery. Old school, but it works.',
  ),
];

// ── Address ──────────────────────────────────────────────────────────────────

/// Sample shipping address for the showcase.
const kSampleAddress = OiAddressData(
  firstName: 'Leopold',
  lastName: 'Brandauer',
  company: 'Alpenglueck GmbH',
  line1: 'Kärntner Straße 38',
  line2: 'Top 7',
  city: 'Vienna',
  state: 'W',
  postalCode: '1010',
  country: 'AT',
  phone: '+43 1 512 1487',
  email: 'leopold@alpenglueck.at',
);

// ── Coupons ──────────────────────────────────────────────────────────────────

/// Valid coupon definitions: code -> (discount percentage, message).
const kValidCoupons = <String, ({double discount, String message})>{
  'SACHERTORTE10': (
    discount: 0.10,
    message: '10 % off — a sweet deal, just like the cake!',
  ),
  'ALPENGLUECK': (
    discount: 0.15,
    message: '15 % off — Alpine happiness delivered!',
  ),
  'SCHNITZEL': (
    discount: 0.05,
    message: '5 % off — a crispy little saving.',
  ),
};

/// Validates a coupon code against [kValidCoupons] and returns a result.
OiCouponResult validateCoupon(String code, double subtotal) {
  final upper = code.trim().toUpperCase();
  final entry = kValidCoupons[upper];

  if (entry == null) {
    return const OiCouponResult(
      valid: false,
      message: 'Invalid coupon code. Nice try though!',
    );
  }

  final discountAmount = subtotal * entry.discount;

  return OiCouponResult(
    valid: true,
    message: entry.message,
    discountAmount: discountAmount,
  );
}
