
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import '../../helpers/pump_chart_app.dart';

void main() {
  group('computeBins', () {
    test('produces correct bin count for uniform data', () {
      final values = List.generate(100, (i) => i.toDouble());
      final bins = computeBins(values, binCount: 10);
      expect(bins.length, 10);
    });

    test('bin frequencies sum to total count', () {
      final values = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0];
      final bins = computeBins(values, binCount: 5);
      final totalCount = bins.fold<int>(0, (sum, b) => sum + b.count);
      expect(totalCount, values.length);
    });

    test('normalized frequencies sum to approximately 1.0', () {
      final values = List.generate(50, (i) => i * 2.0);
      final bins = computeBins(values, binCount: 5);
      final totalFreq = bins.fold<double>(0, (sum, b) => sum + b.frequency);
      expect(totalFreq, closeTo(1.0, 0.01));
    });

    test('single value produces single bin', () {
      final bins = computeBins([42.0], binCount: 5);
      expect(bins.length, greaterThanOrEqualTo(1));
      expect(bins.first.count, 1);
    });

    test('empty values produces empty bins', () {
      final bins = computeBins([], binCount: 5);
      expect(bins, isEmpty);
    });
  });

  group('OiHistogram widget', () {
    testWidgets('renders with series data', (tester) async {
      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiHistogram<double>(
            label: 'Ages',
            series: [
              OiHistogramSeries<double>(
                id: 'ages',
                label: 'Ages',
                data: List.generate(50, (i) => i * 1.5),
                valueMapper: (v) => v,
                binCount: 8,
              ),
            ],
          ),
        ),
        surfaceSize: const Size(400, 300),
      );
      expect(find.byType(OiHistogram<double>), findsOneWidget);
    });

    testWidgets('fromValues renders without error', (tester) async {
      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiHistogram.fromValues(
            label: 'Distribution',
            values: [10, 20, 30, 40, 50, 20, 30, 25, 35, 45],
            binCount: 5,
          ),
        ),
        surfaceSize: const Size(400, 300),
      );
      expect(find.byType(OiHistogram<double>), findsOneWidget);
    });
  });
}
