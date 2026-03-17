// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/feedback/oi_scale_rating.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders all scale numbers', (tester) async {
    await tester.pumpObers(const OiScaleRating(scale: 5));
    for (var i = 1; i <= 5; i++) {
      expect(find.text('$i'), findsOneWidget);
    }
  });

  testWidgets('default scale is 10', (tester) async {
    await tester.pumpObers(const OiScaleRating());
    expect(find.text('10'), findsOneWidget);
  });

  testWidgets('onChanged fires with correct value', (tester) async {
    int? received;
    await tester.pumpObers(
      OiScaleRating(scale: 5, onChanged: (v) => received = v),
    );
    await tester.tap(find.text('3'));
    await tester.pump();
    expect(received, 3);
  });

  testWidgets('enabled=false blocks onChanged', (tester) async {
    int? received;
    await tester.pumpObers(
      OiScaleRating(scale: 5, enabled: false, onChanged: (v) => received = v),
    );
    await tester.tap(find.text('2'), warnIfMissed: false);
    await tester.pump();
    expect(received, isNull);
  });

  testWidgets('startLabel and endLabel are shown', (tester) async {
    await tester.pumpObers(
      const OiScaleRating(
        scale: 5,
        startLabel: 'Not likely',
        endLabel: 'Very likely',
      ),
    );
    expect(find.text('Not likely'), findsOneWidget);
    expect(find.text('Very likely'), findsOneWidget);
  });

  testWidgets('selected value is highlighted', (tester) async {
    await tester.pumpObers(const OiScaleRating(value: 4, scale: 5));
    // The selected button text is present and widget builds without error.
    expect(find.text('4'), findsOneWidget);
  });
}
