import 'package:flutter/painting.dart';

/// Color palette for chart rendering.
class OiChartColors {
  const OiChartColors({
    required this.seriesColors,
    required this.gridColor,
    required this.axisColor,
    required this.backgroundColor,
  });

  final List<Color> seriesColors;
  final Color gridColor;
  final Color axisColor;
  final Color backgroundColor;

  /// Returns the color for a given series index, cycling through available
  /// colors.
  Color colorForSeries(int index) => seriesColors[index % seriesColors.length];

  OiChartColors copyWith({
    List<Color>? seriesColors,
    Color? gridColor,
    Color? axisColor,
    Color? backgroundColor,
  }) => OiChartColors(
    seriesColors: seriesColors ?? this.seriesColors,
    gridColor: gridColor ?? this.gridColor,
    axisColor: axisColor ?? this.axisColor,
    backgroundColor: backgroundColor ?? this.backgroundColor,
  );
}
