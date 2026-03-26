import 'dart:ui' show Size;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import '../../helpers/pump_chart_app.dart';

class _TempReading {
  const _TempReading(this.day, this.low, this.high, this.avg);
  final double day;
  final double low;
  final double high;
  final double avg;
}

class _Project {
  const _Project(this.name, this.start, this.end);
  final String name;
  final double start;
  final double end;
}

void main() {
  group('OiRangeAreaChart', () {
    testWidgets('renders range fill', (tester) async {
      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiRangeAreaChart<_TempReading>(
            label: 'Temperature',
            series: [
              OiRangeAreaSeries<_TempReading>(
                id: 'temp',
                label: 'Temperature',
                data: const [
                  _TempReading(1, 10, 25, 18),
                  _TempReading(2, 12, 28, 20),
                  _TempReading(3, 8, 22, 15),
                ],
                xMapper: (r) => r.day,
                yMinMapper: (r) => r.low,
                yMaxMapper: (r) => r.high,
                midLineMapper: (r) => r.avg,
              ),
            ],
          ),
        ),
        surfaceSize: const Size(400, 300),
      );
      expect(find.byType(OiRangeAreaChart<_TempReading>), findsOneWidget);
    });

    testWidgets('empty data renders empty state', (tester) async {
      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiRangeAreaChart<_TempReading>(
            label: 'Empty',
            series: [
              OiRangeAreaSeries<_TempReading>(
                id: 'empty',
                label: 'Empty',
                data: const [],
                xMapper: (r) => r.day,
                yMinMapper: (r) => r.low,
                yMaxMapper: (r) => r.high,
              ),
            ],
          ),
        ),
        surfaceSize: const Size(400, 300),
      );
      expect(find.byType(OiRangeAreaChart<_TempReading>), findsOneWidget);
    });
  });

  group('OiRangeBarChart', () {
    testWidgets('renders horizontal bars', (tester) async {
      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiRangeBarChart<_Project>(
            label: 'Timeline',
            series: [
              OiRangeBarSeries<_Project>(
                id: 'projects',
                label: 'Projects',
                data: const [
                  _Project('Alpha', 1, 5),
                  _Project('Beta', 3, 8),
                  _Project('Gamma', 6, 10),
                ],
                categoryMapper: (p) => p.name,
                startMapper: (p) => p.start,
                endMapper: (p) => p.end,
              ),
            ],
          ),
        ),
        surfaceSize: const Size(400, 300),
      );
      expect(find.byType(OiRangeBarChart<_Project>), findsOneWidget);
    });

    testWidgets('empty data shows empty state', (tester) async {
      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiRangeBarChart<_Project>(
            label: 'Empty',
            series: [
              OiRangeBarSeries<_Project>(
                id: 'empty',
                label: 'Empty',
                data: const [],
                categoryMapper: (p) => p.name,
                startMapper: (p) => p.start,
                endMapper: (p) => p.end,
              ),
            ],
          ),
        ),
        surfaceSize: const Size(400, 300),
      );
      expect(find.byType(OiRangeBarChart<_Project>), findsOneWidget);
    });
  });
}
