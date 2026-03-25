import 'package:flutter/foundation.dart';

/// The verbosity level for chart semantic descriptions.
///
/// Controls how much detail is included in auto-generated accessibility
/// summaries.
///
/// {@category Foundation}
enum OiSemanticVerbosity {
  /// Minimal: chart type and data count only.
  minimal,

  /// Standard: chart type, series labels, axis labels, and domain ranges.
  standard,

  /// Verbose: everything in [standard] plus detected insights such as
  /// min/max values, trends, and outliers.
  verbose,
}

/// Information about a chart's structure, passed to [OiChartSummaryBuilder]
/// for custom summary generation.
///
/// {@category Foundation}
@immutable
class OiChartSummaryData {
  /// Creates an [OiChartSummaryData].
  const OiChartSummaryData({
    required this.chartType,
    this.seriesLabels = const [],
    this.xAxisLabel,
    this.yAxisLabel,
    this.domainMin,
    this.domainMax,
    this.dataPointCount = 0,
    this.insights = const [],
  });

  /// The type of chart (e.g. "bar", "line", "pie").
  final String chartType;

  /// Labels of each data series.
  final List<String> seriesLabels;

  /// Label for the x-axis, if any.
  final String? xAxisLabel;

  /// Label for the y-axis, if any.
  final String? yAxisLabel;

  /// The minimum value in the domain, formatted as a string.
  final String? domainMin;

  /// The maximum value in the domain, formatted as a string.
  final String? domainMax;

  /// Total number of data points across all series.
  final int dataPointCount;

  /// Detected insights (e.g. "Revenue peaks in Q3", "Downward trend").
  final List<String> insights;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiChartSummaryData &&
        other.chartType == chartType &&
        listEquals(other.seriesLabels, seriesLabels) &&
        other.xAxisLabel == xAxisLabel &&
        other.yAxisLabel == yAxisLabel &&
        other.domainMin == domainMin &&
        other.domainMax == domainMax &&
        other.dataPointCount == dataPointCount &&
        listEquals(other.insights, insights);
  }

  @override
  int get hashCode => Object.hash(
    chartType,
    Object.hashAll(seriesLabels),
    xAxisLabel,
    yAxisLabel,
    domainMin,
    domainMax,
    dataPointCount,
    Object.hashAll(insights),
  );
}

/// A function that builds a custom accessibility summary from chart data.
///
/// Receives the [OiChartSummaryData] describing the chart and returns a
/// human-readable summary string for screen readers.
typedef OiChartSummaryBuilder = String Function(OiChartSummaryData data);

/// Controls chart accessibility features.
///
/// [OiChartAccessibilityConfig] determines which accessibility features a
/// chart exposes: whether to generate semantic summaries, expose an
/// accessible data table, enable keyboard exploration, and how verbose
/// the descriptions should be.
///
/// When [enabled] is true and [generateSummary] is true, charts
/// auto-generate semantic descriptions that include the chart type, series
/// labels, axis labels, domain ranges, and detected insights (depending
/// on [verbosity]).
///
/// A custom [summaryBuilder] can override the auto-generated summary with
/// a domain-specific description.
///
/// {@category Foundation}
@immutable
class OiChartAccessibilityConfig {
  /// Creates an [OiChartAccessibilityConfig].
  const OiChartAccessibilityConfig({
    this.enabled = true,
    this.generateSummary = true,
    this.exposeDataTable = false,
    this.enableKeyboardExploration = true,
    this.verbosity = OiSemanticVerbosity.standard,
    this.summaryBuilder,
  });

  /// A config with all accessibility features disabled.
  const OiChartAccessibilityConfig.disabled()
    : enabled = false,
      generateSummary = false,
      exposeDataTable = false,
      enableKeyboardExploration = false,
      verbosity = OiSemanticVerbosity.minimal,
      summaryBuilder = null;

  /// Whether accessibility features are enabled for this chart.
  final bool enabled;

  /// Whether to auto-generate a semantic summary of the chart data.
  ///
  /// When true, a `Semantics` label is built from chart metadata
  /// (chart type, series, axes, domain ranges, and insights).
  final bool generateSummary;

  /// Whether to expose chart data as an accessible table.
  ///
  /// When true, chart data is available as a semantic table structure
  /// that assistive technologies can navigate.
  final bool exposeDataTable;

  /// Whether keyboard exploration of data points is enabled.
  ///
  /// When true, users can navigate between data points using arrow
  /// keys and read individual values.
  final bool enableKeyboardExploration;

  /// The verbosity level for auto-generated semantic descriptions.
  final OiSemanticVerbosity verbosity;

  /// An optional custom summary builder.
  ///
  /// When provided, this replaces the auto-generated summary with a
  /// custom description. The builder receives [OiChartSummaryData]
  /// containing all chart metadata.
  final OiChartSummaryBuilder? summaryBuilder;

  /// Builds an accessibility summary for the given [data].
  ///
  /// If a [summaryBuilder] is provided, delegates to it. Otherwise,
  /// auto-generates a summary based on the [verbosity] level.
  ///
  /// Returns an empty string when [enabled] or [generateSummary] is false.
  String buildSummary(OiChartSummaryData data) {
    if (!enabled || !generateSummary) return '';
    if (summaryBuilder != null) return summaryBuilder!(data);
    return _autoGenerateSummary(data);
  }

  String _autoGenerateSummary(OiChartSummaryData data) {
    final buffer = StringBuffer()
      // Chart type and data count (always included).
      ..write(
        '${_capitalise(data.chartType)} chart with '
        '${data.dataPointCount} data point'
        '${data.dataPointCount == 1 ? '' : 's'}',
      );

    // Series labels.
    if (data.seriesLabels.isNotEmpty) {
      final count = data.seriesLabels.length;
      buffer.write(
        ' across $count series: '
        '${data.seriesLabels.join(', ')}',
      );
    }

    buffer.write('.');

    if (verbosity == OiSemanticVerbosity.minimal) {
      return buffer.toString();
    }

    // Axis labels.
    if (data.xAxisLabel != null || data.yAxisLabel != null) {
      final parts = <String>[];
      if (data.xAxisLabel != null) parts.add('x-axis: ${data.xAxisLabel}');
      if (data.yAxisLabel != null) parts.add('y-axis: ${data.yAxisLabel}');
      buffer.write(' Axes: ${parts.join(', ')}.');
    }

    // Domain range.
    if (data.domainMin != null && data.domainMax != null) {
      buffer.write(' Range: ${data.domainMin} to ${data.domainMax}.');
    }

    if (verbosity == OiSemanticVerbosity.standard) {
      return buffer.toString();
    }

    // Insights (verbose only).
    if (data.insights.isNotEmpty) {
      buffer.write(' Insights: ${data.insights.join('; ')}.');
    }

    return buffer.toString();
  }

  static String _capitalise(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  /// Creates a copy with optionally overridden values.
  OiChartAccessibilityConfig copyWith({
    bool? enabled,
    bool? generateSummary,
    bool? exposeDataTable,
    bool? enableKeyboardExploration,
    OiSemanticVerbosity? verbosity,
    OiChartSummaryBuilder? summaryBuilder,
  }) {
    return OiChartAccessibilityConfig(
      enabled: enabled ?? this.enabled,
      generateSummary: generateSummary ?? this.generateSummary,
      exposeDataTable: exposeDataTable ?? this.exposeDataTable,
      enableKeyboardExploration:
          enableKeyboardExploration ?? this.enableKeyboardExploration,
      verbosity: verbosity ?? this.verbosity,
      summaryBuilder: summaryBuilder ?? this.summaryBuilder,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiChartAccessibilityConfig &&
        other.enabled == enabled &&
        other.generateSummary == generateSummary &&
        other.exposeDataTable == exposeDataTable &&
        other.enableKeyboardExploration == enableKeyboardExploration &&
        other.verbosity == verbosity &&
        other.summaryBuilder == summaryBuilder;
  }

  @override
  int get hashCode => Object.hash(
    enabled,
    generateSummary,
    exposeDataTable,
    enableKeyboardExploration,
    verbosity,
    summaryBuilder,
  );
}
