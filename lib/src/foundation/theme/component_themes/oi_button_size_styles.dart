import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_button_size_style.dart';

/// Nullable opt-in styles; omitted sizes retain exact legacy resolution.
///
/// {@category Foundation}
@immutable
class OiButtonSizeStyles {
  /// Creates independently optional size styles without an upward enum import.
  const OiButtonSizeStyles({this.small, this.medium, this.large});

  /// Explicit small-size overrides; null retains legacy resolution.
  final OiButtonSizeStyle? small;

  /// Explicit medium-size overrides; null retains legacy resolution.
  final OiButtonSizeStyle? medium;

  /// Explicit large-size overrides; null retains legacy resolution.
  final OiButtonSizeStyle? large;

  /// Omitted fields retain their current value, matching existing themes.
  OiButtonSizeStyles copyWith({
    OiButtonSizeStyle? small,
    OiButtonSizeStyle? medium,
    OiButtonSizeStyle? large,
  }) => OiButtonSizeStyles(
    small: small ?? this.small,
    medium: medium ?? this.medium,
    large: large ?? this.large,
  );

  /// Applies non-null overrides while retaining inherited state and size styles.
  OiButtonSizeStyles merge(OiButtonSizeStyles? other) {
    if (other == null) return this;
    return OiButtonSizeStyles(
      small: small?.merge(other.small) ?? other.small,
      medium: medium?.merge(other.medium) ?? other.medium,
      large: large?.merge(other.large) ?? other.large,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is OiButtonSizeStyles &&
      other.small == small &&
      other.medium == medium &&
      other.large == large;

  @override
  int get hashCode => Object.hash(small, medium, large);
}
