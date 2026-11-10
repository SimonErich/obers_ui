import 'dart:ui' show ColorSpace;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

void main() {
  test(
    'typed group lerp constructors preserve endpoints and reject bad fractions',
    () {
      final base = OiThemeData.light().resolvedSemanticColors;
      const color = Color(0xFF123456);
      const ramp = OiColorRamp(
        first: color,
        second: color,
        third: color,
        fourth: color,
        fifth: color,
        sixth: color,
      );
      final factories = <(Object Function(double), Object)>[
        (
          (fraction) =>
              OiSurfaceColors.lerp(base.surfaces, base.surfaces, fraction),
          base.surfaces,
        ),
        (
          (fraction) => OiInkColors.lerp(base.inks, base.inks, fraction),
          base.inks,
        ),
        (
          (fraction) => OiRoleColors.lerp(base.primary, base.primary, fraction),
          base.primary,
        ),
        (
          (fraction) => OiRailColors.lerp(base.rail, base.rail, fraction),
          base.rail,
        ),
        (
          (fraction) => OiChartColors.lerp(base.charts, base.charts, fraction),
          base.charts,
        ),
        ((fraction) => OiColorRamp.lerp(ramp, ramp, fraction), ramp),
      ];
      for (final (create, original) in factories) {
        expect(create(0), same(original));
        expect(create(1), same(original));
        expect(() => create(double.nan), throwsArgumentError);
        expect(() => create(-0.1), throwsArgumentError);
        expect(() => create(1.1), throwsArgumentError);
      }
    },
  );

  test('optional colors and ramps carry one endpoint and interpolate two', () {
    final base = OiThemeData.light().resolvedSemanticColors;
    const red = Color(0xFFFF0000);
    const blue = Color(0xFF0000FF);
    const redRamp = OiColorRamp(
      first: red,
      second: red,
      third: red,
      fourth: red,
      fifth: red,
      sixth: red,
    );
    const blueRamp = OiColorRamp(
      first: blue,
      second: blue,
      third: blue,
      fourth: blue,
      fifth: blue,
      sixth: blue,
    );
    final first = base.copyWith(
      focusHalo: red,
      primary: base.primary.copyWith(clearHover: true),
      charts: base.charts.copyWith(sequential: redRamp),
    );
    final second = base.copyWith(
      focusHalo: blue,
      charts: base.charts.copyWith(sequential: blueRamp),
    );
    for (final result in [
      OiSemanticColors.lerp(base, first, 0.5),
      OiSemanticColors.lerp(first, base, 0.5),
    ]) {
      expect(result.focusHalo, red);
      expect(result.charts.sequential, same(redRamp));
      expect(result.primary.hover, base.primary.hover);
    }
    final result = OiSemanticColors.lerp(first, second, 0.5);
    expect(result.focusHalo!.r, 0.5);
    expect(result.focusHalo!.b, 0.5);
    for (final color in result.charts.sequential!.colors) {
      expect(color.r, 0.5);
      expect(color.g, 0);
      expect(color.b, 0.5);
      expect(color.a, 1);
    }
  });

  test(
    'semantic theme metadata is opt-in and copy/merge/clear are explicit',
    () {
      final light = OiThemeData.light();
      final dark = OiThemeData.dark();
      final semantic = OiLegacySemanticColors.fromScheme(dark.colors);
      expect(light.semanticColors, isNull);
      expect(
        light.resolvedSemanticColors,
        OiLegacySemanticColors.fromScheme(light.colors),
      );
      final custom = light.copyWith(semanticColors: semantic);
      expect(custom.resolvedSemanticColors, same(semantic));
      expect(custom.colors, same(light.colors));
      expect(custom.copyWith(), custom);
      expect(custom.copyWith().hashCode, custom.hashCode);
      expect(custom, isNot(light));
      expect(light.merge(custom).semanticColors, same(semantic));
      expect(custom.merge(dark).semanticColors, same(semantic));
      expect(custom.copyWith(clearSemanticColors: true).semanticColors, isNull);
      expect(
        OiThemeData.fromBrand(color: const Color(0xFF123456)).semanticColors,
        isNull,
      );
      expect(OiThemeData.lerp(light, dark, 0.5).semanticColors, isNull);
    },
  );

  test(
    'semantic interpolation preserves raw gamut and premultiplies alpha',
    () {
      final light = OiThemeData.light();
      final base = light.resolvedSemanticColors;
      const first = Color.from(
        alpha: 0.25,
        red: -0.4,
        green: 0.3,
        blue: 1.2,
        colorSpace: ColorSpace.extendedSRGB,
      );
      const second = Color.from(
        alpha: 0.75,
        red: 1.4,
        green: 0.9,
        blue: -0.2,
        colorSpace: ColorSpace.extendedSRGB,
      );
      final a = base.copyWith(surfaces: base.surfaces.copyWith(canvas: first));
      final b = base.copyWith(surfaces: base.surfaces.copyWith(canvas: second));
      final midpoint = OiSemanticColors.lerp(a, b, 0.5);
      final color = midpoint.surfaces.canvas;
      expect(color.a, 0.5);
      expect(color.r, closeTo(0.95, 0.0000001));
      expect(color.g, closeTo(0.75, 0.0000001));
      expect(color.b, closeTo(0.15, 0.0000001));
      expect(color.colorSpace, ColorSpace.extendedSRGB);
      expect(OiSemanticColors.lerp(a, b, 0), same(a));
      expect(OiSemanticColors.lerp(a, b, 1), same(b));
      final raw = OiSemanticColors.lerp(a, a, 0.5).surfaces.canvas;
      expect(raw.r, -0.4);
      expect(raw.b, 1.2);
      final theme = OiThemeData.lerp(
        light.copyWith(semanticColors: a),
        light.copyWith(semanticColors: b),
        0.5,
      );
      expect(theme.semanticColors, midpoint);
      expect(
        OiThemeData.lerp(
          light,
          light.copyWith(semanticColors: b),
          0.5,
        ).semanticColors,
        OiSemanticColors.lerp(base, b, 0.5),
      );
      expect(
        () => OiSemanticColors.lerp(a, b, double.nan),
        throwsArgumentError,
      );
      expect(() => OiSemanticColors.lerp(a, b, -0.1), throwsArgumentError);
      expect(() => OiSemanticColors.lerp(a, b, 1.1), throwsArgumentError);
    },
  );
}
