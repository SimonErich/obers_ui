import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiPagination;
import 'package:obers_ui/src/components/display/oi_pagination.dart'
    show OiPagination;

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
    this.distributed,
    this.showFirstLast,
    this.siblingCount,
    this.activeBackground,
    this.activeForeground,
    this.buttonRadius,
    this.buttonSize,
    this.perPageWidth,
  });

  /// Linearly interpolates between two [OiPaginationThemeData] instances.
  OiPaginationThemeData.lerp(
    OiPaginationThemeData a,
    OiPaginationThemeData b,
    double t,
  ) : labelStyle = TextStyle.lerp(a.labelStyle, b.labelStyle, t),
      activePageStyle = TextStyle.lerp(a.activePageStyle, b.activePageStyle, t),
      pageStyle = TextStyle.lerp(a.pageStyle, b.pageStyle, t),
      buttonSpacing = lerpDouble(a.buttonSpacing, b.buttonSpacing, t),
      padding = EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      distributed = t < .5 ? a.distributed : b.distributed,
      showFirstLast = t < .5 ? a.showFirstLast : b.showFirstLast,
      siblingCount = t < .5 ? a.siblingCount : b.siblingCount,
      activeBackground = Color.lerp(a.activeBackground, b.activeBackground, t),
      activeForeground = Color.lerp(a.activeForeground, b.activeForeground, t),
      buttonRadius = BorderRadius.lerp(a.buttonRadius, b.buttonRadius, t),
      buttonSize = lerpDouble(a.buttonSize, b.buttonSize, t),
      perPageWidth = lerpDouble(a.perPageWidth, b.perPageWidth, t);

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

  /// Places the range left, page navigation centrally and page size right.
  final bool? distributed;

  /// Whether first/last shortcuts are visible; defaults to true.
  final bool? showFirstLast;

  /// Number of page neighbors around the current page; defaults to one.
  final int? siblingCount;

  /// Selected page fill; defaults to the primary base color.
  final Color? activeBackground;

  /// Selected page text; defaults to the primary foreground color.
  final Color? activeForeground;

  /// Corner radius of page buttons.
  final BorderRadius? buttonRadius;

  /// Visual size of arrow buttons and minimum size of numbered page buttons.
  ///
  /// Also sets the page-size selector's minimum height. Large page numbers and
  /// scaled text can grow instead of clipping. Null retains component defaults.
  final double? buttonSize;

  /// Width of the page-size selector; defaults to 80.
  final double? perPageWidth;

  /// Creates a copy with optionally overridden values.
  OiPaginationThemeData copyWith({
    TextStyle? labelStyle,
    TextStyle? activePageStyle,
    TextStyle? pageStyle,
    double? buttonSpacing,
    EdgeInsetsGeometry? padding,
    bool? distributed,
    bool? showFirstLast,
    int? siblingCount,
    Color? activeBackground,
    Color? activeForeground,
    BorderRadius? buttonRadius,
    double? buttonSize,
    double? perPageWidth,
  }) {
    return OiPaginationThemeData(
      labelStyle: labelStyle ?? this.labelStyle,
      activePageStyle: activePageStyle ?? this.activePageStyle,
      pageStyle: pageStyle ?? this.pageStyle,
      buttonSpacing: buttonSpacing ?? this.buttonSpacing,
      padding: padding ?? this.padding,
      distributed: distributed ?? this.distributed,
      showFirstLast: showFirstLast ?? this.showFirstLast,
      siblingCount: siblingCount ?? this.siblingCount,
      activeBackground: activeBackground ?? this.activeBackground,
      activeForeground: activeForeground ?? this.activeForeground,
      buttonRadius: buttonRadius ?? this.buttonRadius,
      buttonSize: buttonSize ?? this.buttonSize,
      perPageWidth: perPageWidth ?? this.perPageWidth,
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
        other.padding == padding &&
        other.distributed == distributed &&
        other.showFirstLast == showFirstLast &&
        other.siblingCount == siblingCount &&
        other.activeBackground == activeBackground &&
        other.activeForeground == activeForeground &&
        other.buttonRadius == buttonRadius &&
        other.buttonSize == buttonSize &&
        other.perPageWidth == perPageWidth;
  }

  @override
  int get hashCode => Object.hash(
    labelStyle,
    activePageStyle,
    pageStyle,
    buttonSpacing,
    padding,
    distributed,
    showFirstLast,
    siblingCount,
    activeBackground,
    activeForeground,
    buttonRadius,
    buttonSize,
    perPageWidth,
  );
}
