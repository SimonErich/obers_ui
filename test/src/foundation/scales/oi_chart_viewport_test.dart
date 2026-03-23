// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'dart:ui';

import 'package:flutter/widgets.dart' show EdgeInsets;
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_viewport.dart';

void main() {
  group('OiAxisInsets', () {
    test('default constructor has all zeros', () {
      const insets = OiAxisInsets();
      expect(insets.left, 0);
      expect(insets.top, 0);
      expect(insets.right, 0);
      expect(insets.bottom, 0);
    });

    test('symmetric constructor', () {
      const insets = OiAxisInsets.symmetric(horizontal: 40, vertical: 24);
      expect(insets.left, 40);
      expect(insets.right, 40);
      expect(insets.top, 24);
      expect(insets.bottom, 24);
    });

    test('all constructor', () {
      const insets = OiAxisInsets.all(16);
      expect(insets.left, 16);
      expect(insets.top, 16);
      expect(insets.right, 16);
      expect(insets.bottom, 16);
    });

    test('horizontal and vertical totals', () {
      const insets = OiAxisInsets(left: 40, right: 20, top: 10, bottom: 30);
      expect(insets.horizontal, 60);
      expect(insets.vertical, 40);
    });

    test('copyWith', () {
      const insets = OiAxisInsets(left: 40, bottom: 24);
      final copy = insets.copyWith(left: 60);
      expect(copy.left, 60);
      expect(copy.bottom, 24);
    });

    test('equality', () {
      const a = OiAxisInsets(left: 40, bottom: 24);
      const b = OiAxisInsets(left: 40, bottom: 24);
      const c = OiAxisInsets(left: 40, bottom: 30);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, b.hashCode);
    });

    test('toString', () {
      const insets = OiAxisInsets(left: 40, bottom: 24);
      expect(insets.toString(), contains('40'));
      expect(insets.toString(), contains('24'));
    });
  });

  group('OiChartViewport', () {
    const defaultViewport = OiChartViewport(
      size: Size(400, 300),
      padding: EdgeInsets.all(16),
      axisInsets: OiAxisInsets(left: 40, bottom: 24),
    );

    test('plotBounds excludes padding and axis insets', () {
      final pb = defaultViewport.plotBounds;
      // left = 16 + 40 = 56
      expect(pb.left, 56);
      // top = 16 + 0 = 16
      expect(pb.top, 16);
      // right = 400 - 16 - 0 = 384
      expect(pb.right, 384);
      // bottom = 300 - 16 - 24 = 260
      expect(pb.bottom, 260);
    });

    test('plotWidth and plotHeight', () {
      expect(defaultViewport.plotWidth, 328); // 384 - 56
      expect(defaultViewport.plotHeight, 244); // 260 - 16
    });

    test('physicalPlotWidth with devicePixelRatio', () {
      const viewport = OiChartViewport(
        size: Size(400, 300),
        devicePixelRatio: 2,
      );
      expect(viewport.physicalPlotWidth, 800);
      expect(viewport.physicalPlotHeight, 600);
    });

    test('chartBounds is full widget size', () {
      expect(defaultViewport.chartBounds, const Rect.fromLTWH(0, 0, 400, 300));
    });

    test('widgetToPlot converts coordinates', () {
      final plotPoint = defaultViewport.widgetToPlot(const Offset(56, 16));
      expect(plotPoint.dx, closeTo(0, 0.01));
      expect(plotPoint.dy, closeTo(0, 0.01));
    });

    test('plotToWidget converts coordinates back', () {
      final widgetPoint = defaultViewport.plotToWidget(Offset.zero);
      expect(widgetPoint.dx, closeTo(56, 0.01));
      expect(widgetPoint.dy, closeTo(16, 0.01));
    });

    test('widgetToPlot and plotToWidget are inverse', () {
      const point = Offset(200, 150);
      final roundTrip = defaultViewport.plotToWidget(
        defaultViewport.widgetToPlot(point),
      );
      expect(roundTrip.dx, closeTo(point.dx, 0.01));
      expect(roundTrip.dy, closeTo(point.dy, 0.01));
    });

    test('widgetToNormalized returns 0-1 range', () {
      final pb = defaultViewport.plotBounds;
      // Center of plot area.
      final center = Offset((pb.left + pb.right) / 2, (pb.top + pb.bottom) / 2);
      final normalized = defaultViewport.widgetToNormalized(center);
      expect(normalized.dx, closeTo(0.5, 0.01));
      expect(normalized.dy, closeTo(0.5, 0.01));
    });

    test('normalizedToWidget converts back', () {
      const normalized = Offset(0.5, 0.5);
      final widget = defaultViewport.normalizedToWidget(normalized);
      final pb = defaultViewport.plotBounds;
      expect(widget.dx, closeTo(pb.center.dx, 0.01));
      expect(widget.dy, closeTo(pb.center.dy, 0.01));
    });

    test('hitTestPlot returns true inside plot area', () {
      final pb = defaultViewport.plotBounds;
      expect(defaultViewport.hitTestPlot(pb.center), isTrue);
    });

    test('hitTestPlot returns false outside plot area', () {
      expect(defaultViewport.hitTestPlot(Offset.zero), isFalse);
      expect(defaultViewport.hitTestPlot(const Offset(399, 299)), isFalse);
    });

    test('snapToPixel rounds to physical pixels', () {
      const viewport = OiChartViewport(
        size: Size(400, 300),
        devicePixelRatio: 2,
      );
      // 10.3 * 2 = 20.6 → round to 21 → 21 / 2 = 10.5
      expect(viewport.snapToPixel(10.3), 10.5);
      // 10.5 * 2 = 21.0 → round to 21 → 21 / 2 = 10.5
      expect(viewport.snapToPixel(10.5), 10.5);
    });

    test('snapOffsetToPixel snaps both components', () {
      const viewport = OiChartViewport(
        size: Size(400, 300),
        devicePixelRatio: 2,
      );
      final snapped = viewport.snapOffsetToPixel(const Offset(10.3, 20.7));
      expect(snapped.dx, viewport.snapToPixel(10.3));
      expect(snapped.dy, viewport.snapToPixel(20.7));
    });

    group('zoom and pan', () {
      test('panBy adds delta to panOffset', () {
        final panned = defaultViewport.panBy(const Offset(10, 20));
        expect(panned.panOffset, const Offset(10, 20));
      });

      test('panBy accumulates', () {
        final panned = defaultViewport
            .panBy(const Offset(10, 20))
            .panBy(const Offset(5, -10));
        expect(panned.panOffset, const Offset(15, 10));
      });

      test('zoomTo changes zoomLevel', () {
        final zoomed = defaultViewport.zoomTo(2);
        expect(zoomed.zoomLevel, 2);
      });

      test('zoomTo preserves focal point', () {
        final pb = defaultViewport.plotBounds;
        final focal = pb.center;
        final zoomed = defaultViewport.zoomTo(2, focalPoint: focal);
        // After zooming, the focal point should map to the same
        // plot-relative position.
        final before = defaultViewport.widgetToPlot(focal);
        final after = zoomed.widgetToPlot(focal);
        expect(after.dx, closeTo(before.dx, 0.01));
        expect(after.dy, closeTo(before.dy, 0.01));
      });

      test('resetTransform resets zoom and pan', () {
        final modified = defaultViewport.panBy(const Offset(50, 50)).zoomTo(3);
        final reset = modified.resetTransform();
        expect(reset.zoomLevel, 1);
        expect(reset.panOffset, Offset.zero);
      });
    });

    test('copyWith returns new instance with overrides', () {
      final copy = defaultViewport.copyWith(devicePixelRatio: 3, zoomLevel: 2);
      expect(copy.devicePixelRatio, 3);
      expect(copy.zoomLevel, 2);
      expect(copy.size, defaultViewport.size);
      expect(copy.padding, defaultViewport.padding);
    });

    test('equality', () {
      const a = OiChartViewport(
        size: Size(400, 300),
        padding: EdgeInsets.all(16),
      );
      const b = OiChartViewport(
        size: Size(400, 300),
        padding: EdgeInsets.all(16),
      );
      const c = OiChartViewport(
        size: Size(500, 300),
        padding: EdgeInsets.all(16),
      );
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, b.hashCode);
    });

    test('toString includes key info', () {
      expect(defaultViewport.toString(), contains('OiChartViewport'));
      expect(defaultViewport.toString(), contains('400'));
    });

    test('visibleDomain can be set', () {
      const domain = Rect.fromLTWH(10, 20, 100, 200);
      final viewport = defaultViewport.copyWith(visibleDomain: domain);
      expect(viewport.visibleDomain, domain);
    });

    test('default values', () {
      const viewport = OiChartViewport(size: Size(400, 300));
      expect(viewport.padding, EdgeInsets.zero);
      expect(viewport.axisInsets, const OiAxisInsets());
      expect(viewport.devicePixelRatio, 1);
      expect(viewport.visibleDomain, isNull);
      expect(viewport.zoomLevel, 1);
      expect(viewport.panOffset, Offset.zero);
    });

    test('plotBounds with no padding or insets equals full size', () {
      const viewport = OiChartViewport(size: Size(400, 300));
      expect(viewport.plotBounds, const Rect.fromLTWH(0, 0, 400, 300));
    });
  });
}
