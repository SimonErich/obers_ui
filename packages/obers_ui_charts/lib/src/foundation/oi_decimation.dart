import 'dart:math' as math;

/// Decimation strategy used by the chart performance system.
///
/// {@category Foundation}
enum OiDecimationStrategy {
  /// No decimation — all points are rendered.
  none,

  /// Min-max bucketing: preserves extremes in each bucket.
  minMax,

  /// Largest Triangle Three Buckets: preserves visually significant points.
  lttb,
}

/// Decimates [points] using min-max bucketing to at most [targetCount] points.
///
/// Each bucket retains the minimum and maximum y-value points, preserving the
/// visual envelope of the data. Returns the original list if it already fits
/// within [targetCount].
List<math.Point<double>> decimateMinMax(
  List<math.Point<double>> points, {
  required int targetCount,
}) {
  if (points.length <= targetCount) return points;
  if (points.isEmpty) return points;

  // Each bucket produces 2 points (min + max), so we need targetCount/2 buckets
  final bucketCount = targetCount ~/ 2;
  if (bucketCount == 0) return [points.first];

  final bucketSize = points.length / bucketCount;
  final result = <math.Point<double>>[];

  for (var i = 0; i < bucketCount; i++) {
    final start = (i * bucketSize).floor();
    final end = ((i + 1) * bucketSize).floor().clamp(start + 1, points.length);

    var minPoint = points[start];
    var maxPoint = points[start];

    for (var j = start; j < end; j++) {
      if (points[j].y < minPoint.y) minPoint = points[j];
      if (points[j].y > maxPoint.y) maxPoint = points[j];
    }

    // Add in x-order to preserve temporal ordering
    if (minPoint.x <= maxPoint.x) {
      result.add(minPoint);
      if (minPoint != maxPoint) result.add(maxPoint);
    } else {
      result.add(maxPoint);
      if (minPoint != maxPoint) result.add(minPoint);
    }
  }

  return result;
}

/// Decimates [points] using the Largest Triangle Three Buckets (LTTB) algorithm
/// to exactly [targetCount] points.
///
/// LTTB selects the point in each bucket that forms the largest triangle area
/// with the selected points in adjacent buckets, preserving the most visually
/// significant features of the data.
///
/// See: Sveinn Steinarsson, "Downsampling Time Series for Visual
/// Representation" (2013).
List<math.Point<double>> decimateLttb(
  List<math.Point<double>> points, {
  required int targetCount,
}) {
  if (points.length <= targetCount) return List.of(points);
  if (targetCount <= 2) {
    if (points.isEmpty) return [];
    if (targetCount == 1) return [points.first];
    return [points.first, points.last];
  }

  final result = <math.Point<double>>[points.first];
  final bucketSize = (points.length - 2) / (targetCount - 2);

  var previousIndex = 0;

  for (var i = 0; i < targetCount - 2; i++) {
    final bucketStart = ((i + 1) * bucketSize + 1).floor();
    final bucketEnd = ((i + 2) * bucketSize + 1).floor().clamp(
      bucketStart,
      points.length,
    );

    // Calculate the average point for the next bucket
    final nextBucketStart = ((i + 2) * bucketSize + 1).floor().clamp(
      0,
      points.length,
    );
    final nextBucketEnd = ((i + 3) * bucketSize + 1).floor().clamp(
      nextBucketStart,
      points.length,
    );

    var avgX = 0.0;
    var avgY = 0.0;
    final avgCount = nextBucketEnd - nextBucketStart;

    if (avgCount > 0) {
      for (var j = nextBucketStart; j < nextBucketEnd; j++) {
        avgX += points[j].x;
        avgY += points[j].y;
      }
      avgX /= avgCount;
      avgY /= avgCount;
    }

    // Find the point in the current bucket that maximizes triangle area
    var maxArea = -1.0;
    var maxIndex = bucketStart;
    final prevPoint = points[previousIndex];

    for (var j = bucketStart; j < bucketEnd; j++) {
      final area =
          ((prevPoint.x - avgX) * (points[j].y - prevPoint.y) -
                  (prevPoint.x - points[j].x) * (avgY - prevPoint.y))
              .abs() *
          0.5;

      if (area > maxArea) {
        maxArea = area;
        maxIndex = j;
      }
    }

    result.add(points[maxIndex]);
    previousIndex = maxIndex;
  }

  result.add(points.last);
  return result;
}

/// Selects the appropriate decimation strategy based on data density.
///
/// Returns [OiDecimationStrategy.none] if the point density is low enough
/// that all points can be rendered. Returns [OiDecimationStrategy.lttb] for
/// high-density data (default threshold: 2 points per pixel).
OiDecimationStrategy selectDecimationStrategy({
  required int pointCount,
  required double pixelWidth,
  double densityThreshold = 2.0,
}) {
  if (pixelWidth <= 0 || pointCount <= 0) return OiDecimationStrategy.none;

  final density = pointCount / pixelWidth;
  if (density <= densityThreshold) return OiDecimationStrategy.none;

  return OiDecimationStrategy.lttb;
}
