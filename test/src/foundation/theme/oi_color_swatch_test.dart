// ignore_for_file: public_member_api_docs // No public API docs needed in test files.

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_swatch.dart';

void main() {
  group('OiColorSwatch', () {
    const blue = Color(0xFF2563EB);

    test('const constructor stores all fields', () {
      const swatch = OiColorSwatch(
        base: Color(0xFF0000FF),
        light: Color(0xFF6666FF),
        dark: Color(0xFF000099),
        muted: Color(0xFFCCCCFF),
        foreground: Color(0xFFFFFFFF),
      );
      expect(swatch.base, const Color(0xFF0000FF));
      expect(swatch.light, const Color(0xFF6666FF));
      expect(swatch.dark, const Color(0xFF000099));
      expect(swatch.muted, const Color(0xFFCCCCFF));
      expect(swatch.foreground, const Color(0xFFFFFFFF));
    });

    group('OiColorSwatch.from', () {
      test('light is brighter than base', () {
        final swatch = OiColorSwatch.from(blue);
        expect(
          swatch.light.computeLuminance(),
          greaterThan(swatch.base.computeLuminance()),
        );
      });

      test('dark is darker than base', () {
        final swatch = OiColorSwatch.from(blue);
        expect(
          swatch.dark.computeLuminance(),
          lessThan(swatch.base.computeLuminance()),
        );
      });

      test('foreground is white for dark base', () {
        final swatch = OiColorSwatch.from(const Color(0xFF1A1A2E));
        expect(swatch.foreground, const Color(0xFFFFFFFF));
      });

      test('foreground is black for light base', () {
        final swatch = OiColorSwatch.from(const Color(0xFFF9FAFB));
        expect(swatch.foreground, const Color(0xFF000000));
      });

      test('muted has lower saturation than base', () {
        final swatch = OiColorSwatch.from(blue);
        final baseHsl = HSLColor.fromColor(swatch.base);
        final mutedHsl = HSLColor.fromColor(swatch.muted);
        expect(mutedHsl.saturation, lessThan(baseHsl.saturation));
      });
    });

    group('copyWith', () {
      test('returns same values when no overrides', () {
        final swatch = OiColorSwatch.from(blue);
        final copy = swatch.copyWith();
        expect(copy, equals(swatch));
      });

      test('overrides only the specified field', () {
        final swatch = OiColorSwatch.from(blue);
        final copy = swatch.copyWith(base: const Color(0xFFFF0000));
        expect(copy.base, const Color(0xFFFF0000));
        expect(copy.light, swatch.light);
        expect(copy.dark, swatch.dark);
      });
    });

    group('lerp', () {
      test('t=0 returns a', () {
        final a = OiColorSwatch.from(const Color(0xFF0000FF));
        final b = OiColorSwatch.from(const Color(0xFFFF0000));
        expect(OiColorSwatch.lerp(a, b, 0), equals(a));
      });

      test('t=1 returns b', () {
        final a = OiColorSwatch.from(const Color(0xFF0000FF));
        final b = OiColorSwatch.from(const Color(0xFFFF0000));
        final result = OiColorSwatch.lerp(a, b, 1);
        expect(result.base, equals(b.base));
      });

      test('t=0.5 interpolates base color', () {
        const a = OiColorSwatch(
          base: Color(0xFF000000),
          light: Color(0xFF000000),
          dark: Color(0xFF000000),
          muted: Color(0xFF000000),
          foreground: Color(0xFFFFFFFF),
        );
        const b = OiColorSwatch(
          base: Color(0xFFFFFFFF),
          light: Color(0xFFFFFFFF),
          dark: Color(0xFFFFFFFF),
          muted: Color(0xFFFFFFFF),
          foreground: Color(0xFF000000),
        );
        final mid = OiColorSwatch.lerp(a, b, 0.5);
        expect((mid.base.r * 255).round(), closeTo(128, 2));
      });
    });

    group('equality', () {
      test('equal swatches are equal', () {
        final a = OiColorSwatch.from(blue);
        final b = OiColorSwatch.from(blue);
        expect(a, equals(b));
      });

      test('different swatches are not equal', () {
        final a = OiColorSwatch.from(blue);
        final b = OiColorSwatch.from(const Color(0xFFFF0000));
        expect(a, isNot(equals(b)));
      });

      test('hashCode is consistent', () {
        final a = OiColorSwatch.from(blue);
        final b = OiColorSwatch.from(blue);
        expect(a.hashCode, equals(b.hashCode));
      });
    });

    test('toString contains field names', () {
      final swatch = OiColorSwatch.from(blue);
      expect(swatch.toString(), contains('OiColorSwatch'));
      expect(swatch.toString(), contains('base'));
    });
  });
}
