import 'package:flutter/rendering.dart' show SemanticsService;
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
import 'package:obers_ui/src/foundation/oi_overlays.dart';
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
    required this.onUpload, this.onCopy,
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

  // ── Dialog helpers ────────────────────────────────────────────────────────

  void _dismissDialog() {
    _dialogHandle?.dismiss();
    _dialogHandle = null;
  }

  void _showDeleteDialog(List<OiFileNodeData> files) {
    _dismissDialog();
    _dialogHandle = OiDialog.show(
      context,
      label: 'Delete confirmation',
      dialog: OiDialog.confirm(
        label: 'Delete confirmation',
        content: OiDeleteDialog(
          files: files,
          onDelete: () async {
            _dismissDialog();
            await widget.onDelete(files);
            widget.controller.clearSelection();
            widget.controller.refresh();
            _announce('${files.length} item${files.length == 1 ? '' : 's'} deleted');
          },
          onCancel: _dismissDialog,
          permanent: true,
        ),
        onClose: _dismissDialog,
      ),
    );
  }

  void _showMoveDialog(List<OiFileNodeData> files, {bool copyMode = false}) {
    if (!copyMode && !widget.enableMove) return;
    if (copyMode && widget.onCopy == null) return;
    _dismissDialog();
    _dialogHandle = OiDialog.show(
      context,
      label: copyMode ? 'Copy dialog' : 'Move dialog',
      dialog: OiDialog.form(
        label: copyMode ? 'Copy dialog' : 'Move dialog',
        content: OiMoveDialog(
          files: files,
          folderTree: _folderTree,
          copyMode: copyMode,
          onMove: (destination) async {
            _dismissDialog();
            if (copyMode) {
              await widget.onCopy?.call(files, destination);
            } else {
              await widget.onMove(files, destination);
            }
            widget.controller.clearSelection();
            widget.controller.refresh();
            final action = copyMode ? 'copied' : 'moved';
            _announce(
              '${files.length} item${files.length == 1 ? '' : 's'} $action to ${destination.name}',
            );
          },
          onCancel: _dismissDialog,
        ),
        onClose: _dismissDialog,
      ),
    );
  }

  void _showUploadDialog() {
    _dismissDialog();
    final folderId =
        widget.controller.currentFolder?.id.toString() ?? 'root';
    _dialogHandle = OiDialog.show(
      context,
      label: 'Upload dialog',
      dialog: OiDialog.form(
        label: 'Upload dialog',
        content: OiUploadDialog(
          allowedExtensions: widget.allowedUploadExtensions,
          maxFileSize: widget.maxUploadFileSize,
          destinationPath: widget.controller.currentFolder?.name,
          onUpload: (files, _) async {
            _dismissDialog();
            await widget.onUpload(files, folderId);
            widget.controller.refresh();
            _announce('${files.length} file${files.length == 1 ? '' : 's'} uploaded');
          },
          onCancel: _dismissDialog,
        ),
        onClose: _dismissDialog,
      ),
    );
  }

  // ── Accessibility announcements ───────────────────────────────────────────

  void _announce(String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  // ── Keyboard shortcut bindings ────────────────────────────────────────────

  List<OiShortcutBinding> get _shortcuts => [
        OiShortcutBinding(
          activator: OiShortcutActivator.primary(LogicalKeyboardKey.keyA),
          label: 'Select all',
          category: 'Selection',
          onInvoke: () {
            if (!widget.enableMultiSelect) return;
            widget.controller.selectAll();
            _announce('All items selected');
          },
        ),
        OiShortcutBinding(
          activator: const SingleActivator(LogicalKeyboardKey.delete),
          label: 'Delete',
          category: 'Actions',
          onInvoke: () {
            if (!widget.enableDelete) return;
            final selected = widget.controller.selectedFiles;
            if (selected.isEmpty) return;
            _showDeleteDialog(selected);
          },
        ),
        OiShortcutBinding(
          activator: const SingleActivator(LogicalKeyboardKey.backspace),
          label: 'Delete',
          category: 'Actions',
          onInvoke: () {
            if (!widget.enableDelete) return;
            final selected = widget.controller.selectedFiles;
            if (selected.isEmpty) return;
            _showDeleteDialog(selected);
          },
        ),
        OiShortcutBinding(
          activator: const SingleActivator(LogicalKeyboardKey.f2),
          label: 'Rename',
          category: 'Actions',
          onInvoke: () {
            if (!widget.enableRename) return;
            final selected = widget.controller.selectedFiles;
            if (selected.length != 1) return;
            widget.controller.startRename(selected.first.id);
          },
        ),
        OiShortcutBinding(
          activator: OiShortcutActivator.primary(LogicalKeyboardKey.keyF),
          label: 'Search',
          category: 'Navigation',
          onInvoke: () {
            if (!widget.enableSearch) return;
            setState(() => _searchActive = true);
          },
        ),
        OiShortcutBinding(
          activator: const SingleActivator(LogicalKeyboardKey.escape),
          label: 'Cancel / close search',
          category: 'Navigation',
          onInvoke: () {
            if (_searchActive) {
              setState(() {
                _searchActive = false;
                widget.controller.setSearchQuery('');
              });
            } else if (widget.controller.renamingKey != null) {
              widget.controller.cancelRename();
            } else if (widget.controller.selectedKeys.isNotEmpty) {
              widget.controller.clearSelection();
              _announce('Selection cleared');
            }
          },
        ),
        OiShortcutBinding(
          activator: OiShortcutActivator.primary(LogicalKeyboardKey.keyX),
          label: 'Cut (for keyboard move)',
          category: 'Clipboard',
          onInvoke: () {
            final selected = widget.controller.selectedFiles;
            if (selected.isEmpty) return;
            _clipboard = List.of(selected);
            _clipboardIsCut = true;
            _announce(
              '${selected.length} item${selected.length == 1 ? '' : 's'} cut',
            );
          },
        ),
        OiShortcutBinding(
          activator: OiShortcutActivator.primary(LogicalKeyboardKey.keyC),
          label: 'Copy (for keyboard copy)',
          category: 'Clipboard',
          onInvoke: () {
            if (widget.onCopy == null) return;
            final selected = widget.controller.selectedFiles;
            if (selected.isEmpty) return;
            _clipboard = List.of(selected);
            _clipboardIsCut = false;
            _announce(
              '${selected.length} item${selected.length == 1 ? '' : 's'} copied to clipboard',
            );
          },
        ),
        OiShortcutBinding(
          activator: OiShortcutActivator.primary(LogicalKeyboardKey.keyV),
          label: 'Paste (move/copy here)',
          category: 'Clipboard',
          onInvoke: () async {
            if (_clipboard.isEmpty) return;
            final folder = widget.controller.currentFolder;
            if (folder == null) return;
            if (_clipboardIsCut) {
              await widget.onMove(_clipboard, folder);
              _announce(
                '${_clipboard.length} item${_clipboard.length == 1 ? '' : 's'} moved here',
              );
            } else {
              await widget.onCopy?.call(_clipboard, folder);
              _announce(
                '${_clipboard.length} item${_clipboard.length == 1 ? '' : 's'} copied here',
              );
            }
            _clipboard = [];
            _clipboardIsCut = false;
            widget.controller.clearSelection();
            widget.controller.refresh();
          },
        ),
        OiShortcutBinding(
          activator: OiShortcutActivator.primary(LogicalKeyboardKey.keyU),
          label: 'Upload',
          category: 'Actions',
          onInvoke: () {
            if (!widget.enableUpload) return;
            _showUploadDialog();
          },
        ),
        OiShortcutBinding(
          activator: OiShortcutActivator.primary(LogicalKeyboardKey.keyN,
              shift: true),
          label: 'New folder',
          category: 'Actions',
          onInvoke: () async {
            final folderId =
                widget.controller.currentFolder?.id.toString() ?? 'root';
            await widget.onCreateFolder(folderId, 'New Folder');
            widget.controller.refresh();
            _announce('New folder created');
          },
        ),
        OiShortcutBinding(
          activator: const SingleActivator(LogicalKeyboardKey.backspace,
              alt: true),
          label: 'Go back',
          category: 'Navigation',
          onInvoke: () {
            if (widget.controller.canGoBack) {
              widget.controller.goBack();
            }
          },
        ),
        OiShortcutBinding(
          activator: const SingleActivator(LogicalKeyboardKey.backspace,
              alt: true, shift: true),
          label: 'Go forward',
          category: 'Navigation',
          onInvoke: () {
            if (widget.controller.canGoForward) {
              widget.controller.goForward();
            }
          },
        ),
      ];

  // ── Context menu builders ─────────────────────────────────────────────────

  List<OiMenuItem> _buildFileContextMenu(OiFileNodeData file) {
    final custom = widget.customContextMenuItems?.call(file) ?? [];
    return [
      if (file.isFolder)
        OiMenuItem(
          label: 'Open',
          icon: const IconData(0xe89e, fontFamily: 'MaterialIcons'),
          onTap: () => widget.controller
              .navigateTo(file.id.toString(), folder: file),
        )
      else ...[
        if (widget.onOpen != null)
          OiMenuItem(
            label: 'Open',
            icon: const IconData(0xe89e, fontFamily: 'MaterialIcons'),
            onTap: () => widget.onOpen!(file),
          ),
        if (widget.onPreview != null)
          OiMenuItem(
            label: 'Preview',
            icon: const IconData(0xe417, fontFamily: 'MaterialIcons'),
            onTap: () => widget.onPreview!(file),
          ),
      ],
      if (custom.isNotEmpty) ...[
        const OiMenuItem(label: '', separator: true),
        ...custom,
      ],
      const OiMenuItem(label: '', separator: true),
      if (widget.enableRename)
        OiMenuItem(
          label: 'Rename',
          icon: const IconData(0xe3c9, fontFamily: 'MaterialIcons'),
          onTap: () => widget.controller.startRename(file.id),
        ),
      if (widget.enableMove)
        OiMenuItem(
          label: 'Move to...',
          icon: const IconData(0xeb80, fontFamily: 'MaterialIcons'),
          onTap: () => _showMoveDialog([file]),
        ),
      if (widget.enableCopy && widget.onCopy != null)
        OiMenuItem(
          label: 'Copy to...',
          icon: const IconData(0xe14d, fontFamily: 'MaterialIcons'),
          onTap: () => _showMoveDialog([file], copyMode: true),
        ),
      if (widget.onDownload != null)
        OiMenuItem(
          label: 'Download',
          icon: const IconData(0xf090, fontFamily: 'MaterialIcons'),
          onTap: () => widget.onDownload!(file),
        ),
      if (widget.onShare != null)
        OiMenuItem(
          label: 'Share',
          icon: const IconData(0xe80d, fontFamily: 'MaterialIcons'),
          onTap: () => widget.onShare!(file),
        ),
      const OiMenuItem(label: '', separator: true),
      if (widget.enableDelete)
        OiMenuItem(
          label: 'Delete',
          icon: const IconData(0xe872, fontFamily: 'MaterialIcons'),
          onTap: () => _showDeleteDialog([file]),
        ),
    ];
  }

  List<OiMenuItem> _buildBackgroundContextMenu() {
    return [
      OiMenuItem(
        label: 'New folder',
        icon: const IconData(0xe2cc, fontFamily: 'MaterialIcons'),
        onTap: () async {
          final folderId =
              widget.controller.currentFolder?.id.toString() ?? 'root';
          await widget.onCreateFolder(folderId, 'New Folder');
          widget.controller.refresh();
        },
      ),
      if (widget.enableUpload)
        OiMenuItem(
          label: 'Upload files',
          icon: const IconData(0xe9e4, fontFamily: 'MaterialIcons'),
          onTap: _showUploadDialog,
        ),
      if (widget.controller.selectedKeys.isNotEmpty) ...[
        const OiMenuItem(label: '', separator: true),
        OiMenuItem(
          label: 'Select all',
          icon: const IconData(0xe164, fontFamily: 'MaterialIcons'),
          onTap: widget.controller.selectAll,
        ),
        OiMenuItem(
          label: 'Clear selection',
          onTap: widget.controller.clearSelection,
        ),
      ],
    ];
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final controller = widget.controller;
    final files = _filteredFiles;

    Widget body = Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.label,
      child: widget.showSidebar
          ? OiSplitPane(
              leading: _buildSidebar(colors, spacing),
              trailing: _buildMainContent(colors, spacing, files, controller),
              initialRatio: 0.25,
            )
          : _buildMainContent(colors, spacing, files, controller),
    );

    if (widget.enableKeyboardShortcuts) {
      body = OiShortcuts(
        shortcuts: _shortcuts,
        child: body,
      );
    }

    return body;
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
      onFileDrop: widget.enableDragDrop
          ? (files, folder) async {
              await widget.onMove(files, folder);
              widget.controller.clearSelection();
              widget.controller.refresh();
              _announce(
                '${files.length} item${files.length == 1 ? '' : 's'} moved to ${folder.name}',
              );
            }
          : null,
      semanticsLabel: 'File explorer sidebar',
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
                _announce(
                  '${droppedFiles.length} item${droppedFiles.length == 1 ? '' : 's'} moved to ${targetFolder.name}',
                );
              }
            },
            onExternalDrop: (externalFiles) async {
              final folderId =
                  controller.currentFolder?.id.toString() ?? 'root';
              await widget.onUpload(externalFiles, folderId);
              controller.refresh();
              _announce(
                '${externalFiles.length} file${externalFiles.length == 1 ? '' : 's'} uploaded',
              );
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

    return Semantics(
      label: 'File explorer toolbar',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: (spacing as dynamic).md as double,
          vertical: (spacing as dynamic).sm as double,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom:
                BorderSide(color: (colors as dynamic).borderSubtle as Color),
          ),
        ),
        child: isSelectionMode
            ? _buildSelectionToolbar(colors, spacing, controller)
            : _buildNormalToolbar(colors, spacing, controller),
      ),
    );
  }

  Widget _buildNormalToolbar(dynamic colors, dynamic spacing,
      OiFileExplorerController controller) {
    return Row(
      children: [
        // Back/Forward buttons
        OiIconButton(
          icon: const IconData(0xe5c4, fontFamily: 'MaterialIcons'),
          semanticLabel: 'Go back',
          onTap: controller.canGoBack ? controller.goBack : null,
        ),
        OiIconButton(
          icon: const IconData(0xe5c8, fontFamily: 'MaterialIcons'),
          semanticLabel: 'Go forward',
          onTap: controller.canGoForward ? controller.goForward : null,
        ),
        SizedBox(width: (spacing as dynamic).xs as double),
        // Path bar or search
        Expanded(
          child: _searchActive
              ? Semantics(
                  label: 'Search files',
                  child: OiTextInput.search(
                    autofocus: true,
                    onChanged: (q) {
                      _searchDebounce.call(q, _onSearch);
                    },
                  ),
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
          label: 'View mode',
          exclusive: true,
          selectedIndex:
              controller.viewMode == OiFileViewMode.list ? 0 : 1,
          onSelect: (int index) {
            controller.setViewMode(
                index == 0 ? OiFileViewMode.list : OiFileViewMode.grid);
          },
          items: const [
            OiButtonGroupItem(
              icon: IconData(0xe8ef, fontFamily: 'MaterialIcons'),
              label: 'List view',
            ),
            OiButtonGroupItem(
              icon: IconData(0xe3ea, fontFamily: 'MaterialIcons'),
              label: 'Grid view',
            ),
          ],
        ),
        SizedBox(width: (spacing as dynamic).sm as double),
        // Actions
        if (widget.enableUpload)
          OiIconButton(
            icon: const IconData(0xe9e4, fontFamily: 'MaterialIcons'),
            semanticLabel: 'Upload files',
            onTap: _showUploadDialog,
          ),
        OiIconButton(
          icon: const IconData(0xe2cc, fontFamily: 'MaterialIcons'),
          semanticLabel: 'New folder',
          onTap: () async {
            final folderId =
                controller.currentFolder?.id.toString() ?? 'root';
            await widget.onCreateFolder(folderId, 'New Folder');
            controller.refresh();
            _announce('New folder created');
          },
        ),
      ],
    );
  }

  Widget _buildSelectionToolbar(dynamic colors, dynamic spacing,
      OiFileExplorerController controller) {
    final count = controller.selectedKeys.length;
    return Row(
      children: [
        Expanded(
          child: Semantics(
            liveRegion: true,
            child: Text(
              '$count selected',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: (colors as dynamic).text as Color,
              ),
            ),
          ),
        ),
        if (widget.enableMove)
          OiButton.ghost(
            label: 'Move',
            onTap: () => _showMoveDialog(controller.selectedFiles),
          ),
        if (widget.enableCopy && widget.onCopy != null)
          OiButton.ghost(
            label: 'Copy',
            onTap: () =>
                _showMoveDialog(controller.selectedFiles, copyMode: true),
          ),
        if (widget.enableDelete)
          OiButton.ghost(
            label: 'Delete',
            onTap: () => _showDeleteDialog(controller.selectedFiles),
          ),
        OiButton.ghost(
          label: 'Clear',
          onTap: () {
            controller.clearSelection();
            _announce('Selection cleared');
          },
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
          icon: const IconData(0xe8b6, fontFamily: 'MaterialIcons'),
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
      return OiContextMenu(
        label: 'Empty folder context menu',
        items: _buildBackgroundContextMenu(),
        child: OiEmptyState(
          icon: const IconData(0xe2c7, fontFamily: 'MaterialIcons'),
          title: 'This folder is empty',
          action: widget.enableUpload
              ? OiButton.primary(
                  label: 'Upload files',
                  icon: const IconData(0xe9e4, fontFamily: 'MaterialIcons'),
                  onTap: _showUploadDialog,
                )
              : null,
        ),
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
            _announce('Renamed to $newName');
          }
        },
        onCancelRename: controller.cancelRename,
        onMoveToFolder: widget.enableMove
            ? (movedFiles, folder) async {
                await widget.onMove(movedFiles, folder);
                controller.clearSelection();
                controller.refresh();
                _announce(
                  '${movedFiles.length} item${movedFiles.length == 1 ? '' : 's'} moved to ${folder.name}',
                );
              }
            : null,
        enableDragDrop: widget.enableDragDrop,
        enableMultiSelect: widget.enableMultiSelect,
        contextMenuBuilder: _buildFileContextMenu,
        backgroundContextMenu: _buildBackgroundContextMenu,
        searchQuery: controller.searchQuery,
        semanticsLabel: 'File list with ${files.length} items',
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
          _announce('Renamed to $newName');
        }
      },
      onCancelRename: controller.cancelRename,
      onMoveToFolder: widget.enableMove
          ? (movedFiles, folder) async {
              await widget.onMove(movedFiles, folder);
              controller.clearSelection();
              controller.refresh();
              _announce(
                '${movedFiles.length} item${movedFiles.length == 1 ? '' : 's'} moved to ${folder.name}',
              );
            }
          : null,
      enableDragDrop: widget.enableDragDrop,
      enableMultiSelect: widget.enableMultiSelect,
      contextMenuBuilder: _buildFileContextMenu,
      backgroundContextMenu: _buildBackgroundContextMenu,
      searchQuery: controller.searchQuery,
      semanticsLabel: 'File grid with ${files.length} items',
    );
  }
}
