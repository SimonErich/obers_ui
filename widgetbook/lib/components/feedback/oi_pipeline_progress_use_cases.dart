import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiPipelineProgressComponent = WidgetbookComponent(
  name: 'OiPipelineProgress',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final currentStepIndex = context.knobs.int.slider(
          label: 'Current Step Index',
          initialValue: 1,
          max: 4,
        );
        final hasError = context.knobs.boolean(label: 'Has Error');
        final showCancel = context.knobs.boolean(
          label: 'Show Cancel',
          initialValue: true,
        );
        final showRetry = context.knobs.boolean(label: 'Show Retry');

        return useCaseWrapper(
          SizedBox(
            width: 350,
            child: OiPipelineProgress(
              label: 'Deployment pipeline',
              currentStepIndex: currentStepIndex,
              error: hasError ? 'Connection timed out after 30s' : null,
              onCancel: showCancel ? () {} : null,
              onRetry: hasError && showRetry ? () {} : null,
              steps: const [
                OiPipelineProgressStep(label: 'Install dependencies'),
                OiPipelineProgressStep(
                  label: 'Run tests',
                  detail: 'Running 148 test cases',
                ),
                OiPipelineProgressStep(
                  label: 'Build artifacts',
                  detail: 'Compiling release bundle',
                ),
                OiPipelineProgressStep(label: 'Deploy to staging'),
                OiPipelineProgressStep(label: 'Run smoke tests'),
              ],
            ),
          ),
        );
      },
    ),
  ],
);
