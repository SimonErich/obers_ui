import 'package:flutter/widgets.dart';

/// Theme data for bottom-sheet / side-sheet components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiSheetThemeData {
  /// Creates an [OiSheetThemeData].
  const OiSheetThemeData({this.borderRadius});

  /// The corner radius applied to the top corners of the sheet surface.
  final BorderRadius? borderRadius;

  /// Creates a copy with optionally overridden values.
  OiSheetThemeData copyWith({BorderRadius? borderRadius}) {
    return OiSheetThemeData(borderRadius: borderRadius ?? this.borderRadius);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiSheetThemeData && other.borderRadius == borderRadius;
  }

  @override
  int get hashCode => borderRadius.hashCode;
}
