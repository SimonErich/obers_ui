## Overview

Close final 1%: add controller to OiComboChart, add shorthand data/x/y API to OiLineChart.

**Gap analysis**: `concept/25-03-chart-gaps-8.md` (gaps 1–2)

## Context

- **Reference**: `lib/src/composites/oi_combo_chart.dart` (missing controller), `lib/src/composites/oi_line_chart/oi_line_chart.dart` (needs shorthand)
- **Assumptions**: Gaps 3 (delegation) and 4 (colors) are out of scope — documented as intentional.

## Plan

### Phase 1: ComboChart Controller + LineChart Shorthand

- **Goal**: 100% param coverage; OiLineChart shorthand API
- [ ] `lib/src/composites/oi_combo_chart.dart` — Add `this.controller` param (OiChartController?) + field + import
- [ ] `lib/src/composites/oi_line_chart/oi_line_chart.dart` — Add shorthand params: `data: List<T>?`, `x: dynamic Function(T)?`, `y: num Function(T)?`. In build, if `data != null && series.isEmpty`, create single `OiLineSeries` from shorthand. Requires making OiLineChart generic `<T>`.
- [ ] TDD: OiComboChart accepts controller param without error
- [ ] TDD: OiLineChart with shorthand data/x/y renders same as explicit series
- [ ] Verify: `dart analyze` && `flutter test`

## Risks / Out of scope

- **Risks**: Making OiLineChart generic `<T>` is a breaking change for existing `OiLineChart(...)` usages (they'd need `OiLineChart<MyType>(...)`). Mitigate: keep non-generic constructor, add `OiLineChart.fromData<T>(...)` factory instead.
- **Out of scope**: Concrete chart → family base delegation (P3). Hardcoded color reduction (P4). Tier B/C charts. Modules.
