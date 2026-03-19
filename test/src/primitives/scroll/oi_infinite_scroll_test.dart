// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

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
}
