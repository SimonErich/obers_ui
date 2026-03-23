import 'package:flutter/painting.dart';
import 'package:obers_ui/obers_ui.dart';

/// Text styles used in chart labels.
class OiChartTextStyles {
  const OiChartTextStyles({
    required this.axisLabel,
    required this.tooltipLabel,
    required this.legendLabel,
  });

  /// Creates chart text styles derived from an [OiTextTheme].
  factory OiChartTextStyles.fromTextTheme(OiTextTheme textTheme) =>
      OiChartTextStyles(
        axisLabel: textTheme.styleFor(OiLabelVariant.tiny),
        tooltipLabel: textTheme
            .styleFor(OiLabelVariant.small)
            .copyWith(fontWeight: FontWeight.w500),
        legendLabel: textTheme.styleFor(OiLabelVariant.small),
      );

  final TextStyle axisLabel;
  final TextStyle tooltipLabel;
  final TextStyle legendLabel;

  OiChartTextStyles copyWith({
    TextStyle? axisLabel,
    TextStyle? tooltipLabel,
    TextStyle? legendLabel,
  }) => OiChartTextStyles(
    axisLabel: axisLabel ?? this.axisLabel,
    tooltipLabel: tooltipLabel ?? this.tooltipLabel,
    legendLabel: legendLabel ?? this.legendLabel,
  );
}
