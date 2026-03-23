import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiRefreshIndicator;
import 'package:obers_ui/src/components/display/oi_refresh_indicator.dart' show OiRefreshIndicator;

/// Theme overrides for [OiRefreshIndicator].
///
/// Controls the visual appearance and animation behavior of the
/// pull-to-refresh indicator.
///
/// {@category Foundation}
@immutable
class OiRefreshIndicatorThemeData {
  /// Creates an [OiRefreshIndicatorThemeData].
  const OiRefreshIndicatorThemeData({
    this.indicatorColor,
    this.indicatorBackgroundColor,
    this.displacement,
    this.triggerDistance,
    this.indicatorSize,
    this.strokeWidth,
    this.snapBackDuration,
    this.completionHideDuration,
    this.snapBackCurve,
    this.completionCurve,
  });

  /// Color of the progress spinner.
  final Color? indicatorColor;

  /// Background color of the circular indicator container.
  final Color? indicatorBackgroundColor;

  /// Distance the indicator is inset from the top of the scrollable.
  final double? displacement;

  /// How far the user must overscroll before a refresh is triggered.
  final double? triggerDistance;

  /// Diameter of the progress indicator.
  final double? indicatorSize;

  /// Stroke width of the progress spinner.
  final double? strokeWidth;

  /// Duration of the snap-back animation when drag is released without
  /// reaching the trigger distance.
  final Duration? snapBackDuration;

  /// Duration of the hide animation when the refresh completes.
  final Duration? completionHideDuration;

  /// Curve for the snap-back animation.
  final Curve? snapBackCurve;

  /// Curve for the completion hide animation.
  final Curve? completionCurve;

  /// Creates a copy with optionally overridden values.
  OiRefreshIndicatorThemeData copyWith({
    Color? indicatorColor,
    Color? indicatorBackgroundColor,
    double? displacement,
    double? triggerDistance,
    double? indicatorSize,
    double? strokeWidth,
    Duration? snapBackDuration,
    Duration? completionHideDuration,
    Curve? snapBackCurve,
    Curve? completionCurve,
  }) {
    return OiRefreshIndicatorThemeData(
      indicatorColor: indicatorColor ?? this.indicatorColor,
      indicatorBackgroundColor:
          indicatorBackgroundColor ?? this.indicatorBackgroundColor,
      displacement: displacement ?? this.displacement,
      triggerDistance: triggerDistance ?? this.triggerDistance,
      indicatorSize: indicatorSize ?? this.indicatorSize,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      snapBackDuration: snapBackDuration ?? this.snapBackDuration,
      completionHideDuration:
          completionHideDuration ?? this.completionHideDuration,
      snapBackCurve: snapBackCurve ?? this.snapBackCurve,
      completionCurve: completionCurve ?? this.completionCurve,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiRefreshIndicatorThemeData &&
        other.indicatorColor == indicatorColor &&
        other.indicatorBackgroundColor == indicatorBackgroundColor &&
        other.displacement == displacement &&
        other.triggerDistance == triggerDistance &&
        other.indicatorSize == indicatorSize &&
        other.strokeWidth == strokeWidth &&
        other.snapBackDuration == snapBackDuration &&
        other.completionHideDuration == completionHideDuration &&
        other.snapBackCurve == snapBackCurve &&
        other.completionCurve == completionCurve;
  }

  @override
  int get hashCode => Object.hash(
        indicatorColor,
        indicatorBackgroundColor,
        displacement,
        triggerDistance,
        indicatorSize,
        strokeWidth,
        snapBackDuration,
        completionHideDuration,
        snapBackCurve,
        completionCurve,
      );
}
