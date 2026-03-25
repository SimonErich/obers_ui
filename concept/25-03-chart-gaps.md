# obers_ui_charts — Gap Analysis (2026-03-25)

**Spec reference:** `concept/obers_ui_charts-spec.md`
**Previous gap analysis:** `concept/obers_ui_charts-gap-analysis.md`
**Overall:** 537 tests pass, 0 analysis errors in package. ~85% of spec requirements implemented; remaining gaps cluster around internal wiring, missing types, convention violations, and test coverage.

---

## 1. Foundation Layer Gaps (Reqs 5–36)

### Req 9 — `OiChartScale<T>.withDomain()` method missing

**Spec:** `OiChartScale<TDomain> withDomain(TDomain min, TDomain max)` — create constrained copy.
**Actual:** No `withDomain()` method on any scale class.
**Fix:** Add abstract `withDomain()` to `OiChartScale<T>` and implement in all 8 concrete scales. Each returns a copy with overridden domain min/max.

### Req 9 — `buildTicks` signature differs

**Spec:** `List<TDomain> buildTicks(OiAxisTickStrategy strategy, double axisLength)`
**Actual:** `List<OiTick<T>> buildTicks({int count = 5})` — takes `count` int, not a strategy object + axis length.
**Fix:** Add overload or update signature to accept `OiTickStrategy` and `double axisLength`. Current `count` can stay as fallback.

### Req 11 — `OiTickStrategy` class upgrade incomplete

**Spec:** `OiAxisTickStrategy` — class with `maxCount`, `minSpacingPx`, `includeEndpoints`, `niceValues`.
**Actual:** `OiTickStrategy` class exists with all four fields + `mode` enum. Static const `auto/even/all/minMax` presets present.
**Remaining:** The `buildTicks()` method on scales does NOT consume the `OiTickStrategy` class — it still takes `{int count}`. The class exists but is unused by the scale system.
**Fix:** Wire `OiTickStrategy` into `OiChartScale.buildTicks()` so scales actually use `maxCount`, `minSpacingPx`, `niceValues`, and `includeEndpoints` when generating ticks.

### Req 12 — `visibleDomainX`/`visibleDomainY` as separate fields

**Spec:** Separate `visibleDomainX` and `visibleDomainY` range properties on `OiChartViewport`.
**Actual:** Single `visibleDomain: Rect?` field.
**Fix:** Add computed `visibleDomainX` and `visibleDomainY` getters that extract from the existing `visibleDomain` Rect, or add dedicated range tuple fields.

### Req 14 — `OiChartBehavior.buildOverlays()` missing

**Spec:** `List<Widget> buildOverlays(OiChartBehaviorContext context)` — behaviors can contribute overlay widgets (tooltip, crosshair).
**Actual:** No `buildOverlays()` method. Overlay rendering is handled by the tooltip behavior internally via `OiOverlays`.
**Fix:** Add `List<Widget> buildOverlays() => const []` default method to `OiChartBehavior`. Composites should call `buildOverlays()` on each behavior and render them in a Stack above the chart content.

### Req 15 — `BehaviorContext.accessibilityBridge` is nullable

**Spec:** `OiChartAccessibilityBridge accessibility` (non-nullable).
**Actual:** `OiChartAccessibilityBridge? accessibilityBridge` (nullable).
**Fix:** Either make non-nullable with a no-op default, or document the intentional nullable design. The `ChartBehaviorHost` mixin currently passes no accessibility bridge when creating the context — it should create a default bridge.

### Req 19 — `OiChartAccessibilitySummary` naming mismatch

**Spec:** `OiChartAccessibilitySummary` with `insights: List<OiDetectedChartInsight>`.
**Actual:** `OiChartSummaryData` (different class name). `OiDetectedChartInsight` exists in the bridge file.
**Fix:** Either rename `OiChartSummaryData` → `OiChartAccessibilitySummary`, or add a typedef/alias. Verify `insights` field references `OiDetectedChartInsight`.

### Req 21–22 — Animation enums not implemented

**Spec:** Three enums: `OiChartEnterAnimation` (grow/fade/slide/none), `OiChartUpdateAnimation` (morph/crossfade/none), `OiChartExitAnimation` (shrink/fade/none).
**Actual:** Class-based `OiPhaseAnimationConfig` with `duration` + `curve` per phase. No enum types for animation modes.
**Decision:** The class-based approach is more flexible (you can configure any curve/duration). This is an intentional design deviation. **Document this in the spec or add the enums as optional convenience on top of the class approach.**

### Req 23 — Performance config defaults wrong

**Spec:** `progressiveChunkSize: 5000`, `maxInteractivePoints: 10000`.
**Actual:** `progressiveChunkSize: 500`, `maxInteractivePoints: 5000`.
**Fix:** Update defaults in `oi_chart_performance_config.dart` lines 61–62 to match spec values.

### Req 28 — Streaming adapter missing `appendMode` and `windowDuration`

**Spec:** `OiStreamingSeriesAdapter` should have `appendMode` (append/replace) and `windowDuration` (time-based windowing).
**Actual:** Neither field exists. The adapter always appends.
**Fix:** Add `OiStreamingAppendMode` enum (`append`/`replace`) and `Duration? windowDuration` to the adapter constructor. In `replace` mode, each stream emission replaces the buffer entirely. `windowDuration` evicts data older than the window.

### Req 30 — Persistence model simplified

**Spec:** `viewport: OiPersistedViewport?`, `selection: OiPersistedSelection?`, `expandedLegendGroups: Map<String, bool>`.
**Actual:** `viewportWindow: Rect?`, `selectedSeriesIndex: int?` + `selectedDataIndex: int?`, `legendExpandedGroups: Set<String>`.
**Fix:**
1. Create `OiPersistedViewport` class with `xMin/xMax/yMin/yMax` (or keep `Rect?` and document the mapping).
2. Create `OiPersistedSelection` class with `selectedRefs: Set<OiChartDataRef>` (or structured fields).
3. Change `legendExpandedGroups` from `Set<String>` to `Map<String, bool>` to track both expanded and explicitly-collapsed groups.

### Req 32 — Sync coordinator method names differ

**Spec:** `broadcastHover(syncGroup, xDomainValue, sourceChartId)`, `broadcastViewport(syncGroup, viewport, sourceChartId)`.
**Actual:** `syncViewport(OiChartViewport)`, `syncSelection(Set<OiChartDataRef>)`, `syncCrosshair(double? normalizedX)`. No `sourceChartId` parameter.
**Fix:** Add `String sourceChartId` to sync methods. Add `broadcastHover` and `broadcastViewport` methods matching spec signature. Existing sync methods can delegate.

### Req 32 — `OiChartSyncCoordinator` not provisioned in `OiApp`

**Spec:** Provided via InheritedWidget from `OiApp` (lazy, only when needed).
**Actual:** No reference to `OiChartSyncCoordinator` in obers_ui's `OiApp`.
**Fix:** Add a lazy `OiChartSyncCoordinator` InheritedWidget inside `OiApp`. Create only when first chart with `syncGroup` requests it.

### Reqs 33–34 — Formatter typedefs use generic context instead of specific

**Spec:** `OiAxisFormatter<T>` should take `OiAxisFormatContext`, `OiTooltipValueFormatter` should take `OiTooltipFormatContext`.
**Actual:** Both use generic `OiFormatterContext<T>`. The specific context classes (`OiAxisFormatContext`, `OiTooltipFormatContext`) exist but are not used in the typedefs.
**Fix:** Update typedefs to reference the specific context types:
```dart
typedef OiAxisFormatter<T> = String Function(T value, OiAxisFormatContext<T> context);
typedef OiTooltipValueFormatter = String Function(double value, OiTooltipFormatContext context);
```
This is a breaking change for anyone using the current typedefs.

---

## 2. Data Contract Gaps (Reqs 37–56)

### Req 44 — `OiChartAxis` missing `domain: OiAxisRange<TDomain>?` field

**Spec:** `domain: OiAxisRange<TDomain>?` (explicit min/max override).
**Actual:** Separate `domainMin: TDomain?` and `domainMax: TDomain?` fields. `OiAxisRange` class exists but is not referenced by axis.
**Fix:** Either add `domain: OiAxisRange<TDomain>?` as a convenience field that delegates to domainMin/domainMax, or document the intentional API divergence.

### Req 51 — `OiChartSelectionState` fields differ from spec

**Spec:** `selectedPointIndices`, `selectedSeriesIds`, `selectedDomainRange`.
**Actual:** `selectedRefs: Set<OiChartDataRef>`, `mode: OiChartSelectionMode`, `timestamp: DateTime?`.
**Assessment:** The actual implementation is more precise (references contain both series and point index). The spec fields can be derived from refs. This is an improvement over spec, not a bug. **Document the deviation.**

### Req 55 — `OiSeriesStyle` missing `marker` field

**Spec:** `marker: OiMarkerStyle?` (for styling data point markers at series level).
**Actual:** `OiSeriesStyle` has strokeColor, strokeWidth, fill, dashPattern, dataLabelStyle, state overrides — but NO `marker` field. `OiChartMarkerStyle` class exists separately.
**Fix:** Add `OiChartMarkerStyle? marker` field to `OiSeriesStyle`, include in `copyWith`, `merge`, `==`, and `hashCode`.

### Req 60 — `OiHitTestResult` field names differ

**Spec:** `seriesId: String`, `pointIndex: int`, `datum: OiChartDatum`, `distance: double`, `screenPosition: Offset`.
**Actual:** Uses `ref: OiChartDataRef` (contains `seriesIndex: int`, `dataIndex: int`), `position: Offset`, `distance: double`. No `seriesId` string, no `datum`.
**Assessment:** The structured `OiChartDataRef` approach is valid. However, direct `seriesId` string access and `datum` would be convenient.
**Fix:** Consider adding convenience getters or leave as-is and document the mapping.

---

## 3. Component Widget Gaps (Reqs 62–72)

### Req 63 — `OiChartLegend` uses raw `Row`/`Text` instead of OiRow/OiLabel

**Spec:** "OiRow/OiColumn layout, OiLabel for text, keyboard navigable, responsive position via OiResponsive".
**Actual:** Uses raw `Row` (line 293) and raw `Text()` (line 303) in `oi_chart_legend.dart`. No keyboard navigation. No OiResponsive positioning.
**Fix:**
1. Replace `Row` → `OiRow`, `Text` → `OiLabel` in the legend widget.
2. Add keyboard navigation (Focus + arrow key handling) to legend items.
3. Wrap position logic in `OiResponsive` for automatic top/bottom/left/right switching at breakpoints.

### Tooltip/Crosshair widgets — hardcoded colors

**Files:** `oi_chart_tooltip.dart` (lines 506–572), `oi_chart_tooltip_widget.dart` (lines 68–100).
**Issue:** Multiple hardcoded `Color(0x...)` values for backgrounds, text, shadows. Spec convention says "All colors from theme, never hardcoded".
**Fix:** Replace hardcoded colors with theme tokens from `OiChartTooltipTheme` / `context.colors`. The tooltip widget already reads `tooltipTheme` but falls back to hardcoded values for several secondary colors (label color, secondary text color, shadow).

---

## 4. Composite Wiring Gaps (Reqs 73–77)

These are the **largest remaining gaps**. The composites have `ChartBehaviorHost` mixin for behavior attach/detach and pointer forwarding, but lack the deeper orchestration the spec requires.

### Req 73–77 — Data normalization pipeline not implemented

**Spec:** Composites should "orchestrate data normalization" — converting raw domain data through scales into `OiChartDatum` lists.
**Actual:** `OiChartDatum` and `normalizeSeries()` function exist in the datum file, but composites never call them. The `seriesBuilder` callback receives raw series data, not normalized datums.
**Fix:** Create `_ChartDataPipeline` mixin or utility that:
1. Iterates visible series
2. Calls `normalizeSeries()` on each to produce `List<OiChartDatum>`
3. Applies decimation if `performance.decimation != none`
4. Passes normalized datums to the series builder

### Req 73–77 — Sync group registration not wired

**Spec:** Composites should register with `OiChartSyncCoordinator` on mount and unregister on dispose.
**Actual:** `syncGroup` param accepted but never used in any composite's state lifecycle.
**Fix:** In `initState`, look up `OiChartSyncCoordinator` from context (via InheritedWidget). Register with `syncGroup.id`. Unregister in `dispose`. Coordinate via `effectiveController`.

### Req 73–77 — Persistence save/restore not wired

**Spec:** Composites should save/restore chart settings via `OiSettingsMixin` pattern.
**Actual:** `OiChartSettings` model exists. No composite references it.
**Fix:** Add optional `settings: OiChartSettings?` param to composites. On mount, restore controller state from settings. On state change, persist to settings.

### Req 73–77 — Streaming adapter management not wired

**Spec:** Composites should manage `OiStreamingSeriesAdapter` subscriptions, attaching on mount and detaching on dispose.
**Actual:** Series with `streamingSource` are accepted but no adapter lifecycle management occurs. The composite doesn't subscribe to stream updates.
**Fix:** In `initState`/`didUpdateWidget`, for each series with `streamingSource`, create/update an `OiStreamingSeriesAdapter`. Listen for data changes and trigger rebuild. Dispose adapters on unmount.

### Req 73–77 — Behavior overlay rendering not wired

**Spec:** Composites should collect overlay widgets from behaviors and render in a Stack.
**Actual:** Behaviors are attached and receive pointer events, but there's no overlay collection. `buildOverlays()` doesn't exist on the behavior base class (see Req 14 gap).
**Fix:** After implementing `buildOverlays()` on behaviors, composites should wrap content in a Stack that includes `[content, ...behaviorOverlays]`.

### Req 73 — Cartesian chart missing shared props

**Spec:** "Plus all shared props from `OiChartWidget` base (label, semanticLabel, theme, **legend**, behaviors, annotations, thresholds, performance, animation, accessibility, **settings**, controller, syncGroup, loading/empty/error states)".
**Actual:** Missing `legend: OiChartLegendConfig?` and `settings: OiChartSettings?` params.
**Fix:** Add `legend` and `settings` params to `OiCartesianChart` (and other composites).

### Req 74 — `OiPolarAngleAxis` and `OiPolarRadiusAxis` missing

**Spec:** `OiPolarChart` should accept `angleAxis: OiPolarAngleAxis` and `radiusAxis: OiPolarRadiusAxis`.
**Actual:** These types don't exist. OiPolarChart has no axis params.
**Fix:** Create `OiPolarAngleAxis` and `OiPolarRadiusAxis` data classes (label, formatter, ticks, range). Add as optional params to `OiPolarChart`.

### Req 75 — `OiColorScale` missing

**Spec:** `OiMatrixChart` should accept `colorScale: OiColorScale` for mapping cell values to colors.
**Actual:** `OiColorScale` doesn't exist.
**Fix:** Create `OiColorScale` class with `Color resolve(num value)` method, supporting linear interpolation between min/max colors and optional gradient stops.

---

## 5. Error Handling & Edge Case Gaps (Reqs 86–100)

### Req 87 — Mixed-type x-values error not implemented

**Spec:** "Mixed-type x-values → throw descriptive error at normalization time".
**Actual:** No validation. `resolvedXScaleType` infers from the first series' first data point. If series have mixed types, silent type mismatch.
**Fix:** In the normalization pipeline (when implemented), validate that all series produce the same x-value type. Throw `ArgumentError` with message like `'Series "A" produces String x-values but series "B" produces DateTime. All series in a cartesian chart must have consistent x-types.'`

### Req 90 — Theme fallback chain not implemented

**Spec:** Resolution order: series style → chart-local theme → `context.components.chart` → auto-derived from `context.colors`.
**Actual:** No cascading theme resolution. Components use `OiChartThemeData()` default or widget's theme prop.
**Fix:** Implement in composites:
```dart
OiChartThemeData get _resolvedTheme =>
    widget.theme ?? context.components.chart ?? OiChartThemeData.fromContext(context);
```
Then for series-level style: `series.style?.strokeColor ?? _resolvedTheme.palette.categorical[seriesIndex]`.

### Req 98 — Controller dispose does not auto-detach behaviors

**Spec:** "Controller disposed while behaviors attached → behaviors auto-detach".
**Actual:** `OiDefaultChartController.dispose()` inherits from `ChangeNotifier.dispose()` — no behavior detach logic.
**Fix:** The `ChartBehaviorHost.disposeBehaviorHost()` already calls `detachBehaviors()` before disposing the internal controller. This gap is only when an external controller is disposed independently. Fix: have the composite listen to the controller and detach behaviors if the controller is disposed.

### Req 99 — Theme change mid-animation not handled

**Spec:** "Theme change mid-animation → restart animation with new theme values, don't glitch".
**Actual:** Not implemented. No animation controllers exist in composites.
**Fix:** When composites implement animations, add a `didUpdateWidget` check for theme changes. If an animation is in progress, restart with the new theme's motion config.

---

## 6. Convention Violations

### Raw `Text()` usage (violates "All text via OiLabel")

**Files with `Text()` instead of `OiLabel`:**
- `lib/src/foundation/oi_chart_tooltip.dart` — lines 524, 530, 550, 558, 572
- `lib/src/components/oi_chart_tooltip_widget.dart` — fallback tooltip content
- `lib/src/composites/oi_chart_legend.dart` — line 303
- `lib/src/components/oi_chart_empty_state.dart` (if applicable)

### Raw `Row`/`Column` usage (violates "All layouts via OiRow/OiColumn")

**Files with `Row`/`Column` instead of `OiRow`/`OiColumn`:**
- `lib/src/foundation/oi_chart_tooltip.dart` — lines 519 (Column), 536 (Row)
- `lib/src/components/oi_chart_tooltip_widget.dart` — tooltip layout
- `lib/src/composites/oi_chart_legend.dart` — line 293 (Row)

### Hardcoded colors (violates "All colors from theme")

**Files with hardcoded `Color(0x...)` values:**
- `lib/src/foundation/oi_chart_tooltip.dart` — 6 hardcoded colors
- `lib/src/components/oi_chart_tooltip_widget.dart` — 6 hardcoded colors
- `lib/src/foundation/oi_chart_marker.dart` — line 420 `Color(0xFF000000)` fallback in cross painter

---

## 7. Test Coverage Gaps

### Missing test files

| Area | Spec Expects | Actual | Gap |
|------|-------------|--------|-----|
| **Controller tests** | 6+ tests | `oi_default_chart_controller_test.dart` (18 tests) | ✓ Covered |
| **Scale tests** | 8 groups | `oi_chart_scale_test.dart` (81 tests) | ✓ Covered |
| **Hit tester tests** | 6 tests | `oi_chart_hit_tester_test.dart` (25 tests) | ✓ Covered |
| **Legend widget tests** | 5 tests | **0 tests** | ❌ Missing |
| **Tooltip widget tests** | 6 tests | `oi_chart_component_widgets_test.dart` has 1 tooltip test | ⚠️ Minimal |
| **Axis widget tests** | 5 tests | 1 test in component widgets | ⚠️ Minimal |
| **Tooltip behavior tests** | 8 tests | **0 tests** | ❌ Missing |
| **Crosshair behavior tests** | 4 tests | **0 tests** | ❌ Missing |
| **Brush behavior tests** | 4 tests | **0 tests** | ❌ Missing |
| **Composite integration tests** | 20+ tests | 15 render + 3 behavior | ⚠️ Basic only |
| **Accessibility tests** | 8 tests | 4 (keyboard behavior) | ⚠️ Partial |
| **Performance tests (1k/10k points)** | 5 tests | **0 tests** | ❌ Missing |
| **Theme tests** | 6 tests | **0 tests** | ❌ Missing |
| **Golden tests** | Multiple | **0 tests** | ❌ Missing |

### Missing integration test scenarios

- Multi-series render with interleaved data
- Zoom + pan interaction round-trip
- Sync group with 2+ charts syncing hover
- Persistence save → dispose → restore round-trip
- Streaming data source updates trigger rebuild
- Error state recovery (error → valid data → chart appears)

---

## 8. Priority-Ordered Fix List

### P0 — Blocks real usage

1. **Wire normalization pipeline in composites** (Reqs 73–77) — without this, chart data isn't processed through scales
2. **Wire streaming adapter lifecycle** (Reqs 73–77) — streaming data won't work
3. **Add `marker` field to `OiSeriesStyle`** (Req 55) — blocks marker customization per series
4. **Fix performance defaults** (Req 23) — `500` → `5000`, `5000` → `10000`
5. **Wire formatter typedefs to specific context types** (Reqs 33–34)

### P1 — Important for spec compliance

6. **Add `buildOverlays()` to `OiChartBehavior`** (Req 14) + wire in composites
7. **Wire sync group registration** (Req 32, 73–77)
8. **Create `OiPolarAngleAxis`/`OiPolarRadiusAxis`** (Req 74)
9. **Create `OiColorScale`** (Req 75)
10. **Add `legend` and `settings` params to composites** (Req 73)
11. **Wire `OiTickStrategy` into `buildTicks()`** (Req 11)
12. **Add `withDomain()` to scales** (Req 9)
13. **Add `appendMode`/`windowDuration` to streaming adapter** (Req 28)
14. **Provision `OiChartSyncCoordinator` in `OiApp`** (Req 84)

### P2 — Convention compliance

15. **Replace raw `Text()` → `OiLabel`** across tooltip, legend, state widgets
16. **Replace raw `Row`/`Column` → `OiRow`/`OiColumn`** across tooltip, legend
17. **Replace hardcoded colors → theme tokens** in tooltip, markers
18. **Add keyboard navigation to legend widget** (Req 63)
19. **Rename `OiChartSummaryData` → `OiChartAccessibilitySummary`** (Req 19)

### P3 — Nice-to-have / documentation

20. **Add `visibleDomainX`/`visibleDomainY` getters** (Req 12)
21. **Enrich `OiPersistedViewport`/`OiPersistedSelection` types** (Req 30)
22. **Add `sourceChartId` to sync methods** (Req 32)
23. **Implement mixed-type x-values error** (Req 87)
24. **Implement theme fallback chain** (Req 90)
25. **Document animation enum deviation** (Reqs 21–22)

### P4 — Test coverage

26. **Legend widget tests** (toggle, keyboard nav, responsive)
27. **Tooltip behavior tests** (show/hide, anchor modes, custom builder)
28. **Crosshair/brush behavior tests**
29. **Theme tests** (palette, override chain, light/dark)
30. **Golden tests** (visual regression)
31. **Performance tests** (1k/10k points)
32. **Integration tests** (zoom+pan, sync, persistence, streaming)

---

## Summary Statistics

| Category | Complete | Partial | Missing |
|----------|----------|---------|---------|
| Foundation (reqs 5–36) | 22/32 | 8/32 | 2/32 |
| Data Contracts (reqs 37–56) | 17/20 | 2/20 | 1/20 |
| Primitives (reqs 57–61) | 5/5 | 0/5 | 0/5 |
| Components (reqs 62–72) | 10/11 | 1/11 | 0/11 |
| Composites (reqs 73–77) | 0/5 | 5/5 | 0/5 |
| Migration (reqs 78–85) | 7/8 | 0/8 | 1/8 |
| Error/Edge (reqs 86–100) | 9/15 | 2/15 | 4/15 |
| **TOTAL** | **70/96** | **18/96** | **8/96** |

**Overall: ~73% fully complete, ~92% at least partially implemented.** Up from 49%/69% in previous gap analysis.
