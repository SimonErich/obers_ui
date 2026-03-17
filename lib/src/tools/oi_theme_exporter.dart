import 'dart:convert';
import 'dart:ui';

import 'package:flutter/painting.dart';
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
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';

/// Utility class for exporting and importing [OiThemeData].
///
/// Supports JSON serialization for theme persistence and sharing,
/// as well as Dart source code generation.
class OiThemeExporter {
  // Private constructor to prevent instantiation.
  OiThemeExporter._();

  // ── JSON Export ──────────────────────────────────────────────────────────

  /// Converts an [OiThemeData] instance to a JSON string.
  ///
  /// The resulting JSON includes all theme tokens: colors, text styles,
  /// spacing, radius, shadows, animation config, effects, and decoration.
  static String toJson(OiThemeData theme) {
    return const JsonEncoder.withIndent('  ').convert(toMap(theme));
  }

  /// Converts an [OiThemeData] instance to a JSON-encodable map.
  static Map<String, dynamic> toMap(OiThemeData theme) {
    return {
      'brightness': theme.brightness == Brightness.dark ? 'dark' : 'light',
      'colors': _colorSchemeToMap(theme.colors),
      'textTheme': _textThemeToMap(theme.textTheme),
      'spacing': _spacingToMap(theme.spacing),
      'radius': _radiusToMap(theme.radius),
      'shadows': _shadowsToMap(theme.shadows),
      'animations': _animationsToMap(theme.animations),
      'effects': _effectsToMap(theme.effects),
      'decoration': _decorationToMap(theme.decoration),
      if (theme.fontFamily != null) 'fontFamily': theme.fontFamily,
      if (theme.monoFontFamily != null) 'monoFontFamily': theme.monoFontFamily,
    };
  }

  // ── JSON Import ──────────────────────────────────────────────────────────

  /// Creates an [OiThemeData] from a JSON string.
  ///
  /// Missing or invalid fields fall back to the light theme defaults.
  /// If the JSON string is malformed, returns [OiThemeData.light].
  static OiThemeData fromJson(String json) {
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return fromMap(map);
    } on FormatException {
      return OiThemeData.light();
    } on Exception {
      return OiThemeData.light();
    }
  }

  /// Creates an [OiThemeData] from a JSON-encodable map.
  ///
  /// Missing or invalid fields fall back to the light theme defaults.
  static OiThemeData fromMap(Map<String, dynamic> map) {
    final isDark = map['brightness'] == 'dark';
    final defaults = isDark ? OiThemeData.dark() : OiThemeData.light();

    return OiThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      colors: _colorSchemeFromMap(
        map['colors'] as Map<String, dynamic>?,
        defaults.colors,
      ),
      textTheme: _textThemeFromMap(
        map['textTheme'] as Map<String, dynamic>?,
        defaults.textTheme,
      ),
      spacing: _spacingFromMap(
        map['spacing'] as Map<String, dynamic>?,
        defaults.spacing,
      ),
      radius: _radiusFromMap(
        map['radius'] as Map<String, dynamic>?,
        defaults.radius,
      ),
      shadows: _shadowsFromMap(
        map['shadows'] as Map<String, dynamic>?,
        defaults.shadows,
      ),
      animations: _animationsFromMap(
        map['animations'] as Map<String, dynamic>?,
        defaults.animations,
      ),
      effects: _effectsFromMap(
        map['effects'] as Map<String, dynamic>?,
        defaults.effects,
      ),
      decoration: _decorationFromMap(
        map['decoration'] as Map<String, dynamic>?,
        defaults.decoration,
      ),
      components: const OiComponentThemes.empty(),
      fontFamily: map['fontFamily'] as String?,
      monoFontFamily: map['monoFontFamily'] as String?,
    );
  }

  // ── Dart Code Generation ─────────────────────────────────────────────────

  /// Generates a Dart source code string that creates the given theme.
  ///
  /// The output is valid Dart code that can be pasted into a project:
  /// ```dart
  /// final theme = OiThemeData(
  ///   colors: OiColorScheme(
  ///     background: Color(0xFFFFFFFF),
  ///     ...
  ///   ),
  ///   ...
  /// );
  /// ```
  ///
  /// The [variableName] parameter controls the name of the variable in the
  /// generated code.
  static String toDart(OiThemeData theme, {String variableName = 'theme'}) {
    final buf = StringBuffer()
      ..writeln(
        'final $variableName = OiThemeData(',
      )
      ..writeln(
        '  brightness: ${theme.brightness == Brightness.dark ? 'Brightness.dark' : 'Brightness.light'},',
      )
      ..writeln('  colors: OiColorScheme(');
    _writeDartColorScheme(buf, theme.colors);
    buf
      ..writeln('  ),')
      ..writeln('  textTheme: OiTextTheme(');
    _writeDartTextTheme(buf, theme.textTheme);
    buf
      ..writeln('  ),')
      ..writeln('  spacing: OiSpacingScale(');
    _writeDartSpacing(buf, theme.spacing);
    buf
      ..writeln('  ),')
      ..writeln('  radius: OiRadiusScale(');
    _writeDartRadius(buf, theme.radius);
    buf
      ..writeln('  ),')
      ..writeln('  shadows: OiShadowScale(');
    _writeDartShadows(buf, theme.shadows);
    buf
      ..writeln('  ),')
      ..writeln('  animations: OiAnimationConfig(');
    _writeDartAnimations(buf, theme.animations);
    buf
      ..writeln('  ),')
      ..writeln('  effects: OiEffectsTheme(');
    _writeDartEffects(buf, theme.effects);
    buf
      ..writeln('  ),')
      ..writeln('  decoration: OiDecorationTheme(');
    _writeDartDecoration(buf, theme.decoration);
    buf
      ..writeln('  ),')
      ..writeln('  components: const OiComponentThemes.empty(),');
    if (theme.fontFamily != null) {
      buf.writeln("  fontFamily: '${theme.fontFamily}',");
    }
    if (theme.monoFontFamily != null) {
      buf.writeln("  monoFontFamily: '${theme.monoFontFamily}',");
    }
    buf.writeln(');');
    return buf.toString();
  }

  // ── Color helpers ────────────────────────────────────────────────────────

  /// Encodes a [Color] as a hex string including alpha.
  static String _colorToHex(Color color) {
    final a = (color.a * 255).round();
    final r = (color.r * 255).round();
    final g = (color.g * 255).round();
    final b = (color.b * 255).round();
    return '#${a.toRadixString(16).padLeft(2, '0')}'
        '${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }

  /// Decodes a hex string to a [Color].
  ///
  /// Supports "#AARRGGBB" (8 hex digits) and "#RRGGBB" (6 hex digits).
  static Color _hexToColor(String hex) {
    var h = hex.replaceAll('#', '');
    if (h.length == 6) h = 'FF$h';
    if (h.length != 8) return const Color(0x00000000);
    final value = int.tryParse(h, radix: 16);
    if (value == null) return const Color(0x00000000);
    return Color(value);
  }

  /// Converts a [Color] to a Dart `Color(0x...)` literal.
  static String _colorToDart(Color color) {
    final a = (color.a * 255).round();
    final r = (color.r * 255).round();
    final g = (color.g * 255).round();
    final b = (color.b * 255).round();
    final value = (a << 24) | (r << 16) | (g << 8) | b;
    return 'const Color(0x${value.toRadixString(16).padLeft(8, '0').toUpperCase()})';
  }

  // ── OiColorSwatch ────────────────────────────────────────────────────────

  /// Serializes an [OiColorSwatch] to a map.
  static Map<String, String> _swatchToMap(OiColorSwatch swatch) {
    return {
      'base': _colorToHex(swatch.base),
      'light': _colorToHex(swatch.light),
      'dark': _colorToHex(swatch.dark),
      'muted': _colorToHex(swatch.muted),
      'foreground': _colorToHex(swatch.foreground),
    };
  }

  /// Deserializes an [OiColorSwatch] from a map.
  static OiColorSwatch _swatchFromMap(
    Map<String, dynamic>? map,
    OiColorSwatch fallback,
  ) {
    if (map == null) return fallback;
    return OiColorSwatch(
      base: _hexToColor(map['base'] as String? ?? ''),
      light: _hexToColor(map['light'] as String? ?? ''),
      dark: _hexToColor(map['dark'] as String? ?? ''),
      muted: _hexToColor(map['muted'] as String? ?? ''),
      foreground: _hexToColor(map['foreground'] as String? ?? ''),
    );
  }

  // ── OiColorScheme ────────────────────────────────────────────────────────

  /// Serializes an [OiColorScheme] to a map.
  static Map<String, dynamic> _colorSchemeToMap(OiColorScheme colors) {
    return {
      'primary': _swatchToMap(colors.primary),
      'accent': _swatchToMap(colors.accent),
      'success': _swatchToMap(colors.success),
      'warning': _swatchToMap(colors.warning),
      'error': _swatchToMap(colors.error),
      'info': _swatchToMap(colors.info),
      'background': _colorToHex(colors.background),
      'surface': _colorToHex(colors.surface),
      'surfaceHover': _colorToHex(colors.surfaceHover),
      'surfaceActive': _colorToHex(colors.surfaceActive),
      'surfaceSubtle': _colorToHex(colors.surfaceSubtle),
      'overlay': _colorToHex(colors.overlay),
      'text': _colorToHex(colors.text),
      'textSubtle': _colorToHex(colors.textSubtle),
      'textMuted': _colorToHex(colors.textMuted),
      'textInverse': _colorToHex(colors.textInverse),
      'textOnPrimary': _colorToHex(colors.textOnPrimary),
      'border': _colorToHex(colors.border),
      'borderSubtle': _colorToHex(colors.borderSubtle),
      'borderFocus': _colorToHex(colors.borderFocus),
      'borderError': _colorToHex(colors.borderError),
      'glassBackground': _colorToHex(colors.glassBackground),
      'glassBorder': _colorToHex(colors.glassBorder),
      'chart': colors.chart.map(_colorToHex).toList(),
    };
  }

  /// Deserializes an [OiColorScheme] from a map.
  static OiColorScheme _colorSchemeFromMap(
    Map<String, dynamic>? map,
    OiColorScheme fallback,
  ) {
    if (map == null) return fallback;
    return OiColorScheme(
      primary: _swatchFromMap(
        map['primary'] as Map<String, dynamic>?,
        fallback.primary,
      ),
      accent: _swatchFromMap(
        map['accent'] as Map<String, dynamic>?,
        fallback.accent,
      ),
      success: _swatchFromMap(
        map['success'] as Map<String, dynamic>?,
        fallback.success,
      ),
      warning: _swatchFromMap(
        map['warning'] as Map<String, dynamic>?,
        fallback.warning,
      ),
      error: _swatchFromMap(
        map['error'] as Map<String, dynamic>?,
        fallback.error,
      ),
      info: _swatchFromMap(
        map['info'] as Map<String, dynamic>?,
        fallback.info,
      ),
      background:
          _hexToColorOr(map['background'] as String?, fallback.background),
      surface: _hexToColorOr(map['surface'] as String?, fallback.surface),
      surfaceHover:
          _hexToColorOr(map['surfaceHover'] as String?, fallback.surfaceHover),
      surfaceActive: _hexToColorOr(
        map['surfaceActive'] as String?,
        fallback.surfaceActive,
      ),
      surfaceSubtle: _hexToColorOr(
        map['surfaceSubtle'] as String?,
        fallback.surfaceSubtle,
      ),
      overlay: _hexToColorOr(map['overlay'] as String?, fallback.overlay),
      text: _hexToColorOr(map['text'] as String?, fallback.text),
      textSubtle:
          _hexToColorOr(map['textSubtle'] as String?, fallback.textSubtle),
      textMuted:
          _hexToColorOr(map['textMuted'] as String?, fallback.textMuted),
      textInverse:
          _hexToColorOr(map['textInverse'] as String?, fallback.textInverse),
      textOnPrimary: _hexToColorOr(
        map['textOnPrimary'] as String?,
        fallback.textOnPrimary,
      ),
      border: _hexToColorOr(map['border'] as String?, fallback.border),
      borderSubtle:
          _hexToColorOr(map['borderSubtle'] as String?, fallback.borderSubtle),
      borderFocus:
          _hexToColorOr(map['borderFocus'] as String?, fallback.borderFocus),
      borderError:
          _hexToColorOr(map['borderError'] as String?, fallback.borderError),
      glassBackground: _hexToColorOr(
        map['glassBackground'] as String?,
        fallback.glassBackground,
      ),
      glassBorder:
          _hexToColorOr(map['glassBorder'] as String?, fallback.glassBorder),
      chart: _chartFromMap(map['chart'], fallback.chart),
    );
  }

  /// Parses a color from a hex string, falling back to [fallback].
  static Color _hexToColorOr(String? hex, Color fallback) {
    if (hex == null || hex.isEmpty) return fallback;
    return _hexToColor(hex);
  }

  /// Parses the chart color list from a dynamic value.
  static List<Color> _chartFromMap(dynamic value, List<Color> fallback) {
    if (value is! List) return fallback;
    return value.map((e) => _hexToColor(e as String? ?? '')).toList();
  }

  // ── OiTextTheme ──────────────────────────────────────────────────────────

  /// Serializes a [TextStyle] to a map.
  static Map<String, dynamic> _textStyleToMap(TextStyle style) {
    return {
      if (style.fontFamily != null) 'fontFamily': style.fontFamily,
      if (style.fontSize != null) 'fontSize': style.fontSize,
      if (style.fontWeight != null)
        'fontWeight': _fontWeightToInt(style.fontWeight!),
      if (style.height != null) 'height': style.height,
      if (style.letterSpacing != null) 'letterSpacing': style.letterSpacing,
      if (style.decoration != null && style.decoration != TextDecoration.none)
        'decoration': _textDecorationToString(style.decoration!),
    };
  }

  /// Deserializes a [TextStyle] from a map.
  static TextStyle _textStyleFromMap(
    Map<String, dynamic>? map,
    TextStyle fallback,
  ) {
    if (map == null) return fallback;
    return TextStyle(
      fontFamily: map['fontFamily'] as String? ?? fallback.fontFamily,
      fontSize: (map['fontSize'] as num?)?.toDouble() ?? fallback.fontSize,
      fontWeight: _intToFontWeight(map['fontWeight'] as int?) ??
          fallback.fontWeight,
      height: (map['height'] as num?)?.toDouble() ?? fallback.height,
      letterSpacing:
          (map['letterSpacing'] as num?)?.toDouble() ?? fallback.letterSpacing,
      decoration: _stringToTextDecoration(map['decoration'] as String?) ??
          fallback.decoration,
    );
  }

  /// Serializes the full [OiTextTheme] to a map.
  static Map<String, dynamic> _textThemeToMap(OiTextTheme textTheme) {
    return {
      'display': _textStyleToMap(textTheme.display),
      'h1': _textStyleToMap(textTheme.h1),
      'h2': _textStyleToMap(textTheme.h2),
      'h3': _textStyleToMap(textTheme.h3),
      'h4': _textStyleToMap(textTheme.h4),
      'body': _textStyleToMap(textTheme.body),
      'bodyStrong': _textStyleToMap(textTheme.bodyStrong),
      'small': _textStyleToMap(textTheme.small),
      'smallStrong': _textStyleToMap(textTheme.smallStrong),
      'tiny': _textStyleToMap(textTheme.tiny),
      'caption': _textStyleToMap(textTheme.caption),
      'code': _textStyleToMap(textTheme.code),
      'overline': _textStyleToMap(textTheme.overline),
      'link': _textStyleToMap(textTheme.link),
    };
  }

  /// Deserializes an [OiTextTheme] from a map.
  static OiTextTheme _textThemeFromMap(
    Map<String, dynamic>? map,
    OiTextTheme fallback,
  ) {
    if (map == null) return fallback;
    return OiTextTheme(
      display: _textStyleFromMap(
        map['display'] as Map<String, dynamic>?,
        fallback.display,
      ),
      h1: _textStyleFromMap(
        map['h1'] as Map<String, dynamic>?,
        fallback.h1,
      ),
      h2: _textStyleFromMap(
        map['h2'] as Map<String, dynamic>?,
        fallback.h2,
      ),
      h3: _textStyleFromMap(
        map['h3'] as Map<String, dynamic>?,
        fallback.h3,
      ),
      h4: _textStyleFromMap(
        map['h4'] as Map<String, dynamic>?,
        fallback.h4,
      ),
      body: _textStyleFromMap(
        map['body'] as Map<String, dynamic>?,
        fallback.body,
      ),
      bodyStrong: _textStyleFromMap(
        map['bodyStrong'] as Map<String, dynamic>?,
        fallback.bodyStrong,
      ),
      small: _textStyleFromMap(
        map['small'] as Map<String, dynamic>?,
        fallback.small,
      ),
      smallStrong: _textStyleFromMap(
        map['smallStrong'] as Map<String, dynamic>?,
        fallback.smallStrong,
      ),
      tiny: _textStyleFromMap(
        map['tiny'] as Map<String, dynamic>?,
        fallback.tiny,
      ),
      caption: _textStyleFromMap(
        map['caption'] as Map<String, dynamic>?,
        fallback.caption,
      ),
      code: _textStyleFromMap(
        map['code'] as Map<String, dynamic>?,
        fallback.code,
      ),
      overline: _textStyleFromMap(
        map['overline'] as Map<String, dynamic>?,
        fallback.overline,
      ),
      link: _textStyleFromMap(
        map['link'] as Map<String, dynamic>?,
        fallback.link,
      ),
    );
  }

  /// Converts a [FontWeight] to its integer value (100-900).
  static int _fontWeightToInt(FontWeight weight) {
    return weight.value;
  }

  /// Converts an integer to a [FontWeight], or returns null.
  static FontWeight? _intToFontWeight(int? value) {
    if (value == null) return null;
    const weights = {
      100: FontWeight.w100,
      200: FontWeight.w200,
      300: FontWeight.w300,
      400: FontWeight.w400,
      500: FontWeight.w500,
      600: FontWeight.w600,
      700: FontWeight.w700,
      800: FontWeight.w800,
      900: FontWeight.w900,
    };
    return weights[value];
  }

  /// Converts a [TextDecoration] to its string name.
  static String _textDecorationToString(TextDecoration decoration) {
    if (decoration == TextDecoration.underline) return 'underline';
    if (decoration == TextDecoration.lineThrough) return 'lineThrough';
    if (decoration == TextDecoration.overline) return 'overline';
    return 'none';
  }

  /// Converts a string name to a [TextDecoration].
  static TextDecoration? _stringToTextDecoration(String? name) {
    switch (name) {
      case 'underline':
        return TextDecoration.underline;
      case 'lineThrough':
        return TextDecoration.lineThrough;
      case 'overline':
        return TextDecoration.overline;
      case 'none':
        return TextDecoration.none;
      default:
        return null;
    }
  }

  // ── OiSpacingScale ───────────────────────────────────────────────────────

  /// Serializes an [OiSpacingScale] to a map.
  static Map<String, double> _spacingToMap(OiSpacingScale spacing) {
    return {
      'xs': spacing.xs,
      'sm': spacing.sm,
      'md': spacing.md,
      'lg': spacing.lg,
      'xl': spacing.xl,
      'xxl': spacing.xxl,
      'pageGutterCompact': spacing.pageGutterCompact,
      'pageGutterMedium': spacing.pageGutterMedium,
      'pageGutterExpanded': spacing.pageGutterExpanded,
      'pageGutterLarge': spacing.pageGutterLarge,
      'pageGutterExtraLarge': spacing.pageGutterExtraLarge,
    };
  }

  /// Deserializes an [OiSpacingScale] from a map.
  static OiSpacingScale _spacingFromMap(
    Map<String, dynamic>? map,
    OiSpacingScale fallback,
  ) {
    if (map == null) return fallback;
    return OiSpacingScale(
      xs: (map['xs'] as num?)?.toDouble() ?? fallback.xs,
      sm: (map['sm'] as num?)?.toDouble() ?? fallback.sm,
      md: (map['md'] as num?)?.toDouble() ?? fallback.md,
      lg: (map['lg'] as num?)?.toDouble() ?? fallback.lg,
      xl: (map['xl'] as num?)?.toDouble() ?? fallback.xl,
      xxl: (map['xxl'] as num?)?.toDouble() ?? fallback.xxl,
      pageGutterCompact: (map['pageGutterCompact'] as num?)?.toDouble() ??
          fallback.pageGutterCompact,
      pageGutterMedium: (map['pageGutterMedium'] as num?)?.toDouble() ??
          fallback.pageGutterMedium,
      pageGutterExpanded: (map['pageGutterExpanded'] as num?)?.toDouble() ??
          fallback.pageGutterExpanded,
      pageGutterLarge: (map['pageGutterLarge'] as num?)?.toDouble() ??
          fallback.pageGutterLarge,
      pageGutterExtraLarge:
          (map['pageGutterExtraLarge'] as num?)?.toDouble() ??
              fallback.pageGutterExtraLarge,
    );
  }

  // ── OiRadiusScale ────────────────────────────────────────────────────────

  /// Serializes a [BorderRadius] to its top-left radius value.
  static double _borderRadiusToDouble(BorderRadius radius) {
    return radius.topLeft.x;
  }

  /// Deserializes a [BorderRadius] from a double value.
  static BorderRadius _doubleToBorderRadius(double value) {
    if (value == 0) return BorderRadius.zero;
    return BorderRadius.all(Radius.circular(value));
  }

  /// Serializes an [OiRadiusScale] to a map.
  static Map<String, double> _radiusToMap(OiRadiusScale radius) {
    return {
      'none': _borderRadiusToDouble(radius.none),
      'xs': _borderRadiusToDouble(radius.xs),
      'sm': _borderRadiusToDouble(radius.sm),
      'md': _borderRadiusToDouble(radius.md),
      'lg': _borderRadiusToDouble(radius.lg),
      'xl': _borderRadiusToDouble(radius.xl),
      'full': _borderRadiusToDouble(radius.full),
    };
  }

  /// Deserializes an [OiRadiusScale] from a map.
  static OiRadiusScale _radiusFromMap(
    Map<String, dynamic>? map,
    OiRadiusScale fallback,
  ) {
    if (map == null) return fallback;
    return OiRadiusScale(
      none: _doubleToBorderRadius(
        (map['none'] as num?)?.toDouble() ??
            _borderRadiusToDouble(fallback.none),
      ),
      xs: _doubleToBorderRadius(
        (map['xs'] as num?)?.toDouble() ??
            _borderRadiusToDouble(fallback.xs),
      ),
      sm: _doubleToBorderRadius(
        (map['sm'] as num?)?.toDouble() ??
            _borderRadiusToDouble(fallback.sm),
      ),
      md: _doubleToBorderRadius(
        (map['md'] as num?)?.toDouble() ??
            _borderRadiusToDouble(fallback.md),
      ),
      lg: _doubleToBorderRadius(
        (map['lg'] as num?)?.toDouble() ??
            _borderRadiusToDouble(fallback.lg),
      ),
      xl: _doubleToBorderRadius(
        (map['xl'] as num?)?.toDouble() ??
            _borderRadiusToDouble(fallback.xl),
      ),
      full: _doubleToBorderRadius(
        (map['full'] as num?)?.toDouble() ??
            _borderRadiusToDouble(fallback.full),
      ),
    );
  }

  // ── OiShadowScale ───────────────────────────────────────────────────────

  /// Serializes a list of [BoxShadow] to a list of maps.
  static List<Map<String, dynamic>> _boxShadowListToMap(
    List<BoxShadow> shadows,
  ) {
    return shadows.map((s) {
      return <String, dynamic>{
        'color': _colorToHex(s.color),
        'offsetX': s.offset.dx,
        'offsetY': s.offset.dy,
        'blurRadius': s.blurRadius,
        'spreadRadius': s.spreadRadius,
      };
    }).toList();
  }

  /// Deserializes a list of [BoxShadow] from a list of maps.
  static List<BoxShadow> _boxShadowListFromMap(dynamic value) {
    if (value is! List) return [];
    return value.map((e) {
      final map = e as Map<String, dynamic>;
      return BoxShadow(
        color: _hexToColor(map['color'] as String? ?? ''),
        offset: Offset(
          (map['offsetX'] as num?)?.toDouble() ?? 0,
          (map['offsetY'] as num?)?.toDouble() ?? 0,
        ),
        blurRadius: (map['blurRadius'] as num?)?.toDouble() ?? 0,
        spreadRadius: (map['spreadRadius'] as num?)?.toDouble() ?? 0,
      );
    }).toList();
  }

  /// Serializes an [OiShadowScale] to a map.
  static Map<String, dynamic> _shadowsToMap(OiShadowScale shadows) {
    return {
      'none': _boxShadowListToMap(shadows.none),
      'xs': _boxShadowListToMap(shadows.xs),
      'sm': _boxShadowListToMap(shadows.sm),
      'md': _boxShadowListToMap(shadows.md),
      'lg': _boxShadowListToMap(shadows.lg),
      'xl': _boxShadowListToMap(shadows.xl),
      'glass': _boxShadowListToMap(shadows.glass),
    };
  }

  /// Deserializes an [OiShadowScale] from a map.
  static OiShadowScale _shadowsFromMap(
    Map<String, dynamic>? map,
    OiShadowScale fallback,
  ) {
    if (map == null) return fallback;
    return OiShadowScale(
      none: map.containsKey('none')
          ? _boxShadowListFromMap(map['none'])
          : fallback.none,
      xs: map.containsKey('xs')
          ? _boxShadowListFromMap(map['xs'])
          : fallback.xs,
      sm: map.containsKey('sm')
          ? _boxShadowListFromMap(map['sm'])
          : fallback.sm,
      md: map.containsKey('md')
          ? _boxShadowListFromMap(map['md'])
          : fallback.md,
      lg: map.containsKey('lg')
          ? _boxShadowListFromMap(map['lg'])
          : fallback.lg,
      xl: map.containsKey('xl')
          ? _boxShadowListFromMap(map['xl'])
          : fallback.xl,
      glass: map.containsKey('glass')
          ? _boxShadowListFromMap(map['glass'])
          : fallback.glass,
    );
  }

  // ── OiAnimationConfig ────────────────────────────────────────────────────

  /// Serializes an [OiAnimationConfig] to a map (durations as milliseconds).
  static Map<String, dynamic> _animationsToMap(OiAnimationConfig animations) {
    return {
      'fastMs': animations.fast.inMilliseconds,
      'normalMs': animations.normal.inMilliseconds,
      'slowMs': animations.slow.inMilliseconds,
      'reducedMotion': animations.reducedMotion,
    };
  }

  /// Deserializes an [OiAnimationConfig] from a map.
  static OiAnimationConfig _animationsFromMap(
    Map<String, dynamic>? map,
    OiAnimationConfig fallback,
  ) {
    if (map == null) return fallback;
    return OiAnimationConfig(
      fast: Duration(
        milliseconds: (map['fastMs'] as num?)?.toInt() ??
            fallback.fast.inMilliseconds,
      ),
      normal: Duration(
        milliseconds: (map['normalMs'] as num?)?.toInt() ??
            fallback.normal.inMilliseconds,
      ),
      slow: Duration(
        milliseconds: (map['slowMs'] as num?)?.toInt() ??
            fallback.slow.inMilliseconds,
      ),
      reducedMotion: map['reducedMotion'] as bool? ?? fallback.reducedMotion,
    );
  }

  // ── OiEffectsTheme ───────────────────────────────────────────────────────

  /// Serializes an [OiHaloStyle] to a map.
  static Map<String, dynamic> _haloToMap(OiHaloStyle halo) {
    return {
      'color': _colorToHex(halo.color),
      'spread': halo.spread,
      'blur': halo.blur,
    };
  }

  /// Deserializes an [OiHaloStyle] from a map.
  static OiHaloStyle _haloFromMap(
    Map<String, dynamic>? map,
    OiHaloStyle fallback,
  ) {
    if (map == null) return fallback;
    return OiHaloStyle(
      color: _hexToColorOr(map['color'] as String?, fallback.color),
      spread: (map['spread'] as num?)?.toDouble() ?? fallback.spread,
      blur: (map['blur'] as num?)?.toDouble() ?? fallback.blur,
    );
  }

  /// Serializes an [OiInteractiveStyle] to a map.
  static Map<String, dynamic> _interactiveStyleToMap(
    OiInteractiveStyle style,
  ) {
    return {
      'backgroundOverlay': _colorToHex(style.backgroundOverlay),
      'halo': _haloToMap(style.halo),
      'scale': style.scale,
    };
  }

  /// Deserializes an [OiInteractiveStyle] from a map.
  static OiInteractiveStyle _interactiveStyleFromMap(
    Map<String, dynamic>? map,
    OiInteractiveStyle fallback,
  ) {
    if (map == null) return fallback;
    return OiInteractiveStyle(
      backgroundOverlay: _hexToColorOr(
        map['backgroundOverlay'] as String?,
        fallback.backgroundOverlay,
      ),
      halo: _haloFromMap(
        map['halo'] as Map<String, dynamic>?,
        fallback.halo,
      ),
      scale: (map['scale'] as num?)?.toDouble() ?? fallback.scale,
    );
  }

  /// Serializes an [OiEffectsTheme] to a map.
  static Map<String, dynamic> _effectsToMap(OiEffectsTheme effects) {
    return {
      'hover': _interactiveStyleToMap(effects.hover),
      'focus': _interactiveStyleToMap(effects.focus),
      'active': _interactiveStyleToMap(effects.active),
      'disabled': _interactiveStyleToMap(effects.disabled),
      'selected': _interactiveStyleToMap(effects.selected),
      'dragging': _interactiveStyleToMap(effects.dragging),
    };
  }

  /// Deserializes an [OiEffectsTheme] from a map.
  static OiEffectsTheme _effectsFromMap(
    Map<String, dynamic>? map,
    OiEffectsTheme fallback,
  ) {
    if (map == null) return fallback;
    return OiEffectsTheme(
      hover: _interactiveStyleFromMap(
        map['hover'] as Map<String, dynamic>?,
        fallback.hover,
      ),
      focus: _interactiveStyleFromMap(
        map['focus'] as Map<String, dynamic>?,
        fallback.focus,
      ),
      active: _interactiveStyleFromMap(
        map['active'] as Map<String, dynamic>?,
        fallback.active,
      ),
      disabled: _interactiveStyleFromMap(
        map['disabled'] as Map<String, dynamic>?,
        fallback.disabled,
      ),
      selected: _interactiveStyleFromMap(
        map['selected'] as Map<String, dynamic>?,
        fallback.selected,
      ),
      dragging: _interactiveStyleFromMap(
        map['dragging'] as Map<String, dynamic>?,
        fallback.dragging,
      ),
    );
  }

  // ── OiDecorationTheme ────────────────────────────────────────────────────

  /// Serializes an [OiBorderStyle] to a map.
  static Map<String, dynamic> _borderStyleToMap(OiBorderStyle border) {
    return {
      'lineStyle': border.lineStyle.name,
      'color': _colorToHex(border.color),
      'width': border.width,
      if (border.borderRadius != null)
        'borderRadius': _borderRadiusToDouble(border.borderRadius!),
    };
  }

  /// Deserializes an [OiBorderStyle] from a map.
  static OiBorderStyle _borderStyleFromMap(
    Map<String, dynamic>? map,
    OiBorderStyle fallback,
  ) {
    if (map == null) return fallback;
    final lineStyleName = map['lineStyle'] as String?;
    OiBorderLineStyle lineStyle;
    switch (lineStyleName) {
      case 'dashed':
        lineStyle = OiBorderLineStyle.dashed;
      case 'dotted':
        lineStyle = OiBorderLineStyle.dotted;
      default:
        lineStyle = OiBorderLineStyle.solid;
    }
    return OiBorderStyle(
      lineStyle: lineStyle,
      color: _hexToColorOr(map['color'] as String?, fallback.color),
      width: (map['width'] as num?)?.toDouble() ?? fallback.width,
      borderRadius: map['borderRadius'] != null
          ? _doubleToBorderRadius((map['borderRadius'] as num).toDouble())
          : fallback.borderRadius,
    );
  }

  /// Serializes an [OiGradientStyle] to a map.
  static Map<String, dynamic> _gradientStyleToMap(OiGradientStyle gradient) {
    return {
      'isLinear': gradient.isLinear,
      'colors': gradient.colors.map(_colorToHex).toList(),
      if (gradient.stops != null) 'stops': gradient.stops,
    };
  }

  /// Deserializes an [OiGradientStyle] from a map.
  static OiGradientStyle _gradientStyleFromMap(Map<String, dynamic> map) {
    final colors = (map['colors'] as List)
        .map((c) => _hexToColor(c as String? ?? ''))
        .toList();
    final stops =
        (map['stops'] as List?)?.map((s) => (s as num).toDouble()).toList();
    return OiGradientStyle(
      isLinear: map['isLinear'] as bool? ?? true,
      colors: colors,
      stops: stops,
    );
  }

  /// Serializes an [OiDecorationTheme] to a map.
  static Map<String, dynamic> _decorationToMap(OiDecorationTheme decoration) {
    return {
      'defaultBorder': _borderStyleToMap(decoration.defaultBorder),
      'focusBorder': _borderStyleToMap(decoration.focusBorder),
      'errorBorder': _borderStyleToMap(decoration.errorBorder),
      'gradients': decoration.gradients.map(
        (key, value) => MapEntry(key, _gradientStyleToMap(value)),
      ),
    };
  }

  /// Deserializes an [OiDecorationTheme] from a map.
  static OiDecorationTheme _decorationFromMap(
    Map<String, dynamic>? map,
    OiDecorationTheme fallback,
  ) {
    if (map == null) return fallback;
    final gradientsRaw = map['gradients'] as Map<String, dynamic>?;
    final gradients = <String, OiGradientStyle>{};
    if (gradientsRaw != null) {
      for (final entry in gradientsRaw.entries) {
        gradients[entry.key] =
            _gradientStyleFromMap(entry.value as Map<String, dynamic>);
      }
    }
    return OiDecorationTheme(
      defaultBorder: _borderStyleFromMap(
        map['defaultBorder'] as Map<String, dynamic>?,
        fallback.defaultBorder,
      ),
      focusBorder: _borderStyleFromMap(
        map['focusBorder'] as Map<String, dynamic>?,
        fallback.focusBorder,
      ),
      errorBorder: _borderStyleFromMap(
        map['errorBorder'] as Map<String, dynamic>?,
        fallback.errorBorder,
      ),
      gradients: gradients.isNotEmpty ? gradients : fallback.gradients,
    );
  }

  // ── Dart code generation helpers ─────────────────────────────────────────

  /// Writes the color scheme fields as Dart source code.
  static void _writeDartColorScheme(StringBuffer buf, OiColorScheme colors) {
    void writeSwatch(String name, OiColorSwatch s) {
      buf
        ..writeln('    $name: OiColorSwatch(')
        ..writeln('      base: ${_colorToDart(s.base)},')
        ..writeln('      light: ${_colorToDart(s.light)},')
        ..writeln('      dark: ${_colorToDart(s.dark)},')
        ..writeln('      muted: ${_colorToDart(s.muted)},')
        ..writeln('      foreground: ${_colorToDart(s.foreground)},')
        ..writeln('    ),');
    }

    writeSwatch('primary', colors.primary);
    writeSwatch('accent', colors.accent);
    writeSwatch('success', colors.success);
    writeSwatch('warning', colors.warning);
    writeSwatch('error', colors.error);
    writeSwatch('info', colors.info);
    buf
      ..writeln('    background: ${_colorToDart(colors.background)},')
      ..writeln('    surface: ${_colorToDart(colors.surface)},')
      ..writeln('    surfaceHover: ${_colorToDart(colors.surfaceHover)},')
      ..writeln('    surfaceActive: ${_colorToDart(colors.surfaceActive)},')
      ..writeln('    surfaceSubtle: ${_colorToDart(colors.surfaceSubtle)},')
      ..writeln('    overlay: ${_colorToDart(colors.overlay)},')
      ..writeln('    text: ${_colorToDart(colors.text)},')
      ..writeln('    textSubtle: ${_colorToDart(colors.textSubtle)},')
      ..writeln('    textMuted: ${_colorToDart(colors.textMuted)},')
      ..writeln('    textInverse: ${_colorToDart(colors.textInverse)},')
      ..writeln('    textOnPrimary: ${_colorToDart(colors.textOnPrimary)},')
      ..writeln('    border: ${_colorToDart(colors.border)},')
      ..writeln('    borderSubtle: ${_colorToDart(colors.borderSubtle)},')
      ..writeln('    borderFocus: ${_colorToDart(colors.borderFocus)},')
      ..writeln('    borderError: ${_colorToDart(colors.borderError)},')
      ..writeln(
        '    glassBackground: ${_colorToDart(colors.glassBackground)},',
      )
      ..writeln('    glassBorder: ${_colorToDart(colors.glassBorder)},')
      ..write('    chart: [');
    for (final c in colors.chart) {
      buf.write('${_colorToDart(c)}, ');
    }
    buf.writeln('],');
  }

  /// Writes text theme fields as Dart source code.
  static void _writeDartTextTheme(StringBuffer buf, OiTextTheme textTheme) {
    void writeStyle(String name, TextStyle s) {
      buf.write('    $name: TextStyle(');
      final parts = <String>[];
      if (s.fontFamily != null) parts.add("fontFamily: '${s.fontFamily}'");
      if (s.fontSize != null) parts.add('fontSize: ${s.fontSize}');
      if (s.fontWeight != null) {
        parts.add('fontWeight: FontWeight.w${s.fontWeight!.value}');
      }
      if (s.height != null) parts.add('height: ${s.height}');
      if (s.letterSpacing != null) {
        parts.add('letterSpacing: ${s.letterSpacing}');
      }
      if (s.decoration != null && s.decoration != TextDecoration.none) {
        parts.add(
          'decoration: TextDecoration.${_textDecorationToString(s.decoration!)}',
        );
      }
      buf
        ..write(parts.join(', '))
        ..writeln('),');
    }

    writeStyle('display', textTheme.display);
    writeStyle('h1', textTheme.h1);
    writeStyle('h2', textTheme.h2);
    writeStyle('h3', textTheme.h3);
    writeStyle('h4', textTheme.h4);
    writeStyle('body', textTheme.body);
    writeStyle('bodyStrong', textTheme.bodyStrong);
    writeStyle('small', textTheme.small);
    writeStyle('smallStrong', textTheme.smallStrong);
    writeStyle('tiny', textTheme.tiny);
    writeStyle('caption', textTheme.caption);
    writeStyle('code', textTheme.code);
    writeStyle('overline', textTheme.overline);
    writeStyle('link', textTheme.link);
  }

  /// Writes spacing fields as Dart source code.
  static void _writeDartSpacing(StringBuffer buf, OiSpacingScale spacing) {
    buf
      ..writeln('    xs: ${spacing.xs},')
      ..writeln('    sm: ${spacing.sm},')
      ..writeln('    md: ${spacing.md},')
      ..writeln('    lg: ${spacing.lg},')
      ..writeln('    xl: ${spacing.xl},')
      ..writeln('    xxl: ${spacing.xxl},')
      ..writeln('    pageGutterCompact: ${spacing.pageGutterCompact},')
      ..writeln('    pageGutterMedium: ${spacing.pageGutterMedium},')
      ..writeln('    pageGutterExpanded: ${spacing.pageGutterExpanded},')
      ..writeln('    pageGutterLarge: ${spacing.pageGutterLarge},')
      ..writeln(
        '    pageGutterExtraLarge: ${spacing.pageGutterExtraLarge},',
      );
  }

  /// Writes radius fields as Dart source code.
  static void _writeDartRadius(StringBuffer buf, OiRadiusScale radius) {
    void writeRadius(String name, BorderRadius r) {
      final v = r.topLeft.x;
      if (v == 0) {
        buf.writeln('    $name: BorderRadius.zero,');
      } else {
        buf.writeln('    $name: BorderRadius.all(Radius.circular($v)),');
      }
    }

    writeRadius('none', radius.none);
    writeRadius('xs', radius.xs);
    writeRadius('sm', radius.sm);
    writeRadius('md', radius.md);
    writeRadius('lg', radius.lg);
    writeRadius('xl', radius.xl);
    writeRadius('full', radius.full);
  }

  /// Writes shadow fields as Dart source code.
  static void _writeDartShadows(StringBuffer buf, OiShadowScale shadows) {
    void writeShadowList(String name, List<BoxShadow> list) {
      if (list.isEmpty) {
        buf.writeln('    $name: const [],');
        return;
      }
      buf.writeln('    $name: [');
      for (final s in list) {
        buf
          ..writeln('      BoxShadow(')
          ..writeln('        color: ${_colorToDart(s.color)},');
        if (s.offset != Offset.zero) {
          buf.writeln(
            '        offset: Offset(${s.offset.dx}, ${s.offset.dy}),',
          );
        }
        if (s.blurRadius != 0) {
          buf.writeln('        blurRadius: ${s.blurRadius},');
        }
        if (s.spreadRadius != 0) {
          buf.writeln('        spreadRadius: ${s.spreadRadius},');
        }
        buf.writeln('      ),');
      }
      buf.writeln('    ],');
    }

    writeShadowList('none', shadows.none);
    writeShadowList('xs', shadows.xs);
    writeShadowList('sm', shadows.sm);
    writeShadowList('md', shadows.md);
    writeShadowList('lg', shadows.lg);
    writeShadowList('xl', shadows.xl);
    writeShadowList('glass', shadows.glass);
  }

  /// Writes animation config fields as Dart source code.
  static void _writeDartAnimations(
    StringBuffer buf,
    OiAnimationConfig animations,
  ) {
    buf
      ..writeln(
        '    fast: Duration(milliseconds: ${animations.fast.inMilliseconds}),',
      )
      ..writeln(
        '    normal: Duration(milliseconds: ${animations.normal.inMilliseconds}),',
      )
      ..writeln(
        '    slow: Duration(milliseconds: ${animations.slow.inMilliseconds}),',
      )
      ..writeln('    reducedMotion: ${animations.reducedMotion},');
  }

  /// Writes effects theme fields as Dart source code.
  static void _writeDartEffects(StringBuffer buf, OiEffectsTheme effects) {
    void writeInteractiveStyle(String name, OiInteractiveStyle style) {
      buf
        ..writeln('    $name: OiInteractiveStyle(')
        ..writeln(
          '      backgroundOverlay: ${_colorToDart(style.backgroundOverlay)},',
        )
        ..writeln('      halo: OiHaloStyle(')
        ..writeln('        color: ${_colorToDart(style.halo.color)},')
        ..writeln('        spread: ${style.halo.spread},')
        ..writeln('        blur: ${style.halo.blur},')
        ..writeln('      ),')
        ..writeln('      scale: ${style.scale},')
        ..writeln('    ),');
    }

    writeInteractiveStyle('hover', effects.hover);
    writeInteractiveStyle('focus', effects.focus);
    writeInteractiveStyle('active', effects.active);
    writeInteractiveStyle('disabled', effects.disabled);
    writeInteractiveStyle('selected', effects.selected);
    writeInteractiveStyle('dragging', effects.dragging);
  }

  /// Writes decoration theme fields as Dart source code.
  static void _writeDartDecoration(
    StringBuffer buf,
    OiDecorationTheme decoration,
  ) {
    void writeBorder(String name, OiBorderStyle b) {
      buf
        ..writeln('    $name: OiBorderStyle(')
        ..writeln(
          '      lineStyle: OiBorderLineStyle.${b.lineStyle.name},',
        )
        ..writeln('      color: ${_colorToDart(b.color)},')
        ..writeln('      width: ${b.width},');
      if (b.borderRadius != null) {
        final r = b.borderRadius!.topLeft.x;
        if (r == 0) {
          buf.writeln('      borderRadius: BorderRadius.zero,');
        } else {
          buf.writeln(
            '      borderRadius: BorderRadius.all(Radius.circular($r)),',
          );
        }
      }
      buf.writeln('    ),');
    }

    writeBorder('defaultBorder', decoration.defaultBorder);
    writeBorder('focusBorder', decoration.focusBorder);
    writeBorder('errorBorder', decoration.errorBorder);
    buf.writeln('    gradients: {');
    for (final entry in decoration.gradients.entries) {
      buf
        ..write("      '${entry.key}': OiGradientStyle(")
        ..write('isLinear: ${entry.value.isLinear}, ')
        ..write('colors: [');
      for (final c in entry.value.colors) {
        buf.write('${_colorToDart(c)}, ');
      }
      buf.write(']');
      if (entry.value.stops != null) {
        buf.write(', stops: ${entry.value.stops}');
      }
      buf.writeln('),');
    }
    buf.writeln('    },');
  }
}
