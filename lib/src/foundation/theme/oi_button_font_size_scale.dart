import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show FontWeight;

/// Per-size font sizes and weights for `OiButton`.
///
/// Buttons typically have their own typography scale separate from body /
/// caption text — coupling them to `OiTextTheme` would force the theme to
/// remember which text role maps to which button size. This class keeps
/// the two concerns independent: configure button typography in pixels and
/// weights directly.
///
/// Defaults match the built-in button sizes (12/14/16, w500).
///
/// {@category Foundation}
@immutable
class OiButtonFontSizeScale {
  /// Creates an [OiButtonFontSizeScale] with explicit values.
  const OiButtonFontSizeScale({
    this.small = 12,
    this.medium = 14,
    this.large = 16,
    this.weightSmall = FontWeight.w500,
    this.weightMedium = FontWeight.w500,
    this.weightLarge = FontWeight.w500,
  });

  /// Font size for small buttons.
  final double small;

  /// Font size for medium-size (default) buttons.
  final double medium;

  /// Font size for large buttons.
  final double large;

  /// Font weight for small buttons.
  final FontWeight weightSmall;

  /// Font weight for medium-size (default) buttons.
  final FontWeight weightMedium;

  /// Font weight for large buttons.
  final FontWeight weightLarge;

  /// Creates a copy with optionally overridden values.
  OiButtonFontSizeScale copyWith({
    double? small,
    double? medium,
    double? large,
    FontWeight? weightSmall,
    FontWeight? weightMedium,
    FontWeight? weightLarge,
  }) {
    return OiButtonFontSizeScale(
      small: small ?? this.small,
      medium: medium ?? this.medium,
      large: large ?? this.large,
      weightSmall: weightSmall ?? this.weightSmall,
      weightMedium: weightMedium ?? this.weightMedium,
      weightLarge: weightLarge ?? this.weightLarge,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiButtonFontSizeScale &&
        other.small == small &&
        other.medium == medium &&
        other.large == large &&
        other.weightSmall == weightSmall &&
        other.weightMedium == weightMedium &&
        other.weightLarge == weightLarge;
  }

  @override
  int get hashCode => Object.hash(
        small,
        medium,
        large,
        weightSmall,
        weightMedium,
        weightLarge,
      );
}
