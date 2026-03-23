// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders label and placeholder when no value', (tester) async {
    await tester.pumpObers(
      const OiDatePickerField(
        label: 'Birth Date',
        placeholder: 'Choose a date',
      ),
    );

    expect(find.text('Birth Date'), findsOneWidget);
    expect(find.text('Choose a date'), findsOneWidget);
  });

  testWidgets('shows formatted date when value is set', (tester) async {
    await tester.pumpObers(
      OiDatePickerField(
        value: DateTime(2026, 3, 23),
      ),
    );

    // Default format is 'MMM d, yyyy'.
    expect(find.text('Mar 23, 2026'), findsOneWidget);
  });

  testWidgets('renders calendar icon', (tester) async {
    await tester.pumpObers(
      const OiDatePickerField(),
    );

    expect(find.byIcon(OiIcons.calendarDays), findsOneWidget);
  });

  testWidgets('disabled state prevents interaction', (tester) async {
    await tester.pumpObers(
      OiDatePickerField(
        value: DateTime(2026, 1, 15),
        enabled: false,
      ),
    );

    // The field should render but tapping should not open a picker.
    // We verify the widget renders without error in disabled state.
    expect(find.byType(OiDatePickerField), findsOneWidget);
    expect(find.text('Jan 15, 2026'), findsOneWidget);

    // Tap should be a no-op (no dialog opens, no crash).
    await tester.tap(find.byType(GestureDetector).first, warnIfMissed: false);
    await tester.pump();

    // Still showing the same value — nothing changed.
    expect(find.text('Jan 15, 2026'), findsOneWidget);
  });
}
