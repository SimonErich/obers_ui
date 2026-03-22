import 'package:flutter/foundation.dart';

/// A summary of cart totals for display in checkout UIs.
///
/// Coverage: REQ-0003, REQ-0050
///
/// All data flows in via props — no direct coupling to any backend.
///
/// {@category Models}
@immutable
class OiCartSummary {
  /// Creates an [OiCartSummary].
  const OiCartSummary({
    required this.total,
    this.subtotal = 0,
    this.discount,
    this.discountLabel,
    this.shipping,
    this.shippingLabel,
    this.tax,
    this.taxLabel,
    this.currencyCode = 'USD',
  });

  /// Sum of all line items before adjustments.
  final double subtotal;

  /// Discount amount (positive value subtracted from subtotal).
  ///
  /// `null` means no discount is applicable (distinct from a zero discount).
  final double? discount;

  /// Human-readable discount description (e.g. "SUMMER20 (-20%)").
  final String? discountLabel;

  /// Shipping cost.
  ///
  /// `null` means shipping is not applicable (distinct from free shipping).
  final double? shipping;

  /// Human-readable shipping description (e.g. "Express Shipping").
  final String? shippingLabel;

  /// Tax amount.
  ///
  /// `null` means tax is not applicable (distinct from zero tax).
  final double? tax;

  /// Human-readable tax description (e.g. "VAT 20%").
  final String? taxLabel;

  /// Final total after all adjustments.
  final double total;

  /// ISO 4217 currency code.
  final String currencyCode;

  /// Returns a copy with the specified fields replaced.
  OiCartSummary copyWith({
    double? subtotal,
    Object? discount = _sentinel,
    Object? discountLabel = _sentinel,
    Object? shipping = _sentinel,
    Object? shippingLabel = _sentinel,
    Object? tax = _sentinel,
    Object? taxLabel = _sentinel,
    double? total,
    String? currencyCode,
  }) {
    return OiCartSummary(
      subtotal: subtotal ?? this.subtotal,
      discount: identical(discount, _sentinel)
          ? this.discount
          : discount as double?,
      discountLabel: identical(discountLabel, _sentinel)
          ? this.discountLabel
          : discountLabel as String?,
      shipping: identical(shipping, _sentinel)
          ? this.shipping
          : shipping as double?,
      shippingLabel: identical(shippingLabel, _sentinel)
          ? this.shippingLabel
          : shippingLabel as String?,
      tax: identical(tax, _sentinel) ? this.tax : tax as double?,
      taxLabel: identical(taxLabel, _sentinel)
          ? this.taxLabel
          : taxLabel as String?,
      total: total ?? this.total,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiCartSummary) return false;
    return subtotal == other.subtotal &&
        discount == other.discount &&
        discountLabel == other.discountLabel &&
        shipping == other.shipping &&
        shippingLabel == other.shippingLabel &&
        tax == other.tax &&
        taxLabel == other.taxLabel &&
        total == other.total &&
        currencyCode == other.currencyCode;
  }

  @override
  String toString() =>
      'OiCartSummary(subtotal: $subtotal, total: $total, '
      'currencyCode: $currencyCode)';

  @override
  int get hashCode => Object.hash(
    subtotal,
    discount,
    discountLabel,
    shipping,
    shippingLabel,
    tax,
    taxLabel,
    total,
    currencyCode,
  );
}

/// Sentinel used by [OiCartSummary.copyWith] to distinguish an explicit `null`
/// from "not provided".
const Object _sentinel = Object();
