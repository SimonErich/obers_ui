# obers_ui_charts — Gap Analysis vs Concept (2026-03-26, Rev 4)

**Concept reference:** `concept/obers_ui_charts.md`
**Package:** `packages/obers_ui_charts`
**Tests:** 674 pass (3 pre-existing bubble chart layout failures), 58 test files, 0 analysis errors
**Previous revisions:** gaps-1, gaps-2, gaps-3

---

## Executive Summary

The package has **two parallel API layers** with different maturity:

1. **Foundation layer** (models, scales, behaviors, configs, contracts) — **100% complete** per concept
2. **Concrete chart widgets** (OiLineChart, OiBarChart, etc.) — **pre-migration legacy widgets** that do NOT use the foundation layer's mapper-first data binding, normalization pipeline, or full config surface

The concept envisions concrete charts as thin wrappers around family bases (e.g., OiLineChart wraps OiCartesianChart). In reality, concrete charts are **standalone pre-existing widgets** with their own simpler APIs (OiLinePoint-based, not mapper-based). The family bases (OiCartesianChart, etc.) DO implement the concept's architecture but concrete charts don't delegate to them.

**This is the single largest remaining gap: concrete charts and foundation contracts are disconnected.**

---

## 1. Critical Gap: Concrete Charts vs Mapper-First Architecture

### The Problem

The concept requires mapper-first data binding:
```dart
OiLineChart<SalesPoint>(
  label: 'Revenue',
  series: [
    OiLineSeries<SalesPoint>(
      id: 'actual', label: 'Actual',
      data: sales,
      x: (p) => p.date,
      y: (p) => p.revenue,
    ),
  ],
)
```

The actual implementation uses pre-mapped point objects:
```dart
OiLineChart(
  label: 'Revenue',
  series: [
    OiLineSeries(
      label: 'Actual',
      points: [OiLinePoint(x: 1, y: 100), ...],
    ),
  ],
)
```

### Affected Charts

| Chart | Uses Mapper-First? | Data Model |
|-------|-------------------|------------|
| OiLineChart | ❌ | `OiLineSeries.points: List<OiLinePoint>` |
| OiBarChart | ❌ | `OiBarSeries` with pre-mapped data |
| OiBubbleChart | ❌ | `OiBubbleSeries` with pre-mapped data |
| OiScatterPlot | ❌ | Pre-mapped data |
| OiPieChart | ❌ | `OiPieSegment(label, value)` |
| OiRadarChart | ❌ | Pre-mapped data |
| OiHeatmap | ❌ | Pre-mapped data |
| OiGauge | N/A | Single value, no mapper needed |
| OiSparkline | ❌ | Pre-mapped data |
| OiAreaChart | ✓ | `OiAreaSeries<T>` extends `OiCartesianSeries<T>` with mappers |
| OiComboChart | ✓ | Accepts `OiCartesianSeries<T>` with mappers |
| OiCandlestickChart | ✓ | `OiCandlestickSeries<T>` with mappers |
| OiDonutChart | ❌ | Wraps OiPieChart (OiPieSegment) |
| OiCartesianChart | ✓ | Family base, mapper-first by design |
| OiPolarChart | ✓ | Family base, mapper-first |

**9 of 15 concrete charts use legacy pre-mapped data models instead of mapper-first.**

### Fix

Each legacy chart needs refactoring to either:
- **Option A:** Become a thin wrapper around the corresponding family base (concept's preferred approach)
- **Option B:** Add mapper-based constructors alongside existing point-based ones (backward compatible)

This is a large refactor affecting all pre-migration charts.

---

## 2. OiLineChart Missing Concept Requirements

OiLineChart is the concept's reference implementation. These features are specified but missing:

### 2.1 — Missing series-level properties

`OiLineSeries` has: `label, points, color, strokeWidth, dashed, fill, fillOpacity`

**Concept requires additionally:**
- `interpolation: OiLineInterpolation` — per-series interpolation mode (currently only chart-level `mode`)
- `missingValueBehavior: OiLineMissingValueBehavior` — how to handle gaps (enum: gap/connect/zero/interpolate). **Enum doesn't exist.**
- `showLine: bool` — toggle line visibility per series
- `showMarkers: bool` — toggle markers per series
- `showDataLabels: bool` — toggle data labels per series
- `fillBelow: bool` — area fill per series (exists as `fill` but concept uses `fillBelow` name)
- `smoothing: double?` — spline tension control
- `valueFormatter: OiTooltipValueFormatter?` — per-series value formatting
- `xFormatter: OiAxisFormatter?` — per-series x-axis formatting
- `pointColor: Color? Function(T item, OiSeriesPointContext)?` — dynamic per-point coloring
- `semanticValue: String? Function(T item)?` — per-point screen reader text

### 2.2 — Missing chart-level parameters

OiLineChart has: `label, series, mode, xAxis, yAxis, showGrid, showLegend, showPoints, stacked, onPointTap, theme, interactionMode, compact`

**Concept requires additionally:**
- `data: List<T>?` + `x` + `y` — shorthand single-series API
- `yAxes: List<OiChartAxis>?` — multi y-axis support (only single `yAxis` exists)
- `legend: OiChartLegendConfig?` — full legend configuration
- `behaviors: List<OiChartBehavior>` — composable behavior system
- `annotations: List<OiChartAnnotation>` — annotation overlays
- `thresholds: List<OiChartThreshold>` — threshold lines
- `performance: OiChartPerformanceConfig?` — decimation/rendering config
- `animation: OiChartAnimationConfig?` — animation config
- `accessibility: OiChartAccessibilityConfig?` — a11y config
- `settings: OiChartSettingsDriverBinding?` — persistence
- `controller: OiChartController?` — external state control
- `syncGroup: String?` — chart synchronization
- `loadingState: OiChartLoadingStateConfig?` — typed config (not raw Widget)
- `emptyState: OiChartEmptyStateConfig?` — typed config
- `errorState: OiChartErrorStateConfig?` — typed config

### 2.3 — Missing callbacks

Only `onPointTap` exists. Concept requires:
- `onPointDoubleTap`
- `onPointLongPress`
- `onSeriesVisibilityChange`
- `onViewportChange`
- `onSelectionChange`

### 2.4 — Missing enums

- `OiLineMissingValueBehavior` (gap/connect/zero/interpolate) — **doesn't exist**
- `OiLineInterpolation` — exists as `OiLineChartMode` (same values, different name)

---

## 3. Missing Factory Constructors

### `OiMarkerStyle.hidden()` — Missing

**Concept:** `marker: OiMarkerStyle.hidden()`
**Actual:** Must use `OiChartMarkerStyle(visible: false)`
**Fix:** Add `factory OiChartMarkerStyle.hidden() => const OiChartMarkerStyle(visible: false);`

### `OiChartLoadingStateConfig` / `OiChartEmptyStateConfig` / `OiChartErrorStateConfig` — Missing

**Concept:** Typed config objects for state presentation
**Actual:** Raw Widget classes (`OiChartEmptyState`, etc.)
**Assessment:** Widget approach is pragmatic and allows full customization. Config objects would be an additional abstraction layer. **Document as intentional deviation.**

---

## 4. Normalization + Decimation Pipeline Still Unwired

### `normalizeSeries()` never called by composites

**File:** `models/oi_chart_datum.dart` — function exists (lines 94-114)
**Usage:** 0 calls in any composite. Raw series data passed directly to painters.
**Impact:** Charts don't benefit from the normalized `OiChartDatum` model. Hit testing, tooltip resolution, and accessibility narration operate on raw data instead of normalized internal representation.

### Decimation functions never invoked

**File:** `foundation/oi_decimation.dart` — `decimateMinMax()`, `decimateLttb()`, `selectDecimationStrategy()` exist
**Usage:** 0 calls in any composite.
**Impact:** Large datasets render all points without optimization. The `performance: OiChartPerformanceConfig` parameter is accepted but ignored.

---

## 5. Convention Violations

### 1 remaining `Text()` in legend

**File:** `composites/oi_line_chart/oi_line_chart_legend.dart` line 100
**Fix:** Replace `Text(label, style: ...)` → `OiLabel.caption(label, color: ...)`

### ~30 hardcoded `Color(0x...)` values

Across 13 files. All have theme-first fallback chains. The hardcoded values are defensive fallbacks, not primary styling. Low priority.

---

## 6. Test Gaps

### 3 pre-existing bubble chart test failures

**File:** `test/src/composites/oi_bubble_chart/oi_bubble_chart_test.dart`
**Cause:** RenderFlex overflow in size legend layout
**Not related to** recent changes — pre-existing before this work.

### Missing test scenarios

- **Normalization pipeline** — no test verifies `normalizeSeries()` produces correct OiChartDatum output when called from a composite
- **Decimation integration** — no test verifies decimation reduces point count in rendering
- **2-chart sync** — no test verifies two charts with same syncGroup coordinate hover/viewport
- **Full persistence round-trip** — save controller state → dispose → restore → verify match (partial coverage exists for initial restore)

---

## 7. Tier B/C Charts + Modules (Future Scope)

Not implemented, not v1:
- **Tier B:** OiHistogram, OiWaterfallChart, OiBoxPlotChart, OiRangeAreaChart, OiRangeBarChart, OiRadialBarChart, OiPolarAreaChart, OiSunburstChart, OiCalendarHeatmap
- **Tier C:** OiStepLineChart, OiSplineChart, OiStepAreaChart, OiAlluvialChart, OiIcicleChart, OiSparkBar, OiWinLossChart
- **Modules:** OiAnalyticsDashboard, OiChartExplorer, OiKpiBoard

---

## 8. Priority-Ordered Fix List

### P0 — Architecture: Bridge concrete charts to foundation

1. **Refactor OiLineChart to use mapper-first data binding** — either wrap OiCartesianChart or add `OiLineSeries<T>` with x/y mappers alongside legacy OiLineSeries
2. **Refactor OiBarChart similarly** — same pattern
3. **Refactor OiBubbleChart similarly**
4. **Add OiLineMissingValueBehavior enum** (gap/connect/zero/interpolate)
5. **Wire normalizeSeries() into composite rendering**
6. **Wire decimation into composite rendering**

### P1 — OiLineChart concept compliance

7. **Add shorthand API** (data/x/y props) to OiLineChart for single-series convenience
8. **Add missing chart-level params** (behaviors, annotations, thresholds, legend, performance, animation, accessibility, settings, controller, syncGroup)
9. **Add missing callbacks** (onPointDoubleTap, onPointLongPress, onSeriesVisibilityChange, onViewportChange, onSelectionChange)
10. **Add missing series-level props** (interpolation, missingValueBehavior, showMarkers, showDataLabels, pointColor, semanticValue)

### P2 — Convenience factories

11. **OiChartMarkerStyle.hidden()** factory
12. **Document state config deviation** (Widgets vs Config objects)

### P3 — Convention polish

13. **Fix 1 remaining Text()** in line chart legend
14. **Reduce hardcoded colors** where feasible (low priority)

### P4 — Test depth

15. **Fix 3 bubble chart test failures**
16. **Add normalization + decimation integration tests**
17. **Add 2-chart sync test**

### P5 — Future scope

18. Tier B/C chart types
19. Modules (dashboard, explorer, KPI board)

---

## Summary Statistics

| Category | Complete | Partial | Missing |
|----------|----------|---------|---------|
| Foundation contracts (24 items) | 24 | 0 | 0 |
| Family base composites (5) | 5 | 0 | 0 |
| Composite wiring (streaming/sync/persistence) | 3/5 | 2 | 0 |
| Normalization + decimation pipeline | 0/2 | 0 | 2 |
| V1 chart widgets exist (18) | 18 | 0 | 0 |
| Mapper-first data binding (15 concrete) | 6 | 0 | 9 |
| OiLineChart concept compliance (25 features) | 10 | 3 | 12 |
| Convention compliance | — | 2 | 0 |
| Test coverage | 56/58 areas | — | 2 |

**Foundation layer: 100% complete.**
**Concrete chart API compliance: ~40% (mapper-first only in new charts; legacy charts unchanged).**
**Overall v1 concept alignment: ~80%.**

**The gap is no longer in missing types or contracts — it's in upgrading legacy chart widgets to use the foundation layer they now sit on top of.**
