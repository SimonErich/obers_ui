// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/models/oi_cart_summary.dart';

void main() {
  group('OiCartSummary', () {
    test('constructor and field access', () {
      const summary = OiCartSummary(
        subtotal: 100.0,
        total: 95.0,
        discount: 5.0,
        discountLabel: 'SAVE5',
        shipping: 10.0,
        shippingLabel: 'Standard',
        tax: 8.0,
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
      const summary = OiCartSummary(subtotal: 50.0, total: 50.0);
      expect(summary.discount, isNull);
      expect(summary.discountLabel, isNull);
      expect(summary.shipping, isNull);
      expect(summary.shippingLabel, isNull);
      expect(summary.tax, isNull);
      expect(summary.taxLabel, isNull);
      expect(summary.currencyCode, 'USD');
    });

    test('copyWith replaces specified fields', () {
      const summary = OiCartSummary(subtotal: 100.0, total: 100.0);
      final copy = summary.copyWith(total: 90.0, discount: 10.0);
      expect(copy.total, 90.0);
      expect(copy.discount, 10.0);
      expect(copy.subtotal, 100.0);
    });

    test('copyWith can set nullable fields to null', () {
      const summary = OiCartSummary(
        subtotal: 100.0,
        total: 100.0,
        discount: 5.0,
        shipping: 10.0,
        tax: 8.0,
      );
      final copy = summary.copyWith(discount: null, shipping: null, tax: null);
      expect(copy.discount, isNull);
      expect(copy.shipping, isNull);
      expect(copy.tax, isNull);
    });

    test('equality works', () {
      const a = OiCartSummary(subtotal: 100.0, total: 100.0);
      const b = OiCartSummary(subtotal: 100.0, total: 100.0);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('inequality for different totals', () {
      const a = OiCartSummary(subtotal: 100.0, total: 100.0);
      const b = OiCartSummary(subtotal: 100.0, total: 90.0);
      expect(a, isNot(equals(b)));
    });

    test('toString includes key fields', () {
      const summary = OiCartSummary(subtotal: 100.0, total: 100.0);
      expect(summary.toString(), contains('100.0'));
    });
  });
}
