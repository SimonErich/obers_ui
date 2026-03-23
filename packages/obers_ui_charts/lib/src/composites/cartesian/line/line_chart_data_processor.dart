import 'dart:ui';

import 'package:obers_ui_charts/src/foundation/data/chart_data.dart';

/// Pure-Dart processor for line chart data transformations.
///
/// Handles interpolation and control point computation for smooth curves.
class OiLineChartDataProcessor {
  const OiLineChartDataProcessor();

  /// Linearly interpolates between data points to produce [segments] evenly
  /// spaced points.
  ///
  /// If [points] has fewer than 2 entries, returns [points] unchanged.
  List<OiDataPoint> interpolate(List<OiDataPoint> points, int segments) {
    if (points.length < 2 || segments <= 0) return points;

    final result = <OiDataPoint>[];
    final totalDistance = points.last.x - points.first.x;
    if (totalDistance == 0) return points;

    final step = totalDistance / segments;

    var segmentIndex = 0;
    for (var i = 0; i <= segments; i++) {
      final targetX = points.first.x + i * step;

      // Advance segment index to the right interval.
      while (segmentIndex < points.length - 2 &&
          points[segmentIndex + 1].x < targetX) {
        segmentIndex++;
      }

      final p0 = points[segmentIndex];
      final p1 = points[segmentIndex + 1];
      final xRange = p1.x - p0.x;
      final t = xRange == 0 ? 0.0 : (targetX - p0.x) / xRange;

      result.add(OiDataPoint(x: targetX, y: p0.y + t * (p1.y - p0.y)));
    }

    return result;
  }

  /// Computes cubic Bezier control points for a Catmull-Rom spline through
  /// [points].
  ///
  /// Returns pairs of control points for each segment between consecutive data
  /// points. The returned list has `(points.length - 1) * 2` offsets:
  /// `[cp1_0, cp2_0, cp1_1, cp2_1, ...]`.
  List<Offset> computeControlPoints(List<OiDataPoint> points) {
    if (points.length < 2) return [];

    final controlPoints = <Offset>[];
    const tension = 0.25;

    for (var i = 0; i < points.length - 1; i++) {
      final prev = i > 0 ? points[i - 1] : points[i];
      final curr = points[i];
      final next = points[i + 1];
      final nextNext = i + 2 < points.length ? points[i + 2] : points[i + 1];

      final cp1 = Offset(
        curr.x + (next.x - prev.x) * tension,
        curr.y + (next.y - prev.y) * tension,
      );

      final cp2 = Offset(
        next.x - (nextNext.x - curr.x) * tension,
        next.y - (nextNext.y - curr.y) * tension,
      );

      controlPoints
        ..add(cp1)
        ..add(cp2);
    }

    return controlPoints;
  }
}
