import 'package:flutter/foundation.dart';

import 'package:obers_ui/src/models/oi_address_data.dart';
import 'package:obers_ui/src/models/oi_cart_item.dart';
import 'package:obers_ui/src/models/oi_cart_summary.dart';
import 'package:obers_ui/src/models/oi_payment_method.dart';
import 'package:obers_ui/src/models/oi_shipping_method.dart';

/// Aggregated order data produced by the checkout flow.
///
/// Coverage: REQ-0067
///
/// Contains the shipping and billing addresses, selected shipping and payment
/// methods, the cart items, and the cart summary.
///
/// {@category Models}
@immutable
class OiOrderData {
  /// Creates an [OiOrderData].
  const OiOrderData({
    required this.shippingAddress,
    required this.shippingMethod,
    required this.paymentMethod,
    required this.items,
    required this.summary,
    this.billingAddress,
  });

  /// The shipping address.
  final OiAddressData shippingAddress;

  /// The billing address. When `null` the shipping address is used.
  final OiAddressData? billingAddress;

  /// The selected shipping method.
  final OiShippingMethod shippingMethod;

  /// The selected payment method.
  final OiPaymentMethod paymentMethod;

  /// The cart items included in the order.
  final List<OiCartItem> items;

  /// The cart summary totals.
  final OiCartSummary summary;

  /// Returns a copy with the specified fields replaced.
  OiOrderData copyWith({
    OiAddressData? shippingAddress,
    Object? billingAddress = _sentinel,
    OiShippingMethod? shippingMethod,
    OiPaymentMethod? paymentMethod,
    List<OiCartItem>? items,
    OiCartSummary? summary,
  }) {
    return OiOrderData(
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: identical(billingAddress, _sentinel)
          ? this.billingAddress
          : billingAddress as OiAddressData?,
      shippingMethod: shippingMethod ?? this.shippingMethod,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      items: items ?? this.items,
      summary: summary ?? this.summary,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiOrderData) return false;
    return shippingAddress == other.shippingAddress &&
        billingAddress == other.billingAddress &&
        shippingMethod == other.shippingMethod &&
        paymentMethod == other.paymentMethod &&
        listEquals(items, other.items) &&
        summary == other.summary;
  }

  @override
  int get hashCode => Object.hash(
    shippingAddress,
    billingAddress,
    shippingMethod,
    paymentMethod,
    Object.hashAll(items),
    summary,
  );

  @override
  String toString() =>
      'OiOrderData(shippingAddress: $shippingAddress, '
      'shippingMethod: $shippingMethod, '
      'paymentMethod: $paymentMethod, '
      'items: ${items.length} items)';
}

/// Sentinel used by [OiOrderData.copyWith] to distinguish an explicit `null`
/// from "not provided".
const Object _sentinel = Object();
