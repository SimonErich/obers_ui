# Foundation (tier 0)

Overview: theme tokens, `OiApp`, global overlays, breakpoints, persistence, routing, scroll, selection UI, and accessibility helpers. [← Skill](../SKILL.md)

Paths are relative to `lib/src/foundation/`.

## Theme core


| Name                    | Path                                               | Role                                                            |
| ----------------------- | -------------------------------------------------- | --------------------------------------------------------------- |
| `OiThemeData`           | `theme/oi_theme_data.dart`                         | Light/dark/fromBrand factories and full token bundle            |
| `OiColorScheme`         | `theme/oi_color_scheme.dart`                       | Semantic color roles for surfaces and accents                   |
| `OiColorSwatch`         | `theme/oi_color_swatch.dart`                       | Multi-tone swatch (base/light/dark/muted/foreground)            |
| `OiTextTheme`           | `theme/oi_text_theme.dart`                         | Typography scale aligned to `OiLabel` variants                  |
| `OiSpacingScale`        | `theme/oi_spacing_scale.dart`                      | Named spacing tokens                                            |
| `OiRadiusScale`         | `theme/oi_radius_scale.dart`                       | Corner radii; pairs with `OiRadiusPreference` enum in same file |
| `OiShadowScale`         | `theme/oi_shadow_scale.dart`                       | Elevation shadows                                               |
| `OiDecorationTheme`     | `theme/oi_decoration_theme.dart`                   | Borders and dividers; `OiBorderLineStyle`                       |
| `OiEffectsTheme`        | `theme/oi_effects_theme.dart`                      | Blur and visual effects tokens                                  |
| `OiAnimationConfig`     | `theme/oi_animation_config.dart`                   | Durations/curves; `**OiPageTransitionType**` enum               |
| `OiComponentSizeScale`  | `theme/oi_component_size_scale.dart`               | Sizing tokens for dense layouts                                 |
| `OiComponentThemes`     | `theme/oi_component_themes.dart`                   | Aggregate of per-widget theme data                              |
| Per-widget `*ThemeData` | `theme/component_themes/*.dart`                    | Button, dialog, table, input, etc. overrides                    |
| `OiTheme` / scope       | `theme/oi_theme.dart`, `theme/oi_theme_scope.dart` | Inherited theme resolution                                      |


## App shell and density


| Name               | Path                      | Role                                                                                             |
| ------------------ | ------------------------- | ------------------------------------------------------------------------------------------------ |
| `OiApp`            | `oi_app.dart`             | Root app widget (replaces MaterialApp); `**OiThemeMode**`, `**OiDensity**`, `**OiDensityScope**` |
| `OiScrollBehavior` | `oi_scroll_behavior.dart` | Scroll physics and overscroll behavior                                                           |


## Overlays and global UI


| Name         | Path               | Role                                            |
| ------------ | ------------------ | ----------------------------------------------- |
| `OiOverlays` | `oi_overlays.dart` | Z-order and overlay host; `**OiOverlayZOrder**` |
| `OiSpan`     | `oi_span.dart`     | Text span helper for themed rich text           |


## Responsive and platform


| Name                      | Path                              | Role                                                                           |
| ------------------------- | --------------------------------- | ------------------------------------------------------------------------------ |
| `OiResponsive`            | `oi_responsive.dart`              | Breakpoints, `OiResponsive<T>`, width/height helpers; `**OiHeightBreakpoint**` |
| `OiPlatform`              | `oi_platform.dart`                | Platform-style hints                                                           |
| `OiInputModalityDetector` | `oi_input_modality_detector.dart` | Pointer vs keyboard modality; `**OiInputModality**`                            |


## Interaction support


| Name                      | Path                              | Role                                         |
| ------------------------- | --------------------------------- | -------------------------------------------- |
| `OiAccessibility`         | `oi_accessibility.dart`           | Announcements and a11y helpers               |
| `OiOptimisticAction`      | `oi_optimistic_action.dart`       | Optimistic UI with rollback snackbar pattern |
| `OiUndoStack`             | `oi_undo_stack.dart`              | Local undo stack                             |
| `OiShortcutScope`         | `oi_shortcut_scope.dart`          | Registers keyboard shortcuts subtree         |
| `OiTourScope`             | `oi_tour_scope.dart`              | Coordinates guided tour hooks                |
| `OiSearchDebounce`        | `oi_search_debounce.dart`         | Debounced search notifier                    |
| `OiTextSelectionControls` | `oi_text_selection_controls.dart` | Custom selection toolbar builder             |


## Persistence (settings)


| Name                   | Path                                               | Role                               |
| ---------------------- | -------------------------------------------------- | ---------------------------------- |
| `OiSettingsDriver`     | `persistence/oi_settings_driver.dart`              | Abstract settings I/O              |
| `OiSettingsData`       | `persistence/oi_settings_data.dart`                | Base type for persisted blobs      |
| `OiSettingsProvider`   | `persistence/oi_settings_provider.dart`            | Inherited settings scope           |
| `OiSettingsMixin`      | `persistence/oi_settings_mixin.dart`               | Mixin for widget state persistence |
| `OiLocalStorageDriver` | `persistence/drivers/oi_local_storage_driver.dart` | File-backed driver                 |
| `OiInMemoryDriver`     | `persistence/drivers/oi_in_memory_driver.dart`     | Ephemeral driver for tests         |


## Navigation


| Name               | Path                 | Role                                        |
| ------------------ | -------------------- | ------------------------------------------- |
| `OiPageRoute`      | `oi_page_route.dart` | Custom page route                           |
| `OiTransitionPage` | `oi_page_route.dart` | Declarative page with transition from theme |


## Icons (registry only)


| Name         | Path                      | Role                                                                                    |
| ------------ | ------------------------- | --------------------------------------------------------------------------------------- |
| `OiIcons`    | `oi_icons.dart`           | Lucide-backed icon constants (detail in [models-tools-icons.md](models-tools-icons.md)) |
| `OiIconData` | `icons/oi_icon_data.dart` | Icon descriptor type                                                                    |


## Chart scales (foundation)


| Name        | Path            | Role                                                           |
| ----------- | --------------- | -------------------------------------------------------------- |
| Scale types | `scales/*.dart` | Linear, log, time, band, threshold, etc. for chart integration |


## Hover detection (internal)

| `_hover_detect_*` | `_hover_detect_*.dart` | Platform-specific hover stubs; not part of public API surface |