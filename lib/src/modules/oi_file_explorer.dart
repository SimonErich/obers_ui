import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/buttons/oi_button_group.dart';
import 'package:obers_ui/src/components/buttons/oi_icon_button.dart';
import 'package:obers_ui/src/components/dialogs/oi_delete_dialog.dart';
import 'package:obers_ui/src/components/dialogs/oi_move_dialog.dart';
import 'package:obers_ui/src/components/dialogs/oi_upload_dialog.dart';
import 'package:obers_ui/src/components/display/oi_empty_state.dart';
import 'package:obers_ui/src/components/display/oi_path_bar.dart';
import 'package:obers_ui/src/components/display/oi_tooltip.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/components/overlays/oi_context_menu.dart';
import 'package:obers_ui/src/components/overlays/oi_dialog.dart';
import 'package:obers_ui/src/components/panels/oi_split_pane.dart';
import 'package:obers_ui/src/composites/data/oi_tree.dart';
import 'package:obers_ui/src/composites/files/oi_file_drop_target.dart';
import 'package:obers_ui/src/composites/files/oi_file_grid_view.dart';
import 'package:obers_ui/src/composites/files/oi_file_list_view.dart';
import 'package:obers_ui/src/composites/files/oi_file_sidebar.dart';
import 'package:obers_ui/src/composites/navigation/oi_shortcuts.dart';
import 'package:obers_ui/src/foundation/oi_accessibility.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/oi_overlays.dart';
import 'package:obers_ui/src/foundation/oi_search_debounce.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_file_explorer_controller.dart';
import 'package:obers_ui/src/models/oi_file_node_data.dart';
import 'package:obers_ui/src/models/settings/oi_file_explorer_settings.dart';
import 'package:obers_ui/src/modules/oi_chat.dart';

part 'oi_file_explorer/oi_file_explorer_content.part.dart';
part 'oi_file_explorer/oi_file_explorer_context_menus.part.dart';
part 'oi_file_explorer/oi_file_explorer_dialogs.part.dart';
part 'oi_file_explorer/oi_file_explorer_shortcuts.part.dart';
part 'oi_file_explorer/oi_file_explorer_toolbar.part.dart';

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
    required this.onUpload,
    this.onCopy,
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
    List<OiFileNodeData> files,
    OiFileNodeData destination,
  )
  onMove;

  /// Copies files/folders to a destination.
  final Future<void> Function(
    List<OiFileNodeData> files,
    OiFileNodeData destination,
  )?
  onCopy;

  /// Uploads files to a folder.
  final Future<void> Function(List<OiFileData> files, String folderId) onUpload;

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

  /// Whether file upload is enabled.
  final bool enableUpload;

  /// Whether file deletion is enabled.
  final bool enableDelete;

  /// Whether file renaming is enabled.
  final bool enableRename;

  /// Whether file moving is enabled.
  final bool enableMove;

  /// Whether file copying is enabled.
  final bool enableCopy;

  /// Whether search is enabled.
  final bool enableSearch;

  /// Whether drag-and-drop is enabled.
  final bool enableDragDrop;

  /// Whether multi-select is enabled.
  final bool enableMultiSelect;

  /// Whether favorites are enabled.
  final bool enableFavorites;

  /// Whether keyboard shortcuts are enabled.
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

  /// Clipboard for keyboard-based move (Ctrl+X / Ctrl+V).
  List<OiFileNodeData> _clipboard = [];
  bool _clipboardIsCut = false;

  /// Overlay handle for open dialogs.
  OiOverlayHandle? _dialogHandle;

  /// Whether a dialog overlay is currently open. Used to disable the
  /// background [OiFileDropTarget] so that OS-level drops are only handled
  /// by the dialog's own [DropTarget], preventing duplicate uploads.
  bool _isDialogOpen = false;

  // ── setState helpers (callable from extensions) ───────────────────────────

  void _setSearchActive({required bool active}) =>
      setState(() => _searchActive = active);

  void _setDialogOpen({required bool open}) =>
      setState(() => _isDialogOpen = open);

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    widget.controller.loadFolder = widget.loadFolder;
    widget.controller.addListener(_onControllerChanged);
    unawaited(_loadFolderTree());
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _searchDebounce.dispose();
    _dismissDialog();
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
        // Navigate to root so the content area shows initial files.
        if (widget.controller.currentFolder == null) {
          const rootFolder = OiFileNodeData(
            id: 'root',
            name: 'Home',
            folder: true,
          );
          await widget.controller.navigateTo('root', folder: rootFolder);
        }
      }
    } on Exception catch (_) {
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

  void _announce(String message) {
    OiA11y.announce(context, message);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final files = _filteredFiles;

    Widget body = Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.label,
      child: widget.showSidebar
          ? OiSplitPane(
              leading: _buildSidebar(),
              trailing: _buildMainContent(files, controller),
              initialRatio: 0.25,
            )
          : _buildMainContent(files, controller),
    );

    if (widget.enableKeyboardShortcuts) {
      body = OiShortcuts(shortcuts: _shortcuts, child: body);
    }

    return body;
  }
}
