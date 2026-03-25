## Overview

Migrate existing chart infrastructure (~60 files across foundation/scales, composites/visualization, models/settings, theme) from obers_ui into `packages/obers_ui_charts`, then fill gaps: ring buffer, decimation algorithms, streaming adapter, keyboard explore behavior, mapper-first series type hierarchy, and family base composite widgets.

**Spec**: `concept/obers_ui_charts-spec.md` (read this file for full requirements)

## Context

- **Structure**: tier-based (foundation → primitives → components → composites), same as obers_ui
- **State management**: ChangeNotifier-based `OiChartController` (already implemented)
- **Critical finding**: ~70% of foundation already exists in obers_ui. This is primarily a migration + gap-fill, not greenfield.
- **Reference implementations**:
  - `lib/src/foundation/scales/oi_chart_scale.dart` — abstract scale base + `OiScaleType` enum + `OiTick<T>`
  - `lib/src/foundation/scales/oi_chart_behavior.dart` — behavior lifecycle with attach/detach
  - `lib/src/foundation/scales/oi_chart_hit_tester.dart` — x-bucket spatial indexing with binary search
  - `lib/src/composites/visualization/oi_bar_chart/` — complex chart with data/painter/legend/theme/a11y files
  - `lib/src/foundation/persistence/oi_settings_mixin.dart` — typed persistence mixin

- **Already implemented** (in obers_ui, needs migration only):
  - `OiChartScale<T>` + 8 concrete scale implementations (linear, log, time, category, band, point, quantile, threshold)
  - `OiChartCanvas`, `OiChartLayer`, `OiChartLayerPainter` with z-order and pixel snapping
  - `OiChartBehavior` base + `OiChartCrosshairBehavior`, `OiChartBrushBehavior`, `OiChartTooltipBehavior`
  - `OiChartController` with selection/hover state
  - `OiChartViewport` with zoom/pan/coordinate conversion
  - `OiChartHitTester` with binary search + bucket indexing
  - `OiChartSyncGroup` + `OiChartSyncProvider` InheritedWidget
  - `OiChartAccessibilityConfig` + `OiChartAccessibilityBridge`
  - `OiChartPerformanceConfig` with decimation strategy resolution
  - `OiChartExtension` lifecycle hooks
  - `OiChartAnimationConfig`
  - `OiChartFormatters`
  - `OiChartThemeData` (880 lines) + `OiChartPalette` — already in `OiComponentThemes`
  - `OiChartSettings` + `OiChartSettingsDriverBinding`
  - 9 simple chart widgets + 3 complex chart widgets with subdirectories
  - Shared: `OiChartAxis`, `OiChartLegend`, `OiChartSeriesToggle`, grid painter

- **Not yet implemented** (must be built):
  - `OiRingBuffer<T>` — circular buffer for streaming
  - Concrete decimation algorithms (LTTB, minMax) — strategy enum exists, implementations don't
  - `OiStreamingDataSource<T>` + `OiStreamingSeriesAdapter<T>`
  - `OiKeyboardExploreBehavior` — config exists, behavior doesn't
  - `OiSelectionBehavior`, `OiHoverSyncBehavior`, `OiSeriesToggleBehavior` — need verification
  - Mapper-first series type hierarchy (`OiChartSeries<T>`, `OiCartesianSeries<T>`, etc.)
  - `OiChartDatum` normalized internal model
  - Family base composite widgets (`OiCartesianChart<T>`, `OiPolarChart<T>`, `OiMatrixChart<T>`, `OiHierarchicalChart<TNode>`, `OiFlowChart<TNode, TLink>`)
  - `OiChartEmptyState`, `OiChartLoadingState`, `OiChartErrorState` widgets
  - `OiChartZoomControlsWidget` for touch

- **Assumptions**:
  - `OiChartThemeData` field in `OiComponentThemes` stays in obers_ui (nullable slot); the actual theme class moves to obers_ui_charts. Import from obers_ui_charts where needed.
  - `OiChartSurface` component (`lib/src/components/display/oi_chart_surface.dart`) also migrates.
  - Existing tests for migrated code exist and must move.

## Plan

### Phase 1: Package scaffold + bulk migration

- **Goal**: move all existing chart code into `packages/obers_ui_charts`; both packages analyze clean
- [ ] `packages/obers_ui_charts/pubspec.yaml` — create with `obers_ui` path dep, same SDK constraints, dev_deps (flutter_test, golden_toolkit, mocktail, very_good_analysis)
- [ ] `packages/obers_ui_charts/analysis_options.yaml` — copy from obers_ui (extend very_good_analysis, ignore lines_longer_than_80_chars, require_trailing_commas)
- [ ] Create directory tree: `lib/src/{foundation,primitives,components,composites,models,behaviors,utils}`
- [ ] Move `lib/src/foundation/scales/oi_chart_*.dart` → `packages/obers_ui_charts/lib/src/foundation/`
- [ ] Move `lib/src/foundation/persistence/oi_chart_settings_driver_binding.dart` → `packages/obers_ui_charts/lib/src/foundation/`
- [ ] Move `lib/src/foundation/theme/component_themes/oi_chart_theme_data.dart` + `oi_chart_palette.dart` → `packages/obers_ui_charts/lib/src/foundation/theme/`
- [ ] Move `lib/src/models/settings/oi_chart_settings.dart` → `packages/obers_ui_charts/lib/src/models/`
- [ ] Move `lib/src/components/display/oi_chart_surface.dart` → `packages/obers_ui_charts/lib/src/components/`
- [ ] Move `lib/src/composites/visualization/` (entire dir) → `packages/obers_ui_charts/lib/src/composites/`
- [ ] `packages/obers_ui_charts/lib/obers_ui_charts.dart` — barrel file with sectioned exports for all moved files
- [ ] `lib/obers_ui.dart` — remove all chart-related exports (~60 lines across visualization, scales, persistence, theme, models sections)
- [ ] `lib/src/foundation/theme/oi_component_themes.dart` — keep `OiChartThemeData? chart` field, import type from obers_ui_charts (or keep a minimal forward-declaration)
- [ ] Move corresponding test files from `test/src/` → `packages/obers_ui_charts/test/src/`
- [ ] `packages/obers_ui_charts/test/helpers/pump_chart_app.dart` — create `PumpChartApp` extension mirroring obers_ui's `PumpObers`
- [ ] Fix all import paths in moved files (obers_ui foundation imports stay, chart-internal imports update)
- [ ] `example/pubspec.yaml` — add `obers_ui_charts` path dependency
- [ ] Verify: `dart analyze` passes in both packages, `flutter test` passes in both packages

### Phase 2: Ring buffer + decimation algorithms

- **Goal**: implement missing pure-function utilities with TDD
- [ ] TDD: `OiRingBuffer` — add within capacity retains all → implement minimal buffer
- [ ] TDD: `OiRingBuffer` — add beyond capacity evicts oldest → implement circular logic
- [ ] TDD: `OiRingBuffer` — addAll with batch > capacity keeps last N → batch append
- [ ] TDD: `OiRingBuffer` — items returned in insertion order → iterator
- [ ] TDD: `OiRingBuffer` — clear resets to empty, capacity 0 edge case
- [ ] TDD: `decimateMinMax` — preserves global min/max, reduces count → implement min-max bucketing
- [ ] TDD: `decimateMinMax` — empty/single-point returns unchanged
- [ ] TDD: `decimateLttb` — preserves visually significant points → implement LTTB algorithm
- [ ] TDD: `decimateLttb` — fewer points than target returns all
- [ ] TDD: adaptive strategy selects correct algorithm based on density ratio
- [ ] Verify: `dart analyze` && `flutter test packages/obers_ui_charts`

### Phase 3: Streaming data support

- **Goal**: full streaming pipeline from data source to chart consumption
- [ ] `packages/obers_ui_charts/lib/src/foundation/oi_streaming_data_source.dart` — abstract contract: `dataStream`, `maxRetainedPoints`, `updateInterval`
- [ ] TDD: `OiStreamingSeriesAdapter` — subscribes on attach, unsubscribes on detach → implement lifecycle
- [ ] TDD: `OiStreamingSeriesAdapter` — maintains ring buffer with correct capacity → integrate OiRingBuffer
- [ ] TDD: `OiStreamingSeriesAdapter` — throttles rapid updates to interval → debounce logic
- [ ] TDD: `OiStreamingSeriesAdapter` — handles stream errors without crash → error state exposure
- [ ] TDD: `OiStreamingSeriesAdapter` — multiple attach/detach cycles don't leak subscriptions
- [ ] Update `OiChartSeries<T>` (if exists) or create — accept `data` OR `streamingData` (mutually exclusive, ArgumentError if both)
- [ ] Verify: `dart analyze` && `flutter test packages/obers_ui_charts`

### Phase 4: Mapper-first series type hierarchy + normalized datum

- **Goal**: generic series contracts that accept domain models with mapper functions
- [ ] `packages/obers_ui_charts/lib/src/models/oi_chart_series.dart` — `OiChartSeries<T>` abstract base: id, label, data/streamingData, visible, style, animation, legend, semanticLabel
- [ ] `packages/obers_ui_charts/lib/src/models/oi_cartesian_series.dart` — x/y mappers, pointLabel, isMissing, semanticValue, yAxisId
- [ ] `packages/obers_ui_charts/lib/src/models/oi_polar_series.dart` — value/label mappers
- [ ] `packages/obers_ui_charts/lib/src/models/oi_matrix_series.dart` — row/column/value mappers
- [ ] `packages/obers_ui_charts/lib/src/models/oi_hierarchical_series.dart` — nodeId/parentId/value/nodeLabel mappers
- [ ] `packages/obers_ui_charts/lib/src/models/oi_flow_series.dart` — nodes/links lists with nodeId/sourceId/targetId/linkValue mappers
- [ ] `packages/obers_ui_charts/lib/src/models/oi_chart_datum.dart` — normalized internal point: seriesId, index, rawItem, xRaw/yRaw, xScaled/yScaled, colorRaw, label, isMissing, extra map
- [ ] TDD: `OiChartSeries` — validates data/streamingData mutual exclusivity
- [ ] TDD: `OiCartesianSeries` — mapper extraction produces correct x/y from domain model
- [ ] TDD: `OiChartDatum` — normalization from series via mappers produces correct datum list
- [ ] Verify: `dart analyze` && `flutter test packages/obers_ui_charts`

### Phase 5: Missing behaviors + component widgets

- **Goal**: fill remaining behavior and widget gaps
- [ ] TDD: `OiKeyboardExploreBehavior` — left/right navigates points → implement with focusedIndex tracking
- [ ] TDD: `OiKeyboardExploreBehavior` — up/down switches series → series navigation
- [ ] TDD: `OiKeyboardExploreBehavior` — enter selects, escape clears → selection dispatch
- [ ] TDD: `OiKeyboardExploreBehavior` — announces formatted values via accessibility bridge
- [ ] `OiSelectionBehavior` — verify exists or implement: point/series/domain-group/brush modes
- [ ] `OiHoverSyncBehavior` — verify exists (may be part of sync group) or implement
- [ ] `OiSeriesToggleBehavior` — verify exists or implement legend-driven show/hide
- [ ] `packages/obers_ui_charts/lib/src/components/oi_chart_empty_state.dart` — no-data state using OiLabel + obers_ui patterns
- [ ] `packages/obers_ui_charts/lib/src/components/oi_chart_loading_state.dart` — loading state
- [ ] `packages/obers_ui_charts/lib/src/components/oi_chart_error_state.dart` — error state (streaming errors)
- [ ] `packages/obers_ui_charts/lib/src/components/oi_chart_zoom_controls.dart` — touch-friendly zoom/reset buttons
- [ ] TDD: empty state shown when data list is empty
- [ ] TDD: error state shown when streaming source errors
- [ ] Verify: `dart analyze` && `flutter test packages/obers_ui_charts`

### Phase 6: Family base composite widgets

- **Goal**: orchestrating composite widgets that wire viewport → scales → behaviors → rendering → accessibility → persistence → sync
- [ ] `packages/obers_ui_charts/lib/src/composites/oi_cartesian_chart.dart` — xAxis, yAxes, `List<OiCartesianSeries<T>>`, all shared props (label, theme, legend, behaviors, annotations, thresholds, performance, animation, accessibility, settings, controller, syncGroup, states)
- [ ] TDD: `OiCartesianChart` — renders with single series using mapper-first data binding
- [ ] TDD: `OiCartesianChart` — auto-resolves scale type from data (DateTime → time, num → linear)
- [ ] TDD: `OiCartesianChart` — empty data shows empty state
- [ ] TDD: `OiCartesianChart` — accessibility summary generates with chart type + series count
- [ ] TDD: `OiCartesianChart` — zoom/pan behavior modifies viewport state
- [ ] TDD: `OiCartesianChart` — sync group broadcasts hover to sibling chart
- [ ] TDD: `OiCartesianChart` — persistence saves/restores hidden series + viewport via OiSettingsMixin
- [ ] TDD: `OiCartesianChart` — performance config enables decimation for 10k+ points
- [ ] `packages/obers_ui_charts/lib/src/composites/oi_polar_chart.dart` — angleAxis, radiusAxis, polar series, center content
- [ ] TDD: `OiPolarChart` — renders arc layout, angular hit testing identifies correct slice
- [ ] `packages/obers_ui_charts/lib/src/composites/oi_matrix_chart.dart` — x/y axes, colorScale, matrix series
- [ ] TDD: `OiMatrixChart` — renders cell grid with color scale mapping
- [ ] `packages/obers_ui_charts/lib/src/composites/oi_hierarchical_chart.dart` — tree parsing from flat node list, value aggregation, drill navigation
- [ ] TDD: `OiHierarchicalChart` — builds tree from flat list, aggregates leaf values
- [ ] `packages/obers_ui_charts/lib/src/composites/oi_flow_chart.dart` — node/link layout, flow width scaling
- [ ] TDD: `OiFlowChart` — node layout non-overlapping, link width proportional to value
- [ ] Update barrel file with all new composites
- [ ] Verify: `dart analyze` && `flutter test packages/obers_ui_charts`

### Phase 7: Integration verification + cleanup

- **Goal**: end-to-end validation across both packages
- [ ] Verify `dart analyze lib` in main obers_ui — 0 errors/warnings/infos
- [ ] Verify `flutter test` in main obers_ui — all tests pass
- [ ] Verify `dart analyze` in obers_ui_charts — 0 errors/warnings/infos
- [ ] Verify `flutter test packages/obers_ui_charts` — all tests pass
- [ ] Verify `cd example && flutter build` — example app builds with both dependencies
- [ ] Review barrel file completeness — all public APIs exported
- [ ] Verify no circular dependencies between packages

## Risks / Out of scope

**Risks:**
- **Circular dependency**: `OiComponentThemes` in obers_ui references `OiChartThemeData` which moves to obers_ui_charts. Resolution: keep a minimal type-only import or use a forward-declaration pattern; may need `OiChartThemeData` to stay in obers_ui as a shared type.
- **Import breakage cascade**: ~60 exports removed from obers_ui barrel. Any external consumer breaks. Mitigated by `publish_to: 'none'` (internal package).
- **Existing chart widget refactoring**: migrated charts keep their current internal logic initially; refactoring them onto the new family base widgets (OiCartesianChart etc.) is a follow-up task, not this plan.

**Out of scope:**
- Individual chart type specs (OiLineChart, OiBarChart, etc.) — separate specs per the user's "foundation only first" decision
- Refactoring migrated charts to use new series type hierarchy — follow-up work after foundation is stable
- Real chart rendering within family base widgets — they provide the orchestration shell; concrete series renderers come with individual chart specs
- Widgetbook or documentation site updates
- Example app chart screen updates (beyond ensuring build works)
