// Tests for OiColorScheme — no public API docs needed in test files.
// ignore_for_file: public_member_api_docs

import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_scheme.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_swatch.dart';

void main() {
  group('OiColorScheme', () {
    group('OiColorScheme.light', () {
      test('creates non-null primary swatch', () {
        final scheme = OiColorScheme.light();
        expect(scheme.primary, isA<OiColorSwatch>());
      });

      test('creates non-null accent swatch', () {
        final scheme = OiColorScheme.light();
        expect(scheme.accent, isA<OiColorSwatch>());
      });

      test('creates non-null success swatch', () {
        final scheme = OiColorScheme.light();
        expect(scheme.success, isA<OiColorSwatch>());
      });

      test('creates non-null warning swatch', () {
        final scheme = OiColorScheme.light();
        expect(scheme.warning, isA<OiColorSwatch>());
      });

      test('creates non-null error swatch', () {
        final scheme = OiColorScheme.light();
        expect(scheme.error, isA<OiColorSwatch>());
      });

      test('creates non-null info swatch', () {
        final scheme = OiColorScheme.light();
        expect(scheme.info, isA<OiColorSwatch>());
      });

      test('background is light color', () {
        final scheme = OiColorScheme.light();
        expect(scheme.background.computeLuminance(), greaterThan(0.5));
      });

      test('chart has 8 colors', () {
        final scheme = OiColorScheme.light();
        expect(scheme.chart, hasLength(8));
      });

      test('chart colors are non-null', () {
        final scheme = OiColorScheme.light();
        for (final color in scheme.chart) {
          expect(color, isA<Color>());
        }
      });
    });

    group('OiColorScheme.dark', () {
      test('creates non-null primary swatch', () {
        final scheme = OiColorScheme.dark();
        expect(scheme.primary, isA<OiColorSwatch>());
      });

      test('creates non-null accent swatch', () {
        final scheme = OiColorScheme.dark();
        expect(scheme.accent, isA<OiColorSwatch>());
      });

      test('creates non-null success swatch', () {
        final scheme = OiColorScheme.dark();
        expect(scheme.success, isA<OiColorSwatch>());
      });

      test('creates non-null warning swatch', () {
        final scheme = OiColorScheme.dark();
        expect(scheme.warning, isA<OiColorSwatch>());
      });

      test('creates non-null error swatch', () {
        final scheme = OiColorScheme.dark();
        expect(scheme.error, isA<OiColorSwatch>());
      });

      test('creates non-null info swatch', () {
        final scheme = OiColorScheme.dark();
        expect(scheme.info, isA<OiColorSwatch>());
      });

      test('background is dark color', () {
        final scheme = OiColorScheme.dark();
        expect(scheme.background.computeLuminance(), lessThan(0.1));
      });

      test('chart has 8 colors', () {
        final scheme = OiColorScheme.dark();
        expect(scheme.chart, hasLength(8));
      });
    });

    test('light and dark have different background colors', () {
      final light = OiColorScheme.light();
      final dark = OiColorScheme.dark();
      expect(light.background, isNot(equals(dark.background)));
    });

    test('light and dark have different surface colors', () {
      final light = OiColorScheme.light();
      final dark = OiColorScheme.dark();
      expect(light.surface, isNot(equals(dark.surface)));
    });

    group('copyWith', () {
      test('returns equal scheme when no overrides', () {
        final scheme = OiColorScheme.light();
        final copy = scheme.copyWith();
        expect(copy, equals(scheme));
      });

      test('overrides background only', () {
        final scheme = OiColorScheme.light();
        const newBg = Color(0xFFAABBCC);
        final copy = scheme.copyWith(background: newBg);
        expect(copy.background, equals(newBg));
        expect(copy.surface, equals(scheme.surface));
        expect(copy.primary, equals(scheme.primary));
      });

      test('overrides primary swatch only', () {
        final scheme = OiColorScheme.light();
        final newPrimary = OiColorSwatch.from(const Color(0xFFFF0000));
        final copy = scheme.copyWith(primary: newPrimary);
        expect(copy.primary, equals(newPrimary));
        expect(copy.accent, equals(scheme.accent));
      });

      test('overrides chart list', () {
        final scheme = OiColorScheme.light();
        const newChart = [Color(0xFF000000), Color(0xFFFFFFFF)];
        final copy = scheme.copyWith(chart: newChart);
        expect(copy.chart, equals(newChart));
        expect(copy.background, equals(scheme.background));
      });
    });

    group('lerp', () {
      test('t=0 returns scheme equal to a', () {
        final a = OiColorScheme.light();
        final b = OiColorScheme.dark();
        final result = OiColorScheme.lerp(a, b, 0);
        expect(result, equals(a));
      });

      test('t=1 returns scheme equal to b', () {
        final a = OiColorScheme.light();
        final b = OiColorScheme.dark();
        final result = OiColorScheme.lerp(a, b, 1);
        expect(result, equals(b));
      });

      test('t=0.5 interpolates background', () {
        final a = OiColorScheme.light();
        final b = OiColorScheme.dark();
        final mid = OiColorScheme.lerp(a, b, 0.5);
        // mid background luminance should be between light and dark
        expect(
          mid.background.computeLuminance(),
          lessThan(a.background.computeLuminance()),
        );
        expect(
          mid.background.computeLuminance(),
          greaterThan(b.background.computeLuminance()),
        );
      });
    });

    group('equality', () {
      test('two light schemes are equal', () {
        final a = OiColorScheme.light();
        final b = OiColorScheme.light();
        expect(a, equals(b));
      });

      test('two dark schemes are equal', () {
        final a = OiColorScheme.dark();
        final b = OiColorScheme.dark();
        expect(a, equals(b));
      });

      test('light and dark schemes are not equal', () {
        final a = OiColorScheme.light();
        final b = OiColorScheme.dark();
        expect(a, isNot(equals(b)));
      });

      test('hashCode is consistent for light', () {
        final a = OiColorScheme.light();
        final b = OiColorScheme.light();
        expect(a.hashCode, equals(b.hashCode));
      });

      test('hashCode is consistent for dark', () {
        final a = OiColorScheme.dark();
        final b = OiColorScheme.dark();
        expect(a.hashCode, equals(b.hashCode));
      });
    });

    group('semantic surface colors', () {
      test('light scheme surface fields are non-null', () {
        final scheme = OiColorScheme.light();
        expect(scheme.surfaceHover, isA<Color>());
        expect(scheme.surfaceActive, isA<Color>());
        expect(scheme.surfaceSubtle, isA<Color>());
        expect(scheme.overlay, isA<Color>());
      });

      test('dark scheme surface fields are non-null', () {
        final scheme = OiColorScheme.dark();
        expect(scheme.surfaceHover, isA<Color>());
        expect(scheme.surfaceActive, isA<Color>());
        expect(scheme.surfaceSubtle, isA<Color>());
        expect(scheme.overlay, isA<Color>());
      });
    });

    group('text colors', () {
      test('light scheme text fields are non-null', () {
        final scheme = OiColorScheme.light();
        expect(scheme.text, isA<Color>());
        expect(scheme.textSubtle, isA<Color>());
        expect(scheme.textMuted, isA<Color>());
        expect(scheme.textInverse, isA<Color>());
        expect(scheme.textOnPrimary, isA<Color>());
      });

      test('dark scheme text fields are non-null', () {
        final scheme = OiColorScheme.dark();
        expect(scheme.text, isA<Color>());
        expect(scheme.textSubtle, isA<Color>());
        expect(scheme.textMuted, isA<Color>());
        expect(scheme.textInverse, isA<Color>());
        expect(scheme.textOnPrimary, isA<Color>());
      });
    });

    group('border colors', () {
      test('light scheme border fields are non-null', () {
        final scheme = OiColorScheme.light();
        expect(scheme.border, isA<Color>());
        expect(scheme.borderSubtle, isA<Color>());
        expect(scheme.borderFocus, isA<Color>());
        expect(scheme.borderError, isA<Color>());
      });

      test('dark scheme border fields are non-null', () {
        final scheme = OiColorScheme.dark();
        expect(scheme.border, isA<Color>());
        expect(scheme.borderSubtle, isA<Color>());
        expect(scheme.borderFocus, isA<Color>());
        expect(scheme.borderError, isA<Color>());
      });
    });

    group('glass colors', () {
      test('light scheme glass fields are non-null', () {
        final scheme = OiColorScheme.light();
        expect(scheme.glassBackground, isA<Color>());
        expect(scheme.glassBorder, isA<Color>());
      });

      test('dark scheme glass fields are non-null', () {
        final scheme = OiColorScheme.dark();
        expect(scheme.glassBackground, isA<Color>());
        expect(scheme.glassBorder, isA<Color>());
      });
    });
  });
}
