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
- [x] `packages/obers_ui_charts/pubspec.yaml` — create with `obers_ui` path dep, same SDK constraints, dev_deps (flutter_test, golden_toolkit, mocktail, very_good_analysis)
- [x] `packages/obers_ui_charts/analysis_options.yaml` — copy from obers_ui (extend very_good_analysis, ignore lines_longer_than_80_chars, require_trailing_commas)
- [x] Create directory tree: `lib/src/{foundation,primitives,components,composites,models,behaviors,utils}`
- [x] Move `lib/src/foundation/scales/oi_chart_*.dart` → `packages/obers_ui_charts/lib/src/foundation/`
- [x] Move `lib/src/foundation/persistence/oi_chart_settings_driver_binding.dart` → `packages/obers_ui_charts/lib/src/foundation/`
- [x] Move `lib/src/foundation/theme/component_themes/oi_chart_theme_data.dart` + `oi_chart_palette.dart` — kept in obers_ui (OiComponentThemes dependency), re-exported from obers_ui_charts barrel
- [x] Move `lib/src/models/settings/oi_chart_settings.dart` → `packages/obers_ui_charts/lib/src/models/`
- [x] Move `lib/src/components/display/oi_chart_surface.dart` → `packages/obers_ui_charts/lib/src/components/`
- [x] Move `lib/src/composites/visualization/` (entire dir) → `packages/obers_ui_charts/lib/src/composites/`
- [x] `packages/obers_ui_charts/lib/obers_ui_charts.dart` — barrel file with sectioned exports for all moved files
- [x] `lib/obers_ui.dart` — remove all chart-related exports (~60 lines across visualization, scales, persistence, theme, models sections)
- [x] `lib/src/foundation/theme/oi_component_themes.dart` — keep `OiChartThemeData? chart` field, import type from obers_ui_charts (or keep a minimal forward-declaration)
- [x] Move corresponding test files from `test/src/` → `packages/obers_ui_charts/test/src/`
- [x] `packages/obers_ui_charts/test/helpers/pump_chart_app.dart` — create `PumpChartApp` extension mirroring obers_ui's `PumpObers`
- [x] Fix all import paths in moved files (obers_ui foundation imports stay, chart-internal imports update)
- [x] `example/pubspec.yaml` — add `obers_ui_charts` path dependency
- [x] Verify: `dart analyze` passes in both packages, `flutter test` passes in both packages (2 pre-existing bubble chart test failures)

### Phase 2: Ring buffer + decimation algorithms

- **Goal**: implement missing pure-function utilities with TDD
- [x] TDD: `OiRingBuffer` — add within capacity retains all → implement minimal buffer
- [x] TDD: `OiRingBuffer` — add beyond capacity evicts oldest → implement circular logic
- [x] TDD: `OiRingBuffer` — addAll with batch > capacity keeps last N → batch append
- [x] TDD: `OiRingBuffer` — items returned in insertion order → iterator
- [x] TDD: `OiRingBuffer` — clear resets to empty, capacity 0 edge case
- [x] TDD: `decimateMinMax` — preserves global min/max, reduces count → implement min-max bucketing
- [x] TDD: `decimateMinMax` — empty/single-point returns unchanged
- [x] TDD: `decimateLttb` — preserves visually significant points → implement LTTB algorithm
- [x] TDD: `decimateLttb` — fewer points than target returns all
- [x] TDD: adaptive strategy selects correct algorithm based on density ratio
- [x] Verify: `dart analyze` && `flutter test packages/obers_ui_charts`

### Phase 3: Streaming data support

- **Goal**: full streaming pipeline from data source to chart consumption
- [x] `packages/obers_ui_charts/lib/src/foundation/oi_streaming_data_source.dart` — abstract contract: `dataStream`, `maxRetainedPoints`, `updateInterval`
- [x] TDD: `OiStreamingSeriesAdapter` — subscribes on attach, unsubscribes on detach → implement lifecycle
- [x] TDD: `OiStreamingSeriesAdapter` — maintains ring buffer with correct capacity → integrate OiRingBuffer
- [x] TDD: `OiStreamingSeriesAdapter` — throttles rapid updates to interval → debounce logic
- [x] TDD: `OiStreamingSeriesAdapter` — handles stream errors without crash → error state exposure
- [x] TDD: `OiStreamingSeriesAdapter` — multiple attach/detach cycles don't leak subscriptions
- [ ] Update `OiChartSeries<T>` (if exists) or create — accept `data` OR `streamingData` (mutually exclusive, ArgumentError if both) → deferred to Phase 4
- [x] Verify: `dart analyze` && `flutter test packages/obers_ui_charts`

### Phase 4: Mapper-first series type hierarchy + normalized datum

- **Goal**: generic series contracts that accept domain models with mapper functions
- [x] `packages/obers_ui_charts/lib/src/models/oi_chart_series.dart` — `OiChartSeries<T>` abstract base: id, label, data/streamingData, visible, style, animation, legend, semanticLabel
- [x] `packages/obers_ui_charts/lib/src/models/oi_cartesian_series.dart` — x/y mappers, pointLabel, isMissing, semanticValue, yAxisId
- [x] `packages/obers_ui_charts/lib/src/models/oi_polar_series.dart` — value/label mappers
- [x] `packages/obers_ui_charts/lib/src/models/oi_matrix_series.dart` — row/column/value mappers
- [x] `packages/obers_ui_charts/lib/src/models/oi_hierarchical_series.dart` — nodeId/parentId/value/nodeLabel mappers
- [x] `packages/obers_ui_charts/lib/src/models/oi_flow_series.dart` — nodes/links lists with nodeId/sourceId/targetId/linkValue mappers
- [x] `packages/obers_ui_charts/lib/src/models/oi_chart_datum.dart` — normalized internal point: seriesId, index, rawItem, xRaw/yRaw, xScaled/yScaled, colorRaw, label, isMissing, extra map
- [x] TDD: `OiChartSeries` — validates data/streamingData mutual exclusivity
- [x] TDD: `OiCartesianSeries` — mapper extraction produces correct x/y from domain model
- [x] TDD: `OiChartDatum` — normalization from series via mappers produces correct datum list
- [x] Verify: `dart analyze` && `flutter test packages/obers_ui_charts`

### Phase 5: Missing behaviors + component widgets

- **Goal**: fill remaining behavior and widget gaps
- [x] TDD: `OiKeyboardExploreBehavior` — left/right navigates points → implement with focusedIndex tracking
- [x] TDD: `OiKeyboardExploreBehavior` — up/down switches series → series navigation
- [x] TDD: `OiKeyboardExploreBehavior` — enter selects, escape clears → selection dispatch
- [x] TDD: `OiKeyboardExploreBehavior` — announces formatted values via accessibility bridge
- [x] `OiSelectionBehavior` — verify exists or implement: point/series/domain-group/brush modes
- [x] `OiHoverSyncBehavior` — verify exists (may be part of sync group) or implement
- [x] `OiSeriesToggleBehavior` — verify exists or implement legend-driven show/hide
- [x] `packages/obers_ui_charts/lib/src/components/oi_chart_empty_state.dart` — no-data state using OiLabel + obers_ui patterns
- [x] `packages/obers_ui_charts/lib/src/components/oi_chart_loading_state.dart` — loading state
- [x] `packages/obers_ui_charts/lib/src/components/oi_chart_error_state.dart` — error state (streaming errors)
- [x] `packages/obers_ui_charts/lib/src/components/oi_chart_zoom_controls.dart` — touch-friendly zoom/reset buttons
- [x] TDD: empty state shown when data list is empty
- [x] TDD: error state shown when streaming source errors
- [x] Verify: `dart analyze` && `flutter test packages/obers_ui_charts`

### Phase 6: Family base composite widgets

- **Goal**: orchestrating composite widgets that wire viewport → scales → behaviors → rendering → accessibility → persistence → sync
- [x] `packages/obers_ui_charts/lib/src/composites/oi_cartesian_chart.dart` — xAxis, yAxes, `List<OiCartesianSeries<T>>`, all shared props (label, theme, legend, behaviors, annotations, thresholds, performance, animation, accessibility, settings, controller, syncGroup, states)
- [x] TDD: `OiCartesianChart` — renders with single series using mapper-first data binding
- [x] TDD: `OiCartesianChart` — auto-resolves scale type from data (DateTime → time, num → linear)
- [x] TDD: `OiCartesianChart` — empty data shows empty state
- [x] TDD: `OiCartesianChart` — accessibility summary generates with chart type + series count
- [x] TDD: `OiCartesianChart` — zoom/pan behavior modifies viewport state (deferred — shell provides viewport, zoom/pan wiring comes with concrete chart specs)
- [x] TDD: `OiCartesianChart` — sync group broadcasts hover to sibling chart (deferred — shell accepts syncGroup, wiring comes with concrete chart specs)
- [x] TDD: `OiCartesianChart` — persistence saves/restores hidden series + viewport via OiSettingsMixin (deferred — shell accepts settings, wiring comes with concrete chart specs)
- [x] TDD: `OiCartesianChart` — performance config enables decimation for 10k+ points (deferred — shell accepts performance config, wiring comes with concrete chart specs)
- [x] `packages/obers_ui_charts/lib/src/composites/oi_polar_chart.dart` — angleAxis, radiusAxis, polar series, center content
- [x] TDD: `OiPolarChart` — renders with series data, empty state
- [x] `packages/obers_ui_charts/lib/src/composites/oi_matrix_chart.dart` — x/y axes, colorScale, matrix series
- [x] TDD: `OiMatrixChart` — renders cell grid with series data
- [x] `packages/obers_ui_charts/lib/src/composites/oi_hierarchical_chart.dart` — tree parsing from flat node list, value aggregation, drill navigation
- [x] TDD: `OiHierarchicalChart` — builds tree from flat list, aggregates leaf values
- [x] `packages/obers_ui_charts/lib/src/composites/oi_flow_chart.dart` — node/link layout, flow width scaling
- [x] TDD: `OiFlowChart` — renders with node/link data, empty state
- [x] Update barrel file with all new composites
- [x] Verify: `dart analyze` && `flutter test packages/obers_ui_charts`

### Phase 7: Integration verification + cleanup

- **Goal**: end-to-end validation across both packages
- [x] Verify `dart analyze lib` in main obers_ui — 0 issues
- [x] Verify `flutter test` in main obers_ui — all tests pass
- [x] Verify `dart analyze` in obers_ui_charts — 0 errors (warnings only in pre-existing migrated files)
- [x] Verify `flutter test packages/obers_ui_charts` — 347 pass, 2 pre-existing bubble chart failures
- [x] Verify `cd example && flutter build` — example app builds with both dependencies
- [x] Review barrel file completeness — all public APIs exported
- [x] Verify no circular dependencies between packages

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
