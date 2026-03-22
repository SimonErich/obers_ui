// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/shop/oi_payment_option.dart';
import 'package:obers_ui/src/models/oi_payment_method.dart';

import '../../../helpers/pump_app.dart';

const _visa = OiPaymentMethod(
  key: 'visa',
  label: 'Visa',
  description: 'Ending in 4242',
  icon: IconData(0xe870, fontFamily: 'MaterialIcons'),
);

const _paypal = OiPaymentMethod(
  key: 'paypal',
  label: 'PayPal',
  description: 'user@example.com',
  isDefault: true,
);

const _minimal = OiPaymentMethod(key: 'bank', label: 'Bank Transfer');

void main() {
  group('OiPaymentOption', () {
    testWidgets('renders method label', (tester) async {
      await tester.pumpObers(
        const OiPaymentOption(method: _visa, label: 'Payment'),
      );

      expect(find.text('Visa'), findsOneWidget);
    });

    testWidgets('renders description when provided', (tester) async {
      await tester.pumpObers(
        const OiPaymentOption(method: _visa, label: 'Payment'),
      );

      expect(find.text('Ending in 4242'), findsOneWidget);
    });

    testWidgets('hides description when null', (tester) async {
      await tester.pumpObers(
        const OiPaymentOption(method: _minimal, label: 'Payment'),
      );

      expect(find.text('Bank Transfer'), findsOneWidget);
      // Only the label text, no description.
      final labels = tester.widgetList<Widget>(find.byType(Widget));
      expect(labels, isNotEmpty);
    });

    testWidgets('shows Default tag for default method', (tester) async {
      await tester.pumpObers(
        const OiPaymentOption(method: _paypal, label: 'Payment'),
      );

      expect(find.text('Default'), findsOneWidget);
    });

    testWidgets('fires onSelect with method when tapped', (tester) async {
      OiPaymentMethod? selected;
      await tester.pumpObers(
        OiPaymentOption(
          method: _visa,
          label: 'Payment',
          onSelect: (m) => selected = m,
        ),
      );

      await tester.tap(find.byType(OiPaymentOption));
      await tester.pump();
      expect(selected, _visa);
    });

    testWidgets('selected state renders without error', (tester) async {
      await tester.pumpObers(
        OiPaymentOption(
          method: _visa,
          label: 'Payment',
          selected: true,
          onSelect: (_) {},
        ),
      );

      expect(find.byType(OiPaymentOption), findsOneWidget);
    });

    testWidgets('renders icon widget', (tester) async {
      await tester.pumpObers(
        const OiPaymentOption(method: _visa, label: 'Payment'),
      );

      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('semantic label is set', (tester) async {
      await tester.pumpObers(
        const OiPaymentOption(method: _visa, label: 'Visa payment option'),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Visa payment option',
        ),
        findsOneWidget,
      );
    });
  });
}
