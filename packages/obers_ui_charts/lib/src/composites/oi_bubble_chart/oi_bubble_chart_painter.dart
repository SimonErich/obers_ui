import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

/// Resolved data for a single bubble ready for painting.
class ResolvedBubble {
  /// Creates a [ResolvedBubble].
  const ResolvedBubble({
    required this.x,
    required this.y,
    required this.radius,
    required this.color,
    required this.opacity,
    required this.borderWidth,
    required this.borderColor,
    required this.seriesIndex,
    required this.pointIndex,
  });

  /// Normalised x position (0–1).
  final double x;

  /// Normalised y position (0–1).
  final double y;

  /// Rendered radius in logical pixels.
  final double radius;

  /// Fill color.
  final Color color;

  /// Fill opacity.
  final double opacity;

  /// Border stroke width.
  final double borderWidth;

  /// Border color (typically the fill color at full opacity).
  final Color borderColor;

  /// Index of the series this bubble belongs to.
  final int seriesIndex;

  /// Index of the point within its series.
  final int pointIndex;
}

/// Custom painter for the bubble chart.
///
/// Draws axes, grid lines, and bubbles. Supports high-contrast mode
/// (thicker borders) and reduced-motion mode (no animated effects).
class OiBubbleChartPainter extends CustomPainter {
  /// Creates an [OiBubbleChartPainter].
  OiBubbleChartPainter({
    required this.bubbles,
    required this.gridColor,
    required this.axisLabelColor,
    required this.textColor,
    required this.highContrast,
    required this.compact,
    this.hoveredIndex,
  });

  /// The resolved bubbles to paint.
  final List<ResolvedBubble> bubbles;

  /// Color for grid / axis lines.
  final Color gridColor;

  /// Color for axis label text.
  final Color axisLabelColor;

  /// Color for value text.
  final Color textColor;

  /// Whether high-contrast mode is active.
  final bool highContrast;

  /// Whether the chart is in compact mode (fewer labels).
  final bool compact;

  /// Index in [bubbles] of the currently hovered/focused bubble, if any.
  final int? hoveredIndex;

  static const double _padding = 40;
  static const double _compactPadding = 24;

  @override
  void paint(Canvas canvas, Size size) {
    final pad = compact ? _compactPadding : _padding;
    final chartRect = Rect.fromLTRB(
      pad,
      pad / 2,
      size.width - 8,
      size.height - pad,
    );

    if (chartRect.width <= 0 || chartRect.height <= 0) return;

    _drawAxes(canvas, size, chartRect);
    for (var i = 0; i < bubbles.length; i++) {
      _drawBubble(canvas, chartRect, bubbles[i], isHovered: i == hoveredIndex);
    }
  }

  void _drawAxes(Canvas canvas, Size size, Rect chartRect) {
    final axisPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = highContrast ? 1.5 : 0.5;

    // Draw x-axis (bottom) and y-axis (left).
    canvas
      ..drawLine(
        Offset(chartRect.left, chartRect.bottom),
        Offset(chartRect.right, chartRect.bottom),
        axisPaint,
      )
      ..drawLine(
        Offset(chartRect.left, chartRect.top),
        Offset(chartRect.left, chartRect.bottom),
        axisPaint,
      );

    // Grid lines.
    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: highContrast ? 0.3 : 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final gridCount = compact ? 3 : 5;

    for (var i = 1; i <= gridCount; i++) {
      final t = i / gridCount;

      // Horizontal grid line.
      final gy = chartRect.bottom - t * chartRect.height;
      canvas.drawLine(
        Offset(chartRect.left, gy),
        Offset(chartRect.right, gy),
        gridPaint,
      );

      // Vertical grid line.
      final gx = chartRect.left + t * chartRect.width;
      canvas.drawLine(
        Offset(gx, chartRect.top),
        Offset(gx, chartRect.bottom),
        gridPaint,
      );
    }
  }

  void _drawBubble(
    Canvas canvas,
    Rect chartRect,
    ResolvedBubble bubble, {
    bool isHovered = false,
  }) {
    final cx = chartRect.left + bubble.x * chartRect.width;
    final cy = chartRect.bottom - bubble.y * chartRect.height;
    final r = bubble.radius;

    final fillPaint = Paint()
      ..color = bubble.color.withValues(alpha: bubble.opacity)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = bubble.borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = isHovered
          ? bubble.borderWidth + 1.5
          : (highContrast ? bubble.borderWidth + 1 : bubble.borderWidth);

    canvas
      ..drawCircle(Offset(cx, cy), r, fillPaint)
      ..drawCircle(Offset(cx, cy), r, borderPaint);

    // Draw a stronger ring when hovered.
    if (isHovered) {
      final hoverPaint = Paint()
        ..color = bubble.borderColor.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(cx, cy), r + 3, hoverPaint);
    }
  }

  @override
  bool shouldRepaint(OiBubbleChartPainter oldDelegate) =>
      oldDelegate.bubbles != bubbles ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.highContrast != highContrast ||
      oldDelegate.compact != compact ||
      oldDelegate.hoveredIndex != hoveredIndex;
}

/// Finds the index of the nearest bubble to [position] within [maxDistance].
///
/// Returns null if no bubble is close enough.
int? findNearestBubble(
  Offset position,
  List<ResolvedBubble> bubbles,
  Rect chartRect, {
  double maxDistance = 40,
}) {
  int? nearestIndex;
  var nearestDist = double.infinity;

  for (var i = 0; i < bubbles.length; i++) {
    final b = bubbles[i];
    final cx = chartRect.left + b.x * chartRect.width;
    final cy = chartRect.bottom - b.y * chartRect.height;
    final dist = math.sqrt(
      math.pow(position.dx - cx, 2) + math.pow(position.dy - cy, 2),
    );
    if (dist < nearestDist && dist <= maxDistance + b.radius) {
      nearestDist = dist;
      nearestIndex = i;
    }
  }

  return nearestIndex;
}
