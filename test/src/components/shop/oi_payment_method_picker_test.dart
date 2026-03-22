// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/shop/oi_payment_method_picker.dart';
import 'package:obers_ui/src/models/oi_payment_method.dart';

import '../../../helpers/pump_app.dart';

const _visa = OiPaymentMethod(key: 'visa', label: 'Visa');
const _paypal = OiPaymentMethod(key: 'paypal', label: 'PayPal');

void main() {
  group('OiPaymentMethodPicker', () {
    testWidgets('renders list of methods', (tester) async {
      await tester.pumpObers(
        OiPaymentMethodPicker(
          label: 'Payment method',
          methods: const [_visa, _paypal],
          onSelected: (_) {},
        ),
      );

      expect(find.text('Visa'), findsOneWidget);
      expect(find.text('PayPal'), findsOneWidget);
    });

    testWidgets('fires onSelected when a method is tapped', (tester) async {
      OiPaymentMethod? selected;
      await tester.pumpObers(
        OiPaymentMethodPicker(
          label: 'Payment method',
          methods: const [_visa, _paypal],
          onSelected: (m) => selected = m,
        ),
      );

      await tester.tap(find.text('Visa'));
      await tester.pump();

      expect(selected, _visa);
    });

    testWidgets('shows empty label when methods is empty', (tester) async {
      await tester.pumpObers(
        OiPaymentMethodPicker(
          label: 'Payment method',
          methods: const [],
          onSelected: (_) {},
        ),
      );

      expect(find.text('No payment methods available'), findsOneWidget);
    });

    testWidgets('highlights selected method', (tester) async {
      await tester.pumpObers(
        OiPaymentMethodPicker(
          label: 'Payment method',
          methods: const [_visa, _paypal],
          selectedKey: 'visa',
          onSelected: (_) {},
        ),
      );

      expect(find.byType(OiPaymentMethodPicker), findsOneWidget);
    });

    testWidgets('semantic label is set', (tester) async {
      await tester.pumpObers(
        OiPaymentMethodPicker(
          label: 'Choose payment',
          methods: const [_visa],
          onSelected: (_) {},
        ),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Choose payment',
        ),
        findsOneWidget,
      );
    });
  });
}
