import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final _sampleVersions = [
  OiVersionEntry(
    version: '3.0.0',
    isLatest: true,
    date: DateTime(2026, 3, 20),
    summary: 'Major release with dark mode and new dashboard.',
    changes: const [
      OiChangeEntry(description: 'Dark mode support', type: OiChangeType.added),
      OiChangeEntry(
        description: 'New analytics dashboard',
        type: OiChangeType.added,
      ),
      OiChangeEntry(
        description: 'Redesigned settings page',
        type: OiChangeType.changed,
      ),
      OiChangeEntry(
        description: 'Fixed memory leak in chart renderer',
        type: OiChangeType.fixed,
      ),
      OiChangeEntry(
        description: 'XSS vulnerability in markdown preview',
        type: OiChangeType.security,
      ),
    ],
  ),
  OiVersionEntry(
    version: '2.5.1',
    date: DateTime(2026, 2, 15),
    changes: const [
      OiChangeEntry(
        description: 'Fixed crash when opening empty folders',
        type: OiChangeType.fixed,
      ),
      OiChangeEntry(
        description: 'Fixed timezone handling in scheduler',
        type: OiChangeType.fixed,
      ),
    ],
  ),
  OiVersionEntry(
    version: '2.5.0',
    date: DateTime(2026, 1, 28),
    summary: 'Calendar improvements and new file preview.',
    changes: const [
      OiChangeEntry(
        description: 'File preview panel with thumbnails',
        type: OiChangeType.added,
      ),
      OiChangeEntry(
        description: 'Calendar drag-and-drop rescheduling',
        type: OiChangeType.added,
      ),
      OiChangeEntry(
        description: 'Improved table sorting performance',
        type: OiChangeType.changed,
      ),
      OiChangeEntry(
        description: 'Deprecated OiLegacyGrid in favor of OiDataGrid',
        type: OiChangeType.deprecated,
      ),
    ],
  ),
  OiVersionEntry(
    version: '2.4.0',
    date: DateTime(2025, 12, 10),
    changes: const [
      OiChangeEntry(
        description: 'Kanban board swimlanes',
        type: OiChangeType.added,
      ),
      OiChangeEntry(
        description: 'Removed legacy export format',
        type: OiChangeType.removed,
      ),
      OiChangeEntry(
        description: 'Updated color token generation',
        type: OiChangeType.changed,
      ),
    ],
  ),
  OiVersionEntry(
    version: '2.3.0',
    date: DateTime(2025, 11, 5),
    changes: const [
      OiChangeEntry(
        description: 'Notification center module',
        type: OiChangeType.added,
      ),
      OiChangeEntry(
        description: 'Fixed sidebar collapse animation jank',
        type: OiChangeType.fixed,
      ),
      OiChangeEntry(
        description: 'Auth token refresh vulnerability patch',
        type: OiChangeType.security,
      ),
    ],
  ),
];

final oiChangelogViewComponent = WidgetbookComponent(
  name: 'OiChangelogView',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final showSearch = context.knobs.boolean(
          label: 'Show Search',
          initialValue: true,
        );
        final showTypeFilters = context.knobs.boolean(
          label: 'Show Type Filters',
          initialValue: true,
        );
        final expandedCount = context.knobs.double
            .slider(
              label: 'Initially Expanded Count',
              initialValue: 3,
              min: 1,
              max: 5,
            )
            .toInt();
        final maxWidth = context.knobs.double.slider(
          label: 'Max Width',
          initialValue: 720,
          min: 400,
          max: 1200,
        );

        return useCaseWrapper(
          SizedBox(
            width: 800,
            height: 700,
            child: OiChangelogView(
              versions: _sampleVersions,
              label: 'Changelog',
              showSearch: showSearch,
              showTypeFilters: showTypeFilters,
              initiallyExpandedCount: expandedCount,
              maxWidth: maxWidth,
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Rich Content',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            width: 800,
            height: 700,
            child: OiChangelogView(
              versions: _sampleVersions,
              label: 'Release Notes',
              initiallyExpandedCount: 5,
            ),
          ),
        );
      },
    ),
  ],
);
