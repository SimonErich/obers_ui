import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  late OiChartTheme theme;

  setUp(() {
    theme = OiChartTheme.light();
  });

  group('OiBarChartPainter', () {
    test('creates painter with required parameters', () {
      final data = createSampleBarData();
      final painter = OiBarChartPainter(data: data, theme: theme);

      expect(painter.data, data);
      expect(painter.theme, theme);
      expect(painter.barSpacing, 8);
      expect(painter.orientation, OiBarChartOrientation.vertical);
    });

    test('shouldRepaint returns true when data changes', () {
      final data1 = createSampleBarData(categories: 3);
      final data2 = createSampleBarData(categories: 5);

      final painter1 = OiBarChartPainter(data: data1, theme: theme);
      final painter2 = OiBarChartPainter(data: data2, theme: theme);

      expect(painter2.shouldRepaint(painter1), isTrue);
    });

    test('paints without error on valid data', () {
      final data = createSampleBarData(series: 2);
      final painter = OiBarChartPainter(data: data, theme: theme);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      painter.paint(canvas, const Size(400, 300));
      recorder.endRecording();
    });

    test('paints without error on empty data', () {
      final painter = OiBarChartPainter(data: OiChartData.empty, theme: theme);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      painter.paint(canvas, const Size(400, 300));
      recorder.endRecording();
    });

    test('skips painting on zero-size canvas', () {
      final data = createSampleBarData();
      final painter = OiBarChartPainter(data: data, theme: theme);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      painter.paint(canvas, Size.zero);
      recorder.endRecording();
    });

    test('supports horizontal orientation painting', () {
      final data = createSampleBarData();
      final painter = OiBarChartPainter(
        data: data,
        theme: theme,
        orientation: OiBarChartOrientation.horizontal,
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      painter.paint(canvas, const Size(400, 300));
      recorder.endRecording();
    });

    test('applies custom bar spacing', () {
      final data = createSampleBarData();
      final painter = OiBarChartPainter(
        data: data,
        theme: theme,
        barSpacing: 16,
      );

      expect(painter.barSpacing, 16);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      painter.paint(canvas, const Size(400, 300));
      recorder.endRecording();
    });

    test('applies custom bar radius', () {
      final data = createSampleBarData();
      final painter = OiBarChartPainter(data: data, theme: theme, barRadius: 0);

      expect(painter.barRadius, 0);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      painter.paint(canvas, const Size(400, 300));
      recorder.endRecording();
    });
  });
}
