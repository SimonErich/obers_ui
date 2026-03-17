// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inputs/oi_time_input.dart'
    show OiTimeOfDay;
import 'package:obers_ui/src/components/navigation/oi_time_picker.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── Rendering ──────────────────────────────────────────────────────────────

  testWidgets('renders without error', (tester) async {
    await tester.pumpObers(
      const OiTimePicker(value: OiTimeOfDay(hour: 10, minute: 30)),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders hour and minute ListWheelScrollViews', (tester) async {
    await tester.pumpObers(
      const OiTimePicker(value: OiTimeOfDay(hour: 8, minute: 0)),
    );
    expect(find.byType(ListWheelScrollView), findsNWidgets(2));
  });

  testWidgets('24-hour mode: no AM/PM toggle shown', (tester) async {
    await tester.pumpObers(
      const OiTimePicker(),
    );
    expect(find.text('AM'), findsNothing);
    expect(find.text('PM'), findsNothing);
  });

  testWidgets('12-hour mode: AM and PM buttons shown', (tester) async {
    await tester.pumpObers(
      const OiTimePicker(use24Hour: false),
    );
    expect(find.text('AM'), findsOneWidget);
    expect(find.text('PM'), findsOneWidget);
  });

  // ── AM/PM toggle ───────────────────────────────────────────────────────────

  testWidgets('tapping PM button fires onChanged with PM hour', (tester) async {
    OiTimeOfDay? result;
    await tester.pumpObers(
      OiTimePicker(
        use24Hour: false,
        value: const OiTimeOfDay(hour: 9, minute: 0),
        onChanged: (t) => result = t,
      ),
    );
    await tester.tap(find.text('PM'));
    await tester.pump();
    expect(result, isNotNull);
    expect(result!.hour, greaterThanOrEqualTo(12));
  });

  testWidgets('tapping AM button fires onChanged with AM hour', (tester) async {
    OiTimeOfDay? result;
    await tester.pumpObers(
      OiTimePicker(
        use24Hour: false,
        value: const OiTimeOfDay(hour: 14, minute: 0),
        onChanged: (t) => result = t,
      ),
    );
    await tester.tap(find.text('AM'));
    await tester.pump();
    expect(result, isNotNull);
    expect(result!.hour, lessThan(12));
  });

  // ── onChanged ──────────────────────────────────────────────────────────────

  testWidgets('null value renders without error', (tester) async {
    await tester.pumpObers(const OiTimePicker());
    expect(tester.takeException(), isNull);
    expect(find.byType(ListWheelScrollView), findsNWidgets(2));
  });
}
