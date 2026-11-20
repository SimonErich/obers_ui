// Tests do not require documentation comments.

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

  Future<void> dragInSteps(WidgetTester tester, Offset step, int steps) async {
    final gesture = await tester.startGesture(const Offset(200, 300));
    for (var i = 0; i < steps; i++) {
      await gesture.moveBy(step);
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  group('OiActivityFeed load more', () {
    List<OiActivityEvent> events(int count) => [
      for (var i = 0; i < count; i++)
        OiActivityEvent(key: '$i', title: 'Event $i'),
    ];

    testWidgets('a first page shorter than the viewport loads the next one', (
      tester,
    ) async {
      var loads = 0;
      await tester.pumpObers(
        OiActivityFeed(
          events: events(2),
          label: 'Feed',
          moreAvailable: true,
          onLoadMore: () async => loads++,
        ),
        surfaceSize: const Size(400, 600),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 16));

      expect(loads, 1);
    });

    testWidgets('does not load while loading or when nothing more exists', (
      tester,
    ) async {
      var loads = 0;
      await tester.pumpObers(
        OiActivityFeed(
          events: events(2),
          label: 'Feed',
          moreAvailable: true,
          loading: true,
          onLoadMore: () async => loads++,
        ),
        surfaceSize: const Size(400, 600),
      );
      await tester.pump();
      await tester.pumpObers(
        OiActivityFeed(
          events: events(2),
          label: 'Feed',
          onLoadMore: () async => loads++,
        ),
      );
      await tester.pump();

      expect(loads, 0);
    });

    testWidgets('a load that ends without new events is not repeated', (
      tester,
    ) async {
      var loads = 0;
      Widget feed({required bool loading}) => OiActivityFeed(
        events: events(2),
        label: 'Feed',
        moreAvailable: true,
        loading: loading,
        onLoadMore: () async => loads++,
      );
      await tester.pumpObers(
        feed(loading: false),
        surfaceSize: const Size(400, 600),
      );
      await tester.pump();
      expect(loads, 1);

      // The fetch runs and fails: loading goes on and off, nothing arrives.
      await tester.pumpObers(feed(loading: true));
      await tester.pump();
      await tester.pumpObers(feed(loading: false));
      for (var frame = 0; frame < 5; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      expect(loads, 1);
    });

    testWidgets('loads again when the next page is still too short', (
      tester,
    ) async {
      var loads = 0;
      Widget feed(int count) => OiActivityFeed(
        events: events(count),
        label: 'Feed',
        moreAvailable: true,
        onLoadMore: () async => loads++,
      );
      await tester.pumpObers(feed(1), surfaceSize: const Size(400, 600));
      await tester.pump();
      expect(loads, 1);

      await tester.pumpObers(feed(2));
      await tester.pump();

      expect(loads, 2);
    });

    testWidgets('one arrival at the end loads once, not once per tick', (
      tester,
    ) async {
      var loads = 0;
      await tester.pumpObers(
        OiActivityFeed(
          events: events(60),
          label: 'Feed',
          moreAvailable: true,
          onLoadMore: () async => loads++,
        ),
        surfaceSize: const Size(400, 600),
      );
      await tester.pump();
      expect(loads, 0);

      // Small steps, so several scroll ticks land inside the 100 px zone.
      await dragInSteps(tester, const Offset(0, -20), 300);

      expect(loads, 1);
    });
  });
}
