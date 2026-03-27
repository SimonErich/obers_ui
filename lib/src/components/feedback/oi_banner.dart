import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/buttons/oi_icon_button.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/layout/oi_row.dart';

/// The severity level of an [OiBanner].
///
/// {@category Components}
enum OiBannerLevel {
  /// Informational message.
  info,

  /// Success message.
  success,

  /// Warning message.
  warning,

  /// Error message.
  error,

  /// Neutral message with no severity.
  neutral,
}

/// Inline persistent notification bar.
///
/// Use for messages that should remain visible within the page flow until the
/// user or the system dismisses them. For transient feedback use `OiToast` or
/// `OiSnackBar` instead.
///
/// ```dart
/// OiBanner.info(message: 'Your trial expires in 3 days')
/// OiBanner.warning(title: 'Heads up', message: 'Maintenance tonight')
/// OiBanner.error(message: 'Critical issue', dismissible: false)
/// ```
///
/// {@category Components}
class OiBanner extends StatefulWidget {
  // ── Private base constructor ──────────────────────────────────────────────

  const OiBanner._({
    required this.message,
    required this.level,
    this.title,
    this.icon,
    this.action,
    this.secondaryAction,
    this.onDismiss,
    this.dismissible = true,
    this.compact = false,
    this.border = true,
    this.visible,
    this.semanticLabel,
    super.key,
  });

  // ── Named variant constructors ────────────────────────────────────────────

  /// Creates an informational banner.
  const OiBanner.info({
    required String message,
    String? title,
    IconData? icon,
    Widget? action,
    Widget? secondaryAction,
    VoidCallback? onDismiss,
    bool dismissible = true,
    bool compact = false,
    bool border = true,
    bool? visible,
    String? semanticLabel,
    Key? key,
  }) : this._(
         message: message,
         level: OiBannerLevel.info,
         title: title,
         icon: icon,
         action: action,
         secondaryAction: secondaryAction,
         onDismiss: onDismiss,
         dismissible: dismissible,
         compact: compact,
         border: border,
         visible: visible,
         semanticLabel: semanticLabel,
         key: key,
       );

  /// Creates a success banner.
  const OiBanner.success({
    required String message,
    String? title,
    IconData? icon,
    Widget? action,
    Widget? secondaryAction,
    VoidCallback? onDismiss,
    bool dismissible = true,
    bool compact = false,
    bool border = true,
    bool? visible,
    String? semanticLabel,
    Key? key,
  }) : this._(
         message: message,
         level: OiBannerLevel.success,
         title: title,
         icon: icon,
         action: action,
         secondaryAction: secondaryAction,
         onDismiss: onDismiss,
         dismissible: dismissible,
         compact: compact,
         border: border,
         visible: visible,
         semanticLabel: semanticLabel,
         key: key,
       );

  /// Creates a warning banner.
  const OiBanner.warning({
    required String message,
    String? title,
    IconData? icon,
    Widget? action,
    Widget? secondaryAction,
    VoidCallback? onDismiss,
    bool dismissible = true,
    bool compact = false,
    bool border = true,
    bool? visible,
    String? semanticLabel,
    Key? key,
  }) : this._(
         message: message,
         level: OiBannerLevel.warning,
         title: title,
         icon: icon,
         action: action,
         secondaryAction: secondaryAction,
         onDismiss: onDismiss,
         dismissible: dismissible,
         compact: compact,
         border: border,
         visible: visible,
         semanticLabel: semanticLabel,
         key: key,
       );

  /// Creates an error banner.
  const OiBanner.error({
    required String message,
    String? title,
    IconData? icon,
    Widget? action,
    Widget? secondaryAction,
    VoidCallback? onDismiss,
    bool dismissible = true,
    bool compact = false,
    bool border = true,
    bool? visible,
    String? semanticLabel,
    Key? key,
  }) : this._(
         message: message,
         level: OiBannerLevel.error,
         title: title,
         icon: icon,
         action: action,
         secondaryAction: secondaryAction,
         onDismiss: onDismiss,
         dismissible: dismissible,
         compact: compact,
         border: border,
         visible: visible,
         semanticLabel: semanticLabel,
         key: key,
       );

  /// Creates a neutral banner with no severity styling.
  const OiBanner.neutral({
    required String message,
    String? title,
    IconData? icon,
    Widget? action,
    Widget? secondaryAction,
    VoidCallback? onDismiss,
    bool dismissible = true,
    bool compact = false,
    bool border = true,
    bool? visible,
    String? semanticLabel,
    Key? key,
  }) : this._(
         message: message,
         level: OiBannerLevel.neutral,
         title: title,
         icon: icon,
         action: action,
         secondaryAction: secondaryAction,
         onDismiss: onDismiss,
         dismissible: dismissible,
         compact: compact,
         border: border,
         visible: visible,
         semanticLabel: semanticLabel,
         key: key,
       );

  /// The alert severity. Controls background tint, icon, and border color.
  final OiBannerLevel level;

  /// Primary message text. Always visible.
  final String message;

  /// Optional bold title above the message.
  final String? title;

  /// Leading icon override. Defaults to a level-appropriate icon.
  final IconData? icon;

  /// Primary action widget — typically an `OiButton.ghost` or
  /// `OiButton.outline`.
  final Widget? action;

  /// Secondary action widget — typically an `OiButton.ghost`.
  final Widget? secondaryAction;

  /// Called when the dismiss button is tapped. If null and [dismissible]
  /// is true, the banner removes itself from the tree with an animation.
  final VoidCallback? onDismiss;

  /// Whether the close/dismiss icon button is shown.
  final bool dismissible;

  /// Compact mode: hides the icon and reduces vertical padding.
  final bool compact;

  /// Whether to show a left accent border in the level color.
  final bool border;

  /// When provided, controls visibility externally. When null, the banner
  /// manages its own visibility (self-dismiss on tap).
  final bool? visible;

  /// Accessibility label. Defaults to "$level: $message".
  final String? semanticLabel;

  @override
  State<OiBanner> createState() => _OiBannerState();
}

class _OiBannerState extends State<OiBanner>
    with SingleTickerProviderStateMixin {
  bool _visible = true;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 1,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final themeData = context.components.banner;
    final duration =
        themeData?.animationDuration ?? const Duration(milliseconds: 250);
    if (_controller.duration != duration) {
      _controller.duration = duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (widget.onDismiss != null) {
      widget.onDismiss!();
    } else {
      _controller.reverse().then((_) {
        if (mounted) setState(() => _visible = false);
      });
    }
  }

  IconData? _defaultIcon() {
    return switch (widget.level) {
      OiBannerLevel.info => OiIcons.circleAlert,
      OiBannerLevel.success => OiIcons.circleCheck,
      OiBannerLevel.warning => OiIcons.triangleAlert,
      OiBannerLevel.error => OiIcons.circleX,
      OiBannerLevel.neutral => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (widget.visible == false) return const SizedBox.shrink();
    if (!_visible && widget.visible == null) return const SizedBox.shrink();

    final colors = context.colors;
    final spacing = context.spacing;
    final themeData = context.components.banner;

    final effectiveCompact =
        widget.compact ||
        context.breakpoint.compareTo(OiBreakpoint.compact) <= 0;

    final effectiveIcon = widget.icon ?? _defaultIcon();
    final showIcon = !effectiveCompact && effectiveIcon != null;

    // Resolve level-specific colors with theme overrides.
    final (bgColor, accentColor, iconColor) = switch (widget.level) {
      OiBannerLevel.info => (
        themeData?.infoBackground ?? colors.info.muted,
        themeData?.infoBorder ?? colors.info.base,
        colors.info.base,
      ),
      OiBannerLevel.success => (
        themeData?.successBackground ?? colors.success.muted,
        themeData?.successBorder ?? colors.success.base,
        colors.success.base,
      ),
      OiBannerLevel.warning => (
        themeData?.warningBackground ?? colors.warning.muted,
        themeData?.warningBorder ?? colors.warning.base,
        colors.warning.base,
      ),
      OiBannerLevel.error => (
        themeData?.errorBackground ?? colors.error.muted,
        themeData?.errorBorder ?? colors.error.base,
        colors.error.base,
      ),
      OiBannerLevel.neutral => (
        themeData?.neutralBackground ?? colors.surfaceSubtle,
        themeData?.neutralBorder ?? colors.border,
        colors.textMuted,
      ),
    };

    final borderRadius = themeData?.borderRadius ?? context.radius.md;
    final padding =
        themeData?.padding ??
        EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: effectiveCompact ? spacing.xs : spacing.sm,
        );

    final content = Semantics(
      label: widget.semanticLabel ?? '${widget.level.name}: ${widget.message}',
      liveRegion: true,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => ClipRect(
          child: Align(
            heightFactor: _controller.value,
            child: Opacity(opacity: _controller.value, child: child),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: borderRadius,
            border: widget.border
                ? Border(left: BorderSide(color: accentColor, width: 3))
                : null,
          ),
          padding: padding,
          child: OiRow(
            breakpoint: context.breakpoint,
            gap: OiResponsive<double>(spacing.sm),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showIcon)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: OiIcon.decorative(
                    icon: effectiveIcon,
                    color: iconColor,
                    size: themeData?.iconSize ?? 18,
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.title != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: OiLabel.bodyStrong(widget.title!),
                      ),
                    OiLabel.body(widget.message),
                    if (widget.action != null || widget.secondaryAction != null)
                      Padding(
                        padding: EdgeInsets.only(top: spacing.xs),
                        child: OiRow(
                          breakpoint: context.breakpoint,
                          gap: OiResponsive<double>(spacing.xs),
                          children: [
                            if (widget.action != null) widget.action!,
                            if (widget.secondaryAction != null)
                              widget.secondaryAction!,
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (widget.dismissible)
                OiIconButton(
                  icon: OiIcons.x,
                  semanticLabel: 'Dismiss',
                  onTap: _dismiss,
                  size: OiButtonSize.small,
                  variant: OiButtonVariant.ghost,
                ),
            ],
          ),
        ),
      ),
    );

    return content;
  }
}
