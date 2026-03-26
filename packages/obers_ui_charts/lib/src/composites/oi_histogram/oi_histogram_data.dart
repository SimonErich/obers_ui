import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:obers_ui_charts/src/models/oi_axis_range.dart';

/// A single data series for a histogram chart.
///
/// Holds raw domain objects and mapper functions for extracting numeric
/// values, plus bin configuration. Bins are computed lazily at render time
/// via [computeBins].
///
/// {@category Composites}
class OiHistogramSeries<T> {
  /// Creates an [OiHistogramSeries].
  const OiHistogramSeries({
    required this.id,
    required this.label,
    required this.data,
    required this.valueMapper,
    this.binCount,
    this.binWidth,
    this.binRange,
    this.color,
    this.visible = true,
    this.semanticLabel,
  });

  /// Unique identifier for this series.
  final String id;

  /// Human-readable label for legends and accessibility.
  final String label;

  /// The raw data items.
  final List<T> data;

  /// Extracts a numeric value from each domain object.
  final num Function(T item) valueMapper;

  /// Number of equal-width bins. When null, a default is chosen from the
  /// data size using the Sturges formula.
  final int? binCount;

  /// Explicit bin width. When provided, overrides [binCount].
  final double? binWidth;

  /// Explicit min/max range for the bins. When null, the data range is used.
  final OiAxisRange<double>? binRange;

  /// Optional series color override. When null, the chart palette is used.
  final Color? color;

  /// Whether this series is visible.
  final bool visible;

  /// Accessibility label for screen readers.
  final String? semanticLabel;
}

/// A computed histogram bin.
///
/// Represents a contiguous interval `[start, end)` in the data domain,
/// together with the count of values that fall within it and the relative
/// frequency as a fraction of the total.
///
/// {@category Composites}
class OiHistogramBin {
  /// Creates an [OiHistogramBin].
  const OiHistogramBin({
    required this.start,
    required this.end,
    required this.count,
    required this.frequency,
  });

  /// Left edge of the bin (inclusive).
  final double start;

  /// Right edge of the bin (exclusive, except for the last bin which is
  /// inclusive on both sides).
  final double end;

  /// Number of values that fall within this bin.
  final int count;

  /// Relative frequency: `count / total`. In `[0.0, 1.0]`.
  final double frequency;

  /// The midpoint of the bin, useful for axis labelling.
  double get midpoint => (start + end) / 2;

  @override
  String toString() =>
      'OiHistogramBin([$start, $end), count: $count, freq: $frequency)';
}

/// Computes histogram bins from a list of numeric [values].
///
/// Either [binCount] or [binWidth] may be supplied:
/// - [binWidth] takes priority over [binCount].
/// - When neither is provided, the bin count is estimated with the
///   Sturges formula: `ceil(log2(n)) + 1` (minimum 1).
///
/// An explicit `[rangeMin, rangeMax]` can be passed via [rangeMin]/[rangeMax]
/// to override the data-derived extents; useful when comparing multiple
/// series on the same axis.
///
/// Returns an empty list when [values] is empty.
List<OiHistogramBin> computeBins(
  List<num> values, {
  int? binCount,
  double? binWidth,
  double? rangeMin,
  double? rangeMax,
}) {
  if (values.isEmpty) return const [];

  final doubles = values.map((v) => v.toDouble()).toList();
  final dataMin = rangeMin ?? doubles.reduce(math.min);
  final dataMax = rangeMax ?? doubles.reduce(math.max);

  // Guard against degenerate range.
  if (dataMin == dataMax) {
    return [
      OiHistogramBin(
        start: dataMin,
        end: dataMax + 1,
        count: doubles.length,
        frequency: 1,
      ),
    ];
  }

  final double effectiveWidth;
  if (binWidth != null && binWidth > 0) {
    effectiveWidth = binWidth;
  } else {
    final n =
        binCount ??
        (values.length <= 1
            ? 1
            : (math.log(values.length) / math.log(2)).ceil() + 1);
    effectiveWidth = (dataMax - dataMin) / math.max(n, 1);
  }

  final numBins = ((dataMax - dataMin) / effectiveWidth).ceil();
  final bins = List<int>.filled(math.max(numBins, 1), 0);

  for (final v in doubles) {
    if (v < dataMin || v > dataMax) continue;
    var idx = ((v - dataMin) / effectiveWidth).floor();
    // Clamp the last value into the final bin.
    if (idx >= bins.length) idx = bins.length - 1;
    bins[idx]++;
  }

  final total = doubles.length;
  return [
    for (var i = 0; i < bins.length; i++)
      OiHistogramBin(
        start: dataMin + i * effectiveWidth,
        end: dataMin + (i + 1) * effectiveWidth,
        count: bins[i],
        frequency: total > 0 ? bins[i] / total : 0.0,
      ),
  ];
}
