import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  const processor = OiBarChartDataProcessor();

  group('OiBarChartDataProcessor.computeBarRects', () {
    test('returns empty list for empty data', () {
      final result = processor.computeBarRects(
        OiChartData.empty,
        const Size(400, 300),
      );
      expect(result, isEmpty);
    });

    test('returns correct number of rect lists for single series', () {
      final data = createSampleBarData();
      final result = processor.computeBarRects(data, const Size(400, 300));

      expect(result.length, 1); // 1 series
      expect(result[0].length, 4); // 4 categories
    });

    test('returns correct rect count for multi-series', () {
      final data = createSampleBarData(categories: 3, series: 2);
      final result = processor.computeBarRects(data, const Size(400, 300));

      expect(result.length, 2); // 2 series
      expect(result[0].length, 3); // 3 categories each
      expect(result[1].length, 3);
    });

    test('rects are within chart area', () {
      final data = createSampleBarData();
      const padding = OiChartPadding();
      final result = processor.computeBarRects(data, const Size(400, 300));

      for (final seriesRects in result) {
        for (final rect in seriesRects) {
          expect(rect.left, greaterThanOrEqualTo(padding.left));
          expect(rect.top, greaterThanOrEqualTo(padding.top));
          expect(rect.bottom, lessThanOrEqualTo(300 - padding.bottom));
        }
      }
    });

    test('horizontal orientation produces horizontal bars', () {
      final data = createSampleBarData(categories: 3);
      final result = processor.computeBarRects(
        data,
        const Size(400, 300),
        orientation: OiBarChartOrientation.horizontal,
      );

      expect(result.length, 1);
      // Horizontal bars start from the left edge.
      for (final rect in result[0]) {
        expect(rect.left, equals(48.0)); // Default left padding.
      }
    });

    test('spacing parameter affects bar positions', () {
      final data = createSampleBarData();
      final result1 = processor.computeBarRects(
        data,
        const Size(400, 300),
        spacing: 4,
      );
      final result2 = processor.computeBarRects(
        data,
        const Size(400, 300),
        spacing: 16,
      );

      // Different spacing should produce different bar widths.
      expect(result1[0][0].width, isNot(result2[0][0].width));
    });

    test('handles single category', () {
      final data = createSampleBarData(categories: 1);
      final result = processor.computeBarRects(data, const Size(400, 300));

      expect(result.length, 1);
      expect(result[0].length, 1);
      expect(result[0][0].width, greaterThan(0));
      expect(result[0][0].height, greaterThan(0));
    });

    test('all rects have positive dimensions', () {
      final data = createSampleBarData(categories: 5, series: 3);
      final result = processor.computeBarRects(data, const Size(400, 300));

      for (final seriesRects in result) {
        for (final rect in seriesRects) {
          expect(rect.width, greaterThan(0));
          expect(rect.height, greaterThanOrEqualTo(0));
        }
      }
    });
  });
}
