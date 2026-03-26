# obers_ui_charts — Gap Analysis vs Concept (2026-03-26, Rev 5)

**Concept reference:** `concept/obers_ui_charts.md`
**Package:** `packages/obers_ui_charts`
**Tests:** 687 pass, 3 pre-existing failures (bubble chart layout), 59 test files, 0 analysis errors
**Previous revisions:** gaps-1 through gaps-4

---

## Executive Summary

The package has two complete layers that are NOT YET connected to each other:

1. **Foundation layer** — 100% complete: all contracts, models, behaviors, scales, persistence, streaming, sync, normalization, decimation
2. **Concrete chart widgets** — functionally complete standalone widgets with their own simpler APIs, plus new mapper-first series classes added alongside legacy classes

**The bridge between them is the gap.** Concrete charts (OiLineChart, OiBarChart, etc.) are standalone StatefulWidgets that don't delegate to family bases (OiCartesianChart, etc.) and don't wire the foundation's behavior/sync/persistence/normalization systems. The mapper-first series classes exist but aren't exported from the barrel file.

---

## 1. What's Fully Complete (no gaps)

### Foundation Layer — 100%
- All 24 foundation contracts (themes, 8 scales, 8 behaviors, configs)
- All 21 data contracts (series types, axis, legend, tooltip, annotation, threshold, style)
- OiChartController with 5 states + all methods
- OiDefaultChartController concrete implementation
- All state models (Selection, Hover, Legend, Focus)
- OiChartViewportState (mutable zoom/pan)
- OiChartViewport with visibleDomainX/Y
- OiTickStrategy class with maxCount, minSpacingPx, niceValues
- Formatter contexts (OiAxisFormatContext, OiTooltipFormatContext)
- Decimation (minMax, LTTB, adaptive selection)
- Streaming (OiStreamingDataSource, OiRingBuffer, OiStreamingSeriesAdapter with appendMode/windowDuration)
- Persistence (OiPersistedViewport, OiPersistedSelection, OiChartSettings v2, OiChartSettingsDriverBinding)
- Sync (OiChartSyncCoordinator with broadcastHover/Viewport, OiChartSyncProvider)
- Accessibility (OiChartAccessibilityConfig, OiChartSummaryData, OiDetectedChartInsight, OiNoOpAccessibilityBridge)
- Extension hooks (OiChartExtension with 7 lifecycle hooks)
- Utilities (chart_math, path_utils, label_collision)

### Primitives + Components — 100%
- 12 component widgets (axis, legend, tooltip, crosshair, brush, zoom, annotation layer, empty/loading/error, surface, toggle)
- OiChartCanvas, OiChartLayer, OiChartHitTester, painters

### Family Base Composites — 100% (as shells)
- OiCartesianChart: behavior lifecycle, streaming, sync registration, persistence restore, normalization pipeline wired
- OiPolarChart: behavior lifecycle, streaming
- OiMatrixChart: behavior lifecycle, streaming
- OiHierarchicalChart: behavior lifecycle
- OiFlowChart: behavior lifecycle

### Mapper-First Series Classes — 100% (all 10 created)
- OiLineSeriesData<T>, OiBarSeriesData<T>, OiBubbleSeriesData<T>, OiScatterSeriesData<T>
- OiPieSeriesData<T>, OiRadarSeriesData<T>, OiHeatmapSeriesData<T>, OiSparklineSeriesData<T>
- OiAreaSeries<T>, OiCandlestickSeries<T> (already mapper-first from creation)

### Convention Compliance — 100%
- Zero raw `Text()` in lib/src/
- OiSeriesStyle.dashed() and .dotted() factories
- OiChartMarkerStyle.hidden() factory
- OiLineMissingValueBehavior enum (gap/connect/zero/interpolate)
- OiChartComplexity enum (mini/standard/detailed)

### V1 Chart Types — All 18 exist
OiLineChart, OiAreaChart, OiBarChart, OiScatterPlot, OiBubbleChart, OiComboChart, OiCandlestickChart, OiPieChart, OiDonutChart, OiRadarChart, OiGauge, OiHeatmap, OiTreemap, OiSankey, OiFunnelChart, OiSparkline + 5 family bases

---

## 2. Remaining Gaps

### Gap 2.1 — Mapper series classes NOT exported from barrel file

**Critical:** All 10 mapper-first series classes exist but are NOT exported from `lib/obers_ui_charts.dart`. Users cannot import them without reaching into `src/` internals.

**Missing exports:**
- `OiLineSeriesData<T>` (in `oi_line_chart_data.dart`)
- `OiBarSeriesData<T>` (in `oi_bar_chart_data.dart`)
- `OiBubbleSeriesData<T>` (in `oi_bubble_chart_data.dart`)
- `OiScatterSeriesData<T>` (in `oi_scatter_plot.dart`)
- `OiPieSeriesData<T>` (in `oi_pie_chart.dart`)
- `OiRadarSeriesData<T>` (in `oi_radar_chart.dart`)
- `OiHeatmapSeriesData<T>` (in `oi_heatmap.dart`)
- `OiSparklineSeriesData<T>` (in `oi_sparkline.dart`)
- `OiLineMissingValueBehavior` (in `oi_line_chart_data.dart`)

**Note:** `OiAreaSeries`, `OiCandlestickSeries`, `OiComboBarSeries`, `OiComboScatterSeries` ARE already exported because they're in files that are exported.

**Fix:** Add exports to barrel file. These are in files already exported (the chart data files), so the types ARE accessible — they just need to be verified as public API. The main issue is `OiLineSeriesData` and `OiLineMissingValueBehavior` which are in the already-exported `oi_line_chart_data.dart` — they should be publicly visible. Same for the others. **Verify by checking if the barrel's current exports already cover these types transitively.**

### Gap 2.2 — Concrete charts don't delegate to family bases

**Concept vision:** OiLineChart → thin wrapper around OiCartesianChart
**Actual:** OiLineChart is a standalone 450-line StatefulWidget with its own painter, legend, accessibility implementations.

**Consequence:** Concrete charts don't benefit from:
- Behavior system (no behaviors param on OiLineChart)
- Sync coordination (no syncGroup param)
- Persistence (no settings param)
- Normalization pipeline (normalizeSeries not called)
- Foundation theme resolution (uses own OiLineChartTheme)

**Affected charts:** OiLineChart, OiBarChart, OiBubbleChart, OiScatterPlot, OiPieChart, OiRadarChart, OiHeatmap, OiTreemap, OiSankey, OiFunnelChart, OiSparkline, OiGauge

**Fix options:**
- **Option A (Full refactor):** Rewrite each concrete chart to delegate to its family base. OiLineChart would use OiCartesianChart internally with a seriesBuilder that paints lines.
- **Option B (Param forwarding):** Add the missing params (behaviors, controller, annotations, etc.) to each concrete chart and wire them internally.
- **Option C (Document as two-tier API):** Document that OiLineChart is the "simple API" for common cases, and OiCartesianChart<T> with OiLineSeriesData<T> is the "power API" with full behavior/sync/persistence support.

**Recommendation:** Option C for now. Option A as a future refactor.

### Gap 2.3 — OiLineChart missing concept-specified params

OiLineChart currently accepts:
`label, series, mode, xAxis, yAxis, showGrid, showLegend, showPoints, stacked, onPointTap, theme, interactionMode, compact`

**Missing per concept Part 4:**
- `behaviors: List<OiChartBehavior>` — composable interaction
- `controller: OiChartController?` — external state
- `annotations: List<OiChartAnnotation>` — overlay lines/regions
- `thresholds: List<OiChartThreshold>` — threshold lines
- `legend: OiChartLegendConfig?` — full legend config
- `performance: OiChartPerformanceConfig?` — decimation
- `animation: OiChartAnimationConfig?` — animation control
- `accessibility: OiChartAccessibilityConfig?` — a11y config
- `settings: OiChartSettingsDriverBinding?` — persistence
- `syncGroup: String?` — chart sync
- Shorthand `data/x/y` props for single-series convenience
- `yAxes: List<OiChartAxis>?` — multi y-axis
- `onPointDoubleTap`, `onPointLongPress`, `onSeriesVisibilityChange`, `onViewportChange`, `onSelectionChange` callbacks

**Fix:** Either add these params to OiLineChart (and wire internally), or document that OiCartesianChart<T> is the full-featured alternative.

### Gap 2.4 — Decimation not auto-invoked

`normalizeSeries()` is called in OiCartesianChart's build, but decimation is not applied to the result. The `performance.decimationStrategy` config is accepted but never acted upon.

**Fix:** After normalization, check if total point count exceeds `performance.maxInteractivePoints`. If so, convert normalized datums to `Point<double>` and call `decimateMinMax()` or `decimateLttb()` based on strategy.

### Gap 2.5 — 30 hardcoded `Color(0x...)` values

Across 13 files. All are fallback defaults in theme-first resolution chains. Low priority but violates concept's "all colors from theme" rule.

### Gap 2.6 — No `OiChartWidget` abstract base

Concept section 3.1 defines a shared abstract base for all chart composites. Not implemented. Concrete charts have independent prop sets.

**Assessment:** Intentional deviation. Deep inheritance hierarchies conflict with Flutter's composition preference and obers_ui's pragmatic approach.

### Gap 2.7 — 3 pre-existing test failures

All in `oi_bubble_chart_test.dart` — RenderFlex overflow in size legend layout. Not related to any recent changes.

---

## 3. Priority-Ordered Fix List

### P0 — Must fix (usability blockers)

1. **Verify barrel exports cover mapper series** — Check if `OiLineSeriesData`, `OiBarSeriesData`, etc. are publicly accessible via the barrel's existing file exports. If not, add explicit exports.

### P1 — Should fix (concept compliance)

2. **Document two-tier API** — Add doc comments explaining: OiLineChart = simple API, OiCartesianChart<T> + OiLineSeriesData<T> = power API with full foundation wiring
3. **Wire decimation into OiCartesianChart** — After normalization, apply decimation based on performance config
4. **Add missing params to OiLineChart** — At minimum: `behaviors`, `controller`, `annotations`, `thresholds`

### P2 — Nice to have

5. **Fix 3 bubble chart test failures** — Layout overflow in size legend
6. **Add shorthand `data/x/y` API** to OiLineChart for single-series convenience
7. **Add missing callbacks** (onPointDoubleTap, onSeriesVisibilityChange, etc.)
8. **Reduce hardcoded colors** in component painters

### P3 — Future

9. **Refactor concrete charts to delegate to family bases** (Option A — major refactor)
10. **OiChartWidget abstract base** (document deviation instead)
11. Tier B/C charts + Modules

---

## Summary Statistics

| Category | Complete | Partial | Missing |
|----------|----------|---------|---------|
| Foundation contracts (24) | 24 | 0 | 0 |
| Data contracts (21) | 21 | 0 | 0 |
| Primitives + Components (18) | 18 | 0 | 0 |
| Family base composites (5) | 5 | 0 | 0 |
| V1 chart widgets (18) | 18 | 0 | 0 |
| Mapper-first series (10) | 10 | 0 | 0 |
| Barrel exports for mapper series | 0 | 1 | 0 |
| Concrete chart → foundation wiring | 0 | 1 | 0 |
| OiLineChart concept params | 13/25+ | 0 | 12+ |
| Normalization pipeline | 1 (called) | 0 | 0 |
| Decimation invocation | 0 | 1 | 0 |
| Convention (Text→OiLabel) | 100% | 0 | 0 |
| Convention (colors) | — | 30 fallbacks | 0 |
| Test coverage | 59 files, 687 pass | 3 fail | 0 |

**Foundation + contracts + chart types: 100% complete.**
**Remaining gap is the bridge between concrete charts and foundation — either wire them together or document the two-tier approach.**
**V1 scope: ~95% complete. The last 5% is export verification, decimation wiring, and documentation.**
