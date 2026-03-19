import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_scheme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

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
    Key? key,
  }) : this._(
         label: label,
         style: OiBadgeStyle.filled,
         color: color,
         size: size,
         icon: icon,
         dot: dot,
         key: key,
       );

  /// Creates a soft badge with a muted tinted background.
  const OiBadge.soft({
    required String label,
    OiBadgeColor color = OiBadgeColor.primary,
    OiBadgeSize size = OiBadgeSize.medium,
    IconData? icon,
    bool dot = false,
    Key? key,
  }) : this._(
         label: label,
         style: OiBadgeStyle.soft,
         color: color,
         size: size,
         icon: icon,
         dot: dot,
         key: key,
       );

  /// Creates an outline badge with a coloured border and no fill.
  const OiBadge.outline({
    required String label,
    OiBadgeColor color = OiBadgeColor.primary,
    OiBadgeSize size = OiBadgeSize.medium,
    IconData? icon,
    bool dot = false,
    Key? key,
  }) : this._(
         label: label,
         style: OiBadgeStyle.outline,
         color: color,
         size: size,
         icon: icon,
         dot: dot,
         key: key,
       );

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

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Returns a distinct icon per semantic color so color is never the sole
  /// visual indicator when [dot] is `true` (REQ-0025).
  IconData? _dotIcon() {
    switch (color) {
      case OiBadgeColor.success:
        return const IconData(0xe5ca, fontFamily: 'MaterialIcons'); // check
      case OiBadgeColor.warning:
        return const IconData(0xe002, fontFamily: 'MaterialIcons'); // warning
      case OiBadgeColor.error:
        return const IconData(0xe5cd, fontFamily: 'MaterialIcons'); // close
      case OiBadgeColor.info:
        return const IconData(0xe88e, fontFamily: 'MaterialIcons'); // info
      case OiBadgeColor.primary:
      case OiBadgeColor.accent:
      case OiBadgeColor.neutral:
        return null;
    }
  }

  Color _baseColor(OiColorScheme colors) {
    switch (color) {
      case OiBadgeColor.primary:
        return colors.primary.base;
      case OiBadgeColor.accent:
        return colors.accent.base;
      case OiBadgeColor.success:
        return colors.success.base;
      case OiBadgeColor.warning:
        return colors.warning.base;
      case OiBadgeColor.error:
        return colors.error.base;
      case OiBadgeColor.info:
        return colors.info.base;
      case OiBadgeColor.neutral:
        return colors.textMuted;
    }
  }

  Color _mutedColor(OiColorScheme colors) {
    switch (color) {
      case OiBadgeColor.primary:
        return colors.primary.muted;
      case OiBadgeColor.accent:
        return colors.accent.muted;
      case OiBadgeColor.success:
        return colors.success.muted;
      case OiBadgeColor.warning:
        return colors.warning.muted;
      case OiBadgeColor.error:
        return colors.error.muted;
      case OiBadgeColor.info:
        return colors.info.muted;
      case OiBadgeColor.neutral:
        return colors.borderSubtle;
    }
  }

  ({Color background, Color textColor, Color? borderColor}) _resolveColors(
    OiColorScheme colors,
  ) {
    final base = _baseColor(colors);
    final muted = _mutedColor(colors);
    switch (style) {
      case OiBadgeStyle.filled:
        return (
          background: base,
          textColor: colors.textOnPrimary,
          borderColor: null,
        );
      case OiBadgeStyle.soft:
        return (
          background: muted.withValues(alpha: 0.15),
          textColor: base,
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
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          fontSize: 11,
          dotSize: 6,
          iconSize: 10,
        );
      case OiBadgeSize.medium:
        return (
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          fontSize: 12,
          dotSize: 8,
          iconSize: 12,
        );
      case OiBadgeSize.large:
        return (
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
    final resolved = _resolveColors(colors);
    final dims = _resolveDimensions();

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
                  child: Icon(
                    dotIconData,
                    size: dims.dotSize * 0.7,
                    color: colors.textOnPrimary,
                  ),
                )
              : null,
        ),
      );
    }

    final textStyle = TextStyle(
      fontSize: dims.fontSize,
      fontWeight: FontWeight.w500,
      color: resolved.textColor,
      height: 1,
    );

    Widget content = Text(label, style: textStyle);

    if (icon != null) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: dims.iconSize, color: resolved.textColor),
          const SizedBox(width: 4),
          Text(label, style: textStyle),
        ],
      );
    }

    return Container(
      padding: dims.padding,
      decoration: BoxDecoration(
        color: resolved.background,
        borderRadius: BorderRadius.circular(100),
        border: resolved.borderColor != null
            ? Border.all(color: resolved.borderColor!)
            : null,
      ),
      child: content,
    );
  }
}
