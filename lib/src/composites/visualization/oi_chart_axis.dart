/// Configuration for a chart axis (x or y).
///
/// Used by Cartesian charts ([OiLineChart], [OiBarChart], [OiScatterPlot])
/// to configure axis labels, grid divisions, and value formatting.
///
/// {@category Composites}
class OiChartAxis {
  /// Creates an [OiChartAxis].
  const OiChartAxis({
    this.label,
    this.labels,
    this.format,
    this.divisions,
    this.min,
    this.max,
  });

  /// An optional axis title displayed beside the axis.
  final String? label;

  /// Fixed tick labels. When provided, these are displayed instead of
  /// auto-generated numeric labels.
  final List<String>? labels;

  /// A formatter for numeric tick values. When null, values are formatted
  /// using [double.toStringAsFixed] with appropriate precision.
  final String Function(double)? format;

  /// The number of grid divisions along this axis. Defaults vary by chart.
  final int? divisions;

  /// The minimum value for the axis range. When null, determined from data.
  final double? min;

  /// The maximum value for the axis range. When null, determined from data.
  final double? max;

  /// Formats a [value] using [format] or a sensible default.
  String formatValue(double value) {
    if (format != null) return format!(value);
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }
}
