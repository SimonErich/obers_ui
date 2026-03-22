import 'package:flutter/painting.dart';

/// A category (group) of bars in a bar chart.
///
/// Each category has a [label] displayed along the category axis and a list
/// of [values] — one per series. For a single-series chart, provide a
/// single-element list.
///
/// {@category Composites}
class OiBarCategory {
  /// Creates an [OiBarCategory].
  const OiBarCategory({
    required this.label,
    required this.values,
    this.colors,
  });

  /// The display label for this category.
  final String label;

  /// The bar values — one per series.
  final List<double> values;

  /// Optional per-bar color overrides (one per series).
  final List<Color>? colors;
}

/// A named data series in a bar chart.
///
/// When multiple series are provided to [OiBarChart], bars are grouped
/// or stacked per category.
///
/// {@category Composites}
class OiBarSeries {
  /// Creates an [OiBarSeries].
  const OiBarSeries({required this.label, this.color});

  /// The display name for this series (shown in legend).
  final String label;

  /// An optional color override for all bars in this series.
  final Color? color;
}
