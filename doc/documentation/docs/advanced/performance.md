# Performance

ObersUI is designed to run smoothly on everything from budget phones to powerful desktops. For demanding scenarios, you have explicit control over performance trade-offs.

## Performance config

[OiPerformanceConfig](lib/src/foundation/theme/oi_animation_config.dart) toggles the expensive visual effects in the design system. Four presets ship:

| Preset | Blur | Shadows | Halo | Animations |
| --- | --- | --- | --- | --- |
| `OiPerformanceConfig.high()` | on | on | on | full (scale 1.0) |
| `OiPerformanceConfig.mid()` | off | on | on | full (scale 1.0) |
| `OiPerformanceConfig.low()` | off | off | off | halved (scale 0.5) |
| `OiPerformanceConfig.auto()` | chooses `mid` on web, `high` elsewhere |||| |

You can pass a preset directly on `OiApp` to override whatever the theme supplies:

```dart
OiApp(
  performanceConfig: OiPerformanceConfig.auto(),
  theme: OiThemeData.light(),
  home: const MyHomePage(),
)
```

Or tune each lever individually with the default constructor:

```dart
const OiPerformanceConfig(
  disableBlur: true,
  disableShadows: false,
  reduceAnimations: false,
  disableHalo: false,
  animationScale: 1.0,
)
```

All five fields are required on the default constructor. Flags use "disable" semantics — `disableBlur: true` turns blur effects off.

## Virtual scrolling

For large lists, use the virtualized primitives:

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

For infinite data, pair `OiInfiniteScroll` with your scroll container:

```dart
OiInfiniteScroll(
  onLoadMore: () async {
    final nextPage = await api.fetchPage(page++);
    setState(() => items.addAll(nextPage));
  },
  child: ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, i) => ItemTile(items[i]),
  ),
)
```

## Image optimization

[OiImage](lib/src/primitives/display/oi_image.dart) handles network / asset loading, a placeholder slot, and error state:

```dart
OiImage(
  src: imageUrl,
  alt: 'Product photo',
  width: 200,
  height: 200,
  fit: BoxFit.cover,
  placeholder: const OiShimmer(),
  errorWidget: const Icon(OiIcons.imageOff),
)
```

## Best practices

1. Reach for `OiVirtualList` / `OiVirtualGrid` once a list exceeds a few hundred items.
2. Set `OiPerformanceConfig.low()` on low-end targets, or call `OiPerformanceConfig.auto()` and let it pick per-platform.
3. Keep rebuild scope small — hoist state no higher than it needs to be.
4. Use `const` constructors wherever possible; every ObersUI widget supports them.
5. Profile with Flutter DevTools — the Timeline view surfaces jank the fastest.
