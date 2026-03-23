/// Configuration for a chart axis (X or Y).
class OiChartAxisConfig {
  const OiChartAxisConfig({
    this.label,
    this.tickLabels,
    this.formatValue,
    this.divisions = 5,
    this.min,
    this.max,
  });

  /// Optional axis title label.
  final String? label;

  /// Explicit tick labels (overrides numeric formatting).
  final List<String>? tickLabels;

  /// Custom formatter for numeric tick values.
  final String Function(double)? formatValue;

  /// Number of tick divisions.
  final int divisions;

  /// Optional axis minimum override.
  final double? min;

  /// Optional axis maximum override.
  final double? max;

  /// Formats a [value] using the custom formatter or default formatting.
  String format(double value) {
    if (formatValue != null) return formatValue!(value);
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }
}
