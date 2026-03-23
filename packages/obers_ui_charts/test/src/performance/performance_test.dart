import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

/// Creates a large dataset with [pointCount] points per series and
/// [seriesCount] series.
OiChartData createLargeDataset({
  int pointCount = 1000,
  int seriesCount = 1,
}) {
  return OiChartData(
    series: List.generate(
      seriesCount,
      (si) => OiChartSeries(
        name: 'Series $si',
        dataPoints: List.generate(
          pointCount,
          (pi) => OiDataPoint(
            x: pi.toDouble(),
            y: (pi * (si + 1) % 100).toDouble(),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('Performance - OiChartData.bounds', () {
    test('computes bounds for 10,000 points efficiently', () {
      final data = createLargeDataset(pointCount: 10000);

      final stopwatch = Stopwatch()..start();
      final bounds = data.bounds;
      stopwatch.stop();

      expect(bounds.minX, 0);
      expect(bounds.maxX, 9999);
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('computes totalPoints for large dataset', () {
      final data = createLargeDataset(pointCount: 5000, seriesCount: 3);

      final stopwatch = Stopwatch()..start();
      final total = data.totalPoints;
      stopwatch.stop();

      expect(total, 15000);
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });
  });

  group('Performance - OiLineChartDataProcessor', () {
    test('interpolates 1,000 points into 5,000 efficiently', () {
      const processor = OiLineChartDataProcessor();
      final points = List.generate(
        1000,
        (i) => OiDataPoint(x: i.toDouble(), y: (i % 50).toDouble()),
      );

      final stopwatch = Stopwatch()..start();
      final result = processor.interpolate(points, 5000);
      stopwatch.stop();

      expect(result.length, 5001);
      expect(stopwatch.elapsedMilliseconds, lessThan(200));
    });

    test('computes control points for 1,000 points efficiently', () {
      const processor = OiLineChartDataProcessor();
      final points = List.generate(
        1000,
        (i) => OiDataPoint(x: i.toDouble(), y: (i % 50).toDouble()),
      );

      final stopwatch = Stopwatch()..start();
      final result = processor.computeControlPoints(points);
      stopwatch.stop();

      expect(result.length, 1998); // (1000-1) * 2
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });

  group('Performance - OiBarChartDataProcessor', () {
    test('computes bar rects for 100 categories x 5 series', () {
      const processor = OiBarChartDataProcessor();
      final data = createLargeDataset(pointCount: 100, seriesCount: 5);

      final stopwatch = Stopwatch()..start();
      final rects = processor.computeBarRects(data, const Size(1200, 800));
      stopwatch.stop();

      expect(rects.length, 5);
      expect(rects[0].length, 100);
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });

  group('Performance - OiPieChartDataProcessor', () {
    test('computes slices for 100 data points efficiently', () {
      const processor = OiPieChartDataProcessor();
      final series = OiChartSeries(
        name: 'Large',
        dataPoints: List.generate(
          100,
          (i) => OiDataPoint(x: i.toDouble(), y: (i + 1).toDouble()),
        ),
      );

      final stopwatch = Stopwatch()..start();
      final slices = processor.computeSlices(series);
      stopwatch.stop();

      expect(slices.length, 100);
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });
  });

  group('Performance - OiChartGestureHandler', () {
    test('hit tests against 10,000 points efficiently', () {
      final data = createLargeDataset(pointCount: 10000);
      final bounds = data.bounds;
      final handler = OiChartGestureHandler(
        data: data,
        bounds: bounds,
        hitTolerance: 10,
      );

      final stopwatch = Stopwatch()..start();
      final result = handler.hitTest(
        const Offset(200, 150),
        const Size(400, 300),
      );
      stopwatch.stop();

      // Result may or may not be found depending on tolerance, but should
      // not take long.
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
      // Just verify it returns something (or null) without crashing.
      expect(result, anyOf(isNull, isA<OiChartHitResult>()));
    });
  });

  group('Performance - painting large datasets', () {
    test('OiLineChartPainter paints 1,000 points without timeout', () {
      final data = createLargeDataset(pointCount: 1000);
      final theme = OiChartTheme.light();
      final painter = OiLineChartPainter(data: data, theme: theme);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      final stopwatch = Stopwatch()..start();
      painter.paint(canvas, const Size(800, 600));
      stopwatch.stop();
      recorder.endRecording();

      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    test('OiBarChartPainter paints 50 categories x 3 series', () {
      final data = createLargeDataset(pointCount: 50, seriesCount: 3);
      final theme = OiChartTheme.light();
      final painter = OiBarChartPainter(data: data, theme: theme);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      final stopwatch = Stopwatch()..start();
      painter.paint(canvas, const Size(800, 600));
      stopwatch.stop();
      recorder.endRecording();

      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    test('OiPieChartPainter paints 50 slices without timeout', () {
      final data = OiPolarData(
        segments: List.generate(
          50,
          (i) => OiPolarSegment(
            label: 'Slice $i',
            value: (i + 1).toDouble(),
          ),
        ),
      );
      final theme = OiChartTheme.light();
      final painter = OiPieChartPainter(data: data, theme: theme);

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      final stopwatch = Stopwatch()..start();
      painter.paint(canvas, const Size(600, 600));
      stopwatch.stop();
      recorder.endRecording();

      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });
  });
}
