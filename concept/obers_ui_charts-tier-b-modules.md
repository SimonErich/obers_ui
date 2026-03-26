# obers_ui_charts — Tier B Charts + Modules Specification

**Package:** `packages/obers_ui_charts`
**Prerequisite:** V1 complete (18 chart types, foundation layer, 696 tests)
**Scope:** 9 Tier B chart types + 3 Tier 4 modules

---

## Tier B Charts

All Tier B charts MUST follow the same conventions as v1:
- Oi prefix, `{@category Composites}` dartdoc tag
- Accept `behaviors`, `controller`, `label` (required), `semanticLabel`
- Mapper-first series class (`Oi{Chart}SeriesData<T>`) alongside legacy pre-mapped class
- Theme-derived colors (no hardcoded values)
- All text via `OiLabel`, all layouts via obers_ui primitives
- Accessibility: semantic label, keyboard navigable where applicable
- Compact mode support
- Tests: render, empty data, accessibility, interaction

---

### 1. OiHistogram<T>

**Family:** Cartesian (OiCartesianChart base)
**Purpose:** Visualize frequency distributions by grouping continuous data into bins.

**API:**
```dart
OiHistogram<T>(
  label: 'Age Distribution',
  series: [
    OiHistogramSeries<T>(
      id: 'ages',
      label: 'Ages',
      data: people,
      valueMapper: (p) => p.age,
      binCount: 10,           // auto if null
      binWidth: null,          // override binCount
      binRange: null,          // OiAxisRange<double>? explicit min/max
    ),
  ],
  xAxis: OiChartAxis<num>(...),
  yAxis: OiChartAxis<num>(label: 'Frequency'),
  showGrid: true,
  barGap: 0,                  // 0 = touching bars (histogram convention)
  cumulative: false,          // overlay cumulative line
  normalized: false,          // show percentages instead of counts
  behaviors: [...],
  controller: ...,
)
```

**Legacy shorthand:**
```dart
OiHistogram.fromValues(
  label: 'Distribution',
  values: [23, 45, 67, 34, ...],
  binCount: 8,
)
```

**Rendering:**
- Compute bins from data (equal-width or custom edges)
- Draw filled rectangles for each bin (no gap between bars — histogram convention)
- Optional cumulative line overlay
- Tooltip shows bin range + count/percentage
- Auto-label x-axis with bin edges

**Series class:** `OiHistogramSeries<T>` with `valueMapper: num Function(T)`, `binCount`, `binWidth`, `binRange`

**Tests:** Bin computation correctness, empty data, single value, custom bin width, cumulative overlay, normalized mode

---

### 2. OiWaterfallChart<T>

**Family:** Cartesian (OiCartesianChart base)
**Purpose:** Show how individual positive/negative values contribute to a cumulative total.

**API:**
```dart
OiWaterfallChart<T>(
  label: 'Revenue Breakdown',
  series: [
    OiWaterfallSeries<T>(
      id: 'breakdown',
      label: 'Revenue',
      data: items,
      categoryMapper: (item) => item.name,
      valueMapper: (item) => item.amount,
      isTotal: (item) => item.isTotal,  // marks summary bars
    ),
  ],
  showConnectors: true,       // lines connecting bar tops
  positiveColor: null,        // derived from theme.palette.positive
  negativeColor: null,        // derived from theme.palette.negative
  totalColor: null,           // derived from theme.palette.neutral
  behaviors: [...],
  controller: ...,
)
```

**Rendering:**
- Each bar starts where the previous bar ended (floating bars)
- Positive values go up, negative go down
- "Total" bars start at zero and show cumulative sum
- Connector lines between bars show the running total
- Color: green for positive, red for negative, blue/grey for totals

**Series class:** `OiWaterfallSeries<T>` with `categoryMapper`, `valueMapper`, `isTotal`

**Tests:** Positive/negative stacking, total bars reset to baseline, connectors render, mixed positive/negative sequence

---

### 3. OiBoxPlotChart<T>

**Family:** Cartesian (OiCartesianChart base)
**Purpose:** Statistical distribution summary showing quartiles, median, whiskers, and outliers.

**API:**
```dart
OiBoxPlotChart<T>(
  label: 'Salary Distribution',
  series: [
    OiBoxPlotSeries<T>(
      id: 'salaries',
      label: 'Salaries by Department',
      data: departments,
      categoryMapper: (d) => d.name,
      valuesMapper: (d) => d.salaries,  // List<num> per category
      // OR pre-computed:
      minMapper: (d) => d.min,
      q1Mapper: (d) => d.q1,
      medianMapper: (d) => d.median,
      q3Mapper: (d) => d.q3,
      maxMapper: (d) => d.max,
      outliersMapper: (d) => d.outliers,
    ),
  ],
  showMean: false,            // dot for mean value
  showNotch: false,           // confidence interval notch
  whiskerMode: OiWhiskerMode.minMax,  // minMax / iqr1_5 / percentile
  horizontal: false,
  behaviors: [...],
  controller: ...,
)
```

**Enums:**
```dart
enum OiWhiskerMode { minMax, iqr1_5, percentile5_95 }
```

**Rendering:**
- Box from Q1 to Q3 with median line
- Whiskers from box to min/max (or IQR × 1.5)
- Outlier dots beyond whiskers
- Optional mean dot
- Optional notch at median for confidence

**Series class:** `OiBoxPlotSeries<T>` with dual API (raw values OR pre-computed stats)

**Tests:** Quartile computation from raw values, pre-computed stats render correctly, outlier detection, horizontal mode, empty category

---

### 4. OiRangeAreaChart<T>

**Family:** Cartesian (OiCartesianChart base)
**Purpose:** Visualize ranges, confidence bands, min-max envelopes over an ordered domain.

**API:**
```dart
OiRangeAreaChart<T>(
  label: 'Temperature Range',
  series: [
    OiRangeAreaSeries<T>(
      id: 'temp',
      label: 'Temperature',
      data: readings,
      xMapper: (r) => r.date,
      yMinMapper: (r) => r.low,
      yMaxMapper: (r) => r.high,
      midLineMapper: (r) => r.avg,  // optional center line
    ),
  ],
  showMidLine: true,
  fillOpacity: 0.2,
  behaviors: [...],
  controller: ...,
)
```

**Rendering:**
- Filled area between yMin and yMax
- Optional mid-line (average/median) drawn as a line stroke
- Tooltip shows min, max, and mid values at hovered x position

**Series class:** `OiRangeAreaSeries<T>` with `yMinMapper`, `yMaxMapper`, `midLineMapper`

**Tests:** Range area fills between min/max, mid-line renders on top, single point, empty data

---

### 5. OiRangeBarChart<T>

**Family:** Cartesian (OiCartesianChart base)
**Purpose:** Visualize intervals, schedules, time spans, or min-max ranges per category.

**API:**
```dart
OiRangeBarChart<T>(
  label: 'Project Timeline',
  series: [
    OiRangeBarSeries<T>(
      id: 'projects',
      label: 'Projects',
      data: projects,
      categoryMapper: (p) => p.name,
      startMapper: (p) => p.startDate,
      endMapper: (p) => p.endDate,
    ),
  ],
  horizontal: true,           // Gantt-style horizontal
  behaviors: [...],
  controller: ...,
)
```

**Rendering:**
- Each bar spans from start to end value
- Horizontal mode for timeline/Gantt-like visualization
- Color per series or per bar via mapper

**Series class:** `OiRangeBarSeries<T>` with `categoryMapper`, `startMapper`, `endMapper`

**Tests:** Horizontal bars span correct range, vertical mode, overlapping ranges, empty data

---

### 6. OiRadialBarChart<T>

**Family:** Polar (OiPolarChart base)
**Purpose:** Circular bar comparison — bars extend outward from center.

**API:**
```dart
OiRadialBarChart<T>(
  label: 'Progress',
  series: [
    OiRadialBarSeries<T>(
      id: 'progress',
      label: 'Goals',
      data: goals,
      categoryMapper: (g) => g.name,
      valueMapper: (g) => g.progress,
      maxValue: 100,
    ),
  ],
  startAngle: -90,            // 12 o'clock
  innerRadius: 0.3,           // fraction of total radius
  barSpacing: 4,              // gap between bars in px
  showLabels: true,
  behaviors: [...],
  controller: ...,
)
```

**Rendering:**
- Concentric arc bars, one per category
- Each bar's sweep angle proportional to value/maxValue
- Labels at bar ends or in center
- Background track showing full range

**Series class:** `OiRadialBarSeries<T>` with `categoryMapper`, `valueMapper`, `maxValue`

**Tests:** Arc angles correct, inner radius respected, bar spacing, empty data, single bar

---

### 7. OiPolarAreaChart<T>

**Family:** Polar (OiPolarChart base)
**Purpose:** Radial segments where area (not just angle) encodes magnitude — like a radar chart with filled wedges of varying radius.

**API:**
```dart
OiPolarAreaChart<T>(
  label: 'Skills',
  series: [
    OiPolarAreaSeries<T>(
      id: 'skills',
      label: 'Skill Levels',
      data: skills,
      categoryMapper: (s) => s.name,
      valueMapper: (s) => s.level,
    ),
  ],
  startAngle: -90,
  showLabels: true,
  behaviors: [...],
  controller: ...,
)
```

**Rendering:**
- Equal-angle wedges, radius varies by value
- Like pie chart but with variable radius per slice
- Fill with series color at opacity, stroke outline

**Series class:** `OiPolarAreaSeries<T>` with `categoryMapper`, `valueMapper`

**Tests:** Wedge angles equal, radii proportional to values, labels render, empty data

---

### 8. OiSunburstChart<TNode>

**Family:** Hierarchical (OiHierarchicalChart base)
**Purpose:** Radial hierarchy visualization — like treemap but in concentric rings.

**API:**
```dart
OiSunburstChart<TNode>(
  label: 'File System',
  data: nodes,
  nodeId: (n) => n.id,
  parentId: (n) => n.parentId,
  value: (n) => n.size,
  nodeLabel: (n) => n.name,
  maxDepth: null,             // limit visible depth
  centerContent: Text('Root'),
  onNodeTap: (node) { ... },
  behaviors: [...],
  controller: ...,
)
```

**Rendering:**
- Center = root node
- Each ring = one depth level
- Arc span proportional to node's share of parent
- Click to drill into a subtree (re-root)
- Breadcrumb trail for navigation back

**Tests:** Ring depth correct, arc spans proportional, drill-in/out, single node, deep hierarchy

---

### 9. OiCalendarHeatmap<T>

**Family:** Matrix (OiMatrixChart base)
**Purpose:** GitHub-style contribution/activity grid by date.

**API:**
```dart
OiCalendarHeatmap<T>(
  label: 'Activity',
  data: activities,
  dateMapper: (a) => a.date,
  valueMapper: (a) => a.count,
  startDate: DateTime(2025, 1, 1),
  endDate: DateTime(2025, 12, 31),
  colorScale: OiColorScale.linear(
    minColor: Color(0xFFebedf0),
    maxColor: Color(0xFF216e39),
    min: 0,
    max: 10,
  ),
  weekStartsOn: DateTime.monday,
  showMonthLabels: true,
  showDayLabels: true,        // Mon/Wed/Fri
  cellSize: 12,
  cellSpacing: 2,
  behaviors: [...],
  controller: ...,
)
```

**Rendering:**
- Grid of cells: columns = weeks, rows = days of week
- Cell color from OiColorScale based on value
- Month labels above columns
- Day-of-week labels on left
- Tooltip on hover showing date + value

**Series class:** Not series-based — uses `data` + `dateMapper` + `valueMapper` directly

**Tests:** Cell count matches date range, color mapping correct, empty dates show base color, leap year handling, week start day respected

---

## Tier 4 Modules

Modules are assembled experiences combining multiple charts with shared infrastructure. They live in `lib/src/modules/` (new directory).

---

### 10. OiAnalyticsDashboard

**Purpose:** Multi-chart dashboard layout with synchronized filtering, responsive grid, and shared state.

**API:**
```dart
OiAnalyticsDashboard(
  label: 'Sales Analytics',
  charts: [
    OiDashboardPanel(
      id: 'revenue',
      title: 'Revenue Over Time',
      gridPosition: OiGridPosition(row: 0, col: 0, rowSpan: 1, colSpan: 2),
      chart: OiLineChart(...),
    ),
    OiDashboardPanel(
      id: 'breakdown',
      title: 'Revenue by Category',
      gridPosition: OiGridPosition(row: 0, col: 2, rowSpan: 1, colSpan: 1),
      chart: OiPieChart(...),
    ),
    OiDashboardPanel(
      id: 'trend',
      title: 'Monthly Trend',
      gridPosition: OiGridPosition(row: 1, col: 0, rowSpan: 1, colSpan: 3),
      chart: OiBarChart(...),
    ),
  ],
  syncGroup: 'sales-dashboard',  // all charts sync hover/selection
  columns: 3,
  rowHeight: 250,
  spacing: 16,
  filters: [
    OiDashboardFilter.dateRange(...),
    OiDashboardFilter.dropdown(...),
  ],
  settings: OiChartSettingsDriverBinding(...),  // persist layout + filters
  onFilterChange: (filters) { ... },
)
```

**Supporting classes:**
- `OiDashboardPanel` — wraps a chart with title, grid position, optional toolbar
- `OiGridPosition` — row, col, rowSpan, colSpan
- `OiDashboardFilter` — date range, dropdown, search filters
- `OiDashboardController` — manages filter state, panel visibility, layout mode

**Features:**
- Responsive grid layout (columns adapt to breakpoints)
- Synchronized hover/crosshair across all charts via syncGroup
- Panel drag-to-reorder (optional)
- Panel collapse/expand
- Filter bar with date range, dropdowns
- Persistence of layout, filters, hidden panels
- Print/export mode (simplified rendering)

**Tests:** Grid layout positions panels correctly, sync group coordinates hover, filter changes propagate, responsive column count, empty dashboard, panel collapse

---

### 11. OiChartExplorer

**Purpose:** Interactive data exploration workspace — drill down, filter, pivot, compare datasets.

**API:**
```dart
OiChartExplorer<T>(
  label: 'Data Explorer',
  data: records,
  columns: [
    OiExplorerColumn<T>(id: 'date', label: 'Date', accessor: (r) => r.date, type: OiColumnType.date),
    OiExplorerColumn<T>(id: 'revenue', label: 'Revenue', accessor: (r) => r.revenue, type: OiColumnType.numeric),
    OiExplorerColumn<T>(id: 'category', label: 'Category', accessor: (r) => r.category, type: OiColumnType.categorical),
    OiExplorerColumn<T>(id: 'region', label: 'Region', accessor: (r) => r.region, type: OiColumnType.categorical),
  ],
  initialChart: OiExplorerChartType.line,
  xColumn: 'date',
  yColumn: 'revenue',
  groupBy: 'category',
  behaviors: [...],
  controller: ...,
)
```

**Supporting classes:**
- `OiExplorerColumn<T>` — column definition with accessor, type, label
- `OiExplorerChartType` — enum: line, bar, scatter, pie, heatmap, histogram
- `OiExplorerController` — manages axis assignment, chart type, filters, grouping

**Features:**
- Column picker: drag columns to x-axis, y-axis, group-by, filter slots
- Chart type switcher (line/bar/scatter/pie/heatmap/histogram)
- Auto-infer chart type from column types
- Filter panel: range sliders for numeric, checkboxes for categorical
- Group-by: split series by categorical column
- Aggregation: sum, avg, count, min, max per group
- Data table toggle (show underlying data alongside chart)
- Brush selection on chart filters the data table

**Tests:** Chart type switching renders correctly, column assignment updates chart, filter narrows data, group-by creates series, aggregation computes correctly, empty data

---

### 12. OiKpiBoard

**Purpose:** Single-value metric display with sparklines, delta indicators, and trend context.

**API:**
```dart
OiKpiBoard(
  label: 'Key Metrics',
  metrics: [
    OiKpiMetric(
      id: 'revenue',
      title: 'Total Revenue',
      value: 1_234_567,
      previousValue: 1_100_000,  // for delta calculation
      format: OiKpiFormat.currency(symbol: '\$'),
      sparklineData: monthlySeries,
      target: 1_500_000,
      status: OiKpiStatus.onTrack,
    ),
    OiKpiMetric(
      id: 'users',
      title: 'Active Users',
      value: 45_231,
      previousValue: 42_100,
      format: OiKpiFormat.number(decimals: 0),
      sparklineData: userSeries,
    ),
    OiKpiMetric(
      id: 'conversion',
      title: 'Conversion Rate',
      value: 0.0342,
      previousValue: 0.0298,
      format: OiKpiFormat.percentage(decimals: 1),
      sparklineData: conversionSeries,
      target: 0.04,
      status: OiKpiStatus.needsAttention,
    ),
  ],
  columns: 3,                   // responsive grid
  cardStyle: OiKpiCardStyle.standard,  // standard / compact / detailed
  showSparklines: true,
  showDeltas: true,
  showTargets: true,
  settings: OiChartSettingsDriverBinding(...),
)
```

**Supporting classes:**
- `OiKpiMetric` — single metric with value, previous, format, sparkline, target, status
- `OiKpiFormat` — currency, number, percentage, duration, custom
- `OiKpiStatus` — enum: onTrack, needsAttention, critical, neutral
- `OiKpiCardStyle` — enum: standard, compact, detailed

**Features:**
- Card grid layout (responsive columns)
- Each card shows: title, primary value, delta (↑↓), sparkline, target progress
- Delta shows absolute and percentage change from previous
- Color coding: green (positive), red (negative), configurable per metric
- Sparkline uses OiSparkline internally
- Target progress bar or gauge
- Compact mode: just value + delta (for dense dashboards)
- Detailed mode: adds trend description, min/max/avg from sparkline data

**Tests:** Card renders all parts, delta computes correctly, format produces correct strings, responsive columns, empty metrics, sparkline integration, status colors

---

## Implementation Order

1. **Cartesian Tier B first** (Histogram, Waterfall, BoxPlot, RangeArea, RangeBar) — most overlap with existing cartesian infrastructure
2. **Polar Tier B** (RadialBar, PolarArea) — builds on OiPolarChart base
3. **Hierarchical + Matrix** (Sunburst, CalendarHeatmap) — extend existing bases
4. **OiKpiBoard** — simplest module, uses OiSparkline internally
5. **OiAnalyticsDashboard** — medium complexity, needs grid layout + sync
6. **OiChartExplorer** — most complex, needs column picker + chart type switching

---

## Shared Infrastructure Needed

Before building Tier B charts:
- **OiChartGrid responsive layout** — shared grid component for dashboards
- **OiDashboardFilter** — reusable filter widgets (date range, dropdown)
- **OiKpiFormat** — number/currency/percentage formatting utilities

These can be built as part of the first module (OiKpiBoard) and reused.

---

## Test Requirements

Each chart/module needs:
- Basic render test (data → widget without errors)
- Empty data test (shows empty state)
- Accessibility test (semantic label, keyboard navigation)
- Interaction test (tap, hover where applicable)
- Edge case tests (single data point, extreme values, zero values)
- Snapshot consistency (widget tree structure, not golden images)
- Module-specific: integration test with child charts
