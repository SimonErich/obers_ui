import 'package:obers_ui_charts/src/composites/oi_bubble_chart/oi_bubble_chart_data.dart';

/// Accessibility helpers for the bubble chart.
///
/// Generates semantic descriptions for the chart as a whole and for
/// individual focused bubbles.
///
/// {@category Composites}
abstract final class OiBubbleChartAccessibility {
  /// Generates a summary description for the entire chart.
  ///
  /// The summary includes the number of series, the total number of
  /// data points, and explicitly mentions the size dimension so that
  /// screen reader users understand the three-dimensional nature of
  /// the visualization.
  static String generateSummary(OiBubbleChartData data) {
    final totalPoints = data.series.fold<int>(
      0,
      (sum, s) => sum + s.points.length,
    );
    final seriesCount = data.series.length;
    final seriesNames = data.series.map((s) => s.name).join(', ');

    final sizeInfo = data.sizeConfig?.sizeLabel != null
        ? ' Size represents ${data.sizeConfig!.sizeLabel}.'
        : ' Bubbles vary by size dimension.';

    if (seriesCount == 0) {
      return 'Empty bubble chart.';
    }

    return 'Bubble chart with $seriesCount '
        '${seriesCount == 1 ? 'series' : 'series'}: '
        '$seriesNames. '
        '$totalPoints ${totalPoints == 1 ? 'data point' : 'data points'} '
        'plotted by x, y, and size.'
        '$sizeInfo';
  }

  /// Describes a single bubble for screen reader narration when focused.
  ///
  /// Includes the series name and all three dimensions (x, y, size).
  static String describeBubble(OiBubblePoint point, String seriesName) {
    final label = point.label != null ? ' (${point.label})' : '';
    return '$seriesName$label: '
        'x=${_fmt(point.x)}, y=${_fmt(point.y)}, size=${_fmt(point.size)}';
  }

  static String _fmt(double v) {
    return v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
  }
}
