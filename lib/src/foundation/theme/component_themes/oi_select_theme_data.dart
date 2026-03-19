import 'package:flutter/widgets.dart';

/// Theme data for select / dropdown components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiSelectThemeData {
  /// Creates an [OiSelectThemeData].
  const OiSelectThemeData({this.borderRadius, this.itemHeight});

  /// The corner radius applied to the select control border.
  final BorderRadius? borderRadius;

  /// The height of each option item in the dropdown list.
  final double? itemHeight;

  /// Creates a copy with optionally overridden values.
  OiSelectThemeData copyWith({BorderRadius? borderRadius, double? itemHeight}) {
    return OiSelectThemeData(
      borderRadius: borderRadius ?? this.borderRadius,
      itemHeight: itemHeight ?? this.itemHeight,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiSelectThemeData &&
        other.borderRadius == borderRadius &&
        other.itemHeight == itemHeight;
  }

  @override
  int get hashCode => Object.hash(borderRadius, itemHeight);
}
