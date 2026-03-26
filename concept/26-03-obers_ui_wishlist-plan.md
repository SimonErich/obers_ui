## Overview

Add 10 new widgets to obers_ui across Foundation/Component/Composite tiers. Staged by priority (HIGH → MEDIUM → LOW) with discovery phases for complex composites.

**Spec**: `concept/26-03-obers_ui_wishlist-spec.md` (read this file for full requirements)

## Context

- **Structure**: Tier-based (Foundation → Primitives → Components → Composites → Modules)
- **State management**: None (InheritedWidget + BuildContext extensions)
- **Reference implementations**:
  - Component scaffold: `lib/src/components/display/oi_badge.dart` (factory constructors, companion types)
  - Stateful + animation: `lib/src/components/feedback/oi_bulk_bar.dart` (confirm pattern, OiBulkAction model)
  - Overlay static show: `lib/src/components/overlays/oi_snack_bar.dart` (OiOverlayHandle, singleton dismiss)
  - Theme data: `lib/src/foundation/theme/component_themes/oi_badge_theme_data.dart`
  - Theme registration: `lib/src/foundation/theme/oi_component_themes.dart`
  - Controller pattern: `lib/src/composites/data/oi_table_controller.dart` (extends ChangeNotifier)
  - Skeleton composition: `lib/src/components/display/oi_skeleton_group.dart` (OiSkeletonLine, OiSkeletonBox)
  - Test scaffold: `test/src/components/display/oi_badge_test.dart`
  - Test helper: `test/helpers/pump_app.dart` (pumpObers extension)
- **Assumptions/Gaps**:
  - No `toolbars/` directory → OiActionBar goes in `components/navigation/`
  - OiSkeletonPreset must be new class (OiSkeletonGroup composes independent child classes)
  - OiDatePicker may need `displayMonth` parameter exposed for composite control — verify in discovery
  - OiSnackBar has static `_activeHandle` singleton — OiOptimisticAction uses this pattern

## Plan

### Phase 1: OiBanner + OiKeyValue + OiOptimisticAction (HIGH, simple)

- **Goal**: Ship 3 independent, low-dependency widgets. Validates the full creation pipeline (source → theme → export → test).

**1A. OiBanner — Inline Alert Bar**

- [x] `lib/src/components/feedback/oi_banner.dart` — StatefulWidget. OiBannerLevel enum (info/success/warning/error/neutral). 5 factory constructors. AnimatedSize for self-dismiss. Semantics(liveRegion: true) for a11y. Companion types in same file.
- [x] `lib/src/foundation/theme/component_themes/oi_banner_theme_data.dart` — borderRadius, padding, iconSize, animationDuration, animationCurve
- [x] Register in `lib/src/foundation/theme/oi_component_themes.dart` — add `banner` field, update empty/copyWith/==/hashCode
- [x] Export in `lib/obers_ui.dart` — add under Components/Feedback section
- [x] TDD: 16 tests — renders message, title, all 5 levels, dismiss button show/hide, onDismiss callback, animate out, action widget, icons, compact mode, live region, border, stacking
- [x] `test/src/components/feedback/oi_banner_test.dart`

**1B. OiKeyValue — Label-Value Display**

- [x] `lib/src/components/display/oi_key_value.dart` — StatelessWidget. String label + String? value (no OiFieldType). Horizontal/vertical direction. emptyText placeholder. copyable via OiCopyable. Static group() method for grouped rows with dividers. Dense mode.
- [x] `lib/src/foundation/theme/component_themes/oi_key_value_theme_data.dart` — labelWidth, padding, dividerColor
- [x] Register in `oi_component_themes.dart` + export in `obers_ui.dart`
- [x] TDD: 15 tests — renders label+value, null/empty emptyText, copyable, onTap, valueWidget, horizontal/vertical, leading/trailing, group with dividers/title/card, dense
- [x] `test/src/components/display/oi_key_value_test.dart`

**1C. OiOptimisticAction — Optimistic Update Utility**

- [x] Discovery: read `oi_snack_bar.dart` — OiOverlayHandle with dismiss(), OiSnackBar.show() returns handle, actionLabel+onAction for undo
- [x] Discovery: read `oi_undo_stack.dart` — OiUndoAction for undo/redo, different pattern from optimistic action
- [x] `lib/src/foundation/oi_optimistic_action.dart` — static utility class. execute() + cancelPending(). Context disposal guard.
- [x] Export in `obers_ui.dart`
- [x] TDD: 6 tests — apply immediate, snackbar appears, commit after duration, commit failure rollback, returns true on commit, cancelPending
- [x] `test/src/foundation/oi_optimistic_action_test.dart`

- [x] Verify: all 37 Phase 1 tests pass, dart analyze clean (info-only)

---

### Phase 2: OiDateRangePicker + OiGroupedList (HIGH, complex composites)

- **Goal**: Ship 2 complex composites with discovery phases. These are the highest-value widgets.

**2A. OiDateRangePicker — Dual-Calendar Range Selector**

- [ ] Discovery: read `oi_date_picker.dart` fully — rangeMode, _pendingRangeStart, range highlighting. Check if displayMonth can be externally controlled. If not, add displayMonth parameter to OiDatePicker.
- [ ] Discovery: read `oi_date_range_picker_field.dart` — reuse OiDateRangePreset. Add missing static presets (thisQuarter, lastQuarter, thisYear, lastYear, allTime) to existing class.
- [ ] Discovery: check hover-based range preview in OiDatePicker. If absent, add hoverDate parameter.
- [ ] `lib/src/components/inputs/oi_date_range_picker_field.dart` — add new OiDateRangePreset static getters (thisQuarter, lastQuarter, thisYear, lastYear, allTime)
- [ ] `lib/src/composites/input/oi_date_range_picker.dart` — StatefulWidget. Wraps 2 OiDatePicker instances. Presets panel (left on desktop, chips on mobile). Apply/Cancel footer. firstDate/lastDate (not min/max). Auto-swap if end < start. Right calendar >= left calendar month. Responsive: dual on expanded, single on compact. Keyboard nav.
- [ ] `lib/src/composites/input/oi_date_range_input.dart` — form field companion, opens picker in OiPopover. displayFormat callback. clearable.
- [ ] `lib/src/foundation/theme/component_themes/oi_date_range_picker_theme_data.dart`
- [ ] Register in `oi_component_themes.dart` + export both files in `obers_ui.dart`
- [ ] TDD: renders 2 calendars on expanded → single on compact → selecting start then end calls onApply → Cancel does not call onApply → preset populates dates → hides presets when showPresets false → disabled dates blocked → firstDate prevents earlier nav → hover highlights range → right calendar >= left month → keyboard arrows + Enter → initial dates highlighted → showTimePicker renders time inputs
- [ ] TDD (OiDateRangeInput): displays formatted range → shows error text → disabled prevents interaction → clearable shows clear button → opens picker on tap
- [ ] TDD (preset additions): thisQuarter/lastQuarter/thisYear/lastYear/allTime resolve correctly
- [ ] `test/src/composites/input/oi_date_range_picker_test.dart` + `test/src/composites/input/oi_date_range_input_test.dart`

**2B. OiGroupedList — Sectioned/Grouped Data List**

- [ ] Discovery: read `oi_virtual_list.dart` — understand API for potential composition
- [ ] Discovery: confirm SliverPersistentHeader available from widgets.dart for sticky headers (not Material)
- [ ] `lib/src/composites/data/oi_grouped_list.dart` — Generic OiGroupedList<T>. Companion types: OiEmptyGroupBehavior enum, OiGroupedListController (extends ChangeNotifier). groupBy function groups items. Sticky headers via SliverPersistentHeader(pinned: true). Collapsible groups. Settings persistence (settingsDriver/settingsKey/settingsNamespace). Custom headerBuilder. Separators. Loading indicator. Pull-to-refresh. Optional controller (create internal if not provided).
- [ ] `lib/src/foundation/theme/component_themes/oi_grouped_list_theme_data.dart`
- [ ] Register in `oi_component_themes.dart` + export in `obers_ui.dart`
- [ ] TDD: renders group headers from groupBy → items under correct headers → groupOrder controls ordering → collapsible toggle on header tap → initiallyCollapsed groups start collapsed → empty items shows emptyState → custom headerBuilder → separator between items → loading shows OiProgress → controller.scrollToGroup → emptyGroupBehavior.hide → semantic label → controller.collapseAll/expandAll
- [ ] `test/src/composites/data/oi_grouped_list_test.dart`

- [ ] Verify: `dart analyze && dart format . --set-exit-if-changed && flutter test test/src/composites/input/ test/src/composites/data/oi_grouped_list_test.dart`

---

### Phase 3: OiWeekStrip + OiIndexBar + OiActionBar + OiAccountSwitcher (MEDIUM, independent)

- **Goal**: 4 independent components. Can be built in any order or parallelized.

**3A. OiWeekStrip — Compact Horizontal Week Selector**

- [ ] `lib/src/components/navigation/oi_week_strip.dart` — StatefulWidget. 7-day horizontal row. Swipe (touch) / arrows (pointer) for week nav. Selected day highlighted. Today indicator. Event dot badges from eventCounts map. firstDayOfWeek. firstDate/lastDate (not min/max). showMonth with dual-month label on week boundaries. todayLabel jump button. Compact mode.
- [ ] `lib/src/foundation/theme/component_themes/oi_week_strip_theme_data.dart`
- [ ] Register + export
- [ ] TDD: renders 7 day cells → highlights selected date → tap calls onDateSelected → nav arrows change week → event dots for eventCounts → disabled dates not tappable → firstDayOfWeek=sunday starts on Sunday → showMonth displays month name → todayLabel shows jump button → firstDate disables previous nav → swipe left navigates next week → today indicator when not selected → week spanning months shows dual label
- [ ] `test/src/components/navigation/oi_week_strip_test.dart`

**3B. OiIndexBar — Alphabet/Index Sidebar**

- [ ] `lib/src/components/navigation/oi_index_bar.dart` — StatelessWidget. Companion: OiIndexBarSize enum. Factory: .alphabet(). Vertical label list. Tap + drag fire onLabelSelected. Drag deduplicates consecutive labels. activeLabel highlighted. availableLabels dims missing. showTooltip floating bubble on drag. hapticFeedback. Custom labels support.
- [ ] `lib/src/foundation/theme/component_themes/oi_index_bar_theme_data.dart`
- [ ] Register + export
- [ ] TDD: renders 26 letters + # → tap calls onLabelSelected → activeLabel highlights → unavailable labels dimmed → drag fires multiple callbacks → custom labels render → showTooltip on drag → excludes # when includeHash false → minimum touch target size
- [ ] `test/src/components/navigation/oi_index_bar_test.dart`

**3C. OiActionBar — Contextual Entity Action Toolbar**

- [ ] `lib/src/components/navigation/oi_action_bar.dart` — StatelessWidget. Companion: OiActionBarItem (@immutable), OiActionBarStyle enum. Primary actions as visible buttons. Overflow actions in "more" menu. Toggled/active state. Loading spinner. Confirm pattern (String? confirm — first tap shows message, second executes). Group separators. Leading/trailing widgets. showLabels responsive. Badge on actions.
- [ ] `lib/src/foundation/theme/component_themes/oi_action_bar_theme_data.dart`
- [ ] Register + export
- [ ] TDD: renders all action buttons → tap calls onTap → disabled no-op → overflow in more menu → toggled shows active state → loading shows spinner → confirm requires two taps → separator between groups → leading/trailing render → showLabels displays text → badge renders
- [ ] `test/src/components/navigation/oi_action_bar_test.dart`

**3D. OiAccountSwitcher — Workspace/Account Selector**

- [ ] `lib/src/components/navigation/oi_account_switcher.dart` — Generic OiAccountSwitcher<T>. StatefulWidget. Avatar trigger opens dropdown (OiPopover or overlay). Active account marked. Generic callbacks: labelOf, avatarOf, descriptionOf, colorOf, accountKey. Searchable. onAddAccount action. Compact (avatar only). maxVisible with scroll. Single account = no-op tap.
- [ ] `lib/src/foundation/theme/component_themes/oi_account_switcher_theme_data.dart`
- [ ] Register + export
- [ ] TDD: renders trigger with active account → compact shows only avatar → tap opens dropdown → selecting calls onSelect → active marked in dropdown → add account action → searchable filters → descriptionOf shows subtitle → single account no dropdown
- [ ] `test/src/components/navigation/oi_account_switcher_test.dart`

- [ ] Verify: `dart analyze && dart format . --set-exit-if-changed && flutter test test/src/components/navigation/oi_week_strip_test.dart test/src/components/navigation/oi_index_bar_test.dart test/src/components/navigation/oi_action_bar_test.dart test/src/components/navigation/oi_account_switcher_test.dart`

---

### Phase 4: OiSkeletonPreset (LOW)

- **Goal**: Skeleton loading presets. New class composing OiSkeletonLine/OiSkeletonBox/OiShimmer.

- [ ] Discovery: verify OiShimmer respects MediaQuery.disableAnimations for reduced-motion
- [ ] `lib/src/components/feedback/oi_skeleton_preset.dart` — StatelessWidget. Factory constructors: .text(lines, lastLineWidth), .avatar(size), .card(height, aspectRatio), .image(height, aspectRatio), .badge(width), .listTile(showAvatar, showTrailing), .tableRow(columns), .metric(). Static .list() factory for repeating. Composes OiSkeletonLine/OiSkeletonBox wrapped in OiSkeletonGroup. Proportional/responsive sizing. Reduced-motion: static placeholder.
- [ ] Export in `obers_ui.dart` (no theme data needed — uses OiSkeletonGroup/OiShimmer theming)
- [ ] TDD: text preset renders N lines → last line shorter → avatar circular → card rounded rect → listTile avatar + text lines → listTile without avatar → tableRow N columns → list factory repeats count times → image respects aspectRatio → badge small rect → metric value + label → reduced-motion static
- [ ] `test/src/components/feedback/oi_skeleton_preset_test.dart`

- [ ] Verify: `dart analyze && dart format . --set-exit-if-changed && flutter test test/src/components/feedback/oi_skeleton_preset_test.dart`

---

### Phase 5: Documentation + Final Verification

- **Goal**: Sync all documentation, run full suite, confirm done-when criteria.

- [ ] Update `AI_README.md` — add entries for all 10 widgets (tags, params, usage, anti-patterns, combine-with)
- [ ] Update `doc/` site pages if category pages exist for Feedback, Display, Navigation, Input, Data
- [ ] Run full test suite: `flutter test`
- [ ] Run analysis: `dart analyze`
- [ ] Run format check: `dart format . --set-exit-if-changed`
- [ ] Verify barrel exports: grep `obers_ui.dart` for all 10 new widget files
- [ ] Verify no Material/Cupertino imports in new files: `grep -r 'material.dart\|cupertino.dart' lib/src/components/feedback/oi_banner.dart lib/src/components/display/oi_key_value.dart lib/src/foundation/oi_optimistic_action.dart lib/src/composites/input/oi_date_range_picker.dart lib/src/composites/input/oi_date_range_input.dart lib/src/composites/data/oi_grouped_list.dart lib/src/components/navigation/oi_week_strip.dart lib/src/components/navigation/oi_index_bar.dart lib/src/components/navigation/oi_action_bar.dart lib/src/components/navigation/oi_account_switcher.dart lib/src/components/feedback/oi_skeleton_preset.dart`
- [ ] Verify all interactive widgets require `label` parameter
- [ ] Verify parameter naming uses `firstDate`/`lastDate` (not minDate/maxDate)

## Risks / Out of scope

- **Risks**:
  - OiDatePicker may need API changes (displayMonth, hoverDate params) to support composite — could affect existing tests
  - OiGroupedList sticky headers via SliverPersistentHeader requires CustomScrollView — may conflict with simple ListView usage patterns
  - OiOptimisticAction context disposal during undo window needs careful lifecycle management
- **Out of scope**:
  - Widgetbook entries (separate task)
  - Example app integration (separate task)
  - Golden tests for new widgets (separate task)
  - Internationalization of preset labels (use English, consumers override)
