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

part 'oi_button/oi_button_content.part.dart';
part 'oi_button/oi_button_special_variants.part.dart';
part 'oi_button/oi_button_standard_variants.part.dart';
part 'oi_button/oi_button_styling.part.dart';

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

  void _setHighlighted(bool value) {
    if (_highlighted == value) return;
    setState(() => _highlighted = value);
  }

  void _toggleDropdownVisible() {
    setState(() => _dropdownVisible = !_dropdownVisible);
  }

  void _setConfirmPending(bool value) {
    if (_confirmPending == value) return;
    setState(() => _confirmPending = value);
  }

  void _tickCountdown() {
    setState(() {
      _remaining--;
      if (_remaining <= 0) {
        _remaining = 0;
        _countdownTimer?.cancel();
      }
    });
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _tickCountdown();
    });
  }

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

}
