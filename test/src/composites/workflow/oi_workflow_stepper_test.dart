// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/workflow/oi_workflow_stepper.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';

import '../../../helpers/pump_app.dart';

// ── Test data ───────────────────────────────────────────────────────────────

const _phases = [
  OiWorkflowPhase(
    id: 'design',
    label: 'Design',
    steps: [
      OiWorkflowStep(id: 'd1', label: 'Wireframes'),
      OiWorkflowStep(id: 'd2', label: 'Mockups'),
    ],
  ),
  OiWorkflowPhase(
    id: 'develop',
    label: 'Develop',
    steps: [
      OiWorkflowStep(id: 'dev1', label: 'Frontend'),
      OiWorkflowStep(id: 'dev2', label: 'Backend'),
      OiWorkflowStep(id: 'dev3', label: 'Integration'),
    ],
  ),
  OiWorkflowPhase(
    id: 'deploy',
    label: 'Deploy',
    steps: [
      OiWorkflowStep(id: 'dep1', label: 'Staging'),
      OiWorkflowStep(id: 'dep2', label: 'Production'),
    ],
  ),
];

// ── Helper ──────────────────────────────────────────────────────────────────

Widget _stepper({
  List<OiWorkflowPhase> phases = _phases,
  String currentPhaseId = 'develop',
  String currentStepId = 'dev1',
  String label = 'Test Workflow',
  void Function(String, String)? onStepTap,
  Set<String> completedStepIds = const {},
  Set<String> enabledStepIds = const {},
  Set<String> skippedStepIds = const {},
}) {
  return SizedBox(
    width: 800,
    height: 200,
    child: OiWorkflowStepper(
      phases: phases,
      currentPhaseId: currentPhaseId,
      currentStepId: currentStepId,
      label: label,
      onStepTap: onStepTap,
      completedStepIds: completedStepIds,
      enabledStepIds: enabledStepIds,
      skippedStepIds: skippedStepIds,
    ),
  );
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  // 1. Renders phase labels.
  testWidgets('renders phase labels', (tester) async {
    await tester.pumpObers(_stepper());
    expect(find.text('Design'), findsOneWidget);
    expect(find.text('Develop'), findsOneWidget);
    expect(find.text('Deploy'), findsOneWidget);
  });

  // 2. Renders step labels for current phase.
  testWidgets('renders step labels for current phase', (tester) async {
    await tester.pumpObers(_stepper());
    // Current phase is 'develop' with steps: Frontend, Backend, Integration.
    expect(find.text('Frontend'), findsOneWidget);
    expect(find.text('Backend'), findsOneWidget);
    expect(find.text('Integration'), findsOneWidget);
    // Steps from other phases should not appear.
    expect(find.text('Wireframes'), findsNothing);
    expect(find.text('Production'), findsNothing);
  });

  // 3. Skipped steps are not rendered.
  testWidgets('skipped steps are not rendered', (tester) async {
    await tester.pumpObers(_stepper(skippedStepIds: const {'dev2'}));
    expect(find.text('Frontend'), findsOneWidget);
    expect(find.text('Backend'), findsNothing);
    expect(find.text('Integration'), findsOneWidget);
  });

  // 4. Current phase is highlighted (has primary background via key).
  testWidgets('current phase is highlighted', (tester) async {
    await tester.pumpObers(_stepper());
    // The current phase pill should exist.
    final phasePill = find.byKey(const ValueKey('oi_wfs_phase_develop'));
    expect(phasePill, findsOneWidget);

    // Verify that the Container for the current phase has a primary-colored
    // decoration (non-null BoxDecoration with color set).
    final container = tester.widget<Container>(phasePill);
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, isNotNull);
  });

  // 5. Completed phase shows checkmark.
  testWidgets('completed phase shows checkmark', (tester) async {
    // Mark all steps of 'design' phase as completed.
    await tester.pumpObers(_stepper(completedStepIds: const {'d1', 'd2'}));
    // Checkmark icon should appear (at least one for the completed phase).
    expect(find.byIcon(OiIcons.check), findsWidgets);
  });

  // 6. Current step is highlighted.
  testWidgets('current step is highlighted', (tester) async {
    await tester.pumpObers(_stepper());
    final stepPill = find.byKey(const ValueKey('oi_wfs_step_dev1'));
    expect(stepPill, findsOneWidget);

    final container = tester.widget<Container>(stepPill);
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, isNotNull);
  });

  // 7. Tapping completed step fires onStepTap.
  testWidgets('tapping completed step fires onStepTap', (tester) async {
    String? tappedPhase;
    String? tappedStep;

    await tester.pumpObers(
      _stepper(
        completedStepIds: const {'dev2'},
        onStepTap: (phaseId, stepId) {
          tappedPhase = phaseId;
          tappedStep = stepId;
        },
      ),
    );

    // Tap the completed step 'Backend'.
    await tester.tap(find.text('Backend'));
    await tester.pump();

    expect(tappedPhase, 'develop');
    expect(tappedStep, 'dev2');
  });

  // 8. Disabled step is not tappable.
  testWidgets('disabled step is not tappable', (tester) async {
    String? tappedStep;

    await tester.pumpObers(
      _stepper(
        onStepTap: (_, stepId) => tappedStep = stepId,
        // dev2 is neither completed nor enabled, so it should be disabled.
      ),
    );

    // Tap the disabled step 'Backend'.
    await tester.tap(find.text('Backend'));
    await tester.pump();

    expect(tappedStep, isNull);
  });

  // 9. Has semantics label.
  testWidgets('has semantics label', (tester) async {
    await tester.pumpObers(_stepper(label: 'Checkout Workflow'));
    expect(
      find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Checkout Workflow',
      ),
      findsOneWidget,
    );
  });

  // 10. Renders without error with minimal config.
  testWidgets('renders without error with minimal config', (tester) async {
    const minimalPhases = [
      OiWorkflowPhase(
        id: 'p1',
        label: 'Phase 1',
        steps: [OiWorkflowStep(id: 's1', label: 'Step 1')],
      ),
    ];

    await tester.pumpObers(
      _stepper(
        phases: minimalPhases,
        currentPhaseId: 'p1',
        currentStepId: 's1',
      ),
    );

    expect(find.text('Phase 1'), findsOneWidget);
    expect(find.text('Step 1'), findsOneWidget);
  });
}
