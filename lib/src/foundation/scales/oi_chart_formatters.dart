import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';

import 'package:obers_ui/src/foundation/scales/oi_chart_scale.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_chart_theme_data.dart';

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
typedef OiAxisFormatter<T> = String Function(
  T value,
  OiFormatterContext<T> context,
);

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
typedef OiTooltipValueFormatter = String Function(
  double value,
  OiFormatterContext<double> context,
);

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
typedef OiSeriesLabelFormatter<T> = String Function(
  T value,
  OiFormatterContext<T> context,
);
