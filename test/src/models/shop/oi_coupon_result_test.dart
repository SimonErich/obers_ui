// Why: Test files are not part of the public API surface; requiring doc comments on every test group and helper closure would add noise without value.

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/models/oi_coupon_result.dart';

void main() {
  group('OiCouponResult', () {
    test('constructor and field access', () {
      const result = OiCouponResult(
        valid: true,
        message: '20% off applied!',
        discountAmount: 10,
      );
      expect(result.valid, isTrue);
      expect(result.message, '20% off applied!');
      expect(result.discountAmount, 10.0);
    });

    test('defaults: nullable fields null', () {
      const result = OiCouponResult(valid: false);
      expect(result.message, isNull);
      expect(result.discountAmount, isNull);
    });

    test('copyWith replaces specified fields', () {
      const result = OiCouponResult(valid: false, message: 'Invalid');
      final copy = result.copyWith(valid: true, message: 'Applied');
      expect(copy.valid, isTrue);
      expect(copy.message, 'Applied');
    });

    test('copyWith can set nullable fields to null', () {
      const result = OiCouponResult(
        valid: true,
        message: 'OK',
        discountAmount: 5,
      );
      final copy = result.copyWith(message: null, discountAmount: null);
      expect(copy.message, isNull);
      expect(copy.discountAmount, isNull);
    });

    test('equality works', () {
      const a = OiCouponResult(valid: true, message: 'OK');
      const b = OiCouponResult(valid: true, message: 'OK');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('inequality for different results', () {
      const a = OiCouponResult(valid: true);
      const b = OiCouponResult(valid: false);
      expect(a, isNot(equals(b)));
    });

    test('toString includes key fields', () {
      const result = OiCouponResult(valid: true, message: 'Applied');
      expect(result.toString(), contains('true'));
      expect(result.toString(), contains('Applied'));
    });
  });
}
