import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_charts/src/foundation/oi_chart_scale.dart';

/// Context provided to chart formatters alongside the raw value.
///
/// Gives formatters access to the chart theme, the current locale, and
/// the scale that produced the value — enabling locale-aware formatting
/// and data-range–aware label truncation.
///
/// {@category Foundation}
@immutable
class OiFormatterContext<T> {
  /// Creates an [OiFormatterContext].
  const OiFormatterContext({
    required this.theme,
    required this.locale,
    this.scale,
  });

  /// The current chart theme data.
  final OiChartThemeData theme;

  /// The active locale for number/date formatting.
  final Locale locale;

  /// The scale that produced this value, if available.
  ///
  /// Can be used to inspect the domain range, scale type, or tick
  /// density for smarter formatting decisions.
  final OiChartScale<T>? scale;

  /// The pixel distance for one minimal logical step of the associated scale.
  ///
  /// Convenience accessor for `scale?.atom ?? 0`. Formatters can use this
  /// to decide display precision — e.g. when [atom] is very small, show
  /// more decimal places.
  double get atom => scale?.atom ?? 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiFormatterContext<T> &&
        other.theme == theme &&
        other.locale == locale &&
        other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(theme, locale, scale);
}

// ─────────────────────────────────────────────────────────────────────────────
// OiAxisFormatContext — axis-specific formatter context
// ─────────────────────────────────────────────────────────────────────────────

/// Extended formatter context for axis tick formatting.
///
/// Adds axis-specific information: tick position flags and available
/// rendering width.
///
/// {@category Foundation}
@immutable
class OiAxisFormatContext<T> extends OiFormatterContext<T> {
  /// Creates an [OiAxisFormatContext].
  const OiAxisFormatContext({
    required super.theme,
    required super.locale,
    super.scale,
    this.axisPosition,
    this.isFirstTick = false,
    this.isLastTick = false,
    this.availableWidth,
  });

  /// The position of the axis (top/bottom/left/right), if known.
  final String? axisPosition;

  /// Whether this is the first tick on the axis.
  final bool isFirstTick;

  /// Whether this is the last tick on the axis.
  final bool isLastTick;

  /// Available rendering width in logical pixels for this label.
  ///
  /// Formatters can use this to truncate long labels.
  final double? availableWidth;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiAxisFormatContext<T> &&
        other.theme == theme &&
        other.locale == locale &&
        other.scale == scale &&
        other.axisPosition == axisPosition &&
        other.isFirstTick == isFirstTick &&
        other.isLastTick == isLastTick &&
        other.availableWidth == availableWidth;
  }

  @override
  int get hashCode => Object.hash(
    theme,
    locale,
    scale,
    axisPosition,
    isFirstTick,
    isLastTick,
    availableWidth,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// OiTooltipFormatContext — tooltip-specific formatter context
// ─────────────────────────────────────────────────────────────────────────────

/// Extended formatter context for tooltip value formatting.
///
/// Adds series identification and point index information.
///
/// {@category Foundation}
@immutable
class OiTooltipFormatContext extends OiFormatterContext<double> {
  /// Creates an [OiTooltipFormatContext].
  const OiTooltipFormatContext({
    required super.theme,
    required super.locale,
    super.scale,
    this.seriesId,
    this.seriesLabel,
    this.pointIndex,
  });

  /// The id of the series this value belongs to.
  final String? seriesId;

  /// The display label of the series.
  final String? seriesLabel;

  /// The index of the data point within its series.
  final int? pointIndex;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiTooltipFormatContext &&
        other.theme == theme &&
        other.locale == locale &&
        other.scale == scale &&
        other.seriesId == seriesId &&
        other.seriesLabel == seriesLabel &&
        other.pointIndex == pointIndex;
  }

  @override
  int get hashCode =>
      Object.hash(theme, locale, scale, seriesId, seriesLabel, pointIndex);
}

// ─────────────────────────────────────────────────────────────────────────────
// Formatter typedefs
// ─────────────────────────────────────────────────────────────────────────────

/// Formats an axis tick value of type [T] into a display string.
///
/// Receives the raw tick [value] and an [OiFormatterContext] providing
/// theme, locale, and scale information for context-aware formatting.
///
/// ```dart
/// final OiAxisFormatter<double> percentFormatter = (value, context) {
///   return '${(value * 100).toStringAsFixed(0)}%';
/// };
/// ```
///
/// {@category Foundation}
typedef OiAxisFormatter<T> =
    String Function(T value, OiAxisFormatContext<T> context);

/// Formats a tooltip value into a display string.
///
/// Unlike [OiAxisFormatter], this is not generic — tooltip values are
/// always presented as pre-resolved [double] values (the y/measure
/// value of a data point).
///
/// Receives the raw [value] and an [OiFormatterContext] providing
/// theme, locale, and scale information.
///
/// ```dart
/// final OiTooltipValueFormatter currencyFormatter = (value, context) {
///   return '\$${value.toStringAsFixed(2)}';
/// };
/// ```
///
/// {@category Foundation}
typedef OiTooltipValueFormatter =
    String Function(double value, OiTooltipFormatContext context);

/// Formats a series label for legend or tooltip display.
///
/// Receives the raw series value of type [T] (typically a [String] label
/// or an enum) and an [OiFormatterContext] providing theme, locale, and
/// scale information.
///
/// ```dart
/// final OiSeriesLabelFormatter<String> truncateFormatter = (value, context) {
///   return value.length > 20 ? '${value.substring(0, 17)}...' : value;
/// };
/// ```
///
/// {@category Foundation}
typedef OiSeriesLabelFormatter<T> =
    String Function(T value, OiFormatterContext<T> context);
