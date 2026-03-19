import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

const _sampleFilters = [
  OiFilterDefinition(key: 'status', label: 'Status', type: OiFilterType.text),
  OiFilterDefinition(
    key: 'priority',
    label: 'Priority',
    type: OiFilterType.text,
  ),
  OiFilterDefinition(key: 'date', label: 'Date', type: OiFilterType.text),
];

final oiFilterBarComponent = WidgetbookComponent(
  name: 'OiFilterBar',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            var activeFilters = <String, OiColumnFilter>{};
            return useCaseWrapper(
              OiFilterBar(
                filters: _sampleFilters,
                activeFilters: activeFilters,
                onFilterChange: (filters) {
                  setState(() => activeFilters = filters);
                },
              ),
            );
          },
        );
      },
    ),
  ],
);
