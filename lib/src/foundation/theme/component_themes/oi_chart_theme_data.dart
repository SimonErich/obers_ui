import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'package:obers_ui/src/foundation/theme/component_themes/oi_chart_palette.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Sub-theme: Axis
// ─────────────────────────────────────────────────────────────────────────────

/// Visual tokens for chart axes (tick marks, labels, lines).
///
/// {@category Foundation}
@immutable
class OiChartAxisTheme {
  /// Creates an [OiChartAxisTheme].
  const OiChartAxisTheme({
    this.lineColor,
    this.lineWidth,
    this.tickColor,
    this.tickLength,
    this.tickWidth,
    this.labelStyle,
    this.labelColor,
    this.titleStyle,
    this.titleColor,
  });

  /// Color of the axis line.
  final Color? lineColor;

  /// Width of the axis line in logical pixels.
  final double? lineWidth;

  /// Color of tick marks.
  final Color? tickColor;

  /// Length of tick marks in logical pixels.
  final double? tickLength;

  /// Width of tick marks in logical pixels.
  final double? tickWidth;

  /// Text style for axis labels.
  final TextStyle? labelStyle;

  /// Color override for axis labels (applied on top of [labelStyle]).
  final Color? labelColor;

  /// Text style for the axis title.
  final TextStyle? titleStyle;

  /// Color override for the axis title.
  final Color? titleColor;

  /// Creates a copy with optionally overridden values.
  OiChartAxisTheme copyWith({
    Color? lineColor,
    double? lineWidth,
    Color? tickColor,
    double? tickLength,
    double? tickWidth,
    TextStyle? labelStyle,
    Color? labelColor,
    TextStyle? titleStyle,
    Color? titleColor,
  }) {
    return OiChartAxisTheme(
      lineColor: lineColor ?? this.lineColor,
      lineWidth: lineWidth ?? this.lineWidth,
      tickColor: tickColor ?? this.tickColor,
      tickLength: tickLength ?? this.tickLength,
      tickWidth: tickWidth ?? this.tickWidth,
      labelStyle: labelStyle ?? this.labelStyle,
      labelColor: labelColor ?? this.labelColor,
      titleStyle: titleStyle ?? this.titleStyle,
      titleColor: titleColor ?? this.titleColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiChartAxisTheme &&
        other.lineColor == lineColor &&
        other.lineWidth == lineWidth &&
        other.tickColor == tickColor &&
        other.tickLength == tickLength &&
        other.tickWidth == tickWidth &&
        other.labelStyle == labelStyle &&
        other.labelColor == labelColor &&
        other.titleStyle == titleStyle &&
        other.titleColor == titleColor;
  }

  @override
  int get hashCode => Object.hash(
    lineColor,
    lineWidth,
    tickColor,
    tickLength,
    tickWidth,
    labelStyle,
    labelColor,
    titleStyle,
    titleColor,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-theme: Grid
// ─────────────────────────────────────────────────────────────────────────────

/// Visual tokens for chart grid lines.
///
/// {@category Foundation}
@immutable
class OiChartGridTheme {
  /// Creates an [OiChartGridTheme].
  const OiChartGridTheme({
    this.color,
    this.width,
    this.dashPattern,
  });

  /// Color of grid lines.
  final Color? color;

  /// Width of grid lines in logical pixels.
  final double? width;

  /// Optional dash pattern (e.g. `[4, 2]` for 4px dash, 2px gap).
  final List<double>? dashPattern;

  /// Creates a copy with optionally overridden values.
  OiChartGridTheme copyWith({
    Color? color,
    double? width,
    List<double>? dashPattern,
  }) {
    return OiChartGridTheme(
      color: color ?? this.color,
      width: width ?? this.width,
      dashPattern: dashPattern ?? this.dashPattern,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiChartGridTheme) return false;
    if (dashPattern != null && other.dashPattern != null) {
      if (!listEquals(dashPattern, other.dashPattern)) return false;
    } else if (dashPattern != other.dashPattern) {
      return false;
    }
    return other.color == color && other.width == width;
  }

  @override
  int get hashCode => Object.hash(
    color,
    width,
    dashPattern == null ? null : Object.hashAll(dashPattern!),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-theme: Legend
// ─────────────────────────────────────────────────────────────────────────────

/// Visual tokens for chart legends.
///
/// {@category Foundation}
@immutable
class OiChartLegendTheme {
  /// Creates an [OiChartLegendTheme].
  const OiChartLegendTheme({
    this.labelStyle,
    this.labelColor,
    this.iconSize,
    this.spacing,
    this.padding,
  });

  /// Text style for legend labels.
  final TextStyle? labelStyle;

  /// Color override for legend labels.
  final Color? labelColor;

  /// Size of the legend color swatch / icon in logical pixels.
  final double? iconSize;

  /// Space between legend items in logical pixels.
  final double? spacing;

  /// Padding around the legend container.
  final EdgeInsets? padding;

  /// Creates a copy with optionally overridden values.
  OiChartLegendTheme copyWith({
    TextStyle? labelStyle,
    Color? labelColor,
    double? iconSize,
    double? spacing,
    EdgeInsets? padding,
  }) {
    return OiChartLegendTheme(
      labelStyle: labelStyle ?? this.labelStyle,
      labelColor: labelColor ?? this.labelColor,
      iconSize: iconSize ?? this.iconSize,
      spacing: spacing ?? this.spacing,
      padding: padding ?? this.padding,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiChartLegendTheme &&
        other.labelStyle == labelStyle &&
        other.labelColor == labelColor &&
        other.iconSize == iconSize &&
        other.spacing == spacing &&
        other.padding == padding;
  }

  @override
  int get hashCode =>
      Object.hash(labelStyle, labelColor, iconSize, spacing, padding);
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-theme: Tooltip
// ─────────────────────────────────────────────────────────────────────────────

/// Visual tokens for chart tooltips.
///
/// {@category Foundation}
@immutable
class OiChartTooltipTheme {
  /// Creates an [OiChartTooltipTheme].
  const OiChartTooltipTheme({
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.textStyle,
    this.textColor,
    this.padding,
    this.shadow,
  });

  /// Background color of the tooltip.
  final Color? backgroundColor;

  /// Border color of the tooltip.
  final Color? borderColor;

  /// Border width of the tooltip in logical pixels.
  final double? borderWidth;

  /// Corner radius of the tooltip.
  final BorderRadius? borderRadius;

  /// Text style for tooltip content.
  final TextStyle? textStyle;

  /// Color override for tooltip text.
  final Color? textColor;

  /// Internal padding of the tooltip.
  final EdgeInsets? padding;

  /// Box shadow applied to the tooltip.
  final BoxShadow? shadow;

  /// Creates a copy with optionally overridden values.
  OiChartTooltipTheme copyWith({
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    BorderRadius? borderRadius,
    TextStyle? textStyle,
    Color? textColor,
    EdgeInsets? padding,
    BoxShadow? shadow,
  }) {
    return OiChartTooltipTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      textStyle: textStyle ?? this.textStyle,
      textColor: textColor ?? this.textColor,
      padding: padding ?? this.padding,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiChartTooltipTheme &&
        other.backgroundColor == backgroundColor &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.borderRadius == borderRadius &&
        other.textStyle == textStyle &&
        other.textColor == textColor &&
        other.padding == padding &&
        other.shadow == shadow;
  }

  @override
  int get hashCode => Object.hash(
    backgroundColor,
    borderColor,
    borderWidth,
    borderRadius,
    textStyle,
    textColor,
    padding,
    shadow,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-theme: Crosshair
// ─────────────────────────────────────────────────────────────────────────────

/// Visual tokens for chart crosshair / hover indicator lines.
///
/// {@category Foundation}
@immutable
class OiChartCrosshairTheme {
  /// Creates an [OiChartCrosshairTheme].
  const OiChartCrosshairTheme({
    this.color,
    this.width,
    this.dashPattern,
  });

  /// Color of the crosshair line.
  final Color? color;

  /// Width of the crosshair line in logical pixels.
  final double? width;

  /// Optional dash pattern for the crosshair line.
  final List<double>? dashPattern;

  /// Creates a copy with optionally overridden values.
  OiChartCrosshairTheme copyWith({
    Color? color,
    double? width,
    List<double>? dashPattern,
  }) {
    return OiChartCrosshairTheme(
      color: color ?? this.color,
      width: width ?? this.width,
      dashPattern: dashPattern ?? this.dashPattern,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiChartCrosshairTheme) return false;
    if (dashPattern != null && other.dashPattern != null) {
      if (!listEquals(dashPattern, other.dashPattern)) return false;
    } else if (dashPattern != other.dashPattern) {
      return false;
    }
    return other.color == color && other.width == width;
  }

  @override
  int get hashCode => Object.hash(
    color,
    width,
    dashPattern == null ? null : Object.hashAll(dashPattern!),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-theme: Annotation
// ─────────────────────────────────────────────────────────────────────────────

/// Visual tokens for chart annotations (reference lines, bands, markers).
///
/// {@category Foundation}
@immutable
class OiChartAnnotationTheme {
  /// Creates an [OiChartAnnotationTheme].
  const OiChartAnnotationTheme({
    this.lineColor,
    this.lineWidth,
    this.lineDashPattern,
    this.bandColor,
    this.labelStyle,
    this.labelColor,
  });

  /// Default color for annotation reference lines.
  final Color? lineColor;

  /// Default width for annotation reference lines.
  final double? lineWidth;

  /// Optional dash pattern for annotation lines.
  final List<double>? lineDashPattern;

  /// Default fill color for annotation bands / ranges.
  final Color? bandColor;

  /// Text style for annotation labels.
  final TextStyle? labelStyle;

  /// Color override for annotation label text.
  final Color? labelColor;

  /// Creates a copy with optionally overridden values.
  OiChartAnnotationTheme copyWith({
    Color? lineColor,
    double? lineWidth,
    List<double>? lineDashPattern,
    Color? bandColor,
    TextStyle? labelStyle,
    Color? labelColor,
  }) {
    return OiChartAnnotationTheme(
      lineColor: lineColor ?? this.lineColor,
      lineWidth: lineWidth ?? this.lineWidth,
      lineDashPattern: lineDashPattern ?? this.lineDashPattern,
      bandColor: bandColor ?? this.bandColor,
      labelStyle: labelStyle ?? this.labelStyle,
      labelColor: labelColor ?? this.labelColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiChartAnnotationTheme) return false;
    if (lineDashPattern != null && other.lineDashPattern != null) {
      if (!listEquals(lineDashPattern, other.lineDashPattern)) return false;
    } else if (lineDashPattern != other.lineDashPattern) {
      return false;
    }
    return other.lineColor == lineColor &&
        other.lineWidth == lineWidth &&
        other.bandColor == bandColor &&
        other.labelStyle == labelStyle &&
        other.labelColor == labelColor;
  }

  @override
  int get hashCode => Object.hash(
    lineColor,
    lineWidth,
    lineDashPattern == null ? null : Object.hashAll(lineDashPattern!),
    bandColor,
    labelStyle,
    labelColor,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-theme: Selection
// ─────────────────────────────────────────────────────────────────────────────

/// Visual tokens for selected / highlighted chart elements.
///
/// {@category Foundation}
@immutable
class OiChartSelectionTheme {
  /// Creates an [OiChartSelectionTheme].
  const OiChartSelectionTheme({
    this.highlightColor,
    this.dimmedOpacity,
    this.strokeColor,
    this.strokeWidth,
  });

  /// Color used to highlight the selected element.
  final Color? highlightColor;

  /// Opacity applied to non-selected elements to dim them.
  final double? dimmedOpacity;

  /// Stroke color drawn around a selected element.
  final Color? strokeColor;

  /// Stroke width drawn around a selected element.
  final double? strokeWidth;

  /// Creates a copy with optionally overridden values.
  OiChartSelectionTheme copyWith({
    Color? highlightColor,
    double? dimmedOpacity,
    Color? strokeColor,
    double? strokeWidth,
  }) {
    return OiChartSelectionTheme(
      highlightColor: highlightColor ?? this.highlightColor,
      dimmedOpacity: dimmedOpacity ?? this.dimmedOpacity,
      strokeColor: strokeColor ?? this.strokeColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiChartSelectionTheme &&
        other.highlightColor == highlightColor &&
        other.dimmedOpacity == dimmedOpacity &&
        other.strokeColor == strokeColor &&
        other.strokeWidth == strokeWidth;
  }

  @override
  int get hashCode =>
      Object.hash(highlightColor, dimmedOpacity, strokeColor, strokeWidth);
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-theme: State (hover, pressed, disabled)
// ─────────────────────────────────────────────────────────────────────────────

/// Visual tokens for interactive states of chart elements (hover, pressed,
/// disabled).
///
/// {@category Foundation}
@immutable
class OiChartStateTheme {
  /// Creates an [OiChartStateTheme].
  const OiChartStateTheme({
    this.hoverOpacity,
    this.pressedOpacity,
    this.disabledOpacity,
    this.hoverStrokeWidth,
    this.hoverElevation,
  });

  /// Opacity multiplier when hovering over a chart element.
  final double? hoverOpacity;

  /// Opacity multiplier when pressing a chart element.
  final double? pressedOpacity;

  /// Opacity multiplier for disabled chart elements.
  final double? disabledOpacity;

  /// Extra stroke width applied on hover.
  final double? hoverStrokeWidth;

  /// Elevation (shadow spread) applied on hover.
  final double? hoverElevation;

  /// Creates a copy with optionally overridden values.
  OiChartStateTheme copyWith({
    double? hoverOpacity,
    double? pressedOpacity,
    double? disabledOpacity,
    double? hoverStrokeWidth,
    double? hoverElevation,
  }) {
    return OiChartStateTheme(
      hoverOpacity: hoverOpacity ?? this.hoverOpacity,
      pressedOpacity: pressedOpacity ?? this.pressedOpacity,
      disabledOpacity: disabledOpacity ?? this.disabledOpacity,
      hoverStrokeWidth: hoverStrokeWidth ?? this.hoverStrokeWidth,
      hoverElevation: hoverElevation ?? this.hoverElevation,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiChartStateTheme &&
        other.hoverOpacity == hoverOpacity &&
        other.pressedOpacity == pressedOpacity &&
        other.disabledOpacity == disabledOpacity &&
        other.hoverStrokeWidth == hoverStrokeWidth &&
        other.hoverElevation == hoverElevation;
  }

  @override
  int get hashCode => Object.hash(
    hoverOpacity,
    pressedOpacity,
    disabledOpacity,
    hoverStrokeWidth,
    hoverElevation,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-theme: Motion
// ─────────────────────────────────────────────────────────────────────────────

/// Visual tokens for chart animation and transition behaviour.
///
/// {@category Foundation}
@immutable
class OiChartMotionTheme {
  /// Creates an [OiChartMotionTheme].
  const OiChartMotionTheme({
    this.entryDuration,
    this.updateDuration,
    this.exitDuration,
    this.entryCurve,
    this.updateCurve,
    this.exitCurve,
    this.staggerDelay,
  });

  /// Duration of the entry / appear animation.
  final Duration? entryDuration;

  /// Duration of update / data-change animations.
  final Duration? updateDuration;

  /// Duration of the exit / disappear animation.
  final Duration? exitDuration;

  /// Curve for entry animations.
  final Curve? entryCurve;

  /// Curve for update animations.
  final Curve? updateCurve;

  /// Curve for exit animations.
  final Curve? exitCurve;

  /// Delay between staggered element animations.
  final Duration? staggerDelay;

  /// Creates a copy with optionally overridden values.
  OiChartMotionTheme copyWith({
    Duration? entryDuration,
    Duration? updateDuration,
    Duration? exitDuration,
    Curve? entryCurve,
    Curve? updateCurve,
    Curve? exitCurve,
    Duration? staggerDelay,
  }) {
    return OiChartMotionTheme(
      entryDuration: entryDuration ?? this.entryDuration,
      updateDuration: updateDuration ?? this.updateDuration,
      exitDuration: exitDuration ?? this.exitDuration,
      entryCurve: entryCurve ?? this.entryCurve,
      updateCurve: updateCurve ?? this.updateCurve,
      exitCurve: exitCurve ?? this.exitCurve,
      staggerDelay: staggerDelay ?? this.staggerDelay,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiChartMotionTheme &&
        other.entryDuration == entryDuration &&
        other.updateDuration == updateDuration &&
        other.exitDuration == exitDuration &&
        other.entryCurve == entryCurve &&
        other.updateCurve == updateCurve &&
        other.exitCurve == exitCurve &&
        other.staggerDelay == staggerDelay;
  }

  @override
  int get hashCode => Object.hash(
    entryDuration,
    updateDuration,
    exitDuration,
    entryCurve,
    updateCurve,
    exitCurve,
    staggerDelay,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-theme: Density
// ─────────────────────────────────────────────────────────────────────────────

/// Visual tokens controlling chart element density / sizing.
///
/// {@category Foundation}
@immutable
class OiChartDensityTheme {
  /// Creates an [OiChartDensityTheme].
  const OiChartDensityTheme({
    this.pointSize,
    this.lineWidth,
    this.barSpacing,
    this.barGroupSpacing,
    this.padding,
  });

  /// Default data-point radius in logical pixels.
  final double? pointSize;

  /// Default line / stroke width in logical pixels.
  final double? lineWidth;

  /// Space between individual bars within a group.
  final double? barSpacing;

  /// Space between bar groups.
  final double? barGroupSpacing;

  /// Padding around the chart plot area.
  final EdgeInsets? padding;

  /// Creates a copy with optionally overridden values.
  OiChartDensityTheme copyWith({
    double? pointSize,
    double? lineWidth,
    double? barSpacing,
    double? barGroupSpacing,
    EdgeInsets? padding,
  }) {
    return OiChartDensityTheme(
      pointSize: pointSize ?? this.pointSize,
      lineWidth: lineWidth ?? this.lineWidth,
      barSpacing: barSpacing ?? this.barSpacing,
      barGroupSpacing: barGroupSpacing ?? this.barGroupSpacing,
      padding: padding ?? this.padding,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiChartDensityTheme &&
        other.pointSize == pointSize &&
        other.lineWidth == lineWidth &&
        other.barSpacing == barSpacing &&
        other.barGroupSpacing == barGroupSpacing &&
        other.padding == padding;
  }

  @override
  int get hashCode =>
      Object.hash(pointSize, lineWidth, barSpacing, barGroupSpacing, padding);
}

// ─────────────────────────────────────────────────────────────────────────────
// Main: OiChartThemeData
// ─────────────────────────────────────────────────────────────────────────────

/// A typed container for all chart visual tokens.
///
/// [OiChartThemeData] aggregates the [palette], [axis], [grid], [legend],
/// [tooltip], [crosshair], [annotation], [selection], [state], [motion], and
/// [density] sub-themes into a single object. It integrates with the
/// `OiComponentThemes` system and is accessible via
/// `context.components.chart`.
///
/// All chart visual properties should derive from theme tokens by default,
/// never from hardcoded constants.
///
/// {@category Foundation}
@immutable
class OiChartThemeData {
  /// Creates an [OiChartThemeData] with explicit sub-theme values.
  const OiChartThemeData({
    this.palette,
    this.axis,
    this.grid,
    this.legend,
    this.tooltip,
    this.crosshair,
    this.annotation,
    this.selection,
    this.state,
    this.motion,
    this.density,
  });

  /// The color palette for chart series and semantic colors.
  final OiChartPalette? palette;

  /// Visual tokens for chart axes.
  final OiChartAxisTheme? axis;

  /// Visual tokens for chart grid lines.
  final OiChartGridTheme? grid;

  /// Visual tokens for chart legends.
  final OiChartLegendTheme? legend;

  /// Visual tokens for chart tooltips.
  final OiChartTooltipTheme? tooltip;

  /// Visual tokens for chart crosshair / hover indicator.
  final OiChartCrosshairTheme? crosshair;

  /// Visual tokens for chart annotations.
  final OiChartAnnotationTheme? annotation;

  /// Visual tokens for selected / highlighted chart elements.
  final OiChartSelectionTheme? selection;

  /// Visual tokens for interactive states (hover, pressed, disabled).
  final OiChartStateTheme? state;

  /// Visual tokens for chart animation and transition behaviour.
  final OiChartMotionTheme? motion;

  /// Visual tokens controlling chart element density / sizing.
  final OiChartDensityTheme? density;

  /// Creates a copy with optionally overridden values.
  OiChartThemeData copyWith({
    OiChartPalette? palette,
    OiChartAxisTheme? axis,
    OiChartGridTheme? grid,
    OiChartLegendTheme? legend,
    OiChartTooltipTheme? tooltip,
    OiChartCrosshairTheme? crosshair,
    OiChartAnnotationTheme? annotation,
    OiChartSelectionTheme? selection,
    OiChartStateTheme? state,
    OiChartMotionTheme? motion,
    OiChartDensityTheme? density,
  }) {
    return OiChartThemeData(
      palette: palette ?? this.palette,
      axis: axis ?? this.axis,
      grid: grid ?? this.grid,
      legend: legend ?? this.legend,
      tooltip: tooltip ?? this.tooltip,
      crosshair: crosshair ?? this.crosshair,
      annotation: annotation ?? this.annotation,
      selection: selection ?? this.selection,
      state: state ?? this.state,
      motion: motion ?? this.motion,
      density: density ?? this.density,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiChartThemeData &&
        other.palette == palette &&
        other.axis == axis &&
        other.grid == grid &&
        other.legend == legend &&
        other.tooltip == tooltip &&
        other.crosshair == crosshair &&
        other.annotation == annotation &&
        other.selection == selection &&
        other.state == state &&
        other.motion == motion &&
        other.density == density;
  }

  @override
  int get hashCode => Object.hash(
    palette,
    axis,
    grid,
    legend,
    tooltip,
    crosshair,
    annotation,
    selection,
    state,
    motion,
    density,
  );
}
