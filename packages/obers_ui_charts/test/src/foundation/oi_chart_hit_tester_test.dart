import 'dart:ui' show Offset, Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

// ── Concrete OiChartHitTester stub for interface tests ───────────────────────

/// A minimal [OiChartHitTester] that delegates to a pre-built
/// [OiChartHitTestIndex] over a fixed set of hit points.
class _StubHitTester implements OiChartHitTester {
  _StubHitTester(List<OiHitPoint> points) : _index = OiChartHitTestIndex() {
    // Build the index with a large viewport so no points are filtered out.
    _index.build(
      points,
      viewport: const OiChartViewport(size: Size(1000, 1000)),
    );
  }

  final OiChartHitTestIndex _index;

  @override
  OiChartHitResult? hitTest(Offset position, {double tolerance = 16}) =>
      _index.hitTest(position, tolerance: tolerance);

  @override
  List<OiChartHitResult> hitTestAll(Offset position, {double tolerance = 16}) =>
      _index.hitTestAll(position, tolerance: tolerance);
}

// ── Helpers ──────────────────────────────────────────────────────────────────

OiHitPoint _point(double x, double y, {int series = 0, int data = 0}) =>
    OiHitPoint(
      position: Offset(x, y),
      ref: OiChartDataRef(seriesIndex: series, dataIndex: data),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('OiChartHitTester (via _StubHitTester)', () {
    // Three points placed far apart so there are no ambiguous nearest results.
    final tester = _StubHitTester([
      _point(100, 100),
      _point(300, 200, data: 1),
      _point(600, 400, series: 1),
    ]);

    group('hitTest', () {
      test('returns the nearest point within tolerance', () {
        // Query right on top of the first point.
        final result = tester.hitTest(const Offset(100, 100));
        expect(result, isNotNull);
        expect(result!.ref, const OiChartDataRef(seriesIndex: 0, dataIndex: 0));
        expect(result.distance, closeTo(0, 0.001));
      });

      test('returns nearest point when query is close but not exact', () {
        // Query 8 px away from the second point — within the default 16 px.
        final result = tester.hitTest(const Offset(308, 200));
        expect(result, isNotNull);
        expect(result!.ref, const OiChartDataRef(seriesIndex: 0, dataIndex: 1));
      });

      test('returns null when no point is within tolerance', () {
        // Query far from all points (more than 16 px from any of them).
        final result = tester.hitTest(const Offset(50, 50));
        expect(result, isNull);
      });

      test('respects a custom tolerance', () {
        // With tolerance 5, a point 10 px away should not match.
        final result = tester.hitTest(const Offset(110, 100), tolerance: 5);
        expect(result, isNull);
      });

      test('with tolerance large enough, finds a far point', () {
        // Query at (50, 50): closest point is (100, 100) → ~70.7 px away.
        final result = tester.hitTest(const Offset(50, 50), tolerance: 80);
        expect(result, isNotNull);
        expect(result!.ref, const OiChartDataRef(seriesIndex: 0, dataIndex: 0));
      });
    });

    group('hitTestAll', () {
      test('returns all points within tolerance sorted by distance', () {
        // Place the query between two close points so both qualify.
        final closeTester = _StubHitTester([
          _point(100, 100),
          _point(110, 100, data: 1),
          _point(500, 500, series: 1),
        ]);
        // Query at (105, 100) — both first two are within 16 px.
        final results = closeTester.hitTestAll(const Offset(105, 100));
        expect(results.length, 2);
        // Should be sorted nearest first.
        expect(
          results.first.distance,
          lessThanOrEqualTo(results.last.distance),
        );
      });

      test('returns empty list when no points are within tolerance', () {
        final results = tester.hitTestAll(Offset.zero, tolerance: 10);
        expect(results, isEmpty);
      });

      test('returns single result when only one point qualifies', () {
        final results = tester.hitTestAll(const Offset(100, 100));
        expect(results.length, 1);
        expect(results.first.ref.dataIndex, 0);
      });

      test('all returned results are within the specified tolerance', () {
        final results = tester.hitTestAll(
          const Offset(100, 100),
          tolerance: 250,
        );
        for (final r in results) {
          expect(r.distance, lessThanOrEqualTo(250));
        }
      });
    });
  });

  // ── OiChartHitTestIndex (concrete implementation) ─────────────────────────

  group('OiChartHitTestIndex', () {
    OiChartViewport viewport(double w, double h) =>
        OiChartViewport(size: Size(w, h));

    test('hitTest on empty index returns null', () {
      final index = OiChartHitTestIndex()
        ..build([], viewport: viewport(400, 300));
      expect(index.hitTest(const Offset(200, 150)), isNull);
    });

    test('pointCount reflects indexed points', () {
      final index = OiChartHitTestIndex()
        ..build([
          _point(50, 50),
          _point(100, 100),
          _point(200, 150),
        ], viewport: viewport(400, 300));
      expect(index.pointCount, 3);
    });

    test('hitTest finds exact point match', () {
      final index = OiChartHitTestIndex()
        ..build([_point(200, 150)], viewport: viewport(400, 300));
      final result = index.hitTest(const Offset(200, 150));
      expect(result, isNotNull);
      expect(result!.distance, closeTo(0, 0.001));
    });

    test('hitTest returns null for out-of-tolerance query', () {
      final index = OiChartHitTestIndex()
        ..build([_point(200, 150)], viewport: viewport(400, 300));
      final result = index.hitTest(const Offset(300, 300));
      expect(result, isNull);
    });

    test('hitTestAll sorts results by distance ascending', () {
      final index = OiChartHitTestIndex()
        ..build([
          _point(100, 100),
          _point(108, 100, data: 1),
          _point(114, 100, data: 2),
        ], viewport: viewport(400, 300));

      final results = index.hitTestAll(const Offset(100, 100));
      expect(results, isNotEmpty);
      for (var i = 1; i < results.length; i++) {
        expect(
          results[i].distance,
          greaterThanOrEqualTo(results[i - 1].distance),
        );
      }
    });

    test('hitTest with includeRadius expands effective hit area', () {
      // Point has radius 20, so effective distance from a query 25 px away
      // is max(0, 25 - 20) = 5, which is within the 16 px tolerance.
      const bigPoint = OiHitPoint(
        position: Offset(200, 150),
        ref: OiChartDataRef(seriesIndex: 0, dataIndex: 0),
        radius: 20,
      );
      final index = OiChartHitTestIndex()
        ..build([bigPoint], viewport: viewport(400, 300));
      final result = index.hitTest(const Offset(225, 150)); // 25 px away
      expect(result, isNotNull);
    });

    test('nearestPoint returns closest point using binary search', () {
      final index = OiChartHitTestIndex()
        ..build([
          _point(50, 100),
          _point(150, 100, data: 1),
          _point(250, 100, data: 2),
        ], viewport: viewport(400, 300));

      final result = index.nearestPoint(const Offset(155, 100));
      expect(result, isNotNull);
      expect(result!.ref.dataIndex, 1);
    });

    test('clear resets the index to empty', () {
      final index = OiChartHitTestIndex()
        ..build([_point(100, 100)], viewport: viewport(400, 300));
      expect(index.pointCount, 1);
      index.clear();
      expect(index.pointCount, 0);
      expect(index.hitTest(const Offset(100, 100)), isNull);
    });

    test('foremost preference selects highest series index in cluster', () {
      final index =
          OiChartHitTestIndex(
            config: const OiHitTestConfig(
              preference: OiHitTestPreference.foremost,
            ),
          )..build([
            _point(100, 100),
            _point(102, 100, series: 1),
          ], viewport: viewport(400, 300));

      final result = index.hitTest(const Offset(101, 100));
      expect(result, isNotNull);
      expect(result!.ref.seriesIndex, 1); // foremost = highest series index
    });

    test('verticalNearest preference selects point closest in y', () {
      final index =
          OiChartHitTestIndex(
            config: const OiHitTestConfig(
              tolerance: 30,
              preference: OiHitTestPreference.verticalNearest,
            ),
          )..build([
            _point(100, 80), // 20 px above query
            _point(100, 115, series: 1), // 15 px below query
          ], viewport: viewport(400, 300));

      final result = index.hitTest(const Offset(100, 100));
      expect(result, isNotNull);
      // series 1 is closer in y (15 px vs 20 px)
      expect(result!.ref.seriesIndex, 1);
    });
  });

  // ── OiChartDataRef ────────────────────────────────────────────────────────

  group('OiChartDataRef', () {
    test('equality holds when seriesIndex and dataIndex match', () {
      const a = OiChartDataRef(seriesIndex: 1, dataIndex: 5);
      const b = OiChartDataRef(seriesIndex: 1, dataIndex: 5);
      expect(a, equals(b));
    });

    test('inequality when seriesIndex differs', () {
      const a = OiChartDataRef(seriesIndex: 0, dataIndex: 5);
      const b = OiChartDataRef(seriesIndex: 1, dataIndex: 5);
      expect(a, isNot(equals(b)));
    });

    test('toString includes both indices', () {
      const ref = OiChartDataRef(seriesIndex: 2, dataIndex: 7);
      expect(ref.toString(), contains('2'));
      expect(ref.toString(), contains('7'));
    });
  });

  // ── OiChartHitResult ──────────────────────────────────────────────────────

  group('OiChartHitResult', () {
    test('equality holds when all fields match', () {
      const a = OiChartHitResult(
        ref: OiChartDataRef(seriesIndex: 0, dataIndex: 0),
        position: Offset(10, 20),
        distance: 5,
      );
      const b = OiChartHitResult(
        ref: OiChartDataRef(seriesIndex: 0, dataIndex: 0),
        position: Offset(10, 20),
        distance: 5,
      );
      expect(a, equals(b));
    });

    test('distance defaults to 0', () {
      const r = OiChartHitResult(
        ref: OiChartDataRef(seriesIndex: 0, dataIndex: 0),
        position: Offset.zero,
      );
      expect(r.distance, 0);
    });
  });
}
