import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/foundation/data/chart_padding.dart';
import 'package:obers_ui_charts/src/foundation/theme/chart_colors.dart';
import 'package:obers_ui_charts/src/foundation/theme/chart_text_styles.dart';

/// Theme configuration for chart widgets.
///
/// Use [OiChartThemeData.fromContext] inside an [OiApp] widget tree to
/// automatically derive chart theme from the ambient [OiThemeData].
class OiChartThemeData {
  const OiChartThemeData({
    required this.colors,
    required this.textStyles,
    this.gridLineWidth = 0.5,
    this.axisLineWidth = 1,
    this.padding = const OiChartPadding(),
  });

  /// Derives a chart theme from the ambient [OiThemeData] via [context].
  ///
  /// Asserts that an [OiTheme] ancestor exists in the widget tree.
  factory OiChartThemeData.fromContext(BuildContext context) {
    final theme = OiTheme.maybeOf(context);
    assert(
      theme != null,
      'OiChartThemeData.fromContext() requires an OiTheme ancestor. '
      'Wrap your widget tree in OiApp, or pass an explicit theme parameter.',
    );
    if (theme == null) return OiChartThemeData.light();

    return OiChartThemeData(
      colors: OiChartColors.fromColorScheme(theme.colors),
      textStyles: OiChartTextStyles.fromTextTheme(theme.textTheme),
    );
  }

  /// A light theme suitable for light backgrounds.
  factory OiChartThemeData.light() => const OiChartThemeData(
    colors: OiChartColors(
      seriesColors: [
        Color(0xFF4285F4),
        Color(0xFFEA4335),
        Color(0xFFFBBC04),
        Color(0xFF34A853),
        Color(0xFFFF6D01),
        Color(0xFF46BDC6),
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
  factory OiChartThemeData.dark() => const OiChartThemeData(
    colors: OiChartColors(
      seriesColors: [
        Color(0xFF8AB4F8),
        Color(0xFFF28B82),
        Color(0xFFFDD663),
        Color(0xFF81C995),
        Color(0xFFFCAD70),
        Color(0xFF78D9E0),
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
  final OiChartPadding padding;

  OiChartThemeData copyWith({
    OiChartColors? colors,
    OiChartTextStyles? textStyles,
    double? gridLineWidth,
    double? axisLineWidth,
    OiChartPadding? padding,
  }) => OiChartThemeData(
    colors: colors ?? this.colors,
    textStyles: textStyles ?? this.textStyles,
    gridLineWidth: gridLineWidth ?? this.gridLineWidth,
    axisLineWidth: axisLineWidth ?? this.axisLineWidth,
    padding: padding ?? this.padding,
  );
}
