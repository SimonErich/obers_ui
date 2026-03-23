import 'dart:ui';

import 'package:obers_ui_charts/src/core/chart_data.dart';
import 'package:obers_ui_charts/src/core/chart_hit_result.dart';
import 'package:obers_ui_charts/src/core/chart_padding.dart';

/// Handles gesture hit-testing against chart data.
///
/// Uses pixel distance to find the nearest data point to a tap position.
class OiChartGestureHandler {
  OiChartGestureHandler({
    required this.data,
    required this.bounds,
    this.hitTolerance = 24,
    this.padding = const OiChartPadding(),
  });

  final OiChartData data;
  final OiChartBounds bounds;

  /// Maximum pixel distance for a tap to register as a hit.
  final double hitTolerance;

  final OiChartPadding padding;

  /// Tests whether [position] is close enough to any data point.
  ///
  /// Returns the nearest [OiChartHitResult] within [hitTolerance], or `null`.
  OiChartHitResult? hitTest(Offset position, Size size) {
    if (data.isEmpty) return null;

    final area = Rect.fromLTRB(
      padding.left,
      padding.top,
      size.width - padding.right,
      size.height - padding.bottom,
    );

    OiChartHitResult? closest;
    var closestDistance = double.infinity;

    for (var si = 0; si < data.series.length; si++) {
      final series = data.series[si];
      for (var pi = 0; pi < series.dataPoints.length; pi++) {
        final point = series.dataPoints[pi];
        final normalizedX = (point.x - bounds.minX) / bounds.xRange;
        final normalizedY = (point.y - bounds.minY) / bounds.yRange;

        final pixelX = area.left + normalizedX * area.width;
        final pixelY = area.bottom - normalizedY * area.height;

        final distance = (position - Offset(pixelX, pixelY)).distance;

        if (distance < closestDistance && distance <= hitTolerance) {
          closestDistance = distance;
          closest = OiChartHitResult(
            seriesIndex: si,
            pointIndex: pi,
            dataPoint: point,
          );
        }
      }
    }

    return closest;
  }
}
