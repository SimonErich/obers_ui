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
/// Supports three rendering [style]s ([OiBadgeStyle.filled],
/// [OiBadgeStyle.soft], [OiBadgeStyle.outline]) and seven semantic [color]s.
/// When [dot] is `true` a small circle is shown with no text.
///
/// {@category Components}
class OiBadge extends StatelessWidget {
  /// Creates an [OiBadge].
  const OiBadge({
    required this.label,
    this.color = OiBadgeColor.primary,
    this.size = OiBadgeSize.medium,
    this.style = OiBadgeStyle.filled,
    this.icon,
    this.dot = false,
    super.key,
  });

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

  ({
    Color background,
    Color textColor,
    Color? borderColor,
  }) _resolveColors(OiColorScheme colors) {
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

  ({
    EdgeInsets padding,
    double fontSize,
    double dotSize,
    double iconSize,
  }) _resolveDimensions() {
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
      return Container(
        width: dims.dotSize,
        height: dims.dotSize,
        decoration: BoxDecoration(
          color: resolved.background == const Color(0x00000000)
              ? resolved.textColor
              : resolved.background,
          shape: BoxShape.circle,
          border: resolved.borderColor != null
              ? Border.all(color: resolved.borderColor!)
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
