import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'package:obers_ui/src/foundation/theme/oi_color_scheme.dart';

/// A color palette for chart and data-visualization widgets.
///
/// Provides [categorical] colors for series differentiation, semantic colors
/// for directional meaning ([positive], [negative], [neutral], [highlight]),
/// and optional gradient scales ([sequential], [diverging]) for continuous
/// data mapping.
///
/// The categorical palette defaults to the 8-color list from
/// `context.colors.chart` (via `OiColorScheme`). Each level of the override
/// cascade (global theme → chart-local → series → point) can supply its own
/// [OiChartPalette] to customise colors at any granularity.
///
/// {@category Foundation}
@immutable
class OiChartPalette {
  /// Creates an [OiChartPalette] with explicit values.
  const OiChartPalette({
    required this.categorical,
    required this.positive,
    required this.negative,
    required this.neutral,
    required this.highlight,
    this.sequential,
    this.diverging,
  });

  /// Creates a minimal single-color palette for simple charts.
  ///
  /// The [color] is used as the sole categorical entry. Semantic colors
  /// default to the provided [color] unless explicitly overridden.
  /// This parallels `OiChartData.atom` for single-series charts.
  factory OiChartPalette.atom({
    required Color color,
    Color? positive,
    Color? negative,
    Color? neutral,
    Color? highlight,
  }) {
    return OiChartPalette(
      categorical: [color],
      positive: positive ?? color,
      negative: negative ?? color,
      neutral: neutral ?? color,
      highlight: highlight ?? color,
    );
  }

  /// Creates a palette derived from an [OiColorScheme].
  ///
  /// Categorical colors default from [OiColorScheme.chart]. Semantic colors
  /// are mapped from the scheme's semantic swatches: [OiColorScheme.success]
  /// → [positive], [OiColorScheme.error] → [negative],
  /// [OiColorScheme.info] → [neutral], and [OiColorScheme.warning] →
  /// [highlight].
  factory OiChartPalette.colors(OiColorScheme scheme) {
    return OiChartPalette(
      categorical: scheme.chart,
      positive: scheme.success.base,
      negative: scheme.error.base,
      neutral: scheme.info.base,
      highlight: scheme.warning.base,
    );
  }

  /// An ordered list of categorical colors for chart series.
  ///
  /// Series are assigned colors by index (wrapping with modulo). Override at
  /// global theme, chart-local, or series level to change the colour sequence.
  final List<Color> categorical;

  /// Color representing a positive value (e.g. profit, gain, up).
  final Color positive;

  /// Color representing a negative value (e.g. loss, down, decline).
  final Color negative;

  /// Color representing a neutral or baseline value.
  final Color neutral;

  /// Color used to highlight a specific data point or series.
  final Color highlight;

  /// Optional sequential gradient for mapping continuous data ranges.
  ///
  /// When provided, charts may interpolate across these stops for heat-maps,
  /// choropleth maps, or other continuous-scale visuals.
  final List<Color>? sequential;

  /// Optional diverging gradient for mapping data ranges that have a meaningful
  /// midpoint (e.g. profit/loss around zero).
  ///
  /// Typically a three-stop gradient: negative → neutral → positive.
  final List<Color>? diverging;

  /// Resolves a categorical color at [index], cycling through the palette.
  Color operator [](int index) => categorical[index % categorical.length];

  /// Creates a copy with optionally overridden values.
  OiChartPalette copyWith({
    List<Color>? categorical,
    Color? positive,
    Color? negative,
    Color? neutral,
    Color? highlight,
    List<Color>? sequential,
    List<Color>? diverging,
  }) {
    return OiChartPalette(
      categorical: categorical ?? this.categorical,
      positive: positive ?? this.positive,
      negative: negative ?? this.negative,
      neutral: neutral ?? this.neutral,
      highlight: highlight ?? this.highlight,
      sequential: sequential ?? this.sequential,
      diverging: diverging ?? this.diverging,
    );
  }

  /// Merges [other] on top of this palette.
  ///
  /// Non-null fields in [other] take precedence.
  OiChartPalette merge(OiChartPalette? other) {
    if (other == null) return this;
    return copyWith(
      categorical: other.categorical,
      positive: other.positive,
      negative: other.negative,
      neutral: other.neutral,
      highlight: other.highlight,
      sequential: other.sequential,
      diverging: other.diverging,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiChartPalette) return false;
    if (!listEquals(categorical, other.categorical)) return false;
    if (sequential != null && other.sequential != null) {
      if (!listEquals(sequential, other.sequential)) return false;
    } else if (sequential != other.sequential) {
      return false;
    }
    if (diverging != null && other.diverging != null) {
      if (!listEquals(diverging, other.diverging)) return false;
    } else if (diverging != other.diverging) {
      return false;
    }
    return other.positive == positive &&
        other.negative == negative &&
        other.neutral == neutral &&
        other.highlight == highlight;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(categorical),
    positive,
    negative,
    neutral,
    highlight,
    sequential == null ? null : Object.hashAll(sequential!),
    diverging == null ? null : Object.hashAll(diverging!),
  );
}
