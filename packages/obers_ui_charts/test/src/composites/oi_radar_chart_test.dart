// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/src/composites/oi_radar_chart.dart';

import '../../helpers/pump_chart_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

const _axes = ['Speed', 'Power', 'Range', 'Armor', 'Magic'];

const _series = [
  OiRadarSeries(label: 'Player A', values: [80, 60, 90, 40, 70]),
  OiRadarSeries(
    label: 'Player B',
    values: [50, 80, 60, 70, 90],
    color: Color(0xFFFF5722),
    fillOpacity: 0.3,
  ),
];

Widget _radarChart({
  List<String> axes = _axes,
  List<OiRadarSeries> series = _series,
  String label = 'Test Radar',
  bool showLegend = true,
  bool showValues = false,
  double? maxValue,
  double? size,
}) {
  return SizedBox(
    width: 400,
    height: 400,
    child: OiRadarChart(
      axes: axes,
      series: series,
      label: label,
      showLegend: showLegend,
      showValues: showValues,
      maxValue: maxValue,
      size: size,
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // 1. Renders without errors.
  testWidgets('renders without errors', (tester) async {
    await tester.pumpChartApp(_radarChart());
    expect(find.byType(OiRadarChart), findsOneWidget);
  });

  // 2. Data displays correctly — CustomPaint is present.
  testWidgets('CustomPaint painter is present', (tester) async {
    await tester.pumpChartApp(_radarChart());
    expect(find.byKey(const Key('oi_radar_chart_painter')), findsOneWidget);
  });

  // 3. Labels render — legend shows series names.
  testWidgets('legend displays series labels', (tester) async {
    await tester.pumpChartApp(_radarChart());
    expect(find.text('Player A'), findsOneWidget);
    expect(find.text('Player B'), findsOneWidget);
  });

  // 4. Custom colors applied — series with custom color renders.
  testWidgets('renders with custom series colors', (tester) async {
    await tester.pumpChartApp(
      _radarChart(
        series: const [
          OiRadarSeries(
            label: 'Custom',
            values: [10, 20, 30],
            color: Color(0xFF00BCD4),
          ),
        ],
        axes: const ['A', 'B', 'C'],
      ),
    );
    expect(find.text('Custom'), findsOneWidget);
  });

  // 5. Legend hidden when showLegend is false.
  testWidgets('hides legend when showLegend is false', (tester) async {
    await tester.pumpChartApp(_radarChart(showLegend: false));
    expect(find.byKey(const Key('oi_radar_chart_legend')), findsNothing);
  });

  // 6. Empty data handles gracefully.
  testWidgets('handles empty series gracefully', (tester) async {
    await tester.pumpChartApp(_radarChart(series: const []));
    expect(find.byType(OiRadarChart), findsOneWidget);
    expect(find.byKey(const Key('oi_radar_chart_legend')), findsNothing);
  });

  // 7. Empty axes handles gracefully.
  testWidgets('handles empty axes gracefully', (tester) async {
    await tester.pumpChartApp(_radarChart(axes: const [], series: const []));
    expect(find.byType(OiRadarChart), findsOneWidget);
  });

  // 8. Semantics label present.
  testWidgets('has semantics label', (tester) async {
    await tester.pumpChartApp(_radarChart(label: 'Player Stats'));
    final semantics = tester.getSemantics(find.byType(OiRadarChart));
    expect(semantics.label, contains('Player Stats'));
  });

  // 9. Size adapts to container.
  testWidgets('adapts to custom size', (tester) async {
    await tester.pumpChartApp(_radarChart(size: 150));
    final painter = find.byKey(const Key('oi_radar_chart_painter'));
    final painterSize = tester.getSize(painter);
    expect(painterSize.width, 150);
    expect(painterSize.height, 150);
  });

  // 10. maxValue override works.
  testWidgets('renders with custom maxValue', (tester) async {
    await tester.pumpChartApp(_radarChart(maxValue: 200));
    expect(find.byType(OiRadarChart), findsOneWidget);
  });

  // 11. showValues renders without error.
  testWidgets('renders with showValues enabled', (tester) async {
    await tester.pumpChartApp(_radarChart(showValues: true));
    expect(find.byType(OiRadarChart), findsOneWidget);
  });

  // 12. Legend widget key is present when legend shown.
  testWidgets('legend widget has expected key', (tester) async {
    await tester.pumpChartApp(_radarChart());
    expect(find.byKey(const Key('oi_radar_chart_legend')), findsOneWidget);
  });
}
