import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

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
        final icon = context.knobs.iconKnob(label: 'Icon');

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
