import 'dart:math' as math;
import 'dart:ui';

/// Shape used to mark individual data points on a chart.
enum OiMarkerShape { circle, square, diamond, triangle, cross, none }

/// Paints marker shapes at specified positions on a chart canvas.
class OiChartMarkerPainter {
  OiChartMarkerPainter._();

  /// Paints a marker [shape] at [center] with the given [color] and [size].
  static void paint(
    Canvas canvas,
    Offset center, {
    required OiMarkerShape shape,
    required Color color,
    double size = 6,
  }) {
    switch (shape) {
      case OiMarkerShape.none:
        return;
      case OiMarkerShape.circle:
        _paintCircle(canvas, center, color, size);
      case OiMarkerShape.square:
        _paintSquare(canvas, center, color, size);
      case OiMarkerShape.diamond:
        _paintDiamond(canvas, center, color, size);
      case OiMarkerShape.triangle:
        _paintTriangle(canvas, center, color, size);
      case OiMarkerShape.cross:
        _paintCross(canvas, center, color, size);
    }
  }

  static void _paintCircle(
    Canvas canvas,
    Offset center,
    Color color,
    double size,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size / 2, paint);
  }

  static void _paintSquare(
    Canvas canvas,
    Offset center,
    Color color,
    double size,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final half = size / 2;
    canvas.drawRect(
      Rect.fromCenter(center: center, width: half * 2, height: half * 2),
      paint,
    );
  }

  static void _paintDiamond(
    Canvas canvas,
    Offset center,
    Color color,
    double size,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final half = size / 2;
    final path = Path()
      ..moveTo(center.dx, center.dy - half)
      ..lineTo(center.dx + half, center.dy)
      ..lineTo(center.dx, center.dy + half)
      ..lineTo(center.dx - half, center.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  static void _paintTriangle(
    Canvas canvas,
    Offset center,
    Color color,
    double size,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final half = size / 2;
    final height = half * math.sqrt(3);
    final path = Path()
      ..moveTo(center.dx, center.dy - height / 2)
      ..lineTo(center.dx + half, center.dy + height / 2)
      ..lineTo(center.dx - half, center.dy + height / 2)
      ..close();
    canvas.drawPath(path, paint);
  }

  static void _paintCross(
    Canvas canvas,
    Offset center,
    Color color,
    double size,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final half = size / 2;
    canvas
      ..drawLine(
        Offset(center.dx - half, center.dy - half),
        Offset(center.dx + half, center.dy + half),
        paint,
      )
      ..drawLine(
        Offset(center.dx + half, center.dy - half),
        Offset(center.dx - half, center.dy + half),
        paint,
      );
  }
}
