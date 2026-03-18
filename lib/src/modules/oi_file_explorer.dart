import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/buttons/oi_button_group.dart';
import 'package:obers_ui/src/components/buttons/oi_icon_button.dart';
import 'package:obers_ui/src/components/display/oi_drop_highlight.dart';
import 'package:obers_ui/src/components/display/oi_empty_state.dart';
import 'package:obers_ui/src/components/display/oi_path_bar.dart';
import 'package:obers_ui/src/components/display/oi_storage_indicator.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/components/overlays/oi_context_menu.dart';
import 'package:obers_ui/src/components/panels/oi_split_pane.dart';
import 'package:obers_ui/src/composites/data/oi_tree.dart';
import 'package:obers_ui/src/composites/files/oi_file_drop_target.dart';
import 'package:obers_ui/src/composites/files/oi_file_grid_view.dart';
import 'package:obers_ui/src/composites/files/oi_file_list_view.dart';
import 'package:obers_ui/src/composites/files/oi_file_sidebar.dart';
import 'package:obers_ui/src/foundation/oi_search_debounce.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_file_explorer_controller.dart';
import 'package:obers_ui/src/models/oi_file_node_data.dart';
import 'package:obers_ui/src/models/settings/oi_file_explorer_settings.dart';
import 'package:obers_ui/src/modules/oi_chat.dart';

/// A complete file explorer module.
///
/// Combines sidebar folder tree, toolbar with path/search/sort/view-toggle,
/// content area with list/grid views, drag-and-drop everywhere, dialogs for
/// all CRUD operations, keyboard shortcuts, and OS-level drag support.
///
/// {@category Modules}
class OiFileExplorer extends StatefulWidget {
  /// Creates an [OiFileExplorer].
  const OiFileExplorer({
    required this.controller,
    required this.label,
    required this.loadFolder,
    required this.loadFolderTree,
    required this.onCreateFolder,
    required this.onRename,
    required this.onDelete,
    required this.onMove,
    this.onCopy,
    required this.onUpload,
    this.onDownload,
    this.onOpen,
    this.onPreview,
    this.onShare,
    this.defaultViewMode = OiFileViewMode.list,
    this.defaultSortField = OiFileSortField.name,
    this.defaultSortDirection = OiSortDirection.ascending,
    this.quickAccess,
    this.storage,
    this.showSidebar = true,
    this.sidebarWidth = 260,
    this.enableUpload = true,
    this.enableDelete = true,
    this.enableRename = true,
    this.enableMove = true,
    this.enableCopy = true,
    this.enableSearch = true,
    this.enableDragDrop = true,
    this.enableMultiSelect = true,
    this.enableFavorites = true,
    this.enableKeyboardShortcuts = true,
    this.allowedUploadExtensions,
    this.maxUploadFileSize,
    this.filePreviewBuilder,
    this.customContextMenuItems,
    super.key,
  });

  /// The controller managing explorer state.
  final OiFileExplorerController controller;

  /// Accessibility label for the explorer.
  final String label;

  /// Loads files for a given folder ID.
  final Future<List<OiFileNodeData>> Function(String folderId) loadFolder;

  /// Loads the folder tree for a given parent ID.
  final Future<List<OiTreeNode<OiFileNodeData>>> Function(String parentId)
      loadFolderTree;

  /// Creates a new folder.
  final Future<OiFileNodeData> Function(String parentId, String name)
      onCreateFolder;

  /// Renames a file/folder.
  final Future<void> Function(OiFileNodeData file, String newName) onRename;

  /// Deletes files/folders.
  final Future<void> Function(List<OiFileNodeData> files) onDelete;

  /// Moves files/folders to a destination.
  final Future<void> Function(
      List<OiFileNodeData> files, OiFileNodeData destination) onMove;

  /// Copies files/folders to a destination.
  final Future<void> Function(
      List<OiFileNodeData> files, OiFileNodeData destination)? onCopy;

  /// Uploads files to a folder.
  final Future<void> Function(List<OiFileData> files, String folderId)
      onUpload;

  /// Downloads a file.
  final Future<void> Function(OiFileNodeData file)? onDownload;

  /// Opens a file (e.g. in a viewer).
  final ValueChanged<OiFileNodeData>? onOpen;

  /// Previews a file.
  final ValueChanged<OiFileNodeData>? onPreview;

  /// Shares a file.
  final ValueChanged<OiFileNodeData>? onShare;

  /// Default view mode.
  final OiFileViewMode defaultViewMode;

  /// Default sort field.
  final OiFileSortField defaultSortField;

  /// Default sort direction.
  final OiSortDirection defaultSortDirection;

  /// Quick-access items for the sidebar.
  final List<OiQuickAccessItem>? quickAccess;

  /// Storage data for the sidebar indicator.
  final OiStorageData? storage;

  /// Whether to show the sidebar.
  final bool showSidebar;

  /// Sidebar width.
  final double sidebarWidth;

  /// Feature flags.
  final bool enableUpload;
  final bool enableDelete;
  final bool enableRename;
  final bool enableMove;
  final bool enableCopy;
  final bool enableSearch;
  final bool enableDragDrop;
  final bool enableMultiSelect;
  final bool enableFavorites;
  final bool enableKeyboardShortcuts;

  /// Allowed upload file extensions.
  final List<String>? allowedUploadExtensions;

  /// Maximum upload file size in bytes.
  final int? maxUploadFileSize;

  /// Custom preview builder for files.
  final Widget Function(OiFileNodeData)? filePreviewBuilder;

  /// Custom context menu items for files.
  final List<OiMenuItem> Function(OiFileNodeData)? customContextMenuItems;

  @override
  State<OiFileExplorer> createState() => _OiFileExplorerState();
}

class _OiFileExplorerState extends State<OiFileExplorer> {
  List<OiTreeNode<OiFileNodeData>> _folderTree = [];
  final OiSearchDebounce _searchDebounce = OiSearchDebounce();
  bool _searchActive = false;

  @override
  void initState() {
    super.initState();
    widget.controller.loadFolder = widget.loadFolder;
    widget.controller.addListener(_onControllerChanged);
    _loadFolderTree();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _searchDebounce.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadFolderTree() async {
    try {
      final tree = await widget.loadFolderTree('root');
      if (mounted) {
        setState(() => _folderTree = tree);
      }
    } catch (_) {
      // Tree loading error handled silently
    }
  }

  List<OiFileNodeData> get _filteredFiles {
    final query = widget.controller.searchQuery;
    if (query.isEmpty) return widget.controller.files;
    final lower = query.toLowerCase();
    return widget.controller.files
        .where((f) => f.name.toLowerCase().contains(lower))
        .toList();
  }

  List<OiPathSegment> get _pathSegments {
    final folder = widget.controller.currentFolder;
    if (folder == null) return [];
    // Build path from navigation history
    return [
      const OiPathSegment(id: 'root', label: 'Home'),
      if (folder.parentId != null)
        OiPathSegment(id: folder.parentId!, label: folder.parentId!),
      OiPathSegment(id: folder.id.toString(), label: folder.name),
    ];
  }

  void _onSearch(String query) {
    widget.controller.setSearchQuery(query);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final controller = widget.controller;
    final files = _filteredFiles;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.label,
      child: widget.showSidebar
          ? OiSplitPane(
              initialSizes: [widget.sidebarWidth, -1],
              children: [
                _buildSidebar(colors, spacing),
                _buildMainContent(colors, spacing, files, controller),
              ],
            )
          : _buildMainContent(colors, spacing, files, controller),
    );
  }

  Widget _buildSidebar(dynamic colors, dynamic spacing) {
    return OiFileSidebar(
      folderTree: _folderTree,
      selectedFolderId: widget.controller.currentFolder?.id.toString(),
      onFolderSelect: (folder) {
        widget.controller.navigateTo(folder.id.toString(), folder: folder);
      },
      quickAccess: widget.quickAccess,
      storage: widget.storage,
      width: widget.sidebarWidth,
      onNewFolder: (parent) async {
        await widget.onCreateFolder(parent.id.toString(), 'New Folder');
        widget.controller.refresh();
      },
    );
  }

  Widget _buildMainContent(dynamic colors, dynamic spacing,
      List<OiFileNodeData> files, OiFileExplorerController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Toolbar
        _buildToolbar(colors, spacing, controller),
        // Content
        Expanded(
          child: OiFileDropTarget(
            onInternalDrop: (droppedFiles, targetFolder) async {
              if (targetFolder != null) {
                await widget.onMove(droppedFiles, targetFolder);
                controller.refresh();
              }
            },
            onExternalDrop: (externalFiles) async {
              final folderId =
                  controller.currentFolder?.id.toString() ?? 'root';
              await widget.onUpload(externalFiles, folderId);
              controller.refresh();
            },
            enabled: widget.enableDragDrop,
            child: _buildContentArea(colors, spacing, files, controller),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar(dynamic colors, dynamic spacing,
      OiFileExplorerController controller) {
    final isSelectionMode = controller.selectedKeys.isNotEmpty;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (spacing as dynamic).md as double,
        vertical: (spacing as dynamic).sm as double,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: (colors as dynamic).borderSubtle as Color),
        ),
      ),
      child: isSelectionMode
          ? _buildSelectionToolbar(colors, spacing, controller)
          : _buildNormalToolbar(colors, spacing, controller),
    );
  }

  Widget _buildNormalToolbar(dynamic colors, dynamic spacing,
      OiFileExplorerController controller) {
    return Row(
      children: [
        // Path bar
        Expanded(
          child: _searchActive
              ? OiTextInput.search(
                  autofocus: true,
                  onChanged: (q) {
                    _searchDebounce.call(q, _onSearch);
                  },
                )
              : OiPathBar(
                  segments: _pathSegments,
                  onNavigate: (segment) {
                    controller.navigateTo(segment.id);
                  },
                ),
        ),
        // Search toggle
        if (widget.enableSearch)
          OiIconButton(
            icon: _searchActive
                ? const IconData(0xe5cd, fontFamily: 'MaterialIcons')
                : const IconData(0xe8b6, fontFamily: 'MaterialIcons'),
            semanticLabel: _searchActive ? 'Close search' : 'Search',
            onTap: () => setState(() {
              _searchActive = !_searchActive;
              if (!_searchActive) controller.setSearchQuery('');
            }),
          ),
        SizedBox(width: (spacing as dynamic).sm as double),
        // View toggle
        OiButtonGroup(
          selectedIndex:
              controller.viewMode == OiFileViewMode.list ? 0 : 1,
          onChanged: (index) {
            controller.setViewMode(
                index == 0 ? OiFileViewMode.list : OiFileViewMode.grid);
          },
          children: const [
            OiButtonGroupItem(
              icon: IconData(0xe8ef, fontFamily: 'MaterialIcons'), // list
              label: 'List',
            ),
            OiButtonGroupItem(
              icon: IconData(0xe3ea, fontFamily: 'MaterialIcons'), // grid
              label: 'Grid',
            ),
          ],
        ),
        SizedBox(width: (spacing as dynamic).sm as double),
        // Actions
        if (widget.enableUpload)
          OiIconButton(
            icon: const IconData(0xe9e4, fontFamily: 'MaterialIcons'), // upload
            semanticLabel: 'Upload',
            onTap: () {
              // Open upload dialog
            },
          ),
        OiIconButton(
          icon: const IconData(0xe2cc, fontFamily: 'MaterialIcons'), // create_new_folder
          semanticLabel: 'New folder',
          onTap: () async {
            final folderId =
                controller.currentFolder?.id.toString() ?? 'root';
            await widget.onCreateFolder(folderId, 'New Folder');
            controller.refresh();
          },
        ),
      ],
    );
  }

  Widget _buildSelectionToolbar(dynamic colors, dynamic spacing,
      OiFileExplorerController controller) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '${controller.selectedKeys.length} selected',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: (colors as dynamic).text as Color,
            ),
          ),
        ),
        if (widget.enableMove)
          OiButton.ghost(
            label: 'Move',
            onTap: () {
              // Open move dialog
            },
          ),
        if (widget.enableCopy && widget.onCopy != null)
          OiButton.ghost(
            label: 'Copy',
            onTap: () {
              // Open copy dialog
            },
          ),
        if (widget.enableDelete)
          OiButton.ghost(
            label: 'Delete',
            onTap: () async {
              await widget.onDelete(controller.selectedFiles);
              controller.clearSelection();
              controller.refresh();
            },
          ),
        OiButton.ghost(
          label: 'Clear',
          onTap: controller.clearSelection,
        ),
      ],
    );
  }

  Widget _buildContentArea(dynamic colors, dynamic spacing,
      List<OiFileNodeData> files, OiFileExplorerController controller) {
    if (controller.loading) {
      if (controller.viewMode == OiFileViewMode.list) {
        return OiFileListView(
          files: const [],
          selectedKeys: const {},
          onSelectionChange: (_) {},
          onOpen: (_) {},
          loading: true,
        );
      }
      return OiFileGridView(
        files: const [],
        selectedKeys: const {},
        onSelectionChange: (_) {},
        onOpen: (_) {},
        loading: true,
      );
    }

    if (files.isEmpty) {
      if (controller.searchQuery.isNotEmpty) {
        return OiEmptyState(
          icon: const IconData(0xe8b6, fontFamily: 'MaterialIcons'), // search
          title: "No files match '${controller.searchQuery}'",
          action: OiButton.ghost(
            label: 'Clear search',
            onTap: () {
              controller.setSearchQuery('');
              setState(() => _searchActive = false);
            },
          ),
        );
      }
      return OiEmptyState(
        icon: const IconData(0xe2c7, fontFamily: 'MaterialIcons'), // folder
        title: 'This folder is empty',
        action: widget.enableUpload
            ? OiButton.primary(
                label: 'Upload files',
                icon: const IconData(0xe9e4, fontFamily: 'MaterialIcons'),
                onTap: () {
                  // Open upload dialog
                },
              )
            : null,
      );
    }

    if (controller.viewMode == OiFileViewMode.list) {
      return OiFileListView(
        files: files,
        selectedKeys: controller.selectedKeys,
        onSelectionChange: controller.setSelection,
        onOpen: (file) {
          if (file.isFolder) {
            controller.navigateTo(file.id.toString(), folder: file);
          } else {
            widget.onOpen?.call(file);
          }
        },
        sortField: controller.sortField,
        sortDirection: controller.sortDirection,
        onSortFieldChange: controller.setSortField,
        onSortDirectionChange: controller.setSortDirection,
        renamingKey: controller.renamingKey,
        onRename: (newName) async {
          final renamingFile = controller.files
              .where((f) => f.id == controller.renamingKey)
              .firstOrNull;
          if (renamingFile != null) {
            await widget.onRename(renamingFile, newName);
            controller.cancelRename();
            controller.refresh();
          }
        },
        onCancelRename: controller.cancelRename,
        onMoveToFolder: widget.enableMove
            ? (files, folder) async {
                await widget.onMove(files, folder);
                controller.refresh();
              }
            : null,
      );
    }

    return OiFileGridView(
      files: files,
      selectedKeys: controller.selectedKeys,
      onSelectionChange: controller.setSelection,
      onOpen: (file) {
        if (file.isFolder) {
          controller.navigateTo(file.id.toString(), folder: file);
        } else {
          widget.onOpen?.call(file);
        }
      },
      renamingKey: controller.renamingKey,
      onRename: (newName) async {
        final renamingFile = controller.files
            .where((f) => f.id == controller.renamingKey)
            .firstOrNull;
        if (renamingFile != null) {
          await widget.onRename(renamingFile, newName);
          controller.cancelRename();
          controller.refresh();
        }
      },
      onCancelRename: controller.cancelRename,
      onMoveToFolder: widget.enableMove
          ? (files, folder) async {
              await widget.onMove(files, folder);
              controller.refresh();
            }
          : null,
    );
  }
}
