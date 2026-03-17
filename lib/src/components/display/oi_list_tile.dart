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
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    var content = titleWidget as Widget;

    if (subtitle != null) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget,
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: TextStyle(fontSize: 12, color: colors.textMuted),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    final row = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: verticalPadding,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ],
          Expanded(child: content),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
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

    return OiTappable(
      onTap: onTap,
      enabled: enabled,
      child: tile,
    );
  }
}
