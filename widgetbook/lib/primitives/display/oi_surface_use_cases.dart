import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiSurfaceComponent = WidgetbookComponent(
  name: 'OiSurface',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        final frosted = context.knobs.boolean(
          label: 'Frosted',
          initialValue: false,
        );
        final borderRadius = context.knobs.double.slider(
          label: 'Border Radius',
          initialValue: 8,
          min: 0,
          max: 32,
        );
        final hasBorder = context.knobs.boolean(
          label: 'Show Border',
          initialValue: true,
        );
        final hasShadow = context.knobs.boolean(
          label: 'Show Shadow',
          initialValue: false,
        );

        return useCaseWrapper(
          OiSurface(
            borderRadius: BorderRadius.circular(borderRadius),
            border: hasBorder
                ? OiBorderStyle.solid(
                    const Color(0xFFBDBDBD),
                    1,
                  )
                : null,
            shadow: hasShadow
                ? const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
            frosted: frosted,
            padding: const EdgeInsets.all(24),
            child: const SizedBox(
              width: 200,
              height: 100,
              child: Center(child: Text('OiSurface')),
            ),
          ),
        );
      },
    ),
  ],
);
