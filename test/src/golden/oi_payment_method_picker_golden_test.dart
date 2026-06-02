// Golden tests have no public API.

import 'package:alchemist/alchemist.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../helpers/golden_helper.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

const _methods = [
  OiPaymentMethod(
    key: 'visa',
    label: 'Visa',
    description: 'Ending in 4242',
    lastFour: '4242',
  ),
  OiPaymentMethod(
    key: 'mastercard',
    label: 'Mastercard',
    description: 'Ending in 5555',
    lastFour: '5555',
  ),
  OiPaymentMethod(
    key: 'amex',
    label: 'Amex',
    description: 'Ending in 1234',
    lastFour: '1234',
  ),
];

Widget _buildPaymentPickerGolden() {
  return const SizedBox(
    width: 400,
    height: 400,
    child: SingleChildScrollView(
      child: OiPaymentMethodPicker(
        label: 'Payment method',
        methods: _methods,
        selectedKey: 'visa',
        onSelect: _noop,
        addNewCard: Text('+ Add new card'),
      ),
    ),
  );
}

void _noop(OiPaymentMethod _) {}

// ── Tests ────────────────────────────────────────────────────────────────────

Future<void> main() async {
  await goldenTest(
    'OiPaymentMethodPicker 3 methods + addNewCard — light',
    fileName: 'oi_payment_method_picker_3_methods_add_card_light',
    builder: () => obersGoldenGroup(
      columns: 1,
      cellSize: const Size(440, 440),
      children: {
        '3 methods + addNewCard, visa selected': _buildPaymentPickerGolden(),
      },
    ),
  );

  await goldenTest(
    'OiPaymentMethodPicker 3 methods + addNewCard — dark',
    fileName: 'oi_payment_method_picker_3_methods_add_card_dark',
    builder: () => obersGoldenGroup(
      columns: 1,
      theme: OiThemeData.dark(),
      cellSize: const Size(440, 440),
      children: {
        '3 methods + addNewCard, visa selected': _buildPaymentPickerGolden(),
      },
    ),
  );
}
