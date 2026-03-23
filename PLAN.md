# WI-0001: Package Setup & Code Standards — Implementation Plan

## Concept

The `packages/obers_ui_charts/` package already exists with 28 Dart files (3 chart types, core infrastructure, and tests), but has 1 blocking error, 5 warnings, 13 info-level lint issues, and 4 formatting violations. This plan fixes all static analysis issues and aligns the package with obers_ui conventions so it passes `dart analyze` and `dart format` with zero diagnostics.

## Sub-tasks

**ST1: Fix the blocking type error in pie_chart_data_processor.dart**
- Line 93: `num` passed where `double` is expected — add `.toDouble()` cast.

**ST2: Fix 5 unused-local-variable warnings in tests**
- `test/src/charts/bar/bar_chart_test.dart:76` — remove or use `tappedResult`
- `test/src/charts/line/line_chart_test.dart:46` — remove or use `tappedResult`
- `test/src/charts/pie/pie_chart_test.dart:72` — remove or use `tappedResult`
- `test/src/core/chart_gesture_handler_test.dart:129` — remove or use `result`

**ST3: Fix 13 info-level lint issues**
- `avoid_equals_and_hash_code_on_mutable_classes` — make `OiChartHitResult` and `OiPieSlice` immutable (`@immutable` + final fields, or use `const` constructors).
- `use_setters_to_change_properties` — convert `OiChartTooltipController.show(result)` to a setter `set activeResult`.
- `use_named_constants` — replace `Offset(0, 0)` with `Offset.zero`, `Size(0, 0)` with `Size.zero`, etc.
- `prefer_int_literals` — use `0` instead of `0.0` where a double context is already established.
- `cascade_invocations` — use cascades where consecutive method calls target the same object.

**ST4: Run `dart format .` on the package to fix all 4 formatting violations**

**ST5: Verify zero diagnostics**
- Run `dart analyze` — expect exit code 0, zero errors/warnings/infos.
- Run `dart format --set-exit-if-changed .` — expect exit code 0.
- Run `flutter test` — expect all tests pass.

## Method signatures

Changes to existing public API (no new public classes are added):

- `OiChartHitResult` — add `@immutable` annotation, ensure all fields are final (already are, just needs annotation)
- `OiPieSlice` — add `@immutable` annotation, ensure all fields are final (already are, just needs annotation)
- `OiChartTooltipController.show(OiChartHitResult result)` → convert to setter `set activeResult(OiChartHitResult? result)` OR suppress lint if setter semantics don't fit
- `OiPieChartDataProcessor.computeSlices()` — fix return type cast on line 93

## Edge cases and fallbacks

- **Setter conversion risk**: `OiChartTooltipController.show()` also calls `notifyListeners()`, which a setter wouldn't normally do. If converting to a setter breaks the pattern, we suppress the lint rule for that one method instead.
- **Immutability annotations**: `OiChartHitResult` and `OiPieSlice` already have all-final fields, so `@immutable` is safe. No behavioral change.
- **Test variable removal**: Removing unused variables from tap-callback tests — verify the tests still verify tap behavior (the callback assignment itself tests wiring; the variable capture is unused).

## UX / requirement matching

- **REQ-0001** (Package structure): Already satisfied — `packages/obers_ui_charts/` exists with `pubspec.yaml`, `analysis_options.yaml`, `lib/`, `test/`. Verified during exploration. No changes needed.
- **REQ-0002** (Code conventions): The package already uses `Oi*` prefix naming, factory constructors for theme variants, accessibility labels on chart widgets, and the same analysis rules. The lint/format fixes in ST1–ST4 complete alignment.
- **REQ-0003** (Zero diagnostics): ST1–ST5 collectively bring the diagnostic count from 19 issues to 0.

## Test cases

No new tests are added. Existing tests (104 assertions across 14 test files) must continue to pass after all fixes:

1. `flutter test test/src/core/chart_data_test.dart` — data structure tests
2. `flutter test test/src/core/chart_gesture_handler_test.dart` — hit testing + tooltip controller
3. `flutter test test/src/core/chart_painter_test.dart` — coordinate mapping
4. `flutter test test/src/core/chart_theme_test.dart` — theme factories
5. `flutter test test/src/charts/bar/` — bar chart widget, processor, painter
6. `flutter test test/src/charts/line/` — line chart widget, processor, painter
7. `flutter test test/src/charts/pie/` — pie chart widget, processor, painter

## Definition of done checklist

- [ ] REQ-0001: Package exists at `packages/obers_ui_charts/` with `pubspec.yaml`, `analysis_options.yaml`, `lib/`, `test/` — verified, no changes needed
- [ ] REQ-0002: Package follows obers_ui conventions (Oi* prefix, factory constructors, theme-driven styling, accessibility labels, very_good_analysis) — lint fixes applied
- [ ] REQ-0003: `dart analyze` returns zero errors, zero warnings, zero infos
- [ ] `dart format --set-exit-if-changed .` returns exit code 0
- [ ] `flutter test` passes all existing tests
- [ ] No placeholders or TODO comments introduced

## Files to create or modify

1. [ ] `packages/obers_ui_charts/lib/src/charts/pie/pie_chart_data_processor.dart` — fix `num` → `double` type error on line 93
2. [ ] `packages/obers_ui_charts/lib/src/core/chart_gesture_handler.dart` — add `@immutable` to `OiChartHitResult`; convert `show()` to setter or suppress lint
3. [ ] `packages/obers_ui_charts/lib/src/charts/pie/pie_chart_data_processor.dart` — add `@immutable` to `OiPieSlice` (same file as #1)
4. [ ] `packages/obers_ui_charts/lib/src/charts/pie/pie_chart_painter.dart` — fix formatting + any `use_named_constants` issues
5. [ ] `packages/obers_ui_charts/lib/src/core/chart_theme.dart` — fix formatting
6. [ ] `packages/obers_ui_charts/test/src/charts/bar/bar_chart_test.dart` — remove unused `tappedResult` variable
7. [ ] `packages/obers_ui_charts/test/src/charts/bar/bar_chart_data_processor_test.dart` — fix formatting
8. [ ] `packages/obers_ui_charts/test/src/charts/line/line_chart_test.dart` — remove unused `tappedResult` variable
9. [ ] `packages/obers_ui_charts/test/src/charts/pie/pie_chart_test.dart` — remove unused `tappedResult` variable
10. [ ] `packages/obers_ui_charts/test/src/core/chart_gesture_handler_test.dart` — remove unused `result` variable
11. [ ] `packages/obers_ui_charts/test/src/core/chart_theme_test.dart` — fix formatting
12. [ ] Any additional files flagged by remaining info-level lint issues (named constants, cascade invocations, prefer_int_literals)

## Commands to run in check phase

```bash
cd packages/obers_ui_charts && dart format --set-exit-if-changed .
cd packages/obers_ui_charts && dart analyze
cd packages/obers_ui_charts && flutter test
```

## Key design decisions and rationale

1. **No API changes**: All fixes are internal (annotations, casts, variable cleanup). The public API surface remains identical.
2. **`@immutable` over refactoring**: Adding the annotation is simpler and correct since the classes already have all-final fields.
3. **Setter vs. suppress**: If `show()` does more than set a value (it calls `notifyListeners()`), we'll suppress the lint rather than break the interface contract.

## Potential risks with mitigation

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Setter conversion breaks tooltip behavior | Medium | Inspect implementation; suppress lint if setter doesn't fit |
| `@immutable` annotation requires `meta` import | Low | Flutter SDK includes `package:meta`; already in scope |
| Formatting changes alter line breaks in tests | Low | Run tests after formatting to confirm |

## Cross-atom dependencies

- **REQ-0001** is already satisfied and independent — no changes needed.
- **REQ-0002** and **REQ-0003** share the same fix set: every lint fix (ST1–ST3) serves both convention alignment (REQ-0002) and zero-diagnostic (REQ-0003). Formatting (ST4) serves REQ-0003 directly.
- **Ordering**: ST1 (blocking error) → ST2 (warnings) → ST3 (infos) → ST4 (format) → ST5 (verify). The blocking error must be fixed first since `dart analyze` may short-circuit on errors.
- **Shared files**: `pie_chart_data_processor.dart` is touched by both ST1 (type fix) and ST3 (immutability annotation). `chart_gesture_handler.dart` is touched by both ST3 items (immutability + setter).
