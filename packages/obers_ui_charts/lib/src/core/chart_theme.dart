import 'package:flutter/painting.dart';
import 'package:obers_ui_charts/src/core/chart_colors.dart';
import 'package:obers_ui_charts/src/core/chart_text_styles.dart';

/// Theme configuration for chart widgets.
class OiChartTheme {
  const OiChartTheme({
    required this.colors,
    required this.textStyles,
    required this.gridLineWidth,
    required this.axisLineWidth,
  });

  /// A light theme suitable for light backgrounds.
  factory OiChartTheme.light() => const OiChartTheme(
    colors: OiChartColors(
      seriesColors: [
        Color(0xFF4285F4), // blue
        Color(0xFFEA4335), // red
        Color(0xFFFBBC04), // yellow
        Color(0xFF34A853), // green
        Color(0xFFFF6D01), // orange
        Color(0xFF46BDC6), // teal
      ],
      gridColor: Color(0xFFE0E0E0),
      axisColor: Color(0xFF757575),
      backgroundColor: Color(0xFFFFFFFF),
    ),
    textStyles: OiChartTextStyles(
      axisLabel: TextStyle(color: Color(0xFF757575), fontSize: 11),
      tooltipLabel: TextStyle(
        color: Color(0xFF212121),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      legendLabel: TextStyle(color: Color(0xFF424242), fontSize: 12),
    ),
    gridLineWidth: 0.5,
    axisLineWidth: 1,
  );

  /// A dark theme suitable for dark backgrounds.
  factory OiChartTheme.dark() => const OiChartTheme(
    colors: OiChartColors(
      seriesColors: [
        Color(0xFF8AB4F8), // light blue
        Color(0xFFF28B82), // light red
        Color(0xFFFDD663), // light yellow
        Color(0xFF81C995), // light green
        Color(0xFFFCAD70), // light orange
        Color(0xFF78D9E0), // light teal
      ],
      gridColor: Color(0xFF424242),
      axisColor: Color(0xFF9E9E9E),
      backgroundColor: Color(0xFF121212),
    ),
    textStyles: OiChartTextStyles(
      axisLabel: TextStyle(color: Color(0xFF9E9E9E), fontSize: 11),
      tooltipLabel: TextStyle(
        color: Color(0xFFE0E0E0),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      legendLabel: TextStyle(color: Color(0xFFBDBDBD), fontSize: 12),
    ),
    gridLineWidth: 0.5,
    axisLineWidth: 1,
  );

  final OiChartColors colors;
  final OiChartTextStyles textStyles;
  final double gridLineWidth;
  final double axisLineWidth;

  OiChartTheme copyWith({
    OiChartColors? colors,
    OiChartTextStyles? textStyles,
    double? gridLineWidth,
    double? axisLineWidth,
  }) => OiChartTheme(
    colors: colors ?? this.colors,
    textStyles: textStyles ?? this.textStyles,
    gridLineWidth: gridLineWidth ?? this.gridLineWidth,
    axisLineWidth: axisLineWidth ?? this.axisLineWidth,
  );
}
