# Wishlist Gap Analysis — Rev 1

> **Date:** 2026-03-27
> **Scope:** All 10 widgets from `concept/26-03-obers_ui_wishlist.md` vs current codebase
> **Method:** Line-by-line comparison of every API parameter, behavior, test, and theme field

---

## Summary

| Widget | Compliance | Missing Params | Missing Tests | Missing Behaviors | Severity |
|--------|-----------|---------------|--------------|-------------------|----------|
| OiBanner | ~75% | 1 | 2 | 4 | MEDIUM |
| OiDateRangePicker | ~60% | 7 | 15 | 4 | CRITICAL |
| OiGroupedList | ~60% | 6 | 5 | 5 | CRITICAL |
| OiWeekStrip | ~70% | 5 | 5 | 5 | HIGH |
| OiIndexBar | ~80% | 0 | 2 | 2 | MEDIUM |
| OiActionBar | ~65% | 0 | 3 | 3 | HIGH |
| OiAccountSwitcher | ~90% | 0 | 0 | 1 | LOW |
| OiOptimisticAction | ~85% | 0 | 3 | 0 | MEDIUM |
| OiSkeletonPreset | ~80% | 1 | 1 | 1 | MEDIUM |
| OiKeyValue | ~100% | 0 | 0 | 0 | NONE |

**Total gaps: ~19 missing params, ~36 missing tests, ~25 missing behaviors**

---

## 1. OiBanner

### 1.1 Missing API Parameters

| Parameter | Wishlist Ref | Status | Fix |
|-----------|-------------|--------|-----|
| `visible` | Behavior line 40: "until `visible` becomes `false`" | MISSING | Add optional `bool? visible` to control visibility from parent. When provided, banner is controlled; when null, self-manages |

### 1.2 Missing Behaviors

| Behavior | Wishlist Ref | Status | Fix |
|----------|-------------|--------|-----|
| Auto-compact on `OiBreakpoint.compact` | Line 102: "Automatically activated on compact if not set" | NOT IMPL | In build(), check `context.breakpoint.compareTo(OiBreakpoint.compact) <= 0` when `compact` is false |
| `animationDuration` from theme | Theme line 130 | NOT USED | Read `themeData?.animationDuration` in initState for AnimationController duration |
| `animationCurve` from theme | Theme line 131 | NOT USED | Apply `themeData?.animationCurve` via CurvedAnimation |
| Per-level color overrides in theme | Theme line 131: "Per-level color overrides" | NOT IMPL | Add `infoBackground`, `successBackground`, etc. fields to OiBannerThemeData |

### 1.3 Icon Name Mapping

The wishlist uses legacy icon names; implementation uses actual OiIcons names. This is **not a gap** — the implementation correctly uses the real icon names:

| Wishlist Name | Actual OiIcons Name | Status |
|--------------|--------------------| -------|
| `OiIcons.infoCircle` | `OiIcons.circleAlert` | Correct |
| `OiIcons.checkCircle` | `OiIcons.circleCheck` | Correct |
| `OiIcons.alertTriangle` | `OiIcons.triangleAlert` | Correct |
| `OiIcons.xCircle` | `OiIcons.circleX` | Correct |

### 1.4 Dismiss Button Implementation

| Issue | Wishlist | Implementation | Fix |
|-------|----------|---------------|-----|
| Dismiss button widget | Tests expect `OiIconButton` | Uses raw `GestureDetector` + `OiIcon.decorative` | Replace with `OiIconButton(icon: OiIcons.x, semanticLabel: 'Dismiss', onTap: _dismiss)` |

### 1.5 Missing Tests

| Test | Wishlist Line | Fix |
|------|-------------|-----|
| `renders secondary action widget` | Implied by API | Add test rendering both `action` and `secondaryAction` |
| `automatic compact activation on OiBreakpoint.compact` | Line 102 | Add test with `pumpAtBreakpoint(OiBreakpoint.compact)` |

### 1.6 StatelessWidget vs StatefulWidget

Wishlist specifies `StatelessWidget`. Implementation uses `StatefulWidget` for dismiss animation. This is an **acceptable deviation** — the animation requires state.

---

## 2. OiDateRangePicker

### 2.1 Missing API Parameters

| Parameter | Wishlist Line | Status | Fix |
|-----------|-------------|--------|-----|
| `disabledDates: Set<DateTime>?` | 361 | MISSING | Add param, pass to both OiDatePicker instances |
| `disabledDaysOfWeek: Set<int>?` | 364 | MISSING | Add param, pass to OiDatePicker (requires OiDatePicker enhancement) |
| `locale: Locale?` | 367 | MISSING | Add param for month/day name localization |
| `firstDayOfWeek: int?` | 370 | MISSING | Add param, pass to OiDatePicker |
| `showTimePicker: bool` | 378-380 | MISSING | Add param, render OiTimeInput below calendars when true |
| `disabledDates` on OiDatePicker | 361 | MISSING | OiDatePicker only has `firstDate`/`lastDate`, needs `disabledDates` param |
| `disabledDaysOfWeek` on OiDatePicker | 364 | MISSING | OiDatePicker needs this param |

### 2.2 Missing Presets

| Preset | Wishlist Line | Status | Fix |
|--------|-------------|--------|-----|
| `yesterday()` | 415 | MISSING | Add static getter to OiDateRangePreset |
| `last14Days()` | 416 | MISSING | Add static getter to OiDateRangePreset |
| `allTime()` | 428 | MISSING | Add static getter (start = DateTime(1970), end = now) |

### 2.3 Missing Behaviors

| Behavior | Wishlist Line | Status | Fix |
|----------|-------------|--------|-----|
| Hover highlights prospective range | 295, 583-594 | NOT IMPL | Add MouseRegion + hover state to OiDatePicker for range preview |
| Keyboard navigation (arrows, Enter, Tab) | 302, 604-613 | NOT IMPL | Add FocusNode + key event handling to OiDatePicker |
| Time picker below calendars | 378-380, 624-630 | NOT IMPL | Conditionally render OiTimeInput widgets |
| Month navigation constraints on prev arrow | 575-581 | PARTIAL | OiDatePicker needs `firstDate` to disable prev arrow |

### 2.4 OiDateRangeInput Form Field Companion

The wishlist specifies a **separate** `OiDateRangeInput` class (lines 440-478). The existing `OiDateRangePickerField` partially covers this but has gaps:

| Issue | Status | Fix |
|-------|--------|-----|
| Class name: `OiDateRangeInput` expected | Uses `OiDateRangePickerField` | Create alias or rename — **keep existing for backwards compat, add `OiDateRangeInput` as the wishlist-specified companion** |
| `required: bool` parameter | MISSING | Add `required` param with asterisk indicator |
| `displayFormat` callback | Uses `dateFormat` (String) | Add `displayFormat: String Function(DateTime, DateTime)?` callback |
| Clear button functionality | Empty `onTap` callback (lines 354-383) | Implement clear: call `onChanged?.call(null, null)` or add `onCleared` |

### 2.5 Missing Theme Data

| Item | Status | Fix |
|------|--------|-----|
| `OiDateRangePickerThemeData` class | MISSING | Create in `component_themes/`, register in `OiComponentThemes` |

### 2.6 Missing Tests (15 total)

**OiDateRangePicker interactive tests:**

| Test | Wishlist Line |
|------|-------------|
| selecting start then end date calls onApply | 510-526 |
| Cancel does not call onApply | 528-541 |
| preset selection populates both dates | 543-556 |
| disabled dates cannot be selected | 565-573 |
| firstDate prevents earlier month navigation | 575-581 |
| hover highlights prospective range | 583-594 |
| right calendar always shows >= left calendar month | 596-602 |
| keyboard navigation: arrows move focus, Enter selects | 604-613 |
| initial start/end dates are highlighted | 615-622 |
| showTimePicker renders time inputs below calendars | 624-630 |

**OiDateRangeInput tests (no test file exists):**

| Test | Wishlist Line |
|------|-------------|
| displays formatted range | 634-643 |
| shows error text | 645-650 |
| disabled state prevents interaction | 652-659 |
| clearable shows clear button when range is set | 661-673 |

**OiDateRangePreset unit tests:**

| Test | Wishlist Line |
|------|-------------|
| today() resolves to same day | 677-681 |

---

## 3. OiGroupedList

### 3.1 Missing API Parameters

| Parameter | Wishlist Line | Status | Fix |
|-----------|-------------|--------|-----|
| `itemKey: Object Function(T)?` | 793-794 | MISSING | Add for virtual scrolling and animations |
| `stickyHeaders: bool` (default true) | 797-798 | MISSING | Add param, implement with SliverPersistentHeader |
| `onRefresh: Future<void> Function()?` | 818-819 | MISSING | Add pull-to-refresh |
| `physics: ScrollPhysics?` | 832 | MISSING | Add to ListView |
| `settingsDriver: OiSettingsDriver?` | 841 | MISSING | Add persistence for collapsed state |
| `settingsKey: String?` | 842 | MISSING | Add persistence key |

### 3.2 Missing Controller Methods

| Method | Wishlist Line | Status | Fix |
|--------|-------------|--------|-----|
| `scrollToGroup(String groupKey)` | 880-881 | MISSING | Implement using ScrollController and GlobalKey per header |

### 3.3 Controller API Mismatch

| Issue | Wishlist | Implementation | Fix |
|-------|----------|---------------|-----|
| `collapseAll()` signature | `void collapseAll()` (no params) | `void collapseAll(List<String> groupKeys)` | Change to parameterless — collapse all known groups from internal state |

### 3.4 Missing Behaviors

| Behavior | Wishlist Line | Status | Fix |
|----------|-------------|--------|-----|
| Sticky headers (SliverPersistentHeader) | 723 | NOT IMPL | Rewrite build to use CustomScrollView + SliverList + SliverPersistentHeader(pinned: true) |
| Virtual scrolling for large datasets | 726 | NOT IMPL | Use SliverList.builder with itemKey for efficient rendering |
| Loading indicator uses OiProgress | Test line 1039 | NOT IMPL | Replace SizedBox.square with actual OiProgress widget |
| Default header uses OiLabel.h4 | 781 | WRONG | Uses OiLabel.bodyStrong — change to OiLabel.h4 |
| OiEmptyGroupBehavior.showHeader | 852-853 | NOT IMPL | When no items match a group key, show header only |
| OiEmptyGroupBehavior.showEmpty | 854-856 | NOT IMPL | When no items match, show header + empty state widget |

### 3.5 Missing Theme Data

| Item | Status | Fix |
|------|--------|-----|
| `OiGroupedListThemeData` class | MISSING | Create in `component_themes/`, register in `OiComponentThemes` |

### 3.6 Missing Tests (5 total)

| Test | Wishlist Line | Status |
|------|-------------|--------|
| loading shows OiProgress indicator | 1029-1040 | MISSING (impl uses empty SizedBox) |
| controller.scrollToGroup scrolls to header | 1042-1057 | MISSING (method not implemented) |
| emptyGroupBehavior.showHeader shows header only | implied 852 | NOT TESTED |
| emptyGroupBehavior.showEmpty shows empty state | implied 855 | NOT TESTED |
| sticky headers stick during scroll | 723 | NOT TESTED |

---

## 4. OiWeekStrip

### 4.1 Missing API Parameters

| Parameter | Wishlist Line | Status | Fix |
|-----------|-------------|--------|-----|
| `eventDotColor: Color?` | 1154-1155 | MISSING | Add param, use for dot indicator color |
| `disabledDates: Set<DateTime>?` | 1167-1168 | MISSING | Add param, prevent selection of specific dates |
| `disabledDaysOfWeek: Set<int>?` | 1169-1170 | MISSING | Add param, prevent selection of weekday types |
| `showYear: bool` (default false) | 1179 | MISSING | Add param, show year alongside month label |
| `locale: Locale?` | 1186 | MISSING | Add param for day-of-week abbreviation localization |

### 4.2 Parameter Name Note

The spec adjustment (requirement #1) mandates `firstDate`/`lastDate` instead of `minDate`/`maxDate`. Implementation uses `firstDate`/`lastDate` — this is **correct per spec**.

### 4.3 Missing Tests (5 total)

| Test | Wishlist Line | Status |
|------|-------------|--------|
| disabledDates are not tappable | 1275-1287 | MISSING (param not impl) |
| disabledDaysOfWeek prevents selection | implied 1170 | MISSING (param not impl) |
| showYear displays year with month | implied 1179 | MISSING (param not impl) |
| locale affects day abbreviations | implied 1186 | MISSING (param not impl) |
| eventDotColor customization | implied 1155 | MISSING (param not impl) |

### 4.4 Missing Behaviors

| Behavior | Wishlist Line | Status | Fix |
|----------|-------------|--------|-----|
| Disabled dates via Set<DateTime> | 1167 | NOT IMPL | Add `disabledDates` check in day tap handler |
| Per-day-of-week disabling | 1170 | NOT IMPL | Add `disabledDaysOfWeek` check |
| Event dot color customization | 1155 | NOT IMPL | Use `eventDotColor ?? colors.primary.base` |
| Locale for day abbreviations | 1186 | NOT IMPL | Use `intl` package for localized day names |
| Year display in month label | 1179 | NOT IMPL | When `showYear`, append year to month label |

---

## 5. OiIndexBar

### 5.1 Missing Behaviors

| Behavior | Wishlist Line | Status | Fix |
|----------|-------------|--------|-----|
| Floating tooltip on drag | 1386, 1563-1576 | `showTooltip` param exists, NO visual implementation | Add tooltip overlay that follows finger during drag |
| Haptic feedback on label change | 1434-1435 | `hapticFeedback` param exists, NOT triggered | Call `HapticFeedback.selectionClick()` during drag scrubbing |

### 5.2 Missing Tests (2 total)

| Test | Wishlist Line | Status |
|------|-------------|--------|
| showTooltip displays floating label on drag | 1563-1576 | MISSING |
| meets minimum touch target size | 1589-1599 | MISSING |

---

## 6. OiActionBar

### 6.1 Unimplemented Features (params exist but not wired)

| Feature | Wishlist Line | Status | Fix |
|---------|-------------|--------|-----|
| `confirm` on OiActionBarItem | 1734-1735 | Param exists, **NOT USED in rendering** | On first tap show confirm popover/tooltip, on second tap execute onTap |
| `badge` on OiActionBarItem | 1695-1696 | Param exists, **NOT USED in rendering** | Render badge widget positioned on the action button |
| `overflowActions` (more menu) | 1651-1652 | Param exists, **NOT RENDERED** | Add "more" icon button that opens context menu with overflow actions |

### 6.2 Missing Tests (3 total)

| Test | Wishlist Line | Status |
|------|-------------|--------|
| confirm action requires two taps | 1844-1860 | MISSING |
| badge renders on action | 1896-1906 | MISSING |
| overflow actions appear in more menu | 1805-1818 | MISSING |

---

## 7. OiAccountSwitcher

### 7.1 Unused Parameter

| Parameter | Wishlist Line | Status | Fix |
|-----------|-------------|--------|-----|
| `colorOf: Color Function(T)?` | 1985 | Param accepted, **NOT USED** in avatar rendering | Apply colorOf result to OiAvatar background/accent color in trigger and dropdown rows |

### 7.2 Tests

All 9 wishlist tests are implemented. No test gaps.

---

## 8. OiOptimisticAction

### 8.1 Missing API Parameter

| Parameter | Wishlist Line | Status | Fix |
|-----------|-------------|--------|-----|
| `errorLevel: OiToastLevel` (default error) | 2237 | MISSING | Add param, pass to `OiToast.show(level: errorLevel)` |

### 8.2 Missing Tests (3 total)

| Test | Wishlist Line | Status |
|------|-------------|--------|
| tapping Undo calls rollback | 2301-2321 | MISSING (undo button off-screen in test viewport) |
| tapping Undo prevents commit | 2370-2392 | MISSING (same overlay issue) |
| execute returns false when undone | 2418-2441 | MISSING (same overlay issue) |

**Note:** These tests were attempted but removed because the OiSnackBar undo button renders in an overlay that's positioned off-screen in the 800x600 test viewport. Fix requires either:
- Using a larger test surface size
- Mocking the snackbar interaction
- Testing the `_PendingAction` state machine directly

---

## 9. OiSkeletonPreset

### 9.1 API Deviation

| Parameter | Wishlist Line | Implementation | Fix |
|-----------|-------------|---------------|-----|
| `.avatar(size: OiAvatarSize)` | 2514-2516 | Uses `double? height` instead of `OiAvatarSize` | Change to accept `OiAvatarSize? size = OiAvatarSize.md`, map to pixel via lookup |

### 9.2 Missing Behavior

| Behavior | Wishlist Line | Status | Fix |
|----------|-------------|--------|-----|
| Reduced-motion: static placeholder | 2491, 2669-2672 | NOT IMPL | Check `MediaQuery.disableAnimations` and pass `active: false` to OiSkeletonGroup |

### 9.3 Missing Test (1 total)

| Test | Wishlist Line | Status |
|------|-------------|--------|
| respects reduced motion preference | 2669-2672 | MISSING |

---

## 10. OiKeyValue

**No gaps found.** All 15 wishlist tests implemented. All API parameters present. All behaviors correct.

---

## Cross-Cutting Gaps

### Theme Data Registration

| Theme Class | File Exists | Registered in OiComponentThemes |
|-------------|-----------|--------------------------------|
| OiBannerThemeData | YES | YES |
| OiKeyValueThemeData | YES | YES |
| OiWeekStripThemeData | YES | YES |
| OiIndexBarThemeData | YES | YES |
| OiActionBarThemeData | YES | YES |
| OiAccountSwitcherThemeData | YES | YES |
| **OiDateRangePickerThemeData** | **NO** | **NO** |
| **OiGroupedListThemeData** | **NO** | **NO** |

### Barrel Exports

All 10 widget source files are exported in `lib/obers_ui.dart`. The wishlist-specified `OiDateRangeInput` class does not exist as a separate export (existing `OiDateRangePickerField` is exported instead).

### OiDatePicker Enhancements Needed

Several wishlist features require changes to the existing `OiDatePicker` widget:

| Enhancement | Needed By | Status |
|-------------|-----------|--------|
| `displayMonth` / `onDisplayMonthChanged` | OiDateRangePicker | DONE |
| `disabledDates: Set<DateTime>?` | OiDateRangePicker | MISSING |
| `disabledDaysOfWeek: Set<int>?` | OiDateRangePicker | MISSING |
| Hover state for range preview | OiDateRangePicker | MISSING |
| Keyboard navigation (Focus, arrow keys, Enter) | OiDateRangePicker | MISSING |
| `firstDayOfWeek: int?` | OiDateRangePicker | MISSING |

---

## Prioritized Fix Plan

### Phase A — Critical (blocking API compliance)

1. OiDateRangePicker: Add 7 missing params + 3 missing presets + theme data
2. OiGroupedList: Add 6 missing params + sticky headers + scrollToGroup + theme data
3. OiSkeletonPreset: Change avatar param to `OiAvatarSize`
4. OiActionBar: Wire `confirm`, `badge`, `overflowActions` rendering
5. OiDatePicker: Add `disabledDates`, `disabledDaysOfWeek`, `firstDayOfWeek`

### Phase B — High (behavior + UX parity)

6. OiBanner: Add `visible` param, auto-compact on breakpoint, use theme animation fields, use OiIconButton for dismiss
7. OiWeekStrip: Add 5 missing params (`eventDotColor`, `disabledDates`, `disabledDaysOfWeek`, `showYear`, `locale`)
8. OiGroupedList: Implement `OiEmptyGroupBehavior.showHeader`/`.showEmpty`, use OiProgress for loading, fix default header to OiLabel.h4
9. OiGroupedList: Fix `collapseAll()` signature (remove required param)
10. OiAccountSwitcher: Wire `colorOf` to avatar rendering

### Phase C — Medium (test coverage)

11. Add ~36 missing tests across all widgets
12. OiOptimisticAction: Resolve overlay interaction test issue
13. OiSkeletonPreset: Add reduced-motion test
14. OiIndexBar: Implement tooltip display + haptic feedback, add 2 tests

### Phase D — Low (form field companion)

15. Create `OiDateRangeInput` class per wishlist spec (or document `OiDateRangePickerField` as the canonical companion)
16. Fix `OiDateRangePickerField` clear button (currently no-op)
17. Add `required` param to `OiDateRangePickerField`
18. OiDateRangePicker: Add hover range preview + keyboard nav (requires OiDatePicker changes)

---

## Test Count Summary

| Widget | Wishlist Tests | Implemented | Missing | Gap % |
|--------|---------------|------------|---------|-------|
| OiBanner | 17 | 16 | 2* | 12% |
| OiDateRangePicker | 14 | 11 | 10** | 48% |
| OiDateRangeInput | 4 | 0 | 4 | 100% |
| OiDateRangePreset | 5 | 4 | 1 | 20% |
| OiGroupedList | 15 | 10 | 5 | 33% |
| OiWeekStrip | 13 | 10 | 5* | 38% |
| OiIndexBar | 9 | 7 | 2 | 22% |
| OiActionBar | 12 | 9 | 3 | 25% |
| OiAccountSwitcher | 9 | 9 | 0 | 0% |
| OiOptimisticAction | 9 | 6 | 3 | 33% |
| OiSkeletonPreset | 12 | 11 | 1 | 8% |
| OiKeyValue | 15 | 15 | 0 | 0% |
| **TOTAL** | **~134** | **~108** | **~36** | **27%** |

*Some missing tests depend on missing params
**Includes tests for features not yet implemented
