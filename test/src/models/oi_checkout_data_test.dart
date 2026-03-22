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
    test('constructor assigns fields correctly', () {
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

    test('copyWith replaces specified fields', () {
      const original = OiCheckoutData(
        shippingAddress: _address1,
        billingAddress: _address1,
        shippingMethod: _shipping,
        paymentMethod: _payment,
      );

      final copied = original.copyWith(
        billingAddress: _address2,
        shippingMethod: _shipping2,
      );

      expect(copied.shippingAddress, _address1);
      expect(copied.billingAddress, _address2);
      expect(copied.shippingMethod, _shipping2);
      expect(copied.paymentMethod, _payment);
    });

    test('copyWith without arguments returns equal instance', () {
      const original = OiCheckoutData(
        shippingAddress: _address1,
        billingAddress: _address1,
        shippingMethod: _shipping,
        paymentMethod: _payment,
      );

      final copied = original.copyWith();
      expect(copied, original);
    });

    test('equality based on all fields', () {
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
      const c = OiCheckoutData(
        shippingAddress: _address2,
        billingAddress: _address2,
        shippingMethod: _shipping2,
        paymentMethod: _payment2,
      );

      expect(a, b);
      expect(a, isNot(c));
      expect(a.hashCode, b.hashCode);
      expect(a.hashCode, isNot(c.hashCode));
    });

    test('inequality when single field differs', () {
      const base = OiCheckoutData(
        shippingAddress: _address1,
        billingAddress: _address1,
        shippingMethod: _shipping,
        paymentMethod: _payment,
      );

      expect(base.copyWith(paymentMethod: _payment2), isNot(base));
      expect(base.copyWith(shippingMethod: _shipping2), isNot(base));
      expect(base.copyWith(billingAddress: _address2), isNot(base));
      expect(base.copyWith(shippingAddress: _address2), isNot(base));
    });

    test('toString returns expected format', () {
      const data = OiCheckoutData(
        shippingAddress: _address1,
        billingAddress: _address1,
        shippingMethod: _shipping,
        paymentMethod: _payment,
      );

      expect(data.toString(), contains('OiCheckoutData'));
      expect(data.toString(), contains('shippingAddress'));
    });
  });
}
