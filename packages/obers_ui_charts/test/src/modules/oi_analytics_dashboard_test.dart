import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import '../../helpers/pump_chart_app.dart';

void main() {
  group('OiGridPosition', () {
    test('equality holds for same row/col/span values', () {
      const a = OiGridPosition(row: 0, col: 1, rowSpan: 2, colSpan: 3);
      const b = OiGridPosition(row: 0, col: 1, rowSpan: 2, colSpan: 3);
      expect(a, equals(b));
    });

    test('inequality when any field differs', () {
      const a = OiGridPosition(row: 0, col: 0);
      const b = OiGridPosition(row: 1, col: 0);
      expect(a, isNot(equals(b)));
    });

    test('default rowSpan and colSpan are 1', () {
      const pos = OiGridPosition(row: 2, col: 3);
      expect(pos.rowSpan, equals(1));
      expect(pos.colSpan, equals(1));
    });
  });

  group('OiDashboardPanel', () {
    test('holds chart widget and position', () {
      const chartWidget = SizedBox(width: 100, height: 100);
      const panel = OiDashboardPanel(
        id: 'revenue',
        title: 'Revenue',
        gridPosition: OiGridPosition(row: 0, col: 0, colSpan: 2),
        chart: chartWidget,
      );

      expect(panel.id, equals('revenue'));
      expect(panel.title, equals('Revenue'));
      expect(panel.gridPosition.colSpan, equals(2));
      expect(panel.chart, same(chartWidget));
    });
  });

  group('OiAnalyticsDashboard', () {
    testWidgets('renders with panels', (tester) async {
      const panels = [
        OiDashboardPanel(
          id: 'panel-a',
          title: 'Panel A',
          gridPosition: OiGridPosition(row: 0, col: 0),
          chart: SizedBox(key: Key('chart_a'), width: 100, height: 100),
        ),
        OiDashboardPanel(
          id: 'panel-b',
          title: 'Panel B',
          gridPosition: OiGridPosition(row: 0, col: 1),
          chart: SizedBox(key: Key('chart_b'), width: 100, height: 100),
        ),
      ];

      await tester.pumpChartApp(
        const SizedBox(
          width: 800,
          height: 600,
          child: OiAnalyticsDashboard(
            label: 'Test Dashboard',
            panels: panels,
            columns: 2,
          ),
        ),
        surfaceSize: const Size(900, 700),
      );

      expect(
        find.byKey(const Key('oi_analytics_dashboard_grid')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('oi_dashboard_panel_panel-a')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('oi_dashboard_panel_panel-b')),
        findsOneWidget,
      );
    });

    testWidgets('empty panels shows empty state', (tester) async {
      await tester.pumpChartApp(
        const SizedBox(
          width: 800,
          height: 600,
          child: OiAnalyticsDashboard(label: 'Empty Dashboard', panels: []),
        ),
        surfaceSize: const Size(900, 700),
      );

      expect(
        find.byKey(const Key('oi_analytics_dashboard_empty')),
        findsOneWidget,
      );
    });
  });
}
