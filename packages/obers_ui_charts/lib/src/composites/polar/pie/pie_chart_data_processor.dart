import 'dart:math' as math;

import 'package:obers_ui_charts/src/composites/polar/oi_polar_data.dart';
import 'package:obers_ui_charts/src/composites/polar/pie/pie_slice.dart';
import 'package:obers_ui_charts/src/foundation/data/chart_data.dart';

/// Pure-Dart processor for pie chart slice computations.
///
/// Supports both [OiPolarData] (preferred) and legacy [OiChartSeries] input.
class OiPieChartDataProcessor {
  const OiPieChartDataProcessor();

  /// Computes pie slices from [OiPolarData].
  List<OiPieSlice> computeSlicesFromPolarData(OiPolarData data) {
    if (data.isEmpty) return [];

    final values = data.segments.map((s) => s.value).toList();
    final labels = data.segments.map((s) => s.label).toList();
    final total = data.total;

    return _computeFromValues(values, labels, total);
  }

  /// Computes pie slices from a single [OiChartSeries] (legacy support).
  ///
  /// Negative values are treated as zero. If all values are zero, returns
  /// equal-sized slices.
  List<OiPieSlice> computeSlices(OiChartSeries series) {
    if (series.dataPoints.isEmpty) return [];

    final values = series.dataPoints.map((p) => math.max(0.0, p.y)).toList();
    final labels = series.dataPoints.map((p) => p.label).toList();
    final total = values.fold<double>(0, (sum, v) => sum + v);

    return _computeFromValues(values, labels, total);
  }

  List<OiPieSlice> _computeFromValues(
    List<double> values,
    List<String?> labels,
    double total,
  ) {
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
          label: labels[i],
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
          value: value,
          percentage: percentage,
          label: labels[i],
        ),
      );

      currentAngle += sweepAngle;
    }

    return slices;
  }
}
