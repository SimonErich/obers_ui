import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_scale.dart';

/// A continuous scale that maps [DateTime] values to pixel positions.
///
/// {@category Foundation}
@immutable
class OiTimeScale {
  /// Creates an [OiTimeScale].
  const OiTimeScale({
    required this.domainMin,
    required this.domainMax,
    required this.rangeMin,
    required this.rangeMax,
    this.clamp = false,
  });

  /// Creates a scale from a list of [DateTime] values.
  ///
  /// Returns a default domain of `[now - 1 day, now + 1 day]` when [values]
  /// is empty. Single-value domains are expanded by one day on each side.
  factory OiTimeScale.fromData({
    required List<DateTime> values,
    required double rangeMin,
    required double rangeMax,
    bool clamp = false,
  }) {
    if (values.isEmpty) {
      final now = DateTime.now();
      return OiTimeScale(
        domainMin: now.subtract(const Duration(days: 1)),
        domainMax: now.add(const Duration(days: 1)),
        rangeMin: rangeMin,
        rangeMax: rangeMax,
        clamp: clamp,
      );
    }

    var dMin = values.reduce((a, b) => a.isBefore(b) ? a : b);
    var dMax = values.reduce((a, b) => a.isAfter(b) ? a : b);

    if (dMin == dMax) {
      dMin = dMin.subtract(const Duration(days: 1));
      dMax = dMax.add(const Duration(days: 1));
    }

    return OiTimeScale(
      domainMin: dMin,
      domainMax: dMax,
      rangeMin: rangeMin,
      rangeMax: rangeMax,
      clamp: clamp,
    );
  }

  /// Minimum date of the input domain.
  final DateTime domainMin;

  /// Maximum date of the input domain.
  final DateTime domainMax;

  /// Minimum pixel position of the output range.
  final double rangeMin;

  /// Maximum pixel position of the output range.
  final double rangeMax;

  /// Whether to clamp output values to [rangeMin]..[rangeMax].
  final bool clamp;

  /// The type identifier for this scale.
  OiScaleType get type => OiScaleType.time;

  int get _domainExtentMs =>
      domainMax.millisecondsSinceEpoch - domainMin.millisecondsSinceEpoch;

  /// Maps a [DateTime] to a pixel position.
  double toPixel(DateTime value) {
    final extent = _domainExtentMs;
    if (extent == 0) return rangeMin;
    final t =
        (value.millisecondsSinceEpoch - domainMin.millisecondsSinceEpoch) /
        extent;
    final pixel = rangeMin + t * (rangeMax - rangeMin);
    if (clamp) {
      return pixel.clamp(
        math.min(rangeMin, rangeMax),
        math.max(rangeMin, rangeMax),
      );
    }
    return pixel;
  }

  /// Maps a pixel position back to a [DateTime].
  DateTime fromPixel(double pixel) {
    final extent = rangeMax - rangeMin;
    if (extent == 0) return domainMin;
    final t = (pixel - rangeMin) / extent;
    final ms = domainMin.millisecondsSinceEpoch + (t * _domainExtentMs).round();
    return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: domainMin.isUtc);
  }

  /// Generates ticks spaced at a sensible interval within the domain.
  List<OiScaleTick<DateTime>> buildTicks({int count = 5}) {
    if (count <= 0) return [];
    final extentMs = _domainExtentMs;
    if (extentMs == 0) return [OiScaleTick(value: domainMin)];

    final stepMs = extentMs / count;
    final ticks = <OiScaleTick<DateTime>>[];
    for (var i = 0; i <= count; i++) {
      final ms = domainMin.millisecondsSinceEpoch + (stepMs * i).round();
      final dt = DateTime.fromMillisecondsSinceEpoch(
        ms,
        isUtc: domainMin.isUtc,
      );
      if (!dt.isAfter(domainMax)) ticks.add(OiScaleTick(value: dt));
    }
    return ticks;
  }

  /// Returns a copy with any overridden fields.
  OiTimeScale copyWith({
    DateTime? domainMin,
    DateTime? domainMax,
    double? rangeMin,
    double? rangeMax,
    bool? clamp,
  }) {
    return OiTimeScale(
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
      other is OiTimeScale &&
          runtimeType == other.runtimeType &&
          domainMin == other.domainMin &&
          domainMax == other.domainMax &&
          rangeMin == other.rangeMin &&
          rangeMax == other.rangeMax &&
          clamp == other.clamp;

  @override
  int get hashCode =>
      Object.hash(domainMin, domainMax, rangeMin, rangeMax, clamp);
}
