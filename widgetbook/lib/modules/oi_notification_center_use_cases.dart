import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final _sampleNotifications = [
  OiNotification(
    key: '1',
    title: 'New comment on your PR',
    body: 'Alice left a comment on "Fix navigation bug".',
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    icon: Icons.comment,
    category: 'Code Review',
  ),
  OiNotification(
    key: '2',
    title: 'Deployment succeeded',
    body: 'Production v2.4.1 was deployed successfully.',
    timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    icon: Icons.check_circle,
    read: true,
    category: 'Deployments',
  ),
  OiNotification(
    key: '3',
    title: 'You were mentioned in #general',
    timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    icon: Icons.alternate_email,
    category: 'Mentions',
  ),
  OiNotification(
    key: '4',
    title: 'Security alert',
    body: 'A new login was detected from an unknown device.',
    timestamp: DateTime.now().subtract(const Duration(hours: 6)),
    icon: Icons.security,
    category: 'Security',
  ),
  OiNotification(
    key: '5',
    title: 'Weekly report ready',
    body: 'Your team activity summary for this week is available.',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    icon: Icons.assessment,
    read: true,
    category: 'Reports',
  ),
];

final oiNotificationCenterComponent = WidgetbookComponent(
  name: 'OiNotificationCenter',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final showBadge = context.knobs.boolean(
          label: 'Show Badge',
          initialValue: true,
        );
        final unreadCount = context.knobs.int.slider(
          label: 'Unread Count',
          initialValue: 3,
        );

        return useCaseWrapper(
          SizedBox(
            height: 600,
            width: 400,
            child: OiNotificationCenter(
              notifications: _sampleNotifications,
              label: 'Notification center',
              showBadge: showBadge,
              unreadCount: unreadCount,
              onNotificationTap: (_) {},
              onMarkRead: (_) {},
              onMarkAllRead: () {},
              onDismiss: (_) {},
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
            child: OiNotificationCenter(
              notifications: [],
              label: 'Empty notification center',
            ),
          ),
        );
      },
    ),
  ],
);
