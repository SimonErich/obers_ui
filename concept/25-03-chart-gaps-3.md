# obers_ui_charts — Gap Analysis vs Concept (2026-03-26, Rev 3)

**Concept reference:** `concept/obers_ui_charts.md`
**Package:** `packages/obers_ui_charts`
**Tests:** 671 pass, 56 test files, 0 analysis errors
**Overall:** ~90% of concept requirements implemented. Foundation 100%, chart types 100%, remaining gaps in composite wiring, convention polish, and test depth.

---

## 1. Fully Complete Areas (no gaps)

These sections of the concept are fully implemented with no remaining work:

| Area | Items | Status |
|------|-------|--------|
| Package structure | Separate package, tier directories, barrel file | ✓ |
| Theme system | OiChartThemeData (10 sub-themes), OiChartPalette, theme registration | ✓ |
| Scale system | 8 concrete scales, withDomain(), buildTicksConstrained() | ✓ |
| Viewport | OiChartViewport (immutable), OiChartViewportState (mutable), visibleDomainX/Y | ✓ |
| Behavior system | 8 behaviors, buildOverlays(), BehaviorContext, ChartBehaviorHost mixin | ✓ |
| Controller | 5 state properties, all methods, OiDefaultChartController | ✓ |
| State models | Selection, Hover, Legend, Focus states with equality/copyWith | ✓ |
| Data contracts | OiChartSeries + 5 family subclasses, OiChartDatum, mapper-first | ✓ |
| Axis model | OiChartAxis<T> with OiTickStrategy class, OiAxisRange, responsive ticks | ✓ |
| Legend model | OiChartLegendConfig, OiChartLegendItem, wrapBehavior, toggle/focus | ✓ |
| Tooltip model | OiChartTooltipConfig, OiChartTooltipModel, OiChartTooltipEntry | ✓ |
| Annotation/Threshold | OiChartAnnotation (5 types), OiAnnotationStyle, OiChartThreshold | ✓ |
| Style model | OiSeriesStyle with marker, fill, dataLabel, state overrides | ✓ |
| Animation config | OiChartAnimationConfig, OiPhaseAnimationConfig, per-series override | ✓ |
| Performance config | RenderMode, DecimationStrategy, defaults 5000/10000 | ✓ |
| Streaming | OiStreamingDataSource, OiRingBuffer, OiStreamingSeriesAdapter, appendMode | ✓ |
| Persistence model | OiPersistedViewport, OiPersistedSelection, OiChartSettings v2 | ✓ |
| Persistence driver | OiChartSettingsDriverBinding with key, driver, autoSave, restoreOnInit | ✓ |
| Extension hooks | OiChartExtension with 7 lifecycle hooks | ✓ |
| Sync coordinator | OiChartSyncCoordinator with broadcastHover/Viewport, listeners | ✓ |
| Formatter contexts | OiAxisFormatContext, OiTooltipFormatContext, typed typedefs | ✓ |
| Accessibility config | OiChartAccessibilityConfig, OiChartSummaryData, OiDetectedChartInsight | ✓ |
| Accessibility bridge | OiChartAccessibilityBridge with typed announce methods, OiNoOpAccessibilityBridge | ✓ |
| Decimation | decimateMinMax, decimateLttb, selectDecimationStrategy | ✓ |
| Utilities | chart_math, path_utils, label_collision | ✓ |
| Component widgets | 12 widgets (axis, legend, tooltip, crosshair, brush, zoom, annotation, empty/loading/error, surface, toggle) | ✓ |
| Primitives | OiChartCanvas, OiChartLayer, OiChartHitTester, painters | ✓ |
| Family base composites | 5 bases (Cartesian, Polar, Matrix, Hierarchical, Flow) with behavior mixin | ✓ |

---

## 2. Chart Type Catalog — 100% Complete

All 18 v1 chart types from the concept exist and are exported:

| Chart | Family | File | Modes/Variants |
|-------|--------|------|----------------|
| OiLineChart | Cartesian | `oi_line_chart/` | straight/stepped/smooth, stacked, showPoints, compact |
| OiAreaChart | Cartesian | `oi_area_chart/` | fillOpacity, stacked, showLine |
| OiBarChart | Cartesian | `oi_bar_chart/` | grouped/stacked/horizontal |
| OiScatterPlot | Cartesian | `oi_scatter_plot.dart` | (named OiScatterPlot not OiScatterChart) |
| OiBubbleChart | Cartesian | `oi_bubble_chart/` | size mapping |
| OiComboChart | Cartesian | `oi_combo_chart.dart` | mixed line/bar/scatter/area |
| OiCandlestickChart | Cartesian | `oi_candlestick_chart/` | OHLC with bull/bear colors |
| OiPieChart | Polar | `oi_pie_chart.dart` | built-in donut mode |
| OiDonutChart | Polar | `oi_donut_chart.dart` | convenience wrapper |
| OiRadarChart | Polar | `oi_radar_chart.dart` | multi-axis comparison |
| OiGauge | Metric | `oi_gauge.dart` | radial meter |
| OiHeatmap | Matrix | `oi_heatmap.dart` | cell-based density |
| OiTreemap | Hierarchical | `oi_treemap.dart` | space-filling hierarchy |
| OiSankey | Flow | `oi_sankey.dart` | weighted flow |
| OiFunnelChart | Specialized | `oi_funnel_chart.dart` | stage drop-off |
| OiSparkline | Compact | `oi_sparkline.dart` | inline trend |
| OiCartesianChart | Base | `oi_cartesian_chart.dart` | generic x/y base |
| OiPolarChart | Base | `oi_polar_chart.dart` | generic radial base |

---

## 3. Remaining Gaps

### Gap 3.1 — Composite wiring: Streaming adapter lifecycle NOT managed

**Concept:** Composites should create `OiStreamingSeriesAdapter` for series with `streamingSource`, attach on mount, detach on dispose, rebuild on data emission.
**Actual:** `ChartStreamingHost` mixin exists in `_chart_streaming_host.dart` but NO composite mixes it in. Series accept `streamingSource` but composites ignore it.
**Fix:** Mix `ChartStreamingHost` into `_OiCartesianChartState` and other composites. Call `attachStreamingAdapters()` in `initState`, `detachStreamingAdapters()` in `dispose`. Override `streamingSeries` getter. On adapter notification, `setState` to trigger rebuild with `streamingDataFor(seriesId)`.

### Gap 3.2 — Composite wiring: Sync group registration NOT wired

**Concept:** Composites register with `OiChartSyncCoordinator` on mount and unregister on dispose.
**Actual:** `syncGroup` parameter accepted on `OiCartesianChart` but never used in lifecycle. No composite calls `OiChartSyncProvider.maybeOf(context)`.
**Fix:** In `ChartBehaviorHost.attachBehaviors()`, look up `OiChartSyncProvider.maybeOf(context)`. If found and `syncGroup` is set, register viewport/selection/crosshair listeners. Unregister in `disposeBehaviorHost()`.

### Gap 3.3 — Composite wiring: Persistence save/restore NOT wired

**Concept:** Composites restore chart settings on mount and save on controller state change.
**Actual:** `OiChartSettings? settings` param accepted on `OiCartesianChart` but never read or written.
**Fix:** In `initState`, if `settings != null`, restore controller state (hiddenSeriesIds → legendState, viewport → viewportState). Add controller listener that persists changes to settings via `OiChartSettingsDriverBinding` when provided.

### Gap 3.4 — Composite wiring: Data normalization NOT invoked

**Concept:** Composites normalize raw series data → `OiChartDatum` lists through scales, then apply decimation.
**Actual:** `normalizeSeries()` function exists in `oi_chart_datum.dart` but no composite calls it. `seriesBuilder` receives raw series, not normalized datums.
**Fix:** In cartesian chart build, optionally call `normalizeSeries()` on each visible series. Apply decimation via `selectDecimationStrategy()` when `performance?.decimation != none`. Expose normalized datums as secondary data for series builder.

### Gap 3.5 — Convention: ~19 raw `Text()` in chart composites

**Files with raw `Text()` (not yet converted to `OiLabel`):**
- `oi_line_chart.dart` (2)
- `oi_candlestick_chart.dart` (2)
- `oi_bubble_chart.dart` (2), `oi_bubble_chart_legend.dart` (1), `oi_bubble_chart_size_legend.dart` (2)
- `oi_scatter_plot.dart` (2)
- `oi_radar_chart.dart` (1)
- `oi_heatmap.dart` (3)
- `oi_treemap.dart` (2)
- `oi_gauge.dart` (1)
- `oi_chart_series_toggle.dart` (1)

**Fix:** Replace each `Text()` → `OiLabel.caption()` or `OiLabel.body()`. These are in charts that were migrated before the convention fix pass (Phase 2 of last plan fixed tooltip/bar/pie/funnel/sankey/combo/area/legend but missed these).

### Gap 3.6 — Convention: ~10 hardcoded `Color(0x...)` fallbacks in components

**Files:**
- `oi_chart_tooltip_widget.dart` — 5 fallback colors (secondary text, shadow)
- `oi_chart_annotation_layer.dart` — 2 fallbacks (line, band)
- `oi_chart_crosshair_widget.dart` — 1 fallback
- `oi_chart_axis_widget.dart` — 2 fallbacks (tick labels, title)

**Assessment:** All have theme-first resolution chains (`theme?.value ?? fallback`). The concept says "all colors from theme, never hardcoded." These are defensive fallbacks, not primary styling.
**Fix:** Could replace with `context.colors.outline` or `context.colors.textMuted` but requires BuildContext access in painters (which currently only receive theme data). Low priority.

### Gap 3.7 — No `OiChartWidget` abstract base class

**Concept:** Section 3.1 defines `OiChartWidget` as the common abstract base for all chart composites, with shared props (label, semanticLabel, theme, legend, behaviors, annotations, thresholds, etc.).
**Actual:** No common base. Each chart independently declares its own props. Family bases (OiCartesianChart, etc.) share some props but concrete charts (OiLineChart, OiPieChart, etc.) have independent prop sets.
**Fix:** Create abstract `OiChartWidget` that declares the shared prop surface. Family bases extend it. Concrete charts extend family bases. This is a significant refactor — every chart constructor would change.
**Alternative:** Document this as an intentional deviation — keeping charts as independent StatefulWidgets is simpler and avoids deep inheritance.

### Gap 3.8 — `OiSeriesStyle.dashed()` factory missing

**Concept:** Example shows `style: OiSeriesStyle.dashed()` as a convenience factory.
**Actual:** No factory constructors on OiSeriesStyle. Users must write `OiSeriesStyle(dashPattern: [5, 3])`.
**Fix:** Add convenience factories:
```dart
factory OiSeriesStyle.dashed({Color? strokeColor}) => OiSeriesStyle(dashPattern: const [5, 3], strokeColor: strokeColor);
factory OiSeriesStyle.dotted({Color? strokeColor}) => OiSeriesStyle(dashPattern: const [2, 3], strokeColor: strokeColor);
```

### Gap 3.9 — OiScatterPlot naming differs from concept

**Concept:** `OiScatterChart<T>`
**Actual:** `OiScatterPlot` (no generic, different name)
**Assessment:** Minor naming inconsistency. The widget works correctly.
**Fix:** Either rename to `OiScatterChart<T>` (breaking) or add a typedef: `typedef OiScatterChart<T> = OiScatterPlot;`

### Gap 3.10 — Tier B/C charts not implemented

**Concept lists these as second-wave:**
- OiHistogram, OiWaterfallChart, OiBoxPlotChart (Cartesian)
- OiRangeAreaChart, OiRangeBarChart (Cartesian)
- OiRadialBarChart, OiPolarAreaChart (Polar)
- OiSunburstChart (Hierarchical)
- OiCalendarHeatmap (Matrix)
- OiStepLineChart, OiSplineChart, OiStepAreaChart (Cartesian — partially covered by OiLineChart modes)
- OiAlluvialChart, OiIcicleChart (Flow/Hierarchical)
- OiSparkBar, OiWinLossChart (Compact)

**Status:** None implemented. These are explicitly Tier B/C in the concept.

### Gap 3.11 — Module charts not implemented

**Concept defines Tier 4 modules:**
- OiAnalyticsDashboard
- OiChartExplorer
- OiKpiBoard

**Status:** None implemented. These depend on mature chart + sync infrastructure.

---

## 4. Test Coverage Gaps

### 56 test files, 671 tests. Missing areas:

| Area | Current Tests | Gap |
|------|--------------|-----|
| Scale types | 81+ tests in oi_chart_scale_test.dart + withDomain test | ✓ Complete |
| Controller | 18 tests | ✓ Complete |
| Hit tester | 25 tests | ✓ Complete |
| All 8 behaviors | 9 test files covering all | ✓ Complete |
| State models | 12 tests | ✓ Complete |
| Settings persistence | 34 tests (settings + driver binding) | ✓ Complete |
| Component widgets | 7 tests | Basic — **needs tick rendering, tooltip timing depth** |
| Legend widget | 17 tests | ✓ Complete |
| Theme | 6 tests | Basic — **needs override chain, sub-theme inheritance** |
| Integration (cartesian) | 12+ tests | Basic — **needs zoom/pan round-trip, sync 2-chart, streaming** |
| Chart composites | 24 test files | Per-chart basic render — **needs interaction, data binding depth** |
| **Golden tests** | 0 | ❌ **Not implemented** |
| **Performance tests** | 0 | ❌ **Not implemented** (1k/10k points) |
| **Streaming integration** | 0 | ❌ **No test verifies streaming data updates trigger chart rebuild** |
| **Sync integration** | 0 | ❌ **No test verifies 2-chart sync coordination** |
| **Persistence integration** | 0 | ❌ **No test verifies save→restore round-trip in composite** |

---

## 5. Priority-Ordered Fix List

### P0 — Blocks real-world usage

1. **Wire streaming adapter into composites** — streaming data won't work without this
2. **Wire sync group registration** — chart synchronization won't work
3. **Wire persistence save/restore** — user preferences won't persist

### P1 — Convention compliance

4. **Replace 19 remaining `Text()`** → `OiLabel` in line, candlestick, bubble, scatter, radar, heatmap, treemap, gauge, series toggle
5. **Add `OiSeriesStyle.dashed()` / `.dotted()` factories** — DX improvement the concept explicitly shows

### P2 — Completeness

6. **Wire data normalization + decimation into cartesian chart build** — performance won't scale without this
7. **Add integration tests** — streaming update, sync 2-chart, persistence round-trip, zoom/pan

### P3 — Nice-to-have

8. **Document OiChartWidget base class deviation** (using independent widgets instead of deep inheritance)
9. **Add OiScatterChart typedef** for concept naming alignment
10. **Reduce hardcoded color fallbacks** in component painters where feasible

### P4 — Future (not v1)

11. Tier B charts (histogram, waterfall, boxplot, range, radial bar, sunburst, etc.)
12. Tier C charts (step line, spline, alluvial, icicle, sparkbar, win/loss)
13. Modules (OiAnalyticsDashboard, OiChartExplorer, OiKpiBoard)
14. Golden tests
15. Performance benchmarks

---

## Summary Statistics

| Category | Complete | Partial | Missing | Total |
|----------|----------|---------|---------|-------|
| Architecture | 3/3 | 0 | 0 | 100% |
| Foundation contracts | 24/24 | 0 | 0 | 100% |
| Data contracts | 21/21 | 0 | 0 | 100% |
| Primitives + Components | 18/18 | 0 | 0 | 100% |
| Family base composites | 5/5 | 0 | 0 | 100% |
| V1 chart widgets | 18/18 | 0 | 0 | 100% |
| Composite wiring | 1/5 | 0 | 4 | 20% |
| Convention compliance | — | 2 issues | 0 | ~85% |
| Test coverage | 48/56 areas | 3 | 5 | ~86% |
| Tier B/C charts | 0/16+ | 0 | 16+ | 0% |
| Modules | 0/3 | 0 | 3 | 0% |

**V1 scope (excluding Tier B/C/Modules): ~92% complete.**
**The 8% gap is entirely in composite wiring (streaming/sync/persistence/normalization) and convention polish.**
