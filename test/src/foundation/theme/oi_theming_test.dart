import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

void main() {
  // ── ST1: OiColorScheme.chart ─────────────────────────────────────────────

  group('OiColorScheme.chart', () {
    test('light() has non-empty chart list', () {
      final scheme = OiColorScheme.light();
      expect(scheme.chart, isNotEmpty);
    });

    test('dark() has non-empty chart list', () {
      final scheme = OiColorScheme.dark();
      expect(scheme.chart, isNotEmpty);
    });

    test('copyWith(chart: [...]) replaces chart colors', () {
      final scheme = OiColorScheme.light();
      const newChart = [Color(0xFFFF0000), Color(0xFF00FF00)];
      final updated = scheme.copyWith(chart: newChart);
      expect(updated.chart, equals(newChart));
    });

    test('copyWith without chart preserves original chart', () {
      final scheme = OiColorScheme.light();
      final updated = scheme.copyWith(background: const Color(0xFF123456));
      expect(updated.chart, equals(scheme.chart));
    });

    test('lerp interpolates chart list (same length)', () {
      final a = OiColorScheme.light();
      final b = OiColorScheme.dark();
      final lerped = OiColorScheme.lerp(a, b, 0.5);
      expect(lerped.chart.length, equals(a.chart.length));
    });

    test('lerp at t=0 equals a chart', () {
      final a = OiColorScheme.light();
      final b = OiColorScheme.dark();
      final lerped = OiColorScheme.lerp(a, b, 0);
      expect(lerped.chart, equals(a.chart));
    });

    test('lerp at t=1 equals b chart', () {
      final a = OiColorScheme.light();
      final b = OiColorScheme.dark();
      final lerped = OiColorScheme.lerp(a, b, 1);
      expect(lerped.chart, equals(b.chart));
    });
  });

  // ── ST2: OiThemeExt ───────────────────────────────────────────────────────

  group('OiThemeExt', () {
    testWidgets('context.oiTheme returns OiThemeData', (tester) async {
      OiThemeData? captured;

      await tester.pumpWidget(
        OiTheme(
          data: OiThemeData.light(),
          child: Builder(
            builder: (context) {
              captured = context.oiTheme;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(captured, isNotNull);
      expect(captured, isA<OiThemeData>());
    });

    testWidgets('context.oiColors returns OiColorScheme', (tester) async {
      OiColorScheme? captured;

      await tester.pumpWidget(
        OiTheme(
          data: OiThemeData.light(),
          child: Builder(
            builder: (context) {
              captured = context.oiColors;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(captured, isNotNull);
      expect(captured, isA<OiColorScheme>());
    });
  });

  // ── ST3: OiThemeData.performanceConfig ───────────────────────────────────

  group('OiThemeData.performanceConfig', () {
    test('light() has performanceConfig field', () {
      final theme = OiThemeData.light();
      expect(theme.performanceConfig, isNotNull);
      expect(theme.performanceConfig, isA<OiPerformanceConfig>());
    });

    test('dark() has performanceConfig field', () {
      final theme = OiThemeData.dark();
      expect(theme.performanceConfig, isNotNull);
    });

    test('light() defaults to high performance config', () {
      final theme = OiThemeData.light();
      expect(theme.performanceConfig.disableBlur, isFalse);
      expect(theme.performanceConfig.disableShadows, isFalse);
      expect(theme.performanceConfig.reduceAnimations, isFalse);
    });

    test('light() accepts custom performanceConfig', () {
      const config = OiPerformanceConfig.low();
      final theme = OiThemeData.light(performanceConfig: config);
      expect(theme.performanceConfig, equals(config));
    });

    test('dark() accepts custom performanceConfig', () {
      const config = OiPerformanceConfig.mid();
      final theme = OiThemeData.dark(performanceConfig: config);
      expect(theme.performanceConfig, equals(config));
    });

    test('copyWith(performanceConfig: ...) replaces config', () {
      final theme = OiThemeData.light();
      const newConfig = OiPerformanceConfig.low();
      final updated = theme.copyWith(performanceConfig: newConfig);
      expect(updated.performanceConfig, equals(newConfig));
    });

    test('copyWith without performanceConfig preserves original', () {
      const config = OiPerformanceConfig.low();
      final theme = OiThemeData.light(performanceConfig: config);
      final updated = theme.copyWith(fontFamily: 'Roboto');
      expect(updated.performanceConfig, equals(config));
    });

    test('merge propagates performanceConfig from other', () {
      final base = OiThemeData.light();
      const config = OiPerformanceConfig.low();
      final override = OiThemeData.light(performanceConfig: config);
      final merged = base.merge(override);
      expect(merged.performanceConfig, equals(config));
    });

    test('lerp at t=0 uses a.performanceConfig', () {
      const configA = OiPerformanceConfig.high();
      const configB = OiPerformanceConfig.low();
      final a = OiThemeData.light(performanceConfig: configA);
      final b = OiThemeData.light(performanceConfig: configB);
      final lerped = OiThemeData.lerp(a, b, 0);
      expect(lerped.performanceConfig, equals(configA));
    });

    test('lerp at t=1 uses b.performanceConfig', () {
      const configA = OiPerformanceConfig.high();
      const configB = OiPerformanceConfig.low();
      final a = OiThemeData.light(performanceConfig: configA);
      final b = OiThemeData.light(performanceConfig: configB);
      final lerped = OiThemeData.lerp(a, b, 1);
      expect(lerped.performanceConfig, equals(configB));
    });

    test('lerp at t=0.5 uses b.performanceConfig (t >= 0.5)', () {
      const configA = OiPerformanceConfig.high();
      const configB = OiPerformanceConfig.low();
      final a = OiThemeData.light(performanceConfig: configA);
      final b = OiThemeData.light(performanceConfig: configB);
      final lerped = OiThemeData.lerp(a, b, 0.5);
      expect(lerped.performanceConfig, equals(configB));
    });

    test('fromBrand() accepts performanceConfig', () {
      const config = OiPerformanceConfig.mid();
      final theme = OiThemeData.fromBrand(
        color: const Color(0xFF2563EB),
        performanceConfig: config,
      );
      expect(theme.performanceConfig, equals(config));
    });

    test('equality considers performanceConfig', () {
      final a = OiThemeData.light(
        performanceConfig: const OiPerformanceConfig.high(),
      );
      final b = OiThemeData.light(
        performanceConfig: const OiPerformanceConfig.low(),
      );
      expect(a == b, isFalse);
    });

    test('hashCode differs when performanceConfig differs', () {
      final a = OiThemeData.light(
        performanceConfig: const OiPerformanceConfig.high(),
      );
      final b = OiThemeData.light(
        performanceConfig: const OiPerformanceConfig.low(),
      );
      expect(a.hashCode == b.hashCode, isFalse);
    });
  });

  // ── ST5: OiButtonThemeScope ───────────────────────────────────────────────

  group('OiButtonThemeScope', () {
    testWidgets('provides OiButtonThemeData to descendants', (tester) async {
      const buttonTheme = OiButtonThemeData(borderRadius: BorderRadius.zero);
      OiButtonThemeData? captured;

      await tester.pumpWidget(
        OiButtonThemeScope(
          theme: buttonTheme,
          child: Builder(
            builder: (context) {
              captured = OiButtonThemeScope.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(captured, equals(buttonTheme));
    });

    testWidgets('of(context) returns null when no ancestor', (tester) async {
      OiButtonThemeData? Function()? capturedFn;

      await tester.pumpWidget(
        Builder(
          builder: (context) {
            capturedFn = () => OiButtonThemeScope.of(context);
            return const SizedBox();
          },
        ),
      );

      expect(capturedFn?.call(), isNull);
    });

    testWidgets('nested scope overrides ancestor scope', (tester) async {
      const outerTheme = OiButtonThemeData(borderRadius: BorderRadius.zero);
      const innerTheme = OiButtonThemeData(
        borderRadius: BorderRadius.zero,
        padding: EdgeInsets.all(8),
      );
      OiButtonThemeData? captured;

      await tester.pumpWidget(
        OiButtonThemeScope(
          theme: outerTheme,
          child: OiButtonThemeScope(
            theme: innerTheme,
            child: Builder(
              builder: (context) {
                captured = OiButtonThemeScope.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(captured, equals(innerTheme));
    });

    testWidgets('updateShouldNotify triggers rebuild on theme change', (
      tester,
    ) async {
      var buildCount = 0;

      Widget build(OiButtonThemeData theme) {
        return OiButtonThemeScope(
          theme: theme,
          child: Builder(
            builder: (context) {
              OiButtonThemeScope.of(context);
              buildCount++;
              return const SizedBox();
            },
          ),
        );
      }

      await tester.pumpWidget(build(const OiButtonThemeData()));
      final countAfterFirst = buildCount;

      await tester.pumpWidget(
        build(const OiButtonThemeData(borderRadius: BorderRadius.zero)),
      );

      expect(buildCount, greaterThan(countAfterFirst));
    });
  });
}
