import 'dart:math' as math;
import 'dart:ui' show Offset, Rect;

import 'package:flutter/foundation.dart';

import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_hit_tester.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_viewport.dart';

/// A spatial point for hit testing, representing a data point's screen
/// position and its data reference.
///
/// {@category Foundation}
@immutable
class OiHitPoint {
  /// Creates an [OiHitPoint].
  const OiHitPoint({
    required this.position,
    required this.ref,
    this.radius = 0,
  });

  /// The widget-local position of this point's visual center.
  final Offset position;

  /// The data reference identifying the series and data index.
  final OiChartDataRef ref;

  /// Optional visual radius of the data mark (used for hit area expansion).
  final double radius;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiHitPoint &&
          other.position == position &&
          other.ref == ref &&
          other.radius == radius;

  @override
  int get hashCode => Object.hash(position, ref, radius);

  @override
  String toString() => 'OiHitPoint(pos: $position, ref: $ref, r: $radius)';
}

/// Strategy for resolving hit test conflicts when multiple series have
/// points at similar distances.
///
/// {@category Foundation}
enum OiHitTestPreference {
  /// Return the nearest point regardless of series.
  nearest,

  /// Prefer the foremost (highest series index) series when points are
  /// within the tolerance threshold of each other.
  foremost,

  /// Prefer the series closest to the query's y-coordinate, useful for
  /// line charts where vertical proximity is more meaningful.
  verticalNearest,
}

/// Configuration for the hit test system.
///
/// {@category Foundation}
@immutable
class OiHitTestConfig {
  /// Creates an [OiHitTestConfig].
  const OiHitTestConfig({
    this.tolerance = 16.0,
    this.preference = OiHitTestPreference.nearest,
    this.bucketWidth = 0,
    this.includeRadius = true,
  });

  /// Maximum distance in logical pixels for a hit to register.
  final double tolerance;

  /// How to resolve conflicts between equidistant points from
  /// different series.
  final OiHitTestPreference preference;

  /// Width of x-buckets for spatial indexing. When 0, the bucket
  /// width is auto-computed from the tolerance.
  final double bucketWidth;

  /// Whether to expand the hit area by the point's visual [OiHitPoint.radius].
  final bool includeRadius;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiHitTestConfig &&
          other.tolerance == tolerance &&
          other.preference == preference &&
          other.bucketWidth == bucketWidth &&
          other.includeRadius == includeRadius;

  @override
  int get hashCode =>
      Object.hash(tolerance, preference, bucketWidth, includeRadius);
}

/// An efficient spatial lookup system for chart data points.
///
/// [OiChartHitTestIndex] uses x-bucket indexing for O(1) average-case
/// lookup on ordered domains, falling back to binary search for
/// precise nearest-point resolution. It supports viewport-filtered
/// point sets, configurable tolerance, and series-aware preference
/// rules.
///
/// ## Usage
///
/// ```dart
/// final index = OiChartHitTestIndex(
///   config: const OiHitTestConfig(tolerance: 20),
/// );
///
/// // Build the index from screen-projected points.
/// index.build(points, viewport: viewport);
///
/// // Query — O(1) average for ordered domains.
/// final result = index.hitTest(pointerPosition);
/// ```
///
/// {@category Foundation}
class OiChartHitTestIndex implements OiChartHitTester {
  /// Creates an [OiChartHitTestIndex].
  OiChartHitTestIndex({this.config = const OiHitTestConfig()});

  /// The hit test configuration.
  final OiHitTestConfig config;

  /// The raw points currently indexed.
  List<OiHitPoint> _points = const [];

  /// The x-bucket index. Each bucket holds indices into [_points].
  List<List<int>> _buckets = const [];

  /// The bucket width in logical pixels.
  double _bucketWidth = 0;

  /// The minimum x-coordinate of the indexed range.
  double _minX = 0;

  /// The viewport used to filter points.
  Rect _plotBounds = Rect.zero;

  /// Whether the index is sorted by x-coordinate (ordered domain).
  bool _isXOrdered = false;

  /// Returns the number of indexed points.
  int get pointCount => _points.length;

  /// Returns the current bucket count.
  int get bucketCount => _buckets.length;

  /// Builds the spatial index from the given [points].
  ///
  /// Points outside the [viewport]'s plot bounds (expanded by
  /// [OiHitTestConfig.tolerance]) are excluded.
  ///
  /// The method detects whether the domain is x-ordered and selects
  /// the optimal indexing strategy accordingly.
  void build(List<OiHitPoint> points, {required OiChartViewport viewport}) {
    _plotBounds = viewport.plotBounds;

    // Filter to viewport-visible points (with tolerance margin).
    final margin = config.tolerance;
    final filterRect = _plotBounds.inflate(margin);

    final filtered = <OiHitPoint>[];
    for (final p in points) {
      if (filterRect.contains(p.position)) {
        filtered.add(p);
      }
    }

    _points = filtered;
    if (_points.isEmpty) {
      _buckets = const [];
      _bucketWidth = 0;
      _isXOrdered = false;
      return;
    }

    // Detect x-ordering.
    _isXOrdered = _detectXOrdering(_points);

    // If x-ordered, sort by x for binary search support.
    if (_isXOrdered) {
      _points = List<OiHitPoint>.of(_points)
        ..sort((a, b) => a.position.dx.compareTo(b.position.dx));
    }

    // Build x-bucket index.
    _buildBuckets();
  }

  void _buildBuckets() {
    if (_points.isEmpty) return;

    var minX = double.infinity;
    var maxX = double.negativeInfinity;
    for (final p in _points) {
      if (p.position.dx < minX) minX = p.position.dx;
      if (p.position.dx > maxX) maxX = p.position.dx;
    }
    _minX = minX;

    final range = maxX - minX;
    _bucketWidth = config.bucketWidth > 0
        ? config.bucketWidth
        : math.max(config.tolerance, 1);

    final numBuckets = range <= 0 ? 1 : (range / _bucketWidth).ceil() + 1;
    _buckets = List.generate(numBuckets, (_) => <int>[]);

    for (var i = 0; i < _points.length; i++) {
      final bucketIndex = _bucketIndex(_points[i].position.dx);
      _buckets[bucketIndex].add(i);
    }
  }

  int _bucketIndex(double x) {
    if (_bucketWidth <= 0) return 0;
    final idx = ((x - _minX) / _bucketWidth).floor();
    return idx.clamp(0, _buckets.length - 1);
  }

  static bool _detectXOrdering(List<OiHitPoint> points) {
    if (points.length < 2) return true;
    for (var i = 1; i < points.length; i++) {
      if (points[i].position.dx < points[i - 1].position.dx - 0.01) {
        return false;
      }
    }
    return true;
  }

  @override
  OiChartHitResult? hitTest(Offset position, {double? tolerance}) {
    final tol = tolerance ?? config.tolerance;
    final results = _findNearby(position, tol);
    if (results.isEmpty) return null;

    return _resolvePreference(results, position);
  }

  @override
  List<OiChartHitResult> hitTestAll(Offset position, {double? tolerance}) {
    final tol = tolerance ?? config.tolerance;
    final results = _findNearby(position, tol)
      ..sort((a, b) => a.distance.compareTo(b.distance));
    return results;
  }

  /// Finds the single nearest point using binary search on ordered
  /// domains. Returns `null` if no point is within [tolerance].
  ///
  /// This is faster than [hitTest] when only the nearest point is
  /// needed and the domain is x-ordered, as it avoids bucket scanning.
  OiChartHitResult? nearestPoint(Offset position, {double? tolerance}) {
    final tol = tolerance ?? config.tolerance;

    if (_points.isEmpty) return null;

    if (_isXOrdered) {
      return _binarySearchNearest(position, tol);
    }

    // Fallback to bucket scan for unordered data.
    return hitTest(position, tolerance: tol);
  }

  List<OiChartHitResult> _findNearby(Offset position, double tolerance) {
    if (_points.isEmpty) return const [];

    final results = <OiChartHitResult>[];
    final tolSq = tolerance * tolerance;

    if (_buckets.isEmpty) {
      // No buckets — scan all points.
      for (final point in _points) {
        final dist = _effectiveDistance(point, position);
        if (dist * dist <= tolSq) {
          results.add(
            OiChartHitResult(
              ref: point.ref,
              position: point.position,
              distance: dist,
            ),
          );
        }
      }
      return results;
    }

    // Determine which buckets to search.
    final centerBucket = _bucketIndex(position.dx);
    final bucketSpan = (tolerance / _bucketWidth).ceil();
    final startBucket = (centerBucket - bucketSpan).clamp(
      0,
      _buckets.length - 1,
    );
    final endBucket = (centerBucket + bucketSpan).clamp(0, _buckets.length - 1);

    for (var b = startBucket; b <= endBucket; b++) {
      for (final idx in _buckets[b]) {
        final point = _points[idx];
        final dist = _effectiveDistance(point, position);
        if (dist * dist <= tolSq) {
          results.add(
            OiChartHitResult(
              ref: point.ref,
              position: point.position,
              distance: dist,
            ),
          );
        }
      }
    }

    return results;
  }

  double _effectiveDistance(OiHitPoint point, Offset queryPos) {
    final dx = point.position.dx - queryPos.dx;
    final dy = point.position.dy - queryPos.dy;
    final rawDist = math.sqrt(dx * dx + dy * dy);
    if (config.includeRadius && point.radius > 0) {
      return math.max(0, rawDist - point.radius);
    }
    return rawDist;
  }

  OiChartHitResult? _binarySearchNearest(Offset position, double tolerance) {
    if (_points.isEmpty) return null;

    // Binary search for the closest x-coordinate.
    var lo = 0;
    var hi = _points.length - 1;
    while (lo < hi) {
      final mid = (lo + hi) ~/ 2;
      if (_points[mid].position.dx < position.dx) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }

    // Search a window around the found index.
    OiChartHitResult? best;
    var bestDist = double.infinity;

    // Scan left from lo while x is within tolerance.
    for (var i = lo; i >= 0; i--) {
      final dx = position.dx - _points[i].position.dx;
      if (dx > tolerance) break;
      final dist = _effectiveDistance(_points[i], position);
      if (dist <= tolerance && dist < bestDist) {
        bestDist = dist;
        best = OiChartHitResult(
          ref: _points[i].ref,
          position: _points[i].position,
          distance: dist,
        );
      }
    }

    // Scan right from lo+1 while x is within tolerance.
    for (var i = lo; i < _points.length; i++) {
      final dx = _points[i].position.dx - position.dx;
      if (dx > tolerance) break;
      final dist = _effectiveDistance(_points[i], position);
      if (dist <= tolerance && dist < bestDist) {
        bestDist = dist;
        best = OiChartHitResult(
          ref: _points[i].ref,
          position: _points[i].position,
          distance: dist,
        );
      }
    }

    return best;
  }

  OiChartHitResult _resolvePreference(
    List<OiChartHitResult> results,
    Offset queryPos,
  ) {
    if (results.length == 1) return results.first;

    switch (config.preference) {
      case OiHitTestPreference.nearest:
        return _selectNearest(results);

      case OiHitTestPreference.foremost:
        // Among points within a tight cluster (within 4px of the
        // nearest), prefer the one with the highest series index.
        final nearest = _selectNearest(results);
        final threshold = math.min(nearest.distance + 4, config.tolerance);
        final cluster = results.where((r) => r.distance <= threshold).toList();
        cluster.sort((a, b) => b.ref.seriesIndex.compareTo(a.ref.seriesIndex));
        return cluster.first;

      case OiHitTestPreference.verticalNearest:
        // Select the point closest in y-coordinate.
        var best = results.first;
        var bestDy = (best.position.dy - queryPos.dy).abs();
        for (var i = 1; i < results.length; i++) {
          final dy = (results[i].position.dy - queryPos.dy).abs();
          if (dy < bestDy) {
            bestDy = dy;
            best = results[i];
          }
        }
        return best;
    }
  }

  OiChartHitResult _selectNearest(List<OiChartHitResult> results) {
    var best = results.first;
    for (var i = 1; i < results.length; i++) {
      if (results[i].distance < best.distance) {
        best = results[i];
      }
    }
    return best;
  }

  /// Clears the spatial index and all indexed points.
  void clear() {
    _points = const [];
    _buckets = const [];
    _bucketWidth = 0;
    _minX = 0;
    _isXOrdered = false;
    _plotBounds = Rect.zero;
  }
}
