import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiTooltipComponent = WidgetbookComponent(
  name: 'OiTooltip',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final message = context.knobs.string(
          label: 'Message',
          initialValue: 'This is a tooltip',
        );

        return useCaseWrapper(
          OiTooltip(
            label: 'Tooltip',
            message: message,
            child: OiButton.primary(
              label: 'Hover me',
              onTap: () {},
            ),
          ),
        );
      },
    ),
  ],
);
