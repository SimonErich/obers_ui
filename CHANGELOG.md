# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Versions 0.1.0 to 0.1.2 were never tagged. Their sections are reconstructed
from the git history, using the commits that changed `version:` in
`pubspec.yaml` as the release boundaries.

## [Unreleased]

### Added

- `OiTappable`: `role` (`OiTappableRole`), `checked`, `mixed`, `toggled`, `selected`, `expanded`, `inMutuallyExclusiveGroup`, `onKeyEvent` and `skipTraversal`, so toggles, tabs and disclosure headers can be built on it
- `OiCalendar.labels` (`OiCalendarLabels`): the mode names and the week number column header can be translated
- `OiCalendarUtils.addDays`, `daysBetween` and `fractionalDaysBetween`: day arithmetic on calendar dates that is not thrown off by daylight-saving changes
- `OiClockDial`: a clock face that picks a time of day by tapping the hour, then the minute (drag for the exact one)
- `OiSelect` opens its menu with the selected option in view instead of at the top
- `OiPlatform.inputModalityOf`, `platformOf` and `keyboardHeightOf` (with `OiPlatformAspect`): read one part of the platform data and rebuild only when that part changes
- `OiInfiniteScroll.scrollDirection`: the axis of the scrollable that drives loading (default vertical)
- `OiRedoIntent`: Ctrl+Shift+Z, Cmd+Shift+Z and Ctrl+Y redo the `OiUndoStack`
- `OiShortcutScopeState.helpActive`: set when the user presses `?`
- `OiInputModalityDetector.debugInitialModalityOverride` (tests only): pins the modality an app starts in
- `OiComboBox.labels` (`OiComboBoxLabels`): the dropdown's search placeholder, loading text, create action and load-more row can be translated
- `OiComboBox` opens from the keyboard: the trigger takes focus and Enter, Space or Arrow Down opens the dropdown
- `OiSearchOverlay.errorStateTitle` and `errorStateDescription`: a failed search shows an error state instead of "no results"
- `obers_ui_charts`: `OiChartController.setSeriesVisible` shows or hides a series without toggling, and `OiChartLabelPainter.textDirection` sets the reading direction of axis labels
- `obers_ui_charts`: `OiLineChart` labels its y-axis with round numbers and leaves a gap at non-finite points; `OiPieChart` gives negative and non-finite segments no share
- `obers_ui_charts`: `OiLogarithmicScale.toPixel` returns NaN for values that are not positive (the low end with `clamp`), `buildTicks` honours `count` and adds sub-decade ticks; `OiLinearScale.fromData` pads a single value by 10 % of its magnitude instead of ±1
- `OiVectorMap`, `OiTileMap`, `OiCarousel`, `OiRadialSlider` and `OiAuthMode.lock`
- `OiCalendarWeekPicker`
- `OiAutocomplete`
- Localizable texts across the library through per-widget `*Labels` classes, including `OiTable`, `OiPagination`, `OiWizard`, `OiBulkBar` and the week and month pickers
- `OiWizard`: asynchronous next step, customizable navigation buttons, optional title, optional stepper label, and a per-step `nextEnabled` to disable Next
- `OiTable`: `shrinkWrap` to size the table to its rows, and an optional header tooltip on `OiTableColumn`
- `OiTextInput`: select all on focus; `OiTextInput.search` takes a placeholder and a leading widget
- `OiTouchTarget`: callers can place the child inside the enlarged touch target
- `OiToast`: state-driven usage and a dismiss button
- `OiButton`: themeable per-size font sizes and weights
- `OiDialog`: width parameters
- `OiCheckbox`: `labelGap`; quantity selector: suffix
- `OiLabel`: runtime variant constructor
- `OiSegmentedControl`: theme overrides
- `OiCalendar`: drag-and-drop for events
- `OiKanban`: dragging cards between columns
- Semantics for `OiSwitch`, `OiCheckbox`, `OiRadio`, `OiTabs` and `OiSlider`
- `OiTappable` honors `backgroundOverride` on interaction states
- `obers_ui_autoforms`: `OiAfMessageResolver` is used for validation messages
- `obers_ui_autoforms`: `OiAfController.updateAttachment` (how `OiAfForm` applies changed props), `OiAfController.dispose` now also disposes the field controllers, `OiAfScope.enabled`, and `OiAfMessageResolver` messages for `ipAddress`, `multipleOf`, `decimal`, `digitsBetween`, `distinct`, the today-inclusive date rules and a failed `buildData`
- README files for `obers_ui_charts` and `obers_ui_autoforms`

### Changed

- `file_picker` moved to 12.x, so that consumers that depend on win32 ^6 can resolve it
- Golden tests moved from golden_toolkit to alchemist; only machine-independent CI goldens are committed
- `OiButton`: ghost buttons signal hover with the text colour instead of a grey fill
- `OiTappable` shows the focus ring only while the keyboard is used
- `OiSelect` sizes its menu to its field
- Large widgets (`OiTable`, `OiButton`, `OiContextMenu`, `OiButtonGroup`, field display) are split into part files
- `obers_ui_charts` and `obers_ui_autoforms` use very_good_analysis ^10, like the root package, and share its version number
- CI runs the tests of both sub-packages and analyzes the example app; all workflows read the Flutter version from `.tool-versions`
- Build output and lockfiles of the sub-packages are no longer tracked
- `obers_ui_autoforms`: `OiAfController.set` and `patch` (and so `restore` in `patchCurrent` mode) no longer mark fields touched; pass `markTouched: true` to `set` / `patch` for the old behaviour
- `obers_ui_autoforms`: `OiAfValidators.email` requires a top-level domain and rejects leading, trailing and doubled dots; `url` requires a host for http(s), ftp(s) and ws(s); `ipAddress` validates IPv6 properly and rejects IPv4 octets with leading zeros
- `obers_ui_autoforms`: a circular or unregistered derived-field dependency throws a `StateError` instead of failing an assertion
- `OiGanttTask.end` is now documented and treated as exclusive everywhere: the timeline no longer adds an empty day after the last task, and bars are positioned by time of day (a 09:00 to 17:00 task is a third of a day wide instead of a sliver)
- `OiCalendar` follows a new `mode` or `initialDate` from its parent, and its all-day row only lists events on the dates in view
- Android, iOS and Fuchsia start in touch mode, so tappables have their 48 dp touch target from the first frame instead of growing on the first touch
  - Widget tests are affected too: `flutter test` reports Android, so apps' tests now start in touch mode and lay tappables out at 48 dp. Tests or goldens that expect desktop sizes can pin the old starting mode in `test/flutter_test_config.dart` with `OiInputModalityDetector.debugInitialModalityOverride = OiInputModality.pointer;`
- `OiVirtualList` pull-to-refresh works at every density and with bouncing scroll physics (iOS), calls `onRefresh` once per pull, and only reacts to touch input: scrolling past the top with a mouse or trackpad does not refresh
- `OiInfiniteScroll`, `OiListView` and `OiActivityFeed` load the next page when the first one does not fill the viewport, and once per arrival at the end instead of on every scroll tick; a load that fails or brings nothing is not retried until new items arrive or the user scrolls away and back. `OiChatWindow.onScrollToTop` fires once per arrival at the top
- `OiInfiniteScroll` watches the nearest scrollable on its axis, also inside a scroller on the other axis, and ignores scrollables on the other axis; pass `scrollDirection: Axis.horizontal` for a horizontal list
- `context.isCompact`, `isMedium`, `isExpanded`, `isLarge` and `isExtraLarge` are ranges, so exactly one is true on scales with extra breakpoints (`OiBreakpointScale.extended()`: 480 is compact, 1920 is extraLarge)
- `OiGrid` counts the gaps when deriving the column count from `minColumnWidth`, and lays its columns out right-to-left under an RTL `Directionality`
- `OiApp` without an explicit `locale` takes its text direction from the resolved device locale
- `OiLongPressMenu` is positioned with `OiFloating`: it stays on screen and takes its colours, radius and shadow from the theme

### Fixed

- Overlays: dialog crash when the overlay host rebuilt on a `MediaQuery` change; the hidden overlay asserting on covered routes; floating content dismissing when its own anchor was pressed; overlay position gap in the two-column layout
- `OiSegmentedControl` no longer crashes with fewer than two segments
- `OiSlider` animates without a `setState` per frame, and no longer exposes scroll and tap actions in its semantics
- `OiRawInput` enforces `maxLength`, keeps the selection valid on programmatic updates, and reuses the default text selection controls
- Text inputs: focus delay, text selection gestures, multi-line placeholder, the OTP focus indicator, and the layout shift caused by the focus border
- `OiInputFrame` gives slot icons a theme colour
- `OiSelect` pins its overlay when the dropdown is wider than the remaining space
- `OiButton`: icon-only buttons draw the variant's fill; per-state colours from `OiButtonVariantStyle` are honored
- `OiTouchTarget`: taps and drags that start in the padding reach the child, and the child is centred in the enlarged hit area
- `OiTable`: focus nodes are disposed, column headers follow their column's `textAlign`
- `OiGrid` re-measures stretched rows when a child grows
- `OiWizard` clamps the current step when the number of steps shrinks
- `OiFocusTrap` keeps Escape and Tab working when `initialFocus` is false
- Ctrl+Z is left to a focused text field
- `OiBanner` colours in the dark theme
- `OiSheet` autofocus
- `OiExportButton` menu had a transparent surface
- `obers_ui_autoforms`: field controllers are notified on form-level batch mutations
- `obers_ui_autoforms`: `OiAfForm` applies changed props (`enabled`, `validateMode`, `onSubmit`, `onSubmitResult`, `errorMapper`, …) to an already attached controller
- `obers_ui_autoforms`: a validation overtaken by a newer one no longer reports the field invalid, and a result for an old value no longer lands on a changed, hidden, disabled or reset field
- `obers_ui_autoforms`: `submit()` and a form-wide `validate()` only pass once every visible and enabled field has a verdict for its current value: fields that changed, were reset, rebased, or hidden and shown again while validators were running are validated again first
- `obers_ui_autoforms`: `rebase` and `restore(rebaseInitial)` re-evaluate `visibleWhen` / `enabledWhen` and derived fields; a derived value given in the map and a derived field the user overrode are kept
- `obers_ui_autoforms`: `integer`, `digitsBetween` and `multipleOf` no longer throw on NaN, infinity or a zero factor; `multipleOf` and `decimal` tolerate binary rounding (`multipleOf(0.1)` accepts 0.3)
- `obers_ui_charts`: `OiTileMap` wraps markers across the antimeridian and pins every visible world copy
- `OiCalendar`: week and day views dropped events shorter than an hour, events past midnight and events spanning the focused day
- `OiCalendar` and `OiGantt`: dates were repeated or a day off after a daylight-saving change (month grid, week numbers, navigation, bar and today-line positions)
- `OiGantt`: scrolling the timeline threw "ScrollController attached to multiple scroll views" and the header did not follow the body; a saved scroll position was never restored
- `OiThemeData.fromBrand` sets `colors.textOnPrimary` from the brand swatch, so a light brand colour gets dark text
- Keyboard insets no longer rebuild every tappable on each frame of the keyboard animation
- `OiStagger` no longer adds animation listeners on every frame
- A hidden `OiVisibility` child no longer receives taps or focus, and keeps its state with `transition: none`
- `OiOptimisticAction` rolls back and completes when `commit` throws an `Error`; a pending action no longer leaks into another app or test
- `OiApp` reuses and disposes one `HeroController`
- `OiGrid` no longer throws when the gaps are wider than the available width
- `OiResponsive` without a value for the smallest breakpoint falls back to the nearest larger one instead of throwing; equal instances have equal hash codes
- The `?` shortcut (`OiShortcutScopeState.helpActive`) works on real keyboards (it is Shift+/ on most layouts) and is left alone in text fields
- `OiDecorationTheme`, `OiFileExplorerThemeData` and `OiContextMenuThemeData` compare every field, and collections by content

### Removed

- A leftover diagnostic test for `OiAppShell` that only printed to stdout

## [0.1.2] - 2026-03-29

### Added

- Helper components: `OiStatusDot`, `OiKbd`, `OiPanelHeader`, `OiPropertyGrid`, `OiPageHeader` and `OiWorkflowTree`
- `OiScrollBehavior` and the library's own text selection controls

## [0.1.1] - 2026-03-29

### Added

- `obers_ui_autoforms` package: controller-first form handling (`OiAfForm`, `OiAfController`) with field wrappers, validation, derived fields and conditional visibility
- Modules: `OiSettingsPage`, `OiProfilePage`, `OiHelpCenter`, `OiOnboardingFlow`, `OiPricingTable`, `OiSubscriptionManager`, `OiSearchOverlay`, `OiMediaPicker`, `OiMaintenancePage`, `OiFeedbackSheet`, `OiConsentBanner`, `OiChangelogView`, `OiChatWindow`, `OiDevMenu` and `OiDrawerNavigation`
- Components: `OiMenuBar`, `OiStatusBar`, `OiFormSection`, `OiFilterableNavList`, `OiThreeColumnLayout`, `OiWorkflowStepper`, `OiPipelineProgress`, `OiColorPalettePicker` and `OiImagePreviewCard`

## [0.1.0] - 2026-03-28

### Added

- Initial package scaffold with directory structure
- Foundation: theme tokens, responsive breakpoints, accessibility helpers
- Primitives, components, composites and modules of the core library
- `obers_ui_charts` package with the chart foundation and chart composites
- Test infrastructure (widget tests, golden tests)
- Example catalog app
- GitHub Actions CI (analyze, test, golden tests, docs)
- Documentation setup (dartdoc, README, CONTRIBUTING)

### Changed

- `OiTappable.semanticLabel` now replaces what the child announces instead of being read before it, as documented. A tappable that wraps other controls or content the label does not cover should get its label from a `Semantics` wrapper instead

### Fixed

- `OiTappable` no longer rebuilds its child from scratch (losing its `State`) when it is pressed, focused with the keyboard, dragged, disabled or hovered with a halo theme
- `OiTappable` is announced as a button with its enabled state even without a `semanticLabel`, and offers no tap or long-press action to assistive technology while disabled
