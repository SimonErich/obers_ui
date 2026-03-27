// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/models/oi_payment_method.dart';

const IconData _kVisaIcon = IconData(0xe870, fontFamily: 'MaterialIcons');

void main() {
  group('OiPaymentMethod', () {
    test('default construction has expected defaults', () {
      const method = OiPaymentMethod(key: 'cc', label: 'Credit Card');
      expect(method.key, 'cc');
      expect(method.label, 'Credit Card');
      expect(method.description, isNull);
      expect(method.icon, isNull);
      expect(method.defaultMethod, false);
      expect(method.lastFour, isNull);
      expect(method.expiryDate, isNull);
      expect(method.logo, isNull);
    });

    test('all fields are stored correctly', () {
      const method = OiPaymentMethod(
        key: 'visa',
        label: 'Visa',
        description: 'Visa ending in 4242',
        icon: _kVisaIcon,
        defaultMethod: true,
        lastFour: '•••• 4242',
        expiryDate: '12/25',
      );
      expect(method.key, 'visa');
      expect(method.label, 'Visa');
      expect(method.description, 'Visa ending in 4242');
      expect(method.icon, _kVisaIcon);
      expect(method.defaultMethod, true);
      expect(method.lastFour, '•••• 4242');
      expect(method.expiryDate, '12/25');
    });

    test('logo field stores widget', () {
      final logo = Container();
      final method = OiPaymentMethod(key: 'visa', label: 'Visa', logo: logo);
      expect(method.logo, same(logo));
    });

    test('copyWith replaces fields', () {
      const method = OiPaymentMethod(key: 'cc', label: 'Credit Card');
      final updated = method.copyWith(
        key: 'visa',
        label: 'Visa',
        defaultMethod: true,
        lastFour: '•••• 1234',
        expiryDate: '06/26',
      );
      expect(updated.key, 'visa');
      expect(updated.label, 'Visa');
      expect(updated.defaultMethod, true);
      expect(updated.lastFour, '•••• 1234');
      expect(updated.expiryDate, '06/26');
    });

    test('copyWith can set nullable fields to null via sentinel', () {
      final method = OiPaymentMethod(
        key: 'visa',
        label: 'Visa',
        description: 'Visa card',
        icon: _kVisaIcon,
        lastFour: '•••• 4242',
        expiryDate: '12/25',
        logo: Container(),
      );
      final cleared = method.copyWith(
        description: null,
        icon: null,
        lastFour: null,
        expiryDate: null,
        logo: null,
      );
      expect(cleared.description, isNull);
      expect(cleared.icon, isNull);
      expect(cleared.lastFour, isNull);
      expect(cleared.expiryDate, isNull);
      expect(cleared.logo, isNull);
      expect(cleared.key, 'visa');
      expect(cleared.label, 'Visa');
    });

    test('copyWith with no args returns equal instance', () {
      const method = OiPaymentMethod(
        key: 'cc',
        label: 'Credit Card',
        defaultMethod: true,
      );
      final copy = method.copyWith();
      expect(copy, equals(method));
    });

    test('equal instances are ==', () {
      const a = OiPaymentMethod(
        key: 'cc',
        label: 'Credit Card',
        description: 'Primary card',
        icon: _kVisaIcon,
        defaultMethod: true,
        lastFour: '•••• 4242',
        expiryDate: '12/25',
      );
      const b = OiPaymentMethod(
        key: 'cc',
        label: 'Credit Card',
        description: 'Primary card',
        icon: _kVisaIcon,
        defaultMethod: true,
        lastFour: '•••• 4242',
        expiryDate: '12/25',
      );
      expect(a, equals(b));
    });

    test('equal instances have the same hashCode', () {
      const a = OiPaymentMethod(key: 'cc', label: 'Credit Card');
      const b = OiPaymentMethod(key: 'cc', label: 'Credit Card');
      expect(a.hashCode, equals(b.hashCode));
    });

    test('different instances are not ==', () {
      const a = OiPaymentMethod(key: 'cc', label: 'Credit Card');
      const b = OiPaymentMethod(key: 'paypal', label: 'PayPal');
      expect(a, isNot(equals(b)));
    });

    test('instances with different lastFour are not ==', () {
      const a = OiPaymentMethod(
        key: 'cc',
        label: 'Card',
        lastFour: '•••• 4242',
      );
      const b = OiPaymentMethod(
        key: 'cc',
        label: 'Card',
        lastFour: '•••• 1234',
      );
      expect(a, isNot(equals(b)));
    });

    test('toString includes key, label, isDefault', () {
      const method = OiPaymentMethod(
        key: 'cc',
        label: 'Credit Card',
        defaultMethod: true,
      );
      final str = method.toString();
      expect(str, contains('cc'));
      expect(str, contains('Credit Card'));
      expect(str, contains('true'));
    });
  });
}
