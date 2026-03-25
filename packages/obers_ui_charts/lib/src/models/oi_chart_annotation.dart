import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OiAnnotationType
// ─────────────────────────────────────────────────────────────────────────────

/// The type of chart annotation.
///
/// {@category Models}
enum OiAnnotationType {
  /// A horizontal line at a specific y-value.
  horizontalLine,

  /// A vertical line at a specific x-value.
  verticalLine,

  /// A rectangular region between two domain values.
  region,

  /// A point marker at a specific (x, y) position.
  point,

  /// A floating text label at a specific position.
  label,
}

// ─────────────────────────────────────────────────────────────────────────────
// OiAnnotationStyle
// ─────────────────────────────────────────────────────────────────────────────

/// Visual style for a chart annotation.
///
/// {@category Models}
@immutable
class OiAnnotationStyle {
  /// Creates an [OiAnnotationStyle].
  const OiAnnotationStyle({
    this.color,
    this.strokeWidth = 1.0,
    this.dashPattern,
    this.fill,
    this.labelStyle,
  });

  /// Line/border color. When null, derived from theme.
  final Color? color;

  /// Line/border width in logical pixels.
  final double strokeWidth;

  /// Dash pattern for the line. Null means solid.
  final List<double>? dashPattern;

  /// Fill color for region annotations. When null, no fill.
  final Color? fill;

  /// Text style for the annotation label. When null, derived from theme.
  final TextStyle? labelStyle;

  /// Creates a copy with optionally overridden values.
  OiAnnotationStyle copyWith({
    Color? color,
    double? strokeWidth,
    List<double>? dashPattern,
    Color? fill,
    TextStyle? labelStyle,
  }) {
    return OiAnnotationStyle(
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      dashPattern: dashPattern ?? this.dashPattern,
      fill: fill ?? this.fill,
      labelStyle: labelStyle ?? this.labelStyle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiAnnotationStyle &&
        other.color == color &&
        other.strokeWidth == strokeWidth &&
        listEquals(other.dashPattern, dashPattern) &&
        other.fill == fill &&
        other.labelStyle == labelStyle;
  }

  @override
  int get hashCode => Object.hash(
    color,
    strokeWidth,
    dashPattern == null ? null : Object.hashAll(dashPattern!),
    fill,
    labelStyle,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// OiChartAnnotation
// ─────────────────────────────────────────────────────────────────────────────

/// A chart annotation marking a notable data value, range, or position.
///
/// {@category Models}
@immutable
class OiChartAnnotation {
  /// Creates an [OiChartAnnotation].
  const OiChartAnnotation({
    required this.type,
    this.value,
    this.start,
    this.end,
    this.label,
    this.style,
    this.visible = true,
    this.semanticLabel,
  });

  /// Creates a horizontal line annotation.
  const OiChartAnnotation.horizontalLine({
    required double value,
    String? label,
    OiAnnotationStyle? style,
    String? semanticLabel,
  }) : this(
         type: OiAnnotationType.horizontalLine,
         value: value,
         label: label,
         style: style,
         semanticLabel: semanticLabel,
       );

  /// Creates a vertical line annotation.
  const OiChartAnnotation.verticalLine({
    required double value,
    String? label,
    OiAnnotationStyle? style,
    String? semanticLabel,
  }) : this(
         type: OiAnnotationType.verticalLine,
         value: value,
         label: label,
         style: style,
         semanticLabel: semanticLabel,
       );

  /// Creates a region annotation spanning a range.
  const OiChartAnnotation.region({
    required double start,
    required double end,
    String? label,
    OiAnnotationStyle? style,
    String? semanticLabel,
  }) : this(
         type: OiAnnotationType.region,
         start: start,
         end: end,
         label: label,
         style: style,
         semanticLabel: semanticLabel,
       );

  /// The annotation type.
  final OiAnnotationType type;

  /// The domain value for line/point annotations.
  final double? value;

  /// The start of the range for region annotations.
  final double? start;

  /// The end of the range for region annotations.
  final double? end;

  /// An optional text label displayed with the annotation.
  final String? label;

  /// Visual style. When null, derived from theme.
  final OiAnnotationStyle? style;

  /// Whether the annotation is visible.
  final bool visible;

  /// Accessibility label for screen readers.
  final String? semanticLabel;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiChartAnnotation &&
        other.type == type &&
        other.value == value &&
        other.start == start &&
        other.end == end &&
        other.label == label &&
        other.style == style &&
        other.visible == visible &&
        other.semanticLabel == semanticLabel;
  }

  @override
  int get hashCode => Object.hash(
    type,
    value,
    start,
    end,
    label,
    style,
    visible,
    semanticLabel,
  );

  @override
  String toString() =>
      'OiChartAnnotation(type: $type, value: $value, label: $label)';
}
