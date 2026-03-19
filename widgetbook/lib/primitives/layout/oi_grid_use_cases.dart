import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiGridComponent = WidgetbookComponent(
  name: 'OiGrid',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        final columns = context.knobs.int.slider(
          label: 'Columns',
          initialValue: 3,
          min: 1,
          max: 6,
        );
        final gap = context.knobs.double.slider(
          label: 'Gap',
          initialValue: 8,
          min: 0,
          max: 32,
        );

        return useCaseWrapper(
          SizedBox(
            width: 400,
            child: OiGrid(
              breakpoint: OiBreakpoint.expanded,
              columns: OiResponsive<int>(columns),
              gap: OiResponsive<double>(gap),
              children: List.generate(
                9,
                (i) => Container(
                  height: 60,
                  color: Color(0xFF2196F3).withValues(
                    alpha: 0.3 + (i * 0.07),
                  ),
                  child: Center(child: Text('${i + 1}')),
                ),
              ),
            ),
          ),
        );
      },
    ),
  ],
);
