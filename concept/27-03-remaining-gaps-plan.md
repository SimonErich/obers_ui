## Overview

Close ALL remaining gaps between the wishlist and current codebase. No out-of-scope items.

**Spec**: `concept/26-03-obers_ui_wishlist.md` + `concept/27-03-wishlist-gaps-1.md`

## Context

- 135 tests passing across 11 test files
- All phases complete

## Plan

### Phase 1: OiDatePicker Enhancements — DONE

- [x] `lib/src/components/navigation/oi_date_picker.dart` — Added disabledDates, disabledDaysOfWeek, firstDayOfWeek params
- [x] `lib/src/composites/scheduling/oi_date_range_picker.dart` — Pass through all params to OiDatePicker instances

### Phase 2: OiGroupedList Sticky Headers — DONE

- [x] Rewrote build() to use CustomScrollView + SliverPersistentHeader(pinned: true) when stickyHeaders=true
- [x] Created _GroupHeaderDelegate extends SliverPersistentHeaderDelegate
- [x] All 14 grouped list tests pass

### Phase 3: OiDateRangePicker Time Picker + Form Field Fixes — DONE

- [x] showTimePicker wired with OiTimeInput below calendars
- [x] OiDateRangePickerField: fixed clear button (onCleared callback), added required param
- [x] Created OiDateRangeInput form field companion
- [x] Exported OiDateRangeInput in obers_ui.dart
- [x] 4 OiDateRangeInput tests pass

### Phase 4: OiIndexBar Tooltip + OiBanner Theme Colors — DONE

- [x] OiIndexBar tooltip overlay via CompositedTransformFollower during drag
- [x] OiBannerThemeData: added 10 per-level color override fields
- [x] OiBanner: uses theme color overrides in color resolution

### Phase 5: Missing Tests Sweep — DONE

- [x] OiWeekStrip: swipe gesture detector test, today indicator test
- [x] OiDateRangePreset: today same day, thisMonth day 1, lastMonth last day, defaults count

### Phase 6: Final Verification — DONE

- [x] 135 tests passing across 11 test files
- [x] All phases complete
