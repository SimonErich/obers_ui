// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/forms/oi_wizard.dart';

import '../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

List<OiWizardStep> _steps({
  bool Function(Map<String, dynamic>)? step1Validate,
  bool Function(Map<String, dynamic>)? step2Validate,
}) => [
  OiWizardStep(
    title: 'Account',
    subtitle: 'Create your account',
    builder: (ctx) {
      // Simulate setting a value when the step is built.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ctx.values['account_visited'] != true) {
          ctx.setValue('account_visited', true);
        }
      });
      return const Text('Account Content');
    },
    validate: step1Validate,
  ),
  OiWizardStep(
    title: 'Profile',
    builder: (ctx) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ctx.values['profile_visited'] != true) {
          ctx.setValue('profile_visited', true);
        }
      });
      return const Text('Profile Content');
    },
    validate: step2Validate,
  ),
  OiWizardStep(
    title: 'Confirmation',
    builder: (ctx) => const Text('Confirmation Content'),
  ),
];

Widget _wizard({
  List<OiWizardStep>? steps,
  ValueChanged<Map<String, dynamic>>? onComplete,
  VoidCallback? onCancel,
  ValueChanged<int>? onStepChange,
  bool linear = true,
  bool showSummary = true,
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
        showSummary: showSummary,
        animated: false,
        initialValues: initialValues,
      ),
    ),
  );
}

// ── Integration tests ─────────────────────────────────────────────────────────

void main() {
  group('Wizard step navigation flow', () {
    testWidgets('navigate forward through all 3 steps', (tester) async {
      final stepsVisited = <int>[];

      await tester.pumpObers(
        _wizard(onStepChange: stepsVisited.add),
        surfaceSize: const Size(600, 800),
      );

      // Step 1 is displayed initially.
      expect(find.text('Account Content'), findsOneWidget);

      // Advance to step 2.
      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(find.text('Profile Content'), findsOneWidget);

      // Advance to step 3.
      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(find.text('Confirmation Content'), findsOneWidget);

      // Verify step change callbacks fired in order.
      expect(stepsVisited, [1, 2]);
    });

    testWidgets('navigate backward with Previous', (tester) async {
      await tester.pumpObers(_wizard(), surfaceSize: const Size(600, 800));

      // Go to step 2.
      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(find.text('Profile Content'), findsOneWidget);

      // Go back to step 1.
      await tester.tap(find.text('Previous'));
      await tester.pump();
      expect(find.text('Account Content'), findsOneWidget);
    });

    testWidgets('Previous is hidden on first step', (tester) async {
      await tester.pumpObers(_wizard(), surfaceSize: const Size(600, 800));

      expect(find.text('Previous'), findsNothing);
    });

    testWidgets('complete wizard fires onComplete with values', (tester) async {
      Map<String, dynamic>? completedValues;

      await tester.pumpObers(
        _wizard(
          onComplete: (v) => completedValues = v,
          initialValues: {'source': 'test'},
        ),
        surfaceSize: const Size(600, 800),
      );

      // Navigate through all steps.
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.tap(find.text('Next'));
      await tester.pump();

      // Last step shows "Complete" button.
      expect(find.text('Complete'), findsOneWidget);
      await tester.tap(find.text('Complete'));
      await tester.pump();

      expect(completedValues, isNotNull);
      // Initial values should be carried through.
      expect(completedValues!['source'], 'test');
    });

    testWidgets('validation blocks forward navigation', (tester) async {
      await tester.pumpObers(
        _wizard(steps: _steps(step1Validate: (_) => false)),
        surfaceSize: const Size(600, 800),
      );

      // Try to advance — validation fails.
      await tester.tap(find.text('Next'));
      await tester.pump();

      // Should still be on step 1.
      expect(find.text('Account Content'), findsOneWidget);
    });

    testWidgets('passing validation then advancing works', (tester) async {
      await tester.pumpObers(
        _wizard(steps: _steps(step1Validate: (_) => true)),
        surfaceSize: const Size(600, 800),
      );

      await tester.tap(find.text('Next'));
      await tester.pump();

      expect(find.text('Profile Content'), findsOneWidget);
    });

    testWidgets('full forward-backward-forward cycle', (tester) async {
      final stepsVisited = <int>[];

      await tester.pumpObers(
        _wizard(onStepChange: stepsVisited.add),
        surfaceSize: const Size(600, 800),
      );

      // Forward to step 2.
      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(find.text('Profile Content'), findsOneWidget);

      // Back to step 1.
      await tester.tap(find.text('Previous'));
      await tester.pump();
      expect(find.text('Account Content'), findsOneWidget);

      // Forward to step 2 again.
      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(find.text('Profile Content'), findsOneWidget);

      // Forward to step 3.
      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(find.text('Confirmation Content'), findsOneWidget);

      expect(stepsVisited, [1, 0, 1, 2]);
    });

    testWidgets('onCancel fires when cancel is pressed', (tester) async {
      var cancelled = false;

      await tester.pumpObers(
        _wizard(onCancel: () => cancelled = true),
        surfaceSize: const Size(600, 800),
      );

      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(cancelled, isTrue);
    });
  });
}
