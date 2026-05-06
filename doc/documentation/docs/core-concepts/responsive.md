# Responsive Design

ObersUI is responsive by default. Layouts, spacing, and component behavior adapt across screen sizes — from compact phones to ultra-wide desktops.

## Breakpoints

The library defines five breakpoints in [oi_responsive.dart](lib/src/foundation/oi_responsive.dart):

| Breakpoint | Width (dp) | Typical device |
| --- | --- | --- |
| `OiBreakpoint.compact` | 0 – 599 | Phones |
| `OiBreakpoint.medium` | 600 – 839 | Small tablets, landscape phones |
| `OiBreakpoint.expanded` | 840 – 1199 | Tablets, small desktops |
| `OiBreakpoint.large` | 1200 – 1599 | Desktops |
| `OiBreakpoint.extraLarge` | 1600+ | Wide monitors |

The standard thresholds are defined in `OiBreakpointScale.standard()` (aliased as `OiBreakpointScale.defaultScale`). You can supply a custom scale on any layout primitive via the `scale:` parameter.

## Responsive values

Any property can vary by breakpoint using `OiResponsive<T>`. The class has two constructors:

```dart
// Static value across all breakpoints.
const OiResponsive(3);

// Per-breakpoint map. Missing breakpoints cascade upward from smaller ones.
OiResponsive.breakpoints({
  OiBreakpoint.compact: 1,
  OiBreakpoint.medium: 2,
  OiBreakpoint.expanded: 3,
  OiBreakpoint.large: 4,
});
```

A Map literal has a `.responsive` extension for concise inline use:

```dart
{
  OiBreakpoint.compact: 1,
  OiBreakpoint.expanded: 3,
}.responsive
```

Values cascade upward. If you only define `compact` and `expanded`, `medium` inherits from `compact`, and `large` / `extraLarge` inherit from `expanded`. Mobile-first.

### In a grid

Layout primitives all require an explicit `breakpoint:` — that's the library's zero-magic rule. Resolve it once at the page level with `context.breakpoint` and pass it down:

```dart
OiGrid(
  breakpoint: context.breakpoint,
  columns: OiResponsive.breakpoints({
    OiBreakpoint.compact: 1,
    OiBreakpoint.medium: 2,
    OiBreakpoint.expanded: 3,
    OiBreakpoint.large: 4,
  }),
  children: cards,
)
```

## Showing different content per breakpoint

There's no dedicated show/hide widget. Branch on the resolved breakpoint:

```dart
if (context.atLeast(OiBreakpoint.expanded)) {
  // desktop layout
}
```

Convenience getters are also available on `BuildContext`: `isCompact`, `isMedium`, `isExpanded`, `isLarge`, `isExtraLarge`, `isMediumOrWider`, `isExpandedOrWider`, `isLargeOrWider`.

Or select a widget with an `OiResponsive` and `.resolve()`:

```dart
final layout = OiResponsive.breakpoints({
  OiBreakpoint.compact: const _MobileHeader(),
  OiBreakpoint.expanded: const _DesktopHeader(),
}).resolve(context.breakpoint, OiBreakpointScale.defaultScale);
```

## Navigation adaptation

ObersUI ships navigation primitives that you can switch between by breakpoint. The library does not pick one for you — the choice is a layout decision in your shell.

| Widget | Typical use |
| --- | --- |
| [OiBottomBar](lib/src/components/navigation/oi_bottom_bar.dart) | Compact: primary destinations at the bottom |
| [OiDrawer](lib/src/components/navigation/oi_drawer.dart) | Compact: full-height navigation panel |
| [OiNavigationRail](lib/src/components/navigation/oi_navigation_rail.dart) | Medium: compact vertical rail (default width 72dp) |
| [OiSidebar](lib/src/composites/navigation/oi_sidebar.dart) | Expanded+: full-width labeled sidebar |
| [OiResponsiveShell](lib/src/composites/navigation/oi_responsive_shell.dart) | A composite that switches between the above per breakpoint |

## Page gutters

`OiBreakpointScale` carries per-breakpoint page-gutter and content-max-width tokens. The standard scale uses:

| Breakpoint | Page gutter | Content max-width |
| --- | --- | --- |
| compact | 16dp | unbounded |
| medium | 24dp | 720dp |
| expanded | 32dp | 960dp |
| large | 40dp | 1200dp |
| extraLarge | 48dp | 1400dp |

Resolve them for the active breakpoint:

```dart
final scale = OiTheme.of(context).breakpoints;
final gutter = scale.resolvePageGutter(context.breakpoint);
final maxWidth = scale.resolveContentMaxWidth(context.breakpoint);
```

`OiPage` does not apply gutters automatically — use [OiContainer](lib/src/primitives/layout/oi_container.dart) for a centered max-width shell, or pass the resolved gutter into `padding:` explicitly.

## Custom breakpoints

Supply a custom `OiBreakpointScale` when you want non-standard thresholds. Pass a list of `OiBreakpoint` plus optional `pageGutters` and `contentMaxWidths` maps keyed by breakpoint name:

```dart
final mobileFirst = OiBreakpointScale(
  const [
    OiBreakpoint.compact,
    OiBreakpoint('tablet', 480),
    OiBreakpoint('desktop', 1024),
  ],
  pageGutters: const {'compact': 12, 'tablet': 20, 'desktop': 32},
);

final bp = mobileFirst.resolve(MediaQuery.sizeOf(context).width);

OiGrid(
  breakpoint: bp,
  scale: mobileFirst,
  columns: const OiResponsive(3),
  children: cards,
)
```

Pass the same `scale:` to every layout primitive that should honour the custom thresholds, and wire the scale into your theme via `OiThemeData(breakpoints: mobileFirst)` so `context.breakpoint` picks it up.

For a lightly extended scale that keeps the standard 5 tiers and adds two more, use `OiBreakpointScale.extended()`.
