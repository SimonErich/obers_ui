# Custom Persistence Drivers

ObersUI widgets can save and restore user preferences. Column widths, sort order,
filters, layout, and view modes survive a page reload or an app restart. A driver
decides where that state is stored. You get two drivers by default, and you can
write your own to point at any backend.

## How persistence works

Persistence has four parts:

1. A driver stores and reads serialized settings. It implements `OiSettingsDriver`.
2. `OiSettingsProvider` carries a driver down the widget tree. `OiApp` places one
   for you when you pass `settingsDriver`.
3. A settings data class implements `OiSettingsData`. It knows how to serialize
   itself to JSON.
4. `OiSettingsMixin` lives on a widget's `State`. It loads on init, debounces
   saves, and falls back to defaults.

You wire the driver once on `OiApp`. Every built-in widget that supports
persistence reads it from the tree.

```dart
OiApp(
  settingsDriver: OiLocalStorageDriver(),
  theme: OiThemeData.light(),
  home: const MyHomePage(),
)
```

That is all the setup a table or a file explorer needs. No per-widget driver
wiring is required.

## What gets persisted

Persistence covers the state a user changes to fit their own workflow. It does
not touch your app data. A widget opts in by taking a persistence parameter,
usually a `settingsKey` that scopes its storage.

| Widget | Persisted state |
| --- | --- |
| `OiTable` | Column order, widths, visibility, sort, filters, page size, groups |
| `OiListView` | Layout mode, sort, filters, page size |
| `OiFileManager` | View mode, sort, sidebar state, favorites, recent paths |
| `OiKanban` | Column order, collapsed columns, WIP limits |
| `OiGroupedList` | Collapsed groups, group order |
| `OiSidebar` | Mode, width, collapsed sections, selected item |
| `OiAppShell` | Sidebar state, drawer state, responsive mode overrides |
| `OiDashboard` | Card positions and dimensions |
| `OiCalendar` | View type, date range, collapsed categories |
| `OiGantt` | Zoom level, scroll position, collapsed groups |
| `OiTabs` | Tab order, selected index |
| `OiAccordion` | Expanded section indices |
| `OiFilterBar` | Active filters, filter order |

A `settingsKey` keeps two instances of the same widget type apart. Give each one
its own key so they save to separate slots.

```dart
OiTable(settingsKey: 'users-table', ...)
OiTable(settingsKey: 'orders-table', ...)
```

## OiSettingsDriver

The interface every driver implements. It is small. Four methods cover load,
save, delete, and existence checks. Drivers are stateless and do not cache.
Caching is the job of `OiSettingsMixin`.

```dart
abstract class OiSettingsDriver {
  const OiSettingsDriver();

  Future<T?> load<T extends OiSettingsData>({
    required String namespace,
    required T Function(Map<String, dynamic> json) deserialize,
    String? key,
  });

  Future<void> save<T extends OiSettingsData>({
    required String namespace,
    required T data,
    required Map<String, dynamic> Function(T data) serialize,
    String? key,
  });

  Future<void> delete({required String namespace, String? key});

  Future<bool> exists({required String namespace, String? key});
}
```

| Method | Returns | Purpose |
| --- | --- | --- |
| `load` | `Future<T?>` | Read settings. Return `null` when nothing is saved or the data is unusable. Never throws. |
| `save` | `Future<void>` | Write serialized settings. |
| `delete` | `Future<void>` | Remove settings. After this, `load` returns `null` and `exists` returns `false`. |
| `exists` | `Future<bool>` | Report whether settings are stored for the key. |
| `resolveKey` | `String` | Protected helper that builds the storage key. Override it if your backend needs a different shape. |

`resolveKey` returns `namespace` when `key` is `null`, or `"$namespace::$key"`
when a key is set. Override it for a path-based REST backend or any other key
scheme.

## OiLocalStorageDriver

The driver for production apps. It writes to `SharedPreferences` on mobile and
desktop, and to `localStorage` on web. Reads that hit corrupt or missing data
return `null` instead of throwing.

```dart
OiApp(
  settingsDriver: OiLocalStorageDriver(),
  home: const MyHomePage(),
)
```

Every stored key gets a prefix. The default is `obers_ui`, so a table with
`settingsKey: 'users-table'` lands under a key like
`obers_ui.oi_table::users-table`. Set a custom prefix to separate environments
or apps that share one storage backend.

```dart
OiLocalStorageDriver(prefix: 'admin_console')
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `prefix` | `String` | `'obers_ui'` | Prepended to every storage key as `"$prefix.$namespace"`. |

## OiInMemorySettingsDriver

A driver that keeps settings in a `Map` in RAM. Nothing is written to disk or
network. State is lost when the driver is garbage collected. Reach for it in
tests and quick prototypes.

```dart
final driver = OiInMemorySettingsDriver();

OiApp(
  settingsDriver: driver,
  home: const MyHomePage(),
)
```

It exposes its `store` map so tests can assert on what was written, plus a
`clear()` method to reset between tests.

| Member | Type | Description |
| --- | --- | --- |
| `store` | `Map<String, Map<String, dynamic>>` | The raw internal store, keyed by `resolveKey` output. Read it in test assertions. |
| `clear()` | `void` | Removes all stored settings. Call it in `tearDown`. |

!!! note
    The class is named `OiInMemorySettingsDriver`. Some older notes call it
    `OiInMemoryDriver`. Use `OiInMemorySettingsDriver`.

## Writing a custom driver

To store settings in your own backend, extend `OiSettingsDriver` and implement
the four methods. Use the protected `resolveKey` helper to compose the storage
key so your driver matches the built-in key format.

```dart
class ApiSettingsDriver extends OiSettingsDriver {
  const ApiSettingsDriver(this.api);
  final SettingsApi api;

  @override
  Future<T?> load<T extends OiSettingsData>({
    required String namespace,
    required T Function(Map<String, dynamic> json) deserialize,
    String? key,
  }) async {
    final json = await api.get(resolveKey(namespace, key));
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
    await api.put(resolveKey(namespace, key), serialize(data));
  }

  @override
  Future<void> delete({required String namespace, String? key}) async {
    await api.delete(resolveKey(namespace, key));
  }

  @override
  Future<bool> exists({required String namespace, String? key}) async {
    return api.has(resolveKey(namespace, key));
  }
}
```

Two rules keep a custom driver well behaved. Return `null` from `load` on any
read error rather than throwing. Keep the driver stateless, since the mixin holds
the live value in memory.

Pass the driver to `OiApp` the same way as a built-in one.

```dart
OiApp(
  settingsDriver: ApiSettingsDriver(myApi),
  home: const MyHomePage(),
)
```

## OiSettingsData

The serialization contract for a settings class. Implement it on an `@immutable`
data class. The mixin has two members.

| Member | Type | Description |
| --- | --- | --- |
| `toJson()` | `Map<String, dynamic>` | Serialize to a JSON-encodable map. The map must include a `'schemaVersion'` key. |
| `schemaVersion` | `int` | Bump when you add, remove, or rename fields so older payloads can be detected. |

`fromJson` is not on the mixin. Each settings class declares its own
`factory MyType.fromJson(...)` so it can validate and default its own fields.

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

## OiSettingsProvider

An `InheritedWidget` that carries an `OiSettingsDriver` down the tree. `OiApp`
wraps your app in one when you pass `settingsDriver`. You can also place one by
hand to scope a driver to a subtree.

```dart
OiSettingsProvider(
  driver: OiLocalStorageDriver(),
  child: MyFeature(),
)

// Inside any descendant State:
final driver = OiSettingsProvider.of(context);
```

| Member | Type | Description |
| --- | --- | --- |
| `driver` | `OiSettingsDriver` | The driver made available to the subtree. Required on the constructor. |
| `OiSettingsProvider.of(context)` | `static OiSettingsDriver?` | The nearest driver in the tree, or `null` when none is present. |

## OiSettingsMixin

Mix `OiSettingsMixin<W, T>` into a `State` to give a custom widget the same
persistence as the built-ins. `W` is your `StatefulWidget`. `T` is your
`OiSettingsData` class. The mixin loads on init, debounces saves, and falls back
to defaults on error.

You implement six members.

| Member | Type | Purpose |
| --- | --- | --- |
| `settingsNamespace` | `String` | The primary storage key, usually a widget-type name like `'table'`. |
| `settingsKey` | `String?` | Optional sub-key for per-instance isolation, such as a record ID. Defaults to `null`. |
| `settingsDriver` | `OiSettingsDriver?` | The driver to persist through. Return `null` to disable persistence. Read it from `OiSettingsProvider.of(context)`. |
| `defaultSettings` | `T` | The value used when nothing is saved. |
| `deserializeSettings(json)` | `T` | Turn a JSON map into typed settings. Usually `T.fromJson(json)`. |
| `mergeSettings(saved, defaults)` | `T` | Reconcile a loaded value with current defaults after a load, so new fields keep their defaults. |

The mixin exposes state you read in `build`.

| Getter | Type | Description |
| --- | --- | --- |
| `currentSettings` | `T` | The live in-memory value. Falls back to `defaultSettings` until the first load finishes. |
| `settingsLoaded` | `bool` | `true` once the initial load completes, whether or not data was found. |
| `settingsLoadError` | `bool` | `true` when the last load failed. `currentSettings` then holds the defaults. |

The mixin gives you methods to change and flush settings.

| Method | Description |
| --- | --- |
| `updateSettings(settings, {debounce})` | Replace the value and schedule a debounced save. Calls `setState`. Debounce defaults to 500ms. Pass `Duration.zero` to save on the next tick. |
| `saveSettingsNow()` | Cancel any pending debounce and save now. Call it before navigating away. |
| `resetSettings()` | Delete stored settings and reset to `defaultSettings`. |
| `reloadSettings()` | Re-read from the driver. Call it from `didUpdateWidget` when the driver or key changes. |

!!! warning
    `dispose` cancels a pending debounced save but does not flush it. If you need
    the last change saved, call `saveSettingsNow()` yourself before disposal.

Here is a small widget that saves a counter through whatever driver is in the
tree.

```dart
@immutable
class CounterSettings with OiSettingsData {
  const CounterSettings({this.count = 0});
  final int count;

  @override
  int get schemaVersion => 1;

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
  @override
  String get settingsNamespace => 'persistent_counter';

  @override
  String? get settingsKey => widget.settingsKey;

  @override
  OiSettingsDriver? get settingsDriver => OiSettingsProvider.of(context);

  @override
  CounterSettings get defaultSettings => const CounterSettings();

  @override
  CounterSettings deserializeSettings(Map<String, dynamic> json) =>
      CounterSettings.fromJson(json);

  @override
  CounterSettings mergeSettings(
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

## Testing with the in-memory driver

Tests should not touch disk or the network. Use `OiInMemorySettingsDriver` in
place of the local storage driver. It runs synchronously and lets you read the
`store` map to assert what a widget saved.

```dart
testWidgets('table remembers its page size', (tester) async {
  final driver = OiInMemorySettingsDriver();

  await tester.pumpWidget(
    OiApp(
      settingsDriver: driver,
      home: OiTable(settingsKey: 'users-table', ...),
    ),
  );

  // Drive the UI to change a persisted setting, then let the debounce fire.
  await tester.pumpAndSettle(const Duration(milliseconds: 600));

  expect(driver.store, isNotEmpty);
});
```

!!! tip
    The debounce on saves is 500ms by default. In a test, pump past that window,
    or set `debounce: Duration.zero` in your own widget's `updateSettings` call,
    so the save lands before you assert.

## Related

- [Extending Themes](../theming/extending-themes.md) for driving styling from the theme.
- [Custom Modules](custom-modules.md) for building larger persistent widgets.
- [Data Tables](../widgets/data-tables.md) for the widget that persists the most state.
