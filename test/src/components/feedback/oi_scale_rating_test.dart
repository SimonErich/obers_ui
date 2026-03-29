// Tests do not require documentation comments.

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/feedback/oi_scale_rating.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders all scale numbers', (tester) async {
    await tester.pumpObers(const OiScaleRating(max: 5));
    for (var i = 1; i <= 5; i++) {
      expect(find.text('$i'), findsOneWidget);
    }
  });

  testWidgets('default max is 10', (tester) async {
    await tester.pumpObers(const OiScaleRating());
    expect(find.text('10'), findsOneWidget);
  });

  testWidgets('onChanged fires with correct value', (tester) async {
    int? received;
    await tester.pumpObers(
      OiScaleRating(max: 5, onChanged: (v) => received = v),
    );
    await tester.tap(find.text('3'));
    await tester.pump();
    expect(received, 3);
  });

  testWidgets('enabled=false blocks onChanged', (tester) async {
    int? received;
    await tester.pumpObers(
      OiScaleRating(max: 5, enabled: false, onChanged: (v) => received = v),
    );
    await tester.tap(find.text('2'), warnIfMissed: false);
    await tester.pump();
    expect(received, isNull);
  });

  testWidgets('minLabel and maxLabel are shown', (tester) async {
    await tester.pumpObers(
      const OiScaleRating(
        max: 5,
        minLabel: 'Not likely',
        maxLabel: 'Very likely',
      ),
    );
    expect(find.text('Not likely'), findsOneWidget);
    expect(find.text('Very likely'), findsOneWidget);
  });

  testWidgets('selected value is highlighted', (tester) async {
    await tester.pumpObers(const OiScaleRating(value: 4, max: 5));
    // The selected button text is present and widget builds without error.
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('custom min renders numbers from min to max', (tester) async {
    await tester.pumpObers(const OiScaleRating(min: 3, max: 7));
    for (var i = 3; i <= 7; i++) {
      expect(find.text('$i'), findsOneWidget);
    }
    // Numbers below min are not shown.
    expect(find.text('1'), findsNothing);
    expect(find.text('2'), findsNothing);
  });

  testWidgets('onChanged fires correct value with custom min', (tester) async {
    int? received;
    await tester.pumpObers(
      OiScaleRating(min: 3, max: 7, onChanged: (v) => received = v),
    );
    await tester.tap(find.text('5'));
    await tester.pump();
    expect(received, 5);
  });

  testWidgets('label is included in semantics', (tester) async {
    await tester.pumpObers(const OiScaleRating(label: 'NPS score'));
    expect(find.bySemanticsLabel(RegExp('NPS score')), findsOneWidget);
  });
}
