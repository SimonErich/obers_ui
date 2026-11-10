part of '../oi_button.dart';

enum _OiButtonKind { standard, icon, split, countdown, confirm }

abstract class _OiButtonBase extends StatefulWidget {
  const _OiButtonBase(
    this._kind, {
    this.label,
    this.labelMaxLines = 1,
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
  }) : assert(labelMaxLines > 0, 'labelMaxLines must be positive');

  /// The internal discriminator for which kind of button this is.
  final _OiButtonKind _kind;

  /// The primary label text.
  final String? label;

  /// Maximum visible label lines; wrapping retains the full accessible name.
  final int labelMaxLines;

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
}
