// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/models/oi_cart_item.dart';

void main() {
  group('OiCartItem', () {
    test('default construction has expected defaults', () {
      const item = OiCartItem(
        productKey: 'p1',
        name: 'Widget',
        unitPrice: 19.99,
      );
      expect(item.productKey, 'p1');
      expect(item.variantKey, isNull);
      expect(item.name, 'Widget');
      expect(item.variantLabel, isNull);
      expect(item.unitPrice, 19.99);
      expect(item.quantity, 1);
      expect(item.imageUrl, isNull);
      expect(item.maxQuantity, isNull);
      expect(item.attributes, isNull);
    });

    test('totalPrice is unitPrice * quantity', () {
      const item = OiCartItem(
        productKey: 'p1',
        name: 'Widget',
        unitPrice: 10.0,
        quantity: 3,
      );
      expect(item.totalPrice, 30.0);
    });

    test('totalPrice with default quantity is unitPrice', () {
      const item = OiCartItem(
        productKey: 'p1',
        name: 'Widget',
        unitPrice: 7.50,
      );
      expect(item.totalPrice, 7.50);
    });

    test('copyWith replaces fields', () {
      const item = OiCartItem(
        productKey: 'p1',
        name: 'Widget',
        unitPrice: 10.0,
        quantity: 2,
      );
      final updated = item.copyWith(quantity: 5, unitPrice: 12.0);
      expect(updated.quantity, 5);
      expect(updated.unitPrice, 12.0);
      expect(updated.productKey, 'p1');
      expect(updated.name, 'Widget');
    });

    test('copyWith can set nullable fields to null via sentinel', () {
      const item = OiCartItem(
        productKey: 'p1',
        variantKey: 'v1',
        name: 'Widget',
        variantLabel: 'Red / Large',
        unitPrice: 10.0,
        imageUrl: 'http://img.png',
        maxQuantity: 5,
      );
      final cleared = item.copyWith(
        variantKey: null,
        variantLabel: null,
        imageUrl: null,
        maxQuantity: null,
      );
      expect(cleared.variantKey, isNull);
      expect(cleared.variantLabel, isNull);
      expect(cleared.imageUrl, isNull);
      expect(cleared.maxQuantity, isNull);
    });

    test('copyWith preserves unchanged fields', () {
      const item = OiCartItem(
        productKey: 'p1',
        variantKey: 'v1',
        name: 'Widget',
        variantLabel: 'Red',
        unitPrice: 10.0,
        quantity: 2,
        imageUrl: 'http://img.png',
        maxQuantity: 5,
        attributes: {'Color': 'Red'},
      );
      final updated = item.copyWith(quantity: 3);
      expect(updated.productKey, 'p1');
      expect(updated.variantKey, 'v1');
      expect(updated.variantLabel, 'Red');
      expect(updated.unitPrice, 10.0);
      expect(updated.imageUrl, 'http://img.png');
      expect(updated.maxQuantity, 5);
      expect(updated.attributes, {'Color': 'Red'});
    });

    test('equal instances are ==', () {
      const a = OiCartItem(
        productKey: 'p1',
        variantKey: 'v1',
        name: 'Widget',
        unitPrice: 10.0,
        quantity: 2,
        attributes: {'Color': 'Red'},
      );
      const b = OiCartItem(
        productKey: 'p1',
        variantKey: 'v1',
        name: 'Widget',
        unitPrice: 10.0,
        quantity: 2,
        attributes: {'Color': 'Red'},
      );
      expect(a, equals(b));
    });

    test('different instances are not ==', () {
      const a = OiCartItem(productKey: 'p1', name: 'Widget', unitPrice: 10.0);
      const b = OiCartItem(productKey: 'p1', name: 'Widget', unitPrice: 11.0);
      expect(a, isNot(equals(b)));
    });

    test('equal instances have the same hashCode', () {
      const a = OiCartItem(
        productKey: 'p1',
        name: 'Widget',
        unitPrice: 10.0,
        quantity: 3,
      );
      const b = OiCartItem(
        productKey: 'p1',
        name: 'Widget',
        unitPrice: 10.0,
        quantity: 3,
      );
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString includes totalPrice', () {
      const item = OiCartItem(
        productKey: 'p1',
        name: 'Widget',
        unitPrice: 10.0,
        quantity: 3,
      );
      expect(item.toString(), contains('totalPrice: 30.0'));
    });
  });
}
