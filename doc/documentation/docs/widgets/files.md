# Files & File Management

These widgets build file browsers, upload flows, and media pickers. Some are
whole views like a grid or list of files. Some are small pieces like a file
icon or a folder tile. Some are dialogs for the usual file actions: rename,
move, delete, and upload. Two full modules, `OiFileExplorer` and
`OiFileManager`, wire these together for you. See
[Modules](../modules/files.md) for those.

Most of the views work on `OiFileNodeData`, the shared model that describes a
file or folder (`id`, `name`, `folder`, `size`, `mimeType`, `modified`, and
more). The two lightweight display widgets, `OiFileTile` and `OiFileGridCard`,
use a smaller model called `OiFileNode` (`key`, `name`, `folder`, `size`).

| Widget | What it does |
| --- | --- |
| `OiFileInput` | A form field that opens the file picker and shows chips. |
| `OiFileDropTarget` | Wraps an area so files can be dropped onto it. |
| `OiFileGridView` | A grid of file cards with selection and drag-and-drop. |
| `OiFileListView` | A sortable table-style list of files. |
| `OiFileSidebar` | The folder tree, quick access, and storage panel. |
| `OiFileToolbar` | A breadcrumb bar that flips to a selection bar. |
| `OiFileTile` | A single file row (icon, name, size). |
| `OiFileGridCard` | A single file card for a grid. |
| `OiFileIcon` | A file-type icon with a colored extension band. |
| `OiFolderIcon` | A folder icon with states and variants. |
| `OiFolderTreeItem` | An expandable folder node for a sidebar tree. |
| `OiUploadDialog` | Upload files with a drop zone and progress. |
| `OiRenameDialog` | Rename a file or folder. |
| `OiMoveDialog` | Move or copy items to another folder. |
| `OiDeleteDialog` | Confirm a delete, with a trash or permanent mode. |
| `OiNewFolderDialog` | Create a new folder. |
| `OiFileInfoDialog` | Show a file's details and metadata. |
| `OiMediaPicker` | Pick images and files from a gallery or the file system. |
| `OiMetadataEditor` | Edit a list of typed key-value fields. |

## OiFileInput

A form field that opens the platform file picker. Selected files show as
removable chips. Reach for it inside a form when you need the user to attach one
or more files.

```dart
OiFileInput(
  label: 'Attachments',
  multipleFiles: true,
  onChanged: (paths) => setState(() => _paths = paths),
)
```

Turn on `dropZone` to render a drop area beneath the chips. Pass
`allowedExtensions` to limit the file types the picker offers.

```dart
OiFileInput(
  label: 'Resume',
  hint: 'PDF or Word document',
  allowedExtensions: ['pdf', 'doc', 'docx'],
  dropZone: true,
  onChanged: (paths) => _handle(paths),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `List<String>?` | `null` | Controlled list of selected file paths. Leave null to let the field manage its own state. |
| `onChanged` | `ValueChanged<List<String>>?` | `null` | Fires with the updated path list. |
| `label` | `String?` | `null` | Label above the field. |
| `hint` | `String?` | `null` | Hint below the field. |
| `error` | `String?` | `null` | Validation error message. |
| `enabled` | `bool` | `true` | Set `false` to disable. |
| `multipleFiles` | `bool` | `false` | Allow more than one file. |
| `allowedExtensions` | `List<String>?` | `null` | Restrict to these extensions, without the dot. |
| `dropZone` | `bool` | `false` | Show a drop area beneath the chips. |

## OiFileDropTarget

Wraps any widget and turns it into a drop target. It handles two kinds of drop:
files dragged in from the operating system, and items dragged from inside your
app (like a file moved from the sidebar). It shows a highlight overlay while a
drag is over it.

```dart
OiFileDropTarget(
  onExternalDrop: (files) => upload(files),
  onInternalDrop: (files, targetFolder) => move(files, targetFolder),
  child: OiFileGridView(
    files: _files,
    selectedKeys: _selected,
    onSelectionChange: (keys) => setState(() => _selected = keys),
    onOpen: _open,
  ),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | **required** | The area that accepts drops. |
| `onExternalDrop` | `ValueChanged<List<OiFileData>>` | **required** | Fires with files dropped from the OS. Each has `name`, `size`, `bytes`, and `mimeType`. |
| `onInternalDrop` | `void Function(List<OiFileNodeData>, OiFileNodeData?)` | **required** | Fires with items dragged from inside the app. The second argument is the target folder, or null for the root area. |
| `enabled` | `bool` | `true` | Set `false` to pass the child through untouched. |
| `dropMessage` | `String?` | `null` | Message shown in the highlight. Defaults to "Drop files here". |

## OiFileGridView

A grid of file cards. It handles selection (including Ctrl and Shift click),
rubber-band selection, keyboard arrows, inline rename, and drag-and-drop. You
own the selected set and update it in `onSelectionChange`.

```dart
OiFileGridView(
  files: _files,
  selectedKeys: _selected,
  onSelectionChange: (keys) => setState(() => _selected = keys),
  onOpen: (file) => _open(file),
)
```

Folders become drop targets when you pass `onMoveToFolder`. Set a
`contextMenuBuilder` to add a right-click menu per file.

```dart
OiFileGridView(
  files: _files,
  selectedKeys: _selected,
  onSelectionChange: (keys) => setState(() => _selected = keys),
  onOpen: _open,
  onMoveToFolder: (files, folder) => move(files, folder),
  contextMenuBuilder: (file) => [
    OiMenuItem(label: 'Rename', icon: OiIcons.pencil, onTap: () => _rename(file)),
    OiMenuItem(label: 'Delete', icon: OiIcons.trash2, onTap: () => _delete(file)),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `files` | `List<OiFileNodeData>` | **required** | Files and folders to show. |
| `selectedKeys` | `Set<Object>` | **required** | The selected file ids. |
| `onSelectionChange` | `ValueChanged<Set<Object>>` | **required** | Fires with the new selection. |
| `onOpen` | `ValueChanged<OiFileNodeData>` | **required** | Fires on double-tap or Enter. |
| `cardWidth` | `double` | `160` | Card width in logical pixels. |
| `cardHeight` | `double` | `180` | Card height in logical pixels. |
| `gap` | `double` | `12` | Space between cards. |
| `renamingKey` | `Object?` | `null` | Id of the file being renamed inline. |
| `onRename` | `ValueChanged<String>?` | `null` | Fires with the new name. |
| `onCancelRename` | `VoidCallback?` | `null` | Fires when rename is cancelled. |
| `onMoveToFolder` | `void Function(List<OiFileNodeData>, OiFileNodeData)?` | `null` | Enables folder drop targets. |
| `contextMenuBuilder` | `List<OiMenuItem> Function(OiFileNodeData)?` | `null` | Per-file right-click menu. |
| `backgroundContextMenu` | `List<OiMenuItem> Function()?` | `null` | Menu for the empty area. |
| `enableDragDrop` | `bool` | `true` | Turn drag-and-drop on or off. |
| `enableMultiSelect` | `bool` | `true` | Turn Ctrl/Shift multi-select on or off. |
| `searchQuery` | `String?` | `null` | Highlights matches in file names. |
| `loading` | `bool` | `false` | Shows skeleton cards. |
| `semanticsLabel` | `String?` | `null` | Accessibility label for the grid. |

## OiFileListView

The table-style view of files. It shows a sortable column header (name, size,
modified, type) and virtualized rows. It shares the selection, rename, and
drag-and-drop behavior with `OiFileGridView`. Sorting is controlled: you hold
the sort state and update it in the callbacks.

```dart
OiFileListView(
  files: _files,
  selectedKeys: _selected,
  onSelectionChange: (keys) => setState(() => _selected = keys),
  onOpen: _open,
  sortField: _field,
  sortDirection: _direction,
  onSortFieldChange: (field) => setState(() => _field = field),
  onSortDirectionChange: (dir) => setState(() => _direction = dir),
)
```

Add your own columns with `extraColumns`, each an `OiFileColumnDef` with an
`id`, `label`, `width`, and `cellBuilder`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `files` | `List<OiFileNodeData>` | **required** | Files and folders to show. |
| `selectedKeys` | `Set<Object>` | **required** | The selected file ids. |
| `onSelectionChange` | `ValueChanged<Set<Object>>` | **required** | Fires with the new selection. |
| `onOpen` | `ValueChanged<OiFileNodeData>` | **required** | Fires on double-tap or Enter. |
| `sortField` | `OiFileSortField` | `name` | Active sort field: `name`, `size`, `modified`, `type`. |
| `sortDirection` | `OiSortDirection` | `ascending` | `ascending` or `descending`. |
| `onSortFieldChange` | `ValueChanged<OiFileSortField>?` | `null` | Fires when the header field changes. |
| `onSortDirectionChange` | `ValueChanged<OiSortDirection>?` | `null` | Fires when the direction flips. |
| `showSize` | `bool` | `true` | Show the size column. |
| `showModified` | `bool` | `true` | Show the modified column. |
| `showType` | `bool` | `true` | Show the type column. |
| `extraColumns` | `List<OiFileColumnDef>?` | `null` | Extra custom columns. |
| `renamingKey` | `Object?` | `null` | Id of the file being renamed inline. |
| `onRename` | `ValueChanged<String>?` | `null` | Fires with the new name. |
| `onCancelRename` | `VoidCallback?` | `null` | Fires when rename is cancelled. |
| `onMoveToFolder` | `void Function(List<OiFileNodeData>, OiFileNodeData)?` | `null` | Enables folder drop targets. |
| `contextMenuBuilder` | `List<OiMenuItem> Function(OiFileNodeData)?` | `null` | Per-file right-click menu. |
| `backgroundContextMenu` | `List<OiMenuItem> Function()?` | `null` | Menu for the empty area. |
| `enableDragDrop` | `bool` | `true` | Turn drag-and-drop on or off. |
| `enableMultiSelect` | `bool` | `true` | Turn Ctrl/Shift multi-select on or off. |
| `searchQuery` | `String?` | `null` | Highlights matches in file names. |
| `loading` | `bool` | `false` | Shows skeleton rows. |
| `semanticsLabel` | `String?` | `null` | Accessibility label for the list. |

## OiFileSidebar

The left panel of a file browser. It shows a folder tree with drag-and-drop, an
optional quick-access section (Home, Downloads, Trash), favorites, a storage
indicator, and folder actions. The folder tree is a list of
`OiTreeNode<OiFileNodeData>`.

```dart
OiFileSidebar(
  folderTree: _tree,
  selectedFolderId: _folderId,
  onFolderSelect: (folder) => setState(() => _folderId = folder.id as String),
  quickAccess: const [
    OiQuickAccessItem(id: 'home', label: 'Home', icon: OiIcons.home),
    OiQuickAccessItem(id: 'trash', label: 'Trash', icon: OiIcons.trash2),
  ],
  storage: const OiStorageData(usedBytes: 3200000000, totalBytes: 5000000000),
)
```

Pass `onNewFolder`, `onRenameFolder`, or `onDeleteFolder` to add folder
management. When any of them is set, each folder gets a right-click menu, and
`onNewFolder` also shows a "New Folder" button at the bottom.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `folderTree` | `List<OiTreeNode<OiFileNodeData>>` | **required** | The folder hierarchy. |
| `selectedFolderId` | `String?` | **required** | Id of the selected folder. |
| `onFolderSelect` | `ValueChanged<OiFileNodeData>` | **required** | Fires when a folder is tapped. |
| `loadChildren` | `Future<List<OiTreeNode<OiFileNodeData>>> Function(...)?` | `null` | Lazy loader for child folders. |
| `draggable` | `bool` | `true` | Allow folders to be dragged. |
| `onFolderMove` | `void Function(OiFileNodeData, OiFileNodeData?, int)?` | `null` | Fires when a folder is reordered. |
| `onFileDrop` | `void Function(List<OiFileNodeData>, OiFileNodeData)?` | `null` | Fires when files are dropped on a folder. |
| `quickAccess` | `List<OiQuickAccessItem>?` | `null` | Quick-access rows. |
| `onQuickAccessTap` | `ValueChanged<OiQuickAccessItem>?` | `null` | Fires when a quick-access row is tapped. |
| `favorites` | `List<OiFileNodeData>?` | `null` | Favorite folders. |
| `onFavoriteTap` | `ValueChanged<OiFileNodeData>?` | `null` | Fires when a favorite is tapped. |
| `onNewFolder` | `ValueChanged<OiFileNodeData>?` | `null` | Create a folder under the given parent. |
| `onRenameFolder` | `ValueChanged<OiFileNodeData>?` | `null` | Rename the given folder. |
| `onDeleteFolder` | `ValueChanged<OiFileNodeData>?` | `null` | Delete the given folder. |
| `storage` | `OiStorageData?` | `null` | Storage indicator data (`usedBytes`, `totalBytes`, `breakdown`). |
| `width` | `double` | `260` | Sidebar width. |
| `resizable` | `bool` | `true` | Allow the user to resize. |
| `collapsible` | `bool` | `true` | Allow the sidebar to collapse. |
| `semanticsLabel` | `String?` | `null` | Accessibility label. |

**Theme:** `context.components.fileExplorer` → `OiFileExplorerThemeData`

## OiFileToolbar

The top bar of a file browser. Normally it shows the breadcrumb path with an
optional search toggle. When `selectedCount` is greater than zero it slides over
to a selection bar that shows the count and your bulk actions.

```dart
OiFileToolbar(
  label: 'File navigation',
  breadcrumbs: const [
    OiBreadcrumbItem(label: 'Home'),
    OiBreadcrumbItem(label: 'Documents'),
  ],
  selectedCount: _selected.length,
  bulkActions: [
    OiIconButton(icon: OiIcons.trash2, semanticLabel: 'Delete', onTap: _delete),
  ],
  onSearch: (query) => setState(() => _query = query),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `breadcrumbs` | `List<OiBreadcrumbItem>` | **required** | The current path. |
| `label` | `String` | **required** | Toolbar accessibility label. |
| `selectedCount` | `int` | `0` | Above zero switches to selection mode. |
| `bulkActions` | `List<Widget>` | `[]` | Actions shown in selection mode. |
| `onSearch` | `ValueChanged<String>?` | `null` | Fires with the query, debounced 300 ms. Null hides the search icon. |

## OiFileTile

A single file row: an icon, the name, and the size. It is the small building
block for a custom list. It takes an `OiFileNode` (note the `key` field, not
`id`).

```dart
OiFileTile(
  file: const OiFileNode(key: '1', name: 'report.pdf', folder: false, size: 240000),
  onTap: () => _select(),
  onDoubleTap: () => _open(),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `OiFileNode` | **required** | The file or folder to show. |
| `selected` | `bool` | `false` | Highlight the row. |
| `onTap` | `VoidCallback?` | `null` | Called on single tap. |
| `onDoubleTap` | `VoidCallback?` | `null` | Called on double tap. |
| `searchQuery` | `String?` | `null` | Highlights a match in the name. |
| `semanticsLabel` | `String?` | `null` | Accessibility label. Defaults to the file name. |

!!! note
    `OiFileTile` and `OiFileGridCard` are plain display rows. For a full view
    with selection, sorting, and drag-and-drop, use `OiFileListView` or
    `OiFileGridView` instead.

## OiFileGridCard

A single file card for a grid: a large icon and the name. Like `OiFileTile`, it
takes an `OiFileNode`.

```dart
OiFileGridCard(
  file: const OiFileNode(key: '2', name: 'photo.png', folder: false),
  selected: true,
  onDoubleTap: () => _open(),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `OiFileNode` | **required** | The file or folder to show. |
| `selected` | `bool` | `false` | Highlight the card. |
| `onTap` | `VoidCallback?` | `null` | Called on single tap. |
| `onDoubleTap` | `VoidCallback?` | `null` | Called on double tap. |
| `searchQuery` | `String?` | `null` | Highlights a match in the name. |
| `semanticsLabel` | `String?` | `null` | Accessibility label. Defaults to the file name. |

## OiFileIcon

A file-type icon drawn as a page shape with a dog-ear fold and a colored band
that shows the extension. The color comes from the file category, so a PDF, an
image, and a zip each read differently at a glance.

```dart
OiFileIcon(fileName: 'report.pdf')
```

Pass a `size`, a `mimeType` to help detect the category, or a `colorOverride` to
force the band color.

```dart
OiFileIcon(fileName: 'data.xlsx', size: OiFileIconSize.lg)
OiFileIcon(fileName: 'photo.png', colorOverride: context.colors.accent.base)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fileName` | `String` | **required** | The file name. The extension sets the category and label. |
| `mimeType` | `String?` | `null` | Fallback for category detection when the extension is unknown. |
| `size` | `OiFileIconSize` | `md` | `xs`, `sm`, `md`, `lg`, or `xl`. |
| `colorOverride` | `Color?` | `null` | Overrides the band color. |
| `semanticsLabel` | `String?` | `null` | Accessibility label. Defaults to the extension plus "file". |

## OiFolderIcon

A folder icon with open and closed states, color, special variants (shared,
starred, locked, trash), and an optional badge count.

```dart
OiFolderIcon()
```

```dart
OiFolderIcon(state: OiFolderIconState.open)
OiFolderIcon(variant: OiFolderIconVariant.shared, badgeCount: 3)
OiFolderIcon(color: context.colors.primary.base, size: OiFolderIconSize.lg)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `OiFolderIconState` | `closed` | `closed`, `open`, or `empty`. |
| `variant` | `OiFolderIconVariant` | `normal` | `normal`, `shared`, `starred`, `locked`, or `trash`. |
| `size` | `OiFolderIconSize` | `md` | `xs`, `sm`, `md`, `lg`, or `xl`. |
| `color` | `Color?` | `null` | Overrides the folder color. |
| `badgeCount` | `int?` | `null` | Badge count overlay. |
| `semanticsLabel` | `String?` | `null` | Accessibility label. |

## OiFolderTreeItem

One row in a folder tree: a chevron, a folder icon that reflects the folder's
state, the name, and an item count. It picks its icon variant from the folder's
own flags (`shared`, `locked`, `favorite`, `trashed`). `OiFileSidebar` builds
its tree from these, but you can use it directly in a custom tree.

```dart
OiFolderTreeItem(
  folder: const OiFileNodeData(id: 'docs', name: 'Documents', folder: true),
  expanded: true,
  selected: false,
  itemCount: 12,
  onTap: () => _open(),
  onExpand: () => _toggle(),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `folder` | `OiFileNodeData` | **required** | The folder node data. |
| `expanded` | `bool` | **required** | Whether the node is expanded. |
| `selected` | `bool` | **required** | Whether the folder is selected. |
| `dropTarget` | `bool` | `false` | Show the drop highlight. |
| `renaming` | `bool` | `false` | Show the inline rename field. |
| `itemCount` | `int?` | `null` | Count badge on the right. |
| `onTap` | `VoidCallback?` | `null` | Called when the row is tapped. |
| `onExpand` | `VoidCallback?` | `null` | Called when the chevron is tapped. |
| `onRename` | `ValueChanged<String>?` | `null` | Fires with the new name. |
| `onCancelRename` | `VoidCallback?` | `null` | Fires when rename is cancelled. |
| `onDrop` | `ValueChanged<List<OiFileNodeData>>?` | `null` | Fires when files are dropped on the folder. |
| `semanticsLabel` | `String?` | `null` | Accessibility label. |

## OiUploadDialog

A dialog for uploading files. It has a drop zone, a browse button, per-file
progress, size and type validation, and a conflict-resolution choice. Show it
inside an overlay, then call your upload code in `onUpload`.

```dart
OiUploadDialog(
  destinationPath: '/Documents',
  allowedExtensions: const ['pdf', 'png', 'jpg'],
  maxFileSize: 10 * 1024 * 1024,
  onUpload: (files, resolution) => upload(files, resolution),
  onCancel: () => Navigator.of(context).pop(),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `onUpload` | `void Function(List<OiFileData>, OiConflictResolution)` | **required** | Runs the upload with the chosen conflict strategy. |
| `onCancel` | `VoidCallback?` | `null` | Called when the user cancels. |
| `allowedExtensions` | `List<String>?` | `null` | Restrict to these extensions. |
| `maxFileSize` | `int?` | `null` | Max size per file, in bytes. |
| `maxFiles` | `int?` | `null` | Max number of files. |
| `defaultResolution` | `OiConflictResolution` | `ask` | `ask`, `replace`, `skip`, or `rename`. |
| `destinationPath` | `String?` | `null` | Destination path shown for context. |

## OiRenameDialog

A dialog to rename a file or folder. It pre-fills the current name and can
select just the base name, so the extension stays put. Add a `validate`
callback to block bad names.

```dart
OiRenameDialog(
  file: _file,
  onRename: (name) => rename(_file, name),
  onCancel: () => Navigator.of(context).pop(),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `OiFileNodeData` | **required** | The file or folder to rename. |
| `onRename` | `ValueChanged<String>` | **required** | Fires with the new name on confirm. |
| `onCancel` | `VoidCallback?` | `null` | Called when the user cancels. |
| `validate` | `String? Function(String)?` | `null` | Return an error string, or null if the name is valid. |

## OiMoveDialog

A dialog to move or copy items to another folder. It shows the folder tree so
the user can pick a destination. Set `copyMode` to make it a copy instead of a
move.

```dart
OiMoveDialog(
  files: _selectedFiles,
  folderTree: _tree,
  onMove: (destination) => move(_selectedFiles, destination),
  onCancel: () => Navigator.of(context).pop(),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `files` | `List<OiFileNodeData>` | **required** | The items being moved or copied. |
| `folderTree` | `List<OiTreeNode<OiFileNodeData>>` | **required** | Folder hierarchy to choose from. |
| `onMove` | `void Function(OiFileNodeData)` | **required** | Fires with the chosen destination. |
| `onCancel` | `VoidCallback?` | `null` | Called when the user cancels. |
| `copyMode` | `bool` | `false` | Copy instead of move. |
| `loadChildren` | `Future<List<OiTreeNode<OiFileNodeData>>> Function(...)?` | `null` | Lazy loader for child folders. |
| `onCreateFolder` | `ValueChanged<String>?` | `null` | Create a new folder from inside the dialog. |

## OiDeleteDialog

A confirmation dialog for deleting one or more items. By default it reads as a
move to trash. Set `permanent` to make it a hard delete with the stronger
warning.

```dart
OiDeleteDialog(
  files: _selectedFiles,
  onDelete: () => delete(_selectedFiles),
  onCancel: () => Navigator.of(context).pop(),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `files` | `List<OiFileNodeData>` | **required** | The items to delete. |
| `onDelete` | `VoidCallback` | **required** | Called when the user confirms. |
| `onCancel` | `VoidCallback?` | `null` | Called when the user cancels. |
| `showDontAskAgain` | `bool` | `false` | Show a "Don't ask again" checkbox. |
| `onDontAskAgainChange` | `ValueChanged<bool>?` | `null` | Fires when that checkbox changes. |
| `permanent` | `bool` | `false` | Permanent delete instead of trash. |

## OiNewFolderDialog

A dialog to create a folder. It pre-fills a default name and can validate the
input.

```dart
OiNewFolderDialog(
  parentFolderName: 'Documents',
  onCreate: (name) => createFolder(name),
  onCancel: () => Navigator.of(context).pop(),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `onCreate` | `ValueChanged<String>` | **required** | Fires with the folder name on confirm. |
| `onCancel` | `VoidCallback?` | `null` | Called when the user cancels. |
| `defaultName` | `String` | `'New Folder'` | Name pre-filled in the input. |
| `validate` | `String? Function(String)?` | `null` | Return an error string, or null if valid. |
| `parentFolderName` | `String?` | `null` | Parent folder name shown for context. |

## OiFileInfoDialog

A read-only dialog that shows a file's details: name, size, dates, type, and
location. Pass `extraMetadata` to add your own key-value rows.

```dart
OiFileInfoDialog(
  file: _file,
  extraMetadata: const {'Owner': 'Jane Doe', 'Shared with': '3 people'},
  onClose: () => Navigator.of(context).pop(),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `OiFileNodeData` | **required** | The file to describe. |
| `onClose` | `VoidCallback?` | `null` | Called when the dialog is closed. |
| `extraMetadata` | `Map<String, String>?` | `null` | Extra key-value rows to show. |

## OiMediaPicker

A picker for images and files. It offers two sources, a gallery of existing
items and the local file system, and a selection strip along the bottom. You
hold the selected list and update it in `onSelect`.

```dart
OiMediaPicker(
  label: 'Add media',
  allowedTypes: OiMediaType.image,
  maxItems: 5,
  galleryItems: _gallery,
  selected: _selected,
  onSelect: (items) => setState(() => _selected = items),
  onRemove: (item) => setState(() => _selected.remove(item)),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label. |
| `sources` | `List<OiMediaSource>` | `[gallery, files]` | Which tabs to show: `gallery`, `files`. |
| `allowedTypes` | `OiMediaType` | `any` | Filter: `image`, `video`, `document`, or `any`. |
| `maxItems` | `int` | `10` | Max items the user can pick. |
| `maxFileSize` | `int?` | `null` | Max size per file, in bytes. |
| `selected` | `List<OiMediaItem>` | `[]` | The current selection. |
| `onSelect` | `void Function(List<OiMediaItem>)?` | `null` | Fires with the updated selection. |
| `onRemove` | `void Function(OiMediaItem)?` | `null` | Fires when an item is removed. |
| `uploadProgress` | `List<OiMediaUploadProgress>` | `[]` | Per-item upload progress. |
| `galleryItems` | `List<OiMediaItem>` | `[]` | Items shown in the gallery tab. |
| `onLoadMoreGallery` | `Future<void> Function()?` | `null` | Loads the next page of gallery items. |
| `moreGalleryAvailable` | `bool` | `false` | Whether more gallery items can load. |

Each `OiMediaItem` has a `key`, `name`, and optional `thumbnailUrl`,
`thumbnail`, `mimeType`, and `sizeBytes`.

## OiMetadataEditor

An editor for a list of typed key-value fields, like tags, owner, or a due
date. Each field has a `type` that picks the input: text, number, date, boolean,
or select. You own the list and update it in `onChange`.

```dart
OiMetadataEditor(
  label: 'File metadata',
  fields: const [
    OiMetadataField(key: 'Title', value: 'Q3 Report'),
    OiMetadataField(key: 'Pages', value: 24, type: OiMetadataType.number),
    OiMetadataField(key: 'Archived', value: false, type: OiMetadataType.boolean),
  ],
  onChange: (fields) => setState(() => _fields = fields),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fields` | `List<OiMetadataField>` | **required** | The current fields. |
| `onChange` | `ValueChanged<List<OiMetadataField>>` | **required** | Fires with the updated fields. |
| `label` | `String` | **required** | Accessibility label. |
| `enabled` | `bool` | `true` | Set `false` for read-only. |
| `allowAdd` | `bool` | `true` | Allow adding new fields. |
| `allowRemove` | `bool` | `true` | Allow removing fields. |
| `availableKeys` | `List<String>?` | `null` | Restrict new field keys to this set. |

## Full modules

- `OiFileExplorer` is a complete file browser: sidebar, toolbar, grid or list
  view, and the file dialogs, wired together.
- `OiFileManager` is a lighter file view built on `OiFileNode`, with list and
  grid layouts and selection modes.

See [Modules](../modules/files.md) for both.

## Related

- [Modules](../modules/files.md) for `OiFileExplorer` and `OiFileManager`.
- [Media](media.md) for image, video, and audio display.
- [Forms](forms.md) for using `OiFileInput` inside a form.
