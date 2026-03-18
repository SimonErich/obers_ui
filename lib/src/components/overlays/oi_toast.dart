import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_overlays.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_scheme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

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
  final Duration duration;

  /// Whether hovering over the toast pauses the auto-dismiss timer.
  final bool pauseOnHover;

  /// An optional action widget rendered to the right of the message.
  final Widget? action;

  /// Called just before the toast is dismissed (either automatically or by
  /// the user).
  final VoidCallback? onDismiss;

  /// Shows a toast notification above the current widget tree.
  ///
  /// Uses [OiOverlays.of] when available; otherwise falls back to the raw
  /// Flutter [Overlay]. Returns an [OiOverlayHandle] for early dismissal.
  static OiOverlayHandle show(
    BuildContext context, {
    required String message,
    OiToastLevel level = OiToastLevel.info,
    OiToastPosition position = OiToastPosition.bottomRight,
    Duration duration = const Duration(seconds: 4),
    bool pauseOnHover = true,
    Widget? action,
    VoidCallback? onDismiss,
  }) {
    // Build the handle first so the onDismiss closure can reference it.
    // For the OiOverlays service path we use its built-in dismiss mechanism;
    // for the raw-Overlay fallback we wire onDismiss → handle.dismiss().
    final service = OiOverlays.maybeOf(context);

    if (service != null) {
      // Service manages the entry lifetime; pass onDismiss straight through.
      return service.show(
        builder: (_) => OiToast(
          label: message,
          message: message,
          level: level,
          position: position,
          duration: duration,
          pauseOnHover: pauseOnHover,
          action: action,
          onDismiss: onDismiss,
        ),
        zOrder: OiOverlayZOrder.toast,
        dismissible: false,
      );
    }

    // Fallback: raw Overlay. We need to dismiss the entry when the toast
    // auto-expires. Use a value notifier so the handle is captured after
    // the entry is created.
    final entry = OverlayEntry(
      builder: (_) => OiToast(
        label: message,
        message: message,
        level: level,
        position: position,
        duration: duration,
        pauseOnHover: pauseOnHover,
        action: action,
        onDismiss: onDismiss,
      ),
    );
    Overlay.of(context).insert(entry);
    return createOiOverlayHandle(entry);
  }

  @override
  State<OiToast> createState() => _OiToastState();
}

class _OiToastState extends State<OiToast> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  Timer? _timer;
  bool _hovered = false;
  bool _animationStarted = false;

  static const Duration _animDuration = Duration(milliseconds: 220);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scheduleTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced =
        context.animations.reducedMotion ||
        MediaQuery.disableAnimationsOf(context);
    _controller.duration = reduced ? Duration.zero : _animDuration;
    if (!_animationStarted) {
      _animationStarted = true;
      _controller.forward();
    }
  }

  void _scheduleTimer() {
    _timer?.cancel();
    _timer = Timer(widget.duration, _dismiss);
  }

  void _pauseTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _resumeTimer() {
    if (_timer == null && !_hovered) {
      _scheduleTimer();
    }
  }

  Future<void> _dismiss() async {
    widget.onDismiss?.call();
    if (!mounted) return;
    await _controller.reverse();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Color _accentColor(OiColorScheme colors) {
    switch (widget.level) {
      case OiToastLevel.info:
        return colors.info.base;
      case OiToastLevel.success:
        return colors.success.base;
      case OiToastLevel.warning:
        return colors.warning.base;
      case OiToastLevel.error:
        return colors.error.base;
    }
  }

  String _icon() {
    switch (widget.level) {
      case OiToastLevel.info:
        return 'ℹ';
      case OiToastLevel.success:
        return '✓';
      case OiToastLevel.warning:
        return '⚠';
      case OiToastLevel.error:
        return '✕';
    }
  }

  String _iconSemanticLabel() {
    switch (widget.level) {
      case OiToastLevel.info:
        return 'Info';
      case OiToastLevel.success:
        return 'Success';
      case OiToastLevel.warning:
        return 'Warning';
      case OiToastLevel.error:
        return 'Error';
    }
  }

  AlignmentGeometry _alignment() {
    switch (widget.position) {
      case OiToastPosition.topLeft:
        return Alignment.topLeft;
      case OiToastPosition.topCenter:
        return Alignment.topCenter;
      case OiToastPosition.topRight:
        return Alignment.topRight;
      case OiToastPosition.bottomLeft:
        return Alignment.bottomLeft;
      case OiToastPosition.bottomCenter:
        return Alignment.bottomCenter;
      case OiToastPosition.bottomRight:
        return Alignment.bottomRight;
    }
  }

  EdgeInsetsGeometry _padding() {
    const edge = 16.0;
    switch (widget.position) {
      case OiToastPosition.topLeft:
      case OiToastPosition.topCenter:
      case OiToastPosition.topRight:
        return const EdgeInsets.only(top: edge, left: edge, right: edge);
      case OiToastPosition.bottomLeft:
      case OiToastPosition.bottomCenter:
      case OiToastPosition.bottomRight:
        return const EdgeInsets.only(bottom: edge, left: edge, right: edge);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;
    final accent = _accentColor(colors);

    Widget toast = Semantics(
      label: widget.label,
      liveRegion: true,
      child: Container(
        constraints: const BoxConstraints(minWidth: 240, maxWidth: 400),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: colors.overlay.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Colored left-border accent strip.
                Container(width: 4, color: accent),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Semantics(
                          label: _iconSemanticLabel(),
                          excludeSemantics: true,
                          child: Text(
                            _icon(),
                            style: TextStyle(
                              color: accent,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.message,
                            style: textTheme.small.copyWith(color: colors.text),
                          ),
                        ),
                        if (widget.action != null) ...[
                          const SizedBox(width: 8),
                          widget.action!,
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (widget.pauseOnHover) {
      toast = MouseRegion(
        onEnter: (_) {
          _hovered = true;
          _pauseTimer();
        },
        onExit: (_) {
          _hovered = false;
          _scheduleTimer();
        },
        child: toast,
      );
    }

    // Pause on long-press for touch devices.
    toast = GestureDetector(
      onLongPressStart: (_) => _pauseTimer(),
      onLongPressEnd: (_) => _resumeTimer(),
      child: toast,
    );

    return Align(
      alignment: _alignment(),
      child: Padding(
        padding: _padding(),
        child: FadeTransition(opacity: _opacity, child: toast),
      ),
    );
  }
}
