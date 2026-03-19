import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiDividerComponent = WidgetbookComponent(
  name: 'OiDivider',
  useCases: [
    WidgetbookUseCase(
      name: 'Plain',
      builder: (context) {
        final axis = context.knobs.enumKnob(
          label: 'Axis',
          values: Axis.values,
          initialValue: Axis.horizontal,
        );
        final thickness = context.knobs.double.slider(
          label: 'Thickness',
          initialValue: 1,
          min: 0.5,
          max: 4,
        );
        final style = context.knobs.enumKnob(
          label: 'Style',
          values: OiBorderLineStyle.values,
          initialValue: OiBorderLineStyle.solid,
        );
        final spacing = context.knobs.double.slider(
          label: 'Spacing',
          initialValue: 0,
          min: 0,
          max: 32,
        );

        final divider = OiDivider(
          axis: axis,
          thickness: thickness,
          style: style,
          spacing: spacing,
        );

        return useCaseWrapper(
          axis == Axis.horizontal
              ? SizedBox(width: 300, child: divider)
              : SizedBox(height: 200, child: divider),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'With Label',
      builder: (context) {
        final label = context.knobs.string(
          label: 'Label',
          initialValue: 'OR',
        );

        return useCaseWrapper(
          SizedBox(
            width: 300,
            child: OiDivider.withLabel(label),
          ),
        );
      },
    ),
  ],
);
