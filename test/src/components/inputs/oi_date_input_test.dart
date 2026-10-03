// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inputs/oi_date_input.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('presets and the custom picker share one date value', (
    tester,
  ) async {
    var value = DateTime(2026, 9, 28);
    await tester.pumpObers(
      StatefulBuilder(
        builder: (context, setState) => OiDateInput(
          value: value,
          dateFormat: 'd MMM yyyy',
          presets: [
            OiDatePreset(date: DateTime(2026, 9, 28), label: 'Today'),
            OiDatePreset(date: DateTime(2026, 9, 29), label: 'Tomorrow'),
          ],
          onChanged: (next) => setState(() => value = next!),
        ),
      ),
    );
    await tester.tap(find.text('Tomorrow'));
    await tester.pumpAndSettle();
    expect(value, DateTime(2026, 9, 29));
    await tester.tap(find.text('Pick a date'));
    await tester.pumpAndSettle();
    expect(find.text('OK'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(value, DateTime(2026, 9, 29));
  });

  testWidgets('a selected custom date can reopen the picker', (tester) async {
    await tester.pumpObers(
      OiDateInput(
        value: DateTime(2026, 10, 2),
        dateFormat: 'd MMM yyyy',
        presets: [OiDatePreset(date: DateTime(2026, 9, 28), label: 'Today')],
      ),
    );
    for (var attempt = 0; attempt < 2; attempt++) {
      await tester.tap(find.text('2 Oct 2026'));
      await tester.pumpAndSettle();
      expect(find.text('OK'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('disabled presets cannot change the date', (tester) async {
    DateTime? selected;
    await tester.pumpObers(
      OiDateInput(
        value: DateTime(2026, 9, 29),
        presets: [
          OiDatePreset(
            date: DateTime(2026, 9, 28),
            label: 'Today',
            enabled: false,
          ),
          OiDatePreset(date: DateTime(2026, 9, 29), label: 'Tomorrow'),
        ],
        onChanged: (next) => selected = next,
      ),
    );
    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    expect(selected, isNull);
  });

  testWidgets('renders without error', (tester) async {
    await tester.pumpObers(const OiDateInput());
    expect(find.byType(OiDateInput), findsOneWidget);
  });

  testWidgets('displays formatted date when value provided', (tester) async {
    await tester.pumpObers(OiDateInput(value: DateTime(2024, 6, 15)));
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
      OiDateInput(value: DateTime(2024, 1, 5), dateFormat: 'dd/MM/yyyy'),
    );
    expect(find.text('05/01/2024'), findsOneWidget);
  });

  testWidgets('tapping opens picker overlay', (tester) async {
    await tester.pumpObers(const OiDateInput());
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();
    // Picker has OK and Cancel buttons.
    expect(find.text('OK'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('textual month tokens and quoted literals remain intact', (
    tester,
  ) async {
    await tester.pumpObers(
      OiDateInput(value: DateTime(2026, 9, 28), dateFormat: 'dd MMM yyyy'),
    );
    expect(find.text('28 Sep 2026'), findsOneWidget);
    expect(find.textContaining('09M'), findsNothing);
    await tester.pumpObers(
      OiDateInput(
        value: DateTime(2026, 9, 28),
        dateFormat: "EEEE, d MMMM yyyy 'at'",
      ),
    );
    expect(find.text('Monday, 28 September 2026 at'), findsOneWidget);
  });

  testWidgets('enabled=false prevents picker opening', (tester) async {
    await tester.pumpObers(const OiDateInput(enabled: false));
    await tester.tap(find.byType(GestureDetector).first, warnIfMissed: false);
    await tester.pump();
    expect(find.text('OK'), findsNothing);
  });

  testWidgets('explicit locale formats textual months consistently', (
    tester,
  ) async {
    await tester.pumpObers(
      OiDateInput(
        value: DateTime(2026, 9, 29),
        dateFormat: 'dd MMM yyyy',
        locale: 'en_IE',
      ),
    );
    expect(find.text('29 Sept 2026'), findsOneWidget);
  });
}
