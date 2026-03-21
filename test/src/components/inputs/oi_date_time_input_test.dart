// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inputs/oi_date_input.dart';
import 'package:obers_ui/src/components/inputs/oi_date_time_input.dart';
import 'package:obers_ui/src/components/inputs/oi_time_input.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders without error', (tester) async {
    await tester.pumpObers(const OiDateTimeInput());
    expect(find.byType(OiDateTimeInput), findsOneWidget);
  });

  testWidgets('displays label when provided', (tester) async {
    await tester.pumpObers(const OiDateTimeInput(label: 'Event date'));
    expect(find.text('Event date'), findsOneWidget);
  });

  testWidgets('displays error message when provided', (tester) async {
    await tester.pumpObers(const OiDateTimeInput(error: 'Date is required'));
    expect(find.text('Date is required'), findsOneWidget);
  });

  testWidgets('displays hint when provided and no error', (tester) async {
    await tester.pumpObers(
      const OiDateTimeInput(hint: 'Select a date and time'),
    );
    expect(find.text('Select a date and time'), findsOneWidget);
  });

  testWidgets('error takes priority over hint', (tester) async {
    await tester.pumpObers(
      const OiDateTimeInput(hint: 'Pick a date', error: 'Invalid date'),
    );
    expect(find.text('Invalid date'), findsOneWidget);
    expect(find.text('Pick a date'), findsNothing);
  });

  testWidgets('shows both date and time sub-inputs', (tester) async {
    await tester.pumpObers(const OiDateTimeInput());
    expect(find.byType(OiDateInput), findsOneWidget);
    expect(find.byType(OiTimeInput), findsOneWidget);
  });

  testWidgets(
    'changing date fires onChanged with updated date, preserved time',
    (tester) async {
      DateTime? result;
      await tester.pumpObers(
        OiDateTimeInput(
          value: DateTime(2024, 6, 15, 14, 30),
          onChanged: (v) => result = v,
        ),
      );

      // Tap the date input to open picker
      final dateInputFinder = find.byType(OiDateInput);
      await tester.tap(
        find.descendant(
          of: dateInputFinder,
          matching: find.byType(GestureDetector),
        ),
      );
      await tester.pump();

      // Confirm the picker (keeps existing date, fires callback)
      await tester.tap(find.text('OK'));
      await tester.pump();

      // The time portion (14:30) should be preserved in the result
      expect(result, isNotNull);
      expect(result!.hour, 14);
      expect(result!.minute, 30);
    },
  );

  testWidgets(
    'changing time fires onChanged with updated time, preserved date',
    (tester) async {
      DateTime? result;
      await tester.pumpObers(
        OiDateTimeInput(
          value: DateTime(2024, 6, 15, 14, 30),
          onChanged: (v) => result = v,
        ),
      );

      // Tap the time input to open picker
      final timeInputFinder = find.byType(OiTimeInput);
      await tester.tap(
        find.descendant(
          of: timeInputFinder,
          matching: find.byType(GestureDetector),
        ),
      );
      await tester.pump();

      // Confirm the picker
      await tester.tap(find.text('OK'));
      await tester.pump();

      // The date portion should be preserved
      expect(result, isNotNull);
      expect(result!.year, 2024);
      expect(result!.month, 6);
      expect(result!.day, 15);
    },
  );

  testWidgets('when value is null and date selected, time defaults to 00:00', (
    tester,
  ) async {
    DateTime? result;
    await tester.pumpObers(OiDateTimeInput(onChanged: (v) => result = v));

    // Tap the date input to open picker
    final dateInputFinder = find.byType(OiDateInput);
    await tester.tap(
      find.descendant(
        of: dateInputFinder,
        matching: find.byType(GestureDetector),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('OK'));
    await tester.pump();

    expect(result, isNotNull);
    expect(result!.hour, 0);
    expect(result!.minute, 0);
  });

  testWidgets('when value is null and time selected, date defaults to today', (
    tester,
  ) async {
    DateTime? result;
    await tester.pumpObers(OiDateTimeInput(onChanged: (v) => result = v));

    // Tap the time input to open picker
    final timeInputFinder = find.byType(OiTimeInput);
    await tester.tap(
      find.descendant(
        of: timeInputFinder,
        matching: find.byType(GestureDetector),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('OK'));
    await tester.pump();

    final today = DateTime.now();
    expect(result, isNotNull);
    expect(result!.year, today.year);
    expect(result!.month, today.month);
    expect(result!.day, today.day);
  });

  testWidgets('enabled=false prevents interaction on both sub-inputs', (
    tester,
  ) async {
    await tester.pumpObers(const OiDateTimeInput(enabled: false));

    // Try to tap date input — should not open picker
    final dateGestures = find.descendant(
      of: find.byType(OiDateInput),
      matching: find.byType(GestureDetector),
    );
    await tester.tap(dateGestures, warnIfMissed: false);
    await tester.pump();
    expect(find.text('OK'), findsNothing);

    // Try to tap time input — should not open picker
    final timeGestures = find.descendant(
      of: find.byType(OiTimeInput),
      matching: find.byType(GestureDetector),
    );
    await tester.tap(timeGestures, warnIfMissed: false);
    await tester.pump();
    expect(find.text('OK'), findsNothing);
  });

  testWidgets('readOnly prevents interaction', (tester) async {
    await tester.pumpObers(const OiDateTimeInput(readOnly: true));

    final dateGestures = find.descendant(
      of: find.byType(OiDateInput),
      matching: find.byType(GestureDetector),
    );
    await tester.tap(dateGestures, warnIfMissed: false);
    await tester.pump();
    expect(find.text('OK'), findsNothing);
  });

  testWidgets('required=true shows asterisk on label', (tester) async {
    await tester.pumpObers(
      const OiDateTimeInput(label: 'Deadline', required: true),
    );
    expect(find.text('Deadline'), findsOneWidget);
    expect(find.text('*'), findsOneWidget);
  });

  testWidgets('min/max passed to date input', (tester) async {
    final minDate = DateTime(2020);
    final maxDate = DateTime(2030);

    await tester.pumpObers(OiDateTimeInput(min: minDate, max: maxDate));

    final dateInput = tester.widget<OiDateInput>(find.byType(OiDateInput));
    expect(dateInput.firstDate, minDate);
    expect(dateInput.lastDate, maxDate);
  });

  testWidgets('displays formatted date and time when value provided', (
    tester,
  ) async {
    await tester.pumpObers(
      OiDateTimeInput(value: DateTime(2024, 3, 15, 9, 30)),
    );
    // Date portion
    expect(find.text('2024-03-15'), findsOneWidget);
    // Time portion
    expect(find.text('09:30'), findsOneWidget);
  });
}
