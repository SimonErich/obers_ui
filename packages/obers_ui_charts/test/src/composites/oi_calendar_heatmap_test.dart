import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import '../../helpers/pump_chart_app.dart';

void main() {
  group('OiCalendarHeatmap', () {
    final baseDate = DateTime(2025, 6, 15);

    final sampleData = [
      (date: DateTime(2025, 6), value: 5),
      (date: DateTime(2025, 6, 10), value: 12),
      (date: DateTime(2025, 6, 15), value: 3),
    ];

    testWidgets('renders with date + value data', (tester) async {
      await tester.pumpChartApp(
        SizedBox(
          width: 700,
          height: 120,
          child: OiCalendarHeatmap<({DateTime date, int value})>(
            label: 'Activity Heatmap',
            data: sampleData,
            dateMapper: (item) => item.date,
            valueMapper: (item) => item.value,
            startDate: DateTime(2025),
            endDate: baseDate,
          ),
        ),
        surfaceSize: const Size(800, 200),
      );

      expect(find.byKey(const Key('oi_calendar_heatmap')), findsOneWidget);
      expect(
        find.byKey(const Key('oi_calendar_heatmap_painter')),
        findsOneWidget,
      );
    });

    testWidgets('empty data shows empty state when date range is invalid', (
      tester,
    ) async {
      // Passing startDate after endDate results in an empty weeks list.
      await tester.pumpChartApp(
        SizedBox(
          width: 700,
          height: 120,
          child: OiCalendarHeatmap<({DateTime date, int value})>(
            label: 'Empty Heatmap',
            data: const [],
            dateMapper: (item) => item.date,
            valueMapper: (item) => item.value,
            startDate: DateTime(2026),
            endDate: DateTime(2025),
          ),
        ),
        surfaceSize: const Size(800, 200),
      );

      expect(
        find.byKey(const Key('oi_calendar_heatmap_empty')),
        findsOneWidget,
      );
    });

    test('color resolves through OiColorScale linear', () {
      final scale = OiColorScale.linear(
        minColor: const Color(0xFFebedf0),
        maxColor: const Color(0xFF216e39),
        min: 0,
        max: 10,
      );

      // Value at min should be near minColor.
      final colorMin = scale.resolve(0);
      expect(colorMin, equals(const Color(0xFFebedf0)));

      // Value at max should be near maxColor.
      final colorMax = scale.resolve(10);
      expect(colorMax, equals(const Color(0xFF216e39)));

      // Value in the middle should be different from both extremes.
      final colorMid = scale.resolve(5);
      expect(colorMid, isNot(equals(const Color(0xFFebedf0))));
      expect(colorMid, isNot(equals(const Color(0xFF216e39))));
    });
  });
}
