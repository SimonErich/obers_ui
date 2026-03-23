import 'dart:ui';

/// A shaded threshold band drawn between two values on a chart axis.
class OiChartThresholdBand {
  const OiChartThresholdBand({
    required this.min,
    required this.max,
    this.color,
    this.label,
  });

  final double min;
  final double max;
  final Color? color;
  final String? label;
}
