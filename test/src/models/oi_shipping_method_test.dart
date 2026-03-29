// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/models/oi_shipping_method.dart';

void main() {
  group('OiShippingMethod', () {
    test('default construction has expected defaults', () {
      const method = OiShippingMethod(
        key: 'standard',
        label: 'Standard Shipping',
        price: 5.99,
      );
      expect(method.key, 'standard');
      expect(method.label, 'Standard Shipping');
      expect(method.price, 5.99);
      expect(method.description, isNull);
      expect(method.estimatedDelivery, isNull);
      expect(method.currencyCode, 'USD');
      expect(method.icon, isNull);
    });

    test('all fields are stored correctly', () {
      const icon = IconData(0xe001);
      const method = OiShippingMethod(
        key: 'express',
        label: 'Express Shipping',
        price: 14.99,
        description: 'Delivered in 1-2 business days',
        estimatedDelivery: '1-2 days',
        currencyCode: 'EUR',
        icon: icon,
      );
      expect(method.key, 'express');
      expect(method.label, 'Express Shipping');
      expect(method.price, 14.99);
      expect(method.description, 'Delivered in 1-2 business days');
      expect(method.estimatedDelivery, '1-2 days');
      expect(method.currencyCode, 'EUR');
      expect(method.icon, icon);
    });

    test('copyWith replaces non-nullable fields', () {
      const method = OiShippingMethod(
        key: 'standard',
        label: 'Standard',
        price: 5.99,
      );
      final updated = method.copyWith(
        key: 'express',
        label: 'Express',
        price: 14.99,
        currencyCode: 'EUR',
      );
      expect(updated.key, 'express');
      expect(updated.label, 'Express');
      expect(updated.price, 14.99);
      expect(updated.currencyCode, 'EUR');
    });

    test('copyWith can set nullable fields to null via sentinel', () {
      const icon = IconData(0xe001);
      const method = OiShippingMethod(
        key: 'express',
        label: 'Express',
        price: 14.99,
        description: 'Fast delivery',
        estimatedDelivery: '1-2 days',
        icon: icon,
      );
      final cleared = method.copyWith(
        description: null,
        estimatedDelivery: null,
        icon: null,
      );
      expect(cleared.description, isNull);
      expect(cleared.estimatedDelivery, isNull);
      expect(cleared.icon, isNull);
      expect(cleared.key, 'express');
      expect(cleared.label, 'Express');
      expect(cleared.price, 14.99);
    });

    test('copyWith with no args returns equal instance', () {
      const method = OiShippingMethod(
        key: 'standard',
        label: 'Standard',
        price: 5.99,
        description: 'Normal delivery',
      );
      final copy = method.copyWith();
      expect(copy, equals(method));
    });

    test('equal instances are ==', () {
      const a = OiShippingMethod(
        key: 'standard',
        label: 'Standard',
        price: 5.99,
        description: 'Normal',
      );
      const b = OiShippingMethod(
        key: 'standard',
        label: 'Standard',
        price: 5.99,
        description: 'Normal',
      );
      expect(a, equals(b));
    });

    test('equal instances have the same hashCode', () {
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
      expect(a.hashCode, equals(b.hashCode));
    });

    test('different instances are not ==', () {
      const a = OiShippingMethod(
        key: 'standard',
        label: 'Standard',
        price: 5.99,
      );
      const b = OiShippingMethod(
        key: 'express',
        label: 'Express',
        price: 14.99,
      );
      expect(a, isNot(equals(b)));
    });

    test('instances with different icons are not ==', () {
      const a = OiShippingMethod(
        key: 'standard',
        label: 'Standard',
        price: 5.99,
        icon: IconData(0xe001),
      );
      const b = OiShippingMethod(
        key: 'standard',
        label: 'Standard',
        price: 5.99,
        icon: IconData(0xe002),
      );
      expect(a, isNot(equals(b)));
    });

    test('toString includes key, label, price', () {
      const method = OiShippingMethod(
        key: 'standard',
        label: 'Standard',
        price: 5.99,
      );
      final str = method.toString();
      expect(str, contains('standard'));
      expect(str, contains('Standard'));
      expect(str, contains('5.99'));
    });
  });
}
