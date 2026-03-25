import 'dart:ui' show Offset, Path;

/// Builds a smooth cubic Bézier path through the given [points].
///
/// If [points] has fewer than 2 entries, returns an empty path.
/// Uses Catmull-Rom to compute control points for smooth interpolation.
Path smoothLinePath(List<Offset> points) {
  final path = Path();
  if (points.length < 2) return path;

  path.moveTo(points.first.dx, points.first.dy);

  if (points.length == 2) {
    path.lineTo(points[1].dx, points[1].dy);
    return path;
  }

  for (var i = 0; i < points.length - 1; i++) {
    final p0 = i > 0 ? points[i - 1] : points[i];
    final p1 = points[i];
    final p2 = points[i + 1];
    final p3 = i + 2 < points.length ? points[i + 2] : p2;

    // Catmull-Rom to cubic Bézier control points.
    final cp1 = Offset(
      p1.dx + (p2.dx - p0.dx) / 6,
      p1.dy + (p2.dy - p0.dy) / 6,
    );
    final cp2 = Offset(
      p2.dx - (p3.dx - p1.dx) / 6,
      p2.dy - (p3.dy - p1.dy) / 6,
    );

    path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
  }

  return path;
}

/// Builds a straight-line path connecting the given [points].
///
/// Gaps can be introduced by setting a point to `null` in the list.
Path straightLinePath(List<Offset?> points) {
  final path = Path();
  var drawing = false;

  for (final point in points) {
    if (point == null) {
      drawing = false;
      continue;
    }
    if (!drawing) {
      path.moveTo(point.dx, point.dy);
      drawing = true;
    } else {
      path.lineTo(point.dx, point.dy);
    }
  }

  return path;
}
