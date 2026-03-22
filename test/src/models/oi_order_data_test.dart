// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/models/oi_address_data.dart';
import 'package:obers_ui/src/models/oi_cart_item.dart';
import 'package:obers_ui/src/models/oi_cart_summary.dart';
import 'package:obers_ui/src/models/oi_order_data.dart';
import 'package:obers_ui/src/models/oi_payment_method.dart';
import 'package:obers_ui/src/models/oi_shipping_method.dart';

OiOrderData _makeOrder({
  Object key = 'order-1',
  String orderNumber = 'ORD-001',
  DateTime? createdAt,
  OiOrderStatus status = OiOrderStatus.pending,
  OiAddressData? billingAddress,
  List<OiOrderEvent>? timeline,
}) {
  return OiOrderData(
    key: key,
    orderNumber: orderNumber,
    createdAt: createdAt ?? DateTime(2026, 1, 15),
    status: status,
    items: const [
      OiCartItem(productKey: 'p1', name: 'Widget', unitPrice: 10),
    ],
    summary: const OiCartSummary(total: 10),
    shippingAddress: const OiAddressData(firstName: 'Jane', lastName: 'Doe'),
    billingAddress: billingAddress,
    paymentMethod: const OiPaymentMethod(key: 'pm1', label: 'Credit Card'),
    shippingMethod: const OiShippingMethod(
      key: 'sm1',
      label: 'Standard',
      price: 5,
    ),
    timeline: timeline,
  );
}

void main() {
  group('OiOrderStatus', () {
    test('has 7 values', () {
      expect(OiOrderStatus.values, hasLength(7));
      expect(
        OiOrderStatus.values,
        containsAll([
          OiOrderStatus.pending,
          OiOrderStatus.confirmed,
          OiOrderStatus.processing,
          OiOrderStatus.shipped,
          OiOrderStatus.delivered,
          OiOrderStatus.cancelled,
          OiOrderStatus.refunded,
        ]),
      );
    });
  });

  group('OiOrderEvent', () {
    OiOrderEvent makeEvent({
      DateTime? timestamp,
      String title = 'Order placed',
      String? description,
      OiOrderStatus status = OiOrderStatus.pending,
    }) {
      return OiOrderEvent(
        timestamp: timestamp ?? DateTime(2026, 1, 15, 10, 30),
        title: title,
        description: description,
        status: status,
      );
    }

    test('default construction with required fields', () {
      final event = makeEvent();
      expect(event.timestamp, DateTime(2026, 1, 15, 10, 30));
      expect(event.title, 'Order placed');
      expect(event.description, isNull);
      expect(event.status, OiOrderStatus.pending);
    });

    test('copyWith replaces fields', () {
      final event = makeEvent();
      final updated = event.copyWith(
        title: 'Shipped',
        status: OiOrderStatus.shipped,
      );
      expect(updated.title, 'Shipped');
      expect(updated.status, OiOrderStatus.shipped);
      expect(updated.timestamp, event.timestamp);
    });

    test('copyWith sets nullable description to null', () {
      final event = makeEvent(description: 'Initial');
      final cleared = event.copyWith(description: null);
      expect(cleared.description, isNull);
    });

    test('equal instances are ==', () {
      final a = makeEvent(description: 'desc');
      final b = makeEvent(description: 'desc');
      expect(a, equals(b));
    });

    test('different instances are not ==', () {
      final a = makeEvent(title: 'A');
      final b = makeEvent(title: 'B');
      expect(a, isNot(equals(b)));
    });

    test('equal instances have the same hashCode', () {
      final a = makeEvent();
      final b = makeEvent();
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString includes key fields', () {
      final event = makeEvent();
      final s = event.toString();
      expect(s, contains('OiOrderEvent'));
      expect(s, contains('Order placed'));
      expect(s, contains('pending'));
    });
  });

  group('OiOrderData', () {
    test('default construction with required fields, timeline null', () {
      final order = _makeOrder();
      expect(order.key, 'order-1');
      expect(order.orderNumber, 'ORD-001');
      expect(order.createdAt, DateTime(2026, 1, 15));
      expect(order.status, OiOrderStatus.pending);
      expect(order.items, hasLength(1));
      expect(order.summary.total, 10.0);
      expect(order.shippingAddress.firstName, 'Jane');
      expect(order.billingAddress, isNull);
      expect(order.paymentMethod.label, 'Credit Card');
      expect(order.shippingMethod.label, 'Standard');
      expect(order.timeline, isNull);
    });

    test('copyWith replaces fields', () {
      final order = _makeOrder();
      final updated = order.copyWith(
        orderNumber: 'ORD-002',
        status: OiOrderStatus.shipped,
      );
      expect(updated.orderNumber, 'ORD-002');
      expect(updated.status, OiOrderStatus.shipped);
      expect(updated.key, order.key);
    });

    test('copyWith sets nullable fields to null', () {
      final order = _makeOrder(
        billingAddress: const OiAddressData(firstName: 'Bill'),
        timeline: [
          OiOrderEvent(
            timestamp: DateTime(2026),
            title: 'Placed',
            status: OiOrderStatus.pending,
          ),
        ],
      );
      final cleared = order.copyWith(billingAddress: null, timeline: null);
      expect(cleared.billingAddress, isNull);
      expect(cleared.timeline, isNull);
    });

    test('equal instances are ==', () {
      final a = _makeOrder();
      final b = _makeOrder();
      expect(a, equals(b));
    });

    test('different instances are not ==', () {
      final a = _makeOrder(orderNumber: 'A');
      final b = _makeOrder(orderNumber: 'B');
      expect(a, isNot(equals(b)));
    });

    test('equal instances have the same hashCode', () {
      final a = _makeOrder();
      final b = _makeOrder();
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString includes key fields', () {
      final s = _makeOrder().toString();
      expect(s, contains('OiOrderData'));
      expect(s, contains('order-1'));
      expect(s, contains('ORD-001'));
      expect(s, contains('pending'));
    });
  });
}
