// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/models/oi_cart_summary.dart';

void main() {
  group('OiCartSummary', () {
    test('default construction has expected defaults', () {
      const s = OiCartSummary(subtotal: 0, total: 0);
      expect(s.subtotal, 0);
      expect(s.discount, isNull);
      expect(s.discountLabel, isNull);
      expect(s.shipping, isNull);
      expect(s.shippingLabel, isNull);
      expect(s.tax, isNull);
      expect(s.taxLabel, isNull);
      expect(s.total, 0);
      expect(s.currencyCode, 'USD');
    });

    test('full construction with all fields', () {
      const s = OiCartSummary(
        subtotal: 100,
        discount: 20,
        discountLabel: 'SUMMER20 (-20%)',
        shipping: 5.99,
        shippingLabel: 'Express Shipping',
        tax: 16,
        taxLabel: 'VAT 20%',
        total: 101.99,
        currencyCode: 'EUR',
      );
      expect(s.subtotal, 100.0);
      expect(s.discount, 20.0);
      expect(s.discountLabel, 'SUMMER20 (-20%)');
      expect(s.shipping, 5.99);
      expect(s.shippingLabel, 'Express Shipping');
      expect(s.tax, 16.0);
      expect(s.taxLabel, 'VAT 20%');
      expect(s.total, 101.99);
      expect(s.currencyCode, 'EUR');
    });

    test('copyWith replaces fields', () {
      const s = OiCartSummary(subtotal: 100, total: 100);
      final updated = s.copyWith(discount: 10.0, total: 90);
      expect(updated.subtotal, 100.0);
      expect(updated.discount, 10.0);
      expect(updated.total, 90.0);
    });

    test('copyWith can set nullable fields to null via sentinel', () {
      const s = OiCartSummary(
        subtotal: 100,
        total: 100,
        discount: 10,
        discountLabel: 'SAVE10',
        shipping: 5,
        shippingLabel: 'Standard',
        tax: 8,
        taxLabel: 'VAT 20%',
      );
      final cleared = s.copyWith(
        discount: null,
        discountLabel: null,
        shipping: null,
        shippingLabel: null,
        tax: null,
        taxLabel: null,
      );
      expect(cleared.discount, isNull);
      expect(cleared.discountLabel, isNull);
      expect(cleared.shipping, isNull);
      expect(cleared.shippingLabel, isNull);
      expect(cleared.tax, isNull);
      expect(cleared.taxLabel, isNull);
    });

    test('copyWith preserves null when not specified', () {
      const s = OiCartSummary(subtotal: 50, total: 50);
      final updated = s.copyWith(total: 60);
      expect(updated.discount, isNull);
      expect(updated.shipping, isNull);
      expect(updated.tax, isNull);
      expect(updated.total, 60.0);
    });

    test('equal instances are ==', () {
      const a = OiCartSummary(
        subtotal: 100,
        discount: 10,
        discountLabel: 'SAVE10',
        total: 90,
      );
      const b = OiCartSummary(
        subtotal: 100,
        discount: 10,
        discountLabel: 'SAVE10',
        total: 90,
      );
      expect(a, equals(b));
    });

    test('different instances are not ==', () {
      const a = OiCartSummary(subtotal: 100, total: 100);
      const b = OiCartSummary(subtotal: 100, total: 90);
      expect(a, isNot(equals(b)));
    });

    test('toString includes key fields', () {
      const s = OiCartSummary(
        subtotal: 100,
        total: 90,
        currencyCode: 'EUR',
      );
      expect(
        s.toString(),
        'OiCartSummary(subtotal: 100.0, total: 90.0, currencyCode: EUR)',
      );
    });

    test('equal instances have the same hashCode', () {
      const a = OiCartSummary(
        subtotal: 50,
        tax: 10,
        taxLabel: 'Tax',
        total: 60,
        currencyCode: 'GBP',
      );
      const b = OiCartSummary(
        subtotal: 50,
        tax: 10,
        taxLabel: 'Tax',
        total: 60,
        currencyCode: 'GBP',
      );
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
