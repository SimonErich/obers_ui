import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiFieldDisplay;
import 'package:obers_ui/src/components/display/oi_field_display.dart' show OiFieldDisplay;

/// Theme data for [OiFieldDisplay] components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiFieldDisplayThemeData {
  /// Creates an [OiFieldDisplayThemeData].
  const OiFieldDisplayThemeData({
    this.labelStyle,
    this.valueStyle,
    this.emptyStyle,
    this.linkStyle,
    this.labelWidth,
    this.pairGap,
    this.padding,
  });

  /// Linearly interpolates between two [OiFieldDisplayThemeData] instances.
  OiFieldDisplayThemeData.lerp(
    OiFieldDisplayThemeData a,
    OiFieldDisplayThemeData b,
    double t,
  )   : labelStyle = TextStyle.lerp(a.labelStyle, b.labelStyle, t),
        valueStyle = TextStyle.lerp(a.valueStyle, b.valueStyle, t),
        emptyStyle = TextStyle.lerp(a.emptyStyle, b.emptyStyle, t),
        linkStyle = TextStyle.lerp(a.linkStyle, b.linkStyle, t),
        labelWidth = lerpDouble(a.labelWidth, b.labelWidth, t),
        pairGap = lerpDouble(a.pairGap, b.pairGap, t),
        padding = EdgeInsetsGeometry.lerp(a.padding, b.padding, t);

  /// Text style for labels in pair mode.
  final TextStyle? labelStyle;

  /// Text style for values.
  final TextStyle? valueStyle;

  /// Text style for empty/null placeholder text.
  final TextStyle? emptyStyle;

  /// Text style for tappable link values (email, url, phone).
  final TextStyle? linkStyle;

  /// Default label width in horizontal pair mode.
  final double? labelWidth;

  /// Gap between label and value in pair mode.
  final double? pairGap;

  /// Padding around the field display.
  final EdgeInsetsGeometry? padding;

  /// Creates a copy with optionally overridden values.
  OiFieldDisplayThemeData copyWith({
    TextStyle? labelStyle,
    TextStyle? valueStyle,
    TextStyle? emptyStyle,
    TextStyle? linkStyle,
    double? labelWidth,
    double? pairGap,
    EdgeInsetsGeometry? padding,
  }) {
    return OiFieldDisplayThemeData(
      labelStyle: labelStyle ?? this.labelStyle,
      valueStyle: valueStyle ?? this.valueStyle,
      emptyStyle: emptyStyle ?? this.emptyStyle,
      linkStyle: linkStyle ?? this.linkStyle,
      labelWidth: labelWidth ?? this.labelWidth,
      pairGap: pairGap ?? this.pairGap,
      padding: padding ?? this.padding,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiFieldDisplayThemeData &&
        other.labelStyle == labelStyle &&
        other.valueStyle == valueStyle &&
        other.emptyStyle == emptyStyle &&
        other.linkStyle == linkStyle &&
        other.labelWidth == labelWidth &&
        other.pairGap == pairGap &&
        other.padding == padding;
  }

  @override
  int get hashCode => Object.hash(
    labelStyle,
    valueStyle,
    emptyStyle,
    linkStyle,
    labelWidth,
    pairGap,
    padding,
  );
}
