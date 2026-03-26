## Overview

Write 8 missing test files for Tier B charts (Phases 3-4) and modules (Phases 5-7). All implementations exist — tests only.

**Gap analysis**: `concept/25-03-chart-gaps-11.md`

## Context

- **Reference**: `test/src/composites/oi_histogram_test.dart` (Tier B test pattern), `test/helpers/pump_chart_app.dart`
- **Assumptions**: Widget tests use pumpChartApp. Logic tests are pure unit tests. Module tests need OiApp wrapper.

## Plan

### Phase 1: Tier B Chart Tests

- **Goal**: 4 test files for polar, hierarchical, matrix charts
- [x] `test/src/composites/oi_radial_bar_chart_test.dart` — Widget renders with data, empty data shows empty state, arc sweep test (verify arc proportional to value/maxValue via painter inspection)
- [x] `test/src/composites/oi_polar_area_chart_test.dart` — Widget renders, wedge count matches data count, empty data
- [x] `test/src/composites/oi_sunburst_chart_test.dart` — Widget renders with flat node list, center content shows, empty data
- [x] `test/src/composites/oi_calendar_heatmap_test.dart` — Widget renders, date range produces correct grid, empty data
- [x] Verify: `flutter test`

### Phase 2: Module Tests

- **Goal**: 4 test files for KPI, dashboard, explorer
- [x] `test/src/modules/oi_kpi_format_test.dart` — currency "$1,234,567", percentage "3.4%", number "42,000", delta computation, OiKpiStatus values
- [x] `test/src/modules/oi_kpi_board_test.dart` — Board renders correct card count, empty metrics shows empty, responsive column count
- [x] `test/src/modules/oi_analytics_dashboard_test.dart` — Dashboard renders panel count, empty panels shows empty, OiGridPosition equality
- [x] `test/src/modules/oi_chart_explorer_test.dart` — OiExplorerController setChartType notifies, setXColumn notifies, OiColumnType values, OiExplorerChartType values
- [x] Verify: `flutter test`

## Risks / Out of scope

- **Risks**: Module widget tests may need complex setup (nested OiApp + charts). Mitigate: test data models and controllers as unit tests, test widgets as basic render checks.
- **Out of scope**: Golden tests. Performance tests. Deep interaction tests (hover, drag).
