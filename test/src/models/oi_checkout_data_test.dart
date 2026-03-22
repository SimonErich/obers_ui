// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/models/oi_address_data.dart';
import 'package:obers_ui/src/models/oi_checkout_data.dart';
import 'package:obers_ui/src/models/oi_payment_method.dart';
import 'package:obers_ui/src/models/oi_shipping_method.dart';

const _address1 = OiAddressData(
  firstName: 'Jane',
  lastName: 'Doe',
  line1: '123 Main St',
  city: 'Springfield',
  postalCode: '62701',
  country: 'US',
);

const _address2 = OiAddressData(
  firstName: 'John',
  lastName: 'Smith',
  line1: '456 Oak Ave',
  city: 'Portland',
  postalCode: '97201',
  country: 'US',
);

const _shipping = OiShippingMethod(
  key: 'standard',
  label: 'Standard Shipping',
  price: 5.99,
);

const _shipping2 = OiShippingMethod(
  key: 'express',
  label: 'Express Shipping',
  price: 14.99,
);

const _payment = OiPaymentMethod(key: 'credit', label: 'Credit Card');

const _payment2 = OiPaymentMethod(key: 'paypal', label: 'PayPal');

void main() {
  group('OiCheckoutData', () {
    test('constructor sets all required fields', () {
      const data = OiCheckoutData(
        shippingAddress: _address1,
        billingAddress: _address2,
        shippingMethod: _shipping,
        paymentMethod: _payment,
      );
      expect(data.shippingAddress, _address1);
      expect(data.billingAddress, _address2);
      expect(data.shippingMethod, _shipping);
      expect(data.paymentMethod, _payment);
    });

    test('copyWith replaces shippingAddress independently', () {
      const data = OiCheckoutData(
        shippingAddress: _address1,
        billingAddress: _address1,
        shippingMethod: _shipping,
        paymentMethod: _payment,
      );
      final updated = data.copyWith(shippingAddress: _address2);
      expect(updated.shippingAddress, _address2);
      expect(updated.billingAddress, _address1);
      expect(updated.shippingMethod, _shipping);
      expect(updated.paymentMethod, _payment);
    });

    test('copyWith replaces billingAddress independently', () {
      const data = OiCheckoutData(
        shippingAddress: _address1,
        billingAddress: _address1,
        shippingMethod: _shipping,
        paymentMethod: _payment,
      );
      final updated = data.copyWith(billingAddress: _address2);
      expect(updated.shippingAddress, _address1);
      expect(updated.billingAddress, _address2);
      expect(updated.shippingMethod, _shipping);
      expect(updated.paymentMethod, _payment);
    });

    test('copyWith replaces shippingMethod independently', () {
      const data = OiCheckoutData(
        shippingAddress: _address1,
        billingAddress: _address1,
        shippingMethod: _shipping,
        paymentMethod: _payment,
      );
      final updated = data.copyWith(shippingMethod: _shipping2);
      expect(updated.shippingAddress, _address1);
      expect(updated.billingAddress, _address1);
      expect(updated.shippingMethod, _shipping2);
      expect(updated.paymentMethod, _payment);
    });

    test('copyWith replaces paymentMethod independently', () {
      const data = OiCheckoutData(
        shippingAddress: _address1,
        billingAddress: _address1,
        shippingMethod: _shipping,
        paymentMethod: _payment,
      );
      final updated = data.copyWith(paymentMethod: _payment2);
      expect(updated.shippingAddress, _address1);
      expect(updated.billingAddress, _address1);
      expect(updated.shippingMethod, _shipping);
      expect(updated.paymentMethod, _payment2);
    });

    test('copyWith preserves unset fields', () {
      const data = OiCheckoutData(
        shippingAddress: _address1,
        billingAddress: _address2,
        shippingMethod: _shipping,
        paymentMethod: _payment,
      );
      final updated = data.copyWith();
      expect(updated.shippingAddress, _address1);
      expect(updated.billingAddress, _address2);
      expect(updated.shippingMethod, _shipping);
      expect(updated.paymentMethod, _payment);
    });

    test('equal instances are ==', () {
      const a = OiCheckoutData(
        shippingAddress: _address1,
        billingAddress: _address1,
        shippingMethod: _shipping,
        paymentMethod: _payment,
      );
      const b = OiCheckoutData(
        shippingAddress: _address1,
        billingAddress: _address1,
        shippingMethod: _shipping,
        paymentMethod: _payment,
      );
      expect(a, equals(b));
    });

    test('different instances are not ==', () {
      const a = OiCheckoutData(
        shippingAddress: _address1,
        billingAddress: _address1,
        shippingMethod: _shipping,
        paymentMethod: _payment,
      );
      const b = OiCheckoutData(
        shippingAddress: _address2,
        billingAddress: _address2,
        shippingMethod: _shipping2,
        paymentMethod: _payment2,
      );
      expect(a, isNot(equals(b)));
    });

    test('equal instances have the same hashCode', () {
      const a = OiCheckoutData(
        shippingAddress: _address1,
        billingAddress: _address1,
        shippingMethod: _shipping,
        paymentMethod: _payment,
      );
      const b = OiCheckoutData(
        shippingAddress: _address1,
        billingAddress: _address1,
        shippingMethod: _shipping,
        paymentMethod: _payment,
      );
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString includes all fields', () {
      const data = OiCheckoutData(
        shippingAddress: _address1,
        billingAddress: _address2,
        shippingMethod: _shipping,
        paymentMethod: _payment,
      );
      final str = data.toString();
      expect(str, contains('shippingAddress:'));
      expect(str, contains('billingAddress:'));
      expect(str, contains('shippingMethod:'));
      expect(str, contains('paymentMethod:'));
    });
  });
}
