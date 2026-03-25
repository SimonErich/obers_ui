import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import '../../helpers/pump_chart_app.dart';

class _Point {
  const _Point(this.x, this.y);
  final double x;
  final double y;
}

OiCartesianSeries<_Point> _makeSeries({
  String id = 'series',
  List<_Point>? data,
}) {
  return OiCartesianSeries<_Point>(
    id: id,
    label: id,
    data: data ?? const [_Point(1, 10), _Point(2, 20), _Point(3, 30)],
    xMapper: (p) => p.x,
    yMapper: (p) => p.y,
  );
}

void main() {
  group('OiCartesianChart integration', () {
    testWidgets('multi-series render: 2 series with different data render '
        'without error', (tester) async {
      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiCartesianChart<_Point>(
            label: 'Multi-series chart',
            series: [
              _makeSeries(id: 'a', data: const [_Point(1, 10), _Point(2, 20)]),
              _makeSeries(
                id: 'b',
                data: const [_Point(1, 5), _Point(2, 15), _Point(3, 25)],
              ),
            ],
          ),
        ),
        surfaceSize: const Size(400, 300),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(OiCartesianChart<_Point>), findsOneWidget);
    });

    testWidgets('error state: controller with error shows OiChartErrorState', (
      tester,
    ) async {
      final controller = OiDefaultChartController()
        ..setError('Something went wrong');

      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiCartesianChart<_Point>(
            label: 'Error chart',
            series: [_makeSeries()],
            controller: controller,
          ),
        ),
        surfaceSize: const Size(400, 300),
      );

      expect(find.byType(OiChartErrorState), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);

      controller.dispose();
    });

    testWidgets(
      'loading state: controller with isLoading shows OiChartLoadingState',
      (tester) async {
        final controller = OiDefaultChartController()
          ..setLoading(loading: true);

        await tester.pumpChartApp(
          SizedBox(
            width: 400,
            height: 300,
            child: OiCartesianChart<_Point>(
              label: 'Loading chart',
              series: [_makeSeries()],
              controller: controller,
            ),
          ),
          surfaceSize: const Size(400, 300),
        );

        expect(find.byType(OiChartLoadingState), findsOneWidget);

        controller.dispose();
      },
    );

    testWidgets('empty data: series with empty list shows OiChartEmptyState', (
      tester,
    ) async {
      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiCartesianChart<_Point>(
            label: 'Empty chart',
            series: [_makeSeries(id: 'empty', data: const [])],
          ),
        ),
        surfaceSize: const Size(400, 300),
      );

      expect(find.byType(OiChartEmptyState), findsOneWidget);
      expect(find.text('No data available'), findsOneWidget);
    });

    testWidgets('all series hidden via controller.toggleSeries shows '
        '"All series are hidden"', (tester) async {
      final controller = OiDefaultChartController()
        ..toggleSeries('a')
        ..toggleSeries('b');

      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiCartesianChart<_Point>(
            label: 'Hidden chart',
            series: [
              _makeSeries(id: 'a'),
              _makeSeries(id: 'b'),
            ],
            controller: controller,
          ),
        ),
        surfaceSize: const Size(400, 300),
      );

      expect(find.text('All series are hidden'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('error recovery: controller error then clear error + add data '
        'renders chart', (tester) async {
      final controller = OiDefaultChartController()
        ..setError('Network failure');

      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiCartesianChart<_Point>(
            label: 'Recovering chart',
            series: [_makeSeries()],
            controller: controller,
          ),
        ),
        surfaceSize: const Size(400, 300),
      );

      expect(find.byType(OiChartErrorState), findsOneWidget);

      // Clear the error then re-pump the widget tree; the chart should now
      // render normally without the error state.
      controller.setError(null);
      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiCartesianChart<_Point>(
            label: 'Recovering chart',
            series: [_makeSeries()],
            controller: controller,
          ),
        ),
        surfaceSize: const Size(400, 300),
      );

      expect(find.byType(OiChartErrorState), findsNothing);
      expect(find.byType(OiCartesianChart<_Point>), findsOneWidget);

      controller.dispose();
    });
  });
}
