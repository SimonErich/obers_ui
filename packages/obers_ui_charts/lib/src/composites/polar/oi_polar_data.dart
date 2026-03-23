import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';

/// A single segment of a polar chart.
@immutable
class OiPolarSegment {
  /// Creates a polar segment. Negative [value] is clamped to zero.
  OiPolarSegment({
    required this.label,
    required double value,
    this.color,
  }) : value = math.max(0, value);

  final String label;
  final double value;
  final Color? color;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiPolarSegment &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          value == other.value &&
          color == other.color;

  @override
  int get hashCode => Object.hash(label, value, color);
}

/// Data contract for polar/radial chart types.
class OiPolarData {
  const OiPolarData({required this.segments});

  final List<OiPolarSegment> segments;

  bool get isEmpty => segments.isEmpty;

  /// The sum of all segment values.
  double get total => segments.fold(0, (sum, s) => sum + s.value);
}
