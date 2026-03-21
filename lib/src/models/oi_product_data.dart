import 'package:flutter/foundation.dart';

/// An individual product variant (e.g. "Red / Large").
///
/// Coverage: REQ-0020
///
/// When [price] is `null` the parent [OiProductData.price] applies.
/// When [stockCount] is `null` no stock tracking is implied at variant level.
///
/// {@category Models}
@immutable
class OiProductVariant {
  /// Creates an [OiProductVariant].
  const OiProductVariant({
    required this.key,
    required this.label,
    this.price,
    this.imageUrl,
    this.inStock = true,
    this.stockCount,
    this.attributes = const {},
  });

  /// Unique identifier for this variant.
  final Object key;

  /// Human-readable label (e.g. "Red / Large").
  final String label;

  /// Price override. `null` means use the parent product price.
  final double? price;

  /// Variant-specific image URL.
  final String? imageUrl;

  /// Whether this variant is currently in stock.
  final bool inStock;

  /// Available stock count. `null` means untracked.
  final int? stockCount;

  /// Arbitrary key-value attributes (e.g. `{'Color': 'Red'}`).
  final Map<String, String> attributes;

  /// Returns a copy with the specified fields replaced.
  OiProductVariant copyWith({
    Object? key,
    String? label,
    Object? price = _sentinel,
    Object? imageUrl = _sentinel,
    bool? inStock,
    Object? stockCount = _sentinel,
    Map<String, String>? attributes,
  }) {
    return OiProductVariant(
      key: key ?? this.key,
      label: label ?? this.label,
      price: identical(price, _sentinel) ? this.price : price as double?,
      imageUrl: identical(imageUrl, _sentinel)
          ? this.imageUrl
          : imageUrl as String?,
      inStock: inStock ?? this.inStock,
      stockCount: identical(stockCount, _sentinel)
          ? this.stockCount
          : stockCount as int?,
      attributes: attributes ?? this.attributes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiProductVariant) return false;
    return key == other.key &&
        label == other.label &&
        price == other.price &&
        imageUrl == other.imageUrl &&
        inStock == other.inStock &&
        stockCount == other.stockCount &&
        _mapEquals(attributes, other.attributes);
  }

  @override
  int get hashCode => Object.hash(
    key,
    label,
    price,
    imageUrl,
    inStock,
    stockCount,
    Object.hashAll(attributes.entries.map((e) => Object.hash(e.key, e.value))),
  );

  @override
  String toString() =>
      'OiProductVariant(key: $key, label: $label, price: $price, '
      'inStock: $inStock)';
}

/// A product in the shop catalog.
///
/// Coverage: REQ-0020
///
/// All data flows in via props — no direct coupling to any backend.
///
/// {@category Models}
@immutable
class OiProductData {
  /// Creates an [OiProductData].
  const OiProductData({
    required this.key,
    required this.name,
    required this.price,
    this.description,
    this.compareAtPrice,
    this.currencyCode = 'USD',
    this.imageUrl,
    this.imageUrls = const [],
    this.variants = const [],
    this.attributes = const {},
    this.inStock = true,
    this.stockCount,
    this.rating,
    this.reviewCount,
    this.tags = const [],
    this.sku,
  });

  /// Unique identifier for this product.
  final Object key;

  /// Product name / title.
  final String name;

  /// Optional product description.
  final String? description;

  /// Current selling price.
  final double price;

  /// Strikethrough "was" price (e.g. before a sale).
  final double? compareAtPrice;

  /// ISO 4217 currency code.
  final String currencyCode;

  /// Primary image URL.
  final String? imageUrl;

  /// Gallery image URLs.
  final List<String> imageUrls;

  /// Available product variants.
  final List<OiProductVariant> variants;

  /// Arbitrary key-value attributes (e.g. `{'Color': 'Red'}`).
  final Map<String, String> attributes;

  /// Whether this product is currently in stock.
  final bool inStock;

  /// Available stock count. `null` means untracked.
  final int? stockCount;

  /// Average rating (e.g. 4.5 out of 5).
  final double? rating;

  /// Number of reviews.
  final int? reviewCount;

  /// Searchable tags.
  final List<String> tags;

  /// Stock-keeping unit identifier.
  final String? sku;

  /// Returns a copy with the specified fields replaced.
  OiProductData copyWith({
    Object? key,
    String? name,
    Object? description = _sentinel,
    double? price,
    Object? compareAtPrice = _sentinel,
    String? currencyCode,
    Object? imageUrl = _sentinel,
    List<String>? imageUrls,
    List<OiProductVariant>? variants,
    Map<String, String>? attributes,
    bool? inStock,
    Object? stockCount = _sentinel,
    Object? rating = _sentinel,
    Object? reviewCount = _sentinel,
    List<String>? tags,
    Object? sku = _sentinel,
  }) {
    return OiProductData(
      key: key ?? this.key,
      name: name ?? this.name,
      description: identical(description, _sentinel)
          ? this.description
          : description as String?,
      price: price ?? this.price,
      compareAtPrice: identical(compareAtPrice, _sentinel)
          ? this.compareAtPrice
          : compareAtPrice as double?,
      currencyCode: currencyCode ?? this.currencyCode,
      imageUrl: identical(imageUrl, _sentinel)
          ? this.imageUrl
          : imageUrl as String?,
      imageUrls: imageUrls ?? this.imageUrls,
      variants: variants ?? this.variants,
      attributes: attributes ?? this.attributes,
      inStock: inStock ?? this.inStock,
      stockCount: identical(stockCount, _sentinel)
          ? this.stockCount
          : stockCount as int?,
      rating: identical(rating, _sentinel) ? this.rating : rating as double?,
      reviewCount: identical(reviewCount, _sentinel)
          ? this.reviewCount
          : reviewCount as int?,
      tags: tags ?? this.tags,
      sku: identical(sku, _sentinel) ? this.sku : sku as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiProductData) return false;
    return key == other.key &&
        name == other.name &&
        description == other.description &&
        price == other.price &&
        compareAtPrice == other.compareAtPrice &&
        currencyCode == other.currencyCode &&
        imageUrl == other.imageUrl &&
        listEquals(imageUrls, other.imageUrls) &&
        listEquals(variants, other.variants) &&
        _mapEquals(attributes, other.attributes) &&
        inStock == other.inStock &&
        stockCount == other.stockCount &&
        rating == other.rating &&
        reviewCount == other.reviewCount &&
        listEquals(tags, other.tags) &&
        sku == other.sku;
  }

  @override
  int get hashCode => Object.hash(
    key,
    name,
    description,
    price,
    compareAtPrice,
    currencyCode,
    imageUrl,
    Object.hashAll(imageUrls),
    Object.hashAll(variants),
    Object.hashAll(attributes.entries.map((e) => Object.hash(e.key, e.value))),
    inStock,
    stockCount,
    rating,
    reviewCount,
    Object.hashAll(tags),
    sku,
  );

  @override
  String toString() =>
      'OiProductData(key: $key, name: $name, price: $price, '
      'currencyCode: $currencyCode, inStock: $inStock)';
}

// ── Private helpers ──────────────────────────────────────────────────────────

bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key) || b[key] != a[key]) return false;
  }
  return true;
}

/// Sentinel used by `copyWith` to distinguish an explicit `null` from
/// "not provided".
const Object _sentinel = Object();
