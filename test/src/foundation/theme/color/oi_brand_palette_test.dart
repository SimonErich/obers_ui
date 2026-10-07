import 'dart:ui' show Brightness, ColorSpace;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

void main() {
  test(
    'on-color transition preserves the fractional encoded-lightness ramp',
    () {
      // Independent exact D65-gray oracle: L=cbrt(Y), then the source equations.
      final fixtures = <double, (double, double)>{
        0.18140043: (1, 0),
        0.181400432: (0.9245621530481631, 0.0006705586395718832),
        0.181400433: (0.7888636825778164, 0.0018767672659749657),
        0.181400435: (0.5180781335825437, 0.004283749923710722),
        0.18140044: (0.1, 0.008),
      };
      for (final fixture in fixtures.entries) {
        final luminance = fixture.key;
        final fill = OiOklab.fromXyzD65(
          x: 0.3127 / 0.3290 * luminance,
          y: luminance,
          z: (1 - 0.3127 - 0.3290) / 0.3290 * luminance,
        ).toOklch();
        final palette = OiBrandPalette.derive(
          primary: fill,
          secondary: fill,
          highlight: fill,
          brightness: Brightness.light,
        );
        for (final role in [
          palette.primary,
          palette.secondary,
          palette.highlight,
        ]) {
          final foreground = OiOklch.fromColor(role.onColor);
          expect(foreground.lightness, closeTo(fixture.value.$1, 0.000001));
          expect(foreground.chroma, closeTo(fixture.value.$2, 0.0000001));
        }
      }
    },
  );

  test('apricot and sage source vectors are distinct from pinned presets', () {
    final apricotLight = OiBrandPalette.derive(
      primary: const OiOklch(lightness: 0.255, chroma: 0.010, hue: 60),
      secondary: const OiOklch(lightness: 0.74, chroma: 0.040, hue: 250),
      highlight: const OiOklch(lightness: 0.80, chroma: 0.090, hue: 55),
      brightness: Brightness.light,
    );
    expect(_clipped(apricotLight.primary.hover!), 0xFF393431);
    expect(_clipped(apricotLight.primary.pressed!), 0xFF46423E);
    expect(_clipped(apricotLight.primary.onColor), 0xFFFFFFFF);
    final apricotDark = OiBrandPalette.derive(
      primary: const OiOklch(lightness: 0.93, chroma: 0.006, hue: 70),
      secondary: const OiOklch(lightness: 0.72, chroma: 0.04, hue: 250),
      highlight: const OiOklch(lightness: 0.78, chroma: 0.085, hue: 55),
      brightness: Brightness.dark,
    );
    expect(_clipped(apricotDark.primary.hover!), 0xFFCCC9C6);
    expect(_clipped(apricotDark.primary.pressed!), 0xFFB7B4B1);
    final sage = OiBrandPalette.derive(
      primary: const OiOklch(lightness: 0.49, chroma: 0.060, hue: 232),
      secondary: const OiOklch(lightness: 0.82, chroma: 0.065, hue: 158),
      highlight: const OiOklch(lightness: 0.80, chroma: 0.085, hue: 35),
      brightness: Brightness.light,
    );
    expect(_clipped(sage.primary.hover!), 0xFF32586C);
    expect(_clipped(sage.charts.first), 0xFF00698F);
    expect(sage.charts.first.r, lessThan(0));
  });

  test('high chroma preserves gamut and the source light/dark cap order', () {
    // Actual Chrome154 original CSS oracle, independently computed above.
    for (final brightness in Brightness.values) {
      final dark = brightness == Brightness.dark;
      const fill = OiOklch(lightness: 0.65, chroma: 0.4, hue: 30, alpha: 0.4);
      final palette = OiBrandPalette.derive(
        primary: fill,
        secondary: fill,
        highlight: fill,
        brightness: brightness,
      );
      expect(palette.primary.base.g, lessThan(0));
      expect(palette.primary.base.r, greaterThan(1));
      _polar(
        palette.primary.ink,
        dark ? 0.800131 : 0.508629,
        dark ? 0.1 : 0.156502,
        30,
        tolerance: 0.00002,
      );
      _polar(palette.primary.onColor, 0.127, 0.0134, 30);
      expect(palette.primary.ink.a, 0.4);
      expect(palette.primary.onColor.a, 0.4);
      expect(palette.primary.hover!.a, closeTo(0.4, 0.0000001));
      _polar(
        palette.primary.soft,
        dark ? 0.272 : 0.955,
        dark ? 0.034 : 0.022,
        30,
      );
      final caps = dark
          ? [0.05, 0.07, 0.09, 0.1, 0.092, 0.072]
          : [0.022, 0.045, 0.07, 0.095, 0.112, 0.108];
      for (var index = 0; index < caps.length; index++) {
        expect(
          OiOklch.fromColor(palette.charts.sequential.colors[index]).chroma,
          closeTo(caps[index], 0.000001),
        );
      }
      _polar(palette.rail.badge, 0.74, 0.4, 30);
    }
  });

  test(
    'transparent black, white and missing hue stay finite without fake opacity',
    () {
      for (final lightness in [0.0, 1.0]) {
        for (final brightness in Brightness.values) {
          final fill = OiOklch(
            lightness: lightness,
            chroma: 0,
            hue: null,
            alpha: 0,
          );
          final palette = OiBrandPalette.derive(
            primary: fill,
            secondary: fill,
            highlight: fill,
            brightness: brightness,
          );
          for (final color in [
            palette.primary.base,
            palette.primary.onColor,
            palette.primary.ink,
            palette.primary.soft,
            palette.primary.hover!,
            palette.primary.pressed!,
            palette.infoColor,
            palette.rail.badge,
          ]) {
            expect(color.a, 0);
            expect(
              color.r.isFinite && color.g.isFinite && color.b.isFinite,
              isTrue,
            );
          }
          expect(
            palette.focusHalo.a,
            brightness == Brightness.dark ? 0.3 : 0.2,
          );
          // Missing hue is numerically zero when a raw RGB result is required.
          _polar(
            palette.rail.active,
            brightness == Brightness.dark ? 0.745 : 0.805,
            0.02,
            0,
          );
        }
      }
      final authored = OiBrandPalette.derive(
        primary: const OiOklch(lightness: 0.5, chroma: 0, hue: 280),
        secondary: const OiOklch(lightness: 0.5, chroma: 0, hue: 280),
        highlight: const OiOklch(lightness: 0.5, chroma: 0, hue: 280),
        brightness: Brightness.light,
      );
      _polar(authored.surfaces.sheet, 0.997, 0.0015, 280);
    },
  );

  test('explicit application preserves undefined roles and legacy scheme', () {
    final legacy = OiColorScheme.light();
    final base = OiLegacySemanticColors.fromScheme(legacy);
    final palette = OiBrandPalette.derive(
      primary: const OiOklch(lightness: 0.525, chroma: 0.118, hue: 283),
      secondary: const OiOklch(lightness: 0.8, chroma: 0.058, hue: 222),
      highlight: const OiOklch(lightness: 0.87, chroma: 0.078, hue: 76),
      brightness: Brightness.light,
    );
    final result = palette.applyTo(base);
    expect(result.primary, palette.primary);
    expect(result.secondary.hover, base.secondary.hover);
    expect(result.highlight.pressed, base.highlight.pressed);
    expect(result.highlight.softHover, base.highlight.softHover);
    expect(result.info.base, palette.infoColor);
    expect(result.info.soft, palette.infoSoft);
    expect(result.info.ink, base.info.ink);
    expect(result.info.onColor, base.info.onColor);
    expect(result.info.hover, base.info.hover);
    expect(result.charts.fourth, base.charts.fourth);
    expect(result.charts.fifth, base.charts.fifth);
    expect(result.charts.sixth, base.charts.sixth);
    expect(result.charts.negative, base.charts.negative);
    expect(result.charts.sequential, palette.charts.sequential);
    expect(result.surfaces, palette.surfaces);
    expect(result.inks, palette.inks);
    expect(result.rail, palette.rail);
    expect(result.focusHalo, palette.focusHalo);
    expect(base.info.base, legacy.info.base);
    expect(legacy, OiColorScheme.light());
    final absent = base.copyWith(
      secondary: base.secondary.copyWith(
        clearHover: true,
        clearPressed: true,
        clearSoftHover: true,
      ),
      highlight: base.highlight.copyWith(
        clearHover: true,
        clearPressed: true,
        clearSoftHover: true,
      ),
    );
    final authored = palette.copyWith(
      secondary: palette.secondary.copyWith(
        hover: palette.infoColor,
        pressed: palette.infoColor,
        softHover: palette.infoColor,
      ),
      highlight: palette.highlight.copyWith(
        hover: palette.infoColor,
        pressed: palette.infoColor,
        softHover: palette.infoColor,
      ),
    );
    final merged = authored.applyTo(absent);
    expect(merged.secondary.hover, isNull);
    expect(merged.secondary.pressed, isNull);
    expect(merged.secondary.softHover, isNull);
    expect(merged.highlight.hover, isNull);
    expect(merged.highlight.pressed, isNull);
    expect(merged.highlight.softHover, isNull);
    expect(palette.copyWith(), palette);
    expect(palette.copyWith().hashCode, palette.hashCode);
    expect(
      palette.copyWith(infoSoft: palette.infoColor).infoSoft,
      palette.infoColor,
    );
  });

  test(
    'charts derive only source slots and a deeply immutable six-color ramp',
    () {
      const primary = OiOklch(
        lightness: 0.35,
        chroma: 0.05,
        hue: 246,
        alpha: 0.6,
      );
      const secondary = OiOklch(lightness: 0.9, chroma: 0.3, hue: 170);
      const highlight = OiOklch(lightness: 0.9, chroma: 0.2, hue: 76);
      for (final brightness in Brightness.values) {
        final dark = brightness == Brightness.dark;
        final palette = OiBrandPalette.derive(
          primary: primary,
          secondary: secondary,
          highlight: highlight,
          brightness: brightness,
        );
        final charts = palette.charts;
        expect(
          OiBrandCharts.derive(
            primary: primary,
            secondary: secondary,
            highlight: highlight,
            brightness: brightness,
          ),
          charts,
        );
        _polar(charts.first, dark ? 0.5 : 0.45, 0.1, 246);
        _polar(charts.second, dark ? 0.66 : 0.76, 0.12, 76);
        _polar(charts.third, dark ? 0.66 : 0.74, 0.12, 170);
        _polar(charts.positive, dark ? 0.5 : 0.45, 0.1, 246);
        _polar(charts.middle, dark ? 0.36 : 0.9, dark ? 0.01 : 0.006, 246);
        _polar(charts.muted, dark ? 0.42 : 0.8, dark ? 0.01 : 0.008, 246);
        final lightness = dark
            ? [0.3, 0.39, 0.48, 0.58, 0.68, 0.79]
            : [0.94, 0.865, 0.775, 0.675, 0.575, 0.465];
        final chroma = dark
            ? [0.03, 0.041, 0.05, 0.05, 0.05, 0.0425]
            : [0.0095, 0.019, 0.03, 0.04, 0.0475, 0.046];
        final ramp = charts.sequential;
        for (var index = 0; index < 6; index++) {
          _polar(ramp.colors[index], lightness[index], chroma[index], 246);
          expect(ramp.colors[index].a, 0.6);
        }
        expect(
          () => ramp.colors[0] = const Color(0x00000000),
          throwsUnsupportedError,
        );
        expect(ramp.copyWith(), ramp);
        expect(ramp.copyWith().hashCode, ramp.hashCode);
        expect(charts.copyWith(), charts);
        expect(charts.copyWith().hashCode, charts.hashCode);
      }
    },
  );

  test(
    'tinted inks/info and brand rail/focus retain their distinct sources',
    () {
      const primary = OiOklch(
        lightness: 0.525,
        chroma: 0.118,
        hue: 283,
        alpha: 0.6,
      );
      const highlight = OiOklch(
        lightness: 0.3,
        chroma: 0.078,
        hue: 76,
        alpha: 0.8,
      );
      for (final brightness in Brightness.values) {
        final dark = brightness == Brightness.dark;
        final palette = OiBrandPalette.derive(
          primary: primary,
          secondary: primary,
          highlight: highlight,
          tint: const OiOklch(
            lightness: 0.5,
            chroma: 0.03,
            hue: 160,
            alpha: 0.4,
          ),
          brightness: brightness,
        );
        final inks = palette.inks;
        final fixtures = <Color, (double, double)>{
          inks.primary: dark ? (0.955, 0.004) : (0.235, 0.016),
          inks.muted: dark ? (0.775, 0.01) : (0.47, 0.014),
          inks.subtle: dark ? (0.615, 0.01) : (0.6, 0.01),
          inks.onInverse: dark ? (0.215, 0.012) : (0.975, 0.004),
          inks.inverseMuted: dark ? (0.455, 0.012) : (0.765, 0.01),
          palette.infoColor: (dark ? 0.62 : 0.6, 0.012),
          palette.infoSoft: dark ? (0.252, 0.008) : (0.958, 0.005),
          palette.rail.surface: dark ? (0.104, 0.008) : (0.235, 0.02),
          palette.rail.ink: dark ? (0.705, 0.01) : (0.785, 0.012),
        };
        for (final fixture in fixtures.entries) {
          _polar(fixture.key, fixture.value.$1, fixture.value.$2, 160);
          expect(fixture.key.a, 0.4);
        }
        _polar(palette.rail.active, dark ? 0.745 : 0.805, 0.07, 283);
        _polar(
          palette.rail.onActive,
          dark ? 0.18 : 0.215,
          dark ? 0.03 : 0.035,
          283,
        );
        _polar(palette.rail.badge, 0.74, 0.078, 76);
        _polar(palette.rail.onBadge, 0.24, 0.04, 76);
        expect(palette.rail.active.a, 0.6);
        expect(palette.rail.badge.a, 0.8);
        expect(palette.rail.hoverWash.a, dark ? 0.06 : 0.08);
        expect(palette.rail.line.a, 0.07);
        expect(palette.focus, palette.primary.ink);
        _polar(palette.focusHalo, dark ? 0.7 : 0.525, 0.118, 283);
        expect(palette.focusHalo.a, dark ? 0.3 : 0.2);
        expect(inks.copyWith(), inks);
        expect(inks.copyWith().hashCode, inks.hashCode);
        expect(palette.rail.copyWith(), palette.rail);
        expect(palette.rail.copyWith().hashCode, palette.rail.hashCode);
      }
    },
  );

  test('away is continuous at each luminance boundary', () {
    // Independent W3C-matrix JavaScript oracle, not this Dart implementation.
    final fixtures = <double, double>{
      0.029999: 0.32606375337361426,
      0.030001: 0.27965403273382916,
      0.181399: 0.509472568916949,
      0.181401: 0.5558903763977844,
      0.699999: 0.8455291561414368,
      0.700001: 0.799113982098446,
    };
    for (final fixture in fixtures.entries) {
      final luminance = fixture.key;
      final primary = OiOklab.fromXyzD65(
        x: 0.3127 / 0.3290 * luminance,
        y: luminance,
        z: (1 - 0.3127 - 0.3290) / 0.3290 * luminance,
      ).toOklch();
      final palette = OiBrandPalette.derive(
        primary: primary,
        secondary: primary,
        highlight: primary,
        brightness: Brightness.light,
      );
      expect(
        OiOklab.fromColor(palette.primary.hover!).lightness,
        closeTo(fixture.value, 0.0000001),
        reason: 'Y=$luminance',
      );
    }
  });

  test(
    'neutral surfaces use tint, retain relative alpha and separate scrim',
    () {
      const fill = OiOklch(lightness: 0.525, chroma: 0.118, hue: 283);
      for (final brightness in Brightness.values) {
        final palette = OiBrandPalette.derive(
          primary: fill,
          secondary: fill,
          highlight: fill,
          tint: const OiOklch(
            lightness: 0.5,
            chroma: 0.03,
            hue: 160,
            alpha: 0.4,
          ),
          brightness: brightness,
        );
        final surfaces = palette.surfaces;
        final dark = brightness == Brightness.dark;
        final fixtures = <Color, (double, double)>{
          surfaces.canvas: dark ? (0.148, 0.006) : (0.965, 0.005),
          surfaces.sheet: dark ? (0.192, 0.007) : (0.997, 0.0015),
          surfaces.well: dark ? (0.168, 0.007) : (0.976, 0.004),
          surfaces.overlaySurface: dark ? (0.228, 0.008) : (0.999, 0.001),
          surfaces.line: dark ? (0.262, 0.008) : (0.924, 0.006),
          surfaces.lineStrong: dark ? (0.322, 0.01) : (0.868, 0.008),
          surfaces.border: dark ? (0.575, 0.012) : (0.63, 0.01),
          surfaces.inverse: dark ? (0.925, 0.005) : (0.25, 0.014),
        };
        for (final fixture in fixtures.entries) {
          _polar(fixture.key, fixture.value.$1, fixture.value.$2, 160);
          expect(fixture.key.a, 0.4);
        }
        _polar(surfaces.hoverWash, dark ? 0.96 : 0.3, dark ? 0.01 : 0.03, 160);
        _polar(
          surfaces.pressedWash,
          dark ? 0.96 : 0.3,
          dark ? 0.01 : 0.03,
          160,
        );
        _polar(surfaces.scrim, dark ? 0.08 : 0.2, dark ? 0.01 : 0.02, 160);
        expect(surfaces.hoverWash.a, dark ? 0.06 : 0.05);
        expect(surfaces.pressedWash.a, dark ? 0.1 : 0.085);
        expect(surfaces.scrim.a, dark ? 0.62 : 0.32);
        expect(surfaces.copyWith(), surfaces);
        expect(surfaces.copyWith().hashCode, surfaces.hashCode);
        expect(
          surfaces.copyWith(canvas: surfaces.sheet).canvas,
          surfaces.sheet,
        );
        expect(surfaces, isNot(equals(null)));
      }
    },
  );

  test(
    'generic violet light derives the source primary family, not statics',
    () {
      final palette = OiBrandPalette.derive(
        primary: const OiOklch(lightness: 0.525, chroma: 0.118, hue: 283),
        secondary: const OiOklch(lightness: 0.8, chroma: 0.058, hue: 222),
        highlight: const OiOklch(lightness: 0.87, chroma: 0.078, hue: 76),
        brightness: Brightness.light,
      );
      // Actual Chrome, executing the original CSS with data-brand="custom".
      expect(_clipped(palette.primary.base), 0xFF625FAC);
      expect(_clipped(palette.primary.onColor), 0xFFFFFFFF);
      expect(_clipped(palette.primary.hover!), 0xFF545295);
      expect(_clipped(palette.primary.pressed!), 0xFF4B4985);
      expect(_clipped(palette.primary.ink), 0xFF5B58A0);
      expect(_clipped(palette.primary.soft), 0xFFEEEFFC);
      expect(_clipped(palette.primary.softHover!), 0xFFE5E6FB);
      expect(palette.primary.base.colorSpace, ColorSpace.extendedSRGB);
    },
  );

  test('generic violet dark uses dark ink scaling and soft surfaces', () {
    final palette = OiBrandPalette.derive(
      primary: const OiOklch(lightness: 0.765, chroma: 0.085, hue: 285),
      secondary: const OiOklch(lightness: 0.76, chroma: 0.056, hue: 222),
      highlight: const OiOklch(lightness: 0.8, chroma: 0.068, hue: 76),
      brightness: Brightness.dark,
    );
    // Original CSS with custom branding; these are not pinned dark statics.
    expect(_clipped(palette.primary.onColor), 0xFF1B1B2C);
    expect(_clipped(palette.primary.hover!), 0xFFB4B4EA);
    expect(_clipped(palette.primary.pressed!), 0xFFBABAEC);
    expect(_clipped(palette.primary.ink), 0xFFADABE7);
    final soft = OiOklch.fromColor(palette.primary.soft);
    expect(soft.lightness, closeTo(0.272, 0.000001));
    expect(soft.chroma, closeTo(0.034, 0.000001));
    final softHover = OiOklch.fromColor(palette.primary.softHover!);
    expect(softHover.lightness, closeTo(0.310, 0.000001));
    expect(softHover.chroma, closeTo(0.044, 0.000001));
  });

  test(
    'secondary and highlight use their own light and dark role policies',
    () {
      final light = OiBrandPalette.derive(
        primary: const OiOklch(lightness: 0.525, chroma: 0.118, hue: 283),
        secondary: const OiOklch(lightness: 0.8, chroma: 0.058, hue: 222),
        highlight: const OiOklch(lightness: 0.87, chroma: 0.078, hue: 76),
        brightness: Brightness.light,
      );
      _polar(light.secondary.onColor, 0.26, 0.04, 222);
      _polar(light.highlight.onColor, 0.26, 0.04, 76);
      // Independent source journal ink values rounded to four decimal places.
      _polar(light.secondary.ink, 0.4876, 0.0354, 222, tolerance: 0.0001);
      _polar(light.highlight.ink, 0.4917, 0.0441, 76, tolerance: 0.0001);
      _polar(light.secondary.soft, 0.958, 0.01508, 222);
      _polar(light.highlight.soft, 0.965, 0.026, 76);
      expect(light.secondary.hover, isNull);
      expect(light.highlight.softHover, isNull);

      final dark = OiBrandPalette.derive(
        primary: const OiOklch(lightness: 0.765, chroma: 0.085, hue: 285),
        secondary: const OiOklch(lightness: 0.76, chroma: 0.056, hue: 222),
        highlight: const OiOklch(lightness: 0.8, chroma: 0.068, hue: 76),
        brightness: Brightness.dark,
      );
      _polar(dark.secondary.onColor, 0.226, 0.0332, 222);
      _polar(dark.highlight.onColor, 0.26, 0.04, 76);
      _polar(dark.secondary.ink, 0.76, 0.056, 222);
      _polar(dark.highlight.ink, 0.8, 0.068, 76);
      _polar(dark.secondary.soft, 0.268, 0.020, 222);
      _polar(dark.highlight.soft, 0.282, 0.02856, 76);
      expect(dark.secondary.pressed, isNull);
      expect(dark.highlight.hover, isNull);
    },
  );
}

int _clipped(Color color) =>
    color.withValues(colorSpace: ColorSpace.sRGB).toARGB32();

void _polar(
  Color color,
  double lightness,
  double chroma,
  double hue, {
  double tolerance = 0.000001,
}) {
  final value = OiOklch.fromColor(color);
  expect(value.lightness, closeTo(lightness, tolerance));
  expect(value.chroma, closeTo(chroma, tolerance));
  expect(value.hue, closeTo(hue, 0.00001));
}
