import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/composites/oi_bar_chart/oi_bar_chart.dart'
    show OiBarChart;

/// Theme overrides for an [OiBarChart].
///
/// {@category Composites}
class OiBarChartTheme {
  /// Creates an [OiBarChartTheme].
  const OiBarChartTheme({
    this.seriesColors,
    this.gridColor,
    this.axisLabelColor,
    this.barRadius,
  });

  /// Override colors for series.
  final List<Color>? seriesColors;

  /// Override color for grid lines.
  final Color? gridColor;

  /// Override color for axis labels.
  final Color? axisLabelColor;

  /// Override bar corner radius.
  final double? barRadius;

  /// Resolves the color for a series at [seriesIndex] following the cascade:
  /// `seriesColor` → `chartTheme.seriesColors` → context chart palette.
  static Color resolveColor(
    int seriesIndex,
    Color? seriesColor,
    BuildContext context, {
    OiBarChartTheme? chartTheme,
  }) {
    if (seriesColor != null) return seriesColor;
    final themeColors = chartTheme?.seriesColors;
    if (themeColors != null && themeColors.isNotEmpty) {
      return themeColors[seriesIndex % themeColors.length];
    }
    final palette = context.colors.chart;
    return palette[seriesIndex % palette.length];
  }
}
