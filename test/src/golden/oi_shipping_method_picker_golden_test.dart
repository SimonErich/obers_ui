// Golden tests have no public API.

import 'package:alchemist/alchemist.dart';
import 'package:flutter/widgets.dart';
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
        onSelect: _noop,
      ),
    ),
  );
}

void _noop(OiShippingMethod _) {}

// ── Tests ────────────────────────────────────────────────────────────────────

Future<void> main() async {
  await goldenTest(
    'OiShippingMethodPicker 3 methods selected — light',
    fileName: 'oi_shipping_method_picker_3_methods_light',
    builder: () => obersGoldenGroup(
      columns: 1,
      cellSize: const Size(460, 360),
      children: {'3 methods, express selected': _buildShippingPickerGolden()},
    ),
  );

  await goldenTest(
    'OiShippingMethodPicker 3 methods selected — dark',
    fileName: 'oi_shipping_method_picker_3_methods_dark',
    builder: () => obersGoldenGroup(
      columns: 1,
      theme: OiThemeData.dark(),
      cellSize: const Size(460, 360),
      children: {'3 methods, express selected': _buildShippingPickerGolden()},
    ),
  );
}
