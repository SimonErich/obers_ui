## Overview

Close remaining v1 gaps: add 4 missing chart widgets (Area, Donut, Combo, Candlestick), wire composite orchestration (streaming, sync, persistence, normalization), fix convention violations, expand test coverage.

**Spec**: `concept/25-03-chart-gaps-2.md` (all gaps with fix details)
**Concept**: `concept/obers_ui_charts.md` (full architecture)

## Context

- **Structure**: tier-based, charts follow multi-file pattern (data, painter, legend, accessibility, theme per chart)
- **State management**: `ChangeNotifier`-based `OiChartController`, `ChartBehaviorHost` mixin on State
- **Reference implementations**: `lib/src/composites/oi_line_chart/` (multi-file chart), `lib/src/composites/oi_pie_chart.dart` (single-file chart with donut mode), `lib/src/composites/_chart_behavior_host.dart` (mixin pattern)
- **Assumptions**: OiDonutChart is a factory/variant of OiPieChart (already has `donut: true` mode). OiComboChart wraps OiCartesianChart with multi-type series dispatch. Animation enums are intentional class-based deviation — document only.

## Plan

### Phase 1: OiAreaChart + OiDonutChart

- **Goal**: Add the two simplest missing v1 charts
- [ ] `lib/src/composites/oi_area_chart/oi_area_chart.dart` — `OiAreaChart<T>` wrapping OiCartesianChart with area fill. Props: series, xAxis, yAxis, fillOpacity, stacked, showLine, showPoints + all shared chart props (behaviors, controller, legend, theme, etc.)
- [ ] `lib/src/composites/oi_area_chart/oi_area_chart_data.dart` — `OiAreaSeries<T>` extending OiCartesianSeries with `fillOpacity: double`, `showLine: bool`, `stackGroup: String?`
- [ ] `lib/src/composites/oi_area_chart/oi_area_chart_painter.dart` — CustomPainter: draw filled area path from data points to x-axis baseline, optional line stroke on top
- [ ] `lib/src/composites/oi_donut_chart.dart` — `OiDonutChart` as convenience widget delegating to `OiPieChart(donut: true, ...)` with `innerRadiusFraction`, `centerContent: Widget?`, typed API
- [ ] Export from `lib/obers_ui_charts.dart`
- [ ] TDD: OiAreaChart renders area fill between line and baseline
- [ ] TDD: OiAreaChart stacked mode stacks series correctly
- [ ] TDD: OiDonutChart renders with center content widget
- [ ] Verify: `dart analyze` && `flutter test`

### Phase 2: OiComboChart + OiCandlestickChart

- **Goal**: Add the two complex missing v1 charts
- [ ] `lib/src/composites/oi_combo_chart.dart` — `OiComboChart<T>` accepting `List<OiCartesianSeries<T>>` of mixed types. Uses `OiCartesianChart` as base. Dispatches each series to appropriate painter (line, bar, scatter, area) based on series runtime type.
- [ ] `lib/src/composites/oi_candlestick_chart/oi_candlestick_chart.dart` — `OiCandlestickChart<T>` built on OiCartesianChart. Time x-axis, OHLC y rendering.
- [ ] `lib/src/composites/oi_candlestick_chart/oi_candlestick_chart_data.dart` — `OiCandlestickSeries<T>` with `open`, `high`, `low`, `close` mappers + `dateMapper`
- [ ] `lib/src/composites/oi_candlestick_chart/oi_candlestick_chart_painter.dart` — Paint body (open→close rect), wicks (low→high lines), green/red coloring from open vs close
- [ ] Export from barrel
- [ ] TDD: OiComboChart renders mixed line+bar series in same coordinate space
- [ ] TDD: OiCandlestickChart renders body and wicks; green when close > open
- [ ] Verify: `dart analyze` && `flutter test`

### Phase 3: Composite Wiring — Streaming + Sync + Persistence

- **Goal**: Wire the four missing orchestration concerns into family composites
- [ ] `lib/src/composites/_chart_streaming_host.dart` — Mixin `ChartStreamingHost`: manage `Map<String, OiStreamingSeriesAdapter>`, attach on initState for series with streamingSource, detach on dispose, listen for changes → setState
- [ ] `lib/src/composites/_chart_behavior_host.dart` — Add sync registration: in `attachBehaviors()`, if syncGroup set, look up `OiChartSyncProvider.maybeOf(context)` and register. In `disposeBehaviorHost()`, unregister.
- [ ] `lib/src/composites/_chart_behavior_host.dart` — Add persistence: if `settings` provided, restore controller state on attach, save on controller changes via listener
- [ ] `lib/src/composites/oi_cartesian_chart.dart` — Mix in `ChartStreamingHost`. In build, normalize visible series via `normalizeSeries()` and apply decimation when `performance.decimation != none`. Pass normalized datums alongside raw series.
- [ ] `lib/src/composites/oi_polar_chart.dart` — Mix in streaming host + persistence
- [ ] `lib/src/composites/oi_matrix_chart.dart` — Same
- [ ] `lib/src/composites/oi_hierarchical_chart.dart` — Same (streaming + persistence, no normalization)
- [ ] `lib/src/composites/oi_flow_chart.dart` — Same
- [ ] TDD: Cartesian chart with streaming source rebuilds on adapter emission
- [ ] TDD: Sync group registration on mount, unregistration on dispose
- [ ] TDD: Persistence round-trip: save → restore → controller state matches
- [ ] Verify: `dart analyze` && `flutter test`

### Phase 4: Convention Compliance

- **Goal**: Fix all Text/Color convention violations; make accessibility bridge non-nullable
- [ ] `lib/src/foundation/oi_chart_tooltip.dart` — Replace all `Text()` → `OiLabel`, `Row`/`Column` → `OiRow`/`OiColumn`, hardcoded `Color(0x...)` → theme tokens
- [ ] `lib/src/components/oi_chart_tooltip_widget.dart` — Same fixes
- [ ] `lib/src/composites/oi_chart_legend.dart` — Replace `Row` → `OiRow`, `Text` → `OiLabel`
- [ ] `lib/src/components/oi_chart_crosshair_widget.dart` — Replace fallback color → theme token
- [ ] `lib/src/components/oi_chart_axis_widget.dart` — Replace 3 fallback colors → theme tokens
- [ ] `lib/src/components/oi_chart_annotation_layer.dart` — Replace fallback color → theme token
- [ ] `lib/src/foundation/oi_chart_accessibility_bridge.dart` — Add `OiNoOpAccessibilityBridge` class
- [ ] `lib/src/composites/_chart_behavior_host.dart` — Pass `OiNoOpAccessibilityBridge()` in `attachBehaviors()` so accessibilityBridge is always non-null
- [ ] `lib/src/foundation/oi_chart_behavior.dart` — Change `accessibilityBridge` from nullable to non-nullable in OiChartBehaviorContext
- [ ] Verify: `dart analyze` && `flutter test`

### Phase 5: Persistence Model + Responsive Expansion

- **Goal**: Enrich persistence types; add OiResponsive to more chart props
- [ ] `lib/src/models/oi_chart_settings.dart` — Create `OiPersistedViewport` (xMin, xMax, yMin, yMax) and `OiPersistedSelection` (serialized refs) classes. Replace `viewportWindow: Rect?` → `viewport: OiPersistedViewport?`, `selectedSeriesIndex/selectedDataIndex` → `selection: OiPersistedSelection?`, `legendExpandedGroups: Set<String>` → `Map<String, bool>`. Update toJson/fromJson/mergeWith.
- [ ] `lib/src/composites/oi_chart_axis.dart` — Change `labelOverflow: OiChartLabelOverflow` → `labelOverflow: OiResponsive<OiChartLabelOverflow>?` (breaking: update callers)
- [ ] `lib/src/composites/oi_cartesian_chart.dart` — Add `complexity: OiResponsive<OiChartComplexity>?` prop
- [ ] `lib/src/models/oi_chart_complexity.dart` — Create `OiChartComplexity` enum (mini/standard/detailed)
- [ ] TDD: OiPersistedViewport round-trips through toJson/fromJson
- [ ] TDD: OiPersistedSelection round-trips correctly
- [ ] Verify: `dart analyze` && `flutter test`

### Phase 6: Test Coverage Expansion

- **Goal**: Fill remaining test gaps from gap analysis
- [ ] `test/src/composites/oi_chart_legend_test.dart` — Toggle series visibility, keyboard navigation (arrow keys), responsive position switching, custom item builder
- [ ] `test/src/behaviors/oi_chart_tooltip_behavior_test.dart` — Show/hide timing with delays, anchor modes (nearestPoint/pointer/xAxis), hover+tap triggers, custom builder
- [ ] `test/src/behaviors/oi_chart_crosshair_behavior_test.dart` — Horizontal/vertical rendering, theme styling, show/hide on hover
- [ ] `test/src/behaviors/oi_chart_brush_behavior_test.dart` — Drag to select, brush rectangle coordinates, domain range output
- [ ] `test/src/composites/oi_area_chart_test.dart` — Area fill rendering, stacked mode, empty data
- [ ] `test/src/composites/oi_combo_chart_test.dart` — Mixed line+bar, shared axes, multi-series
- [ ] `test/src/composites/oi_candlestick_chart_test.dart` — OHLC rendering, green/red coloring, empty data
- [ ] `test/src/composites/oi_donut_chart_test.dart` — Center content, inner radius, segments
- [ ] Verify: `flutter test --coverage`

## Risks / Out of scope

- **Risks**:
  - Phase 4 `accessibilityBridge` non-nullable change breaks any code constructing `OiChartBehaviorContext` without it. Mitigate: provide `OiNoOpAccessibilityBridge` and update all constructors in same commit.
  - Phase 5 persistence model changes break `OiChartSettings.toJson/fromJson`. Mitigate: add schema version migration in fromJson.
  - Phase 2 OiComboChart series dispatch requires runtime type checking — can become fragile if new series types added. Mitigate: use sealed class or visitor pattern.
- **Out of scope**:
  - Golden tests (defer to stable rendering)
  - Performance benchmarks (1k/10k points)
  - Tier B/C charts (histogram, waterfall, boxplot, sunburst, etc.)
  - Modules (OiAnalyticsDashboard, OiChartExplorer, OiKpiBoard)
  - Animation enum creation (intentional class-based deviation)
  - OiApp lazy sync coordinator provisioning (requires main package changes)
