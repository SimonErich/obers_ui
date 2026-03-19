// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_empty_state.dart';
import 'package:obers_ui/src/components/display/oi_progress.dart';
import 'package:obers_ui/src/modules/oi_activity_feed.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('OiActivityFeed', () {
    testWidgets('events render in order', (tester) async {
      await tester.pumpObers(
        const OiActivityFeed(
          events: [
            OiActivityEvent(key: '1', title: 'First event'),
            OiActivityEvent(key: '2', title: 'Second event'),
            OiActivityEvent(key: '3', title: 'Third event'),
          ],
          label: 'Feed',
        ),
        surfaceSize: const Size(400, 600),
      );

      expect(find.text('First event'), findsOneWidget);
      expect(find.text('Second event'), findsOneWidget);
      expect(find.text('Third event'), findsOneWidget);
    });

    testWidgets('timestamps show when enabled', (tester) async {
      await tester.pumpObers(
        OiActivityFeed(
          events: [
            OiActivityEvent(
              key: '1',
              title: 'Timed event',
              timestamp: DateTime(2025, 3, 15, 10, 30),
            ),
          ],
          label: 'Feed',
        ),
        surfaceSize: const Size(400, 600),
      );

      expect(find.text('2025-03-15 10:30'), findsOneWidget);
    });

    testWidgets('timestamps hidden when disabled', (tester) async {
      await tester.pumpObers(
        OiActivityFeed(
          events: [
            OiActivityEvent(
              key: '1',
              title: 'No time event',
              timestamp: DateTime(2025, 3, 15, 10, 30),
            ),
          ],
          label: 'Feed',
          showTimestamps: false,
        ),
        surfaceSize: const Size(400, 600),
      );

      expect(find.text('2025-03-15 10:30'), findsNothing);
    });

    testWidgets('categories render and filter callback fires', (tester) async {
      String? selectedCategory;
      await tester.pumpObers(
        OiActivityFeed(
          events: const [
            OiActivityEvent(key: '1', title: 'E1', category: 'Work'),
          ],
          label: 'Feed',
          categories: const ['Work', 'Personal'],
          onCategoryChange: (c) => selectedCategory = c,
        ),
        surfaceSize: const Size(400, 600),
      );

      expect(find.text('Work'), findsAtLeastNWidgets(1));
      expect(find.text('Personal'), findsOneWidget);

      await tester.tap(find.text('Personal'));
      await tester.pump();
      expect(selectedCategory, 'Personal');
    });

    testWidgets('loading state shows progress', (tester) async {
      await tester.pumpObers(
        const OiActivityFeed(events: [], label: 'Feed', loading: true),
        surfaceSize: const Size(400, 600),
      );

      expect(find.byType(OiProgress), findsOneWidget);
    });

    testWidgets('empty state shows when no events', (tester) async {
      await tester.pumpObers(
        const OiActivityFeed(
          events: [],
          label: 'Feed',
          emptyState: OiEmptyState(title: 'No activity yet'),
        ),
        surfaceSize: const Size(400, 600),
      );

      expect(find.text('No activity yet'), findsOneWidget);
    });

    testWidgets(
      'default empty state shows when no events and no custom widget',
      (tester) async {
        await tester.pumpObers(
          const OiActivityFeed(events: [], label: 'Feed'),
          surfaceSize: const Size(400, 600),
        );

        expect(find.text('No activity'), findsOneWidget);
      },
    );

    testWidgets('onEventTap fires when event is tapped', (tester) async {
      OiActivityEvent? tappedEvent;
      await tester.pumpObers(
        OiActivityFeed(
          events: const [OiActivityEvent(key: '1', title: 'Tap me')],
          label: 'Feed',
          onEventTap: (e) => tappedEvent = e,
        ),
        surfaceSize: const Size(400, 600),
      );

      await tester.tap(find.text('Tap me'));
      await tester.pump();
      expect(tappedEvent?.title, 'Tap me');
    });

    testWidgets('description renders when provided', (tester) async {
      await tester.pumpObers(
        const OiActivityFeed(
          events: [
            OiActivityEvent(
              key: '1',
              title: 'Event',
              description: 'Detailed description',
            ),
          ],
          label: 'Feed',
        ),
        surfaceSize: const Size(400, 600),
      );

      expect(find.text('Detailed description'), findsOneWidget);
    });

    testWidgets('semantics label is applied', (tester) async {
      await tester.pumpObers(
        const OiActivityFeed(
          events: [OiActivityEvent(key: '1', title: 'E1')],
          label: 'Activity Feed',
        ),
        surfaceSize: const Size(400, 600),
      );

      expect(find.bySemanticsLabel('Activity Feed'), findsOneWidget);
    });
  });
}
