// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inputs/oi_time_input.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders without error', (tester) async {
    await tester.pumpObers(const OiTimeInput());
    expect(find.byType(OiTimeInput), findsOneWidget);
  });

  testWidgets('displays formatted time when value provided', (tester) async {
    await tester.pumpObers(
      const OiTimeInput(value: OiTimeOfDay(hour: 9, minute: 5)),
    );
    expect(find.text('09:05'), findsOneWidget);
  });

  testWidgets('clock icon is present', (tester) async {
    await tester.pumpObers(const OiTimeInput());
    expect(find.byType(Icon), findsOneWidget);
  });

  testWidgets('label is shown', (tester) async {
    await tester.pumpObers(const OiTimeInput(label: 'Start time'));
    expect(find.text('Start time'), findsOneWidget);
  });

  testWidgets('tapping opens picker overlay', (tester) async {
    await tester.pumpObers(const OiTimeInput());
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pump();
    expect(find.text('OK'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('enabled=false prevents picker opening', (tester) async {
    await tester.pumpObers(const OiTimeInput(enabled: false));
    await tester.tap(
      find.byType(GestureDetector).first,
      warnIfMissed: false,
    );
    await tester.pump();
    expect(find.text('OK'), findsNothing);
  });

  testWidgets('OiTimeOfDay equality', (tester) async {
    const a = OiTimeOfDay(hour: 10, minute: 30);
    const b = OiTimeOfDay(hour: 10, minute: 30);
    const c = OiTimeOfDay(hour: 11, minute: 0);
    expect(a, b);
    expect(a, isNot(c));
  });

  testWidgets('OiTimeOfDay toString', (tester) async {
    const t = OiTimeOfDay(hour: 8, minute: 5);
    expect(t.toString(), '08:05');
  });

  testWidgets('12-hour format shows AM/PM', (tester) async {
    await tester.pumpObers(
      const OiTimeInput(
        value: OiTimeOfDay(hour: 14, minute: 0),
        use24Hour: false,
      ),
    );
    expect(find.textContaining('PM'), findsOneWidget);
  });
}
