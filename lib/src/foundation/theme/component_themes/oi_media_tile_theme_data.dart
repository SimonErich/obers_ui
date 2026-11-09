import 'package:flutter/widgets.dart';

/// Presentation tokens for selectable media with independent overlays.
///
/// {@category Foundation}
@immutable
class OiMediaTileThemeData {
  /// Creates visual tokens; omitted values inherit the surrounding theme.
  const OiMediaTileThemeData({
    this.borderRadius,
    this.backgroundColor,
    this.selectedBorder,
    this.unselectedOpacity = 1,
    this.desaturateUnselected = false,
    this.transitionDuration,
  });

  /// Clipping radius; defaults to the theme medium radius.
  final BorderRadiusGeometry? borderRadius;

  /// Fill behind transparent or unloaded content.
  final Color? backgroundColor;

  /// Selected outline, painted without changing layout.
  final BorderSide? selectedBorder;

  /// Unselected content opacity; overlays remain fully visible.
  final double unselectedOpacity;

  /// Whether unselected content is rendered in grayscale.
  final bool desaturateUnselected;

  /// Opacity duration; reduced motion always resolves to zero.
  final Duration? transitionDuration;

  /// Creates a copy with selected tokens replaced.
  OiMediaTileThemeData copyWith({
    BorderRadiusGeometry? borderRadius,
    Color? backgroundColor,
    BorderSide? selectedBorder,
    double? unselectedOpacity,
    bool? desaturateUnselected,
    Duration? transitionDuration,
  }) => OiMediaTileThemeData(
    borderRadius: borderRadius ?? this.borderRadius,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    selectedBorder: selectedBorder ?? this.selectedBorder,
    unselectedOpacity: unselectedOpacity ?? this.unselectedOpacity,
    desaturateUnselected: desaturateUnselected ?? this.desaturateUnselected,
    transitionDuration: transitionDuration ?? this.transitionDuration,
  );

  @override
  bool operator ==(Object other) =>
      other is OiMediaTileThemeData &&
      other.borderRadius == borderRadius &&
      other.backgroundColor == backgroundColor &&
      other.selectedBorder == selectedBorder &&
      other.unselectedOpacity == unselectedOpacity &&
      other.desaturateUnselected == desaturateUnselected &&
      other.transitionDuration == transitionDuration;

  @override
  int get hashCode => Object.hashAll([
    borderRadius,
    backgroundColor,
    selectedBorder,
    unselectedOpacity,
    desaturateUnselected,
    transitionDuration,
  ]);
}
