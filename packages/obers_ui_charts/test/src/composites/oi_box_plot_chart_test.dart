import 'dart:ui' show Size;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import '../../helpers/pump_chart_app.dart';

void main() {
  group('computeBoxPlotStats', () {
    test('computes correct quartiles for 1-10', () {
      final stats = computeBoxPlotStats([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
      expect(stats, isNotNull);
      expect(stats!.min, 1);
      expect(stats.max, 10);
      expect(stats.median, closeTo(5.5, 0.01));
      expect(stats.q1, closeTo(3, 0.5));
      expect(stats.q3, closeTo(8, 0.5));
    });

    test('detects outliers beyond 1.5×IQR', () {
      final stats = computeBoxPlotStats([
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        50,
      ], mode: OiWhiskerMode.iqr1_5);
      expect(stats, isNotNull);
      expect(stats!.outliers, isNotEmpty);
      expect(stats.outliers, contains(50));
    });

    test('single value produces degenerate stats', () {
      final stats = computeBoxPlotStats([42]);
      expect(stats, isNotNull);
      expect(stats!.min, 42);
      expect(stats.max, 42);
      expect(stats.median, 42);
    });

    test('empty values returns null', () {
      final stats = computeBoxPlotStats([]);
      expect(stats, isNull);
    });
  });

  group('OiBoxPlotChart widget', () {
    testWidgets('renders with pre-computed stats', (tester) async {
      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiBoxPlotChart<Map<String, dynamic>>(
            label: 'Salary Distribution',
            series: [
              OiBoxPlotSeries<Map<String, dynamic>>(
                id: 'salaries',
                label: 'Salaries',
                data: const [
                  {
                    'cat': 'Eng',
                    'min': 50,
                    'q1': 70,
                    'med': 85,
                    'q3': 100,
                    'max': 130,
                  },
                ],
                categoryMapper: (d) => d['cat'] as String,
                minMapper: (d) => d['min'] as num,
                q1Mapper: (d) => d['q1'] as num,
                medianMapper: (d) => d['med'] as num,
                q3Mapper: (d) => d['q3'] as num,
                maxMapper: (d) => d['max'] as num,
              ),
            ],
          ),
        ),
        surfaceSize: const Size(400, 300),
      );
      expect(find.byType(OiBoxPlotChart<Map<String, dynamic>>), findsOneWidget);
    });
  });
}
