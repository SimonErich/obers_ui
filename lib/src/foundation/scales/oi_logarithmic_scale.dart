import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'package:obers_ui/src/foundation/scales/oi_chart_scale.dart';

/// A logarithmic scale that maps a continuous positive numeric domain
/// to a pixel range using a log transformation.
///
/// Useful for data spanning several orders of magnitude. The domain
/// must contain strictly positive values.
///
/// {@category Foundation}
@immutable
class OiLogarithmicScale extends OiChartScale<double> {
  /// Creates an [OiLogarithmicScale].
  ///
  /// Both [domainMin] and [domainMax] must be positive.
  const OiLogarithmicScale({
    required this.domainMin,
    required this.domainMax,
    required super.rangeMin,
    required super.rangeMax,
    super.clamp,
    this.base = 10,
  }) : assert(domainMin > 0, 'domainMin must be positive'),
       assert(domainMax > 0, 'domainMax must be positive'),
       assert(base > 1, 'base must be greater than 1');

  /// Creates an [OiLogarithmicScale] from a list of positive [values].
  factory OiLogarithmicScale.fromData({
    required List<double> values,
    required double rangeMin,
    required double rangeMax,
    bool clamp = false,
    double base = 10,
  }) {
    if (values.isEmpty) {
      return OiLogarithmicScale(
        domainMin: 1,
        domainMax: 10,
        rangeMin: rangeMin,
        rangeMax: rangeMax,
        clamp: clamp,
        base: base,
      );
    }
    final positive = values.where((v) => v > 0);
    if (positive.isEmpty) {
      return OiLogarithmicScale(
        domainMin: 1,
        domainMax: 10,
        rangeMin: rangeMin,
        rangeMax: rangeMax,
        clamp: clamp,
        base: base,
      );
    }
    var lo = positive.first;
    var hi = positive.first;
    for (final v in positive) {
      if (v < lo) lo = v;
      if (v > hi) hi = v;
    }
    if (lo == hi) {
      lo = lo / base;
      hi = hi * base;
    }
    // Round to nearest power of base.
    final logBase = math.log(base);
    lo = math.pow(base, (math.log(lo) / logBase).floor()).toDouble();
    hi = math.pow(base, (math.log(hi) / logBase).ceil()).toDouble();
    return OiLogarithmicScale(
      domainMin: lo,
      domainMax: hi,
      rangeMin: rangeMin,
      rangeMax: rangeMax,
      clamp: clamp,
      base: base,
    );
  }

  /// The minimum value in the data domain (must be positive).
  final double domainMin;

  /// The maximum value in the data domain (must be positive).
  final double domainMax;

  /// The logarithm base. Defaults to 10.
  final double base;

  @override
  OiScaleType get type => OiScaleType.logarithmic;

  double get _logBase => math.log(base);

  double _logOf(double v) => math.log(v) / _logBase;

  double get _logMin => _logOf(domainMin);
  double get _logMax => _logOf(domainMax);
  double get _logExtent => _logMax - _logMin;

  @override
  double get atom => _logExtent == 0 ? 0 : rangeExtent.abs() / _logExtent.abs();

  @override
  double toPixel(double value) {
    if (value <= 0 || _logExtent == 0) return rangeMin;
    final t = (_logOf(value) - _logMin) / _logExtent;
    return clampPixel(rangeMin + t * rangeExtent);
  }

  @override
  double fromPixel(double position) {
    if (rangeExtent == 0) return domainMin;
    final t = (position - rangeMin) / rangeExtent;
    return math.pow(base, _logMin + t * _logExtent).toDouble();
  }

  @override
  List<OiTick<double>> buildTicks({int count = 5}) {
    final ticks = <OiTick<double>>[];
    final startExp = (math.log(domainMin) / _logBase).floor();
    final endExp = (math.log(domainMax) / _logBase).ceil();

    for (var exp = startExp; exp <= endExp; exp++) {
      final value = math.pow(base, exp).toDouble();
      if (value >= domainMin && value <= domainMax) {
        ticks.add(OiTick(value: value, position: toPixel(value)));
      }
    }
    if (ticks.isEmpty) {
      ticks.add(OiTick(value: domainMin, position: toPixel(domainMin)));
    }
    return ticks;
  }

  /// Creates a copy with optionally overridden values.
  OiLogarithmicScale copyWith({
    double? domainMin,
    double? domainMax,
    double? rangeMin,
    double? rangeMax,
    bool? clamp,
    double? base,
  }) {
    return OiLogarithmicScale(
      domainMin: domainMin ?? this.domainMin,
      domainMax: domainMax ?? this.domainMax,
      rangeMin: rangeMin ?? this.rangeMin,
      rangeMax: rangeMax ?? this.rangeMax,
      clamp: clamp ?? this.clamp,
      base: base ?? this.base,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiLogarithmicScale &&
          other.domainMin == domainMin &&
          other.domainMax == domainMax &&
          other.rangeMin == rangeMin &&
          other.rangeMax == rangeMax &&
          other.clamp == clamp &&
          other.base == base;

  @override
  int get hashCode =>
      Object.hashAll([domainMin, domainMax, rangeMin, rangeMax, clamp, base]);
}
