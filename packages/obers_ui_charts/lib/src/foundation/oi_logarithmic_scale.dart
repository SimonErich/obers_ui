import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'package:obers_ui_charts/src/foundation/oi_chart_scale.dart';

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
  ///
  /// NaN and infinite entries are ignored. The domain is widened to the
  /// surrounding powers of [base].
  factory OiLogarithmicScale.fromData({
    required List<double> values,
    required double rangeMin,
    required double rangeMax,
    bool clamp = false,
    double base = 10,
  }) {
    final finite = values.where((v) => v.isFinite).toList();
    final positive = finite.where((v) => v > 0);
    assert(
      positive.length == finite.length,
      'OiLogarithmicScale: ${finite.length - positive.length} negative/zero '
      'values were clamped. Log scales require strictly positive values.',
    );
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
    lo = math.pow(base, _tolerantFloor(math.log(lo) / logBase)).toDouble();
    hi = math.pow(base, _tolerantCeil(math.log(hi) / logBase)).toDouble();
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

  /// Converts a domain [value] to a pixel position.
  ///
  /// A logarithm is only defined for positive numbers, so a [value] that is
  /// zero, negative or NaN has no position on this scale and yields
  /// [double.nan]. Callers should skip such values rather than draw them.
  @override
  double toPixel(double value) {
    if (value.isNaN || value <= 0) return double.nan;
    if (_logExtent == 0) return rangeMin;
    final t = (_logOf(value) - _logMin) / _logExtent;
    return clampPixel(rangeMin + t * rangeExtent);
  }

  @override
  double fromPixel(double position) {
    if (rangeExtent == 0) return domainMin;
    final t = (position - rangeMin) / rangeExtent;
    return math.pow(base, _logMin + t * _logExtent).toDouble();
  }

  /// Generates at most [count] ticks at human-friendly positions.
  ///
  /// Starts from the powers of [base] inside the domain. When there are
  /// more of them than [count], every n-th power is kept. When there is
  /// room left, sub-decade multiples (1-2-5 for base 10, then every integer
  /// multiple) are added, which also covers a domain that lies inside a
  /// single decade.
  @override
  List<OiTick<double>> buildTicks({int count = 5}) {
    if (count < 1) return const [];
    if (!domainMin.isFinite || !domainMax.isFinite) return const [];

    final startExp = _tolerantFloor(_logMin);
    final endExp = _tolerantCeil(_logMax);

    final powers = _multiples(startExp, endExp, const [1]);
    var values = powers;
    if (powers.length > count) {
      final stride = (powers.length / count).ceil();
      values = [for (var i = 0; i < powers.length; i += stride) powers[i]];
    } else {
      final everyMultiple = [for (var m = 1; m < base; m++) m];
      final candidates = [
        if (base == 10) _multiples(startExp, endExp, const [1, 2, 5]),
        _multiples(startExp, endExp, everyMultiple),
      ];
      for (final candidate in candidates) {
        if (candidate.length <= count || values.isEmpty) values = candidate;
      }
      if (values.length > count) {
        final stride = (values.length / count).ceil();
        values = [for (var i = 0; i < values.length; i += stride) values[i]];
      }
    }
    if (values.isEmpty) {
      values = [domainMin, if (count > 1 && domainMax != domainMin) domainMax];
    }
    return [for (final v in values) OiTick(value: v, position: toPixel(v))];
  }

  /// Every `multiplier * base^exp` inside the domain, in ascending order.
  List<double> _multiples(int startExp, int endExp, List<int> multipliers) {
    // Tolerate rounding in `pow`, so a bound that is itself a multiple is
    // kept.
    final lo = domainMin * (1 - 1e-9);
    final hi = domainMax * (1 + 1e-9);
    final result = <double>[];
    for (var exp = startExp; exp <= endExp; exp++) {
      final power = math.pow(base, exp).toDouble();
      for (final m in multipliers) {
        final value = m * power;
        if (value >= lo && value <= hi) result.add(value);
      }
    }
    return result;
  }

  /// Floors [value], treating a result within rounding error of an integer
  /// as that integer (`log(1000) / ln10` is `2.9999999999999996`).
  static int _tolerantFloor(double value) {
    final nearest = value.roundToDouble();
    if ((value - nearest).abs() < 1e-9) return nearest.toInt();
    return value.floor();
  }

  /// Ceils [value] with the same tolerance as [_tolerantFloor].
  static int _tolerantCeil(double value) {
    final nearest = value.roundToDouble();
    if ((value - nearest).abs() < 1e-9) return nearest.toInt();
    return value.ceil();
  }

  @override
  OiLogarithmicScale withDomain(double min, double max) {
    return OiLogarithmicScale(
      domainMin: min,
      domainMax: max,
      rangeMin: rangeMin,
      rangeMax: rangeMax,
      clamp: clamp,
      base: base,
    );
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
