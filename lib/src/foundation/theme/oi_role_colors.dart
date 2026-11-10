import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:obers_ui/src/foundation/theme/color/oi_semantic_color_interpolation.dart';

/// Explicit colors for one semantic role, independent of HSL swatch shades.
///
/// Values may be raw extended sRGB; this group performs no gamut mapping.
/// Optional interaction colors are absent unless explicitly authored.
///
/// {@category Foundation}
@immutable
class OiRoleColors {
  /// Creates a role with explicit fill, foreground, ink and soft surface.
  const OiRoleColors({
    required this.base,
    required this.onColor,
    required this.ink,
    required this.soft,
    this.hover,
    this.pressed,
    this.softHover,
  });

  /// Interpolates raw sRGB with premultiplied alpha, without gamut clipping.
  ///
  /// Exact endpoints are retained. Optional values carry a sole endpoint.
  /// Throws [ArgumentError] for fractions outside finite 0–1.
  factory OiRoleColors.lerp(
    OiRoleColors first,
    OiRoleColors second,
    double fraction,
  ) {
    if (fraction == 0) return first;
    if (fraction == 1) return second;
    Color mix(Color firstColor, Color secondColor) =>
        OiSemanticColorInterpolation.color(firstColor, secondColor, fraction);
    return OiRoleColors(
      base: mix(first.base, second.base),
      onColor: mix(first.onColor, second.onColor),
      ink: mix(first.ink, second.ink),
      soft: mix(first.soft, second.soft),
      hover: OiSemanticColorInterpolation.optional(
        first.hover,
        second.hover,
        fraction,
      ),
      pressed: OiSemanticColorInterpolation.optional(
        first.pressed,
        second.pressed,
        fraction,
      ),
      softHover: OiSemanticColorInterpolation.optional(
        first.softHover,
        second.softHover,
        fraction,
      ),
    );
  }

  /// The role's main fill.
  final Color base;

  /// Foreground drawn on [base].
  final Color onColor;

  /// Text/icon version drawn on a neutral or soft surface.
  final Color ink;

  /// Low-chroma surface version of the role.
  final Color soft;

  /// Optional hover fill; never inferred from [base].
  final Color? hover;

  /// Optional pressed fill; never inferred from [base].
  final Color? pressed;

  /// Optional hover version of [soft].
  final Color? softHover;

  /// Returns an independent value with supplied colors overridden.
  /// Clear flags take precedence over supplied optional colors.
  OiRoleColors copyWith({
    Color? base,
    Color? onColor,
    Color? ink,
    Color? soft,
    Color? hover,
    Color? pressed,
    Color? softHover,
    bool clearHover = false,
    bool clearPressed = false,
    bool clearSoftHover = false,
  }) => OiRoleColors(
    base: base ?? this.base,
    onColor: onColor ?? this.onColor,
    ink: ink ?? this.ink,
    soft: soft ?? this.soft,
    hover: clearHover ? null : hover ?? this.hover,
    pressed: clearPressed ? null : pressed ?? this.pressed,
    softHover: clearSoftHover ? null : softHover ?? this.softHover,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiRoleColors &&
          other.base == base &&
          other.onColor == onColor &&
          other.ink == ink &&
          other.soft == soft &&
          other.hover == hover &&
          other.pressed == pressed &&
          other.softHover == softHover;

  @override
  int get hashCode => Object.hash(
    base,
    onColor,
    ink,
    soft,
    hover,
    pressed,
    softHover,
  );
}
