import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

class _SalesPoint {
  const _SalesPoint(this.month, this.revenue);
  final double month;
  final double revenue;
}

void main() {
  group('OiLineSeriesData (mapper-first)', () {
    test('extracts x and y values via mappers', () {
      final series = OiLineSeriesData<_SalesPoint>(
        id: 'revenue',
        label: 'Revenue',
        data: const [
          _SalesPoint(1, 100),
          _SalesPoint(2, 200),
          _SalesPoint(3, 300),
        ],
        xMapper: (p) => p.month,
        yMapper: (p) => p.revenue,
      );

      expect(series.xMapper(series.data![0]), 1.0);
      expect(series.yMapper(series.data![1]), 200.0);
      expect(series.data!.length, 3);
    });

    test('defaults are sensible', () {
      final series = OiLineSeriesData<_SalesPoint>(
        id: 's1',
        label: 'S1',
        data: const [_SalesPoint(1, 10)],
        xMapper: (p) => p.month,
        yMapper: (p) => p.revenue,
      );

      expect(series.interpolation, OiLineChartMode.straight);
      expect(series.missingValueBehavior, OiLineMissingValueBehavior.gap);
      expect(series.showLine, isTrue);
      expect(series.showMarkers, isFalse);
      expect(series.showDataLabels, isFalse);
      expect(series.fillBelow, isFalse);
      expect(series.visible, isTrue);
    });

    test('isMissing mapper detects missing points', () {
      final series = OiLineSeriesData<_SalesPoint>(
        id: 's1',
        label: 'S1',
        data: const [
          _SalesPoint(1, 100),
          _SalesPoint(2, -1),
          _SalesPoint(3, 300),
        ],
        xMapper: (p) => p.month,
        yMapper: (p) => p.revenue,
        isMissing: (p) => p.revenue < 0,
      );

      expect(series.isMissing!(series.data![0]), isFalse);
      expect(series.isMissing!(series.data![1]), isTrue);
      expect(series.isMissing!(series.data![2]), isFalse);
    });
  });

  group('OiLineMissingValueBehavior', () {
    test('has all four modes', () {
      expect(OiLineMissingValueBehavior.values.length, 4);
      expect(OiLineMissingValueBehavior.gap, isNotNull);
      expect(OiLineMissingValueBehavior.connect, isNotNull);
      expect(OiLineMissingValueBehavior.zero, isNotNull);
      expect(OiLineMissingValueBehavior.interpolate, isNotNull);
    });
  });

  group('OiChartMarkerStyle.hidden()', () {
    test('creates invisible marker', () {
      const marker = OiChartMarkerStyle.hidden();
      expect(marker.visible, isFalse);
      expect(marker.size, 0);
    });
  });
}
