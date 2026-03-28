import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final _samplePages = [
  const OiOnboardingPage(
    title: 'Welcome to ObersUI',
    description:
        'A comprehensive Flutter UI library with 160+ widgets built from '
        'scratch. No Material or Cupertino dependencies.',
    illustration: Center(
      child: OiLabel.display('O', semanticsLabel: 'ObersUI logo'),
    ),
  ),
  const OiOnboardingPage(
    title: 'Beautiful Components',
    description:
        'From buttons and inputs to charts and dashboards, everything is '
        'theme-driven and fully accessible out of the box.',
    illustration: Center(
      child: OiLabel.display('*', semanticsLabel: 'Components illustration'),
    ),
  ),
  const OiOnboardingPage(
    title: 'Ready to Build',
    description:
        'Get started with a single import and build stunning apps with '
        'consistent, responsive design tokens.',
    illustration: Center(
      child: OiLabel.display('>', semanticsLabel: 'Ready illustration'),
    ),
    actionLabel: 'View Documentation',
  ),
];

/// Widgetbook component for [OiOnboardingFlow].
final oiOnboardingFlowComponent = WidgetbookComponent(
  name: 'OiOnboardingFlow',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final showSkip = context.knobs.boolean(
          label: 'Show Skip',
          initialValue: true,
        );
        final showPageIndicator = context.knobs.boolean(
          label: 'Show Page Indicator',
          initialValue: true,
        );
        final maxWidth = context.knobs.double.slider(
          label: 'Max Width',
          initialValue: 600,
          min: 300,
          max: 900,
        );

        return useCaseWrapper(
          SizedBox(
            width: 800,
            height: 600,
            child: OiOnboardingFlow(
              label: 'Onboarding demo',
              pages: _samplePages,
              showSkip: showSkip,
              showPageIndicator: showPageIndicator,
              maxWidth: maxWidth,
              onComplete: () {},
              onSkip: () {},
            ),
          ),
        );
      },
    ),
  ],
);
