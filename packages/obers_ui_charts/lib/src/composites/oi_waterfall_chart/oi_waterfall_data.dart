import 'package:flutter/painting.dart';

/// A single data series for a waterfall chart.
///
/// Holds raw domain objects and mapper functions for extracting category labels,
/// numeric values, and an optional "total" flag. Running totals and bar
/// positions are computed at render time.
///
/// {@category Composites}
class OiWaterfallSeries<T> {
  /// Creates an [OiWaterfallSeries].
  const OiWaterfallSeries({
    required this.id,
    required this.label,
    required this.data,
    required this.categoryMapper,
    required this.valueMapper,
    this.isTotal,
    this.color,
    this.visible = true,
    this.semanticLabel,
  });

  /// Unique identifier for this series.
  final String id;

  /// Human-readable label for accessibility.
  final String label;

  /// The raw data items.
  final List<T> data;

  /// Extracts the category/label for each bar.
  final String Function(T item) categoryMapper;

  /// Extracts the numeric value for each bar.
  ///
  /// Positive values extend upward from the running total; negative values
  /// extend downward. "Total" bars always start at zero and represent the
  /// cumulative sum up to that point.
  final num Function(T item) valueMapper;

  /// Returns `true` if a given item represents a total/summary bar.
  ///
  /// Total bars start at zero (the baseline) and display the full running
  /// total rather than an incremental change. When null, no bars are totals.
  final bool Function(T item)? isTotal;

  /// Optional series color override. When null, the chart default is used.
  final Color? color;

  /// Whether this series is visible.
  final bool visible;

  /// Accessibility label for screen readers.
  final String? semanticLabel;
}

/// A computed waterfall bar ready for rendering.
///
/// Encodes the absolute canvas positions (baseline and top) of each bar,
/// along with semantic metadata for coloring and accessibility.
///
/// {@category Composites}
class OiWaterfallBar {
  /// Creates an [OiWaterfallBar].
  const OiWaterfallBar({
    required this.category,
    required this.value,
    required this.runningTotal,
    required this.barStart,
    required this.barEnd,
    required this.isPositive,
    required this.isTotal,
  });

  /// The category label for this bar.
  final String category;

  /// The incremental value this bar represents.
  final double value;

  /// The cumulative running total after this bar.
  final double runningTotal;

  /// The y-value at which this bar starts (bottom of the floating bar).
  final double barStart;

  /// The y-value at which this bar ends (top of the floating bar).
  final double barEnd;

  /// Whether the incremental [value] is positive (true) or negative (false).
  final bool isPositive;

  /// Whether this is a total/summary bar (starts from the axis baseline).
  final bool isTotal;

  @override
  String toString() =>
      'OiWaterfallBar($category: $value, running: $runningTotal)';
}

/// Computes waterfall bars from a list of [OiWaterfallSeries].
///
/// Returns a flat list of [OiWaterfallBar] instances with positions calculated
/// so that each incremental bar starts where the previous one ended.
///
/// Total bars always start at 0 and extend to the current cumulative sum.
List<OiWaterfallBar> computeWaterfallBars<T>(OiWaterfallSeries<T> series) {
  final bars = <OiWaterfallBar>[];
  var runningTotal = 0.0;

  for (final item in series.data) {
    final category = series.categoryMapper(item);
    final value = series.valueMapper(item).toDouble();
    final total = series.isTotal?.call(item) ?? false;

    double barStart;
    double barEnd;

    if (total) {
      // Total bars start at zero and go to the cumulative sum.
      runningTotal = value != 0 ? value : runningTotal;
      barStart = 0;
      barEnd = runningTotal;
    } else {
      barStart = runningTotal;
      barEnd = runningTotal + value;
      runningTotal += value;
    }

    bars.add(
      OiWaterfallBar(
        category: category,
        value: value,
        runningTotal: runningTotal,
        barStart: barStart,
        barEnd: barEnd,
        isPositive: value >= 0,
        isTotal: total,
      ),
    );
  }

  return bars;
}
