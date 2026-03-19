import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiStepperComponent = WidgetbookComponent(
  name: 'OiStepper',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final style = context.knobs.enumKnob<OiStepperStyle>(
          label: 'Style',
          values: OiStepperStyle.values,
        );
        final totalSteps = context.knobs.int.slider(
          label: 'Total Steps',
          initialValue: 4,
          min: 2,
          max: 8,
        );
        final currentStep = context.knobs.int.slider(
          label: 'Current Step',
          initialValue: 1,
          min: 0,
          max: 7,
        );

        return useCaseWrapper(
          OiStepper(
            totalSteps: totalSteps,
            currentStep: currentStep.clamp(0, totalSteps - 1),
            style: style,
            stepLabels: List.generate(totalSteps, (i) => 'Step ${i + 1}'),
            completedSteps: {for (var i = 0; i < currentStep; i++) i},
          ),
        );
      },
    ),
  ],
);
