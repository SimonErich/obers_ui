// Golden tests have no public API.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
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

void main() {
  testGoldens('OiPaymentMethodPicker 3 methods + addNewCard — light', (
    tester,
  ) async {
    final builder = obersGoldenBuilder(
      columns: 1,
      children: {
        '3 methods + addNewCard, visa selected': _buildPaymentPickerGolden(),
      },
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(
      tester,
      'oi_payment_method_picker_3_methods_add_card_light',
    );
  });

  testGoldens('OiPaymentMethodPicker 3 methods + addNewCard — dark', (
    tester,
  ) async {
    final builder = obersGoldenBuilder(
      columns: 1,
      theme: OiThemeData.dark(),
      children: {
        '3 methods + addNewCard, visa selected': _buildPaymentPickerGolden(),
      },
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(
      tester,
      'oi_payment_method_picker_3_methods_add_card_dark',
    );
  });
}
