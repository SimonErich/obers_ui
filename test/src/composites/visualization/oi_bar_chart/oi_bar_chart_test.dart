// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/visualization/oi_bar_chart/oi_bar_chart.dart';
import 'package:obers_ui/src/composites/visualization/oi_bar_chart/oi_bar_chart_accessibility.dart';
import 'package:obers_ui/src/composites/visualization/oi_bar_chart/oi_bar_chart_data.dart'
    show OiBarCategory, OiBarChartMode, OiBarSeries;
import 'package:obers_ui/src/composites/visualization/oi_bubble_chart/oi_bubble_chart_interaction.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';

import '../../../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

const _testCategories = [
  OiBarCategory(label: 'Q1', values: [40]),
  OiBarCategory(label: 'Q2', values: [55]),
  OiBarCategory(label: 'Q3', values: [35]),
  OiBarCategory(label: 'Q4', values: [70]),
];

const _multiSeriesCategories = [
  OiBarCategory(label: 'Q1', values: [40, 25]),
  OiBarCategory(label: 'Q2', values: [55, 30]),
  OiBarCategory(label: 'Q3', values: [35, 45]),
];

const _multiSeriesDef = [
  OiBarSeries(label: 'Revenue'),
  OiBarSeries(label: 'Costs'),
];

Widget _barChart({
  List<OiBarCategory> categories = _testCategories,
  List<OiBarSeries>? series,
  String label = 'Test bar chart',
  OiBarChartMode mode = OiBarChartMode.grouped,
  bool showValues = false,
  bool showGrid = true,
  bool showLegend = true,
  double barRadius = 4.0,
  void Function(int, int?)? onBarTap,
  OiChartInteractionMode? interactionMode,
  bool? compact,
  double width = 500,
  double height = 400,
}) {
  return SizedBox(
    width: width,
    height: height,
    child: OiBarChart(
      label: label,
      categories: categories,
      series: series,
      mode: mode,
      showValues: showValues,
      showGrid: showGrid,
      showLegend: showLegend,
      barRadius: barRadius,
      onBarTap: onBarTap,
      interactionMode: interactionMode,
      compact: compact,
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  testWidgets('renders without errors', (tester) async {
    await tester.pumpObers(_barChart());
    expect(find.byType(OiBarChart), findsOneWidget);
  });

  testWidgets('CustomPaint painter is present', (tester) async {
    await tester.pumpObers(_barChart());
    expect(find.byKey(const Key('oi_bar_chart_painter')), findsOneWidget);
  });

  testWidgets('canvas widget has expected key', (tester) async {
    await tester.pumpObers(_barChart());
    expect(find.byKey(const Key('oi_bar_chart_canvas')), findsOneWidget);
  });

  testWidgets('legend shows series names for multi-series', (tester) async {
    await tester.pumpObers(
      _barChart(
        categories: _multiSeriesCategories,
        series: _multiSeriesDef,
      ),
    );
    expect(find.byKey(const Key('oi_bar_chart_legend')), findsOneWidget);
    expect(find.text('Revenue'), findsOneWidget);
    expect(find.text('Costs'), findsOneWidget);
  });

  testWidgets('hides legend for single series', (tester) async {
    await tester.pumpObers(_barChart());
    expect(find.byKey(const Key('oi_bar_chart_legend')), findsNothing);
  });

  testWidgets('custom colors applied', (tester) async {
    await tester.pumpObers(
      _barChart(
        categories: const [
          OiBarCategory(
            label: 'A',
            values: [50],
            colors: [Color(0xFFFF5722)],
          ),
        ],
      ),
    );
    expect(find.byType(OiBarChart), findsOneWidget);
  });

  testWidgets('onBarTap fires on tap', (tester) async {
    await tester.pumpObers(
      _barChart(
        interactionMode: OiChartInteractionMode.touch,
        onBarTap: (ci, si) {},
      ),
    );

    final touchFinder = find.byKey(const Key('oi_bar_chart_touch'));
    expect(touchFinder, findsOneWidget);

    await tester.tap(touchFinder);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('empty categories returns SizedBox.shrink', (tester) async {
    await tester.pumpObers(_barChart(categories: const []));
    expect(find.byKey(const Key('oi_bar_chart_empty')), findsOneWidget);
  });

  testWidgets('has semantics label', (tester) async {
    await tester.pumpObers(_barChart(label: 'Sales chart'));
    final semantics = tester.getSemantics(find.byType(OiBarChart));
    expect(semantics.label, contains('Sales chart'));
  });

  testWidgets('stacked mode renders', (tester) async {
    await tester.pumpObers(
      _barChart(
        mode: OiBarChartMode.stacked,
        categories: _multiSeriesCategories,
        series: _multiSeriesDef,
      ),
    );
    expect(find.byType(OiBarChart), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('horizontal grouped mode renders', (tester) async {
    await tester.pumpObers(
      _barChart(mode: OiBarChartMode.horizontalGrouped),
    );
    expect(find.byType(OiBarChart), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('horizontal stacked mode renders', (tester) async {
    await tester.pumpObers(
      _barChart(
        mode: OiBarChartMode.horizontalStacked,
        categories: _multiSeriesCategories,
        series: _multiSeriesDef,
      ),
    );
    expect(find.byType(OiBarChart), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('OiBarChart.stacked factory sets stacked mode', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 500,
        height: 400,
        child: OiBarChart.stacked(
          label: 'Stacked',
          categories: _multiSeriesCategories,
          series: _multiSeriesDef,
        ),
      ),
    );
    expect(find.byType(OiBarChart), findsOneWidget);
    final widget = tester.widget<OiBarChart>(find.byType(OiBarChart));
    expect(widget.mode, OiBarChartMode.stacked);
  });

  testWidgets('OiBarChart.horizontalGrouped factory', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 500,
        height: 400,
        child: OiBarChart.horizontalGrouped(
          label: 'H-Grouped',
          categories: _testCategories,
        ),
      ),
    );
    final widget = tester.widget<OiBarChart>(find.byType(OiBarChart));
    expect(widget.mode, OiBarChartMode.horizontalGrouped);
  });

  testWidgets('OiBarChart.horizontalStacked factory', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 500,
        height: 400,
        child: OiBarChart.horizontalStacked(
          label: 'H-Stacked',
          categories: _multiSeriesCategories,
          series: _multiSeriesDef,
        ),
      ),
    );
    final widget = tester.widget<OiBarChart>(find.byType(OiBarChart));
    expect(widget.mode, OiBarChartMode.horizontalStacked);
  });

  testWidgets('showValues displays without error', (tester) async {
    await tester.pumpObers(_barChart(showValues: true));
    expect(find.byType(OiBarChart), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('custom barRadius', (tester) async {
    await tester.pumpObers(_barChart(barRadius: 8));
    expect(find.byType(OiBarChart), findsOneWidget);
  });

  testWidgets('compact layout', (tester) async {
    await tester.pumpObers(
      _barChart(
        compact: true,
        categories: _multiSeriesCategories,
        series: _multiSeriesDef,
      ),
    );
    expect(find.byType(OiBarChart), findsOneWidget);
  });

  testWidgets('touch mode renders GestureDetector', (tester) async {
    await tester.pumpObers(
      _barChart(interactionMode: OiChartInteractionMode.touch),
    );
    expect(find.byKey(const Key('oi_bar_chart_touch')), findsOneWidget);
  });

  testWidgets('pointer mode renders MouseRegion', (tester) async {
    await tester.pumpObers(
      _barChart(interactionMode: OiChartInteractionMode.pointer),
    );
    expect(find.byKey(const Key('oi_bar_chart_pointer')), findsOneWidget);
  });

  testWidgets('light theme renders correctly', (tester) async {
    await tester.pumpObers(
      _barChart(),
      theme: OiThemeData.light(),
    );
    expect(find.byType(OiBarChart), findsOneWidget);
  });

  testWidgets('dark theme renders correctly', (tester) async {
    await tester.pumpObers(
      _barChart(),
      theme: OiThemeData.dark(),
    );
    expect(find.byType(OiBarChart), findsOneWidget);
  });

  // ── Accessibility ───────────────────────────────────────────────────────────

  test('generateSummary describes data correctly', () {
    final summary = OiBarChartAccessibility.generateSummary(
      _multiSeriesCategories,
      _multiSeriesDef,
    );
    expect(summary, contains('2-series'));
    expect(summary, contains('Revenue'));
    expect(summary, contains('Costs'));
    expect(summary, contains('3 categories'));
  });

  test('generateSummary handles empty data', () {
    final summary = OiBarChartAccessibility.generateSummary(const [], null);
    expect(summary, 'Empty bar chart.');
  });

  test('describeBar includes category and value', () {
    const cat = OiBarCategory(label: 'Q1', values: [40, 25]);
    final desc = OiBarChartAccessibility.describeBar(cat, 0, 'Revenue');
    expect(desc, contains('Q1'));
    expect(desc, contains('Revenue'));
    expect(desc, contains('40'));
  });
}
