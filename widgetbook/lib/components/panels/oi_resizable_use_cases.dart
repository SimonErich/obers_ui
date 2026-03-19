import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiResizableComponent = WidgetbookComponent(
  name: 'OiResizable',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final minWidth = context.knobs.double.slider(
          label: 'Min Width',
          initialValue: 100,
          min: 50,
          max: 300,
        );
        final maxWidth = context.knobs.double.slider(
          label: 'Max Width',
          initialValue: 500,
          min: 300,
          max: 800,
        );

        return useCaseWrapper(
          OiResizable(
            initialWidth: 250,
            initialHeight: 200,
            minWidth: minWidth,
            maxWidth: maxWidth,
            minHeight: 100,
            maxHeight: 400,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                border: Border.all(color: Colors.blue.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Text('Drag edges to resize')),
            ),
          ),
        );
      },
    ),
  ],
);
