import 'package:flutter/widgets.dart';

/// Highlights a single widget by dimming everything else.
///
/// Renders an overlay with a transparent cutout around the [target] widget.
/// Used for single-step highlighting and as a building block for [OiTour].
///
/// {@category Composites}
class OiSpotlight extends StatefulWidget {
  /// Creates an [OiSpotlight].
  const OiSpotlight({
    required this.target,
    required this.child,
    this.active = true,
    this.overlayColor,
    this.padding = 8,
    this.borderRadius,
    this.onTapOutside,
    super.key,
  });

  /// The [GlobalKey] of the widget to spotlight.
  final GlobalKey target;

  /// The child widget tree (the full page content).
  final Widget child;

  /// Whether the spotlight overlay is active.
  ///
  /// When `false`, only [child] is rendered with no overlay.
  final bool active;

  /// The color of the dimmed overlay.
  ///
  /// Defaults to black54.
  final Color? overlayColor;

  /// Padding in logical pixels around the spotlighted widget.
  final double padding;

  /// Border radius of the cutout.
  ///
  /// When `null`, the cutout is a plain rectangle.
  final BorderRadius? borderRadius;

  /// Called when the user taps outside the spotlighted area.
  final VoidCallback? onTapOutside;

  @override
  State<OiSpotlight> createState() => _OiSpotlightState();
}

class _OiSpotlightState extends State<OiSpotlight> {
  Rect? _targetRect;

  @override
  void initState() {
    super.initState();
    if (widget.active) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateTargetRect();
      });
    }
  }

  @override
  void didUpdateWidget(OiSpotlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active &&
        (!oldWidget.active || widget.target != oldWidget.target)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateTargetRect();
      });
    }
  }

  void _updateTargetRect() {
    final renderObject = widget.target.currentContext?.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      final offset = renderObject.localToGlobal(Offset.zero);
      final size = renderObject.size;
      if (mounted) {
        setState(() {
          _targetRect = Rect.fromLTWH(
            offset.dx - widget.padding,
            offset.dy - widget.padding,
            size.width + widget.padding * 2,
            size.height + widget.padding * 2,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        if (_targetRect != null)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onTapOutside,
              child: CustomPaint(
                key: const Key('oi_spotlight_overlay'),
                painter: _SpotlightPainter(
                  targetRect: _targetRect!,
                  overlayColor: widget.overlayColor ?? const Color(0x8A000000),
                  borderRadius: widget.borderRadius,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Paints a dimmed overlay with a transparent cutout around [targetRect].
class _SpotlightPainter extends CustomPainter {
  const _SpotlightPainter({
    required this.targetRect,
    required this.overlayColor,
    this.borderRadius,
  });

  final Rect targetRect;
  final Color overlayColor;
  final BorderRadius? borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final fullRect = Offset.zero & size;

    final cutoutPath = Path();
    if (borderRadius != null) {
      cutoutPath.addRRect(borderRadius!.toRRect(targetRect));
    } else {
      cutoutPath.addRect(targetRect);
    }

    final overlayPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(fullRect),
      cutoutPath,
    );

    canvas.drawPath(overlayPath, Paint()..color = overlayColor);
  }

  @override
  bool shouldRepaint(_SpotlightPainter oldDelegate) =>
      oldDelegate.targetRect != targetRect ||
      oldDelegate.overlayColor != overlayColor ||
      oldDelegate.borderRadius != borderRadius;
}
