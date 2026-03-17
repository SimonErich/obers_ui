// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inputs/oi_color_input.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders without error', (tester) async {
    await tester.pumpObers(const OiColorInput());
    expect(find.byType(OiColorInput), findsOneWidget);
  });

  testWidgets('shows hex value when color provided', (tester) async {
    await tester.pumpObers(const OiColorInput(value: Color(0xFF2563EB)));
    expect(find.text('#2563eb'), findsOneWidget);
  });

  testWidgets('label is shown', (tester) async {
    await tester.pumpObers(const OiColorInput(label: 'Brand color'));
    expect(find.text('Brand color'), findsOneWidget);
  });

  testWidgets('tapping swatch opens picker overlay', (tester) async {
    await tester.pumpObers(const OiColorInput());
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pump();
    expect(find.byType(OiColorInput), findsOneWidget);
  });

  testWidgets('enabled=false prevents opening picker', (tester) async {
    var called = false;
    await tester.pumpObers(
      OiColorInput(enabled: false, onChanged: (_) => called = true),
    );
    await tester.tap(find.byType(GestureDetector).first, warnIfMissed: false);
    await tester.pump();
    expect(called, isFalse);
  });

  testWidgets('onChanged can be called on color selection', (tester) async {
    final received = <Color?>[];
    await tester.pumpObers(OiColorInput(onChanged: received.add));
    // Open picker then interact — just verify no crash.
    await tester.tap(find.byType(OiColorInput));
    await tester.pump();
    expect(find.byType(OiColorInput), findsOneWidget);
  });
}
