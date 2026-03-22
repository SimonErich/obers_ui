import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A compact inline sparkline chart for embedding in metrics, table cells,
/// or list tiles.
///
/// Renders a polyline from [values] normalised to the widget height.
/// Supports optional area fill, last-point dot, and min/max markers.
///
/// {@category Composites}
class OiSparkline extends StatelessWidget {
  /// Creates an [OiSparkline].
  const OiSparkline({
    required this.label,
    required this.values,
    super.key,
    this.color,
    this.fill = false,
    this.fillOpacity = 0.15,
    this.strokeWidth = 1.5,
    this.showLastPoint = false,
    this.showMinMax = false,
    this.height = 32,
    this.width,
  });

  /// Accessibility label for the sparkline.
  final String label;

  /// The data values to plot.
  final List<double> values;

  /// The line color. Defaults to the theme's primary color.
  final Color? color;

  /// Whether to fill the area below the line.
  final bool fill;

  /// The opacity of the area fill when [fill] is `true`.
  final double fillOpacity;

  /// The stroke width of the line.
  final double strokeWidth;

  /// Whether to show a dot at the last data point.
  final bool showLastPoint;

  /// Whether to show dots at the minimum and maximum values.
  final bool showMinMax;

  /// The height of the sparkline. Defaults to 32.
  final double height;

  /// The width of the sparkline. When null, fills available width.
  final double? width;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return const SizedBox.shrink(key: Key('oi_sparkline_empty'));
    }

    final effectiveColor = color ?? context.colors.primary.base;

    final child = CustomPaint(
      key: const Key('oi_sparkline_painter'),
      size: Size(width ?? double.infinity, height),
      painter: _OiSparklinePainter(
        values: values,
        color: effectiveColor,
        fill: fill,
        fillOpacity: fillOpacity,
        strokeWidth: strokeWidth,
        showLastPoint: showLastPoint,
        showMinMax: showMinMax,
      ),
    );

    return Semantics(
      label: label,
      child: SizedBox(
        width: width,
        height: height,
        child: child,
      ),
    );
  }
}

class _OiSparklinePainter extends CustomPainter {
  _OiSparklinePainter({
    required this.values,
    required this.color,
    required this.fill,
    required this.fillOpacity,
    required this.strokeWidth,
    required this.showLastPoint,
    required this.showMinMax,
  });

  final List<double> values;
  final Color color;
  final bool fill;
  final double fillOpacity;
  final double strokeWidth;
  final bool showLastPoint;
  final bool showMinMax;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final minVal = values.reduce(math.min);
    final maxVal = values.reduce(math.max);
    final range = maxVal - minVal;

    // Pad vertically so dots aren't clipped.
    const vPad = 2.0;
    final drawH = size.height - vPad * 2;

    double normalise(double v) {
      if (range == 0) return 0.5;
      return (v - minVal) / range;
    }

    Offset point(int i) {
      final x = values.length == 1
          ? size.width / 2
          : size.width * i / (values.length - 1);
      final y = vPad + drawH * (1 - normalise(values[i]));
      return Offset(x, y);
    }

    // Build polyline path.
    final path = Path()..moveTo(point(0).dx, point(0).dy);
    for (var i = 1; i < values.length; i++) {
      final p = point(i);
      path.lineTo(p.dx, p.dy);
    }

    // Draw fill.
    if (fill) {
      final fillPath = Path()
        ..addPath(path, Offset.zero)
        ..lineTo(point(values.length - 1).dx, size.height)
        ..lineTo(point(0).dx, size.height)
        ..close();
      canvas.drawPath(
        fillPath,
        Paint()
          ..color = color.withValues(alpha: fillOpacity)
          ..style = PaintingStyle.fill,
      );
    }

    // Draw line.
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Draw last point dot.
    if (showLastPoint && values.isNotEmpty) {
      final last = point(values.length - 1);
      canvas.drawCircle(last, strokeWidth * 2, Paint()..color = color);
    }

    // Draw min/max dots.
    if (showMinMax && values.length > 1) {
      var minIdx = 0;
      var maxIdx = 0;
      for (var i = 1; i < values.length; i++) {
        if (values[i] < values[minIdx]) minIdx = i;
        if (values[i] > values[maxIdx]) maxIdx = i;
      }
      final dotPaint = Paint()..color = color;
      final dotRadius = strokeWidth * 1.5;
      canvas.drawCircle(point(minIdx), dotRadius, dotPaint);
      if (maxIdx != minIdx) {
        canvas.drawCircle(point(maxIdx), dotRadius, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_OiSparklinePainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.color != color ||
      oldDelegate.fill != fill ||
      oldDelegate.fillOpacity != fillOpacity ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.showLastPoint != showLastPoint ||
      oldDelegate.showMinMax != showMinMax;
}
