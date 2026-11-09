import 'package:flutter/widgets.dart';

/// Appearance overrides for step indicators and detailed timeline layouts.
///
/// Null values retain the component's defaults. Spacing applies only to the
/// opt-in timeline layout; ordinary horizontal/vertical layouts are unchanged.
@immutable
class OiStepperThemeData {
  /// Creates stepper appearance overrides.
  const OiStepperThemeData({
    this.indicatorBorderColor,
    this.indicatorBorderWidth,
    this.connectorColor,
    this.stepSpacing,
    this.detailsSpacing,
  });

  /// Border of an upcoming indicator; active/error/completed colors prevail.
  final Color? indicatorBorderColor;

  /// Upcoming indicator stroke width; defaults to 2, or 1 in timeline mode.
  /// Current, completed and error indicators retain their 2px state stroke.
  final double? indicatorBorderWidth;

  /// Upcoming connector color; completed state colors retain precedence.
  final Color? connectorColor;

  /// Space after each nonfinal timeline item; defaults to 20.
  final double? stepSpacing;

  /// Timeline label-to-details spacing; defaults to 2.
  final double? detailsSpacing;

  /// Copies this configuration, preserving omitted values.
  OiStepperThemeData copyWith({
    Color? indicatorBorderColor,
    double? indicatorBorderWidth,
    Color? connectorColor,
    double? stepSpacing,
    double? detailsSpacing,
  }) => OiStepperThemeData(
    indicatorBorderColor: indicatorBorderColor ?? this.indicatorBorderColor,
    indicatorBorderWidth: indicatorBorderWidth ?? this.indicatorBorderWidth,
    connectorColor: connectorColor ?? this.connectorColor,
    stepSpacing: stepSpacing ?? this.stepSpacing,
    detailsSpacing: detailsSpacing ?? this.detailsSpacing,
  );

  @override
  bool operator ==(Object other) =>
      other is OiStepperThemeData &&
      other.indicatorBorderColor == indicatorBorderColor &&
      other.indicatorBorderWidth == indicatorBorderWidth &&
      other.connectorColor == connectorColor &&
      other.stepSpacing == stepSpacing &&
      other.detailsSpacing == detailsSpacing;

  @override
  int get hashCode => Object.hash(
    indicatorBorderColor,
    indicatorBorderWidth,
    connectorColor,
    stepSpacing,
    detailsSpacing,
  );
}
