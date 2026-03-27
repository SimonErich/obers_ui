# obers_ui Wishlist — Proposed New Widgets

> **Date:** 2026-03-26
> **Context:** Gap analysis between Qatery's custom uikit_obers layer (170+ widgets) and the obers_ui library catalog. These proposals are for generic, app-agnostic widgets that would prevent re-implementation across projects.

---

## Table of Contents

1. [OiBanner — Inline Alert Bar](#1-oibanner--inline-alert-bar)
2. [OiDateRangePicker — Dual-Calendar Range Selector](#2-oidaterangepicker--dual-calendar-range-selector)
3. [OiGroupedList — Sectioned/Grouped Data List](#3-oigroupedlist--sectionedgrouped-data-list)
4. [OiWeekStrip — Compact Horizontal Week Selector](#4-oiweekstrip--compact-horizontal-week-selector)
5. [OiIndexBar — Alphabet/Index Sidebar](#5-oiindexbar--alphabetindex-sidebar)
6. [OiActionBar — Contextual Entity Action Toolbar](#6-oiactionbar--contextual-entity-action-toolbar)
7. [OiAccountSwitcher — Workspace/Org/Account Selector](#7-oiaccountswitcher--workspaceorgaccount-selector)
8. [OiOptimisticAction — Optimistic Update Utility](#8-oioptimisticaction--optimistic-update-utility)
9. [OiSkeletonPreset — Skeleton Loading Shape Presets](#9-oiskeletonpreset--skeleton-loading-shape-presets)
10. [OiKeyValue — Lightweight Label-Value Display](#10-oikeyvalue--lightweight-label-value-display)

---

## 1. OiBanner — Inline Alert Bar

**Tags:** `banner`, `alert`, `inline`, `notification`, `callout`, `info`, `warning`, `error`, `success`
**Tier:** Component
**Category:** Feedback

### Problem

obers_ui provides `OiToast` (auto-dismissing overlay), `OiSnackBar` (brief overlay feedback), and `OiDialog` (modal). None of these solve the **inline, persistent, non-blocking notification** use case: a banner that lives inside the page flow, pushes content down, and stays visible until the user dismisses it or the condition resolves.

Every application needs this: cookie consent bars, subscription expiry warnings, maintenance notices, form validation summaries, feature announcements, connectivity status, environment indicators ("You are in staging"), and permission/access warnings.

### Behavior

- Renders inline within the widget tree (not in the overlay stack).
- Occupies full available width by default.
- Animates in/out with a height reveal (slide down) when shown/dismissed.
- Stays visible until explicitly dismissed or until `visible` becomes `false`.
- Supports stacking: multiple banners stack vertically in DOM order.
- On compact breakpoints, icon is hidden if `compact` mode is active to save space.
- Screen readers announce the banner on first appearance via a live region.

### API

```dart
/// Inline persistent notification bar.
///
/// Use for messages that should remain visible within the page flow
/// until the user or the system dismisses them. For transient feedback
/// use [OiToast] or [OiSnackBar] instead.
class OiBanner extends StatelessWidget {

  /// Primary factory constructors — one per severity level.
  const OiBanner.info({
    required this.message,
    this.title,
    this.icon,
    this.action,
    this.secondaryAction,
    this.onDismiss,
    this.dismissible = true,
    this.compact = false,
    this.semanticLabel,
    this.border = true,
    super.key,
  }) : level = OiBannerLevel.info;

  const OiBanner.success({...}) : level = OiBannerLevel.success;
  const OiBanner.warning({...}) : level = OiBannerLevel.warning;
  const OiBanner.error({...})   : level = OiBannerLevel.error;
  const OiBanner.neutral({...}) : level = OiBannerLevel.neutral;

  /// The alert severity. Controls background tint, icon, and border color.
  final OiBannerLevel level;

  /// Primary message text. Always visible.
  final String message;

  /// Optional bold title above the message.
  final String? title;

  /// Leading icon override. Defaults to a level-appropriate icon
  /// (info-circle, check-circle, alert-triangle, x-circle).
  final IconData? icon;

  /// Primary action widget — typically an [OiButton.ghost] or [OiButton.outline].
  final Widget? action;

  /// Secondary action widget — typically an [OiButton.ghost].
  final Widget? secondaryAction;

  /// Called when the dismiss button is tapped. If null and [dismissible]
  /// is true, the banner removes itself from the tree with an animation.
  final VoidCallback? onDismiss;

  /// Whether the close/dismiss icon button is shown.
  final bool dismissible;

  /// Compact mode: hides the icon and reduces vertical padding.
  /// Automatically activated on [OiBreakpoint.compact] if not set.
  final bool compact;

  /// Whether to show a left accent border in the level color.
  final bool border;

  /// Accessibility label. Defaults to "$level: $message".
  final String? semanticLabel;
}
```

### Companion Types

```dart
enum OiBannerLevel { info, success, warning, error, neutral }
```

### Theme Integration

```dart
// In OiComponentThemes:
final OiBannerThemeData? banner;

class OiBannerThemeData {
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? iconSize;
  final Duration? animationDuration;
  final Curve? animationCurve;
  // Per-level color overrides (otherwise derived from OiColorScheme).
}
```

### Default Colors (derived from OiColorScheme)

| Level | Background | Border Accent | Icon | Text |
|-------|-----------|---------------|------|------|
| info | `colors.info.muted` | `colors.info.base` | `OiIcons.infoCircle` | `colors.text` |
| success | `colors.success.muted` | `colors.success.base` | `OiIcons.checkCircle` | `colors.text` |
| warning | `colors.warning.muted` | `colors.warning.base` | `OiIcons.alertTriangle` | `colors.text` |
| error | `colors.error.muted` | `colors.error.base` | `OiIcons.xCircle` | `colors.text` |
| neutral | `colors.surfaceSubtle` | `colors.border` | none | `colors.text` |

### Use When
Persistent inline messages: validation summaries, environment indicators, subscription warnings, maintenance notices, feature announcements, access warnings.

### Avoid When
Transient feedback after an action — use `OiToast` or `OiSnackBar`. Blocking decisions — use `OiDialog`.

### Combine With
`OiPage` (top of page), `OiForm` (above form for validation summary), `OiCard` (inside card for contextual warnings), `OiAppShell` (below header for global notices).

### Tests

```dart
group('OiBanner', () {
  testWidgets('renders message text', (tester) async {
    await tester.pumpWidget(wrap(
      OiBanner.info(message: 'Your trial expires in 3 days'),
    ));
    spot<OiLabel>().withText('Your trial expires in 3 days').existsOnce();
  });

  testWidgets('renders title when provided', (tester) async {
    await tester.pumpWidget(wrap(
      OiBanner.warning(title: 'Heads up', message: 'Maintenance tonight'),
    ));
    spot<OiLabel>().withText('Heads up').existsOnce();
    spot<OiLabel>().withText('Maintenance tonight').existsOnce();
  });

  testWidgets('shows dismiss button when dismissible is true', (tester) async {
    await tester.pumpWidget(wrap(
      OiBanner.info(message: 'Notice', dismissible: true),
    ));
    spot<OiIconButton>().existsOnce();
  });

  testWidgets('hides dismiss button when dismissible is false', (tester) async {
    await tester.pumpWidget(wrap(
      OiBanner.error(message: 'Critical', dismissible: false),
    ));
    spot<OiIconButton>().doesNotExist();
  });

  testWidgets('calls onDismiss when dismiss button tapped', (tester) async {
    var dismissed = false;
    await tester.pumpWidget(wrap(
      OiBanner.info(message: 'Notice', onDismiss: () => dismissed = true),
    ));
    await spot<OiIconButton>().existsOnce().tap();
    expect(dismissed, isTrue);
  });

  testWidgets('animates out after dismiss', (tester) async {
    await tester.pumpWidget(wrap(
      OiBanner.info(message: 'Bye', dismissible: true),
    ));
    await spot<OiIconButton>().existsOnce().tap();
    await tester.pumpAndSettle();
    spot<OiBanner>().doesNotExist();
  });

  testWidgets('renders action widget', (tester) async {
    await tester.pumpWidget(wrap(
      OiBanner.warning(
        message: 'Upgrade required',
        action: OiButton.outline(label: 'Upgrade', onTap: () {}),
      ),
    ));
    spot<OiButton>().withText('Upgrade').existsOnce();
  });

  testWidgets('renders level-appropriate default icon', (tester) async {
    await tester.pumpWidget(wrap(OiBanner.error(message: 'Error')));
    spot<OiIcon>().existsOnce(); // xCircle icon
  });

  testWidgets('uses custom icon when provided', (tester) async {
    await tester.pumpWidget(wrap(
      OiBanner.info(message: 'Custom', icon: OiIcons.star),
    ));
    spot<OiIcon>().existsOnce();
  });

  testWidgets('compact mode hides icon', (tester) async {
    await tester.pumpWidget(wrap(
      OiBanner.info(message: 'Compact', compact: true),
    ));
    spot<OiIcon>().doesNotExist();
  });

  testWidgets('has semantic live region for screen readers', (tester) async {
    await tester.pumpWidget(wrap(
      OiBanner.warning(message: 'Attention'),
    ));
    final semantics = tester.getSemantics(find.byType(OiBanner));
    expect(semantics.hasFlag(SemanticsFlag.isLiveRegion), isTrue);
  });

  testWidgets('renders all five levels without errors', (tester) async {
    for (final factory in [
      OiBanner.info, OiBanner.success, OiBanner.warning,
      OiBanner.error, OiBanner.neutral,
    ]) {
      await tester.pumpWidget(wrap(factory(message: 'test')));
      spot<OiBanner>().existsOnce();
    }
  });

  testWidgets('shows left accent border by default', (tester) async {
    await tester.pumpWidget(wrap(OiBanner.error(message: 'err')));
    // Verify the OiSurface has a left border matching error color.
    final surface = spot<OiSurface>().existsOnce();
    // Implementation-specific: check border is present.
  });

  testWidgets('hides left accent border when border is false', (tester) async {
    await tester.pumpWidget(wrap(
      OiBanner.error(message: 'err', border: false),
    ));
    // Verify no accent border.
  });

  testWidgets('multiple banners stack vertically', (tester) async {
    await tester.pumpWidget(wrap(
      OiColumn(breakpoint: OiBreakpoint.expanded, children: [
        OiBanner.info(message: 'First'),
        OiBanner.warning(message: 'Second'),
      ]),
    ));
    spot<OiBanner>().existsAtLeastNTimes(2);
  });
});
```

---

## 2. OiDateRangePicker — Dual-Calendar Range Selector

**Tags:** `date`, `range`, `picker`, `calendar`, `filter`, `analytics`, `report`, `period`
**Tier:** Composite
**Category:** Input

### Problem

obers_ui provides `OiDatePicker` (single date calendar) and `OiDateInput` (single date form field). There is no way to select a **date range** — a start and end date — which is the primary date interaction in analytics dashboards, report builders, admin filters, booking systems, and scheduling interfaces.

This is consistently one of the most complex widgets apps build from scratch because it involves dual calendars, preset management, relative date logic, and compact/full responsive layouts.

### Behavior

- Two side-by-side month calendars (desktop) or stacked calendars (mobile).
- Click to set start date, click again to set end date. Hover highlights the prospective range.
- Quick-select presets panel on the left (desktop) or as chips above (mobile).
- "Custom" preset activates the calendar for manual selection.
- Apply/Cancel buttons in a footer. Changes are not committed until Apply.
- Can be used as a standalone widget or shown inside `OiDialog` / `OiSheet` / `OiPopover`.
- Month navigation: left/right arrows on each calendar independently.
- Right calendar always shows a month >= left calendar month.
- Keyboard: arrow keys navigate days, Enter selects, Tab moves between calendars.

### API

```dart
/// Dual-calendar date range selector with quick-select presets.
///
/// Use inside an [OiPopover], [OiDialog], or inline in a page.
/// For a form field that opens this picker, use [OiDateRangeInput].
class OiDateRangePicker extends StatelessWidget {

  const OiDateRangePicker({
    required this.label,
    this.startDate,
    this.endDate,
    this.onApply,
    this.onCancel,
    this.presets,
    this.minDate,
    this.maxDate,
    this.disabledDates,
    this.disabledDaysOfWeek,
    this.locale,
    this.firstDayOfWeek,
    this.singleCalendar = false,
    this.showPresets = true,
    this.showTimePicker = false,
    this.applyLabel,
    this.cancelLabel,
    this.semanticLabel,
    super.key,
  });

  /// Accessibility label for the picker region.
  final String label;

  /// Currently selected start date (inclusive).
  final DateTime? startDate;

  /// Currently selected end date (inclusive).
  final DateTime? endDate;

  /// Called when the user taps Apply with the selected range.
  final void Function(DateTime start, DateTime end)? onApply;

  /// Called when the user taps Cancel.
  final VoidCallback? onCancel;

  /// Quick-select presets shown alongside the calendars.
  /// Defaults to a standard set if null.
  final List<OiDateRangePreset>? presets;

  /// Earliest selectable date.
  final DateTime? minDate;

  /// Latest selectable date.
  final DateTime? maxDate;

  /// Specific dates that cannot be selected.
  final Set<DateTime>? disabledDates;

  /// Days of the week that cannot be selected (1=Monday, 7=Sunday).
  final Set<int>? disabledDaysOfWeek;

  /// Locale for month/day names. Defaults to app locale.
  final Locale? locale;

  /// First day of the week (1=Monday, 7=Sunday). Defaults to locale default.
  final int? firstDayOfWeek;

  /// Show only one calendar instead of two side-by-side.
  /// Automatically true on [OiBreakpoint.compact].
  final bool singleCalendar;

  /// Whether to show the presets panel.
  final bool showPresets;

  /// Whether to show time pickers below each calendar for
  /// start time and end time selection.
  final bool showTimePicker;

  /// Override label for the Apply button.
  final String? applyLabel;

  /// Override label for the Cancel button.
  final String? cancelLabel;

  final String? semanticLabel;
}
```

### Companion Types

```dart
/// Quick-select preset for date ranges.
class OiDateRangePreset {
  const OiDateRangePreset({
    required this.label,
    required this.resolve,
    this.icon,
  });

  /// Display label (e.g., "Last 7 days").
  final String label;

  /// Resolves to a concrete (start, end) pair relative to now.
  final (DateTime, DateTime) Function() resolve;

  /// Optional leading icon.
  final IconData? icon;

  // Built-in presets:
  static OiDateRangePreset today();
  static OiDateRangePreset yesterday();
  static OiDateRangePreset last7Days();
  static OiDateRangePreset last14Days();
  static OiDateRangePreset last30Days();
  static OiDateRangePreset thisWeek();
  static OiDateRangePreset lastWeek();
  static OiDateRangePreset thisMonth();
  static OiDateRangePreset lastMonth();
  static OiDateRangePreset thisQuarter();
  static OiDateRangePreset lastQuarter();
  static OiDateRangePreset thisYear();
  static OiDateRangePreset lastYear();
  static OiDateRangePreset allTime();

  /// The standard set used when [OiDateRangePicker.presets] is null.
  static List<OiDateRangePreset> get defaults => [
    today(), yesterday(), last7Days(), last30Days(),
    thisMonth(), lastMonth(), thisQuarter(), thisYear(),
  ];
}
```

### Form Field Companion

```dart
/// Date range input field that opens [OiDateRangePicker] in a popover.
///
/// Drop-in for forms — follows the same API pattern as [OiDateInput].
class OiDateRangeInput extends StatelessWidget {
  const OiDateRangeInput({
    required this.label,
    this.startDate,
    this.endDate,
    this.onChanged,
    this.presets,
    this.minDate,
    this.maxDate,
    this.hint,
    this.error,
    this.enabled = true,
    this.required = false,
    this.clearable = true,
    this.displayFormat,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final DateTime? startDate;
  final DateTime? endDate;
  final void Function(DateTime? start, DateTime? end)? onChanged;
  final List<OiDateRangePreset>? presets;
  final DateTime? minDate;
  final DateTime? maxDate;
  final String? hint;
  final String? error;
  final bool enabled;
  final bool required;
  final bool clearable;
  /// Custom format for displaying the range. Defaults to "dd MMM yyyy — dd MMM yyyy".
  final String Function(DateTime start, DateTime end)? displayFormat;
  final String? semanticLabel;
}
```

### Use When
Analytics date filters, report periods, booking windows, event planning, billing cycles, audit log filtering, availability ranges.

### Avoid When
Single date selection — use `OiDatePicker` / `OiDateInput`. Time-only selection — use `OiTimePicker`.

### Combine With
`OiFilterBar` (as a filter), `OiPopover` (inline trigger), `OiForm` (via `OiDateRangeInput`), `OiTable` (header filter).

### Tests

```dart
group('OiDateRangePicker', () {
  testWidgets('renders two calendars on expanded breakpoint', (tester) async {
    await tester.pumpWidget(wrapWithBreakpoint(
      OiBreakpoint.expanded,
      OiDateRangePicker(label: 'Range'),
    ));
    // Two month calendar grids should be visible.
    spot<OiDatePicker>().existsAtLeastNTimes(2);
  });

  testWidgets('renders single calendar on compact breakpoint', (tester) async {
    await tester.pumpWidget(wrapWithBreakpoint(
      OiBreakpoint.compact,
      OiDateRangePicker(label: 'Range'),
    ));
    spot<OiDatePicker>().existsOnce();
  });

  testWidgets('selecting start then end date calls onApply', (tester) async {
    DateTime? start, end;
    await tester.pumpWidget(wrap(
      OiDateRangePicker(
        label: 'Range',
        onApply: (s, e) { start = s; end = e; },
      ),
    ));
    // Tap day 10, then day 20, then Apply.
    await tester.tap(find.text('10'));
    await tester.pump();
    await tester.tap(find.text('20'));
    await tester.pump();
    await tester.tap(find.text('Apply'));
    expect(start?.day, 10);
    expect(end?.day, 20);
  });

  testWidgets('Cancel does not call onApply', (tester) async {
    var applied = false;
    await tester.pumpWidget(wrap(
      OiDateRangePicker(
        label: 'Range',
        onApply: (_, __) => applied = true,
        onCancel: () {},
      ),
    ));
    await tester.tap(find.text('10'));
    await tester.pump();
    await tester.tap(find.text('Cancel'));
    expect(applied, isFalse);
  });

  testWidgets('preset selection populates both dates', (tester) async {
    DateTime? start, end;
    await tester.pumpWidget(wrap(
      OiDateRangePicker(
        label: 'Range',
        onApply: (s, e) { start = s; end = e; },
        presets: [OiDateRangePreset.last7Days()],
      ),
    ));
    await tester.tap(find.text('Last 7 days'));
    await tester.pump();
    await tester.tap(find.text('Apply'));
    expect(end!.difference(start!).inDays, 6);
  });

  testWidgets('hides presets when showPresets is false', (tester) async {
    await tester.pumpWidget(wrap(
      OiDateRangePicker(label: 'Range', showPresets: false),
    ));
    expect(find.text('Last 7 days'), findsNothing);
  });

  testWidgets('disabled dates cannot be selected', (tester) async {
    final disabled = DateTime(2026, 3, 15);
    await tester.pumpWidget(wrap(
      OiDateRangePicker(label: 'Range', disabledDates: {disabled}),
    ));
    await tester.tap(find.text('15'));
    await tester.pump();
    // Day 15 should not become selected start.
  });

  testWidgets('minDate prevents earlier month navigation', (tester) async {
    final min = DateTime(2026, 3, 1);
    await tester.pumpWidget(wrap(
      OiDateRangePicker(label: 'Range', minDate: min),
    ));
    // Left arrow on the left calendar should be disabled.
  });

  testWidgets('hover highlights prospective range', (tester) async {
    await tester.pumpWidget(wrap(
      OiDateRangePicker(label: 'Range'),
    ));
    await tester.tap(find.text('10')); // Select start.
    await tester.pump();
    // Hover over day 15 — days 11-15 should have range highlight.
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.moveTo(tester.getCenter(find.text('15')));
    await tester.pump();
    // Visual verification: range cells have muted primary background.
  });

  testWidgets('right calendar always shows >= left calendar month',
      (tester) async {
    await tester.pumpWidget(wrap(
      OiDateRangePicker(label: 'Range'),
    ));
    // Navigate left calendar forward — right should follow if needed.
  });

  testWidgets('keyboard navigation: arrows move focus, Enter selects',
      (tester) async {
    await tester.pumpWidget(wrap(
      OiDateRangePicker(label: 'Range'),
    ));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    // First focused day should become selected.
  });

  testWidgets('initial start/end dates are highlighted', (tester) async {
    final start = DateTime(2026, 3, 10);
    final end = DateTime(2026, 3, 20);
    await tester.pumpWidget(wrap(
      OiDateRangePicker(label: 'Range', startDate: start, endDate: end),
    ));
    // Days 10-20 should have range highlighting.
  });

  testWidgets('showTimePicker renders time inputs below calendars',
      (tester) async {
    await tester.pumpWidget(wrap(
      OiDateRangePicker(label: 'Range', showTimePicker: true),
    ));
    spot<OiTimeInput>().existsAtLeastNTimes(2);
  });
});

group('OiDateRangeInput', () {
  testWidgets('displays formatted range', (tester) async {
    await tester.pumpWidget(wrap(
      OiDateRangeInput(
        label: 'Period',
        startDate: DateTime(2026, 3, 1),
        endDate: DateTime(2026, 3, 31),
      ),
    ));
    spot<OiLabel>().withText(contains('01 Mar 2026')).existsOnce();
  });

  testWidgets('shows error text', (tester) async {
    await tester.pumpWidget(wrap(
      OiDateRangeInput(label: 'Period', error: 'Required'),
    ));
    spot<OiLabel>().withText('Required').existsOnce();
  });

  testWidgets('disabled state prevents interaction', (tester) async {
    await tester.pumpWidget(wrap(
      OiDateRangeInput(label: 'Period', enabled: false),
    ));
    await tester.tap(find.byType(OiDateRangeInput));
    await tester.pump();
    spot<OiDateRangePicker>().doesNotExist();
  });

  testWidgets('clearable shows clear button when range is set',
      (tester) async {
    await tester.pumpWidget(wrap(
      OiDateRangeInput(
        label: 'Period',
        startDate: DateTime(2026, 3, 1),
        endDate: DateTime(2026, 3, 31),
        clearable: true,
        onChanged: (_, __) {},
      ),
    ));
    spot<OiIconButton>().existsOnce(); // Clear button.
  });
});

group('OiDateRangePreset', () {
  test('today() resolves to same day for start and end', () {
    final (start, end) = OiDateRangePreset.today().resolve();
    expect(start.day, end.day);
    expect(start.month, end.month);
  });

  test('last7Days() spans exactly 7 days', () {
    final (start, end) = OiDateRangePreset.last7Days().resolve();
    expect(end.difference(start).inDays, 6);
  });

  test('thisMonth() starts on day 1', () {
    final (start, _) = OiDateRangePreset.thisMonth().resolve();
    expect(start.day, 1);
  });

  test('lastMonth() ends on last day of previous month', () {
    final (_, end) = OiDateRangePreset.lastMonth().resolve();
    final now = DateTime.now();
    final firstOfThisMonth = DateTime(now.year, now.month, 1);
    final lastOfPrev = firstOfThisMonth.subtract(const Duration(days: 1));
    expect(end.day, lastOfPrev.day);
  });

  test('defaults list contains expected preset count', () {
    expect(OiDateRangePreset.defaults.length, greaterThanOrEqualTo(6));
  });
});
```

---

## 3. OiGroupedList — Sectioned/Grouped Data List

**Tags:** `list`, `grouped`, `sectioned`, `headers`, `collapsible`, `alphabetical`, `categorized`
**Tier:** Composite
**Category:** Data

### Problem

`OiListView` and `OiVirtualList` render flat lists. `OiAccordion` provides collapse/expand but requires static sections defined upfront. There is no widget that takes a flat data list, groups it dynamically by a key function, renders section headers, and supports collapsible groups — the most common list pattern in contacts (by letter), emails (by date), settings (by category), events (by day), and products (by category).

### Behavior

- Accepts a flat `List<T>` and a `groupBy` function that returns a group key.
- Renders items organized under section headers.
- Headers are sticky by default (float at top while scrolling through their section).
- Groups can be individually collapsed/expanded.
- Empty groups are hidden by default.
- Supports virtual scrolling for large datasets.
- Group order can be controlled via a `groupOrder` comparator, or defaults to the natural order items appear.
- Integrates with `OiInfiniteScroll` for paginated loading.

### API

```dart
/// Data list with automatic grouping, sticky headers, and collapsible sections.
///
/// Groups a flat item list by a key function and renders each group under
/// a section header. Use for contacts, events, categorized products, etc.
class OiGroupedList<T> extends StatelessWidget {

  const OiGroupedList({
    required this.items,
    required this.itemBuilder,
    required this.groupBy,
    required this.label,
    this.headerBuilder,
    this.groupOrder,
    this.itemKey,
    this.stickyHeaders = true,
    this.collapsible = false,
    this.initiallyCollapsed,
    this.emptyGroupBehavior = OiEmptyGroupBehavior.hide,
    this.emptyState,
    this.separator,
    this.groupSeparator,
    this.onRefresh,
    this.onLoadMore,
    this.moreAvailable = false,
    this.loading = false,
    this.padding,
    this.physics,
    this.controller,
    this.semanticLabel,
    this.settingsDriver,
    this.settingsKey,
    super.key,
  });

  /// Flat list of all items. Grouped automatically via [groupBy].
  final List<T> items;

  /// Builds the widget for each item.
  final Widget Function(BuildContext context, T item, int indexInGroup) itemBuilder;

  /// Returns the group key for an item. Items with the same key
  /// are placed in the same section.
  final String Function(T item) groupBy;

  /// Accessibility label for the list.
  final String label;

  /// Builds the section header widget. Receives the group key and
  /// the list of items in that group. Defaults to [OiLabel.h4(groupKey)].
  final Widget Function(
    BuildContext context,
    String groupKey,
    List<T> groupItems,
    bool isCollapsed,
  )? headerBuilder;

  /// Controls group ordering. Receives two group keys.
  /// Defaults to the order groups first appear in [items].
  final int Function(String a, String b)? groupOrder;

  /// Unique key per item. Required for virtual scrolling and animations.
  final Object Function(T item)? itemKey;

  /// Whether section headers stick to the top during scroll.
  final bool stickyHeaders;

  /// Whether groups can be collapsed by tapping the header.
  final bool collapsible;

  /// Set of group keys that start collapsed. Null = all expanded.
  final Set<String>? initiallyCollapsed;

  /// How to handle groups with zero items.
  final OiEmptyGroupBehavior emptyGroupBehavior;

  /// Widget shown when [items] is empty.
  final Widget? emptyState;

  /// Widget rendered between items within a group.
  final Widget? separator;

  /// Widget rendered between groups (below one header, above the next).
  final Widget? groupSeparator;

  /// Pull-to-refresh callback.
  final Future<void> Function()? onRefresh;

  /// Infinite scroll: called when reaching the bottom.
  final VoidCallback? onLoadMore;

  /// Whether more items are available for loading.
  final bool moreAvailable;

  /// Shows a loading indicator at the bottom.
  final bool loading;

  /// List padding.
  final EdgeInsetsGeometry? padding;

  /// Scroll physics override.
  final ScrollPhysics? physics;

  /// Scroll controller.
  final ScrollController? controller;

  final String? semanticLabel;

  // Persistence for collapsed state.
  final OiSettingsDriver? settingsDriver;
  final String? settingsKey;
}
```

### Companion Types

```dart
enum OiEmptyGroupBehavior {
  /// Don't render the group at all.
  hide,
  /// Show the header with an empty state message.
  showHeader,
  /// Show header and a custom empty state widget.
  showEmpty,
}
```

### Programmatic Control

```dart
/// Controller for [OiGroupedList] — expand, collapse, scroll to group.
class OiGroupedListController {
  /// Expand a specific group.
  void expandGroup(String groupKey);

  /// Collapse a specific group.
  void collapseGroup(String groupKey);

  /// Toggle a group's collapsed state.
  void toggleGroup(String groupKey);

  /// Expand all groups.
  void expandAll();

  /// Collapse all groups.
  void collapseAll();

  /// Scroll to bring a group header into view.
  Future<void> scrollToGroup(String groupKey);

  /// Whether a group is currently collapsed.
  bool isCollapsed(String groupKey);

  /// Current set of collapsed group keys (read-only).
  Set<String> get collapsedGroups;
}
```

### Use When
Contacts by letter, events by date, products by category, settings by section, files by folder, messages by date, any alphabetically or categorically organized data.

### Avoid When
Flat lists without grouping — use `OiVirtualList` or `OiListView`. Accordion FAQ — use `OiAccordion`. Tabular data — use `OiTable` with `groupBy`.

### Combine With
`OiIndexBar` (alphabet sidebar), `OiTextInput.search()` (filter), `OiRefreshIndicator`, `OiEmptyState`.

### Tests

```dart
group('OiGroupedList', () {
  final contacts = [
    Contact('Alice', 'A'), Contact('Amy', 'A'), Contact('Bob', 'B'),
    Contact('Charlie', 'C'), Contact('Carol', 'C'),
  ];

  testWidgets('renders group headers', (tester) async {
    await tester.pumpWidget(wrap(
      OiGroupedList<Contact>(
        items: contacts,
        itemBuilder: (_, c, __) => OiListTile(title: c.name),
        groupBy: (c) => c.letter,
        label: 'Contacts',
      ),
    ));
    spot<OiLabel>().withText('A').existsOnce();
    spot<OiLabel>().withText('B').existsOnce();
    spot<OiLabel>().withText('C').existsOnce();
  });

  testWidgets('renders items under correct headers', (tester) async {
    await tester.pumpWidget(wrap(
      OiGroupedList<Contact>(
        items: contacts,
        itemBuilder: (_, c, __) => OiListTile(title: c.name),
        groupBy: (c) => c.letter,
        label: 'Contacts',
      ),
    ));
    spot<OiListTile>().withText('Alice').existsOnce();
    spot<OiListTile>().withText('Bob').existsOnce();
  });

  testWidgets('groupOrder controls section ordering', (tester) async {
    await tester.pumpWidget(wrap(
      OiGroupedList<Contact>(
        items: contacts,
        itemBuilder: (_, c, __) => OiListTile(title: c.name),
        groupBy: (c) => c.letter,
        groupOrder: (a, b) => b.compareTo(a), // Reverse: C, B, A.
        label: 'Contacts',
      ),
    ));
    final labels = find.byType(OiLabel);
    // First header should be 'C', not 'A'.
  });

  testWidgets('collapsible groups toggle on header tap', (tester) async {
    await tester.pumpWidget(wrap(
      OiGroupedList<Contact>(
        items: contacts,
        itemBuilder: (_, c, __) => OiListTile(title: c.name),
        groupBy: (c) => c.letter,
        collapsible: true,
        label: 'Contacts',
      ),
    ));
    // All items visible initially.
    spot<OiListTile>().withText('Alice').existsOnce();
    // Tap header 'A' to collapse.
    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();
    // Alice and Amy should be hidden.
    spot<OiListTile>().withText('Alice').doesNotExist();
    spot<OiListTile>().withText('Amy').doesNotExist();
    // Bob still visible.
    spot<OiListTile>().withText('Bob').existsOnce();
  });

  testWidgets('initiallyCollapsed groups start collapsed', (tester) async {
    await tester.pumpWidget(wrap(
      OiGroupedList<Contact>(
        items: contacts,
        itemBuilder: (_, c, __) => OiListTile(title: c.name),
        groupBy: (c) => c.letter,
        collapsible: true,
        initiallyCollapsed: {'B'},
        label: 'Contacts',
      ),
    ));
    spot<OiListTile>().withText('Alice').existsOnce();
    spot<OiListTile>().withText('Bob').doesNotExist();
  });

  testWidgets('empty items shows emptyState', (tester) async {
    await tester.pumpWidget(wrap(
      OiGroupedList<Contact>(
        items: [],
        itemBuilder: (_, c, __) => OiListTile(title: c.name),
        groupBy: (c) => c.letter,
        label: 'Contacts',
        emptyState: OiEmptyState(title: 'No contacts'),
      ),
    ));
    spot<OiEmptyState>().existsOnce();
  });

  testWidgets('custom headerBuilder renders custom headers', (tester) async {
    await tester.pumpWidget(wrap(
      OiGroupedList<Contact>(
        items: contacts,
        itemBuilder: (_, c, __) => OiListTile(title: c.name),
        groupBy: (c) => c.letter,
        label: 'Contacts',
        headerBuilder: (_, key, items, __) =>
            OiLabel.h3('$key (${items.length})'),
      ),
    ));
    spot<OiLabel>().withText('A (2)').existsOnce();
    spot<OiLabel>().withText('C (2)').existsOnce();
  });

  testWidgets('separator renders between items within a group',
      (tester) async {
    await tester.pumpWidget(wrap(
      OiGroupedList<Contact>(
        items: contacts,
        itemBuilder: (_, c, __) => OiListTile(title: c.name),
        groupBy: (c) => c.letter,
        label: 'Contacts',
        separator: OiDivider(),
      ),
    ));
    // Group A has 2 items -> 1 divider. Group B has 1 -> 0. Group C has 2 -> 1.
    spot<OiDivider>().existsAtLeastNTimes(2);
  });

  testWidgets('loading shows progress indicator at bottom', (tester) async {
    await tester.pumpWidget(wrap(
      OiGroupedList<Contact>(
        items: contacts,
        itemBuilder: (_, c, __) => OiListTile(title: c.name),
        groupBy: (c) => c.letter,
        label: 'Contacts',
        loading: true,
      ),
    ));
    spot<OiProgress>().existsOnce();
  });

  testWidgets('controller.scrollToGroup scrolls to header', (tester) async {
    final ctrl = OiGroupedListController();
    final manyContacts = List.generate(200, (i) => Contact('Name$i', '${String.fromCharCode(65 + (i % 26))}'));
    await tester.pumpWidget(wrap(
      OiGroupedList<Contact>(
        items: manyContacts,
        itemBuilder: (_, c, __) => OiListTile(title: c.name),
        groupBy: (c) => c.letter,
        controller: ScrollController(),
        label: 'Contacts',
      ),
    ));
    await ctrl.scrollToGroup('Z');
    await tester.pumpAndSettle();
    // Header 'Z' should be visible.
  });

  testWidgets('emptyGroupBehavior.hide hides empty groups', (tester) async {
    // Group D has no items.
    await tester.pumpWidget(wrap(
      OiGroupedList<Contact>(
        items: contacts, // Only A, B, C groups.
        itemBuilder: (_, c, __) => OiListTile(title: c.name),
        groupBy: (c) => c.letter,
        label: 'Contacts',
      ),
    ));
    expect(find.text('D'), findsNothing);
  });

  testWidgets('has semantic label for screen readers', (tester) async {
    await tester.pumpWidget(wrap(
      OiGroupedList<Contact>(
        items: contacts,
        itemBuilder: (_, c, __) => OiListTile(title: c.name),
        groupBy: (c) => c.letter,
        label: 'Contact list',
        semanticLabel: 'Contact list grouped by letter',
      ),
    ));
    final semantics = tester.getSemantics(find.byType(OiGroupedList<Contact>));
    expect(semantics.label, contains('Contact list'));
  });
});
```

---

## 4. OiWeekStrip — Compact Horizontal Week Selector

**Tags:** `calendar`, `week`, `strip`, `date`, `selector`, `compact`, `schedule`, `horizontal`
**Tier:** Component
**Category:** Navigation

### Problem

`OiCalendar` is a full-featured day/week/month calendar — too heavy for inline use. `OiDatePicker` is a modal picker. Neither provides a **compact, always-visible, horizontal 7-day strip** that apps use for quick date navigation in scheduling UIs, meal planners, fitness trackers, booking systems, daily planners, and any date-oriented interface.

### Behavior

- Renders exactly 7 day cells in a horizontal row for the current week.
- Each cell shows the day-of-week abbreviation (Mon, Tue...) and the day number.
- The selected day is visually highlighted with the primary color.
- "Today" has a distinct indicator (dot or ring) regardless of selection.
- Optional event dot badges on days that have content.
- Swipe left/right (touch) or arrow buttons (pointer) to navigate between weeks.
- Tapping a day fires `onDateSelected`.
- Configurable first day of week (Monday or Sunday).

### API

```dart
/// Compact horizontal 7-day week selector.
///
/// Always-visible inline date picker for schedule views,
/// daily planners, and date-oriented interfaces.
class OiWeekStrip extends StatelessWidget {

  const OiWeekStrip({
    required this.selectedDate,
    required this.onDateSelected,
    required this.label,
    this.eventCounts,
    this.eventDotColor,
    this.firstDayOfWeek = DateTime.monday,
    this.minDate,
    this.maxDate,
    this.disabledDates,
    this.disabledDaysOfWeek,
    this.showNavigation = true,
    this.showMonth = true,
    this.showYear = false,
    this.todayLabel,
    this.locale,
    this.compact = false,
    this.semanticLabel,
    super.key,
  });

  /// The currently selected date.
  final DateTime selectedDate;

  /// Called when a day is tapped.
  final ValueChanged<DateTime> onDateSelected;

  /// Accessibility label.
  final String label;

  /// Map of date -> event count. Days with count > 0 show a dot indicator.
  /// Only dates within the visible week are checked.
  final Map<DateTime, int>? eventCounts;

  /// Color of event dot badges. Defaults to `colors.primary.base`.
  final Color? eventDotColor;

  /// First day of the week. Defaults to Monday.
  final int firstDayOfWeek;

  /// Earliest navigable date. Hides/disables the "previous" arrow.
  final DateTime? minDate;

  /// Latest navigable date. Hides/disables the "next" arrow.
  final DateTime? maxDate;

  /// Specific dates that cannot be selected (shown as muted).
  final Set<DateTime>? disabledDates;

  /// Days of the week that cannot be selected (1=Mon, 7=Sun).
  final Set<int>? disabledDaysOfWeek;

  /// Show previous/next week navigation arrows.
  final bool showNavigation;

  /// Show the current month name above/beside the strip.
  final bool showMonth;

  /// Show the year alongside the month.
  final bool showYear;

  /// Optional "Today" button label. When provided, a button appears
  /// to jump back to the current date's week.
  final String? todayLabel;

  /// Locale for day-of-week abbreviations.
  final Locale? locale;

  /// Smaller day cells with less padding.
  final bool compact;

  final String? semanticLabel;
}
```

### Use When
Daily planners, meal prep apps, fitness trackers, booking/reservation UIs, scheduling interfaces, any screen centered on a day-by-day workflow.

### Avoid When
Full calendar views — use `OiCalendar`. Date input for forms — use `OiDateInput`. Date range selection — use `OiDateRangePicker`.

### Combine With
`OiGroupedList` (content for selected day), `OiPage`, `OiSliverHeader` (as part of a collapsible header).

### Tests

```dart
group('OiWeekStrip', () {
  testWidgets('renders 7 day cells', (tester) async {
    await tester.pumpWidget(wrap(
      OiWeekStrip(
        selectedDate: DateTime(2026, 3, 25), // Wednesday
        onDateSelected: (_) {},
        label: 'Week',
      ),
    ));
    // Should show Mon 23 through Sun 29.
    spot<OiLabel>().withText('23').existsOnce();
    spot<OiLabel>().withText('29').existsOnce();
  });

  testWidgets('highlights selected date', (tester) async {
    await tester.pumpWidget(wrap(
      OiWeekStrip(
        selectedDate: DateTime(2026, 3, 25),
        onDateSelected: (_) {},
        label: 'Week',
      ),
    ));
    // Day 25 cell should have primary color styling.
  });

  testWidgets('tapping a day calls onDateSelected', (tester) async {
    DateTime? selected;
    await tester.pumpWidget(wrap(
      OiWeekStrip(
        selectedDate: DateTime(2026, 3, 25),
        onDateSelected: (d) => selected = d,
        label: 'Week',
      ),
    ));
    await tester.tap(find.text('26'));
    expect(selected?.day, 26);
  });

  testWidgets('navigation arrows change visible week', (tester) async {
    DateTime? selected;
    await tester.pumpWidget(wrap(
      OiWeekStrip(
        selectedDate: DateTime(2026, 3, 25),
        onDateSelected: (d) => selected = d,
        label: 'Week',
        showNavigation: true,
      ),
    ));
    // Tap next week arrow.
    await tester.tap(find.byIcon(OiIcons.chevronRight));
    await tester.pump();
    // Should now show Mar 30 - Apr 5.
    spot<OiLabel>().withText('30').existsOnce();
  });

  testWidgets('event dots appear for dates with events', (tester) async {
    await tester.pumpWidget(wrap(
      OiWeekStrip(
        selectedDate: DateTime(2026, 3, 25),
        onDateSelected: (_) {},
        label: 'Week',
        eventCounts: {DateTime(2026, 3, 25): 3, DateTime(2026, 3, 27): 1},
      ),
    ));
    // Dot indicators should render for days 25 and 27.
    spot<OiPulse>().existsAtLeastNTimes(2);
  });

  testWidgets('disabled dates are not tappable', (tester) async {
    DateTime? selected;
    await tester.pumpWidget(wrap(
      OiWeekStrip(
        selectedDate: DateTime(2026, 3, 25),
        onDateSelected: (d) => selected = d,
        label: 'Week',
        disabledDates: {DateTime(2026, 3, 26)},
      ),
    ));
    await tester.tap(find.text('26'));
    expect(selected, isNull);
  });

  testWidgets('firstDayOfWeek=sunday starts week on Sunday', (tester) async {
    await tester.pumpWidget(wrap(
      OiWeekStrip(
        selectedDate: DateTime(2026, 3, 25), // Wednesday
        onDateSelected: (_) {},
        label: 'Week',
        firstDayOfWeek: DateTime.sunday,
      ),
    ));
    // First cell should be Sunday the 22nd.
    spot<OiLabel>().withText('22').existsOnce();
  });

  testWidgets('showMonth displays current month name', (tester) async {
    await tester.pumpWidget(wrap(
      OiWeekStrip(
        selectedDate: DateTime(2026, 3, 25),
        onDateSelected: (_) {},
        label: 'Week',
        showMonth: true,
      ),
    ));
    expect(find.textContaining('Mar'), findsOneWidget);
  });

  testWidgets('todayLabel shows jump-to-today button', (tester) async {
    await tester.pumpWidget(wrap(
      OiWeekStrip(
        selectedDate: DateTime(2026, 1, 1), // Far from today.
        onDateSelected: (_) {},
        label: 'Week',
        todayLabel: 'Today',
      ),
    ));
    spot<OiButton>().withText('Today').existsOnce();
  });

  testWidgets('minDate disables previous navigation', (tester) async {
    await tester.pumpWidget(wrap(
      OiWeekStrip(
        selectedDate: DateTime(2026, 3, 25),
        onDateSelected: (_) {},
        label: 'Week',
        minDate: DateTime(2026, 3, 23), // Monday of current week.
      ),
    ));
    // Previous arrow should be disabled.
  });

  testWidgets('swipe left navigates to next week', (tester) async {
    await tester.pumpWidget(wrap(
      OiWeekStrip(
        selectedDate: DateTime(2026, 3, 25),
        onDateSelected: (_) {},
        label: 'Week',
      ),
    ));
    await tester.fling(find.byType(OiWeekStrip), const Offset(-200, 0), 500);
    await tester.pumpAndSettle();
    spot<OiLabel>().withText('30').existsOnce();
  });

  testWidgets('today indicator visible on today even when not selected',
      (tester) async {
    final today = DateTime.now();
    await tester.pumpWidget(wrap(
      OiWeekStrip(
        selectedDate: today.add(const Duration(days: 1)),
        onDateSelected: (_) {},
        label: 'Week',
      ),
    ));
    // Today's cell should have a today indicator (dot or ring).
  });
});
```

---

## 5. OiIndexBar — Alphabet/Index Sidebar

**Tags:** `index`, `alphabet`, `sidebar`, `jump`, `scroll`, `A-Z`, `fast-scroll`
**Tier:** Component
**Category:** Navigation

### Problem

When using `OiGroupedList` with alphabetical groups (contacts, products, directories), users need a way to jump directly to a letter without scrolling through hundreds of items. This **A-Z index sidebar** is a standard pattern on iOS (Contacts) and Android (phonebook) but obers_ui does not provide it.

### Behavior

- Renders vertically along the right edge of the associated list.
- Shows single-character labels (A-Z, or custom labels).
- Tap a letter to jump instantly to that group.
- Drag along the bar to scrub through letters quickly (touch devices).
- Active letter (currently scrolled-to group) is highlighted.
- Letters without matching groups are dimmed but still positioned for spatial consistency.
- On pointer devices, shows a floating tooltip with the letter on hover.
- Compact on mobile, slightly larger on desktop.

### API

```dart
/// Vertical index sidebar for fast jumping in grouped lists.
///
/// Typically positioned on the right edge alongside an [OiGroupedList].
class OiIndexBar extends StatelessWidget {

  const OiIndexBar({
    required this.labels,
    required this.onLabelSelected,
    required this.semanticLabel,
    this.activeLabel,
    this.availableLabels,
    this.size = OiIndexBarSize.medium,
    this.showTooltip = true,
    this.hapticFeedback = true,
    this.alignment = Alignment.centerRight,
    this.padding,
    super.key,
  });

  /// Ordered list of index labels (e.g., ['A', 'B', ..., 'Z', '#']).
  final List<String> labels;

  /// Called when a label is tapped or dragged to.
  final ValueChanged<String> onLabelSelected;

  /// Accessibility label for the index bar.
  final String semanticLabel;

  /// The currently active label (highlighted). Typically derived from
  /// the scroll position of the associated list.
  final String? activeLabel;

  /// Set of labels that have matching content. Labels not in this set
  /// are rendered dimmed/disabled. If null, all labels are active.
  final Set<String>? availableLabels;

  /// Visual size preset.
  final OiIndexBarSize size;

  /// Show floating tooltip bubble on touch drag.
  final bool showTooltip;

  /// Trigger haptic feedback on each label change during drag.
  final bool hapticFeedback;

  /// Alignment within the parent. Typically [Alignment.centerRight].
  final Alignment alignment;

  /// Padding around the bar.
  final EdgeInsetsGeometry? padding;

  /// Convenience constructor for standard A-Z + # labels.
  factory OiIndexBar.alphabet({
    required ValueChanged<String> onLabelSelected,
    required String semanticLabel,
    String? activeLabel,
    Set<String>? availableLabels,
    bool includeHash = true,
  }) {
    final letters = List.generate(26, (i) => String.fromCharCode(65 + i));
    if (includeHash) letters.add('#');
    return OiIndexBar(
      labels: letters,
      onLabelSelected: onLabelSelected,
      semanticLabel: semanticLabel,
      activeLabel: activeLabel,
      availableLabels: availableLabels,
    );
  }
}
```

### Companion Types

```dart
enum OiIndexBarSize {
  /// Smaller labels, 12dp font. For dense lists.
  small,
  /// Default size, 14dp font.
  medium,
  /// Larger touch targets, 16dp font.
  large,
}
```

### Use When
Alongside `OiGroupedList` for fast navigation in long alphabetically-sorted lists. Contact lists, directories, glossaries, product catalogs.

### Avoid When
Short lists (< 50 items). Non-alphabetical grouping where a search bar is more appropriate.

### Combine With
`OiGroupedList` (primary pairing), `OiGroupedListController.scrollToGroup()`.

### Tests

```dart
group('OiIndexBar', () {
  testWidgets('renders all 26 letters plus #', (tester) async {
    await tester.pumpWidget(wrap(
      OiIndexBar.alphabet(
        onLabelSelected: (_) {},
        semanticLabel: 'Index',
      ),
    ));
    spot<OiLabel>().withText('A').existsOnce();
    spot<OiLabel>().withText('Z').existsOnce();
    spot<OiLabel>().withText('#').existsOnce();
  });

  testWidgets('tapping a letter calls onLabelSelected', (tester) async {
    String? selected;
    await tester.pumpWidget(wrap(
      OiIndexBar.alphabet(
        onLabelSelected: (l) => selected = l,
        semanticLabel: 'Index',
      ),
    ));
    await tester.tap(find.text('M'));
    expect(selected, 'M');
  });

  testWidgets('activeLabel highlights the current letter', (tester) async {
    await tester.pumpWidget(wrap(
      OiIndexBar.alphabet(
        onLabelSelected: (_) {},
        semanticLabel: 'Index',
        activeLabel: 'G',
      ),
    ));
    // Letter G should have primary color styling.
  });

  testWidgets('unavailable labels are dimmed', (tester) async {
    await tester.pumpWidget(wrap(
      OiIndexBar.alphabet(
        onLabelSelected: (_) {},
        semanticLabel: 'Index',
        availableLabels: {'A', 'B', 'C'},
      ),
    ));
    // Letters D-Z should be rendered with muted color.
  });

  testWidgets('dragging across letters fires multiple callbacks',
      (tester) async {
    final selected = <String>[];
    await tester.pumpWidget(wrap(
      OiIndexBar.alphabet(
        onLabelSelected: (l) => selected.add(l),
        semanticLabel: 'Index',
      ),
    ));
    // Simulate vertical drag from A to E.
    final aCenter = tester.getCenter(find.text('A'));
    final eCenter = tester.getCenter(find.text('E'));
    await tester.timedDragFrom(aCenter, eCenter - aCenter, const Duration(milliseconds: 300));
    expect(selected.length, greaterThan(1));
  });

  testWidgets('custom labels render correctly', (tester) async {
    await tester.pumpWidget(wrap(
      OiIndexBar(
        labels: ['2024', '2025', '2026'],
        onLabelSelected: (_) {},
        semanticLabel: 'Year index',
      ),
    ));
    spot<OiLabel>().withText('2025').existsOnce();
  });

  testWidgets('showTooltip displays floating label on drag', (tester) async {
    await tester.pumpWidget(wrap(
      OiIndexBar.alphabet(
        onLabelSelected: (_) {},
        semanticLabel: 'Index',
        showTooltip: true,
      ),
    ));
    // Start drag — tooltip should appear.
    final aCenter = tester.getCenter(find.text('A'));
    final gesture = await tester.startGesture(aCenter);
    await tester.pump();
    // A tooltip with the letter should be visible.
  });

  testWidgets('excludes # when includeHash is false', (tester) async {
    await tester.pumpWidget(wrap(
      OiIndexBar.alphabet(
        onLabelSelected: (_) {},
        semanticLabel: 'Index',
        includeHash: false,
      ),
    ));
    expect(find.text('#'), findsNothing);
  });

  testWidgets('meets minimum touch target size', (tester) async {
    await tester.pumpWidget(wrap(
      OiIndexBar.alphabet(
        onLabelSelected: (_) {},
        semanticLabel: 'Index',
        size: OiIndexBarSize.large,
      ),
    ));
    // Each label's tappable area should be >= 24dp tall (they are packed
    // vertically so 48dp per letter is not feasible for 27 labels).
  });
});
```

---

## 6. OiActionBar — Contextual Entity Action Toolbar

**Tags:** `toolbar`, `actions`, `contextual`, `entity`, `bar`, `quick-actions`, `inbox`
**Tier:** Component
**Category:** Toolbars

### Problem

obers_ui provides `OiBulkBar` (appears on multi-select) and `OiContextMenu` (right-click). Neither covers the **always-visible, single-entity action toolbar** pattern: a row of action buttons scoped to the currently viewed/selected item. Examples: email action bars (reply, forward, archive, delete), document toolbars (share, download, print, move), CMS toolbars (publish, unpublish, duplicate, delete).

### Behavior

- Horizontal bar with icon buttons and optional label visibility.
- Supports primary (always visible) and overflow (behind "more" menu) actions.
- Automatically collapses actions into overflow when space is limited.
- Optional separator dividers between action groups.
- Responds to breakpoint: shows labels on desktop, icon-only on mobile.
- Active/toggled state for actions (e.g., "starred" toggle).

### API

```dart
/// Contextual action toolbar for single-entity operations.
///
/// Use for email-style action bars, document toolbars, or any toolbar
/// scoped to the currently viewed item. For multi-select bulk actions,
/// use [OiBulkBar] instead.
class OiActionBar extends StatelessWidget {

  const OiActionBar({
    required this.actions,
    required this.label,
    this.overflowActions,
    this.leading,
    this.trailing,
    this.style = OiActionBarStyle.flat,
    this.showLabels,
    this.size = OiButtonSize.medium,
    this.separator = false,
    this.semanticLabel,
    super.key,
  });

  /// Primary actions rendered as visible buttons.
  final List<OiActionBarItem> actions;

  /// Actions that appear in the overflow "more" menu.
  final List<OiActionBarItem>? overflowActions;

  /// Widget before the action buttons (e.g., back button, title).
  final Widget? leading;

  /// Widget after the action buttons (e.g., close button).
  final Widget? trailing;

  /// Visual style of the bar.
  final OiActionBarStyle style;

  /// Show text labels beside icons. Defaults to true on expanded+
  /// breakpoints, false on compact.
  final bool? showLabels;

  /// Button size for all actions.
  final OiButtonSize size;

  /// Show divider between action groups (items with [OiActionBarItem.group]).
  final bool separator;

  /// Accessibility label.
  final String? semanticLabel;

  final String label;
}
```

### Companion Types

```dart
/// Single action in an [OiActionBar].
class OiActionBarItem {
  const OiActionBarItem({
    required this.icon,
    required this.label,
    required this.semanticLabel,
    this.onTap,
    this.enabled = true,
    this.toggled = false,
    this.variant = OiButtonVariant.ghost,
    this.tooltip,
    this.group,
    this.badge,
    this.loading = false,
    this.confirm,
  });

  /// Action icon.
  final IconData icon;

  /// Action label text.
  final String label;

  /// Accessibility label.
  final String semanticLabel;

  /// Action callback. Null = disabled.
  final VoidCallback? onTap;

  /// Whether the action is enabled.
  final bool enabled;

  /// Whether the action is in a toggled/active state (e.g., starred).
  final bool toggled;

  /// Button visual variant.
  final OiButtonVariant variant;

  /// Tooltip shown on hover.
  final String? tooltip;

  /// Group key for visual separator grouping.
  final String? group;

  /// Optional badge widget (e.g., unread count).
  final Widget? badge;

  /// Shows a spinner instead of the icon.
  final bool loading;

  /// If set, the action requires confirmation before executing.
  /// Shows a confirm tooltip/popover on first tap.
  final String? confirm;
}

enum OiActionBarStyle {
  /// No background, blends into page.
  flat,
  /// Subtle surface background.
  surface,
  /// Bordered container.
  outlined,
  /// Elevated with shadow.
  elevated,
}
```

### Use When
Email action bars, document/file toolbars, CMS publish toolbars, record detail page actions, media player controls.

### Avoid When
Multi-select batch operations — use `OiBulkBar`. Global app actions — use `OiAppShell` header actions. Navigation — use `OiBottomBar` or `OiSidebar`.

### Combine With
`OiDetailView`, `OiResourcePage`, `OiSliverHeader`, `OiCard`.

### Tests

```dart
group('OiActionBar', () {
  final actions = [
    OiActionBarItem(icon: OiIcons.reply, label: 'Reply', semanticLabel: 'Reply', onTap: () {}),
    OiActionBarItem(icon: OiIcons.forward, label: 'Forward', semanticLabel: 'Forward', onTap: () {}),
    OiActionBarItem(icon: OiIcons.archive, label: 'Archive', semanticLabel: 'Archive', onTap: () {}),
    OiActionBarItem(icon: OiIcons.trash, label: 'Delete', semanticLabel: 'Delete', variant: OiButtonVariant.destructive, onTap: () {}),
  ];

  testWidgets('renders all action buttons', (tester) async {
    await tester.pumpWidget(wrap(
      OiActionBar(actions: actions, label: 'Actions'),
    ));
    spot<OiIconButton>().existsAtLeastNTimes(4);
  });

  testWidgets('tapping action calls onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(wrap(
      OiActionBar(
        actions: [
          OiActionBarItem(icon: OiIcons.reply, label: 'Reply', semanticLabel: 'Reply', onTap: () => tapped = true),
        ],
        label: 'Actions',
      ),
    ));
    await tester.tap(find.bySemanticsLabel('Reply'));
    expect(tapped, isTrue);
  });

  testWidgets('disabled action does not fire onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(wrap(
      OiActionBar(
        actions: [
          OiActionBarItem(icon: OiIcons.reply, label: 'Reply', semanticLabel: 'Reply', enabled: false, onTap: () => tapped = true),
        ],
        label: 'Actions',
      ),
    ));
    await tester.tap(find.bySemanticsLabel('Reply'));
    expect(tapped, isFalse);
  });

  testWidgets('overflow actions appear in more menu', (tester) async {
    await tester.pumpWidget(wrap(
      OiActionBar(
        actions: [actions.first],
        overflowActions: [actions.last],
        label: 'Actions',
      ),
    ));
    // A "more" button should exist.
    await tester.tap(find.bySemanticsLabel(contains('More')));
    await tester.pump();
    // Overflow menu should show 'Delete'.
    spot<OiLabel>().withText('Delete').existsOnce();
  });

  testWidgets('toggled action shows active state', (tester) async {
    await tester.pumpWidget(wrap(
      OiActionBar(
        actions: [
          OiActionBarItem(icon: OiIcons.star, label: 'Star', semanticLabel: 'Star', toggled: true, onTap: () {}),
        ],
        label: 'Actions',
      ),
    ));
    // Toggled button should have primary/active styling.
  });

  testWidgets('loading action shows spinner', (tester) async {
    await tester.pumpWidget(wrap(
      OiActionBar(
        actions: [
          OiActionBarItem(icon: OiIcons.archive, label: 'Archive', semanticLabel: 'Archiving', loading: true, onTap: () {}),
        ],
        label: 'Actions',
      ),
    ));
    spot<OiProgress>().existsOnce();
  });

  testWidgets('confirm action requires two taps', (tester) async {
    var executed = false;
    await tester.pumpWidget(wrap(
      OiActionBar(
        actions: [
          OiActionBarItem(icon: OiIcons.trash, label: 'Delete', semanticLabel: 'Delete', confirm: 'Are you sure?', onTap: () => executed = true),
        ],
        label: 'Actions',
      ),
    ));
    await tester.tap(find.bySemanticsLabel('Delete'));
    await tester.pump();
    expect(executed, isFalse); // First tap shows confirmation.
    spot<OiLabel>().withText('Are you sure?').existsOnce();
    await tester.tap(find.text('Are you sure?'));
    expect(executed, isTrue);
  });

  testWidgets('separator renders between groups', (tester) async {
    await tester.pumpWidget(wrap(
      OiActionBar(
        actions: [
          OiActionBarItem(icon: OiIcons.reply, label: 'Reply', semanticLabel: 'Reply', group: 'comm', onTap: () {}),
          OiActionBarItem(icon: OiIcons.trash, label: 'Delete', semanticLabel: 'Delete', group: 'destructive', onTap: () {}),
        ],
        separator: true,
        label: 'Actions',
      ),
    ));
    spot<OiDivider>().existsOnce();
  });

  testWidgets('leading and trailing widgets render', (tester) async {
    await tester.pumpWidget(wrap(
      OiActionBar(
        actions: actions,
        leading: OiLabel.body('Email from John'),
        trailing: OiIconButton(icon: OiIcons.close, semanticLabel: 'Close', onTap: () {}),
        label: 'Actions',
      ),
    ));
    spot<OiLabel>().withText('Email from John').existsOnce();
  });

  testWidgets('showLabels=true displays text labels', (tester) async {
    await tester.pumpWidget(wrap(
      OiActionBar(actions: actions, showLabels: true, label: 'Actions'),
    ));
    spot<OiLabel>().withText('Reply').existsOnce();
    spot<OiLabel>().withText('Forward').existsOnce();
  });

  testWidgets('badge renders on action', (tester) async {
    await tester.pumpWidget(wrap(
      OiActionBar(
        actions: [
          OiActionBarItem(icon: OiIcons.inbox, label: 'Inbox', semanticLabel: 'Inbox', badge: OiBadge.filled(label: '5', color: OiBadgeColor.error), onTap: () {}),
        ],
        label: 'Actions',
      ),
    ));
    spot<OiBadge>().withText('5').existsOnce();
  });
});
```

---

## 7. OiAccountSwitcher — Workspace/Org/Account Selector

**Tags:** `account`, `switcher`, `workspace`, `organization`, `tenant`, `multi-account`, `dropdown`
**Tier:** Component
**Category:** Navigation

### Problem

`OiUserMenu` handles the current user's profile dropdown (settings, logout). But multi-tenant SaaS apps also need a **workspace/account/organization switcher** — a separate control that changes the entire app context. Examples: Slack workspace switcher, GitHub organization selector, Google account picker, Figma team switcher.

### Behavior

- Avatar/icon trigger that opens a dropdown of available accounts/workspaces.
- Each item shows an avatar/icon, name, and optional description/role.
- Active account is visually marked.
- Optional search when the list is long.
- Optional "Add account" / "Create workspace" action at the bottom.
- Fires a callback on selection (the app handles the actual context switch).
- Compact: shows only the active account's avatar. Expanded: shows avatar + name.

### API

```dart
/// Workspace, organization, or account switcher dropdown.
///
/// Changes the entire app context. Distinct from [OiUserMenu] which
/// manages the current user's profile actions.
class OiAccountSwitcher<T> extends StatelessWidget {

  const OiAccountSwitcher({
    required this.accounts,
    required this.activeAccount,
    required this.onSelect,
    required this.label,
    this.labelOf,
    this.avatarOf,
    this.descriptionOf,
    this.colorOf,
    this.accountKey,
    this.onAddAccount,
    this.addAccountLabel,
    this.searchable = false,
    this.searchHint,
    this.compact = false,
    this.maxVisible,
    this.header,
    this.footer,
    this.semanticLabel,
    super.key,
  });

  /// All available accounts/workspaces.
  final List<T> accounts;

  /// The currently active account.
  final T activeAccount;

  /// Called when the user selects a different account.
  final ValueChanged<T> onSelect;

  /// Accessibility label.
  final String label;

  /// Display name for each account. Defaults to `.toString()`.
  final String Function(T)? labelOf;

  /// Avatar URL or initials for each account.
  final String Function(T)? avatarOf;

  /// Subtitle/description for each account (e.g., role, email, plan).
  final String Function(T)? descriptionOf;

  /// Accent color for each account (e.g., workspace color).
  final Color Function(T)? colorOf;

  /// Unique key for each account. Required if T doesn't implement ==.
  final Object Function(T)? accountKey;

  /// Callback for the "Add account" action. If null, the action is hidden.
  final VoidCallback? onAddAccount;

  /// Label for the add action. Defaults to "Add account".
  final String? addAccountLabel;

  /// Whether to show a search field inside the dropdown.
  final bool searchable;

  /// Placeholder text for the search field.
  final String? searchHint;

  /// Show only the avatar trigger (no name text).
  final bool compact;

  /// Max visible accounts before scrolling. Defaults to 8.
  final int? maxVisible;

  /// Custom header widget inside the dropdown (above the list).
  final Widget? header;

  /// Custom footer widget inside the dropdown (below the list).
  final Widget? footer;

  final String? semanticLabel;
}
```

### Use When
Multi-tenant SaaS (workspace switching), multi-account apps (Google account picker), organization selectors, team/project switchers.

### Avoid When
User profile actions (logout, settings) — use `OiUserMenu`. Simple dropdowns — use `OiSelect`.

### Combine With
`OiAppShell` (sidebar header), `OiSidebar` (top of sidebar), `OiAvatar`.

### Tests

```dart
group('OiAccountSwitcher', () {
  final accounts = [
    Workspace('ws-1', 'Acme Corp', 'acme.png'),
    Workspace('ws-2', 'Beta Inc', 'beta.png'),
    Workspace('ws-3', 'Gamma LLC', 'gamma.png'),
  ];

  testWidgets('renders trigger with active account', (tester) async {
    await tester.pumpWidget(wrap(
      OiAccountSwitcher<Workspace>(
        accounts: accounts,
        activeAccount: accounts[0],
        onSelect: (_) {},
        label: 'Workspace',
        labelOf: (w) => w.name,
      ),
    ));
    spot<OiLabel>().withText('Acme Corp').existsOnce();
  });

  testWidgets('compact mode shows only avatar', (tester) async {
    await tester.pumpWidget(wrap(
      OiAccountSwitcher<Workspace>(
        accounts: accounts,
        activeAccount: accounts[0],
        onSelect: (_) {},
        label: 'Workspace',
        labelOf: (w) => w.name,
        compact: true,
      ),
    ));
    spot<OiAvatar>().existsOnce();
    expect(find.text('Acme Corp'), findsNothing);
  });

  testWidgets('tapping trigger opens dropdown', (tester) async {
    await tester.pumpWidget(wrap(
      OiAccountSwitcher<Workspace>(
        accounts: accounts,
        activeAccount: accounts[0],
        onSelect: (_) {},
        label: 'Workspace',
        labelOf: (w) => w.name,
      ),
    ));
    await tester.tap(find.text('Acme Corp'));
    await tester.pump();
    spot<OiLabel>().withText('Beta Inc').existsOnce();
    spot<OiLabel>().withText('Gamma LLC').existsOnce();
  });

  testWidgets('selecting an account calls onSelect', (tester) async {
    Workspace? selected;
    await tester.pumpWidget(wrap(
      OiAccountSwitcher<Workspace>(
        accounts: accounts,
        activeAccount: accounts[0],
        onSelect: (w) => selected = w,
        label: 'Workspace',
        labelOf: (w) => w.name,
      ),
    ));
    await tester.tap(find.text('Acme Corp')); // Open.
    await tester.pump();
    await tester.tap(find.text('Beta Inc')); // Select.
    expect(selected?.name, 'Beta Inc');
  });

  testWidgets('active account is visually marked in dropdown', (tester) async {
    await tester.pumpWidget(wrap(
      OiAccountSwitcher<Workspace>(
        accounts: accounts,
        activeAccount: accounts[0],
        onSelect: (_) {},
        label: 'Workspace',
        labelOf: (w) => w.name,
      ),
    ));
    await tester.tap(find.text('Acme Corp'));
    await tester.pump();
    // Active account row should have a check icon or primary styling.
  });

  testWidgets('add account action appears when callback provided',
      (tester) async {
    var addTapped = false;
    await tester.pumpWidget(wrap(
      OiAccountSwitcher<Workspace>(
        accounts: accounts,
        activeAccount: accounts[0],
        onSelect: (_) {},
        label: 'Workspace',
        labelOf: (w) => w.name,
        onAddAccount: () => addTapped = true,
        addAccountLabel: 'Create workspace',
      ),
    ));
    await tester.tap(find.text('Acme Corp'));
    await tester.pump();
    await tester.tap(find.text('Create workspace'));
    expect(addTapped, isTrue);
  });

  testWidgets('searchable filters accounts', (tester) async {
    await tester.pumpWidget(wrap(
      OiAccountSwitcher<Workspace>(
        accounts: accounts,
        activeAccount: accounts[0],
        onSelect: (_) {},
        label: 'Workspace',
        labelOf: (w) => w.name,
        searchable: true,
      ),
    ));
    await tester.tap(find.text('Acme Corp'));
    await tester.pump();
    await tester.enterText(find.byType(OiTextInput), 'Beta');
    await tester.pump();
    spot<OiLabel>().withText('Beta Inc').existsOnce();
    expect(find.text('Gamma LLC'), findsNothing);
  });

  testWidgets('descriptionOf shows subtitle per account', (tester) async {
    await tester.pumpWidget(wrap(
      OiAccountSwitcher<Workspace>(
        accounts: accounts,
        activeAccount: accounts[0],
        onSelect: (_) {},
        label: 'Workspace',
        labelOf: (w) => w.name,
        descriptionOf: (w) => 'Admin',
      ),
    ));
    await tester.tap(find.text('Acme Corp'));
    await tester.pump();
    spot<OiLabel>().withText('Admin').existsAtLeastNTimes(3);
  });
});
```

---

## 8. OiOptimisticAction — Optimistic Update Utility

**Tags:** `optimistic`, `undo`, `rollback`, `async`, `action`, `snackbar`, `utility`
**Tier:** Foundation (Utility)
**Category:** State Management

### Problem

obers_ui has `OiUndoStack` for global undo/redo history and `OiSnackBar`/`OiToast` for feedback. But the **optimistic update pattern** — apply a change immediately, show an undo opportunity, and roll back on failure — requires orchestrating all three. Every app building async operations (delete, archive, move, status change) re-implements this fragile pattern from scratch.

### Behavior

- Immediately applies the change (optimistic callback).
- Shows a snackbar/toast with an "Undo" action.
- If the user taps Undo within the duration, calls the rollback.
- If the timer expires, calls the commit (the actual async operation).
- If the commit fails, automatically calls the rollback and shows an error toast.
- Cancels itself if a new optimistic action replaces it (debounce).

### API

```dart
/// Orchestrates optimistic UI updates with undo and automatic rollback.
///
/// Apply a change immediately, give the user a window to undo, then
/// commit the real operation. If the commit fails, rolls back automatically.
class OiOptimisticAction {

  /// Execute an optimistic action with undo support.
  ///
  /// 1. Calls [apply] immediately (optimistic update).
  /// 2. Shows an [OiSnackBar] with [message] and an Undo button.
  /// 3. If Undo is tapped within [undoDuration], calls [rollback].
  /// 4. If the timer expires, calls [commit].
  /// 5. If [commit] throws, calls [rollback] and shows an error toast.
  static Future<bool> execute(
    BuildContext context, {
    /// Optimistic change — apply immediately (e.g., remove item from list).
    required VoidCallback apply,

    /// Undo the optimistic change (e.g., re-insert item).
    required VoidCallback rollback,

    /// The real async operation (e.g., API delete call).
    required Future<void> Function() commit,

    /// Snackbar/toast message shown during the undo window.
    required String message,

    /// Duration of the undo window.
    Duration undoDuration = const Duration(seconds: 5),

    /// Label for the undo button. Defaults to "Undo".
    String undoLabel = 'Undo',

    /// Error message shown if [commit] fails.
    String? errorMessage,

    /// Accessibility label for the snackbar.
    String? semanticLabel,

    /// Snackbar position.
    OiSnackBarPosition position = OiSnackBarPosition.bottom,

    /// Level of the error toast on failure.
    OiToastLevel errorLevel = OiToastLevel.error,
  });

  /// Cancel any pending optimistic action in the current context.
  /// Rolls back the pending change if one exists.
  static void cancelPending(BuildContext context);
}
```

### Use When
Any async mutation where immediate UI feedback matters: delete, archive, move, mark-as-read, status changes, reorder, unsubscribe.

### Avoid When
Operations that must confirm before executing (use `OiDialog.confirm()` or `OiButton.confirm()`). Operations that cannot be undone (permanent deletion without soft-delete).

### Combine With
`OiSnackBar` (internal), `OiToast` (error feedback), `OiListView` / `OiTable` (data mutation), `OiActionBar` (action trigger).

### Tests

```dart
group('OiOptimisticAction', () {
  testWidgets('apply is called immediately', (tester) async {
    var applied = false;
    await tester.pumpWidget(wrap(
      Builder(builder: (context) {
        return OiButton.primary(
          label: 'Delete',
          onTap: () => OiOptimisticAction.execute(
            context,
            apply: () => applied = true,
            rollback: () {},
            commit: () async {},
            message: 'Item deleted',
          ),
        );
      }),
    ));
    await tester.tap(find.text('Delete'));
    expect(applied, isTrue);
  });

  testWidgets('snackbar with undo appears after apply', (tester) async {
    await tester.pumpWidget(wrap(
      Builder(builder: (context) {
        return OiButton.primary(
          label: 'Delete',
          onTap: () => OiOptimisticAction.execute(
            context,
            apply: () {},
            rollback: () {},
            commit: () async {},
            message: 'Item deleted',
          ),
        );
      }),
    ));
    await tester.tap(find.text('Delete'));
    await tester.pump();
    spot<OiSnackBar>().existsOnce();
    spot<OiLabel>().withText('Item deleted').existsOnce();
    spot<OiLabel>().withText('Undo').existsOnce();
  });

  testWidgets('tapping undo calls rollback', (tester) async {
    var rolledBack = false;
    await tester.pumpWidget(wrap(
      Builder(builder: (context) {
        return OiButton.primary(
          label: 'Delete',
          onTap: () => OiOptimisticAction.execute(
            context,
            apply: () {},
            rollback: () => rolledBack = true,
            commit: () async {},
            message: 'Deleted',
          ),
        );
      }),
    ));
    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.tap(find.text('Undo'));
    expect(rolledBack, isTrue);
  });

  testWidgets('commit is called after undo duration expires', (tester) async {
    var committed = false;
    await tester.pumpWidget(wrap(
      Builder(builder: (context) {
        return OiButton.primary(
          label: 'Delete',
          onTap: () => OiOptimisticAction.execute(
            context,
            apply: () {},
            rollback: () {},
            commit: () async { committed = true; },
            message: 'Deleted',
            undoDuration: const Duration(seconds: 1),
          ),
        );
      }),
    ));
    await tester.tap(find.text('Delete'));
    await tester.pump(const Duration(seconds: 2));
    expect(committed, isTrue);
  });

  testWidgets('commit failure triggers rollback and error toast',
      (tester) async {
    var rolledBack = false;
    await tester.pumpWidget(wrap(
      Builder(builder: (context) {
        return OiButton.primary(
          label: 'Delete',
          onTap: () => OiOptimisticAction.execute(
            context,
            apply: () {},
            rollback: () => rolledBack = true,
            commit: () async { throw Exception('Network error'); },
            message: 'Deleted',
            errorMessage: 'Failed to delete',
            undoDuration: const Duration(milliseconds: 100),
          ),
        );
      }),
    ));
    await tester.tap(find.text('Delete'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(rolledBack, isTrue);
    spot<OiToast>().existsOnce();
  });

  testWidgets('tapping undo prevents commit', (tester) async {
    var committed = false;
    await tester.pumpWidget(wrap(
      Builder(builder: (context) {
        return OiButton.primary(
          label: 'Delete',
          onTap: () => OiOptimisticAction.execute(
            context,
            apply: () {},
            rollback: () {},
            commit: () async { committed = true; },
            message: 'Deleted',
            undoDuration: const Duration(seconds: 5),
          ),
        );
      }),
    ));
    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.tap(find.text('Undo'));
    await tester.pump(const Duration(seconds: 6));
    expect(committed, isFalse);
  });

  testWidgets('execute returns true on successful commit', (tester) async {
    bool? result;
    await tester.pumpWidget(wrap(
      Builder(builder: (context) {
        return OiButton.primary(
          label: 'Delete',
          onTap: () async {
            result = await OiOptimisticAction.execute(
              context,
              apply: () {},
              rollback: () {},
              commit: () async {},
              message: 'Deleted',
              undoDuration: const Duration(milliseconds: 100),
            );
          },
        );
      }),
    ));
    await tester.tap(find.text('Delete'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(result, isTrue);
  });

  testWidgets('execute returns false when undone', (tester) async {
    bool? result;
    await tester.pumpWidget(wrap(
      Builder(builder: (context) {
        return OiButton.primary(
          label: 'Delete',
          onTap: () async {
            result = await OiOptimisticAction.execute(
              context,
              apply: () {},
              rollback: () {},
              commit: () async {},
              message: 'Deleted',
            );
          },
        );
      }),
    ));
    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.tap(find.text('Undo'));
    await tester.pump();
    expect(result, isFalse);
  });

  testWidgets('cancelPending rolls back pending action', (tester) async {
    var rolledBack = false;
    await tester.pumpWidget(wrap(
      Builder(builder: (context) {
        return OiColumn(breakpoint: OiBreakpoint.expanded, children: [
          OiButton.primary(
            label: 'Delete',
            onTap: () => OiOptimisticAction.execute(
              context,
              apply: () {},
              rollback: () => rolledBack = true,
              commit: () async {},
              message: 'Deleted',
            ),
          ),
          OiButton.secondary(
            label: 'Cancel',
            onTap: () => OiOptimisticAction.cancelPending(context),
          ),
        ]);
      }),
    ));
    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.tap(find.text('Cancel'));
    expect(rolledBack, isTrue);
  });
});
```

---

## 9. OiSkeletonPreset — Skeleton Loading Shape Presets

**Tags:** `skeleton`, `loading`, `placeholder`, `shimmer`, `preset`, `text`, `avatar`, `card`
**Tier:** Component
**Category:** Feedback

### Problem

obers_ui provides `OiShimmer` (raw shimmer effect) and `OiSkeletonGroup` (multiple placeholders). But apps need **preset skeleton shapes** that match common content layouts without manually sizing rectangles. Every skeleton loading state in the Qatery project re-implements the same text-line, avatar-circle, card-rectangle, and table-row patterns.

### Behavior

- Each preset renders a shimmer-animated placeholder matching a common content shape.
- Dimensions are proportional and responsive (not hardcoded pixels).
- Multiple presets compose into realistic loading states.
- Respects the app's radius and spacing tokens for visual consistency.
- Reduced-motion preference: shows a static gray placeholder instead of animating.

### API

```dart
/// Pre-shaped skeleton loading placeholders.
///
/// Compose multiple presets to build realistic loading states that
/// match your content layout. All presets use [OiShimmer] internally.
class OiSkeletonPreset extends StatelessWidget {

  /// Rectangle placeholder for text lines.
  const OiSkeletonPreset.text({
    this.lines = 3,
    this.lastLineWidth = 0.6,
    this.lineHeight = 14,
    this.lineSpacing,
    this.width,
    super.key,
  }) : _preset = _SkeletonType.text;

  /// Circular placeholder for avatars.
  const OiSkeletonPreset.avatar({
    this.size = OiAvatarSize.md,
    super.key,
  }) : _preset = _SkeletonType.avatar;

  /// Rounded rectangle placeholder for cards.
  const OiSkeletonPreset.card({
    this.height = 120,
    this.width,
    this.aspectRatio,
    super.key,
  }) : _preset = _SkeletonType.card;

  /// Full-width rectangle for images/banners.
  const OiSkeletonPreset.image({
    this.height = 200,
    this.width,
    this.aspectRatio,
    super.key,
  }) : _preset = _SkeletonType.image;

  /// Small rounded rectangle for badges/chips.
  const OiSkeletonPreset.badge({
    this.width = 60,
    super.key,
  }) : _preset = _SkeletonType.badge;

  /// Standard list tile: avatar + 2 text lines + trailing element.
  const OiSkeletonPreset.listTile({
    this.showAvatar = true,
    this.showTrailing = false,
    this.subtitleWidth = 0.5,
    super.key,
  }) : _preset = _SkeletonType.listTile;

  /// Table row with N columns of varying width.
  const OiSkeletonPreset.tableRow({
    this.columns = 4,
    super.key,
  }) : _preset = _SkeletonType.tableRow;

  /// Metric card: large number + label below.
  const OiSkeletonPreset.metric({
    super.key,
  }) : _preset = _SkeletonType.metric;

  /// Composes multiple [OiSkeletonPreset] in a vertical list,
  /// repeating [count] times with optional separator.
  factory OiSkeletonPreset.list({
    required Widget itemSkeleton,
    int count = 5,
    Widget? separator,
    Key? key,
  });
}
```

### Use When
Any content loading state. Compose presets to match the actual content layout: list tile skeleton for list pages, card skeleton for dashboards, text skeleton for article bodies.

### Avoid When
Simple spinner/progress — use `OiProgress`. Custom layouts not matching any preset — use `OiShimmer` directly.

### Combine With
`OiMorph` (crossfade from skeleton to content), `OiPage`, `OiCard`, `OiListView` (loading state).

### Tests

```dart
group('OiSkeletonPreset', () {
  testWidgets('text preset renders correct number of lines', (tester) async {
    await tester.pumpWidget(wrap(
      const OiSkeletonPreset.text(lines: 4),
    ));
    spot<OiShimmer>().existsAtLeastNTimes(4);
  });

  testWidgets('text preset last line is shorter', (tester) async {
    await tester.pumpWidget(wrap(
      const OiSkeletonPreset.text(lines: 3, lastLineWidth: 0.5),
    ));
    // Last shimmer should have 50% width of the others.
  });

  testWidgets('avatar preset renders circular shape', (tester) async {
    await tester.pumpWidget(wrap(
      const OiSkeletonPreset.avatar(size: OiAvatarSize.lg),
    ));
    spot<OiShimmer>().existsOnce();
    // Should have circular borderRadius.
  });

  testWidgets('card preset renders rounded rectangle', (tester) async {
    await tester.pumpWidget(wrap(
      const OiSkeletonPreset.card(height: 200),
    ));
    spot<OiShimmer>().existsOnce();
  });

  testWidgets('listTile preset shows avatar + text lines', (tester) async {
    await tester.pumpWidget(wrap(
      const OiSkeletonPreset.listTile(showAvatar: true),
    ));
    // Should have circular avatar shimmer + 2 text shimmer lines.
    spot<OiShimmer>().existsAtLeastNTimes(3);
  });

  testWidgets('listTile without avatar omits circle', (tester) async {
    await tester.pumpWidget(wrap(
      const OiSkeletonPreset.listTile(showAvatar: false),
    ));
    spot<OiShimmer>().existsAtLeastNTimes(2); // Just text lines.
  });

  testWidgets('tableRow preset renders N column placeholders', (tester) async {
    await tester.pumpWidget(wrap(
      const OiSkeletonPreset.tableRow(columns: 5),
    ));
    spot<OiShimmer>().existsAtLeastNTimes(5);
  });

  testWidgets('list factory repeats item skeleton', (tester) async {
    await tester.pumpWidget(wrap(
      OiSkeletonPreset.list(
        itemSkeleton: const OiSkeletonPreset.listTile(),
        count: 3,
      ),
    ));
    // 3 list tiles * 3 shimmer elements each = 9 shimmer widgets.
    spot<OiShimmer>().existsAtLeastNTimes(9);
  });

  testWidgets('image preset respects aspectRatio', (tester) async {
    await tester.pumpWidget(wrap(
      const OiSkeletonPreset.image(aspectRatio: 16 / 9),
    ));
    spot<OiShimmer>().existsOnce();
    // Should have OiAspectRatio wrapper.
    spot<OiAspectRatio>().existsOnce();
  });

  testWidgets('badge preset renders small rounded rectangle', (tester) async {
    await tester.pumpWidget(wrap(
      const OiSkeletonPreset.badge(width: 80),
    ));
    spot<OiShimmer>().existsOnce();
  });

  testWidgets('metric preset renders value + label placeholders',
      (tester) async {
    await tester.pumpWidget(wrap(
      const OiSkeletonPreset.metric(),
    ));
    spot<OiShimmer>().existsAtLeastNTimes(2); // Big value + label.
  });

  testWidgets('respects reduced motion preference', (tester) async {
    // When reduced motion is enabled, shimmer should not animate.
    // Verify OiShimmer receives animated: false.
  });
});
```

---

## 10. OiKeyValue — Lightweight Label-Value Display

**Tags:** `key-value`, `label`, `value`, `detail`, `pair`, `field`, `read-only`, `display`
**Tier:** Component
**Category:** Display

### Problem

`OiFieldDisplay.pair()` is powerful but opinionated — it requires an `OiFieldType`, does automatic formatting, and pulls theme data from `OiFieldDisplayThemeData`. Sometimes you just need a simple **label: value** row without any formatting logic, type coercion, or heavy machinery. The Qatery project has `UiDetailRow` (~95 lines) used in 50+ places for exactly this purpose.

### Behavior

- Renders a label on the left and a value on the right (horizontal) or label above value (vertical).
- No automatic formatting — the value is displayed exactly as provided.
- Supports leading icon, trailing action, copyable value.
- Optional divider between rows when used in a group.
- Adapts direction based on breakpoint (horizontal on desktop, vertical on compact).

### API

```dart
/// Lightweight label-value pair for read-only data display.
///
/// Simpler alternative to [OiFieldDisplay.pair] when you don't need
/// type-based formatting. Just shows a label and a value.
class OiKeyValue extends StatelessWidget {

  const OiKeyValue({
    required this.label,
    required this.value,
    this.direction,
    this.labelWidth,
    this.leading,
    this.trailing,
    this.valueWidget,
    this.emptyText = '---',
    this.copyable = false,
    this.onTap,
    this.dense = false,
    this.semanticLabel,
    super.key,
  });

  /// The field label.
  final String label;

  /// The field value as a string. If null or empty, [emptyText] is shown.
  final String? value;

  /// Layout direction. Defaults to horizontal on expanded+, vertical on compact.
  final Axis? direction;

  /// Fixed width for the label column (horizontal direction only).
  final double? labelWidth;

  /// Leading widget before the label (e.g., icon).
  final Widget? leading;

  /// Trailing widget after the value (e.g., action button, badge).
  final Widget? trailing;

  /// Custom widget to render instead of a text value.
  /// When provided, [value] is ignored for display (but still used for copy).
  final Widget? valueWidget;

  /// Placeholder when [value] is null or empty.
  final String emptyText;

  /// Whether the value can be tapped to copy to clipboard.
  final bool copyable;

  /// Makes the entire row tappable.
  final VoidCallback? onTap;

  /// Reduced vertical padding.
  final bool dense;

  final String? semanticLabel;

  /// Group multiple [OiKeyValue] rows into a visual section.
  ///
  /// Adds dividers between rows and optional title/card wrapper.
  static Widget group({
    required List<OiKeyValue> children,
    String? title,
    bool dividers = true,
    bool wrapInCard = false,
    Axis? direction,
    double? labelWidth,
    Key? key,
  });
}
```

### Use When
Simple detail displays: user profile fields, settings summaries, order details, metadata display. When you have a string label and a string value and that's all you need.

### Avoid When
Formatted values (dates, currencies, booleans) — use `OiFieldDisplay.pair()`. Editable fields — use `OiForm`. Complex multi-section detail pages — use `OiDetailView`.

### Combine With
`OiCard` (inside cards), `OiDetailView` (alongside formatted fields), `OiSheet` (detail panels).

### Tests

```dart
group('OiKeyValue', () {
  testWidgets('renders label and value', (tester) async {
    await tester.pumpWidget(wrap(
      const OiKeyValue(label: 'Name', value: 'John Doe'),
    ));
    spot<OiLabel>().withText('Name').existsOnce();
    spot<OiLabel>().withText('John Doe').existsOnce();
  });

  testWidgets('shows emptyText when value is null', (tester) async {
    await tester.pumpWidget(wrap(
      const OiKeyValue(label: 'Email', value: null),
    ));
    spot<OiLabel>().withText('---').existsOnce();
  });

  testWidgets('shows custom emptyText', (tester) async {
    await tester.pumpWidget(wrap(
      const OiKeyValue(label: 'Phone', value: null, emptyText: 'Not provided'),
    ));
    spot<OiLabel>().withText('Not provided').existsOnce();
  });

  testWidgets('copyable value shows copy action', (tester) async {
    await tester.pumpWidget(wrap(
      const OiKeyValue(label: 'ID', value: 'abc-123', copyable: true),
    ));
    spot<OiCopyButton>().existsOnce();
  });

  testWidgets('onTap makes row tappable', (tester) async {
    var tapped = false;
    await tester.pumpWidget(wrap(
      OiKeyValue(label: 'Link', value: 'example.com', onTap: () => tapped = true),
    ));
    await tester.tap(find.text('example.com'));
    expect(tapped, isTrue);
  });

  testWidgets('valueWidget overrides text value', (tester) async {
    await tester.pumpWidget(wrap(
      OiKeyValue(
        label: 'Status',
        value: 'active',
        valueWidget: OiBadge.filled(label: 'Active', color: OiBadgeColor.success),
      ),
    ));
    spot<OiBadge>().withText('Active').existsOnce();
  });

  testWidgets('horizontal direction renders side-by-side', (tester) async {
    await tester.pumpWidget(wrap(
      const OiKeyValue(label: 'Name', value: 'John', direction: Axis.horizontal),
    ));
    // Label and value should be in the same Row.
  });

  testWidgets('vertical direction renders stacked', (tester) async {
    await tester.pumpWidget(wrap(
      const OiKeyValue(label: 'Name', value: 'John', direction: Axis.vertical),
    ));
    // Label should be above value in a Column.
  });

  testWidgets('leading widget renders before label', (tester) async {
    await tester.pumpWidget(wrap(
      OiKeyValue(
        label: 'Email',
        value: 'john@example.com',
        leading: OiIcon.decorative(icon: OiIcons.mail),
      ),
    ));
    spot<OiIcon>().existsOnce();
  });

  testWidgets('trailing widget renders after value', (tester) async {
    await tester.pumpWidget(wrap(
      OiKeyValue(
        label: 'Role',
        value: 'Admin',
        trailing: OiIconButton(icon: OiIcons.edit, semanticLabel: 'Edit', onTap: () {}),
      ),
    ));
    spot<OiIconButton>().existsOnce();
  });

  testWidgets('group renders multiple rows with dividers', (tester) async {
    await tester.pumpWidget(wrap(
      OiKeyValue.group(
        children: [
          const OiKeyValue(label: 'Name', value: 'John'),
          const OiKeyValue(label: 'Email', value: 'john@test.com'),
          const OiKeyValue(label: 'Role', value: 'Admin'),
        ],
      ),
    ));
    spot<OiKeyValue>().existsAtLeastNTimes(3);
    spot<OiDivider>().existsAtLeastNTimes(2); // Between rows.
  });

  testWidgets('group with title renders section header', (tester) async {
    await tester.pumpWidget(wrap(
      OiKeyValue.group(
        title: 'Contact Info',
        children: [
          const OiKeyValue(label: 'Name', value: 'John'),
        ],
      ),
    ));
    spot<OiLabel>().withText('Contact Info').existsOnce();
  });

  testWidgets('group with wrapInCard wraps in OiCard', (tester) async {
    await tester.pumpWidget(wrap(
      OiKeyValue.group(
        wrapInCard: true,
        children: [
          const OiKeyValue(label: 'Name', value: 'John'),
        ],
      ),
    ));
    spot<OiCard>().existsOnce();
  });

  testWidgets('dense reduces padding', (tester) async {
    await tester.pumpWidget(wrap(
      const OiKeyValue(label: 'X', value: 'Y', dense: true),
    ));
    // Verify reduced vertical padding compared to default.
  });

  testWidgets('empty string value shows emptyText', (tester) async {
    await tester.pumpWidget(wrap(
      const OiKeyValue(label: 'Field', value: ''),
    ));
    spot<OiLabel>().withText('---').existsOnce();
  });
});
```

---

## Summary

| # | Widget | Tier | Priority | Lines Saved | Key Use Cases |
|---|--------|------|----------|-------------|---------------|
| 1 | **OiBanner** | Component | HIGH | ~600 | Inline alerts, env indicators, validation summaries |
| 2 | **OiDateRangePicker** | Composite | HIGH | ~800 | Analytics filters, report periods, booking windows |
| 3 | **OiGroupedList** | Composite | HIGH | ~500 | Contacts, events by date, categorized products |
| 4 | **OiWeekStrip** | Component | MEDIUM | ~400 | Daily planners, schedulers, booking UIs |
| 5 | **OiIndexBar** | Component | MEDIUM | ~200 | Alphabet navigation for long grouped lists |
| 6 | **OiActionBar** | Component | MEDIUM | ~700 | Email toolbars, document actions, CMS toolbars |
| 7 | **OiAccountSwitcher** | Component | MEDIUM | ~300 | Multi-tenant SaaS, workspace switching |
| 8 | **OiOptimisticAction** | Foundation | HIGH | ~250 | Delete/archive/move with undo |
| 9 | **OiSkeletonPreset** | Component | LOW | ~400 | Loading states for any content layout |
| 10 | **OiKeyValue** | Component | LOW | ~200 | Simple label-value detail displays |

**Estimated total lines saved per project:** ~4,350

### Naming Conventions Followed

- All widget names prefixed with `Oi` (matching obers_ui convention).
- Named constructors for variants (`.info()`, `.text()`, `.alphabet()`).
- `label` required on all interactive widgets (accessibility).
- `semanticLabel` for non-interactive widgets.
- Companion enums use `Oi` prefix.
- Theme integration via `OiComponentThemes` and `context.components.*`.
- Persistence via `settingsDriver` / `settingsKey` params.
- Callbacks use `ValueChanged<T>` or `VoidCallback` (never raw `Function`).
