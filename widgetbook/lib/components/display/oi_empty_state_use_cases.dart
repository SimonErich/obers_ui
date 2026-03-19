import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiEmptyStateComponent = WidgetbookComponent(
  name: 'OiEmptyState',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final title = context.knobs.string(
          label: 'Title',
          initialValue: 'No items found',
        );
        final description = context.knobs.string(
          label: 'Description',
          initialValue: 'Try adjusting your search or filter criteria.',
        );
        final icon = context.knobs.iconKnob();

        return useCaseWrapper(
          SizedBox(
            width: 400,
            child: OiEmptyState(
              title: title,
              description: description,
              icon: icon,
            ),
          ),
        );
      },
    ),
  ],
);
