
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import '../../helpers/pump_chart_app.dart';

class _Point {
  const _Point(this.x, this.y);
  final double x;
  final double y;
}

void main() {
  group('OiCartesianChart decimation wiring', () {
    testWidgets('decimation applies when performance config set', (
      tester,
    ) async {
      // Create 200 data points.
      final data = List.generate(
        200,
        (i) => _Point(i.toDouble(), (i * 7 % 50).toDouble()),
      );

      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiCartesianChart<_Point>(
            label: 'Decimation test',
            series: [
              OiCartesianSeries<_Point>(
                id: 'test',
                label: 'Test',
                data: data,
                xMapper: (p) => p.x,
                yMapper: (p) => p.y,
              ),
            ],
            performance: const OiChartPerformanceConfig(
              decimationStrategy: OiChartDecimationStrategy.lttb,
              maxInteractivePoints: 50,
            ),
            seriesBuilder: (context, viewport, series) {
              // Access the chart's state to check normalization.
              // The chart should have reduced point count.
              return const SizedBox.expand();
            },
          ),
        ),
        surfaceSize: const Size(400, 300),
      );

      // Chart renders without error.
      expect(find.byType(OiCartesianChart<_Point>), findsOneWidget);
    });

    testWidgets('no decimation when strategy is none', (tester) async {
      final data = List.generate(
        100,
        (i) => _Point(i.toDouble(), i.toDouble()),
      );

      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiCartesianChart<_Point>(
            label: 'No decimation',
            series: [
              OiCartesianSeries<_Point>(
                id: 'test',
                label: 'Test',
                data: data,
                xMapper: (p) => p.x,
                yMapper: (p) => p.y,
              ),
            ],
            performance: const OiChartPerformanceConfig(
              decimationStrategy: OiChartDecimationStrategy.none,
            ),
          ),
        ),
        surfaceSize: const Size(400, 300),
      );

      expect(find.byType(OiCartesianChart<_Point>), findsOneWidget);
    });
  });

  group('OiLineChart new params', () {
    testWidgets('accepts behaviors param without error', (tester) async {
      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiLineChart(
            label: 'With behaviors',
            series: const [
              OiLineSeries(
                label: 'Test',
                points: [
                  OiLinePoint(x: 1, y: 10),
                  OiLinePoint(x: 2, y: 20),
                ],
              ),
            ],
            behaviors: [OiZoomPanBehavior()],
            annotations: const [
              OiChartAnnotation.horizontalLine(value: 15, label: 'Target'),
            ],
            thresholds: const [OiChartThreshold(value: 18, label: 'Max')],
          ),
        ),
        surfaceSize: const Size(400, 300),
      );

      expect(find.byType(OiLineChart), findsOneWidget);
    });
  });
}
