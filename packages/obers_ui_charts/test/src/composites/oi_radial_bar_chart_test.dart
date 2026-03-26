import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import '../../helpers/pump_chart_app.dart';

void main() {
  group('OiRadialBarChart', () {
    final sampleSeries = OiRadialBarSeries<Map<String, dynamic>>(
      id: 'test',
      label: 'Test Series',
      data: [
        {'category': 'Alpha', 'value': 80.0},
        {'category': 'Beta', 'value': 55.0},
        {'category': 'Gamma', 'value': 30.0},
      ],
      categoryMapper: (item) => item['category'] as String,
      valueMapper: (item) => item['value'] as double,
    );

    testWidgets('renders with sample data (3 categories)', (tester) async {
      await tester.pumpChartApp(
        SizedBox(
          width: 300,
          height: 300,
          child: OiRadialBarChart<Map<String, dynamic>>(
            label: 'Radial Bar Chart',
            series: [sampleSeries],
          ),
        ),
        surfaceSize: const Size(400, 400),
      );

      expect(find.byKey(const Key('oi_radial_bar_chart')), findsOneWidget);
      expect(
        find.byKey(const Key('oi_radial_bar_chart_painter')),
        findsOneWidget,
      );
    });

    testWidgets('empty data shows empty state', (tester) async {
      final emptySeries = OiRadialBarSeries<Map<String, dynamic>>(
        id: 'empty',
        label: 'Empty Series',
        data: const [],
        categoryMapper: (item) => item['category'] as String,
        valueMapper: (item) => item['value'] as double,
      );

      await tester.pumpChartApp(
        SizedBox(
          width: 300,
          height: 300,
          child: OiRadialBarChart<Map<String, dynamic>>(
            label: 'Empty Radial Bar Chart',
            series: [emptySeries],
          ),
        ),
        surfaceSize: const Size(400, 400),
      );

      expect(
        find.byKey(const Key('oi_radial_bar_chart_empty')),
        findsOneWidget,
      );
    });

    testWidgets('renders in compact mode', (tester) async {
      await tester.pumpChartApp(
        SizedBox(
          width: 300,
          height: 300,
          child: OiRadialBarChart<Map<String, dynamic>>(
            label: 'Compact Radial Bar Chart',
            series: [sampleSeries],
            compact: true,
          ),
        ),
        surfaceSize: const Size(400, 400),
      );

      // In compact mode, chart renders but labels are hidden.
      expect(find.byKey(const Key('oi_radial_bar_chart')), findsOneWidget);
      expect(
        find.byKey(const Key('oi_radial_bar_chart_painter')),
        findsOneWidget,
      );
    });
  });
}
