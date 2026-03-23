import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

void main() {
  const processor = OiPieChartDataProcessor();

  group('OiPieChartDataProcessor.computeSlices', () {
    test('returns empty list for empty series', () {
      const series = OiChartSeries(name: 'Empty', dataPoints: []);
      final slices = processor.computeSlices(series);
      expect(slices, isEmpty);
    });

    test('single point produces full circle', () {
      const series = OiChartSeries(
        name: 'Single',
        dataPoints: [OiDataPoint(x: 0, y: 100)],
      );

      final slices = processor.computeSlices(series);

      expect(slices.length, 1);
      expect(slices[0].sweepAngle, closeTo(2 * math.pi, 0.001));
      expect(slices[0].percentage, closeTo(100, 0.001));
    });

    test('percentages sum to 100', () {
      const series = OiChartSeries(
        name: 'Test',
        dataPoints: [
          OiDataPoint(x: 0, y: 30),
          OiDataPoint(x: 1, y: 20),
          OiDataPoint(x: 2, y: 50),
        ],
      );

      final slices = processor.computeSlices(series);
      final totalPercentage = slices.fold<double>(
        0,
        (sum, s) => sum + s.percentage,
      );

      expect(totalPercentage, closeTo(100, 0.001));
    });

    test('sweep angles sum to 2*pi', () {
      const series = OiChartSeries(
        name: 'Test',
        dataPoints: [
          OiDataPoint(x: 0, y: 10),
          OiDataPoint(x: 1, y: 20),
          OiDataPoint(x: 2, y: 30),
          OiDataPoint(x: 3, y: 40),
        ],
      );

      final slices = processor.computeSlices(series);
      final totalAngle = slices.fold<double>(0, (sum, s) => sum + s.sweepAngle);

      expect(totalAngle, closeTo(2 * math.pi, 0.001));
    });

    test('first slice starts at -pi/2 (12 o clock)', () {
      const series = OiChartSeries(
        name: 'Test',
        dataPoints: [OiDataPoint(x: 0, y: 25), OiDataPoint(x: 1, y: 75)],
      );

      final slices = processor.computeSlices(series);
      expect(slices[0].startAngle, closeTo(-math.pi / 2, 0.001));
    });

    test('handles negative values as zero', () {
      const series = OiChartSeries(
        name: 'Test',
        dataPoints: [
          OiDataPoint(x: 0, y: -10),
          OiDataPoint(x: 1, y: 50),
          OiDataPoint(x: 2, y: 50),
        ],
      );

      final slices = processor.computeSlices(series);

      expect(slices[0].value, 0);
      expect(slices[0].sweepAngle, 0);
      expect(slices[1].percentage, closeTo(50, 0.001));
      expect(slices[2].percentage, closeTo(50, 0.001));
    });

    test('all-zero values produce equal slices', () {
      const series = OiChartSeries(
        name: 'Zeros',
        dataPoints: [
          OiDataPoint(x: 0, y: 0),
          OiDataPoint(x: 1, y: 0),
          OiDataPoint(x: 2, y: 0),
        ],
      );

      final slices = processor.computeSlices(series);

      expect(slices.length, 3);
      const expectedAngle = (2 * math.pi) / 3;

      for (final slice in slices) {
        expect(slice.sweepAngle, closeTo(expectedAngle, 0.001));
        expect(slice.percentage, closeTo(100.0 / 3, 0.01));
      }
    });

    test('preserves labels from data points', () {
      const series = OiChartSeries(
        name: 'Labeled',
        dataPoints: [
          OiDataPoint(x: 0, y: 50, label: 'Alpha'),
          OiDataPoint(x: 1, y: 50, label: 'Beta'),
        ],
      );

      final slices = processor.computeSlices(series);

      expect(slices[0].label, 'Alpha');
      expect(slices[1].label, 'Beta');
    });

    test('correct proportional slices', () {
      const series = OiChartSeries(
        name: 'Proportional',
        dataPoints: [OiDataPoint(x: 0, y: 25), OiDataPoint(x: 1, y: 75)],
      );

      final slices = processor.computeSlices(series);

      expect(slices[0].percentage, closeTo(25, 0.001));
      expect(slices[0].sweepAngle, closeTo(math.pi / 2, 0.001));

      expect(slices[1].percentage, closeTo(75, 0.001));
      expect(slices[1].sweepAngle, closeTo(3 * math.pi / 2, 0.001));
    });
  });

  group('OiPieSlice', () {
    test('equality compares all fields', () {
      const a = OiPieSlice(
        startAngle: 0,
        sweepAngle: 1,
        value: 10,
        percentage: 50,
        label: 'A',
      );
      const b = OiPieSlice(
        startAngle: 0,
        sweepAngle: 1,
        value: 10,
        percentage: 50,
        label: 'A',
      );
      const c = OiPieSlice(
        startAngle: 0,
        sweepAngle: 2,
        value: 10,
        percentage: 50,
        label: 'A',
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('hashCode is consistent', () {
      const a = OiPieSlice(
        startAngle: 0,
        sweepAngle: 1,
        value: 10,
        percentage: 50,
      );
      const b = OiPieSlice(
        startAngle: 0,
        sweepAngle: 1,
        value: 10,
        percentage: 50,
      );

      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
