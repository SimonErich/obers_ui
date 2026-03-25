## Overview

Close remaining ~27% spec gaps: fix P0 blockers (scale wiring, streaming, marker style, perf defaults, formatter types), add missing types (polar axes, color scale), wire composite orchestration (normalization, sync, persistence, overlays), fix convention violations, expand test coverage.

**Spec**: `concept/obers_ui_charts-spec.md` (full requirements)
**Gap analysis**: `concept/25-03-chart-gaps.md` (every gap with fix instructions)

## Context

- **Structure**: tier-based (`foundation/` → `models/` → `behaviors/` → `components/` → `composites/`)
- **State management**: `ChangeNotifier`-based `OiChartController`, immutable data models
- **Reference implementations**: `lib/src/foundation/oi_chart_scale.dart` (scale base), `lib/src/composites/_chart_behavior_host.dart` (behavior mixin), `lib/src/composites/oi_cartesian_chart.dart` (composite pattern)
- **Assumptions**: Animation enum deviation is intentional (document, don't implement enums). `OiChartSelectionState` field deviation is an improvement over spec (document).

## Plan

### Phase 1: P0 Foundation Fixes

- **Goal**: Fix blocking scale, formatter, style, and config gaps
- [x] `lib/src/foundation/oi_chart_scale.dart` — Add abstract `OiChartScale<T> withDomain(T min, T max)` method. Add `List<OiTick<T>> buildTicksWithStrategy(OiTickStrategy strategy, double axisLength)` method with default impl delegating to `buildTicks(count: strategy.maxCount ?? 5)`.
- [x] `lib/src/foundation/oi_linear_scale.dart` — Implement `withDomain()`: return `OiLinearScale(domainMin: min, domainMax: max, rangeMin: rangeMin, rangeMax: rangeMax, clamp: clamp)`
- [x] `lib/src/foundation/oi_logarithmic_scale.dart` — Implement `withDomain()`
- [x] `lib/src/foundation/oi_time_scale.dart` — Implement `withDomain()`
- [x] `lib/src/foundation/oi_category_scale.dart` — Implement `withDomain()` (accept String min/max → filter categories)
- [x] `lib/src/foundation/oi_band_scale.dart` — Implement `withDomain()`
- [x] `lib/src/foundation/oi_point_scale.dart` — Implement `withDomain()`
- [x] `lib/src/foundation/oi_quantile_scale.dart` — Implement `withDomain()`
- [x] `lib/src/foundation/oi_threshold_scale.dart` — Implement `withDomain()`
- [x] `lib/src/models/oi_series_style.dart` — Add `OiChartMarkerStyle? marker` field; update `copyWith`, `merge`, `==`, `hashCode`
- [x] `lib/src/foundation/oi_chart_performance_config.dart` — Change defaults: `progressiveChunkSize: 500` → `5000`, `maxInteractivePoints: 5000` → `10000`
- [x] `lib/src/foundation/oi_chart_formatters.dart` — Update typedefs: `OiAxisFormatter<T>` takes `OiAxisFormatContext<T>`, `OiTooltipValueFormatter` takes `OiTooltipFormatContext`. Keep old `OiFormatterContext<T>` as base class.
- [x] TDD: `withDomain()` on OiLinearScale returns new scale with overridden domain; toPixel still maps correctly
- [x] TDD: `buildTicksWithStrategy()` respects `maxCount` from OiTickStrategy
- [x] TDD: `OiSeriesStyle.merge()` propagates marker field
- [x] Verify: `dart analyze` && `flutter test`

### Phase 2: Missing Types + Streaming

- **Goal**: Create OiPolarAngleAxis, OiPolarRadiusAxis, OiColorScale; add appendMode/windowDuration to streaming adapter
- [x] `lib/src/models/oi_polar_axis.dart` — Create `OiPolarAngleAxis` (label, formatter, startAngle, direction) and `OiPolarRadiusAxis` (label, formatter, min, max, ticks)
- [x] `lib/src/composites/oi_polar_chart.dart` — Add `angleAxis: OiPolarAngleAxis?` and `radiusAxis: OiPolarRadiusAxis?` params
- [x] `lib/src/models/oi_color_scale.dart` — Create `OiColorScale` class: `Color resolve(num value)`, `OiColorScale.linear(minColor, maxColor, min, max)`, `OiColorScale.gradient(List<Color>, List<double> stops, min, max)`
- [x] `lib/src/composites/oi_matrix_chart.dart` — Add `colorScale: OiColorScale?` param
- [x] `lib/src/foundation/oi_streaming_series_adapter.dart` — Add `OiStreamingAppendMode` enum (append/replace), `Duration? windowDuration` param. In replace mode, clear buffer on each emission. For windowDuration, evict data older than window on each emission.
- [x] Export new files from `lib/obers_ui_charts.dart`
- [x] TDD: OiColorScale.linear maps 0→blue, 100→red, 50→purple midpoint
- [x] TDD: OiStreamingSeriesAdapter in replace mode clears buffer on new emission
- [x] TDD: windowDuration evicts old data
- [x] Verify: `dart analyze` && `flutter test`

### Phase 3: Composite Orchestration Wiring

- **Goal**: Wire normalization pipeline, streaming lifecycle, overlay rendering, sync, persistence, theme fallback into composites
- [x] `lib/src/foundation/oi_chart_behavior.dart` — Add `List<Widget> buildOverlays() => const []` default method
- [x] `lib/src/foundation/oi_chart_viewport.dart` — Add `({double, double})? get visibleDomainX` and `visibleDomainY` computed getters from `visibleDomain` Rect
- [x] `lib/src/composites/_chart_behavior_host.dart` — In `attachBehaviors()`: create `OiNoOpAccessibilityBridge` so context.accessibilityBridge is non-null. Add `List<Widget> collectBehaviorOverlays()` method. Add `OiChartThemeData resolveTheme(BuildContext context)` using fallback chain: widget.theme → context.components.chart → OiChartThemeData().
- [x] `lib/src/composites/_chart_data_pipeline.dart` — Create mixin `ChartDataPipeline`: method `List<OiChartDatum> normalizeAndDecimate(List<OiCartesianSeries> series, OiChartPerformanceConfig? perf)` that calls `normalizeSeries()` then applies decimation. Validate mixed-type x-values → throw `ArgumentError`.
- [x] `lib/src/composites/_chart_streaming_host.dart` — Create mixin `ChartStreamingHost`: manages Map<String, OiStreamingSeriesAdapter> per series id. Attaches on mount, detaches on dispose, listens for changes → setState.
- [x] `lib/src/composites/oi_cartesian_chart.dart` — Add `legend: OiChartLegendConfig?`, `settings: OiChartSettings?`, `theme: OiChartThemeData?` params. Wire: normalization pipeline in build, streaming host, overlay stack from `collectBehaviorOverlays()`, sync group register/unregister, persistence restore on mount.
- [x] `lib/src/composites/oi_polar_chart.dart` — Same wiring (legend, settings, theme, streaming, overlays)
- [x] `lib/src/composites/oi_matrix_chart.dart` — Same wiring
- [x] `lib/src/composites/oi_hierarchical_chart.dart` — Same wiring (no normalization pipeline needed)
- [x] `lib/src/composites/oi_flow_chart.dart` — Same wiring (no normalization pipeline needed)
- [x] TDD: Cartesian chart with streaming source rebuilds when adapter emits new data
- [x] TDD: Cartesian chart with mixed-type x-values across series throws ArgumentError
- [x] TDD: Behavior overlay widgets appear in render tree when behavior returns overlays
- [x] TDD: Theme resolves via fallback chain (series → chart → context → default)
- [x] Verify: `dart analyze` && `flutter test`

### Phase 4: Sync Coordinator + Persistence Wiring

- **Goal**: Provision sync coordinator in OiApp; wire persistence save/restore
- [x] `lib/src/foundation/oi_chart_sync_coordinator.dart` — Add `broadcastHover(String syncGroup, Object? xDomainValue, String sourceChartId)` and `broadcastViewport(String syncGroup, OiChartViewportState viewport, String sourceChartId)` methods delegating to existing sync methods. Add `String sourceChartId` param to existing sync methods.
- [x] `lib/src/foundation/oi_chart_sync_provider.dart` — Create `OiChartSyncProvider` InheritedWidget wrapping lazy `OiChartSyncCoordinator`. Add `static OiChartSyncCoordinator? maybeOf(BuildContext)`.
- [x] Main obers_ui package `lib/src/foundation/oi_app.dart` — Add `OiChartSyncProvider` as child of OiApp's widget tree (lazy — only instantiated when first `maybeOf` call finds no provider above).
- [x] `lib/src/models/oi_chart_settings.dart` — Add `OiPersistedViewport` (xMin, xMax, yMin, yMax) and `OiPersistedSelection` (selectedRefs serialized) classes. Change `legendExpandedGroups` from `Set<String>` to `Map<String, bool>`. Update toJson/fromJson.
- [x] `lib/src/composites/_chart_behavior_host.dart` — Add sync registration: if `syncGroup` is set, register controller with coordinator on attach, unregister on dispose.
- [x] TDD: OiChartSyncProvider.maybeOf returns coordinator when present
- [x] TDD: Persistence round-trip: save settings → restore → controller state matches
- [x] TDD: Sync registration on mount, unregistration on dispose
- [x] Verify: `dart analyze` && `flutter test`

### Phase 5: Convention Compliance

- **Goal**: Fix all raw Text/Row/Column and hardcoded color violations
- [x] `lib/src/foundation/oi_chart_tooltip.dart` — Replace `Text()` → `OiLabel`, `Row`/`Column` → `OiRow`/`OiColumn`, hardcoded `Color(0x...)` → theme tokens from `OiChartTooltipTheme`
- [x] `lib/src/components/oi_chart_tooltip_widget.dart` — Same convention fixes
- [x] `lib/src/composites/oi_chart_legend.dart` — Replace `Row` → `OiRow`, `Text` → `OiLabel`. Add keyboard navigation: wrap items in `Focus` + handle arrow keys. Add `OiResponsive` position switching.
- [x] `lib/src/foundation/oi_chart_marker.dart` — Replace `Color(0xFF000000)` fallback → `const Color(0x00000000)` or derive from context
- [x] `lib/src/foundation/oi_chart_accessibility_config.dart` — Rename `OiChartSummaryData` → `OiChartAccessibilitySummary`. Add `insights: List<OiDetectedChartInsight>` field if missing.
- [x] `lib/src/foundation/oi_chart_behavior.dart` — Make `accessibilityBridge` non-nullable in `OiChartBehaviorContext` (default no-op bridge)
- [x] TDD: Legend keyboard navigation — arrow keys move focus between items
- [x] Verify: `dart analyze` && `flutter test`

### Phase 6: Edge Case Hardening

- **Goal**: Implement remaining error handling and edge cases
- [x] `lib/src/composites/oi_cartesian_chart.dart` — Single-point data: detect in build, apply `domainPaddingForSinglePoint()` to viewport domain
- [x] `lib/src/composites/_chart_behavior_host.dart` — Listen to external controller disposal; auto-detach behaviors when controller notifies disposal
- [x] `lib/src/composites/oi_cartesian_chart.dart` — Theme change mid-animation: in `didUpdateWidget`, if theme changed and animation in progress, reset animation controllers
- [x] `lib/src/foundation/oi_chart_viewport.dart` — In `OiChartViewportState.set zoomLevel`: also clamp if zoom would produce zero domain range (delegate to `clampDomainRange()`)
- [x] TDD: Single data point produces chart with domain padding (not zero-range)
- [x] TDD: External controller disposed → behaviors auto-detach without crash
- [x] Verify: `dart analyze` && `flutter test`

### Phase 7: Test Coverage Expansion

- **Goal**: Fill all spec-required test gaps
- [x] `test/src/composites/oi_chart_legend_test.dart` — Legend toggle, keyboard nav, responsive position, custom item builder
- [x] `test/src/behaviors/oi_chart_tooltip_behavior_test.dart` — Show/hide timing, anchor modes, hover+tap triggers, custom builder
- [x] `test/src/behaviors/oi_chart_crosshair_behavior_test.dart` — Line rendering, horizontal/vertical modes, theme styling
- [x] `test/src/behaviors/oi_chart_brush_behavior_test.dart` — Drag to select, rectangle rendering, domain range output
- [x] `test/src/foundation/oi_chart_theme_test.dart` — Palette assignment by index, override chain (series → chart → context), light/dark mode, sub-theme inheritance
- [x] `test/src/composites/oi_cartesian_chart_integration_test.dart` — Multi-series render, zoom+pan round-trip, sync group 2-chart hover sync, persistence save/restore, streaming update, error recovery
- [x] `test/src/foundation/oi_chart_performance_test.dart` — 1k points render time, 10k points with decimation, memory (no leak after dispose)
- [x] Verify: `flutter test --coverage`

## Risks / Out of scope

- **Risks**:
  - Phase 1 formatter typedef change is breaking — any code passing `OiFormatterContext` to `OiAxisFormatter` will break. Mitigate: update all internal callers in same commit.
  - Phase 3 normalization pipeline changes `seriesBuilder` contract if we pass normalized datums instead of raw series. Mitigate: keep existing callback, add optional `normalizedBuilder` alongside.
  - Phase 4 modifying `OiApp` in main package affects all obers_ui consumers. Mitigate: lazy provider creates no objects unless charts with syncGroup are used.
- **Out of scope**:
  - Golden tests (need stable rendering first — defer to after Phase 7)
  - Animation enum creation (intentional class-based deviation — document only)
  - `OiChartSelectionState` field rename (current approach is superior to spec)
  - `OiHitTestResult` field names (structured `OiChartDataRef` approach is valid)
