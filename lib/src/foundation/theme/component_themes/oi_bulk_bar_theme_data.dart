import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_button_theme_data.dart';

/// Typography and action treatment for selection toolbars.
///
/// Overrides apply inside the bar after its optional inverse color scope.
/// {@category Foundation}
@immutable
class OiBulkBarThemeData {
  /// Creates nullable selection-toolbar overrides.
  const OiBulkBarThemeData({
    this.labelStyle,
    this.actionStyle,
    this.destructiveActionStyle,
    this.compactSeparator,
    this.padding,
    this.borderRadius,
  });

  /// Selected-record count typography.
  final TextStyle? labelStyle;

  /// Ghost action colors, including hover/pressed states.
  final OiButtonVariantStyle? actionStyle;

  /// Destructive action colors, including hover/pressed states.
  final OiButtonVariantStyle? destructiveActionStyle;

  /// Separates the count from compact actions with a vertical line.
  final bool? compactSeparator;

  /// Internal bar padding.
  final EdgeInsetsGeometry? padding;

  /// Outer surface corner radius.
  final BorderRadius? borderRadius;

  /// Copies selected overrides.
  OiBulkBarThemeData copyWith({
    TextStyle? labelStyle,
    OiButtonVariantStyle? actionStyle,
    OiButtonVariantStyle? destructiveActionStyle,
    bool? compactSeparator,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
  }) => OiBulkBarThemeData(
    labelStyle: labelStyle ?? this.labelStyle,
    actionStyle: actionStyle ?? this.actionStyle,
    destructiveActionStyle:
        destructiveActionStyle ?? this.destructiveActionStyle,
    compactSeparator: compactSeparator ?? this.compactSeparator,
    padding: padding ?? this.padding,
    borderRadius: borderRadius ?? this.borderRadius,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiBulkBarThemeData &&
          other.labelStyle == labelStyle &&
          other.actionStyle == actionStyle &&
          other.destructiveActionStyle == destructiveActionStyle &&
          other.compactSeparator == compactSeparator &&
          other.padding == padding &&
          other.borderRadius == borderRadius;

  @override
  int get hashCode => Object.hash(
    labelStyle,
    actionStyle,
    destructiveActionStyle,
    compactSeparator,
    padding,
    borderRadius,
  );
}
