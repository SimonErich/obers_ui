import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A wrapper that adds infinite-scroll behaviour to any scrollable [child].
///
/// [OiInfiniteScroll] listens to scroll notifications from its [child]. When
/// the scroll position approaches the bottom (within [threshold] pixels) and
/// [moreAvailable] is `true`, [onLoadMore] is called. While the future is in flight
/// a [loadingWidget] (or a default spinner) is shown at the bottom of the
/// stack. Once the future resolves the loading indicator is removed.
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
    super.key,
  });

  /// Whether more items can be loaded.
  ///
  /// When `false`, [onLoadMore] will not be called even if the user scrolls
  /// to the bottom.
  final bool moreAvailable;

  /// Called when the user scrolls within [threshold] pixels of the bottom.
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

  /// The scrollable content.
  ///
  /// Typically a [ListView], [GridView], or [CustomScrollView].
  final Widget child;

  @override
  State<OiInfiniteScroll> createState() => _OiInfiniteScrollState();
}

class _OiInfiniteScrollState extends State<OiInfiniteScroll> {
  bool _isLoading = false;

  bool _onNotification(ScrollNotification notification) {
    if (!widget.moreAvailable || _isLoading) return false;

    final metrics = notification.metrics;
    if (metrics.pixels >= metrics.maxScrollExtent - widget.threshold) {
      _loadMore();
    }
    return false;
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await widget.onLoadMore();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onNotification,
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
    )..repeat();
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
      _controller.repeat();
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
