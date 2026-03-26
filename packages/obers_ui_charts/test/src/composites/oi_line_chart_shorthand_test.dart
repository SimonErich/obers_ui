import 'dart:ui' show Size;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import '../../helpers/pump_chart_app.dart';

class _Point {
  const _Point(this.x, this.y);
  final double x;
  final double y;
}

void main() {
  group('OiLineChart.fromData shorthand', () {
    testWidgets('renders chart from shorthand data/x/y', (tester) async {
      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiLineChart.fromData<_Point>(
            label: 'Revenue',
            data: const [_Point(1, 100), _Point(2, 200), _Point(3, 150)],
            x: (p) => p.x,
            y: (p) => p.y,
          ),
        ),
        surfaceSize: const Size(400, 300),
      );

      expect(find.byType(OiLineChart), findsOneWidget);
    });

    testWidgets('empty data renders without error', (tester) async {
      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiLineChart.fromData<_Point>(
            label: 'Empty',
            data: const [],
            x: (p) => p.x,
            y: (p) => p.y,
          ),
        ),
        surfaceSize: const Size(400, 300),
      );

      expect(find.byType(OiLineChart), findsOneWidget);
    });
  });

  group('OiComboChart controller', () {
    testWidgets('accepts controller param', (tester) async {
      final controller = OiDefaultChartController();

      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiComboChart<_Point>(
            label: 'Combo',
            series: [
              OiCartesianSeries<_Point>(
                id: 'line',
                label: 'Line',
                data: const [_Point(1, 100), _Point(2, 200)],
                xMapper: (p) => p.x,
                yMapper: (p) => p.y,
              ),
            ],
            controller: controller,
          ),
        ),
        surfaceSize: const Size(400, 300),
      );

      expect(find.byType(OiComboChart<_Point>), findsOneWidget);
      controller.dispose();
    });
  });
}
