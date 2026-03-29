// Tests do not require documentation comments.

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/models/oi_product_data.dart';

void main() {
  group('OiProductVariant', () {
    test('default construction has expected defaults', () {
      const v = OiProductVariant(key: 'v1', label: 'Red');
      expect(v.key, 'v1');
      expect(v.label, 'Red');
      expect(v.price, isNull);
      expect(v.imageUrl, isNull);
      expect(v.inStock, isTrue);
      expect(v.stockCount, isNull);
      expect(v.attributes, isEmpty);
    });

    test('copyWith replaces individual fields', () {
      const v = OiProductVariant(key: 'v1', label: 'Red', price: 9.99);
      final updated = v.copyWith(label: 'Blue', price: 12.99);
      expect(updated.key, 'v1');
      expect(updated.label, 'Blue');
      expect(updated.price, 12.99);
    });

    test('copyWith can set nullable fields to null via sentinel', () {
      const v = OiProductVariant(
        key: 'v1',
        label: 'Red',
        price: 9.99,
        imageUrl: 'http://img.png',
        stockCount: 5,
      );
      final cleared = v.copyWith(price: null, imageUrl: null, stockCount: null);
      expect(cleared.price, isNull);
      expect(cleared.imageUrl, isNull);
      expect(cleared.stockCount, isNull);
    });

    test('copyWith preserves unchanged fields', () {
      const v = OiProductVariant(
        key: 'v1',
        label: 'Red',
        price: 9.99,
        imageUrl: 'http://img.png',
        inStock: false,
        stockCount: 0,
        attributes: {'Color': 'Red'},
      );
      final updated = v.copyWith(label: 'Blue');
      expect(updated.key, 'v1');
      expect(updated.price, 9.99);
      expect(updated.imageUrl, 'http://img.png');
      expect(updated.inStock, isFalse);
      expect(updated.stockCount, 0);
      expect(updated.attributes, {'Color': 'Red'});
    });

    test('equal instances are ==', () {
      const a = OiProductVariant(
        key: 'v1',
        label: 'Red',
        attributes: {'Color': 'Red'},
      );
      const b = OiProductVariant(
        key: 'v1',
        label: 'Red',
        attributes: {'Color': 'Red'},
      );
      expect(a, equals(b));
    });

    test('different instances are not ==', () {
      const a = OiProductVariant(key: 'v1', label: 'Red');
      const b = OiProductVariant(key: 'v1', label: 'Blue');
      expect(a, isNot(equals(b)));
    });

    test('equal instances have the same hashCode', () {
      const a = OiProductVariant(
        key: 'v1',
        label: 'Red',
        price: 5,
        attributes: {'Size': 'L'},
      );
      const b = OiProductVariant(
        key: 'v1',
        label: 'Red',
        price: 5,
        attributes: {'Size': 'L'},
      );
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString includes key fields', () {
      const v = OiProductVariant(key: 'v1', label: 'Red', price: 5);
      expect(v.toString(), contains('v1'));
      expect(v.toString(), contains('Red'));
    });
  });

  group('OiProductData', () {
    test('default construction has expected defaults', () {
      const p = OiProductData(key: 'p1', name: 'Widget', price: 19.99);
      expect(p.key, 'p1');
      expect(p.name, 'Widget');
      expect(p.description, isNull);
      expect(p.price, 19.99);
      expect(p.compareAtPrice, isNull);
      expect(p.currencyCode, 'USD');
      expect(p.imageUrl, isNull);
      expect(p.imageUrls, isEmpty);
      expect(p.variants, isEmpty);
      expect(p.attributes, isEmpty);
      expect(p.inStock, isTrue);
      expect(p.stockCount, isNull);
      expect(p.rating, isNull);
      expect(p.reviewCount, isNull);
      expect(p.tags, isEmpty);
      expect(p.sku, isNull);
    });

    test('full construction with all fields', () {
      const variant = OiProductVariant(key: 'v1', label: 'Red');
      const p = OiProductData(
        key: 'p1',
        name: 'Widget',
        description: 'A great widget',
        price: 19.99,
        compareAtPrice: 29.99,
        currencyCode: 'EUR',
        imageUrl: 'http://img.png',
        imageUrls: ['http://a.png', 'http://b.png'],
        variants: [variant],
        attributes: {'Color': 'Red'},
        inStock: false,
        stockCount: 42,
        rating: 4.5,
        reviewCount: 100,
        tags: ['sale', 'new'],
        sku: 'WDG-001',
      );
      expect(p.description, 'A great widget');
      expect(p.compareAtPrice, 29.99);
      expect(p.currencyCode, 'EUR');
      expect(p.imageUrl, 'http://img.png');
      expect(p.imageUrls, hasLength(2));
      expect(p.variants, hasLength(1));
      expect(p.attributes, {'Color': 'Red'});
      expect(p.inStock, isFalse);
      expect(p.stockCount, 42);
      expect(p.rating, 4.5);
      expect(p.reviewCount, 100);
      expect(p.tags, ['sale', 'new']);
      expect(p.sku, 'WDG-001');
    });

    test('copyWith replaces individual fields', () {
      const p = OiProductData(key: 'p1', name: 'Widget', price: 19.99);
      final updated = p.copyWith(name: 'Gadget', price: 29.99);
      expect(updated.name, 'Gadget');
      expect(updated.price, 29.99);
      expect(updated.key, 'p1');
    });

    test('copyWith can set all nullable fields to null', () {
      const p = OiProductData(
        key: 'p1',
        name: 'Widget',
        price: 19.99,
        description: 'desc',
        compareAtPrice: 29.99,
        imageUrl: 'http://img.png',
        stockCount: 10,
        rating: 4,
        reviewCount: 50,
        sku: 'SKU-1',
      );
      final cleared = p.copyWith(
        description: null,
        compareAtPrice: null,
        imageUrl: null,
        stockCount: null,
        rating: null,
        reviewCount: null,
        sku: null,
      );
      expect(cleared.description, isNull);
      expect(cleared.compareAtPrice, isNull);
      expect(cleared.imageUrl, isNull);
      expect(cleared.stockCount, isNull);
      expect(cleared.rating, isNull);
      expect(cleared.reviewCount, isNull);
      expect(cleared.sku, isNull);
    });

    test('copyWith replaces variants and attributes', () {
      const p = OiProductData(
        key: 'p1',
        name: 'Widget',
        price: 19.99,
        variants: [OiProductVariant(key: 'v1', label: 'Red')],
        attributes: {'Color': 'Red'},
      );
      final updated = p.copyWith(
        variants: [const OiProductVariant(key: 'v2', label: 'Blue')],
        attributes: {'Color': 'Blue'},
      );
      expect(updated.variants, hasLength(1));
      expect(updated.variants.first.label, 'Blue');
      expect(updated.attributes, {'Color': 'Blue'});
    });

    test('equal instances with same variants are ==', () {
      const variant = OiProductVariant(key: 'v1', label: 'Red');
      const a = OiProductData(
        key: 'p1',
        name: 'Widget',
        price: 19.99,
        variants: [variant],
        tags: ['sale'],
        attributes: {'Color': 'Red'},
      );
      const b = OiProductData(
        key: 'p1',
        name: 'Widget',
        price: 19.99,
        variants: [variant],
        tags: ['sale'],
        attributes: {'Color': 'Red'},
      );
      expect(a, equals(b));
    });

    test('instances with different variants are not ==', () {
      const a = OiProductData(
        key: 'p1',
        name: 'Widget',
        price: 19.99,
        variants: [OiProductVariant(key: 'v1', label: 'Red')],
      );
      const b = OiProductData(
        key: 'p1',
        name: 'Widget',
        price: 19.99,
        variants: [OiProductVariant(key: 'v2', label: 'Blue')],
      );
      expect(a, isNot(equals(b)));
    });

    test('equal instances have the same hashCode', () {
      const a = OiProductData(
        key: 'p1',
        name: 'Widget',
        price: 19.99,
        tags: ['sale'],
      );
      const b = OiProductData(
        key: 'p1',
        name: 'Widget',
        price: 19.99,
        tags: ['sale'],
      );
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString includes key fields', () {
      const p = OiProductData(key: 'p1', name: 'Widget', price: 19.99);
      expect(p.toString(), contains('p1'));
      expect(p.toString(), contains('Widget'));
    });
  });
}
