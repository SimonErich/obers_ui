import 'dart:ui' show ColorSpace;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

void main() {
  test('sRGB red agrees with independent Chrome CSS conversion', () {
    final red = OiOklab.fromColor(const Color(0xFFFF0000));

    // Chrome 154: getComputedStyle for oklab(from red l a b).
    // Its float32 matrix differs slightly from CSS Color 4's float64 matrix.
    expect(red.lightness, closeTo(0.627966, 0.000025));
    expect(red.a, closeTo(0.22488, 0.000025));
    expect(red.b, closeTo(0.125859, 0.000025));
    expect(red.alpha, 1);
  });

  test(
    'conversion round-trips extended RGB without clipping or losing alpha',
    () {
      const source = Color.from(
        alpha: 0.37,
        red: -0.4,
        green: 0.03,
        blue: 1.2,
        colorSpace: ColorSpace.extendedSRGB,
      );

      final result = OiOklab.fromColor(source).toColor();
      expect(result.r, closeTo(-0.4, 0.0000001));
      expect(result.g, closeTo(0.03, 0.0000001));
      expect(result.b, closeTo(1.2, 0.0000001));
      expect(result.a, 0.37);
      expect(result.colorSpace, ColorSpace.extendedSRGB);
    },
  );

  test('nonfinite coordinates and invalid opacity are rejected', () {
    for (final invalid in [
      double.nan,
      double.infinity,
      double.negativeInfinity,
    ]) {
      expect(
        () => OiOklab(lightness: invalid, axisA: 0, axisB: 0),
        throwsAssertionError,
      );
      expect(
        () => OiOklab(lightness: 0.5, axisA: invalid, axisB: 0),
        throwsAssertionError,
      );
      expect(
        () => OiOklab(lightness: 0.5, axisA: 0, axisB: invalid),
        throwsAssertionError,
      );
    }
    for (final invalid in [-0.1, 1.1, double.nan]) {
      expect(
        () => OiOklab(lightness: 0.5, axisA: 0, axisB: 0, alpha: invalid),
        throwsAssertionError,
      );
    }
  });

  test('XYZ-D65 exposes true uncomposited luminance for brand derivation', () {
    final red = OiOklab.fromColor(const Color(0x80FF0000));
    final xyz = red.toXyzD65();
    // W3C CSS Color 4 sRGB primary column, also checked through Chrome.
    expect(xyz.x, closeTo(0.4123907992659595, 0.0000001));
    expect(xyz.y, closeTo(0.2126390058715104, 0.0000001));
    expect(xyz.z, closeTo(0.01933081871559185, 0.0000001));
    expect(red.relativeLuminance, closeTo(0.2126390058715104, 0.0000001));
  });

  test('XYZ-D65 construction agrees with the published Oklab sample pair', () {
    final value = OiOklab.fromXyzD65(x: 1, y: 0, z: 0, alpha: 0.23);
    // Bottosson's published XYZ=(1,0,0) table rounded to three decimals.
    expect(value.lightness, closeTo(0.450, 0.001));
    expect(value.a, closeTo(1.236, 0.001));
    expect(value.b, closeTo(-0.019, 0.001));
    final xyz = value.toXyzD65();
    expect(xyz.x, closeTo(1, 0.0000001));
    expect(xyz.y, closeTo(0, 0.0000001));
    expect(xyz.z, closeTo(0, 0.0000001));
    expect(value.alpha, 0.23);
  });

  test(
    'luminance scaling multiplies XYZ without clipping or changing opacity',
    () {
      const value = OiOklab(
        lightness: 0.8,
        axisA: 0.12,
        axisB: -0.04,
        alpha: 0.37,
      );
      final scaled = value.scaleLuminance(0.125);
      expect(scaled.lightness, closeTo(0.4, 0.0000001));
      expect(scaled.a, closeTo(0.06, 0.0000001));
      expect(scaled.b, closeTo(-0.02, 0.0000001));
      expect(scaled.alpha, 0.37);
      final before = value.toXyzD65();
      final after = scaled.toXyzD65();
      expect(after.x, closeTo(before.x * 0.125, 0.0000001));
      expect(after.y, closeTo(before.y * 0.125, 0.0000001));
      expect(after.z, closeTo(before.z * 0.125, 0.0000001));
      expect(value.scaleLuminance(0).relativeLuminance, 0);
      for (final invalid in [-1.0, double.infinity, double.nan]) {
        expect(() => value.scaleLuminance(invalid), throwsArgumentError);
      }
    },
  );

  test('Display P3 input converts without clipping the wider red primary', () {
    const source = Color.from(
      alpha: 0.37,
      red: 1,
      green: 0,
      blue: 0,
      colorSpace: ColorSpace.displayP3,
    );
    final lab = OiOklab.fromColor(source);
    // Chrome 154 relative-color oracle for color(display-p3 1 0 0).
    expect(lab.lightness, closeTo(0.648574, 0.000025));
    expect(lab.a, closeTo(0.262041, 0.000025));
    expect(lab.b, closeTo(0.145002, 0.000025));
    final raw = lab.toColor();
    // Independent W3C rational P3/XYZ/sRGB matrices evaluated in JavaScript.
    // Chromium's older conversion differs here by less than 0.02 byte.
    expect(raw.r, closeTo(1.0930663624351615, 0.0000001));
    expect(raw.g, closeTo(-0.22674197356975437, 0.0000001));
    expect(raw.b, closeTo(-0.15013458093711937, 0.0000001));
    expect(raw.a, 0.37);
  });

  test(
    'signed cube roots and both mirrored sRGB transfer branches round-trip',
    () {
      final negative = OiOklab.fromXyzD65(x: -1, y: 0, z: 0);
      expect(negative.lightness, closeTo(-0.450, 0.001));
      expect(negative.a, closeTo(-1.236, 0.001));
      expect(negative.b, closeTo(0.019, 0.001));
      for (final channel in [-0.040451, -0.04045, 0.0, 0.04045, 0.040451]) {
        final value = OiOklab.fromColor(
          Color.from(
            alpha: 1,
            red: channel,
            green: channel,
            blue: channel,
            colorSpace: ColorSpace.extendedSRGB,
          ),
        ).toColor();
        expect(value.r, closeTo(channel, 0.0000001));
        expect(value.g, closeTo(channel, 0.0000001));
        expect(value.b, closeTo(channel, 0.0000001));
      }
    },
  );
}
