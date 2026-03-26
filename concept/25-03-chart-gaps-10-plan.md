## Overview

Complete remaining 7 Tier B/module items: Phase 2 tests, RadialBar, PolarArea, Sunburst, CalendarHeatmap, KpiBoard, AnalyticsDashboard, ChartExplorer.

**Gap analysis**: `concept/25-03-chart-gaps-10.md`
**Spec**: `concept/obers_ui_charts-tier-b-modules.md`

## Context

- **Reference**: `lib/src/composites/oi_histogram/` (multi-file Tier B), `lib/src/composites/oi_gauge.dart` (single-file polar), `lib/src/composites/oi_sparkline.dart` (compact chart for module reuse)
- **Assumptions**: Modules go in new `lib/src/modules/` directory. OiKpiBoard reuses OiSparkline internally.

## Plan

### Phase 1: Phase 2 Tests + Polar Tier B

- **Goal**: Fill Phase 2 test gap; add 2 polar charts
- [x] `test/src/composites/oi_box_plot_chart_test.dart` — computeBoxPlotStats correctness, outlier detection, widget render, horizontal mode
- [x] `test/src/composites/oi_range_area_chart_test.dart` — Range fill renders, mid-line shows, empty data
- [x] `test/src/composites/oi_range_bar_chart_test.dart` — Horizontal bars span, empty data
- [x] `lib/src/composites/oi_radial_bar_chart.dart` — Single-file. OiRadialBarSeries<T> with categoryMapper, valueMapper, maxValue. Concentric arc bars with background track. startAngle, innerRadius, barSpacing params.
- [x] `lib/src/composites/oi_polar_area_chart.dart` — Single-file. OiPolarAreaSeries<T> with categoryMapper, valueMapper. Equal-angle wedges, radius by value.
- [x] Export from barrel
- [x] TDD: RadialBar arc sweep = (value/maxValue) × full sweep
- [x] TDD: PolarArea all wedge angles equal, radii proportional
- [x] Verify: `dart analyze` && `flutter test`

### Phase 2: Sunburst + CalendarHeatmap

- **Goal**: Complete all 9 Tier B charts
- [x] `lib/src/composites/oi_sunburst_chart/oi_sunburst_chart.dart` — Widget with data, nodeId, parentId, value, nodeLabel, maxDepth, centerContent, onNodeTap, behaviors, controller
- [x] `lib/src/composites/oi_sunburst_chart/oi_sunburst_painter.dart` — Concentric ring layout, arc spans proportional to parent share
- [x] `lib/src/composites/oi_calendar_heatmap.dart` — Single-file with dateMapper, valueMapper, startDate, endDate, colorScale, weekStartsOn, cellSize, cellSpacing, behaviors, controller
- [x] Export from barrel
- [x] TDD: Sunburst ring depth matches tree hierarchy depth
- [x] TDD: CalendarHeatmap cell count matches date range accounting for partial weeks
- [x] TDD: CalendarHeatmap color resolves through OiColorScale
- [x] Verify: `dart analyze` && `flutter test`

### Phase 3: OiKpiBoard Module

- **Goal**: First module; metric cards with sparklines
- [x] Create `lib/src/modules/` directory
- [x] `lib/src/modules/oi_kpi_format.dart` — OiKpiFormat (currency/number/percentage/custom), OiKpiStatus enum (onTrack/needsAttention/critical/neutral), OiKpiCardStyle enum
- [x] `lib/src/modules/oi_kpi_metric.dart` — OiKpiMetric data class with value, previousValue, format, sparklineData, target, status
- [x] `lib/src/modules/oi_kpi_card.dart` — Single metric card: title (OiLabel), value (OiLabel.heading), delta arrow + percentage, embedded OiSparkline, optional target bar
- [x] `lib/src/modules/oi_kpi_board.dart` — Widget with metrics list, columns, cardStyle, showSparklines, showDeltas, showTargets. Responsive grid via LayoutBuilder.
- [x] Export from barrel under `// ── Modules ──`
- [x] TDD: OiKpiFormat.currency formats 1234567 → "$1,234,567"
- [x] TDD: OiKpiFormat.percentage formats 0.0342 → "3.4%"
- [x] TDD: Delta = (value - previous) / previous × 100
- [x] TDD: OiKpiBoard renders correct card count
- [x] Verify: `dart analyze` && `flutter test`

### Phase 4: OiAnalyticsDashboard Module

- **Goal**: Multi-chart grid with sync
- [x] `lib/src/modules/oi_dashboard_panel.dart` — OiDashboardPanel (id, title, gridPosition, chart)
- [x] `lib/src/modules/oi_grid_position.dart` — OiGridPosition (row, col, rowSpan, colSpan)
- [x] `lib/src/modules/oi_dashboard_filter.dart` — OiDashboardFilter base + dateRange/dropdown
- [x] `lib/src/modules/oi_analytics_dashboard.dart` — Widget with panels, syncGroup, columns, rowHeight, spacing, filters. Responsive grid. Panels wrapped in OiChartSyncProvider.
- [x] Export from barrel
- [x] TDD: Dashboard renders correct panel count
- [x] TDD: Dashboard responsive: 3 cols at 900px, 1 col at 400px
- [x] Verify: `dart analyze` && `flutter test`

### Phase 5: OiChartExplorer Module

- **Goal**: Interactive data exploration
- [x] `lib/src/modules/oi_explorer_column.dart` — OiExplorerColumn<T> (id, label, accessor, type), OiColumnType enum (numeric/categorical/date)
- [x] `lib/src/modules/oi_explorer_chart_type.dart` — OiExplorerChartType enum (line/bar/scatter/pie/heatmap/histogram)
- [x] `lib/src/modules/oi_explorer_controller.dart` — Manages xColumn, yColumn, groupBy, chartType, filters, aggregation
- [x] `lib/src/modules/oi_chart_explorer.dart` — Widget with data, columns, initialChart, controller. Column picker + chart area + filter panel.
- [x] Export from barrel
- [x] TDD: Chart type switch renders different chart widget
- [x] TDD: GroupBy creates multiple series from categorical column
- [x] Verify: `dart analyze` && `flutter test`

## Risks / Out of scope

- **Risks**:
  - Sunburst drill-in needs careful state for current root node
  - Dashboard responsive grid with colSpan/rowSpan is complex layout logic
  - Explorer column picker UI may need drag-and-drop from obers_ui
- **Out of scope**:
  - Tier C charts (step line, spline, alluvial, icicle)
  - Dashboard panel drag-to-reorder
  - Explorer data table toggle
  - Print/export mode
