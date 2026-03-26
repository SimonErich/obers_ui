## Overview

Close final 5% gap: wire decimation into normalization pipeline, add key params to OiLineChart, document two-tier API, fix bubble chart test failures.

**Gap analysis**: `concept/25-03-chart-gaps-5.md` (sections 2.1–2.7, 3)

## Context

- **Structure**: Barrel exports data files containing mapper series classes — types ARE accessible via `obers_ui_charts.dart`
- **Reference implementations**: `lib/src/composites/oi_cartesian_chart.dart` (has normalization wired), `lib/src/foundation/oi_decimation.dart` (decimation functions)
- **Assumptions**: Two-tier API approach (simple + power) is the pragmatic solution. Concrete chart → family base delegation is a future refactor. Mapper series are already publicly exported via their data files.

## Plan

### Phase 1: Wire Decimation + Add Key Params to OiLineChart

- **Goal**: Decimation auto-applies; OiLineChart gains behaviors/controller/annotations
- [ ] `lib/src/composites/oi_cartesian_chart.dart` — After `_normalizeVisibleSeries()`, check `widget.performance?.decimationStrategy`. If not `none`, convert each series' normalized datums to `Point<double>` (xRaw as num, yRaw as num), call `decimateMinMax` or `decimateLttb` based on strategy, rebuild filtered datum list. Only decimate when point count > `maxInteractivePoints`.
- [ ] `lib/src/composites/oi_line_chart/oi_line_chart.dart` — Add params: `behaviors: List<OiChartBehavior>`, `controller: OiChartController?`, `annotations: List<OiChartAnnotation>`, `thresholds: List<OiChartThreshold>`, `legend: OiChartLegendConfig?`, `performance: OiChartPerformanceConfig?`, `syncGroup: String?`, `onSeriesVisibilityChange`, `onViewportChange`. Store but don't wire internally yet (availability for future wiring).
- [ ] TDD: OiCartesianChart with performance config (decimation=lttb, maxInteractivePoints=50) and 200 data points → normalized datums count ≤ 50
- [ ] TDD: OiLineChart accepts behaviors param without error
- [ ] Verify: `dart analyze` && `flutter test`

### Phase 2: Document Two-Tier API + Fix Bubble Tests

- **Goal**: Clear documentation, fix test failures
- [ ] `lib/src/composites/oi_line_chart/oi_line_chart.dart` — Add dartdoc section explaining two-tier API: "For simple usage, use OiLineChart with OiLineSeries (pre-mapped data). For full control (behaviors, sync, persistence, mapper-first binding), use OiCartesianChart<T> with OiLineSeriesData<T>."
- [ ] `lib/src/composites/oi_cartesian_chart.dart` — Add dartdoc noting it's the power API base for all cartesian charts with full behavior/sync/persistence/normalization support
- [ ] `lib/src/composites/oi_bubble_chart/oi_bubble_chart.dart` — Fix RenderFlex overflow in size legend: wrap Row in Flexible or constrain width, or add `mainAxisSize: MainAxisSize.min` + overflow handling
- [ ] `test/src/composites/oi_bubble_chart/oi_bubble_chart_test.dart` — Verify 3 failing tests now pass after layout fix
- [ ] Verify: `dart analyze` && `flutter test` (target: 0 failures)

## Risks / Out of scope

- **Risks**:
  - Decimation converts OiChartDatum back to Point<double> then back — potential precision loss. Mitigate: use index-based decimation instead of point conversion.
  - Adding params to OiLineChart without wiring them may confuse users. Mitigate: add `@experimental` annotation or doc warning.
- **Out of scope**:
  - Full concrete chart → family base delegation refactor
  - OiChartWidget abstract base class
  - Tier B/C charts and modules
  - Reducing hardcoded color fallbacks (all have theme chains)
  - Adding all missing OiLineChart callbacks (onPointDoubleTap, onPointLongPress, etc.)
