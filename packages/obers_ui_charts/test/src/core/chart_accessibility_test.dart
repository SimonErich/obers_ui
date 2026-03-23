import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/src/foundation/chart_accessibility.dart';

void main() {
  group('OiChartInsight', () {
    test('equality', () {
      const a = OiChartInsight(type: OiChartInsightType.trendUp);
      const b = OiChartInsight(type: OiChartInsightType.trendUp);
      const c = OiChartInsight(
        type: OiChartInsightType.trendUp,
        description: 'Rising',
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('with seriesIndex', () {
      const a = OiChartInsight(
        type: OiChartInsightType.maximum,
        seriesIndex: 0,
      );
      const b = OiChartInsight(
        type: OiChartInsightType.maximum,
        seriesIndex: 1,
      );

      expect(a, isNot(equals(b)));
    });
  });

  group('OiChartAccessibilitySummary', () {
    test('basic description with chart type only', () {
      const summary = OiChartAccessibilitySummary(chartType: 'Line chart');

      expect(summary.toDescription(), equals('Line chart.'));
    });

    test('description with single series', () {
      const summary = OiChartAccessibilitySummary(
        chartType: 'Line chart',
        seriesLabels: ['Revenue'],
      );

      expect(
        summary.toDescription(),
        equals('Line chart with 1 series: Revenue.'),
      );
    });

    test('description with multiple series', () {
      const summary = OiChartAccessibilitySummary(
        chartType: 'Bar chart',
        seriesLabels: ['Q1', 'Q2', 'Q3'],
      );

      expect(
        summary.toDescription(),
        equals('Bar chart with 3 series: Q1, Q2, Q3.'),
      );
    });

    test('description with more than 5 series omits labels', () {
      const summary = OiChartAccessibilitySummary(
        chartType: 'Line chart',
        seriesLabels: ['A', 'B', 'C', 'D', 'E', 'F'],
      );

      expect(
        summary.toDescription(),
        equals('Line chart with 6 series.'),
      );
    });

    test('description with axis labels', () {
      const summary = OiChartAccessibilitySummary(
        chartType: 'Line chart',
        seriesLabels: ['Sales'],
        xAxisLabel: 'Month',
        yAxisLabel: 'Revenue',
      );

      expect(summary.toDescription(), contains('X-axis (Month)'));
      expect(summary.toDescription(), contains('Y-axis (Revenue)'));
    });

    test('description with domain ranges', () {
      const summary = OiChartAccessibilitySummary(
        chartType: 'Bar chart',
        seriesLabels: ['Data'],
        xMin: 0,
        xMax: 100,
        yMin: -5,
        yMax: 50,
      );

      final desc = summary.toDescription();
      expect(desc, contains('X-axis from 0 to 100'));
      expect(desc, contains('Y-axis from -5 to 50'));
    });

    test('description with axis labels and ranges', () {
      const summary = OiChartAccessibilitySummary(
        chartType: 'Line chart',
        seriesLabels: ['Temperature'],
        xAxisLabel: 'Time',
        yAxisLabel: 'Degrees',
        xMin: 0,
        xMax: 24,
        yMin: 10,
        yMax: 35,
      );

      final desc = summary.toDescription();
      expect(desc, contains('X-axis (Time) from 0 to 24'));
      expect(desc, contains('Y-axis (Degrees) from 10 to 35'));
    });

    test('description with trend up insight', () {
      const summary = OiChartAccessibilitySummary(
        chartType: 'Line chart',
        seriesLabels: ['Revenue'],
        insights: [OiChartInsight(type: OiChartInsightType.trendUp)],
      );

      expect(summary.toDescription(), contains('General trend: upward'));
    });

    test('description with trend down insight', () {
      const summary = OiChartAccessibilitySummary(
        chartType: 'Line chart',
        seriesLabels: ['Cost'],
        insights: [OiChartInsight(type: OiChartInsightType.trendDown)],
      );

      expect(summary.toDescription(), contains('General trend: downward'));
    });

    test('description with trend flat insight', () {
      const summary = OiChartAccessibilitySummary(
        chartType: 'Line chart',
        seriesLabels: ['Stable'],
        insights: [OiChartInsight(type: OiChartInsightType.trendFlat)],
      );

      expect(summary.toDescription(), contains('General trend: flat'));
    });

    test('description with custom insight description', () {
      const summary = OiChartAccessibilitySummary(
        chartType: 'Line chart',
        seriesLabels: ['Revenue'],
        insights: [
          OiChartInsight(
            type: OiChartInsightType.trendUp,
            description: 'Revenue increased 40% over the period',
          ),
        ],
      );

      expect(
        summary.toDescription(),
        contains('Revenue increased 40% over the period'),
      );
    });

    test('description with extrema insight', () {
      const summary = OiChartAccessibilitySummary(
        chartType: 'Line chart',
        insights: [
          OiChartInsight(
            type: OiChartInsightType.maximum,
            description: 'Peak value of 150 at x=7',
          ),
          OiChartInsight(
            type: OiChartInsightType.minimum,
            description: 'Low of 10 at x=2',
          ),
        ],
      );

      final desc = summary.toDescription();
      expect(desc, contains('Peak value of 150 at x=7'));
      expect(desc, contains('Low of 10 at x=2'));
    });

    test('formats decimal values', () {
      const summary = OiChartAccessibilitySummary(
        chartType: 'Line chart',
        xMin: 0.5,
        xMax: 10.3,
        yMin: -2.7,
        yMax: 8,
      );

      final desc = summary.toDescription();
      expect(desc, contains('from 0.5 to 10.3'));
      expect(desc, contains('from -2.7 to 8'));
    });

    test('equality', () {
      const a = OiChartAccessibilitySummary(
        chartType: 'Line chart',
        seriesLabels: ['A'],
        xMin: 0,
        xMax: 10,
      );
      const b = OiChartAccessibilitySummary(
        chartType: 'Line chart',
        seriesLabels: ['A'],
        xMin: 0,
        xMax: 10,
      );
      const c = OiChartAccessibilitySummary(
        chartType: 'Bar chart',
        seriesLabels: ['A'],
        xMin: 0,
        xMax: 10,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });

  group('OiChartA11y', () {
    test('describeChart falls back to basic description without summary', () {
      final desc = OiChartA11y.describeChart('Line chart', 2, 10);
      expect(desc, equals('Line chart with 2 series and 10 data points'));
    });

    test('describeChart uses summary when provided', () {
      const summary = OiChartAccessibilitySummary(
        chartType: 'Line chart',
        seriesLabels: ['Sales'],
        xMin: 0,
        xMax: 12,
      );

      final desc = OiChartA11y.describeChart(
        'Line chart',
        1,
        12,
        summary: summary,
      );

      expect(desc, contains('Line chart with 1 series: Sales'));
      expect(desc, contains('X-axis from 0 to 12'));
    });

    test('describeChart uses summaryBuilder when provided', () {
      const summary = OiChartAccessibilitySummary(
        chartType: 'Line chart',
        seriesLabels: ['Sales'],
      );

      final desc = OiChartA11y.describeChart(
        'Line chart',
        1,
        12,
        summary: summary,
        summaryBuilder: (s) => 'Custom: ${s.chartType}',
      );

      expect(desc, equals('Custom: Line chart'));
    });

    test('describeDataPoint with label', () {
      final desc = OiChartA11y.describeDataPoint(
        'Revenue',
        3,
        150,
        label: 'March',
      );

      expect(desc, equals('Revenue: March, x=3, y=150'));
    });

    test('describeDataPoint without label', () {
      final desc = OiChartA11y.describeDataPoint('Revenue', 3.5, 150.2);
      expect(desc, equals('Revenue: x=3.5, y=150.2'));
    });

    test('buildCartesianSummary infers upward trend', () {
      final summary = OiChartA11y.buildCartesianSummary(
        chartType: 'Line chart',
        seriesLabels: ['Revenue'],
        xMin: 0,
        xMax: 4,
        yMin: 10,
        yMax: 50,
        seriesYValues: [
          [10, 20, 30, 40, 50],
        ],
      );

      expect(summary.chartType, equals('Line chart'));
      expect(summary.seriesLabels, equals(['Revenue']));
      expect(summary.xMin, equals(0));
      expect(summary.xMax, equals(4));
      expect(summary.insights, isNotEmpty);
      expect(summary.insights.first.type, equals(OiChartInsightType.trendUp));
    });

    test('buildCartesianSummary infers downward trend', () {
      final summary = OiChartA11y.buildCartesianSummary(
        chartType: 'Line chart',
        seriesLabels: ['Cost'],
        seriesYValues: [
          [50, 40, 30, 20, 10],
        ],
      );

      expect(summary.insights, isNotEmpty);
      expect(
        summary.insights.first.type,
        equals(OiChartInsightType.trendDown),
      );
    });

    test('buildCartesianSummary infers flat trend', () {
      final summary = OiChartA11y.buildCartesianSummary(
        chartType: 'Line chart',
        seriesLabels: ['Stable'],
        seriesYValues: [
          [50, 50, 50, 50, 50],
        ],
      );

      expect(summary.insights, isNotEmpty);
      expect(
        summary.insights.first.type,
        equals(OiChartInsightType.trendFlat),
      );
    });

    test('buildCartesianSummary with no y-values has no insights', () {
      final summary = OiChartA11y.buildCartesianSummary(
        chartType: 'Bar chart',
        seriesLabels: ['Data'],
      );

      expect(summary.insights, isEmpty);
    });

    test('buildCartesianSummary with axis labels', () {
      final summary = OiChartA11y.buildCartesianSummary(
        chartType: 'Line chart',
        seriesLabels: ['Temp'],
        xAxisLabel: 'Time',
        yAxisLabel: 'Temperature',
      );

      expect(summary.xAxisLabel, equals('Time'));
      expect(summary.yAxisLabel, equals('Temperature'));
    });

    test('buildCartesianSummary with single point has no trend', () {
      final summary = OiChartA11y.buildCartesianSummary(
        chartType: 'Line chart',
        seriesLabels: ['Single'],
        seriesYValues: [
          [42],
        ],
      );

      expect(summary.insights, isEmpty);
    });

    test('full description includes all components', () {
      const summary = OiChartAccessibilitySummary(
        chartType: 'Line chart',
        seriesLabels: ['Revenue', 'Expenses'],
        xAxisLabel: 'Month',
        yAxisLabel: 'Amount',
        xMin: 1,
        xMax: 12,
        yMin: 0,
        yMax: 1000,
        insights: [
          OiChartInsight(type: OiChartInsightType.trendUp),
          OiChartInsight(
            type: OiChartInsightType.maximum,
            description: 'Peak revenue of 1000 in December',
          ),
        ],
      );

      final desc = summary.toDescription();
      expect(desc, contains('Line chart with 2 series: Revenue, Expenses'));
      expect(desc, contains('X-axis (Month) from 1 to 12'));
      expect(desc, contains('Y-axis (Amount) from 0 to 1000'));
      expect(desc, contains('General trend: upward'));
      expect(desc, contains('Peak revenue of 1000 in December'));
    });
  });
}
