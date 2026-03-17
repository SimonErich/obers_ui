// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inline_edit/oi_editable_number.dart';
import 'package:obers_ui/src/components/inputs/oi_number_input.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('display mode shows formatted value', (tester) async {
    await tester.pumpObers(
      const OiEditableNumber(value: 42),
    );
    expect(find.text('42'), findsOneWidget);
  });

  testWidgets('display mode shows dash when no value', (tester) async {
    await tester.pumpObers(
      const OiEditableNumber(),
    );
    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('tap enters edit mode showing OiNumberInput', (tester) async {
    await tester.pumpObers(
      const OiEditableNumber(value: 42),
    );
    await tester.tap(find.text('42'));
    await tester.pump();
    expect(find.byType(OiNumberInput), findsOneWidget);
  });

  testWidgets('edit mode passes value and step to OiNumberInput',
      (tester) async {
    await tester.pumpObers(
      const OiEditableNumber(value: 10, step: 5, min: 0, max: 100),
    );
    await tester.tap(find.text('10'));
    await tester.pump();
    final widget = tester.widget<OiNumberInput>(find.byType(OiNumberInput));
    expect(widget.value, 10);
    expect(widget.step, 5);
    expect(widget.min, 0);
    expect(widget.max, 100);
  });

  testWidgets('disabled does not enter edit mode on tap', (tester) async {
    await tester.pumpObers(
      const OiEditableNumber(value: 7, enabled: false),
    );
    await tester.tap(find.text('7'));
    await tester.pump();
    expect(find.byType(OiNumberInput), findsNothing);
  });
}
