// Tests do not require documentation comments.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/primitives/scroll/oi_infinite_scroll.dart';

import '../../../helpers/pump_app.dart';

/// Builds a scrollable list with [itemCount] items, each 60 px tall, inside
/// a 400×300 viewport, wrapped by [OiInfiniteScroll].
Widget _buildScroll({
  required int itemCount,
  required bool moreAvailable,
  required Future<void> Function() onLoadMore,
  Widget? loadingWidget,
  double threshold = 200,
}) {
  final controller = ScrollController();
  return OiInfiniteScroll(
    moreAvailable: moreAvailable,
    onLoadMore: onLoadMore,
    loadingWidget: loadingWidget,
    threshold: threshold,
    child: ListView.builder(
      controller: controller,
      itemCount: itemCount,
      itemBuilder: (_, i) => SizedBox(height: 60, child: Text('item $i')),
    ),
  );
}

void main() {
  // ── 1. onLoadMore called when scrolled near bottom ─────────────────────────

  testWidgets('onLoadMore triggered when scrolled within threshold of bottom', (
    tester,
  ) async {
    var loadMoreCalled = false;
    final completer = Completer<void>();

    await tester.pumpObers(
      _buildScroll(
        itemCount: 20,
        moreAvailable: true,
        onLoadMore: () {
          loadMoreCalled = true;
          return completer.future;
        },
      ),
      surfaceSize: const Size(400, 300),
    );

    // Scroll to near the bottom — 20 items × 60px = 1200px content,
    // viewport 300px, so maxScrollExtent ≈ 900. Scroll past (900 - 200).
    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pump();

    expect(loadMoreCalled, isTrue);

    completer.complete();
    await tester.pump();
  });

  // ── 2. hasMore=false: onLoadMore not called ────────────────────────────────

  testWidgets('hasMore=false: onLoadMore is never called on scroll', (
    tester,
  ) async {
    var loadMoreCalled = false;

    await tester.pumpObers(
      _buildScroll(
        itemCount: 20,
        moreAvailable: false,
        onLoadMore: () async => loadMoreCalled = true,
      ),
      surfaceSize: const Size(400, 300),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pump();

    expect(loadMoreCalled, isFalse);
  });

  // ── 3. loadingWidget shown while loading ──────────────────────────────────

  testWidgets('loadingWidget is visible while onLoadMore is in progress', (
    tester,
  ) async {
    final completer = Completer<void>();

    await tester.pumpObers(
      _buildScroll(
        itemCount: 20,
        moreAvailable: true,
        loadingWidget: const Text('loading...', key: ValueKey('loader')),
        onLoadMore: () => completer.future,
      ),
      surfaceSize: const Size(400, 300),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pump();

    // Loading widget should be present while completer hasn't resolved.
    expect(find.text('loading...'), findsOneWidget);

    completer.complete();
    await tester.pump();

    // Loading widget gone after completion.
    expect(find.text('loading...'), findsNothing);
  });

  // ── 4. threshold configurable ─────────────────────────────────────────────

  testWidgets('high threshold triggers load earlier in scroll', (tester) async {
    var loadMoreCalled = false;
    final completer = Completer<void>();

    // threshold=900 means load fires almost immediately (maxScrollExtent ≈ 900).
    await tester.pumpObers(
      _buildScroll(
        itemCount: 20,
        moreAvailable: true,
        threshold: 900,
        onLoadMore: () {
          loadMoreCalled = true;
          return completer.future;
        },
      ),
      surfaceSize: const Size(400, 300),
    );

    // Scroll only a small amount — threshold is so large it fires immediately.
    await tester.drag(find.byType(ListView), const Offset(0, -10));
    await tester.pump();

    expect(loadMoreCalled, isTrue);

    completer.complete();
    await tester.pump();
  });

  // ── 5. child is rendered ──────────────────────────────────────────────────

  testWidgets('child widget is rendered inside OiInfiniteScroll', (
    tester,
  ) async {
    await tester.pumpObers(
      OiInfiniteScroll(
        moreAvailable: false,
        onLoadMore: () async {},
        child: const Text('content'),
      ),
    );
    expect(find.text('content'), findsOneWidget);
  });

  // ── 6. default loadingWidget (spinner) shows when no custom widget given ──

  testWidgets('default spinner shown when loadingWidget is null', (
    tester,
  ) async {
    final completer = Completer<void>();

    await tester.pumpObers(
      _buildScroll(
        itemCount: 20,
        moreAvailable: true,
        onLoadMore: () => completer.future,
      ),
      surfaceSize: const Size(400, 300),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pump();

    // The default spinner key should be present.
    expect(
      find.byKey(const ValueKey('oi_infinite_scroll_spinner')),
      findsOneWidget,
    );

    completer.complete();
    await tester.pump();
  });

  // ── 7. Reduced motion: spinner stops animating ──────────────────────────

  testWidgets('reducedMotion: spinner animation controller stops', (
    tester,
  ) async {
    final completer = Completer<void>();

    await tester.pumpObers(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: _buildScroll(
          itemCount: 20,
          moreAvailable: true,
          onLoadMore: () => completer.future,
        ),
      ),
      surfaceSize: const Size(400, 300),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pump();

    // Spinner is present but its RotationTransition controller is stopped.
    expect(
      find.byKey(const ValueKey('oi_infinite_scroll_spinner')),
      findsOneWidget,
    );

    final rotation = tester.widget<RotationTransition>(
      find.byType(RotationTransition),
    );
    final ctrl = rotation.turns;
    if (ctrl is AnimationController) {
      expect(ctrl.isAnimating, isFalse);
    }

    completer.complete();
    await tester.pump();
  });

  // ── Short first page, nested scrollables, one load per arrival ────────────

  testWidgets('a first page shorter than the viewport loads without a scroll', (
    tester,
  ) async {
    var items = 2;
    var loads = 0;
    late StateSetter rebuild;

    await tester.pumpObers(
      StatefulBuilder(
        builder: (context, setState) {
          rebuild = setState;
          return OiInfiniteScroll(
            moreAvailable: items < 8,
            onLoadMore: () async {
              loads++;
              rebuild(() => items += 2);
            },
            child: ListView.builder(
              itemCount: items,
              itemBuilder: (_, i) => SizedBox(height: 60, child: Text('s$i')),
            ),
          );
        },
      ),
      surfaceSize: const Size(400, 300),
    );
    await tester.pumpAndSettle();

    // 2 → 4 → 6 → 8 items (480 px > 300 px viewport); then moreAvailable is
    // false.
    expect(loads, 3);
    expect(items, 8);
  });

  testWidgets('a load that changes nothing is not repeated in a loop', (
    tester,
  ) async {
    var loads = 0;
    await tester.pumpObers(
      _buildScroll(
        itemCount: 2,
        moreAvailable: true,
        onLoadMore: () async => loads++,
      ),
      surfaceSize: const Size(400, 300),
    );
    await tester.pumpAndSettle();
    for (var frame = 0; frame < 5; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    expect(loads, 1);
  });

  testWidgets('dragging a nested horizontal list does not load', (
    tester,
  ) async {
    var loads = 0;
    await tester.pumpObers(
      OiInfiniteScroll(
        moreAvailable: true,
        onLoadMore: () async => loads++,
        child: ListView(
          children: [
            SizedBox(
              height: 60,
              child: ListView.builder(
                key: const Key('nested'),
                scrollDirection: Axis.horizontal,
                itemCount: 20,
                itemBuilder: (_, i) => SizedBox(width: 60, child: Text('h$i')),
              ),
            ),
            for (var i = 0; i < 40; i++)
              SizedBox(height: 60, child: Text('v$i')),
          ],
        ),
      ),
      surfaceSize: const Size(400, 300),
    );
    await tester.pumpAndSettle();
    expect(loads, 0);

    await tester.drag(find.byKey(const Key('nested')), const Offset(-2000, 0));
    await tester.pumpAndSettle();

    expect(loads, 0);
  });

  testWidgets('a sibling scrollable on the other axis does not load', (
    tester,
  ) async {
    var loads = 0;
    await tester.pumpObers(
      OiInfiniteScroll(
        moreAvailable: true,
        onLoadMore: () async => loads++,
        child: Column(
          children: [
            SizedBox(
              height: 60,
              child: ListView.builder(
                key: const Key('chips'),
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (_, i) => SizedBox(width: 60, child: Text('c$i')),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 40,
                itemBuilder: (_, i) => SizedBox(height: 60, child: Text('v$i')),
              ),
            ),
          ],
        ),
      ),
      surfaceSize: const Size(400, 300),
    );
    await tester.pumpAndSettle();

    expect(loads, 0);
  });

  testWidgets('scrollDirection: horizontal loads from a horizontal list', (
    tester,
  ) async {
    var loads = 0;
    await tester.pumpObers(
      OiInfiniteScroll(
        moreAvailable: true,
        scrollDirection: Axis.horizontal,
        onLoadMore: () async => loads++,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 40,
          itemBuilder: (_, i) => SizedBox(width: 60, child: Text('h$i')),
        ),
      ),
      surfaceSize: const Size(400, 300),
    );
    await tester.pumpAndSettle();
    expect(loads, 0);

    await tester.drag(find.byType(ListView), const Offset(-3000, 0));
    await tester.pumpAndSettle();

    expect(loads, 1);
  });

  testWidgets('one arrival at the bottom loads once, however fast the load', (
    tester,
  ) async {
    var loads = 0;
    await tester.pumpObers(
      _buildScroll(
        itemCount: 20,
        moreAvailable: true,
        onLoadMore: () async => loads++,
      ),
      surfaceSize: const Size(400, 300),
    );

    final gesture = await tester.startGesture(const Offset(200, 250));
    for (var step = 0; step < 30; step++) {
      await gesture.moveBy(const Offset(0, -30));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(loads, 1);
  });
}
