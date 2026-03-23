import 'package:flutter/widgets.dart';

/// Theme data for tab view components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiTabViewThemeData {
  /// Creates an [OiTabViewThemeData].
  const OiTabViewThemeData({
    this.contentAnimationDuration,
    this.contentAnimationCurve,
    this.tabBarPadding,
    this.contentPadding,
  });

  /// The duration of the content transition animation.
  final Duration? contentAnimationDuration;

  /// The curve of the content transition animation.
  final Curve? contentAnimationCurve;

  /// The padding around the tab bar.
  final EdgeInsets? tabBarPadding;

  /// The padding around the tab content area.
  final EdgeInsets? contentPadding;

  /// Creates a copy with optionally overridden values.
  OiTabViewThemeData copyWith({
    Duration? contentAnimationDuration,
    Curve? contentAnimationCurve,
    EdgeInsets? tabBarPadding,
    EdgeInsets? contentPadding,
  }) {
    return OiTabViewThemeData(
      contentAnimationDuration:
          contentAnimationDuration ?? this.contentAnimationDuration,
      contentAnimationCurve:
          contentAnimationCurve ?? this.contentAnimationCurve,
      tabBarPadding: tabBarPadding ?? this.tabBarPadding,
      contentPadding: contentPadding ?? this.contentPadding,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiTabViewThemeData &&
        other.contentAnimationDuration == contentAnimationDuration &&
        other.contentAnimationCurve == contentAnimationCurve &&
        other.tabBarPadding == tabBarPadding &&
        other.contentPadding == contentPadding;
  }

  @override
  int get hashCode => Object.hash(
        contentAnimationDuration,
        contentAnimationCurve,
        tabBarPadding,
        contentPadding,
      );
}
