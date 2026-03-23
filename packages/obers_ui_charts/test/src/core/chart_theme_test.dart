import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

void main() {
  group('OiChartColors', () {
    test('colorForSeries returns correct color by index', () {
      const colors = OiChartColors(
        seriesColors: [Color(0xFFFF0000), Color(0xFF00FF00)],
        gridColor: Color(0xFF000000),
        axisColor: Color(0xFF000000),
        backgroundColor: Color(0xFFFFFFFF),
      );

      expect(colors.colorForSeries(0), const Color(0xFFFF0000));
      expect(colors.colorForSeries(1), const Color(0xFF00FF00));
    });

    test('colorForSeries wraps around for indices beyond list length', () {
      const colors = OiChartColors(
        seriesColors: [Color(0xFFFF0000), Color(0xFF00FF00)],
        gridColor: Color(0xFF000000),
        axisColor: Color(0xFF000000),
        backgroundColor: Color(0xFFFFFFFF),
      );

      expect(colors.colorForSeries(2), const Color(0xFFFF0000));
      expect(colors.colorForSeries(3), const Color(0xFF00FF00));
    });

    test('copyWith replaces specified fields', () {
      const original = OiChartColors(
        seriesColors: [Color(0xFFFF0000)],
        gridColor: Color(0xFF000000),
        axisColor: Color(0xFF000000),
        backgroundColor: Color(0xFFFFFFFF),
      );

      final updated = original.copyWith(gridColor: const Color(0xFF111111));

      expect(updated.gridColor, const Color(0xFF111111));
      expect(updated.seriesColors, original.seriesColors);
      expect(updated.axisColor, original.axisColor);
    });

    test('copyWith preserves all fields when no arguments given', () {
      const original = OiChartColors(
        seriesColors: [Color(0xFFFF0000)],
        gridColor: Color(0xFF000000),
        axisColor: Color(0xFF000000),
        backgroundColor: Color(0xFFFFFFFF),
      );

      final copy = original.copyWith();
      expect(copy.seriesColors, original.seriesColors);
      expect(copy.gridColor, original.gridColor);
      expect(copy.axisColor, original.axisColor);
      expect(copy.backgroundColor, original.backgroundColor);
    });
  });

  group('OiChartTextStyles', () {
    test('stores all text styles', () {
      const styles = OiChartTextStyles(
        axisLabel: TextStyle(fontSize: 10),
        tooltipLabel: TextStyle(fontSize: 12),
        legendLabel: TextStyle(fontSize: 14),
      );

      expect(styles.axisLabel.fontSize, 10);
      expect(styles.tooltipLabel.fontSize, 12);
      expect(styles.legendLabel.fontSize, 14);
    });

    test('copyWith replaces specified fields', () {
      const original = OiChartTextStyles(
        axisLabel: TextStyle(fontSize: 10),
        tooltipLabel: TextStyle(fontSize: 12),
        legendLabel: TextStyle(fontSize: 14),
      );

      final updated = original.copyWith(
        axisLabel: const TextStyle(fontSize: 20),
      );

      expect(updated.axisLabel.fontSize, 20);
      expect(updated.tooltipLabel.fontSize, 12);
    });
  });

  group('OiChartTheme', () {
    test('light factory creates valid theme', () {
      final theme = OiChartTheme.light();

      expect(theme.colors.seriesColors, isNotEmpty);
      expect(theme.colors.backgroundColor, const Color(0xFFFFFFFF));
      expect(theme.gridLineWidth, 0.5);
      expect(theme.axisLineWidth, 1);
    });

    test('dark factory creates valid theme', () {
      final theme = OiChartTheme.dark();

      expect(theme.colors.seriesColors, isNotEmpty);
      expect(theme.colors.backgroundColor, const Color(0xFF121212));
      expect(theme.gridLineWidth, 0.5);
      expect(theme.axisLineWidth, 1);
    });

    test('light and dark have different colors', () {
      final light = OiChartTheme.light();
      final dark = OiChartTheme.dark();

      expect(light.colors.backgroundColor, isNot(dark.colors.backgroundColor));
      expect(light.colors.gridColor, isNot(dark.colors.gridColor));
    });

    test('copyWith replaces specified fields', () {
      final original = OiChartTheme.light();
      final updated = original.copyWith(gridLineWidth: 2);

      expect(updated.gridLineWidth, 2);
      expect(updated.axisLineWidth, original.axisLineWidth);
      expect(updated.colors, original.colors);
    });

    test('series colors list has multiple entries', () {
      final theme = OiChartTheme.light();
      expect(theme.colors.seriesColors.length, greaterThanOrEqualTo(4));
    });

    test('text styles are configured', () {
      final theme = OiChartTheme.light();
      expect(theme.textStyles.axisLabel.fontSize, isNotNull);
      expect(theme.textStyles.tooltipLabel.fontSize, isNotNull);
      expect(theme.textStyles.legendLabel.fontSize, isNotNull);
    });
  });
}
