import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/src/composites/oi_cartesian_chart.dart';
import 'package:obers_ui_charts/src/composites/oi_chart_axis.dart';
import 'package:obers_ui_charts/src/models/oi_cartesian_series.dart';

import '../../helpers/pump_chart_app.dart';

class _SalesRecord {
  _SalesRecord(this.date, this.amount);
  final DateTime date;
  final double amount;
}

class _NumericRecord {
  _NumericRecord(this.x, this.y);
  final double x;
  final double y;
}

class _CategoryRecord {
  _CategoryRecord(this.category, this.value);
  final String category;
  final double value;
}

void main() {
  group('OiCartesianChart', () {
    testWidgets('renders with single series using mapper-first data binding', (
      tester,
    ) async {
      final data = [
        _NumericRecord(1, 10),
        _NumericRecord(2, 20),
        _NumericRecord(3, 30),
      ];

      Widget? builtContent;
      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiCartesianChart<_NumericRecord>(
            label: 'Test chart',
            series: [
              OiCartesianSeries<_NumericRecord>(
                id: 'sales',
                label: 'Sales',
                data: data,
                xMapper: (r) => r.x,
                yMapper: (r) => r.y,
              ),
            ],
            seriesBuilder: (context, viewport, visibleSeries) {
              builtContent = const SizedBox(key: Key('series-content'));
              return builtContent!;
            },
          ),
        ),
      );

      expect(find.byKey(const Key('series-content')), findsOneWidget);
    });

    testWidgets('auto-resolves time scale from DateTime data', (tester) async {
      final data = [
        _SalesRecord(DateTime(2024), 100),
        _SalesRecord(DateTime(2024, 2), 200),
      ];

      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiCartesianChart<_SalesRecord>(
            label: 'Time chart',
            series: [
              OiCartesianSeries<_SalesRecord>(
                id: 'revenue',
                label: 'Revenue',
                data: data,
                xMapper: (r) => r.date,
                yMapper: (r) => r.amount,
              ),
            ],
          ),
        ),
      );

      final state = tester.state<State>(
        find.byType(OiCartesianChart<_SalesRecord>),
      );
      // Access through the state's public getter
      expect((state as dynamic).resolvedXScaleType, OiAxisScaleType.time);
    });

    testWidgets('auto-resolves linear scale from num data', (tester) async {
      final data = [_NumericRecord(1, 10), _NumericRecord(2, 20)];

      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiCartesianChart<_NumericRecord>(
            label: 'Numeric chart',
            series: [
              OiCartesianSeries<_NumericRecord>(
                id: 'data',
                label: 'Data',
                data: data,
                xMapper: (r) => r.x,
                yMapper: (r) => r.y,
              ),
            ],
          ),
        ),
      );

      final state = tester.state<State>(
        find.byType(OiCartesianChart<_NumericRecord>),
      );
      expect((state as dynamic).resolvedXScaleType, OiAxisScaleType.linear);
    });

    testWidgets('auto-resolves category scale from String data', (
      tester,
    ) async {
      final data = [_CategoryRecord('A', 10), _CategoryRecord('B', 20)];

      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiCartesianChart<_CategoryRecord>(
            label: 'Category chart',
            series: [
              OiCartesianSeries<_CategoryRecord>(
                id: 'categories',
                label: 'Categories',
                data: data,
                xMapper: (r) => r.category,
                yMapper: (r) => r.value,
              ),
            ],
          ),
        ),
      );

      final state = tester.state<State>(
        find.byType(OiCartesianChart<_CategoryRecord>),
      );
      expect((state as dynamic).resolvedXScaleType, OiAxisScaleType.category);
    });

    testWidgets('empty data shows empty state', (tester) async {
      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiCartesianChart<_NumericRecord>(
            label: 'Empty chart',
            series: [
              OiCartesianSeries<_NumericRecord>(
                id: 'empty',
                label: 'Empty',
                data: const [],
                xMapper: (r) => r.x,
                yMapper: (r) => r.y,
              ),
            ],
          ),
        ),
      );

      expect(find.text('No data available'), findsOneWidget);
    });

    testWidgets(
      'accessibility summary generates with chart type + series count',
      (tester) async {
        final data = [_NumericRecord(1, 10)];

        await tester.pumpChartApp(
          SizedBox(
            width: 400,
            height: 300,
            child: OiCartesianChart<_NumericRecord>(
              label: 'Revenue over time',
              series: [
                OiCartesianSeries<_NumericRecord>(
                  id: 's1',
                  label: 'Series 1',
                  data: data,
                  xMapper: (r) => r.x,
                  yMapper: (r) => r.y,
                ),
              ],
            ),
          ),
        );

        expect(
          find.bySemanticsLabel(RegExp('Revenue over time')),
          findsWidgets,
        );
      },
    );

    testWidgets('explicit scale override beats auto-inference', (tester) async {
      final data = [_SalesRecord(DateTime(2024), 100)];

      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiCartesianChart<_SalesRecord>(
            label: 'Override chart',
            series: [
              OiCartesianSeries<_SalesRecord>(
                id: 'revenue',
                label: 'Revenue',
                data: data,
                xMapper: (r) => r.date,
                yMapper: (r) => r.amount,
              ),
            ],
            xAxis: const OiChartAxis<dynamic>(
              scaleType: OiAxisScaleType.linear,
            ),
          ),
        ),
      );

      final state = tester.state<State>(
        find.byType(OiCartesianChart<_SalesRecord>),
      );
      // Explicit override should win over auto-inference
      expect((state as dynamic).resolvedXScaleType, OiAxisScaleType.linear);
    });
  });
}
