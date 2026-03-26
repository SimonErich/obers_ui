import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import '../../helpers/pump_chart_app.dart';

void main() {
  group('OiKpiBoard', () {
    List<OiKpiMetric> buildMetrics(int count) => List.generate(
      count,
      (i) => OiKpiMetric(
        id: 'metric-$i',
        title: 'Metric $i',
        value: (i + 1) * 100,
      ),
    );

    testWidgets('renders correct number of children for metrics count', (
      tester,
    ) async {
      const metricCount = 3;
      final metrics = buildMetrics(metricCount);

      await tester.pumpChartApp(
        SizedBox(
          width: 800,
          height: 400,
          child: OiKpiBoard(label: 'KPI Board', metrics: metrics),
        ),
        surfaceSize: const Size(900, 500),
      );

      // Each metric gets a keyed OiKpiCard.
      for (var i = 0; i < metricCount; i++) {
        expect(find.byKey(Key('oi_kpi_card_metric-$i')), findsOneWidget);
      }
    });

    testWidgets('empty metrics shows empty state', (tester) async {
      await tester.pumpChartApp(
        const SizedBox(
          width: 800,
          height: 400,
          child: OiKpiBoard(label: 'Empty KPI Board', metrics: []),
        ),
        surfaceSize: const Size(900, 500),
      );

      expect(find.byKey(const Key('oi_kpi_board_empty')), findsOneWidget);
    });

    test('OiKpiMetric deltaPercent computes (100 - 80) / 80 * 100 = 25%', () {
      const metric = OiKpiMetric(
        id: 'delta-test',
        title: 'Delta Test',
        value: 100,
        previousValue: 80,
      );

      final delta = metric.deltaPercent;
      expect(delta, isNotNull);
      expect(delta, closeTo(25.0, 0.001));
    });
  });
}
