import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import '../../helpers/pump_chart_app.dart';

/// Pumps [chart], removes it again and returns the [TextPainter]s that were
/// created in between and never disposed.
///
/// Painters owned by render objects are disposed when the tree goes away,
/// so what is left was created during paint and leaked.
Future<Set<Object>> _leakedTextPainters(
  WidgetTester tester,
  Widget chart, {
  Size size = const Size(500, 400),
}) async {
  final alive = Set<Object>.identity();
  void listener(ObjectEvent event) {
    if (event is ObjectCreated && event.className == 'TextPainter') {
      alive.add(event.object);
    } else if (event is ObjectDisposed) {
      alive.remove(event.object);
    }
  }

  FlutterMemoryAllocations.instance.addListener(listener);
  try {
    await tester.pumpChartApp(
      Align(
        alignment: Alignment.topLeft,
        child: SizedBox.fromSize(size: size, child: chart),
      ),
    );
    await tester.pumpWidget(const SizedBox.shrink());
  } finally {
    FlutterMemoryAllocations.instance.removeListener(listener);
  }
  return alive;
}

const _barCategories = [
  OiBarCategory(label: 'Q1', values: [40, 25]),
  OiBarCategory(label: 'Q2', values: [55, 30]),
];

final List<Map<String, Object>> _polarData = [
  {'category': 'North', 'value': 120.0},
  {'category': 'South', 'value': 80.0},
  {'category': 'East', 'value': 200.0},
];

void main() {
  group('charts dispose the TextPainters they create while painting', () {
    testWidgets('shared grid labels (line chart)', (tester) async {
      final leaked = await _leakedTextPainters(
        tester,
        const OiLineChart(
          label: 'Line',
          series: [
            OiLineSeries(
              label: 'a',
              points: [OiLinePoint(x: 0, y: 1), OiLinePoint(x: 1, y: 2)],
            ),
          ],
        ),
      );
      expect(leaked, isEmpty);
    });

    testWidgets('pie chart', (tester) async {
      final leaked = await _leakedTextPainters(
        tester,
        const OiPieChart(
          label: 'Pie',
          segments: [
            OiPieSegment(label: 'a', value: 60),
            OiPieSegment(label: 'b', value: 40),
          ],
        ),
      );
      expect(leaked, isEmpty);
    });

    testWidgets('polar area chart', (tester) async {
      final leaked = await _leakedTextPainters(
        tester,
        OiPolarAreaChart<Map<String, dynamic>>(
          label: 'Polar area',
          series: [
            OiPolarAreaSeries<Map<String, dynamic>>(
              id: 'sales',
              label: 'Sales',
              data: _polarData,
              categoryMapper: (item) => item['category'] as String,
              valueMapper: (item) => item['value'] as double,
            ),
          ],
        ),
        size: const Size(300, 400),
      );
      expect(leaked, isEmpty);
    });

    testWidgets('sunburst chart', (tester) async {
      const nodes = [
        (id: 'root', parent: null, value: 0.0),
        (id: 'a', parent: 'root', value: 60.0),
        (id: 'b', parent: 'root', value: 40.0),
      ];
      final leaked = await _leakedTextPainters(
        tester,
        OiSunburstChart<({String id, String? parent, double value})>(
          label: 'Sunburst',
          data: nodes,
          nodeId: (item) => item.id,
          parentId: (item) => item.parent,
          value: (item) => item.value,
          nodeLabel: (item) => item.id,
        ),
      );
      expect(leaked, isEmpty);
    });

    for (final mode in OiBarChartMode.values) {
      testWidgets('bar chart (${mode.name})', (tester) async {
        final leaked = await _leakedTextPainters(
          tester,
          OiBarChart(
            label: 'Bar',
            categories: _barCategories,
            mode: mode,
            showValues: true,
          ),
        );
        expect(leaked, isEmpty);
      });
    }

    testWidgets('radial bar chart', (tester) async {
      final leaked = await _leakedTextPainters(
        tester,
        OiRadialBarChart<Map<String, dynamic>>(
          label: 'Radial bar',
          series: [
            OiRadialBarSeries<Map<String, dynamic>>(
              id: 'test',
              label: 'Test',
              data: _polarData,
              categoryMapper: (item) => item['category'] as String,
              valueMapper: (item) => item['value'] as double,
            ),
          ],
        ),
      );
      expect(leaked, isEmpty);
    });

    testWidgets('radar chart', (tester) async {
      final leaked = await _leakedTextPainters(
        tester,
        const OiRadarChart(
          label: 'Radar',
          axes: ['Speed', 'Power', 'Range'],
          series: [
            OiRadarSeries(label: 'a', values: [80, 60, 90]),
          ],
          showValues: true,
        ),
      );
      expect(leaked, isEmpty);
    });
  });
}
