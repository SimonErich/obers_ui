// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/forms/oi_stepper.dart';
import 'package:obers_ui/src/composites/forms/oi_wizard.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

List<OiWizardStep> _steps({
  bool Function(Map<String, dynamic>)? step1Validate,
}) => [
  OiWizardStep(
    title: 'Step One',
    subtitle: 'First step subtitle',
    builder: (ctx) => const Text('Content One'),
    validate: step1Validate,
  ),
  OiWizardStep(title: 'Step Two', builder: (ctx) => const Text('Content Two')),
  OiWizardStep(
    title: 'Step Three',
    builder: (ctx) => const Text('Content Three'),
  ),
];

/// Same as [_steps] but with the first step marked optional, so the skip
/// button renders.
List<OiWizardStep> _optionalSteps() => [
  OiWizardStep(
    title: 'Step One',
    optional: true,
    builder: (ctx) => const Text('Content One'),
  ),
  OiWizardStep(title: 'Step Two', builder: (ctx) => const Text('Content Two')),
  OiWizardStep(
    title: 'Step Three',
    builder: (ctx) => const Text('Content Three'),
  ),
];

Widget _wizard({
  List<OiWizardStep>? steps,
  ValueChanged<Map<String, dynamic>>? onComplete,
  VoidCallback? onCancel,
  ValueChanged<int>? onStepChange,
  bool linear = true,
  bool allowSkip = false,
  bool showSummary = true,
  OiStepperStyle stepperStyle = OiStepperStyle.horizontal,
  bool animated = true,
  Map<String, dynamic>? initialValues,
  OiWizardLabels labels = const OiWizardLabels(),
}) {
  return SizedBox(
    width: 500,
    height: 600,
    child: SingleChildScrollView(
      child: OiWizard(
        steps: steps ?? _steps(),
        onComplete: onComplete,
        onCancel: onCancel,
        onStepChange: onStepChange,
        linear: linear,
        allowSkip: allowSkip,
        showSummary: showSummary,
        stepperStyle: stepperStyle,
        animated: animated,
        initialValues: initialValues,
        labels: labels,
      ),
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // 1. First step renders by default
  testWidgets('first step content renders by default', (tester) async {
    await tester.pumpObers(_wizard());

    expect(find.text('Content One'), findsOneWidget);
    expect(find.text('Step One'), findsWidgets);
  });

  // 2. Step subtitle renders
  testWidgets('step subtitle renders', (tester) async {
    await tester.pumpObers(_wizard());

    expect(find.text('First step subtitle'), findsOneWidget);
  });

  // 3. Next button advances to next step
  testWidgets('Next advances to the next step', (tester) async {
    await tester.pumpObers(_wizard(animated: false));

    await tester.tap(find.text('Next'));
    await tester.pump();

    expect(find.text('Content Two'), findsOneWidget);
  });

  // 4. Previous button goes back
  testWidgets('Previous goes back to the previous step', (tester) async {
    await tester.pumpObers(_wizard(animated: false));

    // Go to step 2.
    await tester.tap(find.text('Next'));
    await tester.pump();
    expect(find.text('Content Two'), findsOneWidget);

    // Go back to step 1.
    await tester.tap(find.text('Previous'));
    await tester.pump();
    expect(find.text('Content One'), findsOneWidget);
  });

  // 5. Previous button is not shown on the first step
  testWidgets('Previous is not shown on the first step', (tester) async {
    await tester.pumpObers(_wizard());

    expect(find.text('Previous'), findsNothing);
  });

  // 6. Validation blocks next
  testWidgets('validation blocks advancing to the next step', (tester) async {
    await tester.pumpObers(
      _wizard(animated: false, steps: _steps(step1Validate: (_) => false)),
    );

    await tester.tap(find.text('Next'));
    await tester.pump();

    // Should still be on step one because validation failed.
    expect(find.text('Content One'), findsOneWidget);
  });

  // 7. Passing validation allows advancing
  testWidgets('passing validation allows advancing', (tester) async {
    await tester.pumpObers(
      _wizard(animated: false, steps: _steps(step1Validate: (_) => true)),
    );

    await tester.tap(find.text('Next'));
    await tester.pump();

    expect(find.text('Content Two'), findsOneWidget);
  });

  // 8. onComplete fires when completing last step
  testWidgets('onComplete fires on the last step', (tester) async {
    Map<String, dynamic>? completedValues;

    await tester.pumpObers(
      _wizard(animated: false, onComplete: (v) => completedValues = v),
    );

    // Navigate to step 2.
    await tester.tap(find.text('Next'));
    await tester.pump();

    // Navigate to step 3.
    await tester.tap(find.text('Next'));
    await tester.pump();

    // Complete from step 3 (last step shows "Complete" button).
    expect(find.text('Complete'), findsOneWidget);
    await tester.tap(find.text('Complete'));
    await tester.pump();

    expect(completedValues, isNotNull);
  });

  // 9. onCancel fires
  testWidgets('Cancel button fires onCancel', (tester) async {
    var cancelled = false;

    await tester.pumpObers(_wizard(onCancel: () => cancelled = true));

    await tester.tap(find.text('Cancel'));
    await tester.pump();

    expect(cancelled, isTrue);
  });

  // 10. onStepChange fires
  testWidgets('onStepChange fires when step changes', (tester) async {
    int? newStep;

    await tester.pumpObers(
      _wizard(animated: false, onStepChange: (s) => newStep = s),
    );

    await tester.tap(find.text('Next'));
    await tester.pump();

    expect(newStep, 1);
  });

  // 11. Stepper labels show step titles
  testWidgets('stepper shows step titles as labels', (tester) async {
    await tester.pumpObers(_wizard());

    // Step titles are rendered in both the stepper labels and the step
    // header. "Step One" appears at least twice.
    expect(find.text('Step One'), findsWidgets);
    expect(find.text('Step Two'), findsWidgets);
    expect(find.text('Step Three'), findsWidgets);
  });

  // 12. Non-linear wizard allows jumping via stepper
  testWidgets('non-linear wizard allows jumping to any step', (tester) async {
    await tester.pumpObers(_wizard(linear: false, animated: false));

    // In non-linear mode the stepper has onStepTap on the circle.
    // Tap the step circle showing "3" (the third step).
    await tester.tap(find.text('3'));
    await tester.pump();

    expect(find.text('Content Three'), findsOneWidget);
  });

  // 13. Initial values are passed through
  testWidgets('initial values are available in wizard context', (tester) async {
    String? receivedName;

    await tester.pumpObers(
      _wizard(
        initialValues: {'name': 'Alice'},
        steps: [
          OiWizardStep(
            title: 'Only',
            builder: (ctx) {
              receivedName = ctx.values['name'] as String?;
              return const Text('Step');
            },
          ),
        ],
      ),
    );

    expect(receivedName, 'Alice');
  });

  // 14. setValue updates shared values
  testWidgets('setValue in wizard context updates values', (tester) async {
    late OiWizardContext capturedCtx;

    await tester.pumpObers(
      _wizard(
        animated: false,
        steps: [
          OiWizardStep(
            title: 'First',
            builder: (ctx) {
              capturedCtx = ctx;
              return const Text('S1');
            },
          ),
          OiWizardStep(
            title: 'Second',
            builder: (ctx) {
              return Text('Hello ${ctx.values['greeting'] ?? ''}');
            },
          ),
        ],
      ),
    );

    capturedCtx.setValue('greeting', 'World');
    capturedCtx.goNext();
    await tester.pump();

    expect(find.text('Hello World'), findsOneWidget);
  });

  // 15. Compact stepper style works
  testWidgets('compact stepper style shows step count text', (tester) async {
    await tester.pumpObers(_wizard(stepperStyle: OiStepperStyle.compact));

    expect(find.text('Step 1 of 3'), findsWidgets);
  });

  // 16. A shrinking step list must not strand the index past the end
  testWidgets('clamps the current step when the step list shrinks', (
    tester,
  ) async {
    await tester.pumpObers(_wizard());

    // Sit on the last step, then hand over a shorter list — as a caller does
    // when state elsewhere drops a step.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Content Three'), findsOneWidget);

    await tester.pumpObers(_wizard(steps: _steps().sublist(0, 2)));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Content Two'), findsOneWidget);
  });

  // 17. The clamp is a step change like any other
  testWidgets('onStepChange fires with the clamped index', (tester) async {
    final changes = <int>[];

    await tester.pumpObers(_wizard(onStepChange: changes.add));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    changes.clear();
    await tester.pumpObers(
      _wizard(steps: _steps().sublist(0, 2), onStepChange: changes.add),
    );
    await tester.pumpAndSettle();

    expect(changes, [1]);
  });

  // 18. A list that still covers the index leaves it alone
  testWidgets('keeps the current step when the list still reaches it', (
    tester,
  ) async {
    final changes = <int>[];

    await tester.pumpObers(_wizard(onStepChange: changes.add));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Content Two'), findsOneWidget);

    // Drops one step, but step 2 is still in range — nothing should move.
    changes.clear();
    await tester.pumpObers(
      _wizard(steps: _steps().sublist(0, 2), onStepChange: changes.add),
    );
    await tester.pumpAndSettle();

    expect(find.text('Content Two'), findsOneWidget);
    expect(changes, isEmpty);
  });

  // 19. An empty list renders nothing rather than throwing, and reports no
  // step change — there is no step to change to.
  testWidgets('renders nothing when the step list empties', (tester) async {
    final changes = <int>[];

    await tester.pumpObers(_wizard(onStepChange: changes.add));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    changes.clear();
    await tester.pumpObers(
      _wizard(steps: const [], onStepChange: changes.add),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Content One'), findsNothing);
    expect(changes, isEmpty);
  });

  // 20. Every nav label falls back to its English default when not overridden.
  testWidgets('nav labels default to the English literals', (tester) async {
    await tester.pumpObers(
      _wizard(onCancel: () {}, allowSkip: true, steps: _optionalSteps()),
    );

    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    // Previous and Complete only surface on later steps.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Previous'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Complete'), findsOneWidget);
  });

  // 21. Supplied overrides replace the defaults on every nav button.
  testWidgets('nav labels honour the supplied overrides', (tester) async {
    await tester.pumpObers(
      _wizard(
        steps: _optionalSteps(),
        onCancel: () {},
        allowSkip: true,
        labels: const OiWizardLabels(
          next: 'Weiter',
          previous: 'Zurück',
          skip: 'Überspringen',
          complete: 'Fertig',
          cancel: 'Abbrechen',
        ),
      ),
    );

    // Step 1: cancel, skip and next are visible; previous is not.
    expect(find.text('Abbrechen'), findsOneWidget);
    expect(find.text('Überspringen'), findsOneWidget);
    expect(find.text('Weiter'), findsOneWidget);
    expect(find.text('Next'), findsNothing);
    expect(find.text('Zurück'), findsNothing);

    // Step 2: previous appears.
    await tester.tap(find.text('Weiter'));
    await tester.pumpAndSettle();
    expect(find.text('Zurück'), findsOneWidget);
    expect(find.text('Previous'), findsNothing);

    // Step 3 (last): the primary button switches to the complete label.
    await tester.tap(find.text('Weiter'));
    await tester.pumpAndSettle();
    expect(find.text('Fertig'), findsOneWidget);
    expect(find.text('Complete'), findsNothing);
    expect(find.text('Weiter'), findsNothing);
  });

  // 22. Overridden labels still drive navigation, not just rendering.
  testWidgets('overridden labels still trigger navigation', (tester) async {
    var completed = false;

    await tester.pumpObers(
      _wizard(
        labels: const OiWizardLabels(
          next: 'Weiter',
          previous: 'Zurück',
          complete: 'Fertig',
        ),
        onComplete: (_) => completed = true,
      ),
    );

    await tester.tap(find.text('Weiter'));
    await tester.pumpAndSettle();
    expect(find.text('Content Two'), findsOneWidget);

    await tester.tap(find.text('Zurück'));
    await tester.pumpAndSettle();
    expect(find.text('Content One'), findsOneWidget);

    await tester.tap(find.text('Weiter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Weiter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fertig'));
    await tester.pumpAndSettle();

    expect(completed, isTrue);
  });

  // 23. The summary heading defaults to English and honours its override.
  testWidgets('summary heading honours its override', (tester) async {
    await tester.pumpObers(
      _wizard(
        initialValues: const {'name': 'Ada'},
        labels: const OiWizardLabels(summary: 'Übersicht'),
      ),
    );

    // Advance to the last step, where the summary renders.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Übersicht'), findsOneWidget);
    expect(find.text('Summary'), findsNothing);
  });

  // 24. Without an override the summary heading keeps the English default.
  testWidgets('summary heading defaults to English', (tester) async {
    await tester.pumpObers(_wizard(initialValues: const {'name': 'Ada'}));

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Summary'), findsOneWidget);
  });
}
