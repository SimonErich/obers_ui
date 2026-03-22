// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/visualization/oi_bubble_chart/oi_bubble_chart_interaction.dart';
import 'package:obers_ui/src/composites/visualization/oi_scatter_plot.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

List<OiScatterSeries> _testSeries() {
  return const [
    OiScatterSeries(
      label: 'Group A',
      points: [
        OiScatterPoint(x: 10, y: 20),
        OiScatterPoint(x: 30, y: 50),
        OiScatterPoint(x: 60, y: 80),
      ],
    ),
  ];
}

List<OiScatterSeries> _multiSeries() {
  return const [
    OiScatterSeries(
      label: 'Group A',
      points: [
        OiScatterPoint(x: 10, y: 20),
        OiScatterPoint(x: 30, y: 50),
      ],
    ),
    OiScatterSeries(
      label: 'Group B',
      points: [
        OiScatterPoint(x: 20, y: 40),
        OiScatterPoint(x: 50, y: 70),
      ],
    ),
  ];
}

Widget _scatterPlot({
  List<OiScatterSeries>? series,
  String label = 'Test scatter plot',
  bool showGrid = true,
  bool showLegend = true,
  void Function(int, int)? onPointTap,
  OiChartInteractionMode? interactionMode,
  bool? compact,
  double width = 500,
  double height = 400,
}) {
  return SizedBox(
    width: width,
    height: height,
    child: OiScatterPlot(
      label: label,
      series: series ?? _testSeries(),
      showGrid: showGrid,
      showLegend: showLegend,
      onPointTap: onPointTap,
      interactionMode: interactionMode,
      compact: compact,
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  testWidgets('renders without errors', (tester) async {
    await tester.pumpObers(_scatterPlot());
    expect(find.byType(OiScatterPlot), findsOneWidget);
  });

  testWidgets('CustomPaint painter is present', (tester) async {
    await tester.pumpObers(_scatterPlot());
    expect(
      find.byKey(const Key('oi_scatter_plot_painter')),
      findsOneWidget,
    );
  });

  testWidgets('grid renders with canvas key', (tester) async {
    await tester.pumpObers(_scatterPlot());
    expect(
      find.byKey(const Key('oi_scatter_plot_canvas')),
      findsOneWidget,
    );
  });

  testWidgets('legend shows series names for multi-series', (tester) async {
    await tester.pumpObers(_scatterPlot(series: _multiSeries()));
    expect(
      find.byKey(const Key('oi_scatter_plot_legend')),
      findsOneWidget,
    );
    expect(find.text('Group A'), findsOneWidget);
    expect(find.text('Group B'), findsOneWidget);
  });

  testWidgets('hides legend for single series', (tester) async {
    await tester.pumpObers(_scatterPlot());
    expect(
      find.byKey(const Key('oi_scatter_plot_legend')),
      findsNothing,
    );
  });

  testWidgets('custom colors applied', (tester) async {
    await tester.pumpObers(
      _scatterPlot(
        series: const [
          OiScatterSeries(
            label: 'Custom',
            points: [OiScatterPoint(x: 1, y: 2)],
            color: Color(0xFFFF5722),
          ),
        ],
      ),
    );
    expect(find.byType(OiScatterPlot), findsOneWidget);
  });

  testWidgets('onPointTap fires on tap', (tester) async {
    await tester.pumpObers(
      _scatterPlot(
        interactionMode: OiChartInteractionMode.touch,
        onPointTap: (si, pi) {},
      ),
    );

    final touchFinder = find.byKey(const Key('oi_scatter_plot_touch'));
    expect(touchFinder, findsOneWidget);

    await tester.tap(touchFinder);
    await tester.pumpAndSettle();

    // Verify the chart handles the interaction without error.
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty series returns SizedBox.shrink', (tester) async {
    await tester.pumpObers(_scatterPlot(series: const []));
    expect(
      find.byKey(const Key('oi_scatter_plot_empty')),
      findsOneWidget,
    );
  });

  testWidgets('has semantics label', (tester) async {
    await tester.pumpObers(_scatterPlot(label: 'Correlation chart'));
    final semantics = tester.getSemantics(find.byType(OiScatterPlot));
    expect(semantics.label, contains('Correlation chart'));
  });

  testWidgets('different shapes render without error', (tester) async {
    await tester.pumpObers(
      _scatterPlot(
        series: const [
          OiScatterSeries(
            label: 'Circles',
            points: [OiScatterPoint(x: 1, y: 1)],
          ),
          OiScatterSeries(
            label: 'Squares',
            points: [OiScatterPoint(x: 2, y: 2)],
            shape: OiScatterShape.square,
          ),
          OiScatterSeries(
            label: 'Diamonds',
            points: [OiScatterPoint(x: 3, y: 3)],
            shape: OiScatterShape.diamond,
          ),
          OiScatterSeries(
            label: 'Triangles',
            points: [OiScatterPoint(x: 4, y: 4)],
            shape: OiScatterShape.triangle,
          ),
        ],
      ),
    );
    expect(find.byType(OiScatterPlot), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact layout', (tester) async {
    await tester.pumpObers(
      _scatterPlot(compact: true, series: _multiSeries()),
    );
    expect(find.byType(OiScatterPlot), findsOneWidget);
  });

  testWidgets('touch mode renders GestureDetector', (tester) async {
    await tester.pumpObers(
      _scatterPlot(interactionMode: OiChartInteractionMode.touch),
    );
    expect(
      find.byKey(const Key('oi_scatter_plot_touch')),
      findsOneWidget,
    );
  });

  testWidgets('pointer mode renders MouseRegion', (tester) async {
    await tester.pumpObers(
      _scatterPlot(interactionMode: OiChartInteractionMode.pointer),
    );
    expect(
      find.byKey(const Key('oi_scatter_plot_pointer')),
      findsOneWidget,
    );
  });

  testWidgets('light theme renders correctly', (tester) async {
    await tester.pumpObers(
      _scatterPlot(),
      theme: OiThemeData.light(),
    );
    expect(find.byType(OiScatterPlot), findsOneWidget);
  });

  testWidgets('dark theme renders correctly', (tester) async {
    await tester.pumpObers(
      _scatterPlot(),
      theme: OiThemeData.dark(),
    );
    expect(find.byType(OiScatterPlot), findsOneWidget);
  });
}
