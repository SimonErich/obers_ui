## Overview

Close final 3%: add behaviors/controller/annotations/thresholds params to 12 concrete charts, wire sync/persistence into remaining family bases, fix bubble chart test failures.

**Gap analysis**: `concept/25-03-chart-gaps-6.md` (sections 2.1–2.4)

## Context

- **Structure**: Mechanical param addition — copy pattern from OiLineChart (already has all params)
- **Reference implementations**: `lib/src/composites/oi_line_chart/oi_line_chart.dart` (25 params including behaviors, controller, annotations, thresholds)
- **Assumptions**: Params added but not internally wired to rendering (available for future delegation). Documented as two-tier API.

## Plan

### Phase 1: Add Behavior Params to 12 Concrete Charts

- **Goal**: Every concrete chart accepts behaviors, controller, annotations, thresholds
- [ ] `lib/src/composites/oi_bar_chart/oi_bar_chart.dart` — Add `behaviors`, `controller`, `annotations`, `thresholds`, `legendConfig`, `performance`, `syncGroup` params + fields
- [ ] `lib/src/composites/oi_bubble_chart/oi_bubble_chart.dart` — Same params
- [ ] `lib/src/composites/oi_scatter_plot.dart` — Same params
- [ ] `lib/src/composites/oi_pie_chart.dart` — Add `behaviors`, `controller` (no annotations/thresholds for pie)
- [ ] `lib/src/composites/oi_radar_chart.dart` — Same as pie
- [ ] `lib/src/composites/oi_heatmap.dart` — Add `behaviors`, `controller`
- [ ] `lib/src/composites/oi_treemap.dart` — Add `behaviors`, `controller`
- [ ] `lib/src/composites/oi_sankey.dart` — Add `behaviors`, `controller`
- [ ] `lib/src/composites/oi_funnel_chart.dart` — Add `behaviors`, `controller`
- [ ] `lib/src/composites/oi_sparkline.dart` — Add `behaviors`, `controller`
- [ ] `lib/src/composites/oi_gauge.dart` — Add `controller`
- [ ] `lib/src/composites/oi_donut_chart.dart` — Add `behaviors`, `controller` (forwarded to OiPieChart)
- [ ] Verify: `dart analyze` && `flutter test`

### Phase 2: Wire Sync + Persistence in Remaining Family Bases

- **Goal**: All family bases support sync registration and settings persistence
- [ ] `lib/src/composites/oi_polar_chart.dart` — Add `syncGroup: OiChartSyncGroup?` and `settings: OiChartSettings?` params. Override `syncGroup` getter. Call `restoreSettings(widget.settings)` in initState. Call `registerSync()` in behavior attach callback.
- [ ] `lib/src/composites/oi_matrix_chart.dart` — Same wiring
- [ ] `lib/src/composites/oi_hierarchical_chart.dart` — Same wiring
- [ ] `lib/src/composites/oi_flow_chart.dart` — Same wiring
- [ ] Verify: `dart analyze` && `flutter test`

### Phase 3: Fix Bubble Chart Test Failures

- **Goal**: 0 test failures
- [ ] `lib/src/composites/oi_bubble_chart/oi_bubble_chart.dart` — Fix vertical overflow: wrap chart body + narration + legend in a Column with Expanded for the chart body so legend/narration don't push total height beyond constraints. Use Flexible or constrain narration widget.
- [ ] `test/src/composites/oi_bubble_chart/oi_bubble_chart_test.dart` — Verify 3 failing tests now pass
- [ ] Verify: `flutter test` (target: 0 failures)

## Risks / Out of scope

- **Risks**:
  - Phase 1 adds params without wiring — users might expect them to work. Mitigate: add dartdoc noting "accepted for API consistency; for full behavior support use OiCartesianChart<T>".
  - Phase 3 bubble layout fix may affect other bubble chart tests. Mitigate: run full bubble test suite after fix.
- **Out of scope**:
  - Reducing 31 hardcoded color fallbacks (low priority, all have theme chains)
  - Refactoring concrete charts to delegate to family bases
  - Tier B/C charts and modules
  - Wiring behaviors internally in concrete charts (future refactor)
