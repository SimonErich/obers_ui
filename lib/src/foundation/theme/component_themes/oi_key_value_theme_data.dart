import 'package:flutter/widgets.dart';

/// Theme data for key-value display components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiKeyValueThemeData {
  /// Creates an [OiKeyValueThemeData].
  const OiKeyValueThemeData({this.labelWidth, this.padding, this.dividerColor});

  /// Default fixed width for labels in horizontal layout.
  final double? labelWidth;

  /// The internal padding of each key-value row.
  final EdgeInsetsGeometry? padding;

  /// The color of dividers between grouped rows.
  final Color? dividerColor;

  /// Creates a copy with optionally overridden values.
  OiKeyValueThemeData copyWith({
    double? labelWidth,
    EdgeInsetsGeometry? padding,
    Color? dividerColor,
  }) {
    return OiKeyValueThemeData(
      labelWidth: labelWidth ?? this.labelWidth,
      padding: padding ?? this.padding,
      dividerColor: dividerColor ?? this.dividerColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiKeyValueThemeData &&
        other.labelWidth == labelWidth &&
        other.padding == padding &&
        other.dividerColor == dividerColor;
  }

  @override
  int get hashCode => Object.hash(labelWidth, padding, dividerColor);
}
