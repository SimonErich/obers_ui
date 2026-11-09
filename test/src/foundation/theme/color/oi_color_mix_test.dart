import 'dart:ui' show ColorSpace;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

void main() {
  test(
    'OKLCH mix crosses zero on the shorter hue arc with premultiplied alpha',
    () {
      const first = OiOklch(lightness: 0.6, chroma: 0.1, hue: 350, alpha: 0.25);
      const second = OiOklch(lightness: 0.8, chroma: 0.2, hue: 10, alpha: 0.75);
      final result = OiColorMix.oklch(first, second);

      // Independent Chrome color-mix result: oklch(.75 .175 0 / .5).
      expect(result.lightness, closeTo(0.75, 0.0000001));
      expect(result.chroma, closeTo(0.175, 0.0000001));
      expect(result.hue, 0);
      expect(result.alpha, 0.5);
    },
  );

  test(
    'CSS percentages normalize weights and reduce alpha for a partial sum',
    () {
      const first = OiOklch(lightness: 0.6, chroma: 0.1, hue: 350);
      const second = OiOklch(lightness: 0.8, chroma: 0.2, hue: 10);
      final result = OiColorMix.oklch(
        first,
        second,
        firstPercent: 30,
        secondPercent: 30,
      );

      expect(result.lightness, closeTo(0.7, 0.0000001));
      expect(result.chroma, closeTo(0.15, 0.0000001));
      expect(result.hue, 0);
      expect(result.alpha, 0.6);
    },
  );

  test(
    'CSS percentages reject nonfinite and out-of-range input at runtime',
    () {
      const color = OiOklch(lightness: 0.6, chroma: 0.1, hue: 280);
      for (final invalid in [-1.0, 101.0, double.nan, double.infinity]) {
        expect(
          () => OiColorMix.oklch(color, color, firstPercent: invalid),
          throwsArgumentError,
        );
        expect(
          () => OiColorMix.oklch(color, color, secondPercent: invalid),
          throwsArgumentError,
        );
      }
    },
  );

  test(
    'a zero percentage total gives the CSS Color 5 transparent midpoint',
    () {
      const first = OiOklch(lightness: 0.6, chroma: 0.1, hue: 350);
      const second = OiOklch(lightness: 0.8, chroma: 0.2, hue: 10);
      final result = OiColorMix.oklch(
        first,
        second,
        firstPercent: 0,
        secondPercent: 0,
      );
      expect(result.lightness, closeTo(0.7, 0.0000001));
      expect(result.chroma, closeTo(0.15, 0.0000001));
      expect(result.hue, 0);
      expect(result.alpha, 0);
    },
  );

  test('all CSS hue strategies choose the documented circular arc', () {
    const first = OiOklch(lightness: 0.6, chroma: 0.1, hue: 350);
    const second = OiOklch(lightness: 0.8, chroma: 0.2, hue: 10);
    const forward = [0.0, 180.0, 0.0, 180.0];
    const backward = [0.0, 180.0, 180.0, 0.0];
    for (final strategy in OiHueInterpolation.values) {
      expect(
        OiColorMix.oklch(first, second, hueInterpolation: strategy).hue,
        forward[strategy.index],
      );
      expect(
        OiColorMix.oklch(second, first, hueInterpolation: strategy).hue,
        backward[strategy.index],
      );
    }
  });

  test(
    'Oklab mixing premultiplies each rectangular axis but not final opacity',
    () {
      const first = OiOklab(
        lightness: 0.6,
        axisA: 0.1,
        axisB: 0.2,
        alpha: 0.25,
      );
      const second = OiOklab(
        lightness: 0.8,
        axisA: -0.2,
        axisB: -0.1,
        alpha: 0.75,
      );
      final result = OiColorMix.oklab(first, second);
      expect(result.lightness, closeTo(0.75, 0.0000001));
      expect(result.a, closeTo(-0.125, 0.0000001));
      expect(result.b, closeTo(-0.025, 0.0000001));
      expect(result.alpha, 0.5);
    },
  );

  test('sRGB interpolation matches Chrome percentage and alpha semantics', () {
    const red = Color(0xFFFF0000);
    const blue = Color(0xFF0000FF);
    final result = OiColorMix.srgb(
      red,
      blue,
      firstPercent: 30,
      secondPercent: 30,
    );
    // Chrome: color(srgb .5 0 .5 / .6), canvas byte RGBA [128, 0, 128, 153].
    expect(result.r, 0.5);
    expect(result.g, 0);
    expect(result.b, 0.5);
    expect(result.a, 0.6);
    expect(result.colorSpace, ColorSpace.extendedSRGB);
  });

  test(
    'missing converted hue carries forward while authored neutral hue remains',
    () {
      const color = OiOklch(lightness: 0.7, chroma: 0.1, hue: 280);
      final white = OiOklch.fromColor(const Color(0xFFFFFFFF));
      final black = OiOklch.fromColor(const Color(0xFF000000));
      expect(OiColorMix.oklch(white, color).hue, 280);
      expect(OiColorMix.oklch(color, white).hue, 280);
      expect(OiColorMix.oklch(white, black).hue, isNull);
      const authored = OiOklch(lightness: 0.5, chroma: 0, hue: 120);
      // Chrome computes hue=200 for authored oklch(.5 0 120), oklch(.7 .1 280).
      expect(OiColorMix.oklch(authored, color).hue, 200);
    },
  );

  test('complementary and excess percentages keep CSS opacity and weights', () {
    const first = OiOklch(lightness: 0.6, chroma: 0.1, hue: 350);
    const second = OiOklch(lightness: 0.8, chroma: 0.2, hue: 10);
    final excess = OiColorMix.oklch(
      first,
      second,
      firstPercent: 80,
      secondPercent: 80,
    );
    // Chrome: oklch(.7 .15 0), without an excess opacity multiplier.
    expect(excess.lightness, closeTo(0.7, 0.0000001));
    expect(excess.chroma, closeTo(0.15, 0.0000001));
    expect(excess.hue, 0);
    expect(excess.alpha, 1);
    final quarter = OiColorMix.oklch(first, second, firstPercent: 25);
    // Chrome: oklch(.75 .175 5).
    expect(quarter.lightness, closeTo(0.75, 0.0000001));
    expect(quarter.chroma, closeTo(0.175, 0.0000001));
    expect(quarter.hue, 5);
    expect(quarter.alpha, 1);
    expect(OiColorMix.oklch(first, second, secondPercent: 25).hue, 355);
    expect(OiColorMix.oklch(first, second, firstPercent: 100).lightness, 0.6);
    expect(OiColorMix.oklch(first, second, secondPercent: 100).lightness, 0.8);
  });

  test(
    'two transparent colors do not divide by zero when unpremultiplying',
    () {
      const first = OiOklab(lightness: 0.6, axisA: 0.1, axisB: 0.2, alpha: 0);
      const second = OiOklab(
        lightness: 0.8,
        axisA: -0.2,
        axisB: -0.1,
        alpha: 0,
      );
      final lab = OiColorMix.oklab(first, second);
      expect([lab.lightness, lab.a, lab.b, lab.alpha], [0, 0, 0, 0]);
      final polar = OiColorMix.oklch(
        const OiOklch(lightness: 0.6, chroma: 0.1, hue: 350, alpha: 0),
        const OiOklch(lightness: 0.8, chroma: 0.2, hue: 10, alpha: 0),
      );
      expect(
        [polar.lightness, polar.chroma, polar.hue, polar.alpha],
        [0, 0, 0, 0],
      );
      final rgb = OiColorMix.srgb(
        const Color(0x00FF0000),
        const Color(0x000000FF),
      );
      expect([rgb.r, rgb.g, rgb.b, rgb.a], [0, 0, 0, 0]);
    },
  );

  test('sRGB mixing converts the Display P3 matrix without early clipping', () {
    const red = Color.from(
      alpha: 1,
      red: 1,
      green: 0,
      blue: 0,
      colorSpace: ColorSpace.displayP3,
    );
    final mixed = OiColorMix.srgb(red, const Color(0xFF000000));
    // Half the W3C rational matrix oracle, independently evaluated in JS.
    expect(mixed.r, closeTo(0.5465331812175807, 0.0000001));
    expect(mixed.g, closeTo(-0.11337098678487719, 0.0000001));
    expect(mixed.b, closeTo(-0.07506729046855968, 0.0000001));
    expect(mixed.a, 1);
  });

  test('normalized opaque percentages cannot round alpha above one', () {
    const color = OiOklab(lightness: 0.6, axisA: 0.1, axisB: 0.2);
    final mixed = OiColorMix.oklab(
      color,
      color,
      firstPercent: 0.1,
      secondPercent: 99.97,
    );
    expect(mixed.alpha, 1);
    expect(mixed.lightness, closeTo(0.6, 0.0000001));
  });
}
