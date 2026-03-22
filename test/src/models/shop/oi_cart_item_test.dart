// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/models/oi_cart_item.dart';

void main() {
  group('OiCartItem', () {
    test('constructor and field access', () {
      const item = OiCartItem(
        productKey: 'p1',
        name: 'Widget',
        unitPrice: 29.99,
        quantity: 2,
      );
      expect(item.productKey, 'p1');
      expect(item.name, 'Widget');
      expect(item.unitPrice, 29.99);
      expect(item.quantity, 2);
      expect(item.variantKey, isNull);
      expect(item.variantLabel, isNull);
      expect(item.imageUrl, isNull);
      expect(item.maxQuantity, isNull);
      expect(item.attributes, isNull);
    });

    test('default quantity is 1', () {
      const item = OiCartItem(
        productKey: 'p1',
        name: 'Widget',
        unitPrice: 10.0,
      );
      expect(item.quantity, 1);
    });

    test('totalPrice calculates correctly', () {
      const item = OiCartItem(
        productKey: 'p1',
        name: 'Widget',
        unitPrice: 10.0,
        quantity: 3,
      );
      expect(item.totalPrice, 30.0);
    });

    test('copyWith replaces specified fields', () {
      const item = OiCartItem(
        productKey: 'p1',
        name: 'Widget',
        unitPrice: 10.0,
      );
      final copy = item.copyWith(quantity: 5, name: 'Gadget');
      expect(copy.quantity, 5);
      expect(copy.name, 'Gadget');
      expect(copy.productKey, 'p1');
    });

    test('copyWith can set nullable fields to null', () {
      const item = OiCartItem(
        productKey: 'p1',
        name: 'Widget',
        unitPrice: 10.0,
        variantKey: 'v1',
        imageUrl: 'https://example.com/img.png',
        maxQuantity: 10,
        attributes: {'Color': 'Red'},
      );
      final copy = item.copyWith(
        variantKey: null,
        imageUrl: null,
        maxQuantity: null,
        attributes: null,
      );
      expect(copy.variantKey, isNull);
      expect(copy.imageUrl, isNull);
      expect(copy.maxQuantity, isNull);
      expect(copy.attributes, isNull);
    });

    test('equality works', () {
      const a = OiCartItem(productKey: 'p1', name: 'Widget', unitPrice: 10.0);
      const b = OiCartItem(productKey: 'p1', name: 'Widget', unitPrice: 10.0);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('equality considers attributes', () {
      const a = OiCartItem(
        productKey: 'p1',
        name: 'Widget',
        unitPrice: 10.0,
        attributes: {'Color': 'Red'},
      );
      const b = OiCartItem(
        productKey: 'p1',
        name: 'Widget',
        unitPrice: 10.0,
        attributes: {'Color': 'Blue'},
      );
      expect(a, isNot(equals(b)));
    });

    test('toString includes key fields', () {
      const item = OiCartItem(
        productKey: 'p1',
        name: 'Widget',
        unitPrice: 10.0,
        quantity: 3,
      );
      final str = item.toString();
      expect(str, contains('p1'));
      expect(str, contains('Widget'));
      expect(str, contains('30.0'));
    });
  });
}
