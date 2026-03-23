import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('OiBarChart', () {
    testWidgets('renders without errors', (tester) async {
      final data = createSampleBarData();
      await pumpChart(tester, OiBarChart(data: data, label: 'Test bar chart'));

      expect(find.byType(OiBarChart), findsOneWidget);
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('renders with empty data', (tester) async {
      await pumpChart(
        tester,
        const OiBarChart(data: OiChartData.empty, label: 'Empty bar chart'),
      );

      expect(find.byType(OiBarChart), findsOneWidget);
    });

    testWidgets('supports vertical orientation', (tester) async {
      final data = createSampleBarData();
      await pumpChart(tester, OiBarChart(data: data, label: 'Vertical bars'));

      expect(find.byType(OiBarChart), findsOneWidget);
    });

    testWidgets('supports horizontal orientation', (tester) async {
      final data = createSampleBarData();
      await pumpChart(
        tester,
        OiBarChart(
          data: data,
          orientation: OiBarChartOrientation.horizontal,
          label: 'Horizontal bars',
        ),
      );

      expect(find.byType(OiBarChart), findsOneWidget);
    });

    testWidgets('has semantics label', (tester) async {
      final data = createSampleBarData();
      await pumpChart(
        tester,
        OiBarChart(data: data, label: 'Sales by quarter'),
      );

      expect(find.bySemanticsLabel('Sales by quarter'), findsOneWidget);
    });

    testWidgets('applies custom theme', (tester) async {
      final data = createSampleBarData();
      await pumpChart(
        tester,
        OiBarChart(
          data: data,
          theme: OiChartTheme.dark(),
          label: 'Dark bar chart',
        ),
      );

      expect(find.byType(OiBarChart), findsOneWidget);
    });

    testWidgets('handles tap callback', (tester) async {
      final data = createSampleBarData();
      await pumpChart(
        tester,
        OiBarChart(
          data: data,
          label: 'Tappable bar chart',
          onDataPointTap: (_) {},
        ),
      );

      await tester.tapAt(const Offset(100, 200));
      await tester.pump();

      expect(find.byType(OiBarChart), findsOneWidget);
    });

    testWidgets('renders multiple series', (tester) async {
      final data = createSampleBarData(series: 3);
      await pumpChart(
        tester,
        OiBarChart(data: data, label: 'Multi series bars'),
      );

      expect(find.byType(OiBarChart), findsOneWidget);
    });
  });
}
