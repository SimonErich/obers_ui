## Overview

Close final 1%: fix 3 bubble chart test failures, add behaviors/controller to OiCandlestickChart + OiGauge.

**Gap analysis**: `concept/25-03-chart-gaps-7.md` (gaps 1–3)

## Context

- **Reference**: `test/src/composites/oi_bubble_chart/oi_bubble_chart_test.dart` (failing tests), `lib/src/composites/oi_candlestick_chart/oi_candlestick_chart.dart`, `lib/src/composites/oi_gauge.dart`
- **Assumptions**: Bubble test failures are hit-test coordinate mismatches after layout wrapping changes. Fix by adjusting test surface size or tap coordinates.

## Plan

### Phase 1: Fix Bubble Chart Tests + Add Params to Last 2 Charts

- **Goal**: 0 test failures, 16/16 charts accept behaviors
- [x] `test/src/composites/oi_bubble_chart/oi_bubble_chart_test.dart` — Read failing tests. Fix coordinate mismatch: either increase surfaceSize so bubbles render at expected positions, or update tap/hover coordinates to match actual layout. If overflow persists, wrap test widget in UnconstrainedBox or increase height.
- [x] `lib/src/composites/oi_candlestick_chart/oi_candlestick_chart.dart` — Add `behaviors: List<OiChartBehavior>`, `controller: OiChartController?` params + fields + imports
- [x] `lib/src/composites/oi_gauge.dart` — Add `behaviors: List<OiChartBehavior>` param + field + import
- [x] Verify: `dart analyze` && `flutter test` (target: 0 failures)

## Risks / Out of scope

- **Risks**: Bubble test fixes may require understanding internal bubble positioning math. If coordinate adjustment insufficient, may need to restructure layout.
- **Out of scope**: Reducing 30 hardcoded color fallbacks. Tier B/C charts. Modules.
