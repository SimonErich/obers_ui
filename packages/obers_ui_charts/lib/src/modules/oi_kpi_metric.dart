import 'package:flutter/foundation.dart';
import 'package:obers_ui_charts/src/modules/oi_kpi_format.dart';

/// A single KPI data point for display in an [OiKpiBoard].
///
/// Carries the primary [value], an optional [previousValue] for delta
/// computation, formatting via [format], optional [sparklineData] for inline
/// trend visualization, a [target] for progress display, and a [status]
/// classification that drives color coding.
///
/// The computed [deltaPercent] getter returns the percentage change from
/// [previousValue] to [value], or `null` when no previous value is available.
///
/// ```dart
/// OiKpiMetric(
///   id: 'revenue',
///   title: 'Total Revenue',
///   value: 1_234_567,
///   previousValue: 1_100_000,
///   format: OiKpiFormat.currency(symbol: '\$'),
///   sparklineData: monthlySeries,
///   target: 1_500_000,
///   status: OiKpiStatus.onTrack,
/// )
/// ```
///
/// {@category Modules}
@immutable
class OiKpiMetric {
  /// Creates an [OiKpiMetric].
  const OiKpiMetric({
    required this.id,
    required this.title,
    required this.value,
    this.previousValue,
    this.format,
    this.sparklineData,
    this.target,
    this.status = OiKpiStatus.neutral,
  });

  /// A unique identifier for this metric.
  final String id;

  /// The human-readable title displayed above the value.
  final String title;

  /// The current numeric value of the metric.
  final num value;

  /// The previous period's value, used to compute [deltaPercent].
  ///
  /// When null, no delta indicator is shown on the card.
  final num? previousValue;

  /// The formatter used to render [value] and [previousValue] as strings.
  ///
  /// Defaults to a plain number formatter with no decimal places when null.
  final OiKpiFormat? format;

  /// Optional data series for an inline sparkline visualization.
  ///
  /// Each element is a numeric value plotted left-to-right in chronological
  /// order. When null or empty, no sparkline is rendered.
  final List<double>? sparklineData;

  /// An optional target value used to render a progress bar.
  ///
  /// When null, no target progress is shown.
  final num? target;

  /// The status classification used for color coding the card.
  final OiKpiStatus status;

  /// The percentage change from [previousValue] to [value].
  ///
  /// Returns `null` when [previousValue] is null or zero (to avoid
  /// division by zero).
  double? get deltaPercent {
    if (previousValue == null || previousValue == 0) return null;
    return ((value - previousValue!) / previousValue!.abs()) * 100;
  }

  /// The absolute change from [previousValue] to [value].
  ///
  /// Returns `null` when [previousValue] is null.
  num? get deltaAbsolute {
    if (previousValue == null) return null;
    return value - previousValue!;
  }

  /// The progress toward [target] as a fraction in [0.0, 1.0].
  ///
  /// Returns `null` when [target] is null or zero.
  double? get targetProgress {
    if (target == null || target == 0) return null;
    return (value / target!).clamp(0.0, 1.0).toDouble();
  }

  /// The formatted value string using [format], or a plain integer string.
  String get formattedValue =>
      format?.format(value) ?? value.toStringAsFixed(0);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiKpiMetric &&
        other.id == id &&
        other.title == title &&
        other.value == value &&
        other.previousValue == previousValue &&
        other.target == target &&
        other.status == status;
  }

  @override
  int get hashCode =>
      Object.hash(id, title, value, previousValue, target, status);
}
