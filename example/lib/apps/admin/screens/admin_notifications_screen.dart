import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/data/mock_dashboard.dart';

/// Notification center with mark-as-read, dismiss with undo, and grouping.
class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  late List<OiNotification> _notifications = List.of(kNotifications);
  final Set<Object> _dismissedKeys = {};

  OiNotification _withRead(OiNotification n, {required bool read}) {
    return OiNotification(
      key: n.key,
      title: n.title,
      body: n.body,
      timestamp: n.timestamp,
      icon: n.icon,
      category: n.category,
      read: read,
    );
  }

  void _onMarkRead(OiNotification n) {
    setState(() {
      _notifications = _notifications.map((existing) {
        if (existing.key == n.key) {
          return _withRead(existing, read: !existing.read);
        }
        return existing;
      }).toList();
    });
  }

  void _onMarkAllRead() {
    setState(() {
      _notifications = _notifications
          .map((n) => _withRead(n, read: true))
          .toList();
    });
  }

  void _onDismiss(OiNotification n) {
    final dismissedKey = n.key;
    final dismissedNotification = n;
    final dismissedIndex = _notifications.indexWhere(
      (item) => item.key == dismissedKey,
    );

    setState(() {
      _dismissedKeys.add(dismissedKey);
      _notifications = _notifications
          .where((item) => item.key != dismissedKey)
          .toList();
    });

    OiToast.show(
      context,
      message: 'Notification dismissed',
      action: OiButton.ghost(
        label: 'Undo',
        size: OiButtonSize.small,
        onTap: () {
          setState(() {
            _dismissedKeys.remove(dismissedKey);
            final insertIndex = dismissedIndex.clamp(0, _notifications.length);
            _notifications = List.of(_notifications)
              ..insert(insertIndex, dismissedNotification);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unread = _notifications.where((n) => !n.read).length;

    return OiNotificationCenter(
      label: 'Notifications',
      notifications: _notifications,
      unreadCount: unread,
      onMarkRead: _onMarkRead,
      onMarkAllRead: _onMarkAllRead,
      onDismiss: _onDismiss,
      groupBy: (n) => n.category ?? 'Other',
    );
  }
}
