// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_progress.dart';
import 'package:obers_ui/src/components/feedback/oi_pipeline_progress.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── Helper ──────────────────────────────────────────────────────────────

  List<OiPipelineProgressStep> threeSteps({String? detail, Widget? sub}) {
    return [
      const OiPipelineProgressStep(label: 'Build'),
      OiPipelineProgressStep(label: 'Test', detail: detail, subProgress: sub),
      const OiPipelineProgressStep(label: 'Deploy'),
    ];
  }

  // ── Rendering ─────────────────────────────────────────────────────────────

  testWidgets('renders all step labels', (tester) async {
    await tester.pumpObers(
      OiPipelineProgress(
        label: 'Pipeline',
        currentStepIndex: 0,
        steps: threeSteps(),
      ),
    );

    expect(find.text('Build'), findsOneWidget);
    expect(find.text('Test'), findsOneWidget);
    expect(find.text('Deploy'), findsOneWidget);
  });

  // ── Completed steps ─────────────────────────────────────────────────────

  testWidgets('completed steps show checkmark icon', (tester) async {
    await tester.pumpObers(
      OiPipelineProgress(
        label: 'Pipeline',
        currentStepIndex: 2,
        steps: threeSteps(),
      ),
    );

    // Steps 0 and 1 are completed — each should have a decorative OiIcon.
    // The active step (index 2) shows a spinner, not an OiIcon.
    // Future steps also show OiIcon.  With currentStepIndex=2, there are
    // no future steps, so exactly 2 OiIcons (both checkmarks).
    final icons = tester.widgetList<OiIcon>(find.byType(OiIcon)).toList();
    expect(icons.length, 2);
  });

  // ── Active step ─────────────────────────────────────────────────────────

  testWidgets('active step shows progress indicator', (tester) async {
    await tester.pumpObers(
      OiPipelineProgress(
        label: 'Pipeline',
        currentStepIndex: 1,
        steps: threeSteps(),
      ),
    );

    expect(find.byType(OiProgress), findsOneWidget);
  });

  // ── Future steps ────────────────────────────────────────────────────────

  testWidgets('future steps render with muted styling', (tester) async {
    await tester.pumpObers(
      OiPipelineProgress(
        label: 'Pipeline',
        currentStepIndex: 0,
        steps: threeSteps(),
      ),
    );

    // Steps 1 and 2 are future steps. They get OiIcon with circle icon.
    // Step 0 is active (spinner), so 2 OiIcons for the future steps.
    final icons = tester.widgetList<OiIcon>(find.byType(OiIcon)).toList();
    expect(icons.length, 2);
  });

  // ── Error state ─────────────────────────────────────────────────────────

  testWidgets('error state shows error message', (tester) async {
    await tester.pumpObers(
      OiPipelineProgress(
        label: 'Pipeline',
        currentStepIndex: 1,
        error: 'Connection timed out',
        steps: threeSteps(),
      ),
    );

    expect(find.text('Connection timed out'), findsOneWidget);
    // Error replaces spinner — no OiProgress should be visible.
    expect(find.byType(OiProgress), findsNothing);
  });

  testWidgets('error state shows retry button when onRetry provided', (
    tester,
  ) async {
    var retried = false;
    await tester.pumpObers(
      OiPipelineProgress(
        label: 'Pipeline',
        currentStepIndex: 1,
        error: 'Failed',
        onRetry: () => retried = true,
        steps: threeSteps(),
      ),
    );

    expect(find.text('Retry'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });

  testWidgets('error state hides retry button when onRetry is null', (
    tester,
  ) async {
    await tester.pumpObers(
      OiPipelineProgress(
        label: 'Pipeline',
        currentStepIndex: 1,
        error: 'Failed',
        steps: threeSteps(),
      ),
    );

    expect(find.text('Retry'), findsNothing);
  });

  // ── Cancel button ───────────────────────────────────────────────────────

  testWidgets('cancel button renders when onCancel provided', (tester) async {
    var cancelled = false;
    await tester.pumpObers(
      OiPipelineProgress(
        label: 'Pipeline',
        currentStepIndex: 0,
        onCancel: () => cancelled = true,
        steps: threeSteps(),
      ),
    );

    expect(find.text('Cancel'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    expect(cancelled, isTrue);
  });

  testWidgets('cancel button hidden when onCancel is null', (tester) async {
    await tester.pumpObers(
      OiPipelineProgress(
        label: 'Pipeline',
        currentStepIndex: 0,
        steps: threeSteps(),
      ),
    );

    expect(find.text('Cancel'), findsNothing);
  });

  // ── Detail text ─────────────────────────────────────────────────────────

  testWidgets('detail text renders for active step', (tester) async {
    await tester.pumpObers(
      OiPipelineProgress(
        label: 'Pipeline',
        currentStepIndex: 1,
        steps: threeSteps(detail: 'Running 48 tests'),
      ),
    );

    expect(find.text('Running 48 tests'), findsOneWidget);
  });

  testWidgets('detail text hidden for completed step', (tester) async {
    await tester.pumpObers(
      OiPipelineProgress(
        label: 'Pipeline',
        currentStepIndex: 2,
        steps: threeSteps(detail: 'Running 48 tests'),
      ),
    );

    // Step 1 has the detail but is now completed — detail should not show.
    expect(find.text('Running 48 tests'), findsNothing);
  });

  // ── Accessibility ───────────────────────────────────────────────────────

  testWidgets('has semantics label', (tester) async {
    await tester.pumpObers(
      OiPipelineProgress(
        label: 'Deployment pipeline',
        currentStepIndex: 0,
        steps: threeSteps(),
      ),
    );

    // The Semantics widget wrapping the pipeline should carry the label.
    final semanticsFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics &&
          widget.properties.label == 'Deployment pipeline',
    );
    expect(semanticsFinder, findsOneWidget);
  });

  // ── Sub-progress widget ─────────────────────────────────────────────────

  testWidgets('sub-progress widget renders for active step', (tester) async {
    await tester.pumpObers(
      OiPipelineProgress(
        label: 'Pipeline',
        currentStepIndex: 1,
        steps: threeSteps(
          sub: const SizedBox(key: Key('sub-progress'), height: 4),
        ),
      ),
    );

    expect(find.byKey(const Key('sub-progress')), findsOneWidget);
  });
}
