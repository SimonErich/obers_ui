// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inputs/oi_number_input.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders without error', (tester) async {
    await tester.pumpObers(const OiNumberInput());
    expect(find.byType(OiNumberInput), findsOneWidget);
  });

  testWidgets('displays initial value', (tester) async {
    await tester.pumpObers(const OiNumberInput(value: 42));
    expect(find.text('42'), findsOneWidget);
  });

  testWidgets('increment button fires onChanged', (tester) async {
    double? result;
    await tester.pumpObers(
      OiNumberInput(value: 5, onChanged: (v) => result = v),
    );
    // The '+' button is the trailing widget.
    await tester.tap(find.text('+'));
    await tester.pump();
    expect(result, 6);
  });

  testWidgets('decrement button fires onChanged', (tester) async {
    double? result;
    await tester.pumpObers(
      OiNumberInput(value: 5, onChanged: (v) => result = v),
    );
    await tester.tap(find.text('−'));
    await tester.pump();
    expect(result, 4);
  });

  testWidgets('max clamping prevents exceeding max', (tester) async {
    double? result;
    await tester.pumpObers(
      OiNumberInput(value: 10, max: 10, onChanged: (v) => result = v),
    );
    await tester.tap(find.text('+'));
    await tester.pump();
    expect(result, 10);
  });

  testWidgets('min clamping prevents going below min', (tester) async {
    double? result;
    await tester.pumpObers(
      OiNumberInput(value: 0, min: 0, onChanged: (v) => result = v),
    );
    await tester.tap(find.text('−'));
    await tester.pump();
    expect(result, 0);
  });

  testWidgets('label is shown', (tester) async {
    await tester.pumpObers(const OiNumberInput(label: 'Quantity'));
    expect(find.text('Quantity'), findsOneWidget);
  });

  testWidgets('decimalPlaces formats value', (tester) async {
    await tester.pumpObers(
      const OiNumberInput(value: 3.14159, decimalPlaces: 2),
    );
    expect(find.text('3.14'), findsOneWidget);
  });
}
