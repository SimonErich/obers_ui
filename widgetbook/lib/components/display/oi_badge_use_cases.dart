import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiBadgeComponent = WidgetbookComponent(
  name: 'OiBadge',
  useCases: [
    WidgetbookUseCase(
      name: 'Filled',
      builder: (context) {
        final label = context.knobs.string(
          label: 'Label',
          initialValue: 'New',
        );
        final color = context.knobs.enumKnob<OiBadgeColor>(
          label: 'Color',
          values: OiBadgeColor.values,
        );
        final size = context.knobs.enumKnob<OiBadgeSize>(
          label: 'Size',
          values: OiBadgeSize.values,
          initialValue: OiBadgeSize.medium,
        );
        final showIcon = context.knobs.boolean(
          label: 'Show Icon',
          initialValue: false,
        );
        final dot = context.knobs.boolean(
          label: 'Dot',
          initialValue: false,
        );
        final icon = showIcon ? context.knobs.iconKnob() : null;

        return useCaseWrapper(
          OiBadge.filled(
            label: label,
            color: color,
            size: size,
            icon: icon,
            dot: dot,
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Soft',
      builder: (context) {
        final label = context.knobs.string(
          label: 'Label',
          initialValue: 'Draft',
        );
        final color = context.knobs.enumKnob<OiBadgeColor>(
          label: 'Color',
          values: OiBadgeColor.values,
          initialValue: OiBadgeColor.warning,
        );
        final size = context.knobs.enumKnob<OiBadgeSize>(
          label: 'Size',
          values: OiBadgeSize.values,
          initialValue: OiBadgeSize.medium,
        );

        return useCaseWrapper(
          OiBadge.soft(label: label, color: color, size: size),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Outline',
      builder: (context) {
        final label = context.knobs.string(
          label: 'Label',
          initialValue: 'v2.1',
        );
        final color = context.knobs.enumKnob<OiBadgeColor>(
          label: 'Color',
          values: OiBadgeColor.values,
        );
        final size = context.knobs.enumKnob<OiBadgeSize>(
          label: 'Size',
          values: OiBadgeSize.values,
          initialValue: OiBadgeSize.medium,
        );

        return useCaseWrapper(
          OiBadge.outline(label: label, color: color, size: size),
        );
      },
    ),
  ],
);
