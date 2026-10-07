import 'package:flutter/animation.dart';

/// A curve that linearly interpolates explicit progress/output stops.
///
/// Outputs may overshoot; they are not clamped to the unit interval. This is a
/// Flutter curve, not a CSS parser or a discontinuous/extrapolating easing API.
///
/// {@category Foundation}
class OiPiecewiseCurve extends Curve {
  /// Snapshots at least two finite `(input, output)` [Offset] values.
  ///
  /// Inputs must strictly increase within 0–1, with endpoints (0,0) and (1,1).
  /// Invalid stops throw [ArgumentError] immediately, including in release.
  factory OiPiecewiseCurve(List<Offset> stops) {
    final points = List<Offset>.unmodifiable(stops);
    if (points.length < 2 ||
        points.first != Offset.zero ||
        points.last != const Offset(1, 1)) {
      throw ArgumentError.value(stops, 'stops', 'Need endpoints (0,0), (1,1).');
    }
    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      if (!point.dx.isFinite ||
          !point.dy.isFinite ||
          point.dx < 0 ||
          point.dx > 1 ||
          (i > 0 && point.dx <= points[i - 1].dx)) {
        throw ArgumentError.value(
          stops,
          'stops',
          'Need finite outputs and strictly increasing inputs within 0–1.',
        );
      }
    }
    return OiPiecewiseCurve._(points);
  }

  const OiPiecewiseCurve._(this._stops);

  final List<Offset> _stops;

  @override
  double transformInternal(double t) {
    var upper = 1;
    while (t > _stops[upper].dx) {
      upper++;
    }
    final start = _stops[upper - 1];
    final end = _stops[upper];
    if (start.dy == end.dy) return start.dy;
    final fraction = (t - start.dx) / (end.dx - start.dx);
    // A convex combination avoids overflowing an opposite-sign delta.
    return start.dy * (1 - fraction) + end.dy * fraction;
  }
}
