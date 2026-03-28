import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiProgressComponent = WidgetbookComponent(
  name: 'OiProgress',
  useCases: [
    WidgetbookUseCase(
      name: 'Linear',
      builder: (context) {
        final value = context.knobs.double.slider(
          label: 'Value',
          initialValue: 0.6,
          max: 1,
        );
        final indeterminate = context.knobs.boolean(label: 'Indeterminate');

        return useCaseWrapper(
          SizedBox(
            width: 300,
            child: OiProgress.linear(
              value: value,
              indeterminate: indeterminate,
              label: '${(value * 100).round()}%',
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Circular',
      builder: (context) {
        final value = context.knobs.double.slider(
          label: 'Value',
          initialValue: 0.6,
          max: 1,
        );
        final indeterminate = context.knobs.boolean(label: 'Indeterminate');

        return useCaseWrapper(
          OiProgress.circular(value: value, indeterminate: indeterminate),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Steps',
      builder: (context) {
        final steps = context.knobs.int.slider(
          label: 'Steps',
          initialValue: 5,
          min: 2,
          max: 10,
        );
        final currentStep = context.knobs.int.slider(
          label: 'Current Step',
          initialValue: 3,
          max: 10,
        );

        return useCaseWrapper(
          OiProgress.steps(steps: steps, currentStep: currentStep),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Bulk',
      builder: (context) {
        final current = context.knobs.int.slider(
          label: 'Current',
          initialValue: 5,
        );
        final total = context.knobs.int.slider(
          label: 'Total',
          initialValue: 18,
          min: 1,
        );
        final showPercentage = context.knobs.boolean(
          label: 'Show Percentage',
          initialValue: true,
        );

        return useCaseWrapper(
          SizedBox(
            width: 300,
            child: OiProgress.bulk(
              current: current,
              total: total,
              label: 'Generating specs',
              currentItemLabel: 'Authentication Screen',
              showPercentage: showPercentage,
            ),
          ),
        );
      },
    ),
  ],
);
