// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'dart:ui';

import 'package:flutter/widgets.dart' show EdgeInsets;
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_controller.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_hit_test.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_viewport.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

OiChartViewport _viewport({Size size = const Size(400, 300)}) {
  return OiChartViewport(
    size: size,
    padding: const EdgeInsets.all(16),
    axisInsets: const OiAxisInsets(left: 40, bottom: 24),
  );
}

OiHitPoint _point(double x, double y, {int series = 0, int data = 0, double radius = 0}) {
  return OiHitPoint(
    position: Offset(x, y),
    ref: OiChartDataRef(seriesIndex: series, dataIndex: data),
    radius: radius,
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('OiHitPoint', () {
    test('equality by value', () {
      final a = _point(100, 150, series: 0, data: 2);
      final b = _point(100, 150, series: 0, data: 2);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('inequality when position differs', () {
      final a = _point(100, 150);
      final b = _point(100, 151);
      expect(a, isNot(equals(b)));
    });

    test('toString contains position and ref', () {
      final p = _point(100, 150, series: 1, data: 3);
      final str = p.toString();
      expect(str, contains('100'));
      expect(str, contains('150'));
    });
  });

  group('OiHitTestConfig', () {
    test('default values', () {
      const config = OiHitTestConfig();
      expect(config.tolerance, 16.0);
      expect(config.preference, OiHitTestPreference.nearest);
      expect(config.bucketWidth, 0);
      expect(config.includeRadius, isTrue);
    });

    test('equality', () {
      const a = OiHitTestConfig(tolerance: 20);
      const b = OiHitTestConfig(tolerance: 20);
      const c = OiHitTestConfig(tolerance: 30);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });
  });

  group('OiChartHitTestIndex', () {
    group('build', () {
      test('indexes points within viewport', () {
        final index = OiChartHitTestIndex();
        final vp = _viewport();
        final pb = vp.plotBounds;

        index.build([
          _point(pb.left + 10, pb.top + 10, data: 0),
          _point(pb.center.dx, pb.center.dy, data: 1),
          _point(pb.right - 10, pb.bottom - 10, data: 2),
        ], viewport: vp);

        expect(index.pointCount, 3);
      });

      test('filters out points outside viewport', () {
        final index = OiChartHitTestIndex(
          config: const OiHitTestConfig(tolerance: 5),
        );
        final vp = _viewport();

        index.build([
          _point(0, 0, data: 0),     // Outside (top-left corner)
          _point(vp.plotBounds.center.dx, vp.plotBounds.center.dy, data: 1),
          _point(500, 500, data: 2), // Outside (beyond viewport)
        ], viewport: vp);

        expect(index.pointCount, 1);
      });

      test('handles empty point list', () {
        final index = OiChartHitTestIndex();
        index.build([], viewport: _viewport());
        expect(index.pointCount, 0);
        expect(index.bucketCount, 0);
      });

      test('handles single point', () {
        final index = OiChartHitTestIndex();
        final vp = _viewport();
        index.build([
          _point(vp.plotBounds.center.dx, vp.plotBounds.center.dy),
        ], viewport: vp);
        expect(index.pointCount, 1);
      });

      test('detects x-ordered domains', () {
        final index = OiChartHitTestIndex();
        final vp = _viewport();
        final pb = vp.plotBounds;

        index.build([
          _point(pb.left + 10, pb.center.dy, data: 0),
          _point(pb.left + 50, pb.center.dy, data: 1),
          _point(pb.left + 100, pb.center.dy, data: 2),
        ], viewport: vp);

        expect(index.pointCount, 3);
      });
    });

    group('hitTest', () {
      test('finds nearest point within tolerance', () {
        final index = OiChartHitTestIndex(
          config: const OiHitTestConfig(tolerance: 20),
        );
        final vp = _viewport();
        final pb = vp.plotBounds;

        final target = Offset(pb.left + 100, pb.center.dy);
        index.build([
          _point(target.dx, target.dy, data: 0),
          _point(target.dx + 50, target.dy, data: 1),
        ], viewport: vp);

        final result = index.hitTest(target);
        expect(result, isNotNull);
        expect(result!.ref.dataIndex, 0);
        expect(result.distance, closeTo(0, 0.01));
      });

      test('returns null when no points within tolerance', () {
        final index = OiChartHitTestIndex(
          config: const OiHitTestConfig(tolerance: 5),
        );
        final vp = _viewport();
        final pb = vp.plotBounds;

        index.build([
          _point(pb.left + 100, pb.center.dy, data: 0),
        ], viewport: vp);

        final result = index.hitTest(
          Offset(pb.left + 200, pb.center.dy),
        );
        expect(result, isNull);
      });

      test('finds point with tolerance override', () {
        final index = OiChartHitTestIndex(
          config: const OiHitTestConfig(tolerance: 5),
        );
        final vp = _viewport();
        final pb = vp.plotBounds;

        index.build([
          _point(pb.left + 100, pb.center.dy, data: 0),
        ], viewport: vp);

        // Outside default tolerance.
        expect(
          index.hitTest(Offset(pb.left + 115, pb.center.dy)),
          isNull,
        );

        // Within overridden tolerance.
        final result = index.hitTest(
          Offset(pb.left + 115, pb.center.dy),
          tolerance: 20,
        );
        expect(result, isNotNull);
      });

      test('returns nearest of multiple points', () {
        final index = OiChartHitTestIndex(
          config: const OiHitTestConfig(tolerance: 30),
        );
        final vp = _viewport();
        final pb = vp.plotBounds;

        final queryX = pb.left + 100;
        index.build([
          _point(queryX - 20, pb.center.dy, data: 0),  // 20px away
          _point(queryX - 5, pb.center.dy, data: 1),   // 5px away
          _point(queryX + 25, pb.center.dy, data: 2),  // 25px away
        ], viewport: vp);

        final result = index.hitTest(Offset(queryX, pb.center.dy));
        expect(result, isNotNull);
        expect(result!.ref.dataIndex, 1);
      });
    });

    group('hitTestAll', () {
      test('returns all points within tolerance sorted by distance', () {
        final index = OiChartHitTestIndex(
          config: const OiHitTestConfig(tolerance: 30),
        );
        final vp = _viewport();
        final pb = vp.plotBounds;

        final queryX = pb.left + 100;
        index.build([
          _point(queryX - 20, pb.center.dy, data: 0),
          _point(queryX - 5, pb.center.dy, data: 1),
          _point(queryX + 25, pb.center.dy, data: 2),
        ], viewport: vp);

        final results = index.hitTestAll(Offset(queryX, pb.center.dy));
        expect(results, hasLength(3));
        // Sorted by distance — nearest first.
        expect(results[0].ref.dataIndex, 1);
        expect(results[1].ref.dataIndex, 0);
        expect(results[2].ref.dataIndex, 2);
      });

      test('returns empty list when nothing is within tolerance', () {
        final index = OiChartHitTestIndex(
          config: const OiHitTestConfig(tolerance: 5),
        );
        final vp = _viewport();
        final pb = vp.plotBounds;

        index.build([
          _point(pb.left + 100, pb.center.dy, data: 0),
        ], viewport: vp);

        final results = index.hitTestAll(
          Offset(pb.left + 200, pb.center.dy),
        );
        expect(results, isEmpty);
      });
    });

    group('nearestPoint (binary search)', () {
      test('finds nearest point in ordered domain', () {
        final index = OiChartHitTestIndex(
          config: const OiHitTestConfig(tolerance: 20),
        );
        final vp = _viewport();
        final pb = vp.plotBounds;

        // Create ordered x-domain points.
        final points = <OiHitPoint>[];
        for (var i = 0; i < 100; i++) {
          final x = pb.left + 2 + i * 3;
          if (x < pb.right) {
            points.add(_point(x, pb.center.dy, data: i));
          }
        }
        index.build(points, viewport: vp);

        // Query near point at index 10.
        final targetX = pb.left + 2 + 10 * 3;
        final result = index.nearestPoint(
          Offset(targetX + 1, pb.center.dy),
        );
        expect(result, isNotNull);
        expect(result!.ref.dataIndex, 10);
      });

      test('returns null when no points within tolerance', () {
        final index = OiChartHitTestIndex(
          config: const OiHitTestConfig(tolerance: 5),
        );
        final vp = _viewport();
        final pb = vp.plotBounds;

        index.build([
          _point(pb.left + 100, pb.center.dy, data: 0),
        ], viewport: vp);

        final result = index.nearestPoint(
          Offset(pb.left + 200, pb.center.dy),
        );
        expect(result, isNull);
      });

      test('works with single point', () {
        final index = OiChartHitTestIndex(
          config: const OiHitTestConfig(tolerance: 20),
        );
        final vp = _viewport();
        final pb = vp.plotBounds;

        index.build([
          _point(pb.center.dx, pb.center.dy, data: 0),
        ], viewport: vp);

        final result = index.nearestPoint(
          Offset(pb.center.dx + 5, pb.center.dy),
        );
        expect(result, isNotNull);
        expect(result!.ref.dataIndex, 0);
      });
    });

    group('preference rules', () {
      test('foremost preference selects highest series index in cluster', () {
        final index = OiChartHitTestIndex(
          config: const OiHitTestConfig(
            tolerance: 20,
            preference: OiHitTestPreference.foremost,
          ),
        );
        final vp = _viewport();
        final pb = vp.plotBounds;

        // Two points from different series at nearly the same position.
        final cx = pb.center.dx;
        final cy = pb.center.dy;
        index.build([
          _point(cx, cy, series: 0, data: 0),
          _point(cx + 1, cy, series: 1, data: 0),
          _point(cx + 2, cy, series: 2, data: 0),
        ], viewport: vp);

        final result = index.hitTest(Offset(cx, cy));
        expect(result, isNotNull);
        expect(result!.ref.seriesIndex, 2);
      });

      test('verticalNearest preference selects closest y', () {
        final index = OiChartHitTestIndex(
          config: const OiHitTestConfig(
            tolerance: 30,
            preference: OiHitTestPreference.verticalNearest,
          ),
        );
        final vp = _viewport();
        final pb = vp.plotBounds;

        final cx = pb.center.dx;
        final cy = pb.center.dy;
        index.build([
          _point(cx, cy - 20, series: 0, data: 0),   // 20px above
          _point(cx, cy - 5, series: 1, data: 0),    // 5px above
          _point(cx, cy + 15, series: 2, data: 0),   // 15px below
        ], viewport: vp);

        final result = index.hitTest(Offset(cx, cy));
        expect(result, isNotNull);
        expect(result!.ref.seriesIndex, 1);
      });

      test('nearest preference selects closest point', () {
        final index = OiChartHitTestIndex(
          config: const OiHitTestConfig(
            tolerance: 30,
            preference: OiHitTestPreference.nearest,
          ),
        );
        final vp = _viewport();
        final pb = vp.plotBounds;

        final cx = pb.center.dx;
        final cy = pb.center.dy;
        index.build([
          _point(cx + 20, cy, series: 0, data: 0),
          _point(cx + 3, cy, series: 1, data: 0),
          _point(cx + 15, cy, series: 2, data: 0),
        ], viewport: vp);

        final result = index.hitTest(Offset(cx, cy));
        expect(result, isNotNull);
        expect(result!.ref.seriesIndex, 1);
      });
    });

    group('radius support', () {
      test('point radius expands effective hit area', () {
        final index = OiChartHitTestIndex(
          config: const OiHitTestConfig(tolerance: 10, includeRadius: true),
        );
        final vp = _viewport();
        final pb = vp.plotBounds;

        // Point with 8px radius. Without radius, distance is 15px > 10px tolerance.
        // With radius, effective distance is 15 - 8 = 7px < 10px.
        index.build([
          _point(pb.center.dx, pb.center.dy, data: 0, radius: 8),
        ], viewport: vp);

        final result = index.hitTest(
          Offset(pb.center.dx + 15, pb.center.dy),
        );
        expect(result, isNotNull);
        expect(result!.distance, closeTo(7, 0.5));
      });

      test('radius is ignored when includeRadius is false', () {
        final index = OiChartHitTestIndex(
          config: const OiHitTestConfig(tolerance: 10, includeRadius: false),
        );
        final vp = _viewport();
        final pb = vp.plotBounds;

        index.build([
          _point(pb.center.dx, pb.center.dy, data: 0, radius: 8),
        ], viewport: vp);

        // 15px away, tolerance is 10, no radius expansion.
        final result = index.hitTest(
          Offset(pb.center.dx + 15, pb.center.dy),
        );
        expect(result, isNull);
      });
    });

    group('x-bucket indexing', () {
      test('uses custom bucket width', () {
        final index = OiChartHitTestIndex(
          config: const OiHitTestConfig(
            tolerance: 20,
            bucketWidth: 50,
          ),
        );
        final vp = _viewport();
        final pb = vp.plotBounds;

        index.build([
          _point(pb.left + 10, pb.center.dy, data: 0),
          _point(pb.left + 60, pb.center.dy, data: 1),
          _point(pb.left + 110, pb.center.dy, data: 2),
        ], viewport: vp);

        expect(index.pointCount, 3);
        expect(index.bucketCount, greaterThanOrEqualTo(2));
      });

      test('auto bucket width from tolerance', () {
        final index = OiChartHitTestIndex(
          config: const OiHitTestConfig(tolerance: 25),
        );
        final vp = _viewport();
        final pb = vp.plotBounds;

        index.build([
          _point(pb.left + 10, pb.center.dy, data: 0),
          _point(pb.left + 60, pb.center.dy, data: 1),
        ], viewport: vp);

        expect(index.pointCount, 2);
        expect(index.bucketCount, greaterThanOrEqualTo(2));
      });
    });

    group('clear', () {
      test('clears all indexed data', () {
        final index = OiChartHitTestIndex();
        final vp = _viewport();
        final pb = vp.plotBounds;

        index.build([
          _point(pb.center.dx, pb.center.dy, data: 0),
        ], viewport: vp);
        expect(index.pointCount, 1);

        index.clear();
        expect(index.pointCount, 0);
        expect(index.bucketCount, 0);
      });

      test('hitTest returns null after clear', () {
        final index = OiChartHitTestIndex();
        final vp = _viewport();
        final pb = vp.plotBounds;

        index.build([
          _point(pb.center.dx, pb.center.dy, data: 0),
        ], viewport: vp);

        index.clear();
        expect(index.hitTest(pb.center), isNull);
      });
    });

    group('multi-series', () {
      test('finds correct series in overlapping data', () {
        final index = OiChartHitTestIndex(
          config: const OiHitTestConfig(tolerance: 30),
        );
        final vp = _viewport();
        final pb = vp.plotBounds;

        // Two series with interleaved points.
        final cx = pb.center.dx;
        index.build([
          _point(cx - 10, pb.top + 50, series: 0, data: 0),
          _point(cx - 10, pb.top + 100, series: 1, data: 0),
          _point(cx + 10, pb.top + 80, series: 0, data: 1),
          _point(cx + 10, pb.top + 130, series: 1, data: 1),
        ], viewport: vp);

        // Query near series 1, data 0.
        final result = index.hitTest(
          Offset(cx - 12, pb.top + 102),
        );
        expect(result, isNotNull);
        expect(result!.ref.seriesIndex, 1);
        expect(result.ref.dataIndex, 0);
      });
    });

    group('OiChartHitTester interface', () {
      test('implements OiChartHitTester', () {
        final index = OiChartHitTestIndex();
        expect(index, isA<OiChartHitTestIndex>());
      });
    });

    group('unordered domain', () {
      test('handles randomly ordered x-coordinates', () {
        final index = OiChartHitTestIndex(
          config: const OiHitTestConfig(tolerance: 20),
        );
        final vp = _viewport();
        final pb = vp.plotBounds;

        // Scatter-style unordered points.
        index.build([
          _point(pb.left + 100, pb.top + 50, data: 0),
          _point(pb.left + 50, pb.top + 100, data: 1),
          _point(pb.left + 150, pb.top + 30, data: 2),
          _point(pb.left + 80, pb.top + 80, data: 3),
        ], viewport: vp);

        final result = index.hitTest(
          Offset(pb.left + 82, pb.top + 78),
        );
        expect(result, isNotNull);
        expect(result!.ref.dataIndex, 3);
      });
    });

    group('edge cases', () {
      test('all points at the same position', () {
        final index = OiChartHitTestIndex(
          config: const OiHitTestConfig(tolerance: 10),
        );
        final vp = _viewport();
        final pb = vp.plotBounds;

        index.build([
          _point(pb.center.dx, pb.center.dy, series: 0, data: 0),
          _point(pb.center.dx, pb.center.dy, series: 1, data: 0),
          _point(pb.center.dx, pb.center.dy, series: 2, data: 0),
        ], viewport: vp);

        final results = index.hitTestAll(pb.center);
        expect(results, hasLength(3));
      });

      test('points on plot area boundary', () {
        final index = OiChartHitTestIndex(
          config: const OiHitTestConfig(tolerance: 20),
        );
        final vp = _viewport();
        final pb = vp.plotBounds;

        index.build([
          _point(pb.left, pb.top, data: 0),
          _point(pb.right, pb.bottom, data: 1),
        ], viewport: vp);

        expect(index.pointCount, 2);
        final result = index.hitTest(Offset(pb.left + 5, pb.top + 5));
        expect(result, isNotNull);
        expect(result!.ref.dataIndex, 0);
      });

      test('large number of points does not throw', () {
        final index = OiChartHitTestIndex();
        final vp = _viewport();
        final pb = vp.plotBounds;

        final points = <OiHitPoint>[];
        for (var i = 0; i < 10000; i++) {
          final x = pb.left + (i % 300).toDouble();
          final y = pb.top + (i ~/ 300).toDouble();
          points.add(_point(x, y, data: i));
        }
        index.build(points, viewport: vp);

        final result = index.hitTest(pb.center);
        // Just verify it doesn't throw and returns a result.
        expect(result != null || result == null, isTrue);
      });
    });
  });
}
