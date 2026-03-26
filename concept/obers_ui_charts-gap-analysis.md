# obers_ui_charts — Gap Analysis

**Date:** 2026-03-25
**Spec reference:** `concept/obers_ui_charts-spec.md`
**Plan reference:** `concept/obers_ui_charts-plan.md`

---

## Executive Summary

The foundation plan (Phases 1–7) has been completed: package scaffolding, bulk migration, ring buffer, decimation, streaming adapter, mapper-first series hierarchy, behaviors, component state widgets, family base composites, and integration verification. However, cross-referencing every numbered spec requirement against the actual implementation reveals **significant gaps** in models, component widgets, controller completeness, behavior coverage, and internal wiring within the family base composites. Approximately **40% of the spec's detailed requirements** are not yet implemented.

The gaps cluster into three categories:
1. **Missing model/data classes** — ~20 classes and ~10 enums specified but not created
2. **Missing component widgets** — 6 of 11 component widgets don't exist yet
3. **Incomplete orchestration** — Family base composites are shells that accept configuration but don't wire behavior lifecycle, sync, persistence, decimation, or normalization internally

---

## Gap Inventory by Spec Section

### 1. Package Setup (Reqs 1–4) — COMPLETE ✓

All requirements met: pubspec, analysis_options, barrel file, tier-based directory structure.

---

### 2. Theme System (Reqs 5–7) — COMPLETE ✓

`OiChartThemeData` (880 lines) and `OiChartPalette` exist in obers_ui and are re-exported from obers_ui_charts. `OiComponentThemes.chart` nullable field exists.

**Minor gap:** Spec req 5 lists sub-theme classes (`OiChartAxisTheme`, `OiChartGridTheme`, `OiChartLegendTheme`, `OiChartTooltipTheme`, `OiChartCrosshairTheme`, `OiChartAnnotationTheme`, `OiChartSelectionTheme`, `OiChartMotionTheme`, `OiChartDensityTheme`). These likely exist inside `OiChartThemeData` as fields but need verification that all 9 sub-themes are present with full property sets.

---

### 3. Scale System (Reqs 8–11) — MOSTLY COMPLETE

**Present:** `OiChartScale<T>` abstract + 8 concrete implementations (linear, log, time, category, band, point, quantile, threshold). Enum `OiScaleType` exists.

**Gaps:**
| Req | Item | Status |
|-----|------|--------|
| 8 | `OiAxisScaleType` enum | ✓ Exists in `oi_chart_axis.dart` (composites layer) |
| 9 | `OiChartScale<TDomain>` abstract | ✓ Exists in `oi_chart_scale.dart` |
| 10 | 5 concrete scales | ✓ All 5 specified + 3 extra (point, quantile, threshold) |
| 11 | **`OiAxisTickStrategy`** | ⚠️ Exists as `OiTickStrategy` enum (`auto/even/all/minMax`) but spec calls for a **class** with `maxCount`, `minSpacingPx`, `includeEndpoints`, `niceValues` properties. The enum version is far simpler. |

---

### 4. Viewport (Reqs 12–13) — PARTIAL

**Present:** `OiChartViewport` immutable class with `plotBounds`, `padding`, `axisInsets`, `devicePixelRatio`, `zoomLevel`, `panOffset`, `visibleDomain`, coordinate conversion methods.

**Gaps:**
| Req | Item | Status |
|-----|------|--------|
| 12 | `toLocal()`/`toGlobal()` | ✓ Present as `toLocal()`/`toGlobal()` |
| 12 | `visibleDomainX`/`visibleDomainY` | ⚠️ Single `visibleDomain: Rect?` instead of separate x/y ranges |
| 13 | **`OiChartViewportState`** mutable class | ❌ Missing entirely. No separate mutable state with `xMin/xMax/yMin/yMax`, `zoomLevel`, `panOffset`, `isZoomed`, `reset()`. Viewport is immutable only. |

---

### 5. Behavior System (Reqs 14–16) — PARTIAL

**Present:** `OiChartBehavior` abstract base ✓, `OiChartBehaviorContext` with all required fields ✓.

**Behavior implementations:**
| Req 16 | Behavior | Status |
|--------|----------|--------|
| | `OiTooltipBehavior` | ✓ As `OiChartTooltipBehavior` (migrated) |
| | `OiCrosshairBehavior` | ✓ As `OiChartCrosshairBehavior` (migrated) |
| | **`OiZoomPanBehavior`** | ❌ **Missing entirely** — no equivalent exists |
| | `OiSelectionBehavior` | ✓ In `behaviors/oi_selection_behavior.dart` |
| | `OiBrushBehavior` | ✓ As `OiChartBrushBehavior` (migrated) |
| | `OiKeyboardExploreBehavior` | ✓ In `behaviors/oi_keyboard_explore_behavior.dart` |
| | `OiHoverSyncBehavior` | ✓ In `behaviors/oi_hover_sync_behavior.dart` |
| | `OiSeriesToggleBehavior` | ✓ In `behaviors/oi_series_toggle_behavior.dart` |

**Critical:** `OiZoomPanBehavior` (wheel zoom, pinch zoom, drag pan with constraints) is completely missing.

---

### 6. Controller (Req 17) — PARTIAL

**Present:** `OiChartController` extends `ChangeNotifier`, has `selection`, `hovered`, `isLoading`, `error`, `select()`, `clearSelection()`, `hover()`.

**Gaps:**
| Property/Method | Status |
|----------------|--------|
| `selection` state | ✓ As `Set<OiChartDataRef>` (spec says `OiChartSelectionState`) |
| **`viewport` state** | ❌ Missing |
| `hover` state | ✓ As `OiChartDataRef?` (spec says `OiChartHoverState`) |
| **`legend` state** | ❌ Missing |
| **`focus` state** | ❌ Missing |
| `clearSelection()` | ✓ |
| **`resetZoom()`** | ❌ Missing |
| **`focusSeries(String)`** | ❌ Missing |
| **`toggleSeries(String)`** | ❌ Missing |
| **`setVisibleDomain(...)`** | ❌ Missing |

---

### 7. Accessibility (Reqs 18–20) — MOSTLY COMPLETE

| Req | Item | Status |
|-----|------|--------|
| 18 | `OiChartAccessibilityConfig` | ✓ All fields present |
| 19 | **`OiChartAccessibilitySummary`** | ⚠️ Exists as `OiChartSummaryData` (different name) |
| 19 | **`OiDetectedChartInsight`** | ❌ Missing — spec says summary includes `insights: List<OiDetectedChartInsight>` |
| 20 | `OiChartAccessibilityBridge` | ⚠️ Has generic `announce()` instead of spec's `announcePoint()`, `announceSummary()`, `announceNavigation()`. Functionally equivalent via generic method. |

---

### 8. Animation (Reqs 21–22) — MOSTLY COMPLETE

| Req | Item | Status |
|-----|------|--------|
| 21 | `OiChartAnimationConfig` | ✓ All core fields |
| 21 | **`OiChartEnterAnimation` enum** | ❌ Missing — spec says `grow/fade/slide/none`. Implementation uses `OiPhaseAnimationConfig` class instead of dedicated enums. |
| 21 | **`OiChartUpdateAnimation` enum** | ❌ Missing — spec says `morph/crossfade/none` |
| 21 | **`OiChartExitAnimation` enum** | ❌ Missing — spec says `shrink/fade/none` |
| 22 | `OiSeriesAnimationConfig` | ✓ Present |

**Note:** The implementation takes a different approach (class-based `OiPhaseAnimationConfig` per phase) rather than enum-based. This is arguably more flexible but doesn't match the spec literally.

---

### 9. Performance (Reqs 23–25) — COMPLETE ✓

All present: `OiChartPerformanceConfig`, `OiChartDecimationStrategy` enum, `OiChartRenderMode` enum, decimation utility functions.

**Minor:** Default values differ from spec (`progressiveChunkSize` is 500 vs spec's 5000; `maxInteractivePoints` is 5000 vs spec's 10000).

---

### 10. Streaming (Reqs 26–29) — COMPLETE ✓

`OiStreamingDataSource<T>`, `OiRingBuffer<T>`, `OiStreamingSeriesAdapter<T>` all implemented and tested.

**Minor gap:** Spec req 28 mentions `appendMode` (append/replace) and `windowDuration` (time-based windowing) on the adapter. Need to verify these exist.

---

### 11. Persistence (Reqs 30–31) — MOSTLY COMPLETE

`OiChartSettings` with `OiSettingsData` mixin ✓, `toJson()`/`fromJson()`/`mergeWith()` ✓.

**Gaps:**
| Req 30 | Field | Status |
|--------|-------|--------|
| `hiddenSeriesIds: Set<String>` | ✓ |
| **`viewport: OiPersistedViewport?`** | ⚠️ Simplified as `viewportWindow: Rect?` — missing dedicated type |
| **`selection: OiPersistedSelection?`** | ⚠️ Simplified as `selectedSeriesIndex: int?` + `selectedDataIndex: int?` |
| `expandedLegendGroups: Map<String, bool>` | ⚠️ As `Set<String>` (less expressive — only tracks expanded, not collapsed) |
| `activeComparisonMode: String?` | ✓ As `OiChartComparisonMode` enum |
| `schemaVersion: int` | ✓ |

---

### 12. Sync (Req 32) — COMPLETE ✓

`OiChartSyncCoordinator` abstract class with register/unregister, sync methods, and listeners.

---

### 13. Formatters (Reqs 33–35) — MOSTLY COMPLETE

Typedefs present: `OiAxisFormatter<T>`, `OiTooltipValueFormatter`, `OiSeriesLabelFormatter<T>`.

**Gaps:**
| Req | Item | Status |
|-----|------|--------|
| 34 | **`OiAxisFormatContext`** with specific fields | ⚠️ Generic `OiFormatterContext<T>` instead. Missing spec-required fields: `axisPosition`, `isFirstTick`, `isLastTick`, `availableWidth` |
| 35 | **`OiTooltipFormatContext`** with specific fields | ⚠️ Uses same generic context. Missing: `seriesId`, `seriesLabel`, `pointIndex` |

---

### 14. Extension/Plugin (Req 36) — COMPLETE ✓

`OiChartExtension` with all lifecycle hooks.

---

### 15. Series Models (Reqs 37–42) — PARTIAL

**`OiChartSeries<T>` (req 37):**
| Field | Status |
|-------|--------|
| `id: String` | ✓ |
| `label: String` | ✓ |
| `data: List<T>?` | ✓ |
| `streamingData: OiStreamingDataSource<T>?` | ✓ (as `streamingSource`) |
| `visible: bool` | ✓ |
| **`style: OiSeriesStyle?`** | ❌ Missing — has `color: Color?` instead (much simpler) |
| **`animation: OiSeriesAnimationConfig?`** | ❌ Missing |
| **`legend: OiSeriesLegendConfig?`** | ❌ Missing |
| `semanticLabel: String?` | ✓ |

**`OiCartesianSeries<T>` (req 38):** ✓ Complete — all mapper fields present (`xMapper`, `yMapper`, `pointLabel`, `isMissing`, `semanticValue`, `yAxisId`).

**`OiPolarSeries<T>` (req 39):** ✓ Present.

**`OiMatrixSeries<T>` (req 40):** ✓ Present.

**`OiHierarchicalSeries<TNode>` (req 41):** ✓ Present.

**`OiFlowSeries<TNode, TLink>` (req 42):** ✓ Present.

---

### 16. Normalized Datum (Req 43) — COMPLETE ✓

`OiChartDatum` with all spec fields: `seriesId`, `index`, `rawItem`, `xRaw`, `yRaw`, `xScaled`, `yScaled`, `colorRaw`, `label`, `isMissing`, `extra`.

---

### 17. Axis Model (Req 44) — PARTIAL

`OiChartAxis<TDomain>` exists with label, scaleType, position.

**Gaps:**
| Field | Status |
|-------|--------|
| `label: String?` | ✓ |
| `scaleType: OiAxisScaleType` | ✓ |
| `position: OiAxisPosition` | ✓ |
| `formatter` | ✓ |
| `ticks: OiAxisTickStrategy?` | ⚠️ Exists as `OiTickStrategy` enum (simpler than spec's class) |
| **`maxVisibleTicks: OiResponsive<int>?`** | ❌ Missing |
| `showGrid: bool` | ✓ |
| `showAxisLine: bool` | Need to verify |
| `showTickMarks: bool` | Need to verify |
| **`domain: OiAxisRange<TDomain>?`** | ❌ Missing — `OiAxisRange` class doesn't exist |
| **`overflowBehavior: OiAxisLabelOverflowBehavior`** | ⚠️ Exists as `OiChartLabelOverflow` enum (different name) |
| **`titleAlignment: OiAxisTitleAlignment`** | ✓ |

---

### 18. Legend Model (Reqs 45–46) — PARTIAL

`OiChartLegend` widget exists. `OiChartLegendItem` data class exists.

**Gaps:**
| Req 45 | Field | Status |
|--------|-------|--------|
| **`OiChartLegendConfig`** | ❌ Missing as standalone config class. The existing `OiChartLegend` is a widget, not a config model. |
| `show: bool` | Need to verify |
| **`position: OiResponsive<OiLegendPosition>?`** | ❌ Missing `OiResponsive` wrapper |
| **`wrapBehavior: OiLegendWrapBehavior`** | ❌ Missing enum |
| `allowSeriesToggle: bool` | Need to verify |
| `allowExclusiveFocus: bool` | Need to verify |
| `itemBuilder` | Need to verify |

---

### 19. Tooltip Model (Reqs 47–48) — MOSTLY COMPLETE

`OiChartTooltipConfig` ✓ and `OiChartTooltipModel` ✓ exist in `oi_chart_tooltip.dart`.

---

### 20. Annotation & Threshold (Reqs 49–50) — ❌ MISSING ENTIRELY

| Req | Item | Status |
|-----|------|--------|
| 49 | **`OiChartAnnotation`** | ❌ Not implemented |
| 49 | **`OiAnnotationType` enum** (horizontalLine/verticalLine/region/point/label) | ❌ Not implemented |
| 49 | **`OiAnnotationStyle`** | ❌ Not implemented |
| 50 | **`OiChartThreshold`** | ❌ Not implemented |
| 50 | **`OiThresholdLabelPosition` enum** | ❌ Not implemented |

---

### 21. State Models (Reqs 51–54) — ❌ MISSING ENTIRELY

| Req | Item | Status |
|-----|------|--------|
| 51 | **`OiChartSelectionState`** | ❌ Not implemented. Controller uses `Set<OiChartDataRef>` instead. |
| 52 | **`OiChartHoverState`** | ❌ Not implemented. Controller uses `OiChartDataRef?` instead. |
| 53 | **`OiChartLegendState`** | ❌ Not implemented |
| 54 | **`OiChartFocusState`** | ❌ Not implemented |

---

### 22. Style Models (Reqs 55–56) — ❌ MISSING ENTIRELY

| Req | Item | Status |
|-----|------|--------|
| 55 | **`OiSeriesStyle`** | ❌ Not implemented — `OiChartSeries` only has `color: Color?` |
| 55 | **`OiSeriesFill`** (solid/gradient) | ❌ Not implemented |
| 55 | **`OiDataLabelStyle`** | ❌ Not implemented |
| 55 | **`hoverStyle`/`selectedStyle`/`inactiveStyle`** state overrides | ❌ Not implemented |
| 56 | **`OiMarkerStyle`** | ⚠️ `OiChartMarkerStyle` exists but is for data point rendering, not the series-level style config. Missing: `visible`, `dashPattern` |

---

### 23. Primitives Layer (Reqs 57–61) — MOSTLY COMPLETE (migrated)

| Req | Item | Status |
|-----|------|--------|
| 57 | `OiChartCanvas` | ✓ Migrated |
| 58 | `OiChartLayer` | ✓ Migrated |
| 59 | `OiChartHitTester` | ✓ Migrated |
| 60 | `OiHitTestResult` | ✓ Migrated (as part of hit test file) |
| 61 | `OiGridPainter` | ✓ As `OiChartGridPainter` |
| 61 | `OiAxisPainter` | ✓ As `OiChartAxisPainter` |
| 61 | **`OiMarkerPainter`** | ⚠️ `OiChartMarkerStyle` exists but no dedicated `OiMarkerPainter` class |
| 61 | **`OiChartLabelPainter` with collision avoidance** | ✓ Exists in `oi_chart_axis_painter.dart` |

---

### 24. Component Widgets (Reqs 62–72) — MAJOR GAPS

| Req | Widget | Status |
|-----|--------|--------|
| 62 | **`OiChartAxisWidget`** | ❌ Missing. `OiChartAxis` is a data model, not a rendered widget. No widget renders axes with responsive tick density, label overflow handling, title. |
| 63 | `OiChartLegendWidget` | ⚠️ `OiChartLegend` exists as `StatelessWidget`. Missing spec features: OiRow/OiColumn layout, keyboard navigable items, responsive position via OiResponsive. |
| 64 | **`OiChartTooltipWidget`** | ❌ Missing — no widget that renders tooltip through OiOverlays |
| 65 | **`OiChartCrosshairWidget`** | ❌ Missing — no overlay crosshair widget |
| 66 | **`OiChartBrushWidget`** | ❌ Missing — no visual brush rectangle widget |
| 67 | `OiChartZoomControlsWidget` | ✓ As `OiChartZoomControls` |
| 68 | **`OiChartAnnotationLayer`** | ❌ Missing — no annotation rendering layer |
| 69 | `OiChartEmptyState` | ✓ |
| 70 | `OiChartLoadingState` | ✓ |
| 71 | `OiChartErrorState` | ✓ |
| 72 | `OiChartSeriesToggle` | ✓ Migrated |

---

### 25. Family Base Composites (Reqs 73–77) — SHELLS ONLY

All 5 composites exist as widgets that accept the right parameters and delegate to a `seriesBuilder`. But they are **orchestration shells** that **don't internally wire** the infrastructure they accept:

| Wiring | OiCartesianChart | OiPolarChart | OiMatrixChart | OiHierarchicalChart | OiFlowChart |
|--------|------------------|--------------|---------------|---------------------|-------------|
| Viewport calculation from layout | ✓ | ✓ | ✓ | ✓ | ✓ |
| Scale auto-resolution | ✓ | ❌ | ❌ | N/A | N/A |
| **Data normalization pipeline** | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Behavior attach/detach lifecycle** | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Behavior overlay rendering** | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Sync group registration** | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Persistence save/restore** | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Decimation invocation** | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Streaming adapter management** | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Accessibility tree generation** | ⚠️ Semantics label | ⚠️ | ⚠️ | ⚠️ | ⚠️ |
| Loading/empty/error states | ✓ | ✓ | ✓ | ✓ | ✓ |
| Tree building (hierarchical) | N/A | N/A | N/A | ✓ | N/A |

**Spec req 73 says OiCartesianChart should "orchestrate: viewport calculation, scale resolution, data normalization, behavior dispatch, overlay rendering, accessibility tree."** The current implementation only does viewport calculation, scale resolution, and state checks.

**Polar-specific gaps (req 74):** Missing `OiPolarAngleAxis`, `OiPolarRadiusAxis` classes.

**Matrix-specific gaps (req 75):** Missing `OiColorScale` class.

---

### 26. Migration (Reqs 78–82) — COMPLETE ✓

All existing charts migrated, imports updated, tests moved, example app updated.

---

### 27. obers_ui Changes (Reqs 83–85) — PARTIAL

| Req | Item | Status |
|-----|------|--------|
| 83 | `OiChartThemeData? chart` in `OiComponentThemes` | ✓ |
| 84 | **`OiChartSyncCoordinator` provisioning in `OiApp`** | ❌ Need to verify — spec says lazy provider via InheritedWidget |
| 85 | Export `OiChartThemeData` from charts barrel | ✓ Re-exported |

---

### 28. Error Handling (Reqs 86–90) — PARTIAL

| Req | Item | Status |
|-----|------|--------|
| 86 | Series validates data/streamingData mutual exclusivity | ✓ |
| 87 | **Scale auto-resolution: empty data (show empty state)** | ✓ |
| 87 | **Single-point data (default domain padding)** | ❌ Not implemented |
| 87 | **Mixed-type x-values (descriptive error)** | ❌ Not implemented |
| 88 | Streaming errors show error state | ✓ (adapter catches errors) |
| 89 | Hit test with no data returns null | ✓ (pre-existing) |
| 90 | **Theme fallback chain (series → chart → context → auto)** | ❌ Not implemented in composites |

---

### 29. Edge Cases (Reqs 91–100) — PARTIAL

| Req | Edge Case | Status |
|-----|-----------|--------|
| 91 | Zero data → empty state | ✓ |
| 92 | **Single point → default padding, no interpolation** | ❌ Not handled |
| 93 | **All series hidden → empty state with message** | ❌ Shows generic empty state, no "all series hidden" message |
| 94 | **Negative log scale → clamp + log warning** | ❌ Not implemented |
| 95 | **NaN/Infinity → treat as missing** | ❌ Not implemented |
| 96 | Rapid streaming → throttle | ✓ |
| 97 | SyncGroup with single chart → no-op | ✓ |
| 98 | **Controller disposed while behaviors attached → auto-detach** | ❌ Not implemented |
| 99 | **Theme change mid-animation → restart** | ❌ Not implemented |
| 100 | **Viewport zoom to zero range → clamp** | ❌ Not implemented |

---

### 30. OiApp Lazy Sync Provider (Req 84)

Spec says: "Add `OiChartSyncCoordinator` provisioning in `OiApp` (lazy, only created when charts with syncGroup are used)."

**Status:** ❌ Likely not implemented. Need to verify `OiApp` was modified.

---

### 31. Test Coverage vs Spec Validation Section

The spec defines extensive test requirements. Here's coverage:

| Test Category | Spec Expects | Actually Present |
|---------------|-------------|-----------------|
| **Scale unit tests** (mapping, inverse, ticks, edge cases) | ~8 test groups | ❌ 0 — no scale tests |
| **Decimation tests** | ~7 tests | ✓ Present |
| **Ring buffer tests** | ~6 tests | ✓ Present |
| **Streaming adapter tests** | ~6 tests | ✓ Present |
| **Settings serialization tests** | ~3 tests | ✓ Present |
| **Controller tests** (notify, methods) | ~6 tests | ❌ 0 — no controller tests |
| **Hit testing tests** (nearest, binary search, tolerance) | ~6 tests | ❌ 0 — no hit tester tests |
| **Legend widget tests** | ~5 tests | ❌ 0 |
| **Tooltip widget tests** | ~6 tests | ❌ 0 |
| **Axis widget tests** | ~5 tests | ❌ 0 |
| **Behavior tests** (tooltip, crosshair, zoom, selection, brush, keyboard, sync, toggle) | ~8 groups | ⚠️ 4 of 8 (missing: tooltip, crosshair, zoom/pan, brush) |
| **Composite integration tests** (render, multi-series, zoom, sync, persistence, empty) | ~20+ tests | ⚠️ 15 tests but mostly render + empty state only |
| **Accessibility tests** (semantic label, summary, keyboard nav, focus) | ~8 tests | ⚠️ 4 (keyboard behavior only) |
| **Performance tests** (1k/10k points, memory) | ~5 tests | ❌ 0 |
| **Theming tests** (palette, override chain, light/dark, repaint) | ~6 tests | ❌ 0 |
| **Golden tests** | Multiple | ❌ 0 |

---

### 32. Utility Files (Spec Implementation Section)

| File | Status |
|------|--------|
| **`utils/chart_math.dart`** | ❌ Missing |
| **`utils/path_utils.dart`** | ❌ Missing |
| **`utils/label_collision.dart`** | ❌ Missing |

---

### 33. Naming Convention Differences

Some existing classes use `OiChart` prefix while spec uses shorter names:

| Spec Name | Implementation Name | Notes |
|-----------|-------------------|-------|
| `OiTooltipBehavior` | `OiChartTooltipBehavior` | Migrated with "Chart" prefix |
| `OiCrosshairBehavior` | `OiChartCrosshairBehavior` | Migrated with "Chart" prefix |
| `OiBrushBehavior` | `OiChartBrushBehavior` | Migrated with "Chart" prefix |
| `OiLegendPosition` | `OiChartLegendPosition` | Extended name |
| `OiAxisFormatContext` | `OiFormatterContext<T>` | Generic vs specific |
| `OiAxisTickStrategy` | `OiTickStrategy` (enum) | Simplified to enum |
| `OiAxisLabelOverflowBehavior` | `OiChartLabelOverflow` | Shortened |
| `OiChartAccessibilitySummary` | `OiChartSummaryData` | Different name |
| `OiLegendItem` | `OiChartLegendItem` | Extended name |

These naming differences are minor but may cause confusion when comparing spec to implementation.

---

## Priority-Ordered Implementation Recommendations

### P0 — Critical Foundation Gaps (blocks concrete chart specs)

1. **State models** (reqs 51–54): `OiChartSelectionState`, `OiChartHoverState`, `OiChartLegendState`, `OiChartFocusState` — the controller needs these to manage chart state properly.

2. **Complete `OiChartController`** (req 17): Add missing state properties (`viewport`, `legend`, `focus`) and methods (`resetZoom()`, `focusSeries()`, `toggleSeries()`, `setVisibleDomain()`).

3. **`OiChartViewportState`** (req 13): Mutable viewport state with xMin/xMax/yMin/yMax, isZoomed, reset().

4. **`OiZoomPanBehavior`** (req 16): The only behavior completely missing — handles wheel zoom, pinch zoom, drag pan.

5. **Style models** (reqs 55–56): `OiSeriesStyle`, `OiSeriesFill`, `OiMarkerStyle`, `OiDataLabelStyle` + add `style` field to `OiChartSeries`.

6. **Family base composite wiring**: Implement behavior lifecycle (attach on mount / detach on dispose), overlay rendering via `buildOverlays()`, data normalization pipeline, streaming adapter management.

### P1 — Important Data Models

7. **Annotation & Threshold models** (reqs 49–50): `OiChartAnnotation`, `OiAnnotationType`, `OiChartThreshold`, `OiThresholdLabelPosition`, `OiAnnotationStyle`.

8. **`OiChartLegendConfig`** (req 45): Standalone config class with position, wrap behavior, toggle, etc.

9. **`OiSeriesLegendConfig`** (req 37): Per-series legend configuration.

10. **`OiAxisTickStrategy` as class** (req 11): Upgrade from enum to class with `maxCount`, `minSpacingPx`, `includeEndpoints`, `niceValues`.

11. **`OiAxisRange<TDomain>`** (req 44): Explicit min/max domain override for axes.

12. **Formatter contexts** (reqs 34–35): Replace generic `OiFormatterContext<T>` with spec-specific `OiAxisFormatContext` and `OiTooltipFormatContext`.

### P2 — Component Widgets

13. **`OiChartAxisWidget`** (req 62): Rendered axis component with responsive ticks, overflow handling.

14. **`OiChartTooltipWidget`** (req 64): Tooltip overlay rendered via OiOverlays.

15. **`OiChartCrosshairWidget`** (req 65): Overlay crosshair lines.

16. **`OiChartBrushWidget`** (req 66): Visual brush/selection rectangle.

17. **`OiChartAnnotationLayer`** (req 68): Annotation and threshold rendering.

### P3 — Polar/Matrix Specific Types

18. **`OiPolarAngleAxis`**, **`OiPolarRadiusAxis`** (req 74): Polar chart axis types.

19. **`OiColorScale`** (req 75): Color mapping for matrix charts.

### P4 — Edge Case Handling

20. **Single-point domain padding** (req 92)
21. **"All series hidden" empty state message** (req 93)
22. **Log scale negative clamping** (req 94)
23. **NaN/Infinity → missing** (req 95)
24. **Controller dispose → auto-detach behaviors** (req 98)
25. **Theme change mid-animation → restart** (req 99)
26. **Viewport zero-range clamping** (req 100)

### P5 — Test Coverage

27. **Scale unit tests**: All 8 scale types
28. **Controller tests**: State notify, methods
29. **Hit tester tests**: Binary search, tolerance, multi-series
30. **Component widget tests**: Legend, tooltip, axis
31. **Integration tests**: Multi-series, zoom, sync, persistence
32. **Golden tests**: Visual verification
33. **Performance tests**: 1k/10k points

### P6 — Utilities & Minor

34. **Utils**: `chart_math.dart`, `path_utils.dart`, `label_collision.dart`
35. **`OiChartSyncCoordinator` lazy provisioning in `OiApp`** (req 84)
36. **Animation enums**: `OiChartEnterAnimation`, `OiChartUpdateAnimation`, `OiChartExitAnimation` (or document the intentional deviation)
37. **Accessibility**: `OiDetectedChartInsight` class, specific `announcePoint()`/`announceSummary()`/`announceNavigation()` methods

---

## Summary Statistics

| Category | Fully Implemented | Partially | Missing |
|----------|------------------|-----------|---------|
| Foundation (reqs 5–36) | 18/32 | 8/32 | 6/32 |
| Data Contracts (reqs 37–56) | 9/20 | 3/20 | 8/20 |
| Primitives (reqs 57–61) | 4/5 | 1/5 | 0/5 |
| Components (reqs 62–72) | 4/11 | 1/11 | 6/11 |
| Composites (reqs 73–77) | 0/5 | 5/5 | 0/5 |
| Migration (reqs 78–85) | 7/8 | 0/8 | 1/8 |
| Error/Edge (reqs 86–100) | 5/15 | 1/15 | 9/15 |
| **TOTAL** | **47/96** | **19/96** | **30/96** |

**Overall completion: ~49% fully implemented, ~69% at least partially implemented.**
