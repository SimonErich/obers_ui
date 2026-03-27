## Overview

Close ALL remaining gaps between the wishlist and current codebase. No out-of-scope items.

**Spec**: `concept/26-03-obers_ui_wishlist.md` + `concept/27-03-wishlist-gaps-1.md`

## Context

- 125 tests currently passing across 10 widgets
- Most API params and behaviors are done
- Remaining gaps are: OiDatePicker enhancements, sticky headers, tooltip overlay, form field fixes, per-level theme colors, missing tests

## Plan

### Phase 1: OiDatePicker Enhancements (blocks OiDateRangePicker + OiWeekStrip)

- **Goal**: Add disabledDates, disabledDaysOfWeek, firstDayOfWeek, hover state, and keyboard nav to OiDatePicker. This unblocks the range picker's full spec.

- [ ] `lib/src/components/navigation/oi_date_picker.dart` — Add params:
  - `disabledDates: Set<DateTime>?` — check in `_isDisabled()`, render muted
  - `disabledDaysOfWeek: Set<int>?` — check weekday in `_isDisabled()`
  - `firstDayOfWeek: int?` (default null = Sunday as current) — adjust grid start offset
  - `hoverDate: DateTime?` + `onHoverDateChanged: ValueChanged<DateTime>?` — for range preview hover highlighting
  - Wrap day cells in `MouseRegion(onEnter/onExit)` to track hover
  - Add `_isInHoverRange()` check for visual highlighting between rangeStart and hoverDate
- [ ] `lib/src/components/navigation/oi_date_picker.dart` — Keyboard navigation:
  - Wrap grid in `Focus` widget with `FocusNode`
  - Track `_focusedDay` state
  - Handle `LogicalKeyboardKey.arrowUp/Down/Left/Right` to move focus
  - Handle `LogicalKeyboardKey.enter` to select focused day
  - Visually indicate focused day with border
- [ ] `lib/src/composites/scheduling/oi_date_range_picker.dart` — Pass through:
  - `disabledDates`, `disabledDaysOfWeek`, `firstDayOfWeek` to both OiDatePicker instances
  - Wire hover: track `_hoverDate` in state, pass to OiDatePicker, update on hover callback
- [ ] TDD: OiDatePicker disabled dates blocked → disabled days of week blocked → firstDayOfWeek changes grid → hover highlights prospective range → keyboard arrows move focus, Enter selects
- [ ] TDD: OiDateRangePicker selecting start then end calls onApply → disabled dates blocked → hover highlights range → firstDayOfWeek passed through
- [ ] Verify: `flutter test test/src/components/navigation/oi_date_picker_test.dart test/src/composites/scheduling/oi_date_range_picker_test.dart`

---

### Phase 2: OiGroupedList Sticky Headers

- **Goal**: Rewrite OiGroupedList build to use CustomScrollView with SliverPersistentHeader for sticky headers.

- [ ] `lib/src/composites/data/oi_grouped_list.dart` — Rewrite build():
  - When `stickyHeaders` is true: use `CustomScrollView` with `SliverList` for items + `SliverPersistentHeader(pinned: true)` for group headers
  - When `stickyHeaders` is false: keep current ListView approach
  - Create `_GroupHeaderDelegate extends SliverPersistentHeaderDelegate` for the sticky header
  - Pass `physics` and `controller` to CustomScrollView
- [ ] TDD: sticky headers pin during scroll (verify SliverPersistentHeader in tree when stickyHeaders=true)
- [ ] Verify: `flutter test test/src/composites/data/oi_grouped_list_test.dart`

---

### Phase 3: OiDateRangePicker Time Picker + Form Field Fixes

- **Goal**: Wire showTimePicker, create OiDateRangeInput, fix clear button.

- [ ] `lib/src/composites/scheduling/oi_date_range_picker.dart` — showTimePicker:
  - When `showTimePicker` is true, render OiTimeInput below each calendar
  - Import OiTimeInput from `obers_ui/src/components/inputs/oi_time_input.dart`
  - Track `_startTime` and `_endTime` in state
  - Combine date+time in onApply callback
- [ ] `lib/src/components/inputs/oi_date_range_picker_field.dart` — Fix clear button:
  - Change empty `onTap` callback to actually clear: set internal state to null and trigger rebuild
  - Add `required: bool` parameter with visual asterisk indicator
- [ ] `lib/src/composites/scheduling/oi_date_range_input.dart` — Create OiDateRangeInput:
  - New file as form field companion per wishlist spec (lines 440-478)
  - Params: label (required), startDate, endDate, onChanged, presets, firstDate, lastDate, hint, error, enabled, required, clearable, displayFormat, semanticLabel
  - Opens OiDateRangePicker in OiPopover on tap
  - Displays formatted range text
- [ ] Export OiDateRangeInput in `lib/obers_ui.dart`
- [ ] TDD (OiDateRangePicker): showTimePicker renders time inputs
- [ ] TDD (OiDateRangeInput): displays formatted range → shows error → disabled prevents interaction → clearable shows clear button
- [ ] TDD (preset): today() same day → last7Days() spans 7 → thisMonth() starts day 1 → lastMonth() ends last day → defaults count
- [ ] Verify: `flutter test test/src/composites/scheduling/`

---

### Phase 4: OiIndexBar Tooltip + OiBanner Theme Colors

- **Goal**: Implement floating tooltip overlay during drag. Add per-level color overrides to OiBannerThemeData.

- [ ] `lib/src/components/navigation/oi_index_bar.dart` — Tooltip overlay:
  - In `_IndexBarGesture`, when drag is active and `showTooltip` is true:
  - Use `OverlayEntry` to show a floating label positioned to the left of the current letter
  - The tooltip shows the current letter in a rounded container with primary background
  - Remove overlay when drag ends
- [ ] `lib/src/foundation/theme/component_themes/oi_banner_theme_data.dart` — Add per-level fields:
  - `infoBackground: Color?`, `infoBorder: Color?`
  - `successBackground: Color?`, `successBorder: Color?`
  - `warningBackground: Color?`, `warningBorder: Color?`
  - `errorBackground: Color?`, `errorBorder: Color?`
  - `neutralBackground: Color?`, `neutralBorder: Color?`
  - Update copyWith, ==, hashCode
- [ ] `lib/src/components/feedback/oi_banner.dart` — Use theme color overrides:
  - In the color resolution switch, check themeData fields first, fall back to OiColorScheme
- [ ] TDD: OiIndexBar showTooltip displays floating label on drag
- [ ] TDD: OiBanner per-level theme color overrides applied
- [ ] Verify: `flutter test test/src/components/navigation/oi_index_bar_test.dart test/src/components/feedback/oi_banner_test.dart`

---

### Phase 5: Missing Tests Sweep

- **Goal**: Add ALL remaining wishlist tests that aren't yet implemented.

- [ ] OiWeekStrip tests:
  - swipe left navigates to next week (wishlist line 1338)
  - today indicator visible when not selected (wishlist line 1351)
- [ ] OiIndexBar tests:
  - meets minimum touch target size (wishlist line 1589)
- [ ] OiOptimisticAction tests:
  - tapping Undo calls rollback (wishlist line 2301) — use larger surface or mock
  - tapping Undo prevents commit (wishlist line 2370)
  - execute returns false when undone (wishlist line 2418)
- [ ] OiDateRangePreset tests:
  - today() resolves to same day (wishlist line 677)
  - thisMonth() starts on day 1 (wishlist line 688)
  - lastMonth() ends on last day of prev month (wishlist line 693)
  - defaults list contains expected preset count (wishlist line 701)
- [ ] OiGroupedList tests:
  - virtual scrolling support (verify itemKey used) (wishlist line 726)
- [ ] Verify: `flutter test` (full suite)

---

### Phase 6: Final Verification

- [ ] Run full test suite: `flutter test`
- [ ] Run analysis: `dart analyze`
- [ ] Verify all wishlist tests are covered (re-run gap analysis)
- [ ] Update gap analysis doc with "CLOSED" status

## Risks

- OiDatePicker keyboard navigation requires Focus/FocusNode management — may interact with existing tests
- Sticky headers rewrite changes OiGroupedList from ListView to CustomScrollView — may break existing tests
- OiOptimisticAction undo tests depend on overlay positioning — may need mock approach
