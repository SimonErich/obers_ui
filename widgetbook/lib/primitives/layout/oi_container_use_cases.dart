import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiContainerComponent = WidgetbookComponent(
  name: 'OiContainer',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        final maxWidth = context.knobs.double.slider(
          label: 'Max Width',
          initialValue: 600,
          min: 100,
          max: 1200,
        );
        final centered = context.knobs.boolean(
          label: 'Centered',
          initialValue: true,
        );
        final padding = context.knobs.double.slider(
          label: 'Padding',
          initialValue: 16,
          min: 0,
          max: 64,
        );

        return useCaseWrapper(
          OiContainer(
            breakpoint: OiBreakpoint.expanded,
            maxWidth: OiResponsive<double>(maxWidth),
            padding: OiResponsive<EdgeInsetsGeometry>(
              EdgeInsets.all(padding),
            ),
            centered: centered,
            child: Container(
              height: 100,
              color: const Color(0xFFBBDEFB),
              child: const Center(
                child: Text('OiContainer content'),
              ),
            ),
          ),
        );
      },
    ),
  ],
);
