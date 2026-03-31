# Components

Components are the standard UI widgets you'll use every day. They're built from primitives, styled by the theme, and accessible by default.

## Buttons

| Widget | Description |
| --- | --- |
| `OiButton` | Primary, secondary, outline, ghost, destructive, soft variants |
| `OiIconButton` | Icon-only button |
| `OiToggleButton` | Toggle/switch button |
| `OiButtonGroup` | Multi-button toolbar |
| `OiSortButton` | Dropdown button for sorting non-table lists (card grids, feeds) |
| `OiExportButton` | Export data in various formats (CSV, XLSX, JSON, PDF) |
| `OiBackButton` | RTL-aware back navigation button |

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
OiButton(label: 'Download', leading: OiIcon.decorative(icon: OiIcons.download), onPressed: () {})

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

### OiBackButton

A themed back-navigation button that renders a chevron-left icon, automatically flipping to chevron-right in RTL layouts. Typically used as the leading widget in `OiSliverHeader` or custom app bars.

```dart
OiBackButton(
  onPressed: () => Navigator.of(context).pop(),
)

// Custom size and color
OiBackButton(
  onPressed: () => goBack(),
  size: 20,
  color: context.colors.primary.base,
)
```

**Key features:**

- RTL-aware — automatically mirrors the chevron direction
- Configurable icon size and color
- Built on `OiTappable` for consistent hover, focus, and press feedback
- Semantic label defaults to "Go back"

**Related components:** `OiSliverHeader`, `OiNavigationRail`, `OiBottomBar`

## Inputs

| Widget | Description |
| --- | --- |
| `OiTextInput` | Text field with validation, prefix/suffix, counter, plus `.otp()`, `.password()`, `.multiline()` constructors |
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
| `OiFormSelect` | Form-integrated dropdown with validation |
| `OiSwitchTile` | Toggle tile with switch, label, and subtitle |
| `OiCheckboxTile` | Toggle tile with checkbox, label, and subtitle |
| `OiRadioTile` | Toggle tile with radio indicator, label, and subtitle |
| `OiSegmentedControl` | Exclusive segment toggle (2-5 options) |
| `OiDatePickerField` | Date input with calendar dialog |
| `OiDateRangePickerField` | Date range input with presets and calendar dialog |
| `OiTimePickerField` | Time input with time picker dialog |
| `OiColorPalettePicker` | Multi-slot color palette picker with preset palettes |

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

**Specialized constructors:**

- `OiTextInput.password()` — Obscured input with visibility toggle
- `OiTextInput.multiline()` — Multi-line text area with auto-growing height
- `OiTextInput.otp()` — One-time-password / PIN entry with per-digit boxes

```dart
// Password input with visibility toggle
OiTextInput.password(label: 'Password')

// Multi-line text area
OiTextInput.multiline(
  label: 'Description',
  minLines: 3,
  maxLines: 8,
)

// OTP / verification code input
OiTextInput.otp(
  length: 6,
  onCompleted: (code) => verifyCode(code),
)
```

**Form validation integration:**

OiTextInput integrates with `OiForm` via standard form field properties: `validator`, `autovalidateMode`, and `onSaved`. Additional properties include `textCapitalization`, `textAlign`, `showCounter`, `counterBuilder`, `onTap`, and `onTapOutside`.

```dart
OiTextInput(
  label: 'Username',
  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
  autovalidateMode: AutovalidateMode.onUserInteraction,
  onSaved: (value) => _username = value,
  textCapitalization: TextCapitalization.none,
  showCounter: true,
  maxLength: 30,
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

### OiArrayInput

A repeatable form field group with add, remove, and reorder controls. Each row is built via `itemBuilder` and new blank rows via `createEmpty`.

```dart
OiArrayInput<String>(
  label: 'Tags',
  items: tags,
  itemBuilder: (context, index, tag, onItemChanged) {
    return OiTextInput(
      value: tag,
      onChanged: onItemChanged,
      label: 'Tag ${index + 1}',
    );
  },
  createEmpty: () => '',
  onChanged: (updatedTags) => setState(() => tags = updatedTags),
  reorderable: true,
  addLabel: 'Add Tag',
  minItems: 1,
  maxItems: 10,
)
```

### OiFormSelect

A form-integrated dropdown that wraps `OiSelect` with `FormField<T>`. When `validator` is non-null the widget participates in ancestor `Form` validation, saving, and auto-validate flows. When `validator` is null, it renders a plain `OiSelect<T>`.

```dart
OiFormSelect<String>(
  options: ['Admin', 'Editor', 'Viewer'],
  labelOf: (role) => role,
  value: _selectedRole,
  onChanged: (role) => setState(() => _selectedRole = role),
  label: 'Role',
  placeholder: 'Choose a role',
  validator: (value) => value == null ? 'Role is required' : null,
  searchable: true,
)
```

**Key features:**

- Wraps `OiSelect` in a `FormField` when `validator` is non-null
- Manual `error` takes precedence over form-field error text
- Supports `searchable`, `bottomSheetOnCompact`, `autovalidateMode`
- `onSaved` callback for `Form.save()` integration

**Related components:** `OiSelect`, `OiForm`, `OiTextInput`

### OiSwitchTile / OiCheckboxTile / OiRadioTile

Toggle tiles that pair an `OiListTile` with a trailing toggle control. Tapping anywhere on the tile toggles the value.

```dart
// Switch tile
OiSwitchTile(
  title: 'Enable notifications',
  subtitle: 'Receive push notifications',
  value: _notificationsEnabled,
  onChanged: (value) => setState(() => _notificationsEnabled = value),
)

// Checkbox tile with tristate
OiCheckboxTile(
  title: 'Select all',
  value: _selectAll,
  tristate: true,
  onChanged: (value) => setState(() => _selectAll = value),
)

// Radio tile
OiRadioTile<String>(
  title: 'Dark mode',
  value: 'dark',
  groupValue: _theme,
  onChanged: (value) => setState(() => _theme = value),
)
```

**Key features:**

- Full-tile tap toggles the control
- Optional `subtitle`, `leading` widget, `dense` mode
- Disabled state renders at reduced opacity
- `OiCheckboxTile` supports tristate (`true` / `false` / `null`)
- `OiRadioTile<T>` is generic with `value` / `groupValue` semantics
- Accessibility labels fall back to `title` when `semanticLabel` is null

**Related components:** `OiSwitch`, `OiCheckbox`, `OiRadio`, `OiListTile`

### OiSegmentedControl

An exclusive segment toggle that renders 2-5 options as connected buttons. Exactly one segment is selected at a time.

```dart
OiSegmentedControl<String>(
  segments: [
    OiSegment(value: 'day', label: 'Day'),
    OiSegment(value: 'week', label: 'Week'),
    OiSegment(value: 'month', label: 'Month'),
  ],
  selected: _view,
  onChanged: (value) => setState(() => _view = value),
)

// With icons and expand
OiSegmentedControl<String>(
  segments: [
    OiSegment(value: 'grid', label: 'Grid', icon: OiIcons.grid),
    OiSegment(value: 'list', label: 'List', icon: OiIcons.list),
  ],
  selected: _layout,
  onChanged: (value) => setState(() => _layout = value),
  size: OiSegmentedControlSize.large,
  expand: true,
)
```

**Key features:**

- Three size variants: `small` (28dp), `medium` (36dp), `large` (44dp)
- Connected border styling with rounded corners on first/last segments
- `expand: true` stretches segments to fill available width equally
- Per-segment `enabled` flag for disabling individual options
- Keyboard navigation: arrow keys move selection between segments
- Optional `icon` per segment displayed alongside the label

**Related components:** `OiTabs`, `OiRadio`, `OiToggleButton`

### OiDatePickerField

A date input field that displays a formatted date and opens an `OiDatePicker` calendar dialog when tapped.

```dart
OiDatePickerField(
  value: _selectedDate,
  onChanged: (date) => setState(() => _selectedDate = date),
  label: 'Start date',
  placeholder: 'Select a date',
  minDate: DateTime(2020),
  maxDate: DateTime(2030),
  clearable: true,
)

// With form validation
OiDatePickerField(
  value: _dueDate,
  onChanged: (date) => setState(() => _dueDate = date),
  label: 'Due date',
  validator: (date) => date == null ? 'Due date is required' : null,
  autovalidateMode: AutovalidateMode.onUserInteraction,
)
```

**Key features:**

- Read-only input frame with trailing calendar icon
- Opens `OiDatePicker` dialog on tap
- Date formatting via `intl` `DateFormat` (default: `'MMM d, yyyy'`)
- Optional clear button when `clearable: true`
- Form integration via `validator`, `onSaved`, `autovalidateMode`
- Supports `minDate`, `maxDate` constraints
- `readOnly` mode (visually distinct from disabled)

**Related components:** `OiDatePicker`, `OiDateInput`, `OiDateRangePickerField`, `OiForm`

### OiDateRangePickerField

A date range input field that opens a dialog with optional preset chips and an `OiDatePicker` in range mode.

```dart
OiDateRangePickerField(
  startDate: _start,
  endDate: _end,
  onChanged: (start, end) => setState(() {
    _start = start;
    _end = end;
  }),
  label: 'Date range',
  showPresets: true,
)

// With custom presets and validation
OiDateRangePickerField(
  startDate: _start,
  endDate: _end,
  onChanged: (start, end) => setState(() {
    _start = start;
    _end = end;
  }),
  label: 'Report period',
  presets: [
    OiDateRangePreset.last7Days,
    OiDateRangePreset.last30Days,
    OiDateRangePreset.thisMonth,
  ],
  validator: (range) => range == null ? 'Date range is required' : null,
)
```

**Key features:**

- Displays range as "Mar 1 - Mar 23, 2026" (compact same-year format)
- Dialog with preset chips: Today, Last 7 days, Last 30 days, This week, This month, Last month, This year
- Custom presets via `OiDateRangePreset(label, resolve)` with optional icon
- Calendar in range mode for manual start/end selection
- Cancel / Apply buttons in dialog
- Form integration via `validator`, `onSaved`, `autovalidateMode`
- Optional clear button via `clearable: true`

**Related components:** `OiDatePickerField`, `OiDatePicker`, `OiDialogShell`, `OiForm`

### OiTimePickerField

A time input field that displays a formatted time and opens an `OiTimePicker` dialog when tapped.

```dart
OiTimePickerField(
  value: OiTimeOfDay(hour: 14, minute: 30),
  onChanged: (time) => setState(() => _time = time),
  label: 'Meeting time',
  use24Hour: true,
  clearable: true,
)

// 12-hour format with form validation
OiTimePickerField(
  value: _startTime,
  onChanged: (time) => setState(() => _startTime = time),
  label: 'Start time',
  use24Hour: false,
  validator: (time) => time == null ? 'Start time is required' : null,
)
```

**Key features:**

- Read-only input frame with trailing clock icon
- Opens `OiTimePicker` dialog on tap
- 24-hour (`14:30`) or 12-hour (`2:30 PM`) display via `use24Hour`
- Optional clear button when `clearable: true`
- Form integration via `validator`, `onSaved`, `autovalidateMode`
- Reserved `minTime`, `maxTime`, `minuteInterval` for future constraint support

**Related components:** `OiTimePicker`, `OiTimeInput`, `OiDatePickerField`, `OiForm`

### OiColorPalettePicker

Multi-slot color palette picker with preset palettes. Each slot represents a named color role (e.g. primary, accent) and can be edited individually or filled from a preset palette.

```dart
OiColorPalettePicker(
  label: 'Brand colors',
  slots: [
    OiColorSlot(id: 'primary', label: 'Primary', value: Color(0xFF2563EB)),
    OiColorSlot(id: 'accent', label: 'Accent'),
  ],
  onSlotChanged: (slotId, color) => updateColor(slotId, color),
  presets: [
    OiColorPalette(
      id: 'ocean', name: 'Ocean',
      colors: {'primary': Color(0xFF0077B6), 'accent': Color(0xFF00B4D8)},
    ),
  ],
)
```

**Key features:**

- Multiple named color slots with individual edit controls
- Preset palettes that fill all slots at once
- Each slot opens an `OiColorInput` picker on tap
- Empty slots show a placeholder swatch
- `onSlotChanged` fires per-slot; `onPresetSelected` fires when a preset is applied

**Related components:** `OiColorInput`, `OiForm`, `OiCard`

## Display

| Widget | Description |
| --- | --- |
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
| `OiPagination` | Standalone pagination control with pages, compact, and load-more variants |
| `OiFieldDisplay` | Universal read-only field renderer with 16 field types and pair layout |
| `OiRefreshIndicator` | Pull-to-refresh wrapper for scrollable content |
| `OiPageIndicator` | Dot indicators for paged content (carousels, onboarding) |
| `OiScrollToTop` | Floating scroll-to-top button that appears on scroll |
| `OiImagePreviewCard` | Image card with shimmer loading, status badge, edit overlay, version label |
| `OiStatusDot` | Semantic live-status indicator dot with pulse animation and OiStatusVariant enum |

### OiProgress

**Enhancement:** `OiProgress.bulk()` — A new factory constructor for rendering batch/bulk operation progress. Displays an overall progress bar with a label showing "N of M items processed", estimated time remaining, and an optional cancel button.

```dart
OiProgress.bulk(
  completed: 42,
  total: 100,
  label: 'Uploading files',
  onCancel: () => cancelUpload(),
)
```

### OiMarkdown

**Enhancement:** `OiMarkdown` now supports Mermaid diagram rendering. Fenced code blocks tagged with `mermaid` are parsed and rendered as inline SVG diagrams. Supported diagram types include flowchart, sequence, class, state, and Gantt.

````dart
OiMarkdown(
  data: '''
## Architecture

```mermaid
graph TD
  A[Client] --> B[API Gateway]
  B --> C[Auth Service]
  B --> D[Data Service]
```
''',
)
````

### OiFieldDisplay

A universal read-only field renderer that formats values based on `OiFieldType`. Supports text, number, currency, date, dateTime, boolean, email, url, phone, file, image, select, tags, color, json, and custom types with appropriate formatting, icons, and link behavior.

```dart
// Simple text display
OiFieldDisplay(
  value: 'John Doe',
  type: OiFieldType.text,
  label: 'Customer name',
)

// Currency display
OiFieldDisplay(
  value: 42.99,
  type: OiFieldType.currency,
  label: 'Price',
  currencyCode: 'EUR',
  decimalPlaces: 2,
)

// Boolean display (shows check/cross icon with Yes/No)
OiFieldDisplay(
  value: true,
  type: OiFieldType.boolean,
  label: 'Active',
)

// Select with choice labels and badge colors
OiFieldDisplay(
  value: 'active',
  type: OiFieldType.select,
  label: 'Status',
  choices: {'active': 'Active', 'inactive': 'Inactive'},
  choiceColors: {'active': OiBadgeColor.success, 'inactive': OiBadgeColor.neutral},
)

// Tags display
OiFieldDisplay(
  value: ['flutter', 'dart', 'ui'],
  type: OiFieldType.tags,
  label: 'Tags',
)

// Copyable email
OiFieldDisplay(
  value: 'jane@example.com',
  type: OiFieldType.email,
  label: 'Email',
  copyable: true,
)
```

**Pair layout** for label + value side-by-side or stacked:

```dart
// Horizontal pair (label left, value right)
OiFieldDisplay.pair(
  label: 'Name',
  value: 'Jane Smith',
  type: OiFieldType.text,
)

// Vertical pair (label above value)
OiFieldDisplay.pair(
  label: 'Description',
  value: 'A longer text value that sits below its label.',
  type: OiFieldType.text,
  direction: Axis.vertical,
)

// Aligned pairs with fixed label width
Column(
  children: [
    OiFieldDisplay.pair(label: 'Name', value: 'Jane', labelWidth: 120),
    OiFieldDisplay.pair(label: 'Email', value: 'jane@co.com', type: OiFieldType.email, labelWidth: 120),
    OiFieldDisplay.pair(label: 'Status', value: 'active', type: OiFieldType.select, labelWidth: 120,
      choices: {'active': 'Active'}, choiceColors: {'active': OiBadgeColor.success}),
  ],
)
```

### OiRefreshIndicator

A pull-to-refresh wrapper that shows a circular progress indicator when the user overscrolls at the top of a scrollable child. The indicator appears above the content, animating in as the user drags, then switches to an indeterminate spinner while the refresh is in progress.

```dart
OiRefreshIndicator(
  onRefresh: () async {
    await fetchLatestData();
  },
  child: ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) => ItemTile(items[index]),
  ),
)
```

**Key features:**

- Drag distance threshold before triggering (configurable via `triggerDistance`)
- Themed colors — uses primary color for the spinner, surface for the background
- Configurable displacement, edge offset, indicator size, and stroke width
- Accessibility announcement on refresh start and completion
- Respects `reducedMotion` setting

**Related components:** `OiProgress`, `OiInfiniteScroll`, `OiVirtualList`

### OiPageIndicator

A row of dots indicating the current page in a paged view. Commonly used with carousels, onboarding flows, galleries, and any horizontally-paged content.

```dart
// Standard dot indicators
OiPageIndicator(
  count: 5,
  current: _currentPage,
)

// Pill-shaped active indicator
OiPageIndicator.pill(
  count: 5,
  current: _currentPage,
)

// Custom colors and sizing
OiPageIndicator(
  count: 3,
  current: _currentPage,
  activeColor: context.colors.primary.base,
  color: context.colors.borderSubtle,
  size: 10,
  spacing: 12,
)
```

**Key features:**

- Two variants: circular dots (default) and pill-shaped active indicator
- Animated transitions between active states
- Configurable dot size, active size, spacing, and colors
- Automatic accessibility label ("Page X of Y")

**Related components:** `OiProductGallery`, `OiTabs`, `OiStepper`

### OiScrollToTop

A floating button that appears when the user scrolls past a configurable threshold and scrolls back to the top on tap. Wrap any scrollable widget and provide the same `ScrollController`.

```dart
final _scrollController = ScrollController();

OiScrollToTop(
  controller: _scrollController,
  child: ListView.builder(
    controller: _scrollController,
    itemCount: items.length,
    itemBuilder: (context, index) => ItemTile(items[index]),
  ),
)

// Custom threshold and position
OiScrollToTop(
  controller: _scrollController,
  threshold: 400,
  alignment: Alignment.bottomLeft,
  child: myScrollableWidget,
)
```

**Key features:**

- Fade-in/fade-out animation when crossing the scroll threshold
- Default themed button (circular surface with chevron-up icon and shadow)
- Customizable via the `button` property for a completely custom widget
- Configurable alignment and padding within the stack
- Smooth scroll-to-top animation on tap

**Related components:** `OiVirtualList`, `OiInfiniteScroll`, `OiFloating`

### OiImagePreviewCard

Image card with loading shimmer, status badge overlay, edit overlay, and version indicator. Useful for design asset browsers, media libraries, and project dashboards.

```dart
OiImagePreviewCard(
  alt: 'Authentication wireframe',
  imageUrl: 'https://example.com/wireframe.png',
  statusBadge: OiBadge.filled(label: 'stale', color: OiBadgeColor.warning),
  versionLabel: 'v3',
  onTap: () {},
  onEdit: () {},
)
```

**Key features:**

- Shimmer loading state while image loads
- Optional status badge overlay (top-right corner)
- Edit overlay with pencil icon appears on hover (or always visible on touch)
- Version label pill in the bottom-left corner
- Rounded corners and shadow from theme
- Error state with broken-image placeholder

**Related components:** `OiCard`, `OiBadge`, `OiImage`, `OiShimmer`

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

**Enhancement:** `OiCard` now supports an optional `statusBadge` parameter that renders an `OiBadge` overlay in the top-right corner of the card. Useful for showing state indicators (e.g. "Draft", "Active", "Archived") directly on cards in grid layouts.

```dart
OiCard(
  statusBadge: OiBadge.soft(label: 'Draft', color: OiBadgeColor.warning),
  child: myContent,
)
```

### OiBadge

```dart
// Dot badge
OiBadge.dot(child: OiIconButton(icon: OiIcons.mail, onPressed: () {}))

// Count badge
OiBadge(count: 5, child: OiIconButton(icon: OiIcons.bell, onPressed: () {}))
```

## Navigation

| Widget | Description |
| --- | --- |
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
| `OiLocaleSwitcher` | Locale/language dropdown selector with optional flag emoji |
| `OiNavigationRail` | Compact vertical navigation rail with icon+label items |
| `OiSliverHeader` | Sticky sliver header with .simple, .large, .hero constructors |
| `OiTabView` | Tab bar with content switching, lazy loading, and swipe support |
| `OiMenuBar` | Horizontal menu bar with dropdown menus |
| `OiStatusBar` | Bottom status bar with leading/trailing widget slots |

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
    OiMenuItem(label: 'Profile', icon: OiIcons.user, onTap: () {}),
    OiMenuItem(label: 'Settings', icon: OiIcons.settings, onTap: () {}),
    OiMenuItem(label: 'Logout', icon: OiIcons.logOut, onTap: () {}),
  ],
)
```

### OiNavigationRail

A compact vertical navigation rail for persistent top-level navigation. The rail renders a narrow vertical strip with icon + label items, typically placed along the leading edge of a layout on medium and larger breakpoints.

```dart
OiNavigationRail(
  items: const [
    OiNavigationItem(icon: OiIcons.house, label: 'Home'),
    OiNavigationItem(icon: OiIcons.search, label: 'Search'),
    OiNavigationItem(icon: OiIcons.user, label: 'Profile'),
  ],
  currentIndex: _selectedIndex,
  onTap: (index) => setState(() => _selectedIndex = index),
)

// With leading logo and trailing settings
OiNavigationRail(
  items: navItems,
  currentIndex: _selectedIndex,
  onTap: (index) => setState(() => _selectedIndex = index),
  leading: OiImage(src: 'assets/logo.svg', label: 'Logo'),
  trailing: OiIconButton(icon: OiIcons.settings, onPressed: () {}),
  labelBehavior: OiRailLabelBehavior.selected,
)
```

**Key features:**

- Three label behaviors: `all` (always visible), `selected` (active item only), `none` (icon-only)
- Pill-shaped indicator behind the selected icon with animated transitions
- Badge overlay support via `OiNavigationItem.badge`
- Keyboard navigation with arrow keys and Enter/Space to activate
- Configurable width, group alignment, background, border, and elevation
- Tooltip support per item

**Related components:** `OiBottomBar`, `OiResponsiveShell`, `OiSidebar`

### OiSliverHeader

A sticky sliver header with support for collapsing, flexible space, and snap-to-position behaviour. Wraps `SliverPersistentHeader` with a convenient API for common app-bar patterns inside a `CustomScrollView`.

```dart
// Simple pinned header
CustomScrollView(
  slivers: [
    OiSliverHeader.simple(title: 'Messages'),
    SliverList.builder(
      delegate: SliverChildBuilderDelegate(
        (context, index) => MessageTile(messages[index]),
        childCount: messages.length,
      ),
    ),
  ],
)

// Large collapsing header with back button
OiSliverHeader.large(
  title: 'Settings',
  subtitle: 'Manage your preferences',
  onBack: () => Navigator.of(context).pop(),
  expandedHeight: 120,
)

// Hero header with flexible background
OiSliverHeader.hero(
  flexibleSpace: OiImage(src: coverUrl, label: 'Cover'),
  title: OiLabel.body('Album Title'),
  onBack: () => Navigator.of(context).pop(),
  expandedHeight: 200,
)
```

**Key features:**

- Three convenience constructors: `.simple()`, `.large()`, `.hero()`
- Pinned, floating, and snap behaviours
- Subtitle fades out as the header collapses
- Flexible space background with opacity transition
- Bottom border and shadow appear only when scrolled under content
- Configurable toolbar height, title spacing, and center title option

**Related components:** `OiBackButton`, `OiSliverList`, `OiSliverGrid`

### OiTabView

A tab bar with integrated content switching and transition animations. Combines `OiTabs` (the tab bar) with a content area that displays the widget built by the selected tab's builder.

```dart
// Uncontrolled (manages its own selection state)
OiTabView(
  tabs: [
    OiTabViewItem(label: 'Overview', builder: (_) => OverviewPage()),
    OiTabViewItem(label: 'Details', builder: (_) => DetailsPage()),
    OiTabViewItem(label: 'Activity', icon: OiIcons.activity, builder: (_) => ActivityPage()),
  ],
  onTabChanged: (index) => debugPrint('Tab $index selected'),
)

// Controlled (parent manages selection)
OiTabView.controlled(
  tabs: tabItems,
  selectedIndex: _currentTab,
  onTabChanged: (index) => setState(() => _currentTab = index),
  keepAlive: true,
  scrollable: true,
)
```

**Key features:**

- Two modes: uncontrolled (default) and controlled (`.controlled()`)
- Lazy content building via `OiTabViewItem.builder`
- `keepAlive: true` retains all tab content in an `IndexedStack`
- `keepAlive: false` (default) uses `AnimatedSwitcher` with fade transition
- `swipeable: true` (default) enables horizontal swipe between tabs
- Per-tab `enabled` flag, `icon`, and `badge` support
- `scrollable` tab bar for overflow
- Configurable `indicatorStyle`, `tabBarPadding`, `animationDuration`

**Related components:** `OiTabs`, `OiSegmentedControl`, `OiAccordion`

### OiMenuBar

Desktop horizontal menu bar with dropdown menus. Supports shortcuts, checked state, destructive items, nested sub-menus, and keyboard navigation.

```dart
OiMenuBar(
  label: 'Main menu',
  items: [
    OiMenuItem(
      label: 'File',
      children: [
        OiMenuItem(label: 'New', shortcut: 'Cmd+N', onTap: () {}),
        OiMenuItem(label: 'Open', shortcut: 'Cmd+O', onTap: () {}),
        const OiMenuDivider(),
        OiMenuItem(label: 'Save', shortcut: 'Cmd+S', onTap: () {}),
      ],
    ),
    OiMenuItem(
      label: 'Edit',
      children: [
        OiMenuItem(label: 'Undo', shortcut: 'Cmd+Z', onTap: () {}),
        OiMenuItem(label: 'Redo', shortcut: 'Cmd+Shift+Z', onTap: () {}),
      ],
    ),
  ],
)
```

**Key features:**

- Top-level items render as a horizontal row of text buttons
- Each top-level item opens a dropdown menu on hover or click
- Keyboard shortcut labels displayed right-aligned in menu items
- `OiMenuDivider` for visual grouping within menus
- Nested sub-menus via recursive `children`
- Checked state and destructive variant per item
- Full keyboard navigation: arrow keys, Enter to activate, Escape to close
- Focus management follows WAI-ARIA menu bar pattern

**Related components:** `OiContextMenu`, `OiNavMenu`, `OiCommandBar`

### OiStatusBar

Compact bottom status bar (default 24dp) for desktop interfaces. Provides leading and trailing widget slots for status information.

```dart
OiStatusBar(
  label: 'Application status',
  leading: [
    OiStatusBarItem(label: 'main', icon: OiIcons.gitBranch),
    OiStatusBarItem(label: 'UTF-8'),
  ],
  trailing: [
    OiStatusBarItem(label: 'Ln 42, Col 8'),
    OiStatusBarItem(label: 'Connected', color: Color(0xFF16A34A)),
  ],
)
```

**Key features:**

- Compact 24dp height for desktop IDE-style layouts
- Leading and trailing slots for flexible content placement
- `OiStatusBarItem` renders icon + label pairs with optional color override
- Themed background and border from `context.colors`
- Separator dots between items
- Clickable items via optional `onTap` callback

**Related components:** `OiMenuBar`, `OiAppShell`, `OiToolbar`

### OiDatePicker

A calendar date picker widget. Can be used inline or shown as a modal dialog via the static `show()` method that returns the selected date.

**Inline usage:**

```dart
OiDatePicker(
  value: _selectedDate,
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
  onChanged: (date) => setState(() => _selectedDate = date),
)
```

**Show as dialog (`Future<DateTime?>`):**

```dart
final date = await OiDatePicker.show(
  context,
  initialDate: DateTime.now(),
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
);

if (date != null) {
  setState(() => _selectedDate = date);
}
```

**Key features:**

- `OiDatePicker.show()` returns `Future<DateTime?>` — completes with `null` if dismissed without selection
- Uses `OiDialogShell` under the hood for consistent modal behavior
- Supports `firstDate` and `lastDate` constraints
- Optional `semanticLabel` parameter (defaults to "Select date")

**Related components:** `OiDateInput`, `OiTimePicker`, `OiDialogShell`

### OiTimePicker

A time selector widget with hour and minute wheels. Can be used inline or shown as a modal dialog via the static `show()` method.

**Inline usage:**

```dart
OiTimePicker(
  value: OiTimeOfDay(hour: 14, minute: 30),
  use24Hour: true,
  onChanged: (time) => setState(() => _selectedTime = time),
)
```

**Show as dialog (`Future<OiTimeOfDay?>`):**

```dart
final time = await OiTimePicker.show(
  context,
  initialTime: OiTimeOfDay(hour: 9, minute: 0),
  use24Hour: true,
);

if (time != null) {
  setState(() => _selectedTime = time);
}
```

**Key features:**

- `OiTimePicker.show()` returns `Future<OiTimeOfDay?>` — completes with `null` if dismissed without selection
- Uses `OiDialogShell` under the hood for consistent modal behavior
- `use24Hour` controls 0-23 vs 1-12 AM/PM display
- Optional `semanticLabel` parameter (defaults to "Select time")

**Related components:** `OiTimeInput`, `OiDatePicker`, `OiDialogShell`

## Overlays

| Widget | Description |
| --- | --- |
| `OiDialog` | Modal dialog |
| `OiSheet` | Bottom/side sheet |
| `OiToast` | Toast notification |
| `OiContextMenu` | Right-click / long-press context menu |
| `OiDialogShell` | Low-level dialog container with modal overlay |
| `OiSnackBar` | Brief action feedback bar with action button |

### OiToast

```dart
OiToast.show(
  context,
  message: 'File saved successfully',
  variant: OiToastVariant.success,
);
```

### OiDialog

A modal dialog overlay with five variants: `standard`, `alert`, `confirm`, `form`, and `fullScreen`. Provides both fire-and-forget and async show methods.

**Enhancement:** The `fullScreen` variant now supports responsive breakpoints, transitioning from a centered dialog on desktop to a true full-screen sheet on mobile. Use `OiDialog.fullScreen()` for content that benefits from maximum viewport usage (e.g. image editors, multi-step wizards, rich document previews).

**Showing a dialog (fire-and-forget):**

```dart
OiDialog.show(
  context,
  label: 'Confirm delete',
  dialog: OiDialog.confirm(
    label: 'Confirm delete',
    title: 'Delete item?',
    content: OiLabel.body('This action cannot be undone.'),
    onConfirm: () => deleteItem(),
    onCancel: () {},
  ),
);
```

**Showing a dialog and awaiting a result:**

The top-level `showOiDialog<T>()` function is the recommended way to show a dialog that returns a value. It replaces Material's `showDialog()` with zero Material dependency.

```dart
final confirmed = await showOiDialog<bool>(context, builder: (ctx, close) {
  return OiDialogShell(
    child: Padding(
      padding: EdgeInsets.all(ctx.spacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OiLabel.h4('Unsaved changes'),
          SizedBox(height: ctx.spacing.md),
          OiLabel.body('Discard your changes?'),
          SizedBox(height: ctx.spacing.lg),
          OiRow(gap: ctx.spacing.sm, children: [
            OiButton(label: 'Cancel', variant: OiButtonVariant.ghost, onPressed: () => close(false)),
            OiButton(label: 'Discard', variant: OiButtonVariant.destructive, onPressed: () => close(true)),
          ]),
        ],
      ),
    ),
  );
});

if (confirmed == true) navigator.pop();
```

**`OiDialog.showAsync<T>()` — pre-built variant with async result:**

```dart
final result = await OiDialog.showAsync<bool>(
  context,
  label: 'Confirm action',
  title: 'Are you sure?',
  content: OiLabel.body('This will apply changes.'),
  actions: [
    OiButton(label: 'Cancel', variant: OiButtonVariant.ghost, onPressed: () => Navigator.of(context).pop()),
    OiButton(label: 'Apply', onPressed: () => Navigator.of(context).pop(true)),
  ],
);
```

**Key features:**

- `showOiDialog<T>()` returns `Future<T?>` that completes when the dialog is dismissed
- Builder receives a `close` callback for returning values — call `close(value)` to dismiss and return
- `OiDialog.show()` returns `OiOverlayHandle` for programmatic dismissal (fire-and-forget)
- `OiDialog.showAsync<T>()` wraps the pre-built dialog variants with a `Future<T?>` return
- Works without Material dependency — uses `OiDialogShell` under the hood

**Related components:** `OiDialogShell`, `OiSheet`, `OiSnackBar`

### OiDialogShell

A minimal, themeable dialog container and the low-level building block used by higher-level dialog widgets such as `OiDialog`. The static `OiDialogShell.show` method presents the shell as a modal overlay with a barrier, focus-trapping, enter/exit animations, and Escape-to-dismiss behaviour.

```dart
// Show a custom dialog via the static method
final result = await OiDialogShell.show<bool>(
  context: context,
  builder: (close) => Padding(
    padding: EdgeInsets.all(context.spacing.lg),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OiLabel.h4('Confirm Action'),
        SizedBox(height: context.spacing.md),
        OiLabel.body('Are you sure you want to proceed?'),
        SizedBox(height: context.spacing.lg),
        OiRow(gap: context.spacing.sm, children: [
          OiButton(label: 'Cancel', variant: OiButtonVariant.ghost, onPressed: () => close(false)),
          OiButton(label: 'Confirm', onPressed: () => close(true)),
        ]),
      ],
    ),
  ),
);

// Inline usage as a container
OiDialogShell(
  padding: EdgeInsets.all(24),
  maxWidth: 400,
  child: myDialogContent,
)
```

**Key features:**

- Static `show<T>()` method returns a `Future<T?>` with the dialog result
- Scale + fade enter/exit animations with theme-driven durations
- Focus trapping and Escape key dismissal
- Configurable width constraints, background color, border radius, elevation, and padding
- Visual defaults read from `OiDialogShellThemeData`
- Barrier dismiss control via `barrierDismissible`

**Related components:** `OiDialog`, `OiSheet`, `OiFocusTrap`

### OiSnackBar

A transient notification bar with an optional action button. Unlike `OiToast` (which appears in a corner for passive notifications), `OiSnackBar` appears at the bottom or top of the screen and supports an interactive action (e.g. "Undo", "Retry"). Only one snack bar is shown at a time.

```dart
// Basic snack bar with action
OiSnackBar.show(
  context,
  message: 'Item deleted',
  actionLabel: 'Undo',
  onAction: () => _undoDelete(),
);

// With leading icon and top position
OiSnackBar.show(
  context,
  message: 'Connection restored',
  leading: Icon(OiIcons.wifi, size: 16, color: context.colors.textInverse),
  position: OiSnackBarPosition.top,
);
```

**Key features:**

- Static `show()` method replaces any currently visible snack bar
- Auto-dismisses after a configurable duration (default: 4 seconds)
- Swipe-to-dismiss when `dismissible` is true (default)
- Slide + fade enter/exit animations
- Top or bottom positioning via `OiSnackBarPosition`
- Optional leading widget (e.g. icon) and trailing action button
- Returns an `OiOverlayHandle` for programmatic dismissal

**Related components:** `OiToast`, `OiDialog`, `OiDialogShell`

### OiSheet

A bottom or side sheet overlay. Like `OiDialog`, it offers both a fire-and-forget `show()` and an async `showAsync<T>()` method.

**Fire-and-forget (returns `OiOverlayHandle`):**

```dart
final handle = OiSheet.show(
  context,
  label: 'Filter options',
  child: FilterPanel(),
);

// Dismiss programmatically later
handle.dismiss();
```

**Async with return value (`Future<T?>`):**

```dart
final selectedFilter = await OiSheet.showAsync<FilterConfig>(
  context,
  label: 'Filter options',
  builder: (close) => FilterPanel(
    onApply: (config) => close(config),
    onCancel: () => close(),
  ),
  side: OiPanelSide.bottom,
  dismissible: true,
  dragHandle: true,
);

if (selectedFilter != null) applyFilter(selectedFilter);
```

**Key features:**

- `OiSheet.show()` returns `OiOverlayHandle` for programmatic dismissal (fire-and-forget)
- `OiSheet.showAsync<T>()` returns `Future<T?>` that completes when the sheet is dismissed
- Builder receives a `close` callback — call `close(value)` to dismiss and return a result
- Supports `OiPanelSide.bottom`, `OiPanelSide.left`, `OiPanelSide.right`
- Optional `dragHandle`, `snapPoints`, and `size` parameters
- Scrim dismiss and Escape key handling

**Related components:** `OiDialog`, `OiDialogShell`, `OiPanel`

## Panels

| Widget | Description |
| --- | --- |
| `OiPanel` | Sliding side panel |
| `OiResizable` | Resizable container |
| `OiSplitPane` | Draggable splitter between two children |
| `OiPanelHeader` | Titled header bar for panels with leading/trailing slots, subtitle, 3 sizes, border options |

## Feedback

| Widget | Description |
| --- | --- |
| `OiStarRating` | Star rating (1-5) |
| `OiScaleRating` | Numeric scale (1-10) |
| `OiSentiment` | Mood/emoji selector |
| `OiThumbs` | Thumbs up/down |
| `OiReactionBar` | Emoji reaction bar |
| `OiBulkBar` | Floating toolbar for bulk actions on selected items |
| `OiPipelineProgress` | Sequential step progress indicator with checkmarks, spinners, error/retry |

### OiPipelineProgress

Vertical multi-step progress indicator for sequential operations. Each step shows its state (pending, active with spinner, completed with checkmark, or errored with retry). Ideal for build pipelines, export flows, and multi-stage processes.

```dart
OiPipelineProgress(
  label: 'Export progress',
  steps: [
    OiPipelineProgressStep(label: 'Validating schema...'),
    OiPipelineProgressStep(label: 'Generating assets...'),
    OiPipelineProgressStep(label: 'Uploading to CDN...'),
  ],
  currentStepIndex: 1,
  onCancel: () {},
)
```

**Key features:**

- Four step states: pending (dimmed), active (spinner), completed (checkmark), error (red with retry)
- Vertical connector lines between steps
- `onCancel` shows a cancel button at the bottom
- `onRetry` per step for error recovery
- Animated transitions between step states
- Accessible step announcements via semantics

**Related components:** `OiProgress`, `OiStepper`, `OiPipeline`

### OiBanner

**Enhancement:** `OiBanner.loading()` -- A new factory constructor that displays a persistent banner with an animated progress indicator and message. Useful for indicating background operations or loading states that span the full width of a container.

```dart
OiBanner.loading(
  label: 'Syncing data',
  message: 'Syncing your changes with the server...',
)
```

## Inline Edit

| Widget | Description |
| --- | --- |
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
| --- | --- |
| `OiDeleteDialog` | Delete confirmation dialog |
| `OiRenameDialog` | Rename dialog |
| `OiMoveDialog` | Move/copy file dialog |
| `OiNewFolderDialog` | Create folder dialog |
| `OiUploadDialog` | Upload progress dialog |
| `OiFileInfoDialog` | File details display |

## Shop

| Widget | Description |
| --- | --- |
| `OiPriceTag` | Formatted price display with optional compare-at strikethrough and currency symbol |
| `OiQuantitySelector` | Number stepper with minus/plus buttons for product quantities |
| `OiCartItemRow` | Cart line item row with thumbnail, quantity selector, price, and remove |
| `OiCouponInput` | Coupon/promo code input with apply button and success/error states |
| `OiOrderSummaryLine` | Single summary row (subtotal, discount, shipping, tax, total) |
| `OiProductCard` | Product display card with image, price, rating, and quick actions |
| `OiPaymentOption` | Selectable payment method row with radio indicator |
| `OiShippingOption` | Selectable shipping method row with price and radio indicator |
| `OiStockBadge` | Stock status badge (in stock / low stock / out of stock) |
| `OiWishlistButton` | Heart toggle button for wishlist/favorite functionality |
| `OiAddressForm` | Standardized address form with responsive layout and country/state dropdowns |
| `OiShippingMethodPicker` | Radio-style selector for shipping methods with loading state |
| `OiPaymentMethodPicker` | Payment method selector with optional add-new-card slot |
| `OiOrderStatusBadge` | Color-coded order status badge with i18n support |

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

### OiCartItemRow

A single line item row for the shopping cart showing thumbnail, name, variant info, quantity selector, line total, and remove button.

```dart
OiCartItemRow(
  item: cartItem,
  label: 'Widget A × 2',
  currencyCode: 'EUR',
  onQuantityChange: (qty) => updateQuantity(cartItem.productKey, qty),
  onRemove: () => removeItem(cartItem.productKey),
)

// Compact mode for mini-cart overlays
OiCartItemRow(
  item: cartItem,
  label: 'Widget A × 2',
  compact: true,
  currencyCode: 'EUR',
  onRemove: () => removeItem(cartItem.productKey),
)

// Read-only mode for order confirmation
OiCartItemRow(
  item: cartItem,
  label: 'Widget A × 2',
  editable: false,
  currencyCode: 'EUR',
)
```

**Key features:**

- Swipe-to-remove on mobile via `OiSwipeable`
- Compact mode for dense layouts (mini-cart)
- Non-editable mode hides quantity selector and remove button
- Thumbnail placeholder when no image URL provided

### OiCouponInput

Text input with 'Apply' button for discount/coupon codes. Shows inline success or error feedback.

```dart
// Input mode
OiCouponInput(
  label: 'Coupon code',
  onApply: (code) async {
    final valid = await api.validateCoupon(code);
    return OiCouponResult(valid: valid, message: valid ? null : 'Invalid code');
  },
  onRemove: () => removeCoupon(),
  appliedCode: currentCoupon,
)
```

**Key features:**

- Empty submit prevented (button disabled)
- Applied mode shows green check, bold code, and remove button
- Error messages shown inline in red
- Loading state on Apply button during validation

### OiOrderSummaryLine

A label + amount row for checkout summaries. Supports bold total styling, discount coloring, shimmer loading, and optional subtitles.

```dart
// Subtotal line
OiOrderSummaryLine(label: 'Subtotal', amount: 100.00, currencyCode: 'EUR')

// Discount line (green, negative)
OiOrderSummaryLine(
  label: 'Discount',
  amount: 10.00,
  currencyCode: 'EUR',
  negative: true,
  subtitle: 'SUMMER20',
)

// Bold total line
OiOrderSummaryLine(
  label: 'Total',
  amount: 114.00,
  currencyCode: 'EUR',
  bold: true,
)

// Loading state
OiOrderSummaryLine(label: 'Shipping', amount: 0, loading: true)
```

### OiProductCard

Product display card for grid/list layouts with image, name, price, rating, badges, and quick-action buttons.

```dart
// Vertical card (for grids)
OiProductCard(
  product: productData,
  label: 'Product name',
  onTap: () => navigateToProduct(productData.key),
  onAddToCart: () => addToCart(productData.key),
)

// Horizontal card (for list views)
OiProductCard.horizontal(
  product: productData,
  label: 'Product name',
  onTap: () => navigateToProduct(productData.key),
  onAddToCart: () => addToCart(productData.key),
  showWishlist: true,
  onWishlist: () => toggleWishlist(productData.key),
)

// Skeleton loading
OiProductCard(product: emptyProduct, label: 'Loading', isLoading: true)
```

**Key features:**

- Three variants: vertical (grid), horizontal (list), compact (dense)
- "Sale" badge when `compareAtPrice > price`
- "Out of Stock" badge when `inStock` is false (disables add-to-cart)
- Star rating with review count
- Skeleton loading state via `OiShimmer`

### OiPaymentOption

Selectable payment method row with radio indicator for checkout flows.

```dart
OiPaymentOption(
  method: OiPaymentMethod(label: 'Credit Card', description: 'Visa ending in 4242'),
  label: 'Payment method',
  selected: true,
  onSelect: (method) => setState(() => _payment = method),
)
```

### OiShippingOption

Selectable shipping method row with price display and radio indicator.

```dart
OiShippingOption(
  method: OiShippingMethod(label: 'Express', price: 9.99, estimatedDays: '1-2 days'),
  label: 'Shipping method',
  selected: false,
  onSelect: (method) => setState(() => _shipping = method),
  currencyCode: 'EUR',
)
```

### OiStockBadge

Stock status badge showing availability with color coding: green (in stock), amber (low stock), red (out of stock).

```dart
// Explicit status
OiStockBadge(status: OiStockStatus.inStock, label: 'Availability')

// Auto-determine from count
OiStockBadge.fromCount(stockCount: 3, label: 'Availability', lowStockThreshold: 5)
```

### OiWishlistButton

Heart toggle button for wishlist/favorite functionality with spring animation.

```dart
OiWishlistButton(
  label: 'Add to wishlist',
  active: isWishlisted,
  onToggle: () => toggleWishlist(productId),
)
```

### OiAddressForm

A standardized, reusable address form with fields for name, company, address lines, city, state/province, postal code, country, and phone. Responsive layout adapts between side-by-side and stacked fields based on breakpoint.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | required | Accessibility label |
| `initialValue` | `OiAddressData?` | `null` | Initial address to pre-fill fields |
| `onChange` | `ValueChanged<OiAddressData>?` | `null` | Called on any field change with updated address |
| `onSubmit` | `ValueChanged<OiAddressData>?` | `null` | Called when form is submitted |
| `countries` | `List<OiCountryOption>?` | `null` | Country options for dropdown; state dropdown auto-appears for countries with states |
| `showCompany` | `bool` | `true` | Whether to show company field |
| `showPhone` | `bool` | `true` | Whether to show phone field |
| `showName` | `bool` | `true` | Whether to show first/last name fields |
| `readOnly` | `bool` | `false` | Whether all fields are read-only |
| `error` | `String?` | `null` | Error message displayed below the form |

```dart
OiAddressForm(
  label: 'Shipping address',
  initialValue: savedAddress,
  countries: countryOptions,
  onChange: (address) => setState(() => _address = address),
)
```

**Factory constructors:** `OiAddressForm.shipping()` (pre-labelled "Shipping address"), `OiAddressForm.billing()` (pre-labelled "Billing address").

**Related components:** `OiCheckout`, `OiForm`, `OiTextInput`, `OiSelect`

### OiShippingMethodPicker

A radio-style selector that renders a list of `OiShippingOption` widgets with managed single-selection. Supports shimmer loading state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `methods` | `List<OiShippingMethod>` | required | Available shipping methods |
| `label` | `String` | required | Accessibility label for the group |
| `selectedKey` | `Object?` | `null` | Key of the currently selected method |
| `onSelect` | `ValueChanged<OiShippingMethod>?` | `null` | Called when user selects a method |
| `currencyCode` | `String` | `'EUR'` | ISO 4217 currency code |
| `loading` | `bool` | `false` | Show shimmer loading placeholders |

```dart
OiShippingMethodPicker(
  methods: shippingMethods,
  label: 'Shipping method',
  selectedKey: selectedShipping?.key,
  onSelect: (method) => setState(() => _shipping = method),
  currencyCode: 'EUR',
)
```

**Related components:** `OiShippingOption`, `OiCheckout`, `OiCard`

### OiPaymentMethodPicker

A selector for payment methods that renders `OiPaymentOption` widgets with managed single-selection. Optionally displays an "Add new card" slot below the options.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `methods` | `List<OiPaymentMethod>` | required | Available payment methods |
| `label` | `String` | required | Accessibility label for the group |
| `selectedKey` | `Object?` | `null` | Key of the currently selected method |
| `onSelect` | `ValueChanged<OiPaymentMethod>?` | `null` | Called when user selects a method |
| `addNewCard` | `Widget?` | `null` | Optional widget below options, separated by divider |

```dart
OiPaymentMethodPicker(
  methods: paymentMethods,
  label: 'Payment method',
  selectedKey: selectedPayment?.key,
  onSelect: (method) => setState(() => _payment = method),
  addNewCard: OiButton(label: 'Add new card', onPressed: () => showAddCard()),
)
```

**Related components:** `OiPaymentOption`, `OiCheckout`, `OiCard`

### OiOrderStatusBadge

A badge that displays `OiOrderStatus` with appropriate color coding. Default color mapping: pending (warning), confirmed (info), processing (info), shipped (primary), delivered (success), cancelled (error), refunded (muted).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `status` | `OiOrderStatus` | required | The order status to display |
| `label` | `String` | required | Accessibility label |
| `statusLabels` | `Map<OiOrderStatus, String>?` | `null` | Optional i18n overrides for display text |
| `statusColors` | `Map<OiOrderStatus, Color>?` | `null` | Optional color overrides per status |

```dart
OiOrderStatusBadge(
  status: order.status,
  label: 'Order status',
)

// With i18n overrides
OiOrderStatusBadge(
  status: order.status,
  label: 'Bestellstatus',
  statusLabels: {
    OiOrderStatus.pending: 'Ausstehend',
    OiOrderStatus.delivered: 'Zugestellt',
  },
)
```

**Factory constructors:** `OiOrderStatusBadge.soft()`, `OiOrderStatusBadge.filled()`, `OiOrderStatusBadge.fromOrder({required OiOrderData order})`.

**Related components:** `OiOrderTracker`, `OiTable`, `OiDetailView`, `OiBadge`

### OiBulkBar

Floating toolbar that appears when items are selected, showing selection count and bulk action buttons.

```dart
OiBulkBar(
  selectedCount: 5,
  totalCount: 100,
  label: 'Bulk actions',
  actions: [
    OiBulkAction(label: 'Export', icon: OiIcons.download, onTap: () => export()),
    OiBulkAction(label: 'Delete', icon: OiIcons.trash2, onTap: () => delete(), variant: OiBulkActionVariant.destructive),
  ],
  onSelectAll: () => selectAll(),
  onDeselectAll: () => deselectAll(),
)
```

### OiPagination

Standalone pagination control with three variants: full pages, compact, and load-more.

```dart
// Full pagination
OiPagination(
  totalItems: 250,
  currentPage: 3,
  label: 'items',
  perPage: 25,
  onPageChange: (page) => setState(() => _page = page),
  onPerPageChange: (perPage) => setState(() => _perPage = perPage),
)

// Compact
OiPagination.compact(totalItems: 250, currentPage: 3, label: 'items', perPage: 25, onPageChange: (p) {})

// Load more
OiPagination.loadMore(loadedCount: 50, totalItems: 250, label: 'items', onLoadMore: () async => loadMore())
```

### OiLocaleSwitcher

Locale/language dropdown selector with optional flag emoji support.

```dart
OiLocaleSwitcher(
  currentLocale: Locale('en'),
  locales: [
    OiLocaleOption(locale: Locale('en'), name: 'English', flagEmoji: '🇬🇧'),
    OiLocaleOption(locale: Locale('de'), name: 'Deutsch', flagEmoji: '🇩🇪'),
    OiLocaleOption(locale: Locale('fr'), name: 'Français', flagEmoji: '🇫🇷'),
  ],
  onLocaleChange: (locale) => setLocale(locale),
)
```

## Interaction

| Widget | Description |
| --- | --- |
| `OiSelectionOverlay` | Multi-selection UI overlay |
| `OiKbd` | Keyboard shortcut display with platform-specific glyph mapping |

### OiPanelHeader

Titled header bar for use inside `OiSplitPane`, `OiPanel`, `OiResizable`, or any panel-like container. Shows a label with optional subtitle, leading/trailing slots, and configurable size and borders.

```dart
OiPanelHeader(
  label: 'Properties',
  subtitle: '12 items',
  trailing: OiIconButton(icon: OiIcons.settings, semanticLabel: 'Settings'),
  size: OiPanelHeaderSize.compact,
  border: OiPanelHeaderBorder.bottom,
)
```

**Key features:**

- Three sizes: compact (32px), medium (48px, default), large (64px)
- Three border modes: none, bottom (default), all
- Optional `onTap` wraps content in `OiTappable` with hover/focus states
- Optional `backgroundColor` override
- Semantic header role for accessibility

**Related components:** `OiPanel`, `OiSplitPane`, `OiResizable`, `OiPropertyGrid`

### OiStatusDot

Semantic live-status indicator dot with optional pulse animation. Use `OiStatusDot.active()` for a boolean on/off shorthand.

```dart
// Explicit variant
OiStatusDot(label: 'Service health', variant: OiStatusVariant.success, pulsing: true)

// Boolean shorthand
OiStatusDot.active(active: isOnline, label: 'Connection status')
```

**Key features:**

- Six semantic variants: success (green), warning (amber), error (red), info (blue), neutral, muted
- Optional `color` override takes precedence over variant
- Configurable `size` (default 8px diameter)
- `pulsing` enables OiPulse glow animation
- `OiStatusDot.active()` factory: `active: true` -> success + pulse, `active: false` -> muted

**Related components:** `OiAvatar` (presence), `OiWorkflowTree`, `OiPipeline`, `OiStatusBar`

### OiKbd

Displays a sequence of keyboard keys as styled chips with platform-specific glyph mapping. For example, `meta` renders as the command symbol on Apple and `Ctrl` elsewhere.

```dart
OiKbd(keys: const ['meta', 'shift', 'K'])
// Apple:  ⌘  ⇧  K
// Other: Ctrl Shift K
```

**Key features:**

- Recognised keys: `meta`/`cmd`, `ctrl`, `shift`, `alt`/`option`, `enter`, `tab`, `esc`, `backspace`, `delete`, `up`, `down`, `left`, `right`, `space`
- Unrecognised strings pass through capitalised
- Styled with theme tokens: `surfaceHover` background, `borderSubtle` border, `radius.xs`
- Semantic label auto-generated from key names joined with ` + `

**Related components:** `OiCommandBar`, `OiMenuBar`, `OiTooltip`, `OiShortcutScope`
