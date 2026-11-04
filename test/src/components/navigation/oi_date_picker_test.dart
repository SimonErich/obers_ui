// Tests do not require documentation comments.

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/navigation/oi_date_picker.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── Rendering ──────────────────────────────────────────────────────────────

  testWidgets('renders month/year header', (tester) async {
    await tester.pumpObers(OiDatePicker(value: DateTime(2024, 3, 15)));
    expect(find.text('March 2024'), findsOneWidget);
  });

  testWidgets('renders weekday headers', (tester) async {
    await tester.pumpObers(const OiDatePicker());
    expect(find.text('Mo'), findsOneWidget);
    expect(find.text('Su'), findsOneWidget);
    expect(find.text('Sa'), findsOneWidget);
  });

  testWidgets('renders day numbers in current month', (tester) async {
    await tester.pumpObers(OiDatePicker(value: DateTime(2024, 1, 15)));
    // January — verify some day numbers appear.
    expect(find.text('15'), findsOneWidget);
    expect(find.text('31'), findsOneWidget);
  });

  // ── Navigation ─────────────────────────────────────────────────────────────

  testWidgets('prev arrow navigates to previous month', (tester) async {
    await tester.pumpObers(OiDatePicker(value: DateTime(2024, 3, 15)));
    await tester.tap(find.byIcon(OiIcons.chevronLeft));
    await tester.pump();
    expect(find.text('February 2024'), findsOneWidget);
  });

  testWidgets('next arrow navigates to next month', (tester) async {
    await tester.pumpObers(OiDatePicker(value: DateTime(2024, 3, 15)));
    await tester.tap(find.byIcon(OiIcons.chevronRight));
    await tester.pump();
    expect(find.text('April 2024'), findsOneWidget);
  });

  // ── Selection ──────────────────────────────────────────────────────────────

  testWidgets('tapping a day fires onChanged', (tester) async {
    DateTime? picked;
    await tester.pumpObers(
      OiDatePicker(value: DateTime(2024, 3, 15), onChanged: (d) => picked = d),
    );
    // Tap day 10.
    await tester.tap(find.text('10'));
    await tester.pump();
    expect(picked, isNotNull);
    expect(picked!.day, 10);
    expect(picked!.month, 3);
  });

  // ── Range mode ─────────────────────────────────────────────────────────────

  testWidgets('range mode: tapping two days fires onRangeChanged', (
    tester,
  ) async {
    DateTime? rs;
    DateTime? re;
    await tester.pumpObers(
      OiDatePicker(
        rangeMode: true,
        value: DateTime(2024, 3, 15),
        onRangeChanged: (s, e) {
          rs = s;
          re = e;
        },
      ),
    );
    await tester.tap(find.text('5'));
    await tester.pump();
    await tester.tap(find.text('10'));
    await tester.pump();
    expect(rs?.day, 5);
    expect(re?.day, 10);
  });

  // ── Labels ─────────────────────────────────────────────────────────────────

  const germanLabels = OiDatePickerLabels(
    months: [
      'Januar',
      'Februar',
      'März',
      'April',
      'Mai',
      'Juni',
      'Juli',
      'August',
      'September',
      'Oktober',
      'November',
      'Dezember',
    ],
    weekdays: ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'],
    previousMonth: 'Vorheriger Monat',
    nextMonth: 'Nächster Monat',
    cancel: 'Abbrechen',
    confirm: 'Übernehmen',
  );

  testWidgets('renders the given month and weekday labels', (tester) async {
    await tester.pumpObers(
      OiDatePicker(value: DateTime(2024, 3, 15), labels: germanLabels),
    );
    expect(find.text('März 2024'), findsOneWidget);
    expect(find.text('Di'), findsOneWidget);
    expect(find.text('So'), findsOneWidget);
  });

  testWidgets('labels the month arrows for screen readers', (tester) async {
    await tester.pumpObers(const OiDatePicker(labels: germanLabels));
    expect(find.bySemanticsLabel('Vorheriger Monat'), findsOneWidget);
    expect(find.bySemanticsLabel('Nächster Monat'), findsOneWidget);
  });

  testWidgets('passes its labels on to the month picker', (tester) async {
    await tester.pumpObers(
      OiDatePicker(value: DateTime(2024, 3, 15), labels: germanLabels),
    );
    await tester.tap(find.text('März 2024'));
    await tester.pumpAndSettle();
    expect(find.text('Abbrechen'), findsOneWidget);
    expect(find.text('Übernehmen'), findsOneWidget);
    expect(find.text('Februar'), findsWidgets);
  });
}
