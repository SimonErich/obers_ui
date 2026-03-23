import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

/// Static helpers for chart accessibility semantics.
class OiChartA11y {
  OiChartA11y._();

  /// Generates a semantic description for a chart.
  static String describeChart(
    String chartType,
    int seriesCount,
    int totalPoints,
  ) {
    final seriesDesc =
        seriesCount == 1 ? '1 series' : '$seriesCount series';
    final pointDesc =
        totalPoints == 1 ? '1 data point' : '$totalPoints data points';
    return '$chartType with $seriesDesc and $pointDesc';
  }

  /// Generates a semantic description for a single data point.
  static String describeDataPoint(
    String seriesName,
    double x,
    double y, {
    String? label,
  }) {
    final buffer = StringBuffer('$seriesName: ');
    if (label != null) {
      buffer.write('$label, ');
    }
    buffer.write('x=${_format(x)}, y=${_format(y)}');
    return buffer.toString();
  }

  /// Announces a selection change via semantics.
  static void announceSelection(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  static String _format(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }
}
