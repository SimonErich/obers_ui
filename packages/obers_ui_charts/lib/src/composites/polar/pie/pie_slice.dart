import 'package:flutter/foundation.dart';

/// A computed slice of a pie chart.
@immutable
class OiPieSlice {
  const OiPieSlice({
    required this.startAngle,
    required this.sweepAngle,
    required this.value,
    required this.percentage,
    this.label,
  });

  /// The start angle in radians, measured clockwise from the top (12 o'clock).
  final double startAngle;

  /// The sweep angle in radians.
  final double sweepAngle;

  /// The raw data value for this slice.
  final double value;

  /// The percentage of the total (0.0 to 100.0).
  final double percentage;

  /// Optional label from the data point.
  final String? label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiPieSlice &&
          runtimeType == other.runtimeType &&
          startAngle == other.startAngle &&
          sweepAngle == other.sweepAngle &&
          value == other.value &&
          percentage == other.percentage &&
          label == other.label;

  @override
  int get hashCode =>
      Object.hash(startAngle, sweepAngle, value, percentage, label);
}
