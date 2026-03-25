import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart' show OiColorScheme;
import 'package:obers_ui_charts/obers_ui_charts.dart';

void main() {
  group('OiChartPalette', () {
    test('categorical returns at least 8 colors', () {
      final palette = OiChartPalette.colors(OiColorScheme.light());
      expect(palette.categorical.length, greaterThanOrEqualTo(8));
    });

    test('has semantic colors: positive, negative, neutral, highlight', () {
      final palette = OiChartPalette.colors(OiColorScheme.light());
      // Accessing fields verifies they are non-null (Color is non-nullable).
      expect(palette.positive, isNotNull);
      expect(palette.negative, isNotNull);
      expect(palette.neutral, isNotNull);
      expect(palette.highlight, isNotNull);
    });
  });

  group('OiChartThemeData', () {
    test('default constructor does not throw', () {
      expect(() => const OiChartThemeData(), returnsNormally);
    });

    test('has all 9 non-palette sub-themes as accessible fields after '
        'construction with explicit values', () {
      const theme = OiChartThemeData(
        axis: OiChartAxisTheme(),
        grid: OiChartGridTheme(),
        legend: OiChartLegendTheme(),
        tooltip: OiChartTooltipTheme(),
        crosshair: OiChartCrosshairTheme(),
        annotation: OiChartAnnotationTheme(),
        selection: OiChartSelectionTheme(),
        motion: OiChartMotionTheme(),
        density: OiChartDensityTheme(),
      );

      expect(theme.axis, isNotNull);
      expect(theme.grid, isNotNull);
      expect(theme.legend, isNotNull);
      expect(theme.tooltip, isNotNull);
      expect(theme.crosshair, isNotNull);
      expect(theme.annotation, isNotNull);
      expect(theme.selection, isNotNull);
      expect(theme.motion, isNotNull);
      expect(theme.density, isNotNull);
    });

    test('all 9 sub-theme fields are null on default-constructed instance', () {
      const theme = OiChartThemeData();

      // All sub-themes default to null when not supplied.
      expect(theme.axis, isNull);
      expect(theme.grid, isNull);
      expect(theme.legend, isNull);
      expect(theme.tooltip, isNull);
      expect(theme.crosshair, isNull);
      expect(theme.annotation, isNull);
      expect(theme.selection, isNull);
      expect(theme.motion, isNull);
      expect(theme.density, isNull);
    });

    test('light and dark themes have different categorical palette colors', () {
      final lightPalette = OiChartPalette.colors(OiColorScheme.light());
      final darkPalette = OiChartPalette.colors(OiColorScheme.dark());

      // The two palettes must not be identical (the schemes define different
      // chart color lists for light vs dark contexts).
      expect(lightPalette.categorical, isNot(equals(darkPalette.categorical)));
    });
  });
}
