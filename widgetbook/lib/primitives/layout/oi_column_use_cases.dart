import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiColumnComponent = WidgetbookComponent(
  name: 'OiColumn',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        final gap = context.knobs.double.slider(
          label: 'Gap',
          initialValue: 8,
          min: 0,
          max: 64,
        );
        final mainAxisAlignment = context.knobs.enumKnob(
          label: 'Main Axis Alignment',
          values: MainAxisAlignment.values,
          initialValue: MainAxisAlignment.start,
        );
        final crossAxisAlignment = context.knobs.enumKnob(
          label: 'Cross Axis Alignment',
          values: CrossAxisAlignment.values,
          initialValue: CrossAxisAlignment.center,
        );

        return useCaseWrapper(
          OiColumn(
            breakpoint: OiBreakpoint.expanded,
            gap: OiResponsive<double>(gap),
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            children: [
              Container(
                width: 120,
                height: 40,
                color: const Color(0xFFBBDEFB),
                child: const Center(child: Text('A')),
              ),
              Container(
                width: 80,
                height: 40,
                color: const Color(0xFFC8E6C9),
                child: const Center(child: Text('B')),
              ),
              Container(
                width: 100,
                height: 40,
                color: const Color(0xFFFFCDD2),
                child: const Center(child: Text('C')),
              ),
            ],
          ),
        );
      },
    ),
  ],
);
