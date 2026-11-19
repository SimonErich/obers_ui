# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - Unreleased

### Added

- `OiTappable`: `role` (`OiTappableRole`), `checked`, `mixed`, `toggled`, `selected`, `expanded`, `inMutuallyExclusiveGroup`, `onKeyEvent` and `skipTraversal`, so toggles, tabs and disclosure headers can be built on it
- `OiClockDial`: a clock face that picks a time of day by tapping the hour, then the minute (drag for the exact one)
- `OiSelect` opens its menu with the selected option in view instead of at the top
- Initial package scaffold with directory structure
- Test infrastructure (widget tests, golden tests)
- Example catalog app
- GitHub Actions CI (analyze, test, golden tests, docs)
- Documentation setup (dartdoc, README, CONTRIBUTING)

### Changed

- `OiTappable.semanticLabel` now replaces what the child announces instead of being read before it, as documented. A tappable that wraps other controls or content the label does not cover should get its label from a `Semantics` wrapper instead

### Fixed

- `OiTappable` no longer rebuilds its child from scratch (losing its `State`) when it is pressed, focused with the keyboard, dragged, disabled or hovered with a halo theme
- `OiTappable` is announced as a button with its enabled state even without a `semanticLabel`, and offers no tap or long-press action to assistive technology while disabled
