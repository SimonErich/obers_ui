import 'package:flutter/foundation.dart';
import 'package:obers_ui_charts/src/foundation/data/chart_data.dart';

/// Result of a hit test on chart data.
@immutable
class OiChartHitResult {
  const OiChartHitResult({
    required this.seriesIndex,
    required this.pointIndex,
    required this.dataPoint,
  });

  final int seriesIndex;
  final int pointIndex;
  final OiDataPoint dataPoint;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiChartHitResult &&
          runtimeType == other.runtimeType &&
          seriesIndex == other.seriesIndex &&
          pointIndex == other.pointIndex &&
          dataPoint == other.dataPoint;

  @override
  int get hashCode => Object.hash(seriesIndex, pointIndex, dataPoint);

  @override
  String toString() =>
      'OiChartHitResult(series: $seriesIndex, point: $pointIndex, '
      'data: $dataPoint)';
}
