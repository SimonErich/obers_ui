import 'dart:ui';

/// Axis for an annotation line.
enum OiChartAnnotationAxis { x, y }

/// A reference line annotation drawn on a chart axis.
class OiChartAnnotation {
  const OiChartAnnotation({
    required this.value,
    this.axis = OiChartAnnotationAxis.y,
    this.color,
    this.label,
    this.strokeWidth = 1,
  });

  final double value;
  final OiChartAnnotationAxis axis;
  final Color? color;
  final String? label;
  final double strokeWidth;
}
