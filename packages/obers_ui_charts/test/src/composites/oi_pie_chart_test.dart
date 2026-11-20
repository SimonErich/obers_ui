// Tests do not require documentation comments.

import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';
import 'package:obers_ui_charts/src/composites/oi_bubble_chart/oi_bubble_chart_interaction.dart';
import 'package:obers_ui_charts/src/composites/oi_pie_chart.dart';

import '../../helpers/pump_chart_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

const _testSegments = [
  OiPieSegment(label: 'Alpha', value: 40),
  OiPieSegment(label: 'Beta', value: 30),
  OiPieSegment(label: 'Gamma', value: 20),
  OiPieSegment(label: 'Delta', value: 10),
];

Widget _pieChart({
  List<OiPieSegment> segments = _testSegments,
  String label = 'Test pie chart',
  bool donut = false,
  double donutWidth = 0.4,
  String? centerLabel,
  bool showLabels = true,
  bool showPercentages = true,
  bool showValues = false,
  bool showLegend = true,
  ValueChanged<int>? onSegmentTap,
  OiChartInteractionMode? interactionMode,
  bool? compact,
  double width = 500,
  double height = 400,
}) {
  return SizedBox(
    width: width,
    height: height,
    child: OiPieChart(
      label: label,
      segments: segments,
      donut: donut,
      donutWidth: donutWidth,
      centerLabel: centerLabel,
      showLabels: showLabels,
      showPercentages: showPercentages,
      showValues: showValues,
      showLegend: showLegend,
      onSegmentTap: onSegmentTap,
      interactionMode: interactionMode,
      compact: compact,
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  testWidgets('renders without errors', (tester) async {
    await tester.pumpChartApp(_pieChart());
    expect(find.byType(OiPieChart), findsOneWidget);
  });

  testWidgets('CustomPaint painter is present', (tester) async {
    await tester.pumpChartApp(_pieChart());
    expect(find.byKey(const Key('oi_pie_chart_painter')), findsOneWidget);
  });

  testWidgets('legend shows segment labels', (tester) async {
    await tester.pumpChartApp(_pieChart());
    expect(find.byKey(const Key('oi_pie_chart_legend')), findsOneWidget);
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);
    expect(find.text('Gamma'), findsOneWidget);
    expect(find.text('Delta'), findsOneWidget);
  });

  testWidgets('hides legend when showLegend is false', (tester) async {
    await tester.pumpChartApp(_pieChart(showLegend: false));
    expect(find.byKey(const Key('oi_pie_chart_legend')), findsNothing);
  });

  testWidgets('custom colors applied', (tester) async {
    await tester.pumpChartApp(
      _pieChart(
        segments: const [
          OiPieSegment(label: 'Custom', value: 100, color: Color(0xFFFF5722)),
        ],
      ),
    );
    expect(find.byType(OiPieChart), findsOneWidget);
  });

  testWidgets('onSegmentTap fires with correct index', (tester) async {
    var tappedIndex = -1;
    await tester.pumpChartApp(
      _pieChart(
        interactionMode: OiChartInteractionMode.touch,
        onSegmentTap: (i) => tappedIndex = i,
      ),
    );

    final touchFinder = find.byKey(const Key('oi_pie_chart_touch'));
    expect(touchFinder, findsOneWidget);

    // Tap center of the chart (should hit a segment).
    await tester.tap(touchFinder);
    await tester.pumpAndSettle();

    expect(tappedIndex, greaterThanOrEqualTo(0));
  });

  testWidgets('empty segments returns SizedBox.shrink', (tester) async {
    await tester.pumpChartApp(_pieChart(segments: const []));
    expect(find.byKey(const Key('oi_pie_chart_empty')), findsOneWidget);
  });

  testWidgets('has semantics label', (tester) async {
    await tester.pumpChartApp(_pieChart(label: 'Market share'));
    final semantics = tester.getSemantics(find.byType(OiPieChart));
    expect(semantics.label, contains('Market share'));
  });

  testWidgets('donut mode renders', (tester) async {
    await tester.pumpChartApp(_pieChart(donut: true));
    expect(find.byType(OiPieChart), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('center label displays in donut', (tester) async {
    await tester.pumpChartApp(
      _pieChart(donut: true, centerLabel: 'Total: 100'),
    );
    expect(find.byKey(const Key('oi_pie_chart_center_label')), findsOneWidget);
    expect(find.text('Total: 100'), findsOneWidget);
  });

  testWidgets('showValues displays values', (tester) async {
    await tester.pumpChartApp(_pieChart(showValues: true));
    expect(find.byType(OiPieChart), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('legend is positioned below chart in Column', (tester) async {
    await tester.pumpChartApp(_pieChart());

    final legendFinder = find.byKey(const Key('oi_pie_chart_legend'));
    expect(legendFinder, findsOneWidget);

    // Legend should be inside a Column (below chart).
    final columnAncestor = find.ancestor(
      of: legendFinder,
      matching: find.byType(Column),
    );
    expect(columnAncestor, findsWidgets);
  });

  testWidgets('light theme renders correctly', (tester) async {
    await tester.pumpChartApp(_pieChart(), theme: OiThemeData.light());
    expect(find.byType(OiPieChart), findsOneWidget);
  });

  testWidgets('dark theme renders correctly', (tester) async {
    await tester.pumpChartApp(_pieChart(), theme: OiThemeData.dark());
    expect(find.byType(OiPieChart), findsOneWidget);
  });

  testWidgets('touch mode renders GestureDetector', (tester) async {
    await tester.pumpChartApp(
      _pieChart(interactionMode: OiChartInteractionMode.touch),
    );
    expect(find.byKey(const Key('oi_pie_chart_touch')), findsOneWidget);
  });

  testWidgets('pointer mode renders MouseRegion', (tester) async {
    await tester.pumpChartApp(
      _pieChart(interactionMode: OiChartInteractionMode.pointer),
    );
    expect(find.byKey(const Key('oi_pie_chart_pointer')), findsOneWidget);
  });

  // ── Invalid segment values ──────────────────────────────────────────────────

  group('invalid segment values', () {
    // Donut mode draws each segment with drawArc, which the paints matcher
    // can observe.
    Widget donut(List<OiPieSegment> segments) => _pieChart(
      segments: segments,
      donut: true,
      showLabels: false,
      showPercentages: false,
    );

    final painter = find.byKey(const Key('oi_pie_chart_painter'));

    testWidgets('a negative segment takes no share of the circle', (
      tester,
    ) async {
      await tester.pumpChartApp(
        donut(const [
          OiPieSegment(label: 'a', value: 10),
          OiPieSegment(label: 'b', value: -5),
        ]),
      );

      expect(painter, paints..arc(sweepAngle: 2 * math.pi));
      expect(
        painter,
        isNot(
          paints
            ..arc()
            ..arc(),
        ),
      );
    });

    testWidgets('a NaN segment takes no share of the circle', (tester) async {
      await tester.pumpChartApp(
        donut(const [
          OiPieSegment(label: 'a', value: 10),
          OiPieSegment(label: 'b', value: double.nan),
          OiPieSegment(label: 'c', value: 10),
        ]),
      );

      expect(
        painter,
        paints
          ..arc(sweepAngle: math.pi)
          ..arc(sweepAngle: math.pi),
      );
      expect(
        painter,
        isNot(
          paints
            ..arc()
            ..arc()
            ..arc(),
        ),
      );
    });

    testWidgets('an infinite segment takes no share of the circle', (
      tester,
    ) async {
      await tester.pumpChartApp(
        donut(const [
          OiPieSegment(label: 'a', value: 10),
          OiPieSegment(label: 'b', value: double.infinity),
        ]),
      );

      expect(painter, paints..arc(sweepAngle: 2 * math.pi));
      expect(tester.takeException(), isNull);
    });

    /// Taps at [angle] radians clockwise from the top of the pie.
    Future<void> tapAtAngle(WidgetTester tester, double angle) async {
      final center = tester.getCenter(
        find.byKey(const Key('oi_pie_chart_touch')),
      );
      await tester.tapAt(
        center + Offset(math.sin(angle), -math.cos(angle)) * 100,
      );
    }

    testWidgets('hit-testing skips a negative segment', (tester) async {
      final taps = <int>[];
      await tester.pumpChartApp(
        _pieChart(
          segments: const [
            OiPieSegment(label: 'a', value: 10),
            OiPieSegment(label: 'b', value: -5),
            OiPieSegment(label: 'c', value: 10),
          ],
          interactionMode: OiChartInteractionMode.touch,
          onSegmentTap: taps.add,
        ),
      );

      // a covers the right half, c the left half.
      await tapAtAngle(tester, 0.5 * math.pi);
      await tapAtAngle(tester, 1.2 * math.pi);
      expect(taps, [0, 2]);
    });

    testWidgets('hit-testing skips a NaN segment', (tester) async {
      final taps = <int>[];
      await tester.pumpChartApp(
        _pieChart(
          segments: const [
            OiPieSegment(label: 'a', value: 10),
            OiPieSegment(label: 'b', value: double.nan),
            OiPieSegment(label: 'c', value: 10),
          ],
          interactionMode: OiChartInteractionMode.touch,
          onSegmentTap: taps.add,
        ),
      );

      await tapAtAngle(tester, 0.5 * math.pi);
      await tapAtAngle(tester, 1.5 * math.pi);
      expect(taps, [0, 2]);
    });
  });
}
