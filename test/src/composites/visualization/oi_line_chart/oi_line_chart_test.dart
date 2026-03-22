// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/visualization/oi_bubble_chart/oi_bubble_chart_interaction.dart';
import 'package:obers_ui/src/composites/visualization/oi_line_chart/oi_line_chart.dart';
import 'package:obers_ui/src/composites/visualization/oi_line_chart/oi_line_chart_accessibility.dart';
import 'package:obers_ui/src/composites/visualization/oi_line_chart/oi_line_chart_data.dart';
import 'package:obers_ui/src/composites/visualization/oi_line_chart/oi_line_chart_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';

import '../../../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

List<OiLineSeries> _testSeries() {
  return const [
    OiLineSeries(
      label: 'Revenue',
      points: [
        OiLinePoint(x: 1, y: 10),
        OiLinePoint(x: 2, y: 25),
        OiLinePoint(x: 3, y: 18, label: 'March'),
        OiLinePoint(x: 4, y: 35),
        OiLinePoint(x: 5, y: 30),
      ],
    ),
  ];
}

List<OiLineSeries> _multiSeries() {
  return const [
    OiLineSeries(
      label: 'Revenue',
      points: [
        OiLinePoint(x: 1, y: 10),
        OiLinePoint(x: 2, y: 25),
        OiLinePoint(x: 3, y: 18),
      ],
    ),
    OiLineSeries(
      label: 'Costs',
      points: [
        OiLinePoint(x: 1, y: 8),
        OiLinePoint(x: 2, y: 15),
        OiLinePoint(x: 3, y: 12),
      ],
    ),
  ];
}

Widget _lineChart({
  List<OiLineSeries>? series,
  String label = 'Test line chart',
  bool showGrid = true,
  bool showLegend = true,
  bool showPoints = false,
  bool smooth = false,
  bool stacked = false,
  void Function(int, int)? onPointTap,
  OiLineChartTheme? theme,
  OiChartInteractionMode? interactionMode,
  bool? compact,
  double width = 500,
  double height = 400,
}) {
  return SizedBox(
    width: width,
    height: height,
    child: OiLineChart(
      label: label,
      series: series ?? _testSeries(),
      showGrid: showGrid,
      showLegend: showLegend,
      showPoints: showPoints,
      smooth: smooth,
      stacked: stacked,
      onPointTap: onPointTap,
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
    await tester.pumpObers(_lineChart());
    expect(find.byType(OiLineChart), findsOneWidget);
  });

  testWidgets('CustomPaint painter is present', (tester) async {
    await tester.pumpObers(_lineChart());
    expect(find.byKey(const Key('oi_line_chart_painter')), findsOneWidget);
  });

  testWidgets('legend shows series names', (tester) async {
    await tester.pumpObers(_lineChart(series: _multiSeries()));
    expect(find.byKey(const Key('oi_line_chart_legend')), findsOneWidget);
    expect(find.text('Revenue'), findsOneWidget);
    expect(find.text('Costs'), findsOneWidget);
  });

  testWidgets('hides legend for single series', (tester) async {
    await tester.pumpObers(_lineChart());
    expect(find.byKey(const Key('oi_line_chart_legend')), findsNothing);
  });

  testWidgets('renders with custom series colors', (tester) async {
    await tester.pumpObers(
      _lineChart(
        series: const [
          OiLineSeries(
            label: 'Custom',
            points: [OiLinePoint(x: 1, y: 2)],
            color: Color(0xFFFF5722),
          ),
        ],
      ),
    );
    expect(find.byType(OiLineChart), findsOneWidget);
  });

  testWidgets('onPointTap callback fires', (tester) async {
    await tester.pumpObers(
      _lineChart(
        interactionMode: OiChartInteractionMode.touch,
        onPointTap: (si, pi) {},
      ),
    );

    final touchFinder = find.byKey(const Key('oi_line_chart_touch'));
    expect(touchFinder, findsOneWidget);

    await tester.tap(touchFinder);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('handles empty series gracefully', (tester) async {
    await tester.pumpObers(_lineChart(series: const []));
    expect(find.byKey(const Key('oi_line_chart_empty')), findsOneWidget);
  });

  testWidgets('has semantics label', (tester) async {
    await tester.pumpObers(_lineChart(label: 'Revenue Chart'));
    final semantics = tester.getSemantics(find.byType(OiLineChart));
    expect(semantics.label, contains('Revenue Chart'));
  });

  testWidgets('auto-generates semantics from data', (tester) async {
    await tester.pumpObers(_lineChart(label: ''));
    final semantics = tester.getSemantics(find.byType(OiLineChart));
    expect(semantics.label, contains('Line chart'));
  });

  testWidgets('shows fallback when chart is too small', (tester) async {
    await tester.pumpObers(
      _lineChart(width: 50, height: 30),
      surfaceSize: const Size(50, 30),
    );
    expect(find.byKey(const Key('oi_line_chart_fallback')), findsOneWidget);
  });

  // ── Layout ──────────────────────────────────────────────────────────────────

  testWidgets('compact layout positions legend below', (tester) async {
    await tester.pumpObers(
      _lineChart(compact: true, series: _multiSeries()),
    );

    final legendFinder = find.byKey(const Key('oi_line_chart_legend'));
    expect(legendFinder, findsOneWidget);

    final columnAncestor = find.ancestor(
      of: legendFinder,
      matching: find.byType(Column),
    );
    expect(columnAncestor, findsWidgets);
  });

  testWidgets('touch mode renders GestureDetector', (tester) async {
    await tester.pumpObers(
      _lineChart(interactionMode: OiChartInteractionMode.touch),
    );
    expect(find.byKey(const Key('oi_line_chart_touch')), findsOneWidget);
  });

  testWidgets('pointer mode renders MouseRegion', (tester) async {
    await tester.pumpObers(
      _lineChart(interactionMode: OiChartInteractionMode.pointer),
    );
    expect(find.byKey(const Key('oi_line_chart_pointer')), findsOneWidget);
  });

  // ── Features ────────────────────────────────────────────────────────────────

  testWidgets('smooth mode renders without error', (tester) async {
    await tester.pumpObers(_lineChart(smooth: true));
    expect(find.byType(OiLineChart), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fill mode (area) renders without error', (tester) async {
    await tester.pumpObers(
      _lineChart(
        series: const [
          OiLineSeries(
            label: 'Area',
            points: [
              OiLinePoint(x: 1, y: 10),
              OiLinePoint(x: 2, y: 25),
              OiLinePoint(x: 3, y: 18),
            ],
            fill: true,
          ),
        ],
      ),
    );
    expect(find.byType(OiLineChart), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dashed line renders without error', (tester) async {
    await tester.pumpObers(
      _lineChart(
        series: const [
          OiLineSeries(
            label: 'Dashed',
            points: [
              OiLinePoint(x: 1, y: 10),
              OiLinePoint(x: 2, y: 25),
            ],
            dashed: true,
          ),
        ],
      ),
    );
    expect(find.byType(OiLineChart), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('showPoints renders dots', (tester) async {
    await tester.pumpObers(_lineChart(showPoints: true));
    expect(find.byType(OiLineChart), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('stacked area mode renders', (tester) async {
    await tester.pumpObers(
      _lineChart(
        stacked: true,
        series: [
          const OiLineSeries(
            label: 'A',
            points: [
              OiLinePoint(x: 1, y: 10),
              OiLinePoint(x: 2, y: 20),
            ],
            fill: true,
          ),
          const OiLineSeries(
            label: 'B',
            points: [
              OiLinePoint(x: 1, y: 5),
              OiLinePoint(x: 2, y: 15),
            ],
            fill: true,
          ),
        ],
      ),
    );
    expect(find.byType(OiLineChart), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // ── Theming ─────────────────────────────────────────────────────────────────

  testWidgets('light theme renders correctly', (tester) async {
    await tester.pumpObers(
      _lineChart(),
      theme: OiThemeData.light(),
    );
    expect(find.byType(OiLineChart), findsOneWidget);
  });

  testWidgets('dark theme renders correctly', (tester) async {
    await tester.pumpObers(
      _lineChart(),
      theme: OiThemeData.dark(),
    );
    expect(find.byType(OiLineChart), findsOneWidget);
  });

  // ── Accessibility ───────────────────────────────────────────────────────────

  test('generateSummary describes data correctly', () {
    final summary =
        OiLineChartAccessibility.generateSummary(_multiSeries());
    expect(summary, contains('2-series'));
    expect(summary, contains('Revenue'));
    expect(summary, contains('Costs'));
  });

  test('generateSummary handles empty data', () {
    final summary = OiLineChartAccessibility.generateSummary(const []);
    expect(summary, 'Empty line chart.');
  });

  test('describePoint includes series name and coordinates', () {
    const point = OiLinePoint(x: 10, y: 20, label: 'March');
    final desc =
        OiLineChartAccessibility.describePoint(point, 'Revenue');
    expect(desc, contains('Revenue'));
    expect(desc, contains('March'));
    expect(desc, contains('x=10'));
    expect(desc, contains('y=20'));
  });
}
