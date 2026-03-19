import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiSkeletonGroupComponent = WidgetbookComponent(
  name: 'OiSkeletonGroup',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final active = context.knobs.boolean(
          label: 'Active',
          initialValue: true,
        );

        return useCaseWrapper(
          SizedBox(
            width: 300,
            child: OiSkeletonGroup(
              active: active,
              children: const [
                OiSkeletonBox(width: 48, height: 48),
                SizedBox(height: 12),
                OiSkeletonLine(width: 200),
                SizedBox(height: 8),
                OiSkeletonLine(width: 140),
                SizedBox(height: 8),
                OiSkeletonLine(),
              ],
            ),
          ),
        );
      },
    ),
  ],
);
