# File Management

ObersUI ships two file modules. `OiFileExplorer` is a full file manager: a
sidebar, list and grid views, drag-and-drop, upload, rename, move, delete,
search, and keyboard shortcuts, all wired together. `OiFileManager` is a smaller
browser for cases where you already handle navigation and just need a view of
files. Both read their colors, spacing, and radius from the theme.

| Widget | What it does |
| --- | --- |
| `OiFileExplorer` | A complete file manager driven by a controller and async loaders. |
| `OiFileManager` | A lighter file browser with grid or list layout and selection. |

## OiFileExplorer

Reach for `OiFileExplorer` when you need a real file manager and do not want to
assemble one from parts. It handles the sidebar folder tree, a toolbar with path,
search, sort, and view toggle, the content area, drag-and-drop everywhere, the
CRUD dialogs, and keyboard shortcuts.

It is driven by three things: an `OiFileExplorerController`, a set of async
loaders that fetch folders, and a set of callbacks that run each operation. You
own the data. The explorer owns the interaction.

### Data model

Files and folders are `OiFileNodeData`. Each node has an `id`, a `name`, and a
`folder` flag, plus optional metadata like `size`, `mimeType`, `modified`,
`thumbnailUrl`, `favorite`, and `locked`.

```dart
const OiFileNodeData(
  id: 'file-42',
  name: 'report.pdf',
  folder: false,
  size: 248000,
  mimeType: 'application/pdf',
)
```

Uploaded files arrive as `OiFileData` (`name`, `size`, `mimeType`, `bytes`,
`url`). The folder tree in the sidebar is built from `OiTreeNode<OiFileNodeData>`.

### The controller

`OiFileExplorerController` holds the interactive state: the current folder,
navigation history, selection, view mode, sort, and search query. Create one,
keep it in your state, and dispose it when you are done.

```dart
final controller = OiFileExplorerController(
  viewMode: OiFileViewMode.list,
  sortField: OiFileSortField.name,
  sortDirection: OiSortDirection.ascending,
);
```

You rarely need to poke the controller directly. It calls `notifyListeners` on
every change, and the explorer rebuilds. When you finish an operation outside the
explorer, call `controller.refresh()` to reload the current folder, or
`controller.updateFiles(newFiles)` to swap the list in place.

Useful controller members:

| Member | Type | Description |
| --- | --- | --- |
| `currentFolder` | `OiFileNodeData?` | The folder on screen. |
| `selectedFiles` | `List<OiFileNodeData>` | The current selection. |
| `viewMode` | `OiFileViewMode` | `list` or `grid`. |
| `searchQuery` | `String` | The active search text. |
| `navigateTo(id, {folder})` | `Future<void>` | Loads a folder and pushes history. |
| `goBack()` / `goForward()` / `goUp()` | `void` | Move through history. |
| `refresh()` | `Future<void>` | Reload the current folder. |
| `updateFiles(files)` | `void` | Replace the file list. |
| `clearSelection()` | `void` | Drop the selection. |

### A realistic example

The four loaders and callbacks below are the ones you must provide. The explorer
handles the rest.

```dart
class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  final OiFileExplorerController _controller = OiFileExplorerController();
  final MyFileApi _api = MyFileApi();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OiFileExplorer(
      controller: _controller,
      label: 'Document library',

      // Loaders: fetch data for the sidebar tree and the content area.
      loadFolder: (folderId) => _api.listFiles(folderId),
      loadFolderTree: (parentId) => _api.listFolderTree(parentId),

      // Operation callbacks: run each action against your backend.
      onCreateFolder: (parentId, name) => _api.createFolder(parentId, name),
      onRename: (file, newName) => _api.rename(file.id, newName),
      onDelete: (files) => _api.delete(files),
      onMove: (files, destination) => _api.move(files, destination.id),
      onUpload: (files, folderId) => _api.upload(files, folderId),

      // Optional extras.
      onDownload: (file) => _api.download(file),
      onPreview: (file) => _openPreview(file),

      quickAccess: const [
        OiQuickAccessItem(id: 'recent', label: 'Recent', icon: OiIcons.clock),
        OiQuickAccessItem(id: 'shared', label: 'Shared', icon: OiIcons.share),
      ],
      storage: const OiStorageData(
        usedBytes: 6400000000,
        totalBytes: 16000000000,
      ),
    );
  }
}
```

### Loaders

These four functions fetch data. All are required. They run async, so return a
`Future`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `loadFolder` | `Future<List<OiFileNodeData>> Function(String folderId)` | **required** | Files in a folder. |
| `loadFolderTree` | `Future<List<OiTreeNode<OiFileNodeData>>> Function(String parentId)` | **required** | Folder tree under a parent. `root` loads the top. |

### Operation callbacks

These run each action. The explorer opens the dialog, collects input, then calls
your callback. The five below are required. The rest are optional. If you leave
an optional callback `null`, that action does not appear.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `onCreateFolder` | `Future<OiFileNodeData> Function(String parentId, String name)` | **required** | Create a folder, return the new node. |
| `onRename` | `Future<void> Function(OiFileNodeData file, String newName)` | **required** | Rename a file or folder. |
| `onDelete` | `Future<void> Function(List<OiFileNodeData> files)` | **required** | Delete the given items. |
| `onMove` | `Future<void> Function(List<OiFileNodeData> files, OiFileNodeData destination)` | **required** | Move items into a folder. |
| `onUpload` | `Future<void> Function(List<OiFileData> files, String folderId)` | **required** | Upload files into a folder. |
| `onCopy` | `Future<void> Function(List<OiFileNodeData> files, OiFileNodeData destination)?` | `null` | Copy items into a folder. |
| `onDownload` | `Future<void> Function(OiFileNodeData file)?` | `null` | Download a file. |
| `onOpen` | `ValueChanged<OiFileNodeData>?` | `null` | Open a file, for example in a viewer. |
| `onPreview` | `ValueChanged<OiFileNodeData>?` | `null` | Preview a file. |
| `onShare` | `ValueChanged<OiFileNodeData>?` | `null` | Share a file. |

### Layout and defaults

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `controller` | `OiFileExplorerController` | **required** | Holds the explorer state. |
| `label` | `String` | **required** | Accessibility label for the whole module. |
| `defaultViewMode` | `OiFileViewMode` | `list` | Initial view: `list` or `grid`. |
| `defaultSortField` | `OiFileSortField` | `name` | `name`, `size`, `modified`, or `type`. |
| `defaultSortDirection` | `OiSortDirection` | `ascending` | `ascending` or `descending`. |
| `quickAccess` | `List<OiQuickAccessItem>?` | `null` | Sidebar shortcuts. Each has `id`, `label`, `icon`, `badgeCount`. |
| `storage` | `OiStorageData?` | `null` | Storage bar data (`usedBytes`, `totalBytes`, `breakdown`). |
| `showSidebar` | `bool` | `true` | Show the folder-tree sidebar. |
| `sidebarWidth` | `double` | `260` | Sidebar width in logical pixels. |
| `allowedUploadExtensions` | `List<String>?` | `null` | Restrict uploads to these extensions. |
| `maxUploadFileSize` | `int?` | `null` | Reject uploads over this many bytes. |
| `filePreviewBuilder` | `Widget Function(OiFileNodeData)?` | `null` | Custom preview widget. |
| `customContextMenuItems` | `List<OiMenuItem> Function(OiFileNodeData)?` | `null` | Extra right-click actions. |

### Feature flags

Every feature is on by default. Turn one off and its buttons, menu items, and
shortcuts disappear. Turn off a feature you do not support instead of leaving a
callback that throws.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `enableUpload` | `bool` | `true` | Allow uploading files. |
| `enableDelete` | `bool` | `true` | Allow deleting. |
| `enableRename` | `bool` | `true` | Allow renaming. |
| `enableMove` | `bool` | `true` | Allow moving. |
| `enableCopy` | `bool` | `true` | Allow copying. |
| `enableSearch` | `bool` | `true` | Show the search field. |
| `enableDragDrop` | `bool` | `true` | Allow drag-and-drop and OS-level drops. |
| `enableMultiSelect` | `bool` | `true` | Allow selecting more than one item. |
| `enableFavorites` | `bool` | `true` | Show and toggle favorites. |
| `enableKeyboardShortcuts` | `bool` | `true` | Enable shortcuts like Ctrl+X and Ctrl+V. |

!!! note
    `onMove` and `onUpload` are always required, even if you set `enableMove` or
    `enableUpload` to `false`. Pass a callback that returns `Future.value()` when
    a required operation is not used.

**Theme:** `context.components.fileExplorer` → `OiFileExplorerThemeData`

`OiFileExplorerThemeData` overrides sidebar and content backgrounds, tile height
and hover and selection colors, grid card radius, drop highlight colors, toolbar
sizing, and per-category icon colors. Every field is nullable. A `null` value
keeps the built-in default.

```dart
OiApp(
  theme: OiThemeData.light().copyWith(
    components: OiComponentThemes(
      fileExplorer: OiFileExplorerThemeData(
        sidebarWidth: 300,
        fileTileHeight: 44,
        folderIconColor: context.colors.primary.base,
      ),
    ),
  ),
  home: const FilesScreen(),
)
```

## OiFileManager

`OiFileManager` is a lighter browser. Use it when you already have a list of
files in hand and you handle navigation yourself. It does not fetch data or open
CRUD dialogs. You pass `items`, pick a layout, and respond to taps.

It uses a smaller model, `OiFileNode` (`key`, `name`, `folder`, `size`,
`modified`, `thumbnailUrl`), not `OiFileNodeData`.

```dart
OiFileManager(
  label: 'Project files',
  layout: OiFileManagerLayout.grid,
  items: const [
    OiFileNode(key: 'a', name: 'Designs', folder: true),
    OiFileNode(key: 'b', name: 'brief.pdf', folder: false, size: 82000),
  ],
  onOpen: (node) => open(node),
)
```

### Search

Leave `onSearch` null for client-side search. A non-empty `searchQuery` then
filters `items` by name. Provide `onSearch` for server-side search. The manager
renders a search field and debounces input by 300 ms. You filter and re-provide
`items`, and `searchQuery` is used only to highlight matches.

```dart
OiFileManager(
  label: 'Project files',
  items: _results,
  searchQuery: _query,
  onSearch: (query) => setState(() => _query = query),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `List<OiFileNode>` | **required** | Files and folders to show. |
| `label` | `String` | **required** | Accessibility label. |
| `layout` | `OiFileManagerLayout` | `grid` | `grid` or `list`. |
| `selectionMode` | `OiFileManagerSelectionMode` | `multi` | `none`, `single`, or `multi`. |
| `onOpen` | `ValueChanged<OiFileNode>?` | `null` | Fires on double-tap. |
| `onRename` | `ValueChanged<OiFileNode>?` | `null` | Rename handler. |
| `onDelete` | `ValueChanged<OiFileNode>?` | `null` | Delete handler. |
| `onMove` | `void Function(OiFileNode file, OiFileNode folder)?` | `null` | Move handler. |
| `onUpload` | `ValueChanged<List<OiFileData>>?` | `null` | Upload handler. Shows an upload action in the empty state. |
| `currentPath` | `List<String>?` | `null` | Path segments for the breadcrumb. |
| `onNavigate` | `ValueChanged<List<String>>?` | `null` | Fires when a breadcrumb segment is tapped. |
| `searchQuery` | `String?` | `null` | Active query for filtering or highlighting. |
| `onSearch` | `ValueChanged<String>?` | `null` | Provide for server-side search. |
| `settingsDriver` | `OiSettingsDriver?` | `null` | Persist view settings. `null` disables persistence. |
| `settingsKey` | `String?` | `null` | Scopes settings within the namespace. |
| `settingsNamespace` | `String` | `oi_file_explorer` | Top-level settings key. |

!!! tip "Which one do I use"
    Use `OiFileExplorer` for a full file manager with a sidebar, dialogs, and
    upload. Use `OiFileManager` for a simple grid or list when you already own
    the data and navigation.

## Related

- [Widgets: Files](../widgets/files.md) for the building-block views, icons, and
  dialogs these modules use (`OiFileGridView`, `OiFileSidebar`, `OiUploadDialog`,
  `OiRenameDialog`, `OiMoveDialog`, `OiDeleteDialog`, and more).
- [Buttons & Actions](../widgets/buttons.md) for the bulk bar that appears on
  selection.
