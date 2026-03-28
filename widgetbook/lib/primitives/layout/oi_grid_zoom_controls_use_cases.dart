import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiGridZoomControlsComponent = WidgetbookComponent(
  name: 'OiGridZoomControls',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final initialColumns = context.knobs.int.slider(
          label: 'Initial Columns',
          initialValue: 3,
          min: 1,
          max: 6,
        );
        final minColumns = context.knobs.int.slider(
          label: 'Min Columns',
          initialValue: 1,
          min: 1,
          max: 3,
        );
        final maxColumns = context.knobs.int.slider(
          label: 'Max Columns',
          initialValue: 6,
          min: 3,
          max: 12,
        );

        final colors = [
          const Color(0xFF3B82F6),
          const Color(0xFF8B5CF6),
          const Color(0xFFEC4899),
          const Color(0xFFF59E0B),
          const Color(0xFF22C55E),
          const Color(0xFF06B6D4),
          const Color(0xFFEF4444),
          const Color(0xFF6366F1),
          const Color(0xFF14B8A6),
        ];

        return useCaseWrapper(
          SizedBox(
            width: 500,
            height: 400,
            child: OiGridZoomControls(
              breakpoint: OiBreakpoint.large,
              initialColumns: initialColumns,
              minColumns: minColumns,
              maxColumns: maxColumns,
              gap: const OiResponsive<double>(12),
              children: [
                for (var i = 0; i < colors.length; i++)
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: colors[i],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: OiLabel.body(
                      'Item ${i + 1}',
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    ),
  ],
);
