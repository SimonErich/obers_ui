// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_progress.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('linear style renders', (tester) async {
    await tester.pumpObers(const OiProgress.linear(value: 0.5));
    expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
  });

  testWidgets('circular style renders', (tester) async {
    await tester.pumpObers(const OiProgress.circular(value: 0.75));
    expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
  });

  testWidgets('steps style renders step dots', (tester) async {
    await tester.pumpObers(
      const OiProgress.steps(steps: 4, currentStep: 2),
    );
    // The steps Row contains 4 Container dots.
    expect(find.byType(Container), findsAtLeastNWidgets(4));
  });

  testWidgets('label is rendered when provided', (tester) async {
    await tester.pumpObers(
      const OiProgress.linear(value: 0.3, label: 'Loading…'),
    );
    expect(find.text('Loading…'), findsOneWidget);
  });

  testWidgets('indeterminate linear animates', (tester) async {
    await tester.pumpObers(const OiProgress.linear(indeterminate: true));
    expect(find.byType(AnimatedBuilder), findsAtLeastNWidgets(1));
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets('indeterminate circular animates', (tester) async {
    await tester.pumpObers(
      const OiProgress.circular(indeterminate: true),
    );
    expect(find.byType(AnimatedBuilder), findsAtLeastNWidgets(1));
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets('value 0.0 renders without error', (tester) async {
    await tester.pumpObers(const OiProgress.linear());
    expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
  });

  testWidgets('value 1.0 renders without error', (tester) async {
    await tester.pumpObers(const OiProgress.linear(value: 1));
    expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
  });

  // ── Reduced motion ────────────────────────────────────────────────────────

  testWidgets(
    'reducedMotion: indeterminate linear does not animate',
    (tester) async {
      await tester.pumpObers(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: OiProgress.linear(indeterminate: true),
        ),
      );
      await tester.pump();

      // With reducedMotion, duration is Duration.zero — the controller
      // completes instantly. Pumping extra frames should not throw.
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
    },
  );

  testWidgets(
    'reducedMotion: indeterminate circular does not animate',
    (tester) async {
      await tester.pumpObers(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: OiProgress.circular(indeterminate: true),
        ),
      );
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
    },
  );
}
