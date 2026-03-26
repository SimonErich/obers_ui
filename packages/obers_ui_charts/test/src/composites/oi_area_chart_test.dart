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
  group('OiAreaChart', () {
    testWidgets('renders area fill', (tester) async {
      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiAreaChart<_Point>(
            label: 'Revenue',
            series: [
              OiAreaSeries<_Point>(
                id: 'revenue',
                label: 'Revenue',
                data: const [_Point(1, 100), _Point(2, 200), _Point(3, 150)],
                xMapper: (p) => p.x,
                yMapper: (p) => p.y,
              ),
            ],
          ),
        ),
        surfaceSize: const Size(400, 300),
      );

      expect(find.byType(OiAreaChart<_Point>), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders stacked mode', (tester) async {
      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiAreaChart<_Point>(
            label: 'Stacked',
            stacked: true,
            series: [
              OiAreaSeries<_Point>(
                id: 'a',
                label: 'Series A',
                data: const [_Point(1, 50), _Point(2, 100)],
                xMapper: (p) => p.x,
                yMapper: (p) => p.y,
                stackGroup: 'main',
              ),
              OiAreaSeries<_Point>(
                id: 'b',
                label: 'Series B',
                data: const [_Point(1, 30), _Point(2, 60)],
                xMapper: (p) => p.x,
                yMapper: (p) => p.y,
                stackGroup: 'main',
              ),
            ],
          ),
        ),
        surfaceSize: const Size(400, 300),
      );

      expect(find.byType(OiAreaChart<_Point>), findsOneWidget);
    });

    testWidgets('empty data shows empty state', (tester) async {
      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiAreaChart<_Point>(
            label: 'Empty',
            series: [
              OiAreaSeries<_Point>(
                id: 'empty',
                label: 'Empty',
                data: const [],
                xMapper: (p) => p.x,
                yMapper: (p) => p.y,
              ),
            ],
          ),
        ),
        surfaceSize: const Size(400, 300),
      );

      // Area chart shows empty state for empty data.
      expect(find.byKey(const Key('oi_area_chart_empty')), findsOneWidget);
    });
  });
}
