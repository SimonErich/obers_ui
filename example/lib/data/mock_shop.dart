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
        'Dense, chocolatey, and legally distinct from that other hotel\u2019s version',
    sku: 'SAC-001',
    rating: 4.9,
    reviewCount: 1842,
    tags: ['food', 'chocolate', 'vienna', 'gift', 'classic'],
    attributes: {'Origin': 'Vienna', 'Shelf Life': '14 days'},
    imageUrls: [
      '/images/products/sachertorte_whole.jpg',
      '/images/products/sachertorte_slice.jpg',
      '/images/products/sachertorte_box.jpg',
      '/images/products/sachertorte_detail.jpg',
    ],
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
        'Includes a tiny wooden mallet for when you need to take out your feelings on the meat',
    sku: 'SCH-001',
    rating: 4.7,
    reviewCount: 623,
    tags: ['food', 'cooking', 'vienna', 'diy'],
    attributes: {'Serves': '4 persons'},
    imageUrls: [
      '/images/products/schnitzel_kit_box.jpg',
      '/images/products/schnitzel_kit_contents.jpg',
      '/images/products/schnitzel_plated.jpg',
    ],
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
        'Conquer the Grossglockner or just look ruggedly Austrian at the office',
    sku: 'HIK-001',
    rating: 4.8,
    reviewCount: 347,
    tags: ['footwear', 'hiking', 'outdoor', 'tyrol'],
    attributes: {'Material': 'Full-grain leather', 'Sole': 'Vibram'},
    imageUrls: [
      '/images/products/hiking_boot_side.jpg',
      '/images/products/hiking_boot_sole.jpg',
      '/images/products/hiking_boot_laces.jpg',
      '/images/products/hiking_boot_mountain.jpg',
    ],
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
        'Includes a laminated card explaining the 27 types of Viennese coffee',
    sku: 'KAF-001',
    rating: 4.6,
    reviewCount: 215,
    tags: ['coffee', 'porcelain', 'vienna', 'gift', 'lifestyle'],
    attributes: {'Material': 'Porcelain', 'Pieces': '5'},
    imageUrls: [
      '/images/products/coffee_set_table.jpg',
      '/images/products/coffee_set_cups.jpg',
      '/images/products/coffee_set_tray.jpg',
    ],
  ),

  // 5 — Mozartkugeln Gift Box 24 pcs
  OiProductData(
    key: 'prod-mozartkugeln',
    name: 'Mozartkugeln Gift Box 24 pcs',
    price: 28.50,
    currencyCode: 'EUR',
    description:
        'The perfect gift for anyone you want to impress or apologize to',
    sku: 'MOZ-001',
    rating: 4.5,
    reviewCount: 982,
    tags: ['food', 'chocolate', 'salzburg', 'gift', 'classic'],
    attributes: {'Pieces': '24', 'Origin': 'Salzburg'},
    imageUrls: [
      '/images/products/mozartkugeln_box.jpg',
      '/images/products/mozartkugeln_open.jpg',
      '/images/products/mozartkugeln_cross_section.jpg',
      '/images/products/mozartkugeln_gift.jpg',
    ],
  ),

  // 6 — Dirndl "Almsommer"
  OiProductData(
    key: 'prod-dirndl',
    name: 'Dirndl "Almsommer"',
    price: 249,
    compareAtPrice: 329,
    currencyCode: 'EUR',
    description:
        'Says \u2018I appreciate folk traditions but also have a design degree\u2019',
    sku: 'DIR-001',
    rating: 4.7,
    reviewCount: 178,
    tags: ['clothing', 'tracht', 'dirndl', 'fashion', 'tradition'],
    attributes: {'Color': 'Alpine Green', 'Material': 'Cotton / Linen'},
    imageUrls: [
      '/images/products/dirndl_front.jpg',
      '/images/products/dirndl_back.jpg',
      '/images/products/dirndl_detail_bodice.jpg',
      '/images/products/dirndl_apron.jpg',
      '/images/products/dirndl_meadow.jpg',
    ],
    variants: [
      OiProductVariant(key: 'dirndl-s', label: 'S', attributes: {'Size': 'S'}),
      OiProductVariant(key: 'dirndl-m', label: 'M', attributes: {'Size': 'M'}),
      OiProductVariant(key: 'dirndl-l', label: 'L', attributes: {'Size': 'L'}),
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
    description: 'Break-in period: approximately one Heuriger visit',
    sku: 'LED-001',
    rating: 4.8,
    reviewCount: 134,
    tags: ['clothing', 'tracht', 'lederhosen', 'fashion', 'tradition'],
    attributes: {'Color': 'Walnut Brown', 'Material': 'Deer leather'},
    imageUrls: [
      '/images/products/lederhosen_front.jpg',
      '/images/products/lederhosen_embroidery.jpg',
      '/images/products/lederhosen_suspenders.jpg',
    ],
  ),

  // 8 — Zillertaler Graukäse
  OiProductData(
    key: 'prod-graukaese',
    name: 'Zillertaler Graukäse',
    price: 14.90,
    currencyCode: 'EUR',
    description:
        'The cheese that smells like a gym locker and tastes like heaven',
    sku: 'GRK-001',
    rating: 4.2,
    reviewCount: 89,
    tags: ['food', 'cheese', 'tyrol', 'regional'],
    attributes: {'Weight': '250 g', 'Region': 'Zillertal'},
    imageUrls: [
      '/images/products/graukaese_wheel.jpg',
      '/images/products/graukaese_slice.jpg',
      '/images/products/graukaese_plate.jpg',
    ],
  ),

  // 9 — Almdudler Party Pack 12x0.5L
  OiProductData(
    key: 'prod-almdudler',
    name: 'Almdudler Party Pack 12x0.5L',
    price: 18.90,
    currencyCode: 'EUR',
    description:
        'Austria\u2019s answer to the question nobody asked: what if lemonade tasted like Alpine herbs?',
    sku: 'ALM-001',
    rating: 4.4,
    reviewCount: 456,
    tags: ['beverage', 'lemonade', 'party', 'classic'],
    attributes: {'Volume': '12 x 0.5 L', 'Type': 'Herbal lemonade'},
    imageUrls: [
      '/images/products/almdudler_pack.jpg',
      '/images/products/almdudler_bottle.jpg',
      '/images/products/almdudler_glass.jpg',
    ],
  ),

  // 10 — Manner Schnitten Tower 12 packs (out of stock)
  OiProductData(
    key: 'prod-manner',
    name: 'Manner Schnitten Tower 12 packs',
    price: 24.90,
    currencyCode: 'EUR',
    description: 'The pink wafers that built a nation',
    sku: 'MAN-001',
    inStock: false,
    stockCount: 0,
    rating: 4.6,
    reviewCount: 721,
    tags: ['food', 'wafer', 'vienna', 'snack', 'classic'],
    attributes: {'Packs': '12', 'Flavor': 'Hazelnut'},
    imageUrls: [
      '/images/products/manner_tower.jpg',
      '/images/products/manner_wafer.jpg',
      '/images/products/manner_box.jpg',
      '/images/products/manner_stephansdom.jpg',
    ],
  ),
];

// ── Related Products ────────────────────────────────────────────────────────

/// Product-key to a set of related product keys.
const _kRelatedMap = <String, List<String>>{
  'prod-sachertorte': ['prod-mozartkugeln', 'prod-coffee-set', 'prod-manner'],
  'prod-schnitzel-kit': [
    'prod-graukaese',
    'prod-almdudler',
    'prod-sachertorte',
  ],
  'prod-hiking-boot': [
    'prod-lederhosen',
    'prod-dirndl',
    'prod-almdudler',
    'prod-graukaese',
  ],
  'prod-coffee-set': ['prod-sachertorte', 'prod-mozartkugeln', 'prod-manner'],
  'prod-mozartkugeln': ['prod-sachertorte', 'prod-manner', 'prod-coffee-set'],
  'prod-dirndl': ['prod-lederhosen', 'prod-hiking-boot', 'prod-coffee-set'],
  'prod-lederhosen': ['prod-dirndl', 'prod-hiking-boot', 'prod-almdudler'],
  'prod-graukaese': [
    'prod-schnitzel-kit',
    'prod-almdudler',
    'prod-sachertorte',
  ],
  'prod-almdudler': ['prod-schnitzel-kit', 'prod-graukaese', 'prod-manner'],
  'prod-manner': [
    'prod-sachertorte',
    'prod-mozartkugeln',
    'prod-almdudler',
    'prod-coffee-set',
  ],
};

/// Returns related products for the given [productKey].
List<OiProductData> getRelatedProducts(String productKey) {
  final keys = _kRelatedMap[productKey];
  if (keys == null) return [];
  return keys
      .map((k) => kProducts.where((p) => p.key == k).firstOrNull)
      .whereType<OiProductData>()
      .toList();
}

// ── Reviews ─────────────────────────────────────────────────────────────────

/// A single product review.
class MockReview {
  /// Creates a [MockReview].
  const MockReview({
    required this.reviewerName,
    required this.rating,
    required this.text,
    required this.date,
    this.helpfulCount = 0,
    this.unhelpfulCount = 0,
  });

  /// Name of the reviewer.
  final String reviewerName;

  /// Star rating (1-5).
  final double rating;

  /// Review body text.
  final String text;

  /// When the review was posted.
  final DateTime date;

  /// Number of "helpful" votes.
  final int helpfulCount;

  /// Number of "not helpful" votes.
  final int unhelpfulCount;
}

/// Reviews keyed by product key.
final kProductReviews = <String, List<MockReview>>{
  'prod-sachertorte': [
    MockReview(
      reviewerName: 'Margarethe Gruber',
      rating: 5,
      text:
          'Absolutely divine. The apricot jam layer is perfection. '
          'My Oma would approve, and she approves of nothing.',
      date: DateTime(2026, 3, 10, 14, 30),
      helpfulCount: 42,
      unhelpfulCount: 1,
    ),
    MockReview(
      reviewerName: 'Johann Steinbauer',
      rating: 5,
      text:
          'Ordered the Kaiserlich for a family gathering. It arrived '
          'perfectly packaged and disappeared in under an hour.',
      date: DateTime(2026, 3, 5, 9, 15),
      helpfulCount: 28,
    ),
    MockReview(
      reviewerName: 'Franz Hofer',
      rating: 4,
      text:
          'Very good, but I still think my Tante Helga makes a better one. '
          'Do not tell Hotel Sacher I said that.',
      date: DateTime(2026, 2, 20, 18, 45),
      helpfulCount: 15,
      unhelpfulCount: 3,
    ),
  ],
  'prod-hiking-boot': [
    MockReview(
      reviewerName: 'Katharina Lechner',
      rating: 5,
      text:
          'Wore these up the Grossglockner. My feet were dry, my soul '
          'was at peace. Worth every cent.',
      date: DateTime(2026, 3, 15, 11),
      helpfulCount: 37,
    ),
    MockReview(
      reviewerName: 'Helmut Winkler',
      rating: 4,
      text:
          'Excellent grip on wet rock. Took a week to break in, but '
          'now they feel like slippers — very sturdy slippers.',
      date: DateTime(2026, 2, 28, 16, 20),
      helpfulCount: 21,
      unhelpfulCount: 2,
    ),
  ],
  'prod-dirndl': [
    MockReview(
      reviewerName: 'Anneliese Moser',
      rating: 5,
      text:
          'The fabric quality is outstanding. I wore it to the Villacher '
          'Fasching and received compliments all evening.',
      date: DateTime(2026, 3, 1, 20),
      helpfulCount: 19,
    ),
    MockReview(
      reviewerName: 'Renate Berger',
      rating: 4,
      text:
          'Beautiful stitching and the green is gorgeous. Runs slightly '
          'small — order one size up.',
      date: DateTime(2026, 2, 14, 12, 30),
      helpfulCount: 33,
      unhelpfulCount: 1,
    ),
  ],
  'prod-coffee-set': [
    MockReview(
      reviewerName: 'Leopold Brandauer',
      rating: 5,
      text:
          'Finally, a proper Kaffeehaus experience at home. The porcelain '
          'is thin and elegant. I now judge my own guests.',
      date: DateTime(2026, 3, 18, 8),
      helpfulCount: 12,
    ),
  ],
  'prod-mozartkugeln': [
    MockReview(
      reviewerName: 'Waltraud Pichler',
      rating: 3,
      text:
          'Tasty, but they melted a bit during shipping. Packaging '
          'could use more insulation for summer orders.',
      date: DateTime(2026, 3, 12, 15, 45),
      helpfulCount: 8,
      unhelpfulCount: 2,
    ),
    MockReview(
      reviewerName: 'Stefan Huber',
      rating: 5,
      text:
          'Brought these to a dinner party in Berlin. The Germans were '
          'impressed, which is the highest praise you can get.',
      date: DateTime(2026, 2, 25, 19, 30),
      helpfulCount: 24,
    ),
  ],
};

/// Free shipping threshold in EUR.
const kFreeShippingThreshold = 100.0;

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
  final subtotal = items.fold<double>(0, (sum, item) => sum + item.totalPrice);

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
  'SCHNITZEL': (discount: 0.05, message: '5 % off — a crispy little saving.'),
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
