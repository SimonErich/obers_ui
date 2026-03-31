import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_tooltip.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_button_theme_data.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/animation/oi_pulse.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';
import 'package:obers_ui/src/primitives/overlay/oi_floating.dart';

/// Button size options.
///
/// {@category Components}
enum OiButtonSize {
  /// A compact button (28/24/20 dp tall depending on density).
  small,

  /// The standard-sized button (36/32/28 dp tall depending on density).
  medium,

  /// A large prominent button (44/40/36 dp tall depending on density).
  large,
}

/// Button visual style variants.
///
/// {@category Components}
enum OiButtonVariant {
  /// Filled with the primary brand colour.
  primary,

  /// Filled with the accent colour.
  secondary,

  /// Transparent with a visible border.
  outline,

  /// Transparent with no border.
  ghost,

  /// Filled with the error/destructive colour.
  destructive,

  /// Filled with a muted tint of the primary colour.
  soft,
}

/// The position of an icon relative to its button label.
///
/// {@category Components}
enum OiIconPosition {
  /// Icon appears before the label.
  leading,

  /// Icon appears after the label.
  trailing,
}

// ── Internal discriminator ──────────────────────────────────────────────────

enum _OiButtonKind { standard, icon, split, countdown, confirm }

/// A fully-featured button component for the Obers UI design system.
///
/// [OiButton] supports six visual variants, three density-aware sizes, loading
/// and disabled states, leading/trailing icons, full-width layout, and four
/// specialized constructors:
///
/// - [OiButton.icon] — an icon-only square button.
/// - [OiButton.split] — a main action paired with a dropdown trigger.
/// - [OiButton.countdown] — auto-enables after a timer expires.
/// - [OiButton.confirm] — requires a second tap to confirm a destructive action.
///
/// **Accessibility (REQ-0019):** Every named constructor (including
/// [OiButton.icon]) requires a `label` parameter. For [OiButton.icon] the
/// label is mapped to `Semantics.label` so that icon-only buttons remain
/// accessible to screen readers.
///
/// Uses [OiTappable] as the interaction layer; respects [OiDensityScope] for
/// size calculations and reads all colours, spacing, and radii from the nearest
/// [OiTheme].
///
/// ```dart
/// OiButton.primary(
///   label: 'Save',
///   onTap: () => save(),
/// )
/// ```
///
/// {@category Components}
class OiButton extends StatefulWidget {
  // ── Standard constructor (private) ─────────────────────────────────────────

  const OiButton._({
    required _OiButtonKind kind,
    this.label,
    this.icon,
    this.iconPosition = OiIconPosition.leading,
    this.variant = OiButtonVariant.primary,
    this.size = OiButtonSize.medium,
    this.onTap,
    this.enabled = true,
    this.loading = false,
    this.fullWidth = false,
    this.semanticLabel,
    this.tooltip,
    this.dropdown,
    this.countdownSeconds,
    this.confirmLabel,
    this.onConfirm,
    this.borderRadius,
    super.key,
  }) : _kind = kind;

  // ── Named variant constructors ──────────────────────────────────────────────

  /// Creates a primary-variant button with the supplied [label].
  const OiButton.primary({
    required String label,
    VoidCallback? onTap,
    OiButtonSize size = OiButtonSize.medium,
    bool enabled = true,
    bool loading = false,
    bool fullWidth = false,
    IconData? icon,
    OiIconPosition iconPosition = OiIconPosition.leading,
    String? semanticLabel,
    String? tooltip,
    Key? key,
  }) : this._(
         kind: _OiButtonKind.standard,
         label: label,
         icon: icon,
         iconPosition: iconPosition,
         variant: OiButtonVariant.primary,
         size: size,
         onTap: onTap,
         enabled: enabled,
         loading: loading,
         fullWidth: fullWidth,
         semanticLabel: semanticLabel,
         tooltip: tooltip,
         key: key,
       );

  /// Creates a secondary-variant button with the supplied [label].
  const OiButton.secondary({
    required String label,
    VoidCallback? onTap,
    OiButtonSize size = OiButtonSize.medium,
    bool enabled = true,
    bool loading = false,
    bool fullWidth = false,
    IconData? icon,
    OiIconPosition iconPosition = OiIconPosition.leading,
    String? semanticLabel,
    String? tooltip,
    Key? key,
  }) : this._(
         kind: _OiButtonKind.standard,
         label: label,
         icon: icon,
         iconPosition: iconPosition,
         variant: OiButtonVariant.secondary,
         size: size,
         onTap: onTap,
         enabled: enabled,
         loading: loading,
         fullWidth: fullWidth,
         semanticLabel: semanticLabel,
         tooltip: tooltip,
         key: key,
       );

  /// Creates an outline-variant button with the supplied [label].
  const OiButton.outline({
    required String label,
    VoidCallback? onTap,
    OiButtonSize size = OiButtonSize.medium,
    bool enabled = true,
    bool loading = false,
    bool fullWidth = false,
    IconData? icon,
    OiIconPosition iconPosition = OiIconPosition.leading,
    String? semanticLabel,
    String? tooltip,
    Key? key,
  }) : this._(
         kind: _OiButtonKind.standard,
         label: label,
         icon: icon,
         iconPosition: iconPosition,
         variant: OiButtonVariant.outline,
         size: size,
         onTap: onTap,
         enabled: enabled,
         loading: loading,
         fullWidth: fullWidth,
         semanticLabel: semanticLabel,
         tooltip: tooltip,
         key: key,
       );

  /// Creates a ghost-variant button with the supplied [label].
  const OiButton.ghost({
    required String label,
    VoidCallback? onTap,
    OiButtonSize size = OiButtonSize.medium,
    bool enabled = true,
    bool loading = false,
    bool fullWidth = false,
    IconData? icon,
    OiIconPosition iconPosition = OiIconPosition.leading,
    String? semanticLabel,
    BorderRadius? borderRadius,
    Key? key,
  }) : this._(
         kind: _OiButtonKind.standard,
         label: label,
         icon: icon,
         iconPosition: iconPosition,
         variant: OiButtonVariant.ghost,
         size: size,
         onTap: onTap,
         enabled: enabled,
         loading: loading,
         fullWidth: fullWidth,
         semanticLabel: semanticLabel,
         borderRadius: borderRadius,
         key: key,
       );

  /// Creates a destructive-variant button with the supplied [label].
  const OiButton.destructive({
    required String label,
    VoidCallback? onTap,
    OiButtonSize size = OiButtonSize.medium,
    bool enabled = true,
    bool loading = false,
    bool fullWidth = false,
    IconData? icon,
    OiIconPosition iconPosition = OiIconPosition.leading,
    String? semanticLabel,
    Key? key,
  }) : this._(
         kind: _OiButtonKind.standard,
         label: label,
         icon: icon,
         iconPosition: iconPosition,
         variant: OiButtonVariant.destructive,
         size: size,
         onTap: onTap,
         enabled: enabled,
         loading: loading,
         fullWidth: fullWidth,
         semanticLabel: semanticLabel,
         key: key,
       );

  /// Creates a soft-variant button with the supplied [label].
  const OiButton.soft({
    required String label,
    VoidCallback? onTap,
    OiButtonSize size = OiButtonSize.medium,
    bool enabled = true,
    bool loading = false,
    bool fullWidth = false,
    IconData? icon,
    OiIconPosition iconPosition = OiIconPosition.leading,
    String? semanticLabel,
    BorderRadius? borderRadius,
    Key? key,
  }) : this._(
         kind: _OiButtonKind.standard,
         label: label,
         icon: icon,
         iconPosition: iconPosition,
         variant: OiButtonVariant.soft,
         size: size,
         onTap: onTap,
         enabled: enabled,
         loading: loading,
         fullWidth: fullWidth,
         semanticLabel: semanticLabel,
         borderRadius: borderRadius,
         key: key,
       );

  // ── Special constructors ────────────────────────────────────────────────────

  /// Creates an icon-only button with a square aspect ratio.
  ///
  /// The button has equal padding on all sides; no label is shown.
  /// [label] is required and announced by screen readers.
  const OiButton.icon({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    OiButtonSize size = OiButtonSize.medium,
    bool enabled = true,
    OiButtonVariant variant = OiButtonVariant.ghost,
    Key? key,
  }) : this._(
         kind: _OiButtonKind.icon,
         icon: icon,
         variant: variant,
         size: size,
         onTap: onTap,
         enabled: enabled,
         semanticLabel: label,
         key: key,
       );

  /// Creates a split button combining a main action with a dropdown trigger.
  ///
  /// The main [label] fires [onTap]; the chevron area shows [dropdown].
  const OiButton.split({
    required String label,
    required VoidCallback onTap,
    required Widget dropdown,
    OiButtonVariant variant = OiButtonVariant.primary,
    OiButtonSize size = OiButtonSize.medium,
    bool enabled = true,
    Key? key,
  }) : this._(
         kind: _OiButtonKind.split,
         label: label,
         onTap: onTap,
         dropdown: dropdown,
         variant: variant,
         size: size,
         enabled: enabled,
         key: key,
       );

  /// Creates a countdown button that auto-enables after [seconds] seconds.
  ///
  /// The button is disabled while the countdown is running and shows the
  /// remaining time in the label.
  const OiButton.countdown({
    required String label,
    required VoidCallback onTap,
    required int seconds,
    OiButtonVariant variant = OiButtonVariant.primary,
    OiButtonSize size = OiButtonSize.medium,
    Key? key,
  }) : this._(
         kind: _OiButtonKind.countdown,
         label: label,
         onTap: onTap,
         countdownSeconds: seconds,
         variant: variant,
         size: size,
         key: key,
       );

  /// Creates a confirm button that requires two taps to fire [onConfirm].
  ///
  /// The first tap shows [confirmLabel] as a confirmation prompt; the second
  /// tap calls [onConfirm].
  const OiButton.confirm({
    required String label,
    required String confirmLabel,
    required VoidCallback onConfirm,
    OiButtonVariant variant = OiButtonVariant.destructive,
    OiButtonSize size = OiButtonSize.medium,
    Key? key,
  }) : this._(
         kind: _OiButtonKind.confirm,
         label: label,
         confirmLabel: confirmLabel,
         onConfirm: onConfirm,
         variant: variant,
         size: size,
         key: key,
       );

  // ── Fields ─────────────────────────────────────────────────────────────────

  /// The internal discriminator for which kind of button this is.
  final _OiButtonKind _kind;

  /// The primary label text.
  final String? label;

  /// An optional icon displayed alongside the label.
  final IconData? icon;

  /// The position of [icon] relative to [label].
  final OiIconPosition iconPosition;

  /// The visual style variant.
  final OiButtonVariant variant;

  /// The size tier.
  final OiButtonSize size;

  /// Called when the button is tapped.
  final VoidCallback? onTap;

  /// Whether the button responds to interactions.
  final bool enabled;

  /// Whether to show a loading indicator in place of the content.
  final bool loading;

  /// Whether the button expands to fill its parent's width.
  final bool fullWidth;

  /// Accessibility label announced by screen readers.
  final String? semanticLabel;

  /// Optional tooltip message shown on hover or long-press.
  final String? tooltip;

  /// The dropdown widget shown by a split button.
  final Widget? dropdown;

  /// The initial countdown value in seconds for a countdown button.
  final int? countdownSeconds;

  /// The label shown after the first tap of a confirm button.
  final String? confirmLabel;

  /// The callback fired on the second tap of a confirm button.
  final VoidCallback? onConfirm;

  /// An optional override for the button's corner border radius.
  ///
  /// When `null` (the default), the radius is taken from the component theme
  /// or falls back to `OiTheme.radius.sm`.
  final BorderRadius? borderRadius;

  @override
  State<OiButton> createState() => _OiButtonState();
}

// ── State ───────────────────────────────────────────────────────────────────

class _OiButtonState extends State<OiButton> {
  // ── Ghost hover / focus state ───────────────────────────────────────────────
  bool _highlighted = false;

  // ── Confirm state ──────────────────────────────────────────────────────────
  bool _confirmPending = false;

  // ── Split dropdown state ───────────────────────────────────────────────────
  bool _dropdownVisible = false;

  // ── Countdown state ────────────────────────────────────────────────────────
  int _remaining = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    if (widget._kind == _OiButtonKind.countdown &&
        widget.countdownSeconds != null) {
      _remaining = widget.countdownSeconds!;
      _startCountdown();
    }
  }

  @override
  void didUpdateWidget(OiButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget._kind == _OiButtonKind.countdown &&
        widget.countdownSeconds != oldWidget.countdownSeconds) {
      _countdownTimer?.cancel();
      _remaining = widget.countdownSeconds ?? 0;
      if (_remaining > 0) _startCountdown();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remaining--;
        if (_remaining <= 0) {
          _remaining = 0;
          _countdownTimer?.cancel();
        }
      });
    });
  }

  // ── Size helpers ─────────────────────────────────────────────────────────

  double _buttonHeight(OiDensity density) {
    switch (widget.size) {
      case OiButtonSize.small:
        switch (density) {
          case OiDensity.comfortable:
            return 28;
          case OiDensity.compact:
            return 24;
          case OiDensity.dense:
            return 20;
        }
      case OiButtonSize.medium:
        switch (density) {
          case OiDensity.comfortable:
            return 36;
          case OiDensity.compact:
            return 32;
          case OiDensity.dense:
            return 28;
        }
      case OiButtonSize.large:
        switch (density) {
          case OiDensity.comfortable:
            return 44;
          case OiDensity.compact:
            return 40;
          case OiDensity.dense:
            return 36;
        }
    }
  }

  double _iconSize() {
    switch (widget.size) {
      case OiButtonSize.small:
        return 14;
      case OiButtonSize.medium:
        return 16;
      case OiButtonSize.large:
        return 18;
    }
  }

  double _fontSize() {
    switch (widget.size) {
      case OiButtonSize.small:
        return 12;
      case OiButtonSize.medium:
        return 14;
      case OiButtonSize.large:
        return 16;
    }
  }

  double _hPadding(BuildContext context) {
    final sp = context.spacing;
    switch (widget.size) {
      case OiButtonSize.small:
        return sp.sm;
      case OiButtonSize.medium:
        return sp.md;
      case OiButtonSize.large:
        return sp.lg;
    }
  }

  // ── Colour helpers ──────────────────────────────────────────────────────

  /// Returns the per-variant style override from the button theme, if any.
  OiButtonVariantStyle? _variantStyle(
    OiButtonThemeData? bt,
    OiButtonVariant variant,
  ) {
    return switch (variant) {
      OiButtonVariant.primary => bt?.primaryStyle,
      OiButtonVariant.secondary => bt?.secondaryStyle,
      OiButtonVariant.outline => bt?.outlineStyle,
      OiButtonVariant.ghost => bt?.ghostStyle,
      OiButtonVariant.destructive => bt?.destructiveStyle,
      OiButtonVariant.soft => bt?.softStyle,
    };
  }

  Color _backgroundColor(BuildContext context, OiButtonVariant variant) {
    final vs = _variantStyle(context.components.button, variant);
    if (vs?.background != null) return vs!.background!;
    final c = context.colors;
    switch (variant) {
      case OiButtonVariant.primary:
        return c.primary.base;
      case OiButtonVariant.secondary:
        return c.surfaceSubtle;
      case OiButtonVariant.outline:
        return const Color(0x00000000); // transparent
      case OiButtonVariant.ghost:
        return const Color(0x00000000);
      case OiButtonVariant.destructive:
        return c.error.base;
      case OiButtonVariant.soft:
        return c.primary.muted;
    }
  }

  Color _foregroundColor(BuildContext context, OiButtonVariant variant) {
    final vs = _variantStyle(context.components.button, variant);
    if (vs?.foreground != null) return vs!.foreground!;
    final c = context.colors;
    switch (variant) {
      case OiButtonVariant.primary:
        return c.primary.foreground;
      case OiButtonVariant.secondary:
        return c.text;
      case OiButtonVariant.outline:
        return c.text;
      case OiButtonVariant.ghost:
        return c.text;
      case OiButtonVariant.destructive:
        return c.error.foreground;
      case OiButtonVariant.soft:
        return c.primary.base;
    }
  }

  // ── Build helpers ────────────────────────────────────────────────────────

  BoxDecoration _decoration(
    BuildContext context,
    OiButtonVariant variant, {
    BorderRadius? borderRadius,
  }) {
    final bt = context.components.button;
    final bg = _backgroundColor(context, variant);
    final themeRadius = bt?.borderRadius;
    final effectiveRadius = borderRadius ?? themeRadius ?? context.radius.sm;

    // Resolve border: check variant style override first, then default
    final vs = _variantStyle(bt, variant);
    final Border? border;
    if (vs?.border != null) {
      border = Border.all(color: vs!.border!);
    } else if (variant == OiButtonVariant.outline) {
      border = Border.all(color: context.colors.border);
    } else {
      border = null;
    }

    return BoxDecoration(
      color: bg,
      borderRadius: effectiveRadius,
      border: border,
    );
  }

  Widget _buildLoadingIndicator(Color color) {
    return OiPulse(
      child: SizedBox(
        width: 16,
        height: 16,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.7),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required String? label,
    required IconData? icon,
    required OiIconPosition iconPosition,
    required Color foreground,
    required bool loading,
    bool bold = false,
  }) {
    if (loading) {
      return _buildLoadingIndicator(foreground);
    }

    final bt = context.components.button;
    final effectiveIconSize = bt?.iconSize ?? _iconSize();
    final effectiveIconGap = bt?.iconGap ?? context.spacing.xs;
    final iconWidget = icon != null
        ? Padding(
            padding: EdgeInsets.only(
              right: (iconPosition == OiIconPosition.leading && label != null)
                  ? effectiveIconGap
                  : 0,
              left: (iconPosition == OiIconPosition.trailing && label != null)
                  ? effectiveIconGap
                  : 0,
            ),
            child: OiIcon.decorative(
              icon: icon,
              size: effectiveIconSize,
              color: foreground,
            ),
          )
        : null;

    final labelWidget = label != null
        ? Text(
            label,
            style: TextStyle(
              fontSize: _fontSize(),
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: foreground,
              height: 1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        : null;

    if (iconWidget == null && labelWidget != null) return labelWidget;
    if (iconWidget != null && labelWidget == null) return iconWidget;
    if (iconWidget == null && labelWidget == null) return const SizedBox();

    final children = iconPosition == OiIconPosition.leading
        ? [iconWidget!, labelWidget!]
        : [labelWidget!, iconWidget!];

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    switch (widget._kind) {
      case _OiButtonKind.icon:
        return _buildIconButton(context);
      case _OiButtonKind.split:
        return _buildSplitButton(context);
      case _OiButtonKind.countdown:
        return _buildCountdownButton(context);
      case _OiButtonKind.confirm:
        return _buildConfirmButton(context);
      case _OiButtonKind.standard:
        return _buildStandardButton(context);
    }
  }

  Widget _buildStandardButton(BuildContext context) {
    if (widget.variant == OiButtonVariant.ghost) {
      return _buildGhostButton(context);
    }

    final density = OiDensityScope.of(context);
    final bt = context.components.button;
    final height = bt?.height ?? _buttonHeight(density);
    final hPad = _hPadding(context);
    final foreground = _foregroundColor(context, widget.variant);
    final themeRadius = bt?.borderRadius;
    final effectiveRadius =
        widget.borderRadius ?? themeRadius ?? context.radius.sm;
    final decoration = _decoration(
      context,
      widget.variant,
      borderRadius: widget.borderRadius,
    );
    final isActive = widget.enabled && !widget.loading;

    Widget button = OiTappable(
      onTap: isActive ? widget.onTap : null,
      enabled: isActive,
      semanticLabel: widget.semanticLabel ?? widget.label,
      clipBorderRadius: effectiveRadius,
      child: Opacity(
        opacity: widget.enabled ? 1 : 0.4,
        child: Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: hPad),
          decoration: decoration,
          child: Center(
            widthFactor: 1.0,
            child: _buildContent(
              context,
              label: widget.label,
              icon: widget.icon,
              iconPosition: widget.iconPosition,
              foreground: foreground,
              loading: widget.loading,
            ),
          ),
        ),
      ),
    );

    if (bt?.minWidth != null) {
      button = ConstrainedBox(
        constraints: BoxConstraints(minWidth: bt!.minWidth!),
        child: button,
      );
    }
    if (widget.fullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    } else {
      button = UnconstrainedBox(
        constrainedAxis: Axis.vertical,
        child: button,
      );
    }
    if (widget.tooltip != null) {
      return OiTooltip(
        label: widget.tooltip!,
        message: widget.tooltip!,
        child: button,
      );
    }
    return button;
  }

  Widget _buildGhostButton(BuildContext context) {
    final density = OiDensityScope.of(context);
    final bt = context.components.button;
    final height = bt?.height ?? _buttonHeight(density);
    final hPad = _hPadding(context);
    final foreground = _foregroundColor(context, widget.variant);
    final isActive = widget.enabled && !widget.loading;

    Widget content = Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Center(
        widthFactor: 1.0,
        child: _buildContent(
          context,
          label: widget.label,
          icon: widget.icon,
          iconPosition: widget.iconPosition,
          foreground: foreground,
          loading: widget.loading,
          bold: _highlighted,
        ),
      ),
    );

    if (!widget.enabled) {
      content = Opacity(opacity: 0.4, child: content);
    }

    content = GestureDetector(
      onTap: isActive ? widget.onTap : null,
      behavior: HitTestBehavior.opaque,
      child: content,
    );

    content = MouseRegion(
      cursor: isActive ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (isActive) setState(() => _highlighted = true);
      },
      onExit: (_) => setState(() => _highlighted = false),
      child: content,
    );

    content = Focus(
      canRequestFocus: isActive,
      onFocusChange: (focused) {
        setState(() => _highlighted = focused);
      },
      child: content,
    );

    if (widget.semanticLabel != null) {
      content = Semantics(
        label: widget.semanticLabel,
        button: true,
        enabled: widget.enabled,
        child: content,
      );
    }

    Widget button = content;

    if (bt?.minWidth != null) {
      button = ConstrainedBox(
        constraints: BoxConstraints(minWidth: bt!.minWidth!),
        child: button,
      );
    }
    if (widget.fullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    } else {
      button = UnconstrainedBox(
        constrainedAxis: Axis.vertical,
        child: button,
      );
    }
    if (widget.tooltip != null) {
      return OiTooltip(
        label: widget.tooltip!,
        message: widget.tooltip!,
        child: button,
      );
    }
    return button;
  }

  Widget _buildIconButton(BuildContext context) {
    final density = OiDensityScope.of(context);
    final height = context.components.button?.height ?? _buttonHeight(density);
    final foreground = _foregroundColor(context, widget.variant);
    final highlightColor = context.colors.primary.base;
    final isActive = widget.enabled && !widget.loading;
    final iconSize = _iconSize();
    final highlightedSize = iconSize + 2;

    Widget content = SizedBox(
      width: height,
      height: height,
      child: Center(
        child: Icon(
          widget.icon,
          size: _highlighted ? highlightedSize : iconSize,
          color: _highlighted ? highlightColor : foreground,
        ),
      ),
    );

    if (!widget.enabled) {
      content = Opacity(opacity: 0.4, child: content);
    }

    content = GestureDetector(
      onTap: isActive ? widget.onTap : null,
      behavior: HitTestBehavior.opaque,
      child: content,
    );

    content = MouseRegion(
      cursor: isActive ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (isActive) setState(() => _highlighted = true);
      },
      onExit: (_) => setState(() => _highlighted = false),
      child: content,
    );

    content = Focus(
      canRequestFocus: isActive,
      onFocusChange: (focused) {
        setState(() => _highlighted = focused);
      },
      child: content,
    );

    if (widget.semanticLabel != null) {
      content = Semantics(
        label: widget.semanticLabel,
        button: true,
        enabled: widget.enabled,
        child: content,
      );
    }

    return content;
  }

  Widget _buildSplitButton(BuildContext context) {
    final density = OiDensityScope.of(context);
    final height = context.components.button?.height ?? _buttonHeight(density);
    final hPad = _hPadding(context);
    final foreground = _foregroundColor(context, widget.variant);
    final bgColor = _backgroundColor(context, widget.variant);
    final borderRadius =
        context.components.button?.borderRadius ?? context.radius.sm;

    final leftRadius = BorderRadius.only(
      topLeft: borderRadius.topLeft,
      bottomLeft: borderRadius.bottomLeft,
    );
    final rightRadius = BorderRadius.only(
      topRight: borderRadius.topRight,
      bottomRight: borderRadius.bottomRight,
    );

    final mainPart = OiTappable(
      onTap: widget.onTap,
      enabled: widget.enabled,
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: hPad),
        decoration: BoxDecoration(color: bgColor, borderRadius: leftRadius),
        child: Center(
          child: Text(
            widget.label ?? '',
            style: TextStyle(
              fontSize: _fontSize(),
              fontWeight: FontWeight.w500,
              color: foreground,
              height: 1,
            ),
          ),
        ),
      ),
    );

    final chevronPart = OiTappable(
      onTap: widget.enabled
          ? () => setState(() => _dropdownVisible = !_dropdownVisible)
          : null,
      enabled: widget.enabled,
      child: Container(
        height: height,
        width: height,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: rightRadius,
          border: Border(
            left: BorderSide(color: foreground.withValues(alpha: 0.3)),
          ),
        ),
        child: Center(
          child: Icon(OiIcons.arrowDown, size: _iconSize(), color: foreground),
        ),
      ),
    );

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [mainPart, chevronPart],
    );

    return OiFloating(
      visible: _dropdownVisible,
      alignment: OiFloatingAlignment.bottomEnd,
      anchor: row,
      child: widget.dropdown ?? const SizedBox(),
    );
  }

  Widget _buildCountdownButton(BuildContext context) {
    final isExpired = _remaining <= 0;
    final displayLabel = isExpired
        ? widget.label ?? ''
        : '${widget.label ?? ''} ($_remaining)';

    final density = OiDensityScope.of(context);
    final height = context.components.button?.height ?? _buttonHeight(density);
    final hPad = _hPadding(context);
    final foreground = _foregroundColor(context, widget.variant);
    final decoration = _decoration(context, widget.variant);

    Widget button = OiTappable(
      onTap: widget.onTap,
      enabled: isExpired,
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: hPad),
        decoration: decoration,
        child: Center(
          widthFactor: 1.0,
          child: Text(
            displayLabel,
            style: TextStyle(
              fontSize: _fontSize(),
              fontWeight: FontWeight.w500,
              color: foreground,
              height: 1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );

    if (widget.fullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    } else {
      button = UnconstrainedBox(
        constrainedAxis: Axis.vertical,
        child: button,
      );
    }
    return button;
  }

  Widget _buildConfirmButton(BuildContext context) {
    final density = OiDensityScope.of(context);
    final height = context.components.button?.height ?? _buttonHeight(density);
    final hPad = _hPadding(context);

    final activeVariant = _confirmPending
        ? OiButtonVariant.destructive
        : widget.variant;
    final displayLabel = _confirmPending
        ? (widget.confirmLabel ?? widget.label ?? '')
        : (widget.label ?? '');
    final foreground = _foregroundColor(context, activeVariant);
    final decoration = _decoration(context, activeVariant);

    Widget button = OiTappable(
      onTap: () {
        if (_confirmPending) {
          setState(() => _confirmPending = false);
          widget.onConfirm?.call();
        } else {
          setState(() => _confirmPending = true);
        }
      },
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: hPad),
        decoration: decoration,
        child: Center(
          widthFactor: 1.0,
          child: Text(
            displayLabel,
            style: TextStyle(
              fontSize: _fontSize(),
              fontWeight: FontWeight.w500,
              color: foreground,
              height: 1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );

    if (widget.fullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    } else {
      button = UnconstrainedBox(
        constrainedAxis: Axis.vertical,
        child: button,
      );
    }
    return button;
  }
}
