import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/src/composites/oi_matrix_chart.dart';
import 'package:obers_ui_charts/src/models/oi_matrix_series.dart';

import '../../helpers/pump_chart_app.dart';

class _Cell {
  _Cell(this.row, this.col, this.value);
  final String row;
  final String col;
  final double value;
}

void main() {
  group('OiMatrixChart', () {
    testWidgets('renders cell grid with series data', (tester) async {
      final data = [
        _Cell('A', 'X', 1),
        _Cell('A', 'Y', 2),
        _Cell('B', 'X', 3),
        _Cell('B', 'Y', 4),
      ];

      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiMatrixChart<_Cell>(
            label: 'Heatmap',
            series: [
              OiMatrixSeries<_Cell>(
                id: 'heat',
                label: 'Heat',
                data: data,
                rowMapper: (c) => c.row,
                columnMapper: (c) => c.col,
                valueMapper: (c) => c.value,
              ),
            ],
            seriesBuilder: (context, viewport, visibleSeries) {
              return const SizedBox(key: Key('matrix-content'));
            },
          ),
        ),
      );

      expect(find.byKey(const Key('matrix-content')), findsOneWidget);
    });

    testWidgets('empty data shows empty state', (tester) async {
      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiMatrixChart<_Cell>(
            label: 'Empty matrix',
            series: [
              OiMatrixSeries<_Cell>(
                id: 'heat',
                label: 'Heat',
                data: const [],
                rowMapper: (c) => c.row,
                columnMapper: (c) => c.col,
                valueMapper: (c) => c.value,
              ),
            ],
          ),
        ),
      );

      expect(find.text('No data available'), findsOneWidget);
    });
  });
}
