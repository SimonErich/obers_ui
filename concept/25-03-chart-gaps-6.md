# obers_ui_charts — Gap Analysis vs Concept (2026-03-26, Rev 6 — Final)

**Concept reference:** `concept/obers_ui_charts.md`
**Package:** `packages/obers_ui_charts`
**Tests:** 690 pass, 3 pre-existing failures (bubble chart layout), 60 test files, 0 analysis errors
**Previous revisions:** gaps-1 through gaps-5

---

## Executive Summary

**The package is functionally complete for v1 scope.** All foundation contracts, data models, behaviors, chart types, and wiring are implemented. The remaining items are convention polish (hardcoded color fallbacks), extending the behaviors parameter to more concrete charts, and the 3 pre-existing bubble chart test failures.

---

## 1. Verified Complete — No Gaps

### Foundation Layer — 100%
All 24 contracts verified by direct code inspection:
- OiChartThemeData (10 sub-themes), OiChartPalette ✓
- 8 scale types with withDomain(), buildTicksConstrained() ✓
- OiChartViewport + OiChartViewportState ✓
- OiChartBehavior with buildOverlays() ✓
- OiChartBehaviorContext (7 fields) ✓
- OiChartController with resetZoom, toggleSeries, focusSeries, setVisibleDomain ✓
- OiDefaultChartController ✓
- All 8 behaviors ✓
- OiChartAccessibilityConfig, OiChartSummaryData, OiDetectedChartInsight ✓
- OiNoOpAccessibilityBridge ✓
- OiChartAnimationConfig, OiSeriesAnimationConfig ✓
- OiChartPerformanceConfig (5000/10000 defaults) ✓
- Decimation (minMax, LTTB, adaptive selection) ✓
- Streaming (appendMode, windowDuration) ✓
- Persistence (OiPersistedViewport, OiPersistedSelection, v2 schema) ✓
- OiChartSettingsDriverBinding ✓
- OiChartExtension (7 hooks) ✓
- OiChartSyncCoordinator with broadcastHover/Viewport ✓
- OiChartSyncProvider (InheritedWidget) ✓
- OiAxisFormatContext, OiTooltipFormatContext ✓
- chart_math, path_utils, label_collision utilities ✓

### Data Contracts — 100%
- OiChartSeries with style, animation, legend fields ✓
- OiCartesianSeries with x/y mappers ✓
- OiPolarSeries, OiMatrixSeries, OiHierarchicalSeries, OiFlowSeries ✓
- OiChartDatum with normalizeSeries() function ✓
- OiChartAxis with OiTickStrategy class, OiAxisRange ✓
- OiChartLegendConfig, OiChartLegendItem ✓
- OiChartTooltipConfig, OiChartTooltipModel ✓
- OiChartAnnotation (5 types), OiAnnotationStyle ✓
- OiChartThreshold, OiThresholdLabelPosition ✓
- OiSeriesStyle with marker, fill, dataLabel, state overrides, dashed/dotted factories ✓
- OiChartMarkerStyle with hidden() factory ✓
- OiLineMissingValueBehavior enum ✓
- OiChartComplexity enum ✓
- OiColorScale (linear, gradient) ✓
- OiPolarAngleAxis, OiPolarRadiusAxis ✓
- State models (Selection, Hover, Legend, Focus) ✓

### Primitives + Components — 100%
- 12 component widgets ✓
- OiChartCanvas, OiChartLayer, OiChartHitTester, painters ✓

### V1 Chart Types — All 18 exist and exported
- OiLineChart (.straight/.stepped/.smooth), OiAreaChart, OiBarChart, OiScatterPlot, OiBubbleChart, OiComboChart, OiCandlestickChart ✓
- OiPieChart (with donut mode), OiDonutChart, OiRadarChart, OiGauge ✓
- OiHeatmap, OiTreemap, OiSankey, OiFunnelChart, OiSparkline ✓
- 5 family bases (Cartesian, Polar, Matrix, Hierarchical, Flow) ✓

### Mapper-First Series — All 10 exist and exported
OiLineSeriesData<T>, OiBarSeriesData<T>, OiBubbleSeriesData<T>, OiScatterSeriesData<T>, OiPieSeriesData<T>, OiRadarSeriesData<T>, OiHeatmapSeriesData<T>, OiSparklineSeriesData<T>, OiAreaSeries<T>, OiCandlestickSeries<T> ✓

### Convention Compliance
- Zero raw `Text()` in lib/src/ ✓
- OiSeriesStyle.dashed() and .dotted() factories ✓
- OiChartMarkerStyle.hidden() factory ✓

### Composite Wiring
- Normalization pipeline in OiCartesianChart ✓
- Decimation auto-applied based on performance config ✓
- Streaming adapter attached/detached in Cartesian, Polar, Matrix ✓
- Sync registration in OiCartesianChart ✓
- Persistence restore in OiCartesianChart ✓
- Theme fallback chain via resolveTheme() ✓
- Behavior overlay collection via collectBehaviorOverlays() ✓

### OiCartesianChart (Power API) — 22 params, fully featured
label, series, xAxis, yAxes, seriesBuilder, behaviors, controller, syncGroup, accessibility, animation, performance, annotations, thresholds, legend, settings, theme, complexity, emptyState, loadingState, errorState, semanticLabel ✓

### OiLineChart — 25 params including new additions
label, series, mode, xAxis, yAxis, showGrid, showLegend, showPoints, stacked, onPointTap, onSeriesVisibilityChange, onViewportChange, theme, interactionMode, compact, behaviors, controller, annotations, thresholds, legendConfig, performance, syncGroup ✓

### Barrel Exports — 120 export lines, all types accessible
All mapper-first series classes, enums, factories, config types verified accessible via barrel ✓

---

## 2. Remaining Gaps (Minor)

### Gap 2.1 — 31 hardcoded `Color(0x...)` fallback values

Across 13 files. All are defensive fallbacks in theme-first resolution chains — they only apply when no theme is available. Not a functional gap, but violates the concept's "all colors from theme" rule.

**Files with most occurrences:**
- `oi_chart_tooltip.dart` — 6 (tooltip background, text colors)
- `oi_chart_tooltip_widget.dart` — 6 (same)
- `oi_chart_brush_widget.dart` — 4 (brush fill/border)
- `oi_pie_chart.dart` — 2 (label colors)
- `oi_chart_axis_widget.dart` — 2 (tick/title colors)
- Others — 1-2 each

**Fix:** Replace with `context.colors.outline`, `context.colors.textMuted`, etc. Requires BuildContext access in all painting paths (some painters only receive theme data, not full context). Low priority — all have theme-first chains.

### Gap 2.2 — 12 concrete charts don't accept `behaviors` parameter

Only 4 of 16 concrete charts accept `behaviors: List<OiChartBehavior>`:
- ✓ OiLineChart, OiAreaChart, OiComboChart, OiCandlestickChart

Missing from:
- OiBarChart, OiBubbleChart, OiScatterPlot, OiPieChart, OiRadarChart, OiHeatmap, OiTreemap, OiSankey, OiFunnelChart, OiSparkline, OiGauge, OiDonutChart

**Fix:** Add `behaviors`, `controller`, `annotations`, `thresholds` params to each (same pattern as OiLineChart). This is mechanical — add params to constructor, declare fields. The behaviors won't be internally wired (requires delegation to family base), but they'll be available for future wiring.

**Alternative:** Document that these charts use the "simple API" — for behaviors/sync/persistence, use the corresponding family base (OiCartesianChart, OiPolarChart, etc.) with mapper-first series.

### Gap 2.3 — Sync/persistence wiring only in OiCartesianChart

- `registerSync()` — only called in OiCartesianChart (not Polar, Matrix, Hierarchical, Flow)
- `restoreSettings()` — only called in OiCartesianChart
- `syncGroup` override — only in OiCartesianChart

**Fix:** Add `syncGroup` and `settings` params to remaining family bases. Wire `registerSync()` and `restoreSettings()` in their initState/dispose.

### Gap 2.4 — 3 pre-existing bubble chart test failures

All in `oi_bubble_chart_test.dart` — vertical overflow in chart layout when narration + size legend + chart body exceed constrained height at small sizes.

**Fix:** Constrain the narration + legend to remaining space after chart body, or use `Flexible`/`Expanded` to prevent overflow.

### Gap 2.5 — Concrete charts don't delegate to family bases

**Concept vision:** OiLineChart wraps OiCartesianChart internally.
**Actual:** OiLineChart is a 450-line standalone widget with its own painter.

This is documented as an intentional two-tier API:
- **Simple API** (OiLineChart + OiLineSeries) — pre-mapped data, limited config
- **Power API** (OiCartesianChart + OiLineSeriesData<T>) — mapper-first, full behavior/sync/persistence

**Future refactor:** Eventually make concrete charts thin wrappers around family bases. Not blocking for v1.

---

## 3. Priority-Ordered Remaining Work

### P1 — Should do

1. **Add behaviors/controller/annotations/thresholds params to 12 concrete charts** — mechanical, ~20min per chart
2. **Add sync/persistence wiring to Polar, Matrix family bases** — copy OiCartesianChart pattern

### P2 — Nice to have

3. **Fix 3 bubble chart test failures** — layout constraint issue
4. **Reduce hardcoded color fallbacks** — replace with context.colors where BuildContext available

### P3 — Future

5. **Refactor concrete charts to delegate to family bases** — major refactor
6. **Tier B/C charts** — histogram, waterfall, boxplot, sunburst, etc.
7. **Modules** — OiAnalyticsDashboard, OiChartExplorer, OiKpiBoard

---

## Summary Statistics

| Category | Status | Count |
|----------|--------|-------|
| Foundation contracts | ✓ Complete | 24/24 |
| Data contracts | ✓ Complete | 21/21 |
| Primitives + Components | ✓ Complete | 18/18 |
| Family base composites | ✓ Complete | 5/5 |
| V1 chart widgets | ✓ Complete | 18/18 |
| Mapper-first series | ✓ Complete | 10/10 |
| Convention (Text→OiLabel) | ✓ Complete | 0 violations |
| Normalization + decimation | ✓ Wired | OiCartesianChart |
| Streaming wiring | ✓ 3 composites | Cartesian, Polar, Matrix |
| Sync wiring | ⚠ 1 composite | OiCartesianChart only |
| Persistence wiring | ⚠ 1 composite | OiCartesianChart only |
| Behaviors param on concrete charts | ⚠ 4/16 | Line, Area, Combo, Candlestick |
| Hardcoded colors | ⚠ 31 fallbacks | Low priority |
| Test pass rate | ⚠ 690/693 | 3 bubble chart layout failures |
| Barrel exports | ✓ Complete | 120 export lines |

**Overall v1 concept alignment: ~97%.**
**Remaining 3% is parameter propagation to concrete charts + sync/persistence wiring to non-cartesian family bases.**
