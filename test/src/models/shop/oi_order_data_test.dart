// Why: Test files are not part of the public API surface; requiring doc comments on every test group and helper closure would add noise without value.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/models/oi_address_data.dart';
import 'package:obers_ui/src/models/oi_cart_item.dart';
import 'package:obers_ui/src/models/oi_cart_summary.dart';
import 'package:obers_ui/src/models/oi_order_data.dart';
import 'package:obers_ui/src/models/oi_payment_method.dart';
import 'package:obers_ui/src/models/oi_shipping_method.dart';

// ── Fixtures ────────────────────────────────────────────────────────────────

const _address = OiAddressData(
  firstName: 'Jane',
  lastName: 'Doe',
  line1: '123 Main St',
  city: 'Zürich',
  postalCode: '8001',
  country: 'CH',
);

const _item = OiCartItem(productKey: 'p1', name: 'Widget', unitPrice: 29.99);

const _summary = OiCartSummary(subtotal: 29.99, total: 29.99);

const _payment = OiPaymentMethod(key: 'visa', label: 'Visa');

const _shipping = OiShippingMethod(
  key: 'standard',
  label: 'Standard',
  price: 5,
);

OiOrderData _makeOrder({
  OiOrderStatus status = OiOrderStatus.pending,
  List<OiOrderEvent>? timeline,
}) {
  return OiOrderData(
    key: 'ord-1',
    orderNumber: 'ORD-2024-001',
    createdAt: DateTime(2024),
    status: status,
    items: const [_item],
    summary: _summary,
    shippingAddress: _address,
    paymentMethod: _payment,
    shippingMethod: _shipping,
    timeline: timeline,
  );
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('OiOrderStatus', () {
    test('has all expected values', () {
      expect(OiOrderStatus.values, hasLength(7));
      expect(
        OiOrderStatus.values.map((s) => s.name),
        containsAll([
          'pending',
          'confirmed',
          'processing',
          'shipped',
          'delivered',
          'cancelled',
          'refunded',
        ]),
      );
    });
  });

  group('OiOrderEvent', () {
    test('constructor and field access', () {
      final event = OiOrderEvent(
        timestamp: DateTime(2024, 1, 15),
        title: 'Shipped',
        status: OiOrderStatus.shipped,
        description: 'Package dispatched',
      );
      expect(event.timestamp, DateTime(2024, 1, 15));
      expect(event.title, 'Shipped');
      expect(event.status, OiOrderStatus.shipped);
      expect(event.description, 'Package dispatched');
    });

    test('copyWith replaces fields', () {
      final event = OiOrderEvent(
        timestamp: DateTime(2024),
        title: 'Placed',
        status: OiOrderStatus.pending,
      );
      final copy = event.copyWith(title: 'Updated');
      expect(copy.title, 'Updated');
      expect(copy.status, OiOrderStatus.pending);
    });

    test('copyWith can set description to null', () {
      final event = OiOrderEvent(
        timestamp: DateTime(2024),
        title: 'Placed',
        status: OiOrderStatus.pending,
        description: 'Initial',
      );
      final copy = event.copyWith(description: null);
      expect(copy.description, isNull);
    });

    test('equality works', () {
      final a = OiOrderEvent(
        timestamp: DateTime(2024),
        title: 'Placed',
        status: OiOrderStatus.pending,
      );
      final b = OiOrderEvent(
        timestamp: DateTime(2024),
        title: 'Placed',
        status: OiOrderStatus.pending,
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('inequality for different events', () {
      final a = OiOrderEvent(
        timestamp: DateTime(2024),
        title: 'Placed',
        status: OiOrderStatus.pending,
      );
      final b = OiOrderEvent(
        timestamp: DateTime(2024),
        title: 'Shipped',
        status: OiOrderStatus.shipped,
      );
      expect(a, isNot(equals(b)));
    });

    test('toString includes key fields', () {
      final event = OiOrderEvent(
        timestamp: DateTime(2024),
        title: 'Placed',
        status: OiOrderStatus.pending,
      );
      expect(event.toString(), contains('Placed'));
      expect(event.toString(), contains('pending'));
    });
  });

  group('OiOrderData', () {
    test('constructor and field access', () {
      final order = _makeOrder();
      expect(order.key, 'ord-1');
      expect(order.orderNumber, 'ORD-2024-001');
      expect(order.status, OiOrderStatus.pending);
      expect(order.items, hasLength(1));
      expect(order.billingAddress, isNull);
      expect(order.timeline, isNull);
    });

    test('copyWith replaces status', () {
      final order = _makeOrder();
      final copy = order.copyWith(status: OiOrderStatus.shipped);
      expect(copy.status, OiOrderStatus.shipped);
      expect(copy.key, 'ord-1');
    });

    test('copyWith can set billingAddress to null', () {
      final order = _makeOrder().copyWith(billingAddress: _address);
      expect(order.billingAddress, _address);
      final cleared = order.copyWith(billingAddress: null);
      expect(cleared.billingAddress, isNull);
    });

    test('copyWith can set timeline to null', () {
      final events = [
        OiOrderEvent(
          timestamp: DateTime(2024),
          title: 'Placed',
          status: OiOrderStatus.pending,
        ),
      ];
      final order = _makeOrder(timeline: events);
      expect(order.timeline, hasLength(1));
      final cleared = order.copyWith(timeline: null);
      expect(cleared.timeline, isNull);
    });

    test('equality works for equal orders', () {
      final a = _makeOrder();
      final b = _makeOrder();
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('inequality for different statuses', () {
      final a = _makeOrder();
      final b = _makeOrder(status: OiOrderStatus.shipped);
      expect(a, isNot(equals(b)));
    });

    test('toString includes key fields', () {
      final order = _makeOrder();
      expect(order.toString(), contains('ord-1'));
      expect(order.toString(), contains('ORD-2024-001'));
    });
  });
}
