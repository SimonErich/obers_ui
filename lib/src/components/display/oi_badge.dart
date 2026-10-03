import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_scheme.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_swatch.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';

/// The semantic color of an [OiBadge].
///
/// {@category Components}
enum OiBadgeColor {
  /// Maps to the primary brand swatch.
  primary,

  /// Maps to the accent swatch.
  accent,

  /// Maps to the success swatch.
  success,

  /// Maps to the warning swatch.
  warning,

  /// Maps to the error swatch.
  error,

  /// Maps to the info swatch.
  info,

  /// Neutral grey.
  neutral,
}

/// The size of an [OiBadge].
///
/// {@category Components}
enum OiBadgeSize {
  /// Compact badge with small padding and font.
  small,

  /// Standard badge size.
  medium,

  /// Larger badge with more padding.
  large,
}

/// The rendering style of an [OiBadge].
///
/// {@category Components}
enum OiBadgeStyle {
  /// Solid colored background with white text.
  filled,

  /// Muted tinted background with colored text.
  soft,

  /// Transparent with a colored border and colored text.
  outline,
}

/// A small label chip used to communicate status, category, or metadata.
///
/// Supports three rendering styles and seven semantic [color]s.
/// When [dot] is `true` a small circle is shown with no text.
/// Use [showDot] to retain the label beside a decorative status marker.
///
/// Use the named constructors for each visual style:
/// - [OiBadge.filled]: solid coloured background with contrasting text.
/// - [OiBadge.soft]: muted tinted background with coloured text.
/// - [OiBadge.outline]: transparent with a coloured border and text.
///
/// ```dart
/// OiBadge.filled(label: 'New')
/// OiBadge.soft(label: 'Draft', color: OiBadgeColor.warning)
/// OiBadge.outline(label: 'v2.1')
/// ```
///
/// {@category Components}
class OiBadge extends StatelessWidget {
  // ── Private base constructor ──────────────────────────────────────────────

  const OiBadge._({
    required this.label,
    required this.style,
    this.color = OiBadgeColor.primary,
    this.size = OiBadgeSize.medium,
    this.icon,
    this.dot = false,
    this.showDot = false,
    this.compactToken = false,
    this.counter = false,
    super.key,
  });

  // ── Named variant constructors ────────────────────────────────────────────

  /// Creates a filled badge with a solid coloured background.
  const OiBadge.filled({
    required String label,
    OiBadgeColor color = OiBadgeColor.primary,
    OiBadgeSize size = OiBadgeSize.medium,
    IconData? icon,
    bool dot = false,
    bool showDot = false,
    Key? key,
  }) : this._(
         label: label,
         style: OiBadgeStyle.filled,
         color: color,
         size: size,
         icon: icon,
         dot: dot,
         showDot: showDot,
         key: key,
       );

  /// Creates a soft badge with a muted tinted background.
  const OiBadge.soft({
    required String label,
    OiBadgeColor color = OiBadgeColor.primary,
    OiBadgeSize size = OiBadgeSize.medium,
    IconData? icon,
    bool dot = false,
    bool showDot = false,
    Key? key,
  }) : this._(
         label: label,
         style: OiBadgeStyle.soft,
         color: color,
         size: size,
         icon: icon,
         dot: dot,
         showDot: showDot,
         key: key,
       );

  /// Creates an outline badge with a coloured border and no fill.
  const OiBadge.outline({
    required String label,
    OiBadgeColor color = OiBadgeColor.primary,
    OiBadgeSize size = OiBadgeSize.medium,
    IconData? icon,
    bool dot = false,
    bool showDot = false,
    Key? key,
  }) : this._(
         label: label,
         style: OiBadgeStyle.outline,
         color: color,
         size: size,
         icon: icon,
         dot: dot,
         showDot: showDot,
         key: key,
       );

  /// A small unread count, styled separately from status pills.
  const OiBadge.counter({
    required String label,
    OiBadgeColor color = OiBadgeColor.primary,
    OiBadgeStyle style = OiBadgeStyle.filled,
    Key? key,
  }) : this._(
         label: label,
         style: style,
         color: color,
         counter: true,
         key: key,
       );

  /// A compact square code token, such as an allergen or keyboard-sized tag.
  /// Unlike status pills, tokens use a 20px minimum width and height.
  const OiBadge.token({
    required String label,
    OiBadgeColor color = OiBadgeColor.neutral,
    Key? key,
  }) : this._(
         label: label,
         style: OiBadgeStyle.soft,
         color: color,
         compactToken: true,
         key: key,
       );

  /// Uses compact square token geometry instead of the status badge theme.
  final bool compactToken;

  /// Whether this is a compact unread counter.
  final bool counter;

  /// The text label. Ignored when [dot] is `true`.
  final String label;

  /// The semantic color token.
  final OiBadgeColor color;

  /// The size variant.
  final OiBadgeSize size;

  /// The rendering style.
  final OiBadgeStyle style;

  /// An optional icon shown to the left of the label.
  final IconData? icon;

  /// When `true`, renders a small dot with no text.
  final bool dot;

  /// Shows a decorative six-pixel status marker before the visible label.
  ///
  /// The marker follows the badge foreground, so it contrasts with each style.
  /// The label remains the accessible name. [dot] takes precedence when true.
  final bool showDot;

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Returns a distinct icon per semantic color so color is never the sole
  /// visual indicator when [dot] is `true` (REQ-0025).
  IconData? _dotIcon() {
    switch (color) {
      case OiBadgeColor.success:
        return OiIcons.check; // check
      case OiBadgeColor.warning:
        return OiIcons.circleAlert; // warning
      case OiBadgeColor.error:
        return OiIcons.x; // close
      case OiBadgeColor.info:
        return OiIcons.info; // info
      case OiBadgeColor.primary:
      case OiBadgeColor.accent:
      case OiBadgeColor.neutral:
        return null;
    }
  }

  OiColorSwatch _swatch(OiColorScheme colors) {
    switch (color) {
      case OiBadgeColor.primary:
        return colors.primary;
      case OiBadgeColor.accent:
        return colors.accent;
      case OiBadgeColor.success:
        return colors.success;
      case OiBadgeColor.warning:
        return colors.warning;
      case OiBadgeColor.error:
        return colors.error;
      case OiBadgeColor.info:
        return colors.info;
      case OiBadgeColor.neutral:
        return OiColorSwatch.from(colors.textMuted);
    }
  }

  ({Color background, Color textColor, Color? borderColor}) _resolveColors(
    OiColorScheme colors, {
    required bool useSwatchColors,
  }) {
    final swatch = _swatch(colors);
    final base = swatch.base;
    switch (style) {
      case OiBadgeStyle.filled:
        return (
          background: base,
          textColor: useSwatchColors ? swatch.foreground : colors.textOnPrimary,
          borderColor: null,
        );
      case OiBadgeStyle.soft:
        return (
          background: !useSwatchColors
              ? base.withValues(alpha: 0.2)
              : color == OiBadgeColor.neutral
              ? colors.surfaceSubtle
              : swatch.muted,
          textColor: useSwatchColors && color == OiBadgeColor.neutral
              ? colors.textMuted
              : swatch.dark,
          borderColor: null,
        );
      case OiBadgeStyle.outline:
        return (
          background: const Color(0x00000000),
          textColor: base,
          borderColor: base,
        );
    }
  }

  ({EdgeInsets padding, double fontSize, double dotSize, double iconSize})
  _resolveDimensions() {
    switch (size) {
      case OiBadgeSize.small:
        return (
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          fontSize: 11,
          dotSize: 6,
          iconSize: 10,
        );
      case OiBadgeSize.medium:
        return (
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          fontSize: 12,
          dotSize: 8,
          iconSize: 12,
        );
      case OiBadgeSize.large:
        return (
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          fontSize: 14,
          dotSize: 10,
          iconSize: 14,
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final resolved = _resolveColors(
      colors,
      useSwatchColors: context.components.badge?.useSwatchColors ?? false,
    );
    final dims = _resolveDimensions();
    final bt = context.components.badge;
    final compact = compactToken || counter;
    final metrics = counter
        ? bt?.counter
        : compactToken
        ? bt?.token
        : null;
    final compactHeight = metrics?.height ?? (counter ? 18.0 : 20.0);
    final effectivePadding = compact
        ? metrics?.padding ?? const EdgeInsets.symmetric(horizontal: 4)
        : bt?.padding ?? dims.padding;
    final effectiveBorderRadius = compact
        ? metrics?.borderRadius ?? BorderRadius.circular(counter ? 6 : 4)
        : bt?.borderRadius ?? BorderRadius.circular(100);

    if (dot) {
      final dotColor = resolved.background == const Color(0x00000000)
          ? resolved.textColor
          : resolved.background;
      // REQ-0025: semantic badge colors include a distinct icon so color is
      // never the sole indicator.
      final dotIconData = _dotIcon();
      return Semantics(
        label: label,
        child: Container(
          width: dims.dotSize,
          height: dims.dotSize,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            border: resolved.borderColor != null
                ? Border.all(color: resolved.borderColor!)
                : null,
          ),
          child: dotIconData != null
              ? Center(
                  child: OiIcon.raw(
                    dotIconData,
                    size: dims.dotSize * 0.7,
                    color: colors.textOnPrimary,
                  ),
                )
              : null,
        ),
      );
    }

    final textStyle = compact
        ? (metrics?.textStyle ??
                  context.textTheme.caption.copyWith(
                    fontSize: 12,
                    height: 1,
                    fontWeight: FontWeight.w600,
                    fontVariations: const [],
                  ))
              .copyWith(color: resolved.textColor)
        : bt?.textStyle?.copyWith(color: resolved.textColor) ??
              TextStyle(
                fontSize: dims.fontSize,
                fontWeight: FontWeight.w700,
                color: resolved.textColor,
                height: 1,
              );

    Widget content = Text(label, style: textStyle);

    if (icon != null || showDot) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            ExcludeSemantics(
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: resolved.textColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          if (icon != null) ...[
            OiIcon.raw(icon, size: dims.iconSize, color: resolved.textColor),
            const SizedBox(width: 4),
          ],
          Text(label, style: textStyle),
        ],
      );
    }

    final Widget badge = Container(
      height: compact ? compactHeight : bt?.height,
      constraints: compact
          ? BoxConstraints(minWidth: metrics?.minWidth ?? compactHeight)
          : null,
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: resolved.background,
        borderRadius: effectiveBorderRadius,
        border: resolved.borderColor != null
            ? Border.all(color: resolved.borderColor!)
            : null,
      ),
      child: compact || bt?.height != null
          ? Center(widthFactor: 1, heightFactor: 1, child: content)
          : content,
    );
    return badge;
  }
}
