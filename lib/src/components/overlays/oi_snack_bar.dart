import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_overlays.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// Screen position for an [OiSnackBar].
///
/// {@category Components}
enum OiSnackBarPosition {
  /// Bottom of the screen (default).
  bottom,

  /// Top of the screen.
  top,
}

/// A transient notification bar with an optional action button.
///
/// Unlike `OiToast`, which appears in a corner for passive notifications,
/// [OiSnackBar] appears at the bottom (or top) of the screen and supports an
/// interactive action (e.g. "Undo", "Retry"). Only one snack bar is shown at a
/// time — calling [OiSnackBar.show] replaces any currently visible snack bar.
///
/// The snack bar auto-dismisses after [duration] and can optionally be swiped
/// away when [dismissible] is `true`.
///
/// Use [OiSnackBar.show] to present a snack bar via the overlay system:
///
/// ```dart
/// final handle = OiSnackBar.show(
///   context,
///   message: 'Item deleted',
///   actionLabel: 'Undo',
///   onAction: () => _undoDelete(),
/// );
/// ```
///
/// {@category Components}
class OiSnackBar extends StatefulWidget {
  /// Creates an [OiSnackBar].
  const OiSnackBar({
    required this.message,
    this.action,
    this.actionLabel,
    this.onAction,
    this.duration = const Duration(seconds: 4),
    this.onDismissed,
    this.leading,
    this.backgroundColor,
    this.messageStyle,
    this.dismissible = true,
    this.position = OiSnackBarPosition.bottom,
    this.margin,
    this.borderRadius,
    this.semanticLabel,
    super.key,
  });

  /// The text message displayed in the snack bar.
  final String message;

  /// A custom action widget displayed at the trailing end of the snack bar.
  ///
  /// When provided, this overrides [actionLabel] and [onAction].
  final Widget? action;

  /// The label for a simple text action button.
  ///
  /// Ignored when [action] is provided. When set, [onAction] is called when
  /// the user taps the action label.
  final String? actionLabel;

  /// Callback invoked when the user taps the [actionLabel] button.
  final VoidCallback? onAction;

  /// How long the snack bar remains visible before auto-dismissing.
  ///
  /// Defaults to 4 seconds.
  final Duration duration;

  /// Called when the snack bar is dismissed (automatically, by swipe, or
  /// programmatically via the returned [OiOverlayHandle]).
  final VoidCallback? onDismissed;

  /// An optional leading widget (e.g. an icon) displayed before the message.
  final Widget? leading;

  /// Override the background color of the snack bar.
  ///
  /// Defaults to `colors.text` (a dark bar with inverted text).
  final Color? backgroundColor;

  /// Override the text style of the message.
  ///
  /// Defaults to the theme's small text style in `colors.textInverse`.
  final TextStyle? messageStyle;

  /// Whether the snack bar can be swiped away by the user.
  ///
  /// Defaults to `true`.
  final bool dismissible;

  /// Where the snack bar appears on screen.
  ///
  /// Defaults to [OiSnackBarPosition.bottom].
  final OiSnackBarPosition position;

  /// The margin around the snack bar.
  ///
  /// Defaults to `EdgeInsets.fromLTRB(16, 0, 16, 16)` for bottom position
  /// and `EdgeInsets.fromLTRB(16, 16, 16, 0)` for top position.
  final EdgeInsets? margin;

  /// The border radius of the snack bar surface.
  ///
  /// Defaults to `context.radius.md`.
  final BorderRadius? borderRadius;

  /// An accessible label for the snack bar.
  ///
  /// Defaults to [message] if not provided.
  final String? semanticLabel;

  /// The currently active snack bar handle, if any.
  ///
  /// Used internally to ensure only one snack bar is shown at a time.
  static OiOverlayHandle? _activeHandle;

  /// Shows a snack bar via the overlay system.
  ///
  /// Any previously shown snack bar is dismissed before the new one appears.
  /// Returns an [OiOverlayHandle] that can be used to dismiss the snack bar
  /// programmatically.
  static OiOverlayHandle show(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Widget? action,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onDismissed,
    Widget? leading,
    Color? backgroundColor,
    OiSnackBarPosition position = OiSnackBarPosition.bottom,
  }) {
    // Dismiss any currently active snack bar.
    _activeHandle?.dismiss();
    _activeHandle = null;

    final service = OiOverlays.maybeOf(context);

    Widget snackBar(BuildContext _) => OiSnackBar(
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      action: action,
      duration: duration,
      onDismissed: onDismissed,
      leading: leading,
      backgroundColor: backgroundColor,
      position: position,
    );

    if (service != null) {
      final handle = service.show(
        label: message,
        builder: snackBar,
        zOrder: OiOverlayZOrder.toast,
        dismissible: false,
      );
      _activeHandle = handle;
      return handle;
    }

    // Fallback: raw Overlay.
    final entry = OverlayEntry(builder: snackBar);
    Overlay.of(context).insert(entry);
    final handle = createOiOverlayHandle(entry);
    _activeHandle = handle;
    return handle;
  }

  @override
  State<OiSnackBar> createState() => _OiSnackBarState();
}

class _OiSnackBarState extends State<OiSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _timer;
  bool _dismissed = false;
  bool _animationStarted = false;

  static const Duration _animDuration = Duration(milliseconds: 250);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    _scheduleTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced =
        context.animations.reducedMotion ||
        MediaQuery.disableAnimationsOf(context);
    _controller.duration = reduced ? Duration.zero : _animDuration;

    // Build the slide animation based on position.
    final slideBegin = widget.position == OiSnackBarPosition.bottom
        ? const Offset(0, 1)
        : const Offset(0, -1);
    _slideAnimation =
        Tween<Offset>(
          begin: slideBegin,
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

    if (!_animationStarted) {
      _animationStarted = true;
      unawaited(_controller.forward());
    }
  }

  void _scheduleTimer() {
    _timer?.cancel();
    _timer = Timer(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (_dismissed) return;
    _dismissed = true;
    widget.onDismissed?.call();
    if (!mounted) return;
    await _controller.reverse();
    // Clear the active handle reference if this snack bar owns it.
    if (OiSnackBar._activeHandle != null &&
        !OiSnackBar._activeHandle!.isDismissed) {
      OiSnackBar._activeHandle?.dismiss();
      OiSnackBar._activeHandle = null;
    }
  }

  /// Handles vertical drag to dismiss.
  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (!widget.dismissible) return;
    final dy = details.primaryDelta ?? 0;
    // For bottom position, dismiss on downward swipe.
    // For top position, dismiss on upward swipe.
    final shouldDismiss = widget.position == OiSnackBarPosition.bottom
        ? dy > 0
        : dy < 0;
    if (shouldDismiss && dy.abs() > 2) {
      unawaited(_dismiss());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  EdgeInsets _defaultMargin() {
    return widget.position == OiSnackBarPosition.bottom
        ? const EdgeInsets.fromLTRB(16, 0, 16, 16)
        : const EdgeInsets.fromLTRB(16, 16, 16, 0);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;
    final radiusScale = context.radius;
    final shadowScale = context.shadows;

    final bgColor = widget.backgroundColor ?? colors.text;
    final msgStyle =
        widget.messageStyle ??
        textTheme.small.copyWith(color: colors.textInverse);
    final effectiveRadius = widget.borderRadius ?? radiusScale.md;
    final effectiveMargin = widget.margin ?? _defaultMargin();

    // Build the action widget.
    var actionWidget = widget.action;
    if (actionWidget == null && widget.actionLabel != null) {
      actionWidget = Semantics(
        button: true,
        label: widget.actionLabel,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            widget.onAction?.call();
            unawaited(_dismiss());
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              widget.actionLabel!,
              style: textTheme.small.copyWith(
                color: colors.primary.base,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    Widget bar = Semantics(
      liveRegion: true,
      label: widget.semanticLabel ?? widget.message,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: effectiveRadius,
          boxShadow: shadowScale.md,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.leading != null) ...[
              widget.leading!,
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(widget.message, style: msgStyle),
            ),
            if (actionWidget != null) ...[
              const SizedBox(width: 8),
              actionWidget,
            ],
          ],
        ),
      ),
    );

    // Wrap in swipe-to-dismiss gesture detector.
    if (widget.dismissible) {
      bar = GestureDetector(
        onVerticalDragUpdate: _onVerticalDragUpdate,
        child: bar,
      );
    }

    final alignment = widget.position == OiSnackBarPosition.bottom
        ? Alignment.bottomCenter
        : Alignment.topCenter;

    return Align(
      alignment: alignment,
      child: SafeArea(
        child: Padding(
          padding: effectiveMargin,
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: bar,
            ),
          ),
        ),
      ),
    );
  }
}
