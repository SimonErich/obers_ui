import 'package:obers_ui_charts/src/composites/oi_area_chart/oi_area_chart.dart'
    show OiAreaChart;
import 'package:obers_ui_charts/src/composites/oi_area_chart/oi_area_chart_data.dart';

/// Accessibility helpers for [OiAreaChart].
///
/// {@category Composites}
abstract final class OiAreaChartAccessibility {
  /// Generates a summary description of the chart data for screen readers.
  static String generateSummary<T>(List<OiAreaSeries<T>> series) {
    if (series.isEmpty) return 'Empty area chart.';

    final seriesNames = series.map((s) => s.label).join(', ');
    final stacked = series.any((s) => s.stackGroup != null);
    final type = stacked ? 'stacked area' : 'area';

    if (series.length == 1) {
      final count = series.first.data?.length ?? 0;
      return 'Area chart: ${series.first.label} with $count data points.';
    }

    final totalPoints = series.fold<int>(
      0,
      (sum, s) => sum + (s.data?.length ?? 0),
    );
    return '${series.length}-series $type chart ($seriesNames) '
        'with $totalPoints total data points.';
  }

  /// Describes a single data point for live-region narration.
  static String describePoint(
    double x,
    double y,
    String seriesLabel, {
    String? pointLabel,
  }) {
    final label = pointLabel != null ? ' "$pointLabel"' : '';
    return '$seriesLabel$label: x=$x, y=$y';
  }
}
