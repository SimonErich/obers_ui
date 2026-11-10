# Scrolling & Virtualization

These widgets keep long content fast and smooth. Some render only the items you
can see, so a list of ten thousand rows costs about the same as a list of ten.
Others add a scrollbar, load more data as you reach the end, or build collapsing
headers inside a `CustomScrollView`.

| Widget | What it does |
| --- | --- |
| `OiScrollbar` | Wraps a scrollable and shows a themed, platform-aware scrollbar. |
| `OiInfiniteScroll` | Calls a loader when the user nears the bottom. |
| `OiVirtualList` | A lazy list that only builds visible items. Pull to refresh on touch. |
| `OiVirtualGrid` | A lazy grid that only builds visible cells. |
| `OiSliverList` | A themed list sliver for a `CustomScrollView`. |
| `OiSliverGrid` | A themed grid sliver for a `CustomScrollView`. |
| `OiSliverHeader` | A sticky, collapsing header sliver for a `CustomScrollView`. |
| `OiAnimatedList` | A list that animates items as they are inserted or removed. |

## OiVirtualList

The list you reach for when the data is large. It builds items lazily, so only
the rows near the viewport exist at once. On touch devices, pass `onRefresh` to
get pull-to-refresh for free.

```dart
OiVirtualList(
  itemCount: items.length,
  itemBuilder: (context, index) => OiLabel.body(items[index]),
)
```

Add pull-to-refresh. The gesture is only active on touch devices (comfortable
density). On pointer devices the callback is ignored.

```dart
OiVirtualList(
  itemCount: items.length,
  itemBuilder: (context, index) => OiLabel.body(items[index]),
  onRefresh: () async => reload(),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `itemCount` | `int` | **required** | Number of items. |
| `itemBuilder` | `IndexedWidgetBuilder` | **required** | Builds the row at an index. |
| `onRefresh` | `Future<void> Function()?` | `null` | Pull-to-refresh handler on touch devices. |
| `controller` | `ScrollController?` | `null` | Drives and reads the scroll position. |
| `scrollDirection` | `Axis` | `vertical` | Scroll along `vertical` or `horizontal`. |
| `reverse` | `bool` | `false` | Start from the far end and grow backward. |
| `cacheExtent` | `double?` | `null` | Extra pixels to build beyond the viewport. |
| `padding` | `EdgeInsetsGeometry?` | `null` | Padding around the content. |
| `physics` | `ScrollPhysics?` | `null` | Custom scroll physics. |
| `primary` | `bool?` | `null` | Whether this is the parent's primary scroll view. |
| `shrinkWrap` | `bool` | `false` | Size to content instead of filling the space. |

!!! tip "When to use"
    Reach for `OiVirtualList` for 50 or more items. For a short, static list, an
    `OiColumn` with children is simpler and just as fast.

## OiScrollbar

Wraps any scrollable child and draws a scrollbar that matches the platform. On
pointer devices it shows a full thumb with a track. On touch devices it shows a
thin overlay bar that fades in while scrolling. Share one `ScrollController`
between the scrollbar and the scrollable inside it.

```dart
final _controller = ScrollController();

OiScrollbar(
  controller: _controller,
  child: OiVirtualList(
    controller: _controller,
    itemCount: items.length,
    itemBuilder: (context, index) => OiLabel.body(items[index]),
  ),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | **required** | The scrollable to wrap. |
| `controller` | `ScrollController?` | `null` | The same controller attached to the child. |
| `alwaysShow` | `bool?` | `null` | Keep the thumb visible. Defaults to `true` on pointer, `false` on touch. |
| `showTrack` | `bool?` | `null` | Show the background rail. Defaults to `true` on pointer, `false` on touch. |
| `thickness` | `double?` | `null` | Thumb width. Defaults to `8` on pointer, `3` on touch. |
| `radius` | `Radius?` | `null` | Corner radius of the thumb. |

!!! note
    The controller you pass must be the one attached to the scrollable inside
    `child`. Two different controllers give you a scrollbar that does not move.

## OiInfiniteScroll

Wraps a scrollable and calls `onLoadMore` when the user scrolls near the bottom.
It shows a spinner while your future runs, then removes it. Set `moreAvailable`
to `false` once there is nothing left to load.

```dart
OiInfiniteScroll(
  moreAvailable: hasMore,
  onLoadMore: fetchNextPage,
  child: OiVirtualList(
    itemCount: items.length,
    itemBuilder: (context, index) => OiLabel.body(items[index]),
  ),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `moreAvailable` | `bool` | **required** | Whether more items can load. `false` stops the trigger. |
| `onLoadMore` | `Future<void> Function()` | **required** | Loads the next page. A spinner shows while it runs. |
| `child` | `Widget` | **required** | The scrollable content. |
| `threshold` | `double` | `200` | Pixels from the bottom that trigger a load. |
| `loadingWidget` | `Widget?` | `null` | Custom loading widget. Defaults to a spinner. |

## OiVirtualGrid

A lazy grid for large datasets, laid out in a fixed number of columns. Like
`OiVirtualList`, it only builds the cells near the viewport.

```dart
OiVirtualGrid(
  itemCount: photos.length,
  crossAxisCount: 3,
  itemBuilder: (context, index) => OiCard(child: OiLabel.body(photos[index])),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `itemCount` | `int` | **required** | Number of cells. |
| `itemBuilder` | `IndexedWidgetBuilder` | **required** | Builds the cell at an index. |
| `crossAxisCount` | `int` | `2` | Number of columns. |
| `mainAxisSpacing` | `double` | `0` | Gap between rows. |
| `crossAxisSpacing` | `double` | `0` | Gap between columns. |
| `childAspectRatio` | `double` | `1` | Cell width divided by height. |
| `cacheExtent` | `double?` | `null` | Extra pixels to build beyond the viewport. |
| `controller` | `ScrollController?` | `null` | Drives and reads the scroll position. |
| `padding` | `EdgeInsetsGeometry?` | `null` | Padding around the content. |
| `shrinkWrap` | `bool` | `false` | Size to content instead of filling the space. |

## OiSliverList

A list built as a sliver, for use inside a `CustomScrollView` alongside other
slivers like `OiSliverHeader`. Turn on `separated` for a themed divider between
items, or pass `separatorBuilder` for your own.

```dart
CustomScrollView(
  slivers: [
    OiSliverHeader.simple(title: 'Messages'),
    OiSliverList(
      itemCount: items.length,
      itemBuilder: (context, index) => OiLabel.body(items[index]),
      separated: true,
      padding: EdgeInsets.all(context.spacing.md),
    ),
  ],
)
```

### Variants

Use `OiSliverList.children` for a short, static list you already have in memory.

```dart
OiSliverList.children(
  children: [
    OiLabel.body('First'),
    OiLabel.body('Second'),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `itemCount` | `int` | **required** | Number of items (builder constructor). |
| `itemBuilder` | `Widget Function(BuildContext, int)` | **required** | Builds the item at an index. |
| `separated` | `bool` | `false` | Insert a 1 px `borderSubtle` divider between items. |
| `separatorBuilder` | `Widget Function(BuildContext, int)?` | `null` | Custom separator. Implies `separated`. |
| `padding` | `EdgeInsetsGeometry?` | `null` | Padding around the sliver. |
| `semanticLabel` | `String?` | `null` | Accessibility label for the list. |

!!! note
    `OiSliverList` only works inside a `CustomScrollView` or another sliver host.
    For a standalone list, use `OiVirtualList`.

## OiSliverGrid

A grid built as a sliver, for use inside a `CustomScrollView`. Set a fixed
`crossAxisCount`, or use `OiSliverGrid.extent` to let the column count follow the
viewport width. Spacing defaults to the theme's `sm` value.

```dart
CustomScrollView(
  slivers: [
    OiSliverGrid(
      crossAxisCount: 3,
      itemCount: items.length,
      itemBuilder: (context, index) => OiCard(child: OiLabel.body(items[index])),
    ),
  ],
)
```

### Variants

Use `OiSliverGrid.extent` for responsive columns. The framework fits as many
columns as it can while keeping each item at least `minItemWidth` wide.

```dart
OiSliverGrid.extent(
  minItemWidth: 200,
  itemCount: items.length,
  itemBuilder: (context, index) => OiCard(child: OiLabel.body(items[index])),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `itemCount` | `int` | **required** | Number of cells. |
| `itemBuilder` | `Widget Function(BuildContext, int)` | **required** | Builds the cell at an index. |
| `crossAxisCount` | `int` | `2` | Number of columns (default constructor). |
| `minItemWidth` | `double` | **required** | Minimum item width (`.extent` constructor only). |
| `mainAxisSpacing` | `double?` | `null` | Gap between rows. Defaults to spacing `sm`. |
| `crossAxisSpacing` | `double?` | `null` | Gap between columns. Defaults to spacing `sm`. |
| `childAspectRatio` | `double` | `1.0` | Cell width divided by height. |
| `padding` | `EdgeInsetsGeometry?` | `null` | Padding around the sliver. |
| `semanticLabel` | `String?` | `null` | Accessibility label for the grid. |

## OiSliverHeader

A sticky header sliver for a `CustomScrollView`. It can pin to the top, collapse
as you scroll, and hold a background that fades out. Three named constructors
cover the common shapes.

```dart
CustomScrollView(
  slivers: [
    OiSliverHeader.simple(
      title: 'Messages',
      onBack: () => Navigator.of(context).pop(),
    ),
    OiSliverList(
      itemCount: items.length,
      itemBuilder: (context, index) => OiLabel.body(items[index]),
    ),
  ],
)
```

### Variants

```dart
// Pinned bar with a title, and a back chevron when onBack is set.
OiSliverHeader.simple(title: 'Inbox')

// Larger title area that collapses as you scroll down.
OiSliverHeader.large(title: 'Inbox', subtitle: '12 unread')

// Flexible-space background that fades out on collapse.
OiSliverHeader.hero(
  flexibleSpace: OiSurface(color: context.colors.primary.base),
  expandedHeight: 220,
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | `Widget?` | `null` | The title widget. |
| `subtitle` | `Widget?` | `null` | Optional line below the title. |
| `leading` | `Widget?` | `null` | Widget before the title, often a back button. |
| `trailing` | `Widget?` | `null` | Widget after the title. |
| `actions` | `List<Widget>` | `[]` | Action widgets after `trailing`. |
| `pinned` | `bool` | `true` | Keep the header at the top while scrolling. |
| `floating` | `bool` | `false` | Reveal the header as soon as the user scrolls up. |
| `snap` | `bool` | `false` | Snap fully open or closed. Needs `floating: true`. |
| `expandedHeight` | `double?` | `null` | Height when expanded. Defaults to `toolbarHeight`. |
| `collapsedHeight` | `double?` | `null` | Height when collapsed. Defaults to `toolbarHeight`. |
| `flexibleSpace` | `Widget?` | `null` | Background that fades as the header collapses. |
| `backgroundColor` | `Color?` | `null` | Header fill. Defaults to the surface color. |
| `foregroundColor` | `Color?` | `null` | Icon and text color. Defaults to the text color. |
| `elevation` | `double?` | `null` | Shadow shown once content scrolls under. |
| `border` | `Border?` | `null` | Bottom border shown once scrolled under. |
| `centerTitle` | `bool` | `false` | Center the title horizontally. |
| `titleSpacing` | `double` | `16` | Gap between the leading widget and the title. |
| `toolbarHeight` | `double` | `56` | Height of the collapsed toolbar. |
| `semanticLabel` | `String?` | `null` | Accessibility label for the header. |

The `.simple`, `.large`, and `.hero` constructors take a `String title` (a
`Widget` for `.hero`), an optional `onBack` callback that adds a back chevron,
`actions`, and `semanticLabel`.

## OiAnimatedList

A list that animates each item as it enters or leaves. You drive changes through
an `OiAnimatedListController`, which inserts and removes items and runs the
matching animation. Inserts use a `SizeTransition` by default, removals use a
`FadeTransition`.

```dart
final controller = OiAnimatedListController<String>();

OiAnimatedList<String>(
  items: const ['Apple', 'Banana'],
  controller: controller,
  itemBuilder: (context, item, animation, index) => SizeTransition(
    sizeFactor: animation,
    child: OiLabel.body(item),
  ),
)

// Later, drive changes through the controller.
controller.insert(0, 'Cherry');
controller.remove(1);
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `List<T>` | **required** | The initial items. |
| `itemBuilder` | `Widget Function(BuildContext, T, Animation<double>, int)` | **required** | Builds an item with its insert animation and index. |
| `controller` | `OiAnimatedListController<T>?` | `null` | Inserts and removes items programmatically. |
| `removeBuilder` | `Widget Function(BuildContext, T, Animation<double>)?` | `null` | Builds a leaving item. Defaults to a fade out. |
| `scrollDirection` | `Axis` | `vertical` | Scroll along `vertical` or `horizontal`. |
| `shrinkWrap` | `bool` | `false` | Size to content instead of filling the space. |
| `padding` | `EdgeInsetsGeometry?` | `null` | Padding around the content. |

Controller methods: `insert(index, item)`, `remove(index)`, and
`insertAll(items)`. The controller binds during `initState`, so do not call it
before the list is in the tree.

!!! tip "When to use"
    Use `OiAnimatedList` when items appear or disappear one at a time and the
    motion matters, like a todo list or a chat. For large, static data, use
    `OiVirtualList` instead. It renders lazily; `OiAnimatedList` does not.

## Related

- [Data & Tables](data-tables.md) for `OiTable` and higher-level list modules.
- [Animation](animation.md) for other motion primitives.
- [Feedback & Status](feedback.md) for spinners and progress indicators.
