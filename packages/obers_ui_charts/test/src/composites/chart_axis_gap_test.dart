// Test fixtures use concise chart cases; they are not public API.
// ignore_for_file: public_member_api_docs
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import '../../helpers/pump_chart_app.dart';

void main() {
  final charts = <String, Widget>{
    'Line': const OiLineChart(
      label: 'Line',
      series: [
        OiLineSeries(
          label: 'Data',
          points: [OiLinePoint(x: 1, y: 2), OiLinePoint(x: 2, y: 3)],
        ),
      ],
    ),
    'Area': OiAreaChart<double>(
      label: 'Area',
      series: [
        OiAreaSeries<double>(
          id: 'data',
          label: 'Data',
          data: const [1, 2],
          xMapper: (v) => v,
          yMapper: (v) => v,
        ),
      ],
    ),
    'Histogram': OiHistogram.fromValues(
      label: 'Histogram',
      values: const [1, 2, 3],
      binCount: 2,
    ),
    'Waterfall': OiWaterfallChart<double>(
      label: 'Waterfall',
      series: [
        OiWaterfallSeries<double>(
          id: 'data',
          label: 'Data',
          data: const [1, 2],
          categoryMapper: (v) => '$v',
          valueMapper: (v) => v,
        ),
      ],
    ),
    'BoxPlot': OiBoxPlotChart<double>(
      label: 'BoxPlot',
      series: [
        OiBoxPlotSeries<double>(
          id: 'data',
          label: 'Data',
          data: const [1, 2],
          categoryMapper: (v) => '$v',
          valuesMapper: (v) => [v, v + 1, v + 2],
        ),
      ],
    ),
    'Candlestick': OiCandlestickChart<double>(
      label: 'Candlestick',
      series: [
        OiCandlestickSeries<double>(
          id: 'data',
          label: 'Data',
          data: const [1, 2],
          xMapper: (v) => v,
          openMapper: (v) => v,
          highMapper: (v) => v + 2,
          lowMapper: (v) => v - 1,
          closeMapper: (v) => v + 1,
        ),
      ],
    ),
    'RangeArea': OiRangeAreaChart<double>(
      label: 'RangeArea',
      series: [
        OiRangeAreaSeries<double>(
          id: 'data',
          label: 'Data',
          data: const [1, 2],
          xMapper: (v) => v,
          yMinMapper: (v) => v,
          yMaxMapper: (v) => v + 2,
        ),
      ],
    ),
    'RangeBar': OiRangeBarChart<double>(
      label: 'RangeBar',
      series: [
        OiRangeBarSeries<double>(
          id: 'data',
          label: 'Data',
          data: const [1, 2],
          categoryMapper: (v) => '$v',
          startMapper: (v) => v,
          endMapper: (v) => v + 2,
        ),
      ],
    ),
    'ScatterPlot': const OiScatterPlot(
      label: 'ScatterPlot',
      series: [
        OiScatterSeries(
          label: 'Data',
          points: [OiScatterPoint(x: 1, y: 2), OiScatterPoint(x: 2, y: 3)],
        ),
      ],
    ),
    'Combo': OiComboChart<double>(
      label: 'Combo',
      series: [
        OiCartesianSeries<double>(
          id: 'data',
          label: 'Data',
          data: const [1, 2],
          xMapper: (v) => v,
          yMapper: (v) => v,
        ),
      ],
    ),
  };
  for (final entry in charts.entries) {
    testWidgets(
      '${entry.key} preserves default axis gap and repaints themed gap',
      (tester) async {
        CustomPainter painter() => tester
            .widgetList<CustomPaint>(find.byType(CustomPaint))
            .map((widget) => widget.painter)
            .whereType<CustomPainter>()
            .firstWhere(
              (p) =>
                  p.runtimeType.toString().contains(entry.key) &&
                  p.runtimeType.toString().contains('Painter'),
            );
        final base = OiThemeData.light();
        await tester.pumpChartApp(
          SizedBox(width: 400, height: 300, child: entry.value),
          theme: base,
          surfaceSize: const Size(400, 300),
        );
        final before = painter();
        expect((before as dynamic).labelGap, 4);
        final theme = base.copyWith(
          components: base.components.copyWith(
            chart: const OiChartThemeData(axis: OiChartAxisTheme(labelGap: 10)),
          ),
        );
        await tester.pumpChartApp(
          SizedBox(width: 400, height: 300, child: entry.value),
          theme: theme,
        );
        final after = painter();
        expect((after as dynamic).labelGap, 10);
        expect(after.shouldRepaint(before), isTrue);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
