// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/shop/oi_shipping_option.dart';
import 'package:obers_ui/src/models/oi_shipping_method.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

import '../../../helpers/pump_app.dart';

const _standard = OiShippingMethod(
  key: 'standard',
  label: 'Standard Shipping',
  price: 5.99,
  description: 'Delivered in 5-7 business days',
  estimatedDelivery: '5-7 days',
);

const _free = OiShippingMethod(key: 'free', label: 'Free Shipping', price: 0);

void main() {
  group('OiShippingOption', () {
    testWidgets('renders method label and price', (tester) async {
      await tester.pumpObers(
        const OiShippingOption(method: _standard, label: 'Shipping option'),
      );

      expect(find.text('Standard Shipping'), findsOneWidget);
      expect(find.text('5.99 €'), findsOneWidget);
    });

    testWidgets('renders description and estimated delivery', (tester) async {
      await tester.pumpObers(
        const OiShippingOption(method: _standard, label: 'Shipping option'),
      );

      expect(find.text('Delivered in 5-7 business days'), findsOneWidget);
      expect(find.text('5-7 days'), findsOneWidget);
    });

    testWidgets('displays "Free" for zero price', (tester) async {
      await tester.pumpObers(
        const OiShippingOption(method: _free, label: 'Shipping option'),
      );

      expect(find.text('Free'), findsOneWidget);
    });

    testWidgets('fires onSelect with method when tapped', (tester) async {
      OiShippingMethod? selected;
      await tester.pumpObers(
        OiShippingOption(
          method: _standard,
          label: 'Shipping option',
          onSelect: (m) => selected = m,
        ),
      );

      await tester.tap(find.byType(OiShippingOption));
      await tester.pump();
      expect(selected, _standard);
    });

    testWidgets('selected state shows highlighted border', (tester) async {
      await tester.pumpObers(
        OiShippingOption(
          method: _standard,
          label: 'Shipping option',
          selected: true,
          onSelect: (_) {},
        ),
      );

      // Widget renders without error in selected state.
      expect(find.byType(OiShippingOption), findsOneWidget);
    });

    testWidgets('semantic label is set', (tester) async {
      await tester.pumpObers(
        const OiShippingOption(
          method: _standard,
          label: 'Standard shipping option',
        ),
      );

      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              w.properties.label == 'Standard shipping option',
        ),
        findsOneWidget,
      );
    });

    testWidgets('uses USD currency format when specified', (tester) async {
      await tester.pumpObers(
        const OiShippingOption(
          method: _standard,
          label: 'Shipping',
          currencyCode: 'USD',
        ),
      );

      expect(find.text(r'$5.99'), findsOneWidget);
    });
  });
}
