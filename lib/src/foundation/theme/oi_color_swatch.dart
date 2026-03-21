import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:obers_ui/obers_ui.dart' show OiColorScheme;
import 'package:obers_ui/src/foundation/theme/oi_color_scheme.dart'
    show OiColorScheme;

/// A color token with five semantic shade variants.
///
/// Each swatch represents a single brand/semantic color with automatically
/// derived or explicitly provided shade variants. Used throughout
/// [OiColorScheme] to represent primary, accent, success, warning, error,
/// and info colors.
///
/// {@category Foundation}
@immutable
class OiColorSwatch {
  /// Creates an [OiColorSwatch] with explicit shade values.
  const OiColorSwatch({
    required this.base,
    required this.light,
    required this.dark,
    required this.muted,
    required this.foreground,
  });

  /// Derives shade variants from [base] using HSL color manipulation.
  ///
  /// - [light]: increased lightness (+20%)
  /// - [dark]: decreased lightness (-20%)
  /// - [muted]: desaturated to 40%, increased lightness (+30%)
  /// - [foreground]: white or black depending on contrast with [base]
  factory OiColorSwatch.from(Color base) {
    final hsl = HSLColor.fromColor(base);
    final light = hsl
        .withLightness((hsl.lightness + 0.20).clamp(0.0, 1.0))
        .toColor();
    final dark = hsl
        .withLightness((hsl.lightness - 0.20).clamp(0.0, 1.0))
        .toColor();
    final muted = hsl
        .withSaturation((hsl.saturation * 0.4).clamp(0.0, 1.0))
        .withLightness((hsl.lightness + 0.30).clamp(0.0, 1.0))
        .toColor();
    // WCAG contrast: use white on dark backgrounds, black on light.
    final luminance = base.computeLuminance();
    final foreground = luminance < 0.35
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF000000);
    return OiColorSwatch(
      base: base,
      light: light,
      dark: dark,
      muted: muted,
      foreground: foreground,
    );
  }

  /// Linearly interpolates between two [OiColorSwatch]es.
  ///
  /// [t] must be in the range [0, 1]. At [t] = 0 the result equals [a];
  /// at [t] = 1 the result equals [b].
  OiColorSwatch.lerp(OiColorSwatch a, OiColorSwatch b, double t)
    : base = Color.lerp(a.base, b.base, t)!,
      light = Color.lerp(a.light, b.light, t)!,
      dark = Color.lerp(a.dark, b.dark, t)!,
      muted = Color.lerp(a.muted, b.muted, t)!,
      foreground = Color.lerp(a.foreground, b.foreground, t)!;

  /// The primary/base shade.
  final Color base;

  /// A lighter variant, suitable for backgrounds and hover states.
  final Color light;

  /// A darker variant, suitable for pressed/active states.
  final Color dark;

  /// A muted/desaturated variant, suitable for disabled or subtle contexts.
  final Color muted;

  /// A foreground color (white or black) with sufficient contrast over [base].
  final Color foreground;

  /// Creates a copy with optionally overridden fields.
  OiColorSwatch copyWith({
    Color? base,
    Color? light,
    Color? dark,
    Color? muted,
    Color? foreground,
  }) {
    return OiColorSwatch(
      base: base ?? this.base,
      light: light ?? this.light,
      dark: dark ?? this.dark,
      muted: muted ?? this.muted,
      foreground: foreground ?? this.foreground,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiColorSwatch &&
        other.base == base &&
        other.light == light &&
        other.dark == dark &&
        other.muted == muted &&
        other.foreground == foreground;
  }

  @override
  int get hashCode => Object.hash(base, light, dark, muted, foreground);

  @override
  String toString() =>
      'OiColorSwatch('
      'base: $base, '
      'light: $light, '
      'dark: $dark, '
      'muted: $muted, '
      'foreground: $foreground)';
}
