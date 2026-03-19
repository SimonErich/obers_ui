import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiToastComponent = WidgetbookComponent(
  name: 'OiToast',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final message = context.knobs.string(
          label: 'Message',
          initialValue: 'Changes saved successfully.',
        );
        final level = context.knobs.enumKnob<OiToastLevel>(
          label: 'Level',
          values: OiToastLevel.values,
          initialValue: OiToastLevel.success,
        );
        final position = context.knobs.enumKnob<OiToastPosition>(
          label: 'Position',
          values: OiToastPosition.values,
          initialValue: OiToastPosition.bottomRight,
        );

        return useCaseWrapper(
          OiButton.primary(
            label: 'Show Toast',
            onTap: () {
              OiToast.show(
                context,
                message: message,
                level: level,
                position: position,
              );
            },
          ),
        );
      },
    ),
  ],
);
