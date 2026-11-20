import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/src/composites/_chart_nice_axis.dart';
import 'package:obers_ui_charts/src/composites/oi_bubble_chart/oi_bubble_chart_interaction.dart';
import 'package:obers_ui_charts/src/composites/oi_chart_axis.dart';
import 'package:obers_ui_charts/src/composites/oi_line_chart/oi_line_chart.dart';
import 'package:obers_ui_charts/src/composites/oi_line_chart/oi_line_chart_data.dart'
    show OiLineChartMode, OiLinePoint, OiLineSeries;
import 'package:obers_ui_charts/src/composites/oi_line_chart/oi_line_chart_layout.dart';
import 'package:obers_ui_charts/src/composites/oi_line_chart/oi_line_chart_painter.dart';

import '../../../helpers/pump_chart_app.dart';
import '../../../helpers/run_bounded.dart';

Widget _chart(
  List<OiLineSeries> series, {
  bool stacked = false,
  OiChartAxis<num>? yAxis,
  OiChartInteractionMode? interactionMode,
  void Function(int, int)? onPointTap,
}) {
  return Align(
    alignment: Alignment.topLeft,
    child: SizedBox(
      width: 500,
      height: 400,
      child: OiLineChart(
        label: 'Regression chart',
        series: series,
        stacked: stacked,
        yAxis: yAxis,
        interactionMode: interactionMode,
        onPointTap: onPointTap,
      ),
    ),
  );
}

OiLineChartPainter _painter(WidgetTester tester) {
  final paint = tester.widget<CustomPaint>(
    find.byKey(const Key('oi_line_chart_painter')),
  );
  return paint.painter! as OiLineChartPainter;
}

OiLineSeries _series(List<double> ys, {String label = 'a'}) => OiLineSeries(
  label: label,
  points: [
    for (var i = 0; i < ys.length; i++) OiLinePoint(x: i.toDouble(), y: ys[i]),
  ],
);

void main() {
  // ── Non-finite data ─────────────────────────────────────────────────────────

  group('non-finite data', () {
    testWidgets('a NaN point is left out of the range and the labels', (
      tester,
    ) async {
      await tester.pumpChartApp(
        _chart([
          _series([10, double.nan, 30]),
        ]),
      );

      final painter = _painter(tester);
      expect(painter.minY.isFinite, isTrue);
      expect(painter.maxY.isFinite, isTrue);
      expect(painter.minY, lessThanOrEqualTo(10));
      expect(painter.maxY, greaterThanOrEqualTo(30));
      expect(painter.yLabels, isNot(contains('NaN')));
      expect(tester.takeException(), isNull);
    });

    testWidgets('an infinite point does not break the build', (tester) async {
      await tester.pumpChartApp(
        _chart([
          _series([10, double.infinity, 30, double.negativeInfinity]),
        ]),
      );

      expect(tester.takeException(), isNull);
      final painter = _painter(tester);
      expect(painter.minY.isFinite, isTrue);
      expect(painter.maxY.isFinite, isTrue);
    });

    testWidgets('a non-finite x is ignored as well', (tester) async {
      await tester.pumpChartApp(
        _chart(const [
          OiLineSeries(
            label: 'a',
            points: [
              OiLinePoint(x: 0, y: 1),
              OiLinePoint(x: double.nan, y: 2),
              OiLinePoint(x: double.infinity, y: 3),
              OiLinePoint(x: 4, y: 5),
            ],
          ),
        ]),
      );

      expect(tester.takeException(), isNull);
      final painter = _painter(tester);
      expect(painter.minX, 0);
      expect(painter.maxX, 4);
    });

    testWidgets('a series with only non-finite points still renders', (
      tester,
    ) async {
      await tester.pumpChartApp(
        _chart([
          _series([double.nan, double.infinity]),
        ]),
      );

      expect(tester.takeException(), isNull);
      final painter = _painter(tester);
      expect(painter.minY.isFinite, isTrue);
      expect(painter.maxY.isFinite, isTrue);
    });

    test('non-finite points are not laid out', () {
      final layouts = layoutLineSeries(
        [
          const [
            OiLinePoint(x: 0, y: 0),
            OiLinePoint(x: 1, y: double.nan),
            OiLinePoint(x: 2, y: 10),
          ],
        ],
        chartRect: const Rect.fromLTWH(0, 0, 100, 100),
        minX: 0,
        maxX: 2,
        minY: 0,
        maxY: 10,
        stacked: false,
      );

      expect(layouts.single.points, [
        const Offset(0, 100),
        null,
        const Offset(100, 0),
      ]);
    });

    test('a missing point splits the series into segments', () {
      const a = Offset(0, 10);
      const b = Offset(10, 10);
      const c = Offset(30, 10);
      const base = Offset(0, 100);
      const layout = OiLineSeriesLayout(
        points: [null, a, b, null, null, c, null],
        baselines: [null, base, base, null, null, base, null],
      );

      final segments = splitLineSegments(layout);

      expect(segments.map((s) => s.points), [
        [a, b],
        [c],
      ]);
      expect(segments.map((s) => s.baselines), [
        [base, base],
        [base],
      ]);
      expect(
        splitLineSegments(
          const OiLineSeriesLayout(points: [null], baselines: [null]),
        ),
        isEmpty,
      );
    });

    for (final mode in OiLineChartMode.values) {
      test('${mode.name} lines leave a gap at a missing point', () {
        // Five points along the top of a 400x100 chart; the middle one is
        // missing, so nothing may be drawn between x = 100 and x = 300.
        final painter = OiLineChartPainter(
          resolvedSeries: const [
            ResolvedLineSeries(
              points: [
                OiLinePoint(x: 0, y: 10),
                OiLinePoint(x: 1, y: 10),
                OiLinePoint(x: 2, y: double.nan),
                OiLinePoint(x: 3, y: 10),
                OiLinePoint(x: 4, y: 10),
              ],
              color: Color(0xFFFF0000),
              strokeWidth: 2,
              dashed: false,
              fill: true,
              fillOpacity: 0.5,
              label: 'a',
            ),
          ],
          chartRect: const Rect.fromLTWH(0, 0, 400, 100),
          minX: 0,
          maxX: 4,
          minY: 0,
          maxY: 10,
          showGrid: false,
          gridColor: const Color(0xFF000000),
          axisLabelColor: const Color(0xFF000000),
          highContrast: false,
          compact: false,
          mode: mode,
          showPoints: false,
          stacked: false,
          xLabels: const [],
          yLabels: const [],
          xDivisions: 5,
          yDivisions: 5,
        );

        const underFirst = Offset(50, 50);
        const underGap = Offset(200, 50);
        const underSecond = Offset(350, 50);
        expect(
          (Canvas canvas) => painter.paint(canvas, const Size(400, 100)),
          paints
            ..path(
              style: PaintingStyle.fill,
              includes: [underFirst],
              excludes: [underGap, underSecond],
            )
            ..path(style: PaintingStyle.stroke)
            ..path(
              style: PaintingStyle.fill,
              includes: [underSecond],
              excludes: [underGap, underFirst],
            )
            ..path(style: PaintingStyle.stroke),
        );
      });
    }
  });

  test('a negative stack fills each series from the one below', () {
    // Two series at -1 on a -2..0 range in a 400x100 chart: zero is at
    // y = 0, -1 at y = 50 and -2 at y = 100. The first series fills 0..-1,
    // the second -1..-2, so they do not overlap.
    ResolvedLineSeries series(String label) => ResolvedLineSeries(
      points: const [OiLinePoint(x: 0, y: -1), OiLinePoint(x: 1, y: -1)],
      color: const Color(0xFFFF0000),
      strokeWidth: 2,
      dashed: false,
      fill: true,
      fillOpacity: 0.5,
      label: label,
    );
    final painter = OiLineChartPainter(
      resolvedSeries: [series('a'), series('b')],
      chartRect: const Rect.fromLTWH(0, 0, 400, 100),
      minX: 0,
      maxX: 1,
      minY: -2,
      maxY: 0,
      showGrid: false,
      gridColor: const Color(0xFF000000),
      axisLabelColor: const Color(0xFF000000),
      highContrast: false,
      compact: false,
      mode: OiLineChartMode.straight,
      showPoints: false,
      stacked: true,
      xLabels: const [],
      yLabels: const [],
      xDivisions: 5,
      yDivisions: 5,
    );

    const upperBand = Offset(200, 25);
    const lowerBand = Offset(200, 75);
    expect(
      (Canvas canvas) => painter.paint(canvas, const Size(400, 100)),
      paints
        ..path(
          style: PaintingStyle.fill,
          includes: [upperBand],
          excludes: [lowerBand],
        )
        ..path(style: PaintingStyle.stroke)
        ..path(
          style: PaintingStyle.fill,
          includes: [lowerBand],
          excludes: [upperBand],
        )
        ..path(style: PaintingStyle.stroke),
    );
  });

  // ── Stacked range ───────────────────────────────────────────────────────────

  group('stacked range', () {
    test('covers every cumulative value, not only the final total', () {
      final range = computeLineChartRange(const [
        [OiLinePoint(x: 0, y: 10)],
        [OiLinePoint(x: 0, y: -5)],
      ], stacked: true);

      // The first series is drawn at 10, the second on top of it at 5.
      expect(range.minY, 0);
      expect(range.maxY, 10);
    });

    test('an all-negative stack extends below zero', () {
      final range = computeLineChartRange(const [
        [OiLinePoint(x: 0, y: -5), OiLinePoint(x: 1, y: -1)],
        [OiLinePoint(x: 0, y: -5), OiLinePoint(x: 1, y: -1)],
      ], stacked: true);

      expect(range.minY, -10);
      expect(range.maxY, 0);
    });

    test('a positive stack still starts at zero', () {
      final range = computeLineChartRange(const [
        [OiLinePoint(x: 0, y: 10)],
        [OiLinePoint(x: 0, y: 10)],
      ], stacked: true);

      expect(range.minY, 0);
      expect(range.maxY, 20);
    });
  });

  // ── Round axis labels ───────────────────────────────────────────────────────

  group('y axis labels', () {
    testWidgets('are round numbers covering the data', (tester) async {
      await tester.pumpChartApp(
        _chart([
          _series([3.7, 12.9, 5]),
        ]),
      );

      final painter = _painter(tester);
      expect(painter.yLabels, ['2', '4', '6', '8', '10', '12', '14']);
      expect(painter.minY, 2);
      expect(painter.maxY, 14);
      // Grid lines stay aligned with the labels.
      expect(painter.yDivisions, painter.yLabels.length - 1);
    });

    testWidgets('use decimals when the step is below one', (tester) async {
      await tester.pumpChartApp(
        _chart([
          _series([0.12, 0.48]),
        ]),
      );

      final painter = _painter(tester);
      expect(painter.yLabels, ['0.1', '0.2', '0.3', '0.4', '0.5']);
    });

    testWidgets('keep an explicit axis range that is already round', (
      tester,
    ) async {
      await tester.pumpChartApp(
        _chart([
          _series([3.7, 12.9, 5]),
        ], yAxis: const OiChartAxis<num>(min: 0, max: 20)),
      );

      final painter = _painter(tester);
      expect(painter.minY, 0);
      expect(painter.maxY, 20);
      expect(painter.yLabels, ['0', '5', '10', '15', '20']);
    });

    testWidgets('respect an explicit axis range that is not round', (
      tester,
    ) async {
      await tester.pumpChartApp(
        _chart([
          _series([3.7, 12.9, 5]),
        ], yAxis: const OiChartAxis<num>(min: 3.3, max: 13.3)),
      );

      final painter = _painter(tester);
      expect(painter.minY, 3.3);
      expect(painter.maxY, 13.3);
      expect(painter.yLabels.first, '3.3');
      expect(painter.yLabels.last, '13.3');
    });

    testWidgets('respect explicit labels', (tester) async {
      await tester.pumpChartApp(
        _chart([
          _series([3.7, 12.9, 5]),
        ], yAxis: const OiChartAxis<num>(labels: ['low', 'high'])),
      );

      final painter = _painter(tester);
      expect(painter.yLabels, ['low', 'high']);
      expect(painter.minY, 3.7);
      expect(painter.maxY, 12.9);
    });

    testWidgets('use the axis format callback', (tester) async {
      await tester.pumpChartApp(
        _chart([
          _series([3.7, 12.9, 5]),
        ], yAxis: OiChartAxis<num>(format: (v) => '${v.toInt()} kg')),
      );

      final painter = _painter(tester);
      expect(painter.yLabels.first, '2 kg');
      expect(painter.yLabels.last, '14 kg');
    });
  });

  // A regression here never returns from build, which no test timeout can
  // interrupt. So the axis is first resolved on another isolate with a time
  // limit (see runBounded), and the chart is only built once that returned.
  group('y axis with huge values', () {
    for (final values in const [
      [1e19, 9e19],
      [1e22, 3e22],
      [1.7e308],
      [-1.7e308, 1.7e308],
    ]) {
      testWidgets('$values builds with a sane number of labels', (
        tester,
      ) async {
        final lo = values.reduce(math.min);
        final hi = values.reduce(math.max);
        final ticks = await tester.runAsync(
          () => runBounded(
            () => resolveNiceAxis(
              dataMin: lo,
              dataMax: hi,
              divisions: 5,
            )?.ticks.length,
          ),
        );
        expect(ticks, anyOf(isNull, inInclusiveRange(2, 15)));

        await tester.pumpChartApp(_chart([_series(values)]));

        expect(tester.takeException(), isNull);
        final painter = _painter(tester);
        expect(painter.yLabels.length, inInclusiveRange(2, 15));
        expect(painter.yDivisions, painter.yLabels.length - 1);
        expect(painter.minY.isFinite, isTrue);
        expect(painter.maxY.isFinite, isTrue);
        expect(painter.minY, lessThanOrEqualTo(lo));
        expect(painter.maxY, greaterThanOrEqualTo(hi));
      });
    }
  });

  // ── Stacked hit-testing ─────────────────────────────────────────────────────

  group('stacked hit-testing', () {
    testWidgets('a tap hits the series where it is drawn', (tester) async {
      final taps = <(int, int)>[];
      await tester.pumpChartApp(
        _chart(
          [
            _series([10, 10, 10]),
            _series([10, 10, 10], label: 'b'),
          ],
          stacked: true,
          interactionMode: OiChartInteractionMode.touch,
          onPointTap: (si, pi) => taps.add((si, pi)),
        ),
      );

      final painter = _painter(tester);
      final rect = painter.chartRect;
      final origin = tester.getTopLeft(
        find.byKey(const Key('oi_line_chart_touch')),
      );
      Offset at(double x, double y) =>
          origin +
          Offset(
            rect.left +
                rect.width * (x - painter.minX) / (painter.maxX - painter.minX),
            rect.bottom -
                rect.height *
                    (y - painter.minY) /
                    (painter.maxY - painter.minY),
          );

      // Series b sits on top of series a, so it is drawn at y = 20.
      await tester.tapAt(at(1, 20));
      expect(taps, [(1, 1)]);

      taps.clear();
      await tester.tapAt(at(1, 10));
      expect(taps, [(0, 1)]);

      // Nothing is drawn at the bottom of the chart.
      taps.clear();
      await tester.tapAt(at(1, 0));
      expect(taps, isEmpty);
    });

    test('layout stacks series and exposes the fill baseline', () {
      final layouts = layoutLineSeries(
        [
          const [OiLinePoint(x: 0, y: 10), OiLinePoint(x: 1, y: 10)],
          const [OiLinePoint(x: 0, y: 10), OiLinePoint(x: 1, y: 5)],
        ],
        chartRect: const Rect.fromLTWH(0, 0, 100, 100),
        minX: 0,
        maxX: 1,
        minY: 0,
        maxY: 20,
        stacked: true,
      );

      expect(layouts[0].points, [const Offset(0, 50), const Offset(100, 50)]);
      expect(layouts[0].baselines, [
        const Offset(0, 100),
        const Offset(100, 100),
      ]);
      expect(layouts[1].points, [Offset.zero, const Offset(100, 25)]);
      expect(layouts[1].baselines, layouts[0].points);
    });
  });

  // ── shouldRepaint ───────────────────────────────────────────────────────────

  group('OiLineChartPainter.shouldRepaint', () {
    OiLineChartPainter build({
      List<ResolvedLineSeries>? resolvedSeries,
      Rect chartRect = const Rect.fromLTWH(40, 20, 400, 300),
      double minX = 0,
      double maxX = 10,
      double minY = 0,
      double maxY = 100,
      bool showGrid = true,
      Color gridColor = const Color(0xFF111111),
      Color axisLabelColor = const Color(0xFF222222),
      bool highContrast = false,
      bool compact = false,
      OiLineChartMode mode = OiLineChartMode.straight,
      bool showPoints = false,
      bool stacked = false,
      List<String>? xLabels,
      List<String>? yLabels,
      int xDivisions = 5,
      int yDivisions = 5,
      int? hoveredSeriesIndex,
      int? hoveredPointIndex,
    }) {
      return OiLineChartPainter(
        resolvedSeries: resolvedSeries ?? [_resolved()],
        chartRect: chartRect,
        minX: minX,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        showGrid: showGrid,
        gridColor: gridColor,
        axisLabelColor: axisLabelColor,
        highContrast: highContrast,
        compact: compact,
        mode: mode,
        showPoints: showPoints,
        stacked: stacked,
        xLabels: xLabels ?? ['0', '10'],
        yLabels: yLabels ?? ['0', '100'],
        xDivisions: xDivisions,
        yDivisions: yDivisions,
        hoveredSeriesIndex: hoveredSeriesIndex,
        hoveredPointIndex: hoveredPointIndex,
      );
    }

    test('is false for equal input built from fresh lists', () {
      expect(build().shouldRepaint(build()), isFalse);
    });

    final variants = <String, OiLineChartPainter Function()>{
      'chartRect': () =>
          build(chartRect: const Rect.fromLTWH(40, 20, 401, 300)),
      'minX': () => build(minX: 1),
      'maxX': () => build(maxX: 11),
      'minY': () => build(minY: 1),
      'maxY': () => build(maxY: 101),
      'showGrid': () => build(showGrid: false),
      'gridColor': () => build(gridColor: const Color(0xFF333333)),
      'axisLabelColor': () => build(axisLabelColor: const Color(0xFF333333)),
      'highContrast': () => build(highContrast: true),
      'mode': () => build(mode: OiLineChartMode.smooth),
      'showPoints': () => build(showPoints: true),
      'stacked': () => build(stacked: true),
      'xLabels': () => build(xLabels: ['0', '11']),
      'yLabels': () => build(yLabels: ['0', '101']),
      'xDivisions': () => build(xDivisions: 4),
      'yDivisions': () => build(yDivisions: 4),
      'hoveredSeriesIndex': () => build(hoveredSeriesIndex: 0),
      'hoveredPointIndex': () => build(hoveredPointIndex: 0),
      'series count': () => build(resolvedSeries: [_resolved(), _resolved()]),
      'point value': () => build(resolvedSeries: [_resolved(lastY: 4)]),
      'series color': () =>
          build(resolvedSeries: [_resolved(color: const Color(0xFF00FF00))]),
      'series strokeWidth': () =>
          build(resolvedSeries: [_resolved(strokeWidth: 3)]),
      'series dashed': () => build(resolvedSeries: [_resolved(dashed: true)]),
      'series fill': () => build(resolvedSeries: [_resolved(fill: true)]),
      'series fillOpacity': () =>
          build(resolvedSeries: [_resolved(fillOpacity: 0.5)]),
    };

    for (final entry in variants.entries) {
      test('is true when ${entry.key} changes', () {
        expect(entry.value().shouldRepaint(build()), isTrue);
      });
    }
  });
}

ResolvedLineSeries _resolved({
  double lastY = 3,
  Color color = const Color(0xFFFF0000),
  double strokeWidth = 2,
  bool dashed = false,
  bool fill = false,
  double fillOpacity = 0.15,
}) {
  return ResolvedLineSeries(
    points: [
      const OiLinePoint(x: 0, y: 1),
      OiLinePoint(x: 10, y: lastY),
    ],
    color: color,
    strokeWidth: strokeWidth,
    dashed: dashed,
    fill: fill,
    fillOpacity: fillOpacity,
    label: 'a',
  );
}
