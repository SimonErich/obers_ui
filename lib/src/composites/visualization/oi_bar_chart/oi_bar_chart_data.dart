import 'package:flutter/painting.dart';
import 'package:obers_ui/obers_ui.dart' show OiBarChart;
import 'package:obers_ui/src/composites/visualization/oi_bar_chart/oi_bar_chart.dart' show OiBarChart;

/// The layout mode of an [OiBarChart].
///
/// Controls whether bars are grouped side-by-side, stacked, and whether
/// they are rendered vertically or horizontally.
///
/// {@category Composites}
enum OiBarChartMode {
  /// Bars for each series are placed side-by-side within each category
  /// (vertical orientation).
  grouped,

  /// Bars for each series are stacked on top of each other within each
  /// category (vertical orientation).
  stacked,

  /// Bars for each series are placed side-by-side within each category
  /// (horizontal orientation).
  horizontalGrouped,

  /// Bars for each series are stacked end-to-end within each category
  /// (horizontal orientation).
  horizontalStacked,
}

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
