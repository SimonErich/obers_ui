// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/theme/oi_radius_scale.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';
import 'package:obers_ui/src/tools/oi_dynamic_theme.dart';

void main() {
  const brandColor = Color(0xFF3366FF);

  group('OiDynamicTheme', () {
    group('fromColor', () {
      test('generates a light theme by default', () {
        final theme = OiDynamicTheme.fromColor(brandColor);

        expect(theme.brightness, Brightness.light);
        expect(theme.colors.primary.base, brandColor);
      });

      test('generates a dark theme when specified', () {
        final theme = OiDynamicTheme.fromColor(
          brandColor,
          brightness: Brightness.dark,
        );

        expect(theme.brightness, Brightness.dark);
        expect(theme.colors.primary.base, brandColor);
      });

      test('passes fontFamily through', () {
        final theme = OiDynamicTheme.fromColor(
          brandColor,
          fontFamily: 'Roboto',
        );

        expect(theme.fontFamily, 'Roboto');
      });

      test('respects radiusPreference', () {
        final sharp = OiDynamicTheme.fromColor(
          brandColor,
          radiusPreference: OiRadiusPreference.sharp,
        );
        final rounded = OiDynamicTheme.fromColor(
          brandColor,
          radiusPreference: OiRadiusPreference.rounded,
        );

        // Sharp should have zero or smaller radii than rounded.
        expect(sharp.radius.md, isNot(equals(rounded.radius.md)));
      });

      test('matches OiThemeData.fromBrand output', () {
        final fromDynamic = OiDynamicTheme.fromColor(brandColor);
        final fromBrand = OiThemeData.fromBrand(color: brandColor);

        expect(fromDynamic.brightness, fromBrand.brightness);
        expect(fromDynamic.colors.primary.base, fromBrand.colors.primary.base);
      });
    });

    group('fromColorPair', () {
      test('returns both light and dark themes', () {
        final pair = OiDynamicTheme.fromColorPair(brandColor);

        expect(pair.light.brightness, Brightness.light);
        expect(pair.dark.brightness, Brightness.dark);
      });

      test('both themes use the same brand color', () {
        final pair = OiDynamicTheme.fromColorPair(brandColor);

        expect(pair.light.colors.primary.base, brandColor);
        expect(pair.dark.colors.primary.base, brandColor);
      });

      test('passes fontFamily to both themes', () {
        final pair = OiDynamicTheme.fromColorPair(
          brandColor,
          fontFamily: 'Inter',
        );

        expect(pair.light.fontFamily, 'Inter');
        expect(pair.dark.fontFamily, 'Inter');
      });

      test('passes radiusPreference to both themes', () {
        final pair = OiDynamicTheme.fromColorPair(
          brandColor,
          radiusPreference: OiRadiusPreference.rounded,
        );

        final roundedRef = OiThemeData.fromBrand(
          color: brandColor,
          radiusPreference: OiRadiusPreference.rounded,
        );

        expect(pair.light.radius.md, roundedRef.radius.md);
        expect(pair.dark.radius.md, roundedRef.radius.md);
      });
    });

    group('fromSeedColor', () {
      test('generates a light theme by default', () {
        final theme = OiDynamicTheme.fromSeedColor(brandColor);

        expect(theme.brightness, Brightness.light);
        expect(theme.colors.primary.base, brandColor);
      });

      test('generates a dark theme when specified', () {
        final theme = OiDynamicTheme.fromSeedColor(
          brandColor,
          brightness: Brightness.dark,
        );

        expect(theme.brightness, Brightness.dark);
      });

      test('returns a valid OiThemeData', () {
        final theme = OiDynamicTheme.fromSeedColor(brandColor);

        expect(theme, isA<OiThemeData>());
        expect(theme.textTheme, isNotNull);
        expect(theme.spacing, isNotNull);
        expect(theme.radius, isNotNull);
      });
    });
  });
}
