import 'package:flutter/foundation.dart';

/// A shipping method option displayed during checkout.
///
/// Coverage: REQ-0067
///
/// {@category Models}
@immutable
class OiShippingMethod {
  /// Creates an [OiShippingMethod].
  const OiShippingMethod({
    required this.key,
    required this.label,
    required this.price,
    this.description,
    this.estimatedDelivery,
    this.currencyCode = 'USD',
  });

  /// Unique identifier for this shipping method.
  final String key;

  /// Human-readable label (e.g. "Standard Shipping").
  final String label;

  /// Shipping cost.
  final double price;

  /// Optional description (e.g. "Delivered in 5-7 business days").
  final String? description;

  /// Estimated delivery timeframe (e.g. "3-5 days").
  final String? estimatedDelivery;

  /// ISO 4217 currency code. Defaults to `'USD'`.
  final String currencyCode;

  /// Returns a copy with the specified fields replaced.
  OiShippingMethod copyWith({
    String? key,
    String? label,
    double? price,
    Object? description = _sentinel,
    Object? estimatedDelivery = _sentinel,
    String? currencyCode,
  }) {
    return OiShippingMethod(
      key: key ?? this.key,
      label: label ?? this.label,
      price: price ?? this.price,
      description: identical(description, _sentinel)
          ? this.description
          : description as String?,
      estimatedDelivery: identical(estimatedDelivery, _sentinel)
          ? this.estimatedDelivery
          : estimatedDelivery as String?,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiShippingMethod) return false;
    return key == other.key &&
        label == other.label &&
        price == other.price &&
        description == other.description &&
        estimatedDelivery == other.estimatedDelivery &&
        currencyCode == other.currencyCode;
  }

  @override
  int get hashCode => Object.hash(
    key,
    label,
    price,
    description,
    estimatedDelivery,
    currencyCode,
  );

  @override
  String toString() =>
      'OiShippingMethod(key: $key, label: $label, price: $price)';
}

/// Sentinel used by [OiShippingMethod.copyWith] to distinguish an explicit
/// `null` from "not provided".
const Object _sentinel = Object();
