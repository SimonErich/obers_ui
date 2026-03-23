import 'dart:math' as math;

import 'package:obers_ui_charts/src/charts/pie/pie_slice.dart';
import 'package:obers_ui_charts/src/core/chart_data.dart';

/// Pure-Dart processor for pie chart slice computations.
///
/// Uses the Y values from a single series to compute angular slices.
class OiPieChartDataProcessor {
  const OiPieChartDataProcessor();

  /// Computes pie slices from a single [series].
  ///
  /// Negative values are treated as zero. If all values are zero, returns
  /// equal-sized slices.
  List<OiPieSlice> computeSlices(OiChartSeries series) {
    if (series.dataPoints.isEmpty) return [];

    final values = series.dataPoints.map((p) => math.max(0, p.y)).toList();
    final total = values.fold<double>(0, (sum, v) => sum + v);

    // All-zero case: distribute equally.
    if (total == 0) {
      final equalAngle = (2 * math.pi) / values.length;
      final equalPercentage = 100.0 / values.length;
      var currentAngle = -math.pi / 2; // Start at 12 o'clock.

      return List.generate(values.length, (i) {
        final slice = OiPieSlice(
          startAngle: currentAngle,
          sweepAngle: equalAngle,
          value: 0,
          percentage: equalPercentage,
          label: series.dataPoints[i].label,
        );
        currentAngle += equalAngle;
        return slice;
      });
    }

    final slices = <OiPieSlice>[];
    var currentAngle = -math.pi / 2; // Start at 12 o'clock.

    for (var i = 0; i < values.length; i++) {
      final value = values[i];
      final percentage = (value / total) * 100;
      final sweepAngle = (value / total) * 2 * math.pi;

      slices.add(
        OiPieSlice(
          startAngle: currentAngle,
          sweepAngle: sweepAngle,
          value: value.toDouble(),
          percentage: percentage,
          label: series.dataPoints[i].label,
        ),
      );

      currentAngle += sweepAngle;
    }

    return slices;
  }
}
