# Line, Area & Bar Charts

These are the everyday x/y charts: trends over time, comparisons across
categories, and correlations between two values. They live in a separate
package, so add one import wherever you use them.

```dart
import 'package:obers_ui_charts/obers_ui_charts.dart';
```

Every chart takes a `label`. It is the accessibility text a screen reader
announces, so always pass something meaningful. Give a chart a fixed size by
wrapping it in a `SizedBox` or placing it in a sized parent. Colors come from
the theme chart palette, so series pick distinct colors without you setting any.

Bar charts resolve axis typography and color from `components.chart.axis` and
plot insets from `components.chart.density.padding`. Numeric ticks, category
labels and group labels retain the configured font family and variable axes.
Per-chart color overrides take precedence over component theme values.

| Chart | What it does |
| --- | --- |
| `OiLineChart` | Trends over time as one or more lines. |
| `OiAreaChart` | Filled lines for volume and part-to-whole trends. |
| `OiBarChart` | Compares values across named categories. |
| `OiRangeBarChart` | Bars that span from a start value to an end value (Gantt-style). |
| `OiRangeAreaChart` | A shaded band between a low and a high value. |
| `OiScatterPlot` | Dots for correlation between two variables. |
| `OiComboChart` | Mixes lines, bars, areas, and scatter on one grid. |
| `OiCartesianChart` | The low-level base for building custom cartesian charts. |

## OiLineChart

The chart you reach for most. Pass a list of `OiLineSeries`, each holding a list
of `OiLinePoint` values with an `x` and a `y`.

```dart
OiLineChart(
  label: 'Monthly revenue',
  series: [
    OiLineSeries(
      label: 'Revenue',
      points: const [
        OiLinePoint(x: 1, y: 12),
        OiLinePoint(x: 2, y: 18),
        OiLinePoint(x: 3, y: 15),
        OiLinePoint(x: 4, y: 24),
      ],
    ),
  ],
)
```

Pass more than one series to compare lines. The legend appears automatically
when there are two or more series.

```dart
OiLineChart(
  label: 'Revenue vs cost',
  series: [
    OiLineSeries(
      label: 'Revenue',
      points: const [OiLinePoint(x: 1, y: 12), OiLinePoint(x: 2, y: 18)],
    ),
    OiLineSeries(
      label: 'Cost',
      points: const [OiLinePoint(x: 1, y: 8), OiLinePoint(x: 2, y: 11)],
      dashed: true,
    ),
  ],
)
```

### Variants

Three named constructors set how points connect. The default is `straight`.

```dart
OiLineChart.straight(label: 'Sales', series: series)  // straight segments
OiLineChart.stepped(label: 'Sales', series: series)   // staircase steps
OiLineChart.smooth(label: 'Sales', series: series)    // smooth curves
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label for the chart. |
| `series` | `List<OiLineSeries>` | **required** | The lines to draw. Each has a `label` and a list of `OiLinePoint`. |
| `mode` | `OiLineChartMode` | `straight` | `straight`, `stepped`, or `smooth`. |
| `xAxis` | `OiChartAxis<num>?` | `null` | X-axis config (labels, min, max, divisions). |
| `yAxis` | `OiChartAxis<num>?` | `null` | Y-axis config. |
| `showGrid` | `bool` | `true` | Show background grid lines. |
| `showLegend` | `bool` | `true` | Show a legend when there are two or more series. |
| `showPoints` | `bool` | `false` | Draw a dot at each data point. |
| `stacked` | `bool` | `false` | Stack series values cumulatively. |
| `onPointTap` | `void Function(int, int)?` | `null` | Called with the series and point index on tap. |

Each `OiLineSeries` also takes `color`, `strokeWidth`, `dashed`, `fill`, and
`fillOpacity`. Set `fill: true` to shade below a single line.

!!! tip
    For a single series bound straight to your model, use
    `OiLineChart.fromData<T>(label: ..., data: ..., x: ..., y: ...)`. It maps
    each item to an `OiLinePoint` for you.

## OiAreaChart

A line chart with the area below it filled. Reach for it to show volume or how
parts add up over time. Unlike `OiLineChart`, its series map values straight
from your own model. Each `OiAreaSeries` takes an `id`, a `label`, the `data`
list, and `xMapper` / `yMapper` functions.

```dart
final points = [
  (day: 1, visits: 40),
  (day: 2, visits: 65),
  (day: 3, visits: 52),
  (day: 4, visits: 80),
];

OiAreaChart<({int day, int visits})>(
  label: 'Daily visits',
  series: [
    OiAreaSeries(
      id: 'visits',
      label: 'Visits',
      data: points,
      xMapper: (p) => p.day,
      yMapper: (p) => p.visits,
    ),
  ],
)
```

Set `stacked: true` to stack multiple areas, or give series a shared
`stackGroup` to stack only some of them.

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label for the chart. |
| `series` | `List<OiAreaSeries<T>>` | **required** | The areas to draw. Each maps `x` and `y` from your model. |
| `xAxis` | `OiChartAxis<num>?` | `null` | X-axis config. |
| `yAxis` | `OiChartAxis<num>?` | `null` | Y-axis config. |
| `showGrid` | `bool` | `true` | Show background grid lines. |
| `showLegend` | `bool` | `true` | Show a legend when there are two or more series. |
| `showPoints` | `bool` | `false` | Draw a dot at each data point. |
| `stacked` | `bool` | `false` | Stack series values cumulatively. |
| `onPointTap` | `void Function(int, int)?` | `null` | Called with the series and point index on tap. |

Each `OiAreaSeries` also takes `fillOpacity` (default `0.3`), `showLine`
(default `true`), `color`, and `stackGroup`.

## OiBarChart

Compares values across named categories. You build a list of `OiBarCategory`,
each with a `label` and a list of `values`, one value per series. For a single
series, give each category a one-element list.

```dart
OiBarChart(
  label: 'Sales by quarter',
  categories: const [
    OiBarCategory(label: 'Q1', values: [12]),
    OiBarCategory(label: 'Q2', values: [18]),
    OiBarCategory(label: 'Q3', values: [15]),
    OiBarCategory(label: 'Q4', values: [24]),
  ],
)
```

For grouped or stacked bars, give each category several values and name the
series with `OiBarSeries` so the legend has labels.

```dart
OiBarChart.stacked(
  label: 'Revenue by channel',
  categories: const [
    OiBarCategory(label: 'Q1', values: [12, 5]),
    OiBarCategory(label: 'Q2', values: [18, 7]),
  ],
  series: const [
    OiBarSeries(label: 'Online'),
    OiBarSeries(label: 'Retail'),
  ],
  showValues: true,
)
```

### Variants

Four named constructors set the layout. The default is `grouped`.

```dart
OiBarChart.grouped(label: 'Sales', categories: cats)            // vertical, side by side
OiBarChart.stacked(label: 'Sales', categories: cats)            // vertical, stacked
OiBarChart.horizontalGrouped(label: 'Sales', categories: cats)  // horizontal, side by side
OiBarChart.horizontalStacked(label: 'Sales', categories: cats)  // horizontal, stacked
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label for the chart. |
| `categories` | `List<OiBarCategory>` | **required** | The categories. Each has a `label` and one value per series. |
| `mode` | `OiBarChartMode` | `grouped` | `grouped`, `stacked`, `horizontalGrouped`, or `horizontalStacked`. |
| `series` | `List<OiBarSeries>?` | `null` | Named series for the legend and colors. |
| `showValues` | `bool` | `false` | Print each value on its bar. |
| `showGrid` | `bool` | `true` | Show background grid lines. |
| `showLegend` | `bool` | `true` | Show a legend when there are two or more series. |
| `barRadius` | `double` | `4.0` | Corner radius of each bar. |
| `yAxis` | `OiChartAxis<num>?` | `null` | Value axis config. |
| `onBarTap` | `void Function(int, int?)?` | `null` | Called with the category and series index on tap. |

## OiRangeBarChart

Draws each bar spanning from a start value to an end value instead of from zero.
Good for timelines and Gantt-style views. Each `OiRangeBarSeries` maps a
category, a start, and an end from your model.

```dart
final tasks = [
  (name: 'Design', start: 0, end: 3),
  (name: 'Build', start: 2, end: 7),
  (name: 'Ship', start: 6, end: 9),
];

OiRangeBarChart<({String name, int start, int end})>(
  label: 'Project timeline',
  series: [
    OiRangeBarSeries(
      id: 'tasks',
      label: 'Tasks',
      data: tasks,
      categoryMapper: (t) => t.name,
      startMapper: (t) => t.start,
      endMapper: (t) => t.end,
    ),
  ],
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label for the chart. |
| `series` | `List<OiRangeBarSeries<T>>` | **required** | The bars to draw. Each maps a category, start, and end. |
| `horizontal` | `bool` | `true` | Categories run down the y-axis (Gantt-style). Set `false` for vertical floating bars. |
| `showGrid` | `bool` | `true` | Show background grid lines. |
| `xAxis` | `OiChartAxis<num>?` | `null` | Value axis in horizontal mode, category axis in vertical mode. |
| `yAxis` | `OiChartAxis<num>?` | `null` | The other axis. |

Each `OiRangeBarSeries` also takes `color`, a per-item `colorMapper`, `visible`,
and `semanticLabel`.

## OiRangeAreaChart

Shades a band between a low value and a high value across an x-domain. Reach for
it to show min/max envelopes or confidence bands. Each `OiRangeAreaSeries` maps
an x, a `yMin`, and a `yMax`, with an optional mid-line.

```dart
final readings = [
  (day: 1, low: 8, high: 14, avg: 11),
  (day: 2, low: 9, high: 17, avg: 13),
  (day: 3, low: 7, high: 15, avg: 11),
];

OiRangeAreaChart<({int day, int low, int high, int avg})>(
  label: 'Temperature range',
  series: [
    OiRangeAreaSeries(
      id: 'temp',
      label: 'Temperature',
      data: readings,
      xMapper: (r) => r.day,
      yMinMapper: (r) => r.low,
      yMaxMapper: (r) => r.high,
      midLineMapper: (r) => r.avg,
    ),
  ],
  showMidLine: true,
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label for the chart. |
| `series` | `List<OiRangeAreaSeries<T>>` | **required** | The bands to draw. Each maps `x`, `yMin`, and `yMax`. |
| `showMidLine` | `bool` | `true` | Draw a center line when the series provides a `midLineMapper`. |
| `fillOpacity` | `double` | `0.2` | Opacity of the shaded band, from `0.0` to `1.0`. |
| `showGrid` | `bool` | `true` | Show background grid lines. |
| `xAxis` | `OiChartAxis<num>?` | `null` | X-axis config. |
| `yAxis` | `OiChartAxis<num>?` | `null` | Y-axis config. |

## OiScatterPlot

Plots dots to show correlation between two variables. Pass a list of
`OiScatterSeries`, each with a list of `OiScatterPoint` values.

```dart
OiScatterPlot(
  label: 'Height vs weight',
  series: [
    OiScatterSeries(
      label: 'Sample',
      points: const [
        OiScatterPoint(x: 160, y: 55),
        OiScatterPoint(x: 172, y: 68),
        OiScatterPoint(x: 180, y: 77),
        OiScatterPoint(x: 165, y: 60),
      ],
    ),
  ],
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label for the chart. |
| `series` | `List<OiScatterSeries>` | **required** | The point sets. Each has a `label` and a list of `OiScatterPoint`. |
| `xAxis` | `OiChartAxis<num>?` | `null` | X-axis config. |
| `yAxis` | `OiChartAxis<num>?` | `null` | Y-axis config. |
| `showGrid` | `bool` | `true` | Show background grid lines. |
| `showLegend` | `bool` | `true` | Show a legend when there are two or more series. |
| `onPointTap` | `void Function(int, int)?` | `null` | Called with the series and point index on tap. |

Each `OiScatterSeries` also takes `color`, `pointRadius`, and a `shape`
(`circle`, `square`, `diamond`, or `triangle`).

## OiComboChart

Draws several series types on one shared grid. Mix line, area, bar, and scatter
series so a single chart can show, say, revenue bars behind a target line. Each
series maps `x` and `y` from your model with `xMapper` and `yMapper`.

```dart
final months = [
  (m: 1, sales: 40, target: 45),
  (m: 2, sales: 62, target: 50),
  (m: 3, sales: 55, target: 55),
];

OiComboChart<({int m, int sales, int target})>(
  label: 'Sales vs target',
  series: [
    OiComboBarSeries(
      id: 'sales',
      label: 'Sales',
      data: months,
      xMapper: (r) => r.m,
      yMapper: (r) => r.sales,
    ),
    OiLineSeriesData(
      id: 'target',
      label: 'Target',
      data: months,
      xMapper: (r) => r.m,
      yMapper: (r) => r.target,
    ),
  ],
)
```

The series list accepts these types:

- `OiComboBarSeries` drawn as vertical bars.
- `OiComboScatterSeries` drawn as dots.
- `OiAreaSeries` drawn as a filled area.
- Any other `OiCartesianSeries` (such as `OiLineSeriesData`) drawn as a line.

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label for the chart. |
| `series` | `List<OiCartesianSeries<T>>` | **required** | Mixed-type series on one coordinate system. |
| `xAxis` | `OiChartAxis<dynamic>?` | `null` | X-axis config. |
| `yAxis` | `OiChartAxis<num>?` | `null` | Y-axis config. |
| `showGrid` | `bool` | `true` | Show background grid lines. |
| `showLegend` | `bool` | `true` | Show a legend when there are two or more series. |
| `onPointTap` | `void Function(int, int)?` | `null` | Called with the series and point index on tap. |
| `theme` | `OiComboChartTheme?` | `null` | Overrides for series colors, grid, and bar radius. |

## OiCartesianChart

The low-level base that the charts above are built on. Reach for it only when
you need the full data pipeline: composable `behaviors` (tooltip, crosshair,
zoom), a `controller`, multiple y-axes, `annotations`, `thresholds`, decimation
via `performance`, and settings persistence. You supply a `seriesBuilder` that
paints the series inside the computed plot area. For everyday charts, use one of
the wrappers instead.

```dart
OiCartesianChart<({int x, int y})>(
  label: 'Custom chart',
  series: [
    OiLineSeriesData(
      id: 'main',
      label: 'Main',
      data: const [(x: 1, y: 10), (x: 2, y: 14)],
      xMapper: (p) => p.x,
      yMapper: (p) => p.y,
    ),
  ],
  behaviors: const [],
  seriesBuilder: (context, viewport, visibleSeries) {
    // Paint the visible series inside viewport.size here.
    return const SizedBox.expand();
  },
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label for the chart. |
| `series` | `List<OiCartesianSeries<T>>` | **required** | Mapper-first series to render. |
| `xAxis` | `OiChartAxis<dynamic>?` | `null` | X-axis config. |
| `yAxes` | `List<OiChartAxis<num>>?` | `null` | One or more y-axes for multi-axis charts. |
| `seriesBuilder` | `Widget Function(...)?` | `null` | Paints the series in the plot area. Without it, only the frame renders. |
| `behaviors` | `List<OiChartBehavior>` | `const []` | Tooltip, crosshair, zoom, selection, and more. |
| `controller` | `OiChartController?` | `null` | Programmatic state. An internal one is used if null. |
| `annotations` | `List<OiChartAnnotation>` | `const []` | Reference lines, regions, points, and labels. |
| `thresholds` | `List<OiChartThreshold>` | `const []` | Threshold reference lines. |
| `performance` | `OiChartPerformanceConfig?` | `null` | Decimation and rendering mode for large datasets. |
| `syncGroup` | `OiChartSyncGroup?` | `null` | Links viewport across multiple charts. |
| `settings` | `OiChartSettings?` | `null` | Persists chart state. |

## Configuring axes

All of these charts take `xAxis` and `yAxis` as `OiChartAxis`. Use it to set the
range, the number of divisions, fixed labels, or a value formatter.

```dart
OiLineChart(
  label: 'Revenue',
  series: series,
  yAxis: OiChartAxis<double>(
    label: 'USD',
    min: 0,
    max: 100,
    divisions: 5,
    format: (value) => '\$${value.toStringAsFixed(0)}',
  ),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String?` | `null` | Axis title shown beside the axis. |
| `labels` | `List<String>?` | `null` | Fixed tick labels instead of generated numbers. |
| `format` | `String Function(double)?` | `null` | Formats numeric tick values. |
| `divisions` | `int?` | `null` | Number of grid divisions. Chart picks a default. |
| `min` / `max` | `double?` | `null` | Fix the axis range. Data-driven when null. |
| `scaleType` | `OiAxisScaleType?` | `null` | `linear`, `time`, `category`, and more. Inferred when null. |
| `showGrid` | `bool` | `true` | Show grid lines for this axis. |

## Related

- [Charts overview](index.md) for the full chart catalog and shared setup.
- [Distribution charts](distribution.md) for histograms, box plots, and heatmaps.
- [Part-to-whole charts](part-to-whole.md) for pie, donut, and treemap charts.
- [Specialized charts](specialized.md) for gauges, funnels, and radial charts.

## Forecast patterns and grouped category labels

`OiBarSeries.pattern` accepts `OiBarPattern.diagonal` to distinguish tentative or
forecast data without relying on color alone. `OiBarCategory.patterns` and
`colors` override individual bars. Patterns work for grouped/stacked and vertical/
horizontal bars. `OiBarCategory.group` adds a second-level label below contiguous
vertical categories, useful for grouping dates into weeks. Axis typography inherits
the shared theme.

Explicit `yAxis.min` and `yAxis.max` on `OiBarChart` control both tick labels and bar geometry. Values outside the numeric domain are clipped to the plot range; stacked segments use the same cumulative scale.
