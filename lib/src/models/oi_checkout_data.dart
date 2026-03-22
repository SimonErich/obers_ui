import 'package:flutter/foundation.dart';
import 'package:obers_ui/obers_ui.dart' show OiCheckout;

import 'package:obers_ui/src/models/oi_address_data.dart';
import 'package:obers_ui/src/models/oi_payment_method.dart';
import 'package:obers_ui/src/models/oi_shipping_method.dart';
import 'package:obers_ui/src/modules/oi_checkout.dart' show OiCheckout;

/// Aggregated checkout selections collected during the checkout flow.
///
/// Coverage: REQ-0014
///
/// Captures the shipping and billing addresses, and the selected shipping
/// and payment methods. Passed to [OiCheckout.onPlaceOrder] when the user
/// submits the order.
///
/// {@category Models}
@immutable
class OiCheckoutData {
  /// Creates an [OiCheckoutData].
  const OiCheckoutData({
    required this.shippingAddress,
    required this.billingAddress,
    required this.shippingMethod,
    required this.paymentMethod,
  });

  /// The shipping address entered by the user.
  final OiAddressData shippingAddress;

  /// The billing address. Same as [shippingAddress] when the user checked
  /// "same as shipping".
  final OiAddressData billingAddress;

  /// The selected shipping method.
  final OiShippingMethod shippingMethod;

  /// The selected payment method.
  final OiPaymentMethod paymentMethod;

  /// Returns a copy with the specified fields replaced.
  OiCheckoutData copyWith({
    OiAddressData? shippingAddress,
    OiAddressData? billingAddress,
    OiShippingMethod? shippingMethod,
    OiPaymentMethod? paymentMethod,
  }) {
    return OiCheckoutData(
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      shippingMethod: shippingMethod ?? this.shippingMethod,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiCheckoutData) return false;
    return shippingAddress == other.shippingAddress &&
        billingAddress == other.billingAddress &&
        shippingMethod == other.shippingMethod &&
        paymentMethod == other.paymentMethod;
  }

  @override
  int get hashCode => Object.hash(
    shippingAddress,
    billingAddress,
    shippingMethod,
    paymentMethod,
  );

  @override
  String toString() =>
      'OiCheckoutData(shippingAddress: $shippingAddress, '
      'billingAddress: $billingAddress, '
      'shippingMethod: $shippingMethod, '
      'paymentMethod: $paymentMethod)';
}
