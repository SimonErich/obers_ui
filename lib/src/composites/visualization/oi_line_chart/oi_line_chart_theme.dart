import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// Theme overrides for an [OiLineChart].
///
/// {@category Composites}
class OiLineChartTheme {
  /// Creates an [OiLineChartTheme].
  const OiLineChartTheme({
    this.seriesColors,
    this.gridColor,
    this.axisLabelColor,
  });

  /// Override colors for series. When null, the context chart palette is used.
  final List<Color>? seriesColors;

  /// Override color for grid lines.
  final Color? gridColor;

  /// Override color for axis labels.
  final Color? axisLabelColor;

  /// Resolves the color for a series at [seriesIndex] following the cascade:
  /// [seriesColor] → [chartTheme.seriesColors] → context chart palette.
  static Color resolveColor(
    int seriesIndex,
    Color? seriesColor,
    BuildContext context, {
    OiLineChartTheme? chartTheme,
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
