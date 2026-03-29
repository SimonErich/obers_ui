// Golden tests have no public API.

import 'dart:ui';

import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:obers_ui/src/components/shop/oi_address_form.dart';
import 'package:obers_ui/src/models/oi_address_data.dart';

import '../../helpers/golden_helper.dart';

void main() {
  testGoldens('OiAddressForm — default empty form', (tester) async {
    final builder = obersGoldenBuilder(
      children: {'Empty form': const OiAddressForm(label: 'Shipping address')},
    );
    await tester.pumpWidgetBuilder(builder, surfaceSize: const Size(800, 1000));
    await screenMatchesGolden(tester, 'oi_address_form_empty');
  });

  testGoldens('OiAddressForm — pre-filled form', (tester) async {
    final builder = obersGoldenBuilder(
      children: {
        'Pre-filled': const OiAddressForm(
          label: 'Shipping address',
          initialValue: OiAddressData(
            firstName: 'Jane',
            lastName: 'Doe',
            company: 'Acme Inc.',
            line1: '123 Main St',
            line2: 'Apt 4B',
            city: 'Zürich',
            state: 'ZH',
            postalCode: '8001',
            country: 'Switzerland',
            phone: '+41 44 123 4567',
            email: 'jane@example.com',
          ),
        ),
      },
    );
    await tester.pumpWidgetBuilder(builder, surfaceSize: const Size(800, 1000));
    await screenMatchesGolden(tester, 'oi_address_form_prefilled');
  });
}
