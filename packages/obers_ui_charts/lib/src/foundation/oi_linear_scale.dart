import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'package:obers_ui_charts/src/foundation/oi_chart_scale.dart';

/// A linear scale that maps a continuous numeric domain to a pixel range.
///
/// The mapping is a simple linear interpolation:
/// ```dart
/// pixel = rangeMin + (value - domainMin) / (domainMax - domainMin)
///         * (rangeMax - rangeMin)
/// ```
///
/// {@category Foundation}
@immutable
class OiLinearScale extends OiChartScale<double> {
  /// Creates an [OiLinearScale].
  const OiLinearScale({
    required this.domainMin,
    required this.domainMax,
    required super.rangeMin,
    required super.rangeMax,
    super.clamp,
    this.nice = false,
  });

  /// Creates an [OiLinearScale] from a list of [values].
  ///
  /// The domain is set to the extent of [values]. When [nice] is true,
  /// the domain bounds are rounded to human-friendly numbers.
  factory OiLinearScale.fromData({
    required List<double> values,
    required double rangeMin,
    required double rangeMax,
    bool clamp = false,
    bool nice = true,
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
    var lo = values.first;
    var hi = values.first;
    for (final v in values) {
      if (v < lo) lo = v;
      if (v > hi) hi = v;
    }
    if (lo == hi) {
      lo = lo - 1;
      hi = hi + 1;
    }
    if (nice) {
      final niced = _niceExtent(lo, hi);
      lo = niced.$1;
      hi = niced.$2;
    }
    return OiLinearScale(
      domainMin: lo,
      domainMax: hi,
      rangeMin: rangeMin,
      rangeMax: rangeMax,
      clamp: clamp,
      nice: nice,
    );
  }

  /// The minimum value in the data domain.
  final double domainMin;

  /// The maximum value in the data domain.
  final double domainMax;

  /// Whether the domain bounds were rounded to nice numbers.
  final bool nice;

  @override
  OiScaleType get type => OiScaleType.linear;

  double get _domainExtent => domainMax - domainMin;

  @override
  double get atom =>
      _domainExtent == 0 ? 0 : rangeExtent.abs() / _domainExtent.abs();

  @override
  double toPixel(double value) {
    if (_domainExtent == 0) return rangeMin;
    final t = (value - domainMin) / _domainExtent;
    return clampPixel(rangeMin + t * rangeExtent);
  }

  @override
  double fromPixel(double position) {
    if (rangeExtent == 0) return domainMin;
    final t = (position - rangeMin) / rangeExtent;
    return domainMin + t * _domainExtent;
  }

  @override
  List<OiTick<double>> buildTicks({int count = 5}) {
    if (count < 1) return const [];
    if (count == 1) {
      final mid = (domainMin + domainMax) / 2;
      return [OiTick(value: mid, position: toPixel(mid))];
    }
    final step = _niceStep(_domainExtent / (count - 1));
    final start = (domainMin / step).ceil() * step;
    final ticks = <OiTick<double>>[];
    for (var v = start; v <= domainMax + step * 1e-10; v += step) {
      final rounded = _roundTo(v, step);
      if (rounded >= domainMin - step * 1e-10 &&
          rounded <= domainMax + step * 1e-10) {
        ticks.add(OiTick(value: rounded, position: toPixel(rounded)));
      }
    }
    return ticks;
  }

  @override
  OiLinearScale withDomain(double min, double max) {
    return OiLinearScale(
      domainMin: min,
      domainMax: max,
      rangeMin: rangeMin,
      rangeMax: rangeMax,
      clamp: clamp,
      nice: nice,
    );
  }

  /// Creates a copy with optionally overridden values.
  OiLinearScale copyWith({
    double? domainMin,
    double? domainMax,
    double? rangeMin,
    double? rangeMax,
    bool? clamp,
    bool? nice,
  }) {
    return OiLinearScale(
      domainMin: domainMin ?? this.domainMin,
      domainMax: domainMax ?? this.domainMax,
      rangeMin: rangeMin ?? this.rangeMin,
      rangeMax: rangeMax ?? this.rangeMax,
      clamp: clamp ?? this.clamp,
      nice: nice ?? this.nice,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiLinearScale &&
          other.domainMin == domainMin &&
          other.domainMax == domainMax &&
          other.rangeMin == rangeMin &&
          other.rangeMax == rangeMax &&
          other.clamp == clamp &&
          other.nice == nice;

  @override
  int get hashCode =>
      Object.hashAll([domainMin, domainMax, rangeMin, rangeMax, clamp, nice]);

  static double _niceStep(double roughStep) {
    if (roughStep <= 0) return 1;
    final exp = (math.log(roughStep) / math.ln10).floor();
    final frac = roughStep / math.pow(10, exp);
    double niceFrac;
    if (frac <= 1.5) {
      niceFrac = 1;
    } else if (frac <= 3) {
      niceFrac = 2;
    } else if (frac <= 7) {
      niceFrac = 5;
    } else {
      niceFrac = 10;
    }
    return niceFrac * math.pow(10, exp);
  }

  static (double, double) _niceExtent(double lo, double hi) {
    final step = _niceStep((hi - lo) / 5);
    return ((lo / step).floor() * step, (hi / step).ceil() * step);
  }

  static double _roundTo(double value, double step) {
    if (step == 0) return value;
    return (value / step).round() * step;
  }
}
