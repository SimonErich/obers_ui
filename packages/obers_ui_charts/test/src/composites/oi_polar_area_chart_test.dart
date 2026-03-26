import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import '../../helpers/pump_chart_app.dart';

void main() {
  group('OiPolarAreaChart', () {
    final sampleSeries = OiPolarAreaSeries<Map<String, dynamic>>(
      id: 'sales',
      label: 'Sales',
      data: [
        {'category': 'North', 'value': 120.0},
        {'category': 'South', 'value': 80.0},
        {'category': 'East', 'value': 200.0},
        {'category': 'West', 'value': 150.0},
      ],
      categoryMapper: (item) => item['category'] as String,
      valueMapper: (item) => item['value'] as double,
    );

    testWidgets('renders with sample data', (tester) async {
      await tester.pumpChartApp(
        SizedBox(
          width: 300,
          height: 400,
          child: OiPolarAreaChart<Map<String, dynamic>>(
            label: 'Polar Area Chart',
            series: [sampleSeries],
          ),
        ),
        surfaceSize: const Size(400, 600),
      );

      expect(find.byKey(const Key('oi_polar_area_chart')), findsOneWidget);
      expect(
        find.byKey(const Key('oi_polar_area_chart_painter')),
        findsOneWidget,
      );
    });

    testWidgets('empty data handled gracefully', (tester) async {
      await tester.pumpChartApp(
        const SizedBox(
          width: 300,
          height: 300,
          child: OiPolarAreaChart<Map<String, dynamic>>(
            label: 'Empty Polar Area Chart',
            series: [],
          ),
        ),
        surfaceSize: const Size(400, 400),
      );

      expect(
        find.byKey(const Key('oi_polar_area_chart_empty')),
        findsOneWidget,
      );
    });

    testWidgets('renders in compact mode', (tester) async {
      await tester.pumpChartApp(
        SizedBox(
          width: 300,
          height: 300,
          child: OiPolarAreaChart<Map<String, dynamic>>(
            label: 'Compact Polar Area Chart',
            series: [sampleSeries],
            compact: true,
          ),
        ),
        surfaceSize: const Size(400, 400),
      );

      // In compact mode the chart renders without labels or legend.
      expect(find.byKey(const Key('oi_polar_area_chart')), findsOneWidget);
      // Legend should not appear in compact mode.
      expect(find.byKey(const Key('oi_polar_area_chart_legend')), findsNothing);
    });
  });
}
