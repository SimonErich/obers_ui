// Why: Test files are not part of the public API surface; requiring doc comments on every test group and helper closure would add noise without value.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/models/oi_shipping_method.dart';

void main() {
  group('OiShippingMethod', () {
    test('constructor and field access', () {
      const method = OiShippingMethod(
        key: 'standard',
        label: 'Standard Shipping',
        price: 5.99,
        description: '5-7 business days',
        estimatedDelivery: '3-5 days',
      );
      expect(method.key, 'standard');
      expect(method.label, 'Standard Shipping');
      expect(method.price, 5.99);
      expect(method.description, '5-7 business days');
      expect(method.estimatedDelivery, '3-5 days');
      expect(method.currencyCode, 'USD');
      expect(method.icon, isNull);
    });

    test('copyWith replaces specified fields', () {
      const method = OiShippingMethod(
        key: 'standard',
        label: 'Standard',
        price: 5.99,
      );
      final copy = method.copyWith(price: 9.99, label: 'Express');
      expect(copy.price, 9.99);
      expect(copy.label, 'Express');
      expect(copy.key, 'standard');
    });

    test('copyWith can set nullable fields to null', () {
      const method = OiShippingMethod(
        key: 'standard',
        label: 'Standard',
        price: 5.99,
        description: 'Fast',
        estimatedDelivery: '2 days',
        icon: IconData(0xe001),
      );
      final copy = method.copyWith(
        description: null,
        estimatedDelivery: null,
        icon: null,
      );
      expect(copy.description, isNull);
      expect(copy.estimatedDelivery, isNull);
      expect(copy.icon, isNull);
    });

    test('equality works', () {
      const a = OiShippingMethod(
        key: 'standard',
        label: 'Standard',
        price: 5.99,
      );
      const b = OiShippingMethod(
        key: 'standard',
        label: 'Standard',
        price: 5.99,
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('inequality for different methods', () {
      const a = OiShippingMethod(key: 'a', label: 'A', price: 5);
      const b = OiShippingMethod(key: 'b', label: 'B', price: 10);
      expect(a, isNot(equals(b)));
    });

    test('toString includes key fields', () {
      const method = OiShippingMethod(
        key: 'express',
        label: 'Express',
        price: 12.99,
      );
      expect(method.toString(), contains('express'));
      expect(method.toString(), contains('Express'));
      expect(method.toString(), contains('12.99'));
    });
  });
}
