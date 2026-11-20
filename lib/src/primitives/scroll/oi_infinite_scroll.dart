import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/scroll/oi_load_more_latch.dart';

/// A wrapper that adds infinite-scroll behaviour to any scrollable [child].
///
/// [OiInfiniteScroll] listens to scroll notifications from its [child]. When
/// the scroll position approaches the bottom (within [threshold] pixels) and
/// [moreAvailable] is `true`, [onLoadMore] is called. While the future is in flight
/// a [loadingWidget] (or a default spinner) is shown at the bottom of the
/// stack. Once the future resolves the loading indicator is removed.
///
/// The position is also checked after layout, so a first page that does not
/// fill the viewport loads the next one without the user scrolling. Each
/// arrival near the end calls [onLoadMore] once; it is called again after the
/// content grows, after the user scrolls away and back, or after this widget
/// is rebuilt following a completed load.
///
/// ```dart
/// OiInfiniteScroll(
///   moreAvailable: _hasMore,
///   onLoadMore: _fetchNextPage,
///   child: ListView.builder(
///     itemCount: items.length,
///     itemBuilder: (_, i) => Text(items[i]),
///   ),
/// )
/// ```
///
/// {@category Primitives}
class OiInfiniteScroll extends StatefulWidget {
  /// Creates an [OiInfiniteScroll].
  const OiInfiniteScroll({
    required this.moreAvailable,
    required this.onLoadMore,
    required this.child,
    this.loadingWidget,
    this.threshold = 200,
    this.scrollDirection = Axis.vertical,
    super.key,
  });

  /// Whether more items can be loaded.
  ///
  /// When `false`, [onLoadMore] will not be called even if the user scrolls
  /// to the bottom.
  final bool moreAvailable;

  /// Called when the scroll position is within [threshold] pixels of the
  /// bottom, whether the user scrolled there or the content is that short.
  ///
  /// The returned future is awaited; [loadingWidget] is shown for its
  /// duration.
  final Future<void> Function() onLoadMore;

  /// Widget to display while [onLoadMore] is in progress.
  ///
  /// Defaults to a small animated spinner when null.
  final Widget? loadingWidget;

  /// Distance in pixels from the bottom of the scroll content that triggers
  /// a load. Defaults to 200.
  final double threshold;

  /// The axis of the scrollable in [child] that drives loading.
  ///
  /// The nearest scrollable below this widget on this axis is watched, even
  /// when it sits inside a scroller on the other axis. Scrollables on the
  /// other axis, and ones nested inside the watched one, never trigger a
  /// load. Defaults to [Axis.vertical].
  final Axis scrollDirection;

  /// The scrollable content.
  ///
  /// Typically a [ListView], [GridView], or [CustomScrollView].
  final Widget child;

  @override
  State<OiInfiniteScroll> createState() => _OiInfiniteScrollState();
}

class _OiInfiniteScrollState extends State<OiInfiniteScroll> {
  final OiLoadMoreLatch _latch = OiLoadMoreLatch();
  bool _isLoading = false;

  /// The notification context of the scrollable being watched, used to read
  /// its live position after layout.
  BuildContext? _scrollableContext;

  /// The depth of the scrollable being watched, see [_isWatched].
  int? _watchedDepth;

  /// The laid-out length of the content when the last load was started.
  double? _contentAtFire;

  @override
  void didUpdateWidget(OiInfiniteScroll oldWidget) {
    super.didUpdateWidget(oldWidget);
    // More content is reported by a changed scroll extent, which re-arms the
    // latch on its own. A rebuild alone does not: a load that failed or
    // brought nothing would otherwise be retried in a loop.
    if (widget.moreAvailable && !oldWidget.moreAvailable) _latch.reset();
    _checkAfterLayout();
  }

  void _checkAfterLayout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final scrollableContext = _scrollableContext;
      if (scrollableContext == null || !scrollableContext.mounted) return;
      final position = Scrollable.maybeOf(scrollableContext)?.position;
      if (position == null) return;
      // Content that grew but still fits the viewport leaves the scroll
      // extent at zero, so the latch cannot see it. Measure it instead: more
      // content re-arms the latch, a load that brought nothing does not.
      final content = _contentExtent(scrollableContext);
      final atFire = _contentAtFire;
      if (content != null && atFire != null && content > atFire) {
        _latch.reset();
      }
      _check(position);
    });
  }

  /// The laid-out length of the content of the scrollable at
  /// [scrollableContext], or null when it cannot be measured.
  ///
  /// Exact for content shorter than the viewport (every child is laid out),
  /// an estimate otherwise; it is only compared to spot growth.
  static double? _contentExtent(BuildContext scrollableContext) {
    RenderViewportBase? viewport;
    void find(RenderObject object) {
      if (viewport != null) return;
      if (object is RenderViewportBase) {
        viewport = object;
      } else {
        object.visitChildren(find);
      }
    }

    final root = scrollableContext.findRenderObject();
    if (root == null) return null;
    find(root);
    final found = viewport;
    if (found == null) return null;
    var total = 0.0;
    found.visitChildren((child) {
      if (child is RenderSliver) total += child.geometry?.scrollExtent ?? 0;
    });
    return total;
  }

  /// Whether [metrics] come from the scrollable this widget watches: the
  /// nearest one below it on the configured axis, at any depth. A list
  /// inside a scroller on the other axis (a wide table, say) is still found,
  /// and a scrollable on the other axis (a horizontal carousel inside a
  /// vertical list) is ignored.
  bool _isWatched(int depth, ScrollMetrics metrics) {
    if (metrics.axis != widget.scrollDirection) return false;
    final watched = _watchedDepth;
    if (watched == null || depth < watched) _watchedDepth = depth;
    return depth == _watchedDepth;
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (_isWatched(notification.depth, notification.metrics)) {
      _scrollableContext = notification.context;
      _check(notification.metrics);
    }
    return false;
  }

  /// Sent after layout whenever the extents change, including the first
  /// layout, so a first page shorter than the viewport loads the next one
  /// without any user interaction.
  bool _onMetricsNotification(ScrollMetricsNotification notification) {
    if (_isWatched(notification.depth, notification.metrics)) {
      _scrollableContext = notification.context;
      _check(notification.metrics);
    }
    return false;
  }

  void _check(ScrollMetrics metrics) {
    if (!widget.moreAvailable || _isLoading) return;
    if (_latch.shouldFire(metrics, threshold: widget.threshold)) {
      final scrollableContext = _scrollableContext;
      _contentAtFire = scrollableContext != null && scrollableContext.mounted
          ? _contentExtent(scrollableContext)
          : null;
      unawaited(_loadMore());
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await _latch.track(widget.onLoadMore());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: _onMetricsNotification,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            widget.child,
            if (_isLoading)
              Positioned(
                bottom: 16,
                child:
                    widget.loadingWidget ??
                    const _InfiniteScrollSpinner(
                      key: ValueKey('oi_infinite_scroll_spinner'),
                    ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Default loading spinner used by [OiInfiniteScroll].
class _InfiniteScrollSpinner extends StatefulWidget {
  const _InfiniteScrollSpinner({super.key});

  @override
  State<_InfiniteScrollSpinner> createState() => _InfiniteScrollSpinnerState();
}

class _InfiniteScrollSpinnerState extends State<_InfiniteScrollSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    unawaited(_controller.repeat());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced =
        context.animations.reducedMotion ||
        MediaQuery.disableAnimationsOf(context);
    _controller.duration = reduced
        ? Duration.zero
        : const Duration(milliseconds: 800);
    if (reduced && _controller.isAnimating) {
      _controller
        ..stop()
        ..value = 0;
    } else if (!reduced && !_controller.isAnimating) {
      unawaited(_controller.repeat());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CustomPaint(painter: _SpinnerPainter()),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  const _SpinnerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      0,
      4.2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_SpinnerPainter oldDelegate) => false;
}
