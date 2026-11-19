import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:obers_ui_charts/src/composites/oi_line_chart/oi_line_chart_data.dart'
    show OiLinePoint;

/// The data range covered by a set of line series.
typedef OiLineChartRange = ({
  double minX,
  double maxX,
  double minY,
  double maxY,
});

/// Pixel positions of one line series inside the chart area.
///
/// [points] and [baselines] are parallel to the series' data points. An
/// entry is `null` when the data point has a non-finite coordinate and
/// therefore cannot be drawn or hit.
class OiLineSeriesLayout {
  /// Creates an [OiLineSeriesLayout].
  const OiLineSeriesLayout({required this.points, required this.baselines});

  /// Where each data point is drawn. In stacked mode this includes the
  /// cumulative offset of the series below.
  final List<Offset?> points;

  /// Where the fill below each data point ends: the top of the series
  /// below in stacked mode, otherwise the bottom of the chart area.
  final List<Offset?> baselines;
}

bool _isDrawable(OiLinePoint point) => point.x.isFinite && point.y.isFinite;

/// Computes the data range of [series], ignoring non-finite points.
///
/// In [stacked] mode the y range spans from zero to the highest cumulative
/// value. Falls back to `0..1` on an axis without any finite value.
OiLineChartRange computeLineChartRange(
  List<List<OiLinePoint>> series, {
  required bool stacked,
}) {
  var minX = double.infinity;
  var maxX = double.negativeInfinity;
  var minY = double.infinity;
  var maxY = double.negativeInfinity;

  final totals = <double, double>{};
  for (final points in series) {
    for (final p in points) {
      if (!_isDrawable(p)) continue;
      minX = math.min(minX, p.x);
      maxX = math.max(maxX, p.x);
      if (stacked) {
        final total = (totals[p.x] ?? 0) + p.y;
        totals[p.x] = total;
      } else {
        minY = math.min(minY, p.y);
        maxY = math.max(maxY, p.y);
      }
    }
  }
  if (stacked && totals.isNotEmpty) {
    minY = 0;
    maxY = totals.values.reduce(math.max);
  }

  if (minX > maxX) {
    minX = 0;
    maxX = 1;
  }
  if (minY > maxY) {
    minY = 0;
    maxY = 1;
  }
  return (minX: minX, maxX: maxX, minY: minY, maxY: maxY);
}

/// Maps every data point of [series] to its pixel position in [chartRect].
///
/// This is the single source of truth for where a point is: the painter
/// draws from it and the chart hit-tests against it, so the two cannot
/// disagree (for example about stack offsets).
List<OiLineSeriesLayout> layoutLineSeries(
  List<List<OiLinePoint>> series, {
  required Rect chartRect,
  required double minX,
  required double maxX,
  required double minY,
  required double maxY,
  required bool stacked,
}) {
  final rangeX = maxX - minX == 0 ? 1.0 : maxX - minX;
  final rangeY = maxY - minY == 0 ? 1.0 : maxY - minY;

  Offset map(double x, double y) => Offset(
    chartRect.left + chartRect.width * (x - minX) / rangeX,
    chartRect.bottom - chartRect.height * (y - minY) / rangeY,
  );

  // Cumulative y per x value, used in stacked mode.
  final stackOffsets = <double, double>{};
  final layouts = <OiLineSeriesLayout>[];

  for (final points in series) {
    final mapped = <Offset?>[];
    final baselines = <Offset?>[];
    for (final p in points) {
      if (!_isDrawable(p)) {
        mapped.add(null);
        baselines.add(null);
      } else if (stacked) {
        final base = stackOffsets[p.x] ?? 0;
        final top = base + p.y;
        stackOffsets[p.x] = top;
        mapped.add(map(p.x, top));
        baselines.add(map(p.x, base));
      } else {
        final position = map(p.x, p.y);
        mapped.add(position);
        baselines.add(Offset(position.dx, chartRect.bottom));
      }
    }
    layouts.add(OiLineSeriesLayout(points: mapped, baselines: baselines));
  }
  return layouts;
}

/// Finds the data point drawn nearest to [position] within [hitRadius].
///
/// Returns `null` when no point is close enough. On a tie the earlier
/// series wins.
({int seriesIndex, int pointIndex})? findNearestLinePoint(
  Offset position,
  List<OiLineSeriesLayout> layouts, {
  double hitRadius = 20,
}) {
  var bestDist = double.infinity;
  ({int seriesIndex, int pointIndex})? best;

  for (var si = 0; si < layouts.length; si++) {
    final points = layouts[si].points;
    for (var pi = 0; pi < points.length; pi++) {
      final point = points[pi];
      if (point == null) continue;
      final dist = (point - position).distance;
      if (dist < hitRadius && dist < bestDist) {
        bestDist = dist;
        best = (seriesIndex: si, pointIndex: pi);
      }
    }
  }
  return best;
}
