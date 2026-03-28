import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

final oiThreeColumnLayoutComponent = WidgetbookComponent(
  name: 'OiThreeColumnLayout',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final showRightColumn = context.knobs.boolean(
          label: 'Show Right Column',
          initialValue: true,
        );
        final resizable = context.knobs.boolean(
          label: 'Resizable',
          initialValue: true,
        );

        return SizedBox(
          width: 900,
          height: 500,
          child: OiThreeColumnLayout(
            label: 'Three column layout',
            resizable: resizable,
            showRightColumn: showRightColumn,
            leftColumn: const ColoredBox(
              color: Color(0xFF1E293B),
              child: Center(
                child: OiLabel.body('Navigation', color: Color(0xFFE2E8F0)),
              ),
            ),
            middleColumn: const ColoredBox(
              color: Color(0xFF0F172A),
              child: Center(
                child: OiLabel.body('Main Content', color: Color(0xFFE2E8F0)),
              ),
            ),
            rightColumn: const ColoredBox(
              color: Color(0xFF1E293B),
              child: Center(
                child: OiLabel.body('Detail Panel', color: Color(0xFFE2E8F0)),
              ),
            ),
          ),
        );
      },
    ),
  ],
);
