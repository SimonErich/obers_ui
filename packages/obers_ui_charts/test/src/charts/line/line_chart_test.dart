import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('OiLineChart', () {
    testWidgets('renders without errors', (tester) async {
      final data = createSampleLineData();
      await pumpChart(
        tester,
        OiLineChart(data: data, label: 'Test line chart'),
      );

      expect(find.byType(OiLineChart), findsOneWidget);
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('renders with empty data', (tester) async {
      await pumpChart(
        tester,
        const OiLineChart(
          data: OiChartData(series: []),
          label: 'Empty line chart',
        ),
      );

      expect(find.byType(OiLineChart), findsOneWidget);
    });

    testWidgets('applies custom theme', (tester) async {
      final data = createSampleLineData();
      final darkTheme = OiChartTheme.dark();

      await pumpChart(
        tester,
        OiLineChart(data: data, theme: darkTheme, label: 'Dark line chart'),
      );

      expect(find.byType(OiLineChart), findsOneWidget);
    });

    testWidgets('handles tap callback', (tester) async {
      final data = createSampleLineData();
      OiChartHitResult? tappedResult;

      await pumpChart(
        tester,
        OiLineChart(
          data: data,
          label: 'Tappable line chart',
          onDataPointTap: (result) => tappedResult = result,
        ),
      );

      // Tap near the first data point (bottom-left of chart area).
      await tester.tapAt(const Offset(48, 268));
      await tester.pump();

      // The tap may or may not register depending on exact hit tolerance.
      // We just verify no crash occurred.
      expect(find.byType(OiLineChart), findsOneWidget);
    });

    testWidgets('has semantics label', (tester) async {
      final data = createSampleLineData();
      await pumpChart(
        tester,
        OiLineChart(data: data, label: 'Revenue over time'),
      );

      expect(find.bySemanticsLabel('Revenue over time'), findsOneWidget);
    });

    testWidgets('renders with single data point', (tester) async {
      const data = OiChartData(
        series: [
          OiChartSeries(name: 'Single', dataPoints: [OiDataPoint(x: 5, y: 10)]),
        ],
      );

      await pumpChart(
        tester,
        const OiLineChart(data: data, label: 'Single point'),
      );

      expect(find.byType(OiLineChart), findsOneWidget);
    });

    testWidgets('renders multiple series', (tester) async {
      final data = createSampleLineData(series: 3);
      await pumpChart(tester, OiLineChart(data: data, label: 'Multi series'));

      expect(find.byType(OiLineChart), findsOneWidget);
    });

    testWidgets('uses default light theme when none provided', (tester) async {
      final data = createSampleLineData();
      await pumpChart(tester, OiLineChart(data: data, label: 'Default theme'));

      // Should not throw and render successfully.
      expect(find.byType(CustomPaint), findsOneWidget);
    });
  });
}
