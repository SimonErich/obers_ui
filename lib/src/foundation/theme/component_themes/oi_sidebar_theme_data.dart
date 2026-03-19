import 'package:flutter/widgets.dart';

/// Theme data for sidebar / navigation-rail components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiSidebarThemeData {
  /// Creates an [OiSidebarThemeData].
  const OiSidebarThemeData({this.width, this.compactWidth});

  /// The width of the expanded sidebar in logical pixels.
  final double? width;

  /// The width of the collapsed / compact sidebar in logical pixels.
  final double? compactWidth;

  /// Creates a copy with optionally overridden values.
  OiSidebarThemeData copyWith({double? width, double? compactWidth}) {
    return OiSidebarThemeData(
      width: width ?? this.width,
      compactWidth: compactWidth ?? this.compactWidth,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiSidebarThemeData &&
        other.width == width &&
        other.compactWidth == compactWidth;
  }

  @override
  int get hashCode => Object.hash(width, compactWidth);
}
