import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_scale.dart';

/// A scale that divides the domain into segments separated by explicit
/// threshold values and maps each segment to a pixel band.
///
/// {@category Foundation}
@immutable
class OiThresholdScale {
  /// Creates an [OiThresholdScale].
  ///
  /// [thresholds] must be in ascending order.
  const OiThresholdScale({
    required this.thresholds,
    required this.rangeMin,
    required this.rangeMax,
    this.clamp = false,
  });

  /// The sorted threshold values that separate segments.
  final List<double> thresholds;

  /// Minimum pixel position of the output range.
  final double rangeMin;

  /// Maximum pixel position of the output range.
  final double rangeMax;

  /// Whether to clamp pixel output to [rangeMin]..[rangeMax].
  final bool clamp;

  /// The type identifier for this scale.
  OiScaleType get type => OiScaleType.threshold;

  /// The number of segments (always `thresholds.length + 1`).
  int get segmentCount => thresholds.length + 1;

  double get _bandwidth => (rangeMax - rangeMin) / segmentCount;

  int _binOf(double value) {
    for (var i = 0; i < thresholds.length; i++) {
      if (value < thresholds[i]) return i;
    }
    return thresholds.length;
  }

  /// Maps a [value] to the center pixel of its threshold segment.
  double toPixel(double value) {
    final bin = _binOf(value);
    final pixel = rangeMin + _bandwidth * (bin + 0.5);
    if (clamp) {
      return pixel.clamp(
        math.min(rangeMin, rangeMax),
        math.max(rangeMin, rangeMax),
      );
    }
    return pixel;
  }

  /// Returns the midpoint of the threshold segment that contains [pixel].
  double fromPixel(double pixel) {
    final bin = ((pixel - rangeMin) / _bandwidth).floor().clamp(
      0,
      segmentCount - 1,
    );
    final lo = bin == 0 ? double.negativeInfinity : thresholds[bin - 1];
    final hi = bin >= thresholds.length ? double.infinity : thresholds[bin];
    // If bounds are infinite, return the finite threshold as representative.
    if (lo.isInfinite && hi.isInfinite) return 0;
    if (lo.isInfinite) return hi - 1;
    if (hi.isInfinite) return lo + 1;
    return (lo + hi) / 2;
  }

  /// Generates one tick at each threshold value.
  List<OiScaleTick<double>> buildTicks() =>
      thresholds.map((v) => OiScaleTick(value: v)).toList();

  /// Returns a copy with any overridden fields.
  OiThresholdScale copyWith({
    List<double>? thresholds,
    double? rangeMin,
    double? rangeMax,
    bool? clamp,
  }) {
    return OiThresholdScale(
      thresholds: thresholds ?? this.thresholds,
      rangeMin: rangeMin ?? this.rangeMin,
      rangeMax: rangeMax ?? this.rangeMax,
      clamp: clamp ?? this.clamp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiThresholdScale &&
          runtimeType == other.runtimeType &&
          _listEquals(thresholds, other.thresholds) &&
          rangeMin == other.rangeMin &&
          rangeMax == other.rangeMax &&
          clamp == other.clamp;

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(thresholds), rangeMin, rangeMax, clamp);

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
