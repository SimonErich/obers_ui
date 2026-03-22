// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/components/shop/oi_address_form.dart';
import 'package:obers_ui/src/models/oi_address_data.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiAddressForm', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: OiAddressForm(label: 'Shipping address'),
        ),
        surfaceSize: const Size(800, 900),
      );

      expect(find.byType(OiAddressForm), findsOneWidget);
    });

    testWidgets('displays the label', (tester) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: OiAddressForm(label: 'Billing address'),
        ),
        surfaceSize: const Size(800, 900),
      );

      expect(find.text('Billing address'), findsOneWidget);
    });

    testWidgets('fires onChanged when a field is edited', (tester) async {
      OiAddressData? latest;
      await tester.pumpObers(
        SingleChildScrollView(
          child: OiAddressForm(
            label: 'Address',
            onChanged: (data) => latest = data,
          ),
        ),
        surfaceSize: const Size(800, 900),
      );

      // First OiTextInput is "First name".
      final firstInputs = find.byType(OiTextInput);
      await tester.enterText(firstInputs.first, 'Jane');
      await tester.pump();

      expect(latest, isNotNull);
      expect(latest!.firstName, 'Jane');
    });

    testWidgets('pre-fills from initialData', (tester) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: OiAddressForm(
            label: 'Address',
            initialData: OiAddressData(firstName: 'Alice', city: 'Zürich'),
          ),
        ),
        surfaceSize: const Size(800, 900),
      );

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Zürich'), findsOneWidget);
    });

    testWidgets('semantic label is set', (tester) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: OiAddressForm(label: 'Delivery address'),
        ),
        surfaceSize: const Size(800, 900),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Delivery address',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shipping constructor uses "Shipping address" label', (
      tester,
    ) async {
      await tester.pumpObers(
        const SingleChildScrollView(child: OiAddressForm.shipping()),
        surfaceSize: const Size(800, 900),
      );

      expect(find.text('Shipping address'), findsOneWidget);
    });

    testWidgets('billing constructor uses "Billing address" label', (
      tester,
    ) async {
      await tester.pumpObers(
        const SingleChildScrollView(child: OiAddressForm.billing()),
        surfaceSize: const Size(800, 900),
      );

      expect(find.text('Billing address'), findsOneWidget);
    });

    testWidgets('shipping constructor pre-fills initialData', (tester) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: OiAddressForm.shipping(
            initialData: OiAddressData(firstName: 'Alice'),
          ),
        ),
        surfaceSize: const Size(800, 900),
      );

      expect(find.text('Alice'), findsOneWidget);
    });
  });
}
