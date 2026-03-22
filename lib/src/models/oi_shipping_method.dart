import 'package:flutter/widgets.dart';

/// A shipping method option displayed during checkout.
///
/// Coverage: REQ-0004
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
    this.icon,
  });

  /// Unique identifier for this shipping method.
  final Object key;

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

  /// Optional icon for this shipping method.
  final IconData? icon;

  /// Returns a copy with the specified fields replaced.
  OiShippingMethod copyWith({
    Object? key,
    String? label,
    double? price,
    Object? description = _sentinel,
    Object? estimatedDelivery = _sentinel,
    String? currencyCode,
    Object? icon = _sentinel,
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
      icon: identical(icon, _sentinel) ? this.icon : icon as IconData?,
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
        currencyCode == other.currencyCode &&
        icon == other.icon;
  }

  @override
  int get hashCode => Object.hash(
    key,
    label,
    price,
    description,
    estimatedDelivery,
    currencyCode,
    icon,
  );

  @override
  String toString() =>
      'OiShippingMethod(key: $key, label: $label, price: $price)';
}

/// Sentinel used by [OiShippingMethod.copyWith] to distinguish an explicit
/// `null` from "not provided".
const Object _sentinel = Object();
