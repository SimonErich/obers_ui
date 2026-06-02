// Golden tests have no public API.

import 'dart:ui';

import 'package:alchemist/alchemist.dart';
import 'package:obers_ui/src/components/shop/oi_address_form.dart';
import 'package:obers_ui/src/models/oi_address_data.dart';

import '../../helpers/golden_helper.dart';

Future<void> main() async {
  await goldenTest(
    'OiAddressForm — default empty form',
    fileName: 'oi_address_form_empty',
    builder: () => obersGoldenGroup(
      columns: 1,
      cellSize: const Size(800, 1000),
      children: {'Empty form': const OiAddressForm(label: 'Shipping address')},
    ),
  );

  await goldenTest(
    'OiAddressForm — pre-filled form',
    fileName: 'oi_address_form_prefilled',
    builder: () => obersGoldenGroup(
      columns: 1,
      cellSize: const Size(800, 1000),
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
    ),
  );
}
