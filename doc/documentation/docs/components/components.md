# Components

Components are the standard UI widgets you'll use every day. They're built from primitives, styled by the theme, and accessible by default.

## Buttons

| Widget | Description |
|---|---|
| `OiButton` | Primary, secondary, outline, ghost, destructive, soft variants |
| `OiIconButton` | Icon-only button |
| `OiToggleButton` | Toggle/switch button |
| `OiButtonGroup` | Multi-button toolbar |
| `OiSortButton` | Dropdown button for sorting non-table lists (card grids, feeds) |
| `OiExportButton` | Export data in various formats (CSV, XLSX, JSON, PDF) |

### OiButton

The workhorse. Six visual variants, three sizes, four specialized constructors:

```dart
// Standard button
OiButton(label: 'Save', onPressed: () {})

// Variants
OiButton(label: 'Save', variant: OiButtonVariant.primary, onPressed: () {})
OiButton(label: 'Cancel', variant: OiButtonVariant.ghost, onPressed: () {})
OiButton(label: 'Delete', variant: OiButtonVariant.destructive, onPressed: () {})

// With icon
OiButton(label: 'Download', leading: Icon(Icons.download), onPressed: () {})

// Sizes
OiButton(label: 'Small', size: OiButtonSize.small, onPressed: () {})

// Loading state
OiButton(label: 'Saving...', isLoading: true, onPressed: () {})

// Full width
OiButton(label: 'Continue', fullWidth: true, onPressed: () {})
```

**Specialized constructors:**

- `OiButton.icon()` — Icon-only with tooltip
- `OiButton.split()` — Button with dropdown arrow
- `OiButton.countdown()` — Countdown before enabling
- `OiButton.confirm()` — Double-click to confirm

### OiSortButton

A dropdown button for sorting non-table lists such as card grids and activity feeds. Shows the current sort field and direction, with a popover for field selection and direction toggle.

```dart
OiSortButton(
  label: 'Sort by',
  options: [
    OiSortOption(field: 'name', label: 'Name'),
    OiSortOption(field: 'date', label: 'Date'),
    OiSortOption(field: 'size', label: 'Size'),
  ],
  currentSort: OiSortOption(field: 'name', label: 'Name'),
  onSortChange: (option) => setState(() => _sort = option),
)
```

### OiExportButton

A button that exports data in various formats. Renders as a plain outline button for a single format, or a split button with a dropdown for multiple formats.

```dart
// Single format — direct action
OiExportButton(
  label: 'Export',
  onExport: (format) async => downloadFile(format),
)

// Multiple formats — split button with dropdown
OiExportButton(
  label: 'Export',
  onExport: (format) async => downloadFile(format),
  formats: [OiExportFormat.csv, OiExportFormat.xlsx, OiExportFormat.json],
)
```

## Inputs

| Widget | Description |
|---|---|
| `OiTextInput` | Text field with validation, prefix/suffix, counter |
| `OiCheckbox` | Checkbox with label |
| `OiRadio` | Radio button group |
| `OiSwitch` | Toggle switch |
| `OiSlider` | Range slider |
| `OiSelect` | Dropdown select with search |
| `OiNumberInput` | Number input with increment/decrement |
| `OiDateInput` | Date picker input |
| `OiTimeInput` | Time picker input |
| `OiDateTimeInput` | Combined date + time input |
| `OiColorInput` | Color picker input |
| `OiTagInput` | Multi-value tag input |
| `OiArrayInput` | Repeatable form field group with add/remove/reorder |
| `OiFileInput` | File selection input |

### OiTextInput

```dart
OiTextInput(
  label: 'Email',
  hint: 'you@example.com',
  validator: (value) {
    if (value == null || !value.contains('@')) return 'Invalid email';
    return null;
  },
  onChanged: (value) => print(value),
)
```

### OiSelect

```dart
OiSelect<String>(
  label: 'Country',
  items: ['Austria', 'Germany', 'Switzerland'],
  itemBuilder: (country) => Text(country),
  onChanged: (country) => print(country),
)
```

## Display

| Widget | Description |
|---|---|
| `OiAvatar` | User avatar with image or initials |
| `OiBadge` | Count badge or dot indicator |
| `OiCard` | Content container with shadow |
| `OiCodeBlock` | Syntax-highlighted code display |
| `OiDiffView` | Text diff visualization |
| `OiDropHighlight` | Drag-over visual feedback |
| `OiEmptyState` | Empty list/state placeholder |
| `OiFileGridCard` | File card for grid view |
| `OiFileIcon` | File type icon |
| `OiFileTile` | File row for list view |
| `OiFolderIcon` | Folder icon |
| `OiFolderTreeItem` | Folder tree node |
| `OiFilePreview` | File content preview |
| `OiImage` | Optimized image with error handling |
| `OiListTile` | List item with leading, title, subtitle, trailing |
| `OiMarkdown` | Markdown renderer |
| `OiMetric` | Key-value metric display |
| `OiPathBar` | Breadcrumb path navigation |
| `OiPopover` | Popover overlay |
| `OiProgress` | Progress bar |
| `OiRelativeTime` | "5m ago" timestamps with auto-refresh |
| `OiRenameField` | Inline rename input |
| `OiReplyPreview` | Message reply preview |
| `OiSkeletonGroup` | Loading skeleton placeholders |
| `OiStorageIndicator` | Storage usage bar |
| `OiTooltip` | Hover/focus tooltip |

### OiCard

```dart
OiCard(
  child: Column(
    children: [
      Text('Title', style: context.textTheme.h4),
      SizedBox(height: context.spacing.sm),
      Text('Card content goes here'),
    ],
  ),
)
```

### OiBadge

```dart
// Dot badge
OiBadge.dot(child: OiIconButton(icon: Icons.mail, onPressed: () {}))

// Count badge
OiBadge(count: 5, child: OiIconButton(icon: Icons.notifications, onPressed: () {}))
```

## Navigation

| Widget | Description |
|---|---|
| `OiTabs` | Tab navigation with optional persistence |
| `OiAccordion` | Collapsible sections |
| `OiBreadcrumbs` | Path navigation |
| `OiBottomBar` | Mobile bottom navigation bar |
| `OiDrawer` | Side drawer |
| `OiDatePicker` | Calendar date picker |
| `OiTimePicker` | Time selector |
| `OiEmojiPicker` | Emoji selector |
| `OiThemeToggle` | Light/dark/system theme mode toggle |
| `OiUserMenu` | Avatar-triggered dropdown with user info and actions |

### OiTabs

```dart
OiTabs(
  tabs: [
    OiTab(label: 'Overview', child: OverviewPanel()),
    OiTab(label: 'Details', child: DetailsPanel()),
    OiTab(label: 'History', child: HistoryPanel()),
  ],
)
```

### OiThemeToggle

```dart
// Three-way toggle (light / dark / system) via popover
OiThemeToggle(
  currentMode: OiThemeMode.light,
  onModeChange: (mode) => setState(() => _mode = mode),
)

// Two-way toggle (light ↔ dark) — cycles on tap
OiThemeToggle(
  currentMode: _mode,
  onModeChange: (mode) => setState(() => _mode = mode),
  showSystemOption: false,
)
```

### OiUserMenu

```dart
OiUserMenu(
  label: 'Account menu',
  userName: 'Jane Smith',
  userEmail: 'jane@example.com',
  avatarInitials: 'JS',
  items: [
    OiMenuItem(label: 'Profile', icon: OiIcons.person, onTap: () {}),
    OiMenuItem(label: 'Settings', icon: OiIcons.settings, onTap: () {}),
    OiMenuItem(label: 'Logout', icon: OiIcons.logout, onTap: () {}),
  ],
)
```

## Overlays

| Widget | Description |
|---|---|
| `OiDialog` | Modal dialog |
| `OiSheet` | Bottom/side sheet |
| `OiToast` | Toast notification |
| `OiContextMenu` | Right-click / long-press context menu |

### OiToast

```dart
OiToast.show(
  context,
  message: 'File saved successfully',
  variant: OiToastVariant.success,
);
```

## Panels

| Widget | Description |
|---|---|
| `OiPanel` | Sliding side panel |
| `OiResizable` | Resizable container |
| `OiSplitPane` | Draggable splitter between two children |

## Feedback

| Widget | Description |
|---|---|
| `OiStarRating` | Star rating (1-5) |
| `OiScaleRating` | Numeric scale (1-10) |
| `OiSentiment` | Mood/emoji selector |
| `OiThumbs` | Thumbs up/down |
| `OiReactionBar` | Emoji reaction bar |

## Inline Edit

| Widget | Description |
|---|---|
| `OiEditable` | Generic inline editor wrapper |
| `OiEditableText` | Click-to-edit text |
| `OiEditableNumber` | Click-to-edit number |
| `OiEditableDate` | Click-to-edit date |
| `OiEditableSelect` | Click-to-edit dropdown |

### OiEditableText

```dart
OiEditableText(
  value: 'Project Alpha',
  onSave: (newValue) async {
    await api.rename(newValue);
  },
)
```

## Dialogs (file management)

| Widget | Description |
|---|---|
| `OiDeleteDialog` | Delete confirmation dialog |
| `OiRenameDialog` | Rename dialog |
| `OiMoveDialog` | Move/copy file dialog |
| `OiNewFolderDialog` | Create folder dialog |
| `OiUploadDialog` | Upload progress dialog |
| `OiFileInfoDialog` | File details display |

## Shop

| Widget | Description |
|---|---|
| `OiPriceTag` | Formatted price display with optional compare-at strikethrough and currency symbol |
| `OiQuantitySelector` | Number stepper with minus/plus buttons for product quantities |

### OiPriceTag

Formatted price display with optional compare-at (strikethrough) price and currency symbol. Supports size variants and locale-aware currency placement.

```dart
// Basic price
OiPriceTag(price: 42.99, label: 'Product price')

// With currency
OiPriceTag(price: 42.99, label: 'Price', currencyCode: 'EUR')

// Sale price with compare-at
OiPriceTag(
  price: 29.99,
  label: 'Sale price',
  compareAtPrice: 59.99,
  currencyCode: 'USD',
)

// Large size, zero decimal places
OiPriceTag(
  price: 100,
  label: 'Price',
  size: OiPriceTagSize.large,
  decimalPlaces: 0,
)
```

**Special states:**
- Zero price shows "Free" in success color
- Negative prices shown in success color
- Compare-at price shown with strikethrough when greater than current price

### OiQuantitySelector

A compact number stepper for product quantities with minus/plus buttons, display value, and keyboard support.

```dart
// Basic quantity selector
OiQuantitySelector(
  value: 1,
  label: 'Quantity',
  onChange: (newValue) => setState(() => _qty = newValue),
)

// With custom min/max
OiQuantitySelector(
  value: 3,
  label: 'Quantity',
  min: 1,
  max: 10,
  onChange: (newValue) => setState(() => _qty = newValue),
)

// Compact mode for cart rows
OiQuantitySelector(
  value: 2,
  label: 'Quantity',
  compact: true,
  onChange: (newValue) => setState(() => _qty = newValue),
)
```

## Interaction

| Widget | Description |
|---|---|
| `OiSelectionOverlay` | Multi-selection UI overlay |
