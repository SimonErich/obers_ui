import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final _sampleEvents = [
  OiActivityEvent(
    key: '1',
    title: 'Deployment completed',
    description: 'Production v2.4.1 deployed successfully.',
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    icon: Icons.check_circle,
    category: 'Deployment',
  ),
  OiActivityEvent(
    key: '2',
    title: 'New user registered',
    description: 'jane.doe@example.com joined the workspace.',
    timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    icon: Icons.person_add,
    category: 'Users',
  ),
  OiActivityEvent(
    key: '3',
    title: 'Database backup finished',
    timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    icon: Icons.storage,
    category: 'System',
  ),
  OiActivityEvent(
    key: '4',
    title: 'File uploaded',
    description: 'report-q4.pdf was uploaded to /documents.',
    timestamp: DateTime.now().subtract(const Duration(hours: 6)),
    icon: Icons.upload_file,
    category: 'Files',
  ),
  OiActivityEvent(
    key: '5',
    title: 'Settings changed',
    description: 'Notification preferences updated by admin.',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    icon: Icons.settings,
    category: 'System',
  ),
];

const _categories = ['All', 'Deployment', 'Users', 'System', 'Files'];

final oiActivityFeedComponent = WidgetbookComponent(
  name: 'OiActivityFeed',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final showTimestamps = context.knobs.boolean(
          label: 'Show Timestamps',
          initialValue: true,
        );
        final showCategories = context.knobs.boolean(
          label: 'Show Categories',
          initialValue: true,
        );
        final loading = context.knobs.boolean(label: 'Loading');
        final moreAvailable = context.knobs.boolean(label: 'More Available');

        return useCaseWrapper(
          SizedBox(
            height: 600,
            width: 400,
            child: OiActivityFeed(
              events: loading ? [] : _sampleEvents,
              label: 'Activity feed',
              showTimestamps: showTimestamps,
              categories: showCategories ? _categories : null,
              activeCategory: showCategories ? 'All' : null,
              onCategoryChange: (_) {},
              onEventTap: (_) {},
              loading: loading,
              moreAvailable: moreAvailable,
              onLoadMore: moreAvailable ? () async {} : null,
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Empty State',
      builder: (context) {
        return useCaseWrapper(
          const SizedBox(
            height: 400,
            width: 400,
            child: OiActivityFeed(events: [], label: 'Empty activity feed'),
          ),
        );
      },
    ),
  ],
);
