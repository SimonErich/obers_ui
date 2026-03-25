import 'package:obers_ui_charts/src/composites/oi_bar_chart/oi_bar_chart.dart'
    show OiBarChart;
import 'package:obers_ui_charts/src/composites/oi_bar_chart/oi_bar_chart_data.dart';

/// Accessibility helpers for [OiBarChart].
///
/// {@category Composites}
abstract final class OiBarChartAccessibility {
  /// Generates a summary description of the chart data for screen readers.
  static String generateSummary(
    List<OiBarCategory> categories,
    List<OiBarSeries>? series,
  ) {
    if (categories.isEmpty) return 'Empty bar chart.';

    final numSeries = series?.length ?? 1;
    final seriesNames = series?.map((s) => s.label).join(', ');

    if (numSeries == 1) {
      return 'Bar chart with ${categories.length} categories.';
    }

    return '$numSeries-series bar chart ($seriesNames) '
        'with ${categories.length} categories.';
  }

  /// Describes a single bar for live-region narration.
  static String describeBar(
    OiBarCategory category,
    int valueIndex,
    String? seriesName,
  ) {
    final value = valueIndex < category.values.length
        ? category.values[valueIndex]
        : 0;
    final series = seriesName != null ? ' ($seriesName)' : '';
    return '${category.label}$series: $value';
  }
}
