import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:obers_ui/src/foundation/theme/oi_animation_config.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_scheme.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_swatch.dart';
import 'package:obers_ui/src/foundation/theme/oi_component_themes.dart';
import 'package:obers_ui/src/foundation/theme/oi_decoration_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_effects_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_radius_scale.dart';
import 'package:obers_ui/src/foundation/theme/oi_shadow_scale.dart';
import 'package:obers_ui/src/foundation/theme/oi_spacing_scale.dart';
import 'package:obers_ui/src/foundation/theme/oi_text_theme.dart';

/// The master theme container for the obers_ui design system.
///
/// [OiThemeData] aggregates all design tokens — colors, typography, spacing,
/// radii, shadows, animations, effects, and per-component overrides — into a
/// single immutable object.
///
/// Inject it into the widget tree via [OiApp] or [OiTheme].
///
/// {@category Foundation}
@immutable
class OiThemeData {
  /// Creates an [OiThemeData] with explicit values for all design tokens.
  const OiThemeData({
    required this.brightness,
    required this.colors,
    required this.textTheme,
    required this.spacing,
    required this.radius,
    required this.shadows,
    required this.animations,
    required this.effects,
    required this.decoration,
    required this.components,
    this.fontFamily,
    this.monoFontFamily,
  });

  /// Creates the standard light theme.
  factory OiThemeData.light({
    String? fontFamily,
    String? monoFontFamily,
    OiRadiusPreference radiusPreference = OiRadiusPreference.medium,
    OiComponentThemes? components,
  }) {
    final colors = OiColorScheme.light();
    return OiThemeData(
      brightness: Brightness.light,
      colors: colors,
      textTheme: OiTextTheme.standard(
        fontFamily: fontFamily,
        monoFontFamily: monoFontFamily,
      ),
      spacing: OiSpacingScale.standard(),
      radius: OiRadiusScale.forPreference(radiusPreference),
      shadows: OiShadowScale.standard(),
      animations: const OiAnimationConfig.standard(),
      effects: OiEffectsTheme.standard(primaryColor: colors.primary.base),
      decoration: OiDecorationTheme.standard(
        primaryColor: colors.primary.base,
        errorColor: colors.error.base,
      ),
      components: components ?? const OiComponentThemes.empty(),
      fontFamily: fontFamily,
      monoFontFamily: monoFontFamily,
    );
  }

  /// Creates the standard dark theme.
  factory OiThemeData.dark({
    String? fontFamily,
    String? monoFontFamily,
    OiRadiusPreference radiusPreference = OiRadiusPreference.medium,
    OiComponentThemes? components,
  }) {
    final colors = OiColorScheme.dark();
    return OiThemeData(
      brightness: Brightness.dark,
      colors: colors,
      textTheme: OiTextTheme.standard(
        fontFamily: fontFamily,
        monoFontFamily: monoFontFamily,
      ),
      spacing: OiSpacingScale.standard(),
      radius: OiRadiusScale.forPreference(radiusPreference),
      shadows: OiShadowScale.dark(),
      animations: const OiAnimationConfig.standard(),
      effects: OiEffectsTheme.standard(primaryColor: colors.primary.base),
      decoration: OiDecorationTheme.standard(
        primaryColor: colors.primary.base,
        errorColor: colors.error.base,
      ),
      components: components ?? const OiComponentThemes.empty(),
      fontFamily: fontFamily,
      monoFontFamily: monoFontFamily,
    );
  }

  /// Creates a theme derived from a brand color.
  ///
  /// The brand [color] is used as the primary swatch, and all other
  /// semantic colors are derived automatically.
  factory OiThemeData.fromBrand({
    required Color color,
    Brightness brightness = Brightness.light,
    String? fontFamily,
    String? monoFontFamily,
    OiRadiusPreference radiusPreference = OiRadiusPreference.medium,
    OiComponentThemes? components,
  }) {
    final base = brightness == Brightness.light
        ? OiThemeData.light(
            fontFamily: fontFamily,
            monoFontFamily: monoFontFamily,
            radiusPreference: radiusPreference,
            components: components,
          )
        : OiThemeData.dark(
            fontFamily: fontFamily,
            monoFontFamily: monoFontFamily,
            radiusPreference: radiusPreference,
            components: components,
          );

    // Override primary color with the brand color
    final brandColors = base.colors.copyWith(
      primary: OiColorSwatch.from(color),
      borderFocus: color,
    );

    return base.copyWith(
      colors: brandColors,
      effects: OiEffectsTheme.standard(primaryColor: color),
      decoration: OiDecorationTheme.standard(
        primaryColor: color,
        errorColor: base.colors.error.base,
      ),
    );
  }

  /// Whether this is a light or dark theme.
  final Brightness brightness;

  /// The color scheme providing all semantic color tokens.
  final OiColorScheme colors;

  /// The typography scale.
  final OiTextTheme textTheme;

  /// The spacing scale.
  final OiSpacingScale spacing;

  /// The border radius scale.
  final OiRadiusScale radius;

  /// The box shadow scale.
  final OiShadowScale shadows;

  /// The animation duration configuration.
  final OiAnimationConfig animations;

  /// The interactive state effects (hover, focus, active, etc.).
  final OiEffectsTheme effects;

  /// The decoration theme (borders, gradients).
  final OiDecorationTheme decoration;

  /// Per-component theme overrides.
  final OiComponentThemes components;

  /// Optional font family override for text styles.
  final String? fontFamily;

  /// Optional monospace font family for code text.
  final String? monoFontFamily;

  /// Whether this theme has dark brightness.
  bool get isDark => brightness == Brightness.dark;

  /// Whether this theme has light brightness.
  bool get isLight => brightness == Brightness.light;

  /// Creates a copy with optionally overridden fields.
  OiThemeData copyWith({
    Brightness? brightness,
    OiColorScheme? colors,
    OiTextTheme? textTheme,
    OiSpacingScale? spacing,
    OiRadiusScale? radius,
    OiShadowScale? shadows,
    OiAnimationConfig? animations,
    OiEffectsTheme? effects,
    OiDecorationTheme? decoration,
    OiComponentThemes? components,
    String? fontFamily,
    String? monoFontFamily,
  }) {
    return OiThemeData(
      brightness: brightness ?? this.brightness,
      colors: colors ?? this.colors,
      textTheme: textTheme ?? this.textTheme,
      spacing: spacing ?? this.spacing,
      radius: radius ?? this.radius,
      shadows: shadows ?? this.shadows,
      animations: animations ?? this.animations,
      effects: effects ?? this.effects,
      decoration: decoration ?? this.decoration,
      components: components ?? this.components,
      fontFamily: fontFamily ?? this.fontFamily,
      monoFontFamily: monoFontFamily ?? this.monoFontFamily,
    );
  }

  /// Merges [other] into this theme, with [other]'s non-null values taking
  /// precedence.
  OiThemeData merge(OiThemeData other) {
    return copyWith(
      brightness: other.brightness,
      colors: other.colors,
      textTheme: other.textTheme,
      spacing: other.spacing,
      radius: other.radius,
      shadows: other.shadows,
      animations: other.animations,
      effects: other.effects,
      decoration: other.decoration,
      components: other.components,
      fontFamily: other.fontFamily,
      monoFontFamily: other.monoFontFamily,
    );
  }

  /// Linearly interpolates between two [OiThemeData] instances.
  // lerp is a static method by Flutter convention, not a constructor.
  // ignore: prefer_constructors_over_static_methods
  static OiThemeData lerp(OiThemeData a, OiThemeData b, double t) {
    if (t == 0) return a;
    if (t == 1) return b;
    return OiThemeData(
      brightness: t < 0.5 ? a.brightness : b.brightness,
      colors: OiColorScheme.lerp(a.colors, b.colors, t),
      textTheme: OiTextTheme.lerp(a.textTheme, b.textTheme, t),
      spacing: t < 0.5 ? a.spacing : b.spacing,
      radius: t < 0.5 ? a.radius : b.radius,
      shadows: t < 0.5 ? a.shadows : b.shadows,
      animations: t < 0.5 ? a.animations : b.animations,
      effects: t < 0.5 ? a.effects : b.effects,
      decoration: t < 0.5 ? a.decoration : b.decoration,
      components: t < 0.5 ? a.components : b.components,
      fontFamily: t < 0.5 ? a.fontFamily : b.fontFamily,
      monoFontFamily: t < 0.5 ? a.monoFontFamily : b.monoFontFamily,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiThemeData &&
        other.brightness == brightness &&
        other.colors == colors &&
        other.textTheme == textTheme &&
        other.spacing == spacing &&
        other.radius == radius &&
        other.shadows == shadows &&
        other.animations == animations &&
        other.effects == effects &&
        other.decoration == decoration &&
        other.components == components &&
        other.fontFamily == fontFamily &&
        other.monoFontFamily == monoFontFamily;
  }

  @override
  int get hashCode => Object.hashAll([
    brightness,
    colors,
    textTheme,
    spacing,
    radius,
    shadows,
    animations,
    effects,
    decoration,
    components,
    fontFamily,
    monoFontFamily,
  ]);
}
