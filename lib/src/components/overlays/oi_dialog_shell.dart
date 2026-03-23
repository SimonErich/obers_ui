import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_overlays.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_focus_trap.dart';

/// A minimal, themeable dialog container with a static [show] method.
///
/// [OiDialogShell] renders a constrained, elevated surface that can hold
/// arbitrary content. It is the low-level building block used by higher-level
/// dialog widgets such as `OiDialog`.
///
/// The [OiDialogShell.show] static method presents the shell as a modal
/// overlay with a barrier, focus-trapping, enter/exit animations, and
/// Escape-to-dismiss behaviour. It returns a `Future<T?>` that completes
/// with the result value passed to the `close` callback.
///
/// Visual defaults are read from `OiDialogShellThemeData` (via
/// `context.components.dialogShell`), falling back to sensible built-in
/// values.
///
/// {@category Components}
class OiDialogShell extends StatelessWidget {
  /// Creates an [OiDialogShell].
  const OiDialogShell({
    required this.child,
    this.width,
    this.minWidth,
    this.maxWidth,
    this.maxHeight,
    this.backgroundColor,
    this.borderRadius,
    this.elevation,
    this.padding,
    this.semanticLabel,
    super.key,
  });

  /// The content displayed inside the dialog surface.
  final Widget child;

  /// An explicit width for the dialog. When set, both [minWidth] and
  /// [maxWidth] constraints are ignored.
  final double? width;

  /// Minimum width of the dialog. Defaults to the theme value or 280.
  final double? minWidth;

  /// Maximum width of the dialog. Defaults to a fraction of the viewport.
  final double? maxWidth;

  /// Maximum height of the dialog. Defaults to a fraction of the viewport.
  final double? maxHeight;

  /// Background color of the dialog surface. Defaults to the theme value.
  final Color? backgroundColor;

  /// Corner radius of the dialog surface. Defaults to the theme value.
  final BorderRadius? borderRadius;

  /// Shadow elevation for the dialog. Defaults to `shadows.lg`.
  final List<BoxShadow>? elevation;

  /// Internal padding around the dialog content.
  final EdgeInsets? padding;

  /// An accessibility label announced by screen readers.
  final String? semanticLabel;

  // ── Static show helper ──────────────────────────────────────────────────

  /// Presents an [OiDialogShell] as a modal overlay and returns a future
  /// that completes with the result passed to the `close` callback provided
  /// to `builder`.
  ///
  /// The dialog is shown via the [OiOverlays] service when available,
  /// falling back to a raw [Overlay] insertion otherwise.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget Function(void Function([T? result]) close) builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? semanticLabel,
    double? width,
    double? minWidth,
    double? maxWidth,
    double? maxHeight,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
  }) async {
    final completer = Completer<T?>();
    late OiOverlayHandle handle;

    void close([T? result]) {
      if (!completer.isCompleted) {
        completer.complete(result);
        handle.dismiss();
      }
    }

    Widget overlayContent(BuildContext ctx) {
      return _OiDialogShellOverlay<T>(
        close: close,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
        semanticLabel: semanticLabel,
        width: width,
        minWidth: minWidth,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        padding: padding,
        builder: builder,
      );
    }

    final service = OiOverlays.maybeOf(context);
    if (service != null) {
      handle = service.show(
        label: semanticLabel ?? 'Dialog',
        zOrder: OiOverlayZOrder.dialog,
        dismissible: barrierDismissible,
        onDismiss: close,
        builder: overlayContent,
      );
    } else {
      // Fallback: insert directly into the nearest Flutter Overlay.
      final overlay = Overlay.of(context);
      final entry = OverlayEntry(builder: overlayContent);
      handle = createOiOverlayHandle(entry);
      overlay.insert(entry);
    }

    return completer.future;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = context.components.dialogShell;
    final colors = context.colors;
    final shadows = context.shadows;

    final effectiveMinWidth = minWidth ?? theme?.defaultMinWidth ?? 280.0;
    final effectiveMaxWidthFraction =
        theme?.defaultMaxWidthFraction ?? 0.9;
    final effectiveMaxHeightFraction =
        theme?.defaultMaxHeightFraction ?? 0.9;
    final effectiveBorderRadius =
        borderRadius ?? theme?.borderRadius ?? BorderRadius.circular(12);
    final effectiveBackgroundColor =
        backgroundColor ?? theme?.backgroundColor ?? colors.surface;
    final viewSize = MediaQuery.sizeOf(context);

    Widget result = Container(
      width: width,
      constraints: BoxConstraints(
        minWidth: width ?? effectiveMinWidth,
        maxWidth:
            width ?? (maxWidth ?? viewSize.width * effectiveMaxWidthFraction),
        maxHeight:
            maxHeight ?? viewSize.height * effectiveMaxHeightFraction,
      ),
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: effectiveBorderRadius,
        boxShadow: elevation ?? shadows.lg,
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );

    if (semanticLabel != null) {
      result = Semantics(
        scopesRoute: true,
        namesRoute: true,
        explicitChildNodes: true,
        label: semanticLabel,
        child: result,
      );
    }

    return result;
  }
}

// ── Private overlay widget ────────────────────────────────────────────────────

/// The full-screen overlay that contains the barrier, animation, focus trap,
/// and the [OiDialogShell] itself.
class _OiDialogShellOverlay<T> extends StatefulWidget {
  const _OiDialogShellOverlay({
    required this.close,
    required this.builder,
    required this.barrierDismissible,
    this.barrierColor,
    this.semanticLabel,
    this.width,
    this.minWidth,
    this.maxWidth,
    this.maxHeight,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    super.key,
  });

  final void Function([T? result]) close;
  final Widget Function(void Function([T? result]) close) builder;
  final bool barrierDismissible;
  final Color? barrierColor;
  final String? semanticLabel;
  final double? width;
  final double? minWidth;
  final double? maxWidth;
  final double? maxHeight;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;

  @override
  State<_OiDialogShellOverlay<T>> createState() =>
      _OiDialogShellOverlayState<T>();
}

class _OiDialogShellOverlayState<T> extends State<_OiDialogShellOverlay<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  bool _closing = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 150),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Pick up theme-driven durations when available.
    final theme = OiTheme.maybeOf(context)?.components.dialogShell;
    if (theme != null) {
      if (theme.enterDuration != null) {
        _controller.duration = theme.enterDuration;
      }
      if (theme.exitDuration != null) {
        _controller.reverseDuration = theme.exitDuration;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close([T? result]) {
    if (_closing) return;
    _closing = true;

    // Respect reduced-motion — skip the reverse animation.
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      widget.close(result);
      return;
    }

    _controller.reverse().then((_) {
      if (mounted) widget.close(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveBarrierColor = widget.barrierColor ?? colors.overlay;

    // When animations are disabled, render without transition wrappers.
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    Widget dialogContent = OiDialogShell(
      width: widget.width,
      minWidth: widget.minWidth,
      maxWidth: widget.maxWidth,
      maxHeight: widget.maxHeight,
      backgroundColor: widget.backgroundColor,
      borderRadius: widget.borderRadius,
      padding: widget.padding,
      semanticLabel: widget.semanticLabel,
      child: widget.builder(_close),
    );

    dialogContent = OiFocusTrap(
      onEscape: _close,
      child: dialogContent,
    );

    final Widget barrier = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.barrierDismissible ? _close : null,
      child: ColoredBox(color: effectiveBarrierColor),
    );

    if (disableAnimations) {
      return Stack(
        children: [
          Positioned.fill(child: barrier),
          Center(child: dialogContent),
        ],
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        children: [
          Positioned.fill(child: barrier),
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: dialogContent,
            ),
          ),
        ],
      ),
    );
  }
}
