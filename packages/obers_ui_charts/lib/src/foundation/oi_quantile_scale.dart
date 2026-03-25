import 'package:flutter/foundation.dart';

import 'package:obers_ui_charts/src/foundation/oi_chart_scale.dart';

/// A quantile scale that maps continuous numeric input to discrete
/// output ranges based on data quantiles.
///
/// The domain is divided into equal-frequency bins. Each quantile maps
/// to a proportional segment of the output range. This is useful for
/// choropleth maps and heatmaps where you want equal counts per bin.
///
/// {@category Foundation}
@immutable
class OiQuantileScale extends OiChartScale<double> {
  /// Creates an [OiQuantileScale] from sorted sample [values].
  ///
  /// The [quantileCount] determines how many equal-frequency bins to
  /// create (e.g., 4 for quartiles, 5 for quintiles).
  OiQuantileScale({
    required List<double> values,
    required super.rangeMin,
    required super.rangeMax,
    super.clamp,
    this.quantileCount = 4,
  }) : assert(quantileCount > 0, 'quantileCount must be positive'),
       _sortedValues = List<double>.of(values)..sort();

  /// The number of quantile bins.
  final int quantileCount;

  final List<double> _sortedValues;

  /// The sorted domain values.
  List<double> get sortedValues => List.unmodifiable(_sortedValues);

  /// The quantile thresholds dividing the domain.
  List<double> get thresholds {
    if (_sortedValues.isEmpty) return const [];
    final result = <double>[];
    for (var i = 1; i < quantileCount; i++) {
      result.add(_quantileOf(i / quantileCount));
    }
    return result;
  }

  @override
  OiScaleType get type => OiScaleType.quantile;

  @override
  double get atom => (rangeExtent / quantileCount).abs();

  @override
  double toPixel(double value) {
    final bin = _binOf(value);
    final bandWidth = rangeExtent / quantileCount;
    return clampPixel(rangeMin + (bin + 0.5) * bandWidth);
  }

  @override
  double fromPixel(double position) {
    if (_sortedValues.isEmpty) return 0;
    final bandWidth = rangeExtent / quantileCount;
    if (bandWidth == 0) return _sortedValues.first;
    var bin = ((position - rangeMin) / bandWidth).floor();
    bin = bin.clamp(0, quantileCount - 1);
    // Return the median of the bin.
    final lo = bin == 0 ? 0.0 : bin / quantileCount;
    final hi = (bin + 1) / quantileCount;
    return _quantileOf((lo + hi) / 2);
  }

  @override
  List<OiTick<double>> buildTicks({int count = 5}) {
    final ticks = <OiTick<double>>[];
    if (_sortedValues.isEmpty) return ticks;
    // Generate ticks at each quantile boundary.
    ticks.add(OiTick(value: _sortedValues.first, position: rangeMin));
    for (var i = 1; i < quantileCount; i++) {
      final q = _quantileOf(i / quantileCount);
      ticks.add(OiTick(value: q, position: toPixel(q)));
    }
    ticks.add(OiTick(value: _sortedValues.last, position: rangeMax));
    return ticks;
  }

  int _binOf(double value) {
    if (_sortedValues.isEmpty) return 0;
    final t = thresholds;
    for (var i = 0; i < t.length; i++) {
      if (value < t[i]) return i;
    }
    return quantileCount - 1;
  }

  double _quantileOf(double p) {
    if (_sortedValues.isEmpty) return 0;
    if (_sortedValues.length == 1) return _sortedValues.first;
    final index = p * (_sortedValues.length - 1);
    final lo = index.floor();
    final hi = index.ceil();
    if (lo == hi) return _sortedValues[lo];
    final frac = index - lo;
    return _sortedValues[lo] * (1 - frac) + _sortedValues[hi] * frac;
  }

  /// Creates a copy with optionally overridden values.
  OiQuantileScale copyWith({
    List<double>? values,
    double? rangeMin,
    double? rangeMax,
    bool? clamp,
    int? quantileCount,
  }) {
    return OiQuantileScale(
      values: values ?? _sortedValues,
      rangeMin: rangeMin ?? this.rangeMin,
      rangeMax: rangeMax ?? this.rangeMax,
      clamp: clamp ?? this.clamp,
      quantileCount: quantileCount ?? this.quantileCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiQuantileScale &&
          listEquals(other._sortedValues, _sortedValues) &&
          other.rangeMin == rangeMin &&
          other.rangeMax == rangeMax &&
          other.clamp == clamp &&
          other.quantileCount == quantileCount;

  @override
  int get hashCode => Object.hashAll([
    Object.hashAll(_sortedValues),
    rangeMin,
    rangeMax,
    clamp,
    quantileCount,
  ]);
}
