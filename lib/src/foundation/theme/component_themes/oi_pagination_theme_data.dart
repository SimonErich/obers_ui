import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiPagination;
import 'package:obers_ui/src/components/display/oi_pagination.dart' show OiPagination;

/// Theme data for [OiPagination] components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiPaginationThemeData {
  /// Creates an [OiPaginationThemeData].
  const OiPaginationThemeData({
    this.labelStyle,
    this.activePageStyle,
    this.pageStyle,
    this.buttonSpacing,
    this.padding,
  });

  /// Linearly interpolates between two [OiPaginationThemeData] instances.
  OiPaginationThemeData.lerp(
    OiPaginationThemeData a,
    OiPaginationThemeData b,
    double t,
  )   : labelStyle = TextStyle.lerp(a.labelStyle, b.labelStyle, t),
        activePageStyle = TextStyle.lerp(a.activePageStyle, b.activePageStyle, t),
        pageStyle = TextStyle.lerp(a.pageStyle, b.pageStyle, t),
        buttonSpacing = lerpDouble(a.buttonSpacing, b.buttonSpacing, t),
        padding = EdgeInsetsGeometry.lerp(a.padding, b.padding, t);

  /// Text style for informational labels (e.g. total count, range text).
  final TextStyle? labelStyle;

  /// Text style for the currently active page number.
  final TextStyle? activePageStyle;

  /// Text style for inactive page numbers.
  final TextStyle? pageStyle;

  /// Horizontal spacing between page buttons.
  final double? buttonSpacing;

  /// Padding around the pagination bar.
  final EdgeInsetsGeometry? padding;

  /// Creates a copy with optionally overridden values.
  OiPaginationThemeData copyWith({
    TextStyle? labelStyle,
    TextStyle? activePageStyle,
    TextStyle? pageStyle,
    double? buttonSpacing,
    EdgeInsetsGeometry? padding,
  }) {
    return OiPaginationThemeData(
      labelStyle: labelStyle ?? this.labelStyle,
      activePageStyle: activePageStyle ?? this.activePageStyle,
      pageStyle: pageStyle ?? this.pageStyle,
      buttonSpacing: buttonSpacing ?? this.buttonSpacing,
      padding: padding ?? this.padding,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiPaginationThemeData &&
        other.labelStyle == labelStyle &&
        other.activePageStyle == activePageStyle &&
        other.pageStyle == pageStyle &&
        other.buttonSpacing == buttonSpacing &&
        other.padding == padding;
  }

  @override
  int get hashCode => Object.hash(
    labelStyle,
    activePageStyle,
    pageStyle,
    buttonSpacing,
    padding,
  );
}
