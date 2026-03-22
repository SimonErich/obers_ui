import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/data/mock_dashboard.dart';

/// Notification center screen with unread badges.
class AdminNotificationsScreen extends StatelessWidget {
  const AdminNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final unread = kNotifications.where((n) => !n.read).length;

    return OiNotificationCenter(
      label: 'Notifications',
      notifications: kNotifications,
      unreadCount: unread,
    );
  }
}
