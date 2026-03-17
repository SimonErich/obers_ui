// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inputs/oi_date_input.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders without error', (tester) async {
    await tester.pumpObers(const OiDateInput());
    expect(find.byType(OiDateInput), findsOneWidget);
  });

  testWidgets('displays formatted date when value provided', (tester) async {
    await tester.pumpObers(
      OiDateInput(value: DateTime(2024, 6, 15)),
    );
    expect(find.text('2024-06-15'), findsOneWidget);
  });

  testWidgets('calendar icon is present', (tester) async {
    await tester.pumpObers(const OiDateInput());
    expect(find.byType(Icon), findsOneWidget);
  });

  testWidgets('label is shown', (tester) async {
    await tester.pumpObers(const OiDateInput(label: 'Date of birth'));
    expect(find.text('Date of birth'), findsOneWidget);
  });

  testWidgets('custom dateFormat is applied', (tester) async {
    await tester.pumpObers(
      OiDateInput(
        value: DateTime(2024, 1, 5),
        dateFormat: 'dd/MM/yyyy',
      ),
    );
    expect(find.text('05/01/2024'), findsOneWidget);
  });

  testWidgets('tapping opens picker overlay', (tester) async {
    await tester.pumpObers(const OiDateInput());
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pump();
    // Picker has OK and Cancel buttons.
    expect(find.text('OK'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('enabled=false prevents picker opening', (tester) async {
    await tester.pumpObers(const OiDateInput(enabled: false));
    await tester.tap(
      find.byType(GestureDetector).first,
      warnIfMissed: false,
    );
    await tester.pump();
    expect(find.text('OK'), findsNothing);
  });
}
