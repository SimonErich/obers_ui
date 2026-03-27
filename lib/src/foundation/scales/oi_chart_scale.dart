/// The type of a chart scale, used to identify the mapping strategy.
///
/// {@category Foundation}
enum OiScaleType {
  /// Continuous linear mapping.
  linear,

  /// Continuous logarithmic mapping.
  logarithmic,

  /// Continuous time-based mapping.
  time,

  /// Ordinal mapping to category centers.
  category,

  /// Ordinal mapping to band (bar chart) regions.
  band,

  /// Ordinal mapping to discrete points.
  point,

  /// Statistical quantile bucketing.
  quantile,

  /// Threshold-based bucketing.
  threshold,
}

/// A single tick mark on a chart axis.
///
/// {@category Foundation}
class OiScaleTick<T> {
  /// Creates an [OiScaleTick].
  const OiScaleTick({required this.value, this.label});

  /// The domain value this tick represents.
  final T value;

  /// An optional display label for this tick. Defaults to [value.toString()].
  final String? label;
}
