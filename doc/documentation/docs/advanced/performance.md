# Performance

ObersUI is designed to run smoothly on everything from budget phones to powerful desktops. For demanding scenarios, you have explicit control over performance trade-offs.

## Performance config

`OiPerformanceConfig` controls which visual effects are active:

```dart
OiApp(
  performanceConfig: OiPerformanceConfig.reduced(),
  theme: OiThemeData.light(),
  home: const MyHomePage(),
)
```

| Preset | Blur | Shadows | Animations | Use case |
| --- | --- | --- | --- | --- |
| `OiPerformanceConfig.high()` | Full | Full | Full | Default — desktops, modern phones |
| `OiPerformanceConfig.reduced()` | Disabled | Reduced | Shorter | Older devices, budget phones |
| `OiPerformanceConfig.minimal()` | Disabled | Disabled | Minimal | Very constrained devices |

You can also configure it per-field:

```dart
OiPerformanceConfig(
  enableBlur: false,       // Disable glassmorphism effects
  enableShadows: true,     // Keep shadows
  enableAnimations: true,  // Keep animations
)
```

## Virtual scrolling

For large lists and grids, use virtualized widgets:

```dart
// Only renders visible items — handles 100k+ rows
OiVirtualList(
  itemCount: 100000,
  itemBuilder: (context, index) => UserRow(users[index]),
  itemExtent: 48,
)
```

The `OiTable` composite uses virtual scrolling internally — no extra configuration needed.

## Lazy loading

For infinite data:

```dart
OiInfiniteScroll(
  onLoadMore: () async {
    final nextPage = await api.fetchPage(page++);
    setState(() => items.addAll(nextPage));
  },
  child: OiColumn(
    children: items.map((item) => ItemTile(item)).toList(),
  ),
)
```

## Image optimization

`OiImage` handles caching and error states:

```dart
OiImage(
  src: imageUrl,
  width: 200,
  height: 200,
  fit: BoxFit.cover,
  // Automatically shows placeholder on load, error state on failure
)
```

## Best practices

1. **Use `OiVirtualList` / `OiVirtualGrid`** for lists over ~100 items
2. **Use `OiPerformanceConfig.reduced()`** if targeting older devices
3. **Avoid rebuilding the entire widget tree** — keep state as local as possible
4. **Use `const` constructors** where possible — ObersUI's widgets support them
5. **Profile with Flutter DevTools** — the `Timeline` view helps identify jank
