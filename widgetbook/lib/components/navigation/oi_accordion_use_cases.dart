import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiAccordionComponent = WidgetbookComponent(
  name: 'OiAccordion',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final allowMultiple = context.knobs.boolean(
          label: 'Allow Multiple',
          initialValue: false,
        );

        return useCaseWrapper(
          SizedBox(
            width: 400,
            child: OiAccordion(
              allowMultiple: allowMultiple,
              sections: const [
                OiAccordionSection(
                  title: 'Getting Started',
                  content: Text('Follow the setup guide to begin.'),
                ),
                OiAccordionSection(
                  title: 'Configuration',
                  content: Text('Adjust settings to match your needs.'),
                ),
                OiAccordionSection(
                  title: 'Troubleshooting',
                  content: Text('Check the FAQ for common issues.'),
                ),
              ],
            ),
          ),
        );
      },
    ),
  ],
);
