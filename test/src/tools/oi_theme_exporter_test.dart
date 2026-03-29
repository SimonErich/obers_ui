// Tests do not require documentation comments.

import 'dart:convert';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_scheme.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_swatch.dart';
import 'package:obers_ui/src/foundation/theme/oi_spacing_scale.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';
import 'package:obers_ui/src/tools/oi_theme_exporter.dart';

void main() {
  group('OiThemeExporter', () {
    group('toJson', () {
      test('produces valid JSON string', () {
        final theme = OiThemeData.light();
        final json = OiThemeExporter.toJson(theme);

        // Must parse without throwing.
        final decoded = jsonDecode(json);
        expect(decoded, isA<Map<String, dynamic>>());
      });
    });

    group('toMap', () {
      test('produces Map with expected top-level keys', () {
        final theme = OiThemeData.light();
        final map = OiThemeExporter.toMap(theme);

        expect(map, containsPair('brightness', 'light'));
        expect(map, contains('colors'));
        expect(map, contains('textTheme'));
        expect(map, contains('spacing'));
        expect(map, contains('radius'));
        expect(map, contains('shadows'));
        expect(map, contains('animations'));
        expect(map, contains('effects'));
        expect(map, contains('decoration'));
      });

      test('colors are serialized as hex strings', () {
        final theme = OiThemeData.light();
        final map = OiThemeExporter.toMap(theme);
        final colors = map['colors'] as Map<String, dynamic>;

        // Flat color fields should be hex strings.
        expect(colors['background'], isA<String>());
        expect((colors['background'] as String).startsWith('#'), isTrue);

        // Swatch fields should be maps with hex values.
        final primary = colors['primary'] as Map<String, dynamic>;
        expect(primary['base'], isA<String>());
        expect((primary['base'] as String).startsWith('#'), isTrue);
      });

      test('font weights are serialized as integers', () {
        final theme = OiThemeData.light();
        final map = OiThemeExporter.toMap(theme);
        final textTheme = map['textTheme'] as Map<String, dynamic>;
        final body = textTheme['body'] as Map<String, dynamic>;

        expect(body['fontWeight'], isA<int>());
        expect(body['fontWeight'], equals(400));
      });

      test('durations are serialized as milliseconds', () {
        final theme = OiThemeData.light();
        final map = OiThemeExporter.toMap(theme);
        final animations = map['animations'] as Map<String, dynamic>;

        expect(animations['fastMs'], equals(150));
        expect(animations['normalMs'], equals(250));
        expect(animations['slowMs'], equals(400));
      });
    });

    group('fromJson', () {
      test('roundtrips correctly with toJson', () {
        final original = OiThemeData.light();
        final json = OiThemeExporter.toJson(original);
        final restored = OiThemeExporter.fromJson(json);

        // Colors should match.
        expect(restored.colors.background, equals(original.colors.background));
        expect(
          restored.colors.primary.base,
          equals(original.colors.primary.base),
        );

        // Spacing should match.
        expect(restored.spacing.xs, equals(original.spacing.xs));
        expect(restored.spacing.md, equals(original.spacing.md));
        expect(restored.spacing.xxl, equals(original.spacing.xxl));

        // Animations should match.
        expect(restored.animations.fast, equals(original.animations.fast));
      });

      test('corrupted JSON falls back to light theme', () {
        final result = OiThemeExporter.fromJson('not valid json at all {{{');
        final light = OiThemeData.light();

        expect(result.brightness, equals(light.brightness));
        expect(result.colors.background, equals(light.colors.background));
      });
    });

    group('fromMap', () {
      test('missing fields fall back to defaults', () {
        final result = OiThemeExporter.fromMap(const <String, dynamic>{});
        final light = OiThemeData.light();

        expect(result.brightness, equals(light.brightness));
        expect(result.colors.background, equals(light.colors.background));
        expect(result.spacing.md, equals(light.spacing.md));
      });

      test('dark brightness uses dark defaults for missing fields', () {
        final result = OiThemeExporter.fromMap(const <String, dynamic>{
          'brightness': 'dark',
        });
        final dark = OiThemeData.dark();

        expect(result.brightness, equals(dark.brightness));
        expect(result.colors.background, equals(dark.colors.background));
      });
    });

    group('roundtrip', () {
      test('light theme roundtrips through JSON', () {
        final original = OiThemeData.light();
        final json = OiThemeExporter.toJson(original);
        final restored = OiThemeExporter.fromJson(json);

        _expectColorsMatch(original.colors, restored.colors);
        _expectSpacingMatch(original.spacing, restored.spacing);
      });

      test('dark theme roundtrips through JSON', () {
        final original = OiThemeData.dark();
        final json = OiThemeExporter.toJson(original);
        final restored = OiThemeExporter.fromJson(json);

        expect(restored.brightness, equals(original.brightness));
        _expectColorsMatch(original.colors, restored.colors);
        _expectSpacingMatch(original.spacing, restored.spacing);
      });

      test('custom theme with overrides roundtrips', () {
        final original = OiThemeData.light().copyWith(
          colors: OiColorScheme.light().copyWith(
            primary: OiColorSwatch.from(const Color(0xFFFF5722)),
            background: const Color(0xFFF0F0F0),
          ),
        );
        final json = OiThemeExporter.toJson(original);
        final restored = OiThemeExporter.fromJson(json);

        expect(
          restored.colors.primary.base,
          equals(original.colors.primary.base),
        );
        expect(restored.colors.background, equals(original.colors.background));
      });

      test('roundtrips through Map', () {
        final original = OiThemeData.light();
        final map = OiThemeExporter.toMap(original);
        final restored = OiThemeExporter.fromMap(map);

        _expectColorsMatch(original.colors, restored.colors);
      });
    });

    group('toDart', () {
      test('produces valid-looking Dart code', () {
        final theme = OiThemeData.light();
        final code = OiThemeExporter.toDart(theme);

        expect(code, contains('OiThemeData('));
        expect(code, contains('OiColorScheme('));
        expect(code, contains('OiTextTheme('));
        expect(code, contains('OiSpacingScale('));
        expect(code, contains('OiRadiusScale('));
        expect(code, contains('OiShadowScale('));
        expect(code, contains('OiAnimationConfig('));
        expect(code, contains('OiEffectsTheme('));
        expect(code, contains('OiDecorationTheme('));
      });

      test('includes default variable name', () {
        final theme = OiThemeData.light();
        final code = OiThemeExporter.toDart(theme);

        expect(code, contains('final theme = OiThemeData('));
      });

      test('includes custom variable name', () {
        final theme = OiThemeData.light();
        final code = OiThemeExporter.toDart(
          theme,
          variableName: 'myCustomTheme',
        );

        expect(code, contains('final myCustomTheme = OiThemeData('));
      });

      test('includes Color constructors', () {
        final theme = OiThemeData.light();
        final code = OiThemeExporter.toDart(theme);

        expect(code, contains('const Color(0x'));
      });

      test('includes FontWeight values', () {
        final theme = OiThemeData.light();
        final code = OiThemeExporter.toDart(theme);

        expect(code, contains('FontWeight.w'));
      });

      test('dark theme includes Brightness.dark', () {
        final theme = OiThemeData.dark();
        final code = OiThemeExporter.toDart(theme);

        expect(code, contains('Brightness.dark'));
      });
    });
  });
}

// ── Test helpers ──────────────────────────────────────────────────────────────

void _expectColorsMatch(OiColorScheme a, OiColorScheme b) {
  expect(b.background, equals(a.background));
  expect(b.surface, equals(a.surface));
  expect(b.text, equals(a.text));
  expect(b.primary.base, equals(a.primary.base));
  expect(b.primary.light, equals(a.primary.light));
  expect(b.primary.dark, equals(a.primary.dark));
  expect(b.accent.base, equals(a.accent.base));
  expect(b.success.base, equals(a.success.base));
  expect(b.warning.base, equals(a.warning.base));
  expect(b.error.base, equals(a.error.base));
  expect(b.info.base, equals(a.info.base));
  expect(b.border, equals(a.border));
  expect(b.borderFocus, equals(a.borderFocus));
}

void _expectSpacingMatch(OiSpacingScale a, OiSpacingScale b) {
  expect(b.xs, equals(a.xs));
  expect(b.sm, equals(a.sm));
  expect(b.md, equals(a.md));
  expect(b.lg, equals(a.lg));
  expect(b.xl, equals(a.xl));
  expect(b.xxl, equals(a.xxl));
}
