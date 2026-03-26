## Overview

Build 9 Tier B chart types + 3 Tier 4 modules. Cartesian charts first (most infrastructure reuse), then polar, hierarchical, matrix, then modules in dependency order.

**Spec**: `concept/obers_ui_charts-tier-b-modules.md` (full API designs for all 12 items)

## Context

- **Structure**: Multi-file for complex charts (data, painter, theme, legend, accessibility), single-file for simpler ones (<300 LOC)
- **State management**: `ChangeNotifier`-based `OiChartController`, `ChartBehaviorHost` mixin
- **Reference implementations**: `lib/src/composites/oi_area_chart/` (multi-file cartesian), `lib/src/composites/oi_gauge.dart` (single-file), `lib/src/composites/oi_pie_chart.dart` (polar single-file)
- **Assumptions**: Each chart follows same conventions as v1 (behaviors, controller, OiLabel, theme-derived colors). Modules create new `lib/src/modules/` directory.

## Plan

### Phase 1: Cartesian Tier B — Histogram + Waterfall

- **Goal**: Two new cartesian charts proving the pattern
- [ ] `lib/src/composites/oi_histogram/oi_histogram_data.dart` — `OiHistogramSeries<T>` with valueMapper, binCount, binWidth, binRange. `OiHistogramSeriesData<T>` mapper-first. Bin computation utility.
- [ ] `lib/src/composites/oi_histogram/oi_histogram_painter.dart` — CustomPainter: bins as touching rectangles, optional cumulative line
- [ ] `lib/src/composites/oi_histogram/oi_histogram.dart` — Widget with label, series, xAxis, yAxis, cumulative, normalized, barGap, behaviors, controller. `OiHistogram.fromValues()` shorthand.
- [ ] `lib/src/composites/oi_waterfall_chart/oi_waterfall_data.dart` — `OiWaterfallSeries<T>` with categoryMapper, valueMapper, isTotal
- [ ] `lib/src/composites/oi_waterfall_chart/oi_waterfall_painter.dart` — Floating bars, connector lines, positive/negative/total coloring
- [ ] `lib/src/composites/oi_waterfall_chart/oi_waterfall_chart.dart` — Widget with showConnectors, positiveColor, negativeColor, totalColor
- [ ] Export both from `lib/obers_ui_charts.dart`
- [ ] TDD: Histogram bin computation produces correct count and edges for uniform data
- [ ] TDD: Histogram normalized mode sums to 1.0
- [ ] TDD: Waterfall running total correct after positive + negative values
- [ ] TDD: Waterfall "total" bar resets to baseline
- [ ] Verify: `dart analyze` && `flutter test`

### Phase 2: Cartesian Tier B — BoxPlot + RangeArea + RangeBar

- **Goal**: Three more cartesian charts with statistical/interval focus
- [ ] `lib/src/composites/oi_box_plot_chart/oi_box_plot_data.dart` — `OiBoxPlotSeries<T>` with dual API (raw values OR pre-computed q1/median/q3). `OiWhiskerMode` enum. Quartile computation utility.
- [ ] `lib/src/composites/oi_box_plot_chart/oi_box_plot_painter.dart` — Box + whiskers + outlier dots + optional mean/notch
- [ ] `lib/src/composites/oi_box_plot_chart/oi_box_plot_chart.dart` — Widget
- [ ] `lib/src/composites/oi_range_area_chart.dart` — Single-file. `OiRangeAreaSeries<T>` with yMinMapper, yMaxMapper, midLineMapper. Filled band painter.
- [ ] `lib/src/composites/oi_range_bar_chart.dart` — Single-file. `OiRangeBarSeries<T>` with startMapper, endMapper. Horizontal Gantt-style bars.
- [ ] Export all from barrel
- [ ] TDD: BoxPlot quartile computation from raw values matches expected Q1/Q3
- [ ] TDD: BoxPlot outliers detected beyond 1.5×IQR
- [ ] TDD: RangeArea fills between yMin and yMax correctly
- [ ] TDD: RangeBar horizontal bars span correct start→end range
- [ ] Verify: `dart analyze` && `flutter test`

### Phase 3: Polar Tier B — RadialBar + PolarArea

- **Goal**: Two polar charts extending OiPolarChart base
- [ ] `lib/src/composites/oi_radial_bar_chart.dart` — Single-file. `OiRadialBarSeries<T>` with categoryMapper, valueMapper, maxValue. Concentric arc bars with background track.
- [ ] `lib/src/composites/oi_polar_area_chart.dart` — Single-file. `OiPolarAreaSeries<T>` with categoryMapper, valueMapper. Equal-angle variable-radius wedges.
- [ ] Export from barrel
- [ ] TDD: RadialBar arc sweep angles proportional to value/maxValue
- [ ] TDD: PolarArea wedge radii proportional to values, angles equal
- [ ] Verify: `dart analyze` && `flutter test`

### Phase 4: Hierarchical + Matrix — Sunburst + CalendarHeatmap

- **Goal**: One hierarchical, one matrix chart
- [ ] `lib/src/composites/oi_sunburst_chart/oi_sunburst_chart.dart` — Widget with data, nodeId, parentId, value, nodeLabel, maxDepth, centerContent, onNodeTap. Ring layout painter.
- [ ] `lib/src/composites/oi_sunburst_chart/oi_sunburst_painter.dart` — Concentric rings, arc spans proportional to parent share
- [ ] `lib/src/composites/oi_calendar_heatmap.dart` — Single-file. dateMapper, valueMapper, startDate, endDate, colorScale, weekStartsOn, cellSize, cellSpacing. Grid of week-columns × day-rows.
- [ ] Export from barrel
- [ ] TDD: Sunburst ring depth matches tree depth
- [ ] TDD: CalendarHeatmap cell count matches date range (accounting for partial weeks)
- [ ] TDD: CalendarHeatmap color maps through OiColorScale correctly
- [ ] Verify: `dart analyze` && `flutter test`

### Phase 5: Module — OiKpiBoard

- **Goal**: Simplest module; metric cards with sparklines
- [ ] `lib/src/modules/oi_kpi_board.dart` — Widget with metrics list, columns, cardStyle, showSparklines, showDeltas, showTargets
- [ ] `lib/src/modules/oi_kpi_metric.dart` — `OiKpiMetric` data class (value, previousValue, format, sparklineData, target, status)
- [ ] `lib/src/modules/oi_kpi_format.dart` — `OiKpiFormat` (currency, number, percentage, custom), `OiKpiStatus` enum
- [ ] `lib/src/modules/oi_kpi_card.dart` — Single metric card widget: title, value, delta arrow, sparkline, target progress
- [ ] Export from barrel under `// ── Modules ──` section
- [ ] TDD: OiKpiFormat.currency formats 1234567 as "$1,234,567"
- [ ] TDD: Delta computation: (value - previous) / previous × 100 = percentage change
- [ ] TDD: OiKpiBoard renders correct number of cards for metrics count
- [ ] Verify: `dart analyze` && `flutter test`

### Phase 6: Module — OiAnalyticsDashboard

- **Goal**: Multi-chart dashboard with grid layout + sync
- [ ] `lib/src/modules/oi_analytics_dashboard.dart` — Widget with charts (List<OiDashboardPanel>), syncGroup, columns, rowHeight, spacing, filters
- [ ] `lib/src/modules/oi_dashboard_panel.dart` — `OiDashboardPanel` with id, title, gridPosition, chart widget
- [ ] `lib/src/modules/oi_grid_position.dart` — `OiGridPosition` (row, col, rowSpan, colSpan)
- [ ] `lib/src/modules/oi_dashboard_filter.dart` — `OiDashboardFilter` base + dateRange, dropdown variants
- [ ] Export from barrel
- [ ] TDD: Dashboard renders panels at correct grid positions
- [ ] TDD: Dashboard responsive: 3 columns at 900px, 1 column at 400px
- [ ] TDD: Dashboard syncGroup passed to all child charts
- [ ] Verify: `dart analyze` && `flutter test`

### Phase 7: Module — OiChartExplorer

- **Goal**: Interactive data exploration workspace
- [ ] `lib/src/modules/oi_chart_explorer.dart` — Widget with data, columns, initialChart, xColumn, yColumn, groupBy
- [ ] `lib/src/modules/oi_explorer_column.dart` — `OiExplorerColumn<T>` (id, label, accessor, type), `OiColumnType` enum
- [ ] `lib/src/modules/oi_explorer_controller.dart` — Manages axis assignment, chart type, filters, grouping state
- [ ] `lib/src/modules/oi_explorer_chart_type.dart` — `OiExplorerChartType` enum (line, bar, scatter, pie, heatmap, histogram)
- [ ] Export from barrel
- [ ] TDD: Chart type switch from line to bar re-renders with correct chart widget
- [ ] TDD: GroupBy splits data into multiple series by categorical column
- [ ] TDD: Aggregation sum/avg/count produces correct values
- [ ] Verify: `dart analyze` && `flutter test`

## Risks / Out of scope

- **Risks**:
  - Phase 4 Sunburst drill-in requires state management for current root node — use controller pattern
  - Phase 6 Dashboard grid layout with responsive columns needs careful LayoutBuilder logic
  - Phase 7 Explorer is the most complex — column picker UI may need OiDragTarget from obers_ui
- **Out of scope**:
  - Tier C charts (step line, spline, alluvial, icicle, sparkbar, win/loss)
  - Dashboard panel drag-to-reorder (future enhancement)
  - Explorer data table toggle (future enhancement)
  - Print/export mode
  - Golden tests
