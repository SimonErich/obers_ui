# Settings Persistence

ObersUI widgets can automatically save and restore user preferences —
column widths, sort order, view modes, collapsed panels, and more. This is
powered by a pluggable **settings driver** system plus an `OiSettingsMixin`
that widget authors mix into their `State`.

## How it works

1. You provide a `settingsDriver` to `OiApp`.
2. `OiApp` places it in the tree via an `OiSettingsProvider`
   (`InheritedWidget`).
3. Widgets that mix in `OiSettingsMixin` read that driver via
   `OiSettingsProvider.of(context)` and auto-save their state with
   debouncing.

```dart
OiApp(
  settingsDriver: OiLocalStorageDriver(),  // Persists to SharedPreferences / localStorage
  theme: OiThemeData.light(),
  home: const MyHomePage(),
)
```

For built-in widgets (tables, file explorer, tabs, …) that's all you need.
No per-widget configuration is required.

## Available drivers

| Driver | Storage | Use case |
| --- | --- | --- |
| `OiLocalStorageDriver` | `SharedPreferences` (mobile) / `localStorage` (web) | Production apps |
| `OiInMemorySettingsDriver` | RAM only | Testing, prototyping |

### Custom driver

Implement `OiSettingsDriver` for your own backend. The abstract base class
defines four methods; override them and use the protected `resolveKey`
helper to compose the storage key:

```dart
class ApiSettingsDriver extends OiSettingsDriver {
  const ApiSettingsDriver(this.api);
  final Api api;

  @override
  Future<T?> load<T extends OiSettingsData>({
    required String namespace,
    required T Function(Map<String, dynamic> json) deserialize,
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
    required Map<String, dynamic> Function(T data) serialize,
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

`resolveKey` defaults to `"$namespace"` (no key) or `"$namespace::$key"`
(with key). Override it if your backend needs a different shape (e.g. a
REST path).

## What gets persisted

| Widget | Persisted settings |
| --- | --- |
| `OiTable` | Column order, widths, visibility, sort, filters, page size, groups |
| `OiFileManager` | View mode, sort, sidebar state, favorites, recent paths |
| `OiKanban` | Column order, collapsed columns, WIP limits |
| `OiListView` | Layout mode, sort, filters, page size |
| `OiGroupedList` | Collapsed groups, group order |
| `OiSidebar` | Mode, width, collapsed sections, selected item |
| `OiAppShell` | Sidebar state, drawer state, responsive mode overrides |
| `OiDashboard` | Card positions and dimensions |
| `OiCalendar` | View type, date range, collapsed categories |
| `OiGantt` | Zoom level, scroll position, collapsed groups |
| `OiAccordion` | Expanded section indices |
| `OiTabs` | Tab order, selected index |
| `OiFilterBar` | Active filters, filter order |

A few widgets ship a **settings data class** (under `lib/src/models/settings/`)
that is not currently mixed into a widget — e.g. `OiSplitPaneSettings`,
`OiConsentBannerSettings`. If you want those persisted, implement the
mixin contract in your own wrapper or use the settings model directly with
your own `OiSettingsDriver` calls.

Each widget declares a `settingsKey` parameter so multiple instances of the
same widget type can have independent storage:

```dart
// These save to different keys automatically
OiTable(settingsKey: 'users-table', ...)
OiTable(settingsKey: 'orders-table', ...)
```

## The `OiSettingsData` contract

Every settings class implements the `OiSettingsData` mixin on an
`@immutable` data class. The mixin defines **two** members:

- `Map<String, dynamic> toJson()` — serialize to a JSON map. The map
  **must** include a `'schemaVersion'` key.
- `int get schemaVersion` — bump when adding, removing, or renaming fields
  so future reads can detect and migrate older payloads.

**`fromJson` is _not_ on the mixin.** Each concrete settings class
declares its own `factory MyType.fromJson(Map<String, dynamic> json)`
constructor — the deserialization contract lives per-class, not on the
mixin, so each class can validate shape / defaults for its own fields.

Example:

```dart
@immutable
class MySettings with OiSettingsData {
  const MySettings({this.pageSize = 25});
  final int pageSize;

  @override
  int get schemaVersion => 1;

  @override
  Map<String, dynamic> toJson() => {
        'pageSize': pageSize,
        'schemaVersion': schemaVersion,
      };

  factory MySettings.fromJson(Map<String, dynamic> json) =>
      MySettings(pageSize: (json['pageSize'] as int?) ?? 25);
}
```

Merging saved settings with current defaults (to forward-fill newly-added
fields) is handled by the consumer — typically `mergeSettings` on
`OiSettingsMixin` (see below).

## Debouncing

Settings are auto-saved with a **500ms debounce** by default — rapid
changes (dragging a column wider, toggling a filter) don't spam the
storage backend. The debounce is a parameter on `updateSettings(...)`
inside `OiSettingsMixin`, so widget authors can tune it per call
(`debounce: Duration.zero` for immediate saves, or longer for noisy inputs).

## Adding persistence to a custom widget

To opt a custom widget into persistence, mix `OiSettingsMixin` into its
`State` and supply the five abstract members. The mixin handles
load-on-init, debounced saves, and defaults.

### `OiSettingsMixin<W, T>` — API reference

Mixin on `State<W>` where `W extends StatefulWidget` and
`T extends OiSettingsData`. Source:
[lib/src/foundation/persistence/oi_settings_mixin.dart](../../../lib/src/foundation/persistence/oi_settings_mixin.dart).

**Abstract members you must implement:**

| Member | Type | Purpose |
| --- | --- | --- |
| `settingsNamespace` | `String` | Primary storage key — usually a widget-type identifier (e.g. `'table'`). |
| `settingsKey` | `String?` (default `null`) | Optional sub-key for per-instance isolation (e.g. a record ID). |
| `settingsDriver` | `OiSettingsDriver?` | The driver to persist through. Return `null` to disable persistence. Read via `OiSettingsProvider.of(context)` unless you pass a driver in `widget`. |
| `defaultSettings` | `T` | Fallback value when nothing is saved. |
| `deserializeSettings(json)` | `T Function(Map<String, dynamic>)` | JSON → typed settings. Usually `T.fromJson(json)`. |
| `mergeSettings(saved, defaults)` | `T Function(T, T)` | Reconcile a loaded value with current defaults — called after a successful load so new fields keep their defaults. |

**Reactive state the mixin exposes:**

| Getter | Description |
| --- | --- |
| `T get currentSettings` | The live in-memory settings value. Falls back to `defaultSettings` until the first load completes. |
| `bool get settingsLoaded` | `true` once the initial driver load has completed (whether data was found or not). |
| `bool get settingsLoadError` | `true` if the last load threw; `currentSettings` will contain `defaultSettings` as a fallback. |

**Protected methods you call from your widget logic:**

| Method | Description |
| --- | --- |
| `void updateSettings(T settings, {Duration debounce = const Duration(milliseconds: 500)})` | Replace the current value and schedule a debounced save. Calls `setState` so the UI re-renders. Pass `Duration.zero` to save on the next event-loop tick. |
| `Future<void> saveSettingsNow()` | Cancel any pending debounce and persist immediately. Useful before navigating away. |
| `Future<void> resetSettings()` | Delete persisted settings and reset the in-memory value to `defaultSettings`. |
| `Future<void> reloadSettings()` | Re-read from the driver. Call from `didUpdateWidget` when the driver or key changes. |

**Lifecycle:**

- `initState` seeds `_settings` with `defaultSettings` and kicks off an
  async load. Load failures fall back to defaults silently (and set
  `settingsLoadError = true`).
- `dispose` cancels any pending debounced save. Pending saves are **not**
  flushed automatically — call `saveSettingsNow()` yourself if you need
  that guarantee.

### `OiSettingsProvider` — API reference

InheritedWidget that carries an `OiSettingsDriver` down the tree. `OiApp`
wraps your app in one automatically when you pass `settingsDriver`; you
can also place one manually to scope a driver to a subtree.

Source:
[lib/src/foundation/persistence/oi_settings_provider.dart](../../../lib/src/foundation/persistence/oi_settings_provider.dart).

| Member | Type | Description |
| --- | --- | --- |
| `driver` | `OiSettingsDriver` | The driver being provided. |
| `OiSettingsProvider.of(context)` | `static OiSettingsDriver?` | The nearest driver in the tree, or `null` if none is present. |

```dart
OiSettingsProvider(
  driver: OiLocalStorageDriver(),
  child: MyFeature(),
)

// Inside any descendant State:
final driver = OiSettingsProvider.of(context);
```

### End-to-end example

```dart
@immutable
class CounterSettings with OiSettingsData {
  const CounterSettings({this.count = 0});
  final int count;

  @override int get schemaVersion => 1;

  @override
  Map<String, dynamic> toJson() => {
        'count': count,
        'schemaVersion': schemaVersion,
      };

  factory CounterSettings.fromJson(Map<String, dynamic> json) =>
      CounterSettings(count: (json['count'] as int?) ?? 0);

  CounterSettings copyWith({int? count}) =>
      CounterSettings(count: count ?? this.count);
}

class PersistentCounter extends StatefulWidget {
  const PersistentCounter({super.key, this.settingsKey});
  final String? settingsKey;

  @override
  State<PersistentCounter> createState() => _PersistentCounterState();
}

class _PersistentCounterState extends State<PersistentCounter>
    with OiSettingsMixin<PersistentCounter, CounterSettings> {
  @override String get settingsNamespace => 'persistent_counter';
  @override String? get settingsKey => widget.settingsKey;
  @override OiSettingsDriver? get settingsDriver =>
      OiSettingsProvider.of(context);
  @override CounterSettings get defaultSettings => const CounterSettings();
  @override CounterSettings deserializeSettings(Map<String, dynamic> json) =>
      CounterSettings.fromJson(json);
  @override CounterSettings mergeSettings(
    CounterSettings saved,
    CounterSettings defaults,
  ) => saved;

  void _increment() {
    updateSettings(currentSettings.copyWith(count: currentSettings.count + 1));
  }

  @override
  Widget build(BuildContext context) {
    if (!settingsLoaded) return const SizedBox.shrink();
    return OiButton.primary(
      label: 'Count: ${currentSettings.count}',
      onTap: _increment,
    );
  }
}
```
