import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:obers_ui/src/foundation/theme/color/oi_color_mix.dart';
import 'package:obers_ui/src/foundation/theme/color/oi_oklab.dart';
import 'package:obers_ui/src/foundation/theme/color/oi_oklch.dart';
import 'package:obers_ui/src/foundation/theme/oi_role_colors.dart';

/// Internal source-exact role derivation shared by the public brand engine.
@internal
abstract final class OiBrandRole {
  /// Derives the explicit translucent primary focus halo without compositing.
  static Color focusHalo(OiOklch source, Brightness brightness) => OiOklch(
    lightness: brightness == Brightness.dark
        ? math.max(source.lightness, 0.7)
        : source.lightness,
    chroma: source.chroma,
    hue: source.hue,
    alpha: brightness == Brightness.dark ? 0.3 : 0.2,
  ).toColor();

  /// Derives the primary role, including its interaction colors.
  static OiRoleColors primary(OiOklch source, Brightness brightness) =>
      _derive(source, brightness, _OiBrandRoleKind.primary);

  /// Derives the secondary role without inventing interaction colors.
  static OiRoleColors secondary(OiOklch source, Brightness brightness) =>
      _derive(source, brightness, _OiBrandRoleKind.secondary);

  /// Derives the highlight role without inventing interaction colors.
  static OiRoleColors highlight(OiOklch source, Brightness brightness) =>
      _derive(source, brightness, _OiBrandRoleKind.highlight);

  static OiRoleColors _derive(
    OiOklch source,
    Brightness brightness,
    _OiBrandRoleKind kind,
  ) {
    final dark = brightness == Brightness.dark;
    final primary = kind == _OiBrandRoleKind.primary;
    final secondary = kind == _OiBrandRoleKind.secondary;
    final highlight = kind == _OiBrandRoleKind.highlight;
    final fill = source.toOklab();
    final luminance = fill.relativeLuminance;
    final encoded = fill
        .scaleLuminance(0.001 + 0.999 * _step(luminance - 0.1814))
        .toOklch();
    final switchAmount = ((encoded.lightness - 0.2) * 1000).clamp(0, 1);
    final textLightness = (0.9 * (encoded.lightness - 0.62) + 0.1).clamp(
      0.1,
      0.26,
    );
    final onColor = OiOklch(
      lightness: 1 - switchAmount * (1 - textLightness),
      chroma: switchAmount * (0.008 + 0.2 * (textLightness - 0.1)),
      hue: encoded.hue,
      alpha: source.alpha,
    );
    final chromaCap = primary ? 0.2 : (secondary ? 0.09 : 0.1);
    final capped = dark
        ? fill
        : _polar(
            source,
            source.lightness,
            math.min(source.chroma, chromaCap),
          ).toOklab();
    final target = highlight ? 0.45 : 0.4;
    final factor = dark
        ? math.max<double>(
            1,
            target / math.max(capped.relativeLuminance, 0.0001),
          )
        : math.min<double>(
            1,
            0.118 / math.max(capped.relativeLuminance, 0.0001),
          );
    final scaled = capped.scaleLuminance(factor).toOklch();
    final ink = _polar(
      scaled,
      dark
          ? math.max(scaled.lightness, highlight ? 0.75 : 0.72)
          : math.min(scaled.lightness, secondary ? 0.54 : 0.56),
      dark ? math.min(scaled.chroma, secondary ? 0.09 : 0.1) : scaled.chroma,
    );
    final soft = switch (kind) {
      _OiBrandRoleKind.primary => (
        lightness: dark ? 0.272 : 0.955,
        scale: dark ? 0.4 : 0.15,
        cap: dark ? 0.034 : 0.022,
      ),
      _OiBrandRoleKind.secondary => (
        lightness: dark ? 0.268 : 0.958,
        scale: dark ? 0.36 : 0.26,
        cap: dark ? 0.020 : 0.016,
      ),
      _OiBrandRoleKind.highlight => (
        lightness: dark ? 0.282 : 0.965,
        scale: dark ? 0.42 : 0.34,
        cap: dark ? 0.030 : 0.026,
      ),
    };
    final away = primary ? _away(luminance, source.alpha) : null;
    return OiRoleColors(
      base: source.toColor(),
      onColor: onColor.toColor(),
      hover: away == null
          ? null
          : OiColorMix.oklab(fill, away, secondPercent: 10).toColor(),
      pressed: away == null
          ? null
          : OiColorMix.oklab(fill, away, secondPercent: 17).toColor(),
      ink: ink.toColor(),
      soft: _polar(
        source,
        soft.lightness,
        math.min(source.chroma * soft.scale, soft.cap),
      ).toColor(),
      softHover: primary
          ? _polar(
              source,
              dark ? 0.310 : 0.93,
              dark
                  ? math.min(source.chroma * 0.52, 0.044)
                  : math.min(source.chroma * 0.24, 0.032),
            ).toColor()
          : null,
    );
  }

  static OiOklab _away(double luminance, double alpha) {
    final factor =
        _step(luminance - 0.1814) * _step(0.7 - luminance) +
        _step(0.03 - luminance);
    return OiOklab.fromXyzD65(
      x: 0.95047 * factor,
      y: factor,
      z: 1.08883 * factor,
      alpha: alpha,
    );
  }

  static OiOklch _polar(OiOklch source, double lightness, double chroma) =>
      OiOklch(
        lightness: lightness,
        chroma: chroma,
        hue: source.hue,
        alpha: source.alpha,
      );

  static double _step(double value) => (value * 100000).clamp(0, 1);
}

enum _OiBrandRoleKind { primary, secondary, highlight }
