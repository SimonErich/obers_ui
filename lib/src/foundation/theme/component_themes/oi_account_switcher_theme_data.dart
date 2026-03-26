import 'package:flutter/widgets.dart';

/// Theme data for account switcher components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiAccountSwitcherThemeData {
  /// Creates an [OiAccountSwitcherThemeData].
  const OiAccountSwitcherThemeData({this.triggerPadding, this.dropdownWidth});

  /// Padding applied to the trigger button.
  final EdgeInsetsGeometry? triggerPadding;

  /// Width of the dropdown overlay.
  final double? dropdownWidth;

  /// Creates a copy with optionally overridden values.
  OiAccountSwitcherThemeData copyWith({
    EdgeInsetsGeometry? triggerPadding,
    double? dropdownWidth,
  }) {
    return OiAccountSwitcherThemeData(
      triggerPadding: triggerPadding ?? this.triggerPadding,
      dropdownWidth: dropdownWidth ?? this.dropdownWidth,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiAccountSwitcherThemeData &&
        other.triggerPadding == triggerPadding &&
        other.dropdownWidth == dropdownWidth;
  }

  @override
  int get hashCode => Object.hash(triggerPadding, dropdownWidth);
}
