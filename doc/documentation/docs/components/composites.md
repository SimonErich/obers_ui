# Composites

Composites combine multiple components into complex UI patterns. They handle interactions, state management, and data flow so you don't have to wire everything together yourself.

## Data

| Widget | Description |
|---|---|
| `OiTable` | Full data table with sort, filter, resize, paginate, inline edit, column management |
| `OiTree` | Hierarchical tree view with expand/collapse |
| `OiReorderableList` | Drag-to-reorder list with drag handles, long-press, and keyboard support |
| `OiDataGrid` | Lightweight data grid with sorting, selection, striped rows, and loading states |

### OiTable

The flagship composite. Handles everything from simple lists to 100k-row enterprise tables:

```dart
OiTable<User>(
  columns: [
    OiTableColumn(
      id: 'name',
      header: 'Name',
      cellBuilder: (user) => Text(user.name),
      sortable: true,
    ),
    OiTableColumn(
      id: 'email',
      header: 'Email',
      cellBuilder: (user) => Text(user.email),
    ),
    OiTableColumn(
      id: 'role',
      header: 'Role',
      cellBuilder: (user) => OiBadge.soft(label: user.role),
    ),
  ],
  rows: users,
  onSort: (columnId, ascending) { /* ... */ },
)
```

**Key features:**

- Virtual scrolling (100k+ rows)
- Column resizing, reordering, visibility toggle, freeze
- Inline editing with per-column type hints
- Four pagination modes: pages, load more, infinite, cursor
- Settings persistence (column widths, sort, filters auto-saved)
- Row selection (single/multi), expansion, reordering
- Status bar with aggregations
- Column groups (spanning headers)

### OiReorderableList

A drag-to-reorder list that supports drag handles, long-press drag, keyboard reordering, and animated gap insertion.

```dart
OiReorderableList<Task>(
  items: tasks,
  itemBuilder: (context, task, index, dragHandle) {
    return OiRow(children: [
      if (dragHandle != null) dragHandle,
      Expanded(child: OiLabel.body(task.title)),
    ]);
  },
  onReorder: (oldIndex, newIndex) {
    setState(() {
      final item = tasks.removeAt(oldIndex);
      tasks.insert(newIndex, item);
    });
  },
)

// Long-press drag without handle
OiReorderableList<String>(
  items: items,
  itemBuilder: (context, item, index, _) => OiListTile(title: item),
  onReorder: (from, to) => reorder(from, to),
  dragHandle: false,
  longPressDrag: true,
  separator: const OiDivider(),
)
```

**Key features:**

- Three drag modes: drag handle (default), long-press drag, immediate drag
- Keyboard reordering: Space to pick up, Arrow keys to move, Enter to drop, Escape to cancel
- Animated gap insertion on hover during drag
- `OiDragGhost` feedback widget during drag
- Optional `separator` between items
- `canReorder` predicate to lock specific items
- `shrinkWrap` mode for use inside `Column` or other unbounded containers
- Vertical and horizontal axis support
- `onDragStart` / `onDragEnd` callbacks

**Related components:** `OiTable`, `OiDraggable`, `OiDropZone`, `OiReorderable`

### OiDataGrid

A lightweight data grid for displaying tabular data with sorting, row selection, striped rows, dense mode, and loading states. A simpler alternative to `OiTable` when you don't need virtual scrolling, column resizing, or pagination.

```dart
OiDataGrid<User>(
  rows: users,
  columns: [
    OiDataGridColumn.text(id: 'name', header: 'Name', valueOf: (u) => u.name, sortable: true),
    OiDataGridColumn.text(id: 'email', header: 'Email', valueOf: (u) => u.email),
    OiDataGridColumn(
      id: 'role',
      header: 'Role',
      cellBuilder: (context, user, index) => OiBadge.soft(label: user.role),
    ),
  ],
  sortColumnId: 'name',
  sortAscending: true,
  onSort: (columnId, {required ascending}) {
    setState(() {
      _sortColumn = columnId;
      _ascending = ascending;
    });
  },
  selectable: true,
  multiSelect: true,
  selectedRows: _selected,
  onSelectionChanged: (rows) => setState(() => _selected = rows),
  striped: true,
)
```

**Key features:**

- Two column types: custom `cellBuilder` and `.text()` shorthand for string values
- Sortable columns with chevron indicators in the header
- Single or multi-select with checkbox column
- Header-level "select all" checkbox for multi-select
- Three header styles: `filled`, `plain`, `none`
- Striped alternate rows and dense mode (36dp vs 48dp row height)
- Optional outer border with theme radius
- Shimmer skeleton loading state
- Custom empty state widget (defaults to "No data")
- Fixed-width, min-width, and flex column sizing

**Related components:** `OiTable`, `OiReorderableList`, `OiVirtualList`

## Forms

| Widget | Description |
|---|---|
| `OiForm` | Form container with validation |
| `OiStepper` | Step-by-step form |
| `OiWizard` | Multi-page wizard with progress |
| `OiFormDialog` | Form dialog with managed lifecycle (loading, error, submit states) |

### OiForm

```dart
OiForm(
  onSubmit: (values) async {
    await api.save(values);
  },
  children: [
    OiTextInput(label: 'Name', name: 'name'),
    OiSelect(label: 'Role', name: 'role', items: roles),
    OiButton(label: 'Submit', type: OiButtonType.submit),
  ],
)
```

### OiFormDialog

A static utility for showing form dialogs with a managed lifecycle. The dialog provides a title, custom form content, an optional error area, and cancel/submit action buttons. State (loading, error, submit-enabled) is managed through an `OiFormDialogController`.

```dart
final result = await OiFormDialog.showCustom<String>(
  context,
  title: 'Create Item',
  builder: (controller) {
    var name = '';
    return OiTextInput(
      label: 'Name',
      onChanged: (v) {
        name = v ?? '';
        controller.setSubmitEnabled(enabled: name.isNotEmpty);
      },
    );
  },
);

// With error handling and loading
final user = await OiFormDialog.showCustom<User>(
  context,
  title: 'Edit Profile',
  submitLabel: 'Save',
  cancelLabel: 'Discard',
  builder: (controller) {
    return ProfileForm(
      onSave: (data) async {
        controller.setLoading(loading: true);
        try {
          final user = await api.updateProfile(data);
          await controller.submit(user);
        } catch (e) {
          controller.setError('Failed to save: $e');
          controller.setLoading(loading: false);
        }
      },
    );
  },
);
```

**Key features:**

- `OiFormDialogController<T>` manages loading, error, and submit-enabled states
- `controller.submit(result)` closes dialog and returns the result
- `controller.cancel()` dismisses without a result
- `controller.setError(message)` shows inline error between content and action buttons
- `controller.setLoading(loading: true)` shows spinner on submit button and blocks dismissal
- Uses `OiDialogShell` under the hood for consistent modal behavior
- Configurable `submitLabel`, `cancelLabel`, `dismissible`, `maxWidth`

**Related components:** `OiDialog`, `OiDialogShell`, `OiForm`

## Editors

| Widget | Description |
|---|---|
| `OiRichEditor` | Rich text editor with markdown support |
| `OiSmartInput` | Smart input with mentions and autocomplete |

## Navigation

| Widget | Description |
|---|---|
| `OiSidebar` | Collapsible sidebar with sections |
| `OiNavMenu` | Navigation menu |
| `OiFilterBar` | Advanced filter bar with chips |
| `OiFileToolbar` | File actions toolbar |
| `OiArrowNav` | Previous/next navigation |
| `OiShortcuts` | Keyboard shortcut hint display |
| `OiErrorPage` | Full-page error display for 404, 403, 500 states |
| `OiResponsiveShell` | Responsive navigation shell that auto-switches between OiBottomBar and OiNavigationRail |

### OiResponsiveShell

A responsive navigation shell that automatically switches between `OiBottomBar`, `OiNavigationRail` (compact), and `OiNavigationRail` (expanded with labels) based on viewport width. The consumer only needs to manage one list of `OiNavigationItem` items.

```dart
OiResponsiveShell(
  items: const [
    OiNavigationItem(icon: OiIcons.house, label: 'Home'),
    OiNavigationItem(icon: OiIcons.search, label: 'Search'),
    OiNavigationItem(icon: OiIcons.user, label: 'Profile'),
  ],
  currentIndex: _selectedIndex,
  onTap: (index) => setState(() => _selectedIndex = index),
  body: _pages[_selectedIndex],
)

// With custom breakpoints and rail options
OiResponsiveShell(
  items: navItems,
  currentIndex: _selectedIndex,
  onTap: (index) => setState(() => _selectedIndex = index),
  body: _pages[_selectedIndex],
  breakpoints: OiResponsiveShellBreakpoints(rail: 700, expanded: 1400),
  railLeading: OiImage(src: 'assets/logo.svg', label: 'Logo'),
  railTrailing: OiIconButton(icon: OiIcons.settings, onPressed: () {}),
)
```

**Layout modes:**

| Viewport width | Navigation widget |
|---|---|
| Below rail threshold | `OiBottomBar` at the bottom |
| Rail to expanded | `OiNavigationRail` (icon only) |
| At or above expanded | `OiNavigationRail` (icon + label) |

**Key features:**

- Three layout modes driven by configurable `OiResponsiveShellBreakpoints` (default: 600 / 1200)
- Animated width transition between compact and expanded rail
- Floating action widget support across all modes
- Per-mode customization: rail width, background, border, indicator, label behavior, group alignment
- Bottom bar style, label visibility, and haptic feedback options
- `resolveMode(width)` pure function for testing and conditional logic

**Related components:** `OiBottomBar`, `OiNavigationRail`, `OiSidebar`

## Search

| Widget | Description |
|---|---|
| `OiSearch` | Full-text search with results |
| `OiCommandBar` | Ctrl+K command palette |
| `OiComboBox` | Searchable dropdown |

### OiCommandBar

A power-user favorite — the Ctrl+K command palette:

```dart
OiCommandBar(
  commands: [
    OiCommand(label: 'Go to Dashboard', action: () => navigate('/dashboard')),
    OiCommand(label: 'Create New File', action: () => createFile()),
    OiCommand(label: 'Toggle Dark Mode', action: () => toggleTheme()),
  ],
)
```

## Files

| Widget | Description |
|---|---|
| `OiFileDropTarget` | Drag-and-drop file zone |
| `OiFileGridView` | Grid file browser |
| `OiFileListView` | List file browser |
| `OiFileSidebar` | File tree navigation |

## Media

| Widget | Description |
|---|---|
| `OiGallery` | Image/media grid |
| `OiLightbox` | Full-screen image viewer |
| `OiVideoPlayer` | Video player with controls |
| `OiImageCropper` | Image crop interface |
| `OiImageAnnotator` | Image markup tool |

## Visualization

| Widget | Description |
|---|---|
| `OiHeatmap` | 2D heat grid |
| `OiRadarChart` | Radar/spider chart |
| `OiFunnelChart` | Funnel/conversion chart |
| `OiGauge` | Circular gauge dial |
| `OiSankey` | Flow diagram |
| `OiTreemap` | Nested rectangles |

All visualization widgets use the `context.colors.chart` palette by default.

## Scheduling

| Widget | Description |
|---|---|
| `OiCalendar` | Day/week/month calendar view |
| `OiTimeline` | Chronological timeline |
| `OiGantt` | Gantt chart |

## Social

| Widget | Description |
|---|---|
| `OiAvatarStack` | Overlapping avatar group |
| `OiCursorPresence` | Live cursor position display |
| `OiLiveRing` | Live/active status indicator |
| `OiSelectionPresence` | User selection highlighting |
| `OiTypingIndicator` | "User is typing..." animation |

## Onboarding

| Widget | Description |
|---|---|
| `OiTour` | Multi-step guided tour |
| `OiSpotlight` | Feature highlight overlay |
| `OiWhatsNew` | Release notes dialog |

### OiTour

```dart
OiTour(
  steps: [
    OiTourStep(
      target: sidebarKey,
      title: 'Navigation',
      body: 'Use the sidebar to browse files.',
    ),
    OiTourStep(
      target: searchKey,
      title: 'Search',
      body: 'Press Ctrl+K to search anything.',
    ),
  ],
)
```

## Shop Composites

| Widget | Description |
|---|---|
| `OiCartPanel` | Full shopping cart view with items, coupon, summary, checkout |
| `OiMiniCart` | Compact cart icon with badge and popover/sheet preview |
| `OiOrderSummary` | Order summary card with totals and optional expandable item list |
| `OiOrderTracker` | Visual order status stepper with optional event timeline |

### OiCartPanel

Full shopping cart view with item list, optional coupon input, order summary lines, checkout button, and continue-shopping link. Shows empty state when cart has no items.

```dart
OiCartPanel(
  items: cartItems,
  summary: cartSummary,
  label: 'Shopping cart',
  onQuantityChange: (record) => updateQty(record.productKey, record.quantity),
  onRemove: (key) => removeItem(key),
  onApplyCoupon: (code) async => await validateCoupon(code),
  onRemoveCoupon: () => removeCoupon(),
  appliedCouponCode: currentCoupon,
  onCheckout: () => navigateToCheckout(),
  onContinueShopping: () => navigateToShop(),
  currencyCode: 'EUR',
)
```

**Key features:**

- Empty cart shows `OiEmptyState` with cart icon
- Coupon section hidden when `onApplyCoupon` is null
- Summary lines conditionally show discount, shipping, tax
- Checkout button disabled when `onCheckout` is null
- Shimmer loading on summary lines via `loading: true`

### OiMiniCart

Compact cart widget with badge count that opens a popover or sheet showing a condensed cart preview.

```dart
OiMiniCart(
  items: cartItems,
  summary: cartSummary,
  label: 'Cart',
  onViewCart: () => navigateToCart(),
  onCheckout: () => navigateToCheckout(),
  onRemove: (key) => removeItem(key),
  maxVisibleItems: 3,
)
```

**Key features:**

- Badge shows total quantity; hidden when cart is empty
- Overflow indicator: "X more item(s)" when items exceed `maxVisibleItems`
- Two display modes: `popover` (default) and `sheet`
- Empty state shows "Cart is empty"

### OiOrderSummary

Complete order summary card with all line items and optional expandable item list.

```dart
OiOrderSummary(
  summary: cartSummary,
  label: 'Order summary',
  items: cartItems,
  expandedByDefault: false,
  currencyCode: 'EUR',
)
```

**Key features:**

- Items shown in collapsible `OiAccordion` section
- Read-only `OiCartItemRow` widgets (no quantity/remove controls)
- Conditional discount, shipping, tax lines
- Bold total row

### OiProductFilters

A filter panel for product listings with price range, category checkboxes, rating slider, and in-stock toggle.

```dart
OiProductFilters(
  value: currentFilters,
  onChanged: (filters) => setState(() => currentFilters = filters),
  label: 'Product filters',
  categories: [
    OiFilterCategory(key: 'electronics', label: 'Electronics'),
    OiFilterCategory(key: 'clothing', label: 'Clothing'),
  ],
  priceRange: OiPriceRange(min: 0, max: 500),
)
```

**Key features:**

- Price range with `OiSlider` for min/max
- Category checkboxes for multi-select filtering
- Rating slider for minimum rating filter
- In-stock toggle with `OiSwitch`
- Immutable `OiProductFilterData` model with `copyWith`

### OiProductGallery

An image gallery with a main image display and optional horizontal thumbnail strip for product detail pages.

```dart
OiProductGallery(
  imageUrls: ['https://example.com/img1.jpg', 'https://example.com/img2.jpg'],
  label: 'Product gallery',
  initialIndex: 0,
  onIndexChanged: (index) => handleGalleryChange(index),
  showThumbnails: true,
)
```

**Key features:**

- Large main image with `OiImage` component
- Horizontal thumbnail strip with selected state highlighting
- Placeholder icon when no images are available
- Clamped index to prevent out-of-bounds
- Responsive layout via `OiColumn`

### OiOrderTracker

A visual order status tracker showing progression through order statuses (pending → confirmed → processing → shipped → delivered) as a horizontal stepper. Cancelled and refunded are rendered as terminal states using `OiOrderStatusBadge`. Optionally displays an expandable timeline of order events.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `currentStatus` | `OiOrderStatus` | required | The current order status to highlight |
| `label` | `String` | required | Accessibility label |
| `timeline` | `List<OiOrderEvent>?` | `null` | Chronological list of order events |
| `showTimeline` | `bool` | `false` | Whether to show timeline section below stepper |
| `statusLabels` | `Map<OiOrderStatus, String>?` | `null` | Custom labels for each status step |

```dart
// Basic tracker
OiOrderTracker(
  currentStatus: OiOrderStatus.shipped,
  label: 'Order progress',
)

// With timeline
OiOrderTracker(
  currentStatus: OiOrderStatus.delivered,
  label: 'Order progress',
  showTimeline: true,
  timeline: [
    OiOrderEvent(
      status: OiOrderStatus.delivered,
      title: 'Package delivered',
      timestamp: DateTime(2026, 3, 22, 14, 30),
    ),
    OiOrderEvent(
      status: OiOrderStatus.shipped,
      title: 'Package shipped',
      description: 'Tracking: 1Z999AA10123456784',
      timestamp: DateTime(2026, 3, 20, 9, 0),
    ),
  ],
)
```

**Key features:**

- 5 happy-path steps with completion markers
- Terminal states (cancelled/refunded) rendered via `OiOrderStatusBadge`
- Collapsible timeline section with colored event dots
- Events rendered via `OiTimeline` with status-based colors

**Factory constructors:** `OiOrderTracker.compact({required OiOrderData order})` — extracts status and timeline from order, shows stepper only (no timeline).

**Related components:** `OiOrderStatusBadge`, `OiOrderSummary`, `OiStepper`, `OiTimeline`

## Workflow

| Widget | Description |
|---|---|
| `OiFlowGraph` | Node-edge graph editor |
| `OiPipeline` | Linear stage pipeline |
| `OiStateDiagram` | State machine visualization |
