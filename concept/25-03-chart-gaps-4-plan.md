## Overview

Refactor 9 legacy concrete charts to use mapper-first data binding from the foundation layer. Add missing OiLineChart concept features (enums, callbacks, config params). Wire normalization + decimation pipeline into composites.

**Gap analysis**: `concept/25-03-chart-gaps-4.md` (sections 1–6)

## Context

- **Structure**: Legacy charts use pre-mapped point objects (OiLinePoint, OiPieSegment). Foundation uses mapper functions on generic `<T>`.
- **Reference implementations**: `lib/src/composites/oi_area_chart/` (mapper-first, new pattern), `lib/src/composites/oi_line_chart/` (legacy pattern to upgrade)
- **Approach**: Option B (backward compatible) — add mapper-based `OiLineSeries<T>` generic class alongside existing `OiLineSeries` legacy class. Legacy class becomes `OiLineLegacySeries` or stays with a deprecated annotation. Charts accept both.
- **Assumptions**: We do NOT delete existing APIs. We add new mapper-based series types and update chart widgets to accept both. This preserves backward compatibility.

## Plan

### Phase 1: OiLineChart Mapper-First Upgrade

- **Goal**: Make OiLineChart accept mapper-first data + add missing concept enums/params
- [x] `lib/src/composites/oi_line_chart/oi_line_chart_data.dart` — Add `OiLineMissingValueBehavior` enum (gap/connect/zero/interpolate). Add `OiLineSeriesData<T>` class extending `OiCartesianSeries<T>` with: interpolation (OiLineChartMode), missingValueBehavior, showLine, showMarkers, showDataLabels, fillBelow, smoothing, pointColor callback, valueFormatter, xFormatter, semanticValue mapper. Keep existing `OiLineSeries` + `OiLinePoint` for backward compat.
- [x] `lib/src/composites/oi_line_chart/oi_line_chart.dart` — Add constructor params: `data: List<T>?`, `x`, `y` (shorthand), `mapperSeries: List<OiLineSeriesData<T>>?` (mapper-based), plus `behaviors`, `annotations`, `thresholds`, `legend`, `performance`, `animation`, `accessibility`, `settings`, `controller`, `syncGroup`, `onPointDoubleTap`, `onPointLongPress`, `onSeriesVisibilityChange`, `onViewportChange`, `onSelectionChange`. In build, if mapperSeries provided, use those; else fall back to legacy series.
- [x] `lib/src/foundation/oi_chart_marker.dart` — Add `factory OiChartMarkerStyle.hidden()` returning `const OiChartMarkerStyle(visible: false)`
- [x] TDD: OiLineSeriesData<T> with x/y mappers extracts values correctly
- [x] TDD: OiLineMissingValueBehavior.gap creates visual break in line
- [x] TDD: OiLineChart shorthand (data/x/y) creates single series internally
- [x] Verify: `dart analyze` && `flutter test`

### Phase 2: Wire Normalization + Decimation

- **Goal**: Make composites actually normalize data and apply decimation
- [x] `lib/src/composites/oi_cartesian_chart.dart` — In build, after computing visible series: for each series with data, call `normalizeSeries()` to produce `List<OiChartDatum>`. If `widget.performance?.decimationStrategy != OiChartDecimationStrategy.none`, call `selectDecimationStrategy()` + apply. Store result as `_normalizedData`. Pass to seriesBuilder alongside raw series.
- [x] `lib/src/composites/oi_line_chart/oi_line_chart.dart` — When using mapper-based series, normalize through `normalizeSeries()` before painting. Apply decimation for large datasets.
- [x] TDD: normalizeSeries() called in cartesian chart produces correct OiChartDatum count
- [x] TDD: decimation with LTTB reduces 1000 points to ~100 when maxInteractivePoints exceeded
- [x] Verify: `dart analyze` && `flutter test`

### Phase 3: Upgrade Remaining Legacy Charts (Bar, Bubble, Scatter, Pie)

- **Goal**: Add mapper-first series option to 4 highest-impact legacy charts
- [x] `lib/src/composites/oi_bar_chart/oi_bar_chart_data.dart` — Add `OiBarSeriesData<T>` extending `OiCartesianSeries<T>` with `barWidth`, `grouped`, `stacked`, `horizontal` props. Keep legacy `OiBarSeries`.
- [x] `lib/src/composites/oi_bar_chart/oi_bar_chart.dart` — Accept both legacy and mapper-based series. Add `behaviors`, `controller`, `annotations`, `thresholds` params.
- [x] `lib/src/composites/oi_bubble_chart/oi_bubble_chart_data.dart` — Add `OiBubbleSeriesData<T>` extending `OiCartesianSeries<T>` with `sizeMapper`. Keep legacy.
- [x] `lib/src/composites/oi_bubble_chart/oi_bubble_chart.dart` — Accept both. Add behaviors/controller.
- [x] `lib/src/composites/oi_scatter_plot.dart` — Add generic `<T>` + mapper-based series acceptance alongside legacy.
- [x] `lib/src/composites/oi_pie_chart.dart` — Add `OiPieSeriesData<T>` with value/label mappers alongside `OiPieSegment` legacy.
- [x] TDD: OiBarChart with mapper-based OiBarSeriesData renders same as legacy
- [x] TDD: OiPieChart with mapper-based OiPieSeriesData renders same as legacy
- [x] Verify: `dart analyze` && `flutter test`

### Phase 4: Upgrade Remaining Charts (Radar, Heatmap, Sparkline, Donut, Gauge)

- **Goal**: Complete mapper-first coverage for all concrete charts
- [x] `lib/src/composites/oi_radar_chart.dart` — Add mapper-based series with generic `<T>`
- [x] `lib/src/composites/oi_heatmap.dart` — Add mapper-based series with generic `<T>`
- [x] `lib/src/composites/oi_sparkline.dart` — Add mapper-based data input
- [x] `lib/src/composites/oi_donut_chart.dart` — Delegate to updated OiPieChart
- [x] `lib/src/composites/oi_gauge.dart` — Already single-value; add optional data/mapper shorthand for data-driven gauge
- [x] Fix 1 remaining `Text()` in `oi_line_chart_legend.dart`
- [x] TDD: OiRadarChart with mapper series renders correctly
- [x] Verify: `dart analyze` && `flutter test`

### Phase 5: Integration Tests + Polish

- **Goal**: Prove mapper-first path works end-to-end with normalization, decimation, behaviors
- [x] `test/src/composites/oi_line_chart_mapper_test.dart` — OiLineChart with OiLineSeriesData<T>: renders, shorthand API works, missing value behavior creates gaps, decimation applies
- [x] `test/src/composites/oi_normalization_test.dart` — normalizeSeries produces correct OiChartDatum list, decimation reduces point count, mappers extract values
- [x] `test/src/composites/oi_bar_chart_mapper_test.dart` — Bar chart with mapper-based data renders grouped/stacked
- [x] Fix 3 pre-existing bubble chart test failures (layout overflow in size legend)
- [x] Verify: `flutter test`

## Risks / Out of scope

- **Risks**:
  - Phase 1 dual-API (legacy + mapper) increases API surface. Mitigate: deprecate legacy classes after mapper path is stable.
  - Normalization in build() (Phase 2) adds per-frame computation. Mitigate: cache normalized data, only recompute on data/viewport change.
  - Adding many new params to existing chart constructors may break const constructors. Mitigate: make new params optional with null defaults.
- **Out of scope**:
  - Removing legacy APIs (backward compat preserved)
  - Tier B/C charts (histogram, waterfall, boxplot, etc.)
  - Modules (dashboard, explorer, KPI)
  - Golden tests, performance benchmarks
  - OiChartWidget abstract base class (documented deviation)
  - State config classes (using Widget approach, documented)
  - Reducing hardcoded color fallbacks (low priority, all have theme chains)
