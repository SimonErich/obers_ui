## Overview

Close remaining gaps: persistence model enrichment, responsive expansion, convention compliance (Text→OiLabel, hardcoded colors→theme), composite wiring (sync, persistence, normalization), and test coverage for legend/tooltip/crosshair/brush behaviors.

**Gap analysis**: `concept/25-03-chart-gaps-2.md` (sections 6–11)

## Context

- **Structure**: tier-based (`foundation/` → `models/` → `behaviors/` → `components/` → `composites/`)
- **State management**: `ChangeNotifier`-based `OiChartController`, `ChartBehaviorHost` mixin
- **Reference implementations**: `lib/src/composites/_chart_behavior_host.dart` (mixin), `lib/src/models/oi_chart_settings.dart` (persistence), `lib/src/foundation/oi_chart_tooltip.dart` (convention violations)
- **Assumptions**: `accessibilityBridge` stays nullable in `OiChartBehaviorContext` (no-op bridge always provided by mixin). Animation enum deviation is documented, not implemented.

## Plan

### Phase 1: Persistence Model Enrichment

- **Goal**: Create typed persistence classes; add OiChartComplexity
- [x] `lib/src/models/oi_chart_settings.dart` — Add `OiPersistedViewport` class (xMin, xMax, yMin, yMax doubles, toJson/fromJson, ==, hashCode). Add `OiPersistedSelection` class (selectedRefs as List of {seriesIndex, dataIndex} maps, toJson/fromJson). Replace `viewportWindow: Rect?` → `viewport: OiPersistedViewport?`. Replace `selectedSeriesIndex: int?` + `selectedDataIndex: int?` → `selection: OiPersistedSelection?`. Change `legendExpandedGroups: Set<String>` → `Map<String, bool>`. Bump schema version. Update toJson/fromJson/mergeWith/copyWith/==/hashCode.
- [x] `lib/src/models/oi_chart_complexity.dart` — Create `OiChartComplexity` enum: `mini`, `standard`, `detailed`
- [x] `lib/src/composites/oi_cartesian_chart.dart` — Add `complexity: OiResponsive<OiChartComplexity>?` param + field
- [x] Export `oi_chart_complexity.dart` from barrel
- [x] TDD: OiPersistedViewport round-trips via toJson/fromJson
- [x] TDD: OiPersistedSelection round-trips refs correctly
- [x] TDD: OiChartSettings with new types serializes/deserializes without loss
- [x] Verify: `dart analyze` && `flutter test`

### Phase 2: Convention Compliance — Text/Color Fixes

- **Goal**: Replace all raw Text() and hardcoded Color() in chart package with OiLabel and theme tokens
- [x] `lib/src/foundation/oi_chart_tooltip.dart` — Replace `Text()` → `OiLabel.caption()` / `OiLabel.body()`. Replace `Column` → `OiColumn`, `Row` → `OiRow`. Replace 6 hardcoded `Color(0x...)` → theme tokens from `OiChartTooltipTheme` or `context.colors`
- [x] `lib/src/components/oi_chart_tooltip_widget.dart` — Same: `Text()` → `OiLabel`, hardcoded colors → theme
- [x] `lib/src/composites/oi_chart_legend.dart` — Replace `Row` → `OiRow`, `Text` → `OiLabel.body()`
- [x] `lib/src/composites/oi_pie_chart.dart` — Replace `Text()` → `OiLabel`
- [x] `lib/src/composites/oi_funnel_chart.dart` — Replace `Text()` → `OiLabel`
- [x] `lib/src/composites/oi_sankey.dart` — Replace `Text()` → `OiLabel`
- [x] `lib/src/composites/oi_bar_chart/oi_bar_chart.dart` — Replace `Text()` → `OiLabel`
- [x] `lib/src/composites/oi_bar_chart/oi_bar_chart_legend.dart` — Replace `Text()` → `OiLabel`
- [x] `lib/src/composites/oi_combo_chart.dart` — Replace `Text()` → `OiLabel`
- [x] `lib/src/composites/oi_area_chart/oi_area_chart.dart` — Replace `Text()` → `OiLabel`
- [x] `lib/src/composites/oi_area_chart/oi_area_chart_legend.dart` — Replace `Text()` → `OiLabel`
- [x] `lib/src/components/oi_chart_crosshair_widget.dart` — Replace fallback `Color(0x80888888)` → theme
- [x] `lib/src/components/oi_chart_axis_widget.dart` — Replace 3 fallback colors → theme tokens
- [x] `lib/src/components/oi_chart_annotation_layer.dart` — Replace fallback color → theme
- [x] Verify: `dart analyze` && `flutter test`

### Phase 3: Composite Wiring — Sync + Persistence + Normalization

- **Goal**: Wire remaining orchestration into composites
- [x] `lib/src/composites/_chart_behavior_host.dart` — Add `syncGroup` getter override requirement. In `attachBehaviors()`, if syncGroup set, look up `OiChartSyncProvider.maybeOf(context)` → call `addViewportListener`/`addCrosshairListener`. In `disposeBehaviorHost()`, remove listeners. Add `persistSettings()` method: if settings binding provided, serialize controller state to `OiChartSettings` and save.
- [x] `lib/src/composites/oi_cartesian_chart.dart` — Override `syncGroup` getter. In build, after computing visible series, call `normalizeSeries()` on each to produce `List<OiChartDatum>`. Apply decimation if `performance?.decimation != OiChartDecimationStrategy.none`. Store normalized datums for optional use by seriesBuilder.
- [x] `lib/src/composites/oi_polar_chart.dart` — Override `syncGroup`. Wire streaming host `attachStreamingAdapters()` in initState.
- [x] `lib/src/composites/oi_matrix_chart.dart` — Same wiring
- [x] `lib/src/composites/oi_hierarchical_chart.dart` — Same (no normalization)
- [x] `lib/src/composites/oi_flow_chart.dart` — Same (no normalization)
- [x] TDD: Cartesian chart registers with sync coordinator on mount when syncGroup is set
- [x] TDD: Cartesian chart unregisters from sync coordinator on dispose
- [x] TDD: Cartesian chart normalizes series data into OiChartDatum list
- [x] Verify: `dart analyze` && `flutter test`

### Phase 4: Test Coverage — Legend Widget

- **Goal**: Add comprehensive legend widget tests
- [x] `test/src/composites/oi_chart_legend_test.dart` — Tests:
  - Legend renders all series items with correct labels and colors
  - Tapping legend item fires onToggle callback
  - Hidden series shown with reduced opacity / strike-through
  - Custom itemBuilder replaces default rendering
  - Legend wraps to next line when items overflow available width
- [x] Verify: `flutter test`

### Phase 5: Test Coverage — Behavior Tests

- **Goal**: Add tooltip, crosshair, and brush behavior tests
- [x] `test/src/behaviors/oi_chart_tooltip_behavior_test.dart` — Tests:
  - Tooltip shows on hover after showDelay
  - Tooltip hides after hideDelay when pointer leaves
  - Tooltip anchors to nearest point when anchorMode is nearestPoint
  - Tooltip shows on tap when trigger is tap
  - Custom builder receives correct OiChartTooltipModel
  - Tooltip dismissed on detach
- [x] `test/src/behaviors/oi_chart_crosshair_behavior_test.dart` — Tests:
  - Crosshair lines appear at pointer position on hover
  - Horizontal-only and vertical-only modes work
  - Crosshair hidden when pointer leaves chart area
- [x] `test/src/behaviors/oi_chart_brush_behavior_test.dart` — Tests:
  - Drag creates brush rectangle between start and end positions
  - Brush rectangle coordinates map to domain range
  - Brush cleared on escape or click outside
  - onBrushEnd callback fires with selected domain range
- [x] Verify: `flutter test`

### Phase 6: Integration Tests + Documentation

- **Goal**: Integration tests for wired composites; document animation deviation
- [x] `test/src/composites/oi_cartesian_chart_wiring_test.dart` — Tests:
  - Zoom+pan round-trip: zoom in via controller → viewport changes → reset → back to default
  - Streaming: chart with streaming source shows updated data after adapter emission
  - Persistence: save settings → dispose → restore → controller state matches
  - Mixed-type x-values across series produces consistent rendering (or throws ArgumentError)
- [x] `lib/src/foundation/oi_chart_animation_config.dart` — Add doc comment documenting the intentional deviation from spec's animation enums: "The spec defines OiChartEnterAnimation/Update/Exit enums. This implementation uses class-based OiPhaseAnimationConfig which is more flexible — any curve+duration combination is expressible, not just named presets."
- [x] Verify: `flutter test`

## Risks / Out of scope

- **Risks**:
  - Phase 1 persistence model change breaks existing OiChartSettings toJson/fromJson. Mitigate: bump schemaVersion + migration in fromJson for old format.
  - Phase 2 convention fixes touch ~15 files. Mitigate: mechanical find-replace, run full test suite after each batch.
  - Phase 3 sync wiring requires InheritedWidget lookup in build — may fail if no OiApp ancestor in test environment. Mitigate: null-safe `maybeOf` with graceful no-op.
- **Out of scope**:
  - Golden tests (need stable rendering first)
  - Performance benchmarks (1k/10k points)
  - Tier B/C charts (histogram, waterfall, boxplot, sunburst, etc.)
  - Modules (OiAnalyticsDashboard, OiChartExplorer, OiKpiBoard)
  - OiApp lazy sync coordinator provisioning (requires main package changes)
  - Making `accessibilityBridge` non-nullable in context (no-op already provided by mixin)
