import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_scale.dart';

/// A continuous linear scale that maps a numeric domain to a pixel range.
///
/// {@category Foundation}
@immutable
class OiLinearScale {
  /// Creates an [OiLinearScale].
  const OiLinearScale({
    required this.domainMin,
    required this.domainMax,
    required this.rangeMin,
    required this.rangeMax,
    this.clamp = false,
  });

  /// Creates a scale by computing the domain from a list of values.
  ///
  /// When [nice] is `true` (default) the domain is rounded outward to nice
  /// round numbers. When [values] is empty the domain defaults to `[0, 1]`.
  /// When [values] has a single element the domain is expanded by ±10% so that
  /// the chart always shows meaningful extent.
  factory OiLinearScale.fromData({
    required List<num> values,
    required double rangeMin,
    required double rangeMax,
    bool nice = true,
    bool clamp = false,
  }) {
    if (values.isEmpty) {
      return OiLinearScale(
        domainMin: 0,
        domainMax: 1,
        rangeMin: rangeMin,
        rangeMax: rangeMax,
        clamp: clamp,
      );
    }

    var dMin = values.map((v) => v.toDouble()).reduce(math.min);
    var dMax = values.map((v) => v.toDouble()).reduce(math.max);

    if (dMin == dMax) {
      dMin -= (dMin.abs() * 0.1).clamp(0.5, double.infinity);
      dMax += (dMax.abs() * 0.1).clamp(0.5, double.infinity);
    }

    if (nice) {
      final extent = dMax - dMin;
      final roughStep = extent / 5;
      final step = _niceStep(roughStep);
      dMin = (dMin / step).floor() * step;
      dMax = (dMax / step).ceil() * step;
    }

    return OiLinearScale(
      domainMin: dMin,
      domainMax: dMax,
      rangeMin: rangeMin,
      rangeMax: rangeMax,
      clamp: clamp,
    );
  }

  /// Minimum value of the input domain.
  final double domainMin;

  /// Maximum value of the input domain.
  final double domainMax;

  /// Minimum pixel position of the output range.
  final double rangeMin;

  /// Maximum pixel position of the output range.
  final double rangeMax;

  /// Whether to clamp output values to [rangeMin]..[rangeMax].
  final bool clamp;

  /// The type identifier for this scale.
  OiScaleType get type => OiScaleType.linear;

  /// The extent of the output range (`rangeMax - rangeMin`).
  double get rangeExtent => rangeMax - rangeMin;

  /// Maps a domain [value] to a pixel position.
  double toPixel(double value) {
    final extent = domainMax - domainMin;
    if (extent == 0) return rangeMin;
    final t = (value - domainMin) / extent;
    final pixel = rangeMin + t * (rangeMax - rangeMin);
    if (clamp) {
      return pixel.clamp(
        math.min(rangeMin, rangeMax),
        math.max(rangeMin, rangeMax),
      );
    }
    return pixel;
  }

  /// Maps a pixel position back to a domain value.
  double fromPixel(double pixel) {
    final extent = rangeMax - rangeMin;
    if (extent == 0) return domainMin;
    return domainMin + (pixel - rangeMin) / extent * (domainMax - domainMin);
  }

  /// Generates evenly spaced tick values within the domain.
  ///
  /// [count] controls the number of ticks (default 5). Returns the midpoint
  /// when [count] is 1, and an empty list when [count] is 0.
  List<OiScaleTick<double>> buildTicks({int count = 5}) {
    if (count == 0) return [];
    if (count == 1) {
      return [OiScaleTick(value: (domainMin + domainMax) / 2)];
    }
    final ticks = <OiScaleTick<double>>[];
    final step = (domainMax - domainMin) / (count - 1);
    for (var i = 0; i < count; i++) {
      ticks.add(OiScaleTick(value: domainMin + step * i));
    }
    return ticks;
  }

  /// Returns a copy with any overridden fields.
  OiLinearScale copyWith({
    double? domainMin,
    double? domainMax,
    double? rangeMin,
    double? rangeMax,
    bool? clamp,
  }) {
    return OiLinearScale(
      domainMin: domainMin ?? this.domainMin,
      domainMax: domainMax ?? this.domainMax,
      rangeMin: rangeMin ?? this.rangeMin,
      rangeMax: rangeMax ?? this.rangeMax,
      clamp: clamp ?? this.clamp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiLinearScale &&
          runtimeType == other.runtimeType &&
          domainMin == other.domainMin &&
          domainMax == other.domainMax &&
          rangeMin == other.rangeMin &&
          rangeMax == other.rangeMax &&
          clamp == other.clamp;

  @override
  int get hashCode =>
      Object.hash(domainMin, domainMax, rangeMin, rangeMax, clamp);

  static double _niceStep(double roughStep) {
    if (roughStep <= 0) return 1;
    final magnitude = math
        .pow(10, (math.log(roughStep) / math.ln10).floor())
        .toDouble();
    final normalized = roughStep / magnitude;
    if (normalized < 1.5) return magnitude;
    if (normalized < 3) return 2 * magnitude;
    if (normalized < 7) return 5 * magnitude;
    return 10 * magnitude;
  }
}
