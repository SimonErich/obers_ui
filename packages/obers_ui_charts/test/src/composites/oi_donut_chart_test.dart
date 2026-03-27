
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import '../../helpers/pump_chart_app.dart';

void main() {
  group('OiDonutChart', () {
    testWidgets('renders as donut with center label', (tester) async {
      await tester.pumpChartApp(
        const SizedBox(
          width: 400,
          height: 300,
          child: OiDonutChart(
            label: 'Distribution',
            segments: [
              OiPieSegment(label: 'A', value: 40),
              OiPieSegment(label: 'B', value: 30),
              OiPieSegment(label: 'C', value: 30),
            ],
            centerLabel: 'Total: 100',
          ),
        ),
        surfaceSize: const Size(400, 300),
      );

      expect(find.byType(OiDonutChart), findsOneWidget);
      expect(find.byType(OiPieChart), findsOneWidget);
    });

    testWidgets('renders without center label', (tester) async {
      await tester.pumpChartApp(
        const SizedBox(
          width: 400,
          height: 300,
          child: OiDonutChart(
            label: 'Simple',
            segments: [
              OiPieSegment(label: 'X', value: 60),
              OiPieSegment(label: 'Y', value: 40),
            ],
          ),
        ),
        surfaceSize: const Size(400, 300),
      );

      expect(find.byType(OiDonutChart), findsOneWidget);
    });

    testWidgets('respects custom inner radius', (tester) async {
      await tester.pumpChartApp(
        const SizedBox(
          width: 400,
          height: 300,
          child: OiDonutChart(
            label: 'Thin ring',
            innerRadiusFraction: 0.7,
            segments: [
              OiPieSegment(label: 'A', value: 50),
              OiPieSegment(label: 'B', value: 50),
            ],
          ),
        ),
        surfaceSize: const Size(400, 300),
      );

      expect(find.byType(OiDonutChart), findsOneWidget);
    });
  });
}
