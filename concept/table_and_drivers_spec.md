# obers_ui — Advanced Table & Settings Persistence Driver Specification

> **Date:** 2026-03-16
> **Extends:** `base_concept.md`
> **Scope:** (1) Foundation-level Settings Persistence Driver system, (2) Enhanced OiTable v2 composite.
> **Replaces:** Existing `OiTable<T>` in `base_concept.md`.
> **Principle:** The driver system is a cross-cutting concern at the Foundation tier. The table is the first major consumer, but the system is designed for any widget that has persistable user preferences.

---

## Table of Contents

- [Part 1: Settings Persistence Drivers](#part-1-settings-persistence-drivers)
  - [Motivation & Design Goals](#motivation--design-goals)
  - [Architecture Overview](#architecture-overview)
  - [Core Interfaces](#core-interfaces)
  - [Built-in Drivers](#built-in-drivers)
  - [Settings Data Contracts](#settings-data-contracts)
  - [Widget Integration Pattern](#widget-integration-pattern)
  - [Provider Integration](#provider-integration)
  - [Modules That Use Persistence](#modules-that-use-persistence)
  - [Custom Driver Guide](#custom-driver-guide)
  - [Driver Tests](#driver-tests)
- [Part 2: OiTable v2 — Enhanced Data Table](#part-2-oitable-v2)
  - [What Changed from v1](#what-changed-from-v1)
  - [Full API](#full-api)
  - [Pagination System](#pagination-system)
  - [Inline Editing System](#inline-editing-system)
  - [Column Management](#column-management)
  - [Settings Persistence Integration](#settings-persistence-integration)
  - [Table Controller](#table-controller)
  - [Table Tests](#table-tests)

---

# Part 1: Settings Persistence Drivers

---

## Motivation & Design Goals

Complex widgets like tables, kanban boards, file explorers, dashboards, and sidebars accumulate user preferences: column widths, sort order, visible columns, collapsed groups, view mode, panel widths, filter presets. These preferences are transient by default — lost on navigation or app restart. Persistence is essential for professional apps.

**Design goals:**

1. **Opt-in.** No persistence by default. Widgets work identically with or without a driver. Pass `null` → no persistence. Pass a driver → preferences auto-save and auto-restore.
2. **Driver-based.** The library ships one built-in driver (local storage). Consumers implement the `OiSettingsDriver` interface to persist to their own backend: REST API, SQLite, Hive, SharedPreferences, state management (Riverpod/Bloc), or anything else.
3. **Keyed.** A driver optionally accepts a `key`. Without a key, settings are global (shared by all instances of that widget type). With a key, settings are scoped to a specific view (e.g., `"users-table"` vs. `"orders-table"`).
4. **Type-safe.** Each widget type defines a strongly-typed settings data class. The driver serializes/deserializes via JSON. No stringly-typed maps.
5. **Minimal API surface.** The driver interface has exactly 4 methods: `load`, `save`, `delete`, `exists`. Everything else is derived.
6. **Sync & async.** Drivers can be async (network, database) or sync (in-memory, local storage). The interface uses `Future` for both — sync drivers return `SynchronousFuture`.
7. **Mergeable.** When settings are loaded, they are merged with widget defaults. Missing keys gracefully fall back to defaults. This prevents breaking changes when adding new settings fields.
8. **Testable.** An `OiInMemorySettingsDriver` is provided for testing.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                     Widget Layer                         │
│                                                         │
│  OiTable         OiFileExplorer    OiKanban    OiSidebar│
│  ┌─────────┐    ┌─────────────┐   ┌───────┐   ┌──────┐ │
│  │settings │    │  settings   │   │settings│   │ ... │ │
│  │driver?  │    │  driver?    │   │driver? │   │      │ │
│  └────┬────┘    └──────┬──────┘   └───┬────┘   └──┬───┘ │
│       │                │              │            │     │
│       ▼                ▼              ▼            ▼     │
│  ┌─────────────────────────────────────────────────────┐ │
│  │           OiSettingsDriver (interface)              │ │
│  │                                                     │ │
│  │  Future<T?> load<T>(namespace, key?, deserializer)  │ │
│  │  Future<void> save<T>(namespace, key?, data, ser.)  │ │
│  │  Future<void> delete(namespace, key?)               │ │
│  │  Future<bool> exists(namespace, key?)               │ │
│  └─────────────────────────────────────────────────────┘ │
│                          │                               │
└──────────────────────────┼───────────────────────────────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
              ▼            ▼            ▼
        ┌──────────┐ ┌──────────┐ ┌──────────────┐
        │ OiLocal  │ │OiInMemory│ │ Custom       │
        │ Storage  │ │ Settings │ │ Driver       │
        │ Driver   │ │ Driver   │ │ (user impl)  │
        └──────────┘ └──────────┘ └──────────────┘
         (built-in)   (testing)    (REST, Hive,
                                    SharedPrefs,
                                    Riverpod, ...)
```

**Namespace:** Each widget type has a fixed namespace string. This prevents collisions between different widget types storing settings. For example, `OiTable` uses namespace `"oi_table"`, `OiFileExplorer` uses `"oi_file_explorer"`.

**Key (optional):** When provided, settings are scoped: the storage key becomes `"$namespace::$key"`. When omitted, it's just `"$namespace"` — a global/default setting for all instances.

**Lifecycle:**
1. Widget mounts → calls `driver.load(namespace, key, deserializer)`.
2. Settings are merged with widget defaults (settings values override, missing fields fall back to defaults).
3. User changes a setting (e.g., resizes a column) → widget calls `driver.save(namespace, key, newSettings, serializer)` debounced (500ms default).
4. Widget unmounts → nothing special (save already happened on change).
5. Widget mounts again → step 1 restores the saved settings.

---

## Core Interfaces

```dart
/// The core interface that all persistence drivers implement.
///
/// A driver is responsible for storing and retrieving serialized settings data.
/// The interface is intentionally minimal — 4 methods cover all use cases.
///
/// Drivers are stateless. They do not cache. Caching is the widget's responsibility
/// (via the [OiSettingsMixin]).
abstract class OiSettingsDriver {
  const OiSettingsDriver();

  /// Loads settings for the given [namespace] and optional [key].
  ///
  /// Returns `null` if no settings have been saved yet.
  /// The [deserialize] function converts the raw stored `Map<String, dynamic>`
  /// back into the typed settings object.
  ///
  /// If the stored data is corrupted or incompatible, implementations should
  /// return `null` (not throw), allowing the widget to fall back to defaults.
  Future<T?> load<T>({
    required String namespace,
    String? key,
    required T Function(Map<String, dynamic> json) deserialize,
  });

  /// Saves settings for the given [namespace] and optional [key].
  ///
  /// The [serialize] function converts the typed settings object into a
  /// JSON-encodable `Map<String, dynamic>`.
  ///
  /// Implementations may batch, debounce, or queue writes internally.
  /// The returned Future completes when the write is confirmed.
  Future<void> save<T>({
    required String namespace,
    String? key,
    required T data,
    required Map<String, dynamic> Function(T) serialize,
  });

  /// Deletes settings for the given [namespace] and optional [key].
  ///
  /// After deletion, [load] returns `null` and [exists] returns `false`.
  Future<void> delete({
    required String namespace,
    String? key,
  });

  /// Checks whether settings exist for the given [namespace] and optional [key].
  Future<bool> exists({
    required String namespace,
    String? key,
  });

  /// Computes the storage key from namespace and optional key.
  ///
  /// Default implementation: `"$namespace"` when key is null,
  /// `"$namespace::$key"` when key is provided.
  ///
  /// Drivers may override this to use different key formats (e.g., path-based
  /// for REST APIs: `"/settings/$namespace/$key"`).
  @protected
  String resolveKey(String namespace, String? key) {
    if (key == null) return namespace;
    return '$namespace::$key';
  }
}
```

**The Settings Data Contract:**

```dart
/// Mixin that all settings data classes must implement.
///
/// Provides a standard serialization contract so drivers can store and
/// retrieve settings without knowing their concrete types.
mixin OiSettingsData {
  /// Serializes this settings object to a JSON-encodable map.
  Map<String, dynamic> toJson();

  /// The schema version. Increment when adding/removing/renaming fields.
  /// Used by [merge] to handle backwards compatibility.
  int get schemaVersion;
}
```

**The Widget-Side Mixin:**

```dart
/// Mixin for State classes of widgets that support settings persistence.
///
/// Handles the full lifecycle: load on init, save on change (debounced),
/// merge with defaults.
///
/// Usage in a widget's State class:
/// ```dart
/// class _OiTableState<T> extends State<OiTable<T>>
///     with OiSettingsMixin<OiTableSettings> {
///
///   @override
///   String get settingsNamespace => 'oi_table';
///
///   @override
///   String? get settingsKey => widget.settingsKey;
///
///   @override
///   OiSettingsDriver? get settingsDriver => widget.settingsDriver;
///
///   @override
///   OiTableSettings get defaultSettings => OiTableSettings(
///     columnOrder: widget.columns.map((c) => c.id).toList(),
///     columnWidths: {},
///     // ... defaults from widget props ...
///   );
///
///   @override
///   OiTableSettings deserializeSettings(Map<String, dynamic> json) =>
///       OiTableSettings.fromJson(json);
///
///   @override
///   OiTableSettings mergeSettings(OiTableSettings saved, OiTableSettings defaults) =>
///       saved.mergeWith(defaults);
/// }
/// ```
mixin OiSettingsMixin<S extends OiSettingsData> on State {
  /// The namespace used for storage. Unique per widget type.
  /// Example: `'oi_table'`, `'oi_file_explorer'`.
  String get settingsNamespace;

  /// Optional key for view-specific settings. When null, settings are global.
  String? get settingsKey;

  /// The driver to use. When null, no persistence occurs.
  OiSettingsDriver? get settingsDriver;

  /// Default settings derived from the widget's props.
  S get defaultSettings;

  /// Deserializes JSON into a typed settings object.
  S deserializeSettings(Map<String, dynamic> json);

  /// Merges saved settings with current defaults.
  /// Saved values take precedence. Missing saved fields fall back to defaults.
  /// This is critical for backwards compatibility when new fields are added.
  S mergeSettings(S saved, S defaults);

  /// The currently-active settings (merged result of saved + defaults).
  /// Available after [initState] completes async loading.
  late S currentSettings;

  /// Whether settings have been loaded from the driver.
  bool settingsLoaded = false;

  /// Whether an error occurred during loading (falls back to defaults).
  bool settingsLoadError = false;

  Timer? _saveDebounce;

  @override
  void initState() {
    super.initState();
    currentSettings = defaultSettings;
    _loadSettings();
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the driver or key changed, reload settings.
    // Concrete widgets compare old vs new and call _loadSettings() if needed.
  }

  /// Loads settings from the driver, merges with defaults, and calls setState.
  Future<void> _loadSettings() async {
    final driver = settingsDriver;
    if (driver == null) {
      settingsLoaded = true;
      return;
    }

    try {
      final saved = await driver.load<S>(
        namespace: settingsNamespace,
        key: settingsKey,
        deserialize: deserializeSettings,
      );

      if (saved != null) {
        currentSettings = mergeSettings(saved, defaultSettings);
      }
    } catch (e) {
      // On any error, fall back to defaults silently.
      settingsLoadError = true;
    }

    settingsLoaded = true;
    if (mounted) setState(() {});
  }

  /// Called by the widget whenever a setting changes.
  /// Debounces saves to avoid excessive writes during rapid interactions
  /// (e.g., column resizing).
  void updateSettings(S newSettings, {Duration debounce = const Duration(milliseconds: 500)}) {
    currentSettings = newSettings;
    setState(() {});

    final driver = settingsDriver;
    if (driver == null) return;

    _saveDebounce?.cancel();
    _saveDebounce = Timer(debounce, () {
      driver.save<S>(
        namespace: settingsNamespace,
        key: settingsKey,
        data: newSettings,
        serialize: (s) => s.toJson(),
      );
    });
  }

  /// Saves immediately without debounce. Use for explicit "Save" actions.
  Future<void> saveSettingsNow() async {
    final driver = settingsDriver;
    if (driver == null) return;

    _saveDebounce?.cancel();
    await driver.save<S>(
      namespace: settingsNamespace,
      key: settingsKey,
      data: currentSettings,
      serialize: (s) => s.toJson(),
    );
  }

  /// Resets settings to defaults and deletes saved data.
  Future<void> resetSettings() async {
    currentSettings = defaultSettings;
    setState(() {});

    final driver = settingsDriver;
    if (driver == null) return;

    await driver.delete(
      namespace: settingsNamespace,
      key: settingsKey,
    );
  }
}
```

---

## Built-in Drivers

### OiLocalStorageDriver

Persists settings to the browser's `localStorage` (web) or `SharedPreferences` (mobile/desktop) via a cross-platform abstraction.

```dart
/// Persists settings to local storage.
///
/// On web: uses `window.localStorage`.
/// On mobile/desktop: uses `SharedPreferences` (or `shared_preferences` package).
///
/// Storage format: each key stores a JSON string.
///
/// ```dart
/// OiTable<User>(
///   settingsDriver: OiLocalStorageDriver(),
///   settingsKey: 'users-admin-table',
///   // ...
/// )
/// ```
class OiLocalStorageDriver extends OiSettingsDriver {
  const OiLocalStorageDriver({
    this.prefix = 'obers_ui',
  });

  /// Prefix prepended to all storage keys to avoid collisions with other
  /// application data. Final key format: `"$prefix.$namespace"` or
  /// `"$prefix.$namespace::$key"`.
  final String prefix;

  @override
  String resolveKey(String namespace, String? key) {
    final base = super.resolveKey(namespace, key);
    return '$prefix.$base';
  }

  @override
  Future<T?> load<T>({
    required String namespace,
    String? key,
    required T Function(Map<String, dynamic>) deserialize,
  }) async {
    final storageKey = resolveKey(namespace, key);
    final raw = await _platformRead(storageKey);
    if (raw == null) return null;

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return deserialize(json);
    } catch (e) {
      // Corrupted data — return null, widget falls back to defaults.
      return null;
    }
  }

  @override
  Future<void> save<T>({
    required String namespace,
    String? key,
    required T data,
    required Map<String, dynamic> Function(T) serialize,
  }) async {
    final storageKey = resolveKey(namespace, key);
    final json = jsonEncode(serialize(data));
    await _platformWrite(storageKey, json);
  }

  @override
  Future<void> delete({required String namespace, String? key}) async {
    final storageKey = resolveKey(namespace, key);
    await _platformDelete(storageKey);
  }

  @override
  Future<bool> exists({required String namespace, String? key}) async {
    final storageKey = resolveKey(namespace, key);
    return await _platformExists(storageKey);
  }

  // Platform-specific implementations (internal).
  Future<String?> _platformRead(String key) { /* ... */ }
  Future<void> _platformWrite(String key, String value) { /* ... */ }
  Future<void> _platformDelete(String key) { /* ... */ }
  Future<bool> _platformExists(String key) { /* ... */ }
}
```

### OiInMemorySettingsDriver

For testing. Stores settings in a plain `Map`. Also useful for ephemeral session-only persistence.

```dart
/// In-memory driver for testing and session-only persistence.
///
/// Settings are stored in a [Map] and lost when the driver instance is
/// garbage-collected.
///
/// ```dart
/// final driver = OiInMemorySettingsDriver();
/// // Pass to widgets for testing. Inspect driver.store for assertions.
/// ```
class OiInMemorySettingsDriver extends OiSettingsDriver {
  OiInMemorySettingsDriver();

  /// The internal store. Exposed for test assertions.
  final Map<String, Map<String, dynamic>> store = {};

  @override
  Future<T?> load<T>({
    required String namespace,
    String? key,
    required T Function(Map<String, dynamic>) deserialize,
  }) async {
    final storageKey = resolveKey(namespace, key);
    final data = store[storageKey];
    if (data == null) return null;
    return deserialize(Map<String, dynamic>.from(data));
  }

  @override
  Future<void> save<T>({
    required String namespace,
    String? key,
    required T data,
    required Map<String, dynamic> Function(T) serialize,
  }) async {
    final storageKey = resolveKey(namespace, key);
    store[storageKey] = serialize(data);
  }

  @override
  Future<void> delete({required String namespace, String? key}) async {
    final storageKey = resolveKey(namespace, key);
    store.remove(storageKey);
  }

  @override
  Future<bool> exists({required String namespace, String? key}) async {
    final storageKey = resolveKey(namespace, key);
    return store.containsKey(storageKey);
  }

  /// Clears all stored settings. Useful in test tearDown.
  void clear() => store.clear();
}
```

---

## Settings Data Contracts

Each widget type that supports persistence defines its own immutable settings data class. These classes implement `OiSettingsData` and provide `toJson` / `fromJson` / `mergeWith`.

### OiTableSettings

```dart
@immutable
class OiTableSettings with OiSettingsData {
  const OiTableSettings({
    this.columnOrder = const [],
    this.columnWidths = const {},
    this.visibleColumnIds,
    this.pinnedColumnIds = const {},
    this.sort,
    this.filters = const {},
    this.pageSize,
    this.expandedGroupKeys = const {},
    this.columnAlignments = const {},
  });

  /// Ordered list of column IDs. Defines display order.
  final List<String> columnOrder;

  /// Map of column ID → width in logical pixels. Missing keys use column defaults.
  final Map<String, double> columnWidths;

  /// Set of visible column IDs. Null means all columns visible.
  final Set<String>? visibleColumnIds;

  /// Set of column IDs pinned to the left.
  final Set<String> pinnedColumnIds;

  /// Active sort configuration.
  final OiTableSort? sort;

  /// Active filters. Map of column ID → filter.
  final Map<String, OiColumnFilter> filters;

  /// Number of rows per page. Null means use widget default.
  final int? pageSize;

  /// Expanded group keys (when grouping is active).
  final Set<Object> expandedGroupKeys;

  /// Per-column alignment overrides.
  final Map<String, OiTableColumnAlign> columnAlignments;

  @override
  int get schemaVersion => 1;

  @override
  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'columnOrder': columnOrder,
    'columnWidths': columnWidths.map((k, v) => MapEntry(k, v)),
    'visibleColumnIds': visibleColumnIds?.toList(),
    'pinnedColumnIds': pinnedColumnIds.toList(),
    'sort': sort != null ? {'columnId': sort!.columnId, 'direction': sort!.direction.name} : null,
    'filters': filters.map((k, v) => MapEntry(k, v.toJson())),
    'pageSize': pageSize,
    'expandedGroupKeys': expandedGroupKeys.map((k) => k.toString()).toList(),
    'columnAlignments': columnAlignments.map((k, v) => MapEntry(k, v.name)),
  };

  factory OiTableSettings.fromJson(Map<String, dynamic> json) => OiTableSettings(
    columnOrder: (json['columnOrder'] as List?)?.cast<String>() ?? const [],
    columnWidths: (json['columnWidths'] as Map?)?.map((k, v) => MapEntry(k as String, (v as num).toDouble())) ?? const {},
    visibleColumnIds: (json['visibleColumnIds'] as List?)?.cast<String>().toSet(),
    pinnedColumnIds: (json['pinnedColumnIds'] as List?)?.cast<String>().toSet() ?? const {},
    sort: json['sort'] != null ? OiTableSort(
      columnId: json['sort']['columnId'],
      direction: OiSortDirection.values.byName(json['sort']['direction']),
    ) : null,
    filters: (json['filters'] as Map?)?.map((k, v) => MapEntry(k as String, OiColumnFilter.fromJson(v))) ?? const {},
    pageSize: json['pageSize'] as int?,
    expandedGroupKeys: (json['expandedGroupKeys'] as List?)?.cast<String>().toSet() ?? const {},
    columnAlignments: (json['columnAlignments'] as Map?)?.map((k, v) => MapEntry(k as String, OiTableColumnAlign.values.byName(v))) ?? const {},
  );

  /// Merges saved settings with defaults.
  /// Saved values win. Missing saved values fall back to defaults.
  /// Columns that no longer exist in the widget definition are pruned.
  OiTableSettings mergeWith(OiTableSettings defaults) {
    // Prune saved column IDs that no longer exist in defaults.
    final validColumnIds = defaults.columnOrder.toSet();

    return OiTableSettings(
      columnOrder: columnOrder.isNotEmpty
          ? [...columnOrder.where(validColumnIds.contains), ...defaults.columnOrder.where((id) => !columnOrder.contains(id))]
          : defaults.columnOrder,
      columnWidths: {...defaults.columnWidths, ...Map.fromEntries(columnWidths.entries.where((e) => validColumnIds.contains(e.key)))},
      visibleColumnIds: visibleColumnIds?.intersection(validColumnIds) ?? defaults.visibleColumnIds,
      pinnedColumnIds: pinnedColumnIds.intersection(validColumnIds),
      sort: sort != null && validColumnIds.contains(sort!.columnId) ? sort : defaults.sort,
      filters: Map.fromEntries(filters.entries.where((e) => validColumnIds.contains(e.key))),
      pageSize: pageSize ?? defaults.pageSize,
      expandedGroupKeys: expandedGroupKeys,
      columnAlignments: Map.fromEntries(columnAlignments.entries.where((e) => validColumnIds.contains(e.key))),
    );
  }
}
```

---

## Widget Integration Pattern

Here's the exact pattern for how any widget integrates the driver system. Using `OiTable` as the example:

**Step 1: Widget accepts optional driver + key.**

```dart
OiTable<T>({
  // ... all existing props ...

  /// Optional persistence driver. When provided, column order, widths,
  /// visibility, sort, filters, and page size are automatically saved
  /// and restored.
  OiSettingsDriver? settingsDriver,

  /// Optional key to scope settings to a specific view instance.
  /// Without a key, settings are global (shared by all OiTable instances
  /// using the same driver).
  /// With a key, each table has independent settings.
  ///
  /// Example: `settingsKey: 'admin-users-table'`
  String? settingsKey,

  /// Debounce duration for auto-saving settings after changes.
  /// Default: 500ms. Set to Duration.zero for immediate saves.
  Duration settingsSaveDebounce = const Duration(milliseconds: 500),
})
```

**Step 2: State class uses `OiSettingsMixin`.**

```dart
class _OiTableState<T> extends State<OiTable<T>>
    with OiSettingsMixin<OiTableSettings> {

  @override
  String get settingsNamespace => 'oi_table';

  @override
  String? get settingsKey => widget.settingsKey;

  @override
  OiSettingsDriver? get settingsDriver => widget.settingsDriver;

  @override
  OiTableSettings get defaultSettings => OiTableSettings(
    columnOrder: widget.columns.map((c) => c.id).toList(),
    columnWidths: Map.fromEntries(
      widget.columns.where((c) => c.width != null).map((c) => MapEntry(c.id, c.width!)),
    ),
    sort: widget.sort,
    pageSize: widget.pageSize,
  );

  @override
  OiTableSettings deserializeSettings(Map<String, dynamic> json) =>
      OiTableSettings.fromJson(json);

  @override
  OiTableSettings mergeSettings(OiTableSettings saved, OiTableSettings defaults) =>
      saved.mergeWith(defaults);
}
```

**Step 3: Widget reads from `currentSettings` and writes via `updateSettings`.**

```dart
// Reading — inside build():
final columnOrder = currentSettings.columnOrder;
final columnWidths = currentSettings.columnWidths;
final visibleColumns = currentSettings.visibleColumnIds;

// Writing — when user resizes a column:
void _onColumnResize(String columnId, double newWidth) {
  final newWidths = Map<String, double>.from(currentSettings.columnWidths);
  newWidths[columnId] = newWidth;

  updateSettings(OiTableSettings(
    ...currentSettings, // copyWith pattern
    columnWidths: newWidths,
  ));

  // Also notify the consumer via callback:
  widget.onColumnProfileChange?.call(/* ... */);
}
```

**Step 4: Reset button in column management UI.**

```dart
void _onResetSettings() {
  resetSettings(); // From OiSettingsMixin — clears saved, reverts to defaults.
}
```

---

## Provider Integration

For apps that want to inject a driver globally (so every table, kanban, file explorer automatically gets persistence without passing `settingsDriver` to each one), an `InheritedWidget` provider is available.

```dart
/// Provides a default [OiSettingsDriver] to all descendants.
///
/// Widgets with persistence support look up this provider when their own
/// `settingsDriver` prop is null.
///
/// ```dart
/// OiSettingsProvider(
///   driver: OiLocalStorageDriver(),
///   child: MyApp(),
/// )
/// ```
///
/// Individual widgets can still override with their own driver:
/// ```dart
/// OiTable(settingsDriver: myCustomDriver, ...) // Ignores provider
/// OiTable(...) // Uses provider driver
/// ```
class OiSettingsProvider extends InheritedWidget {
  const OiSettingsProvider({
    required this.driver,
    required super.child,
  });

  final OiSettingsDriver driver;

  static OiSettingsDriver? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<OiSettingsProvider>()?.driver;
  }

  @override
  bool updateShouldNotify(OiSettingsProvider oldWidget) => driver != oldWidget.driver;
}
```

The `OiSettingsMixin` resolution order:
1. `widget.settingsDriver` (explicit prop) — highest priority.
2. `OiSettingsProvider.of(context)` — inherited fallback.
3. `null` — no persistence.

Updated mixin getter:
```dart
@override
OiSettingsDriver? get settingsDriver =>
    widget.settingsDriver ?? OiSettingsProvider.of(context);
```

---

## Modules That Use Persistence

The driver system is designed for reuse. Here's every existing module/composite that has persistable user preferences, what settings it persists, and its namespace:

| Widget | Namespace | Settings Persisted |
|--------|-----------|-------------------|
| **OiTable** | `oi_table` | Column order, column widths, column visibility, pinned columns, sort, filters, page size, expanded groups, column alignments |
| **OiFileExplorer** | `oi_file_explorer` | View mode (list/grid), sort field, sort direction, sidebar width, sidebar collapsed, favorites, recent paths |
| **OiKanban** | `oi_kanban` | Column order, collapsed columns, WIP limits overrides |
| **OiListView** | `oi_list_view` | Layout (list/grid/table), active sort, active filters, page size |
| **OiSidebar** | `oi_sidebar` | Mode (full/compact/hidden), width, collapsed sections, selected item |
| **OiSplitPane** | `oi_split_pane` | Divider position (ratio or pixels), collapsed pane |
| **OiDashboard** | `oi_dashboard` | Card positions (column, row, column span, row span) per card key |
| **OiCalendar** | `oi_calendar` | View type (month/week/day), visible date range, collapsed categories |
| **OiGantt** | `oi_gantt` | Zoom level, scroll position, collapsed groups |
| **OiAccordion** | `oi_accordion` | Expanded section indices |
| **OiTabs** | `oi_tabs` | Tab order (when reorderable), selected tab index |
| **OiFilterBar** | `oi_filter_bar` | Active filters, filter order |

**Settings data class per module (summary):**

```dart
// OiFileExplorerSettings
@immutable
class OiFileExplorerSettings with OiSettingsData {
  final OiFileViewMode viewMode;
  final OiFileSortField sortField;
  final OiSortDirection sortDirection;
  final double sidebarWidth;
  final bool sidebarCollapsed;
  final List<String> favoriteFolderIds;
  final List<String> recentPaths;
  // ... toJson, fromJson, mergeWith, schemaVersion
}

// OiKanbanSettings
@immutable
class OiKanbanSettings with OiSettingsData {
  final List<Object> columnOrder;
  final Set<Object> collapsedColumnKeys;
  // ... toJson, fromJson, mergeWith, schemaVersion
}

// OiSidebarSettings
@immutable
class OiSidebarSettings with OiSettingsData {
  final OiSidebarMode mode;
  final double width;
  final Set<String> collapsedSectionIds;
  // ... toJson, fromJson, mergeWith, schemaVersion
}

// OiDashboardSettings
@immutable
class OiDashboardSettings with OiSettingsData {
  final Map<Object, OiDashboardCardPosition> cardPositions;
  // ... toJson, fromJson, mergeWith, schemaVersion
}

// OiSplitPaneSettings
@immutable
class OiSplitPaneSettings with OiSettingsData {
  final double dividerPosition;
  final bool paneCollapsed;
  // ... toJson, fromJson, mergeWith, schemaVersion
}

// OiListViewSettings
@immutable
class OiListViewSettings with OiSettingsData {
  final OiListViewLayout layout;
  final String? activeSortId;
  final Map<String, OiColumnFilter> activeFilters;
  // ... toJson, fromJson, mergeWith, schemaVersion
}
```

All modules listed above add the same 3 props:

```dart
OiSettingsDriver? settingsDriver,
String? settingsKey,
Duration settingsSaveDebounce = const Duration(milliseconds: 500),
```

---

## Custom Driver Guide

### Example: REST API Driver

```dart
/// Persists settings to a remote REST API.
///
/// Storage format: JSON body POST/PUT to `/api/settings/{key}`.
///
/// ```dart
/// OiTable<User>(
///   settingsDriver: RestSettingsDriver(
///     baseUrl: 'https://api.myapp.com',
///     authToken: userToken,
///   ),
///   settingsKey: 'admin-users-table',
///   // ...
/// )
/// ```
class RestSettingsDriver extends OiSettingsDriver {
  RestSettingsDriver({
    required this.baseUrl,
    required this.authToken,
    this.userId,
  });

  final String baseUrl;
  final String authToken;
  final String? userId;

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $authToken',
    'Content-Type': 'application/json',
  };

  String _url(String namespace, String? key) {
    final storageKey = resolveKey(namespace, key);
    final userPrefix = userId != null ? '/users/$userId' : '';
    return '$baseUrl$userPrefix/settings/$storageKey';
  }

  @override
  Future<T?> load<T>({
    required String namespace,
    String? key,
    required T Function(Map<String, dynamic>) deserialize,
  }) async {
    try {
      final response = await http.get(Uri.parse(_url(namespace, key)), headers: _headers);
      if (response.statusCode == 404) return null;
      if (response.statusCode != 200) return null;
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return deserialize(json);
    } catch (e) {
      return null; // Graceful fallback
    }
  }

  @override
  Future<void> save<T>({
    required String namespace,
    String? key,
    required T data,
    required Map<String, dynamic> Function(T) serialize,
  }) async {
    final body = jsonEncode(serialize(data));
    await http.put(Uri.parse(_url(namespace, key)), headers: _headers, body: body);
  }

  @override
  Future<void> delete({required String namespace, String? key}) async {
    await http.delete(Uri.parse(_url(namespace, key)), headers: _headers);
  }

  @override
  Future<bool> exists({required String namespace, String? key}) async {
    final response = await http.head(Uri.parse(_url(namespace, key)), headers: _headers);
    return response.statusCode == 200;
  }
}
```

### Example: Hive Driver

```dart
class HiveSettingsDriver extends OiSettingsDriver {
  HiveSettingsDriver({required this.box});

  final Box<String> box;

  @override
  Future<T?> load<T>({
    required String namespace,
    String? key,
    required T Function(Map<String, dynamic>) deserialize,
  }) async {
    final storageKey = resolveKey(namespace, key);
    final raw = box.get(storageKey);
    if (raw == null) return null;
    try {
      return deserialize(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save<T>({
    required String namespace,
    String? key,
    required T data,
    required Map<String, dynamic> Function(T) serialize,
  }) async {
    final storageKey = resolveKey(namespace, key);
    await box.put(storageKey, jsonEncode(serialize(data)));
  }

  @override
  Future<void> delete({required String namespace, String? key}) async {
    await box.delete(resolveKey(namespace, key));
  }

  @override
  Future<bool> exists({required String namespace, String? key}) async {
    return box.containsKey(resolveKey(namespace, key));
  }
}
```

### Example: Riverpod State Driver

```dart
/// Persists settings into a Riverpod StateNotifier.
/// Settings live in memory with reactive updates — combine with another
/// driver for actual persistence.
class RiverpodSettingsDriver extends OiSettingsDriver {
  RiverpodSettingsDriver({required this.ref, this.persistTo});

  final Ref ref;
  final OiSettingsDriver? persistTo;

  @override
  Future<T?> load<T>({
    required String namespace,
    String? key,
    required T Function(Map<String, dynamic>) deserialize,
  }) async {
    // Try in-memory state first, then fall back to persistent driver.
    final inMemory = ref.read(_settingsStoreProvider)[resolveKey(namespace, key)];
    if (inMemory != null) return deserialize(inMemory);
    return persistTo?.load(namespace: namespace, key: key, deserialize: deserialize);
  }

  @override
  Future<void> save<T>({
    required String namespace,
    String? key,
    required T data,
    required Map<String, dynamic> Function(T) serialize,
  }) async {
    final json = serialize(data);
    ref.read(_settingsStoreProvider.notifier).state = {
      ...ref.read(_settingsStoreProvider),
      resolveKey(namespace, key): json,
    };
    await persistTo?.save(namespace: namespace, key: key, data: data, serialize: serialize);
  }

  // ... delete, exists similarly
}
```

---

## Driver Tests

### Unit Tests: OiSettingsDriver interface contract

These tests apply to **every** driver implementation. They should be run as a shared test suite that accepts a driver factory.

```dart
void runDriverContractTests(OiSettingsDriver Function() createDriver) {
  // Each test gets a fresh driver instance.
}
```

| Test | What it verifies |
|------|-----------------|
| `load` returns null when nothing saved | Empty state |
| `save` then `load` returns saved data | Roundtrip |
| `save` overwrites previous data | Overwrite |
| `delete` then `load` returns null | Deletion |
| `exists` returns false when nothing saved | Empty state |
| `exists` returns true after save | Existence check |
| `exists` returns false after delete | Deletion check |
| `save` with key, `load` without key returns null | Key isolation |
| `save` without key, `load` with key returns null | Key isolation |
| `save` with key "A", `load` with key "B" returns null | Key isolation |
| `save` with key "A", `load` with key "A" returns data | Correct key match |
| `save` without key (global), `load` without key returns data | Global settings |
| Multiple namespaces don't collide | Namespace isolation |
| Corrupted data returns null from `load` (not throw) | Graceful degradation |
| Complex nested data roundtrips correctly | Nested JSON |
| Concurrent saves don't corrupt | Thread safety |
| `resolveKey` produces expected format | Key format |

### Unit Tests: OiLocalStorageDriver

| Test | What it verifies |
|------|-----------------|
| All contract tests pass | Full contract |
| Custom prefix applied to keys | `"obers_ui.oi_table::my-key"` |
| JSON parse error returns null | Corrupted storage |
| Works on web platform | Platform-specific |
| Works on mobile platform | Platform-specific |

### Unit Tests: OiInMemorySettingsDriver

| Test | What it verifies |
|------|-----------------|
| All contract tests pass | Full contract |
| `store` map directly inspectable | Test assertion support |
| `clear()` empties all settings | Reset |

### Unit Tests: OiSettingsMixin

| Test | What it verifies |
|------|-----------------|
| No driver: `currentSettings` equals `defaultSettings` | No-persistence mode |
| Driver with no saved data: `currentSettings` equals `defaultSettings` | First-use |
| Driver with saved data: `currentSettings` is merged result | Restore |
| `updateSettings` changes `currentSettings` immediately | Sync update |
| `updateSettings` saves to driver after debounce | Debounced write |
| Rapid `updateSettings` calls: only last value saved | Debounce coalescing |
| `saveSettingsNow` saves immediately | Explicit save |
| `resetSettings` reverts to defaults and deletes from driver | Reset |
| Driver change on `didUpdateWidget` reloads settings | Driver swap |
| Key change on `didUpdateWidget` reloads settings | Key swap |
| Load error falls back to defaults | Error resilience |
| Widget disposes cancels pending save timer | No leak |
| `settingsLoaded` is false before load completes | Loading state |
| `settingsLoaded` is true after load completes | Loaded state |

### Unit Tests: OiSettingsProvider

| Test | What it verifies |
|------|-----------------|
| `OiSettingsProvider.of(context)` returns driver | Lookup works |
| Widget uses provider driver when own driver is null | Inherited fallback |
| Widget uses own driver over provider driver | Explicit wins |
| No provider and no driver: no persistence | Null case |
| Provider change notifies dependents | `updateShouldNotify` |

### Unit Tests: OiTableSettings

| Test | What it verifies |
|------|-----------------|
| `toJson()` produces valid JSON-encodable map | Serialization |
| `fromJson(toJson())` roundtrips perfectly | Full roundtrip |
| `mergeWith` preserves saved column order | Saved wins |
| `mergeWith` appends new columns from defaults | Backwards compat |
| `mergeWith` prunes removed columns | Forward compat |
| `mergeWith` falls back to default sort when saved sort column removed | Graceful |
| `mergeWith` preserves saved widths for existing columns | Width persist |
| `mergeWith` ignores saved widths for removed columns | Prune |
| Empty saved settings merges to defaults | Initial state |
| `schemaVersion` is 1 | Version check |

---

# Part 2: OiTable v2 — Enhanced Data Table

---

## What Changed from v1

| Feature | v1 | v2 |
|---------|----|----|
| Pagination | `onLoadMore` + `hasMore` (infinite scroll only) | Full `OiPaginationController` — server-side, client-side, cursor, infinite, with page size selector |
| Inline editing | `editableCells=true`, click-to-edit | Double-click-to-edit, seamless cell transition (display → edit is pixel-identical), per-cell type-aware editors, validation, async save |
| Column resize | `resizeColumns=true`, basic drag | Auto-fit (double-click header edge), min/max enforced, resize indicator line, persisted |
| Column management | `OiColumnProfile` (name, visible, widths, order) | Full column management panel (toggle visibility, reorder via drag, reset), column freeze (left/right), auto-fit all |
| Settings persistence | None | `OiSettingsDriver` integration — all preferences auto-saved/restored |
| Column header menu | None | Click header → sort, filter, hide, freeze, auto-fit in a dropdown |
| Row reordering | None | Drag to reorder rows (manual sort mode) |
| Copy/paste | None | Copy cells/rows to clipboard, paste into editable cells |
| Status bar | None | Optional footer bar with row count, selection count, aggregations |
| Column groups | None | Grouped column headers (spanning headers like "Personal Info" over "Name" + "Email") |

---

## Full API

```dart
OiTable<T>({
  // ── Data ──
  required List<OiTableColumn<T>> columns,
  required List<T> rows,
  required Object Function(T) rowKey,
  required Widget Function(T row, OiTableColumn<T> column) cellBuilder,

  // ── Sorting ──
  OiTableSort? sort,
  List<OiTableSort>? multiSortState,
  ValueChanged<OiTableSort>? onSort,
  ValueChanged<List<OiTableSort>>? onMultiSort,
  bool multiSort = false,
  bool clientSideSort = false,
  int Function(T a, T b)? defaultComparator,

  // ── Selection ──
  OiSelectionMode selectionMode = OiSelectionMode.none,
  Set<Object> selectedKeys = const {},
  ValueChanged<Set<Object>>? onSelectionChange,

  // ── Column Management ──
  bool reorderColumns = false,
  bool resizeColumns = false,
  bool hideColumns = false,
  bool freezeColumns = false,
  bool autoFitColumns = false,
  List<OiTableColumnGroup>? columnGroups,

  // ── Virtualization ──
  bool virtualScroll = false,
  double? rowHeight,
  int overscan = 5,

  // ── Grouping ──
  Object Function(T)? groupBy,
  Widget Function(Object key, List<T> items)? groupHeader,
  bool collapsibleGroups = true,
  Set<Object> expandedGroupKeys = const {},
  ValueChanged<Set<Object>>? onGroupExpansionChange,

  // ── Row Expansion ──
  Set<Object> expandedRowKeys = const {},
  Widget Function(T)? rowDetail,
  ValueChanged<Set<Object>>? onRowExpansionChange,

  // ── Row Reordering ──
  bool reorderRows = false,
  void Function(int oldIndex, int newIndex)? onRowReorder,

  // ── Inline Editing ──
  bool editableCells = false,
  OiCellEditTrigger editTrigger = OiCellEditTrigger.doubleTap,
  void Function(T row, OiTableColumn<T> column, dynamic newValue)? onCellEdit,
  Future<bool> Function(T row, OiTableColumn<T> column, dynamic newValue)? onCellEditAsync,
  Widget Function(T row, OiTableColumn<T> column, dynamic currentValue, ValueChanged<dynamic> onSave, VoidCallback onCancel)? cellEditorBuilder,

  // ── Column Filters ──
  Map<String, OiColumnFilter>? filters,
  ValueChanged<Map<String, OiColumnFilter>>? onFilterChange,
  bool clientSideFilter = false,

  // ── Sticky / Pinned ──
  bool stickyHeader = true,
  Set<String>? frozenLeftColumnIds,
  Set<String>? frozenRightColumnIds,
  List<T>? pinnedRows,
  OiPinnedPosition pinnedPosition = OiPinnedPosition.top,

  // ── Pagination ──
  OiPaginationConfig? pagination,
  OiPaginationController? paginationController,

  // ── Export ──
  VoidCallback? onExport,

  // ── Copy/Paste ──
  bool enableCopy = false,
  bool enablePaste = false,
  void Function(List<T> rows, List<OiTableColumn<T>> columns, String formatted)? onCopy,
  void Function(String clipboardData)? onPaste,

  // ── Status Bar ──
  bool showStatusBar = false,
  List<OiTableAggregation<T>>? aggregations,

  // ── States ──
  bool loading = false,
  Widget? emptyState,
  Widget? loadingState,

  // ── Context Menu ──
  List<OiMenuItem> Function(T row)? rowContextMenu,
  List<OiMenuItem> Function(OiTableColumn<T>)? columnContextMenu,

  // ── Callbacks ──
  ValueChanged<T>? onRowTap,
  ValueChanged<T>? onRowDoubleTap,

  // ── Settings Persistence ──
  OiSettingsDriver? settingsDriver,
  String? settingsKey,
  Duration settingsSaveDebounce = const Duration(milliseconds: 500),

  // ── A11y ──
  required String label,
})
```

**New classes:**

```dart
enum OiCellEditTrigger {
  /// Single click on a cell enters edit mode.
  tap,
  /// Double click enters edit mode. Single click selects the row.
  doubleTap,
  /// No automatic trigger — editing is only triggered programmatically.
  none,
}

class OiTableColumnGroup {
  final String title;
  final List<String> columnIds;
}

class OiTableAggregation<T> {
  final String columnId;
  final String label;
  final String Function(List<T> rows) compute;
}

class OiPaginationConfig {
  const OiPaginationConfig({
    this.mode = OiPaginationMode.pages,
    this.pageSize = 25,
    this.pageSizeOptions = const [10, 25, 50, 100],
    this.showPageSizeSelector = true,
    this.showPageNumbers = true,
    this.showTotalCount = true,
    this.showFirstLast = true,
    this.maxVisiblePages = 7,
  });

  final OiPaginationMode mode;
  final int pageSize;
  final List<int> pageSizeOptions;
  final bool showPageSizeSelector;
  final bool showPageNumbers;
  final bool showTotalCount;
  final bool showFirstLast;
  final int maxVisiblePages;
}

enum OiPaginationMode {
  /// Classic page numbers: « 1 2 3 ... 10 »
  pages,
  /// Load more button at the bottom.
  loadMore,
  /// Infinite scroll — loads next page when near bottom.
  infinite,
  /// Cursor-based pagination (for APIs that use cursor tokens).
  cursor,
}
```

---

## Pagination System

### OiPaginationController

A dedicated controller for managing pagination state. Works for both client-side (all data in memory, table slices it) and server-side (table requests data per page).

```dart
class OiPaginationController extends ChangeNotifier {
  OiPaginationController({
    this.initialPage = 1,
    this.initialPageSize = 25,
    this.totalRows,
    this.serverSide = false,
    this.onPageChange,
    this.onPageSizeChange,
    this.cursorToken,
  });

  /// Whether pagination is server-side (table requests new data per page)
  /// or client-side (table slices the full rows list).
  final bool serverSide;

  /// Total number of rows across all pages. Required for page number display.
  /// For server-side, this is set by the consumer after each fetch.
  int? totalRows;

  /// Callback when the user navigates to a different page.
  /// For server-side: consumer fetches new data and updates [rows] + [totalRows].
  /// For client-side: table slices internally.
  void Function(int page, int pageSize)? onPageChange;

  /// Callback when the user changes the page size.
  void Function(int newPageSize)? onPageSizeChange;

  // ── State ──
  int _currentPage;
  int _pageSize;
  String? cursorToken;
  bool _loading = false;
  bool _hasNextPage = true;

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  bool get loading => _loading;
  bool get hasNextPage => _hasNextPage;

  int get totalPages => totalRows != null ? (totalRows! / _pageSize).ceil() : 0;
  bool get hasPreviousPage => _currentPage > 1;
  int get startRow => (_currentPage - 1) * _pageSize;
  int get endRow => startRow + _pageSize;

  // ── Navigation ──
  void goToPage(int page) {
    if (page < 1 || (totalPages > 0 && page > totalPages)) return;
    _currentPage = page;
    notifyListeners();
    onPageChange?.call(_currentPage, _pageSize);
  }

  void nextPage() => goToPage(_currentPage + 1);
  void previousPage() => goToPage(_currentPage - 1);
  void firstPage() => goToPage(1);
  void lastPage() => goToPage(totalPages);

  void setPageSize(int newSize) {
    _pageSize = newSize;
    _currentPage = 1; // Reset to first page on size change.
    notifyListeners();
    onPageSizeChange?.call(_pageSize);
    onPageChange?.call(_currentPage, _pageSize);
  }

  void setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  void setHasNextPage(bool has) {
    _hasNextPage = has;
    notifyListeners();
  }

  void setTotalRows(int total) {
    totalRows = total;
    notifyListeners();
  }

  /// For cursor-based pagination.
  void setCursor(String? cursor) {
    cursorToken = cursor;
    _hasNextPage = cursor != null;
    notifyListeners();
  }
}
```

### Pagination UI (rendered by OiTable)

The pagination footer is rendered below the table body. It adapts based on `OiPaginationMode`:

**Pages mode:**
```
┌──────────────────────────────────────────────────────────────────────┐
│ Showing 26-50 of 1,234 rows  │  Rows per page: [25 ▾]  │ « ‹ 1 2 [3] 4 5 ... 50 › » │
└──────────────────────────────────────────────────────────────────────┘
```

**Load more mode:**
```
┌──────────────────────────────────────────────────────────────────────┐
│                     [Load more] (showing 50 of 1,234)                │
└──────────────────────────────────────────────────────────────────────┘
```

**Infinite mode:**
No footer — `OiInfiniteScroll` triggers `paginationController.nextPage()` at scroll bottom.

**Cursor mode:**
Same as pages mode visually, but "Previous" may be disabled (cursor-based APIs often don't support backward navigation). Page numbers may be hidden.

### Client-side vs. Server-side

| Aspect | Client-side | Server-side |
|--------|-------------|-------------|
| Data | Consumer provides ALL rows | Consumer provides current page's rows |
| Slicing | Table slices `rows[start:end]` internally | Consumer fetches per-page data |
| Sort | Table sorts full list locally | Consumer sorts on server |
| Filter | Table filters locally | Consumer filters on server |
| Total count | `rows.length` | Consumer sets `controller.totalRows` |
| `clientSideSort` | `true` | `false` |
| `clientSideFilter` | `true` | `false` |
| `paginationController.serverSide` | `false` | `true` |

**Server-side flow:**
1. Table mounts with `paginationController` (serverSide: true).
2. Consumer listens to `onPageChange(page, pageSize)`, fetches data, updates `rows` and `controller.totalRows`.
3. During fetch, consumer sets `controller.setLoading(true)` — table shows loading bar.
4. After fetch, consumer sets `controller.setLoading(false)` and provides new `rows`.

**Client-side flow:**
1. Consumer provides all rows. `paginationController` (serverSide: false).
2. Table internally slices: `displayedRows = rows.sublist(controller.startRow, min(controller.endRow, rows.length))`.
3. `controller.totalRows` auto-set to `rows.length`.
4. Sort + filter applied before slicing.

---

## Inline Editing System

### Design: Seamless Cell Transition

The v2 inline editing system ensures **zero visual jump** when transitioning from display to edit mode. This means:

1. The edit widget must be **pixel-identical** to the display widget in its initial state. Same font, same padding, same alignment, same height.
2. The transition is not a "replace" — it's an **overlay morph**. The display widget stays in place, and the edit widget fades in on top with a 0ms delay (instant), inheriting the exact position and size.
3. The cell border/background subtly transitions to indicate edit mode (e.g., a 1px primary border fades in over 100ms).

### How It Works

```dart
// The table's internal cell rendering logic:

Widget _buildCell(T row, OiTableColumn<T> column) {
  final isEditing = _editingCell?.rowKey == rowKey(row) &&
                    _editingCell?.columnId == column.id;

  if (!isEditing) {
    // Display mode — normal cellBuilder output.
    return GestureDetector(
      onDoubleTap: editableCells && column.editable
          ? () => _startEditing(row, column)
          : null,
      child: _CellFrame(
        column: column,
        child: cellBuilder(row, column),
      ),
    );
  }

  // Edit mode — seamless editor.
  return _CellFrame(
    column: column,
    editing: true,
    child: _buildCellEditor(row, column),
  );
}
```

**`_CellFrame`** is an internal widget that provides:
- Identical padding in both display and edit mode.
- A subtle border that transitions from `transparent` to `primary.s300` in 100ms on edit.
- A subtle background shift from `transparent` to `surface.s50` in 100ms on edit.
- Fixed height matching the row height — the cell never grows or shrinks during editing.

### Built-in Cell Editors

When `cellEditorBuilder` is null, the table uses built-in editors based on column type:

| Column type hint | Display | Editor |
|-----------------|---------|--------|
| `text` (default) | `OiLabel` with text | `OiTextInput` with identical font/size |
| `number` | `OiLabel` with formatted number | `OiNumberInput` with same alignment |
| `date` | `OiLabel` with formatted date | `OiDateInput` (inline, not popup) |
| `select` | `OiLabel` with selected label | `OiSelect` dropdown |
| `bool` | `OiCheckbox` or text | `OiCheckbox` (toggles immediately) |
| `custom` | Custom `cellBuilder` output | Custom `cellEditorBuilder` output |

The column type hint is specified via a new field:

```dart
class OiTableColumn<T> {
  // ... existing fields ...

  /// Type hint for the built-in cell editor.
  /// When [editable] is true and no [cellEditorBuilder] is provided,
  /// this determines which editor widget is used.
  final OiCellType cellType;

  /// For select-type columns: the available options.
  final List<OiSelectOption>? selectOptions;

  /// Validation function for cell editing.
  /// Returns null if valid, error message if invalid.
  final String? Function(dynamic value)? validate;

  /// Whether this individual column is editable.
  /// Only effective when the table's [editableCells] is also true.
  final bool editable;
}

enum OiCellType { text, number, date, select, bool, custom }
```

### Edit Flow

1. **Trigger:** User double-clicks cell (or single-click if `editTrigger=tap`, or programmatic).
2. **Transition:** Display widget stays, edit widget fades in on top (0ms for the widget, 100ms for the border/background).
3. **Focus:** Edit widget is auto-focused. For text: cursor placed at end. For select: dropdown opens.
4. **Navigation:** Tab moves to next editable cell in the row. Shift+Tab moves to previous. Down arrow moves to same column in next row (and enters edit there). Up arrow moves to previous row.
5. **Save:** Enter or Tab confirms. `onCellEdit(row, column, newValue)` fires. If `onCellEditAsync` is provided, a loading spinner shows in the cell until the Future resolves. If the Future returns `false`, the cell reverts with an error flash (red border for 500ms).
6. **Cancel:** Escape reverts to original value and exits edit mode.
7. **Validation:** If `column.validate` returns a non-null string, the error is shown as a tooltip below the cell and save is blocked.
8. **Blur:** Clicking outside the cell saves (like `OiEditable.saveOnBlur`).

### Async Save

```dart
void Function(T row, OiTableColumn<T> column, dynamic newValue)? onCellEdit;
Future<bool> Function(T row, OiTableColumn<T> column, dynamic newValue)? onCellEditAsync;
```

- `onCellEdit` — synchronous. Fire-and-forget. Cell exits edit mode immediately.
- `onCellEditAsync` — asynchronous. Cell shows a tiny inline spinner while the Future is pending. Returns `true` → save accepted, cell exits edit. Returns `false` → save rejected, cell shows error flash, stays in edit mode with the value highlighted so the user can correct it.
- If both are provided, `onCellEditAsync` takes precedence.

---

## Column Management

### Column Header Dropdown Menu

Right-click or click the header "⋮" button opens a context menu per column:

```
┌────────────────────────┐
│  Sort Ascending      ▴ │
│  Sort Descending     ▾ │
│  ───────────────────── │
│  Filter...             │
│  Clear Filter          │
│  ───────────────────── │
│  Freeze Left           │
│  Freeze Right          │
│  Unfreeze              │
│  ───────────────────── │
│  Auto-fit Column       │
│  Auto-fit All Columns  │
│  ───────────────────── │
│  Hide Column           │
│  ───────────────────── │
│  Column Settings...    │  ← opens full column management panel
└────────────────────────┘
```

### Column Management Panel

A side panel (via `OiPanel`) for managing all columns at once:

```
┌──────────────────────────────┐
│  Columns                [×]  │
│  ───────────────────────     │
│  🔍 Search columns           │
│                              │
│  ☑ ≡ Name          [📌L]    │  ← check=visible, ≡=drag, pin indicator
│  ☑ ≡ Email                   │
│  ☐ ≡ Phone      (hidden)     │  ← unchecked=hidden
│  ☑ ≡ Created                 │
│  ☑ ≡ Status                  │
│                              │
│  [Show All]  [Hide All]      │
│  [Reset to Default]          │
└──────────────────────────────┘
```

- **Checkboxes** toggle column visibility.
- **Drag handles (≡)** reorder columns via `OiReorderable`.
- **Pin indicator** shows freeze state (📌L = frozen left, 📌R = frozen right).
- Click a pin indicator to cycle: none → frozen left → frozen right → none.
- **Search** filters the column list.
- **Reset** calls `resetSettings()` from `OiSettingsMixin`.
- All changes auto-save via the settings driver (if provided).

### Auto-fit Columns

**Double-click** on a column resize handle → auto-fits the column to its content:
1. Measures the rendered width of the header text.
2. Measures the rendered width of the widest visible cell in that column (scans visible rows only for performance).
3. Sets the column width to `max(headerWidth, maxCellWidth) + padding`.
4. Respects `minWidth` and `maxWidth`.

**Auto-fit All Columns** does this for every column.

### Column Resize Indicator

When dragging a column edge to resize:
- A vertical dashed line follows the cursor across the full table height.
- The new width is shown in a small floating label at the top: `"Width: 180px"`.
- On mouse-up, the column snaps to the new width and fires `updateSettings`.

---

## Settings Persistence Integration

The table persists the following settings automatically when a driver is provided:

| Setting | When it changes | Debounce |
|---------|----------------|----------|
| Column order | Column header drag-reorder | 500ms |
| Column widths | Column resize drag | 500ms |
| Column visibility | Toggle in column management panel | 500ms |
| Frozen columns | Freeze/unfreeze from header menu | 500ms |
| Sort | Click column header | 500ms |
| Filters | Apply/clear column filter | 500ms |
| Page size | Change in pagination selector | 500ms |
| Expanded groups | Expand/collapse group headers | 500ms |

Settings **not** persisted (ephemeral per session):
- Selected rows (selection is transient)
- Expanded row details (transient)
- Current page number (resets to 1)
- Search query (resets to empty)
- Edit mode state (always exits)

### Reset Flow

The table's column management panel includes a "Reset to Default" button. This:
1. Calls `resetSettings()` on the mixin.
2. Deletes stored settings from the driver.
3. Reverts to `defaultSettings` derived from widget props.
4. Shows a toast: "Table settings reset to default".

---

## Table Controller

An optional controller for programmatic control:

```dart
class OiTableController<T> extends ChangeNotifier {
  /// Programmatically start editing a cell.
  void startEditing(Object rowKey, String columnId);

  /// Programmatically stop editing.
  void cancelEditing();

  /// Scroll to a specific row.
  void scrollToRow(Object rowKey, {bool highlight = true});

  /// Scroll to a specific column.
  void scrollToColumn(String columnId);

  /// Expand all groups.
  void expandAllGroups();

  /// Collapse all groups.
  void collapseAllGroups();

  /// Select a range of rows programmatically.
  void selectRange(Object fromKey, Object toKey);

  /// Export the current view (visible columns, applied sort/filters) as CSV.
  String exportCsv({bool includeHeaders = true, bool selectedOnly = false});

  /// Reset column widths, order, visibility to defaults.
  /// If settings driver is provided, also clears persisted settings.
  void resetColumnSettings();

  /// Auto-fit a specific column.
  void autoFitColumn(String columnId);

  /// Auto-fit all columns.
  void autoFitAllColumns();

  /// Get the current table settings (for manual save/export).
  OiTableSettings get currentSettings;
}
```

---

## Table Tests

### Unit Tests

| Test | What it verifies |
|------|-----------------|
| **Pagination Controller** | |
| `goToPage(3)` sets currentPage to 3 | Navigation |
| `goToPage(0)` is no-op | Boundary |
| `goToPage(totalPages + 1)` is no-op | Boundary |
| `nextPage()` increments | Forward |
| `previousPage()` decrements | Backward |
| `firstPage()` goes to 1 | First |
| `lastPage()` goes to totalPages | Last |
| `setPageSize(50)` resets to page 1 | Size change |
| `totalPages` computes correctly (ceil) | Math |
| `startRow` / `endRow` correct for page 3, size 25 | Slice bounds |
| `hasPreviousPage` false on page 1 | Boundary |
| `hasNextPage` false on last page | Boundary |
| `setCursor(null)` sets hasNextPage false | Cursor mode |
| `onPageChange` fires with correct args | Callback |
| **Client-Side Pagination** | |
| Table with 100 rows, pageSize 25: shows rows 1-25 | Slicing |
| Navigate to page 3: shows rows 51-75 | Correct slice |
| Last page with 8 remaining: shows 8 rows | Partial page |
| Client-side sort applies before slicing | Order correct |
| Client-side filter applies before slicing (and updates totalRows) | Count correct |
| **Cell Editor Type Mapping** | |
| `cellType: text` → OiTextInput editor | Correct editor |
| `cellType: number` → OiNumberInput editor | Correct editor |
| `cellType: date` → OiDateInput editor | Correct editor |
| `cellType: select` → OiSelect editor | Correct editor |
| `cellType: bool` → OiCheckbox editor | Correct editor |
| `cellEditorBuilder` overrides built-in | Custom wins |
| **OiTableSettings Serialization** | |
| Full roundtrip: toJson → fromJson → equals original | Serialization |
| mergeWith adds new columns from defaults | Backwards compat |
| mergeWith prunes removed columns | Forward compat |
| mergeWith preserves saved sort if column still exists | Valid sort |
| mergeWith clears saved sort if column removed | Invalid sort |
| **Auto-Fit Calculation** | |
| Auto-fit measures header and cells correctly | Width calculation |
| Auto-fit respects minWidth | Lower bound |
| Auto-fit respects maxWidth | Upper bound |

### Widget Tests

| Test | What it verifies |
|------|-----------------|
| **Core Rendering** | |
| Columns and rows render | Headers + cells visible |
| Column groups render spanning headers | Group headers span correctly |
| Status bar renders aggregations | Footer with computed values |
| **Sorting** | |
| Header click fires onSort | Callback |
| Sort toggle: asc → desc → none | Cycle |
| Multi-sort: Ctrl+click adds secondary sort | Multiple sort indicators |
| Client-side sort: rows reorder in view | Visual order change |
| **Selection** | |
| Click selects row (single mode) | Single key in set |
| Click selects row (multi mode) | Key added |
| Shift+click range selects | Range selected |
| Ctrl+click toggles | Deselect works |
| Header checkbox: all/none/indeterminate | Three states |
| Space bar toggles focused row selection | Keyboard |
| **Column Resize** | |
| Drag column edge changes width | Width updates |
| Resize indicator line shows during drag | Visual feedback |
| Width label shows during drag | "Width: 180px" |
| minWidth enforced on drag | Cannot go below |
| maxWidth enforced on drag | Cannot go above |
| Double-click header edge auto-fits | Width adjusts to content |
| Settings driver saves new width after debounce | Persisted |
| **Column Reorder** | |
| Drag header to new position | Column moves |
| Settings driver saves new order | Persisted |
| **Column Visibility** | |
| Column management panel opens | Panel visible |
| Uncheck column hides it | Column gone |
| Check column shows it | Column appears |
| "Show All" checks all | All visible |
| "Hide All" unchecks all | All hidden (except at least 1) |
| Settings driver saves visibility | Persisted |
| **Column Freeze** | |
| Freeze left from header menu | Column pinned to left |
| Freeze right from header menu | Column pinned to right |
| Frozen column stays on horizontal scroll | Sticky |
| Unfreeze from header menu | Column scrolls normally |
| Settings driver saves freeze state | Persisted |
| **Column Header Menu** | |
| Right-click header opens dropdown | Menu visible |
| Sort ascending/descending from menu | Sort applied |
| Filter from menu opens filter popover | Filter UI |
| Hide column from menu | Column hidden |
| Auto-fit from menu | Column resized |
| **Inline Editing** | |
| Double-click cell enters edit mode | Editor visible |
| Edit widget is pixel-identical to display | No visual jump |
| Cell border transitions to primary on edit | Subtle indicator |
| Enter saves and exits edit | onCellEdit fires |
| Escape cancels and exits edit | Original value restored |
| Tab moves to next editable cell | Focus advances |
| Shift+Tab moves to previous editable cell | Focus retreats |
| Down arrow edits same column in next row | Vertical navigation |
| Blur saves (saveOnBlur) | Save on focus loss |
| Validation error shows tooltip | Error message |
| Validation error blocks save | Cannot save |
| Async save shows spinner | Loading in cell |
| Async save returns true: exits edit | Confirmed |
| Async save returns false: error flash, stays in edit | Rejected |
| `editTrigger=tap`: single click enters edit | Different trigger |
| `editTrigger=none`: no automatic trigger | Programmatic only |
| `cellEditorBuilder` renders custom editor | Custom widget |
| Bool column toggles immediately on click | No edit mode needed |
| **Pagination (Pages mode)** | |
| Page numbers render | Buttons visible |
| Click page 3 navigates | onPageChange fires |
| Next/previous buttons work | Navigation |
| First/last buttons work | Boundary navigation |
| Page size selector changes page size | Rows per page change |
| "Showing X-Y of Z" text correct | Count text |
| Current page highlighted | Active button |
| Ellipsis for many pages | "1 2 ... 50" |
| **Pagination (Load More mode)** | |
| Load more button visible | Button visible |
| Click fires nextPage | Append rows |
| "Showing X of Y" text correct | Count text |
| **Pagination (Infinite mode)** | |
| Scroll to bottom triggers load | OiInfiniteScroll |
| Loading spinner at bottom | Visible during load |
| **Pagination (Cursor mode)** | |
| Next page uses cursor token | Token passed |
| Previous disabled when no backward cursor | Button disabled |
| **Server-Side Pagination** | |
| onPageChange fires on navigation | Consumer fetches |
| Loading state during fetch | Loading bar |
| totalRows from controller updates UI | Count text |
| **Client-Side Pagination** | |
| Rows sliced correctly per page | Subset shown |
| Sort + filter applied before slice | Order correct |
| Filter reduces totalRows | Count updates |
| **Row Reorder** | |
| Drag row to new position | Row moves |
| onRowReorder fires with old/new index | Callback |
| **Copy/Paste** | |
| Ctrl+C copies selected rows | Clipboard content |
| Copy includes only visible columns | Column filter |
| Ctrl+V pastes into editable cells | Cells updated |
| **Grouping** | |
| Group headers render | Headers visible |
| Collapse group hides rows | Rows hidden |
| Expand group shows rows | Rows visible |
| expandedGroupKeys persisted via settings driver | Saved |
| **Settings Persistence** | |
| No driver: no persistence, all features work | Baseline |
| Driver + no key: global settings | Shared by instances |
| Driver + key: view-specific settings | Isolated |
| Settings loaded on mount | Restored |
| Settings debounce-saved on change | 500ms delay |
| Rapid resizes: only final width saved | Debounce |
| Reset button clears driver and reverts to defaults | Full reset |
| Schema migration: old saved data + new columns → merged | Backwards compat |
| Driver error on load: falls back to defaults | Graceful |
| Driver error on save: no crash, silent fail | Resilient |
| OiSettingsProvider provides driver to table without prop | Inherited |
| Table prop driver overrides provider driver | Explicit wins |
| **Keyboard Navigation** | |
| Arrow keys navigate cells | Focus moves |
| Enter starts cell edit (when editable) | Edit mode |
| Escape cancels edit | Exit edit |
| Tab in edit mode: save + next cell | Chain edit |
| Shift+Tab: save + previous cell | Reverse chain |
| Ctrl+A selects all rows | Select all |
| Ctrl+C copies | Copy |
| Home/End: first/last cell in row | Horizontal bounds |
| Ctrl+Home/End: first/last row | Vertical bounds |
| Page Up/Down: scroll by page | Scroll |
| **Accessibility** | |
| Table has semantics role `table` | Announced |
| Column headers announced with sort state | "Name, sorted ascending" |
| Cell content announced on navigation | Read aloud |
| Edit mode announced | "Editing cell" |
| Pagination controls labeled | "Page 3 of 50" |
| Status bar announced | "Showing 1,234 rows" |
| Column management panel labeled | "Column settings" |
| **Performance** | |
| 10,000 rows + virtual scroll: <16ms frame | Smooth |
| 100,000 rows + virtual scroll: <16ms frame | Smooth |
| Sort 10,000 rows client-side: <100ms | Responsive |
| Filter 10,000 rows client-side: <100ms | Responsive |
| 50 columns with horizontal scroll: <16ms frame | Smooth |
| Rapid column resize (60fps drag): no jank | Smooth |
| Rapid page navigation (click click click): stable | No race conditions |
| **Golden Tests** | |
| Table: default, light + dark | 2 |
| Table: with selection, grouped, filters active | 3 |
| Table: inline edit mode (text, number, date, select, bool) | 5 |
| Table: column resize indicator | 1 |
| Table: column management panel | 1 |
| Table: pagination bar (pages, load more) | 2 |
| Table: status bar with aggregations | 1 |
| Table: column groups with spanning headers | 1 |
| Table: frozen columns with horizontal scroll | 1 |
| Table: loading and empty states | 2 |
| Total goldens | 19 × 2 (light+dark) = 38 |

### Integration Tests

| Test | Scenario |
|------|----------|
| **Full Edit Flow** | Double-click cell → type new value → Enter → cell shows new value → value persisted if async confirms |
| **Edit + Tab Chain** | Double-click cell → type → Tab → next editable cell in edit mode → type → Tab → next → Enter → all saved |
| **Edit + Validation** | Double-click → type invalid → Enter → error tooltip shown → fix → Enter → saved |
| **Edit + Async Reject** | Double-click → type → Enter → spinner → server rejects → error flash → cell stays in edit |
| **Sort + Paginate** | Click sort → rows reorder → navigate to page 2 → rows on page 2 are correctly sorted |
| **Filter + Paginate** | Apply filter → total rows reduces → page count reduces → navigate pages within filtered set |
| **Resize + Persist** | Resize column → switch page → come back → column width still resized |
| **Reorder + Persist** | Drag column to new position → refresh → column order preserved |
| **Hide + Persist** | Open column panel → hide column → refresh → column still hidden |
| **Reset Settings** | Customize everything → Reset to Default → all settings reverted → driver cleared |
| **Server-Side Pagination** | Mount table → controller fires page 1 → consumer fetches → rows display → click page 2 → loading → new rows |
| **Cursor Pagination** | Load page → set cursor → click Next → cursor passed to callback → new data + new cursor |
| **Column Freeze + Scroll** | Freeze Name column → scroll right → Name stays visible, other columns scroll |
| **Full Keyboard Flow** | Tab into table → arrow keys → Enter edits → type → Tab to next → Escape cancels → arrow to select → Space toggles |

---

# Package Structure Additions

```
src/
  foundation/
    persistence/
      oi_settings_driver.dart        ★ NEW — abstract interface
      oi_settings_data.dart          ★ NEW — mixin
      oi_settings_mixin.dart         ★ NEW — widget integration mixin
      oi_settings_provider.dart      ★ NEW — InheritedWidget
      drivers/
        oi_local_storage_driver.dart ★ NEW — built-in
        oi_in_memory_driver.dart     ★ NEW — testing

  composites/
    data/
      oi_table.dart                  ★ REPLACED (v2)
      oi_table_controller.dart       ★ NEW
      oi_pagination_controller.dart  ★ NEW

  models/
    settings/
      oi_table_settings.dart         ★ NEW
      oi_file_explorer_settings.dart ★ NEW
      oi_kanban_settings.dart        ★ NEW
      oi_sidebar_settings.dart       ★ NEW
      oi_dashboard_settings.dart     ★ NEW
      oi_split_pane_settings.dart    ★ NEW
      oi_list_view_settings.dart     ★ NEW
```

---

End of specification.
