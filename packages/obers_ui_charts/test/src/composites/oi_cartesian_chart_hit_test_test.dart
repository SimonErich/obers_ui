import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';
import 'package:obers_ui_charts/src/composites/_cartesian_hit_tester.dart';

import '../../helpers/pump_chart_app.dart';

class _Point {
  const _Point(this.x, this.y);
  final Object x;
  final double y;
}

OiCartesianSeries<_Point> _series(
  String id,
  List<_Point> data, {
  bool visible = true,
}) {
  return OiCartesianSeries<_Point>(
    id: id,
    label: id,
    data: data,
    visible: visible,
    xMapper: (p) => p.x,
    yMapper: (p) => p.y,
  );
}

const _linear = [_Point(1, 10), _Point(2, 20), _Point(3, 30)];

OiChartCrosshairBehavior _snappingCrosshair() => OiChartCrosshairBehavior(
  config: const OiChartCrosshairConfig(snap: OiChartCrosshairSnap.nearestPoint),
);

/// Pumps a 400x300 chart at the top-left corner. Without axis insets the
/// plot area is the whole widget.
///
/// Pass the same [behaviors] list when pumping again: a new list makes the
/// chart detach and re-attach its behaviors.
Future<void> _pumpChart(
  WidgetTester tester,
  List<OiCartesianSeries<_Point>> series,
  List<OiChartBehavior> behaviors, {
  OiChartAxis<dynamic>? xAxis,
  List<OiChartAxis<num>>? yAxes,
  OiChartController? controller,
}) async {
  await tester.pumpChartApp(
    Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: 400,
        height: 300,
        child: OiCartesianChart<_Point>(
          label: 'Hit test',
          series: series,
          xAxis: xAxis,
          yAxes: yAxes,
          behaviors: behaviors,
          controller: controller,
          // Stands in for the series layer; it makes the plot hit-testable.
          seriesBuilder: (context, viewport, series) =>
              const ColoredBox(color: Color(0x00000000)),
        ),
      ),
    ),
  );
  // Behaviors attach in a post-frame callback.
  await tester.pump();
}

Future<TestGesture> _hoverAt(WidgetTester tester, Offset position) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  await gesture.moveTo(position);
  await tester.pump();
  return gesture;
}

void main() {
  group('OiCartesianChart hit testing', () {
    testWidgets('the crosshair snaps to the nearest data point', (
      tester,
    ) async {
      final crosshair = _snappingCrosshair();
      await _pumpChart(tester, [_series('a', _linear)], [crosshair]);

      // x 1..3 spans the plot width and y 10..30 its height, so the middle
      // point sits at the centre of the plot.
      await _hoverAt(tester, const Offset(206, 144));

      expect(
        crosshair.state?.snappedRef,
        const OiChartDataRef(seriesIndex: 0, dataIndex: 1),
      );
      expect(crosshair.state?.snappedPosition, const Offset(200, 150));
    });

    testWidgets('nothing is snapped when no point is within tolerance', (
      tester,
    ) async {
      final crosshair = _snappingCrosshair();
      await _pumpChart(tester, [_series('a', _linear)], [crosshair]);

      await _hoverAt(tester, const Offset(100, 20));

      expect(crosshair.state, isNotNull);
      expect(crosshair.state?.snappedRef, isNull);
    });

    testWidgets('series indices follow the widget and skip hidden series', (
      tester,
    ) async {
      final crosshair = _snappingCrosshair();
      await _pumpChart(
        tester,
        [
          _series('hidden', const [_Point(2, 20)], visible: false),
          _series('a', _linear),
        ],
        [crosshair],
      );

      await _hoverAt(tester, const Offset(200, 150));

      expect(
        crosshair.state?.snappedRef,
        const OiChartDataRef(seriesIndex: 1, dataIndex: 1),
      );
    });

    testWidgets('new data is hit after a rebuild', (tester) async {
      final crosshair = _snappingCrosshair();
      final behaviors = [crosshair];
      await _pumpChart(tester, [_series('a', _linear)], behaviors);
      final gesture = await _hoverAt(tester, const Offset(100, 225));
      expect(crosshair.state?.snappedRef, isNull);

      await _pumpChart(tester, [
        _series('a', const [
          _Point(1, 10),
          _Point(1.5, 15),
          _Point(2, 20),
          _Point(3, 30),
        ]),
      ], behaviors);
      await gesture.moveTo(const Offset(101, 224));
      await tester.pump();

      expect(
        crosshair.state?.snappedRef,
        const OiChartDataRef(seriesIndex: 0, dataIndex: 1),
      );
    });

    testWidgets('a series hidden through the controller is no longer hit', (
      tester,
    ) async {
      final controller = OiDefaultChartController();
      addTearDown(controller.dispose);
      final crosshair = _snappingCrosshair();
      await _pumpChart(
        tester,
        [
          _series('a', _linear),
          // Same extent as a, but no point in the middle.
          _series('b', const [_Point(1, 10), _Point(3, 30)]),
        ],
        [crosshair],
        controller: controller,
      );

      final gesture = await _hoverAt(tester, const Offset(200, 150));
      expect(
        crosshair.state?.snappedRef,
        const OiChartDataRef(seriesIndex: 0, dataIndex: 1),
      );

      controller.toggleSeries('a');
      await tester.pump();
      await gesture.moveTo(const Offset(201, 150));
      await tester.pump();

      expect(crosshair.state, isNotNull);
      expect(crosshair.state?.snappedRef, isNull);
    });

    testWidgets('explicit axis bounds move the points', (tester) async {
      final crosshair = _snappingCrosshair();
      await _pumpChart(
        tester,
        [_series('a', _linear)],
        [crosshair],
        xAxis: const OiChartAxis<dynamic>(min: 0, max: 4),
        yAxes: const [OiChartAxis<num>(min: 0, max: 40)],
      );

      // (1, 10) is a quarter in from the left and a quarter up.
      await _hoverAt(tester, const Offset(100, 225));

      expect(
        crosshair.state?.snappedRef,
        const OiChartDataRef(seriesIndex: 0, dataIndex: 0),
      );
    });
  });

  group('projectCartesianHitPoints', () {
    const viewport = OiChartViewport(size: Size(400, 300));

    List<OiHitPoint> project(
      Map<String, List<_Point>> series, {
      List<String>? seriesIds,
      double? xMin,
      double? xMax,
      double? yMin,
      double? yMax,
      OiChartViewport viewport = viewport,
      bool Function(_Point)? isMissing,
    }) {
      return projectCartesianHitPoints(
        data: {
          for (final entry in series.entries)
            entry.key: normalizeSeries<_Point>(
              seriesId: entry.key,
              data: entry.value,
              xMapper: (p) => p.x,
              yMapper: (p) => p.y,
              isMissing: isMissing,
            ),
        },
        seriesIds: seriesIds ?? series.keys.toList(),
        viewport: viewport,
        xMin: xMin,
        xMax: xMax,
        yMin: yMin,
        yMax: yMax,
      );
    }

    test('maps the data extent onto the plot bounds', () {
      final points = project({'a': _linear});

      expect(points.map((p) => p.position), [
        const Offset(0, 300),
        const Offset(200, 150),
        const Offset(400, 0),
      ]);
      expect(points.map((p) => p.ref.dataIndex), [0, 1, 2]);
    });

    test('places categories at their band centres', () {
      final points = project({
        'a': const [_Point('Jan', 0), _Point('Feb', 10)],
        'b': const [_Point('Feb', 5), _Point('Mar', 10)],
      });

      // Three categories in order of first appearance: Jan, Feb, Mar.
      final byRef = {for (final p in points) p.ref: p.position.dx};
      expect(
        byRef[const OiChartDataRef(seriesIndex: 0, dataIndex: 0)],
        closeTo(400 / 6, 1e-9),
      );
      expect(byRef[const OiChartDataRef(seriesIndex: 0, dataIndex: 1)], 200);
      expect(byRef[const OiChartDataRef(seriesIndex: 1, dataIndex: 0)], 200);
      expect(
        byRef[const OiChartDataRef(seriesIndex: 1, dataIndex: 1)],
        closeTo(400 * 5 / 6, 1e-9),
      );
    });

    test('maps DateTime x values by time', () {
      final points = project({
        'a': [
          _Point(DateTime.utc(2024), 0),
          _Point(DateTime.utc(2024, 1, 2), 5),
          _Point(DateTime.utc(2024, 1, 5), 10),
        ],
      });

      expect(points.map((p) => p.position.dx), [0, 100, 400]);
    });

    test('skips missing and non-finite points', () {
      final points = project({
        'a': const [
          _Point(1, 10),
          _Point(2, double.nan),
          _Point(double.infinity, 20),
          _Point(3, 30),
        ],
      });

      expect(points.map((p) => p.ref.dataIndex), [0, 3]);
      expect(points.first.position, const Offset(0, 300));
      expect(points.last.position, const Offset(400, 0));

      final flagged = project({'a': _linear}, isMissing: (p) => p.x == 2);
      expect(flagged.map((p) => p.ref.dataIndex), [0, 2]);
    });

    test('centres a single point', () {
      final points = project({
        'a': const [_Point(7, 42)],
      });

      expect(points.single.position, const Offset(200, 150));
    });

    test('honours axis bounds', () {
      final points = project(
        {'a': _linear},
        xMin: 0,
        xMax: 4,
        yMin: 0,
        yMax: 40,
      );

      expect(points.first.position, const Offset(100, 225));
    });

    test('uses the position of a series in seriesIds as its index', () {
      final points = project({'a': _linear}, seriesIds: ['hidden', 'a']);

      expect(points.map((p) => p.ref.seriesIndex).toSet(), {1});
    });

    test('follows pan, and like the viewport ignores zoom', () {
      final panned = project(
        {'a': _linear},
        viewport: const OiChartViewport(
          size: Size(400, 300),
          panOffset: Offset(30, -10),
        ),
      );
      expect(panned.first.position, const Offset(30, 290));
      expect(panned.last.position, const Offset(430, -10));

      // The viewport's normalized space spans the plot at every zoom
      // level, which is also what the crosshair and brush work in.
      final plain = project({'a': _linear});
      final zoomed = project({
        'a': _linear,
      }, viewport: const OiChartViewport(size: Size(400, 300), zoomLevel: 2));
      expect(
        zoomed.map((p) => p.position),
        plain.map((p) => p.position).toList(),
      );
    });

    test('follows the plot bounds of the viewport', () {
      final points = project(
        {'a': _linear},
        viewport: const OiChartViewport(
          size: Size(400, 300),
          axisInsets: OiAxisInsets(left: 40, bottom: 20),
        ),
      );

      expect(points.first.position, const Offset(40, 280));
      expect(points.last.position, const Offset(400, 0));
    });
  });
}
