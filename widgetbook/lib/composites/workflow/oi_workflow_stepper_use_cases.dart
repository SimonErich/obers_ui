import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

const _phases = [
  OiWorkflowPhase(
    id: 'requirements',
    label: 'Requirements',
    icon: Icons.description,
    steps: [
      OiWorkflowStep(id: 'req-gather', label: 'Gather'),
      OiWorkflowStep(id: 'req-review', label: 'Review'),
      OiWorkflowStep(id: 'req-approve', label: 'Approve'),
    ],
  ),
  OiWorkflowPhase(
    id: 'design',
    label: 'Design',
    icon: Icons.brush,
    steps: [
      OiWorkflowStep(id: 'des-wireframe', label: 'Wireframe'),
      OiWorkflowStep(id: 'des-mockup', label: 'Mockup'),
      OiWorkflowStep(id: 'des-prototype', label: 'Prototype'),
    ],
  ),
  OiWorkflowPhase(
    id: 'develop',
    label: 'Develop',
    icon: Icons.code,
    steps: [
      OiWorkflowStep(id: 'dev-frontend', label: 'Frontend'),
      OiWorkflowStep(id: 'dev-backend', label: 'Backend'),
      OiWorkflowStep(id: 'dev-integrate', label: 'Integrate'),
    ],
  ),
  OiWorkflowPhase(
    id: 'release',
    label: 'Release',
    icon: Icons.rocket_launch,
    steps: [
      OiWorkflowStep(id: 'rel-qa', label: 'QA'),
      OiWorkflowStep(id: 'rel-staging', label: 'Staging'),
      OiWorkflowStep(id: 'rel-prod', label: 'Production'),
    ],
  ),
];

final oiWorkflowStepperComponent = WidgetbookComponent(
  name: 'OiWorkflowStepper',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final phaseIndex = context.knobs.int.slider(
          label: 'Active Phase Index',
          initialValue: 1,
          max: 3,
        );
        final stepIndex = context.knobs.int.slider(
          label: 'Active Step Index (within phase)',
          initialValue: 1,
          max: 2,
        );

        final currentPhase = _phases[phaseIndex];
        final currentStep = currentPhase.steps[stepIndex];

        // Build completed step IDs: all steps in prior phases + prior steps
        // in the current phase.
        final completedIds = <String>{};
        for (var p = 0; p < phaseIndex; p++) {
          for (final step in _phases[p].steps) {
            completedIds.add(step.id);
          }
        }
        for (var s = 0; s < stepIndex; s++) {
          completedIds.add(currentPhase.steps[s].id);
        }

        return useCaseWrapper(
          SizedBox(
            width: 600,
            child: OiWorkflowStepper(
              label: 'Product workflow',
              phases: _phases,
              currentPhaseId: currentPhase.id,
              currentStepId: currentStep.id,
              completedStepIds: completedIds,
              onStepTap: (phaseId, stepId) {},
            ),
          ),
        );
      },
    ),
  ],
);
