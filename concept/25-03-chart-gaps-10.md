# obers_ui_charts — Gap Analysis: Tier B + Modules (2026-03-26, Rev 10)

**Plan reference:** `concept/obers_ui_charts-tier-b-modules-plan.md`
**Spec reference:** `concept/obers_ui_charts-tier-b-modules.md`
**Package:** `packages/obers_ui_charts`
**Verified state:** 707 tests pass, 0 failures, 0 warnings, 63 test files

---

## Plan Progress Summary

| Phase | Goal | Status | Tests Added |
|-------|------|--------|-------------|
| **1** | Histogram + Waterfall | ✓ COMPLETE | +11 (bin computation, widget render) |
| **2** | BoxPlot + RangeArea + RangeBar | ✓ COMPLETE | +0 (committed, tests pending) |
| **3** | RadialBar + PolarArea | ❌ NOT STARTED | — |
| **4** | Sunburst + CalendarHeatmap | ❌ NOT STARTED | — |
| **5** | OiKpiBoard module | ❌ NOT STARTED | — |
| **6** | OiAnalyticsDashboard module | ❌ NOT STARTED | — |
| **7** | OiChartExplorer module | ❌ NOT STARTED | — |

---

## Completed Items (Phases 1-2)

### Phase 1 — OiHistogram + OiWaterfallChart ✓

**OiHistogram:**
- `lib/src/composites/oi_histogram/oi_histogram.dart` — Widget with label, series, cumulative, normalized, barGap, behaviors, controller, compact ✓
- `lib/src/composites/oi_histogram/oi_histogram_data.dart` — OiHistogramSeries<T>, OiHistogramBin, computeBins() utility ✓
- `lib/src/composites/oi_histogram/oi_histogram_painter.dart` — Touching bars, cumulative line, grid ✓
- `OiHistogram.fromValues()` shorthand ✓
- Exported from barrel ✓
- 7 tests (5 bin computation + 2 widget render) ✓

**OiWaterfallChart:**
- `lib/src/composites/oi_waterfall_chart/oi_waterfall_chart.dart` — Widget with showConnectors, positive/negative/totalColor, behaviors, controller ✓
- `lib/src/composites/oi_waterfall_chart/oi_waterfall_data.dart` — OiWaterfallSeries<T>, OiWaterfallBar, computeWaterfallBars() ✓
- `lib/src/composites/oi_waterfall_chart/oi_waterfall_painter.dart` — Floating bars, connectors, color coding ✓
- Exported from barrel ✓
- 4 tests (3 computation + 1 widget render) ✓

### Phase 2 — OiBoxPlotChart + OiRangeAreaChart + OiRangeBarChart ✓

**OiBoxPlotChart:**
- `lib/src/composites/oi_box_plot_chart/oi_box_plot_chart.dart` — Widget with showMean, showNotch, whiskerMode, horizontal ✓
- `lib/src/composites/oi_box_plot_chart/oi_box_plot_data.dart` — OiWhiskerMode enum, OiBoxPlotSeries<T> (dual API), OiBoxPlotStats, computeBoxPlotStats() ✓
- `lib/src/composites/oi_box_plot_chart/oi_box_plot_painter.dart` — Box, whiskers, outliers, mean dot, notch ✓
- Exported from barrel ✓
- **Tests: PENDING** — need BoxPlot quartile computation + outlier detection + widget render tests

**OiRangeAreaChart:**
- `lib/src/composites/oi_range_area_chart.dart` — Single file with OiRangeAreaSeries<T> (yMinMapper, yMaxMapper, midLineMapper) ✓
- Exported from barrel ✓
- **Tests: PENDING** — need range fill + mid-line + empty data tests

**OiRangeBarChart:**
- `lib/src/composites/oi_range_bar_chart.dart` — Single file with OiRangeBarSeries<T> (categoryMapper, startMapper, endMapper), horizontal Gantt-style ✓
- Exported from barrel ✓
- **Tests: PENDING** — need bar span + horizontal mode tests

---

## Remaining Gaps (Phases 3-7)

### Phase 3 — RadialBar + PolarArea ❌ NOT STARTED

**Files to create:**
- [ ] `lib/src/composites/oi_radial_bar_chart.dart` — OiRadialBarSeries<T> with categoryMapper, valueMapper, maxValue. Concentric arc bars.
- [ ] `lib/src/composites/oi_polar_area_chart.dart` — OiPolarAreaSeries<T> with categoryMapper, valueMapper. Equal-angle variable-radius wedges.
- [ ] Export from barrel
- [ ] Tests: arc angles, radii proportions, empty data

**How to implement:**
- Single-file charts extending polar rendering pattern
- Arc rendering via `canvas.drawArc()` with computed sweep angles
- RadialBar: concentric rings, each bar's sweep = (value/maxValue) × 2π
- PolarArea: equal angle slices (2π/N), radius varies by value

### Phase 4 — Sunburst + CalendarHeatmap ❌ NOT STARTED

**Files to create:**
- [ ] `lib/src/composites/oi_sunburst_chart/oi_sunburst_chart.dart` — Widget with data, nodeId, parentId, value, nodeLabel, maxDepth, centerContent, onNodeTap
- [ ] `lib/src/composites/oi_sunburst_chart/oi_sunburst_painter.dart` — Concentric rings, arc spans proportional to parent share
- [ ] `lib/src/composites/oi_calendar_heatmap.dart` — Single-file with dateMapper, valueMapper, colorScale, weekStartsOn, cellSize
- [ ] Export from barrel
- [ ] Tests: ring depth, arc spans, cell count for date range, color mapping

**How to implement:**
- Sunburst: parse tree hierarchy (reuse OiHierarchicalChart pattern), compute ring layout with arc angles per node. Click drills into subtree.
- CalendarHeatmap: grid of weeks×days. Column = week number. Row = day-of-week. Cell color from OiColorScale. Use OiChartGrid or manual Wrap for layout.

### Phase 5 — OiKpiBoard ❌ NOT STARTED

**Files to create:**
- [ ] `lib/src/modules/oi_kpi_board.dart` — Widget with metrics, columns, cardStyle
- [ ] `lib/src/modules/oi_kpi_metric.dart` — OiKpiMetric data class
- [ ] `lib/src/modules/oi_kpi_format.dart` — OiKpiFormat (currency/number/percentage), OiKpiStatus enum
- [ ] `lib/src/modules/oi_kpi_card.dart` — Single metric card (title, value, delta, sparkline, target)
- [ ] Create `lib/src/modules/` directory
- [ ] Export from barrel under `// ── Modules ──` section
- [ ] Tests: format output, delta computation, card render, grid layout

**How to implement:**
- Grid layout with responsive column count (LayoutBuilder)
- Each card: Column with title (OiLabel), value (OiLabel.heading), delta arrow (↑/↓ + percentage), embedded OiSparkline, optional target progress bar
- OiKpiFormat: `format(num value)` → String using intl or manual formatting

### Phase 6 — OiAnalyticsDashboard ❌ NOT STARTED

**Files to create:**
- [ ] `lib/src/modules/oi_analytics_dashboard.dart` — Widget with panels, syncGroup, columns, rowHeight
- [ ] `lib/src/modules/oi_dashboard_panel.dart` — OiDashboardPanel with id, title, gridPosition, chart
- [ ] `lib/src/modules/oi_grid_position.dart` — OiGridPosition (row, col, rowSpan, colSpan)
- [ ] `lib/src/modules/oi_dashboard_filter.dart` — OiDashboardFilter base + dateRange, dropdown
- [ ] Tests: grid positions, responsive columns, sync propagation

**How to implement:**
- Responsive grid: LayoutBuilder → compute available columns, wrap panels using CustomMultiChildLayout or GridView
- Each panel: OiSurface card with title bar + chart widget
- syncGroup: wrap all panels in OiChartSyncProvider
- Filters: Row of filter widgets above the grid

### Phase 7 — OiChartExplorer ❌ NOT STARTED

**Files to create:**
- [ ] `lib/src/modules/oi_chart_explorer.dart` — Widget with data, columns, initialChart
- [ ] `lib/src/modules/oi_explorer_column.dart` — OiExplorerColumn<T>, OiColumnType enum
- [ ] `lib/src/modules/oi_explorer_controller.dart` — Manages axis assignment, chart type, filters
- [ ] `lib/src/modules/oi_explorer_chart_type.dart` — OiExplorerChartType enum
- [ ] Tests: chart type switching, column assignment, aggregation

**How to implement:**
- Column picker sidebar: list of available columns with drag or tap to assign to x/y/group/filter
- Chart area: renders the selected chart type with assigned columns as mappers
- Filter panel: dynamically generated from column types (range sliders for numeric, checkboxes for categorical)
- Controller manages all state, chart rebuilds on any state change

---

## Phase 2 Test Gaps

These Phase 2 charts exist but lack tests:

### OiBoxPlotChart tests needed:
- [ ] `computeBoxPlotStats()` with [1,2,3,4,5,6,7,8,9,10] → verify Q1=3, median=5.5, Q3=8
- [ ] `computeBoxPlotStats()` outlier detection beyond 1.5×IQR
- [ ] Widget renders with pre-computed stats
- [ ] Widget renders with raw values (auto-compute)
- [ ] Horizontal mode renders correctly

### OiRangeAreaChart tests needed:
- [ ] Range fill between yMin and yMax renders
- [ ] Mid-line shows when enabled
- [ ] Empty data shows empty state

### OiRangeBarChart tests needed:
- [ ] Horizontal bars span correct start→end
- [ ] Multiple series offset correctly
- [ ] Empty data shows empty state

---

## Summary

| Category | Done | Remaining |
|----------|------|-----------|
| Phase 1 (Histogram + Waterfall) | ✓ 2/2 charts, 11 tests | — |
| Phase 2 (BoxPlot + RangeArea + RangeBar) | ✓ 3/3 charts, 0 tests | Tests needed |
| Phase 3 (RadialBar + PolarArea) | 0/2 charts | Full implementation |
| Phase 4 (Sunburst + CalendarHeatmap) | 0/2 charts | Full implementation |
| Phase 5 (OiKpiBoard) | 0/1 module | Full implementation |
| Phase 6 (OiAnalyticsDashboard) | 0/1 module | Full implementation |
| Phase 7 (OiChartExplorer) | 0/1 module | Full implementation |
| **Total** | **5/12 items** | **7 items + Phase 2 tests** |

**Current test count: 707 pass, 0 failures, 63 test files.**
**Phases 1-2: ~42% of Tier B plan complete. Phases 3-7 remain.**
