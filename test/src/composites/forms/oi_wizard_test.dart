// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/forms/oi_stepper.dart';
import 'package:obers_ui/src/composites/forms/oi_wizard.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

List<OiWizardStep> _steps({
  bool Function(Map<String, dynamic>)? step1Validate,
}) =>
    [
      OiWizardStep(
        title: 'Step One',
        subtitle: 'First step subtitle',
        builder: (ctx) => const Text('Content One'),
        validate: step1Validate,
      ),
      OiWizardStep(
        title: 'Step Two',
        builder: (ctx) => const Text('Content Two'),
      ),
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
      _wizard(
        animated: false,
        steps: _steps(step1Validate: (_) => false),
      ),
    );

    await tester.tap(find.text('Next'));
    await tester.pump();

    // Should still be on step one because validation failed.
    expect(find.text('Content One'), findsOneWidget);
  });

  // 7. Passing validation allows advancing
  testWidgets('passing validation allows advancing', (tester) async {
    await tester.pumpObers(
      _wizard(
        animated: false,
        steps: _steps(step1Validate: (_) => true),
      ),
    );

    await tester.tap(find.text('Next'));
    await tester.pump();

    expect(find.text('Content Two'), findsOneWidget);
  });

  // 8. onComplete fires when completing last step
  testWidgets('onComplete fires on the last step', (tester) async {
    Map<String, dynamic>? completedValues;

    await tester.pumpObers(
      _wizard(
        animated: false,
        onComplete: (v) => completedValues = v,
      ),
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

    await tester.pumpObers(
      _wizard(onCancel: () => cancelled = true),
    );

    await tester.tap(find.text('Cancel'));
    await tester.pump();

    expect(cancelled, isTrue);
  });

  // 10. onStepChange fires
  testWidgets('onStepChange fires when step changes', (tester) async {
    int? newStep;

    await tester.pumpObers(
      _wizard(
        animated: false,
        onStepChange: (s) => newStep = s,
      ),
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
    await tester.pumpObers(
      _wizard(linear: false, animated: false),
    );

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
    await tester.pumpObers(
      _wizard(stepperStyle: OiStepperStyle.compact),
    );

    expect(find.text('Step 1 of 3'), findsWidgets);
  });
}
