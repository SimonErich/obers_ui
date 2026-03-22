// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/visualization/oi_bubble_chart/oi_bubble_chart_interaction.dart';
import 'package:obers_ui/src/composites/visualization/oi_pie_chart.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';

import '../../../helpers/pump_app.dart';

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
    await tester.pumpObers(_pieChart());
    expect(find.byType(OiPieChart), findsOneWidget);
  });

  testWidgets('CustomPaint painter is present', (tester) async {
    await tester.pumpObers(_pieChart());
    expect(find.byKey(const Key('oi_pie_chart_painter')), findsOneWidget);
  });

  testWidgets('legend shows segment labels', (tester) async {
    await tester.pumpObers(_pieChart());
    expect(find.byKey(const Key('oi_pie_chart_legend')), findsOneWidget);
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);
    expect(find.text('Gamma'), findsOneWidget);
    expect(find.text('Delta'), findsOneWidget);
  });

  testWidgets('hides legend when showLegend is false', (tester) async {
    await tester.pumpObers(_pieChart(showLegend: false));
    expect(find.byKey(const Key('oi_pie_chart_legend')), findsNothing);
  });

  testWidgets('custom colors applied', (tester) async {
    await tester.pumpObers(
      _pieChart(
        segments: const [
          OiPieSegment(
            label: 'Custom',
            value: 100,
            color: Color(0xFFFF5722),
          ),
        ],
      ),
    );
    expect(find.byType(OiPieChart), findsOneWidget);
  });

  testWidgets('onSegmentTap fires with correct index', (tester) async {
    var tappedIndex = -1;
    await tester.pumpObers(
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
    await tester.pumpObers(_pieChart(segments: const []));
    expect(find.byKey(const Key('oi_pie_chart_empty')), findsOneWidget);
  });

  testWidgets('has semantics label', (tester) async {
    await tester.pumpObers(_pieChart(label: 'Market share'));
    final semantics = tester.getSemantics(find.byType(OiPieChart));
    expect(semantics.label, contains('Market share'));
  });

  testWidgets('donut mode renders', (tester) async {
    await tester.pumpObers(_pieChart(donut: true));
    expect(find.byType(OiPieChart), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('center label displays in donut', (tester) async {
    await tester.pumpObers(
      _pieChart(donut: true, centerLabel: 'Total: 100'),
    );
    expect(
      find.byKey(const Key('oi_pie_chart_center_label')),
      findsOneWidget,
    );
    expect(find.text('Total: 100'), findsOneWidget);
  });

  testWidgets('showValues displays values', (tester) async {
    await tester.pumpObers(_pieChart(showValues: true));
    expect(find.byType(OiPieChart), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('legend is positioned below chart in Column', (tester) async {
    await tester.pumpObers(_pieChart());

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
    await tester.pumpObers(
      _pieChart(),
      theme: OiThemeData.light(),
    );
    expect(find.byType(OiPieChart), findsOneWidget);
  });

  testWidgets('dark theme renders correctly', (tester) async {
    await tester.pumpObers(
      _pieChart(),
      theme: OiThemeData.dark(),
    );
    expect(find.byType(OiPieChart), findsOneWidget);
  });

  testWidgets('touch mode renders GestureDetector', (tester) async {
    await tester.pumpObers(
      _pieChart(interactionMode: OiChartInteractionMode.touch),
    );
    expect(find.byKey(const Key('oi_pie_chart_touch')), findsOneWidget);
  });

  testWidgets('pointer mode renders MouseRegion', (tester) async {
    await tester.pumpObers(
      _pieChart(interactionMode: OiChartInteractionMode.pointer),
    );
    expect(find.byKey(const Key('oi_pie_chart_pointer')), findsOneWidget);
  });
}
