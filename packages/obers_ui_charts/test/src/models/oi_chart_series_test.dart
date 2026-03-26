import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/src/foundation/oi_streaming_data_source.dart';
import 'package:obers_ui_charts/src/models/oi_cartesian_series.dart';
import 'package:obers_ui_charts/src/models/oi_chart_datum.dart';

class _SalesRecord {
  const _SalesRecord(this.date, this.amount);
  final DateTime date;
  final double amount;
}

class _FakeSource extends OiStreamingDataSource<_SalesRecord> {
  @override
  Stream<List<_SalesRecord>> get dataStream =>
      StreamController<List<_SalesRecord>>.broadcast().stream;

  @override
  int get maxRetainedPoints => 100;
}

void main() {
  group('OiChartSeries', () {
    test('validates data/streamingData mutual exclusivity', () {
      // Both provided → error
      expect(
        () => OiCartesianSeries<_SalesRecord>(
          id: 'test',
          label: 'Test',
          data: const [],
          streamingSource: _FakeSource(),
          xMapper: (r) => r.date,
          yMapper: (r) => r.amount,
        ),
        throwsArgumentError,
      );

      // Neither provided → error
      expect(
        () => OiCartesianSeries<_SalesRecord>(
          id: 'test',
          label: 'Test',
          xMapper: (r) => r.date,
          yMapper: (r) => r.amount,
        ),
        throwsArgumentError,
      );

      // Only data → OK
      expect(
        () => OiCartesianSeries<_SalesRecord>(
          id: 'test',
          label: 'Test',
          data: const [],
          xMapper: (r) => r.date,
          yMapper: (r) => r.amount,
        ),
        returnsNormally,
      );

      // Only streaming → OK
      expect(
        () => OiCartesianSeries<_SalesRecord>(
          id: 'test',
          label: 'Test',
          streamingSource: _FakeSource(),
          xMapper: (r) => r.date,
          yMapper: (r) => r.amount,
        ),
        returnsNormally,
      );
    });
  });

  group('OiCartesianSeries', () {
    test('mapper extraction produces correct x/y from domain model', () {
      final data = [
        _SalesRecord(DateTime(2024, 1, 1), 100),
        _SalesRecord(DateTime(2024, 2, 1), 250),
        _SalesRecord(DateTime(2024, 3, 1), 180),
      ];

      final series = OiCartesianSeries<_SalesRecord>(
        id: 'revenue',
        label: 'Revenue',
        data: data,
        xMapper: (r) => r.date,
        yMapper: (r) => r.amount,
        pointLabel: (r) => '\$${r.amount}',
      );

      expect(series.xMapper(data[0]), DateTime(2024, 1, 1));
      expect(series.yMapper(data[1]), 250.0);
      expect(series.pointLabel!(data[2]), '\$180.0');
    });
  });

  group('OiChartDatum', () {
    test(
      'normalization from series via mappers produces correct datum list',
      () {
        final data = [
          _SalesRecord(DateTime(2024, 1, 1), 100),
          _SalesRecord(DateTime(2024, 2, 1), 250),
        ];

        final datums = normalizeSeries<_SalesRecord>(
          seriesId: 'revenue',
          data: data,
          xMapper: (r) => r.date,
          yMapper: (r) => r.amount,
          pointLabel: (r) => '\$${r.amount}',
        );

        expect(datums.length, 2);
        expect(datums[0].seriesId, 'revenue');
        expect(datums[0].index, 0);
        expect(datums[0].xRaw, DateTime(2024, 1, 1));
        expect(datums[0].yRaw, 100.0);
        expect(datums[0].label, '\$100.0');
        expect(datums[0].isMissing, isFalse);

        expect(datums[1].index, 1);
        expect(datums[1].xRaw, DateTime(2024, 2, 1));
        expect(datums[1].yRaw, 250.0);
      },
    );

    test('normalization handles missing data flag', () {
      final data = [_SalesRecord(DateTime(2024, 1, 1), 0)];

      final datums = normalizeSeries<_SalesRecord>(
        seriesId: 'test',
        data: data,
        xMapper: (r) => r.date,
        yMapper: (r) => r.amount,
        isMissing: (r) => r.amount == 0,
      );

      expect(datums[0].isMissing, isTrue);
    });
  });
}
