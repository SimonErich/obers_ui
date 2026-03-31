# Settings Persistence

ObersUI widgets can automatically save and restore user preferences — column widths, sort order, view modes, collapsed panels, and more. This is powered by a pluggable **settings driver** system.

## How it works

1. You provide a `settingsDriver` to `OiApp`
2. Widgets that support persistence auto-save their state
3. On next load, state is restored automatically

```dart
OiApp(
  settingsDriver: OiLocalStorageDriver(),  // Persists to SharedPreferences / localStorage
  theme: OiThemeData.light(),
  home: const MyHomePage(),
)
```

That's it. No per-widget configuration needed.

## Available drivers

| Driver | Storage | Use case |
| --- | --- | --- |
| `OiLocalStorageDriver` | `SharedPreferences` (mobile) / `localStorage` (web) | Production apps |
| `OiInMemorySettingsDriver` | RAM only | Testing, prototyping |

### Custom driver

Implement `OiSettingsDriver` for your own backend:

```dart
class ApiSettingsDriver extends OiSettingsDriver {
  @override
  Future<T?> load<T extends OiSettingsData>({
    required String namespace,
    required T Function(Map<String, dynamic>) deserialize,
    String? key,
  }) async {
    final json = await api.getSettings(resolveKey(namespace, key));
    if (json == null) return null;
    return deserialize(json);
  }

  @override
  Future<void> save<T extends OiSettingsData>({
    required String namespace,
    required T data,
    required Map<String, dynamic> Function(T) serialize,
    String? key,
  }) async {
    await api.putSettings(resolveKey(namespace, key), serialize(data));
  }

  @override
  Future<void> delete({required String namespace, String? key}) async {
    await api.deleteSettings(resolveKey(namespace, key));
  }

  @override
  Future<bool> exists({required String namespace, String? key}) async {
    return api.hasSettings(resolveKey(namespace, key));
  }
}
```

## What gets persisted

| Widget | Persisted settings |
| --- | --- |
| `OiTable` | Column order, widths, visibility, sort, filters, page size, groups |
| `OiFileExplorer` | View mode, sort, sidebar state, favorites, recent paths |
| `OiKanban` | Column order, collapsed columns, WIP limits |
| `OiListView` | Layout mode, sort, filters, page size |
| `OiSidebar` | Mode, width, collapsed sections, selected item |
| `OiSplitPane` | Divider position, collapsed state |
| `OiDashboard` | Card positions and dimensions |
| `OiCalendar` | View type, date range, collapsed categories |
| `OiGantt` | Zoom level, scroll position, collapsed groups |
| `OiAccordion` | Expanded section indices |
| `OiTabs` | Tab order, selected index |
| `OiFilterBar` | Active filters, filter order |

## Per-instance isolation

Each widget instance gets its own storage key. If you have two tables on different pages, their settings are independent:

```dart
// These save to different keys automatically
OiTable(settingsKey: 'users-table', ...)
OiTable(settingsKey: 'orders-table', ...)
```

## Settings data contract

All settings implement `OiSettingsData` which provides:

- `toJson()` — Serialize to JSON map
- `fromJson()` — Deserialize from JSON map
- `mergeWith()` — Merge saved settings with current defaults
- `schemaVersion` — Version for safe migrations

When a widget's settings schema changes, the version is bumped and old settings are gracefully merged with new defaults.

## Debouncing

Settings are auto-saved with a **500ms debounce** — rapid changes (like dragging a column wider) don't spam your storage backend.
