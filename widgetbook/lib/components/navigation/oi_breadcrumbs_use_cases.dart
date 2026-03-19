import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiBreadcrumbsComponent = WidgetbookComponent(
  name: 'OiBreadcrumbs',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final separator = context.knobs.string(
          label: 'Separator',
          initialValue: '/',
        );
        final maxVisible = context.knobs.int.slider(
          label: 'Max Visible (0 = all)',
          initialValue: 0,
          min: 0,
          max: 5,
        );

        return useCaseWrapper(
          OiBreadcrumbs(
            separator: separator,
            maxVisible: maxVisible == 0 ? null : maxVisible,
            items: [
              OiBreadcrumbItem(label: 'Home', onTap: () {}),
              OiBreadcrumbItem(label: 'Documents', onTap: () {}),
              OiBreadcrumbItem(label: 'Projects', onTap: () {}),
              const OiBreadcrumbItem(label: 'Report.pdf'),
            ],
          ),
        );
      },
    ),
  ],
);
