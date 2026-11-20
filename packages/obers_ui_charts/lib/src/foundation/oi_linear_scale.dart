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
  /// The domain is set to the extent of the finite [values]; NaN and
  /// infinite entries are ignored. When [nice] is true, the domain bounds
  /// are rounded to human-friendly numbers.
  ///
  /// A single distinct value is padded by 10 % of its magnitude on each
  /// side (±1 for zero) so the domain is never degenerate.
  factory OiLinearScale.fromData({
    required List<double> values,
    required double rangeMin,
    required double rangeMax,
    bool clamp = false,
    bool nice = true,
  }) {
    var lo = double.infinity;
    var hi = double.negativeInfinity;
    for (final v in values) {
      if (!v.isFinite) continue;
      if (v < lo) lo = v;
      if (v > hi) hi = v;
    }
    if (lo > hi) {
      // No finite values.
      return OiLinearScale(
        domainMin: 0,
        domainMax: 1,
        rangeMin: rangeMin,
        rangeMax: rangeMax,
        clamp: clamp,
      );
    }
    if (lo == hi) {
      final padding = lo == 0 ? 1.0 : lo.abs() * 0.1;
      // Clamped so a value near the double limit cannot pad to infinity.
      lo = math.max(lo - padding, -double.maxFinite);
      hi = math.min(hi + padding, double.maxFinite);
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

  // Half the extent: finite even for a domain spanning the whole double
  // range, where the full extent overflows to infinity.
  double get _halfExtent => domainMax / 2 - domainMin / 2;

  @override
  double get atom =>
      _domainExtent == 0 ? 0 : rangeExtent.abs() / 2 / _halfExtent.abs();

  @override
  double toPixel(double value) {
    final extent = _domainExtent;
    if (extent == 0) return rangeMin;
    final t = extent.isFinite
        ? (value - domainMin) / extent
        : (value / 2 - domainMin / 2) / _halfExtent;
    return clampPixel(rangeMin + t * rangeExtent);
  }

  @override
  double fromPixel(double position) {
    if (rangeExtent == 0) return domainMin;
    final t = (position - rangeMin) / rangeExtent;
    final extent = _domainExtent;
    if (extent.isFinite) return domainMin + t * extent;
    // The extent overflowed: interpolate between the bounds instead.
    return domainMin * (1 - t) + domainMax * t;
  }

  @override
  List<OiTick<double>> buildTicks({int count = 5}) {
    if (count < 1) return const [];
    if (!domainMin.isFinite || !domainMax.isFinite) return const [];
    if (count == 1) {
      final mid = (domainMin + domainMax) / 2;
      return [OiTick(value: mid, position: toPixel(mid))];
    }
    // Divide before subtracting: the extent of a very wide domain
    // overflows to infinity, its share per tick does not.
    final divisions = count - 1;
    final step = _niceStep(domainMax / divisions - domainMin / divisions);
    if (!step.isFinite || step <= 0) return const [];

    // Ticks are whole multiples of the step. Their indices are computed up
    // front, so the loop is bounded even when the step is too small to
    // move a large value (adding it would never advance).
    // The same tolerance at both ends: a niced bound such as 3 * 0.1 is
    // 0.30000000000000004 and must still get its tick.
    final first = (domainMin / step - 1e-10).ceilToDouble();
    final last = (domainMax / step + 1e-10).floorToDouble();
    final tickCount = last - first + 1;
    // A nice step is never much smaller than the rough one, so more ticks
    // than this means the arithmetic ran out of precision.
    if (!tickCount.isFinite || tickCount > count * 2 + 2) {
      return [
        OiTick(value: domainMin, position: toPixel(domainMin)),
        if (domainMax != domainMin)
          OiTick(value: domainMax, position: toPixel(domainMax)),
      ];
    }

    final ticks = <OiTick<double>>[];
    for (var i = 0; i < tickCount; i++) {
      final value = (first + i) * step;
      if (!value.isFinite) continue;
      if (ticks.isNotEmpty && ticks.last.value == value) continue;
      ticks.add(OiTick(value: value, position: toPixel(value)));
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
    if (!roughStep.isFinite || roughStep <= 0) return 1;
    final exp = (math.log(roughStep) / math.ln10).floor();
    // A double base: integer `pow` overflows int64 from 10^19 on.
    final magnitude = math.pow(10.0, exp).toDouble();
    final frac = roughStep / magnitude;
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
    final step = niceFrac * magnitude;
    // At the edges of the double range the rounding can leave it; the
    // rough step is still usable there.
    return step.isFinite && step > 0 ? step : roughStep;
  }

  static (double, double) _niceExtent(double lo, double hi) {
    final step = _niceStep(hi / 5 - lo / 5);
    final niceLo = (lo / step).floorToDouble() * step;
    final niceHi = (hi / step).ceilToDouble() * step;
    // Keep a bound as it is when rounding it would overflow.
    return (niceLo.isFinite ? niceLo : lo, niceHi.isFinite ? niceHi : hi);
  }
}
