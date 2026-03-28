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
    await tester.pumpObers(const OiProgress.steps(steps: 4, currentStep: 2));
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
    await tester.pumpObers(const OiProgress.circular(indeterminate: true));
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

  // ── REQ-0025: color is never the sole indicator ──────────────────────────

  testWidgets('REQ-0025: completed steps show Icon checkmark', (tester) async {
    await tester.pumpObers(const OiProgress.steps(steps: 3, currentStep: 2));
    // 2 completed steps should each render an Icon (check).
    expect(find.byType(Icon), findsNWidgets(2));
  });

  testWidgets('REQ-0025: incomplete steps show no Icon', (tester) async {
    await tester.pumpObers(const OiProgress.steps(steps: 3, currentStep: 0));
    expect(find.byType(Icon), findsNothing);
  });

  // ── Reduced motion ────────────────────────────────────────────────────────

  testWidgets('reducedMotion: indeterminate linear does not animate', (
    tester,
  ) async {
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
  });

  testWidgets('reducedMotion: indeterminate circular does not animate', (
    tester,
  ) async {
    await tester.pumpObers(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: OiProgress.circular(indeterminate: true),
      ),
    );
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
  });

  // ── Bulk style ──────────────────────────────────────────────────────────────

  testWidgets('bulk style renders a linear progress bar', (tester) async {
    await tester.pumpObers(const OiProgress.bulk(current: 5, total: 18));
    expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
  });

  testWidgets('bulk style renders formatted label "(5/18)"', (tester) async {
    await tester.pumpObers(
      const OiProgress.bulk(
        current: 5,
        total: 18,
        label: 'Generating screen specs',
      ),
    );
    expect(find.text('Generating screen specs (5/18)'), findsOneWidget);
  });

  testWidgets('bulk style shows percentage when showPercentage is true', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiProgress.bulk(current: 5, total: 20),
    );
    expect(find.text('25%'), findsOneWidget);
  });

  testWidgets('bulk style hides percentage when showPercentage is false', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiProgress.bulk(current: 5, total: 20, showPercentage: false),
    );
    expect(find.text('25%'), findsNothing);
  });

  testWidgets('bulk style renders currentItemLabel when provided', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiProgress.bulk(
        current: 5,
        total: 18,
        currentItemLabel: 'Authentication Screen',
      ),
    );
    expect(find.text('Authentication Screen'), findsOneWidget);
  });

  testWidgets('bulk style handles total=0 without error', (tester) async {
    await tester.pumpObers(const OiProgress.bulk(current: 0, total: 0));
    expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
  });

  testWidgets('bulk style handles current > total gracefully', (tester) async {
    await tester.pumpObers(const OiProgress.bulk(current: 20, total: 10));
    expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
  });

  testWidgets('bulk style without label renders count only', (tester) async {
    await tester.pumpObers(const OiProgress.bulk(current: 3, total: 10));
    expect(find.text('3/10'), findsOneWidget);
  });
}
