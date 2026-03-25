import 'package:flutter/foundation.dart';

/// Typed domain range for an axis.
///
/// Specifies explicit min/max bounds that override the data-driven domain.
///
/// {@category Models}
@immutable
class OiAxisRange<TDomain> {
  /// Creates an [OiAxisRange].
  const OiAxisRange({this.min, this.max});

  /// The minimum domain value. When null, derived from data.
  final TDomain? min;

  /// The maximum domain value. When null, derived from data.
  final TDomain? max;

  /// Whether both min and max are specified.
  bool get isComplete => min != null && max != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiAxisRange<TDomain> &&
        other.min == min &&
        other.max == max;
  }

  @override
  int get hashCode => Object.hash(min, max);

  @override
  String toString() => 'OiAxisRange<$TDomain>(min: $min, max: $max)';
}
