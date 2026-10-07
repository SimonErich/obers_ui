import 'package:flutter/widgets.dart';

/// Visual tokens for a labelled, discrete choice scale.
@immutable
class OiChoiceScaleThemeData {
  /// Creates choice scale tokens; colors and typography inherit the theme.
  const OiChoiceScaleThemeData({
    this.labelStyle,
    this.selectedLabelStyle,
    this.lineColor,
    this.markerColor,
    this.selectedMarkerColor,
    this.markerSize = 8,
    this.selectedMarkerSize = 16,
    this.markerExtent = 16,
    this.itemWidth = 56,
    this.labelGap = 8,
    this.lineWidth = 2,
    this.lineOffset,
  });

  /// Ordinary label typography.
  final TextStyle? labelStyle;

  /// Selected label typography.
  final TextStyle? selectedLabelStyle;

  /// Connecting line color.
  final Color? lineColor;

  /// Ordinary marker color.
  final Color? markerColor;

  /// Selected marker color.
  final Color? selectedMarkerColor;

  /// Ordinary marker diameter.
  final double markerSize;

  /// Selected marker diameter.
  final double selectedMarkerSize;

  /// Shared marker row extent, preventing shifts on selection.
  final double markerExtent;

  /// Preferred item width at ordinary text sizes.
  final double itemWidth;

  /// Space between the marker and label.
  final double labelGap;

  /// Optional top inset for the line; null centers it in the marker row.
  final double? lineOffset;

  /// Connecting line thickness.
  final double lineWidth;

  /// Creates a copy with selected tokens replaced.
  OiChoiceScaleThemeData copyWith({
    TextStyle? labelStyle,
    TextStyle? selectedLabelStyle,
    Color? lineColor,
    Color? markerColor,
    Color? selectedMarkerColor,
    double? markerSize,
    double? selectedMarkerSize,
    double? markerExtent,
    double? itemWidth,
    double? labelGap,
    double? lineWidth,
    double? lineOffset,
  }) => OiChoiceScaleThemeData(
    labelStyle: labelStyle ?? this.labelStyle,
    selectedLabelStyle: selectedLabelStyle ?? this.selectedLabelStyle,
    lineColor: lineColor ?? this.lineColor,
    markerColor: markerColor ?? this.markerColor,
    selectedMarkerColor: selectedMarkerColor ?? this.selectedMarkerColor,
    markerSize: markerSize ?? this.markerSize,
    selectedMarkerSize: selectedMarkerSize ?? this.selectedMarkerSize,
    markerExtent: markerExtent ?? this.markerExtent,
    itemWidth: itemWidth ?? this.itemWidth,
    labelGap: labelGap ?? this.labelGap,
    lineWidth: lineWidth ?? this.lineWidth,
    lineOffset: lineOffset ?? this.lineOffset,
  );

  @override
  bool operator ==(Object other) =>
      other is OiChoiceScaleThemeData &&
      other.labelStyle == labelStyle &&
      other.selectedLabelStyle == selectedLabelStyle &&
      other.lineColor == lineColor &&
      other.markerColor == markerColor &&
      other.selectedMarkerColor == selectedMarkerColor &&
      other.markerSize == markerSize &&
      other.selectedMarkerSize == selectedMarkerSize &&
      other.markerExtent == markerExtent &&
      other.itemWidth == itemWidth &&
      other.labelGap == labelGap &&
      other.lineWidth == lineWidth &&
      other.lineOffset == lineOffset;
  @override
  int get hashCode => Object.hashAll([
    labelStyle,
    selectedLabelStyle,
    lineColor,
    markerColor,
    selectedMarkerColor,
    markerSize,
    selectedMarkerSize,
    markerExtent,
    itemWidth,
    labelGap,
    lineWidth,
    lineOffset,
  ]);
}
