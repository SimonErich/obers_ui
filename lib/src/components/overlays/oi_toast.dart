import 'dart:async';

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

/// A transient notification banner that auto-dismisses after [duration].
///
/// [OiToast] displays a message with a colored left-border accent and optional
/// [action] widget. When [pauseOnHover] is `true` (the default), moving the
/// pointer over the toast pauses the auto-dismiss timer. The timer is also
/// paused while the widget is pressed on touch devices.
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
    this.dismissLabel = 'Dismiss',
    this.onPauseRequested,
    this.onResumeRequested,
    this.action,
    this.onDismiss,
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
  /// A null duration lets the owner manage expiry.
  final Duration? duration;

  /// Whether hovering over the toast pauses the auto-dismiss timer.
  final bool pauseOnHover;

  /// Whether a dismiss button appears when [onDismiss] is provided.
  final bool dismissible;

  /// Accessible text for the dismiss button; provide a localized label.
  final String dismissLabel;

  /// Requests that an externally owned expiry timer pause.
  final VoidCallback? onPauseRequested;

  /// Requests that an externally owned expiry timer resume.
  final VoidCallback? onResumeRequested;

  /// An optional action widget rendered to the right of the message.
  final Widget? action;

  /// Called just before the toast is dismissed (either automatically or by
  /// the user).
  final VoidCallback? onDismiss;

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
    String dismissLabel = 'Dismiss',
    Widget? action,
    VoidCallback? onDismiss,
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
    );
  }

  @override
  State<OiToast> createState() => _OiToastState();
}
