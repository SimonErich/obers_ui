import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_folder_tree_item.dart';
import 'package:obers_ui/src/components/display/oi_storage_indicator.dart';
import 'package:obers_ui/src/components/overlays/oi_context_menu.dart';
import 'package:obers_ui/src/composites/data/oi_tree.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_scheme.dart';
import 'package:obers_ui/src/foundation/theme/oi_spacing_scale.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_file_node_data.dart';
import 'package:obers_ui/src/primitives/drag_drop/oi_drop_zone.dart';

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

/// The texts of an [OiFileSidebar], in English by default; pass
/// translations to localize the sidebar.
///
/// {@category Composites}
class OiFileSidebarLabels {
  /// Creates an [OiFileSidebarLabels].
  const OiFileSidebarLabels({
    this.quickAccess = 'Quick Access',
    this.favorites = 'Favorites',
    this.folders = 'Folders',
    this.folderTree = 'Folder tree',
    this.folderMenu = englishFolderMenu,
    this.newSubfolder = 'New subfolder',
    this.rename = 'Rename',
    this.delete = 'Delete',
    this.newFolder = '+ New Folder',
    this.rootFolder = 'Home',
    this.favorite = englishFavorite,
  });

  /// "Folder Documents context menu": the default [folderMenu].
  static String englishFolderMenu(String name) => 'Folder $name context menu';

  /// "Favorite: Documents": the default [favorite].
  static String englishFavorite(String name) => 'Favorite: $name';

  /// Heading of the quick access section.
  final String quickAccess;

  /// Heading of the favorites section.
  final String favorites;

  /// Heading of the folder tree.
  final String folders;

  /// Screen-reader label of the folder tree.
  final String folderTree;

  /// Screen-reader label of the context menu of the named folder.
  final String Function(String name) folderMenu;

  /// Label of the context menu entry that creates a subfolder.
  final String newSubfolder;

  /// Label of the context menu entry that renames a folder.
  final String rename;

  /// Label of the context menu entry that deletes a folder.
  final String delete;

  /// Label of the button that creates a folder.
  final String newFolder;

  /// Name of the folder a new folder is created in while the tree is empty.
  final String rootFolder;

  /// Screen-reader label of the named favorite folder.
  final String Function(String name) favorite;
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
    this.labels = const OiFileSidebarLabels(),
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
    OiTreeNode<OiFileNodeData>,
  )?
  loadChildren;

  /// Whether folders are draggable.
  final bool draggable;

  /// Called when a folder is moved within the tree.
  final void Function(
    OiFileNodeData folder,
    OiFileNodeData? newParent,
    int index,
  )?
  onFolderMove;

  /// Called when files are dropped onto a folder.
  final void Function(List<OiFileNodeData> files, OiFileNodeData folder)?
  onFileDrop;

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

  /// The sidebar's texts; pass translations to localize it.
  final OiFileSidebarLabels labels;

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
    List<OiTreeNode<OiFileNodeData>> nodes,
    String id,
  ) {
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
          padding: EdgeInsets.fromLTRB(
            spacing.sm,
            spacing.sm,
            spacing.sm,
            0,
          ),
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: colors.borderSubtle)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Quick access section
              if (widget.quickAccess != null &&
                  widget.quickAccess!.isNotEmpty) ...[
                _SectionHeader(
                  label: widget.labels.quickAccess,
                  colors: colors,
                ),
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
              if (widget.favorites != null && widget.favorites!.isNotEmpty) ...[
                _SectionHeader(label: widget.labels.favorites, colors: colors),
                for (final fav in widget.favorites!)
                  _FavoriteRow(
                    folder: fav,
                    label: widget.labels.favorite(fav.name),
                    onTap: () => widget.onFavoriteTap?.call(fav),
                    onFileDrop: widget.onFileDrop,
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
              _SectionHeader(label: widget.labels.folders, colors: colors),
              Expanded(
                child: OiTree<OiFileNodeData>(
                  label: widget.labels.folderTree,
                  nodes: widget.folderTree,
                  controller: _treeController,
                  selectable: true,
                  onNodeTap: (node) => _onFolderSelect(node.id),
                  nodeBuilder:
                      (
                        context,
                        node,
                        depth, {
                        required expanded,
                        required selected,
                      }) {
                        final folder =
                            node.data ??
                            OiFileNodeData(
                              id: node.id,
                              name: node.label,
                              folder: true,
                            );

                        Widget treeItem = OiFolderTreeItem(
                          folder: folder,
                          expanded: expanded,
                          selected: selected,
                          itemCount: node.data?.itemCount,
                          onTap: () => _onFolderSelect(node.id),
                          onExpand: () {
                            if (expanded) {
                              _treeController.collapse(node.id);
                            } else {
                              _treeController.expand(node.id);
                            }
                          },
                        );

                        // Wrap with drop target if file drops are enabled
                        if (widget.onFileDrop != null) {
                          final innerTreeItem = treeItem;
                          treeItem = OiDropZone<List<OiFileNodeData>>(
                            onWillAccept: (_) => true,
                            onAccept: (files) {
                              widget.onFileDrop!(files, folder);
                            },
                            builder: (ctx, state) {
                              return DecoratedBox(
                                decoration: state == OiDropState.hovering
                                    ? BoxDecoration(
                                        color: context.colors.primary.muted
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      )
                                    : const BoxDecoration(),
                                child: innerTreeItem,
                              );
                            },
                          );
                        }

                        // Wrap with context menu if folder management is enabled
                        if (widget.onRenameFolder != null ||
                            widget.onDeleteFolder != null ||
                            widget.onNewFolder != null) {
                          treeItem = OiContextMenu(
                            label: widget.labels.folderMenu(folder.name),
                            items: [
                              if (widget.onNewFolder != null)
                                OiMenuItem(
                                  label: widget.labels.newSubfolder,
                                  icon: OiIcons.folderOpen,
                                  onTap: () => widget.onNewFolder!(folder),
                                ),
                              if (widget.onRenameFolder != null)
                                OiMenuItem(
                                  label: widget.labels.rename,
                                  icon: OiIcons.pencil,
                                  onTap: () => widget.onRenameFolder!(folder),
                                ),
                              if (widget.onDeleteFolder != null)
                                OiMenuItem(
                                  label: widget.labels.delete,
                                  icon: OiIcons.trash2,
                                  onTap: () => widget.onDeleteFolder!(folder),
                                ),
                            ],
                            child: treeItem,
                          );
                        }

                        return treeItem;
                      },
                ),
              ),
              // New Folder button
              if (widget.onNewFolder != null)
                Padding(
                  padding: EdgeInsets.all(spacing.sm),
                  child: OiButton.outline(
                    label: widget.labels.newFolder,
                    fullWidth: true,
                    onTap: () {
                      // Resolve selected folder, falling back to the first
                      // root node so the button always works.
                      final selected = widget.selectedFolderId != null
                          ? _findFolder(
                              widget.folderTree,
                              widget.selectedFolderId!,
                            )
                          : null;
                      final target =
                          selected ??
                          (widget.folderTree.isNotEmpty
                              ? widget.folderTree.first.data
                              : OiFileNodeData(
                                  id: 'root',
                                  name: widget.labels.rootFolder,
                                  folder: true,
                                ));
                      if (target != null) {
                        widget.onNewFolder!.call(target);
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
  final OiColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Semantics(
      header: true,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.xs,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colors.textMuted,
            letterSpacing: 0.5,
          ),
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
  final OiColorScheme colors;
  final OiSpacingScale spacing;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: item.label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.xs,
          ),
          child: Row(
            children: [
              Icon(item.icon, size: 16, color: colors.textSubtle),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(fontSize: 13, color: colors.text),
                ),
              ),
              if (item.badgeCount != null && item.badgeCount! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.muted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${item.badgeCount}',
                    style: TextStyle(
                      fontSize: 10,
                      color: colors.primary.base,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteRow extends StatelessWidget {
  const _FavoriteRow({
    required this.folder,
    required this.label,
    required this.onTap,
    required this.colors,
    required this.spacing,
    this.onFileDrop,
  });

  final OiFileNodeData folder;
  final String label;
  final VoidCallback onTap;
  final OiColorScheme colors;
  final OiSpacingScale spacing;
  final void Function(List<OiFileNodeData> files, OiFileNodeData folder)?
  onFileDrop;

  @override
  Widget build(BuildContext context) {
    Widget row = Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.xs,
          ),
          child: Row(
            children: [
              Icon(
                OiIcons.star,
                size: 14,
                color: colors.warning.base,
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  folder.name,
                  style: TextStyle(fontSize: 13, color: colors.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Wrap favorites with drop target
    if (onFileDrop != null) {
      row = OiDropZone<List<OiFileNodeData>>(
        onWillAccept: (_) => true,
        onAccept: (files) => onFileDrop!(files, folder),
        builder: (ctx, state) {
          return DecoratedBox(
            decoration: state == OiDropState.hovering
                ? BoxDecoration(
                    color: colors.primary.muted.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  )
                : const BoxDecoration(),
            child: row,
          );
        },
      );
    }

    return row;
  }
}
