// Why: Test files are not part of the public API surface; requiring doc comments on every test group and helper closure would add noise without value.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/models/oi_payment_method.dart';

void main() {
  group('OiPaymentMethod', () {
    test('constructor and field access', () {
      const method = OiPaymentMethod(
        key: 'visa',
        label: 'Visa',
        description: 'Visa ending in 4242',
        defaultMethod: true,
        lastFour: '4242',
        expiryDate: '12/25',
      );
      expect(method.key, 'visa');
      expect(method.label, 'Visa');
      expect(method.description, 'Visa ending in 4242');
      expect(method.defaultMethod, isTrue);
      expect(method.lastFour, '4242');
      expect(method.expiryDate, '12/25');
      expect(method.icon, isNull);
      expect(method.logo, isNull);
    });

    test('defaults: isDefault false, nullable fields null', () {
      const method = OiPaymentMethod(key: 'pp', label: 'PayPal');
      expect(method.defaultMethod, isFalse);
      expect(method.description, isNull);
      expect(method.lastFour, isNull);
      expect(method.expiryDate, isNull);
    });

    test('copyWith replaces specified fields', () {
      const method = OiPaymentMethod(key: 'visa', label: 'Visa');
      final copy = method.copyWith(label: 'MasterCard', defaultMethod: true);
      expect(copy.label, 'MasterCard');
      expect(copy.defaultMethod, isTrue);
      expect(copy.key, 'visa');
    });

    test('copyWith can set nullable fields to null', () {
      const method = OiPaymentMethod(
        key: 'visa',
        label: 'Visa',
        description: 'Ending 4242',
        lastFour: '4242',
        expiryDate: '12/25',
        icon: IconData(0xe001),
      );
      final copy = method.copyWith(
        description: null,
        lastFour: null,
        expiryDate: null,
        icon: null,
      );
      expect(copy.description, isNull);
      expect(copy.lastFour, isNull);
      expect(copy.expiryDate, isNull);
      expect(copy.icon, isNull);
    });

    test('equality works', () {
      const a = OiPaymentMethod(key: 'visa', label: 'Visa');
      const b = OiPaymentMethod(key: 'visa', label: 'Visa');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('inequality for different methods', () {
      const a = OiPaymentMethod(key: 'visa', label: 'Visa');
      const b = OiPaymentMethod(key: 'paypal', label: 'PayPal');
      expect(a, isNot(equals(b)));
    });

    test('toString includes key fields', () {
      const method = OiPaymentMethod(
        key: 'visa',
        label: 'Visa',
        defaultMethod: true,
      );
      expect(method.toString(), contains('visa'));
      expect(method.toString(), contains('Visa'));
      expect(method.toString(), contains('true'));
    });
  });
}
