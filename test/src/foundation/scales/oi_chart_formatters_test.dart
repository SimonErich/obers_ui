// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_formatters.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_scale.dart';
import 'package:obers_ui/src/foundation/scales/oi_linear_scale.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_chart_theme_data.dart';

void main() {
  // ── OiFormatterContext ────────────────────────────────────────────────────

  group('OiFormatterContext', () {
    test('stores theme, locale, and optional scale', () {
      const theme = OiChartThemeData();
      const locale = Locale('en', 'US');

      final context = OiFormatterContext<double>(
        theme: theme,
        locale: locale,
      );

      expect(context.theme, same(theme));
      expect(context.locale, locale);
      expect(context.scale, isNull);
    });

    test('stores optional scale', () {
      const theme = OiChartThemeData();
      const locale = Locale('de', 'DE');
      const scale = OiLinearScale(
        domainMin: 0,
        domainMax: 100,
        rangeMin: 0,
        rangeMax: 400,
      );

      final context = OiFormatterContext<double>(
        theme: theme,
        locale: locale,
        scale: scale,
      );

      expect(context.scale, same(scale));
    });

    test('equality', () {
      const theme = OiChartThemeData();
      const locale = Locale('en', 'US');

      final a = OiFormatterContext<double>(theme: theme, locale: locale);
      final b = OiFormatterContext<double>(theme: theme, locale: locale);
      final c = OiFormatterContext<double>(
        theme: theme,
        locale: const Locale('fr', 'FR'),
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('equality with scale', () {
      const theme = OiChartThemeData();
      const locale = Locale('en', 'US');
      const scale = OiLinearScale(
        domainMin: 0,
        domainMax: 100,
        rangeMin: 0,
        rangeMax: 400,
      );

      final a = OiFormatterContext<double>(
        theme: theme,
        locale: locale,
        scale: scale,
      );
      final b = OiFormatterContext<double>(
        theme: theme,
        locale: locale,
        scale: scale,
      );
      final c = OiFormatterContext<double>(
        theme: theme,
        locale: locale,
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  // ── OiAxisFormatter ───────────────────────────────────────────────────────

  group('OiAxisFormatter', () {
    test('formats numeric values', () {
      final OiAxisFormatter<double> formatter = (value, context) {
        return '${value.toStringAsFixed(1)}%';
      };

      const ctx = OiFormatterContext<double>(
        theme: OiChartThemeData(),
        locale: Locale('en', 'US'),
      );

      expect(formatter(0.5, ctx), '0.5%');
      expect(formatter(99.9, ctx), '99.9%');
    });

    test('formats string values', () {
      final OiAxisFormatter<String> formatter = (value, context) {
        return value.toUpperCase();
      };

      const ctx = OiFormatterContext<String>(
        theme: OiChartThemeData(),
        locale: Locale('en', 'US'),
      );

      expect(formatter('jan', ctx), 'JAN');
    });

    test('can use scale information', () {
      final OiAxisFormatter<double> formatter = (value, context) {
        final scaleType = context.scale?.type;
        if (scaleType == OiScaleType.logarithmic) {
          return '10^${value.toInt()}';
        }
        return value.toString();
      };

      const ctx = OiFormatterContext<double>(
        theme: OiChartThemeData(),
        locale: Locale('en', 'US'),
      );

      expect(formatter(3.0, ctx), '3.0');
    });
  });

  // ── OiTooltipValueFormatter ───────────────────────────────────────────────

  group('OiTooltipValueFormatter', () {
    test('formats tooltip values', () {
      final OiTooltipValueFormatter formatter = (value, context) {
        return '\$${value.toStringAsFixed(2)}';
      };

      const ctx = OiFormatterContext<double>(
        theme: OiChartThemeData(),
        locale: Locale('en', 'US'),
      );

      expect(formatter(1234.5, ctx), '\$1234.50');
      expect(formatter(0, ctx), '\$0.00');
    });

    test('can use locale for formatting', () {
      final OiTooltipValueFormatter formatter = (value, context) {
        final lang = context.locale.languageCode;
        if (lang == 'de') {
          return '${value.toStringAsFixed(2).replaceAll('.', ',')} EUR';
        }
        return '\$${value.toStringAsFixed(2)}';
      };

      const deCtx = OiFormatterContext<double>(
        theme: OiChartThemeData(),
        locale: Locale('de', 'DE'),
      );
      const enCtx = OiFormatterContext<double>(
        theme: OiChartThemeData(),
        locale: Locale('en', 'US'),
      );

      expect(formatter(42.5, deCtx), '42,50 EUR');
      expect(formatter(42.5, enCtx), '\$42.50');
    });
  });

  // ── OiSeriesLabelFormatter ────────────────────────────────────────────────

  group('OiSeriesLabelFormatter', () {
    test('formats series labels', () {
      final OiSeriesLabelFormatter<String> formatter = (value, context) {
        return value.length > 10 ? '${value.substring(0, 7)}...' : value;
      };

      const ctx = OiFormatterContext<String>(
        theme: OiChartThemeData(),
        locale: Locale('en', 'US'),
      );

      expect(formatter('Short', ctx), 'Short');
      expect(formatter('A Very Long Series Name', ctx), 'A Very ...');
    });

    test('works with generic types', () {
      final OiSeriesLabelFormatter<int> formatter = (value, context) {
        return 'Series $value';
      };

      const ctx = OiFormatterContext<int>(
        theme: OiChartThemeData(),
        locale: Locale('en', 'US'),
      );

      expect(formatter(1, ctx), 'Series 1');
      expect(formatter(42, ctx), 'Series 42');
    });
  });
}
