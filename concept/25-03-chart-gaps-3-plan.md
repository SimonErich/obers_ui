## Overview

Close the final 8% v1 gap: wire composite orchestration (streaming, sync, persistence, normalization), fix remaining convention violations, add style factories, and write integration tests proving the wiring works.

**Gap analysis**: `concept/25-03-chart-gaps-3.md` (sections 3.1–3.9, 4, 5)

## Context

- **Structure**: tier-based, `ChartBehaviorHost` + `ChartStreamingHost` mixins on State
- **State management**: `ChangeNotifier`-based `OiChartController`
- **Reference implementations**: `_chart_behavior_host.dart` (mixin pattern), `_chart_streaming_host.dart` (ready but unwired), `oi_chart_datum.dart` (normalizeSeries function)
- **Assumptions**: OiChartWidget abstract base is intentional deviation (documented, not implemented). OiScatterPlot naming kept as-is.

## Plan

### Phase 1: Wire Streaming + Sync + Persistence into Composites

- **Goal**: Make streaming data, chart sync, and settings persistence actually work
- [x] `lib/src/composites/_chart_behavior_host.dart` — Add optional `OiChartSyncGroup? get syncGroup` override. In `attachBehaviors()`, look up `OiChartSyncProvider.maybeOf(context)` → if found + syncGroup set, store ref and add viewport/crosshair listeners. In `disposeBehaviorHost()`, remove listeners. Add `restoreSettings(OiChartSettings?)` method: if non-null, apply hiddenSeriesIds → legendState, viewport → viewportState. Add controller listener that calls `onSettingsChanged` callback when state mutates.
- [x] `lib/src/composites/oi_cartesian_chart.dart` — Mix in `ChartStreamingHost`. Override `streamingSeries` → `widget.series`. Call `attachStreamingAdapters()` in `initState`, `detachStreamingAdapters()` in `dispose`. Override `syncGroup` getter. In `initState`, call `restoreSettings(widget.settings)`. In build, after computing visible series, call `normalizeSeries()` + apply decimation when `widget.performance?.decimationStrategy != OiChartDecimationStrategy.none`.
- [x] `lib/src/composites/oi_polar_chart.dart` — Mix in `ChartStreamingHost`. Override `streamingSeries`, `syncGroup`. Wire initState/dispose.
- [x] `lib/src/composites/oi_matrix_chart.dart` — Same wiring
- [x] `lib/src/composites/oi_hierarchical_chart.dart` — Same (no normalization, no streaming needed for tree data)
- [x] `lib/src/composites/oi_flow_chart.dart` — Same
- [x] TDD: Cartesian chart with streaming source → adapter emits data → chart rebuilds with new data
- [x] TDD: Cartesian chart with syncGroup → registers on mount, unregisters on dispose
- [x] TDD: Cartesian chart with settings → controller state restored from persisted settings on mount
- [x] Verify: `dart analyze` && `flutter test`

### Phase 2: Convention Polish + Style Factories

- **Goal**: Fix remaining 19 raw Text() and add convenience factories
- [x] `lib/src/composites/oi_line_chart/oi_line_chart.dart` — Replace 2 `Text()` → `OiLabel`
- [x] `lib/src/composites/oi_candlestick_chart/oi_candlestick_chart.dart` — Replace 2 `Text()` → `OiLabel`
- [x] `lib/src/composites/oi_bubble_chart/oi_bubble_chart.dart` — Replace 2 `Text()` → `OiLabel`
- [x] `lib/src/composites/oi_bubble_chart/oi_bubble_chart_legend.dart` — Replace 1 `Text()` → `OiLabel`
- [x] `lib/src/composites/oi_bubble_chart/oi_bubble_chart_size_legend.dart` — Replace 2 `Text()` → `OiLabel`
- [x] `lib/src/composites/oi_scatter_plot.dart` — Replace 2 `Text()` → `OiLabel`
- [x] `lib/src/composites/oi_radar_chart.dart` — Replace 1 `Text()` → `OiLabel`
- [x] `lib/src/composites/oi_heatmap.dart` — Replace 3 `Text()` → `OiLabel`
- [x] `lib/src/composites/oi_treemap.dart` — Replace 2 `Text()` → `OiLabel`
- [x] `lib/src/composites/oi_gauge.dart` — Replace 1 `Text()` → `OiLabel`
- [x] `lib/src/composites/oi_chart_series_toggle.dart` — Replace 1 `Text()` → `OiLabel`
- [x] `lib/src/models/oi_series_style.dart` — Add `OiSeriesStyle.dashed({Color? strokeColor, double? strokeWidth})` and `OiSeriesStyle.dotted({Color? strokeColor, double? strokeWidth})` factory constructors
- [x] Verify: `dart analyze` && `flutter test`

### Phase 3: Integration Tests

- **Goal**: Prove streaming, sync, persistence, and normalization wiring works
- [x] `test/src/composites/oi_cartesian_chart_wiring_test.dart`:
  - Streaming: chart with OiStreamingDataSource → adapter emits → chart shows updated data
  - Persistence: create OiChartSettings with hiddenSeriesIds → pass to chart → verify controller.legendState has series hidden
  - Normalization: chart with performance config decimation=lttb → verify fewer datums than raw data points
  - Zoom/pan round-trip: set zoom via controller → verify viewport changes → resetZoom → verify back to default
- [x] `test/src/composites/oi_cartesian_chart_sync_test.dart`:
  - Mount 2 OiCartesianChart widgets with same syncGroup → zoom one → verify other receives viewport update (via sync coordinator listeners)
- [x] Verify: `flutter test`

## Risks / Out of scope

- **Risks**:
  - Phase 1 mixing `ChartStreamingHost` into composites that already use `ChartBehaviorHost` requires careful mixin composition — Dart allows multiple mixins on State but both must be `on State<T>`.
  - Sync registration in `attachBehaviors()` requires `OiChartSyncProvider` InheritedWidget above in tree — tests need `OiChartSyncProvider` wrapper in pumpChartApp.
  - Normalization pipeline in build() adds per-frame computation — may need caching to avoid perf regression.
- **Out of scope**:
  - Tier B/C charts (histogram, waterfall, boxplot, sunburst, etc.)
  - Modules (OiAnalyticsDashboard, OiChartExplorer, OiKpiBoard)
  - Golden tests, performance benchmarks
  - OiChartWidget abstract base class (documented as intentional deviation)
  - OiScatterPlot → OiScatterChart rename (keep existing name)
  - Reducing hardcoded color fallbacks in component painters (low priority, all have theme chains)
