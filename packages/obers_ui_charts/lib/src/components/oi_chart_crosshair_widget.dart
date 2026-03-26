import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:obers_ui_charts/src/foundation/oi_chart_viewport.dart';

/// A widget that renders horizontal and/or vertical crosshair lines at a
/// given position within a chart plot area.
///
/// [OiChartCrosshairWidget] is a pure rendering widget — it does not handle
/// pointer events. Pair it with `OiChartCrosshairBehavior` (or manage the
/// position yourself) and rebuild with the updated [position] on each frame.
///
/// Crosshair lines are clipped to the plot bounds so they never render
/// outside the data area.
///
/// ```dart
/// OiChartCrosshairWidget(
///   position: pointerOffset,
///   viewport: viewport,
///   showHorizontal: true,
///   showVertical: true,
///   color: Colors.blue,
///   dashPattern: const [4, 2],
/// )
/// ```
///
/// {@category Components}
class OiChartCrosshairWidget extends StatelessWidget {
  /// Creates an [OiChartCrosshairWidget].
  const OiChartCrosshairWidget({
    required this.position,
    required this.viewport,
    super.key,
    this.showHorizontal = true,
    this.showVertical = true,
    this.color,
    this.strokeWidth = 1.0,
    this.dashPattern,
  });

  /// The widget-local [Offset] where the crosshair lines intersect.
  ///
  /// Only the components relevant to each enabled line are used:
  /// `position.dx` for the vertical line, `position.dy` for horizontal.
  final Offset position;

  /// The chart viewport supplying the plot bounds for clipping and sizing.
  final OiChartViewport viewport;

  /// Whether to draw the horizontal crosshair line.
  final bool showHorizontal;

  /// Whether to draw the vertical crosshair line.
  final bool showVertical;

  /// Line color. Defaults to a semi-transparent grey when null.
  final Color? color;

  /// Line stroke width in logical pixels.
  final double strokeWidth;

  /// Optional dash pattern (e.g. `[4, 2]` for 4 px on / 2 px off).
  /// When null or empty, solid lines are drawn.
  final List<double>? dashPattern;

  @override
  Widget build(BuildContext context) {
    final themeColor =
        color ?? const Color(0x80888888); // semi-transparent grey fallback
    return CustomPaint(
      size: viewport.size,
      painter: _OiCrosshairPainter(
        position: position,
        plotBounds: viewport.plotBounds,
        showHorizontal: showHorizontal,
        showVertical: showVertical,
        color: themeColor,
        strokeWidth: strokeWidth,
        dashPattern: dashPattern,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal painter
// ─────────────────────────────────────────────────────────────────────────────

class _OiCrosshairPainter extends CustomPainter {
  _OiCrosshairPainter({
    required this.position,
    required this.plotBounds,
    required this.showHorizontal,
    required this.showVertical,
    required this.color,
    required this.strokeWidth,
    this.dashPattern,
  });

  final Offset position;
  final Rect plotBounds;
  final bool showHorizontal;
  final bool showVertical;
  final Color color;
  final double strokeWidth;
  final List<double>? dashPattern;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas
      ..save()
      ..clipRect(plotBounds);

    final hasDash = dashPattern != null && dashPattern!.isNotEmpty;

    if (showVertical) {
      final start = Offset(position.dx, plotBounds.top);
      final end = Offset(position.dx, plotBounds.bottom);
      hasDash
          ? _drawDashed(canvas, start, end, paint, dashPattern!)
          : canvas.drawLine(start, end, paint);
    }

    if (showHorizontal) {
      final start = Offset(plotBounds.left, position.dy);
      final end = Offset(plotBounds.right, position.dy);
      hasDash
          ? _drawDashed(canvas, start, end, paint, dashPattern!)
          : canvas.drawLine(start, end, paint);
    }

    canvas.restore();
  }

  static void _drawDashed(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    List<double> pattern,
  ) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = Offset(dx, dy).distance;
    if (distance == 0) return;

    final dirX = dx / distance;
    final dirY = dy / distance;

    var drawn = 0.0;
    var dashIndex = 0;
    var drawing = true;

    while (drawn < distance) {
      final dashLen = pattern[dashIndex % pattern.length];
      final segEnd = (drawn + dashLen).clamp(0.0, distance);

      if (drawing) {
        canvas.drawLine(
          Offset(start.dx + dirX * drawn, start.dy + dirY * drawn),
          Offset(start.dx + dirX * segEnd, start.dy + dirY * segEnd),
          paint,
        );
      }

      drawn = segEnd;
      dashIndex++;
      drawing = !drawing;
    }
  }

  @override
  bool shouldRepaint(covariant _OiCrosshairPainter old) {
    return old.position != position ||
        old.plotBounds != plotBounds ||
        old.showHorizontal != showHorizontal ||
        old.showVertical != showVertical ||
        old.color != color ||
        old.strokeWidth != strokeWidth ||
        !listEquals(old.dashPattern, dashPattern);
  }
}
