// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/models/oi_product_data.dart';

void main() {
  group('OiProductVariant', () {
    test('constructor and field access', () {
      const variant = OiProductVariant(
        key: 'v1',
        label: 'Red / Large',
        price: 34.99,
        inStock: true,
        stockCount: 5,
        attributes: {'Color': 'Red', 'Size': 'Large'},
      );
      expect(variant.key, 'v1');
      expect(variant.label, 'Red / Large');
      expect(variant.price, 34.99);
      expect(variant.inStock, isTrue);
      expect(variant.stockCount, 5);
      expect(variant.attributes, hasLength(2));
    });

    test('defaults: price null, inStock true, empty attributes', () {
      const variant = OiProductVariant(key: 'v1', label: 'Default');
      expect(variant.price, isNull);
      expect(variant.inStock, isTrue);
      expect(variant.stockCount, isNull);
      expect(variant.attributes, isEmpty);
    });

    test('copyWith replaces fields', () {
      const variant = OiProductVariant(key: 'v1', label: 'Red');
      final copy = variant.copyWith(label: 'Blue', inStock: false);
      expect(copy.label, 'Blue');
      expect(copy.inStock, isFalse);
      expect(copy.key, 'v1');
    });

    test('copyWith can set nullable fields to null', () {
      const variant = OiProductVariant(
        key: 'v1',
        label: 'Red',
        price: 10.0,
        imageUrl: 'https://example.com/img.png',
        stockCount: 5,
      );
      final copy = variant.copyWith(
        price: null,
        imageUrl: null,
        stockCount: null,
      );
      expect(copy.price, isNull);
      expect(copy.imageUrl, isNull);
      expect(copy.stockCount, isNull);
    });

    test('equality works', () {
      const a = OiProductVariant(key: 'v1', label: 'Red');
      const b = OiProductVariant(key: 'v1', label: 'Red');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('inequality for different variants', () {
      const a = OiProductVariant(key: 'v1', label: 'Red');
      const b = OiProductVariant(key: 'v2', label: 'Blue');
      expect(a, isNot(equals(b)));
    });
  });

  group('OiProductData', () {
    test('constructor and field access', () {
      const product = OiProductData(
        key: 'p1',
        name: 'Widget',
        price: 29.99,
        description: 'A fine widget',
        currencyCode: 'EUR',
        inStock: true,
        rating: 4.5,
        reviewCount: 42,
      );
      expect(product.key, 'p1');
      expect(product.name, 'Widget');
      expect(product.price, 29.99);
      expect(product.description, 'A fine widget');
      expect(product.currencyCode, 'EUR');
      expect(product.rating, 4.5);
      expect(product.reviewCount, 42);
    });

    test('defaults: currency USD, inStock true, empty lists/maps', () {
      const product = OiProductData(key: 'p1', name: 'W', price: 10.0);
      expect(product.currencyCode, 'USD');
      expect(product.inStock, isTrue);
      expect(product.imageUrls, isEmpty);
      expect(product.variants, isEmpty);
      expect(product.attributes, isEmpty);
      expect(product.tags, isEmpty);
      expect(product.compareAtPrice, isNull);
      expect(product.stockCount, isNull);
      expect(product.sku, isNull);
    });

    test('copyWith replaces fields', () {
      const product = OiProductData(key: 'p1', name: 'Widget', price: 10.0);
      final copy = product.copyWith(price: 19.99, name: 'Gadget');
      expect(copy.price, 19.99);
      expect(copy.name, 'Gadget');
      expect(copy.key, 'p1');
    });

    test('copyWith can set nullable fields to null', () {
      const product = OiProductData(
        key: 'p1',
        name: 'Widget',
        price: 10.0,
        description: 'Desc',
        compareAtPrice: 20.0,
        rating: 4.0,
        reviewCount: 10,
        sku: 'SKU-001',
      );
      final copy = product.copyWith(
        description: null,
        compareAtPrice: null,
        rating: null,
        reviewCount: null,
        sku: null,
      );
      expect(copy.description, isNull);
      expect(copy.compareAtPrice, isNull);
      expect(copy.rating, isNull);
      expect(copy.reviewCount, isNull);
      expect(copy.sku, isNull);
    });

    test('equality works', () {
      const a = OiProductData(key: 'p1', name: 'Widget', price: 10.0);
      const b = OiProductData(key: 'p1', name: 'Widget', price: 10.0);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('inequality for different products', () {
      const a = OiProductData(key: 'p1', name: 'Widget', price: 10.0);
      const b = OiProductData(key: 'p2', name: 'Gadget', price: 20.0);
      expect(a, isNot(equals(b)));
    });

    test('toString includes key fields', () {
      const product = OiProductData(key: 'p1', name: 'Widget', price: 10.0);
      final str = product.toString();
      expect(str, contains('p1'));
      expect(str, contains('Widget'));
    });
  });
}
