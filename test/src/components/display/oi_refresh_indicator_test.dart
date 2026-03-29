// Tests do not require documentation comments.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_refresh_indicator.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiRefreshIndicator', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpObers(
        OiRefreshIndicator(
          onRefresh: () async {},
          child: ListView(
            children: const [Text('Item A'), Text('Item B')],
          ),
        ),
      );

      expect(find.text('Item A'), findsOneWidget);
      expect(find.text('Item B'), findsOneWidget);
    });

    testWidgets('wraps child in a NotificationListener', (tester) async {
      await tester.pumpObers(
        OiRefreshIndicator(
          onRefresh: () async {},
          child: ListView(
            children: const [Text('content')],
          ),
        ),
      );

      expect(
        find.byType(NotificationListener<ScrollNotification>),
        findsWidgets,
      );
    });

    testWidgets('calls onRefresh when overscrolled past trigger distance',
        (tester) async {
      var refreshed = false;
      await tester.pumpObers(
        OiRefreshIndicator(
          onRefresh: () async {
            refreshed = true;
          },
          child: ListView(
            physics: const ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            children: List.generate(
              50,
              (i) => SizedBox(height: 50, child: Text('Item $i')),
            ),
          ),
        ),
        surfaceSize: const Size(400, 600),
      );

      // Drag downward from top to simulate overscroll. The list is at
      // position 0 so downward dragging produces OverscrollNotification.
      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pumpAndSettle();

      expect(refreshed, isTrue);
    });

    testWidgets('does not double-trigger during refresh', (tester) async {
      var refreshCount = 0;
      final refreshCompleter = Completer<void>();

      await tester.pumpObers(
        OiRefreshIndicator(
          onRefresh: () {
            refreshCount++;
            return refreshCompleter.future;
          },
          child: ListView(
            physics: const ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            children: List.generate(
              50,
              (i) => SizedBox(height: 50, child: Text('Item $i')),
            ),
          ),
        ),
        surfaceSize: const Size(400, 600),
      );

      // First pull to trigger refresh.
      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      // Second pull while refresh is still in progress.
      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      // Complete the refresh.
      refreshCompleter.complete();
      await tester.pumpAndSettle();

      // onRefresh should only have been called once.
      expect(refreshCount, 1);
    });

    testWidgets('respects custom triggerDistance', (tester) async {
      var refreshed = false;
      await tester.pumpObers(
        OiRefreshIndicator(
          triggerDistance: 200,
          onRefresh: () async {
            refreshed = true;
          },
          child: ListView(
            physics: const ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            children: List.generate(
              50,
              (i) => SizedBox(height: 50, child: Text('Item $i')),
            ),
          ),
        ),
        surfaceSize: const Size(400, 600),
      );

      // A small drag should not trigger with a large triggerDistance.
      await tester.drag(find.byType(ListView), const Offset(0, 80));
      await tester.pumpAndSettle();

      expect(refreshed, isFalse);
    });

    testWidgets('default triggerDistance is 80', (tester) async {
      await tester.pumpObers(
        OiRefreshIndicator(
          onRefresh: () async {},
          child: ListView(children: const [Text('child')]),
        ),
      );

      final widget = tester.widget<OiRefreshIndicator>(
        find.byType(OiRefreshIndicator),
      );
      expect(widget.triggerDistance, 80.0);
    });

    testWidgets('default displacement is 40', (tester) async {
      await tester.pumpObers(
        OiRefreshIndicator(
          onRefresh: () async {},
          child: ListView(children: const [Text('child')]),
        ),
      );

      final widget = tester.widget<OiRefreshIndicator>(
        find.byType(OiRefreshIndicator),
      );
      expect(widget.displacement, 40.0);
    });
  });
}
