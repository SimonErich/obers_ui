# Dashboards, Lists & Boards

These are full screens, not single widgets. You hand each one your data and a
few builders, and it renders a complete page: search, filters, sorting,
selection, drag-and-drop, or a grid of cards. Reach for them when you want a
whole feature, not just one control.

| Widget | What it does |
| --- | --- |
| `OiListView` | A complete list page with search, filters, sort, pagination, bulk actions, and a list/grid/table layout. |
| `OiKanban` | A drag-and-drop board with columns, WIP limits, and quick edit. |
| `OiDashboard` | A grid of titled, resizable KPI cards. |

## Picking the right one

Three screens overlap. Choose by the shape of your data.

- Use `OiListView` for a scrolling list of entities: users, orders, articles.
  It gives you search, filter chips, sort, selection, and infinite scroll.
- Use `OiTable` (see [Tables](../widgets/data-tables.md)) when the data is
  tabular and you need per-column operations like column sort, resize, and pin.
- Use `OiKanban` when items move between named stages: a task pipeline, a
  hiring board, a support triage.

## OiListView

The most common screen in any app. You give it `items`, a builder for each row,
and a way to read a stable key from each item. It handles the header, search
field, filter bar, sort control, selection bar, and the scrolling body.

`OiListView` is generic over your item type `T`.

```dart
OiListView<User>(
  label: 'Users',
  items: users,
  itemKey: (user) => user.id,
  itemBuilder: (user) => OiListTile(
    title: user.name,
    subtitle: user.email,
  ),
  searchQuery: _query,
  onSearch: (value) => setState(() => _query = value),
)
```

### Search, filters, and sort

Each of these is opt-in. Pass the data plus a callback, and the control appears.
Leave them out and the header stays clean.

```dart
OiListView<User>(
  label: 'Users',
  items: users,
  itemKey: (user) => user.id,
  itemBuilder: (user) => UserCard(user: user),
  // Search box in the header.
  onSearch: (value) => controller.search(value),
  // Filter chips backed by OiFilterBar.
  filters: [
    OiFilterDefinition(key: 'role', label: 'Role', /* ... */),
  ],
  activeFilters: _activeFilters,
  onFilterChange: (next) => setState(() => _activeFilters = next),
  // Sort dropdown.
  sortOptions: const [
    OiListSortOption(id: 'name', label: 'Name'),
    OiListSortOption(id: 'created', label: 'Newest'),
  ],
  activeSort: _sort,
  onSort: (option) => setState(() => _sort = option),
)
```

### Selection and bulk actions

Turn on `selectionMode`, hold the selected keys yourself, and return action
widgets from `selectionActions`. The selection bar shows the count and your
actions when at least one item is selected.

```dart
OiListView<User>(
  label: 'Users',
  items: users,
  itemKey: (user) => user.id,
  itemBuilder: (user) => UserCard(user: user),
  selectionMode: OiSelectionMode.multi,
  selectedKeys: _selected,
  onSelectionChange: (keys) => setState(() => _selected = keys),
  selectionActions: (keys) => [
    OiButton.destructive(
      label: 'Delete ${keys.length}',
      onTap: () => deleteUsers(keys),
    ),
  ],
)
```

### Layout, paging, and refresh

Switch between a list, a grid, or a table with `layout`. Wire `onLoadMore` and
`moreAvailable` for infinite scroll, and `onRefresh` for pull-to-refresh.

```dart
OiListView<Product>(
  label: 'Products',
  items: products,
  itemKey: (product) => product.sku,
  itemBuilder: (product) => ProductCard(product: product),
  layout: OiListViewLayout.grid,
  gridColumns: const OiResponsive<int>(4),
  loading: _loading,
  moreAvailable: _hasMore,
  onLoadMore: () => controller.loadNextPage(),
  onRefresh: () => controller.reload(),
  emptyState: const OiEmptyState(title: 'No products yet'),
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `List<T>` | **required** | The data to display. |
| `itemBuilder` | `Widget Function(T)` | **required** | Builds the widget for one item. |
| `itemKey` | `Object Function(T)` | **required** | Reads a unique key, used for selection. |
| `label` | `String` | **required** | Accessibility label and header title. |
| `searchQuery` | `String?` | `null` | The current query text. |
| `onSearch` | `ValueChanged<String>?` | `null` | Fires as the user types. Passing it shows the search box. |
| `filters` | `List<OiFilterDefinition>?` | `null` | Filter definitions shown as chips. |
| `activeFilters` | `Map<String, OiColumnFilter>` | `{}` | The active filter set. |
| `onFilterChange` | `ValueChanged<Map<String, OiColumnFilter>>?` | `null` | Fires when filters change. |
| `sortOptions` | `List<OiListSortOption>?` | `null` | Sortable fields. Each has `id`, `label`, `icon`. |
| `activeSort` | `OiListSortOption?` | `null` | The active sort option. |
| `onSort` | `ValueChanged<OiListSortOption>?` | `null` | Fires when the sort changes. |
| `selectionMode` | `OiSelectionMode` | `none` | `none`, `single`, or `multi`. |
| `selectedKeys` | `Set<Object>` | `{}` | The currently selected keys. |
| `onSelectionChange` | `ValueChanged<Set<Object>>?` | `null` | Fires when the selection changes. |
| `selectionActions` | `List<Widget> Function(Set<Object>)?` | `null` | Builds the bulk action bar. |
| `onLoadMore` | `Future<void> Function()?` | `null` | Loads the next page near the end. |
| `moreAvailable` | `bool` | `false` | Whether more items can load. |
| `loading` | `bool` | `false` | Shows a loading indicator. |
| `emptyState` | `Widget?` | `null` | Shown when there are no items. |
| `layout` | `OiListViewLayout` | `list` | `list`, `grid`, or `table`. |
| `gridColumns` | `OiResponsive<int>?` | `3` | Column count in grid layout. |
| `gridGap` | `OiResponsive<double>?` | `spacing.md` | Gap between grid items. |
| `headerActions` | `Widget?` | `null` | A widget pinned to the header's end. |
| `footer` | `Widget?` | `null` | A widget below the body, good for pagination. |
| `onRefresh` | `Future<void> Function()?` | `null` | Pull-to-refresh handler. |
| `settingsDriver` | `OiSettingsDriver?` | `null` | Persists settings. See below. |
| `settingsKey` | `String?` | `null` | Scopes this list's saved settings. |
| `settingsNamespace` | `String` | `'oi_list_view'` | Storage namespace. |
| `settingsSaveDebounce` | `Duration` | `500ms` | Debounce before saving. |

!!! note
    `OiListView` does not sort or filter your data for you. You hold the list.
    The callbacks tell you what the user picked, and you update `items` in
    response. This keeps paging, server-side search, and caching in your hands.

## OiKanban

A board of columns with cards you drag between them. You give it columns, each
holding a `key`, a `title`, and a list of items. It handles drag-and-drop,
column collapse, WIP limits, and double-tap-to-rename.

`OiKanban` is generic over your card type `T`.

```dart
OiKanban<Task>(
  label: 'Sprint board',
  columns: [
    OiKanbanColumn(key: 'todo', title: 'To do', items: todoTasks),
    OiKanbanColumn(key: 'doing', title: 'In progress', items: activeTasks),
    OiKanbanColumn(key: 'done', title: 'Done', items: doneTasks),
  ],
  cardBuilder: (task) => TaskCard(task: task),
  onCardMove: (task, fromColumn, toColumn, newIndex) {
    controller.moveTask(task, toColumn, newIndex);
  },
)
```

When you leave `cardBuilder` out, each card shows the item's `toString()`. Pass
a `color` on a column to tint its header.

### WIP limits and quick edit

Set a work-in-progress limit per column key. When a column goes over its limit,
its header and border turn to the error color. `quickEdit` lets users double-tap
a column title to rename it, and it is on by default.

```dart
OiKanban<Task>(
  label: 'Sprint board',
  columns: columns,
  cardBuilder: (task) => TaskCard(task: task),
  wipLimits: const {'doing': 3},
  quickEdit: true,
  collapsibleColumns: true,
  addColumn: true,
  onAddColumn: () => controller.addColumn(),
  cardKey: (task) => task.id,
)
```

!!! note
    On compact screens, `OiKanban` shows one column at a time with left and
    right paging arrows, instead of a wide horizontal scroll.

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `columns` | `List<OiKanbanColumn<T>>` | **required** | The board columns. Each has `key`, `title`, `items`, `color`. |
| `label` | `String` | **required** | Accessibility label for the board. |
| `onCardMove` | `void Function(T, Object, Object, int)?` | `null` | Fires with the item, source key, target key, and new index. |
| `onColumnReorder` | `void Function(int, int)?` | `null` | Fires with the old and new column index. |
| `cardBuilder` | `Widget Function(T)?` | `null` | Builds each card. Falls back to `toString()`. |
| `columnHeader` | `Widget Function(OiKanbanColumn<T>)?` | `null` | Custom column header. |
| `reorderColumns` | `bool` | `true` | Allow reordering columns. |
| `wipLimits` | `Map<Object, int>?` | `null` | Max cards per column key. |
| `quickEdit` | `bool` | `true` | Double-tap a title to rename. |
| `collapsibleColumns` | `bool` | `true` | Allow collapsing columns. |
| `addColumn` | `bool` | `false` | Show an "Add column" button at the end. |
| `onAddColumn` | `VoidCallback?` | `null` | Fires when "Add column" is tapped. |
| `cardKey` | `Object Function(T)?` | `null` | Reads a stable key from each card. |
| `settingsDriver` | `OiSettingsDriver?` | `null` | Persists settings. See below. |
| `settingsKey` | `String?` | `null` | Scopes this board's saved settings. |
| `settingsNamespace` | `String` | `'oi_kanban'` | Storage namespace. |

!!! warning
    `OiKanban` does not move cards for you. `onCardMove` reports the intended
    move. You mutate your own lists and rebuild with the new `columns`. If you
    ignore the callback, the card snaps back.

## OiDashboard

A grid of titled cards for overview screens. Each card owns a region of the
grid, sized in columns and rows. You put anything inside a card: a metric, a
chart, a short list.

```dart
OiDashboard(
  label: 'Overview',
  columns: 4,
  cards: [
    OiDashboardCard(
      key: 'revenue',
      title: 'Revenue',
      columnSpan: 2,
      child: const OiMetric(
        label: 'This month',
        value: '\$48,200',
        trend: OiMetricTrend.up,
        trendPercent: 12.5,
      ),
    ),
    OiDashboardCard(
      key: 'signups',
      title: 'New signups',
      child: const OiMetric(label: 'Today', value: '128'),
    ),
  ],
)
```

Set `columnSpan` and `rowSpan` on a card to make it larger. The grid has
`columns` tracks across the width and computes the card sizes from there.

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cards` | `List<OiDashboardCard>` | **required** | The cards to render. |
| `label` | `String` | **required** | Accessibility label for the dashboard. |
| `columns` | `int` | `4` | Number of grid columns. |
| `gap` | `double` | `16` | Space between cards, in logical pixels. |
| `editable` | `bool` | `false` | Enable drag-to-reorder edit mode. |
| `onLayoutChange` | `ValueChanged<List<OiDashboardCard>>?` | `null` | Fires when the layout changes in edit mode. |
| `settingsDriver` | `OiSettingsDriver?` | `null` | Persists settings. See below. |
| `settingsKey` | `String?` | `null` | Scopes this dashboard's saved settings. |
| `settingsNamespace` | `String` | `'oi_dashboard'` | Storage namespace. |
| `settingsSaveDebounce` | `Duration` | `500ms` | Debounce before saving. |

Each `OiDashboardCard` takes a `key`, a `title`, a `child`, and optional
`columnSpan`, `rowSpan`, `column`, and `row` for explicit placement.

## Persistence

All three modules can remember their layout between sessions. `OiListView` and
`OiDashboard` save layout and view settings. `OiKanban` saves which columns are
collapsed. Pass a `settingsDriver`, or provide one higher up with
`OiSettingsProvider` and leave the parameter out.

```dart
OiListView<User>(
  label: 'Users',
  items: users,
  itemKey: (user) => user.id,
  itemBuilder: (user) => UserCard(user: user),
  settingsDriver: mySettingsDriver,
  settingsKey: 'admin_users',
)
```

Give each instance its own `settingsKey` when you show more than one on a page,
so their saved settings do not collide.

## Related

- [Tables](../widgets/data-tables.md) for tabular data with column operations.
- [Buttons & Actions](../widgets/buttons.md) for the bulk-action bar and sort controls.
- [Display](../widgets/display.md) for `OiMetric`, `OiCard`, and empty states.
