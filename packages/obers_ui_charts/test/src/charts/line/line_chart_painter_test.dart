import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  late OiChartTheme theme;

  setUp(() {
    theme = OiChartTheme.light();
  });

  group('OiLineChartPainter', () {
    test('creates painter with required parameters', () {
      final data = createSampleLineData();
      final painter = OiLineChartPainter(data: data, theme: theme);

      expect(painter.data, data);
      expect(painter.theme, theme);
      expect(painter.strokeWidth, 2);
      expect(painter.pointRadius, 4);
      expect(painter.showPoints, isTrue);
    });

    test('shouldRepaint returns true when data changes', () {
      final data1 = createSampleLineData(points: 3);
      final data2 = createSampleLineData();

      final painter1 = OiLineChartPainter(data: data1, theme: theme);
      final painter2 = OiLineChartPainter(data: data2, theme: theme);

      expect(painter2.shouldRepaint(painter1), isTrue);
    });

    test('shouldRepaint returns false for identical data', () {
      final data = createSampleLineData();

      final painter1 = OiLineChartPainter(data: data, theme: theme);
      final painter2 = OiLineChartPainter(data: data, theme: theme);

      expect(painter2.shouldRepaint(painter1), isFalse);
    });

    test('paints without error on valid data', () {
      final data = createSampleLineData(series: 2);
      final painter = OiLineChartPainter(data: data, theme: theme);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      // Should not throw.
      painter.paint(canvas, const Size(400, 300));
      recorder.endRecording();
    });

    test('paints without error on empty data', () {
      final painter = OiLineChartPainter(data: OiChartData.empty, theme: theme);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      // Should not throw.
      painter.paint(canvas, const Size(400, 300));
      recorder.endRecording();
    });

    test('skips painting on zero-size canvas', () {
      final data = createSampleLineData();
      final painter = OiLineChartPainter(data: data, theme: theme);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      // Should not throw.
      painter.paint(canvas, Size.zero);
      recorder.endRecording();
    });

    test('uses series color override when provided', () {
      const data = OiChartData(
        series: [
          OiChartSeries(
            name: 'Custom',
            dataPoints: [OiDataPoint(x: 0, y: 0), OiDataPoint(x: 1, y: 1)],
            color: Color(0xFFFF0000),
          ),
        ],
      );

      final painter = OiLineChartPainter(data: data, theme: theme);

      // Just verify creation doesn't crash; color is applied during paint.
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      painter.paint(canvas, const Size(400, 300));
      recorder.endRecording();
    });

    test('respects showPoints flag', () {
      final data = createSampleLineData();
      final painter = OiLineChartPainter(
        data: data,
        theme: theme,
        showPoints: false,
      );

      expect(painter.showPoints, isFalse);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      painter.paint(canvas, const Size(400, 300));
      recorder.endRecording();
    });
  });
}
