import 'package:flutter/widgets.dart';

/// Theme data for data grid components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiDataGridThemeData {
  /// Creates an [OiDataGridThemeData].
  const OiDataGridThemeData({
    this.headerBackgroundColor,
    this.headerTextStyle,
    this.rowHeight,
    this.denseRowHeight,
    this.borderColor,
    this.stripeColor,
    this.selectedRowColor,
    this.hoverRowColor,
  });

  /// The background color of the data grid header row.
  final Color? headerBackgroundColor;

  /// The text style for data grid header labels.
  final TextStyle? headerTextStyle;

  /// The height of each data row in logical pixels.
  final double? rowHeight;

  /// The height of each data row in dense mode in logical pixels.
  final double? denseRowHeight;

  /// The color of the data grid border and row dividers.
  final Color? borderColor;

  /// The background color for alternating (striped) rows.
  final Color? stripeColor;

  /// The background color for selected rows.
  final Color? selectedRowColor;

  /// The background color for hovered rows.
  final Color? hoverRowColor;

  /// Creates a copy with optionally overridden values.
  OiDataGridThemeData copyWith({
    Color? headerBackgroundColor,
    TextStyle? headerTextStyle,
    double? rowHeight,
    double? denseRowHeight,
    Color? borderColor,
    Color? stripeColor,
    Color? selectedRowColor,
    Color? hoverRowColor,
  }) {
    return OiDataGridThemeData(
      headerBackgroundColor:
          headerBackgroundColor ?? this.headerBackgroundColor,
      headerTextStyle: headerTextStyle ?? this.headerTextStyle,
      rowHeight: rowHeight ?? this.rowHeight,
      denseRowHeight: denseRowHeight ?? this.denseRowHeight,
      borderColor: borderColor ?? this.borderColor,
      stripeColor: stripeColor ?? this.stripeColor,
      selectedRowColor: selectedRowColor ?? this.selectedRowColor,
      hoverRowColor: hoverRowColor ?? this.hoverRowColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiDataGridThemeData &&
        other.headerBackgroundColor == headerBackgroundColor &&
        other.headerTextStyle == headerTextStyle &&
        other.rowHeight == rowHeight &&
        other.denseRowHeight == denseRowHeight &&
        other.borderColor == borderColor &&
        other.stripeColor == stripeColor &&
        other.selectedRowColor == selectedRowColor &&
        other.hoverRowColor == hoverRowColor;
  }

  @override
  int get hashCode => Object.hash(
        headerBackgroundColor,
        headerTextStyle,
        rowHeight,
        denseRowHeight,
        borderColor,
        stripeColor,
        selectedRowColor,
        hoverRowColor,
      );
}
