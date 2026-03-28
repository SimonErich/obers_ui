import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_scale.dart';

/// A continuous logarithmic scale for data that spans multiple orders of
/// magnitude.
///
/// {@category Foundation}
@immutable
class OiLogarithmicScale {
  /// Creates an [OiLogarithmicScale].
  ///
  /// [domainMin] must be positive.
  const OiLogarithmicScale({
    required this.domainMin,
    required this.domainMax,
    required this.rangeMin,
    required this.rangeMax,
    this.base = 10,
    this.clamp = false,
  });

  /// Creates a scale from a list of positive values.
  ///
  /// Returns a default `[1, 10]` domain when [values] is empty.
  factory OiLogarithmicScale.fromData({
    required List<num> values,
    required double rangeMin,
    required double rangeMax,
    double base = 10,
    bool clamp = false,
  }) {
    if (values.isEmpty) {
      return OiLogarithmicScale(
        domainMin: 1,
        domainMax: 10,
        rangeMin: rangeMin,
        rangeMax: rangeMax,
        base: base,
        clamp: clamp,
      );
    }
    final positive = values.where((v) => v > 0).map((v) => v.toDouble());
    final dMin = positive.reduce(math.min);
    final dMax = positive.reduce(math.max);
    return OiLogarithmicScale(
      domainMin: dMin,
      domainMax: dMax,
      rangeMin: rangeMin,
      rangeMax: rangeMax,
      base: base,
      clamp: clamp,
    );
  }

  /// Minimum value of the input domain (must be positive).
  final double domainMin;

  /// Maximum value of the input domain.
  final double domainMax;

  /// Minimum pixel position of the output range.
  final double rangeMin;

  /// Maximum pixel position of the output range.
  final double rangeMax;

  /// The logarithm base (default 10).
  final double base;

  /// Whether to clamp output values to [rangeMin]..[rangeMax].
  final bool clamp;

  /// The type identifier for this scale.
  OiScaleType get type => OiScaleType.logarithmic;

  double _log(double v) => math.log(v) / math.log(base);

  /// Maps a domain [value] to a pixel position.
  ///
  /// Returns [rangeMin] for non-positive values.
  double toPixel(double value) {
    if (value <= 0) return rangeMin;
    final logMin = _log(domainMin);
    final logMax = _log(domainMax);
    final extent = logMax - logMin;
    if (extent == 0) return rangeMin;
    final t = (_log(value) - logMin) / extent;
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
    final logMin = _log(domainMin);
    final logMax = _log(domainMax);
    final extent = rangeMax - rangeMin;
    if (extent == 0) return domainMin;
    final t = (pixel - rangeMin) / extent;
    return math.pow(base, logMin + t * (logMax - logMin)).toDouble();
  }

  /// Generates ticks at powers of [base] within the domain.
  List<OiScaleTick<double>> buildTicks({int count = 10}) {
    final ticks = <OiScaleTick<double>>[];
    final logMin = _log(domainMin).floor();
    final logMax = _log(domainMax).ceil();
    for (var i = logMin; i <= logMax; i++) {
      final v = math.pow(base, i).toDouble();
      if (v >= domainMin && v <= domainMax) {
        ticks.add(OiScaleTick(value: v));
      }
    }
    return ticks;
  }

  /// Returns a copy with any overridden fields.
  OiLogarithmicScale copyWith({
    double? domainMin,
    double? domainMax,
    double? rangeMin,
    double? rangeMax,
    double? base,
    bool? clamp,
  }) {
    return OiLogarithmicScale(
      domainMin: domainMin ?? this.domainMin,
      domainMax: domainMax ?? this.domainMax,
      rangeMin: rangeMin ?? this.rangeMin,
      rangeMax: rangeMax ?? this.rangeMax,
      base: base ?? this.base,
      clamp: clamp ?? this.clamp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiLogarithmicScale &&
          runtimeType == other.runtimeType &&
          domainMin == other.domainMin &&
          domainMax == other.domainMax &&
          rangeMin == other.rangeMin &&
          rangeMax == other.rangeMax &&
          base == other.base &&
          clamp == other.clamp;

  @override
  int get hashCode =>
      Object.hash(domainMin, domainMax, rangeMin, rangeMax, base, clamp);
}
