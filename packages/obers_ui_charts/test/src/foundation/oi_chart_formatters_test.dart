import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

void main() {
  group('OiAxisFormatContext', () {
    test('provides tick position flags', () {
      const context = OiAxisFormatContext<double>(
        theme: OiChartThemeData(),
        locale: Locale('en'),
        isFirstTick: true,
        axisPosition: 'bottom',
        availableWidth: 60,
      );

      expect(context.isFirstTick, isTrue);
      expect(context.isLastTick, isFalse);
      expect(context.axisPosition, 'bottom');
      expect(context.availableWidth, 60);
    });

    test('inherits OiFormatterContext properties', () {
      const theme = OiChartThemeData();
      const context = OiAxisFormatContext<double>(
        theme: theme,
        locale: Locale('de'),
      );

      expect(context.theme, theme);
      expect(context.locale, const Locale('de'));
      expect(context.atom, 0);
    });

    test('equality includes axis-specific fields', () {
      const a = OiAxisFormatContext<double>(
        theme: OiChartThemeData(),
        locale: Locale('en'),
        isFirstTick: true,
      );
      const b = OiAxisFormatContext<double>(
        theme: OiChartThemeData(),
        locale: Locale('en'),
        isFirstTick: true,
      );
      const c = OiAxisFormatContext<double>(
        theme: OiChartThemeData(),
        locale: Locale('en'),
      );
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('OiTooltipFormatContext', () {
    test('provides series identification', () {
      const context = OiTooltipFormatContext(
        theme: OiChartThemeData(),
        locale: Locale('en'),
        seriesId: 'revenue',
        seriesLabel: 'Revenue',
        pointIndex: 5,
      );

      expect(context.seriesId, 'revenue');
      expect(context.seriesLabel, 'Revenue');
      expect(context.pointIndex, 5);
    });
  });

  group('OiTickStrategy', () {
    test('auto has sensible defaults', () {
      const strategy = OiTickStrategy.auto;
      expect(strategy.mode, OiTickStrategyMode.auto);
      expect(strategy.niceValues, isTrue);
      expect(strategy.includeEndpoints, isTrue);
      expect(strategy.maxCount, isNull);
    });

    test('custom maxCount limits ticks', () {
      const strategy = OiTickStrategy(maxCount: 5);
      expect(strategy.maxCount, 5);
      expect(strategy.mode, OiTickStrategyMode.auto);
    });

    test('minMax preset limits to 2 ticks', () {
      const strategy = OiTickStrategy.minMax;
      expect(strategy.mode, OiTickStrategyMode.minMax);
      expect(strategy.maxCount, 2);
    });

    test('equality', () {
      const a = OiTickStrategy(maxCount: 10, minSpacingPx: 40);
      const b = OiTickStrategy(maxCount: 10, minSpacingPx: 40);
      const c = OiTickStrategy(maxCount: 5, minSpacingPx: 40);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });
  });
}
