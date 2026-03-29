// Why: Test files are not part of the public API surface; requiring doc comments on every test group and helper closure would add noise without value.

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/models/oi_cart_summary.dart';

void main() {
  group('OiCartSummary', () {
    test('constructor and field access', () {
      const summary = OiCartSummary(
        subtotal: 100,
        total: 95,
        discount: 5,
        discountLabel: 'SAVE5',
        shipping: 10,
        shippingLabel: 'Standard',
        tax: 8,
        taxLabel: 'VAT 8%',
      );
      expect(summary.subtotal, 100.0);
      expect(summary.total, 95.0);
      expect(summary.discount, 5.0);
      expect(summary.discountLabel, 'SAVE5');
      expect(summary.shipping, 10.0);
      expect(summary.shippingLabel, 'Standard');
      expect(summary.tax, 8.0);
      expect(summary.taxLabel, 'VAT 8%');
      expect(summary.currencyCode, 'USD');
    });

    test('defaults: nullable fields null, currency USD', () {
      const summary = OiCartSummary(subtotal: 50, total: 50);
      expect(summary.discount, isNull);
      expect(summary.discountLabel, isNull);
      expect(summary.shipping, isNull);
      expect(summary.shippingLabel, isNull);
      expect(summary.tax, isNull);
      expect(summary.taxLabel, isNull);
      expect(summary.currencyCode, 'USD');
    });

    test('copyWith replaces specified fields', () {
      const summary = OiCartSummary(subtotal: 100, total: 100);
      final copy = summary.copyWith(total: 90, discount: 10.0);
      expect(copy.total, 90.0);
      expect(copy.discount, 10.0);
      expect(copy.subtotal, 100.0);
    });

    test('copyWith can set nullable fields to null', () {
      const summary = OiCartSummary(
        subtotal: 100,
        total: 100,
        discount: 5,
        shipping: 10,
        tax: 8,
      );
      final copy = summary.copyWith(discount: null, shipping: null, tax: null);
      expect(copy.discount, isNull);
      expect(copy.shipping, isNull);
      expect(copy.tax, isNull);
    });

    test('equality works', () {
      const a = OiCartSummary(subtotal: 100, total: 100);
      const b = OiCartSummary(subtotal: 100, total: 100);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('inequality for different totals', () {
      const a = OiCartSummary(subtotal: 100, total: 100);
      const b = OiCartSummary(subtotal: 100, total: 90);
      expect(a, isNot(equals(b)));
    });

    test('toString includes key fields', () {
      const summary = OiCartSummary(subtotal: 100, total: 100);
      expect(summary.toString(), contains('100.0'));
    });
  });
}
