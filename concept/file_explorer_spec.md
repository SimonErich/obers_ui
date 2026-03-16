# obers_ui — File Explorer Module Specification

> **Date:** 2026-03-16
> **Extends:** `base_concept.md`
> **Scope:** Tier 2 additions + Tier 4 module for a full-featured file explorer.
> **Replaces:** The existing `OiFileManager` stub in `base_concept.md`.
> **Principle:** Every widget composes from existing obers_ui primitives and components. Zero new rendering primitives.

---

## Table of Contents

- [Overview & Composition Map](#overview--composition-map)
- [New Tier 2 Components](#new-tier-2-components)
  - [OiFileIcon](#oifileicon)
  - [OiFolderIcon](#oifoldericon)
  - [OiFilePreview](#oifilepreview)
  - [OiFileTile](#oifiletile)
  - [OiFileGridCard](#oifilegridcard)
  - [OiPathBar](#oipathbar)
  - [OiStorageIndicator](#oistorageindicator)
  - [OiDropHighlight](#oidrophighlight)
  - [OiSelectionOverlay](#oiselectionoverlay)
  - [OiRenameField](#oirenamefield)
  - [OiFolderTreeItem](#oifoldertreeitem)
- [New Tier 2 Dialogs](#new-tier-2-dialogs)
  - [OiNewFolderDialog](#oinewfolderdialog)
  - [OiRenameDialog](#oirenamedialog)
  - [OiDeleteDialog](#oideletedialog)
  - [OiMoveDialog](#oimovedialog)
  - [OiFileInfoDialog](#oifileinfodialog)
  - [OiUploadDialog](#oiuploaddialog)
- [New Tier 3 Composites](#new-tier-3-composites)
  - [OiFileToolbar](#oifiletoolbar)
  - [OiFileSidebar](#oifilesidebar)
  - [OiFileListView](#oifilelistview)
  - [OiFileGridView](#oifilegridview)
  - [OiFileDropTarget](#oifiledrop-target)
- [New Tier 4 Module](#new-tier-4-module)
  - [OiFileExplorer (replaces OiFileManager)](#oifileexplorer)
- [Data Models](#data-models)
- [Theme Extensions](#theme-extensions)
- [Testing Strategy](#testing-strategy)

---

# Overview & Composition Map

This specification defines a complete file explorer system. The existing `OiFileManager` stub is replaced by `OiFileExplorer` — a full Tier 4 module composed from **11 new Tier 2 components**, **6 dialog widgets**, **5 Tier 3 composites**, and numerous existing obers_ui widgets.

**Design goals:**
1. Feature-complete: navigation, list/grid view, drag-and-drop (within view, within sidebar, between sidebar and view), search-as-you-type, create/rename/delete/move/copy, sort, multi-select, bulk actions, context menus, keyboard shortcuts, file previews, upload, storage indicator.
2. Compositional: every piece is independently usable. `OiFileTile` can be used outside the explorer. `OiFileSidebar` can power a picker dialog. `OiFileGridCard` can be used in a gallery.
3. Accessible: full keyboard navigation, screen reader announcements, focus management in dialogs, drag-and-drop keyboard fallbacks.

```
Composition Tree (new widgets marked with ★)

★ OiFileIcon                       (Tier 2 — display)
★ OiFolderIcon                     (Tier 2 — display)
★ OiFilePreview                    (Tier 2 — display)
★ OiFileTile                       (Tier 2 — display)
★ OiFileGridCard                   (Tier 2 — display)
★ OiPathBar                        (Tier 2 — navigation)
★ OiStorageIndicator               (Tier 2 — display)
★ OiDropHighlight                  (Tier 2 — feedback)
★ OiSelectionOverlay               (Tier 2 — interaction)
★ OiRenameField                    (Tier 2 — input)
★ OiFolderTreeItem                 (Tier 2 — display)

★ OiNewFolderDialog                (Tier 2 — dialog)
★ OiRenameDialog                   (Tier 2 — dialog)
★ OiDeleteDialog                   (Tier 2 — dialog)
★ OiMoveDialog                     (Tier 2 — dialog)
★ OiFileInfoDialog                 (Tier 2 — dialog)
★ OiUploadDialog                   (Tier 2 — dialog)

★ OiFileToolbar                    (Tier 3 — composite)
★ OiFileSidebar                    (Tier 3 — composite)
★ OiFileListView                   (Tier 3 — composite)
★ OiFileGridView                   (Tier 3 — composite)
★ OiFileDropTarget                 (Tier 3 — composite)

★ OiFileExplorer                   (Tier 4 — module, replaces OiFileManager)

Dependency Graph:

OiFileExplorer (Tier 4)
 ├── OiSplitPane           (existing — sidebar | content)
 │    ├── OiFileSidebar     ★ (Tier 3)
 │    │    ├── OiTree        (existing — folder hierarchy)
 │    │    │    └── OiFolderTreeItem  ★
 │    │    │         ├── OiFolderIcon  ★
 │    │    │         ├── OiLabel       (existing)
 │    │    │         ├── OiBadge       (existing — item count)
 │    │    │         └── OiDropZone    (existing — drop target per folder)
 │    │    ├── OiDraggable   (existing — drag folders to reorder/reparent)
 │    │    ├── OiDropZone    (existing — drop files onto folders)
 │    │    ├── OiStorageIndicator ★
 │    │    ├── OiButton.ghost (existing — "New Folder" quick action)
 │    │    └── OiContextMenu (existing — right-click folder actions)
 │    │
 │    └── OiColumn          (existing — toolbar + content area)
 │         ├── OiFileToolbar  ★ (Tier 3)
 │         │    ├── OiPathBar         ★
 │         │    │    ├── OiBreadcrumbs  (existing)
 │         │    │    └── OiTextInput.search (existing — inline path edit)
 │         │    ├── OiTextInput.search (existing — search-as-you-type)
 │         │    ├── OiButtonGroup     (existing — view toggle: list/grid)
 │         │    ├── OiSelect          (existing — sort dropdown)
 │         │    ├── OiButton          (existing — upload, new folder)
 │         │    └── OiIconButton      (existing — view options)
 │         │
 │         └── OiFileDropTarget ★ (Tier 3 — wraps entire content area)
 │              ├── OiDropZone       (existing — native file drop from OS)
 │              ├── OiDropHighlight  ★ (visual feedback)
 │              │
 │              ├── OiFileListView   ★ (Tier 3 — when layout=list)
 │              │    ├── OiVirtualList     (existing)
 │              │    ├── OiFileTile        ★ (each row)
 │              │    │    ├── OiFileIcon    ★
 │              │    │    ├── OiLabel       (existing — name, size, date)
 │              │    │    ├── OiTimestamp   (existing from messaging spec — modified date)
 │              │    │    ├── OiDraggable   (existing — drag files)
 │              │    │    ├── OiDropZone    (existing — drop onto folders)
 │              │    │    ├── OiTappable    (existing — click to open)
 │              │    │    └── OiRenameField ★ (inline rename)
 │              │    ├── OiSelectionOverlay ★ (rubber-band selection)
 │              │    └── _OiFileListHeader (internal — sortable column headers)
 │              │
 │              ├── OiFileGridView   ★ (Tier 3 — when layout=grid)
 │              │    ├── OiVirtualGrid     (existing)
 │              │    ├── OiFileGridCard    ★ (each card)
 │              │    │    ├── OiFilePreview ★ (thumbnail or icon)
 │              │    │    ├── OiLabel       (existing — file name)
 │              │    │    ├── OiCheckbox    (existing — multi-select overlay)
 │              │    │    ├── OiDraggable   (existing)
 │              │    │    ├── OiDropZone    (existing — folders accept drops)
 │              │    │    └── OiRenameField ★
 │              │    └── OiSelectionOverlay ★
 │              │
 │              └── OiEmptyState     (existing — empty folder)
 │
 ├── OiContextMenu          (existing — right-click in content area)
 ├── OiDialog               (existing — hosts all dialog widgets)
 ├── OiShortcuts            (existing — keyboard shortcut handler)
 └── OiToast                (existing — action feedback)
```

---

# New Tier 2 Components

---

## OiFileIcon

**What it is:** A file type icon that shows different visuals based on file extension, MIME type, or a generic fallback. Not a thumbnail — this is a styled iconographic representation (document icon with extension label overlay, like macOS/Windows file icons).

**Composes:** `OiIcon` (base icon shape), `OiLabel` (extension text overlay), `OiSurface` (icon background tint per file type)

```dart
OiFileIcon({
  required String fileName,
  String? mimeType,
  OiFileIconSize size = OiFileIconSize.md,
  Color? colorOverride,
  String? semanticsLabel,
})

enum OiFileIconSize { xs, sm, md, lg, xl }
```

**File type → icon mapping:**

| Category | Extensions | Icon Shape | Color Accent |
|----------|-----------|------------|-------------|
| Document | .pdf | Page with "PDF" label | Red (error.s500) |
| Document | .doc, .docx | Page with "DOC" label | Blue (primary.s500) |
| Spreadsheet | .xls, .xlsx, .csv | Page with grid lines | Green (success.s500) |
| Presentation | .ppt, .pptx | Page with chart | Orange (warning.s500) |
| Image | .png, .jpg, .gif, .svg, .webp | Landscape mountain icon | Teal (accent.s500) |
| Video | .mp4, .mov, .avi, .webm | Film strip icon | Purple |
| Audio | .mp3, .wav, .flac, .ogg | Music note icon | Pink |
| Archive | .zip, .tar, .gz, .rar, .7z | Box with zipper | Brown |
| Code | .dart, .js, .ts, .py, .rs, .go, .html, .css | Angle brackets `</>` | Cyan |
| Text | .txt, .md, .log | Lined page | Gray (neutral.s500) |
| Executable | .exe, .app, .sh, .bat | Gear icon | Dark gray |
| Font | .ttf, .otf, .woff | "Aa" text | Indigo |
| 3D | .obj, .fbx, .gltf | Cube icon | Violet |
| Unknown | * | Blank page | Neutral (neutral.s300) |

**Rendering:**
- Base shape: A rounded-corner page/document outline (not a circle).
- Top-right corner has a "dog-ear" fold effect.
- Extension label (e.g., "PDF") is rendered in bold uppercase at the bottom of the icon, over a colored band matching the category.
- `colorOverride` replaces the category-based accent color.
- Size scale: xs=16px, sm=24px, md=32px, lg=48px, xl=64px.

**Accessibility:**
- `semanticsLabel` defaults to `"$extension file"` (e.g., "PDF file").

**Tests:**

| Test | What it verifies |
|------|-----------------|
| .pdf shows PDF icon with red accent | Correct category mapping |
| .docx shows DOC icon with blue accent | Correct category mapping |
| .png shows image icon with teal accent | Correct category mapping |
| .unknown shows blank page | Fallback |
| All 5 sizes render correct dimensions | Size scale |
| colorOverride replaces category color | Custom color |
| Case-insensitive extension match | .PDF == .pdf |
| mimeType fallback when extension ambiguous | MIME takes precedence |
| Semantics label present | Screen reader |
| Golden: all categories × md size, light + dark | Visual regression |
| Golden: all sizes for .pdf | Visual regression |

---

## OiFolderIcon

**What it is:** A folder icon with open/closed states, color customization, special folder variants (shared, starred, locked), and optional badge overlay.

**Composes:** `OiIcon` (folder shape), `OiBadge.dot` (status overlay), custom `CustomPainter` (folder shape with tab)

```dart
OiFolderIcon({
  OiFolderIconState state = OiFolderIconState.closed,
  OiFolderIconVariant variant = OiFolderIconVariant.normal,
  OiFolderIconSize size = OiFolderIconSize.md,
  Color? color,
  int? badgeCount,
  String? semanticsLabel,
})

enum OiFolderIconState { closed, open, empty }
enum OiFolderIconVariant { normal, shared, starred, locked, trash }
enum OiFolderIconSize { xs, sm, md, lg, xl }
```

**Rendering:**
- **closed:** Classic folder shape — front face with a tab on top-left.
- **open:** Front face tilted slightly, revealing the interior.
- **empty:** Same as closed but with lighter fill and dashed outline.
- Variant overlays: `shared` → small people icon on bottom-right, `starred` → star, `locked` → lock, `trash` → small delete icon.
- Default color: `colors.warning.s400` (classic folder yellow-amber). `color` overrides.
- Animated transition between open/closed when state changes (folder "opens" with a 150ms rotation tween).

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Closed state renders classic folder | Correct shape |
| Open state renders tilted folder | Correct shape |
| Empty state renders dashed folder | Dashed outline, light fill |
| shared variant shows people overlay | Overlay icon |
| starred variant shows star overlay | Overlay icon |
| locked variant shows lock overlay | Overlay icon |
| trash variant shows delete overlay | Overlay icon |
| Custom color overrides default | Color applied |
| badgeCount shows badge | OiBadge overlay |
| State transition animates | 150ms rotation |
| Reduced motion: instant swap | No animation |
| All sizes render correctly | Dimension check |
| Semantics: "folder" / "shared folder" / etc. | Screen reader |
| Golden: all states × all variants, light + dark | Visual regression |

---

## OiFilePreview

**What it is:** A thumbnail preview of a file. Shows an actual image thumbnail for image/video files, a rich preview for PDFs/documents (first-page render), and falls back to `OiFileIcon` for unsupported types.

**Composes:** `OiImage` (thumbnails), `OiFileIcon` (fallback), `OiShimmer` (loading state), `OiSurface` (frame), `OiIcon` (play button overlay for video)

```dart
OiFilePreview({
  required OiFileNodeData file,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  bool showPlayButton = true,
  bool loading = false,
  String? semanticsLabel,
})
```

**Preview chain:**
1. If `file.thumbnailUrl` is set → load image via `OiImage`.
2. If file is an image type and `file.url` is set → load `OiImage` with the file URL directly.
3. If file is a video → load thumbnail (if available) with play button overlay.
4. Else → render `OiFileIcon` centered in the frame at `lg` size.

**Loading:** When `loading=true` or image is loading, show `OiShimmer` rectangle.

**Error:** If image fails to load, gracefully fall back to `OiFileIcon`.

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Image file shows thumbnail | OiImage rendered |
| Video file shows thumbnail + play button | Play overlay visible |
| PDF falls back to OiFileIcon | Icon fallback |
| Unknown file shows OiFileIcon | Icon fallback |
| Loading shows shimmer | OiShimmer visible |
| Image error falls back to icon | Graceful degradation |
| Custom width/height applied | Dimensions correct |
| fit=cover crops correctly | BoxFit applied |
| Semantics label present | Screen reader |
| Golden: image preview, icon fallback, loading | Visual regression |

---

## OiFileTile

**What it is:** A single row in the list view layout of the file explorer. Shows file/folder icon, name (editable), size, modified date, and optional metadata columns. Supports selection, drag-and-drop, hover effects, and context menu.

**Composes:** `OiTappable` (row interaction), `OiDraggable` (drag source), `OiDropZone` (folder rows accept drops), `OiFileIcon` / `OiFolderIcon` (leading icon), `OiLabel` (name, size, date), `OiTimestamp` (modified time), `OiCheckbox` (selection indicator), `OiRenameField` (inline rename), `OiContextMenu` (right-click), `OiSurface` (row background for states)

```dart
OiFileTile({
  required OiFileNodeData file,
  required bool selected,
  bool renaming = false,
  bool dropTarget = false,
  bool dragSource = false,
  bool showCheckbox = false,
  // Columns
  bool showSize = true,
  bool showModified = true,
  bool showType = true,
  List<OiFileColumnDef>? extraColumns,
  // Callbacks
  VoidCallback? onTap,
  VoidCallback? onDoubleTap,
  ValueChanged<bool>? onSelect,
  ValueChanged<String>? onRename,
  VoidCallback? onCancelRename,
  VoidCallback? onContextMenu,
  // Drag & drop
  VoidCallback? onDragStart,
  ValueChanged<List<OiFileNodeData>>? onDrop,
  bool Function(List<OiFileNodeData>)? canAcceptDrop,
  String? semanticsLabel,
})
```

**Layout:**
```
┌────────────────────────────────────────────────────────────────────────┐
│  ☐  📄 report-q3-final.pdf              2.4 MB    Mar 15, 2026  PDF  │
│  ☑  📁 Design Assets                     —        Mar 14, 2026  —    │  ← selected, folder
│     📄 ┌──────────────────────────────┐   —        Mar 14, 2026  —    │  ← renaming mode
│        │ new-filename.txt          [✓]│                               │
│        └──────────────────────────────┘                               │
└────────────────────────────────────────────────────────────────────────┘
```

**States:**
- **Default:** Normal row.
- **Hover:** Subtle background tint (`colors.surface.s100`). Row actions (context menu dots) appear on trailing edge.
- **Selected:** Stronger background tint (`colors.primary.s100`). Checkbox checked.
- **Focused:** Focus ring around the row.
- **Drop target (folder):** When files are dragged over a folder row, the row shows `OiDropHighlight` with a border glow and accepts the drop.
- **Dragging:** Row becomes semi-transparent (0.5 opacity). `OiDragGhost` shows a badge with count when multi-dragging.
- **Renaming:** Name column switches to `OiRenameField` with the current name selected.

**Double-tap/Enter behavior:**
- Folder → navigates into folder (fires `onTap` or `onDoubleTap` — consumer decides).
- File → opens the file (fires `onDoubleTap` or `onTap`).

**Size formatting:**
- Bytes: "1.2 KB", "3.4 MB", "1.1 GB", "—" for folders.

**Tests:**

| Test | What it verifies |
|------|-----------------|
| File renders with OiFileIcon, name, size, date, type | Core layout |
| Folder renders with OiFolderIcon, name, no size | Folder layout |
| Hover shows background tint | Hover state |
| Hover shows trailing action dots | Action visibility |
| Selected shows checkbox checked + tint | Selection state |
| onSelect fires when checkbox toggled | Callback |
| onTap fires on click | Callback |
| onDoubleTap fires on double-click | Callback |
| renaming=true shows OiRenameField | Inline rename |
| onRename fires with new name | Callback |
| onCancelRename fires on Escape | Callback |
| Drag starts on long-press/mouse-drag | OiDraggable activates |
| Folder row accepts drops when canAcceptDrop returns true | OiDropZone |
| Folder row shows drop highlight on drag-over | OiDropHighlight |
| onDrop fires with dropped files | Callback |
| Non-folder row does not accept drops | No drop zone |
| Context menu on right-click | OiContextMenu |
| Extra columns render | Custom columns |
| Size formatted correctly | "2.4 MB" |
| Keyboard: Enter opens, F2 renames | Keyboard shortcuts |
| Keyboard: Space toggles selection | Selection toggle |
| Semantics: file name and type announced | Screen reader |
| Golden: default, hover, selected, renaming, drop-target | Visual regression |

---

## OiFileGridCard

**What it is:** A single card in the grid view layout of the file explorer. Shows a thumbnail/preview area on top and the file name below. Supports selection, drag-and-drop, hover effects, and inline rename.

**Composes:** `OiSurface` (card background), `OiTappable` (interaction), `OiFilePreview` (thumbnail area), `OiFolderIcon` (folder variant), `OiLabel` (file name), `OiCheckbox` (selection overlay in top-left corner), `OiDraggable`, `OiDropZone` (folders), `OiRenameField` (inline rename below preview), `OiContextMenu`

```dart
OiFileGridCard({
  required OiFileNodeData file,
  required bool selected,
  bool renaming = false,
  bool dropTarget = false,
  bool showCheckbox = false,
  // Callbacks (same as OiFileTile)
  VoidCallback? onTap,
  VoidCallback? onDoubleTap,
  ValueChanged<bool>? onSelect,
  ValueChanged<String>? onRename,
  VoidCallback? onCancelRename,
  VoidCallback? onContextMenu,
  ValueChanged<List<OiFileNodeData>>? onDrop,
  bool Function(List<OiFileNodeData>)? canAcceptDrop,
  String? semanticsLabel,
})
```

**Layout:**
```
File card:                    Folder card:
┌────────────────────┐        ┌────────────────────┐
│                    │        │                    │
│  ☑ (select)        │        │                    │
│     ┌──────────┐   │        │     ┌──────────┐   │
│     │ Thumbnail│   │        │     │  📁      │   │
│     │  Preview │   │        │     │  (large) │   │
│     └──────────┘   │        │     └──────────┘   │
│                    │        │                    │
│  report-q3.pdf     │        │  Design Assets     │
│  2.4 MB            │        │  12 items           │
└────────────────────┘        └────────────────────┘

Renaming:
┌────────────────────┐
│     ┌──────────┐   │
│     │ Thumbnail│   │
│     └──────────┘   │
│  ┌──────────────┐  │
│  │ new-name  [✓]│  │
│  └──────────────┘  │
└────────────────────┘
```

**States:**
- **Default:** Flat card with subtle border.
- **Hover:** Elevated shadow (`shadow.sm`), border becomes `primary.s300`.
- **Selected:** Primary tint background (`primary.s50`), checkbox visible and checked, border becomes `primary.s500`.
- **Multi-select mode:** All cards show checkboxes (even unselected). Triggered when any card is selected.
- **Focused:** Focus ring around card.
- **Drop target (folder):** Border pulses with `primary.s400`, background tints.
- **Dragging:** 0.5 opacity, ghost shows card thumbnail + count badge.

**Folder cards:**
- Show `OiFolderIcon` (size `xl`) instead of `OiFilePreview`.
- Subtitle shows item count: "12 items" or "Empty".
- Accept drops: when files are dragged over, show drop highlight.

**Tests:**

| Test | What it verifies |
|------|-----------------|
| File card shows preview and name | Core layout |
| Folder card shows OiFolderIcon and item count | Folder layout |
| Hover elevates card | Shadow + border change |
| Selected shows checkbox and tint | Selection state |
| showCheckbox in multi-select mode | All checkboxes visible |
| Double-tap opens | onDoubleTap fires |
| Rename mode shows OiRenameField | Inline rename |
| onRename fires | Callback |
| Drag file card | OiDraggable activates |
| Drop onto folder card | OiDropZone accepts |
| Drop highlight on folder hover | Visual feedback |
| Context menu on right-click | OiContextMenu |
| Keyboard: Enter opens, F2 renames, Space selects | Shortcuts |
| Semantics: file name, type, size | Screen reader |
| Golden: file, folder, hover, selected, renaming, drop-target | Visual regression |

---

## OiPathBar

**What it is:** A dual-mode path navigation bar. In **breadcrumb mode**, shows clickable path segments. In **edit mode** (activated by click or keyboard shortcut), shows a text input where the user can type or paste a path directly. Combines `OiBreadcrumbs` with an inline path editor.

**Composes:** `OiBreadcrumbs` (breadcrumb display), `OiTextInput` (path editing), `OiTappable` (click to switch to edit mode), `OiMorph` (crossfade between modes), `OiIcon` (folder icon prefix)

```dart
OiPathBar({
  required List<OiPathSegment> segments,
  required ValueChanged<OiPathSegment> onNavigate,
  ValueChanged<String>? onPathSubmit,
  bool editable = true,
  bool showIcon = true,
  String? semanticsLabel,
})

class OiPathSegment {
  final String id;
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
}
```

**Behavior:**
- Default: `OiBreadcrumbs` with `OiPathSegment` items. Last segment is current folder (non-clickable, bold).
- Click on the breadcrumb area (not on a segment) or press `/` or `Ctrl+L` → switches to edit mode.
- Edit mode: Full path string in a `OiTextInput`, auto-selected. Type a new path and press Enter → fires `onPathSubmit`. Escape → reverts to breadcrumb mode.
- Deep paths collapse middle segments (via `OiBreadcrumbs.collapsible`).
- First segment optionally shows a folder/home icon via `showIcon`.

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Segments render as breadcrumbs | Correct display |
| Click on segment fires onNavigate | Callback |
| Last segment is non-clickable and bold | Current folder |
| Click on background enters edit mode | OiTextInput visible |
| Ctrl+L enters edit mode | Keyboard shortcut |
| Edit mode shows full path | Path string |
| Enter in edit submits path | onPathSubmit fires |
| Escape exits edit mode | Breadcrumbs restored |
| Deep paths collapse middle | "..." menu works |
| showIcon renders folder icon | Icon visible |
| Semantics: navigation breadcrumb | Screen reader |
| Golden: breadcrumb mode, edit mode, collapsed | Visual regression |

---

## OiStorageIndicator

**What it is:** A compact storage usage indicator showing used/total space with a progress bar and breakdown by category.

**Composes:** `OiProgress.linear` (usage bar), `OiLabel` (usage text), `OiTooltip` (breakdown on hover)

```dart
OiStorageIndicator({
  required int usedBytes,
  required int totalBytes,
  List<OiStorageCategory>? breakdown,
  bool compact = false,
  String? semanticsLabel,
})

class OiStorageCategory {
  final String label;
  final int bytes;
  final Color color;
}
```

**Layout:**
```
Default:
┌──────────────────────────────────┐
│  Storage                         │
│  ████████████░░░░░░ 65% used     │
│  6.5 GB of 10 GB                 │
└──────────────────────────────────┘

Compact:
████████████░░░░░░ 6.5 / 10 GB
```

- Progress bar color shifts from green → yellow → red as usage increases (< 70% → success, 70-90% → warning, > 90% → error).
- `breakdown` renders as a segmented/stacked progress bar where each category gets its own color slice.
- Tooltip (on hover) shows the breakdown: "Documents: 2.1 GB, Images: 3.2 GB, Other: 1.2 GB".

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Progress bar at correct percentage | 65% filled |
| Usage text correct | "6.5 GB of 10 GB" |
| Color green when < 70% | Success color |
| Color yellow when 70-90% | Warning color |
| Color red when > 90% | Error color |
| Breakdown renders segmented bar | Category colors |
| Tooltip shows breakdown | Hover detail |
| Compact mode renders inline | Reduced layout |
| Zero usage shows empty bar | Edge case |
| Full usage shows full bar | Edge case |
| Semantics: usage announced | Screen reader |
| Golden: low/medium/high usage, with breakdown | Visual regression |

---

## OiDropHighlight

**What it is:** A visual overlay that indicates a valid drop target. Renders a dashed border + background tint + centered label ("Drop files here" / "Move to folder"). Used by `OiFileDropTarget`, `OiFileTile`, `OiFileGridCard`, and `OiFolderTreeItem`.

**Composes:** `OiSurface` (background tint), `CustomPainter` (dashed border), `OiLabel` (message), `OiIcon` (upload/move icon)

```dart
OiDropHighlight({
  required bool active,
  OiDropHighlightStyle style = OiDropHighlightStyle.area,
  String? message,
  IconData? icon,
  Widget? child,
})

enum OiDropHighlightStyle {
  /// Full-area overlay with dashed border and centered message.
  area,
  /// Subtle border glow around a widget (used on folder rows/cards).
  border,
}
```

**Behavior:**
- `active=true` renders the highlight with a fade-in animation (100ms).
- `active=false` renders nothing (or child only).
- `area` style: Dashed border around the entire widget area, semi-transparent background tint (`primary.s50` at 0.5 opacity), centered icon + message.
- `border` style: Solid glowing border around the child (2px `primary.s500` with `OiHaloStyle`), subtle background tint. No message.

**Tests:**

| Test | What it verifies |
|------|-----------------|
| active=true shows overlay | Visible |
| active=false shows nothing | Hidden |
| area style has dashed border + message | Full overlay |
| border style has glow border | Subtle highlight |
| Fade-in animation | 100ms transition |
| Custom message displayed | Label text |
| Custom icon displayed | Icon visible |
| Reduced motion: instant show | No animation |
| Golden: area + border styles, light + dark | Visual regression |

---

## OiSelectionOverlay

**What it is:** A rubber-band (lasso) selection overlay that lets users click-and-drag on empty space to select multiple files by drawing a rectangle. Items whose bounds intersect the rectangle get selected.

**Composes:** `GestureDetector` (drag tracking), `CustomPainter` (rubber-band rectangle), callback to parent with selected bounds

```dart
OiSelectionOverlay({
  required Widget child,
  required ValueChanged<Rect> onSelectionRect,
  required VoidCallback onSelectionStart,
  required VoidCallback onSelectionEnd,
  bool enabled = true,
  Color? selectionColor,
  Color? borderColor,
})
```

**Behavior:**
- User clicks on empty space (not on a file item) and drags → semi-transparent rectangle drawn from start to current mouse position.
- `onSelectionRect` fires continuously during drag with the current rectangle.
- Parent widget (OiFileListView/OiFileGridView) calculates which items intersect and updates selection.
- Selection rectangle: `primary.s200` at 0.3 opacity fill, `primary.s500` at 1.0 border.
- `enabled=false` disables (e.g., when dragging a file instead of selecting).
- Does NOT fire when drag starts on a file item — only on empty space.

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Click-drag on empty space draws rectangle | Rectangle visible |
| onSelectionRect fires with correct bounds | Callback data |
| onSelectionStart fires at drag start | Callback |
| onSelectionEnd fires at drag end | Callback |
| Click on file item does not trigger | No false activation |
| enabled=false prevents selection | Disabled state |
| Custom colors applied | Color overrides |
| Golden: selection rectangle | Visual regression |

---

## OiRenameField

**What it is:** A specialized inline text input for renaming files/folders. Auto-selects the filename (without extension) on mount, validates against illegal characters, and fires save/cancel callbacks.

**Composes:** `OiTextInput` (input field), `OiIconButton` (confirm/cancel buttons)

```dart
OiRenameField({
  required String currentName,
  required ValueChanged<String> onRename,
  required VoidCallback onCancel,
  bool isFolder = false,
  String? Function(String)? validate,
  bool showButtons = false,
  String? semanticsLabel,
})
```

**Behavior:**
- On mount: auto-focus the input. If the file has an extension and `isFolder=false`, select only the name part (e.g., "report" selected in "report.pdf"). If `isFolder=true`, select all.
- **Enter** → fires `onRename` with the new name (if valid).
- **Escape** → fires `onCancel`.
- **Blur** → fires `onRename` (save on blur, consistent with `OiEditable`).
- Built-in validation: rejects empty names, names with `/`, `\`, `:`, `*`, `?`, `"`, `<`, `>`, `|`. Shows inline error.
- `validate` callback adds custom validation (e.g., duplicate name check).
- `showButtons=true` renders small confirm (✓) and cancel (✕) buttons after the input.

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Auto-focuses on mount | Input focused |
| Selects filename without extension | "report" selected in "report.pdf" |
| Folder mode selects entire name | All text selected |
| Enter fires onRename | Callback with new name |
| Escape fires onCancel | Callback |
| Blur fires onRename | Save on blur |
| Empty name shows error | Validation |
| Illegal characters show error | "/" etc. rejected |
| Custom validate function | Error from callback |
| showButtons renders confirm/cancel | Buttons visible |
| Semantics: "Rename file" | Screen reader |
| Golden: normal, with error | Visual regression |

---

## OiFolderTreeItem

**What it is:** A specialized tree node widget for the folder sidebar. Shows folder icon (with open/closed state), folder name, item count badge, and acts as a drop target. Used inside `OiTree` in the `OiFileSidebar`.

**Composes:** `OiFolderIcon` (leading), `OiLabel` (folder name), `OiBadge` (item count), `OiDropZone` (accept file drops), `OiDropHighlight` (drop feedback), `OiContextMenu` (right-click), `OiRenameField` (inline rename)

```dart
OiFolderTreeItem({
  required OiFileNodeData folder,
  required bool expanded,
  required bool selected,
  bool dropTarget = false,
  bool renaming = false,
  int? itemCount,
  // Callbacks
  VoidCallback? onTap,
  VoidCallback? onExpand,
  ValueChanged<String>? onRename,
  VoidCallback? onCancelRename,
  ValueChanged<List<OiFileNodeData>>? onDrop,
  List<OiMenuItem> Function()? contextMenuItems,
  String? semanticsLabel,
})
```

**Layout:**
```
▶ 📁 Documents (42)
▼ 📂 Design Assets (12)         ← expanded, open icon
    ▶ 📁 Logos (5)
    ▶ 📁 Mockups (7)
  📁̃ ┌──────────────────┐       ← renaming
      │ New name      [✓]│
      └──────────────────┘
```

**States:**
- **Default:** `OiFolderIcon(state: closed)`, name, optional count.
- **Expanded:** `OiFolderIcon(state: open)`, children visible.
- **Selected:** Background tint (`primary.s100`), bold name.
- **Drop target:** `OiDropHighlight.border` around the item — glowing border.
- **Renaming:** Name replaced by `OiRenameField`.

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Renders folder icon, name, count | Core layout |
| Expanded shows open folder icon | OiFolderIcon state=open |
| Selected shows tint and bold | Selection style |
| Drop target shows glow border | OiDropHighlight |
| onDrop fires when files dropped | Callback |
| Renaming shows OiRenameField | Inline rename |
| Context menu on right-click | Items appear |
| onTap fires on click | Callback |
| onExpand fires on chevron click | Callback |
| Semantics: "Documents folder, 42 items" | Screen reader |
| Golden: default, expanded, selected, drop-target | Visual regression |

---

# New Tier 2 Dialogs

All dialogs are rendered via `OiOverlays.of(context).dialog(...)`. Each is a self-contained widget that handles its own validation and callbacks. All trap focus, dismiss on ESC (when appropriate), and are fully keyboard-navigable.

---

## OiNewFolderDialog

**What it is:** A dialog for creating a new folder. Contains a single text input for the folder name with validation.

**Composes:** `OiDialog` (shell), `OiTextInput` (name input), `OiButton` (create/cancel), `OiFolderIcon` (visual)

```dart
OiNewFolderDialog({
  required ValueChanged<String> onCreate,
  VoidCallback? onCancel,
  String defaultName = 'New Folder',
  String? Function(String)? validate,
  String? parentFolderName,
})
```

**Layout:**
```
┌────────────────────────────────────┐
│  📁 New Folder                     │
│                                    │
│  Parent: Documents                 │  ← optional context
│                                    │
│  Folder name                       │
│  ┌──────────────────────────────┐  │
│  │ New Folder                   │  │  ← auto-focused, text selected
│  └──────────────────────────────┘  │
│  ⚠ A folder with this name        │  ← validation error
│    already exists.                 │
│                                    │
│              [Cancel]   [Create]   │
└────────────────────────────────────┘
```

**Behavior:**
- On open: input auto-focused, `defaultName` pre-filled and fully selected.
- **Enter** → create (if valid).
- **Escape** → cancel.
- Built-in validation: non-empty, no illegal characters. `validate` adds custom checks (e.g., duplicate name).
- "Create" button disabled when validation fails.

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Opens with default name selected | Auto-focus + selection |
| Create button fires onCreate | Callback with name |
| Cancel button fires onCancel | Dialog closes |
| Enter key creates | Keyboard shortcut |
| Escape key cancels | Keyboard shortcut |
| Empty name disables Create | Validation |
| Illegal chars show error | Built-in validation |
| Custom validate shows error | Custom validation |
| parentFolderName shown as context | Context label |
| Focus trapped in dialog | OiFocusTrap |
| Semantics: dialog role | Screen reader |

---

## OiRenameDialog

**What it is:** A dialog for renaming a file or folder. Pre-fills the current name with the filename portion selected (not extension).

**Composes:** `OiDialog`, `OiTextInput`, `OiButton`, `OiFileIcon` / `OiFolderIcon` (visual of what's being renamed)

```dart
OiRenameDialog({
  required OiFileNodeData file,
  required ValueChanged<String> onRename,
  VoidCallback? onCancel,
  String? Function(String)? validate,
})
```

**Behavior:**
- Same as `OiRenameField` selection logic (select name, not extension).
- Shows the file/folder icon next to the current name for context.
- "Rename" button disabled when invalid or unchanged.

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Pre-fills current name | Name in input |
| Selects name without extension | Partial selection |
| Folder selects entire name | Full selection |
| Rename fires onRename | Callback |
| Unchanged name disables Rename | No-op prevention |
| Validation errors shown | Error messages |
| File icon/folder icon shown | Visual context |
| Keyboard: Enter renames, Escape cancels | Shortcuts |

---

## OiDeleteDialog

**What it is:** A confirmation dialog for deleting files/folders. Shows what will be deleted, warns about folder contents, and has a destructive action button.

**Composes:** `OiDialog`, `OiButton` (delete — destructive, cancel), `OiLabel`, `OiFileIcon` / `OiFolderIcon`, `OiCheckbox` (optional "Don't ask again")

```dart
OiDeleteDialog({
  required List<OiFileNodeData> files,
  required VoidCallback onDelete,
  VoidCallback? onCancel,
  bool showDontAskAgain = false,
  ValueChanged<bool>? onDontAskAgainChange,
  bool permanent = false,
})
```

**Layout:**
```
┌────────────────────────────────────────────┐
│  🗑️ Delete 3 items?                        │
│                                            │
│  📄 report-q3.pdf                          │
│  📁 Design Assets (12 items inside)        │  ← warns about contents
│  📄 notes.txt                              │
│                                            │
│  ⚠ This action cannot be undone.           │  ← when permanent=true
│                                            │
│  ☐ Don't ask me again                      │  ← optional
│                                            │
│              [Cancel]   [Delete]            │  ← Delete is red/destructive
└────────────────────────────────────────────┘
```

**Behavior:**
- Single file: "Delete report-q3.pdf?"
- Multiple files: "Delete 3 items?"
- Folder: warns about contents — "Design Assets (12 items inside)".
- `permanent=true` shows a warning that the action is irreversible (vs. "Move to Trash").
- Delete button is destructive (red).
- `showDontAskAgain` shows a checkbox that fires `onDontAskAgainChange`.

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Single file shows name | Correct title |
| Multiple files shows count | "Delete 3 items?" |
| Folder shows content count | "12 items inside" |
| permanent=true shows warning | Warning label |
| Delete button fires onDelete | Callback |
| Cancel button fires onCancel | Callback |
| Delete button is destructive style | Red color |
| "Don't ask again" checkbox works | Callback fires |
| Escape cancels | Keyboard shortcut |
| Focus on Cancel by default (not Delete) | Safe default |
| Semantics: alertdialog role | Screen reader |

---

## OiMoveDialog

**What it is:** A dialog for moving/copying files to a different folder. Shows a folder tree for destination selection.

**Composes:** `OiDialog`, `OiTree` (folder tree), `OiFolderTreeItem` (tree nodes), `OiButton` (move/copy/cancel), `OiTextInput.search` (search folders), `OiButton.ghost` ("New Folder" inline)

```dart
OiMoveDialog({
  required List<OiFileNodeData> files,
  required List<OiTreeNode<OiFileNodeData>> folderTree,
  required void Function(OiFileNodeData destination) onMove,
  VoidCallback? onCancel,
  bool copyMode = false,
  Future<List<OiTreeNode<OiFileNodeData>>> Function(OiTreeNode<OiFileNodeData>)? loadChildren,
  ValueChanged<String>? onCreateFolder,
})
```

**Layout:**
```
┌──────────────────────────────────────────┐
│  Move 3 items to...                      │  ← or "Copy 3 items to..."
│                                          │
│  ┌──────────────────────────────────┐    │
│  │ 🔍 Search folders                │    │
│  └──────────────────────────────────┘    │
│                                          │
│  📁 Home                                 │
│  ▼ 📂 Documents                          │
│      📁 Reports         ← selected       │  ← highlighted destination
│      📁 Archive                          │
│  ▶ 📁 Photos                             │
│  ▶ 📁 Design Assets                      │
│                                          │
│  [+ New Folder]                          │
│                                          │
│  Moving to: Documents / Reports          │  ← confirms destination
│                                          │
│              [Cancel]      [Move here]   │
└──────────────────────────────────────────┘
```

**Behavior:**
- Folder tree with expand/collapse. Lazy loading via `loadChildren`.
- Search input filters the tree (highlights matching folders, auto-expands parents).
- Selected folder is highlighted. "Move here" / "Copy here" button shows the destination path.
- "Move here" disabled until a destination is selected.
- Prevents moving a folder into itself or its descendants (grayed out + tooltip explaining why).
- "New Folder" button creates a folder inside the selected destination (inline via tree).
- `copyMode=true` changes labels to "Copy" instead of "Move".

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Folder tree renders | All folders visible |
| Expand/collapse works | Children shown/hidden |
| Select folder highlights it | Visual feedback |
| Move button shows destination | "Moving to: path" |
| Move fires onMove with destination | Callback |
| Move disabled when no selection | Button disabled |
| Self-move prevented | Folder grayed out |
| Descendant-move prevented | Sub-folders grayed out |
| Search filters tree | Matching folders visible |
| Search auto-expands parents | Parents expanded |
| New Folder button fires onCreateFolder | Callback |
| Copy mode changes labels | "Copy here" text |
| Lazy loading via loadChildren | Loading shimmer |
| Keyboard: arrows navigate tree | Focus management |
| Semantics: dialog with tree | Screen reader |

---

## OiFileInfoDialog

**What it is:** A dialog showing detailed metadata about a file or folder: name, type, size, location, created/modified dates, dimensions (images), duration (video/audio), and custom metadata.

**Composes:** `OiDialog`, `OiFilePreview` / `OiFileIcon` (header visual), `OiLabel`, `OiTimestamp`, `OiDivider`, `OiCopyable` (copy path)

```dart
OiFileInfoDialog({
  required OiFileNodeData file,
  VoidCallback? onClose,
  Map<String, String>? extraMetadata,
})
```

**Layout:**
```
┌──────────────────────────────────────────┐
│  ┌──────────────┐                        │
│  │              │  report-q3-final.pdf    │
│  │   Preview    │  PDF Document           │
│  │              │                        │
│  └──────────────┘                        │
│  ─────────────────────────────────────── │
│  Size          2.4 MB                    │
│  Location      /Documents/Reports   📋   │  ← copyable
│  Created       March 10, 2026 at 09:15   │
│  Modified      March 15, 2026 at 14:32   │
│  ─────────────────────────────────────── │
│  Pages         24                        │  ← type-specific
│  ─────────────────────────────────────── │
│  Tags          Q3, Finance, Report       │  ← custom metadata
│                                          │
│                              [Close]     │
└──────────────────────────────────────────┘
```

**Type-specific metadata:**
- **Image:** Dimensions (width × height), color space, DPI.
- **Video:** Duration, resolution, codec, frame rate.
- **Audio:** Duration, bitrate, sample rate, channels.
- **Folder:** Item count, total size of contents.
- **All:** Name, type, size, location, created, modified.

**Tests:**

| Test | What it verifies |
|------|-----------------|
| File info renders all standard fields | Name, type, size, dates |
| Location is copyable | OiCopyable wraps path |
| Image shows dimensions | Width × height |
| Video shows duration | Duration field |
| Folder shows item count and total size | Folder-specific |
| extraMetadata renders custom fields | Custom key-value pairs |
| Preview shows for image files | OiFilePreview |
| Icon shows for non-image files | OiFileIcon |
| Close button works | Dialog closes |
| Semantics: all fields labeled | Screen reader |

---

## OiUploadDialog

**What it is:** A dialog for uploading files with a drop zone, progress tracking per file, conflict resolution (replace/skip/rename), and batch controls.

**Composes:** `OiDialog`, `OiFileInput` (drop zone + file picker), `OiProgress.linear` (per-file progress), `OiLabel`, `OiFileIcon`, `OiIconButton` (cancel per-file), `OiButton` (upload all / cancel all), `OiSelect` (conflict resolution)

```dart
OiUploadDialog({
  required void Function(List<OiFileData> files, OiConflictResolution resolution) onUpload,
  VoidCallback? onCancel,
  List<String>? allowedExtensions,
  int? maxFileSize,
  int? maxFiles,
  OiConflictResolution defaultResolution = OiConflictResolution.ask,
  String? destinationPath,
})

enum OiConflictResolution {
  /// Ask for each conflict individually.
  ask,
  /// Replace existing files silently.
  replace,
  /// Skip files that already exist.
  skip,
  /// Auto-rename with suffix: "file (1).txt".
  rename,
}
```

**Layout:**
```
┌──────────────────────────────────────────────┐
│  Upload to: /Documents/Reports               │
│                                              │
│  ┌──────────────────────────────────────┐    │
│  │                                      │    │
│  │     📤 Drop files here or browse     │    │  ← OiFileInput drop zone
│  │                                      │    │
│  └──────────────────────────────────────┘    │
│                                              │
│  Files to upload:                            │
│  📄 report-q3.pdf     2.4 MB   ████░░ 60%  ✕│  ← per-file progress
│  📄 notes.txt         12 KB    ██████ Done  ✓│
│  📄 data.csv          ⚠ Exceeds 10 MB limit  │  ← validation error
│                                              │
│  If file exists: [Replace ▾]                 │  ← conflict resolution
│                                              │
│              [Cancel]      [Upload 2 files]  │
└──────────────────────────────────────────────┘
```

**Behavior:**
- Files added via drop or browse button.
- Each file shows icon, name, size, progress bar, and cancel (✕) button.
- Files exceeding `maxFileSize` show an error and are excluded from upload.
- Files with disallowed extensions show an error and are excluded.
- `maxFiles` limits the total count — excess files show a warning.
- Conflict resolution dropdown: ask/replace/skip/rename.
- "Upload" button shows the count of valid files. Disabled when no valid files.
- Upload progress is managed by the consumer — the dialog fires `onUpload` and receives progress updates via the file list.

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Drop zone accepts files | Files added to list |
| Browse button opens picker | File picker triggered |
| Per-file progress renders | Progress bar visible |
| Cancel per-file removes it | File removed from list |
| maxFileSize enforced | Error on oversized file |
| allowedExtensions enforced | Error on wrong extension |
| maxFiles enforced | Warning on excess |
| Conflict resolution dropdown works | Value changes |
| Upload button shows valid count | "Upload 2 files" |
| Upload disabled when no valid files | Button disabled |
| onUpload fires with valid files + resolution | Callback |
| Cancel closes dialog | onCancel fires |
| Destination path shown | Context label |
| Semantics: upload dialog | Screen reader |

---

# New Tier 3 Composites

---

## OiFileToolbar

**What it is:** The toolbar above the file content area. Contains the path bar, search input, view toggle (list/grid), sort dropdown, and action buttons (upload, new folder, etc.). Contextually shows selection actions when files are selected.

**Composes:** `OiPathBar` (navigation), `OiTextInput.search` (search-as-you-type), `OiButtonGroup` (list/grid toggle), `OiSelect` (sort), `OiButton` (upload, new folder), `OiIconButton` (refresh, info), `OiDivider` (separator), `OiLabel` (selection count)

```dart
OiFileToolbar({
  required List<OiPathSegment> pathSegments,
  required ValueChanged<OiPathSegment> onNavigate,
  // Search
  String? searchQuery,
  ValueChanged<String>? onSearch,
  bool searchActive = false,
  VoidCallback? onSearchToggle,
  // View
  OiFileViewMode viewMode = OiFileViewMode.list,
  ValueChanged<OiFileViewMode>? onViewModeChange,
  // Sort
  OiFileSortField sortField = OiFileSortField.name,
  OiSortDirection sortDirection = OiSortDirection.ascending,
  ValueChanged<OiFileSortField>? onSortFieldChange,
  ValueChanged<OiSortDirection>? onSortDirectionChange,
  // Actions
  VoidCallback? onNewFolder,
  VoidCallback? onUpload,
  VoidCallback? onRefresh,
  // Selection
  int selectedCount = 0,
  VoidCallback? onDeleteSelected,
  VoidCallback? onMoveSelected,
  VoidCallback? onCopySelected,
  VoidCallback? onDownloadSelected,
  VoidCallback? onClearSelection,
  // Custom
  List<Widget>? extraActions,
  String? semanticsLabel,
})

enum OiFileViewMode { list, grid }
enum OiFileSortField { name, size, modified, type }
enum OiSortDirection { ascending, descending }
```

**Layout (default):**
```
┌──────────────────────────────────────────────────────────────────────────┐
│  📁 Home / Documents / Reports     🔍  │  ≡ ⊞  │  Sort: Name ▴  │ ⬆ + │
│                                         │ list grid│                │ ↻ 📁│
└──────────────────────────────────────────────────────────────────────────┘
     ↑ OiPathBar                    search  view     sort           actions
```

**Layout (selection active):**
```
┌──────────────────────────────────────────────────────────────────────────┐
│  ✓ 3 selected          [Move]  [Copy]  [Download]  [Delete]  [× Clear] │
└──────────────────────────────────────────────────────────────────────────┘
```

**Behavior:**
- When `selectedCount > 0`, the toolbar transitions to selection mode: path bar and search are replaced with selection count and bulk action buttons.
- Search toggle: clicking the search icon expands an `OiTextInput.search` that overlays the path bar with a crossfade animation.
- Search is debounced (300ms) and fires `onSearch` with the query.
- Sort dropdown shows `OiFileSortField` options. Clicking the currently-active sort field toggles direction (ascending ↔ descending).
- View mode toggle: `OiButtonGroup` with list and grid icon buttons.

**Responsive:**
- On narrow screens (< 600px), action buttons collapse into an overflow `OiContextMenu` (dots button).
- Search is always available via keyboard shortcut (`Ctrl+F` / `Cmd+F`).

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Path bar renders segments | OiPathBar visible |
| Search icon toggles search input | Input expands/collapses |
| Search fires onSearch after debounce | 300ms debounced callback |
| View mode toggle switches list/grid | onViewModeChange fires |
| Sort dropdown shows options | OiSelect opens |
| Sort field change fires callback | onSortFieldChange |
| Same sort field click toggles direction | Ascending ↔ descending |
| Upload button fires onUpload | Callback |
| New Folder button fires onNewFolder | Callback |
| Refresh button fires onRefresh | Callback |
| Selection mode shows count and actions | Bulk actions visible |
| Delete selected fires onDeleteSelected | Callback |
| Move selected fires onMoveSelected | Callback |
| Clear selection fires onClearSelection | Callback |
| Extra actions render | Custom widgets |
| Responsive: narrow collapses to overflow | Overflow menu |
| Keyboard: Ctrl+F focuses search | Shortcut |
| Semantics: toolbar role | Screen reader |
| Golden: default, search active, selection active | Visual regression |

---

## OiFileSidebar

**What it is:** The left sidebar panel of the file explorer. Shows a folder tree with drag-and-drop support, quick-access sections (Favorites, Recent), storage indicator, and folder management actions.

**Composes:** `OiTree` (folder hierarchy), `OiFolderTreeItem` (tree nodes), `OiDraggable` (drag folders/files), `OiDropZone` (drop files onto folders), `OiContextMenu` (right-click folder actions), `OiStorageIndicator`, `OiButton.ghost` (new folder), `OiLabel` (section headers), `OiDivider`, `OiTappable` (quick-access items), `OiIcon` (quick-access icons), `OiBadge`

```dart
OiFileSidebar({
  required List<OiTreeNode<OiFileNodeData>> folderTree,
  required String? selectedFolderId,
  required ValueChanged<OiFileNodeData> onFolderSelect,
  // Tree behavior
  Future<List<OiTreeNode<OiFileNodeData>>> Function(OiTreeNode<OiFileNodeData>)? loadChildren,
  bool draggable = true,
  void Function(OiFileNodeData folder, OiFileNodeData? newParent, int index)? onFolderMove,
  void Function(List<OiFileNodeData> files, OiFileNodeData folder)? onFileDrop,
  // Quick access
  List<OiQuickAccessItem>? quickAccess,
  ValueChanged<OiQuickAccessItem>? onQuickAccessTap,
  // Favorites
  List<OiFileNodeData>? favorites,
  ValueChanged<OiFileNodeData>? onFavoriteTap,
  ValueChanged<OiFileNodeData>? onFavoriteRemove,
  // Folder actions
  ValueChanged<OiFileNodeData>? onNewFolder,
  ValueChanged<OiFileNodeData>? onRenameFolder,
  ValueChanged<OiFileNodeData>? onDeleteFolder,
  // Storage
  OiStorageData? storage,
  // Display
  double width = 260,
  bool resizable = true,
  bool collapsible = true,
  String? semanticsLabel,
})

class OiQuickAccessItem {
  final String id;
  final String label;
  final IconData icon;
  final int? badgeCount;
}

class OiStorageData {
  final int usedBytes;
  final int totalBytes;
  final List<OiStorageCategory>? breakdown;
}
```

**Layout:**
```
┌──────────────────────────┐
│  Quick Access             │
│  🏠 Home                  │
│  📥 Downloads             │
│  🗑️ Trash                 │
│  ───────────────────────  │
│  Favorites                │
│  ⭐ Design Assets         │
│  ⭐ Q3 Reports            │
│  ───────────────────────  │
│  Folders                  │
│  ▼ 📂 Home                │
│    ▶ 📁 Documents (42)    │
│    ▼ 📂 Photos (128)      │  ← selected
│      ▶ 📁 Vacation        │
│      ▶ 📁 Work            │
│    ▶ 📁 Projects (15)     │
│                           │
│  [+ New Folder]           │
│  ───────────────────────  │
│  ████████░░░ 6.5 / 10 GB │  ← OiStorageIndicator
└──────────────────────────┘
```

**Drag-and-drop in sidebar:**
1. **Drag folder within tree:** Reorder or reparent folders. `onFolderMove` fires.
2. **Drop files from content area onto folder:** `onFileDrop` fires with the files and destination folder. The `OiFolderTreeItem` highlights as a drop target.
3. **Drop files onto quick-access items:** If the item represents a folder (e.g., "Home"), same behavior.
4. **Drag folder from tree to content area:** Not supported (folders are navigated-to, not moved via drag in that direction).

**Context menu on folder (right-click):**
- New Folder (inside this folder)
- Rename
- Delete
- Add to Favorites / Remove from Favorites
- Copy Path

**Favorites:**
- Shown in a separate section above the tree.
- Each favorite is a tappable row with a star icon + folder name.
- Right-click → "Remove from Favorites".
- Can be drag-reordered (via `OiReorderable`).

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Folder tree renders hierarchy | Correct nesting |
| Select folder highlights and fires callback | onFolderSelect |
| Expand/collapse folders | Children visible/hidden |
| Lazy loading via loadChildren | Shimmer then children |
| Drag folder within tree | onFolderMove fires |
| Drop files onto folder in tree | onFileDrop fires |
| Drop target highlight on drag-over | OiDropHighlight |
| Quick access items render | Icons + labels |
| Quick access tap fires callback | onQuickAccessTap |
| Favorites render | Star + folder name |
| Favorite tap navigates | onFavoriteTap |
| Remove favorite | onFavoriteRemove |
| Context menu on folder right-click | Menu appears |
| New Folder from context menu | onNewFolder fires |
| Rename from context menu | onRenameFolder fires |
| Delete from context menu | onDeleteFolder fires |
| Storage indicator renders | Progress bar + text |
| Resizable sidebar | Drag handle works |
| Collapsible (compact mode) | Icons only |
| Keyboard: arrows navigate tree | Focus management |
| Semantics: navigation landmark | Screen reader |
| Golden: full sidebar, compact, with drop target | Visual regression |

---

## OiFileListView

**What it is:** The list (table-like) view of files. Renders a sortable column header + virtualized rows of `OiFileTile`. Supports multi-select, rubber-band selection, drag-and-drop, and inline rename.

**Composes:** `OiVirtualList` (virtualized rows), `OiFileTile` (each row), `OiSelectionOverlay` (rubber-band), `_OiFileListHeader` (internal sortable header), `OiArrowNav` (keyboard navigation), `OiContextMenu` (right-click on empty area)

```dart
OiFileListView({
  required List<OiFileNodeData> files,
  required Set<Object> selectedKeys,
  required ValueChanged<Set<Object>> onSelectionChange,
  required ValueChanged<OiFileNodeData> onOpen,
  // Sort
  OiFileSortField sortField = OiFileSortField.name,
  OiSortDirection sortDirection = OiSortDirection.ascending,
  ValueChanged<OiFileSortField>? onSortFieldChange,
  ValueChanged<OiSortDirection>? onSortDirectionChange,
  // Columns
  bool showSize = true,
  bool showModified = true,
  bool showType = true,
  List<OiFileColumnDef>? extraColumns,
  // Rename
  Object? renamingKey,
  ValueChanged<String>? onRename,
  VoidCallback? onCancelRename,
  // Drag & drop
  void Function(List<OiFileNodeData> files, OiFileNodeData folder)? onMoveToFolder,
  // Context menu
  List<OiMenuItem> Function(OiFileNodeData)? contextMenu,
  List<OiMenuItem> Function()? backgroundContextMenu,
  // States
  bool loading = false,
  String? semanticsLabel,
})

class OiFileColumnDef {
  final String id;
  final String label;
  final double width;
  final Widget Function(OiFileNodeData) cellBuilder;
  final bool sortable;
}
```

**Column header `_OiFileListHeader`:**
```
┌────────────────────────────────────────────────────────────────────────┐
│  ☐  Name ▴               │  Size  │  Modified        │  Type         │
├────────────────────────────────────────────────────────────────────────┤
```
- Each column header is tappable → toggles sort.
- Active sort column shows an arrow (▴/▾).
- Clicking an inactive column → sort ascending by that column.
- Clicking the active column → toggle direction.
- Column widths are resizable by dragging the header dividers (via `OiResizable`).

**Selection behavior:**
- **Click:** Select single file (deselects others).
- **Ctrl+Click:** Toggle individual file in selection.
- **Shift+Click:** Range-select from last click to current.
- **Ctrl+A:** Select all.
- **Rubber-band:** Click-and-drag on empty space → `OiSelectionOverlay` draws rectangle → files intersecting are selected.
- **Escape:** Clear selection.

**Drag behavior:**
- Dragging a selected file drags ALL selected files.
- Dragging an unselected file selects it and drags only that file.
- `OiDragGhost` shows: first file's icon + name, badge with count if > 1.
- Dropping onto a folder row fires `onMoveToFolder`.

**Inline rename:**
- When `renamingKey` matches a file's key, that `OiFileTile` enters rename mode.
- Managed externally (F2 key or double-click on name triggers the parent to set `renamingKey`).

**Context menu:**
- Right-click on a file → `contextMenu(file)`.
- Right-click on empty area → `backgroundContextMenu()`.

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Files render as OiFileTile rows | All files visible |
| Column header shows sort arrow | Active sort indicator |
| Click column header sorts | onSortFieldChange fires |
| Toggle sort direction on same column | Ascending ↔ descending |
| Column resize by dragging divider | Width changes |
| Click selects single file | Selection updated |
| Ctrl+Click toggles file | Multi-selection |
| Shift+Click range-selects | Range selected |
| Ctrl+A selects all | All selected |
| Escape clears selection | Empty selection |
| Rubber-band draws rectangle | OiSelectionOverlay visible |
| Rubber-band selects intersecting files | Selection updated |
| Drag selected files shows ghost with count | OiDragGhost |
| Drop onto folder fires onMoveToFolder | Callback |
| Drag unselected file selects and drags it | Single file drag |
| renamingKey activates inline rename | OiRenameField visible |
| onRename fires on Enter | Callback |
| onCancelRename fires on Escape | Callback |
| Right-click file shows context menu | contextMenu items |
| Right-click empty area shows background menu | backgroundContextMenu items |
| Double-click opens file/folder | onOpen fires |
| loading=true shows skeletons | Shimmer rows |
| Virtual scroll for large lists | Only visible rows built |
| Keyboard: arrows move focus, Enter opens | Navigation |
| Keyboard: F2 starts rename | Shortcut |
| Keyboard: Delete triggers delete | Shortcut |
| Semantics: list role with items | Screen reader |
| Golden: list with files, selection, rename | Visual regression |

---

## OiFileGridView

**What it is:** The grid view of files. Renders a virtualized grid of `OiFileGridCard` cards. Same selection, drag-and-drop, and rename behavior as `OiFileListView`.

**Composes:** `OiVirtualGrid` (virtualized grid), `OiFileGridCard` (each card), `OiSelectionOverlay` (rubber-band), `OiArrowNav` (2D keyboard navigation), `OiContextMenu`

```dart
OiFileGridView({
  required List<OiFileNodeData> files,
  required Set<Object> selectedKeys,
  required ValueChanged<Set<Object>> onSelectionChange,
  required ValueChanged<OiFileNodeData> onOpen,
  // Grid
  double cardWidth = 160,
  double cardHeight = 180,
  double gap = 12,
  // Rename
  Object? renamingKey,
  ValueChanged<String>? onRename,
  VoidCallback? onCancelRename,
  // Drag & drop
  void Function(List<OiFileNodeData> files, OiFileNodeData folder)? onMoveToFolder,
  // Context menu
  List<OiMenuItem> Function(OiFileNodeData)? contextMenu,
  List<OiMenuItem> Function()? backgroundContextMenu,
  // States
  bool loading = false,
  String? semanticsLabel,
})
```

**Selection and drag behavior:** Identical to `OiFileListView`. See above.

**Grid navigation (keyboard):**
- Arrow keys navigate in 2D: left/right move within a row, up/down move between rows.
- Home/End jump to first/last item.

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Files render as OiFileGridCard cards | Grid layout |
| Card dimensions match cardWidth/cardHeight | Size correct |
| Gap between cards | Spacing correct |
| Selection behavior (click, Ctrl, Shift, Ctrl+A) | Same as list |
| Rubber-band selection | OiSelectionOverlay |
| Drag and drop | Same as list |
| Inline rename | OiRenameField in card |
| Context menus | File and background |
| Loading shows skeleton cards | Shimmer grid |
| Virtual scroll | Only visible cards built |
| Keyboard: 2D arrow navigation | Focus moves correctly |
| Keyboard: F2, Delete, Enter shortcuts | All work |
| Responsive: fewer columns on narrow | Auto-wrapping |
| Semantics: grid role | Screen reader |
| Golden: grid with cards, selection, folders | Visual regression |

---

## OiFileDropTarget

**What it is:** A wrapper composite that makes the entire content area a drop target for both internal file moves (from sidebar to content, from content to content) and external OS-level file drops (native drag from desktop). Shows `OiDropHighlight` overlay when files are dragged over.

**Composes:** `OiDropZone` (internal drops), `OiDropHighlight` (visual overlay), native drag-and-drop listener

```dart
OiFileDropTarget({
  required Widget child,
  required void Function(List<OiFileNodeData> files, OiFileNodeData? targetFolder) onInternalDrop,
  required ValueChanged<List<OiFileData>> onExternalDrop,
  bool enabled = true,
  String? dropMessage,
})
```

**Behavior:**
- **Internal drops (from sidebar or other content area):** Typed `OiDropZone<List<OiFileNodeData>>` receives files being dragged. `targetFolder` is null when dropped on empty space (moves to current folder) or the folder card being hovered.
- **External drops (from OS):** Listens for native file drop events. Converts to `OiFileData` and fires `onExternalDrop`.
- When any drag is detected over the target, `OiDropHighlight.area` activates with the `dropMessage` ("Drop files here to upload" for external, "Move files here" for internal).
- `enabled=false` prevents drops and hides highlights.

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Internal file drop fires onInternalDrop | Callback with files |
| Internal drop on folder fires with targetFolder | Correct folder |
| Internal drop on empty space fires with null folder | Current folder |
| External file drop fires onExternalDrop | Callback with OiFileData |
| Drop highlight shows during drag-over | OiDropHighlight visible |
| Drop highlight hides on drag-leave | OiDropHighlight hidden |
| enabled=false prevents drops | No callback |
| Custom dropMessage displayed | Label text |
| Semantics: drop target announced | Screen reader |

---

# New Tier 4 Module

---

## OiFileExplorer

**What it is:** A complete file explorer module. Replaces the existing `OiFileManager` stub. Combines sidebar folder tree, toolbar with path/search/sort/view-toggle, content area with list/grid views, drag-and-drop everywhere, dialogs for all CRUD operations, keyboard shortcuts, and OS-level drag support.

**Composes:** `OiSplitPane` (sidebar | content), `OiFileSidebar` (left), `OiFileToolbar` (top), `OiFileDropTarget` (content wrapper), `OiFileListView` / `OiFileGridView` (content), `OiContextMenu` (everywhere), `OiShortcuts` (keyboard), `OiToast` (feedback), `OiEmptyState` (empty folder), all dialog widgets.

```dart
OiFileExplorer({
  required OiFileExplorerController controller,
  required String label,
  // Data callbacks (controller delegates to these)
  required Future<List<OiFileNodeData>> Function(String folderId) loadFolder,
  required Future<List<OiTreeNode<OiFileNodeData>>> Function(String parentId) loadFolderTree,
  // CRUD callbacks
  required Future<OiFileNodeData> Function(String parentId, String name) onCreateFolder,
  required Future<void> Function(OiFileNodeData file, String newName) onRename,
  required Future<void> Function(List<OiFileNodeData> files) onDelete,
  required Future<void> Function(List<OiFileNodeData> files, OiFileNodeData destination) onMove,
  Future<void> Function(List<OiFileNodeData> files, OiFileNodeData destination)? onCopy,
  required Future<void> Function(List<OiFileData> files, String folderId) onUpload,
  Future<void> Function(OiFileNodeData file)? onDownload,
  // File actions
  ValueChanged<OiFileNodeData>? onOpen,
  ValueChanged<OiFileNodeData>? onPreview,
  ValueChanged<OiFileNodeData>? onShare,
  // Display
  OiFileViewMode defaultViewMode = OiFileViewMode.list,
  OiFileSortField defaultSortField = OiFileSortField.name,
  OiSortDirection defaultSortDirection = OiSortDirection.ascending,
  // Sidebar
  List<OiQuickAccessItem>? quickAccess,
  OiStorageData? storage,
  bool showSidebar = true,
  double sidebarWidth = 260,
  // Features
  bool enableUpload = true,
  bool enableDelete = true,
  bool enableRename = true,
  bool enableMove = true,
  bool enableCopy = true,
  bool enableSearch = true,
  bool enableDragDrop = true,
  bool enableMultiSelect = true,
  bool enableFavorites = true,
  bool enableKeyboardShortcuts = true,
  // File-type support
  List<String>? allowedUploadExtensions,
  int? maxUploadFileSize,
  // Builders
  Widget Function(OiFileNodeData)? filePreviewBuilder,
  List<OiMenuItem> Function(OiFileNodeData)? customContextMenuItems,
})
```

**OiFileExplorerController:**

```dart
class OiFileExplorerController extends ChangeNotifier {
  /// Current folder being displayed.
  OiFileNodeData get currentFolder;

  /// Navigation stack for back/forward.
  List<OiFileNodeData> get navigationHistory;
  int get historyIndex;
  bool get canGoBack;
  bool get canGoForward;

  /// Current view state.
  OiFileViewMode get viewMode;
  OiFileSortField get sortField;
  OiSortDirection get sortDirection;
  Set<Object> get selectedKeys;
  String get searchQuery;

  /// Navigation
  Future<void> navigateTo(String folderId);
  void goBack();
  void goForward();
  void goUp();

  /// Selection
  void select(Object key);
  void deselect(Object key);
  void selectAll();
  void clearSelection();
  void toggleSelection(Object key);
  void rangeSelect(Object fromKey, Object toKey);

  /// View
  void setViewMode(OiFileViewMode mode);
  void setSortField(OiFileSortField field);
  void setSortDirection(OiSortDirection direction);
  void setSearchQuery(String query);

  /// Actions (triggers dialogs internally)
  void startRename(Object fileKey);
  void cancelRename();
  Future<void> createFolder();
  Future<void> deleteSelected();
  Future<void> moveSelected();
  Future<void> copySelected();
  Future<void> uploadFiles();

  /// Refresh current folder.
  Future<void> refresh();
}
```

**Full screen layout:**
```
┌─────────────────────────────────────────────────────────────────────────────────┐
│  ┌──────────────────┐ ┌─────────────────────────────────────────────────────┐   │
│  │ Quick Access      │ │ 📁 Home / Documents / Reports   🔍 ≡ ⊞ Sort ▴ ⬆ +│   │
│  │ 🏠 Home           │ ├─────────────────────────────────────────────────────┤   │
│  │ 📥 Downloads      │ │ ☐  Name               Size    Modified      Type  │   │
│  │ 🗑️ Trash          │ │ ─────────────────────────────────────────────────── │   │
│  │ ─────────────── │ │ ☐  📁 Design Assets    —       Mar 14, 2026  —     │   │
│  │ Favorites         │ │ ☐  📁 Archive         —       Mar 10, 2026  —     │   │
│  │ ⭐ Design Assets  │ │ ☐  📄 report-q3.pdf   2.4 MB  Mar 15, 2026  PDF   │   │
│  │ ─────────────── │ │ ☐  📄 notes.txt       12 KB   Mar 14, 2026  TXT   │   │
│  │ Folders           │ │ ☐  📄 data.csv        156 KB  Mar 13, 2026  CSV   │   │
│  │ ▼ 📂 Home         │ │ ☐  🖼️ hero-banner.png  3.1 MB  Mar 12, 2026  PNG  │   │
│  │   ▶ 📁 Documents  │ │                                                     │   │
│  │   ▼ 📂 Photos     │ │                                                     │   │
│  │     ▶ 📁 Vacation  │ │                                                     │   │
│  │   ▶ 📁 Projects   │ │                                                     │   │
│  │                    │ │                                                     │   │
│  │ [+ New Folder]    │ │                                                     │   │
│  │ ─────────────── │ │                                                     │   │
│  │ ████████░░ 6/10GB │ │                                                     │   │
│  └──────────────────┘ └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────┘
```

**Context menu (right-click on file):**
```
┌────────────────────────┐
│  Open                  │
│  Open in Preview       │
│  ───────────────────── │
│  Copy            Ctrl+C│
│  Cut             Ctrl+X│
│  ───────────────────── │
│  Rename             F2 │
│  Move to...            │
│  Copy to...            │
│  ───────────────────── │
│  Add to Favorites      │
│  Share                 │
│  Get Info         Ctrl+I│
│  ───────────────────── │
│  Delete         Delete │
└────────────────────────┘
```

**Context menu (right-click on empty area):**
```
┌────────────────────────┐
│  New Folder    Ctrl+N  │
│  Upload Files  Ctrl+U  │
│  ───────────────────── │
│  Paste         Ctrl+V  │
│  ───────────────────── │
│  Sort by ▸            │
│  View as ▸            │
│  ───────────────────── │
│  Refresh        F5    │
│  Select All    Ctrl+A  │
└────────────────────────┘
```

**Keyboard shortcuts (via `OiShortcuts`):**

| Shortcut | Action |
|----------|--------|
| `Enter` | Open selected file/folder |
| `Backspace` / `Alt+←` | Go back / go up |
| `Alt+→` | Go forward |
| `F2` | Rename selected file |
| `Delete` / `Backspace` | Delete selected files (with confirmation) |
| `Ctrl+C` | Copy selected files to clipboard |
| `Ctrl+X` | Cut selected files |
| `Ctrl+V` | Paste files from clipboard |
| `Ctrl+A` | Select all |
| `Ctrl+N` | New folder |
| `Ctrl+U` | Upload files |
| `Ctrl+F` / `Ctrl+L` | Focus search / focus path bar |
| `Ctrl+I` | File info dialog |
| `Escape` | Clear selection / cancel rename / close search |
| `Space` | Toggle selection of focused file |
| `↑ ↓ ← →` | Navigate files |
| `Home` / `End` | First / last file |

**Drag-and-drop flows:**

| Source | Target | Result |
|--------|--------|--------|
| File(s) in content | Folder in content | Move files into folder |
| File(s) in content | Folder in sidebar | Move files into folder |
| Folder in sidebar | Folder in sidebar | Reparent folder |
| File(s) from OS | Content area | Upload files |
| File(s) from OS | Folder in sidebar | Upload files into folder |
| File(s) in content | Empty content area | No-op (stay in current folder) |

**Search-as-you-type:**
- Toolbar search input is debounced (300ms).
- When active, the file list is filtered client-side: files whose name contains the query (case-insensitive) are shown.
- Search highlights the matching portion of the file name in `OiFileTile` / `OiFileGridCard`.
- If the consumer wants server-side search, they re-provide the `files` list filtered by their backend.

**Toast feedback:**
- After rename: "Renamed to 'new-name.pdf'".
- After delete: "Moved 3 items to Trash" with "Undo" action button.
- After move: "Moved 3 items to Design Assets" with "Undo".
- After upload: "Uploaded 3 files".
- After create folder: "Created folder 'New Folder'".
- Errors: "Failed to rename: [reason]" with error styling.

**Empty state:**
- When current folder has no files: `OiEmptyState` with folder icon, "This folder is empty", and an "Upload files" button.
- When search returns no results: `OiEmptyState` with search icon, "No files match '[query]'", and "Clear search" button.

**Loading states:**
- Initial folder load: skeleton list/grid (via `OiShimmer`).
- Folder navigation: content area shows skeleton while loading.
- Sidebar folder expand: lazy-loaded children show shimmer.

**Tests:**

| Test | What it verifies |
|------|-----------------|
| **Navigation** | |
| Initial folder loads and renders | loadFolder called, files shown |
| Click folder in content navigates into it | navigateTo called |
| Click folder in sidebar navigates | onFolderSelect fires |
| Breadcrumb click navigates | onNavigate fires |
| Back button goes to previous folder | goBack works |
| Forward button goes forward after back | goForward works |
| Up button navigates to parent | goUp works |
| Navigation history tracks correctly | Stack is correct |
| **View** | |
| List view renders OiFileListView | OiFileTile rows |
| Grid view renders OiFileGridView | OiFileGridCard cards |
| View toggle switches list ↔ grid | View changes |
| Sort by name ascending | Correct order |
| Sort by size descending | Correct order |
| Sort by modified date | Correct order |
| Sort by type | Correct order |
| **Selection** | |
| Click selects single | One file selected |
| Ctrl+Click multi-selects | Multiple selected |
| Shift+Click range-selects | Range selected |
| Ctrl+A selects all | All selected |
| Escape clears selection | None selected |
| Rubber-band in list view | Files selected |
| Rubber-band in grid view | Cards selected |
| Selection toolbar appears | Bulk actions visible |
| **Search** | |
| Search icon activates search | Input visible |
| Typing filters files | Subset shown |
| Debounce: no filter during typing | 300ms delay |
| Search match highlighted in names | Bold/highlight on match |
| Clear search restores full list | All files back |
| No results shows empty state | "No files match" |
| Ctrl+F focuses search | Keyboard shortcut |
| **Create Folder** | |
| Ctrl+N opens new folder dialog | OiNewFolderDialog |
| Create button fires onCreateFolder | Callback |
| Toast confirms creation | Toast visible |
| New folder appears in list | File list updated |
| **Rename** | |
| F2 starts rename on selected file | OiRenameField visible |
| Enter confirms rename | onRename called |
| Escape cancels rename | Reverted |
| Duplicate name from validate | Error shown |
| Toast confirms rename | Toast visible |
| **Delete** | |
| Delete key opens delete dialog | OiDeleteDialog |
| Confirm fires onDelete | Callback |
| Undo in toast reverts delete | Undo callback |
| Folder deletion warns about contents | Warning in dialog |
| **Move** | |
| Drag file to folder in content | onMove fires |
| Drag file to folder in sidebar | onMove fires |
| "Move to..." from context menu opens dialog | OiMoveDialog |
| Move dialog shows folder tree | Tree rendered |
| Confirm move fires onMove | Callback |
| Toast confirms with undo | Toast visible |
| **Copy** | |
| "Copy to..." opens dialog | OiMoveDialog (copy mode) |
| Ctrl+C copies, Ctrl+V pastes | onCopy fires |
| **Upload** | |
| Upload button opens dialog | OiUploadDialog |
| Drag from OS shows drop highlight | OiDropHighlight |
| Drop from OS fires onUpload | Callback |
| Upload progress shown | Progress bars |
| Toast confirms upload | Toast visible |
| **File Info** | |
| Ctrl+I opens info dialog | OiFileInfoDialog |
| Info dialog shows all metadata | Fields rendered |
| **Sidebar** | |
| Folder tree renders | Hierarchy visible |
| Expand/collapse folders | Children load |
| Drag folder to reparent | onFolderMove fires |
| Drop files onto sidebar folder | onFileDrop fires |
| Favorites section renders | Favorites visible |
| Add to favorites from context menu | Favorite added |
| Remove from favorites | Favorite removed |
| Storage indicator renders | Progress bar |
| Sidebar resizable | Drag handle |
| Sidebar collapsible | Compact mode |
| **Context Menus** | |
| Right-click file shows full menu | All items present |
| Right-click empty area shows background menu | All items present |
| Submenu "Sort by" works | Sort changes |
| Submenu "View as" works | View changes |
| **Keyboard Shortcuts** | |
| All shortcuts in table above work | Each shortcut tested |
| Shortcuts disabled when dialog open | No conflict |
| Shortcuts disabled in rename mode | No conflict |
| **Accessibility** | |
| All dialogs trap focus | OiFocusTrap |
| All actions have semantics labels | Screen reader |
| File list is a semantics list | List role |
| Navigation is a semantics landmark | Navigation role |
| Toast announcements are live regions | Announced |
| **States** | |
| Loading shows skeletons | Shimmer visible |
| Empty folder shows empty state | OiEmptyState |
| Upload button in empty state works | Upload triggered |
| Error loading folder shows error state | Error message |
| Retry on error | Refresh triggered |
| **Drag Ghost** | |
| Single file drag shows icon + name | Ghost content |
| Multi-file drag shows icon + count badge | Badge visible |
| Ghost follows cursor smoothly | Positioned correctly |
| **Performance** | |
| 10,000 files in list view: <16ms frame | Virtual scroll |
| 10,000 files in grid view: <16ms frame | Virtual scroll |
| 5,000 folders in sidebar tree: <16ms frame | Virtual scroll |
| Rapid navigation (100 folder changes): responsive | No jank |
| **Golden Tests** | |
| Full explorer: list view, light + dark | Visual regression |
| Full explorer: grid view, light + dark | Visual regression |
| Selection active, list + grid | Visual regression |
| Rename active, list + grid | Visual regression |
| Drop highlight on content area | Visual regression |
| Drop highlight on sidebar folder | Visual regression |
| Empty state | Visual regression |
| Loading state | Visual regression |
| All 6 dialogs, light + dark | Visual regression (12 goldens) |

---

# Data Models

```dart
@immutable
class OiFileNodeData {
  const OiFileNodeData({
    required this.id,
    required this.name,
    required this.isFolder,
    this.parentId,
    this.size,
    this.mimeType,
    this.extension,
    this.created,
    this.modified,
    this.thumbnailUrl,
    this.url,
    this.itemCount,
    this.metadata,
    this.isFavorite = false,
    this.isShared = false,
    this.isLocked = false,
    this.isTrashed = false,
  });

  /// Unique identifier.
  final Object id;

  /// File or folder name including extension.
  final String name;

  /// Whether this node is a folder.
  final bool isFolder;

  /// Parent folder ID. Null for root.
  final String? parentId;

  /// File size in bytes. Null for folders (use `itemCount` instead).
  final int? size;

  /// MIME type (e.g., "application/pdf"). Null for folders.
  final String? mimeType;

  /// File extension without dot (e.g., "pdf"). Extracted from name if not provided.
  final String? extension;

  /// When this file was created.
  final DateTime? created;

  /// When this file was last modified.
  final DateTime? modified;

  /// URL to a thumbnail image (for image/video/document previews).
  final String? thumbnailUrl;

  /// URL to the actual file (for download or inline viewing).
  final String? url;

  /// Number of items inside (folders only).
  final int? itemCount;

  /// Arbitrary metadata (tags, owner, etc.).
  final Map<String, dynamic>? metadata;

  /// Whether this item is in the user's favorites.
  final bool isFavorite;

  /// Whether this item is shared with others.
  final bool isShared;

  /// Whether this item is locked (read-only).
  final bool isLocked;

  /// Whether this item is in the trash.
  final bool isTrashed;

  /// Extracts the file extension from the name.
  String get resolvedExtension =>
      extension ?? (isFolder ? '' : name.split('.').length > 1 ? name.split('.').last : '');

  /// Extracts the name without extension.
  String get nameWithoutExtension {
    if (isFolder) return name;
    final parts = name.split('.');
    return parts.length > 1 ? parts.sublist(0, parts.length - 1).join('.') : name;
  }

  /// Formatted size string.
  String get formattedSize {
    if (size == null) return '—';
    if (size! < 1024) return '$size B';
    if (size! < 1024 * 1024) return '${(size! / 1024).toStringAsFixed(1)} KB';
    if (size! < 1024 * 1024 * 1024) return '${(size! / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size! / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  OiFileNodeData copyWith({...});
}
```

---

# Theme Extensions

Add to `OiComponentThemes`:

```dart
class OiComponentThemes {
  // ... existing fields ...

  final OiFileExplorerThemeData? fileExplorer;
}

@immutable
class OiFileExplorerThemeData {
  const OiFileExplorerThemeData({
    this.sidebarWidth,
    this.sidebarBackground,
    this.contentBackground,
    this.fileTileHeight,
    this.fileTileHoverColor,
    this.fileTileSelectedColor,
    this.fileGridCardBorderRadius,
    this.fileGridCardHoverElevation,
    this.dropHighlightColor,
    this.dropHighlightBorderColor,
    this.pathBarBackground,
    this.toolbarBackground,
    this.toolbarHeight,
    this.selectionToolbarColor,
    this.iconCategoryColors,
    this.folderIconColor,
    this.renamingFieldBackground,
  });

  final double? sidebarWidth;
  final Color? sidebarBackground;
  final Color? contentBackground;
  final double? fileTileHeight;
  final Color? fileTileHoverColor;
  final Color? fileTileSelectedColor;
  final BorderRadius? fileGridCardBorderRadius;
  final double? fileGridCardHoverElevation;
  final Color? dropHighlightColor;
  final Color? dropHighlightBorderColor;
  final Color? pathBarBackground;
  final Color? toolbarBackground;
  final double? toolbarHeight;
  final Color? selectionToolbarColor;

  /// Override colors for specific file type categories.
  /// Keys: "document", "spreadsheet", "image", "video", "audio", "archive", "code", "text".
  final Map<String, Color>? iconCategoryColors;

  /// Override the default folder icon color.
  final Color? folderIconColor;

  final Color? renamingFieldBackground;
}
```

---

# Package Structure Additions

```
src/
  components/
    display/
      oi_file_icon.dart              ★ NEW
      oi_folder_icon.dart            ★ NEW
      oi_file_preview.dart           ★ NEW
      oi_file_tile.dart              ★ NEW
      oi_file_grid_card.dart         ★ NEW
      oi_path_bar.dart               ★ NEW
      oi_storage_indicator.dart      ★ NEW
      oi_drop_highlight.dart         ★ NEW
      oi_rename_field.dart           ★ NEW
      oi_folder_tree_item.dart       ★ NEW
    interaction/
      oi_selection_overlay.dart      ★ NEW
    dialogs/
      oi_new_folder_dialog.dart      ★ NEW
      oi_rename_dialog.dart          ★ NEW
      oi_delete_dialog.dart          ★ NEW
      oi_move_dialog.dart            ★ NEW
      oi_file_info_dialog.dart       ★ NEW
      oi_upload_dialog.dart          ★ NEW

  composites/
    files/
      oi_file_toolbar.dart           ★ NEW
      oi_file_sidebar.dart           ★ NEW
      oi_file_list_view.dart         ★ NEW
      oi_file_grid_view.dart         ★ NEW
      oi_file_drop_target.dart       ★ NEW

  modules/
    oi_file_explorer.dart            ★ REPLACED (was OiFileManager)

  models/
    oi_file_node_data.dart           ★ NEW (replaces OiFileNode)
    oi_file_explorer_controller.dart ★ NEW
```

---

# Testing Strategy

## Unit Tests

- `OiFileNodeData.resolvedExtension`: extracts correctly from name, prefers explicit extension field.
- `OiFileNodeData.nameWithoutExtension`: handles single extension, multiple dots, no extension, folders.
- `OiFileNodeData.formattedSize`: B, KB, MB, GB boundaries correct.
- `OiFileIcon` category mapping: all extensions map to correct categories. Case-insensitive. MIME fallback.
- `OiRenameField` validation: empty name, illegal characters (`/`, `\`, `:`, etc.), whitespace-only.
- `OiFileExplorerController.navigateTo`: history stack updates. `canGoBack`/`canGoForward` correct.
- `OiFileExplorerController.goBack`/`goForward`: index changes, folder loads.
- `OiFileExplorerController.select`/`deselect`/`toggleSelection`/`rangeSelect`: selection set updates correctly.
- `OiFileExplorerController.sortField`/`sortDirection`: notifyListeners fires.
- Search debounce: query updates after 300ms, not before.
- Size formatting: 0 B, 1023 B, 1.0 KB, 1023.9 KB, 1.0 MB, 1.0 GB edge cases.
- Folder self-containment check (for move): folder cannot be moved into itself or any descendant.

## Widget Tests

Every component section above includes a detailed test table. Summary:

- **Per component:** All visual states (default, hover, focus, selected, drop-target, renaming, loading, disabled, error).
- **Drag-and-drop:** Every draggable/droppable combination tested with correct callbacks and data.
- **Selection:** Click, Ctrl+Click, Shift+Click, Ctrl+A, rubber-band, Escape — in both list and grid.
- **Dialogs:** Open, validate, submit, cancel, keyboard shortcuts (Enter, Escape).
- **Context menus:** File menu, folder menu, background menu — all items fire correct callbacks.
- **Keyboard shortcuts:** All shortcuts in the table tested.
- **Accessibility:** Every component has `Semantics` labels. Dialogs trap focus. Live regions announce actions.
- **Theming:** Every component renders correctly with default and custom theme overrides.
- **Reduced motion:** Every animation has instant fallback.

## Golden Tests

| Widget | Variants | Light + Dark | Total |
|--------|----------|-------------|-------|
| OiFileIcon | 14 categories × md | ×2 | 28 |
| OiFolderIcon | 3 states × 5 variants | ×2 | 30 |
| OiFileTile | default, hover, selected, renaming, drop-target | ×2 | 10 |
| OiFileGridCard | file, folder, hover, selected, renaming, drop | ×2 | 12 |
| OiPathBar | breadcrumb, edit, collapsed | ×2 | 6 |
| OiStorageIndicator | low, medium, high, with breakdown | ×2 | 8 |
| OiDropHighlight | area, border | ×2 | 4 |
| OiSelectionOverlay | active rectangle | ×2 | 2 |
| OiRenameField | normal, error | ×2 | 4 |
| OiFolderTreeItem | default, expanded, selected, drop-target | ×2 | 8 |
| OiFileToolbar | default, search active, selection active | ×2 | 6 |
| OiFileSidebar | full, compact, with drop-target | ×2 | 6 |
| OiFileListView | with files, selection, rename | ×2 | 6 |
| OiFileGridView | with cards, selection, rename | ×2 | 6 |
| OiFileExplorer | full list, full grid, empty, loading | ×2 | 8 |
| 6 Dialogs | each ×1 | ×2 | 12 |
| **Total** | | | **156** |

## Integration Tests

- **Navigate flow:** Open root → click folder → breadcrumb updates → click breadcrumb → back button → forward button.
- **Create folder flow:** Ctrl+N → type name → Enter → folder appears in list + sidebar → toast confirms.
- **Rename flow:** Select file → F2 → type new name → Enter → name updates → toast confirms.
- **Rename cancel:** F2 → Escape → name reverts.
- **Delete flow:** Select 3 files → Delete → dialog confirms → confirm → files removed → toast with undo → undo → files restored.
- **Move via drag (content → sidebar):** Select files → drag to sidebar folder → drop → files moved → toast with undo.
- **Move via drag (content → content folder):** Drag file onto folder card → files moved.
- **Move via dialog:** Right-click → "Move to..." → select destination in tree → confirm → moved.
- **Copy flow:** Right-click → "Copy to..." → select destination → confirm → copy created.
- **Upload flow:** Click upload → select files → progress shown → files appear in list → toast.
- **Upload via drag:** Drag from OS → drop highlight → drop → upload dialog → upload.
- **Search flow:** Ctrl+F → type query → list filters → clear → full list restored.
- **Sort flow:** Click "Size" column → sorted ascending → click again → sorted descending.
- **View toggle:** Click grid icon → grid view → click list icon → list view (selection preserved).
- **Favorites flow:** Right-click folder → "Add to Favorites" → appears in sidebar → right-click → "Remove" → gone.
- **Rubber-band selection:** Click empty space → drag → rectangle selects 5 files → bulk delete.
- **File info:** Select file → Ctrl+I → info dialog shows all metadata → close.

## Performance Tests

- `OiFileListView` with 100,000 files: <16ms frame time (virtual scroll).
- `OiFileGridView` with 50,000 files: <16ms frame time (virtual grid).
- `OiFileSidebar` with 10,000 folders: <16ms frame time (virtual tree).
- Rubber-band selection over 10,000 items: selection calculation <5ms.
- Search filtering 100,000 files client-side: <50ms filter time.
- Rapid folder navigation (100 navigations in 10 seconds): no jank, no memory leak.
- Drag ghost rendering during drag over 10,000-item list: <16ms frame time.

---

End of specification.
