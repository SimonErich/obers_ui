// Tests do not require documentation comments.

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/models/oi_coupon_result.dart';

void main() {
  group('OiCouponResult', () {
    test('constructor sets all fields', () {
      const result = OiCouponResult(
        valid: true,
        message: '20% off applied!',
        discountAmount: 10,
      );
      expect(result.valid, true);
      expect(result.message, '20% off applied!');
      expect(result.discountAmount, 10.0);
    });

    test('copyWith replaces valid independently', () {
      const result = OiCouponResult(
        valid: true,
        message: 'Applied',
        discountAmount: 5,
      );
      final updated = result.copyWith(valid: false);
      expect(updated.valid, false);
      expect(updated.message, 'Applied');
      expect(updated.discountAmount, 5.0);
    });

    test('copyWith replaces message independently', () {
      const result = OiCouponResult(
        valid: true,
        message: 'Applied',
        discountAmount: 5,
      );
      final updated = result.copyWith(message: 'New message');
      expect(updated.valid, true);
      expect(updated.message, 'New message');
      expect(updated.discountAmount, 5.0);
    });

    test('copyWith replaces discountAmount independently', () {
      const result = OiCouponResult(
        valid: true,
        message: 'Applied',
        discountAmount: 5,
      );
      // 15.0 is intentionally a double literal to test double precision handling.
      final updated = result.copyWith(discountAmount: 15.0);
      expect(updated.valid, true);
      expect(updated.message, 'Applied');
      expect(updated.discountAmount, 15.0);
    });

    test('copyWith preserves unset fields', () {
      const result = OiCouponResult(
        valid: true,
        message: 'Applied',
        discountAmount: 5,
      );
      final updated = result.copyWith();
      expect(updated.valid, true);
      expect(updated.message, 'Applied');
      expect(updated.discountAmount, 5.0);
    });

    test('equal instances are ==', () {
      const a = OiCouponResult(
        valid: true,
        message: 'Applied',
        discountAmount: 5,
      );
      const b = OiCouponResult(
        valid: true,
        message: 'Applied',
        discountAmount: 5,
      );
      expect(a, equals(b));
    });

    test('different instances are not ==', () {
      const a = OiCouponResult(
        valid: true,
        message: 'Applied',
        discountAmount: 5,
      );
      const b = OiCouponResult(valid: false, message: 'Invalid code');
      expect(a, isNot(equals(b)));
    });

    test('equal instances have the same hashCode', () {
      const a = OiCouponResult(
        valid: true,
        message: 'Applied',
        discountAmount: 5,
      );
      const b = OiCouponResult(
        valid: true,
        message: 'Applied',
        discountAmount: 5,
      );
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString includes all fields', () {
      const result = OiCouponResult(
        valid: true,
        message: 'Applied',
        discountAmount: 5,
      );
      final str = result.toString();
      expect(str, contains('valid: true'));
      expect(str, contains('message: Applied'));
      expect(str, contains('discountAmount: 5.0'));
    });

    test('null optional fields are accepted', () {
      const result = OiCouponResult(valid: false);
      expect(result.valid, false);
      expect(result.message, isNull);
      expect(result.discountAmount, isNull);
    });

    test('copyWith can set nullable fields to null via sentinel', () {
      const result = OiCouponResult(
        valid: true,
        message: 'Applied',
        discountAmount: 5,
      );
      final cleared = result.copyWith(message: null, discountAmount: null);
      expect(cleared.message, isNull);
      expect(cleared.discountAmount, isNull);
      expect(cleared.valid, true);
    });
  });
}
