# Spec: obers_ui Wishlist — 10 New Widgets

<goal>
Add 10 new widgets to obers_ui that fill common gaps identified in the Qatery gap analysis.
These widgets prevent re-implementation across projects, saving an estimated ~4,350 lines per consuming app.

**Who benefits:** Any Flutter project using obers_ui that needs inline alerts, date range selection,
grouped lists, week-based navigation, entity action toolbars, account switching, optimistic updates,
skeleton loading presets, or lightweight key-value displays.

**Why it matters:** These are the most frequently re-built patterns in Qatery's custom `uikit_obers` layer.
Promoting them to obers_ui eliminates drift between projects and ensures consistent behavior, accessibility,
and theming.
</goal>

<background>
- **Tech stack:** Flutter >=3.41.0, Dart >=3.11.0, zero Material/Cupertino dependency
- **Architecture:** 4-tier (Foundation → Primitives → Components → Composites → Modules), each tier imports only from below
- **Conventions:** `Oi` prefix, factory constructors for variants, `context.colors`/`context.spacing`/`context.radius` for tokens, `OiLabel` for text, `label`/`semanticLabel` required on all interactive widgets
- **Theme integration:** `OiComponentThemes` class with nullable fields per component, theme data classes in `lib/src/foundation/theme/component_themes/`
- **Test conventions:** Mirror source paths, `pumpObers()` helper, `pumpAtBreakpoint()` for responsive tests
- **Barrel export:** Single `lib/obers_ui.dart` with ~389 export statements
- **Settings persistence:** `OiSettingsDriver`/`settingsKey`/`settingsNamespace` pattern (used by OiCalendar, OiListView, OiKanban)

**Files to examine:**
- @lib/obers_ui.dart (barrel exports)
- @lib/src/foundation/theme/oi_component_themes.dart (theme registration)
- @lib/src/components/navigation/oi_date_picker.dart (range mode, `firstDate`/`lastDate` naming)
- @lib/src/components/inputs/oi_date_range_picker_field.dart (existing OiDateRangePreset)
- @lib/src/components/overlays/oi_toast.dart (OiToastLevel pattern)
- @lib/src/components/overlays/oi_snack_bar.dart (programmatic overlay display)
- @lib/src/components/feedback/oi_bulk_bar.dart (OiBulkAction model, confirm pattern)
- @lib/src/components/display/oi_field_display.dart (OiFieldType-based formatting)
- @lib/src/components/display/oi_skeleton_group.dart (existing skeleton composer)
- @lib/src/primitives/animation/oi_shimmer.dart (raw shimmer effect)
- @lib/src/foundation/oi_undo_stack.dart (OiUndoAction pattern)
- @lib/src/components/navigation/oi_user_menu.dart (user profile dropdown)
</background>

<discovery>
Before implementing, the implementer MUST investigate these integration points:

**Phase 1 — OiDateRangePicker discovery:**
1. Read `lib/src/components/navigation/oi_date_picker.dart` fully — understand `rangeMode`, `_pendingRangeStart`, and how range highlighting works. The composite will wrap two OiDatePicker instances.
2. Read `lib/src/components/inputs/oi_date_range_picker_field.dart` fully — OiDateRangePreset already exists here. The composite must reuse it, NOT duplicate.
3. Determine if OiDatePicker exposes enough API surface for external month navigation control (setting `_displayMonth` from the composite). If not, a minor refactor to accept `displayMonth` as a parameter may be needed.
4. Check if OiDatePicker supports hover-based range preview or if this needs adding.

**Phase 2 — OiOptimisticAction discovery:**
1. Read `lib/src/components/overlays/oi_snack_bar.dart` — understand `OiSnackBar.show()` return type (`OiOverlayHandle`?) and how to programmatically dismiss.
2. Read `lib/src/foundation/oi_undo_stack.dart` — understand OiUndoAction model. OiOptimisticAction should NOT duplicate this; it orchestrates differently (async commit vs undo stack).
3. Verify the overlay system supports replacing/cancelling a pending snackbar (needed for debounce behavior).

**Phase 3 — OiSkeletonPreset discovery:**
1. Read `lib/src/components/display/oi_skeleton_group.dart` — determine if factory constructors can be added to OiSkeletonGroup directly, or if a separate OiSkeletonPreset class is warranted.
2. Check if OiShimmer respects `MediaQuery.disableAnimations` for reduced-motion support.

**Phase 4 — OiGroupedList discovery:**
1. Read `lib/src/primitives/scroll/oi_virtual_list.dart` — understand its API. OiGroupedList will likely wrap or compose with it for virtual scrolling support.
2. Check how sticky headers can be implemented without Material's SliverPersistentHeader.
</discovery>

<stages>

## Stage 1: HIGH Priority — Foundation + Simple Components

**Widgets:** OiBanner, OiOptimisticAction, OiKeyValue
**Rationale:** Smallest surface area, fewest dependencies, highest usage frequency.

### 1A. OiBanner — Inline Alert Bar
**Tier:** Component | **Category:** Feedback
**Files:**
- `lib/src/components/feedback/oi_banner.dart`
- `lib/src/foundation/theme/component_themes/oi_banner_theme_data.dart`
- `test/src/components/feedback/oi_banner_test.dart`

### 1B. OiOptimisticAction — Optimistic Update Utility
**Tier:** Foundation | **Category:** Utilities
**Files:**
- `lib/src/foundation/oi_optimistic_action.dart`
- `test/src/foundation/oi_optimistic_action_test.dart`

### 1C. OiKeyValue — Lightweight Label-Value Display
**Tier:** Component | **Category:** Display
**Files:**
- `lib/src/components/display/oi_key_value.dart`
- `lib/src/foundation/theme/component_themes/oi_key_value_theme_data.dart`
- `test/src/components/display/oi_key_value_test.dart`

**Verify Stage 1:** All 3 widgets render correctly, pass tests, are exported via barrel file, and theme data is registered in OiComponentThemes.

---

## Stage 2: HIGH Priority — Complex Composites

**Widgets:** OiDateRangePicker (+OiDateRangeInput), OiGroupedList (+OiGroupedListController)
**Rationale:** These are the most complex widgets with internal dependencies. Discovery phases must be completed first.

### 2A. OiDateRangePicker — Dual-Calendar Range Selector
**Tier:** Composite | **Category:** Input
**Files:**
- `lib/src/composites/input/oi_date_range_picker.dart`
- `lib/src/composites/input/oi_date_range_input.dart`
- `lib/src/foundation/theme/component_themes/oi_date_range_picker_theme_data.dart`
- `test/src/composites/input/oi_date_range_picker_test.dart`
- `test/src/composites/input/oi_date_range_input_test.dart`

### 2B. OiGroupedList — Sectioned/Grouped Data List
**Tier:** Composite | **Category:** Data
**Files:**
- `lib/src/composites/data/oi_grouped_list.dart` (includes OiGroupedListController, OiEmptyGroupBehavior)
- `lib/src/foundation/theme/component_themes/oi_grouped_list_theme_data.dart`
- `test/src/composites/data/oi_grouped_list_test.dart`

**Verify Stage 2:** Date range selection works end-to-end (preset → apply → callback). Grouped list renders sections, collapses/expands, and supports programmatic control.

---

## Stage 3: MEDIUM Priority — Navigation & Interaction Components

**Widgets:** OiWeekStrip, OiIndexBar, OiActionBar, OiAccountSwitcher
**Rationale:** Independent components with clear scope. Can be built in parallel.

### 3A. OiWeekStrip — Compact Horizontal Week Selector
**Tier:** Component | **Category:** Navigation
**Files:**
- `lib/src/components/navigation/oi_week_strip.dart`
- `lib/src/foundation/theme/component_themes/oi_week_strip_theme_data.dart`
- `test/src/components/navigation/oi_week_strip_test.dart`

### 3B. OiIndexBar — Alphabet/Index Sidebar
**Tier:** Component | **Category:** Navigation
**Files:**
- `lib/src/components/navigation/oi_index_bar.dart`
- `lib/src/foundation/theme/component_themes/oi_index_bar_theme_data.dart`
- `test/src/components/navigation/oi_index_bar_test.dart`

### 3C. OiActionBar — Contextual Entity Action Toolbar
**Tier:** Component | **Category:** Toolbars
**Files:**
- `lib/src/components/toolbars/oi_action_bar.dart` (includes OiActionBarItem, OiActionBarStyle)
- `lib/src/foundation/theme/component_themes/oi_action_bar_theme_data.dart`
- `test/src/components/toolbars/oi_action_bar_test.dart`

### 3D. OiAccountSwitcher — Workspace/Org/Account Selector
**Tier:** Component | **Category:** Navigation
**Files:**
- `lib/src/components/navigation/oi_account_switcher.dart`
- `lib/src/foundation/theme/component_themes/oi_account_switcher_theme_data.dart`
- `test/src/components/navigation/oi_account_switcher_test.dart`

**Verify Stage 3:** Each widget renders, responds to interaction, adapts to breakpoints, and passes accessibility checks.

---

## Stage 4: LOW Priority — Skeleton Presets

**Widget:** OiSkeletonPreset
**Rationale:** Depends on discovery findings about OiSkeletonGroup. May become factory constructors on OiSkeletonGroup instead of a separate class.

### 4A. OiSkeletonPreset — Skeleton Loading Shape Presets
**Tier:** Component | **Category:** Feedback
**Files (if separate class):**
- `lib/src/components/feedback/oi_skeleton_preset.dart`
- `test/src/components/feedback/oi_skeleton_preset_test.dart`
**Files (if extending OiSkeletonGroup):**
- Modify `lib/src/components/display/oi_skeleton_group.dart` — add factory constructors
- Modify `test/src/components/display/oi_skeleton_group_test.dart` — add factory tests

**Decision point:** After discovery Phase 3, decide whether to create a new class or extend OiSkeletonGroup. If OiSkeletonGroup already composes children and the factories would just be convenience constructors, extend it. If the presets need fundamentally different rendering (proportional sizing, reduced-motion), create a new class.

**Verify Stage 4:** All preset variants render shimmer elements matching their shape profile. Reduced-motion shows static placeholders.

</stages>

<requirements>

## API Adjustments (Critical — deviations from wishlist)

The wishlist provides complete API signatures. The following adjustments are required to align with existing obers_ui conventions:

**Functional:**

1. **Parameter naming — `firstDate`/`lastDate` not `minDate`/`maxDate`:** OiDatePicker uses `firstDate` and `lastDate`. All date-constraining parameters across OiDateRangePicker, OiWeekStrip, and OiDateRangeInput MUST use `firstDate`/`lastDate` for consistency.

2. **OiDateRangePreset reuse:** `OiDateRangePreset` already exists in `lib/src/components/inputs/oi_date_range_picker_field.dart`. OiDateRangePicker MUST import and reuse this class, NOT define a new one. If the existing class needs new static presets (thisQuarter, lastQuarter, thisYear, lastYear, allTime), add them to the existing class.

3. **OiKeyValue is NOT redundant with OiFieldDisplay:** OiFieldDisplay requires `OiFieldType` and does automatic formatting (dates, currencies, JSON, etc.). OiKeyValue is intentionally simpler — `String` label + `String?` value, no formatting logic. Both serve distinct purposes. OiKeyValue MUST NOT accept `OiFieldType`.

4. **OiActionBar is NOT redundant with OiBulkBar:** OiBulkBar is for multi-select batch operations (shows selectedCount, select-all toggle). OiActionBar is for single-entity contextual actions (email toolbar, document actions). Different use cases, different APIs.

5. **OiAccountSwitcher is NOT redundant with OiUserMenu or OiSelect:** OiUserMenu handles profile actions (settings, logout). OiSelect is a form input. OiAccountSwitcher is a workspace-level context switcher with avatar trigger, active marking, and add-account action.

6. **OiOptimisticAction is a static utility class, not a widget:** It orchestrates `apply` → snackbar → `commit`/`rollback`. It lives in Foundation tier as a utility, not in Components. No theme data needed.

7. **OiBanner level enum naming:** Use `OiBannerLevel` (matching `OiToastLevel` pattern). Values: `info`, `success`, `warning`, `error`, `neutral`. The `neutral` variant is unique to Banner (not in OiToastLevel) since banners serve as generic inline notices.

8. **OiGroupedList settings persistence:** Use the established pattern: `settingsDriver: OiSettingsDriver?`, `settingsKey: String?`, `settingsNamespace: String = 'oi_grouped_list'`. Drop `settingsSaveDebounce` from the wishlist if it was included — match the exact pattern used by OiCalendar and OiListView.

9. **OiWeekStrip locale parameter:** The wishlist includes `locale: Locale?` but existing date components (OiDatePicker, OiCalendar) do NOT accept a locale parameter — they rely on the app-level locale. OiWeekStrip SHOULD include `locale` for day-of-week abbreviations since it uses `intl` for formatting, but document it as optional override of the app locale.

10. **OiActionBar `confirm` field on OiActionBarItem:** This mirrors the existing `OiBulkAction.confirm` pattern (bool + confirmLabel). Keep this pattern but use `String? confirm` (the confirm message) rather than separate `bool confirm` + `String? confirmLabel` — simpler API and consistent with the wishlist's design.

**Error Handling:**

11. **OiOptimisticAction commit failure:** When `commit()` throws, `rollback()` MUST be called automatically, and an error toast shown via `OiToast.show()`. The `errorMessage` parameter provides the toast text. If `rollback()` also throws, the error should be logged but not surface a second toast.

12. **OiDateRangePicker invalid range:** If user selects end date before start date, swap them automatically (the earlier date becomes start, the later becomes end). Do NOT show an error.

13. **OiGroupedList empty items:** When `items` is empty, show `emptyState` widget. When a specific group has zero items, behavior follows `emptyGroupBehavior` enum (`hide`, `showHeader`, `showEmpty`).

**Edge Cases:**

14. **OiBanner self-dismissal:** When `dismissible: true` and no `onDismiss` callback is provided, the banner manages its own visibility state internally with an `AnimatedSize` height reveal. When `onDismiss` IS provided, the banner calls it and does NOT manage its own state — the parent is responsible.

15. **OiDateRangePicker month navigation constraint:** Right calendar MUST always show a month >= left calendar month. If the user navigates the left calendar to match the right, the right auto-advances by one month.

16. **OiWeekStrip week boundary spanning months:** When a week spans two months (e.g., Mar 30 - Apr 5), the month label should show both ("Mar – Apr"). When `showYear` is true and the week spans years, show both years.

17. **OiIndexBar drag across letters:** During a vertical drag, fire `onLabelSelected` for each letter the finger passes over, not just the start and end. Deduplicate consecutive identical labels.

18. **OiAccountSwitcher single account:** When `accounts.length == 1`, the trigger should still render but tapping should be a no-op (no dropdown). Do NOT hide the component.

19. **OiOptimisticAction concurrent actions:** When a new `execute()` is called while a previous one is pending (undo window active), the previous action's `commit()` is triggered immediately (skip remaining undo window), then the new action begins its cycle.

**Validation:**

20. **Required accessibility labels:** Every interactive widget MUST require `label: String` in its constructor. Non-interactive display widgets use optional `semanticLabel: String?`. This is already specified in the wishlist APIs — verify compliance during implementation.

21. **Semantic live regions:** OiBanner MUST announce via a live region on first appearance. OiOptimisticAction's snackbar inherits OiSnackBar's accessibility.

</requirements>

<boundaries>

## Edge Cases

- **OiBanner stacking:** Multiple banners stack in DOM order. No built-in limit on count. Consumer is responsible for managing banner quantity.
- **OiDateRangePicker same-day range:** Selecting the same date for start and end is valid — represents a single-day range.
- **OiGroupedList dynamic groupBy:** If `groupBy` function returns different keys for the same item across rebuilds, groups will reorganize. No animation for group membership changes.
- **OiWeekStrip date normalization:** All DateTime comparisons strip time components (compare date-only). `eventCounts` keys are matched by year/month/day only.
- **OiIndexBar 27+ labels:** When labels exceed vertical space, the bar clips. No scrolling within the bar — this is by design for spatial consistency.
- **OiActionBar zero actions:** If `actions` is empty and `overflowActions` is null, render nothing (not an empty bar).
- **OiAccountSwitcher generic T:** The generic type `T` must support equality for active account marking. If `T` doesn't implement `==`, consumer MUST provide `accountKey`.
- **OiOptimisticAction widget disposal:** If the BuildContext is disposed during the undo window (user navigates away), cancel the pending action and call rollback. Do NOT attempt to show a toast on a disposed context.

## Error Scenarios

- **OiOptimisticAction rollback failure:** Log the error, do not show a second toast. The original error toast is sufficient.
- **OiDateRangePicker disabled date in range:** If a user selects start date, then hovers over a range containing disabled dates, the disabled dates should still be visually muted within the highlight range. Selecting an end date that would include disabled dates IS allowed — the disabled dates constraint only prevents selecting them as start/end points.
- **OiGroupedList virtual scrolling with collapse:** When a group is collapsed during virtual scrolling, the scroll extent must recalculate immediately. Use `ScrollController.jumpTo` if the current scroll position exceeds the new extent.

## Limits

- **OiDateRangePicker preset count:** No hard limit, but the preset panel scrolls if presets exceed visible space.
- **OiGroupedList item count:** Must handle 10,000+ items efficiently when virtual scrolling is active.
- **OiIndexBar label count:** Designed for ~27 labels (A-Z + #). More labels are supported but touch targets shrink proportionally.
- **OiAccountSwitcher account count:** `maxVisible` defaults to 8. Beyond that, the dropdown scrolls.

</boundaries>

<implementation>

## Per-Widget Implementation Checklist

For EACH widget, the implementer must:

1. **Create source file** at the specified path
2. **Create theme data class** (if applicable) in `lib/src/foundation/theme/component_themes/`
3. **Register theme data** in `OiComponentThemes` — add field, update `.empty()`, `copyWith()`, `==`, `hashCode`
4. **Add barrel export** in `lib/obers_ui.dart`
5. **Create test file** at the mirror path under `test/`
6. **Update AI_README.md** with widget entry (tags, parameters, usage, anti-patterns)
7. **Update doc/ site** if documentation pages exist for the widget's category

## Patterns to Follow

- **Factory constructors for variants:** OiBanner (`.info()`, `.success()`, `.warning()`, `.error()`, `.neutral()`), OiSkeletonPreset (`.text()`, `.avatar()`, `.card()`, etc.), OiIndexBar (`.alphabet()`)
- **Companion types in same file:** Enums and data classes (OiBannerLevel, OiActionBarItem, OiActionBarStyle, OiEmptyGroupBehavior, OiIndexBarSize) defined in the widget's main file, not separate files
- **Generic type parameter:** OiAccountSwitcher<T>, OiGroupedList<T> — follow OiSelect<T> pattern
- **Static utility methods:** OiOptimisticAction.execute(), OiOptimisticAction.cancelPending() — follow OiDatePicker.show() pattern
- **Controller pattern:** OiGroupedListController — follow OiUndoStack pattern (standalone class, not attached to widget state)
- **Responsive breakpoint adaptation:** OiBanner compact mode on `OiBreakpoint.compact`, OiDateRangePicker single calendar on compact, OiActionBar icon-only on compact, OiKeyValue vertical direction on compact

## What to Avoid

- **Do NOT use Material or Cupertino widgets.** All rendering via OiSurface, OiLabel, OiIcon, OiTappable, OiRow, OiColumn, etc.
- **Do NOT hardcode colors.** Use `context.colors.info`, `context.colors.success`, `context.colors.warning`, `context.colors.error`, `context.colors.primary`, `context.colors.text`, etc.
- **Do NOT use `Text()`.** Use `OiLabel.body()`, `OiLabel.small()`, `OiLabel.h4()`, etc.
- **Do NOT use `Row`/`Column`.** Use `OiRow`/`OiColumn` with explicit `breakpoint` parameter.
- **Do NOT duplicate OiDateRangePreset.** Import from `oi_date_range_picker_field.dart`. Add new static getters there if needed.
- **Do NOT add `locale` parameters** unless the component uses `intl` for formatting. Match existing component patterns.
- **Do NOT create separate files for companion enums/types.** Keep them in the widget's main file unless they're shared across widgets.

</implementation>

<validation>

## Testing Strategy

### Test Split by Type

**Unit tests** (logic, data, utilities):
- OiDateRangePreset `.resolve()` methods (all static presets return correct date ranges)
- OiGroupedListController programmatic control (expand, collapse, toggle)
- OiOptimisticAction state machine (apply → undo/commit → rollback on failure)
- OiEmptyGroupBehavior enum behavior

**Widget tests** (component rendering, interaction, edge cases):
- Each widget: rendering, factory variants, prop-driven behavior, dismiss/close interactions, disabled state, accessibility labels
- Responsive tests via `pumpAtBreakpoint()`: compact/expanded layout switching
- Theme override tests: verify components respect theme data overrides

**No robot/journey tests needed:** These are isolated library components, not app-level flows. Widget tests cover all interaction paths.

### TDD Expectations

Each widget MUST be implemented using vertical-slice TDD:

1. **Behavior-first slices (recommended order per widget):**
   - Slice 1: Renders with required props (happy path)
   - Slice 2: Factory variants render correctly (if applicable)
   - Slice 3: Primary interaction fires callback
   - Slice 4: Dismiss/close behavior
   - Slice 5: Disabled/loading state
   - Slice 6: Edge cases (empty, boundary conditions)
   - Slice 7: Accessibility (semantic labels, live regions)
   - Slice 8: Responsive breakpoint adaptation

2. **Red-green-refactor cycle:** Write ONE failing test → implement minimally → refactor → next test. Do NOT write all tests first.

3. **Testability seams:**
   - OiOptimisticAction: Accept a `Duration undoDuration` parameter so tests can use short durations (100ms). Use `tester.pump(duration)` to advance timers.
   - OiWeekStrip: Accept `DateTime` for `selectedDate` — tests use fixed dates, not `DateTime.now()`.
   - OiGroupedList: `groupBy` function is the seam — tests provide simple lambdas.
   - OiBanner: Self-dismissal uses `AnimatedSize` — tests use `pumpAndSettle()` to complete animation.

4. **Test helpers:** Use existing `pumpObers()` helper. For breakpoint tests, use `pumpAtBreakpoint()`. For platform-specific tests (touch swipe vs pointer click), use `pumpTouchApp()` / `pumpPointerApp()`.

### Baseline Coverage Outcomes

- **Logic/business rules:** 100% of OiDateRangePreset resolvers, OiOptimisticAction state transitions, OiGroupedList grouping algorithm
- **UI behavior:** Every factory constructor renders without errors. Every callback fires on correct interaction. Every disabled state prevents interaction.
- **Critical paths:** OiDateRangePicker select-start → select-end → apply flow. OiOptimisticAction apply → undo and apply → commit → rollback-on-failure flows. OiBanner dismiss animation.

### Test Count Estimates

| Widget | Estimated Tests |
|--------|----------------|
| OiBanner | 14 |
| OiDateRangePicker | 14 |
| OiDateRangeInput | 5 |
| OiDateRangePreset (additions) | 6 |
| OiGroupedList | 14 |
| OiWeekStrip | 13 |
| OiIndexBar | 9 |
| OiActionBar | 12 |
| OiAccountSwitcher | 9 |
| OiOptimisticAction | 11 |
| OiSkeletonPreset | 12 |
| OiKeyValue | 14 |
| **Total** | **~133** |

</validation>

<done_when>

1. All 10 widgets (+ OiDateRangeInput, OiGroupedListController) are implemented and render correctly
2. All ~133 tests pass with zero failures
3. `dart analyze` reports zero issues on new files
4. `dart format .` produces no changes on new files
5. Each widget is exported via `lib/obers_ui.dart`
6. Theme data classes are registered in `OiComponentThemes` (for widgets that have them)
7. AI_README.md is updated with entries for all 10 widgets
8. No Material or Cupertino imports in any new file
9. All interactive widgets require `label` parameter
10. OiDateRangePreset is reused from existing file (not duplicated)
11. Parameter naming uses `firstDate`/`lastDate` (not `minDate`/`maxDate`)

</done_when>
