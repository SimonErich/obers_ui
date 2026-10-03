# Composing Custom Modules

A module is a full-feature screen built from the tiers below it. ObersUI ships
many modules, like `OiListView`, `OiKanban`, and `OiFileExplorer`. When none of
them fits your data, you build your own the same way they are built. This page
shows how.

## What a module is

A module sits at the top tier. It arranges composites and components, holds any
controllers those pieces need, and wires persistence for user preferences. It
does not own your data. Your app passes data in and gets callbacks back.

Most modules follow the same shape:

1. A `StatefulWidget` that takes your data and `onX` callbacks.
2. Composites and components from the tiers below, laid out with `OiPage`,
   `OiRow`, `OiColumn`, or `OiGrid`.
3. Local UI state (the selected record, the active filters).
4. Optional persistence through a settings driver.
5. Optional undo through `OiOptimisticAction`.

Before you build one, check the widget catalog. A composite may already do the
job. Reach for a custom module only when the built-in modules do not match your
data or workflow.

## The tiers you compose from

| Tier | Examples | Role in a module |
| --- | --- | --- |
| Primitives | `OiPage`, `OiRow`, `OiColumn`, `OiGrid`, `OiLabel` | Layout and text. |
| Components | `OiButton`, `OiTextInput`, `OiCard` | Controls and containers. |
| Composites | `OiTable`, `OiFilterBar`, `OiDetailView`, `OiForm` | Ready-made patterns. |

Each tier imports only from the tier below. Keep that rule in your own module.
Compose composites, do not rebuild them.

## Example: a record browser

Here is a small module. It shows a filter bar, a table of records, and a detail
view for the selected row. It is a common shape: filter, list, inspect.

### The public widget

The widget takes the records and the callbacks. It owns no data of its own.

```dart
class InvoiceBrowser extends StatefulWidget {
  const InvoiceBrowser({
    required this.invoices,
    required this.onArchive,
    this.settingsDriver,
    super.key,
  });

  final List<Invoice> invoices;
  final Future<void> Function(Invoice) onArchive;
  final OiSettingsDriver? settingsDriver;

  @override
  State<InvoiceBrowser> createState() => _InvoiceBrowserState();
}
```

### The state and layout

The state holds the local UI values: the active filters and the selected
record. It lays the pieces out with `OiPage`.

```dart
class _InvoiceBrowserState extends State<InvoiceBrowser> {
  Map<String, OiColumnFilter> _filters = const {};
  Invoice? _selected;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final bp = context.breakpoint;

    return OiPage(
      breakpoint: bp,
      gap: OiResponsive<double>(spacing.md),
      children: [
        _buildFilterBar(context),
        _buildTable(context),
        if (_selected != null) _buildDetail(context),
      ],
    );
  }
}
```

### The filter bar

`OiFilterBar` renders a row of filter chips. You define the filters, hold the
active map, and update it in `onFilterChange`.

```dart
Widget _buildFilterBar(BuildContext context) {
  return OiFilterBar(
    filters: const [
      OiFilterDefinition(
        key: 'status',
        label: 'Status',
        type: OiFilterType.select,
        options: [
          OiSelectOption(value: 'paid', label: 'Paid'),
          OiSelectOption(value: 'due', label: 'Due'),
        ],
      ),
      OiFilterDefinition(
        key: 'customer',
        label: 'Customer',
        type: OiFilterType.text,
      ),
    ],
    activeFilters: _filters,
    onFilterChange: (next) => setState(() => _filters = next),
    trailing: OiButton.ghost(
      label: 'Clear all',
      onTap: () => setState(() => _filters = const {}),
    ),
  );
}
```

`OiFilterDefinition` requires `key`, `label`, and `type`. Use `options` for
`select` and `multiSelect` types. Each active filter is an `OiColumnFilter` with
a `value` and an `operator`. Apply the map to your list yourself, or pass it to a
data source.

### The table

`OiTable` shows the filtered rows. Each `OiTableColumn` reads its cell value with
`valueGetter`. Tap a row to select it.

```dart
Widget _buildTable(BuildContext context) {
  return OiTable<Invoice>(
    label: 'Invoices',
    rows: _visibleInvoices,
    rowKey: (invoice) => invoice.id,
    onRowTap: (invoice) => setState(() => _selected = invoice),
    settingsDriver: widget.settingsDriver,
    settingsKey: 'invoice_browser_table',
    columns: [
      OiTableColumn<Invoice>(
        id: 'number',
        header: 'Number',
        valueGetter: (invoice) => invoice.number,
      ),
      OiTableColumn<Invoice>(
        id: 'customer',
        header: 'Customer',
        valueGetter: (invoice) => invoice.customer,
      ),
      OiTableColumn<Invoice>(
        id: 'total',
        header: 'Total',
        valueGetter: (invoice) => invoice.total.toString(),
      ),
    ],
  );
}
```

Pass `settingsDriver` and `settingsKey` and the table saves its column widths,
order, and sort on its own. See [Persistence](#persistence-for-your-own-state)
for state the table does not own.

### The detail view

`OiDetailView` lays out the fields of the selected record in sections. It formats
values by type, so a date or a currency renders correctly without extra code.

```dart
Widget _buildDetail(BuildContext context) {
  final invoice = _selected!;
  return OiDetailView(
    label: 'Invoice detail',
    sections: [
      OiDetailSection(
        title: 'Summary',
        fields: [
          OiDetailField(label: 'Number', value: invoice.number),
          OiDetailField(
            label: 'Total',
            value: invoice.total,
            type: OiFieldType.currency,
            currencyCode: 'USD',
          ),
          OiDetailField(
            label: 'Issued',
            value: invoice.issuedAt,
            type: OiFieldType.date,
          ),
        ],
      ),
    ],
  );
}
```

That is the whole module. Filter, list, inspect, all from composites. You wrote
layout and state, not widgets.

## Use OiListView when it fits

The record browser above is worth building when you need a table with a detail
pane. If you only need a searchable, filterable, sortable list, do not rebuild
that. `OiListView` already bundles search, filters, sorting, selection, and
persistence.

```dart
OiListView<Invoice>(
  label: 'Invoices',
  items: invoices,
  itemKey: (invoice) => invoice.id,
  itemBuilder: (context, invoice, index) => OiCard(
    child: OiLabel.body(invoice.number),
  ),
  onSearch: (query) => runSearch(query),
  settingsDriver: settingsDriver,
  settingsKey: 'invoice_list',
)
```

Build a custom module only when a built-in module does not match. Composing an
existing composite always beats reinventing one.

## Persistence for your own state

Composites like `OiTable`, `OiFilterBar`, and `OiListView` persist their own view
state when you give them a `settingsDriver`. To do this, register the driver once
on `OiApp`.

```dart
OiApp(
  settingsDriver: OiLocalStorageDriver(),
  home: const InvoiceBrowser(/* ... */),
)
```

For state your module owns, like a chosen layout or a saved filter preset, mix
`OiSettingsMixin` into your state class. The mixin loads on `initState` and saves
on a debounce.

Define a settings class with `OiSettingsData`. It needs `toJson`, a
`schemaVersion`, and a way to read the value back.

```dart
class BrowserSettings with OiSettingsData {
  const BrowserSettings({this.compact = false});
  final bool compact;

  factory BrowserSettings.fromJson(Map<String, dynamic> json) =>
      BrowserSettings(compact: (json['compact'] as bool?) ?? false);

  @override
  int get schemaVersion => 1;

  @override
  Map<String, dynamic> toJson() =>
      {'compact': compact, 'schemaVersion': schemaVersion};
}
```

Then mix `OiSettingsMixin` into your state class and implement its members.

```dart
class _InvoiceBrowserState extends State<InvoiceBrowser>
    with OiSettingsMixin<InvoiceBrowser, BrowserSettings> {
  @override
  String get settingsNamespace => 'invoice_browser';

  @override
  OiSettingsDriver? get settingsDriver => widget.settingsDriver;

  @override
  BrowserSettings get defaultSettings => const BrowserSettings();

  @override
  BrowserSettings deserializeSettings(Map<String, dynamic> json) =>
      BrowserSettings.fromJson(json);

  @override
  BrowserSettings mergeSettings(BrowserSettings saved, BrowserSettings defaults) =>
      saved;

  void _toggleCompact() {
    updateSettings(BrowserSettings(compact: !currentSettings.compact));
  }
}
```

| Member | Type | Description |
| --- | --- | --- |
| `settingsNamespace` | `String` | **required** Namespace for stored keys. |
| `settingsDriver` | `OiSettingsDriver?` | **required** The backend, or `null` to skip saving. |
| `defaultSettings` | `T` | **required** Value used before load and on reset. |
| `deserializeSettings(json)` | `T` | **required** Builds a typed value from stored JSON. |
| `mergeSettings(saved, defaults)` | `T` | **required** Merges a loaded value with current defaults. |
| `settingsKey` | `String?` | Optional key within the namespace. |
| `currentSettings` | `T` | The current in-memory value. |
| `updateSettings(value)` | `void` | Sets the value and schedules a debounced save. |
| `saveSettingsNow()` | `Future<void>` | Flushes any pending save now. |
| `resetSettings()` | `Future<void>` | Deletes the stored value and reloads defaults. |

Read `currentSettings` in `build`. Call `updateSettings` when the user changes a
preference.

## Undo for mutations

When your module deletes, archives, or moves a record, give the user a way back.
`OiOptimisticAction.execute` applies the change at once, shows an undo snackbar,
and runs your real async work. If the work fails, it rolls the change back.

```dart
void _archive(Invoice invoice) {
  OiOptimisticAction.execute(
    context,
    apply: () => setState(() => _invoices.remove(invoice)),
    rollback: () => setState(() => _invoices.add(invoice)),
    commit: () => widget.onArchive(invoice),
    message: 'Invoice archived',
  );
}
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `apply` | `VoidCallback` | **required** | The optimistic change, applied at once. |
| `rollback` | `VoidCallback` | **required** | Reverses `apply` on undo or failure. |
| `commit` | `Future<void> Function()` | **required** | The real async work. |
| `message` | `String` | **required** | The undo snackbar text. |
| `undoDuration` | `Duration` | `5s` | How long the undo window stays open. |
| `errorMessage` | `String?` | `null` | Toast shown if `commit` throws. |

For text editing inside a module, `OiApp` already wires a global undo stack with
Ctrl+Z and Ctrl+Shift+Z. You do not set that up yourself.

!!! tip
    Use `OiOptimisticAction` for reversible actions like archive or move. For an
    action that needs a warning first, confirm with `showOiDialog` instead.

## Rules to keep

- Take data and callbacks in. Do not fetch or own data in the module.
- Read every color from `context.colors`. Never hardcode a color.
- Use `OiLabel` for text and `OiRow`, `OiColumn`, `OiGrid`, or `OiPage` for
  layout. Do not use raw `Text`, `Row`, or `Column`.
- Give every interactive element a `label` or `semanticLabel`.
- Pass `settingsDriver` through to any composite that supports it.
- Test at all five breakpoints, since a module fills the screen.

## Related

- [AI README](ai-readme.md) for the full widget catalog you compose from.
- [Extending Themes](../theming/extending-themes.md) for the theme values your module reads.
- [Performance](performance.md) for large lists and grids inside a module.
- [Data & Tables](../widgets/data-tables.md) for `OiTable` and `OiDetailView` in depth.
