import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'package:obers_ui_charts/src/foundation/oi_chart_marker.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OiSeriesFill
// ─────────────────────────────────────────────────────────────────────────────

/// Describes how a series area is filled.
///
/// {@category Models}
@immutable
class OiSeriesFill {
  const OiSeriesFill._({this.color, this.gradient});

  /// A solid color fill.
  const OiSeriesFill.solid(Color color) : this._(color: color);

  /// A gradient fill.
  const OiSeriesFill.gradient(Gradient gradient) : this._(gradient: gradient);

  /// The solid fill color, or null if gradient is used.
  final Color? color;

  /// The gradient fill, or null if solid color is used.
  final Gradient? gradient;

  /// Whether this is a solid fill.
  bool get isSolid => color != null;

  /// Whether this is a gradient fill.
  bool get isGradient => gradient != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiSeriesFill &&
        other.color == color &&
        other.gradient == gradient;
  }

  @override
  int get hashCode => Object.hash(color, gradient);

  @override
  String toString() {
    if (isSolid) return 'OiSeriesFill.solid($color)';
    return 'OiSeriesFill.gradient($gradient)';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OiDataLabelPosition
// ─────────────────────────────────────────────────────────────────────────────

/// Position of a data label relative to its data point.
///
/// {@category Models}
enum OiDataLabelPosition {
  /// Above the data point.
  above,

  /// Below the data point.
  below,

  /// To the right of the data point.
  right,

  /// To the left of the data point.
  left,

  /// Centered on the data point.
  center,

  /// Automatically positioned to avoid overlap.
  auto,
}

// ─────────────────────────────────────────────────────────────────────────────
// OiDataLabelStyle
// ─────────────────────────────────────────────────────────────────────────────

/// Style configuration for data point labels.
///
/// {@category Models}
@immutable
class OiDataLabelStyle {
  /// Creates an [OiDataLabelStyle].
  const OiDataLabelStyle({
    this.show = false,
    this.position = OiDataLabelPosition.above,
    this.formatter,
    this.textStyle,
  });

  /// Whether to show data labels.
  final bool show;

  /// Position of the label relative to the data point.
  final OiDataLabelPosition position;

  /// Custom formatter for label text. When null, the y-value is used.
  final String Function(Object? value)? formatter;

  /// Text style for the label. When null, derived from theme.
  final TextStyle? textStyle;

  /// Creates a copy with optionally overridden values.
  OiDataLabelStyle copyWith({
    bool? show,
    OiDataLabelPosition? position,
    String Function(Object? value)? formatter,
    TextStyle? textStyle,
  }) {
    return OiDataLabelStyle(
      show: show ?? this.show,
      position: position ?? this.position,
      formatter: formatter ?? this.formatter,
      textStyle: textStyle ?? this.textStyle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiDataLabelStyle &&
        other.show == show &&
        other.position == position &&
        other.textStyle == textStyle;
  }

  @override
  int get hashCode => Object.hash(show, position, textStyle);
}

// ─────────────────────────────────────────────────────────────────────────────
// OiSeriesStyle
// ─────────────────────────────────────────────────────────────────────────────

/// Complete style definition for a chart series.
///
/// Supports base style, fill, markers, data labels, and state-based
/// overrides for hover, selected, and inactive states.
///
/// {@category Models}
@immutable
class OiSeriesStyle {
  /// Creates an [OiSeriesStyle].
  const OiSeriesStyle({
    this.strokeColor,
    this.strokeWidth,
    this.strokeCap,
    this.strokeJoin,
    this.dashPattern,
    this.fill,
    this.marker,
    this.dataLabelStyle,
    this.hoverStyle,
    this.selectedStyle,
    this.inactiveStyle,
  });

  /// Creates a dashed line style.
  factory OiSeriesStyle.dashed({
    Color? strokeColor,
    double? strokeWidth,
    List<double> pattern = const [5, 3],
  }) {
    return OiSeriesStyle(
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      dashPattern: pattern,
    );
  }

  /// Creates a dotted line style.
  factory OiSeriesStyle.dotted({
    Color? strokeColor,
    double? strokeWidth,
    List<double> pattern = const [2, 3],
  }) {
    return OiSeriesStyle(
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      dashPattern: pattern,
    );
  }

  /// The stroke color for lines and borders.
  final Color? strokeColor;

  /// The stroke width in logical pixels.
  final double? strokeWidth;

  /// The stroke cap style.
  final StrokeCap? strokeCap;

  /// The stroke join style.
  final StrokeJoin? strokeJoin;

  /// Dash pattern for the stroke. Null means solid line.
  final List<double>? dashPattern;

  /// Fill style for area regions.
  final OiSeriesFill? fill;

  /// Marker style for data point markers.
  final OiChartMarkerStyle? marker;

  /// Data label style configuration.
  final OiDataLabelStyle? dataLabelStyle;

  /// Style overrides applied when the series is hovered.
  final OiSeriesStyle? hoverStyle;

  /// Style overrides applied when the series is selected.
  final OiSeriesStyle? selectedStyle;

  /// Style overrides applied when the series is inactive (another is focused).
  final OiSeriesStyle? inactiveStyle;

  /// Merges this style with an [override], preferring override values.
  OiSeriesStyle merge(OiSeriesStyle? override) {
    if (override == null) return this;
    return OiSeriesStyle(
      strokeColor: override.strokeColor ?? strokeColor,
      strokeWidth: override.strokeWidth ?? strokeWidth,
      strokeCap: override.strokeCap ?? strokeCap,
      strokeJoin: override.strokeJoin ?? strokeJoin,
      dashPattern: override.dashPattern ?? dashPattern,
      fill: override.fill ?? fill,
      marker: override.marker ?? marker,
      dataLabelStyle: override.dataLabelStyle ?? dataLabelStyle,
      hoverStyle: override.hoverStyle ?? hoverStyle,
      selectedStyle: override.selectedStyle ?? selectedStyle,
      inactiveStyle: override.inactiveStyle ?? inactiveStyle,
    );
  }

  /// Creates a copy with optionally overridden values.
  OiSeriesStyle copyWith({
    Color? strokeColor,
    double? strokeWidth,
    StrokeCap? strokeCap,
    StrokeJoin? strokeJoin,
    List<double>? dashPattern,
    OiSeriesFill? fill,
    OiChartMarkerStyle? marker,
    OiDataLabelStyle? dataLabelStyle,
    OiSeriesStyle? hoverStyle,
    OiSeriesStyle? selectedStyle,
    OiSeriesStyle? inactiveStyle,
  }) {
    return OiSeriesStyle(
      strokeColor: strokeColor ?? this.strokeColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      strokeCap: strokeCap ?? this.strokeCap,
      strokeJoin: strokeJoin ?? this.strokeJoin,
      dashPattern: dashPattern ?? this.dashPattern,
      fill: fill ?? this.fill,
      marker: marker ?? this.marker,
      dataLabelStyle: dataLabelStyle ?? this.dataLabelStyle,
      hoverStyle: hoverStyle ?? this.hoverStyle,
      selectedStyle: selectedStyle ?? this.selectedStyle,
      inactiveStyle: inactiveStyle ?? this.inactiveStyle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiSeriesStyle &&
        other.strokeColor == strokeColor &&
        other.strokeWidth == strokeWidth &&
        other.strokeCap == strokeCap &&
        other.strokeJoin == strokeJoin &&
        listEquals(other.dashPattern, dashPattern) &&
        other.fill == fill &&
        other.marker == marker &&
        other.dataLabelStyle == dataLabelStyle &&
        other.hoverStyle == hoverStyle &&
        other.selectedStyle == selectedStyle &&
        other.inactiveStyle == inactiveStyle;
  }

  @override
  int get hashCode => Object.hash(
    strokeColor,
    strokeWidth,
    strokeCap,
    strokeJoin,
    dashPattern == null ? null : Object.hashAll(dashPattern!),
    fill,
    marker,
    dataLabelStyle,
    hoverStyle,
    selectedStyle,
    inactiveStyle,
  );
}
