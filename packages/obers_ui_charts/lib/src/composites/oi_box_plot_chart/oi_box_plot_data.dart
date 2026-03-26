import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// Determines how the whiskers of a box plot are computed.
///
/// {@category Composites}
enum OiWhiskerMode {
  /// Whiskers extend to the minimum and maximum values in the dataset.
  minMax,

  /// Whiskers extend to 1.5× the interquartile range (IQR) beyond Q1 and Q3.
  ///
  /// Values beyond the whiskers are plotted as individual outlier dots.
  iqr1_5,

  /// Whiskers extend to the 5th and 95th percentiles.
  ///
  /// Values outside this range are plotted as individual outlier dots.
  percentile5_95,
}

/// Pre-computed statistical summary for one box in a box plot.
///
/// Contains the five-number summary (min, Q1, median, Q3, max), an optional
/// mean, and any outlier values that fall outside the whiskers.
///
/// {@category Composites}
class OiBoxPlotStats {
  /// Creates an [OiBoxPlotStats].
  const OiBoxPlotStats({
    required this.min,
    required this.q1,
    required this.median,
    required this.q3,
    required this.max,
    this.mean,
    this.outliers = const [],
  });

  /// Minimum value (lower whisker tip or lowest non-outlier).
  final double min;

  /// First quartile (lower edge of the box).
  final double q1;

  /// Median (line inside the box).
  final double median;

  /// Third quartile (upper edge of the box).
  final double q3;

  /// Maximum value (upper whisker tip or highest non-outlier).
  final double max;

  /// Optional mean value. When non-null, a mean dot is drawn in the box.
  final double? mean;

  /// Values that fall outside the whiskers and are drawn as individual dots.
  final List<double> outliers;

  /// Interquartile range (Q3 − Q1).
  double get iqr => q3 - q1;

  @override
  String toString() =>
      'OiBoxPlotStats(min: $min, q1: $q1, median: $median, '
      'q3: $q3, max: $max, mean: $mean, outliers: $outliers)';
}

/// Computes [OiBoxPlotStats] from a list of [values] using the given
/// `mode`.
///
/// Returns `null` when [values] is empty.
///
/// Outliers are computed only for [OiWhiskerMode.iqr1_5] and
/// [OiWhiskerMode.percentile5_95]; in [OiWhiskerMode.minMax] mode the
/// outliers list is always empty.
OiBoxPlotStats? computeBoxPlotStats(
  List<num> values, {
  OiWhiskerMode mode = OiWhiskerMode.minMax,
}) {
  if (values.isEmpty) return null;

  final sorted = values.map((v) => v.toDouble()).toList()..sort();
  final n = sorted.length;

  double percentile(double p) {
    final pos = p * (n - 1);
    final lower = pos.floor();
    final upper = pos.ceil();
    if (lower == upper) return sorted[lower];
    return sorted[lower] + (sorted[upper] - sorted[lower]) * (pos - lower);
  }

  final q1 = percentile(0.25);
  final median = percentile(0.50);
  final q3 = percentile(0.75);
  final mean = sorted.reduce((a, b) => a + b) / n;

  double whiskerMin;
  double whiskerMax;
  List<double> outliers;

  switch (mode) {
    case OiWhiskerMode.minMax:
      whiskerMin = sorted.first;
      whiskerMax = sorted.last;
      outliers = [];
    case OiWhiskerMode.iqr1_5:
      final iqr = q3 - q1;
      final lowerFence = q1 - 1.5 * iqr;
      final upperFence = q3 + 1.5 * iqr;
      final nonOutliers = sorted.where(
        (v) => v >= lowerFence && v <= upperFence,
      );
      whiskerMin = nonOutliers.isEmpty ? sorted.first : nonOutliers.first;
      whiskerMax = nonOutliers.isEmpty ? sorted.last : nonOutliers.last;
      outliers = sorted.where((v) => v < lowerFence || v > upperFence).toList();
    case OiWhiskerMode.percentile5_95:
      whiskerMin = percentile(0.05);
      whiskerMax = percentile(0.95);
      outliers = sorted.where((v) => v < whiskerMin || v > whiskerMax).toList();
  }

  return OiBoxPlotStats(
    min: whiskerMin,
    q1: q1,
    median: median,
    q3: q3,
    max: whiskerMax,
    mean: mean,
    outliers: outliers,
  );
}

/// A data series for a box plot chart.
///
/// Supports two APIs:
/// - **Raw-values API** — supply [valuesMapper] to extract a `List<num>` of
///   raw measurements per category. Statistics are computed automatically via
///   [computeBoxPlotStats].
/// - **Pre-computed API** — supply individual mappers ([minMapper],
///   [q1Mapper], [medianMapper], [q3Mapper], [maxMapper], [outliersMapper])
///   when statistics are already available in the domain model.
///
/// Exactly one of the two APIs must be used. If [valuesMapper] is provided it
/// takes precedence over the individual mappers.
///
/// {@category Composites}
class OiBoxPlotSeries<T> {
  /// Creates an [OiBoxPlotSeries] using the raw-values API.
  ///
  /// Provide [valuesMapper] to extract a list of numeric measurements per
  /// category. Statistics are derived automatically.
  const OiBoxPlotSeries({
    required this.id,
    required this.label,
    required this.data,
    required this.categoryMapper,
    this.valuesMapper,
    this.minMapper,
    this.q1Mapper,
    this.medianMapper,
    this.q3Mapper,
    this.maxMapper,
    this.outliersMapper,
    this.color,
    this.visible = true,
    this.semanticLabel,
  }) : assert(
         valuesMapper != null ||
             (minMapper != null &&
                 q1Mapper != null &&
                 medianMapper != null &&
                 q3Mapper != null &&
                 maxMapper != null),
         'Either valuesMapper or all pre-computed mappers '
         '(minMapper, q1Mapper, medianMapper, q3Mapper, maxMapper) '
         'must be provided.',
       );

  /// Unique identifier for this series.
  final String id;

  /// Human-readable label for legends and accessibility.
  final String label;

  /// The raw data items (one per box/category).
  final List<T> data;

  /// Extracts the category/label for each box.
  final String Function(T item) categoryMapper;

  // ── Raw-values API ────────────────────────────────────────────────────────

  /// Extracts a list of raw numeric measurements for a category.
  ///
  /// When provided, [computeBoxPlotStats] is called on each list.
  final List<num> Function(T item)? valuesMapper;

  // ── Pre-computed API ──────────────────────────────────────────────────────

  /// Extracts the minimum (lower whisker) value.
  final num Function(T item)? minMapper;

  /// Extracts the first quartile (Q1) value.
  final num Function(T item)? q1Mapper;

  /// Extracts the median value.
  final num Function(T item)? medianMapper;

  /// Extracts the third quartile (Q3) value.
  final num Function(T item)? q3Mapper;

  /// Extracts the maximum (upper whisker) value.
  final num Function(T item)? maxMapper;

  /// Extracts optional outlier values. When null, no outliers are shown.
  final List<num> Function(T item)? outliersMapper;

  /// Optional series color override. When null, the chart palette is used.
  final Color? color;

  /// Whether this series is visible.
  final bool visible;

  /// Accessibility label for screen readers.
  final String? semanticLabel;

  /// Resolves [OiBoxPlotStats] for a single [item].
  ///
  /// Uses the raw-values API when [valuesMapper] is set; otherwise assembles
  /// stats from the pre-computed mappers.
  OiBoxPlotStats? resolve(T item, OiWhiskerMode mode) {
    if (valuesMapper != null) {
      return computeBoxPlotStats(valuesMapper!(item), mode: mode);
    }

    // Pre-computed path — all individual mappers guaranteed non-null by assert.
    final outliers =
        outliersMapper?.call(item).map((v) => v.toDouble()).toList() ?? [];
    return OiBoxPlotStats(
      min: minMapper!(item).toDouble(),
      q1: q1Mapper!(item).toDouble(),
      median: medianMapper!(item).toDouble(),
      q3: q3Mapper!(item).toDouble(),
      max: maxMapper!(item).toDouble(),
      outliers: outliers,
    );
  }
}

/// A fully resolved box ready for painting.
///
/// Contains the category label, computed statistics, and the resolved color.
///
/// {@category Composites}
class OiResolvedBox {
  /// Creates an [OiResolvedBox].
  const OiResolvedBox({
    required this.category,
    required this.stats,
    required this.color,
    required this.seriesIndex,
    required this.categoryIndex,
  });

  /// The category label for this box.
  final String category;

  /// The computed statistical summary.
  final OiBoxPlotStats stats;

  /// The resolved fill color for this box.
  final Color color;

  /// Index of the parent series.
  final int seriesIndex;

  /// Index within the category axis.
  final int categoryIndex;

  @override
  String toString() => 'OiResolvedBox($category: $stats)';
}

/// Resolves all boxes for a list of [OiBoxPlotSeries], returning a flat list
/// of [OiResolvedBox] instances ready for the painter.
///
/// Categories are collected from the first visible series that defines them.
/// Each series contributes one [OiResolvedBox] per category.
List<OiResolvedBox> resolveBoxes<T>(
  List<OiBoxPlotSeries<T>> seriesList,
  OiWhiskerMode mode,
  List<Color> palette,
) {
  final result = <OiResolvedBox>[];

  for (var si = 0; si < seriesList.length; si++) {
    final series = seriesList[si];
    if (!series.visible || series.data.isEmpty) continue;

    final color = series.color ?? palette[si % math.max(palette.length, 1)];

    for (var ci = 0; ci < series.data.length; ci++) {
      final item = series.data[ci];
      final category = series.categoryMapper(item);
      final stats = series.resolve(item, mode);
      if (stats == null) continue;

      result.add(
        OiResolvedBox(
          category: category,
          stats: stats,
          color: color,
          seriesIndex: si,
          categoryIndex: ci,
        ),
      );
    }
  }

  return result;
}
