# Radar, Gauge, Heatmap & Flow Charts

These are the specialized chart types for angular, matrix, and flow data. Reach
for them when a bar or line chart does not fit: comparing many dimensions at
once, showing a single value against a range, or tracing how amounts move
between stages. Every chart lives in the separate `obers_ui_charts` package and
takes a required `label` for screen readers.

Add this import to every example:

```dart
import 'package:obers_ui_charts/obers_ui_charts.dart';
```

| Chart | What it does |
| --- | --- |
| `OiRadarChart` | Compares several series across shared axes as overlapping polygons. |
| `OiPolarChart` | Base composite for pie, donut, and radar layouts. You supply the drawing. |
| `OiPolarAreaChart` | Equal-angle wedges whose radius encodes a value. |
| `OiGauge` | A speedometer arc showing one value within a range. |
| `OiHeatmap` | A grid of colored cells, one value per cell. |
| `OiCalendarHeatmap` | A GitHub-style year grid of daily activity. |
| `OiMatrixChart` | Base composite for heatmaps and correlation grids. You supply the drawing. |
| `OiSankey` | Flow bands between nodes, width proportional to value. |
| `OiFlowChart` | Base composite for Sankey and network layouts. You supply the drawing. |

## OiRadarChart

A radar (spider) chart. Reach for it to compare a few series across the same set
of axes, like skill ratings or product scores. Each series is one polygon.

```dart
OiRadarChart(
  label: 'Skill comparison',
  axes: const ['Speed', 'Power', 'Range', 'Defense', 'Support'],
  series: const [
    OiRadarSeries(label: 'Player A', values: [8, 6, 7, 5, 9]),
    OiRadarSeries(label: 'Player B', values: [5, 9, 6, 8, 4]),
  ],
)
```

Each `OiRadarSeries` needs one value per axis. The `values` list must match the
length of `axes`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `axes` | `List<String>` | **required** | The axis labels around the perimeter. |
| `series` | `List<OiRadarSeries>` | **required** | The polygons to draw. |
| `label` | `String` | **required** | Accessibility label. |
| `showLegend` | `bool` | `true` | Show a legend below the chart. |
| `showValues` | `bool` | `false` | Draw the numeric value at each vertex. |
| `maxValue` | `double?` | `null` | Radial scale maximum. Defaults to the largest value. |
| `size` | `double?` | `null` | Chart diameter. Defaults to the available width. |

`OiRadarSeries` takes `label` (**required**), `values` (**required**), an
optional `color`, and `fillOpacity` (default `0.2`).

## OiPolarChart

A base composite for radial layouts (pie, donut, radar). It handles arc layout,
angular hit testing, and behaviors, but it does not paint anything by itself.
You pass a `seriesBuilder` to draw the arcs. For a ready-made radar, use
`OiRadarChart`; for pie and donut, see the part-to-whole page.

```dart
OiPolarChart<({String name, double value})>(
  label: 'Traffic sources',
  series: [
    OiPolarSeries(
      id: 'sources',
      label: 'Sources',
      data: const [
        (name: 'Direct', value: 40),
        (name: 'Search', value: 35),
        (name: 'Social', value: 25),
      ],
      valueMapper: (item) => item.value,
      labelMapper: (item) => item.name,
    ),
  ],
  seriesBuilder: (context, viewport, visibleSeries) {
    // Paint arcs for visibleSeries here.
    return const SizedBox.shrink();
  },
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label. |
| `series` | `List<OiPolarSeries<T>>` | **required** | The data series. |
| `seriesBuilder` | `Widget Function(...)?` | `null` | Draws the series. Without it the chart is blank. |
| `angleAxis` | `OiPolarAngleAxis?` | `null` | Angle axis configuration. |
| `radiusAxis` | `OiPolarRadiusAxis?` | `null` | Radius axis configuration. |
| `centerContent` | `Widget?` | `null` | Widget shown in the center, for a donut label. |
| `controller` | `OiChartController?` | `null` | External chart controller. |

`OiPolarSeries` takes `id`, `label`, `valueMapper`, and `labelMapper` as required
fields, plus an optional `data` list, `color`, and `visible`.

## OiPolarAreaChart

Each category gets an equal slice of the circle, and its radius grows with the
value. Reach for it when the order around the circle matters, like months of the
year.

```dart
OiPolarAreaChart<({String month, double value})>(
  label: 'Monthly rainfall',
  series: [
    OiPolarAreaSeries(
      id: 'rain',
      label: 'Rainfall',
      data: const [
        (month: 'Jan', value: 40),
        (month: 'Feb', value: 55),
        (month: 'Mar', value: 30),
        (month: 'Apr', value: 70),
      ],
      categoryMapper: (item) => item.month,
      valueMapper: (item) => item.value,
    ),
  ],
)
```

Unlike `OiPolarChart`, this one paints itself. All visible series must have the
same number of items.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label. |
| `series` | `List<OiPolarAreaSeries<T>>` | **required** | The wedge series. |
| `startAngle` | `double` | `-90` | Start angle in degrees. `-90` starts at the top. |
| `showLabels` | `bool` | `true` | Show category labels around the perimeter. |
| `showLegend` | `bool` | `true` | Show a legend below the chart. |
| `fillOpacity` | `double` | `0.65` | Wedge fill opacity, `0.0` to `1.0`. |
| `compact` | `bool?` | `null` | Hide labels and legend. Auto below 120 px wide. |

`OiPolarAreaSeries` takes `id`, `label`, `data`, `categoryMapper`, and
`valueMapper` as required fields, plus an optional `color` and `visible`.

## OiGauge

A speedometer arc for a single value inside a range. Reach for it to show CPU
load, a score, or progress toward a target. It renders one measurement at a
time, so there is no series to build.

```dart
OiGauge(
  label: 'CPU load',
  value: 72,
  min: 0,
  max: 100,
)
```

Colored `segments` mark ranges, and `target` drops a marker at a goal value.

```dart
OiGauge(
  label: 'Response time',
  value: 180,
  max: 500,
  target: 200,
  segments: [
    OiGaugeSegment(from: 0, to: 200, color: context.colors.success.base),
    OiGaugeSegment(from: 200, to: 500, color: context.colors.error.base),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `double` | **required** | The value the needle points to. |
| `label` | `String` | **required** | Accessibility label. |
| `min` | `double` | `0` | Range minimum. |
| `max` | `double` | `100` | Range maximum. |
| `segments` | `List<OiGaugeSegment>?` | `null` | Colored range bands on the arc. |
| `target` | `double?` | `null` | A goal marker on the arc. |
| `showValue` | `bool` | `true` | Show the numeric value below the arc. |
| `formatValue` | `String Function(double)?` | `null` | Custom value formatter. |
| `size` | `double?` | `null` | Gauge diameter. Defaults to the available width. |

`OiGaugeSegment` takes `from`, `to`, and `color` as required fields, plus an
optional `label`.

## OiHeatmap

A grid of cells, each colored by its value on a low-to-high gradient. Reach for
it to show a small matrix, like activity by day and hour. Cells are placed by
zero-based `row` and `column` index.

```dart
OiHeatmap(
  label: 'Weekly activity',
  rowLabels: const ['Mon', 'Tue', 'Wed'],
  columnLabels: const ['AM', 'PM'],
  cells: const [
    OiHeatmapCell(row: 0, column: 0, value: 3),
    OiHeatmapCell(row: 0, column: 1, value: 8),
    OiHeatmapCell(row: 1, column: 0, value: 5),
    OiHeatmapCell(row: 1, column: 1, value: 2),
    OiHeatmapCell(row: 2, column: 0, value: 9),
    OiHeatmapCell(row: 2, column: 1, value: 6),
  ],
)
```

The value shows inside each cell by default, so color is never the only cue.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cells` | `List<OiHeatmapCell>` | **required** | The grid cells. |
| `label` | `String` | **required** | Accessibility label. |
| `rowLabels` | `List<String>?` | `null` | Labels down the left edge. |
| `columnLabels` | `List<String>?` | `null` | Labels across the top edge. |
| `minValue` | `double?` | `null` | Color scale minimum. Defaults to the data minimum. |
| `maxValue` | `double?` | `null` | Color scale maximum. Defaults to the data maximum. |
| `lowColor` | `Color?` | `null` | Color for the lowest value. |
| `highColor` | `Color?` | `null` | Color for the highest value. |
| `showValues` | `bool` | `true` | Draw the value inside each cell. |
| `onCellTap` | `ValueChanged<OiHeatmapCell>?` | `null` | Called when a cell is tapped. |

`OiHeatmapCell` takes `row`, `column`, and `value`, all required.

## OiCalendarHeatmap

A GitHub-style contribution grid. Columns are weeks, rows are days. Reach for it
to show daily activity over weeks or a year. You give it your own data type and
mapper functions. Items on the same date are summed.

```dart
OiCalendarHeatmap<({DateTime date, int count})>(
  label: 'Contributions',
  data: [
    (date: DateTime(2026, 1, 5), count: 3),
    (date: DateTime(2026, 1, 6), count: 7),
    (date: DateTime(2026, 2, 2), count: 1),
  ],
  dateMapper: (item) => item.date,
  valueMapper: (item) => item.count,
)
```

By default the grid covers the year ending today. Set `startDate` and `endDate`
to change the window.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label. |
| `data` | `List<T>` | **required** | Your activity records. |
| `dateMapper` | `DateTime Function(T)` | **required** | Extracts the date from a record. |
| `valueMapper` | `num Function(T)` | **required** | Extracts the value from a record. |
| `startDate` | `DateTime?` | `null` | First date shown. Defaults to one year before `endDate`. |
| `endDate` | `DateTime?` | `null` | Last date shown. Defaults to today. |
| `colorScale` | `OiColorScale?` | `null` | Value-to-color mapping. Defaults to a green scale. |
| `weekStartsOn` | `int` | `DateTime.monday` | First day of each week column. |
| `showMonthLabels` | `bool` | `true` | Month labels above the columns. |
| `showDayLabels` | `bool` | `true` | Mon / Wed / Fri labels on the left. |
| `cellSize` | `double` | `12` | Cell width and height in pixels. |
| `cellSpacing` | `double` | `2` | Gap between cells in pixels. |

## OiMatrixChart

A base composite for cell-grid charts like heatmaps and correlation matrices. It
handles grid layout, color scaling, and cell hit testing, but you supply a
`seriesBuilder` to paint the cells. For a ready-made grid, use `OiHeatmap`.

```dart
OiMatrixChart<({String x, String y, double v})>(
  label: 'Correlation matrix',
  series: [
    OiMatrixSeries(
      id: 'corr',
      label: 'Correlation',
      data: const [
        (x: 'A', y: 'A', v: 1),
        (x: 'A', y: 'B', v: 0.4),
        (x: 'B', y: 'A', v: 0.4),
        (x: 'B', y: 'B', v: 1),
      ],
      rowMapper: (item) => item.y,
      columnMapper: (item) => item.x,
      valueMapper: (item) => item.v,
    ),
  ],
  colorScale: OiColorScale.linear(
    minColor: const Color(0xFFEBEDF0),
    maxColor: const Color(0xFF216E39),
    min: 0,
    max: 1,
  ),
  seriesBuilder: (context, viewport, visibleSeries) {
    // Paint cells for visibleSeries here.
    return const SizedBox.shrink();
  },
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label. |
| `series` | `List<OiMatrixSeries<T>>` | **required** | The cell data. |
| `seriesBuilder` | `Widget Function(...)?` | `null` | Draws the cells. Without it the chart is blank. |
| `xAxis` | `OiChartAxis?` | `null` | X-axis configuration. |
| `yAxis` | `OiChartAxis?` | `null` | Y-axis configuration. |
| `colorScale` | `OiColorScale?` | `null` | Value-to-color mapping. |
| `controller` | `OiChartController?` | `null` | External chart controller. |

`OiMatrixSeries` takes `id`, `label`, `rowMapper`, `columnMapper`, and
`valueMapper` as required fields, plus an optional `data` list, `color`, and
`visible`.

## OiSankey

A Sankey diagram. Reach for it to show how an amount splits and flows between
stages, like a budget or a conversion funnel. Nodes sit in columns, and link
width is proportional to value.

```dart
OiSankey(
  label: 'Budget flow',
  nodes: const [
    OiSankeyNode(key: 'income', label: 'Income'),
    OiSankeyNode(key: 'rent', label: 'Rent'),
    OiSankeyNode(key: 'food', label: 'Food'),
    OiSankeyNode(key: 'savings', label: 'Savings'),
  ],
  links: const [
    OiSankeyLink(source: 'income', target: 'rent', value: 1200),
    OiSankeyLink(source: 'income', target: 'food', value: 600),
    OiSankeyLink(source: 'income', target: 'savings', value: 400),
  ],
)
```

Node columns are derived from the link graph, so you only list nodes and links.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `nodes` | `List<OiSankeyNode>` | **required** | The nodes in the diagram. |
| `links` | `List<OiSankeyLink>` | **required** | The flows between nodes. |
| `label` | `String` | **required** | Accessibility label. |
| `showLabels` | `bool` | `true` | Show a label next to each node. |
| `showValues` | `bool` | `false` | Show each node's total value. |
| `onNodeTap` | `ValueChanged<OiSankeyNode>?` | `null` | Called when a node is tapped. |
| `onLinkTap` | `ValueChanged<OiSankeyLink>?` | `null` | Called when a link is tapped. |

`OiSankeyNode` takes `key` and `label` (both required) plus an optional `color`.
`OiSankeyLink` takes `source`, `target`, and `value` (all required) plus an
optional `color`.

## OiFlowChart

A base composite for flow and network layouts (Sankey, alluvial). It handles
node and link layout and flow scaling, but you supply a `seriesBuilder` to draw
the bands. For a ready-made flow diagram, use `OiSankey`.

```dart
OiFlowChart<({String id, String name}), ({String from, String to, double value})>(
  label: 'User journey',
  series: OiFlowSeries(
    id: 'journey',
    label: 'Journey',
    data: const [
      (id: 'visit', name: 'Visit'),
      (id: 'signup', name: 'Sign up'),
      (id: 'purchase', name: 'Purchase'),
    ],
    links: const [
      (from: 'visit', to: 'signup', value: 60),
      (from: 'signup', to: 'purchase', value: 25),
    ],
    nodeIdMapper: (node) => node.id,
    nodeLabelMapper: (node) => node.name,
    sourceIdMapper: (link) => link.from,
    targetIdMapper: (link) => link.to,
    linkValueMapper: (link) => link.value,
  ),
  seriesBuilder: (context, viewport, series) {
    // Paint nodes and links here.
    return const SizedBox.shrink();
  },
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label. |
| `series` | `OiFlowSeries<TNode, TLink>` | **required** | The nodes and links. |
| `seriesBuilder` | `Widget Function(...)?` | `null` | Draws the flow. Without it the chart is blank. |
| `controller` | `OiChartController?` | `null` | External chart controller. |

`OiFlowSeries` takes `id`, `label`, `data`, `links`, `nodeIdMapper`,
`nodeLabelMapper`, `sourceIdMapper`, `targetIdMapper`, and `linkValueMapper` as
required fields, plus an optional `color` and `visible`.

## Related

- [Charts overview](index.md) for setup and shared concepts.
- [Cartesian Charts](cartesian.md) for line, bar, and area charts.
- [Distribution Charts](distribution.md) for histograms, box plots, and scatter.
- [Part-to-Whole Charts](part-to-whole.md) for pie, donut, and treemap.
