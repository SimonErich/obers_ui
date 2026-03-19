import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final _sampleSteps = [
  OiWizardStep(
    title: 'Account',
    subtitle: 'Create your account',
    builder: (ctx) => const Text('Enter your email and password here.'),
  ),
  OiWizardStep(
    title: 'Profile',
    subtitle: 'Set up your profile',
    builder: (ctx) => const Text('Enter your name and avatar.'),
  ),
  OiWizardStep(
    title: 'Confirm',
    subtitle: 'Review your details',
    builder: (ctx) => const Text('Review and confirm your information.'),
  ),
];

final oiWizardComponent = WidgetbookComponent(
  name: 'OiWizard',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            width: 500,
            child: OiWizard(
              steps: _sampleSteps,
              onComplete: (values) {},
              onCancel: () {},
            ),
          ),
        );
      },
    ),
  ],
);
