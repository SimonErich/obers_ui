import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

/// Pumps a chart widget inside a minimal app scaffold for testing.
Future<void> pumpChart(
  WidgetTester tester,
  Widget chart, {
  OiChartTheme? theme,
  Size size = const Size(400, 300),
}) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: SizedBox(width: size.width, height: size.height, child: chart),
      ),
    ),
  );
}

/// Creates sample data suitable for line charts.
OiChartData createSampleLineData({int points = 5, int series = 1}) {
  return OiChartData(
    series: List.generate(
      series,
      (si) => OiChartSeries(
        name: 'Series ${si + 1}',
        dataPoints: List.generate(
          points,
          (pi) => OiDataPoint(
            x: pi.toDouble(),
            y: (pi * (si + 1) + 1).toDouble(),
            label: 'Point $pi',
          ),
        ),
      ),
    ),
  );
}

/// Creates sample data suitable for bar charts.
OiChartData createSampleBarData({int categories = 4, int series = 1}) {
  return OiChartData(
    series: List.generate(
      series,
      (si) => OiChartSeries(
        name: 'Series ${si + 1}',
        dataPoints: List.generate(
          categories,
          (ci) => OiDataPoint(
            x: ci.toDouble(),
            y: ((ci + 1) * 10 + si * 5).toDouble(),
            label: 'Category $ci',
          ),
        ),
      ),
    ),
  );
}

/// Creates sample data suitable for pie charts (single series).
OiChartData createSamplePieData({int slices = 4}) {
  return OiChartData(
    series: [
      OiChartSeries(
        name: 'Pie',
        dataPoints: List.generate(
          slices,
          (i) => OiDataPoint(
            x: i.toDouble(),
            y: ((i + 1) * 25).toDouble(),
            label: 'Slice $i',
          ),
        ),
      ),
    ],
  );
}
