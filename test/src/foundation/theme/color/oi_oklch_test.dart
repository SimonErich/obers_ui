import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

void main() {
  test('authored primary token matches Chrome extended sRGB conversion', () {
    const primary = OiOklch(lightness: 0.525, chroma: 0.118, hue: 283);
    final rgb = primary.toColor();

    // Chrome 154: color(from oklch(0.525 0.118 283) srgb r g b).
    // Allow the browser's older float32 matrices: below 0.026 of one byte.
    expect(rgb.r, closeTo(0.383597, 0.0001));
    expect(rgb.g, closeTo(0.374058, 0.0001));
    expect(rgb.b, closeTo(0.673521, 0.0001));
    expect(rgb.toARGB32(), 0xFF625FAC);
  });

  test(
    'converted achromatic colors carry missing rather than arbitrary hue',
    () {
      for (final value in [0xFF000000, 0xFF808080, 0xFFFFFFFF]) {
        final gray = OiOklch.fromColor(Color(value));
        expect(gray.hue, isNull);
        expect(gray.chroma, lessThanOrEqualTo(0.000004));
        expect(gray.toColor().toARGB32(), value);
      }
    },
  );

  test('authored polar values reject nonfinite and negative chroma inputs', () {
    for (final invalid in [-0.01, double.nan, double.infinity]) {
      expect(
        () => OiOklch(lightness: 0.5, chroma: invalid, hue: 280),
        throwsAssertionError,
      );
    }
    expect(
      () => OiOklch(lightness: double.nan, chroma: 0.1, hue: 280),
      throwsAssertionError,
    );
    expect(
      () => OiOklch(lightness: 0.5, chroma: 0.1, hue: double.infinity),
      throwsAssertionError,
    );
    expect(
      () => OiOklch(lightness: 0.5, chroma: 0.1, hue: 280, alpha: 1.1),
      throwsAssertionError,
    );
  });

  test(
    'sRGB clipping is explicit and leaves raw out-of-gamut values intact',
    () {
      const vivid = OiOklch(lightness: 0.7, chroma: 0.4, hue: 30, alpha: 0.37);
      final raw = vivid.toColor();
      final clipped = vivid.toSrgbClipped();
      expect(raw.r, greaterThan(1));
      expect(raw.g, lessThan(0));
      expect(raw.b, lessThan(0));
      // Independent Chrome canvas with opaque oklch(.7 .4 30) is [255, 0, 0].
      expect(clipped.r, 1);
      expect(clipped.g, 0);
      expect(clipped.b, 0);
      expect(clipped.a, 0.37);
      expect(vivid.toOklab().toSrgbClipped(), clipped);
    },
  );

  test('converted powerless hue uses the exact CSS epsilon boundary', () {
    const boundary = OiOklab(lightness: 0.5, axisA: 0.000004, axisB: 0);
    const above = OiOklab(lightness: 0.5, axisA: 0.000004000001, axisB: 0);
    expect(boundary.toOklch().hue, isNull);
    expect(above.toOklch().hue, 0);
    const authored = OiOklch(lightness: 0.5, chroma: 0.000004, hue: 280);
    expect(authored.hue, 280);
  });
}
