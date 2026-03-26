# obers_ui_charts — Gap Analysis vs Concept (2026-03-26)

**Concept reference:** `concept/obers_ui_charts.md`
**Spec reference:** `concept/obers_ui_charts-spec.md`
**Previous gap analysis:** `concept/25-03-chart-gaps.md`
**Overall:** 560 tests pass, 0 analysis errors. Foundation layer is ~95% complete. Remaining gaps are in dedicated chart widgets, convention compliance, and advanced wiring.

---

## 1. Foundation Layer — Fully Complete ✓

All foundation contracts from the concept are implemented:

| Concept Item | Status | File |
|---|---|---|
| OiChartThemeData (9 sub-themes + state theme) | ✓ | obers_ui main: `oi_chart_theme_data.dart` |
| OiChartPalette (categorical, semantic, gradients) | ✓ | obers_ui main: `oi_chart_palette.dart` |
| OiChartScale<T> + 8 concrete scales | ✓ | `foundation/oi_chart_scale.dart` + 8 files |
| OiChartViewport + visibleDomainX/Y | ✓ | `foundation/oi_chart_viewport.dart` |
| OiChartViewportState (mutable zoom/pan) | ✓ | `foundation/oi_chart_viewport.dart` |
| OiChartBehavior + buildOverlays | ✓ | `foundation/oi_chart_behavior.dart` |
| OiChartBehaviorContext (7 fields) | ✓ | `foundation/oi_chart_behavior.dart` |
| OiChartController (5 states + methods) | ✓ | `foundation/oi_chart_controller.dart` |
| OiDefaultChartController | ✓ | `models/oi_default_chart_controller.dart` |
| 8 behaviors (tooltip, crosshair, zoom, selection, brush, keyboard, sync, toggle) | ✓ | `behaviors/` + `foundation/` |
| OiChartAccessibilityConfig | ✓ | `foundation/oi_chart_accessibility_config.dart` |
| OiChartSummaryData / OiChartAccessibilitySummary | ✓ | Same file (typedef alias) |
| OiDetectedChartInsight | ✓ | `foundation/oi_chart_accessibility_bridge.dart` |
| OiChartAnimationConfig + OiSeriesAnimationConfig | ✓ | `foundation/oi_chart_animation_config.dart` |
| OiChartPerformanceConfig (5000/10000 defaults) | ✓ | `foundation/oi_chart_performance_config.dart` |
| OiChartSettings (persistence) | ✓ | `models/oi_chart_settings.dart` |
| OiChartSettingsDriverBinding | ✓ | `foundation/oi_chart_settings_driver_binding.dart` |
| OiChartExtension (7 lifecycle hooks) | ✓ | `foundation/oi_chart_extension.dart` |
| OiChartSyncCoordinator + broadcastHover/Viewport | ✓ | `foundation/oi_chart_sync_coordinator.dart` |
| OiChartSyncProvider (InheritedWidget) | ✓ | `foundation/oi_chart_sync_group.dart` |
| Formatter typedefs (OiAxisFormatContext, OiTooltipFormatContext) | ✓ | `foundation/oi_chart_formatters.dart` |
| Decimation utilities (minMax, LTTB) | ✓ | `foundation/oi_decimation.dart` |
| Streaming (OiStreamingDataSource, OiRingBuffer, OiStreamingSeriesAdapter) | ✓ | `foundation/oi_streaming_*.dart` |
| OiStreamingAppendMode + windowDuration | ✓ | `foundation/oi_streaming_series_adapter.dart` |

---

## 2. Data Contract Layer — Fully Complete ✓

| Concept Item | Status | File |
|---|---|---|
| OiChartSeries<T> (id, label, data, style, animation, legend, streaming) | ✓ | `models/oi_chart_series.dart` |
| OiCartesianSeries (xMapper, yMapper, pointLabel, isMissing, yAxisId) | ✓ | `models/oi_cartesian_series.dart` |
| OiPolarSeries | ✓ | `models/oi_polar_series.dart` |
| OiMatrixSeries | ✓ | `models/oi_matrix_series.dart` |
| OiHierarchicalSeries | ✓ | `models/oi_hierarchical_series.dart` |
| OiFlowSeries | ✓ | `models/oi_flow_series.dart` |
| OiChartDatum (normalized internal model) | ✓ | `models/oi_chart_datum.dart` |
| OiChartAxis<T> (scale, position, formatter, ticks, domain, overflow) | ✓ | `composites/oi_chart_axis.dart` |
| OiTickStrategy (class with maxCount, minSpacingPx, niceValues) | ✓ | `composites/oi_chart_axis.dart` |
| OiAxisRange<T> | ✓ | `models/oi_axis_range.dart` |
| OiChartLegendConfig (position, wrap, toggle, focus, builder) | ✓ | `models/oi_chart_legend_config.dart` |
| OiChartLegendItem (seriesId, label, color, markerShape, visible, emphasized) | ✓ | `composites/oi_chart_legend.dart` |
| OiChartTooltipConfig + OiChartTooltipModel | ✓ | `foundation/oi_chart_tooltip.dart` |
| OiChartAnnotation + OiAnnotationType + OiAnnotationStyle | ✓ | `models/oi_chart_annotation.dart` |
| OiChartThreshold + OiThresholdLabelPosition | ✓ | `models/oi_chart_threshold.dart` |
| OiSeriesStyle (stroke, fill, marker, dataLabel, state overrides) | ✓ | `models/oi_series_style.dart` |
| OiChartMarkerStyle (shape, size, fill, stroke, visible, dashPattern) | ✓ | `foundation/oi_chart_marker.dart` |
| OiSeriesLegendConfig (show, label, iconBuilder, order) | ✓ | `models/oi_series_legend_config.dart` |
| OiColorScale (linear, gradient) | ✓ | `models/oi_color_scale.dart` |
| OiPolarAngleAxis + OiPolarRadiusAxis | ✓ | `models/oi_polar_axis.dart` |
| State models (Selection, Hover, Legend, Focus) | ✓ | `models/oi_chart_state_models.dart` |

---

## 3. Primitives + Components Layer — Complete ✓

| Concept Item | Status | File |
|---|---|---|
| OiChartCanvas (clip, layer ordering, DPR) | ✓ | `foundation/oi_chart_canvas.dart` |
| OiChartLayer (paint, zOrder) | ✓ | `foundation/oi_chart_layer.dart` |
| OiChartHitTester (hitTest, hitTestAll, binary search) | ✓ | `foundation/oi_chart_hit_tester.dart` |
| OiGridPainter | ✓ | `foundation/oi_chart_grid_painter.dart` |
| OiAxisPainter | ✓ | `foundation/oi_chart_axis_painter.dart` |
| OiChartMarker (painter) | ✓ | `foundation/oi_chart_marker.dart` |
| OiChartAxisWidget | ✓ | `components/oi_chart_axis_widget.dart` |
| OiChartLegend (widget) | ✓ | `composites/oi_chart_legend.dart` |
| OiChartTooltipWidget | ✓ | `components/oi_chart_tooltip_widget.dart` |
| OiChartCrosshairWidget | ✓ | `components/oi_chart_crosshair_widget.dart` |
| OiChartBrushWidget | ✓ | `components/oi_chart_brush_widget.dart` |
| OiChartZoomControls | ✓ | `components/oi_chart_zoom_controls.dart` |
| OiChartAnnotationLayer | ✓ | `components/oi_chart_annotation_layer.dart` |
| OiChartEmptyState | ✓ | `components/oi_chart_empty_state.dart` |
| OiChartLoadingState | ✓ | `components/oi_chart_loading_state.dart` |
| OiChartErrorState | ✓ | `components/oi_chart_error_state.dart` |
| OiChartSeriesToggle | ✓ | `composites/oi_chart_series_toggle.dart` |
| OiChartSurface | ✓ | `components/oi_chart_surface.dart` |

---

## 4. Family Base Composites — Complete ✓

| Concept Item | Status | Props | Wiring |
|---|---|---|---|
| OiCartesianChart<T> | ✓ | xAxis, yAxes, series, behaviors, controller, legend, annotations, thresholds, settings, theme, syncGroup, accessibility, animation, performance, emptyState, loadingState, errorState | Behavior lifecycle, theme fallback, "all hidden" state, single-point padding, zoom/pan viewport |
| OiPolarChart<T> | ✓ | angleAxis, radiusAxis, series, behaviors, controller, centerContent | Behavior lifecycle, all-hidden, legend-aware visibility |
| OiMatrixChart<T> | ✓ | xAxis, yAxis, colorScale, series, behaviors, controller | Behavior lifecycle, all-hidden |
| OiHierarchicalChart<TNode> | ✓ | data, nodeId, parentId, value, label, behaviors, controller | Behavior lifecycle, all-hidden, tree building |
| OiFlowChart<TNode, TLink> | ✓ | nodes, links, nodeId, sourceId, targetId, linkValue, behaviors, controller | Behavior lifecycle, all-hidden |

---

## 5. Dedicated Chart Widgets — GAPS

The concept specifies a v1 chart catalog. Here's what exists vs what's missing:

### Existing (14 charts)

| Chart | File | Family |
|---|---|---|
| OiLineChart | `composites/oi_line_chart/` | Cartesian |
| OiBarChart | `composites/oi_bar_chart/` | Cartesian |
| OiBubbleChart | `composites/oi_bubble_chart/` | Cartesian |
| OiScatterPlot | `composites/oi_scatter_plot.dart` | Cartesian |
| OiPieChart | `composites/oi_pie_chart.dart` | Polar |
| OiRadarChart | `composites/oi_radar_chart.dart` | Polar |
| OiGauge | `composites/oi_gauge.dart` | Polar/Metric |
| OiHeatmap | `composites/oi_heatmap.dart` | Matrix |
| OiTreemap | `composites/oi_treemap.dart` | Hierarchical |
| OiSankey | `composites/oi_sankey.dart` | Flow |
| OiFunnelChart | `composites/oi_funnel_chart.dart` | Flow |
| OiSparkline | `composites/oi_sparkline.dart` | Cartesian/Compact |
| OiCartesianChart | `composites/oi_cartesian_chart.dart` | Family base |
| OiPolarChart | `composites/oi_polar_chart.dart` | Family base |

### Missing from v1 concept (3 charts)

| Chart | Priority | How to Implement |
|---|---|---|
| **OiAreaChart** | Tier A | Create `composites/oi_area_chart.dart` wrapping `OiCartesianChart` with area fill between line and x-axis. Needs `OiAreaSeries<T>` extending `OiCartesianSeries` with `showLine`, `fillOpacity`, `stackMode` fields. Painter fills area path below the line using `OiSeriesFill`. |
| **OiComboChart** | Tier A | Create `composites/oi_combo_chart.dart` accepting `List<OiCartesianSeries>` of mixed types (line + bar + scatter). Key: the `OiCartesianChart.seriesBuilder` must iterate series and dispatch to type-specific painters. Need a `OiCartesianSeriesRenderer` registry or switch on series type. |
| **OiDonutChart** | Tier A | Create `composites/oi_donut_chart.dart` as `OiPieChart` variant with `innerRadiusFraction` (0.0–1.0), center content widget, and donut-specific arc rendering. Can be a factory constructor on `OiPieChart` or standalone widget. |

### Missing from v1 concept (1 financial chart)

| Chart | Priority | How to Implement |
|---|---|---|
| **OiCandlestickChart** | Tier A | Create `composites/oi_candlestick_chart.dart` built on `OiCartesianChart`. Needs `OiCandlestickSeries<T>` with `open`, `high`, `low`, `close` mappers. Painter renders candlestick bodies (open→close) and wicks (low→high). Green/red derived from open vs close comparison. |

### Missing from Tier B (expansion)

These are listed in the concept but not yet prioritized:
- OiHistogram (binned distribution)
- OiWaterfallChart (stepwise contribution)
- OiBoxPlotChart (quartile summary)
- OiRangeAreaChart / OiRangeBarChart
- OiRadialBarChart
- OiPolarAreaChart
- OiSunburstChart
- OiCalendarHeatmap

### Missing from Tier C (long-tail)
- OiStepLineChart, OiSplineChart, OiStepAreaChart
- OiAlluvialChart
- OiIcicleChart
- OiSparkBar, OiWinLossChart

### Missing Modules (Tier 4)

The concept describes chart modules — these don't exist yet:
- **OiAnalyticsDashboard** — assembled multi-chart dashboard with sync
- **OiChartExplorer** — interactive data exploration workspace
- **OiKpiBoard** — single-value metric layout with sparklines

---

## 6. Convention Compliance Gaps

### Raw `Text()` instead of `OiLabel`

**37 occurrences** of `Text()` across chart files. Most are in tooltip rendering and fallback content:
- `foundation/oi_chart_tooltip.dart` — 5 uses in `_DefaultTooltipContent`
- `components/oi_chart_tooltip_widget.dart` — tooltip fallback content
- `composites/oi_chart_legend.dart` — legend item labels
- Various chart composites in fallback/internal rendering

**Fix:** Replace all `Text()` → `OiLabel.body()` or appropriate variant. The tooltip should use `OiLabel.caption()` for secondary text.

### Hardcoded Colors

**5 hardcoded `Color(0x...)` values** used as fallbacks when theme is null:
- `components/oi_chart_crosshair_widget.dart` — `Color(0x80888888)`
- `components/oi_chart_axis_widget.dart` — `Color(0xFF9E9E9E)`, `Color(0xFF666666)`, `Color(0xFF444444)`
- `components/oi_chart_annotation_layer.dart` — `Color(0xFF9E9E9E)`

**Fix:** These are defensive fallbacks — acceptable in isolation, but the concept says "no hardcoded colors." Replace with `context.colors.outline` or similar theme-derived tokens, or ensure the theme is always resolved before painting.

### `OiChartAccessibilityBridge` nullable vs non-nullable

**Concept:** `OiChartAccessibilityBridge accessibility` (non-nullable in BehaviorContext).
**Actual:** `OiChartAccessibilityBridge? accessibilityBridge` (nullable).
**Fix:** Create a `_NoOpAccessibilityBridge` default implementation and pass it in `ChartBehaviorHost.attachBehaviors()` so the field can be non-nullable. This is a minor breaking change but improves behavior safety.

---

## 7. Persistence Model Gaps

### `OiPersistedViewport` and `OiPersistedSelection` types

**Concept:** `viewport: OiPersistedViewport?` (typed class with xMin/xMax/yMin/yMax), `selection: OiPersistedSelection?`.
**Actual:** `viewportWindow: Rect?`, `selectedSeriesIndex: int?` + `selectedDataIndex: int?`.
**Fix:** Create `OiPersistedViewport` class with `xMin`, `xMax`, `yMin`, `yMax` doubles. Create `OiPersistedSelection` with `Set<OiChartDataRef>` serialization. Update `OiChartSettings.toJson/fromJson`.

### `expandedLegendGroups` type

**Concept:** `Map<String, bool>` (tracks both expanded and collapsed).
**Actual:** `Set<String>` (only tracks expanded).
**Fix:** Change to `Map<String, bool>` and update serialization.

---

## 8. Composite Wiring Gaps

While composites have the `ChartBehaviorHost` mixin wired, some deeper orchestration from the concept is still incomplete:

### Data normalization pipeline not fully wired

**Concept:** Composites should convert raw series data → `OiChartDatum` lists through the scale system, then apply decimation.
**Actual:** `normalizeSeries()` function exists in `oi_chart_datum.dart`. Composites pass raw series to `seriesBuilder`. No automatic normalization or decimation invocation.
**Fix:** In `OiCartesianChart.build()`, optionally normalize visible series into `List<OiChartDatum>` and expose both raw and normalized data to the series builder.

### Streaming adapter lifecycle not managed by composites

**Concept:** Composites should attach `OiStreamingSeriesAdapter` for series with `streamingSource`, listen for changes, rebuild.
**Actual:** Series accept `streamingSource` but composites don't create or manage adapters.
**Fix:** Create `ChartStreamingHost` mixin that manages adapter lifecycle in `initState`/`didUpdateWidget`/`dispose`.

### Sync group registration not wired

**Concept:** Composites register with `OiChartSyncCoordinator` on mount, unregister on dispose.
**Actual:** `syncGroup` parameter accepted but not used in lifecycle.
**Fix:** In `initState`, look up `OiChartSyncProvider.maybeOf(context)` and register. In `dispose`, unregister.

### Persistence save/restore not wired

**Concept:** Composites restore chart settings on mount, persist on state change.
**Actual:** `OiChartSettings` and `OiChartSettingsDriverBinding` exist but composites don't use them.
**Fix:** In `initState`, if `settings` is provided, restore controller state. Listen to controller changes and auto-save via `OiChartSettingsDriverBinding`.

---

## 9. Animation Enum Gap

**Concept:** `OiChartEnterAnimation` (grow/fade/slide/none), `OiChartUpdateAnimation` (morph/crossfade/none), `OiChartExitAnimation` (shrink/fade/none).
**Actual:** Class-based `OiPhaseAnimationConfig` with `duration` + `curve` per phase. More flexible but doesn't have named animation modes.
**Assessment:** Intentional design deviation — class-based is more flexible. **Document this deviation.** Optionally add enums as convenience factories:
```dart
extension OiChartEnterAnimations on OiPhaseAnimationConfig {
  static OiPhaseAnimationConfig get grow => ...;
  static OiPhaseAnimationConfig get fade => ...;
}
```

---

## 10. Responsive Integration Gap

**Concept:** Many chart props should support `OiResponsive<T>`:
- legend position
- max tick count
- label rotation
- marker visibility
- axis label truncation mode
- data label visibility
- complexity mode (mini/standard/detailed)

**Actual:** Only `maxVisibleTicks: OiResponsive<int>?` and `legend position: OiResponsive<OiChartLegendPosition>?` use `OiResponsive`. Other props are static.
**Fix:** Add `OiResponsive<T>` support to:
- `OiChartAxis.labelOverflow` → `OiResponsive<OiChartLabelOverflow>?`
- `OiSeriesStyle.marker.visible` → could accept responsive, but marker is nested
- New `OiChartComplexity` enum (mini/standard/detailed) with `OiResponsive<OiChartComplexity>? complexity` on chart widgets

---

## 11. Test Coverage Gaps

### 47 test files exist. Missing areas:

| Area | Status | Gap |
|---|---|---|
| Scale tests (8 types) | ✓ 81+ tests | Complete |
| Controller tests | ✓ 18 tests | Complete |
| Hit tester tests | ✓ 25 tests | Complete |
| Behavior tests (5 of 8) | ✓ | Missing: tooltip behavior, crosshair behavior, brush behavior |
| Component widget tests | ✓ 7 tests | Basic — needs deeper tests for axis tick rendering, tooltip timing |
| Composite integration | ✓ 12 tests | Basic — needs zoom/pan round-trip, sync 2-chart, streaming update |
| Theme tests | ✓ 6 tests | Basic palette/sub-theme access |
| State model tests | ✓ 12 tests | Complete |
| Style model tests | ✓ 8 tests | Complete |
| **Golden tests** | ❌ 0 | Not implemented |
| **Performance tests** | ❌ 0 | Not implemented (1k/10k points) |
| **Legend widget tests** | ❌ 0 | Toggle, keyboard nav, responsive position |
| **Tooltip behavior tests** | ❌ 0 | Show/hide timing, anchor modes |
| **Crosshair/brush behavior tests** | ❌ 0 | Rendering, mode switching |

---

## 12. Priority-Ordered Fix List

### P0 — Missing chart types from v1 catalog

1. **OiAreaChart** — dedicated widget + OiAreaSeries with fill, stack mode
2. **OiDonutChart** — OiPieChart variant with inner radius + center content
3. **OiComboChart** — mixed series types in one cartesian chart

### P1 — Missing wiring in composites

4. **Wire streaming adapter lifecycle** — composites should manage OiStreamingSeriesAdapter
5. **Wire sync group registration** — register/unregister on mount/dispose
6. **Wire persistence save/restore** — restore on init, save on change
7. **Wire data normalization** — normalize raw series → OiChartDatum + apply decimation

### P2 — Convention compliance

8. **Replace 37 `Text()` → `OiLabel`** across tooltip, legend, chart widgets
9. **Replace 5 hardcoded colors** → theme-derived tokens
10. **Make accessibility bridge non-nullable** with no-op default

### P3 — Data model enrichment

11. **Create OiPersistedViewport and OiPersistedSelection types**
12. **Change legendExpandedGroups from Set → Map**
13. **Add OiResponsive support** to more chart props (complexity, label overflow)
14. **Document animation enum deviation** from concept

### P4 — Tier A financial chart

15. **OiCandlestickChart** + OiCandlestickSeries (open/high/low/close mappers)

### P5 — Test coverage

16. **Legend widget tests** — toggle, keyboard nav, responsive
17. **Tooltip/crosshair/brush behavior tests**
18. **Golden tests** for visual regression
19. **Performance tests** (1k/10k points)
20. **Integration tests** — zoom/pan round-trip, sync group, streaming, persistence

### P6 — Tier B expansion charts

21. OiHistogram, OiWaterfallChart, OiBoxPlotChart
22. OiRangeAreaChart, OiRangeBarChart
23. OiRadialBarChart, OiPolarAreaChart
24. OiSunburstChart, OiCalendarHeatmap

### P7 — Modules (Tier 4)

25. OiAnalyticsDashboard
26. OiChartExplorer
27. OiKpiBoard

---

## Summary Statistics

| Category | Complete | Partial | Missing |
|----------|----------|---------|---------|
| Foundation (themes, scales, behaviors, config) | 24/24 | 0 | 0 |
| Data contracts (series, axis, legend, tooltip, annotation) | 21/21 | 0 | 0 |
| Primitives + Components | 18/18 | 0 | 0 |
| Family base composites | 5/5 | 0 | 0 |
| Composite wiring (normalization, streaming, sync, persistence) | 1/5 | 3/5 | 1/5 |
| V1 chart widgets | 14/18 | 0 | 4 |
| Convention compliance | — | 3 issues | — |
| Test coverage | 47 files | 5 gaps | 0 |
| Tier B/C/Module charts | 0/16+ | 0 | 16+ |

**Foundation + contracts: 100% complete.**
**V1 chart catalog: 78% complete (14/18 charts).**
**Composite wiring: 20% complete (behavior lifecycle only).**
**Overall spec alignment: ~85% for v1 scope.**
