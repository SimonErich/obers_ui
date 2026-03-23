import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

/// The type of insight detected in chart data.
enum OiChartInsightType {
  /// An upward trend across the data range.
  trendUp,

  /// A downward trend across the data range.
  trendDown,

  /// No significant trend detected (flat or fluctuating).
  trendFlat,

  /// A notable maximum value in the data.
  maximum,

  /// A notable minimum value in the data.
  minimum,
}

/// A detected insight about chart data, such as a trend or extremum.
@immutable
class OiChartInsight {
  const OiChartInsight({
    required this.type,
    this.description,
    this.seriesIndex,
  });

  /// The kind of insight.
  final OiChartInsightType type;

  /// Optional human-readable description for this insight.
  final String? description;

  /// The series index this insight applies to, or `null` for overall.
  final int? seriesIndex;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiChartInsight &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          description == other.description &&
          seriesIndex == other.seriesIndex;

  @override
  int get hashCode => Object.hash(type, description, seriesIndex);
}

/// Captures chart metadata for accessibility and auto-generates
/// screen-reader-friendly descriptions.
///
/// Stores chart type, series labels, axis labels, domain ranges,
/// and detected insights (trends, extrema). Use [toDescription] to
/// produce a comprehensive summary suitable for screen readers.
@immutable
class OiChartAccessibilitySummary {
  const OiChartAccessibilitySummary({
    required this.chartType,
    this.seriesLabels = const [],
    this.xAxisLabel,
    this.yAxisLabel,
    this.xMin,
    this.xMax,
    this.yMin,
    this.yMax,
    this.insights = const [],
  });

  /// The chart type label (e.g. "Line chart", "Bar chart").
  final String chartType;

  /// Labels for each data series.
  final List<String> seriesLabels;

  /// The label for the x-axis.
  final String? xAxisLabel;

  /// The label for the y-axis.
  final String? yAxisLabel;

  /// Minimum x-domain value.
  final double? xMin;

  /// Maximum x-domain value.
  final double? xMax;

  /// Minimum y-domain value.
  final double? yMin;

  /// Maximum y-domain value.
  final double? yMax;

  /// Detected chart insights such as trends and notable extrema.
  final List<OiChartInsight> insights;

  /// Auto-generates a screen-reader-friendly description from the model.
  ///
  /// Includes chart type, number of series, series labels, axis domain
  /// ranges, and detected trend direction.
  String toDescription() {
    final buffer = StringBuffer(chartType);

    // Series info
    final count = seriesLabels.length;
    if (count > 0) {
      final seriesDesc = count == 1 ? '1 series' : '$count series';
      buffer.write(' with $seriesDesc');
      if (count <= 5) {
        buffer.write(': ${seriesLabels.join(', ')}');
      }
    }

    buffer.write('.');

    // Axis labels and ranges
    final hasXRange = xMin != null && xMax != null;
    final hasYRange = yMin != null && yMax != null;

    if (xAxisLabel != null || hasXRange) {
      buffer.write(' X-axis');
      if (xAxisLabel != null) buffer.write(' ($xAxisLabel)');
      if (hasXRange) {
        buffer.write(' from ${_format(xMin!)} to ${_format(xMax!)}');
      }
      buffer.write('.');
    }

    if (yAxisLabel != null || hasYRange) {
      buffer.write(' Y-axis');
      if (yAxisLabel != null) buffer.write(' ($yAxisLabel)');
      if (hasYRange) {
        buffer.write(' from ${_format(yMin!)} to ${_format(yMax!)}');
      }
      buffer.write('.');
    }

    // Trend insights
    final trends = insights.where(
      (i) =>
          i.type == OiChartInsightType.trendUp ||
          i.type == OiChartInsightType.trendDown ||
          i.type == OiChartInsightType.trendFlat,
    );
    for (final trend in trends) {
      if (trend.description != null) {
        buffer.write(' ${trend.description}.');
      } else {
        buffer.write(' ${_trendLabel(trend.type)}.');
      }
    }

    // Extrema insights
    final extrema = insights.where(
      (i) =>
          i.type == OiChartInsightType.maximum ||
          i.type == OiChartInsightType.minimum,
    );
    for (final ex in extrema) {
      if (ex.description != null) {
        buffer.write(' ${ex.description}.');
      }
    }

    return buffer.toString();
  }

  static String _trendLabel(OiChartInsightType type) {
    switch (type) {
      case OiChartInsightType.trendUp:
        return 'General trend: upward';
      case OiChartInsightType.trendDown:
        return 'General trend: downward';
      case OiChartInsightType.trendFlat:
        return 'General trend: flat';
      case OiChartInsightType.maximum:
      case OiChartInsightType.minimum:
        return '';
    }
  }

  static String _format(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiChartAccessibilitySummary &&
          runtimeType == other.runtimeType &&
          chartType == other.chartType &&
          listEquals(seriesLabels, other.seriesLabels) &&
          xAxisLabel == other.xAxisLabel &&
          yAxisLabel == other.yAxisLabel &&
          xMin == other.xMin &&
          xMax == other.xMax &&
          yMin == other.yMin &&
          yMax == other.yMax &&
          listEquals(insights, other.insights);

  @override
  int get hashCode => Object.hash(
        chartType,
        Object.hashAll(seriesLabels),
        xAxisLabel,
        yAxisLabel,
        xMin,
        xMax,
        yMin,
        yMax,
        Object.hashAll(insights),
      );
}

/// Callback type for custom accessibility summary overrides.
typedef OiChartA11ySummaryBuilder = String Function(
    OiChartAccessibilitySummary summary);

/// Static helpers for chart accessibility semantics.
class OiChartA11y {
  OiChartA11y._();

  /// Generates a semantic description for a chart.
  ///
  /// When a [summary] is provided, delegates to [summary.toDescription()]
  /// (or [summaryBuilder] if supplied). Otherwise falls back to the basic
  /// description format.
  static String describeChart(
    String chartType,
    int seriesCount,
    int totalPoints, {
    OiChartAccessibilitySummary? summary,
    OiChartA11ySummaryBuilder? summaryBuilder,
  }) {
    if (summary != null) {
      if (summaryBuilder != null) return summaryBuilder(summary);
      return summary.toDescription();
    }
    final seriesDesc =
        seriesCount == 1 ? '1 series' : '$seriesCount series';
    final pointDesc =
        totalPoints == 1 ? '1 data point' : '$totalPoints data points';
    return '$chartType with $seriesDesc and $pointDesc';
  }

  /// Builds an [OiChartAccessibilitySummary] from Cartesian chart data,
  /// automatically inferring trend direction from the first series.
  static OiChartAccessibilitySummary buildCartesianSummary({
    required String chartType,
    required List<String> seriesLabels,
    String? xAxisLabel,
    String? yAxisLabel,
    double? xMin,
    double? xMax,
    double? yMin,
    double? yMax,
    List<List<double>>? seriesYValues,
  }) {
    final insights = <OiChartInsight>[];

    // Infer trend from first series y-values if available.
    if (seriesYValues != null && seriesYValues.isNotEmpty) {
      final firstSeries = seriesYValues.first;
      if (firstSeries.length >= 2) {
        insights.add(OiChartInsight(type: _inferTrend(firstSeries)));
      }
    }

    return OiChartAccessibilitySummary(
      chartType: chartType,
      seriesLabels: seriesLabels,
      xAxisLabel: xAxisLabel,
      yAxisLabel: yAxisLabel,
      xMin: xMin,
      xMax: xMax,
      yMin: yMin,
      yMax: yMax,
      insights: insights,
    );
  }

  /// Infers trend direction from a list of y-values using linear regression
  /// slope sign.
  static OiChartInsightType _inferTrend(List<double> yValues) {
    if (yValues.length < 2) return OiChartInsightType.trendFlat;

    final n = yValues.length;
    var sumX = 0.0;
    var sumY = 0.0;
    var sumXY = 0.0;
    var sumX2 = 0.0;

    for (var i = 0; i < n; i++) {
      sumX += i;
      sumY += yValues[i];
      sumXY += i * yValues[i];
      sumX2 += i * i;
    }

    final denominator = n * sumX2 - sumX * sumX;
    if (denominator == 0) return OiChartInsightType.trendFlat;

    final slope = (n * sumXY - sumX * sumY) / denominator;

    // Use a relative threshold to determine significance.
    final yRange = yValues.reduce(
          (a, b) => a > b ? a : b,
        ) -
        yValues.reduce((a, b) => a < b ? a : b);
    final threshold = yRange * 0.05;

    if (slope > threshold) return OiChartInsightType.trendUp;
    if (slope < -threshold) return OiChartInsightType.trendDown;
    return OiChartInsightType.trendFlat;
  }

  /// Generates a semantic description for a single data point.
  static String describeDataPoint(
    String seriesName,
    double x,
    double y, {
    String? label,
  }) {
    final buffer = StringBuffer('$seriesName: ');
    if (label != null) {
      buffer.write('$label, ');
    }
    buffer.write('x=${_format(x)}, y=${_format(y)}');
    return buffer.toString();
  }

  /// Announces a selection change via semantics.
  static void announceSelection(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  static String _format(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }
}
