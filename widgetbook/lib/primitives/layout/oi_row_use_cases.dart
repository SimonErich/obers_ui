import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiRowComponent = WidgetbookComponent(
  name: 'OiRow',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        final gap = context.knobs.double.slider(
          label: 'Gap',
          initialValue: 8,
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
          OiRow(
            breakpoint: OiBreakpoint.expanded,
            gap: OiResponsive<double>(gap),
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            children: [
              Container(
                width: 60,
                height: 40,
                color: const Color(0xFFBBDEFB),
                child: const Center(child: Text('A')),
              ),
              Container(
                width: 60,
                height: 60,
                color: const Color(0xFFC8E6C9),
                child: const Center(child: Text('B')),
              ),
              Container(
                width: 60,
                height: 50,
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
