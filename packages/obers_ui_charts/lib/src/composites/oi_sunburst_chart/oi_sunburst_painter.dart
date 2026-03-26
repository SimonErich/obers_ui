import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Describes the geometry of a single arc segment in the sunburst chart.
///
/// {@category Composites}
class OiSunburstArcDatum {
  /// Creates an [OiSunburstArcDatum].
  const OiSunburstArcDatum({
    required this.nodeId,
    required this.label,
    required this.depth,
    required this.startAngle,
    required this.sweepAngle,
    required this.color,
  });

  /// The unique identifier of the corresponding tree node.
  final String nodeId;

  /// Display label for this arc segment.
  final String label;

  /// Ring depth (1 = first ring from center).
  final int depth;

  /// Start angle in radians (measured from positive x-axis, clockwise).
  final double startAngle;

  /// Sweep angle in radians.
  final double sweepAngle;

  /// Fill color of this arc.
  final Color color;
}

/// A [CustomPainter] that draws the concentric ring arcs of a sunburst chart.
///
/// Each ring corresponds to one depth level. The center (depth 0 = root)
/// is drawn as a filled circle; deeper levels are drawn as thick arc
/// strokes. Arc spans are proportional to each node's share of its parent's
/// aggregated value.
///
/// {@category Composites}
class OiSunburstPainter extends CustomPainter {
  /// Creates an [OiSunburstPainter].
  OiSunburstPainter({
    required this.arcs,
    required this.centerColor,
    required this.ringWidth,
    required this.innerRadius,
    required this.maxDepth,
    required this.hoveredNodeId,
  });

  /// The pre-computed arc geometry list (depth-ordered).
  final List<OiSunburstArcDatum> arcs;

  /// Color used to fill the root center circle.
  final Color centerColor;

  /// Thickness of each ring band in logical pixels.
  final double ringWidth;

  /// Radius of the center circle in logical pixels.
  final double innerRadius;

  /// Maximum depth actually present in [arcs].
  final int maxDepth;

  /// Node id of the currently hovered arc, or null.
  final String? hoveredNodeId;

  @override
  void paint(Canvas canvas, Size size) {
    if (arcs.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);

    // Draw center circle.
    final centerPaint = Paint()
      ..color = centerColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius, centerPaint);

    // Draw each arc.
    for (final arc in arcs) {
      final midRadius =
          innerRadius + (arc.depth - 1) * ringWidth + ringWidth / 2;
      final rect = Rect.fromCircle(center: center, radius: midRadius);

      final isHovered = hoveredNodeId == arc.nodeId;
      final color = isHovered ? arc.color.withValues(alpha: 1) : arc.color;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = isHovered ? ringWidth + 2 : ringWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, arc.startAngle, arc.sweepAngle, false, paint);

      // Draw separator line at the start of each arc.
      if (arc.sweepAngle > 0.01) {
        final separatorPaint = Paint()
          ..color = const Color(0xFFFFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

        final innerEdge = innerRadius + (arc.depth - 1) * ringWidth;
        final outerEdge = innerEdge + ringWidth;

        final cosA = math.cos(arc.startAngle);
        final sinA = math.sin(arc.startAngle);

        canvas.drawLine(
          Offset(center.dx + innerEdge * cosA, center.dy + innerEdge * sinA),
          Offset(center.dx + outerEdge * cosA, center.dy + outerEdge * sinA),
          separatorPaint,
        );
      }
    }

    // Draw labels for arcs that are wide enough.
    for (final arc in arcs) {
      if (arc.sweepAngle < 0.25) continue;

      final midRadius =
          innerRadius + (arc.depth - 1) * ringWidth + ringWidth / 2;
      final midAngle = arc.startAngle + arc.sweepAngle / 2;
      final labelPos = Offset(
        center.dx + midRadius * math.cos(midAngle),
        center.dy + midRadius * math.sin(midAngle),
      );

      final fontSize = math.max(8, math.min(11, ringWidth * 0.45)).toDouble();

      final tp = TextPainter(
        text: TextSpan(
          text: arc.label,
          style: TextStyle(
            color: const Color(0xFFFFFFFF),
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        ellipsis: '…',
        maxLines: 1,
      )..layout(maxWidth: ringWidth * 2);

      tp.paint(
        canvas,
        Offset(labelPos.dx - tp.width / 2, labelPos.dy - tp.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(OiSunburstPainter old) =>
      old.arcs != arcs ||
      old.centerColor != centerColor ||
      old.ringWidth != ringWidth ||
      old.innerRadius != innerRadius ||
      old.maxDepth != maxDepth ||
      old.hoveredNodeId != hoveredNodeId;
}
