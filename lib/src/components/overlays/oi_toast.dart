import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_icon_button.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/oi_overlays.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_scheme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

part 'oi_toast/oi_toast_queue.part.dart';
part 'oi_toast/oi_toast_column.part.dart';
part 'oi_toast/oi_toast_groups.part.dart';
part 'oi_toast/oi_toast_state.part.dart';
part 'oi_toast/oi_toast_surface.part.dart';
part 'oi_toast/oi_toast_content.part.dart';
part 'oi_toast/oi_toast_body.part.dart';

/// The severity level of an [OiToast] notification.
///
/// {@category Components}
enum OiToastLevel {
  /// Informational message (blue).
  info,

  /// Success message (green).
  success,

  /// Warning message (amber).
  warning,

  /// Error message (red).
  error,
}

/// Screen position for an [OiToast] notification.
///
/// {@category Components}
enum OiToastPosition {
  /// Top-left corner.
  topLeft,

  /// Top-center.
  topCenter,

  /// Top-right corner.
  topRight,

  /// Bottom-left corner.
  bottomLeft,

  /// Bottom-center.
  bottomCenter,

  /// Bottom-right corner.
  bottomRight,
}

/// The texts of an [OiToast], in English by default; pass translations
/// to localize the toast.
///
/// {@category Components}
class OiToastLabels {
  /// Creates an [OiToastLabels].
  const OiToastLabels({
    this.level = englishLevel,
    this.dismiss = 'Dismiss',
    this.container = 'Toast notifications',
  });

  /// "Info", "Success", "Warning", "Error": the default [level].
  static String englishLevel(OiToastLevel level) => switch (level) {
    OiToastLevel.info => 'Info',
    OiToastLevel.success => 'Success',
    OiToastLevel.warning => 'Warning',
    OiToastLevel.error => 'Error',
  };

  /// Screen-reader label of the icon of a toast's level.
  final String Function(OiToastLevel level) level;

  /// Screen-reader label of the close button.
  final String dismiss;

  /// Screen-reader label of the container that stacks the toasts. The
  /// container is shared by all toasts, so it takes this label from the toast
  /// that opens it.
  final String container;
}

/// A transient notification banner that auto-dismisses after [duration].
///
/// [OiToast] displays a message with a colored left-border accent and optional
/// [action] widget. When [pauseOnHover] is `true` (the default), moving the
/// pointer over the toast pauses the auto-dismiss timer. The timer is also
/// paused while the widget is pressed on touch devices.
///
/// When [dismissible] is `true` (the default), a close button is rendered at
/// the trailing edge so the toast can be dismissed before [duration] elapses.
///
/// Passing a `null` [duration] hands expiry to the caller: the toast then runs
/// no timer of its own and stays until it is removed from the tree. State-driven
/// callers that keep their own list of toasts want this — they render [OiToast]
/// directly and use [onPauseRequested] / [onResumeRequested] to keep their timer
/// in step with the pointer.
///
/// Use [OiToast.show] to insert a toast into the overlay stack. The returned
/// [OiOverlayHandle] can be used to dismiss the toast early.
///
/// {@category Components}
class OiToast extends StatefulWidget {
  /// Creates an [OiToast].
  const OiToast({
    required this.label,
    required this.message,
    this.level = OiToastLevel.info,
    this.position = OiToastPosition.bottomRight,
    this.duration = const Duration(seconds: 4),
    this.pauseOnHover = true,
    this.dismissible = true,
    this.dismissLabel,
    this.onPauseRequested,
    this.onResumeRequested,
    this.action,
    this.onDismiss,
    this.labels = const OiToastLabels(),
    super.key,
  });

  /// The accessible label describing this toast for screen readers.
  final String label;

  /// The text message displayed in the toast.
  final String message;

  /// The severity level that controls the accent color and icon.
  final OiToastLevel level;

  /// Where on screen the toast appears. Defaults to [OiToastPosition.bottomRight].
  final OiToastPosition position;

  /// How long the toast remains visible before auto-dismissing.
  ///
  /// When `null` the toast runs no timer and the caller owns expiry.
  final Duration? duration;

  /// Whether hovering over the toast pauses the auto-dismiss timer.
  final bool pauseOnHover;

  /// Whether a close button is rendered at the trailing edge of the toast.
  final bool dismissible;

  /// Accessible text for the dismiss button; provide a localized label.
  ///
  /// Takes precedence over [OiToastLabels.dismiss] of [labels] when set.
  final String? dismissLabel;

  /// Called when the pointer enters the toast, or a long press begins.
  ///
  /// Only useful with a `null` [duration]: it lets a caller that owns expiry
  /// pause its own timer while the user is reading.
  final VoidCallback? onPauseRequested;

  /// Called when the pointer leaves the toast, or a long press ends.
  final VoidCallback? onResumeRequested;

  /// An optional action widget rendered to the right of the message.
  final Widget? action;

  /// Called just before the toast is dismissed (either automatically or by
  /// the user).
  final VoidCallback? onDismiss;

  /// The toast's texts; pass translations to localize it.
  final OiToastLabels labels;

  /// Shows a toast notification above the current widget tree.
  ///
  /// Multiple toasts are stacked vertically instead of overlapping.
  /// Returns an [OiOverlayHandle] for early dismissal.
  /// The handle also reflects removal by expiry or the close control.
  /// Calling its `dismiss()` removes the entry immediately without the close
  /// animation or [onDismiss] callback.
  static OiOverlayHandle show(
    BuildContext context, {
    required String message,
    OiToastLevel level = OiToastLevel.info,
    OiToastPosition position = OiToastPosition.bottomRight,
    Duration? duration = const Duration(seconds: 4),
    bool pauseOnHover = true,
    bool dismissible = true,
    String? dismissLabel,
    Widget? action,
    VoidCallback? onDismiss,
    OiToastLabels labels = const OiToastLabels(),
  }) {
    return _OiToastQueue._shared.addToast(
      context,
      message: message,
      level: level,
      position: position,
      duration: duration,
      pauseOnHover: pauseOnHover,
      dismissible: dismissible,
      dismissLabel: dismissLabel,
      action: action,
      onDismiss: onDismiss,
      labels: labels,
    );
  }

  @override
  State<OiToast> createState() => _OiToastState();
}
