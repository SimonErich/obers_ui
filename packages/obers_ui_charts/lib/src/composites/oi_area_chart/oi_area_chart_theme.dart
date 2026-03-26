import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/composites/oi_area_chart/oi_area_chart.dart'
    show OiAreaChart;

/// Theme overrides for an [OiAreaChart].
///
/// {@category Composites}
class OiAreaChartTheme {
  /// Creates an [OiAreaChartTheme].
  const OiAreaChartTheme({
    this.seriesColors,
    this.gridColor,
    this.axisLabelColor,
  });

  /// Override colors for series. When `null`, the context chart palette is
  /// used.
  final List<Color>? seriesColors;

  /// Override color for grid lines.
  final Color? gridColor;

  /// Override color for axis labels.
  final Color? axisLabelColor;

  /// Resolves the color for a series at [seriesIndex] following the cascade:
  /// `seriesColor` → `chartTheme.seriesColors` → context chart palette.
  static Color resolveColor(
    int seriesIndex,
    Color? seriesColor,
    BuildContext context, {
    OiAreaChartTheme? chartTheme,
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
