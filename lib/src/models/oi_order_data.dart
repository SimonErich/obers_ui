import 'package:flutter/foundation.dart';

import 'package:obers_ui/src/models/oi_address_data.dart';
import 'package:obers_ui/src/models/oi_cart_item.dart';
import 'package:obers_ui/src/models/oi_cart_summary.dart';
import 'package:obers_ui/src/models/oi_payment_method.dart';
import 'package:obers_ui/src/models/oi_shipping_method.dart';

/// The lifecycle status of an order.
///
/// {@category Models}
enum OiOrderStatus {
  /// Order placed but not yet confirmed.
  pending,

  /// Order confirmed by the merchant.
  confirmed,

  /// Order is being prepared.
  processing,

  /// Order has been shipped.
  shipped,

  /// Order has been delivered.
  delivered,

  /// Order was cancelled.
  cancelled,

  /// Order was refunded.
  refunded,
}

/// A timestamped event in an order's lifecycle.
///
/// {@category Models}
@immutable
class OiOrderEvent {
  /// Creates an [OiOrderEvent].
  const OiOrderEvent({
    required this.timestamp,
    required this.title,
    required this.status,
    this.description,
  });

  /// When the event occurred.
  final DateTime timestamp;

  /// Short label for the event (e.g. "Shipped").
  final String title;

  /// Optional longer description.
  final String? description;

  /// The order status at the time of this event.
  final OiOrderStatus status;

  /// Returns a copy with the specified fields replaced.
  OiOrderEvent copyWith({
    DateTime? timestamp,
    String? title,
    Object? description = _sentinel,
    OiOrderStatus? status,
  }) {
    return OiOrderEvent(
      timestamp: timestamp ?? this.timestamp,
      title: title ?? this.title,
      description: identical(description, _sentinel)
          ? this.description
          : description as String?,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiOrderEvent) return false;
    return timestamp == other.timestamp &&
        title == other.title &&
        description == other.description &&
        status == other.status;
  }

  @override
  int get hashCode => Object.hash(timestamp, title, description, status);

  @override
  String toString() =>
      'OiOrderEvent(timestamp: $timestamp, title: $title, status: $status)';
}

/// Aggregated order data produced by the checkout flow.
///
/// Coverage: REQ-0007, REQ-0067
///
/// Contains the shipping and billing addresses, selected shipping and payment
/// methods, the cart items, the cart summary, and order lifecycle metadata.
///
/// {@category Models}
@immutable
class OiOrderData {
  /// Creates an [OiOrderData].
  const OiOrderData({
    required this.key,
    required this.orderNumber,
    required this.createdAt,
    required this.status,
    required this.items,
    required this.summary,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.shippingMethod,
    this.billingAddress,
    this.timeline,
  });

  /// Unique identifier for this order.
  final Object key;

  /// Human-readable order number (e.g. "ORD-2024-001").
  final String orderNumber;

  /// When the order was placed.
  final DateTime createdAt;

  /// Current lifecycle status of the order.
  final OiOrderStatus status;

  /// The cart items included in the order.
  final List<OiCartItem> items;

  /// The cart summary totals.
  final OiCartSummary summary;

  /// The shipping address.
  final OiAddressData shippingAddress;

  /// The billing address. When `null` the shipping address is used.
  final OiAddressData? billingAddress;

  /// The selected payment method.
  final OiPaymentMethod paymentMethod;

  /// The selected shipping method.
  final OiShippingMethod shippingMethod;

  /// Chronological list of order lifecycle events.
  final List<OiOrderEvent>? timeline;

  /// Returns a copy with the specified fields replaced.
  OiOrderData copyWith({
    Object? key,
    String? orderNumber,
    DateTime? createdAt,
    OiOrderStatus? status,
    List<OiCartItem>? items,
    OiCartSummary? summary,
    OiAddressData? shippingAddress,
    Object? billingAddress = _sentinel,
    OiPaymentMethod? paymentMethod,
    OiShippingMethod? shippingMethod,
    Object? timeline = _sentinel,
  }) {
    return OiOrderData(
      key: key ?? this.key,
      orderNumber: orderNumber ?? this.orderNumber,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      items: items ?? this.items,
      summary: summary ?? this.summary,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: identical(billingAddress, _sentinel)
          ? this.billingAddress
          : billingAddress as OiAddressData?,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      shippingMethod: shippingMethod ?? this.shippingMethod,
      timeline: identical(timeline, _sentinel)
          ? this.timeline
          : timeline as List<OiOrderEvent>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiOrderData) return false;
    return key == other.key &&
        orderNumber == other.orderNumber &&
        createdAt == other.createdAt &&
        status == other.status &&
        listEquals(items, other.items) &&
        summary == other.summary &&
        shippingAddress == other.shippingAddress &&
        billingAddress == other.billingAddress &&
        paymentMethod == other.paymentMethod &&
        shippingMethod == other.shippingMethod &&
        listEquals(timeline, other.timeline);
  }

  @override
  int get hashCode => Object.hash(
    key,
    orderNumber,
    createdAt,
    status,
    Object.hashAll(items),
    summary,
    shippingAddress,
    billingAddress,
    paymentMethod,
    shippingMethod,
    timeline == null ? null : Object.hashAll(timeline!),
  );

  @override
  String toString() =>
      'OiOrderData(key: $key, orderNumber: $orderNumber, '
      'status: $status, items: ${items.length} items)';
}

/// Sentinel used by copyWith methods to distinguish an explicit `null`
/// from "not provided".
const Object _sentinel = Object();
