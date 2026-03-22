import 'package:obers_ui/src/composites/visualization/oi_line_chart/oi_line_chart_data.dart';

/// Accessibility helpers for [OiLineChart].
///
/// {@category Composites}
abstract final class OiLineChartAccessibility {
  /// Generates a summary description of the chart data for screen readers.
  static String generateSummary(List<OiLineSeries> series) {
    if (series.isEmpty) return 'Empty line chart.';

    final totalPoints =
        series.fold<int>(0, (sum, s) => sum + s.points.length);
    final seriesNames = series.map((s) => s.label).join(', ');
    final hasArea = series.any((s) => s.fill);

    final type = hasArea ? 'area' : 'line';

    if (series.length == 1) {
      return 'Line chart: ${series.first.label} with $totalPoints data points.';
    }

    return '${series.length}-series $type chart ($seriesNames) '
        'with $totalPoints total data points.';
  }

  /// Describes a single data point for live-region narration.
  static String describePoint(OiLinePoint point, String seriesName) {
    final label = point.label != null ? ' "${point.label}"' : '';
    return '$seriesName$label: x=${point.x}, y=${point.y}';
  }
}
