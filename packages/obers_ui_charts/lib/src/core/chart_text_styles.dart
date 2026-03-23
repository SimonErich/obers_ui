import 'package:flutter/painting.dart';

/// Text styles used in chart labels.
class OiChartTextStyles {
  const OiChartTextStyles({
    required this.axisLabel,
    required this.tooltipLabel,
    required this.legendLabel,
  });

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
