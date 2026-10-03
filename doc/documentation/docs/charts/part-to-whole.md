# Pie, Donut & Hierarchy Charts

These charts show how parts add up to a whole, and how data nests inside data.
Reach for them when the story is a share, a split, or a tree, not a trend over
time. Charts live in a separate package, so import it in every file that uses
one:

```dart
import 'package:obers_ui_charts/obers_ui_charts.dart';
```

Every chart takes a `label` for screen readers. It is required, so pass a short
description of what the chart shows.

| Widget | What it does |
| --- | --- |
| `OiPieChart` | A pie of proportional segments, with an optional donut hole. |
| `OiDonutChart` | A pie with a hollow center for a summary value. |
| `OiFunnelChart` | Stacked stages that narrow, for conversion flows. |
| `OiRadialBarChart` | Concentric arc rings, one per value, on a shared scale. |
| `OiTreemap` | Nested rectangles sized by value. |
| `OiSunburstChart` | Concentric rings that drill into a tree by depth. |
| `OiHierarchicalChart` | The base tree builder behind treemap and sunburst. |

## OiPieChart

The chart you reach for first. It splits a circle into segments sized by value.
You build segments with `OiPieSegment`, which needs a `label` and a `value`.

```dart
OiPieChart(
  label: 'Traffic by source',
  segments: const [
    OiPieSegment(label: 'Direct', value: 45),
    OiPieSegment(label: 'Search', value: 30),
    OiPieSegment(label: 'Social', value: 25),
  ],
)
```

Set `donut: true` for a hollow center, or use `OiDonutChart` for a typed donut
API. Colors come from the theme chart palette unless you pass a `color` on a
segment.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label for the chart. |
| `segments` | `List<OiPieSegment>` | **required** | The slices. Each has `label`, `value`, optional `color`. |
| `donut` | `bool` | `false` | Render with a hollow center. |
| `donutWidth` | `double` | `0.4` | Ring width as a ratio of the radius when `donut` is on. |
| `centerLabel` | `String?` | `null` | Text shown in the donut center. |
| `showLabels` | `bool` | `true` | Draw segment labels on the chart. |
| `showPercentages` | `bool` | `true` | Draw each segment's percentage. |
| `showValues` | `bool` | `false` | Draw each segment's raw value. |
| `showLegend` | `bool` | `true` | Show a legend below the chart. |
| `onSegmentTap` | `ValueChanged<int>?` | `null` | Fires with the tapped segment index. |

## OiDonutChart

A donut is a pie with a hole in the middle. Use the hole for a total or a
headline number with `centerLabel`. It takes the same `OiPieSegment` list as
`OiPieChart`.

```dart
OiDonutChart(
  label: 'Budget split',
  centerLabel: '\$12k',
  segments: const [
    OiPieSegment(label: 'Rent', value: 40),
    OiPieSegment(label: 'Food', value: 25),
    OiPieSegment(label: 'Travel', value: 20),
    OiPieSegment(label: 'Other', value: 15),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label for the chart. |
| `segments` | `List<OiPieSegment>` | **required** | The slices. Each has `label`, `value`, optional `color`. |
| `innerRadiusFraction` | `double` | `0.4` | Inner radius as a fraction of the outer radius. Higher is thinner. |
| `centerLabel` | `String?` | `null` | Text shown in the hollow center. |
| `showLabels` | `bool` | `true` | Draw segment labels on the chart. |
| `showPercentages` | `bool` | `true` | Draw each segment's percentage. |
| `showValues` | `bool` | `false` | Draw each segment's raw value. |
| `showLegend` | `bool` | `true` | Show a legend below the chart. |
| `onSegmentTap` | `void Function(int)?` | `null` | Fires with the tapped segment index. |
| `semanticLabel` | `String?` | `null` | Overrides `label` for screen readers. |

## OiFunnelChart

A funnel shows how a count drops across ordered stages, like a signup flow. You
build stages with `OiFunnelStage`, from widest at the top to narrowest at the
bottom. Each stage shows its percentage relative to the first stage.

```dart
OiFunnelChart(
  label: 'Signup funnel',
  stages: const [
    OiFunnelStage(label: 'Visited', value: 1000),
    OiFunnelStage(label: 'Signed up', value: 420),
    OiFunnelStage(label: 'Activated', value: 180),
    OiFunnelStage(label: 'Paid', value: 60),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label for the chart. |
| `stages` | `List<OiFunnelStage>` | **required** | Ordered stages. Each has `label`, `value`, optional `color`. |
| `showValues` | `bool` | `true` | Show the raw value on each stage. |
| `showPercentages` | `bool` | `true` | Show the percentage of the first stage. |
| `formatValue` | `String Function(double)?` | `null` | Custom formatter for stage values. |
| `onStageTap` | `ValueChanged<int>?` | `null` | Fires with the tapped stage index. |

## OiRadialBarChart

A radial bar chart draws each value as an arc ring on a shared 0 to `maxValue`
scale. It reads well for progress-style metrics side by side. This chart is
mapper-first: you pass one `OiRadialBarSeries` and tell it how to read a label
and a value from each item. The simplest item type is a plain record.

```dart
OiRadialBarChart<({String name, double score})>(
  label: 'Team scores',
  series: [
    OiRadialBarSeries(
      id: 'scores',
      label: 'Scores',
      data: const [
        (name: 'Design', score: 82),
        (name: 'Engineering', score: 64),
        (name: 'Sales', score: 91),
      ],
      categoryMapper: (item) => item.name,
      valueMapper: (item) => item.score,
    ),
  ],
)
```

Only the first visible series is drawn. Each item in its `data` becomes one ring.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label for the chart. |
| `series` | `List<OiRadialBarSeries<T>>` | **required** | Ring data. Only the first visible series renders. |
| `startAngle` | `double` | `-90` | Start angle in degrees. `-90` starts at the top. |
| `innerRadius` | `double` | `0.3` | Hollow center as a fraction of the radius. |
| `barSpacing` | `double` | `4` | Gap in pixels between rings. |
| `showLabels` | `bool` | `true` | Draw a label beside each ring. |
| `showBackground` | `bool` | `true` | Draw a full-circle track behind each ring. |
| `compact` | `bool?` | `null` | Force compact layout. When null, derived from width. |
| `semanticLabel` | `String?` | `null` | Overrides `label` for screen readers. |

Each `OiRadialBarSeries` needs an `id`, a `label`, the `data` list, a
`categoryMapper`, and a `valueMapper`. Set `maxValue` (default `100`) to fix the
scale, and `color` to override the palette.

## OiTreemap

A treemap fills a rectangle with smaller rectangles sized by value. It is good
for showing where space or spend goes at a glance. You build nodes with
`OiTreemapNode`, which needs a `key`, a `label`, and a `value`.

```dart
OiTreemap(
  label: 'Storage by folder',
  nodes: const [
    OiTreemapNode(key: 'photos', label: 'Photos', value: 520),
    OiTreemapNode(key: 'video', label: 'Video', value: 310),
    OiTreemapNode(key: 'docs', label: 'Documents', value: 140),
    OiTreemapNode(key: 'apps', label: 'Apps', value: 90),
  ],
)
```

Nodes take an optional `children` list for nested data. The default layout draws
the top-level nodes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label for the treemap. |
| `nodes` | `List<OiTreemapNode>` | **required** | Top-level nodes. Each has `key`, `label`, `value`, optional `color` and `children`. |
| `showLabels` | `bool` | `true` | Draw a label inside each rectangle. |
| `showValues` | `bool` | `false` | Draw the value inside each rectangle. |
| `onNodeTap` | `ValueChanged<OiTreemapNode>?` | `null` | Fires with the tapped node. |

## OiSunburstChart

A sunburst draws a tree as concentric rings. The center is the root, the first
ring is depth 1, and so on. It is mapper-first over a flat list: give it every
node with an id and a parent id, and it builds the tree for you. Root nodes are
the items whose `parentId` returns `null`.

```dart
OiSunburstChart<({String id, String? parent, String name, num size})>(
  label: 'Files by folder',
  data: const [
    (id: 'root', parent: null, name: 'Project', size: 0),
    (id: 'src', parent: 'root', name: 'src', size: 0),
    (id: 'lib', parent: 'root', name: 'lib', size: 0),
    (id: 'main', parent: 'src', name: 'main.dart', size: 40),
    (id: 'utils', parent: 'src', name: 'utils.dart', size: 25),
    (id: 'api', parent: 'lib', name: 'api.dart', size: 60),
  ],
  nodeId: (item) => item.id,
  parentId: (item) => item.parent,
  value: (item) => item.size,
  nodeLabel: (item) => item.name,
)
```

Branch values are summed from their children, so `value` only matters on leaf
nodes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label for the chart. |
| `data` | `List<TNode>` | **required** | Flat list of nodes, including the root. |
| `nodeId` | `String Function(TNode)` | **required** | Reads the unique id of a node. |
| `parentId` | `String? Function(TNode)` | **required** | Reads the parent id. Return `null` for a root. |
| `value` | `num Function(TNode)` | **required** | Reads a leaf node's value. |
| `nodeLabel` | `String Function(TNode)` | **required** | Reads a node's display label. |
| `maxDepth` | `int?` | `null` | Limit the number of rings drawn. |
| `centerContent` | `Widget?` | `null` | Widget shown in the center circle. |
| `onNodeTap` | `void Function(TNode)?` | `null` | Fires with the tapped item. |
| `compact` | `bool?` | `null` | Suppress arc labels. When null, derived from width. |
| `semanticLabel` | `String?` | `null` | Overrides `label` for screen readers. |

## OiHierarchicalChart

This is the base widget that treemap and sunburst are built on. It takes a flat
list, builds a tree with an `OiHierarchicalSeries`, and hands the computed roots
to your `seriesBuilder` to draw. Reach for it when you want a custom tree
rendering. For the common cases, use `OiTreemap` or `OiSunburstChart` instead.

```dart
OiHierarchicalChart<({String id, String? parent, String name, num size})>(
  label: 'Org tree',
  series: OiHierarchicalSeries(
    id: 'org',
    label: 'Org',
    data: const [
      (id: 'ceo', parent: null, name: 'CEO', size: 0),
      (id: 'eng', parent: 'ceo', name: 'Engineering', size: 12),
      (id: 'ops', parent: 'ceo', name: 'Operations', size: 8),
    ],
    nodeIdMapper: (item) => item.id,
    parentIdMapper: (item) => item.parent,
    valueMapper: (item) => item.size,
    nodeLabelMapper: (item) => item.name,
  ),
  seriesBuilder: (context, viewport, roots) => OiColumn(
    children: [
      for (final root in roots) OiLabel.body(root.label),
    ],
  ),
)
```

Without a `seriesBuilder`, the chart builds the tree but draws nothing, so pass
one.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label for the chart. |
| `series` | `OiHierarchicalSeries<TNode>` | **required** | The data and its id, parent, value, and label mappers. |
| `seriesBuilder` | `Widget Function(...)?` | `null` | Renders the computed roots. Return your tree drawing. |
| `emptyState` | `Widget?` | `null` | Shown when there is no data. |
| `loadingState` | `Widget?` | `null` | Shown while the controller reports loading. |
| `errorState` | `Widget?` | `null` | Shown when the controller reports an error. |
| `semanticLabel` | `String?` | `null` | Overrides `label` for screen readers. |

!!! note
    `OiHierarchicalSeries` needs an `id`, a `label`, the `data` list, and four
    mappers: `nodeIdMapper`, `parentIdMapper`, `valueMapper`, and
    `nodeLabelMapper`. Roots are items whose `parentIdMapper` returns `null`.

## Related

- [Charts overview](index.md) for setup and the full chart list.
- [Cartesian charts](cartesian.md) for line, bar, and area charts.
- [Distribution charts](distribution.md) for histograms, box plots, and heatmaps.
- [Specialized charts](specialized.md) for gauges, flow, and calendar charts.

`OiDonutChart` and `OiPieChart` accept a rich `center` widget in addition to
`centerLabel`. A supplied `legend` can reuse `OiChartLegend`; `legendPosition`
and `legendWidth` control side placement within bounded chart cards.
`OiChartLegendItem.value` supplies a formatted count/value beside a legend label.

`OiDonutChart.innerRadiusFraction` is the hollow radius divided by the outer radius: `.76` leaves a 76% hollow center and a 24% ring. `OiPieChart.donutWidth` instead expresses the ring width. The convenience wrapper converts between these contracts.
