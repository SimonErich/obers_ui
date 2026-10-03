# State, Undo & Persistence

ObersUI ships a few helpers for the state that lives around your widgets. You can
save user preferences to disk, undo the last change, apply a change before the
server confirms it, and bind keyboard shortcuts to a part of the tree. Each one
is opt-in. You reach for it when you need it.

| Helper | What it does |
| --- | --- |
| `settingsDriver` on `OiApp` | Saves and restores column widths, sort, filters, and layout. |
| `OiUndoStack` | A history stack with global Ctrl+Z undo. |
| `OiOptimisticAction` | Applies a change now, shows an undo snackbar, then commits or rolls back. |
| `OiShortcutScope` | The global shortcuts wired into `OiApp` (undo, command bar, help). |
| `OiShortcuts` | Custom keyboard shortcuts scoped to a subtree. |

## Persistence

Many ObersUI widgets can remember what the user set. Column widths, sort order,
active filters, view mode, collapsed panels, and layout all survive a restart
once you give the app a place to store them.

You do this in one step. Pass a `settingsDriver` to `OiApp`.

```dart
OiApp(
  settingsDriver: const OiLocalStorageDriver(),
  theme: OiThemeData.light(),
  home: const MyHomePage(),
)
```

That is all the setup built-in widgets need. `OiApp` puts the driver in the tree,
and any widget that supports persistence reads it and saves its own state with a
short debounce.

### Drivers

Two drivers ship with the library. Pick one by where you want the data to live.

| Driver | Storage | Use case |
| --- | --- | --- |
| `OiLocalStorageDriver` | `SharedPreferences` on mobile and desktop, `localStorage` on web | Real apps |
| `OiInMemorySettingsDriver` | RAM only, lost on restart | Tests and prototypes |

```dart
// Production: persists to the platform's local storage.
const OiLocalStorageDriver()

// Tests: keeps everything in a Map you can inspect.
OiInMemorySettingsDriver()
```

`OiLocalStorageDriver` takes an optional `prefix` (default `'obers_ui'`) that it
prepends to every key. `OiInMemorySettingsDriver` exposes its `store` map and a
`clear()` method, which is handy in a test `tearDown`.

!!! note
    The in-memory driver is named `OiInMemorySettingsDriver`, not
    `OiInMemoryDriver`. Use the full name.

### What gets persisted

You do not configure this per field. Each widget knows what parts of its state
are worth saving.

| Widget | Persisted state |
| --- | --- |
| `OiTable` | Column order, widths, visibility, sort, filters, page size, groups |
| `OiFileManager` | View mode, sort, sidebar state, favorites, recent paths |
| `OiKanban` | Column order, collapsed columns, WIP limits |
| `OiListView` | Layout mode, sort, filters, page size |
| `OiSidebar` | Mode, width, collapsed sections, selected item |
| `OiAppShell` | Sidebar state, drawer state, responsive mode overrides |
| `OiDashboard` | Card positions and sizes |
| `OiCalendar` | View type, date range, collapsed categories |
| `OiGantt` | Zoom level, scroll position, collapsed groups |
| `OiTabs` | Tab order, selected index |
| `OiFilterBar` | Active filters, filter order |

### Separate storage per instance

Two tables on two screens should not share one saved layout. Give each a
`settingsKey`. The key becomes part of the storage path, so each instance keeps
its own record.

```dart
OiTable(settingsKey: 'users-table', columns: userColumns, rows: users)
OiTable(settingsKey: 'orders-table', columns: orderColumns, rows: orders)
```

### Custom driver

Want settings in your own backend instead of local storage? Extend
`OiSettingsDriver` and override its four methods. Use the `resolveKey` helper to
build the storage key from the namespace and optional key.

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
    return json == null ? null : deserialize(json);
  }

  @override
  Future<void> save<T extends OiSettingsData>({
    required String namespace,
    required T data,
    required Map<String, dynamic> Function(T data) serialize,
    String? key,
  }) => api.putSettings(resolveKey(namespace, key), serialize(data));

  @override
  Future<void> delete({required String namespace, String? key}) =>
      api.deleteSettings(resolveKey(namespace, key));

  @override
  Future<bool> exists({required String namespace, String? key}) =>
      api.hasSettings(resolveKey(namespace, key));
}
```

`resolveKey` returns `"$namespace"` with no key, or `"$namespace::$key"` with
one. Override it if your backend needs a different shape, such as a REST path.

| Method | Purpose |
| --- | --- |
| `load` | Read saved settings, or `null` if none exist. Never throws. |
| `save` | Write settings for a namespace and optional key. |
| `delete` | Remove settings. After this, `load` returns `null`. |
| `exists` | Return `true` if settings are stored for the key. |

### Persisting a custom widget

To add persistence to your own widget, mix `OiSettingsMixin<W, T>` into its
`State`. The mixin loads on init, saves with a debounce, and falls back to
defaults when nothing is stored. You supply a settings data class that uses the
`OiSettingsData` mixin.

The data class needs a `schemaVersion`, a `toJson()` that includes that version,
and a `fromJson` factory.

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
```

In the `State`, implement the mixin members and call `updateSettings` to change
and save the value.

```dart
class _CounterState extends State<Counter>
    with OiSettingsMixin<Counter, CounterSettings> {
  @override
  String get settingsNamespace => 'counter';
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
  CounterSettings mergeSettings(CounterSettings saved, CounterSettings defaults) =>
      saved;

  @override
  Widget build(BuildContext context) {
    if (!settingsLoaded) return const SizedBox.shrink();
    return OiButton.primary(
      label: 'Count: ${currentSettings.count}',
      onTap: () => updateSettings(
        currentSettings.copyWith(count: currentSettings.count + 1),
      ),
    );
  }
}
```

| Member | Type | Purpose |
| --- | --- | --- |
| `settingsNamespace` | `String` | The main storage key, usually a widget type name. |
| `settingsKey` | `String?` | Optional sub-key for per-instance storage. |
| `settingsDriver` | `OiSettingsDriver?` | The driver. Return `null` to turn persistence off. |
| `defaultSettings` | `T` | The value used when nothing is saved. |
| `deserializeSettings` | `T Function(Map)` | Turns JSON back into your settings type. |
| `mergeSettings` | `T Function(T, T)` | Reconciles a loaded value with current defaults. |

The mixin exposes `currentSettings`, `settingsLoaded`, and `settingsLoadError`.
Call `updateSettings(value)` to change and save, `saveSettingsNow()` to flush
before navigating away, and `resetSettings()` to clear. Saves debounce by 500ms
by default. Pass `debounce: Duration.zero` for an immediate save.

## Undo and redo

`OiUndoStack` is a history of undoable actions. Push an action after the user
does something reversible. The stack runs the forward operation and keeps the
reverse one ready. `OiApp` creates one stack for the whole app and wires Ctrl+Z
(Cmd+Z on macOS) to undo it.

Get the stack with `OiUndoStack.of(context)` and push an `OiUndoAction`.

```dart
final undo = OiUndoStack.of(context);

undo.push(
  OiUndoAction(
    label: 'Rename column',
    execute: () => setState(() => column.title = newTitle),
    undo: () => setState(() => column.title = oldTitle),
  ),
);
```

`execute` runs right away when you push. `undo` reverses it. If the user presses
Ctrl+Z, the stack calls `undo` and moves the action to the redo list. Calling
`redo()` runs `execute` again.

!!! note
    Only Ctrl+Z is bound globally. Redo is available on the stack through
    `redo()`, but no global key triggers it. Bind your own key with `OiShortcuts`
    if you want Ctrl+Shift+Z.

You can size the history on `OiApp`. When the stack passes the limit, it drops
the oldest entry.

```dart
OiApp(
  undoStackMaxHistory: 100, // default is 50
  home: const MyHomePage(),
)
```

### OiUndoAction

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | A short name for the action, such as `'Delete row'`. |
| `execute` | `VoidCallback` | **required** | Runs the action. Called on push and on redo. |
| `undo` | `VoidCallback` | **required** | Reverses the action. |
| `merge` | `OiUndoAction? Function(OiUndoAction)?` | `null` | Coalesces this action with the next one. Return `null` to skip merging. |
| `groupId` | `String?` | `null` | Actions with the same non-null id are eligible to merge. |

Use `merge` and `groupId` to fold a burst of edits into one undo step, such as
each keystroke while typing. Without them, every push is its own step.

### OiUndoStack methods

| Member | Description |
| --- | --- |
| `push(action)` | Runs the action and adds it to history. Clears the redo list. |
| `undo()` | Reverses the last action and moves it to the redo list. |
| `redo()` | Re-runs the last undone action. |
| `clear()` | Empties both history and redo. |
| `canUndo` / `canRedo` | Whether an undo or redo is available. |
| `nextUndoLabel` / `nextRedoLabel` | The label of the next step, or `null`. |

`OiUndoStack` is a `ChangeNotifier`, so you can listen to it to enable or disable
your own undo and redo buttons.

## Optimistic updates

`OiOptimisticAction` handles the pattern behind delete, archive, and move. It
applies the change on screen at once, shows a snackbar with an Undo button, and
commits the real work only after the undo window closes. If the user taps Undo,
it rolls back. If the commit throws, it rolls back and shows an error toast.

```dart
await OiOptimisticAction.execute(
  context,
  apply: () => setState(() => items.remove(item)),
  onRollback: () => setState(() => items.insert(index, item)),
  commit: () => api.deleteItem(item.id),
  message: 'Item deleted',
);
```

The call returns `true` if the commit succeeded, and `false` if the user undid it
or the commit failed.

!!! warning
    The parameter is `onRollback`, not `rollback`. It runs both on Undo and on a
    failed commit, so it must fully restore the prior state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `BuildContext` | **required** | Used to show the snackbar and toast. |
| `apply` | `VoidCallback` | **required** | Applies the change immediately. |
| `onRollback` | `VoidCallback` | **required** | Restores the prior state on undo or failure. |
| `commit` | `Future<void> Function()` | **required** | The real async operation. |
| `message` | `String` | **required** | The snackbar text. |
| `undoDuration` | `Duration` | `5s` | How long the undo window stays open. |
| `undoLabel` | `String` | `'Undo'` | The snackbar action label. |
| `errorMessage` | `String?` | `null` | Toast text when the commit fails. Falls back to `'Action failed'`. |
| `errorLevel` | `OiToastLevel` | `error` | The level of the error toast. |
| `position` | `OiSnackBarPosition` | `bottom` | Where the snackbar appears. |

Only one optimistic action is pending at a time. Starting a new one commits the
previous one right away. Call `OiOptimisticAction.cancelPending(context)` to drop
and roll back a pending action, for example when the user leaves the screen.

!!! tip "When to reach for something else"
    Use this for reversible async changes. For an action that needs a yes or no
    first, use `OiDialog.confirm`. Do not use it for anything you cannot undo.

## Keyboard shortcuts

### OiShortcutScope

`OiShortcutScope` holds the global shortcuts that `OiApp` sets up for you. It
binds Ctrl+Z to undo, Ctrl+K to the command bar, and `?` to the help overlay. You
do not place it yourself. It is already in the tree under `OiApp`.

Read its state when you build a command bar or help panel.

```dart
final scope = OiShortcutScope.of(context);
scope.commandBarActive.addListener(() {
  // React when Ctrl+K opens the command bar.
});
```

`OiShortcutScope.of(context)` returns the state, and `maybeOf(context)` returns
`null` when no scope is present. The state exposes `commandBarActive`, a
`ValueNotifier<bool>` that is `true` while the command bar is open.

### OiShortcuts

To register your own shortcuts for one part of the screen, wrap that subtree in
`OiShortcuts`. You pass a list of bindings. Each binding pairs a key activator
with a label and a callback. When `showHelpOnQuestionMark` is on, pressing `?`
lists them in a help overlay.

```dart
OiShortcuts(
  shortcuts: [
    OiShortcutBinding(
      activator: const SingleActivator(LogicalKeyboardKey.keyN, control: true),
      label: 'New item',
      onInvoke: createItem,
    ),
    OiShortcutBinding(
      activator: const SingleActivator(LogicalKeyboardKey.keyF, control: true),
      label: 'Find',
      description: 'Focus the search field',
      category: 'Navigation',
      onInvoke: focusSearch,
    ),
  ],
  child: const EditorView(),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | **required** | The subtree the shortcuts apply to. |
| `shortcuts` | `List<OiShortcutBinding>` | **required** | The key bindings. |
| `showHelpOnQuestionMark` | `bool` | `true` | Open a help overlay when the user presses `?`. |

Each `OiShortcutBinding` takes an `activator`, a `label`, and an `onInvoke`
callback. Add an optional `description` and `category` to group and explain the
shortcut in the help overlay.

## Related

- [Component Tiers](component-tiers.md) for where these helpers sit in the stack.
- [Navigation and Routing](navigation-and-routing.md) for `OiApp` setup and routing.
- [Accessibility](accessibility.md) for keyboard and screen-reader guidance.
