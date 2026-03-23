import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('Responsive - OiLineChart', () {
    testWidgets('renders at small size (200x150)', (tester) async {
      final data = createSampleLineData();
      await pumpChart(
        tester,
        OiLineChart(data: data, label: 'Small line chart'),
        size: const Size(200, 150),
      );

      expect(find.byType(OiLineChart), findsOneWidget);
    });

    testWidgets('renders at large size (1200x800)', (tester) async {
      final data = createSampleLineData();
      await pumpChart(
        tester,
        OiLineChart(data: data, label: 'Large line chart'),
        size: const Size(1200, 800),
      );

      expect(find.byType(OiLineChart), findsOneWidget);
    });

    testWidgets('renders at extreme aspect ratio (800x100)', (tester) async {
      final data = createSampleLineData();
      await pumpChart(
        tester,
        OiLineChart(data: data, label: 'Wide line chart'),
        size: const Size(800, 100),
      );

      expect(find.byType(OiLineChart), findsOneWidget);
    });

    testWidgets('renders at narrow aspect ratio (100x800)', (tester) async {
      final data = createSampleLineData();
      await pumpChart(
        tester,
        OiLineChart(data: data, label: 'Tall line chart'),
        size: const Size(100, 800),
      );

      expect(find.byType(OiLineChart), findsOneWidget);
    });

    testWidgets('renders at minimum viable size', (tester) async {
      final data = createSampleLineData();
      await pumpChart(
        tester,
        OiLineChart(data: data, label: 'Tiny line chart'),
        size: const Size(80, 60),
      );

      expect(find.byType(OiLineChart), findsOneWidget);
    });
  });

  group('Responsive - OiBarChart', () {
    testWidgets('renders at small size (200x150)', (tester) async {
      final data = createSampleBarData();
      await pumpChart(
        tester,
        OiBarChart(data: data, label: 'Small bar chart'),
        size: const Size(200, 150),
      );

      expect(find.byType(OiBarChart), findsOneWidget);
    });

    testWidgets('renders at large size (1200x800)', (tester) async {
      final data = createSampleBarData();
      await pumpChart(
        tester,
        OiBarChart(data: data, label: 'Large bar chart'),
        size: const Size(1200, 800),
      );

      expect(find.byType(OiBarChart), findsOneWidget);
    });

    testWidgets('renders horizontal at extreme aspect ratio', (tester) async {
      final data = createSampleBarData();
      await pumpChart(
        tester,
        OiBarChart(
          data: data,
          orientation: OiBarChartOrientation.horizontal,
          label: 'Wide horizontal bar chart',
        ),
        size: const Size(800, 100),
      );

      expect(find.byType(OiBarChart), findsOneWidget);
    });

    testWidgets('adjusts bar rects to different sizes', (tester) async {
      final data = createSampleBarData();
      const processor = OiBarChartDataProcessor();

      final smallRects = processor.computeBarRects(
        data,
        const Size(200, 150),
      );
      final largeRects = processor.computeBarRects(
        data,
        const Size(800, 600),
      );

      expect(smallRects[0][0].width, lessThan(largeRects[0][0].width));
    });
  });

  group('Responsive - OiPieChart', () {
    testWidgets('renders at small size (150x150)', (tester) async {
      final data = createSamplePieData();
      await pumpChart(
        tester,
        OiPieChart.fromChartData(data: data, label: 'Small pie chart'),
        size: const Size(150, 150),
      );

      expect(find.byType(OiPieChart), findsOneWidget);
    });

    testWidgets('renders at large size (800x800)', (tester) async {
      final data = createSamplePieData();
      await pumpChart(
        tester,
        OiPieChart.fromChartData(data: data, label: 'Large pie chart'),
        size: const Size(800, 800),
      );

      expect(find.byType(OiPieChart), findsOneWidget);
    });

    testWidgets('renders at non-square size (800x200)', (tester) async {
      final data = createSamplePieData();
      await pumpChart(
        tester,
        OiPieChart.fromChartData(data: data, label: 'Rectangular pie chart'),
        size: const Size(800, 200),
      );

      expect(find.byType(OiPieChart), findsOneWidget);
    });
  });

  group('Responsive - data-to-pixel mapping scales with size', () {
    test('mapDataToPixel adjusts proportionally to chart size', () {
      const data = OiChartData(
        series: [
          OiChartSeries(
            name: 'A',
            dataPoints: [OiDataPoint(x: 0, y: 0), OiDataPoint(x: 10, y: 10)],
          ),
        ],
      );
      final theme = OiChartTheme.light();
      final bounds = data.bounds;

      final smallPainter = _TestPainter(data: data, theme: theme);
      final smallPixel = smallPainter.mapDataToPixel(
        const OiDataPoint(x: 5, y: 5),
        const Size(200, 150),
        bounds,
      );

      final largePixel = smallPainter.mapDataToPixel(
        const OiDataPoint(x: 5, y: 5),
        const Size(800, 600),
        bounds,
      );

      // Midpoint should be further from origin in the larger chart.
      expect(largePixel.dx, greaterThan(smallPixel.dx));
    });
  });
}

class _TestPainter extends OiChartPainter {
  _TestPainter({required super.data, required super.theme});

  @override
  void paint(Canvas canvas, Size size) {}
}
