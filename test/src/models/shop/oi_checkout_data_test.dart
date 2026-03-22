// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/models/oi_address_data.dart';
import 'package:obers_ui/src/models/oi_checkout_data.dart';
import 'package:obers_ui/src/models/oi_payment_method.dart';
import 'package:obers_ui/src/models/oi_shipping_method.dart';

const _address = OiAddressData(
  firstName: 'Jane',
  lastName: 'Doe',
  line1: '123 Main St',
  city: 'Zürich',
  postalCode: '8001',
  country: 'CH',
);

const _billingAddress = OiAddressData(
  firstName: 'Jane',
  lastName: 'Doe',
  line1: '456 Billing Ave',
  city: 'Bern',
  postalCode: '3000',
  country: 'CH',
);

const _payment = OiPaymentMethod(key: 'visa', label: 'Visa');
const _shipping = OiShippingMethod(
  key: 'standard',
  label: 'Standard',
  price: 5.0,
);

void main() {
  group('OiCheckoutData', () {
    test('constructor and field access', () {
      const data = OiCheckoutData(
        shippingAddress: _address,
        billingAddress: _billingAddress,
        shippingMethod: _shipping,
        paymentMethod: _payment,
      );
      expect(data.shippingAddress, _address);
      expect(data.billingAddress, _billingAddress);
      expect(data.shippingMethod, _shipping);
      expect(data.paymentMethod, _payment);
    });

    test('copyWith replaces specified fields', () {
      const data = OiCheckoutData(
        shippingAddress: _address,
        billingAddress: _address,
        shippingMethod: _shipping,
        paymentMethod: _payment,
      );
      final copy = data.copyWith(billingAddress: _billingAddress);
      expect(copy.billingAddress, _billingAddress);
      expect(copy.shippingAddress, _address);
    });

    test('equality works', () {
      const a = OiCheckoutData(
        shippingAddress: _address,
        billingAddress: _address,
        shippingMethod: _shipping,
        paymentMethod: _payment,
      );
      const b = OiCheckoutData(
        shippingAddress: _address,
        billingAddress: _address,
        shippingMethod: _shipping,
        paymentMethod: _payment,
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('inequality for different data', () {
      const a = OiCheckoutData(
        shippingAddress: _address,
        billingAddress: _address,
        shippingMethod: _shipping,
        paymentMethod: _payment,
      );
      const b = OiCheckoutData(
        shippingAddress: _address,
        billingAddress: _billingAddress,
        shippingMethod: _shipping,
        paymentMethod: _payment,
      );
      expect(a, isNot(equals(b)));
    });

    test('toString includes key fields', () {
      const data = OiCheckoutData(
        shippingAddress: _address,
        billingAddress: _address,
        shippingMethod: _shipping,
        paymentMethod: _payment,
      );
      expect(data.toString(), contains('shippingAddress'));
    });
  });
}
