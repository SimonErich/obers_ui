// Tests are internal; doc comments on local helpers are not required.

import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_swatch.dart';
import 'package:obers_ui/src/foundation/theme/oi_component_themes.dart';
import 'package:obers_ui/src/foundation/theme/oi_decoration_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_effects_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_radius_scale.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';

void main() {
  group('OiThemeData', () {
    group('light() factory', () {
      test('brightness is light', () {
        expect(OiThemeData.light().brightness, Brightness.light);
      });

      test('isLight is true', () {
        expect(OiThemeData.light().isLight, isTrue);
      });

      test('isDark is false', () {
        expect(OiThemeData.light().isDark, isFalse);
      });

      test('colors are non-null', () {
        final theme = OiThemeData.light();
        expect(theme.colors, isNotNull);
        expect(theme.colors.primary, isNotNull);
      });

      test('textTheme is non-null', () {
        expect(OiThemeData.light().textTheme, isNotNull);
      });

      test('spacing is non-null', () {
        expect(OiThemeData.light().spacing, isNotNull);
      });

      test('radiusPreference.sharp gives zero radii', () {
        final theme = OiThemeData.light(
          radiusPreference: OiRadiusPreference.sharp,
        );
        expect(theme.radius.md, equals(BorderRadius.zero));
      });
    });

    group('dark() factory', () {
      test('brightness is dark', () {
        expect(OiThemeData.dark().brightness, Brightness.dark);
      });

      test('isDark is true', () {
        expect(OiThemeData.dark().isDark, isTrue);
      });

      test('background is darker than light theme', () {
        final light = OiThemeData.light();
        final dark = OiThemeData.dark();
        expect(
          dark.colors.background.computeLuminance(),
          lessThan(light.colors.background.computeLuminance()),
        );
      });
    });

    group('fromBrand() factory', () {
      const brandColor = Color(0xFFE11D48); // rose-600

      test('primary color is set to brand color', () {
        final theme = OiThemeData.fromBrand(color: brandColor);
        expect(theme.colors.primary.base, equals(brandColor));
      });

      test(
        'primary swatch is derived from brand color via OiColorSwatch.from',
        () {
          final theme = OiThemeData.fromBrand(color: brandColor);
          final expectedSwatch = OiColorSwatch.from(brandColor);
          expect(theme.colors.primary, equals(expectedSwatch));
        },
      );

      test('borderFocus is set to brand color', () {
        final theme = OiThemeData.fromBrand(color: brandColor);
        expect(theme.colors.borderFocus, equals(brandColor));
      });

      test(
        'non-primary semantic colors are preserved from base light theme',
        () {
          final theme = OiThemeData.fromBrand(color: brandColor);
          final baseLight = OiThemeData.light();
          expect(theme.colors.success, equals(baseLight.colors.success));
          expect(theme.colors.warning, equals(baseLight.colors.warning));
          expect(theme.colors.error, equals(baseLight.colors.error));
          expect(theme.colors.info, equals(baseLight.colors.info));
        },
      );

      test('effects are rebuilt with brand color', () {
        final theme = OiThemeData.fromBrand(color: brandColor);
        final expectedEffects = OiEffectsTheme.standard(
          primaryColor: brandColor,
        );
        expect(theme.effects, equals(expectedEffects));
      });

      test('decoration is rebuilt with brand and error colors', () {
        final theme = OiThemeData.fromBrand(color: brandColor);
        final baseLight = OiThemeData.light();
        final expectedDecoration = OiDecorationTheme.standard(
          primaryColor: brandColor,
          errorColor: baseLight.colors.error.base,
        );
        expect(theme.decoration, equals(expectedDecoration));
      });

      test('defaults to light brightness', () {
        final theme = OiThemeData.fromBrand(color: brandColor);
        expect(theme.brightness, Brightness.light);
        expect(theme.isLight, isTrue);
      });

      test('dark brand theme has dark brightness', () {
        final theme = OiThemeData.fromBrand(
          color: const Color(0xFF2563EB),
          brightness: Brightness.dark,
        );
        expect(theme.isDark, isTrue);
      });

      test('dark brand theme uses dark base colors except primary', () {
        final theme = OiThemeData.fromBrand(
          color: brandColor,
          brightness: Brightness.dark,
        );
        final baseDark = OiThemeData.dark();
        expect(theme.colors.background, equals(baseDark.colors.background));
        expect(theme.colors.surface, equals(baseDark.colors.surface));
      });

      test('fontFamily is forwarded', () {
        final theme = OiThemeData.fromBrand(
          color: brandColor,
          fontFamily: 'Roboto',
        );
        expect(theme.fontFamily, equals('Roboto'));
      });

      test('monoFontFamily is forwarded', () {
        final theme = OiThemeData.fromBrand(
          color: brandColor,
          monoFontFamily: 'Fira Code',
        );
        expect(theme.monoFontFamily, equals('Fira Code'));
      });

      test('radiusPreference sharp is forwarded', () {
        final theme = OiThemeData.fromBrand(
          color: brandColor,
          radiusPreference: OiRadiusPreference.sharp,
        );
        expect(theme.radius.md, equals(BorderRadius.zero));
      });

      test('components override is forwarded', () {
        const customComponents = OiComponentThemes.empty();
        final theme = OiThemeData.fromBrand(
          color: brandColor,
          components: customComponents,
        );
        expect(theme.components, equals(customComponents));
      });
    });

    group('copyWith', () {
      test('overrides brightness', () {
        final light = OiThemeData.light();
        final modified = light.copyWith(brightness: Brightness.dark);
        expect(modified.brightness, Brightness.dark);
        expect(modified.colors, light.colors); // unchanged
      });
    });

    group('merge', () {
      test('merge overrides all fields from other', () {
        final a = OiThemeData.light();
        final b = OiThemeData.dark();
        final merged = a.merge(b);
        expect(merged.brightness, b.brightness);
        expect(merged.colors, b.colors);
      });
    });

    group('lerp', () {
      test('t=0 returns a', () {
        final a = OiThemeData.light();
        final b = OiThemeData.dark();
        expect(OiThemeData.lerp(a, b, 0), equals(a));
      });

      test('t=1 returns b', () {
        final a = OiThemeData.light();
        final b = OiThemeData.dark();
        expect(OiThemeData.lerp(a, b, 1), equals(b));
      });

      test('t=0.5 uses dark brightness (>0.5 threshold)', () {
        final a = OiThemeData.light();
        final b = OiThemeData.dark();
        final mid = OiThemeData.lerp(a, b, 0.5);
        // At t=0.5, t < 0.5 is false, so we get b's brightness
        expect(mid.brightness, Brightness.dark);
      });
    });

    group('equality', () {
      test('same theme equals itself', () {
        final theme = OiThemeData.light();
        expect(theme, equals(theme));
      });

      test('two light themes are equal', () {
        expect(OiThemeData.light(), equals(OiThemeData.light()));
      });

      test('light and dark are not equal', () {
        expect(OiThemeData.light(), isNot(equals(OiThemeData.dark())));
      });
    });
  });
}
