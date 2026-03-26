# obers_ui_charts — Gap Analysis: Tier B + Modules (2026-03-26, Rev 11)

**Plan reference:** `concept/obers_ui_charts-tier-b-modules-plan.md`
**Spec reference:** `concept/obers_ui_charts-tier-b-modules.md`
**Package:** `packages/obers_ui_charts`
**Verified state:** 716 tests pass, 0 failures, 0 warnings, 65 test files, 147 barrel exports

---

## All 12 Items Built ✓

Every chart and module from the plan exists, compiles, and is exported:

### Tier B Charts (9/9) ✓

| Chart | Type | Files | Exported |
|-------|------|-------|----------|
| OiHistogram | Multi-file (3) | `oi_histogram/` | ✓ |
| OiWaterfallChart | Multi-file (3) | `oi_waterfall_chart/` | ✓ |
| OiBoxPlotChart | Multi-file (3) | `oi_box_plot_chart/` | ✓ |
| OiRangeAreaChart | Single-file | `oi_range_area_chart.dart` | ✓ |
| OiRangeBarChart | Single-file | `oi_range_bar_chart.dart` | ✓ |
| OiRadialBarChart | Single-file | `oi_radial_bar_chart.dart` | ✓ |
| OiPolarAreaChart | Single-file | `oi_polar_area_chart.dart` | ✓ |
| OiSunburstChart | Multi-file (2) | `oi_sunburst_chart/` | ✓ |
| OiCalendarHeatmap | Single-file | `oi_calendar_heatmap.dart` | ✓ |

### Modules (3/3) ✓

| Module | Files | Exported |
|--------|-------|----------|
| OiKpiBoard | 4 files (board, card, format, metric) | ✓ |
| OiAnalyticsDashboard | 4 files (dashboard, panel, grid_position, filter) | ✓ |
| OiChartExplorer | 4 files (explorer, column, controller, chart_type) | ✓ |

---

## Remaining Gaps: Tests Only

All 12 items exist and compile. The **only remaining gap** is test coverage for the newer items.

### Tests that EXIST (4 files, 20 tests) ✓

| Test File | Tests | What's Covered |
|-----------|-------|----------------|
| `oi_histogram_test.dart` | 7 | Bin computation (count, frequency sum, normalized, single, empty), widget render, fromValues |
| `oi_waterfall_chart_test.dart` | 4 | Running total, total bar reset, empty data, widget render |
| `oi_box_plot_chart_test.dart` | 5 | Quartile computation, outlier detection, single value, empty, widget render |
| `oi_range_charts_test.dart` | 4 | RangeArea fill + empty, RangeBar horizontal + empty |

### Tests that are MISSING (8 files needed)

#### Tier B chart tests:

1. **`test/src/composites/oi_radial_bar_chart_test.dart`** — needed:
   - Arc sweep = (value / maxValue) × full sweep
   - Background track renders
   - Empty data shows empty state
   - Widget renders with data

2. **`test/src/composites/oi_polar_area_chart_test.dart`** — needed:
   - All wedge angles equal (2π / N)
   - Wedge radii proportional to values
   - Labels render around perimeter
   - Widget renders with data

3. **`test/src/composites/oi_sunburst_chart_test.dart`** — needed:
   - Ring depth matches tree hierarchy
   - Arc spans proportional to parent share
   - Center content renders
   - Widget renders with flat node list

4. **`test/src/composites/oi_calendar_heatmap_test.dart`** — needed:
   - Cell count matches date range (accounting for partial weeks)
   - Color resolves through OiColorScale
   - Empty dates show base color
   - Month labels render
   - Widget renders with data

#### Module tests:

5. **`test/src/modules/oi_kpi_format_test.dart`** — needed:
   - OiKpiFormat.currency formats 1234567 → "$1,234,567"
   - OiKpiFormat.percentage formats 0.0342 → "3.4%"
   - OiKpiFormat.number formats 42000 → "42,000"
   - Delta computation: (value - previous) / previous × 100

6. **`test/src/modules/oi_kpi_board_test.dart`** — needed:
   - Board renders correct card count for metrics
   - Responsive columns: 3 at wide, 1 at narrow
   - Empty metrics shows empty state

7. **`test/src/modules/oi_analytics_dashboard_test.dart`** — needed:
   - Dashboard renders correct panel count
   - Responsive column adaptation
   - SyncGroup wraps children in provider

8. **`test/src/modules/oi_chart_explorer_test.dart`** — needed:
   - Chart type switch renders different chart widget
   - Column assignment updates chart data
   - Controller state changes trigger rebuild

---

## Plan Phase Checklist

| Phase | Task | Status |
|-------|------|--------|
| **1** Histogram | oi_histogram_data.dart | ✓ |
| | oi_histogram_painter.dart | ✓ |
| | oi_histogram.dart + fromValues | ✓ |
| | oi_waterfall_data.dart | ✓ |
| | oi_waterfall_painter.dart | ✓ |
| | oi_waterfall_chart.dart | ✓ |
| | Barrel exports | ✓ |
| | TDD: bin computation | ✓ (7 tests) |
| | TDD: waterfall totals | ✓ (4 tests) |
| **2** BoxPlot | oi_box_plot_data.dart | ✓ |
| | oi_box_plot_painter.dart | ✓ |
| | oi_box_plot_chart.dart | ✓ |
| | oi_range_area_chart.dart | ✓ |
| | oi_range_bar_chart.dart | ✓ |
| | Barrel exports | ✓ |
| | TDD: quartile + outlier | ✓ (5 tests) |
| | TDD: range fill + bar span | ✓ (4 tests) |
| **3** Polar | oi_radial_bar_chart.dart | ✓ |
| | oi_polar_area_chart.dart | ✓ |
| | Barrel exports | ✓ |
| | TDD: arc sweep | ❌ MISSING |
| | TDD: wedge angles | ❌ MISSING |
| **4** Hierarchical+Matrix | oi_sunburst_chart/ | ✓ |
| | oi_calendar_heatmap.dart | ✓ |
| | Barrel exports | ✓ |
| | TDD: ring depth | ❌ MISSING |
| | TDD: cell count + color | ❌ MISSING |
| **5** KpiBoard | oi_kpi_board.dart | ✓ |
| | oi_kpi_metric.dart | ✓ |
| | oi_kpi_format.dart | ✓ |
| | oi_kpi_card.dart | ✓ |
| | Barrel exports | ✓ |
| | TDD: format + delta | ❌ MISSING |
| | TDD: card count | ❌ MISSING |
| **6** Dashboard | oi_analytics_dashboard.dart | ✓ |
| | oi_dashboard_panel.dart | ✓ |
| | oi_grid_position.dart | ✓ |
| | oi_dashboard_filter.dart | ✓ |
| | Barrel exports | ✓ |
| | TDD: panel count + responsive | ❌ MISSING |
| **7** Explorer | oi_chart_explorer.dart | ✓ |
| | oi_explorer_column.dart | ✓ |
| | oi_explorer_controller.dart | ✓ |
| | oi_explorer_chart_type.dart | ✓ |
| | Barrel exports | ✓ |
| | TDD: chart type switch + groupBy | ❌ MISSING |

---

## Summary

| Category | Done | Gap |
|----------|------|-----|
| Chart implementations | 9/9 | — |
| Module implementations | 3/3 | — |
| Barrel exports | 12/12 | — |
| Tests (Phases 1-2) | 20 tests in 4 files | ✓ Complete |
| Tests (Phases 3-7) | 0 tests in 0 files | ❌ 8 test files needed |
| Analyzer warnings | 0 | ✓ |
| Total tests | 716 pass, 0 fail | ✓ |

**Implementation: 100% complete. Test coverage: ~60% (Phases 1-2 tested, Phases 3-7 untested).**
**8 test files needed to reach full coverage.**
