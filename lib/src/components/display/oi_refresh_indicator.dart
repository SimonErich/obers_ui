import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_progress.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A pull-to-refresh wrapper that shows a circular progress indicator when the
/// user overscrolls at the top of a scrollable child.
///
/// Wrap any scrollable widget (e.g. `ListView`, `CustomScrollView`) with
/// [OiRefreshIndicator] and provide an [onRefresh] callback that returns a
/// [Future]. The indicator appears above the child content, animating in as
/// the user drags, then switches to an indeterminate spinner while the refresh
/// is in progress.
///
/// ```dart
/// OiRefreshIndicator(
///   onRefresh: () async {
///     await fetchLatestData();
///   },
///   child: ListView.builder(
///     itemCount: items.length,
///     itemBuilder: (context, index) => ItemTile(items[index]),
///   ),
/// )
/// ```
///
/// {@category Components}
class OiRefreshIndicator extends StatefulWidget {
  /// Creates an [OiRefreshIndicator].
  const OiRefreshIndicator({
    required this.child,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
    this.triggerDistance = 80.0,
    this.indicatorSize = 28.0,
    this.strokeWidth = 3.0,
    this.semanticLabel,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    super.key,
  });

  /// The scrollable child widget to wrap.
  final Widget child;

  /// Called when the user has pulled far enough to trigger a refresh.
  ///
  /// Must return a [Future] that completes when the refresh operation is done.
  final Future<void> Function() onRefresh;

  /// The color of the progress indicator.
  ///
  /// Defaults to the theme's primary color.
  final Color? color;

  /// The background color of the indicator container.
  ///
  /// Defaults to the theme's surface color.
  final Color? backgroundColor;

  /// The distance from the top edge at which the indicator settles during
  /// refresh.
  final double displacement;

  /// Additional offset from the top edge of the scrollable content.
  final double edgeOffset;

  /// The overscroll distance required to trigger the refresh callback.
  final double triggerDistance;

  /// The diameter of the circular progress indicator.
  final double indicatorSize;

  /// The stroke width of the circular progress indicator.
  final double strokeWidth;

  /// The accessibility label announced when a refresh begins.
  ///
  /// Defaults to `'Refreshing'`.
  final String? semanticLabel;

  /// A predicate that determines which [ScrollNotification]s should be handled.
  ///
  /// Defaults to [defaultScrollNotificationPredicate], which only accepts
  /// notifications from the nearest scrollable ancestor.
  final ScrollNotificationPredicate notificationPredicate;

  @override
  State<OiRefreshIndicator> createState() => _OiRefreshIndicatorState();
}

class _OiRefreshIndicatorState extends State<OiRefreshIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragOffset = 0;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reducedMotion =
        context.animations.reducedMotion ||
        MediaQuery.disableAnimationsOf(context);
    _controller.duration = reducedMotion
        ? Duration.zero
        : const Duration(milliseconds: 200);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Notification handling ─────────────────────────────────────────────────

  bool _handleScrollNotification(ScrollNotification notification) {
    if (!widget.notificationPredicate(notification)) return false;

    if (notification is OverscrollNotification) {
      _handleOverscroll(notification);
    } else if (notification is ScrollUpdateNotification) {
      _handleScrollUpdate(notification);
    } else if (notification is ScrollEndNotification) {
      _handleScrollEnd();
    }

    return false;
  }

  void _handleOverscroll(OverscrollNotification notification) {
    if (_isRefreshing) return;
    if (notification.metrics.pixels > 0) return;

    setState(() {
      _dragOffset += notification.overscroll.abs();
    });

    if (_dragOffset >= widget.triggerDistance) {
      unawaited(_triggerRefresh());
    }
  }

  void _handleScrollUpdate(ScrollUpdateNotification notification) {
    if (_isRefreshing) return;
    if (notification.metrics.pixels > 0 && _dragOffset > 0) {
      // User scrolled away from the top — reset the drag offset.
      setState(() {
        _dragOffset = 0.0;
      });
    }
  }

  void _handleScrollEnd() {
    if (_isRefreshing) return;
    if (_dragOffset > 0 && _dragOffset < widget.triggerDistance) {
      // Did not reach trigger distance — snap back.
      unawaited(
        _controller.reverse(from: 1).then((_) {
          if (mounted) {
            setState(() {
              _dragOffset = 0.0;
            });
          }
        }),
      );
    }
  }

  // ── Refresh lifecycle ─────────────────────────────────────────────────────

  Future<void> _triggerRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    unawaited(
      SemanticsService.sendAnnouncement(
        View.of(context),
        widget.semanticLabel ?? 'Refreshing',
        Directionality.of(context),
      ),
    );

    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        unawaited(
          SemanticsService.sendAnnouncement(
            View.of(context),
            'Refresh complete',
            Directionality.of(context),
          ),
        );

        final reducedMotion =
            context.animations.reducedMotion ||
            MediaQuery.disableAnimationsOf(context);

        if (reducedMotion) {
          setState(() {
            _isRefreshing = false;
            _dragOffset = 0.0;
          });
        } else {
          await _controller.reverse(from: 1);
          if (mounted) {
            setState(() {
              _isRefreshing = false;
              _dragOffset = 0.0;
            });
          }
        }
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shadows = context.shadows;
    final effectiveColor = widget.color ?? colors.primary.base;
    final effectiveBg = widget.backgroundColor ?? colors.surface;

    final progress = (_dragOffset / widget.triggerDistance).clamp(0.0, 1.0);
    final containerSize = widget.indicatorSize + 8;

    // The indicator's vertical position during the pull phase.
    final indicatorTop = _isRefreshing
        ? widget.edgeOffset + widget.displacement
        : widget.edgeOffset + (widget.displacement * progress) - containerSize;

    final showIndicator = _dragOffset > 0 || _isRefreshing;

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Stack(
        children: [
          widget.child,
          if (showIndicator)
            Positioned(
              top: indicatorTop,
              left: 0,
              right: 0,
              child: Center(
                child: Opacity(
                  opacity: _isRefreshing ? 1.0 : progress,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: effectiveBg,
                      shape: BoxShape.circle,
                      boxShadow: shadows.sm,
                    ),
                    child: SizedBox(
                      width: containerSize,
                      height: containerSize,
                      child: Center(
                        child: _isRefreshing
                            ? OiProgress.circular(
                                indeterminate: true,
                                color: effectiveColor,
                                strokeWidth: widget.strokeWidth,
                                size: widget.indicatorSize,
                              )
                            : OiProgress.circular(
                                value: progress,
                                color: effectiveColor,
                                strokeWidth: widget.strokeWidth,
                                size: widget.indicatorSize,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
