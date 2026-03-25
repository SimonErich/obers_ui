## Overview

Close the ~40% implementation gap in obers_ui_charts by building missing state models, style models, behaviors, component widgets, and composite wiring — in dependency order so each phase unlocks the next.

**Spec**: `concept/obers_ui_charts-spec.md` (read this file for full requirements)
**Gap analysis**: `concept/obers_ui_charts-gap-analysis.md`

## Context

- **Structure**: tier-based (`foundation/` → `models/` → `behaviors/` → `components/` → `composites/`)
- **State management**: `ChangeNotifier`-based `OiChartController`, immutable data models
- **Reference implementations**: `lib/src/foundation/oi_chart_controller.dart`, `lib/src/composites/oi_cartesian_chart.dart`, `lib/src/foundation/oi_chart_tooltip.dart` (tooltip behavior with overlay integration)
- **Patterns**: `@immutable` data classes with `copyWith`, `==`, `hashCode`; behaviors extend `OiChartBehavior` with attach/detach lifecycle; overlays via `OiOverlays` system
- **Assumptions**: Animation enum gap is intentional (class-based `OiPhaseAnimationConfig` is more flexible — document deviation). Naming differences (e.g. `OiChart*` prefix on migrated behaviors) are kept for consistency.

## Plan

### Phase 1: State Models + Controller Completion

- **Goal**: Create missing state models; upgrade `OiChartController` to manage viewport, legend, and focus state
- [ ] `lib/src/models/oi_chart_state_models.dart` — Create `OiChartSelectionState` (selectedRefs, mode, timestamp), `OiChartHoverState` (ref, position, seriesId), `OiChartLegendState` (hiddenSeriesIds, focusedSeriesId, expandedGroups), `OiChartFocusState` (focusedRef, focusRing, navigating)
- [ ] `lib/src/foundation/oi_chart_viewport.dart` — Add `OiChartViewportState` mutable class with xMin/xMax/yMin/yMax, zoomLevel, panOffset, isZoomed, reset(), copyWith(). Keep existing immutable `OiChartViewport` unchanged.
- [ ] `lib/src/foundation/oi_chart_controller.dart` — Add abstract getters/methods: `viewport` (OiChartViewportState), `legend` (OiChartLegendState), `focus` (OiChartFocusState), `resetZoom()`, `focusSeries(String)`, `toggleSeries(String)`, `setVisibleDomain()`
- [ ] `lib/src/models/oi_default_chart_controller.dart` — Concrete `OiDefaultChartController extends OiChartController` implementing all state + notify
- [ ] Export new files from `lib/obers_ui_charts.dart`
- [ ] TDD: Controller notifies on select/clearSelection/hover/resetZoom/toggleSeries/focusSeries
- [ ] TDD: ViewportState tracks zoom, isZoomed returns true when zoom != 1, reset() restores defaults
- [ ] TDD: State models equality and copyWith
- [ ] Verify: `dart analyze` in `packages/obers_ui_charts` && `flutter test packages/obers_ui_charts`

### Phase 2: Style Models + Series Enrichment

- **Goal**: Add series-level styling, legend config, and marker styles per spec
- [ ] `lib/src/models/oi_series_style.dart` — `OiSeriesStyle` (color, fill: OiSeriesFill?, strokeWidth, dashPattern, hoverStyle, selectedStyle, inactiveStyle, dataLabelStyle: OiDataLabelStyle?), `OiSeriesFill` (solid/gradient factory constructors), `OiDataLabelStyle` (show, position, formatter, style)
- [ ] `lib/src/models/oi_series_legend_config.dart` — `OiSeriesLegendConfig` (show, label, iconBuilder, order)
- [ ] `lib/src/foundation/oi_chart_marker.dart` — Extend existing `OiChartMarkerStyle` with `visible`, `dashPattern` fields
- [ ] `lib/src/models/oi_chart_series.dart` — Add `style: OiSeriesStyle?`, `animation: OiSeriesAnimationConfig?`, `legend: OiSeriesLegendConfig?` fields to `OiChartSeries<T>`
- [ ] Export new files from barrel
- [ ] TDD: OiSeriesStyle merges hover/selected/inactive overrides correctly
- [ ] TDD: OiSeriesFill.solid and OiSeriesFill.gradient produce correct values
- [ ] Verify: `dart analyze` && `flutter test packages/obers_ui_charts`

### Phase 3: ZoomPanBehavior + Annotation/Threshold Models

- **Goal**: Implement the only missing behavior; add annotation/threshold data models
- [ ] `lib/src/behaviors/oi_zoom_pan_behavior.dart` — `OiZoomPanBehavior extends OiChartBehavior`: wheel zoom (onPointerScroll → viewport.zoomTo), pinch zoom (track two pointers), drag pan (onPointerDown/Move/Up → viewport.panBy), min/maxZoom constraints, zoomToRange(Rect), onZoomChanged callback. Dispatch onViewportChanged to all sibling behaviors.
- [ ] `lib/src/models/oi_chart_annotation.dart` — `OiAnnotationType` enum (horizontalLine/verticalLine/region/point/label), `OiAnnotationStyle` (color, strokeWidth, dashPattern, fill, labelStyle), `OiChartAnnotation` (type, value/start/end, style, label, visible)
- [ ] `lib/src/models/oi_chart_threshold.dart` — `OiChartThreshold` (value, label, color, dashPattern, labelPosition: OiThresholdLabelPosition), `OiThresholdLabelPosition` enum (above/below/inline/start/end)
- [ ] Export new files from barrel
- [ ] TDD: ZoomPanBehavior — scroll event increases zoom; drag pan updates panOffset; min/max zoom clamped; resetZoom restores defaults
- [ ] TDD: OiChartAnnotation — horizontalLine/verticalLine/region construct correctly; style merges with theme defaults
- [ ] Verify: `dart analyze` && `flutter test packages/obers_ui_charts`

### Phase 4: Legend Config + Formatter Contexts + Axis Enrichment

- **Goal**: Fill remaining data model gaps
- [ ] `lib/src/models/oi_chart_legend_config.dart` — `OiChartLegendConfig` (show, position: OiResponsive<OiChartLegendPosition>?, wrapBehavior: OiLegendWrapBehavior, allowSeriesToggle, allowExclusiveFocus, itemBuilder), `OiLegendWrapBehavior` enum (wrap/scroll/collapse)
- [ ] `lib/src/foundation/oi_chart_formatters.dart` — Add `OiAxisFormatContext extends OiFormatterContext` with axisPosition, isFirstTick, isLastTick, availableWidth. Add `OiTooltipFormatContext` with seriesId, seriesLabel, pointIndex. Keep generic `OiFormatterContext` as base.
- [ ] `lib/src/composites/oi_chart_axis.dart` — Upgrade `OiTickStrategy` from enum to class with `maxCount`, `minSpacingPx`, `includeEndpoints`, `niceValues`. Add static const `auto/even/all/minMax` factories for backward compat.
- [ ] `lib/src/models/oi_axis_range.dart` — `OiAxisRange<TDomain>` with min/max typed domain bounds
- [ ] `lib/src/foundation/oi_chart_accessibility_bridge.dart` — Add `OiDetectedChartInsight` class. Add typed `announcePoint()`, `announceSummary()`, `announceNavigation()` methods (delegating to existing generic `announce()`).
- [ ] Export new files from barrel
- [ ] TDD: OiTickStrategy.auto has sensible defaults; OiTickStrategy(maxCount: 5) limits ticks
- [ ] TDD: OiAxisFormatContext provides tick position flags correctly
- [ ] Verify: `dart analyze` && `flutter test packages/obers_ui_charts`

### Phase 5: Component Widgets

- **Goal**: Build the 5 missing component widgets
- [ ] `lib/src/components/oi_chart_axis_widget.dart` — `OiChartAxisWidget` renders axis line, ticks, labels, title using `OiChartAxisPainter`. Responsive tick density via `maxVisibleTicks`, label overflow via `labelOverflow`. Accepts `OiChartAxis` config + `OiChartViewport`.
- [ ] `lib/src/components/oi_chart_tooltip_widget.dart` — `OiChartTooltipWidget` wraps `OiChartTooltipBehavior` overlay rendering into a standalone widget usable outside behavior system. Uses `OiOverlays` for positioning.
- [ ] `lib/src/components/oi_chart_crosshair_widget.dart` — `OiChartCrosshairWidget` renders horizontal/vertical guide lines at pointer position within plot bounds. CustomPaint-based.
- [ ] `lib/src/components/oi_chart_brush_widget.dart` — `OiChartBrushWidget` renders visual selection rectangle. Syncs with `OiChartBrushBehavior` state.
- [ ] `lib/src/components/oi_chart_annotation_layer.dart` — `OiChartAnnotationLayer` renders `List<OiChartAnnotation>` and `List<OiChartThreshold>` as CustomPaint overlays within plot bounds.
- [ ] Export new files from barrel
- [ ] TDD: AxisWidget renders correct number of tick labels for given maxVisibleTicks
- [ ] TDD: AnnotationLayer renders horizontal/vertical lines at correct positions
- [ ] TDD: CrosshairWidget shows/hides lines based on pointer position
- [ ] Verify: `dart analyze` && `flutter test packages/obers_ui_charts`

### Phase 6: Composite Wiring

- **Goal**: Wire behavior lifecycle, normalization, streaming, sync, persistence, decimation into family base composites
- [ ] `lib/src/composites/_chart_behavior_host.dart` — Shared mixin `ChartBehaviorHost` on `State`: attach behaviors on initState/didUpdateWidget, detach on dispose, build `OiChartBehaviorContext`, forward pointer/key events to all behaviors, collect overlay widgets from behaviors
- [ ] `lib/src/composites/_chart_data_pipeline.dart` — Shared mixin `ChartDataPipeline`: normalize raw data → `OiChartDatum` list, apply decimation based on `OiChartPerformanceConfig`, manage `OiStreamingSeriesAdapter` subscriptions, handle theme fallback chain (series → chart → context → auto)
- [ ] `lib/src/composites/oi_cartesian_chart.dart` — Wire: behavior host mixin, data pipeline mixin, sync group registration/unregistration, persistence save/restore via `OiChartSettings`, render axis widgets + annotation layer + behavior overlays in Stack. Use `Listener` widget for pointer event dispatch to behaviors.
- [ ] `lib/src/composites/oi_polar_chart.dart` — Same wiring. Add `OiPolarAngleAxis`/`OiPolarRadiusAxis` config classes.
- [ ] `lib/src/composites/oi_matrix_chart.dart` — Same wiring. Add `OiColorScale` class for color mapping.
- [ ] `lib/src/composites/oi_hierarchical_chart.dart` — Same wiring (no axis).
- [ ] `lib/src/composites/oi_flow_chart.dart` — Same wiring (no axis).
- [ ] TDD: Cartesian chart attaches/detaches behaviors on mount/unmount
- [ ] TDD: Cartesian chart with streaming source receives data updates and rebuilds
- [ ] TDD: Cartesian chart shows "all series hidden" message when all series toggled off
- [ ] TDD: Controller disposed while behaviors attached → behaviors auto-detach without error
- [ ] Verify: `dart analyze` && `flutter test packages/obers_ui_charts`

### Phase 7: Edge Cases + Utilities

- **Goal**: Handle all spec edge cases; add missing utilities
- [ ] `lib/src/utils/chart_math.dart` — clampZoom, domainPadding for single-point, NaN/Infinity → missing detection
- [ ] `lib/src/utils/path_utils.dart` — Path interpolation helpers for smooth line charts
- [ ] `lib/src/utils/label_collision.dart` — Label overlap detection, stagger/rotate/skip strategies
- [ ] `lib/src/foundation/oi_logarithmic_scale.dart` — Clamp negative values + dev-mode log warning (req 94)
- [ ] `lib/src/composites/oi_cartesian_chart.dart` — Single-point data → default domain padding (req 92); all-series-hidden → descriptive empty state (req 93)
- [ ] `lib/src/foundation/oi_chart_viewport.dart` — Clamp zoom to prevent zero-range (req 100)
- [ ] `lib/src/models/oi_chart_series.dart` — NaN/Infinity y-values treated as missing in normalization (req 95)
- [ ] Theme change mid-animation → restart animation controller (req 99)
- [ ] `OiChartSyncCoordinator` lazy provisioning in `OiApp` (req 84) — InheritedWidget in obers_ui main package
- [ ] TDD: Single data point produces visible chart with padding
- [ ] TDD: NaN y-value treated as missing (gap in line, skipped in bar)
- [ ] TDD: Negative log scale values clamped, assertion in debug mode
- [ ] Verify: `dart analyze` && `flutter test packages/obers_ui_charts`

### Phase 8: Test Coverage Expansion

- **Goal**: Bring test coverage to spec expectations
- [ ] `test/src/foundation/oi_chart_scale_test.dart` — All 8 scale types: domain→range mapping, inverse, ticks generation, edge cases (empty domain, single value)
- [ ] `test/src/foundation/oi_chart_hit_tester_test.dart` — Nearest point, binary search, tolerance, multi-series hit test
- [ ] `test/src/components/oi_chart_legend_test.dart` — Toggle, keyboard nav, responsive position
- [ ] `test/src/components/oi_chart_tooltip_test.dart` — Show/hide timing, anchor modes, custom builder
- [ ] `test/src/components/oi_chart_axis_widget_test.dart` — Tick count, label overflow, responsive density
- [ ] `test/src/behaviors/oi_zoom_pan_behavior_test.dart` — Wheel zoom, pinch, drag pan, constraints
- [ ] `test/src/composites/oi_cartesian_chart_integration_test.dart` — Multi-series render, zoom+pan, sync group, persistence round-trip, error/loading/empty states
- [ ] `test/src/foundation/oi_chart_theme_test.dart` — Palette assignment, override chain, light/dark
- [ ] Verify: `flutter test packages/obers_ui_charts --coverage` && review uncovered lines

## Risks / Out of scope

- **Risks**:
  - Phase 6 (composite wiring) is the highest-risk phase — touches all 5 family base composites simultaneously. Mitigate by extracting shared logic into mixins first.
  - `OiTickStrategy` enum→class upgrade (Phase 4) is a breaking change for any code using the enum. Mitigate with static const factories matching old enum names.
  - Behavior pointer event dispatch in composites requires wrapping content in `Listener`/`GestureDetector` — must not conflict with child widget gesture recognizers.
- **Out of scope**:
  - Golden tests (need stable rendering first)
  - Performance benchmarks (1k/10k points)
  - Animation enum refactor (current class-based approach is intentionally more flexible)
  - Naming convention unification (existing `OiChart*` prefix on migrated classes is kept)
