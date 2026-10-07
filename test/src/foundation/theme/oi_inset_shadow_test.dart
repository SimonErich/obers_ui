import 'dart:ui' show ColorSpace;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

void main() {
  test(
    'extended lerp converts mixed spaces without clipping and validates extrapolated results',
    () {
      final raw = OiInsetShadow(
        color: const Color.from(
          alpha: .5,
          red: 1.2,
          green: -.1,
          blue: .2,
          colorSpace: ColorSpace.extendedSRGB,
        ),
      );
      final ordinary = OiInsetShadow(color: const Color(0xFF336699));
      final mixed = OiInsetShadow.lerp(raw, ordinary, .5)!.color;
      expect(mixed.colorSpace, ColorSpace.extendedSRGB);
      expect(mixed.r, closeTo(.7, 1e-14));
      expect(mixed.g, closeTo(.15, 1e-14));
      expect(mixed.b, closeTo(.4, 1e-14));
      expect(mixed.a, .75);
      final reversed = OiInsetShadow.lerp(ordinary, raw, .5)!.color;
      expect(reversed.r, closeTo(mixed.r, 1e-14));
      expect(reversed.g, closeTo(mixed.g, 1e-14));
      expect(reversed.b, closeTo(mixed.b, 1e-14));
      expect(reversed.a, mixed.a);
      final beyond = OiInsetShadow.lerp(raw, ordinary, -.5)!.color;
      expect(beyond.r, closeTo(1.7, 1e-14));
      expect(beyond.g, closeTo(-.35, 1e-14));
      expect(beyond.b, closeTo(0, 1e-14));
      expect(OiInsetShadow.lerp(null, raw, 4)!.color.a, 1);
      expect(OiInsetShadow.lerp(raw, null, 4)!.color.a, 0);
      final larger = raw.copyWith(
        color: const Color.from(
          alpha: .5,
          red: 3.2,
          green: -.1,
          blue: .2,
          colorSpace: ColorSpace.extendedSRGB,
        ),
      );
      expect(
        () => OiInsetShadow.lerp(larger, ordinary, -double.maxFinite),
        throwsArgumentError,
      );
      final p3 = OiInsetShadow(
        color: const Color.from(
          alpha: 1,
          red: 1,
          green: 0,
          blue: 0,
          colorSpace: ColorSpace.displayP3,
        ),
      );
      final extendedBlack = OiInsetShadow(
        color: const Color.from(
          alpha: 1,
          red: 0,
          green: 0,
          blue: 0,
          colorSpace: ColorSpace.extendedSRGB,
        ),
      );
      final p3Mixed = OiInsetShadow.lerp(p3, extendedBlack, .5)!.color;
      // Independently evaluated in JS from the pinned SDK P3 matrix and mirrored
      // transfer curve, not the implementation/F1 output. SDK conversion policy
      // deliberately differs from the higher-precision W3C matrix used by F1.
      expect(p3Mixed.r, closeTo(0.546533166323121, 1e-12));
      expect(p3Mixed.g, closeTo(-0.1133709104299799, 1e-12));
      expect(p3Mixed.b, closeTo(-0.07506738929160814, 1e-12));
      expect(p3Mixed.colorSpace, ColorSpace.extendedSRGB);
      expect(
        OiInsetShadow.lerp(p3, ordinary, .5)!.color,
        Color.lerp(p3.color, ordinary.color, .5),
      );
    },
  );

  test(
    'inset lerp retains authored extended RGB during mixing and null fades',
    () {
      const aColor = Color.from(
        alpha: 1,
        red: 1.2,
        green: -.1,
        blue: .2,
        colorSpace: ColorSpace.extendedSRGB,
      );
      const bColor = Color.from(
        alpha: 1,
        red: .2,
        green: .1,
        blue: .6,
        colorSpace: ColorSpace.extendedSRGB,
      );
      final a = OiInsetShadow(color: aColor);
      final b = OiInsetShadow(color: bColor);
      final mixed = OiInsetShadow.lerp(a, b, .5)!;
      expect(
        mixed.color,
        const Color.from(
          alpha: 1,
          red: .7,
          green: 0,
          blue: .4,
          colorSpace: ColorSpace.extendedSRGB,
        ),
      );
      final fadeIn = OiInsetShadow.lerp(null, a, .5)!;
      final fadeOut = OiInsetShadow.lerp(a, null, .5)!;
      expect(
        fadeIn.color,
        const Color.from(
          alpha: .5,
          red: 1.2,
          green: -.1,
          blue: .2,
          colorSpace: ColorSpace.extendedSRGB,
        ),
      );
      expect(fadeOut.color, fadeIn.color);
      expect(OiInsetShadow.lerp(a, b, 0), same(a));
      expect(OiInsetShadow.lerp(a, b, 1), same(b));
    },
  );

  test(
    'inset colors are finite with valid alpha without clipping extended RGB',
    () {
      for (final color in [
        const Color.from(alpha: double.nan, red: 0, green: 0, blue: 0),
        const Color.from(alpha: 1, red: double.infinity, green: 0, blue: 0),
        const Color.from(alpha: 1, red: 0, green: double.nan, blue: 0),
        const Color.from(alpha: 1, red: 0, green: 0, blue: double.infinity),
        const Color.from(alpha: 1.1, red: 0, green: 0, blue: 0),
        const Color.from(alpha: -.1, red: 0, green: 0, blue: 0),
      ]) {
        expect(() => OiInsetShadow(color: color), throwsArgumentError);
      }
      const extended = Color.from(
        alpha: .5,
        red: 1.2,
        green: -.1,
        blue: .2,
        colorSpace: ColorSpace.extendedSRGB,
      );
      expect(OiInsetShadow(color: extended).color, same(extended));
      expect(
        () => OiInsetShadow(color: const Color(0xFFFFFFFF)).copyWith(
          color: const Color.from(alpha: 1, red: double.nan, green: 0, blue: 0),
        ),
        throwsArgumentError,
      );
    },
  );

  test('inset lerp handles endpoints, fading, and finite extrapolation', () {
    final a = OiInsetShadow(
      color: const Color(0xFFFF0000),
      offset: const Offset(2, 4),
      blurSigma: 2,
      spread: -2,
    );
    final b = OiInsetShadow(
      color: const Color(0xFF0000FF),
      offset: const Offset(4, 8),
      blurSigma: 4,
      spread: 2,
    );
    expect(OiInsetShadow.lerp(a, b, 0), same(a));
    expect(OiInsetShadow.lerp(a, b, 1), same(b));
    final middle = OiInsetShadow.lerp(a, b, .5)!;
    expect(
      middle.color,
      const Color.from(alpha: 1, red: .5, green: 0, blue: .5),
    );
    expect(middle.offset, const Offset(3, 6));
    expect(middle.blurSigma, 3);
    expect(middle.spread, 0);
    final fade = OiInsetShadow.lerp(null, b, .5)!;
    expect(fade.color.a, .5);
    expect(fade.offset, const Offset(2, 4));
    expect(fade.blurSigma, 2);
    expect(OiInsetShadow.lerp(a, b, -2)!.blurSigma, 0);
    expect(OiInsetShadow.lerp(a, null, .5)!.color.a, .5);
    expect(OiInsetShadow.lerp(null, null, .5), isNull);
    expect(() => OiInsetShadow.lerp(a, b, double.nan), throwsArgumentError);
  });

  test('copyWith creates validated, value-equal inset shadows', () {
    final original = OiInsetShadow(
      color: const Color(0x80FF0000),
      offset: const Offset(1, -2),
      blurSigma: 3,
      spread: -4,
    );
    final copy = original.copyWith();
    expect(copy, original);
    expect(copy.hashCode, original.hashCode);
    expect(copy.copyWith(spread: 2).spread, 2);
    expect(
      copy.copyWith(
        color: const Color(0xFF000000),
        offset: Offset.zero,
        blurSigma: 0,
      ),
      OiInsetShadow(color: const Color(0xFF000000), spread: -4),
    );
    expect(() => copy.copyWith(blurSigma: -1), throwsArgumentError);
    expect(original, isNot(OiInsetShadow(color: original.color)));
    expect(original == Object(), isFalse);
  });

  test('inset shadows reject negative and nonfinite blur sigma at runtime', () {
    for (final sigma in [-1.0, double.nan, double.infinity]) {
      expect(
        () => OiInsetShadow(color: const Color(0xFF000000), blurSigma: sigma),
        throwsArgumentError,
      );
    }
  });

  test('inset shadows reject nonfinite offset and spread before painting', () {
    for (final offset in [
      const Offset(double.infinity, 0),
      const Offset(0, double.nan),
    ]) {
      expect(
        () => OiInsetShadow(color: const Color(0xFF000000), offset: offset),
        throwsArgumentError,
      );
    }
    expect(
      () => OiInsetShadow(color: const Color(0xFF000000), spread: double.nan),
      throwsArgumentError,
    );
  });
}
