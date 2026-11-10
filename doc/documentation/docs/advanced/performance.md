# Performance

ObersUI aims to stay smooth on budget phones and busy desktops alike. Most of
the work is done for you. This page covers the few levers you reach for when a
screen gets heavy: virtualizing long lists, tuning expensive visual effects, and
keeping rebuilds cheap.

| Tool | What it does |
| --- | --- |
| `OiVirtualList` | Renders only the visible rows of a long list. |
| `OiVirtualGrid` | Renders only the visible cells of a large grid. |
| `OiInfiniteScroll` | Loads the next page as the user nears the bottom. |
| `OiPerformanceConfig` | Turns off blur, shadows, halo, and heavy motion per tier. |
| `OiScrollBehavior` | Strips the Android overscroll glow. Applied by `OiApp` already. |

## Virtualize long lists

A plain `OiColumn` builds every child up front. That is fine for a handful of
rows. Once a list runs past a few hundred items, build them lazily instead. Use
`OiVirtualList`. It wraps `ListView.builder`, so it only builds items near the
viewport.

```dart
OiVirtualList(
  itemCount: users.length,
  itemBuilder: (context, index) => OiLabel.body(users[index].name),
)
```

The `itemBuilder` runs on demand as the user scrolls. It handles very large
counts without building everything at once.

On touch devices you can add pull to refresh. Pass `onRefresh`. It only turns on
when the active density is `comfortable`, which is the touch default.

```dart
OiVirtualList(
  itemCount: users.length,
  itemBuilder: (context, index) => OiLabel.body(users[index].name),
  onRefresh: () async => reloadUsers(),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `itemCount` | `int` | **required** | Number of items in the list. |
| `itemBuilder` | `IndexedWidgetBuilder` | **required** | Builds the item at `index`. |
| `cacheExtent` | `double?` | `null` | Pixels to build beyond the viewport. |
| `onRefresh` | `Future<void> Function()?` | `null` | Pull to refresh, touch devices only. |
| `controller` | `ScrollController?` | `null` | Optional scroll controller. |
| `scrollDirection` | `Axis` | `vertical` | Scroll axis. |
| `reverse` | `bool` | `false` | Reverse the scroll direction. |
| `padding` | `EdgeInsetsGeometry?` | `null` | Padding around the content. |
| `physics` | `ScrollPhysics?` | `null` | Custom scroll physics. |
| `shrinkWrap` | `bool` | `false` | Size to content instead of filling the viewport. |

!!! note
    `OiVirtualList` does not take an `itemExtent`. If your rows all share one
    fixed height and you need every last frame, a raw `ListView.builder` with
    `itemExtent` set can skip some layout work. Reach for that only when
    profiling shows you need it.

## Virtualize large grids

`OiVirtualGrid` is the grid version. It wraps `GridView.builder` with a fixed
column count and builds only the cells near the viewport. Good for photo walls
and card decks.

```dart
OiVirtualGrid(
  itemCount: photos.length,
  crossAxisCount: 3,
  mainAxisSpacing: 8,
  crossAxisSpacing: 8,
  itemBuilder: (context, index) => OiImage(src: photos[index].url),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `itemCount` | `int` | **required** | Number of items in the grid. |
| `itemBuilder` | `IndexedWidgetBuilder` | **required** | Builds the cell at `index`. |
| `crossAxisCount` | `int` | `2` | Number of columns. |
| `mainAxisSpacing` | `double` | `0` | Gap between rows. |
| `crossAxisSpacing` | `double` | `0` | Gap between columns. |
| `childAspectRatio` | `double` | `1` | Cell width divided by height. |
| `cacheExtent` | `double?` | `null` | Pixels to build beyond the viewport. |
| `controller` | `ScrollController?` | `null` | Optional scroll controller. |
| `padding` | `EdgeInsetsGeometry?` | `null` | Padding around the content. |
| `shrinkWrap` | `bool` | `false` | Size to content instead of filling the viewport. |

!!! tip
    `OiTable` already virtualizes its rows. You do not wrap a table in
    `OiVirtualList`. See [Data Tables](../widgets/data-tables.md).

## Load pages as you scroll

For endless feeds, pair `OiInfiniteScroll` with a scrollable child. It watches
the scroll position. When the user comes within `threshold` pixels of the bottom
and `moreAvailable` is true, it calls `onLoadMore` and shows a spinner until the
future finishes.

```dart
OiInfiniteScroll(
  moreAvailable: hasMore,
  onLoadMore: () async {
    final next = await api.fetchPage(page++);
    setState(() => items.addAll(next));
  },
  child: OiVirtualList(
    itemCount: items.length,
    itemBuilder: (context, index) => OiLabel.body(items[index].title),
  ),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `moreAvailable` | `bool` | **required** | Set `false` to stop further loads. |
| `onLoadMore` | `Future<void> Function()` | **required** | Fetches the next page. Awaited. |
| `child` | `Widget` | **required** | The scrollable content. |
| `loadingWidget` | `Widget?` | `null` | Shown while loading. Defaults to a spinner. |
| `threshold` | `double` | `200` | Distance from the bottom, in pixels, that triggers a load. |

## Tune visual effects

`OiPerformanceConfig` turns the expensive visual effects on or off as a group.
Blur, shadows, and the focus halo cost the most on weak GPUs and in browsers.
Four presets cover the common cases.

| Preset | Blur | Shadows | Halo | Motion |
| --- | --- | --- | --- | --- |
| `OiPerformanceConfig.high()` | on | on | on | full (scale 1.0) |
| `OiPerformanceConfig.mid()` | off | on | on | full (scale 1.0) |
| `OiPerformanceConfig.low()` | off | off | off | reduced (scale 0.5) |
| `OiPerformanceConfig.auto()` | picks `mid` on web, `high` elsewhere | | | |

Pass a preset to `OiApp`. It overrides whatever the theme carries and applies to
both the light and dark themes.

```dart
OiApp(
  performanceConfig: OiPerformanceConfig.auto(),
  theme: OiThemeData.light(),
  darkTheme: OiThemeData.dark(),
  home: const HomeScreen(),
)
```

To tune each lever by hand, use the default constructor. All five fields are
required. The flags read as "disable", so `disableBlur: true` turns blur off.

```dart
const OiPerformanceConfig(
  disableBlur: true,
  disableShadows: false,
  reduceAnimations: false,
  disableHalo: false,
  animationScale: 1.0,
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `disableBlur` | `bool` | **required** | Skip `BackdropFilter` blur. Cheapest win on web. |
| `disableShadows` | `bool` | **required** | Skip `BoxShadow` effects. |
| `reduceAnimations` | `bool` | **required** | Halve animation durations. |
| `disableHalo` | `bool` | **required** | Suppress the glow around focused elements. |
| `animationScale` | `double` | **required** | Multiplier on animation durations. `1.0` is full speed. |

!!! note
    This is a visual tradeoff, not free speed. `low()` drops shadows and blur,
    so the UI looks flatter. Use `auto()` as a safe default and step down to
    `low()` only on targets that need it.

## Keep const constructors

A `const` widget does not rebuild when its parent rebuilds. Flutter reuses the
same element. Mark widgets `const` wherever the values are known at compile time.

```dart
// Rebuilt every time the parent does.
OiLabel.caption('Version 1.0')

// Built once, then reused.
const _Footer()
```

Prefer small `const` leaf widgets over one large `build` method. That keeps each
rebuild scope tight. Hoist state no higher in the tree than it needs to be, so a
change only rebuilds the subtree that depends on it.

## Overscroll glow is already handled

`OiApp` wraps the tree in `OiScrollBehavior` through a `ScrollConfiguration`. It
removes Material's Android overscroll glow and picks platform physics: bouncing
on iOS and macOS, clamping elsewhere. Every scrollable under `OiApp` inherits
this. You do not set it yourself.

```dart
// Nothing to do. This is what OiApp applies for you.
const OiScrollBehavior()
```

## Profile before you optimize

Guessing at performance wastes time. Measure first with Flutter DevTools.

- Run in profile mode: `flutter run --profile`. Debug mode is much slower and
  hides the real numbers.
- Open the Performance view and record while you reproduce the jank. Long frames
  show up as tall bars over the 16ms line.
- Use the CPU profiler to find the method eating the frame.
- Turn on "Track widget builds" to catch widgets that rebuild more than they
  should. Those are your `const` and state-hoisting candidates.

Fix the widest bar first. Then measure again. Small, verified changes beat broad
guesses.

## Related

- [Scrolling](../widgets/scroll.md) for the full scroll widget reference.
- [Data Tables](../widgets/data-tables.md) for tables, which virtualize rows for you.
- [Extending Themes](../theming/extending-themes.md) for setting `performanceConfig` on a theme.
