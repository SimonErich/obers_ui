import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiDialogShell;
import 'package:obers_ui/src/components/overlays/oi_dialog_shell.dart' show OiDialogShell;

/// Theme overrides for [OiDialogShell].
///
/// Controls the visual appearance and animation behavior of the low-level
/// dialog container.
///
/// {@category Foundation}
@immutable
class OiDialogShellThemeData {
  /// Creates an [OiDialogShellThemeData].
  const OiDialogShellThemeData({
    this.backgroundColor,
    this.borderRadius,
    this.barrierColor,
    this.defaultMinWidth,
    this.defaultMaxWidthFraction,
    this.defaultMaxHeightFraction,
    this.enterDuration,
    this.exitDuration,
    this.enterCurve,
    this.exitCurve,
  });

  /// Background color of the dialog surface.
  final Color? backgroundColor;

  /// Corner radius of the dialog.
  final BorderRadius? borderRadius;

  /// Color of the barrier (scrim) behind the dialog.
  final Color? barrierColor;

  /// Minimum width of the dialog. Default: 280.
  final double? defaultMinWidth;

  /// Maximum width as a fraction of viewport width (0.0–1.0). Default: 0.9.
  final double? defaultMaxWidthFraction;

  /// Maximum height as a fraction of viewport height (0.0–1.0). Default: 0.9.
  final double? defaultMaxHeightFraction;

  /// Duration of the dialog enter animation.
  final Duration? enterDuration;

  /// Duration of the dialog exit animation.
  final Duration? exitDuration;

  /// Curve for the dialog enter animation.
  final Curve? enterCurve;

  /// Curve for the dialog exit animation.
  final Curve? exitCurve;

  /// Creates a copy with optionally overridden values.
  OiDialogShellThemeData copyWith({
    Color? backgroundColor,
    BorderRadius? borderRadius,
    Color? barrierColor,
    double? defaultMinWidth,
    double? defaultMaxWidthFraction,
    double? defaultMaxHeightFraction,
    Duration? enterDuration,
    Duration? exitDuration,
    Curve? enterCurve,
    Curve? exitCurve,
  }) {
    return OiDialogShellThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      barrierColor: barrierColor ?? this.barrierColor,
      defaultMinWidth: defaultMinWidth ?? this.defaultMinWidth,
      defaultMaxWidthFraction:
          defaultMaxWidthFraction ?? this.defaultMaxWidthFraction,
      defaultMaxHeightFraction:
          defaultMaxHeightFraction ?? this.defaultMaxHeightFraction,
      enterDuration: enterDuration ?? this.enterDuration,
      exitDuration: exitDuration ?? this.exitDuration,
      enterCurve: enterCurve ?? this.enterCurve,
      exitCurve: exitCurve ?? this.exitCurve,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiDialogShellThemeData &&
        other.backgroundColor == backgroundColor &&
        other.borderRadius == borderRadius &&
        other.barrierColor == barrierColor &&
        other.defaultMinWidth == defaultMinWidth &&
        other.defaultMaxWidthFraction == defaultMaxWidthFraction &&
        other.defaultMaxHeightFraction == defaultMaxHeightFraction &&
        other.enterDuration == enterDuration &&
        other.exitDuration == exitDuration &&
        other.enterCurve == enterCurve &&
        other.exitCurve == exitCurve;
  }

  @override
  int get hashCode => Object.hash(
        backgroundColor,
        borderRadius,
        barrierColor,
        defaultMinWidth,
        defaultMaxWidthFraction,
        defaultMaxHeightFraction,
        enterDuration,
        exitDuration,
        enterCurve,
        exitCurve,
      );
}
