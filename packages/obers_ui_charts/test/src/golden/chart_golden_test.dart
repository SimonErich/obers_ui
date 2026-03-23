import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('Golden - OiLineChart', () {
    testWidgets('light theme', (tester) async {
      final data = createSampleLineData(points: 5, series: 2);
      await pumpChart(
        tester,
        OiLineChart(data: data, label: 'Golden line chart'),
        size: const Size(400, 300),
      );

      await expectLater(
        find.byType(OiLineChart),
        matchesGoldenFile('goldens/line_chart_light.png'),
      );
    });

    testWidgets('dark theme', (tester) async {
      final data = createSampleLineData(points: 5, series: 2);
      await pumpChart(
        tester,
        OiLineChart(
          data: data,
          theme: OiChartTheme.dark(),
          label: 'Dark line chart',
        ),
        size: const Size(400, 300),
      );

      await expectLater(
        find.byType(OiLineChart),
        matchesGoldenFile('goldens/line_chart_dark.png'),
      );
    });

    testWidgets('no points variant', (tester) async {
      final data = createSampleLineData(points: 5, series: 1);
      await pumpChart(
        tester,
        OiLineChart(
          data: data,
          showPoints: false,
          label: 'No points line chart',
        ),
        size: const Size(400, 300),
      );

      await expectLater(
        find.byType(OiLineChart),
        matchesGoldenFile('goldens/line_chart_no_points.png'),
      );
    });
  });

  group('Golden - OiBarChart', () {
    testWidgets('vertical light theme', (tester) async {
      final data = createSampleBarData(categories: 4, series: 2);
      await pumpChart(
        tester,
        OiBarChart(data: data, label: 'Golden bar chart'),
        size: const Size(400, 300),
      );

      await expectLater(
        find.byType(OiBarChart),
        matchesGoldenFile('goldens/bar_chart_vertical.png'),
      );
    });

    testWidgets('horizontal orientation', (tester) async {
      final data = createSampleBarData(categories: 4, series: 2);
      await pumpChart(
        tester,
        OiBarChart(
          data: data,
          orientation: OiBarChartOrientation.horizontal,
          label: 'Horizontal bar chart',
        ),
        size: const Size(400, 300),
      );

      await expectLater(
        find.byType(OiBarChart),
        matchesGoldenFile('goldens/bar_chart_horizontal.png'),
      );
    });

    testWidgets('dark theme', (tester) async {
      final data = createSampleBarData(categories: 4, series: 2);
      await pumpChart(
        tester,
        OiBarChart(
          data: data,
          theme: OiChartTheme.dark(),
          label: 'Dark bar chart',
        ),
        size: const Size(400, 300),
      );

      await expectLater(
        find.byType(OiBarChart),
        matchesGoldenFile('goldens/bar_chart_dark.png'),
      );
    });
  });

  group('Golden - OiPieChart', () {
    testWidgets('full pie light theme', (tester) async {
      final data = createSamplePieData(slices: 4);
      await pumpChart(
        tester,
        OiPieChart(data: data, label: 'Golden pie chart'),
        size: const Size(300, 300),
      );

      await expectLater(
        find.byType(OiPieChart),
        matchesGoldenFile('goldens/pie_chart_full.png'),
      );
    });

    testWidgets('donut chart', (tester) async {
      final data = createSamplePieData(slices: 4);
      await pumpChart(
        tester,
        OiPieChart(data: data, holeRadius: 0.5, label: 'Golden donut chart'),
        size: const Size(300, 300),
      );

      await expectLater(
        find.byType(OiPieChart),
        matchesGoldenFile('goldens/pie_chart_donut.png'),
      );
    });

    testWidgets('dark theme', (tester) async {
      final data = createSamplePieData(slices: 4);
      await pumpChart(
        tester,
        OiPieChart(
          data: data,
          theme: OiChartTheme.dark(),
          label: 'Dark pie chart',
        ),
        size: const Size(300, 300),
      );

      await expectLater(
        find.byType(OiPieChart),
        matchesGoldenFile('goldens/pie_chart_dark.png'),
      );
    });
  });
}
