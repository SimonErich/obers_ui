import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('OiPieChart', () {
    testWidgets('renders without errors', (tester) async {
      final data = createSamplePieData();
      await pumpChart(
        tester,
        OiPieChart.fromChartData(data: data, label: 'Test pie chart'),
      );

      expect(find.byType(OiPieChart), findsOneWidget);
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('renders with empty data', (tester) async {
      await pumpChart(
        tester,
        OiPieChart.fromChartData(
          data: OiChartData.empty,
          label: 'Empty pie chart',
        ),
      );

      expect(find.byType(OiPieChart), findsOneWidget);
    });

    testWidgets('renders as donut with holeRadius', (tester) async {
      final data = createSamplePieData();
      await pumpChart(
        tester,
        OiPieChart.fromChartData(
          data: data,
          holeRadius: 0.5,
          label: 'Donut chart',
        ),
      );

      expect(find.byType(OiPieChart), findsOneWidget);
    });

    testWidgets('renders single slice', (tester) async {
      final data = createSamplePieData(slices: 1);
      await pumpChart(
        tester,
        OiPieChart.fromChartData(data: data, label: 'Single slice pie'),
      );

      expect(find.byType(OiPieChart), findsOneWidget);
    });

    testWidgets('has semantics label', (tester) async {
      final data = createSamplePieData();
      await pumpChart(
        tester,
        OiPieChart.fromChartData(data: data, label: 'Market share'),
      );

      expect(find.bySemanticsLabel('Market share'), findsOneWidget);
    });

    testWidgets('applies custom theme', (tester) async {
      final data = createSamplePieData();
      await pumpChart(
        tester,
        OiPieChart.fromChartData(
          data: data,
          theme: OiChartTheme.dark(),
          label: 'Dark pie chart',
        ),
      );

      expect(find.byType(OiPieChart), findsOneWidget);
    });

    testWidgets('handles tap callback', (tester) async {
      final data = createSamplePieData();
      await pumpChart(
        tester,
        OiPieChart.fromChartData(
          data: data,
          label: 'Tappable pie chart',
          onSegmentTap: (_) {},
        ),
      );

      await tester.tapAt(const Offset(200, 150));
      await tester.pump();

      expect(find.byType(OiPieChart), findsOneWidget);
    });

    testWidgets('renders many slices', (tester) async {
      final data = createSamplePieData(slices: 10);
      await pumpChart(
        tester,
        OiPieChart.fromChartData(data: data, label: 'Many slices'),
      );

      expect(find.byType(OiPieChart), findsOneWidget);
    });
  });
}
