// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inline_edit/oi_editable_date.dart';
import 'package:obers_ui/src/components/inputs/oi_date_input.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('display mode shows formatted date', (tester) async {
    await tester.pumpObers(OiEditableDate(value: DateTime(2024, 6, 15)));
    expect(find.text('2024-06-15'), findsOneWidget);
  });

  testWidgets('display mode shows dash when no value', (tester) async {
    await tester.pumpObers(const OiEditableDate());
    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('tap enters edit mode showing OiDateInput', (tester) async {
    await tester.pumpObers(OiEditableDate(value: DateTime(2024, 6, 15)));
    await tester.tap(find.text('2024-06-15'));
    await tester.pump();
    expect(find.byType(OiDateInput), findsOneWidget);
  });

  testWidgets('edit mode passes value to OiDateInput', (tester) async {
    final date = DateTime(2024, 3, 10);
    await tester.pumpObers(OiEditableDate(value: date));
    await tester.tap(find.text('2024-03-10'));
    await tester.pump();
    final widget = tester.widget<OiDateInput>(find.byType(OiDateInput));
    expect(widget.value, date);
  });

  testWidgets('disabled does not enter edit mode on tap', (tester) async {
    final date = DateTime(2024, 2, 20);
    await tester.pumpObers(OiEditableDate(value: date, enabled: false));
    await tester.tap(find.text('2024-02-20'));
    await tester.pump();
    expect(find.byType(OiDateInput), findsNothing);
  });

  testWidgets('custom date format is applied', (tester) async {
    await tester.pumpObers(
      OiEditableDate(value: DateTime(2024, 12, 5), dateFormat: 'dd/MM/yyyy'),
    );
    expect(find.text('05/12/2024'), findsOneWidget);
  });
}
