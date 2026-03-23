import 'dart:ui';

import 'package:flutter/foundation.dart';

/// A single data point in a chart series.
@immutable
class OiDataPoint {
  const OiDataPoint({required this.x, required this.y, this.label});

  final double x;
  final double y;
  final String? label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiDataPoint &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          label == other.label;

  @override
  int get hashCode => Object.hash(x, y, label);

  @override
  String toString() => 'OiDataPoint(x: $x, y: $y, label: $label)';
}

/// A named series of data points with an optional color override.
@immutable
class OiChartSeries {
  const OiChartSeries({
    required this.name,
    required this.dataPoints,
    this.color,
  });

  final String name;
  final List<OiDataPoint> dataPoints;
  final Color? color;

  /// Returns `true` if this series contains at least one data point.
  bool get isValid => dataPoints.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiChartSeries &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          _listEquals(dataPoints, other.dataPoints) &&
          color == other.color;

  @override
  int get hashCode => Object.hash(name, Object.hashAll(dataPoints), color);

  static bool _listEquals(List<OiDataPoint> a, List<OiDataPoint> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Computed axis bounds for chart data.
@immutable
class OiChartBounds {
  const OiChartBounds({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  });

  /// Bounds representing a default empty range (0→1).
  static const empty = OiChartBounds(minX: 0, maxX: 1, minY: 0, maxY: 1);

  final double minX;
  final double maxX;
  final double minY;
  final double maxY;

  double get xRange {
    final range = maxX - minX;
    return range == 0 ? 1 : range;
  }

  double get yRange {
    final range = maxY - minY;
    return range == 0 ? 1 : range;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiChartBounds &&
          runtimeType == other.runtimeType &&
          minX == other.minX &&
          maxX == other.maxX &&
          minY == other.minY &&
          maxY == other.maxY;

  @override
  int get hashCode => Object.hash(minX, maxX, minY, maxY);

  @override
  String toString() =>
      'OiChartBounds(minX: $minX, maxX: $maxX, minY: $minY, maxY: $maxY)';
}

/// Container for one or more chart series with computed bounds.
class OiChartData {
  const OiChartData({required this.series});

  /// Creates an empty chart data instance.
  static const empty = OiChartData(series: []);

  final List<OiChartSeries> series;

  /// Creates an atomic chart data instance from a single series.
  ///
  /// Useful for simple charts that only display one data series.
  factory OiChartData.atom({
    required String name,
    required List<OiDataPoint> dataPoints,
    Color? color,
  }) =>
      OiChartData(
        series: [
          OiChartSeries(name: name, dataPoints: dataPoints, color: color),
        ],
      );

  /// Whether there is any data to render.
  bool get isEmpty =>
      series.isEmpty || series.every((s) => s.dataPoints.isEmpty);

  /// Returns the list of series names.
  List<String> get names => series.map((s) => s.name).toList();

  /// Computes the min/max bounds across all series.
  OiChartBounds get bounds {
    if (isEmpty) return OiChartBounds.empty;

    var minX = double.infinity;
    var maxX = double.negativeInfinity;
    var minY = double.infinity;
    var maxY = double.negativeInfinity;

    for (final s in series) {
      for (final p in s.dataPoints) {
        if (p.x < minX) minX = p.x;
        if (p.x > maxX) maxX = p.x;
        if (p.y < minY) minY = p.y;
        if (p.y > maxY) maxY = p.y;
      }
    }

    // Guard against single-point or all-same-value scenarios.
    if (minX == maxX) {
      minX -= 0.5;
      maxX += 0.5;
    }
    if (minY == maxY) {
      minY -= 0.5;
      maxY += 0.5;
    }

    return OiChartBounds(minX: minX, maxX: maxX, minY: minY, maxY: maxY);
  }

  /// Total number of data points across all series.
  int get totalPoints => series.fold(0, (sum, s) => sum + s.dataPoints.length);
}
