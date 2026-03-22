import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

import 'package:obers_ui/src/composites/visualization/oi_bubble_chart/oi_bubble_chart_data.dart';

/// Styling for the size legend component.
///
/// {@category Composites}
class OiBubbleSizeLegendStyle {
  /// Creates an [OiBubbleSizeLegendStyle].
  const OiBubbleSizeLegendStyle({this.borderColor, this.labelStyle});

  /// The border color for size legend circles.
  final Color? borderColor;

  /// The text style for size legend labels.
  final TextStyle? labelStyle;
}

/// Theme configuration for [OiBubbleChart].
///
/// Controls series colors, size legend styling, and provides the
/// cascade resolution logic for determining the final color of any
/// individual bubble.
///
/// {@category Composites}
class OiBubbleChartTheme {
  /// Creates an [OiBubbleChartTheme].
  const OiBubbleChartTheme({
    this.seriesColors,
    this.sizeLegendStyle,
    this.defaultOpacity,
    this.defaultBorderWidth,
  });

  /// Override colors for series. When null, the chart palette from
  /// the context theme is used.
  final List<Color>? seriesColors;

  /// Styling for the size legend.
  final OiBubbleSizeLegendStyle? sizeLegendStyle;

  /// Default bubble fill opacity. Defaults to 0.7.
  final double? defaultOpacity;

  /// Default bubble border stroke width. Defaults to 1.5.
  final double? defaultBorderWidth;

  /// Resolves the final color for a bubble, following the cascade:
  /// point style → series style → chart theme → context theme palette.
  static Color resolveColor(
    int seriesIndex,
    OiBubbleSeriesStyle? seriesStyle,
    OiBubblePointStyle? pointStyle,
    BuildContext context, {
    OiBubbleChartTheme? chartTheme,
  }) {
    // Point-level override wins.
    if (pointStyle?.color != null) return pointStyle!.color!;

    // Series-level override is next.
    if (seriesStyle?.color != null) return seriesStyle!.color!;

    // Chart theme override.
    if (chartTheme?.seriesColors != null &&
        chartTheme!.seriesColors!.isNotEmpty) {
      return chartTheme.seriesColors![
          seriesIndex % chartTheme.seriesColors!.length];
    }

    // Fall back to context theme palette.
    final palette = context.colors.chart;
    return palette[seriesIndex % palette.length];
  }

  /// Resolves the opacity for a bubble.
  static double resolveOpacity(
    OiBubbleSeriesStyle? seriesStyle,
    OiBubblePointStyle? pointStyle, {
    OiBubbleChartTheme? chartTheme,
  }) {
    if (pointStyle?.opacity != null) return pointStyle!.opacity!;
    if (seriesStyle?.opacity != null) return seriesStyle!.opacity!;
    return chartTheme?.defaultOpacity ?? 0.7;
  }

  /// Resolves the border width for a bubble.
  static double resolveBorderWidth(
    OiBubbleSeriesStyle? seriesStyle, {
    OiBubbleChartTheme? chartTheme,
  }) {
    if (seriesStyle?.borderWidth != null) return seriesStyle!.borderWidth!;
    return chartTheme?.defaultBorderWidth ?? 1.5;
  }
}
