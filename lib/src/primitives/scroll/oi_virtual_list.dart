import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// The overscroll distance required to trigger a pull-to-refresh.
const double _kRefreshTriggerDistance = 60;

/// A virtualised, lazily-rendered list of items.
///
/// Uses [ListView.builder] under the hood for efficient rendering of large
/// datasets. Only items near the visible viewport are built.
///
/// When [onRefresh] is provided and the active density is
/// [OiDensity.comfortable] (touch devices), a pull-to-refresh gesture is
/// enabled: pulling the list down beyond [_kRefreshTriggerDistance] pixels
/// triggers [onRefresh] and shows a loading indicator at the top of the list.
///
/// ```dart
/// OiVirtualList(
///   itemCount: items.length,
///   itemBuilder: (context, index) => Text(items[index]),
/// )
/// ```
///
/// {@category Primitives}
class OiVirtualList extends StatefulWidget {
  /// Creates an [OiVirtualList].
  const OiVirtualList({
    required this.itemCount,
    required this.itemBuilder,
    this.cacheExtent,
    this.onRefresh,
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.padding,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    super.key,
  });

  /// Number of items in the list.
  final int itemCount;

  /// Builder for each item at the given index.
  final IndexedWidgetBuilder itemBuilder;

  /// Cache extent in pixels beyond the viewport.
  final double? cacheExtent;

  /// Called when the user pulls to refresh (touch devices only).
  ///
  /// When non-null and the active density is [OiDensity.comfortable], an
  /// overscroll past [_kRefreshTriggerDistance] pixels will invoke this
  /// callback and display a loading indicator while it completes.
  final Future<void> Function()? onRefresh;

  /// An optional scroll controller.
  final ScrollController? controller;

  /// The axis along which the list scrolls.
  final Axis scrollDirection;

  /// Whether to reverse the scroll direction.
  final bool reverse;

  /// Padding around the list content.
  final EdgeInsetsGeometry? padding;

  /// Whether this is the primary scroll view associated with the parent.
  final bool? primary;

  /// Custom scroll physics.
  final ScrollPhysics? physics;

  /// Whether the list should shrink-wrap its content.
  final bool shrinkWrap;

  @override
  State<OiVirtualList> createState() => _OiVirtualListState();
}

class _OiVirtualListState extends State<OiVirtualList> {
  bool _isRefreshing = false;
  double _overscrollAccumulated = 0;

  bool get _refreshEnabled =>
      widget.onRefresh != null &&
      OiDensityScope.of(context) == OiDensity.comfortable;

  Future<void> _triggerRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      await widget.onRefresh!();
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (!_refreshEnabled) return false;
    if (notification is OverscrollNotification) {
      // overscroll < 0 means pulling past the top on a vertical list.
      if (notification.overscroll < 0) {
        _overscrollAccumulated += notification.overscroll.abs();
        if (_overscrollAccumulated >= _kRefreshTriggerDistance &&
            !_isRefreshing) {
          _overscrollAccumulated = 0;
          _triggerRefresh();
        }
      }
    }
    if (notification is ScrollEndNotification) {
      _overscrollAccumulated = 0;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final list = ListView.builder(
      itemCount: widget.itemCount,
      itemBuilder: widget.itemBuilder,
      cacheExtent: widget.cacheExtent,
      controller: widget.controller,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      padding: widget.padding,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
    );

    if (widget.onRefresh == null) return list;

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Stack(
        children: [
          list,
          if (_isRefreshing && widget.scrollDirection == Axis.vertical)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: _OiSpinner(
                    key: ValueKey('oi_virtual_list_refresh_indicator'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A simple platform-native spinner used as a loading indicator.
class _OiSpinner extends StatefulWidget {
  const _OiSpinner({super.key});

  @override
  State<_OiSpinner> createState() => _OiSpinnerState();
}

class _OiSpinnerState extends State<_OiSpinner>
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
