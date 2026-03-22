import 'package:flutter/foundation.dart';

/// A single item in the shopping cart.
///
/// Coverage: REQ-0002, REQ-0050
///
/// All data flows in via props — no direct coupling to any backend.
///
/// {@category Models}
@immutable
class OiCartItem {
  /// Creates an [OiCartItem].
  const OiCartItem({
    required this.productKey,
    required this.name,
    required this.unitPrice,
    this.variantKey,
    this.variantLabel,
    this.quantity = 1,
    this.imageUrl,
    this.maxQuantity,
    this.attributes,
  });

  /// Identifier of the product this item represents.
  final Object productKey;

  /// Identifier of the selected variant, or `null` if none.
  final Object? variantKey;

  /// Display name of the product.
  final String name;

  /// Human-readable variant label (e.g. "Red / Large").
  final String? variantLabel;

  /// Price per unit.
  final double unitPrice;

  /// Number of units in the cart.
  final int quantity;

  /// Product image URL.
  final String? imageUrl;

  /// Maximum quantity allowed (stock limit). `null` means unlimited.
  final int? maxQuantity;

  /// Arbitrary key-value attributes (e.g. `{'Color': 'Red'}`). `null` means
  /// not applicable.
  final Map<String, String>? attributes;

  /// Total price for this line item (`unitPrice * quantity`).
  double get lineTotal => unitPrice * quantity;

  /// Returns a copy with the specified fields replaced.
  OiCartItem copyWith({
    Object? productKey,
    Object? variantKey = _sentinel,
    String? name,
    Object? variantLabel = _sentinel,
    double? unitPrice,
    int? quantity,
    Object? imageUrl = _sentinel,
    Object? maxQuantity = _sentinel,
    Object? attributes = _sentinel,
  }) {
    return OiCartItem(
      productKey: productKey ?? this.productKey,
      variantKey: identical(variantKey, _sentinel)
          ? this.variantKey
          : variantKey,
      name: name ?? this.name,
      variantLabel: identical(variantLabel, _sentinel)
          ? this.variantLabel
          : variantLabel as String?,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      imageUrl: identical(imageUrl, _sentinel)
          ? this.imageUrl
          : imageUrl as String?,
      maxQuantity: identical(maxQuantity, _sentinel)
          ? this.maxQuantity
          : maxQuantity as int?,
      attributes: identical(attributes, _sentinel)
          ? this.attributes
          : attributes as Map<String, String>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiCartItem) return false;
    return productKey == other.productKey &&
        variantKey == other.variantKey &&
        name == other.name &&
        variantLabel == other.variantLabel &&
        unitPrice == other.unitPrice &&
        quantity == other.quantity &&
        imageUrl == other.imageUrl &&
        maxQuantity == other.maxQuantity &&
        _nullableMapEquals(attributes, other.attributes);
  }

  @override
  int get hashCode => Object.hash(
    productKey,
    variantKey,
    name,
    variantLabel,
    unitPrice,
    quantity,
    imageUrl,
    maxQuantity,
    attributes == null
        ? null
        : Object.hashAll(
            attributes!.entries.map((e) => Object.hash(e.key, e.value)),
          ),
  );

  @override
  String toString() =>
      'OiCartItem(productKey: $productKey, name: $name, '
      'unitPrice: $unitPrice, quantity: $quantity, lineTotal: $lineTotal)';
}

// ── Private helpers ──────────────────────────────────────────────────────────

bool _nullableMapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key) || b[key] != a[key]) return false;
  }
  return true;
}

/// Sentinel used by [OiCartItem.copyWith] to distinguish an explicit `null`
/// from "not provided".
const Object _sentinel = Object();
