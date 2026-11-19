# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Versions 0.1.0 to 0.1.2 were never tagged. Their sections are reconstructed
from the git history, using the commits that changed `version:` in
`pubspec.yaml` as the release boundaries.

## [Unreleased]

### Added

- `OiClockDial`: a clock face that picks a time of day by tapping the hour, then the minute (drag for the exact one)
- `OiSelect` opens its menu with the selected option in view instead of at the top
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
- `obers_ui_charts`: `OiTileMap` wraps markers across the antimeridian and pins every visible world copy

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
