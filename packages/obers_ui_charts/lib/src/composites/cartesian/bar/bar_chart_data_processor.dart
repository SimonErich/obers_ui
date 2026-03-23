import 'dart:ui';

import 'package:obers_ui_charts/src/composites/cartesian/bar/bar_chart_orientation.dart';
import 'package:obers_ui_charts/src/foundation/data/chart_data.dart';
import 'package:obers_ui_charts/src/foundation/data/chart_padding.dart';

/// Pure-Dart processor for bar chart layout computations.
///
/// Computes rectangle positions for grouped bar series.
class OiBarChartDataProcessor {
  const OiBarChartDataProcessor();

  /// Computes bar rectangles for all series within the given [size].
  ///
  /// Returns a list of rect lists, one per series. Each inner list corresponds
  /// to the data points in that series.
  ///
  /// For vertical bars, each bar extends upward from the x-axis.
  /// For horizontal bars, each bar extends rightward from the y-axis.
  List<List<Rect>> computeBarRects(
    OiChartData data,
    Size size, {
    double spacing = 8,
    OiChartPadding padding = const OiChartPadding(),
    OiBarChartOrientation orientation = OiBarChartOrientation.vertical,
  }) {
    if (data.isEmpty) return [];

    final area = Rect.fromLTRB(
      padding.left,
      padding.top,
      size.width - padding.right,
      size.height - padding.bottom,
    );

    final seriesCount = data.series.length;
    // Use the maximum point count across all series.
    final categoryCount = data.series.fold<int>(
      0,
      (max, s) => s.dataPoints.length > max ? s.dataPoints.length : max,
    );

    if (categoryCount == 0) return [];

    final bounds = data.bounds;

    if (orientation == OiBarChartOrientation.vertical) {
      return _computeVerticalRects(
        data,
        area,
        bounds,
        seriesCount,
        categoryCount,
        spacing,
      );
    } else {
      return _computeHorizontalRects(
        data,
        area,
        bounds,
        seriesCount,
        categoryCount,
        spacing,
      );
    }
  }

  List<List<Rect>> _computeVerticalRects(
    OiChartData data,
    Rect area,
    OiChartBounds bounds,
    int seriesCount,
    int categoryCount,
    double spacing,
  ) {
    final totalGroupWidth = area.width / categoryCount;
    final totalSpacing = spacing * (seriesCount + 1);
    final barWidth = (totalGroupWidth - totalSpacing) / seriesCount;
    final clampedBarWidth = barWidth.clamp(1.0, double.infinity);

    final result = <List<Rect>>[];

    for (var si = 0; si < seriesCount; si++) {
      final series = data.series[si];
      final rects = <Rect>[];

      for (var pi = 0; pi < series.dataPoints.length; pi++) {
        final point = series.dataPoints[pi];
        final groupLeft = area.left + pi * totalGroupWidth;
        final barLeft = groupLeft + spacing + si * (clampedBarWidth + spacing);

        final normalizedY = (point.y - bounds.minY) / bounds.yRange;
        final barHeight = normalizedY * area.height;
        final barTop = area.bottom - barHeight;

        rects.add(Rect.fromLTWH(barLeft, barTop, clampedBarWidth, barHeight));
      }

      result.add(rects);
    }

    return result;
  }

  List<List<Rect>> _computeHorizontalRects(
    OiChartData data,
    Rect area,
    OiChartBounds bounds,
    int seriesCount,
    int categoryCount,
    double spacing,
  ) {
    final totalGroupHeight = area.height / categoryCount;
    final totalSpacing = spacing * (seriesCount + 1);
    final barHeight = (totalGroupHeight - totalSpacing) / seriesCount;
    final clampedBarHeight = barHeight.clamp(1.0, double.infinity);

    final result = <List<Rect>>[];

    for (var si = 0; si < seriesCount; si++) {
      final series = data.series[si];
      final rects = <Rect>[];

      for (var pi = 0; pi < series.dataPoints.length; pi++) {
        final point = series.dataPoints[pi];
        final groupTop = area.top + pi * totalGroupHeight;
        final barTop = groupTop + spacing + si * (clampedBarHeight + spacing);

        final normalizedY = (point.y - bounds.minY) / bounds.yRange;
        final barWidth = normalizedY * area.width;

        rects.add(Rect.fromLTWH(area.left, barTop, barWidth, clampedBarHeight));
      }

      result.add(rects);
    }

    return result;
  }
}
