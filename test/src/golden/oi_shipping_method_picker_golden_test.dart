// Golden tests have no public API.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../helpers/golden_helper.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

const _methods = [
  OiShippingMethod(
    key: 'standard',
    label: 'Standard Shipping',
    price: 5.99,
    description: 'Delivered in 5-7 business days',
    estimatedDelivery: '5-7 days',
  ),
  OiShippingMethod(
    key: 'express',
    label: 'Express Shipping',
    price: 12.99,
    description: 'Delivered in 1-2 business days',
    estimatedDelivery: '1-2 days',
  ),
  OiShippingMethod(
    key: 'overnight',
    label: 'Overnight Shipping',
    price: 24.99,
    description: 'Next business day delivery',
    estimatedDelivery: '1 day',
  ),
];

Widget _buildShippingPickerGolden() {
  return const SizedBox(
    width: 400,
    height: 300,
    child: SingleChildScrollView(
      child: OiShippingMethodPicker(
        label: 'Shipping method',
        methods: _methods,
        selectedKey: 'express',
        onSelected: _noop,
      ),
    ),
  );
}

void _noop(OiShippingMethod _) {}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  testGoldens('OiShippingMethodPicker 3 methods selected — light', (
    tester,
  ) async {
    final builder = obersGoldenBuilder(
      columns: 1,
      children: {'3 methods, express selected': _buildShippingPickerGolden()},
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(
      tester,
      'oi_shipping_method_picker_3_methods_light',
    );
  });

  testGoldens('OiShippingMethodPicker 3 methods selected — dark', (
    tester,
  ) async {
    final builder = obersGoldenBuilder(
      columns: 1,
      theme: OiThemeData.dark(),
      children: {'3 methods, express selected': _buildShippingPickerGolden()},
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(
      tester,
      'oi_shipping_method_picker_3_methods_dark',
    );
  });
}
