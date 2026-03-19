import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiSplitPaneComponent = WidgetbookComponent(
  name: 'OiSplitPane',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final direction = context.knobs.enumKnob<Axis>(
          label: 'Direction',
          values: Axis.values,
          initialValue: Axis.horizontal,
        );
        final initialRatio = context.knobs.double.slider(
          label: 'Initial Ratio',
          initialValue: 0.5,
          min: 0.1,
          max: 0.9,
        );

        return SizedBox(
          width: 500,
          height: 300,
          child: OiSplitPane(
            direction: direction,
            initialRatio: initialRatio,
            leading: Container(
              color: Colors.blue.withValues(alpha: 0.1),
              child: const Center(child: Text('Leading Pane')),
            ),
            trailing: Container(
              color: Colors.green.withValues(alpha: 0.1),
              child: const Center(child: Text('Trailing Pane')),
            ),
          ),
        );
      },
    ),
  ],
);
