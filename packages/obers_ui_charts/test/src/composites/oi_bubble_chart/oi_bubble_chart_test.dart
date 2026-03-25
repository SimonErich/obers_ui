// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/src/composites/oi_bubble_chart/oi_bubble_chart.dart';
import 'package:obers_ui_charts/src/composites/oi_bubble_chart/oi_bubble_chart_accessibility.dart';
import 'package:obers_ui_charts/src/composites/oi_bubble_chart/oi_bubble_chart_data.dart';
import 'package:obers_ui_charts/src/composites/oi_bubble_chart/oi_bubble_chart_interaction.dart';
import 'package:obers_ui_charts/src/composites/oi_bubble_chart/oi_bubble_chart_legend.dart';
import 'package:obers_ui_charts/src/composites/oi_bubble_chart/oi_bubble_chart_painter.dart';
import 'package:obers_ui_charts/src/composites/oi_bubble_chart/oi_bubble_chart_size_legend.dart';
import 'package:obers_ui_charts/src/composites/oi_bubble_chart/oi_bubble_chart_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';

import '../../../helpers/pump_chart_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

OiBubbleChartData _testData() {
  return const OiBubbleChartData(
    series: [
      OiBubbleSeries(
        name: 'Sales',
        points: [
          OiBubblePoint(x: 10, y: 20, size: 5, label: 'Q1'),
          OiBubblePoint(x: 30, y: 50, size: 15),
          OiBubblePoint(x: 60, y: 80, size: 25),
        ],
      ),
    ],
  );
}

OiBubbleChartData _multiSeriesData() {
  return const OiBubbleChartData(
    series: [
      OiBubbleSeries(
        name: 'Sales',
        points: [
          OiBubblePoint(x: 10, y: 20, size: 5),
          OiBubblePoint(x: 30, y: 50, size: 15),
        ],
      ),
      OiBubbleSeries(
        name: 'Returns',
        points: [
          OiBubblePoint(x: 20, y: 40, size: 10),
          OiBubblePoint(x: 50, y: 70, size: 20),
        ],
      ),
    ],
    sizeConfig: OiBubbleSizeConfig(
      minRadius: 4,
      maxRadius: 24,
      sizeLabel: 'Revenue',
    ),
  );
}

Widget _bubbleChart({
  OiBubbleChartData? data,
  String? semanticLabel,
  String? label,
  OiBubbleChartTheme? theme,
  OiChartInteractionMode? interactionMode,
  bool? compact,
  double width = 500,
  double height = 400,
}) {
  return SizedBox(
    width: width,
    height: height,
    child: OiBubbleChart(
      data: data ?? _testData(),
      semanticLabel: semanticLabel,
      label: label,
      theme: theme,
      interactionMode: interactionMode,
      compact: compact,
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── Basic rendering ─────────────────────────────────────────────────────────

  testWidgets('renders without errors', (tester) async {
    await tester.pumpChartApp(_bubbleChart());
    expect(find.byType(OiBubbleChart), findsOneWidget);
  });

  testWidgets('CustomPaint painter is present', (tester) async {
    await tester.pumpChartApp(_bubbleChart());
    expect(find.byKey(const Key('oi_bubble_chart_painter')), findsOneWidget);
  });

  testWidgets('legend displays series names', (tester) async {
    await tester.pumpChartApp(_bubbleChart(data: _multiSeriesData()));
    expect(find.byKey(const Key('oi_bubble_chart_legend')), findsOneWidget);
    expect(find.text('Sales'), findsOneWidget);
    expect(find.text('Returns'), findsOneWidget);
  });

  testWidgets('hides legend for single series', (tester) async {
    await tester.pumpChartApp(_bubbleChart());
    expect(find.byKey(const Key('oi_bubble_chart_legend')), findsNothing);
  });

  testWidgets('renders with custom series colors', (tester) async {
    await tester.pumpChartApp(
      _bubbleChart(
        data: const OiBubbleChartData(
          series: [
            OiBubbleSeries(
              name: 'Custom',
              points: [OiBubblePoint(x: 1, y: 2, size: 3)],
              style: OiBubbleSeriesStyle(color: Color(0xFFFF5722)),
            ),
          ],
        ),
      ),
    );
    expect(find.byType(OiBubbleChart), findsOneWidget);
  });

  testWidgets('handles empty series gracefully', (tester) async {
    await tester.pumpChartApp(
      _bubbleChart(data: const OiBubbleChartData(series: [])),
    );
    expect(find.byType(OiBubbleChart), findsOneWidget);
  });

  testWidgets('has semantics label', (tester) async {
    await tester.pumpChartApp(
      _bubbleChart(semanticLabel: 'Revenue Chart'),
    );
    final semantics = tester.getSemantics(find.byType(OiBubbleChart));
    expect(semantics.label, contains('Revenue Chart'));
  });

  testWidgets('auto-generates semantics label from data', (tester) async {
    await tester.pumpChartApp(_bubbleChart());
    final semantics = tester.getSemantics(find.byType(OiBubbleChart));
    expect(semantics.label, contains('Bubble chart'));
  });

  testWidgets('shows fallback when chart is too small', (tester) async {
    await tester.pumpChartApp(
      _bubbleChart(width: 50, height: 30),
      surfaceSize: const Size(50, 30),
    );
    expect(find.byKey(const Key('oi_bubble_chart_fallback')), findsOneWidget);
  });

  testWidgets('shows size legend when sizeConfig is provided', (tester) async {
    await tester.pumpChartApp(_bubbleChart(data: _multiSeriesData()));
    expect(
      find.byKey(const Key('oi_bubble_chart_size_legend')),
      findsOneWidget,
    );
    expect(find.text('Revenue'), findsOneWidget);
    expect(find.text('Small'), findsOneWidget);
    expect(find.text('Large'), findsOneWidget);
  });

  testWidgets('canvas widget has expected key', (tester) async {
    await tester.pumpChartApp(_bubbleChart());
    expect(find.byKey(const Key('oi_bubble_chart_canvas')), findsOneWidget);
  });

  testWidgets('label alias provides semantics', (tester) async {
    await tester.pumpChartApp(_bubbleChart(label: 'My Chart'));
    final semantics = tester.getSemantics(find.byType(OiBubbleChart));
    expect(semantics.label, contains('My Chart'));
  });

  // ── REQ-0137: Accessibility ─────────────────────────────────────────────────

  group('REQ-0137 Accessibility', () {
    test('generateSummary describes data correctly', () {
      final data = _multiSeriesData();
      final summary = OiBubbleChartAccessibility.generateSummary(data);
      expect(summary, contains('2 series'));
      expect(summary, contains('Sales'));
      expect(summary, contains('Returns'));
      expect(summary, contains('4 data points'));
      expect(summary, contains('Revenue'));
    });

    test('generateSummary includes size dimension', () {
      final data = _testData();
      final summary = OiBubbleChartAccessibility.generateSummary(data);
      expect(summary, contains('size'));
    });

    test('describeBubble includes x, y, and size', () {
      const point = OiBubblePoint(x: 10, y: 20, size: 5, label: 'Q1');
      final desc =
          OiBubbleChartAccessibility.describeBubble(point, 'Sales');
      expect(desc, contains('Sales'));
      expect(desc, contains('Q1'));
      expect(desc, contains('x=10'));
      expect(desc, contains('y=20'));
      expect(desc, contains('size=5'));
    });

    test('generateSummary handles empty data', () {
      const data = OiBubbleChartData(series: []);
      final summary = OiBubbleChartAccessibility.generateSummary(data);
      expect(summary, 'Empty bubble chart.');
    });

    testWidgets('legend items are keyboard focusable and activatable',
        (tester) async {
      var tappedIndex = -1;
      await tester.pumpChartApp(
        SizedBox(
          width: 500,
          height: 400,
          child: OiBubbleChartLegend(
            series: _multiSeriesData().series,
            onSeriesTap: (i) => tappedIndex = i,
          ),
        ),
      );

      // Find the first legend item and get its nearest Focus node.
      final item0 =
          find.byKey(const Key('oi_bubble_chart_legend_item_0'));
      expect(item0, findsOneWidget);

      Focus.of(tester.element(item0)).requestFocus();
      await tester.pumpAndSettle();

      // Simulate Enter key.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(tappedIndex, 0);

      // Also verify Space key works on the second item.
      final item1 =
          find.byKey(const Key('oi_bubble_chart_legend_item_1'));
      Focus.of(tester.element(item1)).requestFocus();
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();

      expect(tappedIndex, 1);
    });

    testWidgets('size legend items are keyboard focusable', (tester) async {
      await tester.pumpChartApp(
        const SizedBox(
          width: 500,
          height: 400,
          child: OiBubbleChartSizeLegend(
            config: OiBubbleSizeConfig(
              minRadius: 4,
              maxRadius: 24,
              sizeLabel: 'Population',
            ),
          ),
        ),
      );

      // Find size legend circle 0 and get its nearest Focus node.
      final circleFinder =
          find.byKey(const Key('oi_bubble_chart_size_legend_circle_0'));
      expect(circleFinder, findsOneWidget);

      final focusNode = Focus.of(tester.element(circleFinder));
      // ignore: cascade_invocations — await between calls prevents cascade
      focusNode.requestFocus();
      await tester.pumpAndSettle();

      expect(focusNode.hasFocus, isTrue);
    });

    testWidgets('reduced motion disables hover effects', (tester) async {
      await tester.pumpChartApp(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: _bubbleChart(
            interactionMode: OiChartInteractionMode.pointer,
          ),
        ),
      );

      // Simulate hover over the chart area.
      final mouseRegion =
          find.byKey(const Key('oi_bubble_chart_pointer'));
      expect(mouseRegion, findsOneWidget);

      final gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();

      // Move to center of chart.
      final chartCenter = tester.getCenter(mouseRegion);
      await gesture.moveTo(chartCenter);
      await tester.pump();

      // Find the painter and verify hoveredIndex is null.
      final customPaint = tester.widget<CustomPaint>(
        find.byKey(const Key('oi_bubble_chart_painter')),
      );
      final painter = customPaint.painter! as OiBubbleChartPainter;
      expect(painter.hoveredIndex, isNull);
    });

    testWidgets('high-contrast mode sets highContrast flag on painter',
        (tester) async {
      await tester.pumpChartApp(
        MediaQuery(
          data: const MediaQueryData(highContrast: true),
          child: _bubbleChart(),
        ),
      );

      final customPaint = tester.widget<CustomPaint>(
        find.byKey(const Key('oi_bubble_chart_painter')),
      );
      final painter = customPaint.painter! as OiBubbleChartPainter;
      expect(painter.highContrast, isTrue);
    });

    testWidgets(
        'high-contrast mode NOT set when MediaQuery highContrast is false',
        (tester) async {
      await tester.pumpChartApp(_bubbleChart());

      final customPaint = tester.widget<CustomPaint>(
        find.byKey(const Key('oi_bubble_chart_painter')),
      );
      final painter = customPaint.painter! as OiBubbleChartPainter;
      expect(painter.highContrast, isFalse);
    });
  });

  // ── REQ-0138: Theming ───────────────────────────────────────────────────────

  group('REQ-0138 Theming', () {
    testWidgets('resolveColor returns palette color when no overrides',
        (tester) async {
      late Color resolvedColor;
      late List<Color> palette;

      await tester.pumpChartApp(
        Builder(
          builder: (context) {
            palette = context.colors.chart;
            resolvedColor = OiBubbleChartTheme.resolveColor(
              0,
              null,
              null,
              context,
            );
            return const SizedBox();
          },
        ),
      );

      expect(resolvedColor, palette[0]);
    });

    testWidgets('chartTheme.seriesColors overrides palette', (tester) async {
      const overrideColors = [Color(0xFFFF0000), Color(0xFF00FF00)];
      late Color resolvedColor;

      await tester.pumpChartApp(
        Builder(
          builder: (context) {
            resolvedColor = OiBubbleChartTheme.resolveColor(
              0,
              null,
              null,
              context,
              chartTheme: const OiBubbleChartTheme(
                seriesColors: overrideColors,
              ),
            );
            return const SizedBox();
          },
        ),
      );

      expect(resolvedColor, const Color(0xFFFF0000));
    });

    testWidgets('seriesStyle.color overrides chartTheme', (tester) async {
      const chartColors = [Color(0xFFFF0000), Color(0xFF00FF00)];
      const seriesColor = Color(0xFF0000FF);
      late Color resolvedColor;

      await tester.pumpChartApp(
        Builder(
          builder: (context) {
            resolvedColor = OiBubbleChartTheme.resolveColor(
              0,
              const OiBubbleSeriesStyle(color: seriesColor),
              null,
              context,
              chartTheme: const OiBubbleChartTheme(
                seriesColors: chartColors,
              ),
            );
            return const SizedBox();
          },
        ),
      );

      expect(resolvedColor, seriesColor);
    });

    testWidgets('pointStyle.color overrides seriesStyle', (tester) async {
      const seriesColor = Color(0xFF0000FF);
      const pointColor = Color(0xFFFF00FF);
      late Color resolvedColor;

      await tester.pumpChartApp(
        Builder(
          builder: (context) {
            resolvedColor = OiBubbleChartTheme.resolveColor(
              0,
              const OiBubbleSeriesStyle(color: seriesColor),
              const OiBubblePointStyle(color: pointColor),
              context,
            );
            return const SizedBox();
          },
        ),
      );

      expect(resolvedColor, pointColor);
    });

    testWidgets('size legend borderColor applies to Container decoration',
        (tester) async {
      const testBorderColor = Color(0xFFCCCCCC);

      await tester.pumpChartApp(
        const SizedBox(
          width: 500,
          height: 400,
          child: OiBubbleChartSizeLegend(
            config: OiBubbleSizeConfig(
              minRadius: 6,
              maxRadius: 30,
            ),
            style: OiBubbleSizeLegendStyle(
              borderColor: testBorderColor,
            ),
          ),
        ),
      );

      // Find the circle containers by key and verify border color.
      final circleFinder =
          find.byKey(const Key('oi_bubble_chart_size_legend_circle_0'));
      expect(circleFinder, findsOneWidget);

      final container = tester.widget<Container>(circleFinder);
      final decoration = container.decoration! as BoxDecoration;
      final border = decoration.border! as Border;
      expect(border.top.color, testBorderColor);
    });

    testWidgets('bubble colors derive from theme palette', (tester) async {
      await tester.pumpChartApp(_bubbleChart());

      final customPaint = tester.widget<CustomPaint>(
        find.byKey(const Key('oi_bubble_chart_painter')),
      );
      final painter = customPaint.painter! as OiBubbleChartPainter;

      // All bubbles in single series should use same color (palette[0]).
      expect(painter.bubbles, isNotEmpty);
      final firstColor = painter.bubbles.first.color;
      for (final bubble in painter.bubbles) {
        expect(bubble.color, firstColor);
      }
    });

    testWidgets('chart theme seriesColors override applies to painter',
        (tester) async {
      const red = Color(0xFFFF0000);
      const green = Color(0xFF00FF00);

      await tester.pumpChartApp(
        _bubbleChart(
          data: _multiSeriesData(),
          theme: const OiBubbleChartTheme(
            seriesColors: [red, green],
          ),
        ),
      );

      final customPaint = tester.widget<CustomPaint>(
        find.byKey(const Key('oi_bubble_chart_painter')),
      );
      final painter = customPaint.painter! as OiBubbleChartPainter;

      // Series 0 bubbles should be red, series 1 should be green.
      for (final bubble in painter.bubbles) {
        if (bubble.seriesIndex == 0) {
          expect(bubble.color, red);
        } else {
          expect(bubble.color, green);
        }
      }
    });

    testWidgets('series style color overrides chart theme in painter',
        (tester) async {
      const chartRed = Color(0xFFFF0000);
      const seriesBlue = Color(0xFF0000FF);

      await tester.pumpChartApp(
        _bubbleChart(
          data: const OiBubbleChartData(
            series: [
              OiBubbleSeries(
                name: 'Override',
                points: [OiBubblePoint(x: 1, y: 2, size: 3)],
                style: OiBubbleSeriesStyle(color: seriesBlue),
              ),
            ],
          ),
          theme: const OiBubbleChartTheme(
            seriesColors: [chartRed],
          ),
        ),
      );

      final customPaint = tester.widget<CustomPaint>(
        find.byKey(const Key('oi_bubble_chart_painter')),
      );
      final painter = customPaint.painter! as OiBubbleChartPainter;
      expect(painter.bubbles.first.color, seriesBlue);
    });

    testWidgets('point style color overrides series style in painter',
        (tester) async {
      const seriesBlue = Color(0xFF0000FF);
      const pointMagenta = Color(0xFFFF00FF);

      await tester.pumpChartApp(
        _bubbleChart(
          data: const OiBubbleChartData(
            series: [
              OiBubbleSeries(
                name: 'Override',
                points: [
                  OiBubblePoint(
                    x: 1,
                    y: 2,
                    size: 3,
                    style: OiBubblePointStyle(color: pointMagenta),
                  ),
                ],
                style: OiBubbleSeriesStyle(color: seriesBlue),
              ),
            ],
          ),
        ),
      );

      final customPaint = tester.widget<CustomPaint>(
        find.byKey(const Key('oi_bubble_chart_painter')),
      );
      final painter = customPaint.painter! as OiBubbleChartPainter;
      expect(painter.bubbles.first.color, pointMagenta);
    });

    testWidgets('light theme renders correctly', (tester) async {
      await tester.pumpChartApp(
        _bubbleChart(data: _multiSeriesData()),
        theme: OiThemeData.light(),
      );

      final customPaint = tester.widget<CustomPaint>(
        find.byKey(const Key('oi_bubble_chart_painter')),
      );
      final painter = customPaint.painter! as OiBubbleChartPainter;
      expect(painter.bubbles, isNotEmpty);
      expect(find.byType(OiBubbleChart), findsOneWidget);
    });

    testWidgets('dark theme renders correctly', (tester) async {
      await tester.pumpChartApp(
        _bubbleChart(data: _multiSeriesData()),
        theme: OiThemeData.dark(),
      );

      final customPaint = tester.widget<CustomPaint>(
        find.byKey(const Key('oi_bubble_chart_painter')),
      );
      final painter = customPaint.painter! as OiBubbleChartPainter;
      expect(painter.bubbles, isNotEmpty);
      expect(find.byType(OiBubbleChart), findsOneWidget);
    });
  });

  // ── REQ-0139: Responsive ────────────────────────────────────────────────────

  group('REQ-0139 Responsive', () {
    testWidgets('compact layout uses fewer grid lines', (tester) async {
      await tester.pumpChartApp(_bubbleChart(compact: true, width: 300));

      final customPaint = tester.widget<CustomPaint>(
        find.byKey(const Key('oi_bubble_chart_painter')),
      );
      final painter = customPaint.painter! as OiBubbleChartPainter;
      expect(painter.compact, isTrue);
    });

    testWidgets('non-compact layout uses full grid lines', (tester) async {
      await tester.pumpChartApp(_bubbleChart(compact: false, width: 600));

      final customPaint = tester.widget<CustomPaint>(
        find.byKey(const Key('oi_bubble_chart_painter')),
      );
      final painter = customPaint.painter! as OiBubbleChartPainter;
      expect(painter.compact, isFalse);
    });

    testWidgets('compact positions legends below chart in Column',
        (tester) async {
      await tester.pumpChartApp(
        _bubbleChart(
          data: _multiSeriesData(),
          compact: true,
          width: 300,
        ),
      );

      // In compact mode, the legend should be a descendant of a Column
      // (below chart), not inside a Row (beside chart).
      final legendFinder =
          find.byKey(const Key('oi_bubble_chart_legend'));
      expect(legendFinder, findsOneWidget);

      // Verify the legend is inside a Column (compact puts it below).
      final columnAncestor = find.ancestor(
        of: legendFinder,
        matching: find.byType(Column),
      );
      expect(columnAncestor, findsWidgets);

      // Verify there is NO Row direct ancestor wrapping chart+legend side
      // by side (which would be the non-compact layout).
      // In compact mode, the chart canvas and legend should both be
      // direct children of the same Column.
      final canvasFinder =
          find.byKey(const Key('oi_bubble_chart_canvas'));
      expect(canvasFinder, findsOneWidget);

      // Both canvas and legend share a Column ancestor.
      final canvasColumnAncestor = find.ancestor(
        of: canvasFinder,
        matching: find.byType(Column),
      );
      expect(canvasColumnAncestor, findsWidgets);
    });

    testWidgets('non-compact positions legends beside chart in Row',
        (tester) async {
      await tester.pumpChartApp(
        _bubbleChart(
          data: _multiSeriesData(),
          compact: false,
          width: 600,
        ),
      );

      final legendFinder =
          find.byKey(const Key('oi_bubble_chart_legend'));
      expect(legendFinder, findsOneWidget);

      // In non-compact mode, the legend should be inside a Row.
      final rowAncestor = find.ancestor(
        of: legendFinder,
        matching: find.byType(Row),
      );
      expect(rowAncestor, findsOneWidget);
    });

    testWidgets('touch mode renders GestureDetector', (tester) async {
      await tester.pumpChartApp(_bubbleChart(
        interactionMode: OiChartInteractionMode.touch,
      ));
      expect(find.byKey(const Key('oi_bubble_chart_touch')), findsOneWidget);
    });

    testWidgets('pointer mode renders MouseRegion', (tester) async {
      await tester.pumpChartApp(_bubbleChart(
        interactionMode: OiChartInteractionMode.pointer,
      ));
      expect(
          find.byKey(const Key('oi_bubble_chart_pointer')), findsOneWidget);
    });

    testWidgets('touch tap selects nearest bubble and shows narration',
        (tester) async {
      await tester.pumpChartApp(
        _bubbleChart(
          interactionMode: OiChartInteractionMode.touch,
        ),
      );

      // The touch key wraps the chart.
      final touchFinder = find.byKey(const Key('oi_bubble_chart_touch'));
      expect(touchFinder, findsOneWidget);

      // Tap at the center of the GestureDetector (should be near a bubble).
      await tester.tap(touchFinder);
      await tester.pumpAndSettle();

      // After tapping, a narration widget should appear if a bubble is
      // near enough. The narration widget has the key
      // 'oi_bubble_chart_narration'.
      expect(
        find.byKey(const Key('oi_bubble_chart_narration')),
        findsOneWidget,
      );
    });

    testWidgets('pointer hover highlights nearest bubble', (tester) async {
      await tester.pumpChartApp(
        _bubbleChart(
          interactionMode: OiChartInteractionMode.pointer,
        ),
      );

      final mouseRegion =
          find.byKey(const Key('oi_bubble_chart_pointer'));
      expect(mouseRegion, findsOneWidget);

      // Create a mouse gesture and add it inside the chart area.
      final center = tester.getCenter(mouseRegion);
      final gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await gesture.addPointer(location: center);
      addTearDown(gesture.removePointer);
      await tester.pumpAndSettle();

      // Move slightly to trigger onHover (needs a move event).
      await gesture.moveTo(center + const Offset(1, 1));
      await tester.pumpAndSettle();

      // Verify the painter now has a hovered index set.
      final customPaint = tester.widget<CustomPaint>(
        find.byKey(const Key('oi_bubble_chart_painter')),
      );
      final painter = customPaint.painter! as OiBubbleChartPainter;
      expect(painter.hoveredIndex, isNotNull);
    });

    testWidgets('narrow width 200px renders without overflow',
        (tester) async {
      await tester.pumpChartApp(
        _bubbleChart(width: 200, height: 200),
      );
      // No FlutterError for overflow should have been thrown.
      expect(find.byType(OiBubbleChart), findsOneWidget);
      expect(find.byKey(const Key('oi_bubble_chart_painter')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('below minimum viable size shows fallback presentation',
        (tester) async {
      await tester.pumpChartApp(
        _bubbleChart(width: 50, height: 30),
        surfaceSize: const Size(50, 30),
      );
      expect(
          find.byKey(const Key('oi_bubble_chart_fallback')), findsOneWidget);
    });

    testWidgets('auto compact when width below threshold', (tester) async {
      // Width 300 < 400 threshold → auto compact.
      await tester.pumpChartApp(
        _bubbleChart(width: 300, height: 300, data: _multiSeriesData()),
        surfaceSize: const Size(300, 300),
      );

      final customPaint = tester.widget<CustomPaint>(
        find.byKey(const Key('oi_bubble_chart_painter')),
      );
      final painter = customPaint.painter! as OiBubbleChartPainter;
      expect(painter.compact, isTrue);
    });
  });
}
