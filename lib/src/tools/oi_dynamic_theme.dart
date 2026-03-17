import 'dart:ui';

import 'package:obers_ui/src/foundation/theme/oi_radius_scale.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';

/// Utility for generating dynamic themes from brand parameters.
///
/// This is a convenience wrapper around [OiThemeData.fromBrand] that
/// provides additional utilities for runtime theme generation.
class OiDynamicTheme {
  // Private constructor to prevent instantiation.
  OiDynamicTheme._();

  /// Generates a complete [OiThemeData] from a single brand color.
  ///
  /// Delegates to [OiThemeData.fromBrand] with the given parameters.
  static OiThemeData fromColor(
    Color color, {
    Brightness brightness = Brightness.light,
    String? fontFamily,
    OiRadiusPreference radiusPreference = OiRadiusPreference.medium,
  }) => OiThemeData.fromBrand(
    color: color,
    brightness: brightness,
    fontFamily: fontFamily,
    radiusPreference: radiusPreference,
  );

  /// Generates light and dark variants from a single brand color.
  ///
  /// Returns a record containing both the light and dark [OiThemeData]
  /// derived from the given [color].
  static ({OiThemeData light, OiThemeData dark}) fromColorPair(
    Color color, {
    String? fontFamily,
    OiRadiusPreference radiusPreference = OiRadiusPreference.medium,
  }) {
    return (
      light: OiThemeData.fromBrand(
        color: color,
        brightness: Brightness.light,
        fontFamily: fontFamily,
        radiusPreference: radiusPreference,
      ),
      dark: OiThemeData.fromBrand(
        color: color,
        brightness: Brightness.dark,
        fontFamily: fontFamily,
        radiusPreference: radiusPreference,
      ),
    );
  }

  /// Generates a theme from a seed color by extracting the dominant color.
  ///
  /// Returns the [OiThemeData.fromBrand] result using the provided
  /// [seedColor] as the brand color.
  static OiThemeData fromSeedColor(
    Color seedColor, {
    Brightness brightness = Brightness.light,
  }) => OiThemeData.fromBrand(color: seedColor, brightness: brightness);
}
