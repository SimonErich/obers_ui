part of 'oi_surface.dart';

/// Paints dashed, dotted, or gradient borders around a rounded rectangle.
class _OiBorderPainter extends CustomPainter {
  const _OiBorderPainter({required this.style, required this.radius});

  final OiBorderStyle style;
  final BorderRadius radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = style.width
      ..style = PaintingStyle.stroke;

    if (style.gradient != null) {
      final rect = Offset.zero & size;
      paint.shader = style.gradient!.createShader(rect);
    } else {
      paint.color = style.color;
    }

    final rrect = RRect.fromRectAndCorners(
      Offset.zero & size,
      topLeft: radius.topLeft,
      topRight: radius.topRight,
      bottomLeft: radius.bottomLeft,
      bottomRight: radius.bottomRight,
    );

    if (style.lineStyle == OiBorderLineStyle.solid) {
      canvas.drawRRect(rrect, paint);
      return;
    }

    // Approximate perimeter for dash/dot spacing.
    final perimeter = _rrectPerimeter(rrect);
    final dashLength = style.lineStyle == OiBorderLineStyle.dashed
        ? style.width * 4
        : 0.0;
    final dotLength = style.lineStyle == OiBorderLineStyle.dotted
        ? style.width
        : 0.0;
    final segmentLength = style.lineStyle == OiBorderLineStyle.dashed
        ? dashLength
        : dotLength;
    final gapLength = segmentLength * 1.5;

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      var distance = 0.0;
      var draw = true;
      while (distance < metric.length) {
        final length = draw ? segmentLength : gapLength;
        if (draw) {
          canvas.drawPath(
            metric.extractPath(
              distance,
              distance + math.min(length, perimeter),
            ),
            paint,
          );
        }
        distance += length;
        draw = !draw;
      }
    }
  }

  double _rrectPerimeter(RRect rrect) {
    // Approximate: sum of straight edges + arc lengths at corners.
    final w = rrect.width;
    final h = rrect.height;
    final tl = rrect.tlRadiusX + rrect.tlRadiusY;
    final tr = rrect.trRadiusX + rrect.trRadiusY;
    final bl = rrect.blRadiusX + rrect.blRadiusY;
    final br = rrect.brRadiusX + rrect.brRadiusY;
    return 2 * w + 2 * h + (tl + tr + bl + br) * (math.pi / 4 - 1);
  }

  @override
  bool shouldRepaint(_OiBorderPainter oldDelegate) =>
      oldDelegate.style != style || oldDelegate.radius != radius;
}
