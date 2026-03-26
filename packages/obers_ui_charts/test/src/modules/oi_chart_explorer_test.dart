import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

void main() {
  group('OiExplorerController', () {
    test('setChartType updates chartType and notifies listeners', () {
      // Default chartType is line; start with bar to test a change to line.
      final controller = OiExplorerController(
        chartType: OiExplorerChartType.bar,
      );

      var notified = false;
      controller
        ..addListener(() => notified = true)
        ..setChartType(OiExplorerChartType.line);

      expect(controller.chartType, equals(OiExplorerChartType.line));
      expect(notified, isTrue);

      controller.dispose();
    });

    test('setChartType does not notify when type is unchanged', () {
      final controller = OiExplorerController(
        chartType: OiExplorerChartType.bar,
      );

      var notifyCount = 0;
      controller
        ..addListener(() => notifyCount++)
        ..setChartType(OiExplorerChartType.bar);

      expect(notifyCount, equals(0));

      controller.dispose();
    });

    test('setXColumn updates xColumnId and notifies listeners', () {
      final controller = OiExplorerController();

      var notified = false;
      controller
        ..addListener(() => notified = true)
        ..setXColumn('date');

      expect(controller.xColumnId, equals('date'));
      expect(notified, isTrue);

      controller.dispose();
    });

    test('setXColumn does not notify when id is unchanged', () {
      final controller = OiExplorerController(xColumnId: 'date');

      var notifyCount = 0;
      controller
        ..addListener(() => notifyCount++)
        ..setXColumn('date');

      expect(notifyCount, equals(0));

      controller.dispose();
    });
  });

  group('OiColumnType', () {
    test('has 3 values', () {
      expect(OiColumnType.values.length, equals(3));
      expect(
        OiColumnType.values,
        containsAll([
          OiColumnType.numeric,
          OiColumnType.categorical,
          OiColumnType.date,
        ]),
      );
    });
  });

  group('OiExplorerChartType', () {
    test('has 6 values', () {
      expect(OiExplorerChartType.values.length, equals(6));
      expect(
        OiExplorerChartType.values,
        containsAll([
          OiExplorerChartType.line,
          OiExplorerChartType.bar,
          OiExplorerChartType.scatter,
          OiExplorerChartType.pie,
          OiExplorerChartType.heatmap,
          OiExplorerChartType.histogram,
        ]),
      );
    });
  });
}
