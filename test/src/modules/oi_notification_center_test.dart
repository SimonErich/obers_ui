// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/modules/oi_notification_center.dart';

import '../../helpers/pump_app.dart';

void main() {
  final now = DateTime.now();

  OiNotification notif({
    Object key = '1',
    String title = 'Test notification',
    String? body,
    bool read = false,
    String? category,
  }) {
    return OiNotification(
      key: key,
      title: title,
      body: body,
      timestamp: now,
      read: read,
      category: category,
    );
  }

  testWidgets('notifications render their titles', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 600,
        child: OiNotificationCenter(
          notifications: [notif(title: 'Build passed')],
          label: 'Notifications',
        ),
      ),
    );
    expect(find.text('Build passed'), findsOneWidget);
  });

  testWidgets('unread notification uses bold text', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 600,
        child: OiNotificationCenter(
          notifications: [notif(title: 'Unread')],
          label: 'Notifications',
        ),
      ),
    );

    final textWidget = tester.widget<Text>(find.text('Unread'));
    expect(textWidget.style?.fontWeight, FontWeight.w600);
  });

  testWidgets('read notification uses normal weight text', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 600,
        child: OiNotificationCenter(
          notifications: [notif(read: true, title: 'Read')],
          label: 'Notifications',
        ),
      ),
    );

    final textWidget = tester.widget<Text>(find.text('Read'));
    expect(textWidget.style?.fontWeight, FontWeight.w400);
  });

  testWidgets('onNotificationTap fires when tapped', (tester) async {
    OiNotification? tapped;
    final notification = notif(title: 'Tappable');

    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 600,
        child: OiNotificationCenter(
          notifications: [notification],
          label: 'Notifications',
          onNotificationTap: (n) => tapped = n,
        ),
      ),
    );

    await tester.tap(find.text('Tappable'));
    await tester.pump();

    expect(tapped, notification);
  });

  testWidgets('mark all read button shows and fires', (tester) async {
    var called = false;

    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 600,
        child: OiNotificationCenter(
          notifications: [notif()],
          label: 'Notifications',
          onMarkAllRead: () => called = true,
        ),
      ),
    );

    expect(find.text('Mark all read'), findsOneWidget);

    await tester.tap(find.text('Mark all read'));
    await tester.pump();

    expect(called, true);
  });

  testWidgets('empty state shows when no notifications', (tester) async {
    await tester.pumpObers(
      const SizedBox(
        width: 400,
        height: 600,
        child: OiNotificationCenter(notifications: [], label: 'Notifications'),
      ),
    );
    expect(find.text('No notifications'), findsOneWidget);
  });

  testWidgets('badge count shows when showBadge is true and unreadCount > 0', (
    tester,
  ) async {
    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 600,
        child: OiNotificationCenter(
          notifications: [notif()],
          label: 'Notifications',
          unreadCount: 5,
        ),
      ),
    );
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('badge count hidden when showBadge is false', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 600,
        child: OiNotificationCenter(
          notifications: [notif()],
          label: 'Notifications',
          unreadCount: 5,
          showBadge: false,
        ),
      ),
    );
    expect(find.text('5'), findsNothing);
  });

  testWidgets('has semantics label', (tester) async {
    await tester.pumpObers(
      const SizedBox(
        width: 400,
        height: 600,
        child: OiNotificationCenter(
          notifications: [],
          label: 'My Notifications',
        ),
      ),
    );
    expect(find.bySemanticsLabel('My Notifications'), findsOneWidget);
  });

  testWidgets('notification body renders when provided', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 600,
        child: OiNotificationCenter(
          notifications: [notif(title: 'Title', body: 'Detailed body text')],
          label: 'Notifications',
        ),
      ),
    );
    expect(find.text('Detailed body text'), findsOneWidget);
  });
}
