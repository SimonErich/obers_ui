import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// A single-row list item with optional leading, trailing, title, subtitle,
/// and selection state.
///
/// Wraps content in an [OiTappable] row. When [selected] is `true` a subtle
/// highlight background is applied. When [dense] is `true` vertical padding
/// is reduced.
///
/// {@category Components}
class OiListTile extends StatelessWidget {
  /// Creates an [OiListTile].
  const OiListTile({
    required this.title,
    this.leading,
    this.trailing,
    this.subtitle,
    this.onTap,
    this.selected = false,
    this.enabled = true,
    this.dense = false,
    this.padding,
    this.gap,
    this.titleStyle,
    this.subtitleStyle,
    this.titleMaxLines = 1,
    this.subtitleMaxLines = 2,
    this.semanticLabel,
    super.key,
  });

  /// Optional widget placed at the start of the row.
  final Widget? leading;

  /// Optional widget placed at the end of the row.
  final Widget? trailing;

  /// Primary text content.
  final String title;

  /// Optional secondary text rendered below [title].
  final String? subtitle;

  /// Called when the tile is tapped.
  final VoidCallback? onTap;

  /// Whether this tile is currently selected.
  ///
  /// When `true`, a highlighted background is shown.
  final bool selected;

  /// Whether the tile accepts interaction.
  final bool enabled;

  /// When `true`, vertical padding is reduced for a more compact appearance.
  final bool dense;

  /// Optional insets; null preserves the standard or dense layout.
  final EdgeInsetsGeometry? padding;

  /// Space between leading, content and trailing children.
  final double? gap;

  /// Typography merged with the default title style.
  final TextStyle? titleStyle;

  /// Typography merged with the default subtitle style.
  final TextStyle? subtitleStyle;

  /// Maximum primary text lines; null allows wrapping without a line limit.
  /// The default retains the compact, single-line row.
  final int? titleMaxLines;

  /// Maximum secondary text lines; null allows wrapping without a line limit.
  final int? subtitleMaxLines;

  /// Accessible name for the action; defaults to the title.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final verticalPadding = dense ? 8.0 : 12.0;

    final titleWidget = Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: enabled ? colors.text : colors.textMuted,
      ).merge(titleStyle),
      maxLines: titleMaxLines,
      overflow: titleMaxLines == null
          ? TextOverflow.clip
          : TextOverflow.ellipsis,
    );

    // The action supplies its title once; nested text must not repeat it.
    final namedTitle = onTap == null
        ? titleWidget
        : ExcludeSemantics(child: titleWidget);
    var content = namedTitle;

    if (subtitle != null) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          namedTitle,
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 12,
              color: colors.textMuted,
            ).merge(subtitleStyle),
            maxLines: subtitleMaxLines,
            overflow: subtitleMaxLines == null
                ? TextOverflow.clip
                : TextOverflow.ellipsis,
          ),
        ],
      );
    }

    final row = Padding(
      padding:
          padding ??
          EdgeInsets.symmetric(horizontal: 16, vertical: verticalPadding),
      child: Row(
        children: [
          if (leading != null) ...[leading!, SizedBox(width: gap ?? 12)],
          Expanded(child: content),
          if (trailing != null) ...[SizedBox(width: gap ?? 12), trailing!],
        ],
      ),
    );

    Widget tile;
    if (selected) {
      tile = ColoredBox(
        color: colors.primary.base.withValues(alpha: 0.08),
        child: row,
      );
    } else {
      tile = row;
    }

    if (onTap == null) {
      return tile;
    }

    return OiTappable(
      onTap: onTap,
      enabled: enabled,
      semanticLabel: semanticLabel ?? title,
      child: tile,
    );
  }
}
