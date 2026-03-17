import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A notification item displayed in the [OiNotificationCenter].
///
/// Represents a single notification with title, optional body, timestamp,
/// and read state.
class OiNotification {
  /// Creates an [OiNotification].
  const OiNotification({
    required this.key,
    required this.title,
    this.body,
    required this.timestamp,
    this.read = false,
    this.icon,
    this.leading,
    this.category,
    this.onAction,
  });

  /// Unique identifier for this notification.
  final Object key;

  /// The notification title.
  final String title;

  /// Optional body text with additional detail.
  final String? body;

  /// When the notification was created.
  final DateTime timestamp;

  /// Whether this notification has been read.
  final bool read;

  /// Optional icon for the notification.
  final IconData? icon;

  /// Optional leading widget (e.g. an avatar).
  final Widget? leading;

  /// Optional category for grouping.
  final String? category;

  /// Optional callback when the notification action is triggered.
  final VoidCallback? onAction;
}

/// A notification panel listing notifications with mark-as-read and dismiss.
///
/// Renders a scrollable list of [OiNotification] items with visual
/// distinction between read and unread entries. Supports tapping, dismissing,
/// snoozing, and marking all notifications as read.
///
/// {@category Modules}
class OiNotificationCenter extends StatelessWidget {
  /// Creates an [OiNotificationCenter].
  const OiNotificationCenter({
    super.key,
    required this.notifications,
    required this.label,
    this.onNotificationTap,
    this.onMarkRead,
    this.onMarkAllRead,
    this.onSnooze,
    this.onDismiss,
    this.groupBy,
    this.unreadCount = 0,
    this.showBadge = true,
    this.realTime = false,
  });

  /// The list of notifications to display.
  final List<OiNotification> notifications;

  /// Accessibility label for the notification center.
  final String label;

  /// Called when a notification is tapped.
  final ValueChanged<OiNotification>? onNotificationTap;

  /// Called when a single notification is marked as read.
  final ValueChanged<OiNotification>? onMarkRead;

  /// Called when the user marks all notifications as read.
  final VoidCallback? onMarkAllRead;

  /// Called when a notification is snoozed.
  final ValueChanged<OiNotification>? onSnooze;

  /// Called when a notification is dismissed.
  final ValueChanged<OiNotification>? onDismiss;

  /// Optional grouping function that returns a category string.
  final String Function(OiNotification)? groupBy;

  /// The number of unread notifications shown in the badge.
  final int unreadCount;

  /// Whether to show the unread count badge.
  final bool showBadge;

  /// Whether the notification center updates in real time.
  final bool realTime;

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(spacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'Notifications',
                        style: TextStyle(
                          color: colors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (showBadge && unreadCount > 0) ...[
                        SizedBox(width: spacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.error.base,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            '$unreadCount',
                            style: TextStyle(
                              color: colors.textOnPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onMarkAllRead != null)
                  GestureDetector(
                    onTap: onMarkAllRead,
                    child: Semantics(
                      label: 'Mark all as read',
                      button: true,
                      child: Text(
                        'Mark all read',
                        style: TextStyle(
                          color: colors.primary.base,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // List
          Expanded(
            child: notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          const IconData(0xe7f5,
                              fontFamily: 'MaterialIcons'),
                          size: 48,
                          color: colors.textMuted,
                        ),
                        SizedBox(height: spacing.sm),
                        Text(
                          'No notifications',
                          style: TextStyle(color: colors.textMuted),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: notifications.length,
                    itemBuilder: (context, index) =>
                        _buildNotificationTile(context, notifications[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(
      BuildContext context, OiNotification notification) {
    final colors = context.colors;
    final spacing = context.spacing;

    return GestureDetector(
      onTap: () => onNotificationTap?.call(notification),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.sm,
        ),
        decoration: BoxDecoration(
          color: notification.read ? null : colors.primary.muted.withValues(alpha: 0.08),
          border: Border(
            bottom: BorderSide(color: colors.borderSubtle),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notification.leading != null)
              Padding(
                padding: EdgeInsets.only(right: spacing.sm),
                child: notification.leading!,
              )
            else if (notification.icon != null)
              Padding(
                padding: EdgeInsets.only(right: spacing.sm),
                child: Icon(
                  notification.icon!,
                  size: 24,
                  color: colors.textSubtle,
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 14,
                      fontWeight:
                          notification.read ? FontWeight.w400 : FontWeight.w600,
                    ),
                  ),
                  if (notification.body != null)
                    Padding(
                      padding: EdgeInsets.only(top: spacing.xs),
                      child: Text(
                        notification.body!,
                        style: TextStyle(
                          color: colors.textSubtle,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(top: spacing.xs),
                    child: Text(
                      _formatTimestamp(notification.timestamp),
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.read)
              Padding(
                padding: EdgeInsets.only(left: spacing.sm),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colors.primary.base,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
