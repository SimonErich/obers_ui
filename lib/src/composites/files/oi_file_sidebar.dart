import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_folder_tree_item.dart';
import 'package:obers_ui/src/components/display/oi_storage_indicator.dart';
import 'package:obers_ui/src/components/overlays/oi_context_menu.dart';
import 'package:obers_ui/src/composites/data/oi_tree.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_file_node_data.dart';

/// A quick-access item for the sidebar.
///
/// {@category Composites}
@immutable
class OiQuickAccessItem {
  /// Creates an [OiQuickAccessItem].
  const OiQuickAccessItem({
    required this.id,
    required this.label,
    required this.icon,
    this.badgeCount,
  });

  /// Unique identifier.
  final String id;

  /// Display label.
  final String label;

  /// Leading icon.
  final IconData icon;

  /// Optional badge count.
  final int? badgeCount;
}

/// Storage data for the sidebar storage indicator.
///
/// {@category Composites}
@immutable
class OiStorageData {
  /// Creates an [OiStorageData].
  const OiStorageData({
    required this.usedBytes,
    required this.totalBytes,
    this.breakdown,
  });

  /// Bytes currently used.
  final int usedBytes;

  /// Total available bytes.
  final int totalBytes;

  /// Optional breakdown by category.
  final List<OiStorageCategory>? breakdown;
}

/// The left sidebar panel of the file explorer.
///
/// Shows a folder tree with drag-and-drop support, quick-access sections
/// (Favorites, Recent), storage indicator, and folder management actions.
///
/// {@category Composites}
class OiFileSidebar extends StatefulWidget {
  /// Creates an [OiFileSidebar].
  const OiFileSidebar({
    required this.folderTree,
    required this.selectedFolderId,
    required this.onFolderSelect,
    this.loadChildren,
    this.draggable = true,
    this.onFolderMove,
    this.onFileDrop,
    this.quickAccess,
    this.onQuickAccessTap,
    this.favorites,
    this.onFavoriteTap,
    this.onFavoriteRemove,
    this.onNewFolder,
    this.onRenameFolder,
    this.onDeleteFolder,
    this.storage,
    this.width = 260,
    this.resizable = true,
    this.collapsible = true,
    this.semanticsLabel,
    super.key,
  });

  /// Folder tree data.
  final List<OiTreeNode<OiFileNodeData>> folderTree;

  /// Currently selected folder ID.
  final String? selectedFolderId;

  /// Called when a folder is selected.
  final ValueChanged<OiFileNodeData> onFolderSelect;

  /// Lazy loader for child folders.
  final Future<List<OiTreeNode<OiFileNodeData>>> Function(
      OiTreeNode<OiFileNodeData>)? loadChildren;

  /// Whether folders are draggable.
  final bool draggable;

  /// Called when a folder is moved within the tree.
  final void Function(
      OiFileNodeData folder, OiFileNodeData? newParent, int index)? onFolderMove;

  /// Called when files are dropped onto a folder.
  final void Function(
      List<OiFileNodeData> files, OiFileNodeData folder)? onFileDrop;

  /// Quick-access items (Home, Downloads, Trash, etc.).
  final List<OiQuickAccessItem>? quickAccess;

  /// Called when a quick-access item is tapped.
  final ValueChanged<OiQuickAccessItem>? onQuickAccessTap;

  /// Favorite folders.
  final List<OiFileNodeData>? favorites;

  /// Called when a favorite is tapped.
  final ValueChanged<OiFileNodeData>? onFavoriteTap;

  /// Called when a favorite is removed.
  final ValueChanged<OiFileNodeData>? onFavoriteRemove;

  /// Called to create a new folder.
  final ValueChanged<OiFileNodeData>? onNewFolder;

  /// Called to rename a folder.
  final ValueChanged<OiFileNodeData>? onRenameFolder;

  /// Called to delete a folder.
  final ValueChanged<OiFileNodeData>? onDeleteFolder;

  /// Storage data for the indicator.
  final OiStorageData? storage;

  /// Sidebar width.
  final double width;

  /// Whether the sidebar is resizable.
  final bool resizable;

  /// Whether the sidebar can be collapsed.
  final bool collapsible;

  /// Accessibility label.
  final String? semanticsLabel;

  @override
  State<OiFileSidebar> createState() => _OiFileSidebarState();
}

class _OiFileSidebarState extends State<OiFileSidebar> {
  late OiTreeController _treeController;

  @override
  void initState() {
    super.initState();
    _treeController = OiTreeController();
    if (widget.selectedFolderId != null) {
      _treeController.selectedIds.add(widget.selectedFolderId!);
    }
  }

  @override
  void didUpdateWidget(OiFileSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedFolderId != oldWidget.selectedFolderId) {
      _treeController.selectedIds.clear();
      if (widget.selectedFolderId != null) {
        _treeController.selectedIds.add(widget.selectedFolderId!);
      }
    }
  }

  @override
  void dispose() {
    _treeController.dispose();
    super.dispose();
  }

  void _onFolderSelect(String folderId) {
    final folder = _findFolder(widget.folderTree, folderId);
    if (folder != null) {
      widget.onFolderSelect(folder);
    }
  }

  OiFileNodeData? _findFolder(
      List<OiTreeNode<OiFileNodeData>> nodes, String id) {
    for (final node in nodes) {
      if (node.id == id) return node.data;
      final found = _findFolder(node.children, id);
      if (found != null) return found;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Semantics(
      label: widget.semanticsLabel ?? 'File sidebar',
      child: SizedBox(
        width: widget.width,
        child: Container(
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: colors.borderSubtle)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Quick access section
              if (widget.quickAccess != null &&
                  widget.quickAccess!.isNotEmpty) ...[
                _SectionHeader(label: 'Quick Access', colors: colors),
                for (final item in widget.quickAccess!)
                  _QuickAccessRow(
                    item: item,
                    onTap: () => widget.onQuickAccessTap?.call(item),
                    colors: colors,
                    spacing: spacing,
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.md,
                    vertical: spacing.xs,
                  ),
                  child: Container(height: 1, color: colors.borderSubtle),
                ),
              ],
              // Favorites section
              if (widget.favorites != null &&
                  widget.favorites!.isNotEmpty) ...[
                _SectionHeader(label: 'Favorites', colors: colors),
                for (final fav in widget.favorites!)
                  _FavoriteRow(
                    folder: fav,
                    onTap: () => widget.onFavoriteTap?.call(fav),
                    colors: colors,
                    spacing: spacing,
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.md,
                    vertical: spacing.xs,
                  ),
                  child: Container(height: 1, color: colors.borderSubtle),
                ),
              ],
              // Folder tree
              _SectionHeader(label: 'Folders', colors: colors),
              Expanded(
                child: OiTree<OiFileNodeData>(
                  nodes: widget.folderTree,
                  controller: _treeController,
                  onSelect: _onFolderSelect,
                  nodeBuilder: (context, node, isExpanded, isSelected) {
                    return OiFolderTreeItem(
                      folder: node.data ??
                          OiFileNodeData(
                            id: node.id,
                            name: node.label,
                            isFolder: true,
                          ),
                      expanded: isExpanded,
                      selected: isSelected,
                      itemCount: node.data?.itemCount,
                      onTap: () => _onFolderSelect(node.id),
                      onExpand: () {
                        if (isExpanded) {
                          _treeController.collapse(node.id);
                        } else {
                          _treeController.expand(node.id);
                        }
                      },
                    );
                  },
                ),
              ),
              // New Folder button
              if (widget.onNewFolder != null)
                Padding(
                  padding: EdgeInsets.all(spacing.sm),
                  child: OiButton.ghost(
                    label: '+ New Folder',
                    onTap: () {
                      final selected = widget.selectedFolderId != null
                          ? _findFolder(
                              widget.folderTree, widget.selectedFolderId!)
                          : null;
                      if (selected != null) {
                        widget.onNewFolder?.call(selected);
                      }
                    },
                  ),
                ),
              // Storage indicator
              if (widget.storage != null) ...[
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.md,
                    vertical: spacing.xs,
                  ),
                  child: Container(height: 1, color: colors.borderSubtle),
                ),
                Padding(
                  padding: EdgeInsets.all(spacing.sm),
                  child: OiStorageIndicator(
                    usedBytes: widget.storage!.usedBytes,
                    totalBytes: widget.storage!.totalBytes,
                    breakdown: widget.storage!.breakdown,
                    compact: true,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.colors});

  final String label;
  final dynamic colors;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.xs,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: (colors as dynamic).textMuted as Color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _QuickAccessRow extends StatelessWidget {
  const _QuickAccessRow({
    required this.item,
    required this.onTap,
    required this.colors,
    required this.spacing,
  });

  final OiQuickAccessItem item;
  final VoidCallback onTap;
  final dynamic colors;
  final dynamic spacing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: (spacing as dynamic).md as double,
          vertical: (spacing as dynamic).xs as double,
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 16,
              color: (colors as dynamic).textSubtle as Color,
            ),
            SizedBox(width: (spacing as dynamic).sm as double),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 13,
                  color: (colors as dynamic).text as Color,
                ),
              ),
            ),
            if (item.badgeCount != null && item.badgeCount! > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: (colors as dynamic).primary.muted as Color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${item.badgeCount}',
                  style: TextStyle(
                    fontSize: 10,
                    color: (colors as dynamic).primary.base as Color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteRow extends StatelessWidget {
  const _FavoriteRow({
    required this.folder,
    required this.onTap,
    required this.colors,
    required this.spacing,
  });

  final OiFileNodeData folder;
  final VoidCallback onTap;
  final dynamic colors;
  final dynamic spacing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: (spacing as dynamic).md as double,
          vertical: (spacing as dynamic).xs as double,
        ),
        child: Row(
          children: [
            Icon(
              const IconData(0xe838, fontFamily: 'MaterialIcons'), // star
              size: 14,
              color: (colors as dynamic).warning.base as Color,
            ),
            SizedBox(width: (spacing as dynamic).sm as double),
            Expanded(
              child: Text(
                folder.name,
                style: TextStyle(
                  fontSize: 13,
                  color: (colors as dynamic).text as Color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
