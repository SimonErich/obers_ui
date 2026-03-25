import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OiThresholdLabelPosition
// ─────────────────────────────────────────────────────────────────────────────

/// Position of a threshold label relative to the threshold line.
///
/// {@category Models}
enum OiThresholdLabelPosition {
  /// Label positioned above the threshold line.
  above,

  /// Label positioned below the threshold line.
  below,

  /// Label positioned inline with the threshold line.
  inline,

  /// Label positioned at the start (left for horizontal).
  start,

  /// Label positioned at the end (right for horizontal).
  end,
}

// ─────────────────────────────────────────────────────────────────────────────
// OiChartThreshold
// ─────────────────────────────────────────────────────────────────────────────

/// A threshold line drawn across the chart at a specific value.
///
/// Thresholds are typically used to mark target values, limits, or
/// benchmarks. They render as horizontal lines with optional labels.
///
/// {@category Models}
@immutable
class OiChartThreshold {
  /// Creates an [OiChartThreshold].
  const OiChartThreshold({
    required this.value,
    this.label,
    this.color,
    this.dashPattern,
    this.strokeWidth = 1.0,
    this.showLabel = true,
    this.labelPosition = OiThresholdLabelPosition.end,
    this.semanticLabel,
  });

  /// The y-axis value where the threshold is drawn.
  final num value;

  /// An optional text label displayed alongside the threshold line.
  final String? label;

  /// The line color. When null, derived from theme annotation color.
  final Color? color;

  /// Dash pattern for the line. Null means solid.
  final List<double>? dashPattern;

  /// The line width in logical pixels.
  final double strokeWidth;

  /// Whether to show the label.
  final bool showLabel;

  /// Position of the label relative to the threshold line.
  final OiThresholdLabelPosition labelPosition;

  /// Accessibility label for screen readers.
  final String? semanticLabel;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiChartThreshold &&
        other.value == value &&
        other.label == label &&
        other.color == color &&
        listEquals(other.dashPattern, dashPattern) &&
        other.strokeWidth == strokeWidth &&
        other.showLabel == showLabel &&
        other.labelPosition == labelPosition &&
        other.semanticLabel == semanticLabel;
  }

  @override
  int get hashCode => Object.hash(
    value,
    label,
    color,
    dashPattern == null ? null : Object.hashAll(dashPattern!),
    strokeWidth,
    showLabel,
    labelPosition,
    semanticLabel,
  );

  @override
  String toString() => 'OiChartThreshold(value: $value, label: $label)';
}
