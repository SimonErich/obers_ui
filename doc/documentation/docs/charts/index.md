# Charts Overview

Charts live in their own package, `obers_ui_charts`. They build on the same
theme, colors, and spacing as the rest of ObersUI, so a chart drops into an
`OiApp` and matches everything around it. This page covers the shared parts
every chart uses: axes, legends, series toggles, interaction behaviors, the
surface you wrap a chart in, and theming. The individual chart types live on the
four family pages linked at the bottom.

Charts are a separate dependency, so add `obers_ui_charts` to your `pubspec.yaml`
and import it directly:

```dart
import 'package:obers_ui_charts/obers_ui_charts.dart';
```

| Building block | What it does |
| --- | --- |
| `OiChartAxis` | Configures one axis: scale, range, ticks, grid, and value formatting. |
| `OiChartLegend` | Shows series names with color markers and tap-to-toggle. |
| `OiChartSeriesToggle` | A legend plus show-all / hide-all controls that manages visibility state. |
| Behaviors | Attachable interactions: zoom and pan, hover sync, selection, series toggle, keyboard explore. |
| `OiChartSurface` | A themed container to sit a chart inside, with card, soft, and frosted looks. |
| `OiChartGrid` | Internal painting helper shared by the Cartesian charts. |
| `OiAnalyticsDashboard` | A multi-panel dashboard that lays out and syncs several charts. |

## Your first chart

Every chart takes a `label` for accessibility and a list of series. The simplest
chart is `OiLineChart`. Its series is `OiLineSeries`, and each point is an
`OiLinePoint` with an `x` and a `y`. Give the chart a height and you are done.

```dart
SizedBox(
  height: 240,
  child: OiLineChart(
    label: 'Monthly revenue',
    series: [
      OiLineSeries(
        label: 'Revenue',
        points: [
          OiLinePoint(x: 1, y: 4200),
          OiLinePoint(x: 2, y: 5100),
          OiLinePoint(x: 3, y: 4800),
          OiLinePoint(x: 4, y: 6300),
        ],
      ),
    ],
  ),
)
```

`OiLineChart` also has `.straight`, `.stepped`, and `.smooth` named
constructors, and a `fromData` helper that maps your own model to points. See
the [Cartesian charts](cartesian.md) page for the full set.

!!! note
    The `label` is not drawn on the chart. Screen readers announce it, so every
    chart needs one. Pass a short description of what the chart shows.

## Series and data models

Each chart family has its own point and series types, so you never hand-build a
generic container. A line uses `OiLineSeries` and `OiLinePoint`. A bar uses
`OiBarSeries`, a pie uses `OiPieSlice`, and so on. The pattern is the same
everywhere: a series carries a `label` and a `color` override, and holds a list
of typed points. Reach for the concrete type named on each family page.

For advanced cases (behaviors, sync, persistence) the Cartesian charts also
accept a mapper-first series such as `OiLineSeriesData<T>`, which reads `x` and
`y` straight off your domain model. Start with the simple pre-mapped series and
move to the mapper form only when you need it.

### OiChartAxis

Configures a single axis. You pass one to a Cartesian chart's `xAxis` or
`yAxis` to set the scale type, a fixed range, how many grid divisions to draw,
and how to format tick values. `OiChartAxis` is generic over its domain type,
so use `OiChartAxis<num>` for a numeric axis. When you leave it off, the chart
infers a sensible axis from the data.

```dart
SizedBox(
  height: 240,
  child: OiLineChart(
    label: 'Monthly revenue',
    yAxis: OiChartAxis<num>(
      label: 'Revenue',
      showGrid: true,
      format: (value) => '\$${value.toStringAsFixed(0)}',
    ),
    series: [
      OiLineSeries(
        label: 'Revenue',
        points: [
          OiLinePoint(x: 1, y: 4200),
          OiLinePoint(x: 2, y: 5100),
          OiLinePoint(x: 3, y: 4800),
        ],
      ),
    ],
  ),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String?` | `null` | Axis title shown beside the axis. |
| `scaleType` | `OiAxisScaleType?` | `null` (inferred) | `linear`, `logarithmic`, `time`, `category`, `band`, `point`, `quantile`, or `threshold`. |
| `position` | `OiAxisPosition?` | `null` | `top`, `bottom`, `left`, or `right`. |
| `min` / `max` | `double?` | `null` | Fixed numeric range. Determined from data when null. |
| `divisions` | `int?` | `null` | Number of grid divisions. Varies by chart when null. |
| `labels` | `List<String>?` | `null` | Fixed tick labels instead of generated ones. |
| `format` | `String Function(double)?` | `null` | Formats numeric tick values. |
| `formatter` | `OiAxisFormatter<TDomain>?` | `null` | Typed formatter with theme and locale context. Prefer for new code. |
| `tickStrategy` | `OiTickStrategy` | `auto` | How ticks are chosen: `auto`, `even`, `all`, or `minMax`. |
| `showGrid` | `bool` | `true` | Draw grid lines for this axis. |
| `showAxisLine` | `bool` | `true` | Draw the axis line. |
| `showTickMarks` | `bool` | `true` | Draw tick marks. |
| `labelOverflow` | `OiChartLabelOverflow` | `skip` | How to handle labels that would overlap. |

### OiChartLegend

Shows a color marker and label for each series. Tap an item to toggle its
visibility, double-tap to focus one series and dim the rest. It is keyboard
operable, and on compact screens it moves below the chart on its own. Most
charts render a legend for you when `showLegend` is on, so reach for
`OiChartLegend` directly when you build a custom layout and want to place the
legend yourself.

```dart
OiChartLegend(
  semanticLabel: 'Series legend',
  items: [
    OiChartLegendItem(id: 'rev', label: 'Revenue', color: context.colors.chart[0]),
    OiChartLegendItem(id: 'cost', label: 'Cost', color: context.colors.chart[1]),
  ],
  onToggle: (id) => toggleSeries(id),
  onExclusiveFocus: (id) => focusSeries(id),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `List<OiChartLegendItem>` | **required** | One entry per series. Each has `id`, `label`, `color`, `visible`. |
| `position` | `OiChartLegendPosition` | `bottom` | `top`, `bottom`, `left`, `right`, or `floating`. Moves to `bottom` on compact. |
| `markerShape` | `OiLegendMarkerShape` | `square` | `square`, `circle`, `line`, `diamond`, or `triangle`. |
| `onToggle` | `ValueChanged<String>?` | `null` | Fires with the tapped series id. |
| `onExclusiveFocus` | `ValueChanged<String>?` | `null` | Fires on double-tap to isolate one series. |
| `itemBuilder` | `OiLegendItemBuilder?` | `null` | Custom builder for a legend item. |
| `legendTheme` | `OiChartLegendTheme?` | `null` | Per-legend theme override. |
| `semanticLabel` | `String?` | `null` | Accessibility label for the legend container. |

### OiChartSeriesToggle

Wraps `OiChartLegend` and owns the visibility logic for you. It tracks which
series are hidden and adds "Show All" and "Hide All" controls. You hold the
hidden set in your state and update it in `onVisibilityChanged`.

```dart
Set<String> _hidden = {};

OiChartSeriesToggle(
  semanticLabel: 'Toggle series',
  series: [
    OiSeriesInfo(id: 'rev', label: 'Revenue', color: context.colors.chart[0]),
    OiSeriesInfo(id: 'cost', label: 'Cost', color: context.colors.chart[1]),
  ],
  hiddenSeriesIds: _hidden,
  onVisibilityChanged: (hiddenIds) => setState(() => _hidden = hiddenIds),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `series` | `List<OiSeriesInfo>` | **required** | All series, each with `id`, `label`, `color`. |
| `onVisibilityChanged` | `ValueChanged<Set<String>>` | **required** | Fires with the updated set of hidden ids. |
| `hiddenSeriesIds` | `Set<String>` | `{}` | The currently hidden series. |
| `legendPosition` | `OiChartLegendPosition` | `bottom` | Position of the embedded legend. |
| `markerShape` | `OiLegendMarkerShape` | `square` | Marker shape for legend items. |
| `showBulkControls` | `bool` | `true` | Show the "Show All" / "Hide All" row. |
| `semanticLabel` | `String?` | `null` | Accessibility label for the control area. |

## Interaction behaviors

Behaviors are small objects you attach to a chart to add interaction. Cartesian
charts accept them through a `behaviors` list. Each one takes callbacks that
fire as the user interacts, so you keep your own state in sync. All five extend
`OiChartBehavior`.

```dart
OiZoomPanBehavior(
  config: const OiZoomPanConfig(minZoom: 1, maxZoom: 10),
  onZoomChanged: (zoom, pan) => print('zoom $zoom'),
)
```

| Behavior | What it does | Key parameters |
| --- | --- | --- |
| `OiZoomPanBehavior` | Scroll-wheel zoom, pinch zoom, and drag pan. | `config` (`OiZoomPanConfig`), `onZoomChanged` |
| `OiHoverSyncBehavior` | Broadcasts the hover position to charts in the same sync group. | `onHoverPositionChanged` |
| `OiSelectionBehavior` | Manages point, series, domain-group, or brush selection. | `mode` (`OiSelectionMode`), `multiSelect`, `onChanged` |
| `OiSeriesToggleBehavior` | Tracks per-series visibility, usually driven by a legend. | `onVisibilityChanged` |
| `OiKeyboardExploreBehavior` | Arrow-key navigation across points and series, Enter to select. | `onPointFocused`, `onPointSelected`, `onSelectionCleared` |

!!! tip
    `OiHoverSyncBehavior` pairs with a `syncGroup` id. Give two charts the same
    `syncGroup` and hovering one highlights the matching spot on the other.
    `OiAnalyticsDashboard` sets this up for all its panels at once.

## OiChartSurface

A themed container to sit a chart in, built on `OiSurface`. It gives you a
consistent card background, border, and shadow that match `OiCard` and the rest
of the library. The default constructor is a card. Named constructors switch the
look.

```dart
OiChartSurface(
  semanticLabel: 'Revenue this quarter',
  child: SizedBox(
    height: 240,
    child: OiLineChart(
      label: 'Revenue this quarter',
      series: [
        OiLineSeries(
          label: 'Revenue',
          points: [OiLinePoint(x: 1, y: 4200), OiLinePoint(x: 2, y: 5100)],
        ),
      ],
    ),
  ),
)
```

The presentation presets:

```dart
OiChartSurface(child: chart)          // card look with elevation shadow
OiChartSurface.atom(child: chart)     // bare, no chrome, no padding
OiChartSurface.compact(child: chart)  // reduced padding for inline use
OiChartSurface.soft(child: chart)     // tinted background, no shadow
OiChartSurface.frosted(child: chart)  // frosted-glass backdrop blur
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | **required** | The chart to render inside. |
| `padding` | `EdgeInsetsGeometry?` | varies by preset | Inner padding. `16` for card, `8` for compact, `0` for atom. |
| `border` | `OiBorderStyle?` | `null` | Border override. |
| `gradient` | `OiGradientStyle?` | `null` | Background gradient, replaces the fill color. |
| `halo` | `OiHaloStyle?` | `null` | Optional glow around the surface. |
| `semanticLabel` | `String?` | `null` | Accessibility label. |

### OiChartGrid

`OiChartGrid` is a low-level painting helper, not a widget. The Cartesian charts
use its static methods internally to draw grid lines, axis lines, and tick
labels so they all look the same. You do not construct it or pass it anywhere.
To change how the grid looks, set `showGrid` on an `OiChartAxis`, or use the
grid tokens in `OiChartThemeData`. It is documented here only so the name is not
a mystery when you see it in the source.

## Theming

Charts read their colors from the theme like everything else. Series colors come
from `context.colors.chart`, an ordered list of categorical colors. You rarely
set colors by hand. To customize charts globally, provide an `OiChartThemeData`
through your theme, reachable at `context.components.chart`.

`OiChartThemeData` groups every visual token into sub-themes: `palette`, `axis`,
`grid`, `legend`, `tooltip`, `crosshair`, `annotation`, `selection`, `state`,
`motion`, and `density`. Each is optional, so you override only what you want.

```dart
const OiChartThemeData(
  grid: OiChartGridTheme(dashPattern: [4, 2]),
  density: OiChartDensityTheme(lineWidth: 3),
)
```

The color side lives in `OiChartPalette`. It holds the ordered `categorical`
list used to color series by index, plus semantic colors `positive`,
`negative`, `neutral`, and `highlight`, and optional `sequential` and
`diverging` gradients for continuous scales like heatmaps. Build one from your
color scheme, or use `OiChartPalette.atom` for a single-color chart.

```dart
// One palette from the current color scheme.
final palette = OiChartPalette.colors(context.colors);

// A single-color palette for a one-series chart.
final mono = OiChartPalette.atom(color: context.colors.primary.base);
```

| `OiChartPalette` field | Type | Description |
| --- | --- | --- |
| `categorical` | `List<Color>` | Series colors, assigned by index and cycled. |
| `positive` | `Color` | Gains, up, profit. |
| `negative` | `Color` | Losses, down, decline. |
| `neutral` | `Color` | Baseline or no-change. |
| `highlight` | `Color` | Emphasized point or series. |
| `sequential` | `List<Color>?` | Gradient for continuous data. |
| `diverging` | `List<Color>?` | Gradient around a midpoint (for example profit and loss). |

**Theme:** `context.components.chart` → `OiChartThemeData`

## OiAnalyticsDashboard

A ready-made dashboard that lays out several charts in a grid and can sync their
interactions. Each panel is an `OiDashboardPanel` that names its grid position
and holds a chart. Set a `syncGroup` and hovering one panel highlights the
matching spot on the others. On narrow screens the grid drops columns on its
own.

```dart
OiAnalyticsDashboard(
  label: 'Sales analytics',
  syncGroup: 'sales',
  columns: 3,
  panels: [
    OiDashboardPanel(
      id: 'revenue',
      title: 'Revenue over time',
      gridPosition: OiGridPosition(row: 0, col: 0, colSpan: 2),
      chart: OiLineChart(
        label: 'Revenue over time',
        series: [
          OiLineSeries(
            label: 'Revenue',
            points: [OiLinePoint(x: 1, y: 4200), OiLinePoint(x: 2, y: 5100)],
          ),
        ],
      ),
    ),
    OiDashboardPanel(
      id: 'breakdown',
      title: 'By category',
      gridPosition: OiGridPosition(row: 0, col: 2),
      chart: OiLineChart(
        label: 'By category',
        series: [
          OiLineSeries(
            label: 'Category',
            points: [OiLinePoint(x: 1, y: 900), OiLinePoint(x: 2, y: 1200)],
          ),
        ],
      ),
    ),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label for the dashboard. |
| `panels` | `List<OiDashboardPanel>` | **required** | The chart panels. Empty shows an empty state. |
| `syncGroup` | `String?` | `null` | Links panels so hover and crosshair sync across them. |
| `columns` | `int` | `3` | Logical grid columns. Reduced on narrow screens. |
| `rowHeight` | `double` | `250.0` | Height of each grid row in pixels. |
| `spacing` | `double` | `16.0` | Gap between panels in pixels. |
| `filters` | `List<OiDashboardFilter>` | `[]` | Optional filter bar above the grid. |
| `onFilterChange` | `ValueChanged<List<OiDashboardFilter>>?` | `null` | Fires when a filter changes. |
| `semanticLabel` | `String?` | `null` | Overrides `label` for screen readers. |

## Related

- [Cartesian charts](cartesian.md) for line, bar, area, scatter, and combo charts.
- [Distribution charts](distribution.md) for histograms, box plots, and heatmaps.
- [Part-to-whole charts](part-to-whole.md) for pie, donut, funnel, and treemap.
- [Specialized charts](specialized.md) for gauges, radar, candlestick, and more.
