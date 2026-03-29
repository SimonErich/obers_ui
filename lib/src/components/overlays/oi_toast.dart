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

// ── Toast queue manager ──────────────────────────────────────────────────────

/// Manages a single overlay entry that renders all active toasts in a column.
class _OiToastQueue {
  _OiToastQueue._();

  static _OiToastQueue? _instance;
  // A getter is used here to lazily initialise the singleton; a Dart factory
  // constructor cannot conditionally return an already-created instance.
  // ignore: prefer_constructors_over_static_methods
  static _OiToastQueue get _shared => _instance ??= _OiToastQueue._();

  OiOverlayHandle? _handle;
  final List<_OiToastEntry> _entries = [];
  final _notifier = _ToastQueueNotifier();

  OiOverlayHandle addToast(
    BuildContext context, {
    required String message,
    required OiToastLevel level,
    required OiToastPosition position,
    required Duration duration,
    required bool pauseOnHover,
    Widget? action,
    VoidCallback? onDismiss,
  }) {
    final entry = _OiToastEntry(
      message: message,
      level: level,
      position: position,
      duration: duration,
      pauseOnHover: pauseOnHover,
      action: action,
      onDismiss: onDismiss,
    );
    _entries.add(entry);

    if (_handle == null || _handle!.isDismissed) {
      _createOverlay(context, position);
    } else {
      _handle!.update();
    }
    _notifier.notify();

    // Return a handle that removes this specific entry.
    return _OiSingleToastHandle(onDismiss: () => _removeEntry(entry));
  }

  void _removeEntry(_OiToastEntry entry) {
    _entries.remove(entry);
    if (_entries.isEmpty) {
      _handle?.dismiss();
      _handle = null;
    } else {
      _handle?.update();
    }
    _notifier.notify();
  }

  void _createOverlay(BuildContext context, OiToastPosition position) {
    final service = OiOverlays.maybeOf(context);

    Widget builder(BuildContext _) => ListenableBuilder(
      listenable: _notifier,
      builder: (ctx, _) => _OiToastColumn(
        entries: List.of(_entries),
        onEntryDismissed: _removeEntry,
      ),
    );

    if (service != null) {
      _handle = service.show(
        label: 'Toast notifications',
        builder: builder,
        zOrder: OiOverlayZOrder.toast,
        dismissible: false,
      );
    } else {
      final entry = OverlayEntry(builder: builder);
      Overlay.of(context).insert(entry);
      _handle = createOiOverlayHandle(entry);
    }
  }
}

class _ToastQueueNotifier extends ChangeNotifier {
  // Intentional notify wrapper to keep the public API surface minimal.
  void notify() => notifyListeners();
}

/// Data for a single queued toast.
class _OiToastEntry {
  _OiToastEntry({
    required this.message,
    required this.level,
    required this.position,
    required this.duration,
    required this.pauseOnHover,
    this.action,
    this.onDismiss,
  });

  final String message;
  final OiToastLevel level;
  final OiToastPosition position;
  final Duration duration;
  final bool pauseOnHover;
  final Widget? action;
  final VoidCallback? onDismiss;
}

/// A fake handle that dismisses a single entry from the queue.
class _OiSingleToastHandle implements OiOverlayHandle {
  _OiSingleToastHandle({required VoidCallback onDismiss})
    : _onDismiss = onDismiss;

  final VoidCallback _onDismiss;
  bool _dismissed = false;

  @override
  bool get isDismissed => _dismissed;

  @override
  void dismiss() {
    if (_dismissed) return;
    _dismissed = true;
    _onDismiss();
  }

  @override
  void update() {}
}

/// Renders the column of active toasts.
class _OiToastColumn extends StatelessWidget {
  const _OiToastColumn({required this.entries, required this.onEntryDismissed});

  final List<_OiToastEntry> entries;
  final void Function(_OiToastEntry) onEntryDismissed;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final position = entries.first.position;
    final isTop =
        position == OiToastPosition.topLeft ||
        position == OiToastPosition.topCenter ||
        position == OiToastPosition.topRight;

    final alignment = switch (position) {
      OiToastPosition.topLeft => Alignment.topLeft,
      OiToastPosition.topCenter => Alignment.topCenter,
      OiToastPosition.topRight => Alignment.topRight,
      OiToastPosition.bottomLeft => Alignment.bottomLeft,
      OiToastPosition.bottomCenter => Alignment.bottomCenter,
      OiToastPosition.bottomRight => Alignment.bottomRight,
    };

    final padding = isTop
        ? const EdgeInsets.only(top: 16, left: 16, right: 16)
        : const EdgeInsets.only(bottom: 16, left: 16, right: 16);

    final crossAlignment = switch (position) {
      OiToastPosition.topLeft ||
      OiToastPosition.bottomLeft => CrossAxisAlignment.start,
      OiToastPosition.topCenter ||
      OiToastPosition.bottomCenter => CrossAxisAlignment.center,
      OiToastPosition.topRight ||
      OiToastPosition.bottomRight => CrossAxisAlignment.end,
    };

    return Align(
      alignment: alignment,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: crossAlignment,
          children: [
            for (final entry in entries) ...[
              OiToast(
                key: ValueKey(entry),
                label: entry.message,
                message: entry.message,
                level: entry.level,
                position: entry.position,
                duration: entry.duration,
                pauseOnHover: entry.pauseOnHover,
                action: entry.action,
                onDismiss: () {
                  entry.onDismiss?.call();
                  onEntryDismissed(entry);
                },
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
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
  /// Multiple toasts are stacked vertically instead of overlapping.
  /// Returns an [OiOverlayHandle] for early dismissal.
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
    return _OiToastQueue._shared.addToast(
      context,
      message: message,
      level: level,
      position: position,
      duration: duration,
      pauseOnHover: pauseOnHover,
      action: action,
      onDismiss: onDismiss,
    );
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
      unawaited(_controller.forward());
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
    if (!mounted) return;
    await _controller.reverse();
    if (mounted) widget.onDismiss?.call();
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;
    final accent = _accentColor(colors);
    final tt = context.components.toast;

    final effectiveBorderRadius = tt?.borderRadius ?? BorderRadius.circular(8);
    final effectivePadding =
        tt?.padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 12);
    final effectiveIconSize = tt?.iconSize ?? 16.0;
    final effectiveGap = tt?.gap ?? 8.0;
    final effectiveBgColor = tt?.backgroundColor ?? colors.surface;
    final effectiveShadow =
        tt?.shadow ??
        [
          BoxShadow(
            color: colors.overlay.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ];

    Widget toast = Semantics(
      label: widget.label,
      liveRegion: true,
      explicitChildNodes: true,
      child: Container(
        constraints: const BoxConstraints(minWidth: 240, maxWidth: 400),
        decoration: BoxDecoration(
          color: effectiveBgColor,
          borderRadius: effectiveBorderRadius,
          border: Border.all(color: colors.border),
          boxShadow: effectiveShadow,
        ),
        child: ClipRRect(
          borderRadius: effectiveBorderRadius,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Colored left-border accent strip.
                Container(width: 4, color: accent),
                Expanded(
                  child: Padding(
                    padding: effectivePadding,
                    child: Row(
                      children: [
                        Semantics(
                          label: _iconSemanticLabel(),
                          container: true,
                          excludeSemantics: true,
                          child: Text(
                            _icon(),
                            style: TextStyle(
                              color: accent,
                              fontSize: effectiveIconSize,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(width: effectiveGap),
                        Expanded(
                          child: Text(
                            widget.message,
                            style: textTheme.small.copyWith(color: colors.text),
                          ),
                        ),
                        if (widget.action != null) ...[
                          SizedBox(width: effectiveGap),
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

    return FadeTransition(
      opacity: _opacity,
      alwaysIncludeSemantics: true,
      child: toast,
    );
  }
}
