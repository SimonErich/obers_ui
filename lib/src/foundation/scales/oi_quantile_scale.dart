import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_scale.dart';

/// A statistical scale that divides a dataset into [quantileCount] equal-sized
/// buckets and maps each value to the center of its bucket.
///
/// {@category Foundation}
@immutable
class OiQuantileScale {
  /// Creates an [OiQuantileScale].
  OiQuantileScale({
    required List<num> values,
    required this.rangeMin,
    required this.rangeMax,
    this.quantileCount = 4,
    this.clamp = false,
  }) : sortedValues = (values.map((v) => v.toDouble()).toList()..sort());

  /// The sorted input values (ascending).
  final List<double> sortedValues;

  /// Minimum pixel position of the output range.
  final double rangeMin;

  /// Maximum pixel position of the output range.
  final double rangeMax;

  /// Number of quantile buckets.
  final int quantileCount;

  /// Whether to clamp pixel output to [rangeMin]..[rangeMax].
  final bool clamp;

  /// The type identifier for this scale.
  OiScaleType get type => OiScaleType.quantile;

  /// The threshold values that divide the domain into [quantileCount] buckets.
  List<double> get thresholds {
    if (sortedValues.isEmpty || quantileCount <= 1) return [];
    final thresholds = <double>[];
    for (var q = 1; q < quantileCount; q++) {
      thresholds.add(_quantile(q / quantileCount));
    }
    return thresholds;
  }

  double _quantile(double p) {
    final n = sortedValues.length;
    if (n == 0) return 0;
    final idx = p * (n - 1);
    final lo = idx.floor();
    final hi = idx.ceil();
    if (lo == hi) return sortedValues[lo];
    return sortedValues[lo] +
        (sortedValues[hi] - sortedValues[lo]) * (idx - lo);
  }

  int _binOf(double value) {
    final t = thresholds;
    for (var i = 0; i < t.length; i++) {
      if (value < t[i]) return i;
    }
    return quantileCount - 1;
  }

  double get _bandwidth => (rangeMax - rangeMin) / quantileCount;

  /// Maps a [value] to the center pixel of its quantile bucket.
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

  /// Returns a representative value for the bucket nearest to [pixel].
  double fromPixel(double pixel) {
    if (sortedValues.isEmpty) return rangeMin;
    final bin = ((pixel - rangeMin) / _bandwidth).floor().clamp(
      0,
      quantileCount - 1,
    );
    // Return median of values in this bin.
    final t = thresholds;
    final lo = bin == 0 ? sortedValues.first : t[bin - 1];
    final hi = bin >= t.length ? sortedValues.last : t[bin];
    return (lo + hi) / 2;
  }

  /// Generates ticks at the min and max of the sorted values, plus thresholds.
  List<OiScaleTick<double>> buildTicks() {
    if (sortedValues.isEmpty) return [];
    final values = <double>[
      sortedValues.first,
      ...thresholds,
      sortedValues.last,
    ];
    return values.map((v) => OiScaleTick(value: v)).toList();
  }

  /// Returns a copy with any overridden fields.
  OiQuantileScale copyWith({
    List<num>? values,
    double? rangeMin,
    double? rangeMax,
    int? quantileCount,
    bool? clamp,
  }) {
    return OiQuantileScale(
      values: values ?? sortedValues,
      rangeMin: rangeMin ?? this.rangeMin,
      rangeMax: rangeMax ?? this.rangeMax,
      quantileCount: quantileCount ?? this.quantileCount,
      clamp: clamp ?? this.clamp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiQuantileScale &&
          runtimeType == other.runtimeType &&
          _listEquals(sortedValues, other.sortedValues) &&
          rangeMin == other.rangeMin &&
          rangeMax == other.rangeMax &&
          quantileCount == other.quantileCount &&
          clamp == other.clamp;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(sortedValues),
    rangeMin,
    rangeMax,
    quantileCount,
    clamp,
  );

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
