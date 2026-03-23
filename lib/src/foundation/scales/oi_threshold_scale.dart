import 'package:flutter/foundation.dart';

import 'package:obers_ui/src/foundation/scales/oi_chart_scale.dart';

/// A threshold scale that maps continuous numeric input to discrete
/// output segments based on explicit breakpoints.
///
/// The [thresholds] list defines the boundaries between segments. A
/// value falling below the first threshold maps to the first segment,
/// between the first and second threshold maps to the second segment,
/// and so on.
///
/// This is useful for choropleth maps, heatmaps, and any visualization
/// where continuous values should be bucketed into discrete bands.
///
/// {@category Foundation}
@immutable
class OiThresholdScale extends OiChartScale<double> {
  /// Creates an [OiThresholdScale].
  ///
  /// The [thresholds] list must be sorted in ascending order.
  const OiThresholdScale({
    required this.thresholds,
    required super.rangeMin,
    required super.rangeMax,
    super.clamp,
  });

  /// The sorted ascending breakpoints dividing the domain.
  final List<double> thresholds;

  /// The number of output segments (thresholds + 1).
  int get segmentCount => thresholds.length + 1;

  @override
  OiScaleType get type => OiScaleType.threshold;

  @override
  double get atom => (rangeExtent / segmentCount).abs();

  @override
  double toPixel(double value) {
    final bin = _binOf(value);
    final bandWidth = rangeExtent / segmentCount;
    return clampPixel(rangeMin + (bin + 0.5) * bandWidth);
  }

  @override
  double fromPixel(double position) {
    if (thresholds.isEmpty) return 0;
    final bandWidth = rangeExtent / segmentCount;
    if (bandWidth == 0) return thresholds.first;
    var bin = ((position - rangeMin) / bandWidth).floor();
    bin = bin.clamp(0, segmentCount - 1);
    // Return the midpoint of the bin.
    if (bin == 0) {
      return thresholds.first -
          (thresholds.length > 1 ? thresholds[1] - thresholds.first : 1);
    }
    if (bin >= thresholds.length) return thresholds.last;
    return (thresholds[bin - 1] + thresholds[bin]) / 2;
  }

  @override
  List<OiTick<double>> buildTicks({int count = 5}) {
    return [for (final t in thresholds) OiTick(value: t, position: toPixel(t))];
  }

  int _binOf(double value) {
    for (var i = 0; i < thresholds.length; i++) {
      if (value < thresholds[i]) return i;
    }
    return thresholds.length;
  }

  /// Creates a copy with optionally overridden values.
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
          listEquals(other.thresholds, thresholds) &&
          other.rangeMin == rangeMin &&
          other.rangeMax == rangeMax &&
          other.clamp == clamp;

  @override
  int get hashCode =>
      Object.hashAll([Object.hashAll(thresholds), rangeMin, rangeMax, clamp]);
}
