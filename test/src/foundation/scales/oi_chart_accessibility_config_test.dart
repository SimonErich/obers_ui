// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_accessibility_config.dart';

void main() {
  // ── OiSemanticVerbosity ───────────────────────────────────────────────────

  group('OiSemanticVerbosity', () {
    test('has all expected values', () {
      expect(OiSemanticVerbosity.values, hasLength(3));
      expect(OiSemanticVerbosity.values, containsAll([
        OiSemanticVerbosity.minimal,
        OiSemanticVerbosity.standard,
        OiSemanticVerbosity.verbose,
      ]));
    });
  });

  // ── OiChartSummaryData ────────────────────────────────────────────────────

  group('OiChartSummaryData', () {
    test('default values', () {
      const data = OiChartSummaryData(chartType: 'bar');

      expect(data.chartType, 'bar');
      expect(data.seriesLabels, isEmpty);
      expect(data.xAxisLabel, isNull);
      expect(data.yAxisLabel, isNull);
      expect(data.domainMin, isNull);
      expect(data.domainMax, isNull);
      expect(data.dataPointCount, 0);
      expect(data.insights, isEmpty);
    });

    test('equality', () {
      const a = OiChartSummaryData(
        chartType: 'line',
        seriesLabels: ['Revenue', 'Cost'],
        xAxisLabel: 'Month',
        yAxisLabel: 'USD',
        domainMin: 'Jan',
        domainMax: 'Dec',
        dataPointCount: 24,
        insights: ['Upward trend'],
      );

      const b = OiChartSummaryData(
        chartType: 'line',
        seriesLabels: ['Revenue', 'Cost'],
        xAxisLabel: 'Month',
        yAxisLabel: 'USD',
        domainMin: 'Jan',
        domainMax: 'Dec',
        dataPointCount: 24,
        insights: ['Upward trend'],
      );

      const c = OiChartSummaryData(
        chartType: 'bar',
        seriesLabels: ['Revenue'],
        dataPointCount: 12,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });

  // ── OiChartAccessibilityConfig ────────────────────────────────────────────

  group('OiChartAccessibilityConfig', () {
    test('default values', () {
      const config = OiChartAccessibilityConfig();

      expect(config.enabled, isTrue);
      expect(config.generateSummary, isTrue);
      expect(config.exposeDataTable, isFalse);
      expect(config.enableKeyboardExploration, isTrue);
      expect(config.verbosity, OiSemanticVerbosity.standard);
      expect(config.summaryBuilder, isNull);
    });

    test('disabled factory', () {
      const config = OiChartAccessibilityConfig.disabled();

      expect(config.enabled, isFalse);
      expect(config.generateSummary, isFalse);
      expect(config.exposeDataTable, isFalse);
      expect(config.enableKeyboardExploration, isFalse);
      expect(config.verbosity, OiSemanticVerbosity.minimal);
      expect(config.summaryBuilder, isNull);
    });

    test('copyWith preserves unchanged values', () {
      const original = OiChartAccessibilityConfig(
        exposeDataTable: true,
        verbosity: OiSemanticVerbosity.verbose,
      );

      final copy = original.copyWith(enableKeyboardExploration: false);

      expect(copy.enabled, isTrue);
      expect(copy.generateSummary, isTrue);
      expect(copy.exposeDataTable, isTrue);
      expect(copy.enableKeyboardExploration, isFalse);
      expect(copy.verbosity, OiSemanticVerbosity.verbose);
    });

    test('equality', () {
      const a = OiChartAccessibilityConfig();
      const b = OiChartAccessibilityConfig();
      const c = OiChartAccessibilityConfig(enabled: false);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    // ── buildSummary ──────────────────────────────────────────────────────

    group('buildSummary', () {
      const data = OiChartSummaryData(
        chartType: 'bar',
        seriesLabels: ['Revenue', 'Cost'],
        xAxisLabel: 'Month',
        yAxisLabel: 'USD',
        domainMin: '0',
        domainMax: '1000',
        dataPointCount: 24,
        insights: ['Revenue peaks in Q3', 'Downward trend in Q4'],
      );

      test('returns empty string when disabled', () {
        const config = OiChartAccessibilityConfig.disabled();
        expect(config.buildSummary(data), '');
      });

      test('returns empty string when generateSummary is false', () {
        const config = OiChartAccessibilityConfig(generateSummary: false);
        expect(config.buildSummary(data), '');
      });

      test('uses custom summaryBuilder when provided', () {
        final config = OiChartAccessibilityConfig(
          summaryBuilder: (d) => 'Custom: ${d.chartType}',
        );
        expect(config.buildSummary(data), 'Custom: bar');
      });

      test('minimal verbosity includes chart type and count only', () {
        const config = OiChartAccessibilityConfig(
          verbosity: OiSemanticVerbosity.minimal,
        );
        final summary = config.buildSummary(data);

        expect(summary, contains('Bar chart'));
        expect(summary, contains('24 data points'));
        expect(summary, contains('Revenue, Cost'));
        // Should NOT include axes or insights at minimal level.
        expect(summary, isNot(contains('Axes')));
        expect(summary, isNot(contains('Insights')));
      });

      test('standard verbosity includes axes and range', () {
        const config = OiChartAccessibilityConfig(
          verbosity: OiSemanticVerbosity.standard,
        );
        final summary = config.buildSummary(data);

        expect(summary, contains('Bar chart'));
        expect(summary, contains('24 data points'));
        expect(summary, contains('Revenue, Cost'));
        expect(summary, contains('x-axis: Month'));
        expect(summary, contains('y-axis: USD'));
        expect(summary, contains('Range: 0 to 1000'));
        // Should NOT include insights at standard level.
        expect(summary, isNot(contains('Insights')));
      });

      test('verbose verbosity includes insights', () {
        const config = OiChartAccessibilityConfig(
          verbosity: OiSemanticVerbosity.verbose,
        );
        final summary = config.buildSummary(data);

        expect(summary, contains('Bar chart'));
        expect(summary, contains('Axes'));
        expect(summary, contains('Range'));
        expect(summary, contains('Insights'));
        expect(summary, contains('Revenue peaks in Q3'));
        expect(summary, contains('Downward trend in Q4'));
      });

      test('handles single data point grammar', () {
        const singleData = OiChartSummaryData(
          chartType: 'pie',
          dataPointCount: 1,
        );
        const config = OiChartAccessibilityConfig();
        final summary = config.buildSummary(singleData);

        expect(summary, contains('1 data point'));
        expect(summary, isNot(contains('1 data points')));
      });

      test('handles no series labels', () {
        const noSeries = OiChartSummaryData(
          chartType: 'line',
          dataPointCount: 10,
        );
        const config = OiChartAccessibilityConfig();
        final summary = config.buildSummary(noSeries);

        expect(summary, contains('Line chart'));
        expect(summary, isNot(contains('series')));
      });

      test('handles missing axes', () {
        const noAxes = OiChartSummaryData(
          chartType: 'pie',
          dataPointCount: 5,
        );
        const config = OiChartAccessibilityConfig(
          verbosity: OiSemanticVerbosity.standard,
        );
        final summary = config.buildSummary(noAxes);

        expect(summary, isNot(contains('Axes')));
      });

      test('handles partial domain range', () {
        const partialRange = OiChartSummaryData(
          chartType: 'bar',
          domainMin: '0',
          dataPointCount: 5,
        );
        const config = OiChartAccessibilityConfig(
          verbosity: OiSemanticVerbosity.standard,
        );
        final summary = config.buildSummary(partialRange);

        expect(summary, isNot(contains('Range')));
      });

      test('handles empty insights at verbose level', () {
        const noInsights = OiChartSummaryData(
          chartType: 'line',
          dataPointCount: 10,
        );
        const config = OiChartAccessibilityConfig(
          verbosity: OiSemanticVerbosity.verbose,
        );
        final summary = config.buildSummary(noInsights);

        expect(summary, isNot(contains('Insights')));
      });

      test('capitalises chart type', () {
        const config = OiChartAccessibilityConfig(
          verbosity: OiSemanticVerbosity.minimal,
        );
        const data = OiChartSummaryData(
          chartType: 'scatter',
          dataPointCount: 50,
        );
        expect(config.buildSummary(data), startsWith('Scatter chart'));
      });
    });
  });
}
