import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_drop_highlight.dart';
import 'package:obers_ui/src/components/display/oi_folder_icon.dart';
import 'package:obers_ui/src/components/display/oi_rename_field.dart';
import 'package:obers_ui/src/components/overlays/oi_context_menu.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_file_node_data.dart';

/// A specialized tree node widget for the folder sidebar.
///
/// Shows folder icon (with open/closed state), folder name, item count badge,
/// and acts as a drop target.
///
/// ```dart
/// OiFolderTreeItem(
///   folder: myFolder,
///   expanded: true,
///   selected: false,
///   onTap: () => navigate(myFolder),
/// )
/// ```
///
/// {@category Components}
class OiFolderTreeItem extends StatelessWidget {
  /// Creates an [OiFolderTreeItem].
  const OiFolderTreeItem({
    required this.folder,
    required this.expanded,
    required this.selected,
    this.dropTarget = false,
    this.renaming = false,
    this.itemCount,
    this.onTap,
    this.onExpand,
    this.onRename,
    this.onCancelRename,
    this.onDrop,
    this.contextMenuItems,
    this.semanticsLabel,
    super.key,
  });

  /// The folder node data.
  final OiFileNodeData folder;

  /// Whether the folder tree node is expanded.
  final bool expanded;

  /// Whether the folder is currently selected.
  final bool selected;

  /// Whether the folder is a drop target.
  final bool dropTarget;

  /// Whether the folder is in rename mode.
  final bool renaming;

  /// Number of items in this folder.
  final int? itemCount;

  /// Called when the folder is tapped.
  final VoidCallback? onTap;

  /// Called when the expand/collapse chevron is tapped.
  final VoidCallback? onExpand;

  /// Called when the folder is renamed.
  final ValueChanged<String>? onRename;

  /// Called when renaming is cancelled.
  final VoidCallback? onCancelRename;

  /// Called when files are dropped onto this folder.
  final ValueChanged<List<OiFileNodeData>>? onDrop;

  /// Context menu items for right-click.
  final List<OiMenuItem> Function()? contextMenuItems;

  /// Accessibility label.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    final content = OiDropHighlight(
      active: dropTarget,
      style: OiDropHighlightStyle.border,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.sm,
            vertical: spacing.xs,
          ),
          decoration: BoxDecoration(
            color: selected
                ? colors.primary.muted.withValues(alpha: 0.15)
                : null,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              // Expand/collapse chevron
              GestureDetector(
                onTap: onExpand,
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: Icon(
                    expanded
                        ? OiIcons.chevronDown // expand_more
                        : OiIcons.chevronRight, // chevron_right
                    size: 14,
                    color: colors.textSubtle,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Folder icon
              OiFolderIcon(
                state: expanded
                    ? OiFolderIconState.open
                    : OiFolderIconState.closed,
                size: OiFolderIconSize.sm,
                variant: _folderVariant,
              ),
              const SizedBox(width: 6),
              // Name or rename field
              Expanded(
                child: renaming
                    ? OiRenameField(
                        currentName: folder.name,
                        isFolder: true,
                        onRename: onRename ?? (_) {},
                        onCancel: onCancelRename ?? () {},
                        showButtons: true,
                      )
                    : Text(
                        folder.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: colors.text,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
              // Item count badge
              if (itemCount != null && !renaming)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    '$itemCount',
                    style: TextStyle(fontSize: 11, color: colors.textMuted),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    final widget = Semantics(
      label:
          semanticsLabel ??
          '${folder.name} folder${itemCount != null ? ', $itemCount items' : ''}',
      child: content,
    );

    return widget;
  }

  OiFolderIconVariant get _folderVariant {
    if (folder.isTrashed) return OiFolderIconVariant.trash;
    if (folder.isShared) return OiFolderIconVariant.shared;
    if (folder.isLocked) return OiFolderIconVariant.locked;
    if (folder.isFavorite) return OiFolderIconVariant.starred;
    return OiFolderIconVariant.normal;
  }
}
