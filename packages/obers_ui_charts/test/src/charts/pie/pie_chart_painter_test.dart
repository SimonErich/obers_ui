import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  late OiChartTheme theme;

  setUp(() {
    theme = OiChartTheme.light();
  });

  group('OiPieChartPainter', () {
    test('creates painter with required parameters', () {
      final data = createSamplePieData();
      final painter = OiPieChartPainter(data: data, theme: theme);

      expect(painter.data, data);
      expect(painter.theme, theme);
      expect(painter.holeRadius, 0);
    });

    test('creates donut painter with holeRadius', () {
      final data = createSamplePieData();
      final painter = OiPieChartPainter(
        data: data,
        theme: theme,
        holeRadius: 0.5,
      );

      expect(painter.holeRadius, 0.5);
    });

    test('paints without error on valid data', () {
      final data = createSamplePieData();
      final painter = OiPieChartPainter(data: data, theme: theme);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      painter.paint(canvas, const Size(400, 300));
      recorder.endRecording();
    });

    test('paints without error on empty data', () {
      final painter = OiPieChartPainter(data: OiChartData.empty, theme: theme);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      painter.paint(canvas, const Size(400, 300));
      recorder.endRecording();
    });

    test('skips painting on zero-size canvas', () {
      final data = createSamplePieData();
      final painter = OiPieChartPainter(data: data, theme: theme);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      painter.paint(canvas, Size.zero);
      recorder.endRecording();
    });

    test('shouldRepaint returns true when data changes', () {
      final data1 = createSamplePieData(slices: 3);
      final data2 = createSamplePieData(slices: 5);

      final painter1 = OiPieChartPainter(data: data1, theme: theme);
      final painter2 = OiPieChartPainter(data: data2, theme: theme);

      expect(painter2.shouldRepaint(painter1), isTrue);
    });

    test('paints single slice as full circle', () {
      final data = createSamplePieData(slices: 1);
      final painter = OiPieChartPainter(data: data, theme: theme);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      // Should not throw.
      painter.paint(canvas, const Size(300, 300));
      recorder.endRecording();
    });

    test('paints donut with hole', () {
      final data = createSamplePieData();
      final painter = OiPieChartPainter(
        data: data,
        theme: theme,
        holeRadius: 0.4,
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      painter.paint(canvas, const Size(300, 300));
      recorder.endRecording();
    });
  });

  group('OiPieChartPainter slice angles', () {
    test('all slice sweep angles sum to 2*pi', () {
      const processor = OiPieChartDataProcessor();
      const series = OiChartSeries(
        name: 'Test',
        dataPoints: [
          OiDataPoint(x: 0, y: 25),
          OiDataPoint(x: 1, y: 25),
          OiDataPoint(x: 2, y: 25),
          OiDataPoint(x: 3, y: 25),
        ],
      );

      final slices = processor.computeSlices(series);
      final totalAngle = slices.fold<double>(0, (sum, s) => sum + s.sweepAngle);

      expect(totalAngle, closeTo(2 * math.pi, 0.001));
    });
  });
}
