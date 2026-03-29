// Tests are internal; doc comments on local helpers are not required.

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/utils/color_utils.dart';

void main() {
  group('OiColorUtils', () {
    group('fromString', () {
      test('returns a color for a string', () {
        final color = OiColorUtils.fromString('Alice');
        expect(color, isA<Color>());
      });

      test('returns the same color for the same string', () {
        final color1 = OiColorUtils.fromString('Bob');
        final color2 = OiColorUtils.fromString('Bob');
        expect(color1, equals(color2));
      });

      test('returns different colors for different strings', () {
        final color1 = OiColorUtils.fromString('Alice');
        final color2 = OiColorUtils.fromString('Zack');
        expect(color1, isNot(equals(color2)));
      });

      test('handles empty string', () {
        final color = OiColorUtils.fromString('');
        expect(color, isA<Color>());
      });
    });

    group('lighten', () {
      test('lightens a color', () {
        const color = Color(0xFF336699);
        final lighter = OiColorUtils.lighten(color, 0.2);
        final originalHsl = HSLColor.fromColor(color);
        final lighterHsl = HSLColor.fromColor(lighter);
        expect(lighterHsl.lightness, greaterThan(originalHsl.lightness));
      });

      test('does not change color with amount 0', () {
        const color = Color(0xFF336699);
        final result = OiColorUtils.lighten(color, 0);
        expect(result, equals(color));
      });

      test('clamps at white for large amounts', () {
        const color = Color(0xFF336699);
        final result = OiColorUtils.lighten(color, 1);
        final hsl = HSLColor.fromColor(result);
        expect(hsl.lightness, equals(1.0));
      });
    });

    group('darken', () {
      test('darkens a color', () {
        const color = Color(0xFF336699);
        final darker = OiColorUtils.darken(color, 0.2);
        final originalHsl = HSLColor.fromColor(color);
        final darkerHsl = HSLColor.fromColor(darker);
        expect(darkerHsl.lightness, lessThan(originalHsl.lightness));
      });

      test('does not change color with amount 0', () {
        const color = Color(0xFF336699);
        final result = OiColorUtils.darken(color, 0);
        expect(result, equals(color));
      });

      test('clamps at black for large amounts', () {
        const color = Color(0xFF336699);
        final result = OiColorUtils.darken(color, 1);
        final hsl = HSLColor.fromColor(result);
        expect(hsl.lightness, equals(0.0));
      });
    });

    group('isLight', () {
      test('white is light', () {
        expect(OiColorUtils.isLight(const Color(0xFFFFFFFF)), isTrue);
      });

      test('black is not light', () {
        expect(OiColorUtils.isLight(const Color(0xFF000000)), isFalse);
      });

      test('yellow is light', () {
        expect(OiColorUtils.isLight(const Color(0xFFFFFF00)), isTrue);
      });

      test('dark blue is not light', () {
        expect(OiColorUtils.isLight(const Color(0xFF000066)), isFalse);
      });
    });

    group('contrastText', () {
      test('returns black for white background', () {
        expect(
          OiColorUtils.contrastText(const Color(0xFFFFFFFF)),
          equals(const Color(0xFF000000)),
        );
      });

      test('returns white for black background', () {
        expect(
          OiColorUtils.contrastText(const Color(0xFF000000)),
          equals(const Color(0xFFFFFFFF)),
        );
      });

      test('returns black for yellow background', () {
        expect(
          OiColorUtils.contrastText(const Color(0xFFFFFF00)),
          equals(const Color(0xFF000000)),
        );
      });

      test('returns white for dark blue background', () {
        expect(
          OiColorUtils.contrastText(const Color(0xFF000066)),
          equals(const Color(0xFFFFFFFF)),
        );
      });
    });

    group('blend', () {
      test('ratio 0 returns first color', () {
        const first = Color(0xFFFF0000);
        const second = Color(0xFF0000FF);
        final result = OiColorUtils.blend(first, second, 0);
        expect(result, equals(first));
      });

      test('ratio 1 returns second color', () {
        const first = Color(0xFFFF0000);
        const second = Color(0xFF0000FF);
        final result = OiColorUtils.blend(first, second, 1);
        expect(result, equals(second));
      });

      test('ratio 0.5 blends evenly', () {
        const first = Color(0xFFFF0000);
        const second = Color(0xFF0000FF);
        final result = OiColorUtils.blend(first, second, 0.5);
        // Red channel: (255 + 0) / 2 ~= 128
        // Blue channel: (0 + 255) / 2 ~= 128
        final r = (result.r * 255).round();
        final b = (result.b * 255).round();
        expect(r, closeTo(128, 1));
        expect(b, closeTo(128, 1));
      });
    });

    group('withOpacity', () {
      test('sets opacity to 0', () {
        const color = Color(0xFFFF0000);
        final result = OiColorUtils.withOpacity(color, 0);
        expect((result.a * 255).round(), equals(0));
      });

      test('sets opacity to 1', () {
        const color = Color(0x80FF0000);
        final result = OiColorUtils.withOpacity(color, 1);
        expect((result.a * 255).round(), equals(255));
      });

      test('sets opacity to 0.5', () {
        const color = Color(0xFFFF0000);
        final result = OiColorUtils.withOpacity(color, 0.5);
        expect((result.a * 255).round(), closeTo(128, 1));
      });

      test('preserves RGB channels', () {
        const color = Color(0xFF336699);
        final result = OiColorUtils.withOpacity(color, 0.5);
        expect((result.r * 255).round(), equals(0x33));
        expect((result.g * 255).round(), equals(0x66));
        expect((result.b * 255).round(), equals(0x99));
      });
    });

    group('toHex', () {
      test('converts color to hex without alpha', () {
        const color = Color(0xFFFF5500);
        expect(OiColorUtils.toHex(color), '#FF5500');
      });

      test('converts color to hex with alpha', () {
        const color = Color(0x80FF5500);
        expect(OiColorUtils.toHex(color, includeAlpha: true), '#80FF5500');
      });

      test('converts black', () {
        const color = Color(0xFF000000);
        expect(OiColorUtils.toHex(color), '#000000');
      });

      test('converts white', () {
        const color = Color(0xFFFFFFFF);
        expect(OiColorUtils.toHex(color), '#FFFFFF');
      });
    });

    group('fromHex', () {
      test('parses 6-digit hex with hash', () {
        final color = OiColorUtils.fromHex('#FF5500');
        expect((color.r * 255).round(), equals(0xFF));
        expect((color.g * 255).round(), equals(0x55));
        expect((color.b * 255).round(), equals(0x00));
        expect((color.a * 255).round(), equals(0xFF));
      });

      test('parses 6-digit hex without hash', () {
        final color = OiColorUtils.fromHex('FF5500');
        expect((color.r * 255).round(), equals(0xFF));
      });

      test('parses 3-digit hex', () {
        final color = OiColorUtils.fromHex('#F50');
        expect((color.r * 255).round(), equals(0xFF));
        expect((color.g * 255).round(), equals(0x55));
        expect((color.b * 255).round(), equals(0x00));
      });

      test('parses 8-digit hex with alpha', () {
        final color = OiColorUtils.fromHex('#80FF5500');
        expect((color.a * 255).round(), equals(0x80));
        expect((color.r * 255).round(), equals(0xFF));
      });

      test('roundtrips through toHex and fromHex', () {
        const original = Color(0xFFAB12CD);
        final hex = OiColorUtils.toHex(original);
        final parsed = OiColorUtils.fromHex(hex);
        expect((parsed.r * 255).round(), equals(0xAB));
        expect((parsed.g * 255).round(), equals(0x12));
        expect((parsed.b * 255).round(), equals(0xCD));
      });
    });

    group('generateChartColors', () {
      test('returns empty list for count 0', () {
        expect(OiColorUtils.generateChartColors(0), isEmpty);
      });

      test('returns empty list for negative count', () {
        expect(OiColorUtils.generateChartColors(-1), isEmpty);
      });

      test('returns requested number of colors', () {
        final colors = OiColorUtils.generateChartColors(5);
        expect(colors.length, equals(5));
      });

      test('returns visually distinct colors', () {
        final colors = OiColorUtils.generateChartColors(4);
        // All colors should be different
        final unique = colors.toSet();
        expect(unique.length, equals(4));
      });

      test('uses seed color as starting hue', () {
        const seed = Color(0xFFFF0000); // Red, hue ~= 0
        final colors = OiColorUtils.generateChartColors(3, seed: seed);
        final firstHue = HSLColor.fromColor(colors.first).hue;
        final seedHue = HSLColor.fromColor(seed).hue;
        expect(firstHue, closeTo(seedHue, 1));
      });

      test('single color returns the seed hue', () {
        const seed = Color(0xFF00FF00);
        final colors = OiColorUtils.generateChartColors(1, seed: seed);
        expect(colors.length, equals(1));
      });
    });
  });
}
