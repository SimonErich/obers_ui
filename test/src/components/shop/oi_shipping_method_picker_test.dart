// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/shop/oi_shipping_method_picker.dart';
import 'package:obers_ui/src/models/oi_shipping_method.dart';

import '../../../helpers/pump_app.dart';

const _standard = OiShippingMethod(
  key: 'standard',
  label: 'Standard Shipping',
  price: 5.99,
);

const _express = OiShippingMethod(
  key: 'express',
  label: 'Express Shipping',
  price: 12.99,
);

void main() {
  group('OiShippingMethodPicker', () {
    testWidgets('renders list of methods', (tester) async {
      await tester.pumpObers(
        OiShippingMethodPicker(
          label: 'Shipping method',
          methods: const [_standard, _express],
          onSelected: (_) {},
        ),
      );

      expect(find.text('Standard Shipping'), findsOneWidget);
      expect(find.text('Express Shipping'), findsOneWidget);
    });

    testWidgets('fires onSelected when a method is tapped', (tester) async {
      OiShippingMethod? selected;
      await tester.pumpObers(
        OiShippingMethodPicker(
          label: 'Shipping method',
          methods: const [_standard, _express],
          onSelected: (m) => selected = m,
        ),
      );

      await tester.tap(find.text('Standard Shipping'));
      await tester.pump();

      expect(selected, _standard);
    });

    testWidgets('shows empty label when methods is empty', (tester) async {
      await tester.pumpObers(
        OiShippingMethodPicker(
          label: 'Shipping method',
          methods: const [],
          onSelected: (_) {},
        ),
      );

      expect(find.text('No shipping methods available'), findsOneWidget);
    });

    testWidgets('highlights selected method', (tester) async {
      await tester.pumpObers(
        OiShippingMethodPicker(
          label: 'Shipping method',
          methods: const [_standard, _express],
          selectedKey: 'express',
          onSelected: (_) {},
        ),
      );

      expect(find.byType(OiShippingMethodPicker), findsOneWidget);
    });

    testWidgets('semantic label is set', (tester) async {
      await tester.pumpObers(
        OiShippingMethodPicker(
          label: 'Choose shipping',
          methods: const [_standard],
          onSelected: (_) {},
        ),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Choose shipping',
        ),
        findsOneWidget,
      );
    });
  });
}
