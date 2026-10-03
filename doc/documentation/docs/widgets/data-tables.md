# Data & Tables

These widgets show structured data: rows and columns, grouped lists, hierarchies,
and single-record detail views. Pick the lightest one that fits. A read-only list
does not need a full table, and a settings panel does not need a data grid.

| Widget | What it does |
| --- | --- |
| `OiTable` | The full data table. Sort, filter, paginate, resize, reorder, inline edit. |
| `OiDataGrid` | A lighter table for read-only display with optional sort and select. |
| `OiPropertyGrid` | A two-column inspector with a draggable divider (label, editor). |
| `OiGroupedList` | A list that groups items into sections with sticky, collapsible headers. |
| `OiReorderableList` | A drag-to-reorder list with handles, long-press, and keyboard support. |
| `OiTree` | A hierarchy you can expand and collapse. |
| `OiDetailView` | A read-only record layout of label and value pairs in sections. |

## OiTable

The table you reach for when data needs to be worked with, not just read. It
handles sorting, filtering, pagination, column resize and reorder, row selection,
grouping, and inline cell editing. You pass typed `rows` and a list of
`OiTableColumn<T>` that describe each column.

```dart
OiTable<User>(
  label: 'Users',
  rows: users,
  columns: [
    OiTableColumn<User>(
      id: 'name',
      header: 'Name',
      valueGetter: (u) => u.name,
    ),
    OiTableColumn<User>(
      id: 'email',
      header: 'Email',
      valueGetter: (u) => u.email,
    ),
    OiTableColumn<User>(
      id: 'role',
      header: 'Role',
      cellBuilder: (context, u, index) => OiBadge.soft(label: u.role),
    ),
  ],
)
```

### Selection, pagination, and inline edit

Turn features on with flags. Selection reports back a set of row keys, so give the
table a `rowKey` when you use it.

```dart
OiTable<User>(
  label: 'Users',
  rows: users,
  columns: columns,
  rowKey: (u) => u.id,
  selectable: true,
  multiSelect: true,
  onSelectionChanged: (keys) => setState(() => _selected = keys),
  paginationMode: OiTablePaginationMode.pages,
  onCellChanged: (row, columnId, value) => save(row, columnId, value),
)
```

`paginationMode` accepts `none` (the default), `pages`, `infinite`, or `virtual`.
Use `infinite` or `virtual` with `onLoadMore` and `totalRows` for large sets.

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label for the table. |
| `rows` | `List<T>` | **required** | The data items. |
| `columns` | `List<OiTableColumn<T>>` | **required** | Column definitions. |
| `controller` | `OiTableController?` | `null` | Drives sort, selection, columns, and pagination. |
| `selectable` | `bool` | `false` | Show a selection column. |
| `multiSelect` | `bool` | `false` | Allow more than one selected row. |
| `rowKey` | `String Function(T)?` | `null` | Stable key per row. Needed for selection. |
| `onSelectionChanged` | `ValueChanged<Set<String>>?` | `null` | Fires with the selected keys. |
| `onRowTap` / `onRowDoubleTap` | `void Function(T)?` | `null` | Row tap handlers. |
| `serverSideSort` | `bool` | `false` | Sort on the server. Pair with `onSort`. |
| `serverSideFilter` | `bool` | `false` | Filter on the server. Pair with `onFilter`. |
| `paginationMode` | `OiTablePaginationMode` | `none` | `none`, `pages`, `infinite`, or `virtual`. |
| `totalRows` | `int?` | `null` | Total count for server-side pagination. |
| `onLoadMore` | `Future<void> Function()?` | `null` | Loads the next page for `infinite` or `virtual`. |
| `pageSizeOptions` | `List<int>` | `[10, 25, 50, 100]` | Page-size choices. |
| `showColumnManager` | `bool` | `false` | Show the column show/hide manager. |
| `onCellChanged` | `void Function(T, String, dynamic)?` | `null` | Inline edit handler (row, columnId, value). |
| `reorderable` | `bool` | `false` | Allow drag-to-reorder rows. Pair with `onRowReordered`. |
| `copyable` | `bool` | `false` | Allow copying cell values. |
| `groupBy` | `String Function(T)?` | `null` | Group rows under section headers. |
| `emptyState` | `Widget?` | `null` | Shown when `rows` is empty. |
| `loading` | `bool` | `false` | Show a shimmer skeleton. |
| `striped` | `bool` | `false` | Alternate row backgrounds. |
| `dense` | `bool` | `false` | Tighter row height. |
| `showStatusBar` | `bool` | `true` | Show the footer status bar. |
| `bulkActions` | `List<OiBulkAction>?` | `null` | Actions shown when rows are selected. |
| `settingsDriver` / `settingsKey` / `settingsNamespace` | persistence | `null` / `null` / `'oi_table'` | Persist column and sort settings. |

`OiTableColumn<T>` takes `id` and `header` (both required), plus `width`,
`minWidth` (60), `maxWidth` (500), `sortable`, `filterable`, `resizable`,
`reorderable`, `hidden`, `frozen`, `cellBuilder`, `valueGetter`, `comparator`, and
`textAlign` and `cellPadding`. Column padding applies equally to the heading and
body and falls back to the table theme; narrow action columns can retain full
button targets without reserving text-column insets. Give a column a `valueGetter`
for plain text, or a `cellBuilder` when
a cell needs a widget.
Sortable headings use color emphasis on hover while preserving the theme's font
size, weight, spacing and line height, so pointer movement cannot shift columns
or change text truncation.

**Theme:** `context.components.table` → `OiTableThemeData`

!!! tip "When to reach for something else"
    For read-only tabular display, use `OiDataGrid`. For a flat list with no
    columns, use a list module. Reach for `OiTable` when users sort, filter, edit,
    or select.

### OiTableController

An optional controller that holds the table's state outside the widget: sort
column and direction, the selected row keys, column visibility, order and widths,
active filters, and pagination. Create one when you need to read or change that
state from elsewhere, for example to clear the selection from a toolbar button.

```dart
final controller = OiTableController(pageSize: 25);

OiTable<User>(
  label: 'Users',
  rows: users,
  columns: columns,
  controller: controller,
)

// Later, from anywhere that holds the controller:
controller.clearSelection();
controller.sortBy('name', ascending: true);
```

Useful methods include `sortBy`, `clearSort`, `selectRow`, `toggleRow`,
`selectAllRows`, `clearSelection`, `setFilter`, `clearAllFilters`,
`setColumnVisible`, `setColumnWidth`, `reorderColumns`, `resetColumns`,
`groupBy`, and `setFrozenColumns`.

## OiDataGrid

A lighter table for showing data you do not edit. It supports sorting and
selection but skips column resize, reorder, inline edit, and pagination. Reach for
it on admin lists and read-only panels where a full `OiTable` is more than you
need. Every column needs a `cellBuilder`.

```dart
OiDataGrid<Order>(
  rows: orders,
  columns: [
    OiDataGridColumn<Order>(
      id: 'id',
      header: 'Order',
      cellBuilder: (context, o, index) => OiLabel.body(o.reference),
    ),
    OiDataGridColumn<Order>(
      id: 'total',
      header: 'Total',
      numeric: true,
      cellBuilder: (context, o, index) => OiLabel.body(o.total),
    ),
  ],
)
```

For a text-only column, use the `OiDataGridColumn.text` shorthand with a `valueOf`
function instead of writing a `cellBuilder`.

```dart
OiDataGridColumn<Order>.text(
  id: 'customer',
  header: 'Customer',
  valueOf: (o) => o.customerName,
  sortable: true,
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rows` | `List<T>` | **required** | The data items. |
| `columns` | `List<OiDataGridColumn<T>>` | **required** | Column definitions. |
| `sortColumnId` | `String?` | `null` | Currently sorted column id. |
| `sortAscending` | `bool` | `true` | Sort direction. |
| `onSort` | `void Function(String, {required bool ascending})?` | `null` | Fires when a header is tapped. |
| `selectable` | `bool` | `false` | Show row selection. |
| `multiSelect` | `bool` | `false` | Allow multiple selected rows. |
| `selectedRows` | `Set<int>?` | `null` | Selected row indices. |
| `onSelectionChanged` | `ValueChanged<Set<int>>?` | `null` | Fires with selected indices. |
| `onRowTap` | `void Function(T, int)?` | `null` | Row tap handler. |
| `headerStyle` | `OiDataGridHeaderStyle` | `filled` | `filled`, `plain`, or `none`. |
| `striped` | `bool` | `false` | Alternate row backgrounds. |
| `dense` | `bool` | `false` | Tighter row height. |
| `showBorder` | `bool` | `true` | Draw the outer border. |
| `emptyState` | `Widget?` | `null` | Shown when `rows` is empty. |
| `loading` | `bool` | `false` | Show a shimmer skeleton. |
| `semanticLabel` | `String?` | `null` | Accessibility label. |

## OiPropertyGrid

A dense two-column grid for property inspectors and settings panels. The left
column shows labels, the right column shows inline editors, and a divider between
them is draggable. Each row is an `OiPropertyRow` that pairs a label with an editor
widget.

```dart
OiPropertyGrid(
  properties: [
    OiPropertyRow(
      label: 'Visible',
      editor: OiSwitch(value: _visible, onChanged: (v) => setState(() => _visible = v)),
    ),
    OiPropertyRow(
      label: 'Opacity',
      editor: OiSlider(value: _opacity, onChanged: (v) => setState(() => _opacity = v)),
      tooltip: 'Layer opacity',
    ),
    OiPropertyRow(
      label: 'Name',
      editor: OiEditableText(value: _name, onChanged: (v) => setState(() => _name = v)),
    ),
  ],
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `properties` | `List<OiPropertyRow>` | **required** | The rows to display. |
| `dividerPosition` | `double` | `0.4` | Initial split ratio (0.0 to 1.0). 40% labels, 60% editors. |
| `onDividerDragged` | `ValueChanged<double>?` | `null` | Fires with the new ratio while dragging. |

Each `OiPropertyRow` takes `label` and `editor` (both required) plus an optional
`tooltip` shown on hover over the label.

!!! note
    Use `OiPropertyGrid` for editing attributes, like a design-tool side panel.
    For a form with validation, use `OiForm`. For read-only pairs, use
    `OiDetailView`.

## OiGroupedList

A list that sorts items into sections and shows a sticky header above each one.
You give it a flat `items` list and a `groupBy` function that returns each item's
group key. Contacts by first letter, events by date, and products by category all
fit this shape.

```dart
OiGroupedList<Contact>(
  label: 'Contacts',
  items: contacts,
  groupBy: (c) => c.name[0].toUpperCase(),
  collapsible: true,
  itemBuilder: (context, contact, index) => OiListTile(
    title: contact.name,
    subtitle: contact.email,
  ),
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `List<T>` | **required** | The flat item list. |
| `itemBuilder` | `Widget Function(BuildContext, T, int)` | **required** | Builds each item. |
| `groupBy` | `String Function(T)` | **required** | Returns the group key for an item. |
| `label` | `String` | **required** | Accessibility label. |
| `headerBuilder` | `Widget Function(...)?` | `null` | Custom section header. |
| `groupOrder` | `int Function(String, String)?` | `null` | Sort order for groups. |
| `collapsible` | `bool` | `false` | Tap headers to collapse a section. |
| `initiallyCollapsed` | `Set<String>?` | `null` | Groups that start collapsed. |
| `emptyGroupBehavior` | `OiEmptyGroupBehavior` | `hide` | `hide`, `showHeader`, or `showEmpty`. |
| `emptyState` | `Widget?` | `null` | Shown when `items` is empty. |
| `separator` | `Widget?` | `null` | Between items within a group. |
| `stickyHeaders` | `bool` | `true` | Pin the section header while scrolling. |
| `loading` | `bool` | `false` | Loading indicator at the bottom. |
| `groupedListController` | `OiGroupedListController?` | `null` | Expand or collapse groups in code. |

Use `OiGroupedListController` to drive sections from code: `expandGroup`,
`collapseGroup`, `toggleGroup`, `expandAll`, and `collapseAll`.

**Theme:** `context.components.groupedList` → `OiGroupedListThemeData`

## OiReorderableList

A list where users drag items into a new order. It supports a drag handle,
long-press drag, and keyboard reordering, with an animated gap where the item will
drop. The `itemBuilder` receives the item, its index, and an optional drag-handle
widget you place inside the row.

```dart
OiReorderableList<Task>(
  semanticLabel: 'Task order',
  items: tasks,
  itemKey: (t) => ValueKey(t.id),
  onReorder: (oldIndex, newIndex) => setState(() {
    final task = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, task);
  }),
  itemBuilder: (context, task, index, handle) => OiListTile(
    title: task.title,
    trailing: handle,
  ),
)
```

### Drag modes

- `dragHandle: true` (default): the grip icon starts the drag.
- `dragHandle: false, longPressDrag: true`: long-press the whole item to drag.
- `dragHandle: false, longPressDrag: false`: the item drags on immediate touch.

Keyboard: focus an item, press Space to pick up, arrow keys to move, Enter to
drop, and Escape to cancel.

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `List<T>` | **required** | The data items. |
| `itemBuilder` | `Widget Function(BuildContext, T, int, Widget?)` | **required** | Builds each row. Fourth arg is the drag handle (or null). |
| `onReorder` | `void Function(int oldIndex, int newIndex)` | **required** | Applies the new order. |
| `itemKey` | `ValueKey<Object> Function(T)?` | `null` | Stable key per item. Defaults to index. |
| `dragHandle` | `bool` | `true` | Show a grip icon on each item. |
| `longPressDrag` | `bool` | `false` | Long-press to drag when `dragHandle` is off. |
| `axis` | `Axis` | `vertical` | Scroll and drag axis. |
| `padding` | `EdgeInsetsGeometry?` | `null` | Padding around the list. |
| `separator` | `Widget?` | `null` | Between items. |
| `shrinkWrap` | `bool` | `false` | Use inside an unbounded parent. |
| `onDragStart` / `onDragEnd` | `void Function(int)?` | `null` | Drag lifecycle callbacks. |
| `canReorder` | `bool Function(int)?` | `null` | Per-item predicate to allow or block dragging. |
| `semanticLabel` | `String?` | `null` | Accessibility label. |

## OiTree

A hierarchy you can expand and collapse. You pass a list of root `OiTreeNode<T>`,
and each node carries its own `children`. Good for file trees, category trees, and
org charts.

```dart
OiTree<Category>(
  label: 'Categories',
  nodes: [
    OiTreeNode<Category>(
      id: 'fruit',
      label: 'Fruit',
      children: [
        OiTreeNode(id: 'apple', label: 'Apple', leaf: true),
        OiTreeNode(id: 'pear', label: 'Pear', leaf: true),
      ],
    ),
  ],
  onNodeTap: (node) => open(node),
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label. |
| `nodes` | `List<OiTreeNode<T>>` | **required** | The root nodes. |
| `controller` | `OiTreeController?` | `null` | Manages expansion and selection state. |
| `onNodeTap` / `onNodeDoubleTap` | `void Function(OiTreeNode<T>)?` | `null` | Node tap handlers. |
| `onExpansionChanged` | callback | `null` | Fires when a node expands or collapses. |
| `onSelectionChanged` | callback | `null` | Fires when selection changes. |
| `nodeBuilder` | builder | `null` | Custom row for a node. |
| `indentWidth` | `double` | `24` | Indent per depth level. |
| `rowHeight` | `double` | `40` | Height of each row. |
| `selectable` | `bool` | `false` | Allow selecting nodes. |
| `multiSelect` | `bool` | `false` | Allow selecting more than one node. |
| `showLines` | `bool` | `false` | Draw connector lines between levels. |

Each `OiTreeNode<T>` takes `id` and `label` (both required), plus `data` (your
typed payload), `children`, `leaf` (set `true` to hide the expander), and `icon`.
Create an `OiTreeController(multiSelect: true)` when you need to read or change
expansion and selection from code.

## OiDetailView

A read-only layout for a single record. You group label and value pairs into
sections, and the view lays them out with dividers, optional multi-column grids,
and per-field formatting. Reach for it on profile, order, and product-detail
screens.

```dart
OiDetailView(
  label: 'Order details',
  columns: 2,
  sections: [
    OiDetailSection(
      title: 'Customer',
      fields: [
        OiDetailField(label: 'Name', value: order.customerName),
        OiDetailField(label: 'Email', value: order.email, type: OiFieldType.email),
      ],
    ),
    OiDetailSection(
      title: 'Order',
      fields: [
        OiDetailField(label: 'Placed', value: order.placedAt, type: OiFieldType.date),
        OiDetailField(
          label: 'Total',
          value: order.total,
          type: OiFieldType.currency,
          currencyCode: 'USD',
        ),
      ],
    ),
  ],
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sections` | `List<OiDetailSection>` | **required** | The grouped fields. |
| `label` | `String?` | `null` | Accessibility label. |
| `columns` | `int` | `1` | Number of columns in the field grid. |
| `columnGap` | `double` | `16.0` | Horizontal gap between columns. |
| `rowGap` | `double` | `20.0` | Vertical gap between fields. |
| `fieldDirection` | `Axis` | `horizontal` | Lay label and value side by side or stacked. |
| `labelWidth` | `double?` | `null` | Fixed label column width. |
| `emptyText` | `String` | `—` | Placeholder for a null or empty value. |
| `showDividers` | `bool` | `true` | Draw a divider between fields. |
| `wrapInCard` | `bool` | `true` | Wrap the whole view in a card. |
| `padding` | `EdgeInsetsGeometry?` | `null` | Padding inside the view. |

`OiDetailSection` takes `fields` (required) and an optional `title`. Each
`OiDetailField` takes `label` and `value` (required), a `type` (`OiFieldType`, for
example `text`, `number`, `currency`, `date`, `dateTime`, `boolean`, `email`),
`columnSpan`, a `copyable` flag, and formatting params such as `dateFormat`,
`currencyCode`, and `decimalPlaces`.

!!! note
    `OiDetailView` is read-only. To edit the same record, use `OiForm`.

## Related

- [Buttons & Actions](buttons.md) for `OiBulkBar`, `OiExportButton`, and `OiSortButton`.
- [Forms & Inputs](forms.md) for `OiForm` and the editors you drop into a property grid.
- [Overlays & Menus](overlays.md) for the menus a row action opens.

## Controlled expanded rows and expanded filters

`OiTable.expandedRowKeys` identifies expanded records using `rowKey`.
`expandedRowBuilder(context, row)` renders content below the row and
`onExpandedRowsChanged` requests a new set of expanded keys. Keep those keys in
the host so sorting, filtering and refreshed record instances preserve expansion
identity. Expansion does not replace selection or cell editing.

`OiFilterPanel` renders `OiFilterSection` groups using the same
`OiFilterDefinition` values as `OiFilterBar`. Pass controlled `activeFilters` and
`onFilterChange`; `onApply` is separate so a host can stage changes before querying.
`OiFilterInput` is the shared editor. Number filters emit numbers, dates emit
`DateTime`, date ranges emit `(DateTime, DateTime)`, and number ranges emit
`(num?, num?)`. Multi-select filters emit lists of option values. Custom filters
preserve their typed values. The panel can be placed in `OiSheet` with pinned
header/footer content, `scrollable: true` and a theme-defined inset.
