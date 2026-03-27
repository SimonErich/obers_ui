import 'package:flutter/widgets.dart';

/// Theme data for action bar components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiActionBarThemeData {
  /// Creates an [OiActionBarThemeData].
  const OiActionBarThemeData({this.spacing, this.padding});

  /// The spacing between action buttons.
  final double? spacing;

  /// The internal padding of the action bar.
  final EdgeInsetsGeometry? padding;

  /// Creates a copy with optionally overridden values.
  OiActionBarThemeData copyWith({
    double? spacing,
    EdgeInsetsGeometry? padding,
  }) {
    return OiActionBarThemeData(
      spacing: spacing ?? this.spacing,
      padding: padding ?? this.padding,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiActionBarThemeData &&
        other.spacing == spacing &&
        other.padding == padding;
  }

  @override
  int get hashCode => Object.hash(spacing, padding);
}
