import 'package:flutter/foundation.dart';

import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_axis_painter.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_formatters.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_scale.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Axis Scale Type
// ─────────────────────────────────────────────────────────────────────────────

/// The scale type for an axis.
///
/// Mirrors [OiScaleType] but exposed as part of the public axis API so
/// consumers do not need to import the foundation scales layer directly.
///
/// {@category Composites}
enum OiAxisScaleType {
  /// Maps a continuous numeric domain linearly to a pixel range.
  linear,

  /// Maps a continuous numeric domain logarithmically to a pixel range.
  logarithmic,

  /// Maps [DateTime] values linearly to a pixel range.
  time,

  /// Maps discrete string categories to pixel positions (no width).
  category,

  /// Maps discrete string categories to pixel bands with width.
  band,

  /// Maps discrete string categories to evenly-spaced point positions.
  point,

  /// Maps continuous numeric input to discrete output based on quantiles.
  quantile,

  /// Maps continuous numeric input to discrete output based on thresholds.
  threshold;

  /// Converts this to the foundation [OiScaleType].
  OiScaleType toScaleType() => switch (this) {
    OiAxisScaleType.linear => OiScaleType.linear,
    OiAxisScaleType.logarithmic => OiScaleType.logarithmic,
    OiAxisScaleType.time => OiScaleType.time,
    OiAxisScaleType.category => OiScaleType.category,
    OiAxisScaleType.band => OiScaleType.band,
    OiAxisScaleType.point => OiScaleType.point,
    OiAxisScaleType.quantile => OiScaleType.quantile,
    OiAxisScaleType.threshold => OiScaleType.threshold,
  };

  /// Creates an [OiAxisScaleType] from the foundation [OiScaleType].
  static OiAxisScaleType fromScaleType(OiScaleType type) => switch (type) {
    OiScaleType.linear => OiAxisScaleType.linear,
    OiScaleType.logarithmic => OiAxisScaleType.logarithmic,
    OiScaleType.time => OiAxisScaleType.time,
    OiScaleType.category => OiAxisScaleType.category,
    OiScaleType.band => OiAxisScaleType.band,
    OiScaleType.point => OiAxisScaleType.point,
    OiScaleType.quantile => OiAxisScaleType.quantile,
    OiScaleType.threshold => OiAxisScaleType.threshold,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Axis Position
// ─────────────────────────────────────────────────────────────────────────────

/// Position of an axis relative to the chart plot area.
///
/// {@category Composites}
enum OiAxisPosition {
  /// Top edge — typically a secondary x-axis.
  top,

  /// Bottom edge — typically the primary x-axis.
  bottom,

  /// Left edge — typically the primary y-axis.
  left,

  /// Right edge — typically a secondary y-axis.
  right;

  /// Converts this position to the foundation [OiChartAxisEdge].
  OiChartAxisEdge toEdge() => switch (this) {
    OiAxisPosition.top => OiChartAxisEdge.top,
    OiAxisPosition.bottom => OiChartAxisEdge.bottom,
    OiAxisPosition.left => OiChartAxisEdge.left,
    OiAxisPosition.right => OiChartAxisEdge.right,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Tick Strategy
// ─────────────────────────────────────────────────────────────────────────────

/// Strategy for generating axis tick marks.
///
/// {@category Composites}
enum OiTickStrategy {
  /// Auto-compute tick marks based on the scale and available space.
  auto,

  /// Use evenly-spaced ticks with count determined by [divisions].
  even,

  /// Show a tick at every data point.
  all,

  /// Show only the first and last tick (min/max).
  minMax,
}

// ─────────────────────────────────────────────────────────────────────────────
// Title Alignment
// ─────────────────────────────────────────────────────────────────────────────

/// Alignment of the axis title relative to the axis.
///
/// {@category Composites}
enum OiAxisTitleAlignment {
  /// Align the title at the start (left for horizontal, top for vertical).
  start,

  /// Center the title along the axis.
  center,

  /// Align the title at the end (right for horizontal, bottom for vertical).
  end,
}

// ─────────────────────────────────────────────────────────────────────────────
// OiChartAxis<TDomain>
// ─────────────────────────────────────────────────────────────────────────────

/// Configuration for a chart axis.
///
/// [TDomain] is the type of values on this axis — typically [double] for
/// numeric axes, [DateTime] for time axes, or [String] for category axes.
///
/// Used by Cartesian charts ([OiLineChart], [OiBarChart], [OiScatterPlot])
/// to configure axis labels, grid divisions, and value formatting.
///
/// ```dart
/// OiChartAxis<double>(
///   label: 'Revenue',
///   scaleType: OiAxisScaleType.linear,
///   position: OiAxisPosition.left,
///   showGrid: true,
///   formatter: (value, ctx) => '\$${value.toStringAsFixed(0)}',
/// )
/// ```
///
/// {@category Composites}
@immutable
class OiChartAxis<TDomain> {
  /// Creates an [OiChartAxis].
  const OiChartAxis({
    this.label,
    this.labels,
    this.format,
    this.divisions,
    this.min,
    this.max,
    this.scaleType,
    this.position,
    this.formatter,
    this.tickStrategy = OiTickStrategy.auto,
    this.maxVisibleTicks,
    this.showGrid = true,
    this.showAxisLine = true,
    this.showTickMarks = true,
    this.domainMin,
    this.domainMax,
    this.labelOverflow = OiChartLabelOverflow.skip,
    this.titleAlignment = OiAxisTitleAlignment.center,
  });

  // ── Legacy fields (backward-compatible) ────────────────────────────────

  /// An optional axis title displayed beside the axis.
  final String? label;

  /// Fixed tick labels. When provided, these are displayed instead of
  /// auto-generated numeric labels.
  final List<String>? labels;

  /// A formatter for numeric tick values. When null, values are formatted
  /// using [double.toStringAsFixed] with appropriate precision.
  ///
  /// This is the legacy formatter; prefer [formatter] for new code.
  final String Function(double)? format;

  /// The number of grid divisions along this axis. Defaults vary by chart.
  final int? divisions;

  /// The minimum value for the axis range. When null, determined from data.
  ///
  /// Legacy field for double axes. Prefer [domainMin] for typed access.
  final double? min;

  /// The maximum value for the axis range. When null, determined from data.
  ///
  /// Legacy field for double axes. Prefer [domainMax] for typed access.
  final double? max;

  // ── New typed fields ───────────────────────────────────────────────────

  /// The scale type for this axis.
  ///
  /// Supports all 8 scale types: linear, logarithmic, time, category, band,
  /// point, quantile, threshold. When null, the chart infers the scale type
  /// from the data.
  final OiAxisScaleType? scaleType;

  /// Position of this axis relative to the chart plot area.
  ///
  /// Defaults to [OiAxisPosition.bottom] for x-axes and
  /// [OiAxisPosition.left] for y-axes when not specified.
  final OiAxisPosition? position;

  /// A type-safe formatter for tick values.
  ///
  /// Receives the domain value and a formatter context providing theme,
  /// locale, and scale information for context-aware formatting.
  final OiAxisFormatter<TDomain>? formatter;

  /// Strategy for generating tick marks.
  final OiTickStrategy tickStrategy;

  /// Responsive maximum number of visible ticks.
  ///
  /// When set, the resolved value limits how many tick labels are painted.
  /// Ticks are evenly distributed to meet the limit.
  final OiResponsive<int>? maxVisibleTicks;

  /// Whether to show grid lines for this axis.
  final bool showGrid;

  /// Whether to show the axis line.
  final bool showAxisLine;

  /// Whether to show tick marks along the axis.
  final bool showTickMarks;

  /// Typed minimum domain value override.
  ///
  /// When null, determined from data.
  final TDomain? domainMin;

  /// Typed maximum domain value override.
  ///
  /// When null, determined from data.
  final TDomain? domainMax;

  /// How to handle label text that would overlap or overflow.
  final OiChartLabelOverflow labelOverflow;

  /// Alignment of the axis title relative to the axis.
  final OiAxisTitleAlignment titleAlignment;

  // ── Formatting ─────────────────────────────────────────────────────────

  /// Formats a numeric [value] using [format], [formatter], or a sensible
  /// default.
  ///
  /// Maintained for backward compatibility with charts that use the legacy
  /// `format` callback.
  String formatValue(double value) {
    if (format != null) return format!(value);
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  // ── Copying ────────────────────────────────────────────────────────────

  /// Returns a copy of this axis with the specified fields replaced.
  OiChartAxis<TDomain> copyWith({
    String? label,
    List<String>? labels,
    String Function(double)? format,
    int? divisions,
    double? min,
    double? max,
    OiAxisScaleType? scaleType,
    OiAxisPosition? position,
    OiAxisFormatter<TDomain>? formatter,
    OiTickStrategy? tickStrategy,
    OiResponsive<int>? maxVisibleTicks,
    bool? showGrid,
    bool? showAxisLine,
    bool? showTickMarks,
    TDomain? domainMin,
    TDomain? domainMax,
    OiChartLabelOverflow? labelOverflow,
    OiAxisTitleAlignment? titleAlignment,
  }) {
    return OiChartAxis<TDomain>(
      label: label ?? this.label,
      labels: labels ?? this.labels,
      format: format ?? this.format,
      divisions: divisions ?? this.divisions,
      min: min ?? this.min,
      max: max ?? this.max,
      scaleType: scaleType ?? this.scaleType,
      position: position ?? this.position,
      formatter: formatter ?? this.formatter,
      tickStrategy: tickStrategy ?? this.tickStrategy,
      maxVisibleTicks: maxVisibleTicks ?? this.maxVisibleTicks,
      showGrid: showGrid ?? this.showGrid,
      showAxisLine: showAxisLine ?? this.showAxisLine,
      showTickMarks: showTickMarks ?? this.showTickMarks,
      domainMin: domainMin ?? this.domainMin,
      domainMax: domainMax ?? this.domainMax,
      labelOverflow: labelOverflow ?? this.labelOverflow,
      titleAlignment: titleAlignment ?? this.titleAlignment,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiChartAxis<TDomain> &&
        other.label == label &&
        listEquals(other.labels, labels) &&
        other.divisions == divisions &&
        other.min == min &&
        other.max == max &&
        other.scaleType == scaleType &&
        other.position == position &&
        other.tickStrategy == tickStrategy &&
        other.maxVisibleTicks == maxVisibleTicks &&
        other.showGrid == showGrid &&
        other.showAxisLine == showAxisLine &&
        other.showTickMarks == showTickMarks &&
        other.domainMin == domainMin &&
        other.domainMax == domainMax &&
        other.labelOverflow == labelOverflow &&
        other.titleAlignment == titleAlignment;
  }

  @override
  int get hashCode => Object.hash(
    label,
    labels == null ? null : Object.hashAll(labels!),
    divisions,
    min,
    max,
    scaleType,
    position,
    tickStrategy,
    maxVisibleTicks,
    showGrid,
    showAxisLine,
    showTickMarks,
    domainMin,
    domainMax,
    labelOverflow,
    titleAlignment,
  );

  @override
  String toString() =>
      'OiChartAxis<$TDomain>('
      'label: $label, '
      'scale: $scaleType, '
      'position: $position, '
      'grid: $showGrid, '
      'axisLine: $showAxisLine, '
      'ticks: $showTickMarks)';
}
