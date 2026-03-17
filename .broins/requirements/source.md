# obers_ui — Complete Library Specification v4

> **Date:** 2026-03-16
> **Package:** `obers_ui`
> **Widget prefix:** `Oi`
> **Scope:** Standalone Flutter UI library. Zero Material, zero shadcn_ui.

---

## Table of Contents

- [Naming & Conventions](#naming--conventions)
- [Package Structure](#package-structure)
- [Theming System](#theming-system)
- [Accessibility Enforcement](#accessibility-enforcement)
- [Composition Map](#composition-map)
- [Tier 0: Foundation](#tier-0-foundation)
- [Tier 1: Primitives](#tier-1-primitives)
- [Tier 2: Components](#tier-2-components)
- [Tier 3: Composites](#tier-3-composites)
- [Tier 4: Modules](#tier-4-modules)
- [Testing Strategy](#testing-strategy)

---

# Naming & Conventions

**Prefix:** Every public widget, class, enum, and extension uses the `Oi` prefix.

**Rules:**
1. Name by what it _is_ in the UI. `OiTable`, `OiButton`, `OiSidebar`.
2. Props read like English. `multiSelect: true`, `reorderColumns: true`, `stickyHeader: true`.
3. Required props enforce correctness. Images require `alt`, buttons require `label`.
4. Factories for variants. `OiButton.primary()`, `OiButton.ghost()`, `OiButton.split()`.
5. Callbacks are verbs. `onTap`, `onSave`, `onSort`, `onReorder`.
6. Booleans are descriptive. `enabled`, `dismissible`, `searchable`, `loading`.

---

# Package Structure

```
packages/
  obers_ui/
    lib/
      obers_ui.dart                              # Barrel export

      src/
        foundation/
          theme/
            oi_theme.dart                        # InheritedWidget provider
            oi_theme_data.dart                   # Master theme container
            oi_color_scheme.dart                 # Color tokens
            oi_color_swatch.dart                 # Color with shades
            oi_text_theme.dart                   # Typography
            oi_spacing_scale.dart
            oi_radius_scale.dart
            oi_shadow_scale.dart
            oi_animation_config.dart
            oi_effects_theme.dart                # Halo, hover, focus, active
            oi_decoration_theme.dart             # Gradients, borders
            oi_component_themes.dart             # Per-component overrides
          oi_app.dart
          oi_overlays.dart
          oi_undo_stack.dart
          oi_responsive.dart
          oi_accessibility.dart

        primitives/
          interaction/
            oi_tappable.dart
            oi_focus_trap.dart
          display/
            oi_label.dart
            oi_icon.dart
            oi_surface.dart
            oi_divider.dart
            oi_image.dart
          input/
            oi_raw_input.dart
          layout/
            oi_row.dart
            oi_column.dart
            oi_wrap_layout.dart
            oi_grid.dart
            oi_masonry.dart
            oi_aspect_ratio.dart
            oi_spacer.dart
            oi_container.dart
          overlay/
            oi_floating.dart
            oi_portal.dart
            oi_visibility.dart
          scroll/
            oi_scrollbar.dart
            oi_virtual_list.dart
            oi_virtual_grid.dart
            oi_infinite_scroll.dart
          gesture/
            oi_pinch_zoom.dart
            oi_swipeable.dart
            oi_long_press_menu.dart
            oi_double_tap.dart
          drag_drop/
            oi_draggable.dart
            oi_drop_zone.dart
            oi_drag_ghost.dart
            oi_reorderable.dart
          clipboard/
            oi_copyable.dart
            oi_copy_button.dart
            oi_paste_zone.dart
          animation/
            oi_animated_list.dart
            oi_stagger.dart
            oi_shimmer.dart
            oi_pulse.dart
            oi_morph.dart
            oi_spring.dart

        components/
          buttons/
            oi_button.dart
            oi_icon_button.dart
            oi_toggle_button.dart
            oi_button_group.dart
          inputs/
            oi_text_input.dart
            oi_number_input.dart
            oi_date_input.dart
            oi_time_input.dart
            oi_select.dart
            oi_tag_input.dart
            oi_checkbox.dart
            oi_switch.dart
            oi_radio.dart
            oi_slider.dart
            oi_color_input.dart
            oi_file_input.dart
          inline_edit/
            oi_editable.dart
            oi_editable_text.dart
            oi_editable_select.dart
            oi_editable_date.dart
            oi_editable_number.dart
          display/
            oi_card.dart
            oi_badge.dart
            oi_avatar.dart
            oi_tooltip.dart
            oi_popover.dart
            oi_list_tile.dart
            oi_metric.dart
            oi_progress.dart
            oi_code_block.dart
            oi_diff_view.dart
            oi_markdown.dart
            oi_empty_state.dart
            oi_skeleton_group.dart
          feedback/
            oi_star_rating.dart
            oi_scale_rating.dart
            oi_thumbs.dart
            oi_reaction_bar.dart
            oi_sentiment.dart
          overlays/
            oi_dialog.dart
            oi_toast.dart
            oi_context_menu.dart
            oi_sheet.dart
          navigation/
            oi_tabs.dart
            oi_accordion.dart
            oi_breadcrumbs.dart
            oi_date_picker.dart
            oi_time_picker.dart
            oi_emoji_picker.dart
            oi_bottom_bar.dart
            oi_drawer.dart
          panels/
            oi_resizable.dart
            oi_split_pane.dart
            oi_panel.dart

        composites/
          data/
            oi_table.dart
            oi_tree.dart
          forms/
            oi_form.dart
            oi_wizard.dart
            oi_stepper.dart
          search/
            oi_combo_box.dart
            oi_search.dart
            oi_command_bar.dart
          editors/
            oi_smart_input.dart
            oi_rich_editor.dart
          navigation/
            oi_sidebar.dart
            oi_nav_menu.dart
            oi_filter_bar.dart
            oi_shortcuts.dart
            oi_arrow_nav.dart
          social/
            oi_avatar_stack.dart
            oi_cursor_presence.dart
            oi_selection_presence.dart
            oi_typing_indicator.dart
            oi_live_ring.dart
          onboarding/
            oi_tour.dart
            oi_spotlight.dart
            oi_whats_new.dart
          scheduling/
            oi_gantt.dart
            oi_calendar.dart
            oi_scheduler.dart
            oi_timeline.dart
          workflow/
            oi_flow_graph.dart
            oi_state_diagram.dart
            oi_pipeline.dart
          visualization/
            oi_heatmap.dart
            oi_treemap.dart
            oi_sankey.dart
            oi_radar_chart.dart
            oi_funnel_chart.dart
            oi_gauge.dart
          media/
            oi_image_cropper.dart
            oi_lightbox.dart
            oi_gallery.dart
            oi_image_annotator.dart
            oi_video_player.dart

        modules/
          oi_list_view.dart
          oi_activity_feed.dart
          oi_metadata_editor.dart
          oi_comments.dart
          oi_kanban.dart
          oi_chat.dart
          oi_file_manager.dart
          oi_permissions.dart
          oi_dashboard.dart
          oi_notification_center.dart

        tools/
          oi_dynamic_theme.dart
          oi_theme_preview.dart
          oi_theme_exporter.dart
          oi_playground.dart

        utils/
          formatters.dart
          color_utils.dart
          calendar_utils.dart
          file_utils.dart
          fuzzy_search.dart
          spring_physics.dart
```

---

# Composition Map

This defines which widgets compose from which. The goal: never reimplement complex logic. Higher-tier widgets wrap lower-tier ones.

```
OiTappable
 ├── OiButton (wraps OiTappable for tap/hover/focus/active states)
 │    ├── OiIconButton (is OiButton.icon variant)
 │    ├── OiButtonGroup (renders multiple OiButton in a row)
 │    └── OiToggleButton (is OiButton with selected state)
 ├── OiListTile (wraps OiTappable for rows)
 ├── OiCard (wraps OiTappable when interactive)
 ├── OiTab (internal, wraps OiTappable)
 └── OiBreadcrumbItem (internal, wraps OiTappable)

OiSurface
 ├── OiCard (is an OiSurface with title/footer/elevation)
 ├── OiDialog (is an OiSurface inside an overlay)
 ├── OiSheet (is an OiSurface that slides in)
 ├── OiPanel (is an OiSurface that slides from side)
 ├── OiToast (is an OiSurface with auto-dismiss)
 ├── OiPopover (is an OiSurface positioned by OiFloating)
 ├── OiTooltip (is a small OiSurface positioned by OiFloating)
 └── OiContextMenu (is an OiSurface positioned at cursor)

OiRawInput
 ├── OiTextInput (wraps OiRawInput with label, border, error, hint)
 │    ├── OiNumberInput (is OiTextInput with number formatting + stepper)
 │    └── OiTextInput.search (is OiTextInput with search icon + debounce)
 ├── OiComboBox (wraps OiRawInput + OiPopover + OiVirtualList)
 ├── OiSelect (wraps OiTappable trigger + OiPopover + list)
 ├── OiSmartInput (wraps OiRawInput with highlighting controller)
 ├── OiTagInput (wraps OiRawInput + inline chips)
 └── OiRichEditor (wraps flutter_quill with OiRawInput-like interface)

OiFloating (overlay positioning engine)
 ├── OiTooltip (uses OiFloating to position)
 ├── OiPopover (uses OiFloating to position)
 ├── OiContextMenu (uses OiFloating at cursor position)
 ├── OiSelect dropdown (uses OiFloating anchored to trigger)
 ├── OiComboBox dropdown (uses OiFloating anchored to input)
 ├── OiDatePicker popup (uses OiFloating anchored to input)
 └── OiTimePicker popup (uses OiFloating anchored to input)

OiReorderable
 ├── OiKanban cards (uses OiReorderable within columns + OiDraggable/OiDropZone between columns)
 ├── OiTable column reorder (uses OiReorderable on header row)
 ├── OiTree drag-to-reparent (uses OiDraggable + OiDropZone per node)
 ├── OiNavMenu item reorder (uses OiReorderable)
 └── OiTagInput tag reorder (uses OiReorderable)

OiVirtualList
 ├── OiTable rows (uses OiVirtualList when virtualScroll=true)
 ├── OiTree nodes (uses OiVirtualList when virtualScroll=true)
 ├── OiComboBox dropdown items (uses OiVirtualList when virtualScroll=true)
 ├── OiChat messages (uses OiVirtualList)
 ├── OiActivityFeed items (uses OiVirtualList)
 └── OiGallery grid (uses OiVirtualGrid)

OiEditable (generic inline edit wrapper)
 ├── OiEditableText (display text → OiTextInput on click)
 ├── OiEditableSelect (display value → OiSelect on click)
 ├── OiEditableDate (display date → OiDatePicker on click)
 ├── OiEditableNumber (display number → OiNumberInput on click)
 └── OiTable inline cell editing (uses OiEditable per cell)

OiInfiniteScroll
 ├── OiTable pagination (wraps table in OiInfiniteScroll)
 ├── OiComboBox "load more" (uses OiInfiniteScroll in dropdown)
 ├── OiActivityFeed (wraps feed in OiInfiniteScroll)
 └── OiChat (wraps message list in OiInfiniteScroll)

OiDialog
 ├── OiWizard (can render inside OiDialog)
 ├── OiLightbox (is a full-screen OiDialog variant)
 └── OiImageCropper (renders inside OiDialog)

OiSheet
 ├── OiDrawer (is an OiSheet from left/right side)
 └── OiPanel (is an OiSheet variant with resize)

OiProgress
 ├── OiStepper (uses OiProgress.steps internally)
 ├── OiWizard step indicator (uses OiStepper which uses OiProgress)
 └── OiFileInput upload progress (uses OiProgress.linear)

OiFocusTrap
 ├── OiDialog (traps focus)
 ├── OiSheet (traps focus)
 ├── OiCommandBar (traps focus)
 └── OiSearch (traps focus)

OiShimmer
 ├── OiSkeletonGroup (composes multiple OiShimmer shapes)
 ├── OiCard skeleton mode (shows OiShimmer)
 ├── OiListTile skeleton mode (shows OiShimmer)
 └── OiAvatar skeleton mode (shows OiShimmer circle)

OiAnimatedList
 ├── OiToast stack (animates toasts in/out)
 ├── OiNotificationCenter (animates notifications in/out)
 └── OiTagInput chips (animates add/remove)

OiStagger
 ├── OiNavMenu items (stagger animation on load)
 ├── OiDashboard cards (stagger animation)
 └── OiCommandBar results (stagger in)

OiArrowNav
 ├── OiSelect options (arrow keys navigate)
 ├── OiComboBox results (arrow keys navigate)
 ├── OiCommandBar items (arrow keys navigate)
 ├── OiContextMenu items (arrow keys navigate)
 ├── OiTable rows (arrow keys navigate)
 └── OiTree nodes (arrow keys navigate)

OiCopyable + OiCopyButton
 ├── OiCodeBlock copy button (uses OiCopyButton)
 ├── OiMetric copy value (wraps in OiCopyable)
 └── OiTextInput copy icon (optional trailing OiCopyButton)
```

---

# Theming System

## OiThemeData

```dart
class OiThemeData {
  final OiColorScheme colors;
  final OiTextTheme text;
  final OiSpacingScale spacing;
  final OiRadiusScale radius;
  final OiShadowScale shadows;
  final OiAnimationConfig animation;
  final OiEffectsTheme effects;
  final OiDecorationTheme decoration;
  final OiComponentThemes components;

  factory OiThemeData.light();
  factory OiThemeData.dark();
  factory OiThemeData.fromBrand({
    required Color color,
    Brightness brightness = Brightness.light,
    String? fontFamily,
    OiRadiusPreference radiusPreference = OiRadiusPreference.medium,
  });

  OiThemeData copyWith({...});
  OiThemeData merge(OiThemeData other);
}
```

## OiColorScheme

```dart
class OiColorScheme {
  final Color background;
  final Color surface;
  final Color surfaceHover;
  final Color surfaceActive;
  final Color surfaceSubtle;
  final Color overlay;

  final Color text;
  final Color textSubtle;
  final Color textMuted;
  final Color textInverse;
  final Color textOnPrimary;

  final Color border;
  final Color borderSubtle;
  final Color borderFocus;
  final Color borderError;

  final OiColorSwatch primary;
  final OiColorSwatch accent;
  final OiColorSwatch success;
  final OiColorSwatch warning;
  final OiColorSwatch error;
  final OiColorSwatch info;

  final List<Color> chart;

  final Color glassBackground;
  final Color glassBorder;
}

class OiColorSwatch {
  final Color base;
  final Color light;
  final Color dark;
  final Color muted;
  final Color foreground;
}
```

## OiEffectsTheme

```dart
class OiEffectsTheme {
  final OiHaloStyle? halo;
  final OiHaloStyle? haloFocus;
  final OiHaloStyle? haloError;

  final OiInteractiveStyle hover;
  final OiInteractiveStyle focus;
  final OiInteractiveStyle active;
  final OiInteractiveStyle disabled;
  final OiInteractiveStyle dragging;
  final OiInteractiveStyle selected;

  final Duration stateTransition;
  final Curve stateTransitionCurve;
}

class OiHaloStyle {
  final Color color;
  final double blur;
  final double spread;
  final double opacity;
  final Offset offset;
  BoxShadow toBoxShadow();
  factory OiHaloStyle.from(Color color, {double intensity = 1.0});
}

class OiInteractiveStyle {
  final Color? backgroundOverride;
  final Color? backgroundOverlay;
  final Color? borderColor;
  final Color? textColor;
  final double? opacity;
  final double? scale;
  final Offset? translate;
  final double? elevationDelta;
  final OiHaloStyle? halo;
  final OiBorderStyle? border;
  final OiGradientStyle? gradient;
  final MouseCursor? cursor;
  OiInteractiveStyle merge(OiInteractiveStyle base);
}
```

## OiDecorationTheme

```dart
class OiDecorationTheme {
  final OiGradientStyle? surfaceGradient;
  final OiGradientStyle? cardGradient;
  final OiGradientStyle? pageGradient;

  final OiBorderStyle? surfaceBorder;
  final OiBorderStyle? cardBorder;
  final OiBorderStyle? inputBorder;

  final Map<Type, OiGradientStyle>? componentGradients;
  final Map<Type, OiBorderStyle>? componentBorders;
}

class OiGradientStyle {
  final List<Color> colors;
  final List<double>? stops;
  final OiGradientType type;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  Gradient toGradient();
  factory OiGradientStyle.linear(List<Color> colors, {AlignmentGeometry begin, AlignmentGeometry end});
  factory OiGradientStyle.radial(List<Color> colors, {double radius});
}

class OiBorderStyle {
  final Color? color;
  final double width;
  final OiBorderLineStyle style;
  final double? dashLength;
  final double? dashGap;
  final OiGradientStyle? gradient;
  final BorderRadius? radius;
  factory OiBorderStyle.solid({Color color, double width});
  factory OiBorderStyle.dashed({Color color, double width, double dashLength, double dashGap});
  factory OiBorderStyle.dotted({Color color, double width});
  factory OiBorderStyle.gradient({required OiGradientStyle gradient, double width});
  factory OiBorderStyle.none();
}

enum OiBorderLineStyle { solid, dashed, dotted, double_, gradient, none }
```

## OiComponentThemes

```dart
class OiComponentThemes {
  final OiButtonThemeData? button;
  final OiTextInputThemeData? textInput;
  final OiSelectThemeData? select;
  final OiCardThemeData? card;
  final OiDialogThemeData? dialog;
  final OiToastThemeData? toast;
  final OiTooltipThemeData? tooltip;
  final OiTableThemeData? table;
  final OiTabsThemeData? tabs;
  final OiBadgeThemeData? badge;
  final OiCheckboxThemeData? checkbox;
  final OiSwitchThemeData? switchTheme;
  final OiSheetThemeData? sheet;
  final OiAvatarThemeData? avatar;
  final OiProgressThemeData? progress;
  final OiSidebarThemeData? sidebar;
  // ... one per Tier 2+ component
}
```

## Theme Access

```dart
extension OiThemeExt on BuildContext {
  OiThemeData get theme => OiTheme.of(this);
  OiColorScheme get colors => OiTheme.of(this).colors;
  OiTextTheme get textTheme => OiTheme.of(this).text;
  OiSpacingScale get spacing => OiTheme.of(this).spacing;
  OiEffectsTheme get effects => OiTheme.of(this).effects;
}
```

## Theme Scoping

```dart
// Override entire theme for a subtree
OiThemeScope(theme: OiThemeData.dark(), child: MyDarkSection())

// Override one component's theme for a subtree
OiButtonThemeScope(theme: OiButtonThemeData(height: 48), child: MyArea())
```

---

# Accessibility Enforcement

1. **OiImage** requires `alt`. Use `OiImage.decorative()` to explicitly opt out.
2. **OiButton** (all variants including `.icon()`) requires `label`.
3. **OiIcon** requires `label`. Use `OiIcon.decorative()` to opt out.
4. **Every overlay/dialog/panel** requires `label` for screen reader announcement.
5. **Every data widget** (OiTable, OiTree, etc.) requires `label`.
6. Focus ring is always visible — restyled via theme, never disabled.
7. All animations check `OiAnimationConfig.reducedMotion`.
8. Color is never the sole indicator — semantic states always include icon or text.
9. All keyboard shortcuts have labels, auto-registered in command bar and help dialog.
10. All `OiTappable` elements are focusable, activatable via Enter/Space.

```dart
class OiA11y {
  static void announce(String message, {bool assertive = false});
  static bool reducedMotion(BuildContext context);
  static bool highContrast(BuildContext context);
  static double textScale(BuildContext context);
  static bool boldText(BuildContext context);
  static double get minTouchTarget;  // 48.0 on touch, 0.0 on pointer
}
```

**Responsive Behavior:**
- **Touch target enforcement:** `OiA11y.minTouchTarget` returns 48.0 on touch devices and 0.0 on pointer devices. All interactive widgets check this value to ensure their hit area meets the minimum. This is enforced in `OiTappable` and inherited by every interactive widget.
- **Text scaling:** `OiA11y.textScale(context)` returns the system text scale factor. Widgets must not clip or overflow at text scales up to 200%. Critical widgets (buttons, inputs, tabs) should grow their height to accommodate scaled text rather than truncating. Non-critical widgets (badges, compact metrics) may clamp text scale at 150% with a maximum font size to prevent layout breakage.
- **Bold text:** `OiA11y.boldText(context)` detects when the system bold text preference is active (iOS "Bold Text" setting). When true, `OiTextTheme` adjusts weights — `body` becomes `bodyStrong`, `small` becomes `smallStrong`.
- **High contrast per platform:** On Windows, high contrast mode is detected via `MediaQuery.highContrast`. On macOS/iOS, "Increase Contrast" is detected. When active, all borders increase to 2px minimum, color contrast ratios are elevated, and subtle backgrounds become more distinct.
- **Reduced motion per platform:** Respects `MediaQuery.disableAnimations` (iOS "Reduce Motion") and `prefers-reduced-motion` on web. When active, all animations complete instantly — no spring physics, no stagger delays, no shimmer loops.
- **Focus ring adaptation:** Focus rings are always visible when keyboard navigation is active. On touch-only interaction (no keyboard attached), focus rings may be suppressed to reduce visual noise — but reappear immediately when a keyboard event is detected.
- **Screen reader platform differences:** On iOS (VoiceOver), semantic actions use iOS gestures. On Android (TalkBack), semantic actions use Android conventions. On web, ARIA roles and live regions are used. The library does not need to handle this directly (Flutter's `Semantics` widget abstracts it), but test cases must verify on each platform.

**Responsive Tests:**
| Test | What it verifies |
|------|-----------------|
| All interactive widgets have 48x48 minimum hit area on touch | Touch target enforcement |
| Text at 200% system scale does not overflow button | Buttons grow height |
| Text at 200% system scale does not overflow input | Inputs grow height |
| Text at 200% system scale remains readable in badge | Clamped at 150% max |
| Bold text preference applies heavier weights | FontWeight increases |
| High contrast mode increases border width to 2px | Border thickens |
| High contrast mode elevates color contrast | Stronger distinction |
| Reduced motion disables all animations | Instant transitions |
| Focus ring hidden on touch-only, shown on keyboard | Adaptive focus ring |
| Screen reader announces on iOS VoiceOver | Platform semantics |
| Screen reader announces on Android TalkBack | Platform semantics |
| Screen reader uses ARIA live regions on web | Web semantics |

---

# Tier 0: Foundation

---

## OiApp

**What it is:** The root widget for any obers_ui application. Replaces `MaterialApp` / `CupertinoApp` / `ShadApp`. Wraps `WidgetsApp.router()` and injects all obers_ui systems into the widget tree.

**What it does:**
- Provides `OiTheme` (cascading InheritedWidget)
- Provides `OiOverlays` (global overlay rendering layer)
- Provides `OiUndoStack` (global undo/redo)
- Provides `OiShortcutScope` (global keyboard shortcuts — Ctrl+Z undo, Ctrl+K command bar, ? help)
- Provides `OiTourScope` (onboarding tour system)
- Provides `OiA11yScope` (accessibility settings: reduced motion, high contrast, text scale)
- Handles theme mode switching (light/dark/system)
- Handles locale + directionality

**Composes:** `WidgetsApp.router()`, `OiTheme`, `OiOverlays`, `OiUndoStack`, `OiShortcutScope`

**Props:**
```dart
OiApp({
  required OiThemeData theme,
  OiThemeData? darkTheme,
  ThemeMode themeMode = ThemeMode.system,
  required RouterConfig<Object> routerConfig,
  Locale? locale,
  List<Locale> supportedLocales = const [Locale('en')],
  Widget Function(BuildContext, Widget?)? builder,
  String title = '',
})
```

**States:** Theme mode (light/dark/system). No other interactive state — this is infrastructure.

**Considerations:**
- Must be the top-level widget. Nothing from obers_ui works without it.
- `builder` runs after theme injection but before overlays, so overlays render on top of anything from builder.
- If `darkTheme` is null, `theme` is used for both modes.

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Renders child via routerConfig | App boots and shows first route |
| OiTheme.of(context) returns theme data | Theme InheritedWidget is injected |
| OiOverlays.of(context) is available | Overlay system is injected |
| OiUndoStack.of(context) is available | Undo system is injected |
| Theme mode switching | Changing themeMode updates OiTheme.of(context).colors |
| Dark theme fallback | When darkTheme is null, theme is used in dark mode |
| Builder wraps content | Custom builder receives child |
| Reduced motion propagation | MediaQuery.disableAnimations flows to OiAnimationConfig |
| Ctrl+Z invokes undo | Global shortcut is registered |
| Locale propagation | Directionality matches locale |
| Safe area applied on notched device | Content below notch/status bar |
| OiPlatform injected with correct values | Platform InheritedWidget available |
| Cmd+Z invokes undo on macOS | Platform-mapped shortcut |
| Orientation change triggers rebuild | Portrait ↔ landscape handled |
| Keyboard visibility updates OiPlatformData | isKeyboardVisible reflects state |
| System back gesture (Android) navigates back | Back gesture integrated |
| OiPerformanceConfig.auto detects device tier | Correct performance tier |

**Responsive Behavior:**
- **Safe area handling:** `OiApp` wraps content in `SafeArea` by default. Injects `OiPlatformData.safeArea` from `MediaQuery.of(context).padding` so all descendants can access notch/status bar/home indicator insets. Expose `safeArea: false` prop to opt out.
- **Platform injection:** `OiApp` injects `OiPlatform` InheritedWidget providing `OiPlatformData` (see global Responsive section). This is the source of truth for `isTouch`, `isMobile`, `isDesktop`, `isWeb`, `orientation`, `keyboardHeight`, etc.
- **Keyboard shortcut mapping:** All global shortcuts use `OiShortcutActivator` which auto-maps `Ctrl` → `Cmd` on macOS/iOS. `Ctrl+Z` → `Cmd+Z`, `Ctrl+K` → `Cmd+K`, etc.
- **Orientation handling:** `OiApp` monitors orientation changes and propagates to `OiPlatformData.orientation`. Widgets can use `context.orientation` to adapt layout.
- **System back gesture:** On Android, the system back gesture/button dismisses the topmost overlay (via `OiOverlays`) or triggers `Navigator.pop`. On iOS, swipe-from-left-edge navigates back. `OiApp` integrates with `PopScope` / `BackButtonListener`.
- **Performance config:** `OiApp` accepts `OiPerformanceConfig` (defaults to `auto`) which auto-detects device capability and degrades glass/blur/shadow/animation effects on low-end devices.
- **System UI overlay style:** On mobile, `OiApp` sets status bar and navigation bar colors/brightness to match the current theme (light icons on dark theme, dark icons on light theme).
- **Display density:** `OiApp` injects `OiDensity` (defaults to `comfortable` on touch, `compact` on pointer). Can be overridden via `density` prop.
- **Browser viewport:** On web, `OiApp` handles dynamic viewport height changes (mobile browser URL bar show/hide) without layout jumps.

---

## OiOverlays

**What it is:** A singleton service managing all overlay types (dialogs, toasts, panels, sheets, popovers, context menus, command bar, search). Accessible with context via `OiOverlays.of(context)`.

**What it does:**
- Maintains a `Stack` + `Overlay` at the root of the widget tree (inside `OiApp`)
- All overlays render into this single layer — no `Navigator.push` or `Overlay.of(context)` fragmentation
- Returns `OiOverlayHandle` for programmatic control of each overlay
- Manages z-ordering (toasts above panels above dialogs)
- Manages backdrop/barrier rendering
- Handles ESC key dismissal of the topmost dismissible overlay

**Composes:** Flutter `Overlay`, `AnimatedBuilder`, `OiFocusTrap`

**API:**
```dart
class OiOverlays {
  OiOverlayHandle panel({required WidgetBuilder content, required String label, OiPanelSide side, double width, bool dismissible, bool resizable});
  OiOverlayHandle sheet({required WidgetBuilder content, required String label, double initialSize, List<double> snapPoints, bool dismissible, bool showHandle});
  Future<T?> dialog<T>({required WidgetBuilder content, required String label, bool dismissible});
  OiOverlayHandle toast({required String title, String? description, OiToastLevel level, Duration duration, Widget? action, OiToastPosition position});
  OiOverlayHandle commandBar({required List<OiCommand> commands});
  OiOverlayHandle search({required List<OiSearchSource> sources});
  OiOverlayHandle popover({required GlobalKey anchor, required WidgetBuilder content, OiAlignment alignment});
  OiOverlayHandle contextMenu({required Offset position, required List<OiMenuItem> items});
  void dismissAll();
}

class OiOverlayHandle {
  void dismiss();
  bool get active;
  Future<void> get dismissed;
}
```

**States:** Each overlay has: appearing, visible, dismissing, dismissed. Managed internally via AnimationController.

**Considerations:**
- All `label` parameters are required for screen reader announcements.
- `dialog` returns `Future<T?>` — resolves when dialog is closed.
- `toast` auto-dismisses after `duration`. Multiple toasts stack.
- `panel` and `sheet` can coexist (panel on right, sheet from bottom).
- ESC dismisses the topmost overlay, not all overlays.
- Clicking barrier dismisses the topmost dismissible overlay.

**Tests:**
| Test | What it verifies |
|------|-----------------|
| dialog renders in overlay | Content appears above main tree |
| dialog returns result | `dialog<String>()` resolves with value on close |
| dialog traps focus | Tab key cycles within dialog |
| toast auto-dismisses | Toast disappears after duration |
| toast stacking | Multiple toasts stack vertically |
| toast action callback | Tapping action widget fires callback |
| panel slides in from side | Animation plays, content renders |
| panel dismissible | Tapping outside dismisses when dismissible=true |
| panel resizable | Drag edge resizes panel |
| sheet snap points | Dragging snaps to defined snap points |
| ESC dismisses topmost | With dialog over panel, ESC closes dialog only |
| dismissAll clears everything | All overlays removed |
| OiOverlayHandle.dismiss works | Specific overlay dismissed |
| OiOverlayHandle.active reports correctly | active=true while visible, false after dismiss |
| Screen reader announces overlay | label is announced via SemanticsService on show |
| Barrier click dismisses | Clicking barrier calls dismiss |
| Z-order is correct | Toast renders above panel above dialog |
| Multiple panels coexist | Left + right panel both visible |
| Popover positions correctly | Anchored to target widget |
| Context menu at cursor | Renders at Offset position |
| Dialog full-screen on compact breakpoint | Full-screen presentation on phone |
| Dialog centered modal on expanded+ | Standard modal with maxWidth |
| Toast default position bottom on touch, top-right on pointer | Platform-aware default |
| Toast respects bottom safe area | Not obscured by home indicator |
| Sheet respects bottom safe area on notched device | Content above home indicator |
| Popover becomes bottom sheet on compact | Sheet presentation on phone |
| Context menu via long-press on touch | Touch trigger instead of right-click |
| Panel swipe-to-dismiss on touch | Swipe gesture dismisses |
| Android back button/gesture dismisses topmost overlay | System back integration |
| Overlay repositions when keyboard appears | Not obscured by virtual keyboard |

**Responsive Behavior:**
- **Dialog adaptation:** On `compact` breakpoint, `OiOverlays.dialog()` renders as a full-screen or near-full-screen bottom sheet instead of a centered modal. On `expanded+`, renders as a centered modal constrained by `maxWidth` (default 560dp). The transition between these presentations is automatic based on breakpoint.
- **Toast positioning:** Default toast position is `bottomCenter` on touch devices (above home indicator safe area) and `topRight` on pointer devices. The `position` parameter can override this default.
- **Sheet safe area:** Bottom sheets automatically add bottom safe area padding so content is not obscured by the home indicator. The drag handle area extends into safe area, but interactive content does not.
- **Popover → Sheet:** On `compact` breakpoint, `OiOverlays.popover()` automatically presents as a bottom `OiSheet` instead of a floating popover. The `anchorKey` is still used for the opening animation origin point. On `expanded+`, standard floating behavior.
- **Context menu trigger:** On touch devices, `OiOverlays.contextMenu()` is triggered via long-press (300ms) instead of right-click. The menu appears centered on the long-press point, offset slightly upward so the finger doesn't obscure it.
- **Panel adaptation:** On `compact`, panels expand to full viewport width (minus safe area). On `expanded+`, panels use their configured `width`. On touch, panels support swipe-to-dismiss gesture (swipe toward the edge they came from).
- **Keyboard avoidance:** When the virtual keyboard appears, all active overlays reposition. Sheets shrink their content area. Dialogs scroll if content exceeds available height. Floating popovers anchored to inputs reposition above the keyboard.
- **System back integration:** On Android, the system back gesture/button dismisses the topmost dismissible overlay. If no overlay is active, it delegates to the router's back navigation.
- **Barrier interaction:** On touch, barrier taps account for scroll intent — a quick tap dismisses, but a drag/scroll does not.

---

## OiUndoStack

**What it is:** A global undo/redo history stack. Any component can push undoable actions. Integrates with `OiOverlays` to show "Undo" toasts after destructive operations.

**What it does:**
- Maintains a stack of `OiUndoAction` objects
- Supports undo (Ctrl+Z) and redo (Ctrl+Shift+Z) via global shortcuts registered by `OiApp`
- When `showToast: true`, automatically shows a toast with an "Undo" button via `OiOverlays`
- Actions with `expiry` auto-commit after the duration (can no longer be undone)

**Composes:** Integrates with `OiOverlays.toast()`, `OiShortcutScope`

**API:**
```dart
class OiUndoStack {
  void push(OiUndoAction action);
  void undo();
  void redo();
  bool get canUndo;
  bool get canRedo;
  void clear();
  ValueListenable<List<OiUndoAction>> get history;
}

class OiUndoAction {
  final String label;
  final VoidCallback execute;
  final VoidCallback reverse;
  final bool showToast;
  final Duration? expiry;
}
```

**Tests:**
| Test | What it verifies |
|------|-----------------|
| push + undo reverses action | reverse callback is called |
| push + undo + redo re-executes | execute callback is called again |
| canUndo/canRedo report correctly | true/false based on stack state |
| showToast triggers OiOverlays.toast | Toast appears with "Undo" button |
| Toast "Undo" button calls undo | Tapping undo in toast reverses action |
| expiry auto-commits | After duration, action can no longer be undone |
| clear empties stack | canUndo becomes false |
| Ctrl+Z invokes undo | Global shortcut works |
| Ctrl+Shift+Z invokes redo | Global shortcut works |
| Multiple pushes maintain order | LIFO order |
| Redo stack clears on new push | Pushing after undo clears redo |
| Cmd+Z invokes undo on macOS | Platform-mapped shortcut |
| Cmd+Shift+Z invokes redo on macOS | Platform-mapped shortcut |
| Undo toast "Undo" button has 48x48 touch target on touch | Touch-friendly button |
| Undo toast positions at bottom on touch, top-right on pointer | Platform-aware position |

**Responsive Behavior:**
- **Platform shortcut mapping:** Uses `OiShortcutActivator.primary(LogicalKeyboardKey.keyZ)` which auto-maps to `Cmd+Z` on macOS/iOS, `Ctrl+Z` on Windows/Linux/web. Same for redo with `shift: true`.
- **Toast positioning:** When `showToast: true`, the undo toast follows the platform default: bottom on touch devices (above safe area), top-right on pointer devices.
- **Touch target:** The "Undo" button inside the toast has a minimum 48x48dp touch target on touch devices, even though it visually appears as a small ghost button.
- **External keyboard on mobile:** Undo/redo shortcuts work with external Bluetooth keyboards connected to tablets and phones.

---

## OiResponsive

**What it is:** Breakpoint system and responsive utilities. Provides screen size detection, responsive value selection, and adaptive spacing/layout helpers.

**Breakpoints:**
```
compact:    <600px
medium:     600–840px
expanded:   840–1200px
large:      1200–1600px
extraLarge: >1600px
```

**API:**
```dart
enum OiBreakpoint { compact, medium, expanded, large, extraLarge }

extension OiResponsiveExt on BuildContext {
  OiBreakpoint get breakpoint;
  bool get isCompact;
  bool get isExpanded;
  bool get isLargeOrWider;
  T responsive<T>({required T compact, T? medium, T? expanded, T? large, T? extraLarge});
  double get pageGutter;
  double get contentMaxWidth;
}
```

**Tests:**
| Test | What it verifies |
|------|-----------------|
| breakpoint returns correct value at each width | 500→compact, 700→medium, 1000→expanded, 1400→large, 1800→extraLarge |
| responsive falls back to nearest smaller | expanded: null → uses medium value |
| isCompact/isExpanded/isLargeOrWider | Boolean helpers correct |
| pageGutter scales per breakpoint | Different padding values |
| contentMaxWidth scales per breakpoint | Correct max widths |
| adaptive() returns touch value on touch device | Input modality selection |
| adaptive() returns pointer value on pointer device | Input modality selection |
| orientation returns portrait/landscape correctly | Orientation detection |
| isTouch returns true on touch device | Touch detection |
| isPointer returns true on mouse device | Pointer detection |
| pageGutter returns 16 on compact, 24 on medium, 32 on expanded, 40 on large, 48 on extraLarge | Exact gutter values |
| contentMaxWidth returns 600/720/960/1200/1400 per breakpoint | Exact max width values |
| Height breakpoint returns short for <500px height | Short screen detection |
| Breakpoint recalculates on orientation change | Width changes on rotate |

**Responsive Behavior:**

`OiResponsive` is expanded with the following additional capabilities beyond breakpoints:

**Additional API:**
```dart
extension OiResponsiveExt on BuildContext {
  // ... existing breakpoint methods ...

  /// Input modality — independent of screen size.
  /// Determined by last PointerDeviceKind event.
  T adaptive<T>({required T touch, required T pointer});

  /// Orientation
  Orientation get orientation;
  bool get isPortrait;
  bool get isLandscape;

  /// Height breakpoints (for short screens like landscape phones)
  OiHeightBreakpoint get heightBreakpoint;
  bool get isShortScreen;  // height < 500dp

  /// Concrete gutter and max-width values
  /// pageGutter: 16 / 24 / 32 / 40 / 48
  /// contentMaxWidth: 600 / 720 / 960 / 1200 / 1400

  /// Safe area shorthand (delegated from OiPlatform)
  EdgeInsets get safeArea;
}

enum OiHeightBreakpoint { short, regular, tall }
// short: <500dp   regular: 500–900dp   tall: >900dp
```

**Key additions over original spec:**
- **Input modality detection** (`adaptive<T>()`) is independent of screen width. A 1200px iPad is still touch. A 500px desktop window is still pointer. Modality is determined by `PointerDeviceKind` of the last pointer event and updates dynamically when input device changes.
- **Orientation awareness** so widgets can adapt for landscape phones (short and wide) vs portrait phones (narrow and tall).
- **Height breakpoints** for components that care about vertical space (sheets, dialogs, pickers).
- **Concrete gutter and max-width values** are specified instead of "scales per breakpoint" — exact pixel values at each breakpoint are defined.

---

# Tier 1: Primitives

---

## OiTappable

**What it is:** The foundation of every interactive widget in obers_ui. A gesture detector that handles tap, long press, double tap, secondary tap (right-click), hover, focus, and keyboard activation — and applies the current theme's `OiEffectsTheme` styles (hover background, focus ring, halo, active scale, disabled opacity, etc.) automatically.

**What it does:**
- Handles all pointer and keyboard interactions
- Manages internal state: `isHovered`, `isFocused`, `isActive` (pressed), `isDragging`
- Reads `OiEffectsTheme` from context and applies the correct `OiInteractiveStyle` based on current state
- Animates between states using `effects.stateTransition` duration
- Renders focus ring and halo via `BoxShadow`
- Applies scale/translate transforms
- Provides `Semantics` wrapper with `label`, button trait, enabled state
- Activates on Enter/Space when focused

**Composes:** Flutter `GestureDetector`, `MouseRegion`, `Focus`, `Semantics`, `AnimatedContainer`

**Props:**
```dart
OiTappable({
  required String label,
  required Widget child,
  VoidCallback? onTap,
  VoidCallback? onLongPress,
  VoidCallback? onDoubleTap,
  VoidCallback? onSecondaryTap,
  ValueChanged<bool>? onHover,
  ValueChanged<bool>? onFocus,
  bool enabled = true,
  bool selected = false,
  MouseCursor? cursor,
  FocusNode? focusNode,
  BorderRadius? borderRadius,
  bool haptic = false,
  OiInteractiveStyle? hoverStyle,
  OiInteractiveStyle? focusStyle,
  OiInteractiveStyle? activeStyle,
  OiInteractiveStyle? disabledStyle,
})
```

**States:**
- **Rest:** No interaction. Base appearance.
- **Hovered:** Mouse over. Applies `effects.hover` (background overlay, cursor, subtle halo).
- **Focused:** Keyboard focus. Applies `effects.focus` (focus ring border, halo). Can coexist with hover.
- **Active/Pressed:** Mouse down or keyboard activation. Applies `effects.active` (scale down, darker overlay).
- **Disabled:** `enabled=false`. Applies `effects.disabled` (reduced opacity, forbidden cursor). Blocks all interactions.
- **Selected:** `selected=true`. Applies `effects.selected` (brand tint background, border).
- **Hovered+Focused:** Both states merge additively.

**Considerations:**
- This widget does NOT provide its own decoration (no background color, no border). It wraps the child and applies state-based _modifications_ (overlays, shadows, transforms). The background/border comes from the parent widget (e.g., `OiSurface`) or the child.
- Per-instance style overrides (e.g., `hoverStyle`) merge on top of the theme's global style.
- `borderRadius` is needed for correctly clipping the hover overlay and rounded focus ring.
- Haptic feedback only fires on mobile platforms.
- The `label` is used for `Semantics(label:)` and is required even if the visual child shows text.

**Tests:**
| Test | What it verifies |
|------|-----------------|
| onTap fires on tap | Basic tap callback |
| onTap fires on Enter key | Keyboard activation |
| onTap fires on Space key | Keyboard activation |
| onLongPress fires on long press | Long press callback |
| onDoubleTap fires on double tap | Double tap callback |
| onSecondaryTap fires on right-click | Secondary tap callback |
| Hover state activates on mouse enter | isHovered=true, hover style applied |
| Hover state deactivates on mouse exit | isHovered=false, style reverts |
| Focus state activates on Tab | isFocused=true, focus ring appears |
| Focus state deactivates on blur | Focus ring disappears |
| Active state on pointer down | Scale transform applies |
| Active state reverts on pointer up | Scale returns to 1.0 |
| Disabled blocks all taps | onTap not called when enabled=false |
| Disabled shows reduced opacity | Opacity matches effects.disabled.opacity |
| Disabled shows forbidden cursor | Cursor is SystemMouseCursors.forbidden |
| Selected applies selected style | Brand tint background visible |
| Hover+Focus merge correctly | Both styles combine |
| Per-instance style overrides work | Custom hoverStyle overrides theme |
| Halo renders as BoxShadow | Shadow list includes halo |
| State transitions animate | Duration matches effects.stateTransition |
| Reduced motion collapses animation | Instant transition when reducedMotion=true |
| Semantics label is set | Semantics tree contains label text |
| Semantics button trait is set | Screen reader announces "button" |
| Semantics disabled state | Screen reader announces disabled |
| Haptic fires on mobile | HapticFeedback called (mock test) |
| borderRadius clips overlay correctly | Rounded corners on hover overlay |
| FocusNode passthrough works | External focusNode controls focus |
| Touch target minimum 48x48 enforced on touch device | Tap at edge of 48x48 zone registers |
| Hover state does NOT activate on touch-only device | No hover overlay on touch |
| Long-press triggers onSecondaryTap fallback on touch when onLongPress is null | Touch context menu fallback |
| Active state has press delay (~100ms) inside scrollable | Distinguish tap from scroll |
| Cursor property ignored on touch device | No cursor change |
| Touch visual feedback differs from hover feedback | Different overlay style |
| Haptic does NOT fire on desktop/web | No haptic on non-mobile |
| Right-click fires onSecondaryTap on desktop | Pointer secondary tap |

**Responsive Behavior:**

OiTappable is the most critical widget for responsive adaptation since every interactive element composes it.

- **Touch target enforcement:** `OiTappable` adds a `minHitSize` property (default: `48.0` on touch via `OiA11y.minTouchTarget`, `0.0` on pointer). When the visual child is smaller than `minHitSize`, the gesture detection area expands transparently via `GestureDetector` with `HitTestBehavior.translucent` and centered padding. The visual size of the child does NOT change — only the tappable area grows.
- **Hover behavior on touch:** Hover state (`isHovered`, `onHover`, hover overlay) does NOT activate on touch-only devices. `MouseRegion` callbacks are suppressed when `context.isTouch` is true. No hover overlay, no hover cursor, no hover halo. The `OiEffectsTheme.hover` style is simply not applied.
- **Touch visual feedback:** On touch devices, the active/pressed state provides the primary visual feedback. Instead of just the subtle scale transform specified for desktop, touch adds a brief highlight overlay (a semi-transparent `primary.muted` color fill) that appears immediately on touch-down. This is the touch equivalent of hover + active combined.
- **Secondary tap fallback:** On touch devices, if `onLongPress` is null but `onSecondaryTap` is set, a long-press (500ms) triggers `onSecondaryTap` as a fallback. This makes right-click menus accessible on touch without requiring every consumer to duplicate callbacks.
- **Press delay in scrollables:** When `OiTappable` is inside a scrollable ancestor, the active state (pressed/highlight) is delayed by ~100ms on touch devices. If the user starts scrolling within that delay, the active state is cancelled. This prevents every row in a list from flashing as the user scrolls. On pointer devices, there is no delay.
- **Cursor on touch:** The `cursor` property is ignored on touch devices (there is no cursor). No `MouseRegion` cursor change is applied.
- **Haptic feedback:** `haptic` only fires on platforms that support it (iOS, Android). On desktop and web, it is silently ignored.
- **Focus ring on touch:** Focus ring is hidden during pure touch interaction (no keyboard). It reappears immediately when a keyboard event is detected (e.g., external Bluetooth keyboard connected to tablet). This is controlled by monitoring `PointerDeviceKind` events.

---

## OiFocusTrap

**What it is:** Traps keyboard focus within a subtree. When active, pressing Tab cycles focus only within children. Used by dialogs, sheets, command bar, and any modal overlay.

**What it does:**
- Intercepts Tab and Shift+Tab key events
- Cycles focus among focusable descendants
- Optionally focuses a specific widget on activation (`initialFocus`)
- Restores focus to the previously focused widget when deactivated (`restoreFocus`)
- Fires `onEscape` callback when Escape key is pressed

**Composes:** Flutter `FocusScope`, `RawKeyboardListener`

**Props:**
```dart
OiFocusTrap({
  required Widget child,
  bool active = true,
  FocusNode? initialFocus,
  bool restoreFocus = true,
  VoidCallback? onEscape,
})
```

**Considerations:**
- Only active when `active=true`. Multiple traps can exist but only the innermost active one traps.
- `restoreFocus` is important for modals — closing a dialog should return focus to the button that opened it.

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Tab cycles within trap | Focus doesn't escape subtree |
| Shift+Tab reverse cycles | Backward Tab within trap |
| initialFocus receives focus on activation | Specified widget gets focus |
| restoreFocus returns focus on deactivation | Previous focus target regains focus |
| onEscape fires on Escape key | Callback invoked |
| active=false disables trapping | Tab escapes normally |
| Nested traps: innermost wins | Only innermost active trap captures |
| Focus trap works with external keyboard on tablet | Bluetooth keyboard trapping |
| Focus trap does not interfere with touch navigation | Touch scrolling/tapping unaffected |
| Virtual keyboard does not cause focus to escape trap | Focus stays within trap |
| Android back button/gesture fires onEscape | System back integration |
| System shortcuts (Ctrl+Tab) not consumed by trap | OS-level shortcuts pass through |

**Responsive Behavior:**
- **Touch interaction:** Focus trapping is primarily relevant for keyboard navigation. On pure touch devices (no keyboard attached), the trap does not interfere with touch scrolling or tapping. Touch events pass through normally. The trap becomes active for keyboard navigation when an external keyboard is detected.
- **Virtual keyboard:** When a focus trap contains an input and the virtual keyboard appears, focus must stay within the trap. The keyboard's "Next"/"Done" buttons must not move focus outside the trap boundary.
- **Android back button:** The Android system back gesture/button triggers `onEscape` (same as pressing Escape on a physical keyboard). This allows sheets and dialogs to dismiss via the system back gesture.
- **System shortcuts pass-through:** OS-level shortcuts like `Ctrl+Tab` (switch browser tabs), `Alt+Tab` (switch windows), `Cmd+Tab` (switch apps) are NOT consumed by the focus trap. Only `Tab` and `Shift+Tab` are intercepted.

---

## OiLabel

**What it is:** The text primitive for obers_ui. Renders themed text with semantic variants. Named `OiLabel` to avoid conflicting with Flutter's `Text`.

**What it does:**
- Renders text with the variant's style from `OiTextTheme`
- Supports selectable text, copyable text (tap to copy), gradient text, skeleton loading
- Handles overflow, alignment, max lines

**Composes:** Flutter `Text`, `SelectableText`, `OiCopyable` (when `copyable=true`), `OiShimmer` (when `skeleton=true`)

**Props:**
```dart
OiLabel(
  required String text,
  OiLabelVariant variant = OiLabelVariant.body,
  Color? color,
  int? maxLines,
  TextOverflow? overflow,
  TextAlign? textAlign,
  FontWeight? weight,
  bool selectable = false,
  bool copyable = false,
  bool skeleton = false,
)

enum OiLabelVariant {
  display, h1, h2, h3, h4,
  body, bodyStrong,
  small, smallStrong,
  tiny, caption, code, overline, link,
}
```

**Considerations:**
- `copyable` wraps the text in `OiCopyable`, which shows a toast on copy. `selectable` and `copyable` are mutually exclusive — copyable takes precedence.
- `skeleton` shows a shimmer placeholder matching the text's approximate width and height.
- The `code` variant uses the monospace font from `OiTextTheme.monoFontFamily`.

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Each variant renders correct font size/weight | Check TextStyle for all 15 variants |
| Color override works | Custom color applied |
| maxLines truncates | Text truncated at limit |
| overflow shows ellipsis | TextOverflow.ellipsis visible |
| textAlign aligns correctly | Center/right alignment |
| weight override works | Custom FontWeight applied |
| selectable allows selection | Long press selects text (mobile) |
| copyable copies to clipboard on tap | Clipboard contains text |
| copyable shows feedback toast | Toast appears after copy |
| skeleton shows shimmer | Shimmer animation plays |
| skeleton matches text dimensions | Placeholder width ≈ text width |
| code variant uses mono font | Font family is monoFontFamily |
| Theme change updates style | Switching theme updates all text |
| Display/h1 variants scale down on compact breakpoint | Responsive font sizing |
| Body text size consistent across breakpoints | No body scaling |
| Text at 200% system scale does not overflow | Containers grow |
| Selectable text shows drag handles on touch | Touch selection handles |
| Selectable text allows click-drag on pointer | Pointer selection |
| Copyable feedback toast at bottom on touch, inline on pointer | Platform-aware feedback |
| Long text has appropriate measure on wide screens | Max ~80ch line length |

**Responsive Behavior:**
- **Responsive font sizing:** `display`, `h1`, `h2` variants scale per breakpoint (see Responsive Spacing & Sizing in the global section). On compact screens, display text is 32px; on extraLarge, 48px. `body` and smaller variants do NOT scale — they maintain consistent readability across all breakpoints.
- **Text scaling:** All `OiLabel` variants respect the system text scale factor (`MediaQuery.textScaleFactor`). Containers that hold labels must accommodate up to 200% text scaling without clipping. Non-critical compact variants (`tiny`, `caption`, `overline`) may clamp at 150% maximum scale to prevent layout breakage.
- **Line length / measure:** On wide screens (expanded+), `OiLabel` with `body` or longer text should be constrained to approximately 80 characters per line for optimal readability. This is the responsibility of the parent layout (e.g., `OiContainer` with `maxWidth`), but `OiLabel` should document this recommendation.
- **Selectable behavior per platform:** On touch, `selectable: true` uses the platform's native text selection with drag handles (iOS magnifying glass + handles, Android selection handles). On pointer, text is selected via click-and-drag with shift+click for range extension.
- **Copyable behavior per platform:** On touch, `copyable: true` copies on tap and shows a toast at the bottom (above safe area). On pointer, shows a brief inline checkmark indicator near the text. The feedback mechanism adapts to the platform.
- **Skeleton responsive sizing:** When `skeleton: true`, the shimmer placeholder width adapts to the container width, not a fixed estimate. On compact screens, skeleton lines may be shorter.

---

## OiIcon

**What it is:** Themed icon wrapper. All icons in obers_ui go through this to ensure consistent sizing, coloring, and accessibility.

**What it does:**
- Renders an `IconData` with size and color from theme
- Enforces accessibility label (required) or explicit decorative opt-out
- Provides semantic annotation for screen readers

**Composes:** Flutter `Icon`, `Semantics`

**Props:**
```dart
OiIcon({
  required IconData icon,
  required String label,
  double? size,
  Color? color,
})

OiIcon.decorative({
  required IconData icon,
  double? size,
  Color? color,
})
```

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Renders icon glyph | IconData visible |
| Default size from theme | Matches OiTextTheme default icon size |
| Custom size override | Size applied |
| Custom color override | Color applied |
| Semantics label set | Screen reader announces label |
| Decorative has no semantics | Semantics excluded |
| Theme change updates defaults | Size/color update |
| Icon within tappable has 48x48 minimum hit area on touch | Touch target enforcement |
| Icon size scales with system text scale factor when opt-in | Accessible sizing |

**Responsive Behavior:**
- **Touch target in context:** When `OiIcon` is used inside `OiTappable` (e.g., as part of `OiIconButton`), the overall hit area is enforced to 48x48dp on touch devices by `OiTappable`'s `minHitSize`. The icon itself remains its configured size (e.g., 16dp or 20dp) — only the tappable area grows.
- **Pixel density rendering:** Icons render crisply at all pixel densities (1x, 2x, 3x) because they use `IconData` glyphs (vector-based). No special handling needed, but the spec confirms this expectation.
- **Text scale interaction:** By default, icon sizes do NOT scale with system text scale factor (they are fixed dp values). However, icons inside text-adjacent contexts (e.g., leading icon in a button label) should optionally scale proportionally to maintain visual balance when text scales. This is controlled by the parent widget, not by `OiIcon` itself.

---

## OiImage

**What it is:** Image widget with enforced accessibility. Every image must have alt text for screen readers — unless explicitly marked decorative.

**What it does:**
- Renders an image from URL or asset
- Shows placeholder widget while loading
- Shows error widget on failure
- Provides `Semantics(label: alt)` for screen readers
- Supports border radius clipping

**Composes:** Flutter `Image.network` / `Image.asset`, `Semantics`, `ClipRRect`

**Props:**
```dart
OiImage({
  required String src,
  required String alt,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  BorderRadius? borderRadius,
  Widget? placeholder,
  Widget? error,
})

OiImage.decorative({
  required String src,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  BorderRadius? borderRadius,
})
```

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Renders image from URL | Image visible |
| Alt text in semantics | Screen reader announces alt |
| Placeholder shows while loading | Placeholder widget visible during load |
| Error widget shows on failure | Error widget visible when image fails |
| Border radius clips image | Rounded corners |
| Decorative has empty semantics | excludeSemantics=true |
| Width/height applied | Constraints correct |
| BoxFit applied | Image scales correctly |
| Responsive image loads appropriate resolution for devicePixelRatio | Resolution-aware loading |
| Image lazy-loads when below viewport | Deferred loading |
| Image decoded size limited to display size on mobile | Memory management |
| Placeholder adapts to container size | Responsive placeholder |
| Error widget adapts to container size | Responsive error state |

**Responsive Behavior:**
- **Responsive image loading:** `OiImage` supports an optional `srcSet` parameter — a map of pixel ratios to URLs (e.g., `{1: 'img.jpg', 2: 'img@2x.jpg', 3: 'img@3x.jpg'}`). When provided, the image matching `MediaQuery.devicePixelRatio` is loaded. This reduces bandwidth on 1x displays and improves clarity on 3x displays. When only `src` is provided, it is used for all densities.
- **Lazy loading:** Images below the visible viewport are not loaded until they scroll near the viewport (within 200dp). This is opt-in via `lazy: true` (default: `false`). For lists with many images (`OiGallery`, `OiChat`), lazy loading is strongly recommended.
- **Memory management on mobile:** On mobile devices, decoded image size is capped to the display size using `cacheWidth`/`cacheHeight` on Flutter's `Image` widget. A 4000x3000 image displayed at 200x150 is decoded at ~400x300 (2x for retina), not full resolution. This prevents out-of-memory crashes on low-RAM devices.
- **Placeholder/error adaptation:** Placeholder and error widgets fill the same `width` × `height` as the image would, maintaining layout stability during loading and on failure. If no custom placeholder is provided, a `OiShimmer` rectangle of the image's dimensions is shown.
- **Web CORS:** On web, `OiImage` handles cross-origin images. When CORS headers are missing, the error widget is shown instead of a broken image. The `crossOrigin` attribute is applied automatically on web.

---

## OiSurface

**What it is:** The themed container primitive. Every card, panel, dialog, popover, and styled container in obers_ui is built on `OiSurface`. It reads background, border, shadow, gradient, and halo from the theme and supports all overrides.

**What it does:**
- Renders a `Container` with themed `BoxDecoration`
- Applies background color OR gradient from `OiDecorationTheme`
- Applies border from `OiBorderStyle` (solid, dashed, dotted, gradient)
- Applies shadow from `OiShadowScale`
- Applies halo (glow) as outer `BoxShadow`
- Supports frosted glass effect (blur backdrop)
- When `interactive=true`, wraps in `OiTappable` to get hover/focus/active state effects

**Composes:** Flutter `Container`, `DecoratedBox`, `BackdropFilter` (for glass), `CustomPaint` (for dashed/gradient borders), `OiTappable` (when interactive)

**Props:**
```dart
OiSurface({
  required Widget child,
  EdgeInsets? padding,
  Color? color,
  OiGradientStyle? gradient,
  OiBorderStyle? border,
  BorderRadius? borderRadius,
  List<BoxShadow>? shadows,
  OiHaloStyle? halo,
  bool glass = false,
  double? glassBlur,
  bool interactive = false,
  String? label,       // required if interactive
  VoidCallback? onTap, // only when interactive
})
```

**States:** None by itself. When `interactive=true`, delegates state management to `OiTappable`.

**Considerations:**
- Dashed, dotted, and gradient borders cannot use Flutter's `Border` class. These are rendered via `CustomPainter` that draws the path with appropriate dash pattern or shader.
- Glass effect uses `BackdropFilter` with `ImageFilter.blur` — can be expensive on lower-end devices. Theme's `OiAnimationConfig.reducedMotion` should disable blur.
- `halo` is rendered as an additional `BoxShadow` in the decoration.

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Renders with theme surface color | Default background from colors.surface |
| Color override works | Custom color applied |
| Gradient renders | LinearGradient visible |
| Solid border renders | Border visible with correct width/color |
| Dashed border renders | CustomPaint draws dashes |
| Dotted border renders | CustomPaint draws dots |
| Gradient border renders | CustomPaint draws gradient stroke |
| Shadows render | BoxShadow applied |
| Halo renders as outer glow | BoxShadow with blur/spread |
| Glass effect blurs | BackdropFilter applied |
| Glass disabled when reducedMotion | No blur applied |
| Padding applied | Child has correct insets |
| BorderRadius clips | Rounded corners |
| interactive wraps in OiTappable | Hover/focus effects work |
| interactive requires label | Assert fires without label |
| onTap fires when interactive | Tap callback works |
| Theme change updates decoration | Colors/borders update |
| Golden: solid border appearance | Visual regression |
| Golden: dashed border appearance | Visual regression |
| Golden: gradient border appearance | Visual regression |
| Golden: halo appearance | Visual regression |
| Golden: glass effect appearance | Visual regression |
| Glass degrades to opaque on disableBlur/low-end | No BackdropFilter |
| Shadow intensity appropriate at 1x and 3x pixel ratios | Consistent visual weight |
| Border rendering consistent across pixel densities | No hairline inconsistency |

**Responsive Behavior:**
- **Glass effect degradation:** `BackdropFilter` is extremely expensive, especially on mobile and web. When `OiPerformanceConfig.disableBlur` is true (auto-detected on low-end devices), the glass effect degrades to a semi-transparent solid color (`colors.glassBackground` with opacity) instead of a blur. This maintains the visual aesthetic without the performance cost. Note: this is distinct from `reducedMotion` — reduced motion affects animation, not visual effects.
- **Shadow scaling per density:** Shadows that look good at 1x pixel ratio appear heavier/thicker at 3x. `OiSurface` adjusts shadow opacity by -15% at 1x pixel ratio and uses standard values at 2x-3x for consistent visual weight across devices.
- **Border density scaling:** A 1px logical border renders as 1 physical pixel on 1x (chunky) and 3 physical pixels on 3x (crisp). `OiSurface` renders borders using `BorderSide` with the configured logical width. On 1x displays, `0.5` logical pixel borders may be used for hairline effects.
- **Padding adaptation:** When `OiSurface` is used without explicit `padding`, it inherits padding from the component that wraps it (e.g., `OiCard`, `OiDialog`). These parent components use density-aware padding (see Dense & Comfortable Mode).
- **Performance on web:** `BackdropFilter` performance varies widely across browsers. On Safari, it is generally performant. On Chrome/Firefox, it can cause frame drops with large surfaces. `OiPerformanceConfig.auto()` accounts for browser detection on web.

---

## OiDivider

**What it is:** A separator line — horizontal or vertical — with optional label, and support for dashed, dotted, and gradient styles.

**Composes:** `CustomPainter` (for dashed/gradient), `OiLabel` (when label provided)

**Props:**
```dart
OiDivider({
  OiDividerStyle style = OiDividerStyle.solid,
  Color? color,
  double thickness = 1,
  double? indent,
  double? endIndent,
  Axis direction = Axis.horizontal,
  OiGradientStyle? gradient,
})

OiDivider.withLabel({
  required String label,
  OiDividerStyle style = OiDividerStyle.solid,
  Color? color,
})

// or pass a widget instead of string:
OiDivider.withContent({
  required Widget child,
  OiDividerStyle style = OiDividerStyle.solid,
})

enum OiDividerStyle { solid, dashed, dotted, gradient }
```

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Horizontal renders full width | Fills parent width |
| Vertical renders full height | Fills parent height |
| Solid line renders | 1px line visible |
| Dashed renders with dashes | Custom paint draws dashes |
| Dotted renders with dots | Custom paint draws dots |
| Gradient renders gradient | Gradient stroke |
| Label centered between lines | "OR" text in middle |
| Custom color applies | Override works |
| Thickness applies | 2px line when thickness=2 |
| Indent/endIndent | Lines don't touch edges |

**Responsive Behavior:**
- **Minimal responsive changes.** Dividers are simple decorative elements. Thickness renders consistently across pixel densities (1 logical pixel = 1/2/3 physical pixels depending on device). Label text in `OiDivider.withLabel` scales with system text scale factor.

---

## OiRawInput

**What it is:** The unstyled text input primitive. A thin wrapper around Flutter's `EditableText` providing controller management, placeholder overlay, leading/trailing widget slots, and all standard callbacks — but zero visual chrome (no border, no label, no error). All styled inputs (OiTextInput, OiNumberInput, etc.) compose this.

**What it does:**
- Wraps `EditableText` for raw text editing
- Renders placeholder via `LayoutBuilder` overlay when text is empty
- Provides leading/trailing widget slots via a `Row`
- Manages `TextEditingController` and `FocusNode` (creates internally if not provided)
- Supports custom `TextEditingController` subtypes (e.g., the highlighting controller for `OiSmartInput`)
- Fires `onChange`, `onSubmit`, `onFocusChange`

**Composes:** Flutter `EditableText`, `LayoutBuilder`, `Row`

**Props:**
```dart
OiRawInput({
  TextEditingController? controller,
  FocusNode? focusNode,
  String? placeholder,
  Widget? leading,
  Widget? trailing,
  ValueChanged<String>? onChange,
  ValueChanged<String>? onSubmit,
  ValueChanged<bool>? onFocusChange,
  bool obscure = false,
  int maxLines = 1,
  int? minLines,
  bool readOnly = false,
  bool autoFocus = false,
  TextInputType? keyboard,
  TextInputAction? action,
  List<TextInputFormatter>? formatters,
  TextStyle? style,
  TextAlign textAlign = TextAlign.start,
})
```

**Considerations:**
- This is NOT intended for direct use by library consumers. They use `OiTextInput`, `OiComboBox`, etc. But it must be public for advanced use cases and composition.
- Does NOT handle decoration, validation, labels, errors. Those are added by higher-level components.
- The `controller` prop allows passing `UiHighlightingController` or any custom controller for specialized inputs.

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Text input works | Type text, onChange fires |
| onSubmit fires on Enter | Submit callback |
| Placeholder shows when empty | Placeholder text visible |
| Placeholder hides when text entered | Placeholder disappears |
| Leading widget renders | Widget before input |
| Trailing widget renders | Widget after input |
| Obscure hides text | Dots shown instead of text |
| maxLines limits lines | Single line by default |
| readOnly prevents editing | Cannot type when readOnly |
| autoFocus focuses on mount | Input has focus immediately |
| External controller works | Programmatic text changes reflected |
| External focusNode works | Programmatic focus control works |
| onFocusChange fires | Focus/unfocus callbacks |
| Custom TextInputFormatter applies | Input formatted correctly |
| Custom keyboard type | Numeric keyboard for number type |
| Input scrolls into view when virtual keyboard appears | Keyboard avoidance |
| Numeric keyboard appears on mobile for number type | Platform-correct keyboard |
| iOS input accessory bar (Done/Next/Previous) appears | iOS toolbar above keyboard |
| Paste works via Ctrl+V on desktop and long-press menu on mobile | Platform paste |
| Autocorrect can be disabled per input | Autocorrect control |
| Input works with external keyboard on tablet | External keyboard support |
| Browser autofill does not break input | Web autofill compatibility |

**Responsive Behavior:**
- **Virtual keyboard handling:** When `OiRawInput` gains focus on mobile, the virtual keyboard appears and `MediaQuery.viewInsets.bottom` increases. The nearest scrollable ancestor must scroll to keep the input visible above the keyboard. `OiRawInput` calls `Scrollable.ensureVisible(context)` on focus to trigger this scroll. If no scrollable ancestor exists, the framework's `MediaQuery.viewInsets` handling resizes the layout.
- **Keyboard type per platform:** `TextInputType.number` shows a numeric keypad on iOS (with optional decimal point and minus sign) and a number-focused keyboard on Android. `TextInputType.phone` shows a phone dialer. `TextInputType.emailAddress` shows a keyboard with `@` and `.com` shortcuts. These platform differences are handled by Flutter's engine but the spec acknowledges them.
- **iOS input accessory view:** On iOS, text inputs show a toolbar above the keyboard with "Done", "Previous", and "Next" buttons. This is native iOS behavior. `OiRawInput` supports this via `TextInputAction` — `action: TextInputAction.done` shows "Done", `action: TextInputAction.next` shows "Next" (and auto-focuses the next input).
- **Autocorrect/autocomplete:** `OiRawInput` exposes `autocorrect: true` (default) and `enableSuggestions: true` (default). These should be set to `false` for code inputs, passwords, and identifier fields. On mobile, autocorrect causes unexpected text changes that confuse users in non-prose contexts.
- **Paste behavior per platform:** On desktop, paste is via `Ctrl+V`/`Cmd+V`. On mobile, paste comes from the system clipboard via long-press context menu (iOS) or long-press + "Paste" button (Android). Both work automatically via Flutter's `EditableText`. On web, `Clipboard.readText()` requires secure context (HTTPS) and user permission.
- **Browser autofill:** On web, browsers may inject autofill UI (email suggestions, saved passwords) into input fields. `OiRawInput` must not interfere with this. The `autofillHints` property is exposed to allow consumers to specify `AutofillHints.email`, `AutofillHints.password`, etc. for proper browser autofill integration.
- **Text selection on touch:** On touch, text selection uses platform-native handles (iOS: lollipop handles + magnifying glass, Android: teardrop handles). These handles have built-in 48dp touch targets managed by the platform. No additional handling is needed from `OiRawInput`.

---

## Layout Primitives: OiRow, OiColumn, OiGrid, OiMasonry, OiContainer, OiSpacer, OiWrapLayout, OiAspectRatio

These are thin layout wrappers that save boilerplate. Not much state or complexity.

### OiRow / OiColumn

**What they are:** `Row` and `Column` with a `gap` parameter. In standard Flutter, you need `SizedBox(width: 8)` between children. These add `gap` support natively.

**Composes:** Flutter `Flex` with gap injected via `MainAxisSpacing`

```dart
OiRow({required List<Widget> children, double gap = 0, MainAxisAlignment mainAlign, CrossAxisAlignment crossAlign, MainAxisSize mainSize})
OiColumn({required List<Widget> children, double gap = 0, MainAxisAlignment mainAlign, CrossAxisAlignment crossAlign, MainAxisSize mainSize})
```

**Tests:** Gap renders between children. Alignment works. MainAxisSize works. Empty children list renders nothing.

### OiGrid

**What it is:** Responsive grid that auto-calculates column count from `minColumnWidth`, or uses fixed `columns`.

```dart
OiGrid({required List<Widget> children, int? columns, double? minColumnWidth, double gap = 16, double crossAxisGap = 16, int maxColumns = 12})
```

**Composes:** Flutter `LayoutBuilder`, `Wrap` or `GridView`

**Tests:** Fixed columns renders correct count. minColumnWidth adapts to screen width. Gap applied. maxColumns caps column count.

### OiMasonry

**What it is:** Pinterest-style staggered grid where items have variable heights.

```dart
OiMasonry({required int itemCount, required IndexedWidgetBuilder itemBuilder, int columns = 2, double gap = 16, double crossAxisGap = 16, ScrollController? scrollController})
```

**Composes:** Custom `RenderBox` or `SliverMultiBoxAdaptor` for stagger layout

**Tests:** Items arrange in columns by shortest column. Variable height items don't break layout. Scrollable. Column count correct.

### OiContainer

**What it is:** Max-width centered container with responsive page gutter.

```dart
OiContainer({required Widget child, double maxWidth = 1200, EdgeInsets? padding, Alignment alignment = Alignment.topCenter})
```

**Tests:** Content centered. Max width enforced. Padding applied. Full width when screen < maxWidth.

### OiSpacer

**What it is:** Flexible or fixed space filler.

```dart
OiSpacer({double? size}) // fixed size
OiSpacer.flex({int flex = 1}) // flexible
```

### OiAspectRatio

Thin wrapper around `AspectRatio`.

```dart
OiAspectRatio({required double ratio, required Widget child})
```

**Responsive Behavior for Layout Primitives:**

**OiRow / OiColumn:**
- **Responsive gap:** `gap` should accept the result of `context.responsive(compact: 8, expanded: 16)` since it's a `double`. Consumers are expected to use the responsive helper for adaptive gaps.
- **Row-to-Column collapse:** `OiRow` adds a `collapse` parameter: `OiRow({..., OiBreakpoint? collapse})`. When set (e.g., `collapse: OiBreakpoint.compact`), the row switches to column layout at that breakpoint and below. This is the most common responsive pattern (horizontal on desktop → vertical on mobile). The `gap` value is preserved in both directions.
- **Safe area awareness:** When an `OiRow` or `OiColumn` is at the screen edge, it should be used within a `SafeArea` or `OiContainer` — the layout primitives themselves do not add safe area padding.

**OiGrid:**
- **Responsive column auto-calculation:** When `minColumnWidth` is used (recommended over fixed `columns`), the grid automatically adapts column count to available width. On a 360dp phone: `minColumnWidth: 160` → 2 columns. On a 1200dp desktop: → 7 columns (capped by `maxColumns`).
- **Responsive gap:** Grid `gap` and `crossAxisGap` should use responsive values. Recommended: 8dp on compact, 16dp on expanded+.
- **Default behavior:** When neither `columns` nor `minColumnWidth` is set, default to `minColumnWidth: 200` for sensible auto-adaptation.

**OiMasonry:**
- **Responsive column count:** `columns` should accept responsive values or an auto-calculation mode. Add `minColumnWidth` as an alternative to fixed `columns`, matching `OiGrid` API. On compact screens, masonry typically uses 1-2 columns; on large screens, 3-5.
- **Performance on mobile:** For 100+ items, masonry should integrate with `OiVirtualList`-style virtualization to avoid building all items. Add `virtualScroll: false` parameter (default off, enable for large item counts).

**OiContainer:**
- **Concrete gutter values:** `pageGutter` (the horizontal padding): 16dp on compact, 24dp on medium, 32dp on expanded, 40dp on large, 48dp on extraLarge.
- **Concrete maxWidth values:** `contentMaxWidth` per breakpoint: compact → unconstrained (full width), medium → 720dp, expanded → 960dp, large → 1200dp, extraLarge → 1400dp.
- **Full-bleed on compact:** On compact breakpoint, `OiContainer` removes the maxWidth constraint and content goes edge-to-edge (minus `pageGutter`). This is the mobile-first default.
- **Safe area integration:** `OiContainer` respects horizontal safe areas (e.g., landscape iPhone with notch on side). The `pageGutter` is added on top of safe area insets, not instead of them.

**OiWrapLayout (FULL SPECIFICATION — missing from original):**

```dart
OiWrapLayout({
  required List<Widget> children,
  double spacing = 8,
  double runSpacing = 8,
  WrapAlignment alignment = WrapAlignment.start,
  WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
})
```

Thin wrapper around Flutter `Wrap` with themed defaults. Items flow horizontally and wrap to the next line when they exceed available width. Commonly used for tag lists, filter chips, button groups that need to wrap on narrow screens.

**Tests for OiWrapLayout:**
| Test | What it verifies |
|------|-----------------|
| Items wrap to next line when exceeding width | Correct wrapping |
| Spacing between items correct | Horizontal gap |
| Run spacing between rows correct | Vertical gap between rows |
| Alignment start/center/end/spaceBetween | Correct alignment |
| Layout re-wraps on screen resize | Responsive re-flow |
| Empty children list renders nothing | No crash |

**OiSpacer:**
- No responsive changes needed. `OiSpacer` is a simple space filler.

**OiAspectRatio:**
- **Responsive ratio:** Add support for responsive ratio via consumer use of `context.responsive()`: `OiAspectRatio(ratio: context.responsive(compact: 1.0, expanded: 16/9))`. This allows videos to be 16:9 on desktop but square on mobile.

**Layout Primitives Responsive Tests:**
| Test | What it verifies |
|------|-----------------|
| OiRow collapses to column at specified breakpoint | Row→Column on compact |
| OiRow gap preserved in collapsed column mode | Gap works in both directions |
| OiGrid auto-calculates 2 columns on 360dp width | Responsive columns |
| OiGrid auto-calculates 4 columns on 960dp width | Responsive columns |
| OiGrid respects maxColumns cap | Never exceeds max |
| OiMasonry uses 1-2 columns on compact | Responsive masonry |
| OiContainer full-bleed on compact | No maxWidth constraint |
| OiContainer applies 16dp gutter on compact | Correct gutter |
| OiContainer applies 32dp gutter on expanded | Correct gutter |
| OiContainer centers content on expanded+ | Centered with maxWidth |
| OiContainer respects horizontal safe area | Gutter + safe area |
| OiAspectRatio supports responsive ratio | Ratio changes per breakpoint |
| OiGrid re-layouts on orientation change | Column count updates |

---

## Overlay Primitives: OiFloating, OiPortal, OiVisibility

### OiFloating

**What it is:** The overlay positioning engine. Calculates the best position for floating content (popovers, tooltips, dropdowns, context menus) relative to an anchor widget, ensuring the floating content stays within the viewport.

**What it does:**
- Measures anchor widget position via `GlobalKey`
- Calculates available space in all directions
- Positions the floating content at the preferred alignment, flipping if there's not enough room
- Optionally renders an arrow/caret pointing to the anchor
- Keeps content within viewport bounds

**Composes:** Flutter `Overlay`, `CompositedTransformTarget`/`CompositedTransformFollower`, `LayoutBuilder`

**Props:**
```dart
OiFloating({
  required GlobalKey anchorKey,
  required WidgetBuilder builder,
  OiAlignment alignment = OiAlignment.bottomCenter,
  Offset offset = Offset.zero,
  bool constrainToViewport = true,
  bool showArrow = false,
  bool dismissOnOutsideTap = true,
  VoidCallback? onDismiss,
})
```

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Positions below anchor by default | Content appears below |
| Flips to top when no room below | Viewport constraint works |
| Flips horizontally when needed | Left/right flip |
| Arrow points to anchor | Arrow rendered at correct position |
| dismissOnOutsideTap works | Tap outside closes floating |
| onDismiss fires | Callback invoked |
| Offset applied | Content offset from anchor |

### OiPortal

**What it is:** Renders its child in the nearest `Overlay` layer. Useful for rendering something visually above everything else without managing `Overlay.of(context)` manually.

```dart
OiPortal({required Widget child, bool visible = true})
```

### OiVisibility

**What it is:** Animated show/hide transition for any widget.

```dart
OiVisibility({required bool visible, required Widget child, Duration? duration, Curve? curve, OiTransition transition = OiTransition.fadeScale})
enum OiTransition { fade, fadeScale, slideUp, slideDown, slideLeft, slideRight }
```

**Tests:** visible=true shows child with animation. visible=false hides with reverse animation. Reduced motion plays instantly. Each transition type animates correctly.

**Responsive Behavior for Overlay Primitives:**

**OiFloating:**
- **Compact → bottom-anchored:** On `compact` breakpoint, when there is insufficient space to position floating content in any direction (common on small phones), `OiFloating` automatically switches to bottom-anchored mode: content slides up from the bottom of the viewport as a mini-sheet, full-width with rounded top corners. The arrow is hidden in this mode.
- **Keyboard repositioning:** When the virtual keyboard appears and changes available viewport space, `OiFloating` recalculates position. If the floating content was anchored to an input that moved above the keyboard, the floating content repositions accordingly. If there's no room, it flips to above the anchor or switches to bottom-anchored mode.
- **Scroll-aware dismissal:** On touch, `dismissOnOutsideTap` distinguishes between a deliberate tap (dismiss) and a scroll gesture (do not dismiss). A scroll that starts outside the floating content does NOT dismiss it — only a short, stationary tap does.
- **Arrow visibility:** The arrow/caret pointing to the anchor is hidden on compact breakpoint when floating content is in bottom-anchored mode (it doesn't point to anything meaningful).

**OiPortal:**
- No responsive changes needed. Portal is a structural utility.

**OiVisibility:**
- **Responsive visibility:** Add `OiVisibility.responsive()` factory that shows/hides based on breakpoint:
```dart
OiVisibility.responsive({
  required Widget child,
  Set<OiBreakpoint> visibleAt = const {OiBreakpoint.compact, OiBreakpoint.medium, OiBreakpoint.expanded, OiBreakpoint.large, OiBreakpoint.extraLarge},
  OiTransition transition = OiTransition.fade,
})
```
This enables "show on desktop, hide on mobile" patterns without manual breakpoint checks: `OiVisibility.responsive(visibleAt: {expanded, large, extraLarge}, child: sidebar)`.

**Overlay Primitives Responsive Tests:**
| Test | What it verifies |
|------|-----------------|
| OiFloating switches to bottom-anchored on compact when no space | Full-width bottom mode |
| OiFloating repositions when keyboard appears | Content stays visible |
| OiFloating does not dismiss on scroll gesture (touch) | Only deliberate tap dismisses |
| OiFloating arrow hidden in bottom-anchored mode | No arrow on compact |
| OiVisibility.responsive shows widget at specified breakpoints | Correct visibility |
| OiVisibility.responsive hides widget at other breakpoints | Correct hiding |
| OiVisibility.responsive animates transition on breakpoint change | Smooth show/hide |

---

## Scroll Primitives: OiVirtualList, OiVirtualGrid, OiInfiniteScroll, OiScrollbar

### OiVirtualList

**What it is:** Virtualized list for rendering 100k+ items efficiently. Only items in and near the viewport are built. Required by `OiTable`, `OiTree`, `OiComboBox`, `OiChat`, etc.

**Composes:** Flutter `ListView.builder` with `cacheExtent`, or custom `RenderSliver` for exact viewport control

**Props:**
```dart
OiVirtualList({
  required int itemCount,
  required double itemHeight,
  required IndexedWidgetBuilder itemBuilder,
  int overscan = 5,
  ScrollController? controller,
  Widget? header,
  Widget? footer,
  VoidCallback? onScrollEnd,
  EdgeInsets? padding,
})
```

**Considerations:**
- `itemHeight` is required because virtualization needs to calculate scroll position without building items.
- `overscan` is the number of items rendered beyond the visible viewport to avoid flicker on fast scroll.
- `onScrollEnd` fires when the user scrolls to the bottom — used by `OiInfiniteScroll` and `OiComboBox` load-more.

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Only visible items are built | Build count << itemCount |
| Scroll renders new items | Items appear on scroll |
| Overscan renders buffer | Extra items beyond viewport |
| onScrollEnd fires at bottom | Callback invoked |
| Header renders above list | Header visible |
| Footer renders below list | Footer visible |
| 100k items without OOM | Memory stays bounded |
| Scroll position preservation | Scroll offset maintained on rebuild |
| itemHeight enforced | All items have exact height |

### OiVirtualGrid

Same concept for grid layouts.

```dart
OiVirtualGrid({required int itemCount, required int columns, required double itemHeight, required IndexedWidgetBuilder itemBuilder, int overscan = 5, ScrollController? controller, double gap = 16})
```

### OiInfiniteScroll

**What it is:** A wrapper that detects when the user nears the bottom of a scrollable and triggers a `onLoadMore` callback. Used by `OiTable`, `OiActivityFeed`, `OiChat`, `OiComboBox` for pagination.

```dart
OiInfiniteScroll({required Widget child, required AsyncCallback onLoadMore, required bool hasMore, Widget? loadingIndicator, double threshold = 200})
```

**Tests:** onLoadMore fires when threshold from bottom. Not fired when hasMore=false. Loading indicator shows during load. Not triggered multiple times concurrently.

### OiScrollbar

**What it is:** Themed scrollbar that wraps any scrollable.

```dart
OiScrollbar({required Widget child, ScrollController? controller, bool showAlways = false, Color? thumbColor, double? thickness})
```

**Responsive Behavior for Scroll Primitives:**

**OiVirtualList / OiVirtualGrid:**
- **Pull-to-refresh:** Add `onRefresh` callback parameter. On touch devices, pulling down past a threshold (64dp) shows a refresh indicator and triggers `onRefresh`. On pointer devices, pull-to-refresh is not available (use a dedicated refresh button instead). iOS uses bouncing-style refresh (spinner inside overscroll). Android uses the Material pull indicator above the list.
- **Scroll physics per platform:** iOS uses `BouncingScrollPhysics` (elastic overscroll). Android uses `ClampingScrollPhysics` (glow overscroll). Flutter handles this automatically per `TargetPlatform`, and `OiVirtualList` inherits the platform physics. On web, `ClampingScrollPhysics` is used by default.
- **Scroll-to-top on iOS:** Tapping the iOS status bar scrolls to the top. Flutter supports this natively for `PrimaryScrollController`. `OiVirtualList` registers with `PrimaryScrollController` when it is the primary scrollable on screen.
- **Keyboard navigation:** On pointer/desktop, `Page Up`/`Page Down` scroll by one viewport height. `Home`/`End` scroll to the beginning/end of the list. These are standard desktop scroll behaviors.
- **Scroll position on orientation change:** When the device rotates, the scroll offset is preserved. The virtual list recalculates which items are visible at the new viewport dimensions without jumping to a different scroll position.

**OiInfiniteScroll:**
- **Proportional threshold:** The `threshold` (default 200dp) should be proportional on small screens. On screens shorter than 600dp, use `threshold = viewportHeight * 0.33` instead of the fixed value, ensuring load-more triggers at a reasonable scroll distance.

**OiScrollbar:**
- **Platform-adaptive appearance:** See global "Platform-Adaptive Scrollbar" section. On touch: thin 3dp overlay scrollbar, no track, fades 1.5s after scroll stops. On pointer: 8dp scrollbar with visible track, hover-to-expand to 12dp, click-track-to-jump, drag thumb. `showAlways` forces always-visible even on touch (useful for data-heavy views like tables).
- **Scrollbar interaction on pointer:** Clicking the scrollbar track jumps the scroll position to the click location. Dragging the thumb scrolls proportionally. Hovering expands the scrollbar from 8dp to 12dp for easier grabbing.

**Scroll Primitives Responsive Tests:**
| Test | What it verifies |
|------|-----------------|
| Pull-to-refresh triggers onRefresh on touch | Callback fires with gesture |
| Pull-to-refresh NOT available on pointer device | No pull gesture |
| iOS uses bouncing scroll physics | Elastic overscroll on iOS |
| Android uses clamping scroll physics | Glow overscroll on Android |
| Page Up/Page Down scroll on desktop | Keyboard scroll navigation |
| Home/End scroll to start/end on desktop | Keyboard scroll navigation |
| Scroll position preserved on orientation change | No scroll jump on rotate |
| Scrollbar thin overlay on touch | 3dp, no track |
| Scrollbar full with track on pointer | 8dp, track visible |
| Scrollbar fades after scroll stops on touch | Invisible when idle |
| Scrollbar track click jumps on pointer | Click-to-position |
| Scrollbar hover expands on pointer | 8dp → 12dp |
| InfiniteScroll proportional threshold on short screens | Earlier trigger on phone |
| Status bar tap scrolls to top on iOS | Scroll-to-top integration |

---

## Gesture Primitives: OiPinchZoom, OiSwipeable, OiLongPressMenu, OiDoubleTap

### OiPinchZoom

**What it is:** Wraps any child to make it pinch-to-zoom and pan. Used by `OiLightbox`, `OiImageAnnotator`, `OiFlowGraph`.

```dart
OiPinchZoom({required Widget child, double minScale = 1.0, double maxScale = 5.0, ValueChanged<double>? onScaleChange, bool panEnabled = true, Clip clipBehavior = Clip.hardEdge})
```

**Tests:** Pinch zooms. Pan moves. minScale/maxScale enforced. onScaleChange fires. Double-tap zooms to fit. Clip behavior works.

### OiSwipeable

**What it is:** iOS mail-style swipe actions on a row. Swiping left or right reveals action buttons.

**Composes:** `GestureDetector`, `AnimatedPositioned`, `OiTappable` for action buttons

```dart
OiSwipeable({
  required Widget child,
  required String label,
  List<OiSwipeAction>? leadingActions,
  List<OiSwipeAction>? trailingActions,
  double threshold = 0.3,
  bool haptic = true,
  VoidCallback? onSwipeComplete,
})

class OiSwipeAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool destructive;
}
```

**Tests:** Swipe right reveals leading actions. Swipe left reveals trailing actions. Threshold triggers auto-complete. Haptic fires. Action onTap fires. Destructive styling. Keyboard accessible (arrow keys to reveal, Enter to confirm).

### OiLongPressMenu

**What it is:** iOS-style context menu that appears on long press with a blurred background preview.

**Composes:** `OiTappable` (long press detection), `OiFloating` (positioning), `OiSurface` (menu surface)

```dart
OiLongPressMenu({
  required Widget child,
  required List<OiMenuItem> items,
  required String label,
  bool haptic = true,
  Widget? preview,
})
```

**Tests:** Long press shows menu. Items render. Item tap fires callback and closes menu. Haptic fires. Preview shows. Dismiss on outside tap.

**Responsive Behavior for Gesture Primitives:**

**OiPinchZoom:**
- **Desktop equivalents:** On pointer devices, `OiPinchZoom` supports: `Ctrl+scroll wheel` to zoom (or `Cmd+scroll` on macOS), middle-click drag to pan, `+`/`-` keys to zoom when focused. These are the standard desktop equivalents of touch pinch-to-zoom and two-finger pan.
- **Double-tap-to-zoom details:** Double-tap zooms to 2x centered on the tap point. If already zoomed in, double-tap zooms back to fit (1x). On pointer, double-click does the same.
- **Zoom controls on touch:** On touch devices, add optional on-screen zoom control buttons (`+`/`-` floating buttons) for users who have difficulty with pinch gestures. These appear via `showZoomControls: true` (default: `false`).
- **Browser zoom isolation:** On web, `OiPinchZoom` must prevent browser-level pinch zoom on the widget area while allowing the browser's accessibility zoom to function normally. This is achieved by setting `touch-action: none` on the widget's element in web.

**OiSwipeable:**
- **Desktop alternative:** On pointer devices, swipe actions are not natural. Instead, action buttons are revealed on hover — a subtle "actions" icon or the action buttons themselves slide in from the trailing edge on mouse hover. Right-clicking a swipeable item also opens the actions as an `OiContextMenu` for keyboard/pointer accessibility.
- **Browser gesture conflict:** On web (mobile browsers), horizontal swipe must not conflict with browser back/forward navigation gestures. `OiSwipeable` uses a 10dp horizontal dead zone — the swipe must travel > 10dp horizontally before it captures the gesture, allowing short swipes to be interpreted as browser gestures.
- **Velocity-based auto-complete:** On touch, swiping fast enough (velocity > 800dp/s) auto-completes the swipe action without needing to reach the distance threshold.

**OiLongPressMenu:**
- **Desktop trigger:** On pointer devices, `OiLongPressMenu` is triggered by right-click instead of long-press. It uses `OiContextMenu` positioning (at cursor) instead of the touch-style centered presentation. The `preview` widget is not shown on pointer (it's an iOS-specific pattern).
- **Browser context menu suppression:** On web, the browser's native right-click context menu must be suppressed on `OiLongPressMenu` targets so the custom menu appears instead.

**OiDoubleTap (FULL SPECIFICATION — missing from original):**

**What it is:** A gesture detector specifically for double-tap interactions. Distinguishes single tap from double tap and fires the appropriate callback after the decision interval.

**Composes:** Flutter `GestureDetector`

```dart
OiDoubleTap({
  required Widget child,
  required VoidCallback onDoubleTap,
  Duration interval = const Duration(milliseconds: 300),
  VoidCallback? onSingleTap,  // fires after interval if no second tap
})
```

**Considerations:**
- `onSingleTap` fires only after `interval` expires with no second tap. This introduces a perceived delay to single-tap actions. Use `OiDoubleTap` only when both single and double tap are needed; otherwise use `OiTappable.onTap` for immediate single-tap response.
- On touch devices, the `interval` should be slightly longer (350ms) than on pointer (300ms) because touch input is less precise and users may be slower to double-tap.
- On web, double-tap must not conflict with browser's double-tap-to-zoom. This is handled by `touch-action: manipulation` on the widget's web element.

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Double tap within interval fires onDoubleTap | Correct timing detection |
| Single tap fires onSingleTap after interval expires | Delayed single tap callback |
| Rapid triple tap fires onDoubleTap + onSingleTap | Correct decomposition |
| Double-click works on pointer device | Mouse double-click |
| Interval slightly longer on touch (350ms) vs pointer (300ms) | Platform-adapted interval |
| No conflict with browser double-tap-to-zoom on web | Web gesture isolation |

**Gesture Primitives Responsive Tests:**
| Test | What it verifies |
|------|-----------------|
| PinchZoom: Ctrl+scroll zooms on desktop | Desktop zoom equivalent |
| PinchZoom: middle-click drag pans on desktop | Desktop pan equivalent |
| PinchZoom: +/- keys zoom when focused on desktop | Keyboard zoom |
| PinchZoom: browser zoom isolated on web | No double-zoom |
| Swipeable: actions reveal on hover on pointer | Desktop hover alternative |
| Swipeable: right-click opens actions as context menu | Pointer context menu |
| Swipeable: no conflict with browser back/forward on web | Web gesture isolation |
| LongPressMenu: right-click triggers on pointer | Desktop trigger |
| LongPressMenu: browser context menu suppressed on web | Custom menu on web |
| LongPressMenu: preview hidden on pointer | iOS-only pattern |

---

## Drag & Drop Primitives: OiDraggable, OiDropZone, OiDragGhost, OiReorderable

### OiDraggable\<T\>

**What it is:** Makes any widget draggable. Provides a typed data payload that `OiDropZone` receives.

**Composes:** Flutter `LongPressDraggable` or `Draggable`, `OiDragGhost`, `Semantics`

```dart
OiDraggable<T>({
  required Widget child,
  required T data,
  required String label,
  Widget? dragGhost,
  Axis? axis,
  VoidCallback? onDragStart,
  VoidCallback? onDragEnd,
  bool haptic = true,
  bool enabled = true,
})
```

**Tests:** Drag starts on long press. dragGhost renders during drag. data delivered to OiDropZone. Axis constraint works. onDragStart/onDragEnd fire. Disabled blocks drag. Label in semantics. Keyboard fallback: select item, arrow keys to move, Enter to confirm.

### OiDropZone\<T\>

**What it is:** A zone that can receive dropped items. Visual feedback when an acceptable item hovers over it.

```dart
OiDropZone<T>({
  required Widget Function(BuildContext, OiDropState<T>) builder,
  required ValueChanged<T> onDrop,
  bool Function(T)? canAccept,
  String? label,
})

class OiDropState<T> {
  final bool hovering;
  final T? hoveringData;
  final bool canAccept;
}
```

**Tests:** hovering=true when compatible item enters. canAccept filters types. onDrop fires on drop. Builder rebuilds with state. Non-acceptable items show hovering but canAccept=false.

### OiReorderable

**What it is:** Drag-to-reorder for list or grid items. The primary composition target for kanban cards, table columns, nav menu items, tag chips.

**Composes:** `OiDraggable`, `OiDropZone`, `OiDragGhost`, `AnimatedPositioned`

```dart
OiReorderable({
  required int itemCount,
  required Widget Function(BuildContext, int index, bool isDragging) itemBuilder,
  required void Function(int oldIndex, int newIndex) onReorder,
  Axis direction = Axis.vertical,
  bool showDragHandle = true,
  bool haptic = true,
  String? label,
})

OiReorderable.grid({
  required int itemCount,
  required Widget Function(BuildContext, int index, bool isDragging) itemBuilder,
  required void Function(int oldIndex, int newIndex) onReorder,
  int columns = 3,
  double gap = 16,
})
```

**Tests:** Drag item to new position. onReorder fires with correct indices. Items animate to fill gap. Grid variant works. Drag handle visible when showDragHandle. Keyboard: select with Space, move with arrows, drop with Enter. isDragging=true on dragged item. Haptic fires.

**Responsive Behavior for Drag & Drop Primitives:**

**OiDraggable:**
- **Touch vs pointer drag initiation:** On touch devices, drag starts on long-press (500ms) to distinguish from scroll. Uses `LongPressDraggable`. On pointer devices, drag starts immediately on mouse-down+move (no delay). Uses `Draggable`. The choice is automatic based on `context.isTouch`.
- **Drag ghost positioning:** On touch, the drag ghost is offset 40dp above and 20dp left of the finger position so the user can see what they're dragging (finger doesn't obscure it). On pointer, the ghost follows the cursor directly.
- **Auto-scroll:** When dragging near the edges of a scrollable container (within 40dp of top/bottom edge), the container auto-scrolls in that direction. Scroll speed increases as the cursor gets closer to the edge. This is critical for dragging items in long lists.
- **Browser native drag suppression:** On web, `OiDraggable` suppresses the browser's native HTML drag behavior to prevent duplicate ghost images and conflicting drag events.
- **Haptic feedback:** On touch, a light haptic pulse fires when the drag starts. On pointer, no haptic.

**OiDropZone:**
- **Touch feedback enhancement:** On touch, the drop zone highlight is more prominent (larger border, stronger background tint) because the user's finger obscures part of the view. On pointer, the highlight can be more subtle.

**OiDragGhost (FULL SPECIFICATION — missing from original):**

**What it is:** The visual representation of an item being dragged. Renders a translucent copy of the dragged item with optional elevation and rotation. Used internally by `OiDraggable` and `OiReorderable`.

```dart
OiDragGhost({
  required Widget child,
  double opacity = 0.85,
  double elevation = 8,
  double rotation = 0,  // slight rotation (e.g., 2° on touch) for visual feedback
  BoxDecoration? decoration,
})
```

- On touch: default `rotation: 2°` for a "picked up" feel. On pointer: `rotation: 0`.
- Ghost size matches the original item size. On touch, ghost is rendered at 105% scale for visibility.

**OiReorderable:**
- **Drag handle touch target:** When `showDragHandle: true`, the drag handle has a minimum 48x48dp touch target on touch devices, even though the visual grip icon may be smaller (e.g., 24x24).
- **Long-press to initiate on touch:** Reorder starts on long-press (500ms) on touch, immediate drag on pointer. Same as `OiDraggable`.
- **Auto-scroll during reorder:** When reordering in a long list and dragging near the top/bottom edge, the list auto-scrolls.
- **Grid responsive columns:** `OiReorderable.grid()` column count should use responsive values or `minColumnWidth` for auto-adaptation across breakpoints.

**Drag & Drop Responsive Tests:**
| Test | What it verifies |
|------|-----------------|
| Drag starts on long-press on touch | Touch drag initiation |
| Drag starts on mouse-down+move on pointer | Pointer drag initiation |
| Drag ghost offset from finger on touch | Ghost visible above finger |
| Drag ghost follows cursor on pointer | Ghost at cursor position |
| Auto-scroll when dragging near container edge | List scrolls during drag |
| Browser native drag suppressed on web | No duplicate ghost |
| Drop zone highlight more prominent on touch | Stronger visual feedback |
| Drag handle 48x48 touch target on touch | Touch-friendly handle |
| Reorderable grid adapts column count per breakpoint | Responsive grid |
| Keyboard reorder shows visual insertion indicator | Accessible reorder |

---

## Clipboard Primitives: OiCopyable, OiCopyButton, OiPasteZone

### OiCopyable

**What it is:** A wrapper that copies text to clipboard on tap or long press. Shows toast feedback. Used by `OiCodeBlock`, `OiMetric`, and `OiLabel` when `copyable=true`.

```dart
OiCopyable({required Widget child, required String text, String feedbackMessage = 'Copied to clipboard', VoidCallback? onCopy})
```

**Composes:** `OiTappable`, `OiOverlays.toast()`

**Tests:** Tap copies to clipboard. Toast shows. onCopy fires. Clipboard contains correct text. Long press also copies.

### OiCopyButton

**What it is:** A standalone copy button with checkmark animation.

```dart
OiCopyButton({required String text, OiButtonSize size = OiButtonSize.small})
```

**Composes:** `OiIconButton`, `OiCopyable`, animated icon swap (copy icon → check icon → copy icon)

**Tests:** Tap copies and shows check animation. Check reverts after 2s. Correct text in clipboard.

### OiPasteZone

**What it is:** Detects paste events (Ctrl+V) within its subtree.

```dart
OiPasteZone({required Widget child, required ValueChanged<String> onPaste, List<String>? acceptTypes})
```

**Tests:** Ctrl+V triggers onPaste with clipboard content. acceptTypes filters.

**Responsive Behavior for Clipboard Primitives:**

**OiCopyable:**
- **Copy trigger per platform:** On pointer, hover shows a subtle copy indicator (cursor change or faint icon). On touch, no hover indicator — the user taps to copy, and feedback is immediate via toast.
- **Feedback per platform:** On touch, copy confirmation is a toast at the bottom (above safe area). On pointer, a brief inline checkmark appears near the copied text for 1.5s (less intrusive than a toast for rapid copy operations).

**OiCopyButton:**
- **Touch target:** The copy button must meet 48x48dp minimum touch target on touch devices, even for `OiButtonSize.small`. The visual icon can be 16dp but the tappable area is 48dp.

**OiPasteZone:**
- **Platform paste trigger:** On desktop, `Ctrl+V`/`Cmd+V` triggers `onPaste`. On mobile, there is no equivalent keyboard shortcut for most users. `OiPasteZone` shows a "Tap to paste" button when clipboard content is available and the zone is focused/active. The button reads the clipboard via `Clipboard.getData` and fires `onPaste`.
- **Web clipboard permissions:** On web, `Clipboard.readText()` requires a secure context (HTTPS) and user permission. If permission is denied, `OiPasteZone` shows a graceful error message ("Clipboard access denied") instead of silently failing.

**Clipboard Responsive Tests:**
| Test | What it verifies |
|------|-----------------|
| Copy feedback is toast on touch, inline indicator on pointer | Platform-adapted feedback |
| Copy button has 48x48 touch target on touch | Touch target enforcement |
| Cmd+V triggers paste on macOS | Platform shortcut |
| Ctrl+V triggers paste on Windows/Linux | Platform shortcut |
| Paste zone shows "Tap to paste" button on mobile | Touch-friendly paste |
| Clipboard permission denial handled gracefully on web | Error message shown |

---

## Animation Primitives: OiAnimatedList, OiStagger, OiShimmer, OiPulse, OiMorph, OiSpring

### OiAnimatedList\<T\>

**What it is:** Auto-animates item additions and removals. Watches a `List<T>` and animates differences.

```dart
OiAnimatedList<T>({
  required List<T> items,
  required Object Function(T) itemKey,
  required Widget Function(BuildContext, T, Animation<double>) itemBuilder,
  Duration? insertDuration,
  Duration? removeDuration,
  Curve? insertCurve,
  Curve? removeCurve,
})
```

**Composes:** Flutter `AnimatedList` with diff detection

**Tests:** Adding item animates in. Removing item animates out. Reorder detected via keys. Reduced motion plays instant. Duration/curve overrides work.

### OiStagger

**What it is:** Children animate in sequentially with staggered delay.

```dart
OiStagger({required List<Widget> children, Duration delay = const Duration(milliseconds: 50), Duration duration = const Duration(milliseconds: 300), Offset? slideFrom, bool fadeIn = true, Curve curve = Curves.easeOut})
```

**Tests:** First child appears immediately, second after delay, third after 2*delay. fadeIn works. slideFrom works. Reduced motion plays all instantly.

### OiShimmer

**What it is:** Shimmer loading effect that sweeps a highlight across its child shape.

```dart
OiShimmer({required Widget child, Color? baseColor, Color? highlightColor, Duration duration = const Duration(milliseconds: 1500), bool enabled = true})
```

**Tests:** Shimmer animation plays. Colors from theme by default. enabled=false stops animation. Reduced motion stops animation. Child shape defines shimmer boundary.

### OiPulse

**What it is:** Pulsing attention indicator. Used for notification dots, live status, etc.

```dart
OiPulse({required Widget child, Color? color, Duration duration = const Duration(milliseconds: 1500), bool active = true})
```

**Tests:** Pulsing animation plays when active. Stops when active=false. Reduced motion shows static. Color override works.

### OiMorph

**What it is:** Morphs between two widget states (crossfade + size animation).

```dart
OiMorph({required Widget child, Duration duration = const Duration(milliseconds: 200), Curve curve = Curves.easeInOut})
```

**Tests:** Changing child cross-fades and size-morphs. Duration/curve applied. Reduced motion instant swap.

### OiSpring

**What it is:** Exposes spring physics as an animation builder.

```dart
OiSpring({required double target, required Widget Function(BuildContext, double value) builder, SpringDescription? spring})
```

**Tests:** Value animates to target with spring physics. Overshoots then settles. Custom spring parameters. Reduced motion jumps to target.

**Responsive Behavior for Animation Primitives:**

**All Animation Primitives (OiAnimatedList, OiStagger, OiShimmer, OiPulse, OiMorph, OiSpring):**
- **Performance-based degradation:** All animations respect `OiPerformanceConfig`. When `reduceAnimations` is true (auto-detected on low-end devices), animation durations are halved via `animationScale: 0.5`. When `animationScale: 0` (minimal tier), animations complete instantly (like `reducedMotion` but for performance, not accessibility).
- **Distinction from reducedMotion:** `reducedMotion` is a user accessibility preference — all animations are disabled and values snap instantly. `OiPerformanceConfig.reduceAnimations` is a device capability optimization — animations still play but shorter. Both are respected independently. If both are active, `reducedMotion` takes precedence (instant).
- **Mobile animation durations:** Default durations are designed for desktop (where animations feel natural at 200-300ms). On touch/mobile, consider using 80% of the default duration via `animationScale: 0.8` for snappier perceived performance. This is applied automatically when `OiPerformanceConfig.auto()` detects a mobile device.
- **Frame rate adaptation:** On 120Hz displays, spring animations and other physics-based animations run at 120fps for smoothness. On 60Hz, they run at 60fps. Flutter handles this automatically, but the spec acknowledges that animation quality scales with display capability.

**OiShimmer:**
- Default duration (1500ms) is appropriate for desktop. On mobile with `reduceAnimations`, shimmer cycle reduces to 1000ms for a punchier loading feel.

**OiStagger:**
- On `reducedMotion`, all children appear simultaneously (no stagger delay). On `reduceAnimations`, delay is halved (25ms instead of 50ms default).

**Animation Responsive Tests:**
| Test | What it verifies |
|------|-----------------|
| Animation duration halved on reduceAnimations | 150ms instead of 300ms |
| Animation instant on reducedMotion | No animation at all |
| reduceAnimations and reducedMotion: reducedMotion wins | Instant transition |
| Shimmer cycle 1000ms on mobile with reduceAnimations | Shorter cycle |
| Stagger delay halved on reduceAnimations | 25ms gap |
| All stagger children appear simultaneously on reducedMotion | No stagger |
| Spring animation runs at 120fps on 120Hz display | Smooth high-refresh |
| OiAnimatedList handles rapid add/remove without jank on mobile | Performance test |

---

That's all of Tier 0 and Tier 1. Continuing with Tier 2 in the next section.
# obers_ui Specification v4 — Part 2: Tier 2 Components

---

# Tier 2: Components

Components are standalone UI elements that compose Tier 1 primitives. They are the most commonly used widgets in the library.

---

## Buttons

---

### OiButton

**What it is:** The primary action button for obers_ui. A single class with factory constructors for every variant: primary, secondary, outline, ghost, destructive, soft, icon-only, split (main action + dropdown), countdown (cooldown timer), and confirm (two-press safety).

**What it does:**
- Renders a themed, accessible button with label, optional icon, loading spinner, and tooltip
- Handles tap, hover, focus, active, disabled states via `OiTappable`
- Supports icon in leading or trailing position
- Supports full-width mode
- All variants share the same underlying layout; only colors/borders/backgrounds differ per variant, driven by `OiButtonThemeData` and `OiEffectsTheme`

**Composes:** `OiTappable` (for all interaction states), `OiLabel` (for label text), `OiIcon` (for icon), `OiProgress.circular` (for loading spinner), `OiSurface` (for background decoration on variants that have one)

**Props (shared across all constructors):**
```dart
// Every constructor includes these:
required String label,           // REQUIRED: visible text AND a11y label
VoidCallback? onTap,
IconData? icon,
OiIconPosition iconPosition = OiIconPosition.leading,  // leading, trailing
OiButtonSize size = OiButtonSize.medium,               // small, medium, large
bool loading = false,
bool disabled = false,            // note: onTap==null also disables
bool fullWidth = false,
String? tooltip,
```

**Variant Constructors:**

```dart
/// Solid brand-color background, white text.
OiButton.primary({...all shared props})

/// Subtle background (surfaceSubtle), standard text.
OiButton.secondary({...all shared props})

/// Transparent background, visible border.
OiButton.outline({...all shared props})

/// Transparent background, no border. Text only.
OiButton.ghost({...all shared props})

/// Red/error background. For dangerous actions.
OiButton.destructive({...all shared props})

/// Muted brand tint background. Gentle emphasis.
OiButton.soft({...all shared props})

/// Icon only. Label is REQUIRED for a11y but not shown visually.
/// Label is shown as tooltip on hover.
OiButton.icon({
  required String label,
  required IconData icon,
  required VoidCallback? onTap,
  OiButtonVariant variant = OiButtonVariant.ghost,
  OiButtonSize size = OiButtonSize.medium,
  bool loading = false,
  bool disabled = false,
  Widget? badge,                  // notification dot overlay (uses OiBadge.dot)
})

/// Main action + dropdown arrow separated by a divider.
/// Tapping the main area fires onTap. Tapping the arrow opens a dropdown menu.
OiButton.split({
  required String label,
  required VoidCallback? onTap,
  required List<OiMenuItem> dropdownItems,
  IconData? icon,
  OiButtonVariant variant = OiButtonVariant.primary,
  OiButtonSize size = OiButtonSize.medium,
  bool loading = false,
  bool disabled = false,
})

/// Disables itself for `cooldown` duration after being pressed.
/// Shows countdown in label. Used for "Resend code" patterns.
OiButton.countdown({
  required String label,
  required VoidCallback? onTap,
  required Duration cooldown,
  String Function(int secondsRemaining)? countdownLabel,  // e.g. "Resend in {n}s"
  OiButtonVariant variant = OiButtonVariant.primary,
  OiButtonSize size = OiButtonSize.medium,
})

/// Two-press safety pattern. First press changes label to confirmLabel.
/// Second press within resetAfter executes onTap. Resets after timeout.
OiButton.confirm({
  required String label,
  required VoidCallback? onTap,
  String confirmLabel = 'Are you sure?',
  Duration resetAfter = const Duration(seconds: 3),
  OiButtonVariant variant = OiButtonVariant.destructive,
  OiButtonSize size = OiButtonSize.medium,
})

enum OiButtonVariant { primary, secondary, outline, ghost, destructive, soft }
enum OiButtonSize { small, medium, large }
enum OiIconPosition { leading, trailing }
```

**Internal Layout:**
```
[ padding ]
  Row(gap: theme.button.iconGap)
    if icon && leading: OiIcon.decorative(icon)
    if !iconOnly:       OiLabel(label)
    if icon && trailing: OiIcon.decorative(icon)
    if loading:         OiProgress.circular(size: 16) replacing icon or at trailing
[ /padding ]
```

For `.split()`:
```
Row(
  OiTappable(→ main action area)
    [ icon | label ]
  VerticalDivider
  OiTappable(→ dropdown trigger)
    [ chevron-down icon ]
)
```

**States:**
- **Rest:** Variant-specific colors applied.
- **Hover:** `OiEffectsTheme.hover` + per-variant hover override from `OiButtonThemeData`.
- **Focus:** `OiEffectsTheme.focus` — focus ring visible.
- **Active/Pressed:** `OiEffectsTheme.active` — scale down.
- **Disabled:** `OiEffectsTheme.disabled` — reduced opacity, forbidden cursor. `onTap==null` is also disabled.
- **Loading:** Spinner replaces icon (or appears trailing). Button is non-interactive during loading.
- **Countdown:** Label shows remaining seconds. Button is disabled until cooldown expires.
- **Confirming:** Label changes to confirmLabel, variant may shift to destructive styling. Resets after `resetAfter`.

**Considerations:**
- `label` is always required, even for `.icon()`. This is a hard accessibility rule. For `.icon()`, the label becomes the tooltip and the `Semantics.label`.
- `loading` disables the button (no taps while loading) but shows a different visual than `disabled`.
- `.split()` has two separate `OiTappable` zones — the main area and the dropdown arrow. Each has independent hover/focus/active states. The dropdown uses `OiFloating` + `OiContextMenu` internally.
- `.countdown()` manages a `Timer` internally. On dispose, the timer is cancelled.
- `.confirm()` manages an internal boolean `_confirming`. First tap sets it true and schedules a reset. Second tap while true fires `onTap` and resets.

**Tests:**
| Test | What it verifies |
|------|-----------------|
| primary renders brand background | Background color matches colors.primary.base |
| secondary renders subtle background | Background color matches colors.surfaceSubtle |
| outline renders border, transparent bg | Border visible, bg transparent |
| ghost renders no border, no bg | Transparent |
| destructive renders error background | Background matches colors.error.base |
| soft renders muted brand tint | Background matches colors.primary.muted |
| onTap fires on tap | Callback invoked |
| onTap fires on Enter key | Keyboard activation |
| onTap fires on Space key | Keyboard activation |
| disabled blocks tap | onTap not called |
| disabled reduces opacity | Opacity matches effects.disabled.opacity |
| loading shows spinner | CircularProgress visible |
| loading blocks tap | onTap not called during loading |
| icon leading position | Icon renders before label |
| icon trailing position | Icon renders after label |
| fullWidth stretches | Button fills parent width |
| tooltip shows on hover | Tooltip appears for all variants |
| .icon() shows only icon | Label not visible, icon visible |
| .icon() tooltip shows label | Label text in tooltip |
| .icon() semantics has label | Screen reader announces label |
| .icon() badge renders | Notification dot visible |
| .split() main area fires onTap | Main tap callback |
| .split() arrow opens dropdown | Dropdown menu appears |
| .split() dropdown item fires callback | Menu item onTap fires |
| .split() separate hover zones | Hovering arrow doesn't highlight main |
| .countdown() disables after tap | Button disabled, shows countdown |
| .countdown() re-enables after cooldown | Button active again after duration |
| .countdown() shows remaining seconds | Label updates each second |
| .countdown() custom countdownLabel | Custom format function used |
| .confirm() first tap changes label | Label becomes confirmLabel |
| .confirm() second tap fires onTap | Callback invoked |
| .confirm() resets after timeout | Label reverts to original |
| .confirm() only one onTap call | Not called on first press |
| size small renders smaller | Height, font, padding correct for small |
| size large renders larger | Height, font, padding correct for large |
| hover state applies theme hover | Background/scale change on hover |
| focus ring visible on Tab | Focus ring from OiEffectsTheme.focus |
| active state on press | Scale/bg from OiEffectsTheme.active |
| theme override via OiButtonThemeScope | Subtree buttons use overridden theme |
| per-instance style override | Custom hover style on one button |
| Semantics: button role | Screen reader announces "button" |
| Semantics: disabled announced | Screen reader announces disabled |
| Semantics: label announced | Screen reader reads label text |
| reducedMotion: no animation | State transitions instant |
| Golden: every variant, light theme | Visual regression for all 6 variants |
| Golden: every variant, dark theme | Visual regression for all 6 variants |
| Golden: every size | Visual regression for small/medium/large |
| Golden: loading state | Visual regression with spinner |
| Golden: split button | Visual regression with divider + arrow |

---

### OiIconButton

**What it is:** Convenience alias for `OiButton.icon()`. Exists as a separate widget name for discoverability — developers searching for "icon button" find it immediately. Internally delegates to `OiButton.icon()`.

**Composes:** `OiButton.icon()` — this is literally a forwarding wrapper.

```dart
OiIconButton({
  required String label,
  required IconData icon,
  required VoidCallback? onTap,
  OiButtonVariant variant = OiButtonVariant.ghost,
  OiButtonSize size = OiButtonSize.medium,
  bool loading = false,
  bool disabled = false,
  bool selected = false,
  Widget? badge,
  String? tooltip,
})
```

**Considerations:** The `selected` prop adds a background tint (from `OiEffectsTheme.selected`). This makes it useful for toolbar toggles (bold, italic, etc.) without needing `OiToggleButton`.

**Tests:** Same as `OiButton.icon()` tests + selected state applies background tint. Selected + hover combines correctly.

---

### OiToggleButton

**What it is:** A button that toggles between on/off states. Can be used standalone or in a group. Think bold/italic toggles in a toolbar, or view mode toggles (list/grid).

**Composes:** `OiButton` (renders as ghost or outline variant based on selected state), `OiEffectsTheme.selected`

```dart
OiToggleButton({
  required String label,
  required bool selected,
  required ValueChanged<bool> onToggle,
  IconData? icon,
  OiButtonSize size = OiButtonSize.medium,
  bool disabled = false,
})
```

**States:** Unselected = ghost appearance. Selected = soft/subtle background tint + border (from `OiEffectsTheme.selected` or `OiButtonThemeData`).

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Tap toggles selected | onToggle(true) when off, onToggle(false) when on |
| Selected shows tint | Background tint visible |
| Unselected is ghost | Transparent background |
| Disabled blocks toggle | onToggle not called |
| Keyboard Enter toggles | Keyboard activation |
| Semantics: toggled state announced | Screen reader says "selected" or "not selected" |
| Icon renders | Icon visible with or without label |

---

### OiButtonGroup

**What it is:** A row of connected buttons with shared borders (visually joined). Can be used as an action bar (each button independent) or as a segmented control (exclusive selection, like tabs).

**What it does:**
- Renders a row of `OiButton` instances inside a single `OiSurface` with shared border radius (first child gets left radius, last gets right, middle get none)
- When `exclusive=true`, acts as a single-select toggle group
- When `exclusive=false`, each button fires its own `onTap` independently

**Composes:** `OiButton` (each item is an OiButton), `OiSurface` (shared container), `ClipRRect` (for border radius clipping)

```dart
OiButtonGroup({
  required List<OiButtonGroupItem> items,
  OiButtonSize size = OiButtonSize.medium,
  Axis direction = Axis.horizontal,
  double spacing = 0,            // 0 = connected (shared borders)
  bool exclusive = false,        // single selection mode
  int? selectedIndex,
  ValueChanged<int>? onSelect,
})

class OiButtonGroupItem {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;     // for non-exclusive mode
  final bool disabled;
}
```

**States:**
- When `exclusive=true` + `selectedIndex` is set: the selected button uses `OiButton.soft()` styling, others use `OiButton.ghost()`.
- When `spacing=0`: buttons share a border. Vertical dividers between buttons. First button has left radius, last has right radius.
- When `spacing > 0`: buttons have a gap, each retains individual border radius.

**Considerations:**
- In exclusive mode, `onTap` on individual items is ignored — use `onSelect` instead.
- Vertical direction is supported for sidebar button groups.

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Renders all items | All labels visible |
| Connected mode: shared borders | No gap, shared radius |
| Connected mode: vertical dividers | Dividers between buttons |
| Spacing mode: gap between buttons | Gap visible |
| Exclusive: tap selects | onSelect(index) fires |
| Exclusive: only one selected | Previous deselects |
| Exclusive: selected styling | Selected button has soft bg |
| Non-exclusive: individual onTap | Each fires own callback |
| Disabled item | Cannot tap, reduced opacity |
| Icons render | Icons visible on items |
| Vertical direction | Column layout works |
| First/last radius | Correct border radius |
| Keyboard: Tab between buttons | Each button focusable |
| Keyboard: arrow keys in exclusive | Left/right changes selection |
| Semantics: group announced | "button group" role |
| Golden: connected horizontal | Visual regression |
| Golden: connected vertical | Visual regression |
| Golden: spaced | Visual regression |

---

### OiBottomBar

**What it is:** A mobile bottom navigation bar. Fixed at the bottom of the screen with icon + label items, optional badge counts, and an optional floating action button in the center.

**Composes:** `OiTappable` (each item), `OiIcon`, `OiLabel`, `OiBadge.dot` / `OiBadge.count`, `OiSurface` (bar background)

```dart
OiBottomBar({
  required List<OiBottomBarItem> items,
  required int currentIndex,
  required ValueChanged<int> onTap,
  OiBottomBarStyle style = OiBottomBarStyle.fixed,
  Widget? floatingAction,
  bool showLabels = true,
  bool haptic = true,
})

class OiBottomBarItem {
  final String label;            // REQUIRED always for a11y
  final IconData icon;
  final IconData? activeIcon;
  final int? badgeCount;
  final bool showBadge;
}

enum OiBottomBarStyle { fixed, shifting, labeled, iconOnly }
```

**Considerations:**
- `label` is always required on items — even in `iconOnly` style, the label is used for `Semantics`.
- `floatingAction` is centered and slightly elevated above the bar (like a FAB in Material).
- `shifting` style: only selected item shows label, items shift to accommodate.
- Badge count >99 shows "99+".

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Renders all items | Icons visible |
| Tap changes index | onTap(index) fires |
| currentIndex highlights item | Active styling applied |
| activeIcon swaps on selection | Different icon for active |
| Badge count shows | "5" badge visible |
| Badge dot shows | Red dot visible |
| Badge 99+ | Count capped at 99+ |
| showLabels=false hides labels | Only icons visible |
| floatingAction renders | Center FAB visible |
| Haptic fires on tap | HapticFeedback called |
| Labels always in semantics | Screen reader announces labels |
| Shifting style: only active shows label | Inactive labels hidden |
| Tab key navigates items | Keyboard navigation |
| Golden: fixed style | Visual regression |
| Golden: with FAB | Visual regression |

---

### OiDrawer

**What it is:** A slide-in drawer (typically from the left edge) with optional sticky header and footer. Used for mobile navigation menus or sidebars.

**Composes:** `OiSheet` (which is an `OiSurface` that slides in), `OiFocusTrap`, `OiTappable` (close button)

```dart
OiDrawer({
  required Widget child,
  required String label,         // REQUIRED: a11y
  OiPanelSide side = OiPanelSide.left,
  double width = 300,
  Widget? header,
  Widget? footer,
  bool dismissible = true,
  VoidCallback? onDismiss,
})
```

**Considerations:**
- Managed via `OiOverlays.panel()` or inline. When opened via OiOverlays, it gets a backdrop.
- Header and footer are sticky (don't scroll). Content between them scrolls.
- Focus is trapped inside when open.

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Slides in from side | Animation plays |
| Header renders sticky | Header visible, doesn't scroll |
| Footer renders sticky | Footer visible, doesn't scroll |
| Content scrolls | Middle content scrollable |
| Dismiss on barrier tap | Closes when dismissible=true |
| onDismiss fires | Callback invoked |
| Focus trapped | Tab cycles inside drawer |
| ESC closes | Escape key dismisses |
| Width applied | Drawer has specified width |
| Screen reader announces label | Semantics label present |
| Golden: left side drawer | Visual regression |
| Golden: right side drawer | Visual regression |
| Drawer width adapts to screen size | Max 85% viewport on compact |
| Drawer swipe-from-edge to open on touch | Edge gesture support |
| Drawer safe area applied to header | Below status bar |

**Responsive Behavior for Buttons, Bottom Bar & Drawer:**

**OiButton (all variants):**
- **Touch target enforcement:** All button sizes meet the 48dp minimum touch target on touch devices. `OiButtonSize.small` visually renders smaller (height 32dp) but the tappable area is 48dp. `OiButtonSize.medium` (40dp) gets a 48dp hit area. `OiButtonSize.large` (48dp) already meets the minimum.
- **Full-width on compact:** On `compact` breakpoint, primary action buttons (`.primary()`, `.destructive()`) should be `fullWidth: true` by default in form contexts. This is a recommendation, not enforced — the consumer controls `fullWidth`.
- **Split button on compact:** `OiButton.split()` on `compact` breakpoint: the dropdown arrow area becomes a separate full-width button below the main button OR the main button fires `onTap` and the dropdown is accessible via long-press on the button. This prevents the split button from being too small for touch.
- **Countdown on mobile:** `OiButton.countdown()` countdown label must remain readable at 200% text scale. The button grows height to accommodate scaled text.

**OiButtonGroup:**
- **Overflow wrapping:** On `compact`, when a horizontal `OiButtonGroup` would exceed the available width, it wraps to a vertical layout automatically. Add `wrap: true` (default: `true`) parameter. When wrapping, each button gets full width.
- **Scrollable alternative:** When `wrap: false` and content exceeds width, the group becomes horizontally scrollable with `OiScrollbar`.

**OiBottomBar:**
- **Visibility per breakpoint:** `OiBottomBar` is only shown on `compact` and optionally `medium` breakpoints. On `expanded+`, navigation should use `OiSidebar` instead. The consumer controls this, but the spec recommends using `OiVisibility.responsive()` to show/hide the bottom bar.
- **Landscape adaptation:** On landscape phones (`compact` + landscape orientation), the bottom bar may become narrower (reduced padding) or shift to a side rail (vertical icon strip on the left edge) to save vertical space. This is opt-in via `landscapeMode: OiBottomBarLandscape.compact | rail | hidden`.
- **Safe area:** Bottom bar automatically adds bottom safe area padding (home indicator) and horizontal safe area in landscape (side notch).
- **Keyboard hiding:** Bottom bar hides when the virtual keyboard is visible (input is focused) to avoid taking up precious screen space.

**OiDrawer:**
- **Width adaptation:** On `compact`, drawer width is `min(300, screenWidth * 0.85)` — never more than 85% of screen width. On `medium+`, uses configured `width`.
- **Swipe-to-open:** On touch, the drawer can be opened by swiping from the left (or right) screen edge (within 20dp of the edge). This is an `OiApp`-level gesture that the consumer enables via `OiApp(drawerEdgeSwipe: true)`.
- **Safe area:** Drawer header area respects top safe area (status bar). Footer respects bottom safe area.
- **Backdrop interaction:** On touch, dragging the drawer closed (swiping it back toward the edge) is supported in addition to tapping the backdrop.

**Buttons & Navigation Responsive Tests:**
| Test | What it verifies |
|------|-----------------|
| Small button has 48dp touch target on touch | Touch target enforcement |
| ButtonGroup wraps to vertical on compact when overflow | Responsive wrapping |
| BottomBar hidden on expanded+ breakpoint | Breakpoint visibility |
| BottomBar adds bottom safe area padding | Safe area handling |
| BottomBar hides when keyboard visible | Keyboard avoidance |
| BottomBar landscape rail mode | Landscape adaptation |
| Drawer max 85% screen width on compact | Width constraint |
| Drawer opens on edge swipe on touch | Gesture-to-open |
| Drawer header below status bar | Safe area |
| Split button dropdown via long-press on compact/touch | Touch-friendly split |
| Golden: button group wrapped on compact | Visual regression |
| Golden: bottom bar in landscape rail mode | Visual regression |

---

## Inputs

All inputs share a common visual structure rendered by an internal `_OiInputFrame` mixin/widget:

```
Column(
  OiLabel(label, variant: smallStrong)   // label above
  OiSurface(                              // input container with border
    border: inputBorder from decoration theme or error border
    Row(
      leading?
      [input content area]               // OiRawInput or custom
      trailing?
      clearButton? (OiIconButton)
    )
  )
  if error: OiLabel(error, variant: small, color: error)
  else if hint: OiLabel(hint, variant: small, color: textMuted)
)
```

This structure is reused across OiTextInput, OiNumberInput, OiDateInput, OiTimeInput, OiSelect, OiTagInput, OiComboBox. **The `_OiInputFrame` handles label, border, error, hint, focus ring, halo, and disabled styling — individual inputs only provide the content area.**

---

### OiTextInput

**What it is:** The standard text input field. Wraps `OiRawInput` inside the `_OiInputFrame` structure with label, placeholder, hint, error, leading/trailing widgets, clear button, character count.

**Composes:** `_OiInputFrame`, `OiRawInput`, `OiIconButton` (for clear button), `OiLabel` (for label, hint, error, character count)

```dart
OiTextInput({
  required String label,
  String? placeholder,
  String? value,
  ValueChanged<String>? onChange,
  ValueChanged<String>? onSubmit,
  bool enabled = true,
  bool readOnly = false,
  bool obscure = false,
  int maxLines = 1,
  int? minLines,
  bool autoResize = false,
  Widget? leading,
  Widget? trailing,
  bool clearable = false,
  int? maxLength,
  bool showCharacterCount = false,
  String? hint,
  String? error,
  bool success = false,
  List<TextInputFormatter>? formatters,
  TextInputType? keyboard,
  TextInputAction? action,
  FocusNode? focusNode,
  TextEditingController? controller,
  OiBorderStyle? border,
  OiHaloStyle? halo,
})

// Convenience for search input:
OiTextInput.search({
  required String label,
  ValueChanged<String>? onChange,
  String? placeholder = 'Search...',
  Duration debounce = const Duration(milliseconds: 300),
  VoidCallback? onClear,
})
```

**States:**
- **Rest:** Default border from `OiDecorationTheme.inputBorder`.
- **Focused:** Focus ring from `OiEffectsTheme.focus`. Border may change to `borderFocus`.
- **Hover:** Subtle border change from `OiEffectsTheme.hover`.
- **Error:** Red border from `borderError`. Error message shows below. Halo uses `haloError`.
- **Success:** Green border from `success` color.
- **Disabled:** Reduced opacity, read-only cursor, `OiEffectsTheme.disabled`.
- **Loading:** (via parent, not self) — typically shown by composing widgets.

**Considerations:**
- `autoResize` makes the input grow vertically as the user types (useful for multi-line inputs that start small).
- `.search()` constructor adds a search icon as `leading`, adds `clearable`, and debounces `onChange`.
- `success` only affects border color — it doesn't show a message. If you want a success message, use `hint`.
- `value` is the initial value. For controlled mode, use `controller`.

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Typing fires onChange | Callback with current text |
| Enter fires onSubmit | Submit callback |
| Placeholder shows when empty | Placeholder visible |
| Placeholder hides when typing | Placeholder disappears |
| Label renders above input | Label visible |
| Hint renders below input | Hint text visible |
| Error replaces hint | Error text visible, hint hidden |
| Error shows red border | Border color is borderError |
| Error shows error halo | Halo from haloError |
| Success shows green border | Border color is success |
| Leading widget renders | Widget before input |
| Trailing widget renders | Widget after input |
| Clearable shows X when text present | Clear button visible |
| Clearable X clears text | Text cleared, onChange('') fires |
| Clearable X hidden when empty | No button when no text |
| maxLength limits input | Cannot type beyond limit |
| showCharacterCount shows count | "42/100" visible |
| obscure hides text | Dots displayed |
| readOnly prevents editing | Cannot type |
| disabled reduces opacity | Disabled styling |
| autoResize grows input | Height increases with lines |
| .search() has search icon | Magnifying glass leading |
| .search() debounces onChange | onChange fires after debounce delay |
| .search() onClear fires | Clear callback |
| Focus ring appears on focus | Focus styling from theme |
| Hover border changes | Hover border from theme |
| Custom border override | Per-instance border applied |
| Custom halo override | Per-instance halo applied |
| External controller works | Programmatic text changes |
| External focusNode works | Programmatic focus |
| Keyboard: Tab focuses input | Focus received |
| Semantics: label announced | Screen reader reads label |
| Semantics: error announced | Screen reader reads error |
| Golden: rest, focused, error, success, disabled | Visual regression for each state |

---

### OiNumberInput

**What it is:** Numeric input with stepper buttons (+/-), min/max constraints, step amount, precision control, prefix/suffix display, and mouse wheel scrolling.

**Composes:** `_OiInputFrame`, `OiRawInput` (with number formatter), `OiIconButton` (+ and - stepper buttons), `OiLabel` (prefix/suffix)

```dart
OiNumberInput({
  required String label,
  num? value,
  ValueChanged<num>? onChange,
  num? min,
  num? max,
  num step = 1,
  int precision = 0,
  bool stepper = true,
  bool scrollToChange = true,
  String? prefix,
  String? suffix,
  bool enabled = true,
  String? hint,
  String? error,
})
```

**Considerations:**
- `stepper=true` adds + and - buttons as trailing widgets inside the input frame.
- `scrollToChange=true` allows mouse wheel to increment/decrement.
- `precision=2` means display "3.14" for pi. `precision=0` means integers only.
- The input uses a `TextInputFormatter` that allows only valid numbers with the specified precision.
- `prefix` renders inside the input before the number (e.g., "$"). `suffix` renders after (e.g., "kg").

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Typing a number fires onChange | Numeric value parsed |
| Stepper + button increments | Value increases by step |
| Stepper - button decrements | Value decreases by step |
| min enforced | Cannot go below min |
| max enforced | Cannot go above max |
| Step applied correctly | Increments by step amount |
| Precision limits decimals | Only N decimal places |
| Scroll wheel changes value | Wheel up = increment |
| Prefix renders | "$" before number |
| Suffix renders | "kg" after number |
| Non-numeric input rejected | Letters cannot be typed |
| Empty input allowed | null value on empty |
| Disabled blocks all interaction | No typing, no stepper, no scroll |
| Keyboard: up/down arrows | Increment/decrement |
| Semantics: value announced | Screen reader reads current value |
| Golden: with stepper | Visual regression |

---

### OiDateInput

**What it is:** Date input field that opens an `OiDatePicker` popup and supports natural language parsing ("tomorrow", "next Friday", "Dec 25"). Can also be a date range picker with presets.

**Composes:** `_OiInputFrame`, `OiRawInput` (for typed date entry), `OiFloating` (to position popup), `OiDatePicker` (the popup calendar), `OiTappable` (calendar icon trigger)

```dart
OiDateInput({
  required String label,
  DateTime? value,
  ValueChanged<DateTime>? onChange,
  DateTime? earliest,
  DateTime? latest,
  bool naturalLanguage = true,
  String? format,
  bool enabled = true,
  String? hint,
  String? error,
})

OiDateInput.range({
  required String label,
  DateTimeRange? value,
  ValueChanged<DateTimeRange>? onChange,
  List<OiDatePreset>? presets,
  DateTime? earliest,
  DateTime? latest,
})

class OiDatePreset {
  final String label;                // "Last 7 days", "This month"
  final DateTimeRange range;
}
```

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Tap opens calendar popup | OiDatePicker visible |
| Selecting date fires onChange | DateTime value correct |
| Natural language "tomorrow" | Parses to tomorrow's date |
| Natural language "next Friday" | Parses to correct Friday |
| Earliest constraint | Cannot select before earliest |
| Latest constraint | Cannot select after latest |
| Format displays correctly | Custom date format shown |
| Range mode: select start and end | DateTimeRange returned |
| Range presets show | "Last 7 days" clickable |
| Range preset applies | Correct range selected |
| Typing date in input | Parsed on submit/blur |
| Invalid date shows error | Error state on bad input |
| Calendar icon as trailing | Calendar icon visible |
| Keyboard: type date manually | Date parsed from text |
| Popup positioned by OiFloating | Flips when no room below |

---

### OiTimeInput

**What it is:** Time input field with hour/minute selection popup. Supports 12h/24h format.

**Composes:** `_OiInputFrame`, `OiRawInput`, `OiFloating`, `OiTimePicker` (popup with hour/minute wheels or grid)

```dart
OiTimeInput({
  required String label,
  TimeOfDay? value,
  ValueChanged<TimeOfDay>? onChange,
  bool use24Hour = true,
  int minuteStep = 1,
  TimeOfDay? earliest,
  TimeOfDay? latest,
  bool enabled = true,
  String? hint,
  String? error,
})
```

**Tests:** Tap opens time picker. Selecting time fires onChange. 12h/24h mode. minuteStep skips minutes. earliest/latest constraints. Typing time works.

---

### OiSelect\<T\>

**What it is:** A dropdown selector. The trigger (which displays the selected value) is a styled `OiTappable` that opens a popup via `OiFloating` containing a list of options. Supports search, multi-select, grouping, create new, and custom option rendering.

**Composes:** `_OiInputFrame` (outer shell), `OiTappable` (trigger), `OiFloating` (popup positioning), `OiSurface` (popup surface), `OiArrowNav` (keyboard navigation in options), `OiRawInput` (search input when searchable), `OiVirtualList` (when many options), `OiCheckbox` (when multiSelect), `OiLabel`, `OiIcon`, `OiScrollbar`

```dart
OiSelect<T>({
  required String label,
  required List<OiSelectOption<T>> options,
  T? value,
  ValueChanged<T>? onSelect,
  String? placeholder,
  bool searchable = false,
  bool clearable = false,
  bool enabled = true,
  String? hint,
  String? error,

  // Grouped options
  String Function(T)? groupBy,
  List<String>? groupOrder,

  // Multi-select
  bool multiSelect = false,
  List<T>? selectedValues,
  ValueChanged<List<T>>? onMultiSelect,
  int? maxSelections,

  // Creatable
  bool creatable = false,
  ValueChanged<String>? onCreate,

  // Custom rendering
  Widget Function(OiSelectOption<T>, bool highlighted, bool selected)? optionBuilder,
})

class OiSelectOption<T> {
  final T value;
  final String label;
  final String? description;
  final IconData? icon;
  final Widget? leading;
  final bool disabled;
}
```

**States:**
- **Closed:** Shows selected value (or placeholder) in trigger.
- **Open:** Popup visible. If `searchable`, search input is focused.
- **Searching:** Options filtered by search query.
- **Multi-select open:** Checkboxes beside each option. Selecting doesn't close popup.

**Considerations:**
- When `searchable=true`, the search input (`OiRawInput`) is rendered at the top of the popup. It filters options by label match.
- When `multiSelect=true`, selecting an option toggles it without closing the popup. The trigger shows "N selected" or chip-style display.
- `groupBy` groups options under sticky headers. `groupOrder` controls header ordering.
- `creatable=true` shows a "Create '{query}'" option at the bottom when search query doesn't match any option.
- Option keyboard navigation uses `OiArrowNav` — up/down to highlight, Enter to select, Escape to close.

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Tap opens popup | Options list visible |
| Select option fires onSelect | Correct value returned |
| Popup closes on select | Single-select closes popup |
| Placeholder shows when no value | Placeholder text visible |
| Selected value shows in trigger | Label of selected option visible |
| Clearable X clears selection | value becomes null |
| Searchable shows search input | Input at top of popup |
| Search filters options | Matching options only shown |
| Multi-select: checkbox per option | Checkboxes visible |
| Multi-select: popup stays open | Doesn't close on selection |
| Multi-select: N selected in trigger | "3 selected" text |
| Multi-select: maxSelections enforced | Cannot select more |
| Grouped options: headers show | Group headers visible |
| Grouped options: order correct | Groups in specified order |
| Creatable: "Create 'x'" option | Shown when no match |
| onCreate fires | Callback with search text |
| Custom optionBuilder | Custom widget rendered |
| Disabled option not selectable | Cannot click disabled option |
| Arrow key navigation | Up/down highlights options |
| Enter selects highlighted | Selected on Enter |
| Escape closes popup | Popup dismissed |
| Focus ring on trigger | Focus styling visible |
| Error state on trigger | Red border, error message |
| Popup positioned by OiFloating | Flips when needed |
| Virtual scroll for many options | 1000 options doesn't lag |
| Semantics: combobox role | Announced correctly |
| Golden: closed, open, error | Visual regression |

---

### OiTagInput

**What it is:** Input for entering multiple tags/tokens. Each tag is a chip inside the input. Supports autocomplete suggestions, custom tag colors, drag-to-reorder, and max limit.

**Composes:** `_OiInputFrame`, `OiRawInput` (for typing new tags), `OiBadge` (each tag chip), `OiReorderable` (when reorderable), `OiFloating` + `OiSurface` + `OiArrowNav` (suggestion popup), `OiAnimatedList` (animate chip add/remove)

```dart
OiTagInput({
  required String label,
  required List<String> tags,
  required ValueChanged<List<String>> onChange,
  Future<List<String>> Function(String query)? suggestions,
  int? maxTags,
  bool allowCustom = true,
  bool reorderable = false,
  Color Function(String tag)? tagColor,
  String? placeholder,
  bool enabled = true,
  String? hint,
  String? error,
})
```

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Typing + Enter adds tag | Tag chip appears, onChange fires |
| Backspace removes last tag | Last chip removed |
| X button on chip removes tag | Specific chip removed |
| Duplicate tag prevented | Same tag not added twice |
| maxTags enforced | Cannot add more than limit |
| Suggestions popup shows | Suggestions appear while typing |
| Selecting suggestion adds tag | Tag added from suggestion |
| allowCustom=false: only suggestions | Cannot create tags not in suggestions |
| reorderable: drag chips | Chips reorder via drag |
| tagColor applied | Custom color per tag |
| Tags animate in/out | OiAnimatedList handles transitions |
| Disabled blocks editing | Cannot add/remove tags |
| Keyboard: arrow keys in suggestions | Navigate suggestion list |
| Keyboard: Escape closes suggestions | Popup dismissed |
| Semantics: each tag announced | Screen reader lists tags |

---

### OiCheckbox

**What it is:** Themed checkbox with label, optional description, and three states (checked, unchecked, indeterminate).

**Composes:** `OiTappable` (for click handling + states), `OiLabel` (label text + description), custom `CustomPainter` (checkbox icon rendering with animated check mark)

```dart
OiCheckbox({
  required String label,
  required bool? value,          // null = indeterminate
  required ValueChanged<bool?> onChange,
  String? description,
  bool enabled = true,
})
```

**Considerations:**
- The checkbox renders its own check/dash/empty icon via `CustomPainter` — not using Material's Checkbox.
- `value=null` shows a dash (indeterminate). Tapping indeterminate goes to checked.
- The entire row (checkbox + label + description) is tappable, not just the box.

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Tap toggles checked/unchecked | onChange fires with !value |
| Indeterminate shows dash | Dash mark visible |
| Indeterminate tap → checked | value becomes true |
| Label renders next to checkbox | Label text visible |
| Description renders below label | Description text visible |
| Disabled blocks toggle | onChange not called |
| Focus ring on focus | Focus styling on checkbox box |
| Keyboard Space toggles | Keyboard activation |
| Animated check mark | Check animates in/out |
| Semantics: checkbox role | Screen reader announces checkbox |
| Semantics: checked state | Screen reader announces checked/unchecked |
| Golden: all three states | Visual regression |

---

### OiSwitch

**What it is:** Themed toggle switch with label.

**Composes:** `OiTappable`, `OiLabel`, `AnimatedContainer` (thumb position), `CustomPainter` (track)

```dart
OiSwitch({
  required String label,
  required bool value,
  required ValueChanged<bool> onChange,
  String? description,
  OiSwitchSize size = OiSwitchSize.medium,
  bool enabled = true,
})

enum OiSwitchSize { small, medium }
```

**Tests:** Tap toggles. Thumb animates. Label visible. Description visible. Disabled blocks. Focus ring. Space activates. Semantics switch role. Golden for on/off/disabled.

---

### OiRadio\<T\>

**What it is:** Radio button group. Renders a list of mutually exclusive radio options.

**Composes:** `OiTappable` (each option), `OiLabel`, `CustomPainter` (radio circle)

```dart
OiRadio<T>({
  required String label,             // group label
  required List<OiRadioOption<T>> options,
  required T? value,
  required ValueChanged<T> onChange,
  Axis direction = Axis.vertical,
  bool enabled = true,
})

class OiRadioOption<T> {
  final T value;
  final String label;
  final String? description;
  final bool disabled;
}
```

**Tests:** Tap selects option. Only one selected. Disabled option blocks. Group label renders. Arrow keys navigate. Semantics radiogroup role.

---

### OiSlider

**What it is:** Horizontal slider for selecting a value within a range. Supports single value and range mode.

**Composes:** `GestureDetector`, `CustomPainter` (track + thumb), `OiLabel` (value display), `OiTooltip` (thumb value tooltip)

```dart
OiSlider({
  required String label,
  required double value,
  required ValueChanged<double> onChange,
  double min = 0,
  double max = 100,
  int? divisions,
  bool showValue = true,
  String Function(double)? formatValue,
  bool enabled = true,
})

OiSlider.range({
  required String label,
  required RangeValues value,
  required ValueChanged<RangeValues> onChange,
  double min = 0,
  double max = 100,
  String Function(double)? formatValue,
})
```

**Tests:** Drag thumb changes value. min/max enforced. divisions snaps to step. showValue displays label. formatValue customizes display. Range: two thumbs. Range: min thumb can't exceed max. Keyboard: arrow keys adjust. Semantics: slider role with value. Golden.

---

### OiColorInput

**What it is:** Color picker input. Shows a color swatch trigger that opens a color picker popup.

**Composes:** `_OiInputFrame`, `OiTappable` (trigger with color swatch), `OiFloating` (popup), `OiSurface` (popup surface), custom color picker (hue ring + saturation/brightness square + hex input)

```dart
OiColorInput({
  required String label,
  Color? value,
  ValueChanged<Color>? onChange,
  List<Color>? presets,
  bool showHex = true,
  bool showOpacity = true,
  bool enabled = true,
  String? hint,
  String? error,
})
```

**Tests:** Tap opens picker. Selecting color fires onChange. Presets selectable. Hex input works. Opacity slider works. Trigger shows selected color swatch.

---

### OiFileInput

**What it is:** File upload input with drag-and-drop zone, file type filtering, size limits, multi-file support, and upload progress.

**Composes:** `_OiInputFrame`, `OiDropZone` (drag-and-drop area), `OiTappable` (click to browse), `OiProgress.linear` (per-file progress), `OiLabel`, `OiIcon`, `OiIconButton` (remove file)

```dart
OiFileInput({
  required String label,
  ValueChanged<List<OiFileData>>? onFilesSelected,
  List<String>? allowedExtensions,
  int? maxFiles,
  int? maxFileSize,
  bool dropZone = true,
  bool multiple = true,
  bool showPreview = true,
  bool enabled = true,
  String? hint,
  String? error,
})

class OiFileData {
  final String name;
  final int size;
  final String mimeType;
  final Uint8List? bytes;
  final String? url;
}
```

**Tests:** Click opens file picker. Drag file onto zone. File type filtering. maxFiles enforced. maxFileSize enforced. Preview shows thumbnails for images. Remove button works. Multiple files. Progress bar during upload. Disabled state. Keyboard accessible.

**Responsive Behavior for All Inputs:**

All inputs share `_OiInputFrame` which handles the common responsive behaviors:

**General Input Responsiveness:**
- **Virtual keyboard handling:** When any input gains focus on mobile, the framework scrolls it into view above the keyboard (via `Scrollable.ensureVisible`). The `_OiInputFrame` cooperates with this by ensuring the label + input + error message are all part of the scrolled region.
- **Input height scaling:** All inputs grow height to accommodate system text scale (up to 200%). Labels, placeholders, and error messages scale with text. The input container height increases proportionally.
- **Full-width on compact:** All inputs render full-width on `compact` breakpoint by default. On `expanded+`, inputs respect their parent layout constraints (can be narrower in multi-column forms).
- **Touch target:** All inputs have at least 48dp total height on touch devices (including the label area). The input container itself is at least 44dp tall on touch.

**OiTextInput / OiNumberInput:**
- **Stepper buttons (OiNumberInput):** On touch, stepper +/- buttons have 48x48dp touch targets. On pointer, they are more compact (32x32). `scrollToChange` (mouse wheel increment) is disabled on touch (no wheel).
- **Search input debounce:** `.search()` debounce remains 300ms on both platforms.

**OiDateInput / OiTimeInput:**
- **Picker presentation:** On `compact`/touch, tapping the calendar/clock icon opens a full-screen bottom `OiSheet` containing the picker. On `expanded+`/pointer, it opens as a floating `OiPopover` anchored to the input (current behavior). This is the global overlay paradigm adaptation applied to pickers.
- **Natural language parsing:** Works identically on all platforms.

**OiSelect:**
- **Dropdown presentation:** On `compact`/touch, the dropdown opens as a bottom `OiSheet` with the full option list (scrollable). On `expanded+`/pointer, it opens as a floating dropdown anchored to the trigger. When `searchable`, the search input is at the top of the sheet/dropdown.
- **Multi-select on compact:** In multi-select mode on `compact`, selected items show as a count ("3 selected") in the trigger rather than inline chips (which would overflow on narrow screens). A "View selected" link opens the full selection list.

**OiTagInput:**
- **Chip wrapping on compact:** Tag chips wrap to multiple lines on `compact`. When there are many chips, the input area scrolls vertically (max height constraint) to prevent the tag input from consuming too much screen space.
- **Chip touch targets:** Each tag chip's remove (X) button has 44dp minimum touch target on touch devices.
- **Suggestion popup:** On `compact`/touch, suggestions appear as a bottom sheet. On `expanded+`/pointer, as a floating dropdown.

**OiCheckbox / OiSwitch / OiRadio:**
- **Touch target:** Checkbox, switch, and radio controls have 48dp minimum tappable area on touch. The entire label row is tappable (already specified), which typically exceeds 48dp.
- **Switch size:** `OiSwitchSize.small` is appropriate for dense pointer interfaces. On touch, default to `OiSwitchSize.medium` (or enforce 44dp minimum track height).
- **Radio layout:** On `compact`, vertical radio groups are preferred. Horizontal radio groups should wrap to vertical when they would overflow.

**OiSlider:**
- **Touch track width:** On touch, the slider track should be thicker (4dp instead of 2dp) for easier touch targeting. The thumb should be larger (24dp diameter on touch vs 16dp on pointer).
- **Value tooltip:** On touch, the value tooltip shows continuously while dragging. On pointer, it shows on hover/drag.

**OiColorInput:**
- **Picker presentation:** On `compact`/touch, the color picker opens as a full-screen sheet. On `expanded+`/pointer, as a floating popup anchored to the input.

**OiFileInput:**
- **Drop zone on touch:** The drag-and-drop zone still renders on touch (for visual consistency) but is primarily activated via the "Browse" button tap. Drop is not available on mobile (no inter-app file drop). On web, file drag-and-drop works on both touch and pointer.
- **Camera option on mobile:** On iOS/Android, `OiFileInput` should offer "Take Photo" in addition to "Browse Files" when `allowedExtensions` includes image types. This opens the device camera.
- **File preview on compact:** Image previews render smaller on `compact` (thumbnail grid instead of large previews) to conserve screen space.

**Inputs Responsive Tests:**
| Test | What it verifies |
|------|-----------------|
| Input scrolls into view when keyboard appears | Keyboard avoidance |
| Input height grows with 200% text scale | Accessible sizing |
| All inputs full-width on compact | Mobile layout |
| Number stepper buttons 48dp touch target on touch | Touch enforcement |
| Date picker opens as bottom sheet on compact/touch | Adaptive presentation |
| Date picker opens as floating popup on expanded/pointer | Standard presentation |
| Select dropdown as bottom sheet on compact/touch | Adaptive presentation |
| Select multi-select shows count on compact | Space-efficient display |
| Tag input chips wrap on compact | Multi-line wrapping |
| Tag chip X button 44dp touch target | Touch enforcement |
| Checkbox/Switch/Radio 48dp touch area | Touch enforcement |
| Slider track thicker on touch | Touch-friendly track |
| Slider thumb larger on touch | Touch-friendly thumb |
| Color picker as full-screen sheet on compact | Adaptive presentation |
| File input offers camera on mobile for image types | Mobile camera access |
| File input drop zone non-functional on mobile native | No inter-app drop |
| Golden: input at compact breakpoint | Visual regression |
| Golden: date picker as sheet vs popup | Visual regression |
| Golden: select dropdown as sheet vs popup | Visual regression |

---

## Inline Editing

---

### OiEditable\<T\>

**What it is:** A generic inline edit wrapper. Shows a display view by default; on click (or double-click), switches to an edit view. On save (blur, Enter) or cancel (Escape), switches back. This is the base for `OiEditableText`, `OiEditableSelect`, `OiEditableDate`, `OiEditableNumber`, and for inline cell editing in `OiTable`.

**Composes:** `OiTappable` (click-to-edit trigger), animation via `OiMorph` (crossfade between display and edit)

```dart
OiEditable<T>({
  required T value,
  required Widget Function(T value) displayBuilder,
  required Widget Function(T value, ValueChanged<T> onSave, VoidCallback onCancel) editBuilder,
  ValueChanged<T>? onSave,
  bool saveOnBlur = true,
  bool enabled = true,
  String? label,
})
```

**States:**
- **Display:** Shows `displayBuilder`. Cursor shows edit indicator on hover. Click switches to edit.
- **Editing:** Shows `editBuilder`. Focus is in the edit widget. Escape cancels, Enter/blur saves.
- **Saving:** (Optional) If `onSave` is async, a loading state can be shown.

**Considerations:**
- `OiEditable` is the generic wrapper. The convenience widgets (`OiEditableText`, etc.) provide typed `displayBuilder` and `editBuilder` so consumers don't have to build both manually.
- `saveOnBlur=true` means clicking outside the edit widget triggers save, not cancel. This is the expected behavior for inline editing.
- The edit widget receives `onSave` and `onCancel` callbacks — it's responsible for calling them (e.g., on Enter key, on blur).

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Click switches to edit mode | displayBuilder hidden, editBuilder shown |
| Escape cancels edit | Reverts to display, no onSave |
| Enter saves edit | onSave fires with new value |
| Blur saves when saveOnBlur=true | onSave fires on focus loss |
| Blur cancels when saveOnBlur=false | Reverts on focus loss |
| Value updates display | New value shown after save |
| Disabled blocks edit | Click does nothing |
| Hover shows edit cursor | Cursor indicator on hover |
| Crossfade animation plays | Smooth transition |
| Reduced motion: instant swap | No animation |
| Semantics: editable announced | Screen reader says "editable" |

---

### OiEditableText

**What it is:** Click to edit text inline. Shows an `OiLabel` by default, switches to an `OiTextInput` on click.

**Composes:** `OiEditable` (wrapper), `OiLabel` (display), `OiTextInput` (edit)

```dart
OiEditableText({
  required String text,
  required ValueChanged<String> onSave,
  TextStyle? style,
  String? placeholder,
  int maxLines = 1,
  String? Function(String)? validate,
  bool loading = false,
  bool enabled = true,
  String? label,
})
```

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Shows text as OiLabel | Label visible in display mode |
| Click opens OiTextInput | Input appears with current text |
| Enter saves new text | onSave fires |
| Escape reverts | Original text shown |
| Validation error shown | Error message from validate function |
| Placeholder when text empty | Placeholder in display mode |
| loading shows spinner | Progress indicator during save |

---

### OiEditableSelect

**What it is:** Click to edit a selection inline. Shows the selected label by default, switches to an `OiSelect` on click.

**Composes:** `OiEditable`, `OiLabel` (display), `OiSelect` (edit)

```dart
OiEditableSelect<T>({
  required T value,
  required List<OiSelectOption<T>> options,
  required ValueChanged<T> onSave,
  String Function(T)? displayLabel,
  bool enabled = true,
  String? label,
})
```

**Tests:** Shows value label. Click opens select. Selecting option saves. Escape cancels.

---

### OiEditableDate / OiEditableNumber

Same pattern — `OiEditable` wrapping `OiLabel` (display) + `OiDateInput` / `OiNumberInput` (edit).

**Responsive Behavior for Inline Editing:**
- **Edit trigger per platform:** On pointer, single-click switches to edit mode (current spec). On touch, double-tap switches to edit mode (single tap is reserved for selection/navigation in table contexts). Alternatively, a visible "edit" icon appears next to the value (no hover required).
- **Edit widget on compact:** When the editable value is in a tight space (e.g., table cell on compact), the edit widget opens as a small bottom sheet or popover instead of inline replacement, giving more room for the input and keyboard.
- **Save on blur adaptation:** `saveOnBlur: true` works the same on both platforms, but on touch, "blur" occurs when tapping outside the edit area (not on scroll — a scroll should not trigger save).
- **Keyboard avoidance:** When inline editing activates on mobile and the keyboard appears, the edit area scrolls into view above the keyboard.

| Test | What it verifies |
|------|-----------------|
| Double-tap to edit on touch device | Touch edit trigger |
| Single-click to edit on pointer device | Pointer edit trigger |
| Edit opens as sheet on compact in tight contexts | Adaptive edit presentation |
| Scroll does not trigger save-on-blur on touch | No accidental save |

---

## Display

---

### OiCard

**What it is:** A styled container with optional title, subtitle, leading, trailing, footer, and interactive behavior. The most common surface widget.

**Composes:** `OiSurface` (background, border, shadow, halo, gradient), `OiTappable` (when `onTap` is provided), `OiLabel` (title, subtitle), `OiDivider` (between header and body, body and footer)

```dart
OiCard({
  required Widget child,
  String? title,
  String? subtitle,
  Widget? leading,
  Widget? trailing,
  Widget? footer,
  VoidCallback? onTap,
  bool collapsible = false,
  bool defaultCollapsed = false,
  String? label,                 // REQUIRED when onTap != null
  EdgeInsets? padding,
  OiBorderStyle? border,
  OiGradientStyle? gradient,
  OiHaloStyle? halo,
})

OiCard.flat({...})               // no shadow
OiCard.outlined({...})           // border only, no shadow
OiCard.interactive({...})        // always shows hover effects (onTap or not)
OiCard.compact({...})            // reduced padding
```

**Considerations:**
- When `onTap` is provided, the entire card is wrapped in `OiTappable` and shows hover/focus/active effects.
- `collapsible` adds a chevron to the header that toggles the body/footer visibility.
- Card gradient and border override the theme defaults from `OiDecorationTheme`.

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Renders child content | Content visible |
| Title and subtitle render | Header section visible |
| Leading widget renders | Icon/avatar before title |
| Trailing widget renders | Button/badge after title |
| Footer renders with divider | Footer below body, divider between |
| onTap makes card interactive | Hover/focus effects, tap fires callback |
| Collapsible: chevron toggles body | Animated expand/collapse |
| defaultCollapsed starts closed | Body hidden initially |
| .flat() has no shadow | No BoxShadow |
| .outlined() has border only | Border visible, no shadow |
| .interactive() shows hover always | Hover effects without onTap |
| .compact() has less padding | Reduced EdgeInsets |
| label required when onTap set | Assert fires without label |
| Custom gradient applied | Gradient visible |
| Custom halo applied | Halo glow visible |
| Focus ring when interactive | Tab focus shows ring |
| Golden: all variants | Visual regression |

---

### OiBadge

**What it is:** Small label, count, or dot indicator. Used for status indicators, notification counts, and tags.

**Composes:** `OiSurface` (background), `OiLabel` (text), `OiPulse` (when pulsing)

```dart
OiBadge({
  required String label,
  OiBadgeColor color = OiBadgeColor.neutral,
  OiBadgeSize size = OiBadgeSize.medium,
  OiBadgeStyle style = OiBadgeStyle.filled,
  IconData? icon,
  bool removable = false,
  VoidCallback? onRemove,
  bool pulsing = false,
})

OiBadge.count({required int count, int maxCount = 99, OiBadgeColor color = OiBadgeColor.error})
OiBadge.dot({OiBadgeColor color = OiBadgeColor.error, bool pulsing = false})

enum OiBadgeColor { primary, accent, success, warning, error, info, neutral }
enum OiBadgeSize { small, medium, large }
enum OiBadgeStyle { filled, outlined, soft }
```

**Tests:** Label renders. Colors match theme swatch. Count shows "99+" above maxCount. Dot renders as small circle. Pulsing animates. Removable shows X button. onRemove fires. Icon renders. All styles (filled/outlined/soft). All sizes. Golden.

---

### OiAvatar

**What it is:** User avatar with image, initials fallback, icon fallback, presence status indicator, badge count, and edit overlay.

**Composes:** `OiImage` (when imageUrl), `OiLabel` (initials), `OiIcon` (icon fallback), `OiPulse` (status ring), `OiBadge.count` (badge), `OiTappable` (when onTap), `ClipOval` / `ClipRRect`

```dart
OiAvatar({
  required String label,
  String? imageUrl,
  String? initials,
  IconData? icon,
  OiAvatarSize size = OiAvatarSize.md,
  OiAvatarShape shape = OiAvatarShape.circle,
  OiPresenceStatus? status,
  bool showStatusRing = false,
  int? badgeCount,
  bool editable = false,
  VoidCallback? onTap,
  VoidCallback? onEdit,
})

enum OiAvatarSize { xs, sm, md, lg, xl, xxl }
enum OiAvatarShape { circle, rounded }
enum OiPresenceStatus { online, away, busy, offline }
```

**Considerations:**
- Fallback chain: imageUrl → initials → icon → first-letter-of-label with generated color.
- Presence status dot is a small colored circle at bottom-right. Green=online, yellow=away, red=busy, gray=offline.
- `showStatusRing` adds a pulsing ring animation around the avatar for "active" users.
- `editable` shows a camera/edit icon overlay on hover.
- `label` is required for `Semantics` — the person's name.

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Image loads and displays | Avatar shows image |
| Initials fallback when no image | "JD" text visible |
| Icon fallback when no initials | Icon visible |
| Letter fallback when nothing | First letter of label |
| Presence status dot | Colored dot at bottom-right |
| Status ring pulses | Pulsing animation for active |
| Badge count shows | Count badge at top-right |
| Editable overlay on hover | Camera icon appears |
| onEdit fires on edit overlay click | Callback invoked |
| onTap fires on click | Callback invoked |
| All sizes render correctly | Dimension check for xs through xxl |
| Circle and rounded shapes | ClipOval vs ClipRRect |
| Semantics: label announced | Screen reader reads name |
| Golden: all sizes and states | Visual regression |

---

### OiTooltip

**What it is:** A small informational popup that appears on hover or focus of its child. Positions itself via `OiFloating` and auto-flips when near viewport edges.

**Composes:** `OiFloating` (positioning), `OiSurface` (tooltip background), `OiLabel` (text content), `MouseRegion` + `Focus` (trigger detection)

```dart
OiTooltip({
  required Widget child,
  required String message,
  Widget? richContent,
  Duration delay = const Duration(milliseconds: 500),
  bool showArrow = true,
  bool interactive = false,
  double? maxWidth,
  OiAlignment preferredPosition = OiAlignment.top,
})
```

**Tests:** Appears on hover after delay. Disappears on mouse exit. Appears on focus. Arrow points to anchor. Flips when near edge. interactive keeps tooltip open when mouse enters it. richContent renders custom widget. maxWidth constrains. Screen reader gets message. Golden.

---

### OiPopover

**What it is:** A floating panel anchored to a trigger element. Like a tooltip but larger, interactive, and stays open until dismissed. Used for dropdown menus, mini-forms, info panels.

**Composes:** `OiFloating` (positioning), `OiSurface` (background), `OiFocusTrap` (trap focus when open)

```dart
OiPopover({
  required Widget trigger,
  required WidgetBuilder content,
  required String label,
  OiAlignment alignment = OiAlignment.bottomCenter,
  bool showArrow = true,
  bool dismissOnOutsideTap = true,
  double? maxWidth,
  double? maxHeight,
})
```

**Tests:** Trigger tap opens popover. Content renders. Arrow points to trigger. Flips when near edge. Outside tap dismisses when dismissOnOutsideTap. Focus trapped inside. ESC closes. Screen reader announces label. Golden.

---

### OiListTile

**What it is:** A standard list row with leading, title, subtitle, trailing, and optional swipe actions. The building block for navigation lists, settings screens, search results.

**Composes:** `OiTappable` (interaction), `OiLabel` (title, subtitle), `OiSwipeable` (when swipeActions provided)

```dart
OiListTile({
  required String title,
  String? subtitle,
  Widget? leading,
  Widget? trailing,
  VoidCallback? onTap,
  VoidCallback? onLongPress,
  bool selected = false,
  bool enabled = true,
  bool dense = false,
  List<OiSwipeAction>? leadingSwipeActions,
  List<OiSwipeAction>? trailingSwipeActions,
  bool skeleton = false,
})
```

**Tests:** Title renders. Subtitle renders. Leading/trailing render. onTap fires. Selected applies theme selected style. Dense reduces padding. Swipe actions appear on swipe. Skeleton shows shimmer. Hover/focus/active states. Semantics.

---

### OiMetric

**What it is:** A display widget for a single metric value with label, trend indicator, and optional comparison. Used in dashboards and summary cards.

**Composes:** `OiLabel` (value, label, change), `OiIcon` (trend arrow), `OiCopyable` (optional value copy)

```dart
OiMetric({
  required String label,
  required String value,
  String? previousValue,
  double? changePercent,
  OiMetricTrend? trend,
  String? unit,
  bool compact = false,
  bool copyable = false,
  Widget? sparkline,
})

enum OiMetricTrend { up, down, flat }
```

**Tests:** Value displayed large. Label below. Trend arrow renders. changePercent shows "+12%". Green for up, red for down. Sparkline renders. copyable copies value. Compact mode. Golden.

---

### OiProgress

**What it is:** Progress indicator in three flavors: linear bar, circular spinner, and step indicator.

**Composes:** `CustomPainter` (track + fill), `OiLabel` (percentage text, step labels)

```dart
OiProgress.linear({double? value, double max = 1.0, String? label, bool showPercentage = false, Color? color, Color? trackColor})
OiProgress.circular({double? value, double max = 1.0, double size = 24, double strokeWidth = 3, String? label})
OiProgress.steps({required int total, required int current, List<String>? stepLabels})
```

**States:**
- `value=null`: indeterminate animation (pulsing/spinning).
- `value` between 0 and max: determinate progress.

**Tests:** Linear: fill width proportional to value. Circular: arc proportional. Steps: dots/circles filled up to current. Indeterminate animates. showPercentage displays text. Custom colors. stepLabels. Reduced motion. Semantics: progressbar role with value. Golden.

---

### OiCodeBlock

**What it is:** Syntax-highlighted code display with line numbers, copy button, filename header, line highlighting, and collapsible mode.

**Composes:** `OiSurface` (code container), `OiCopyButton` (copy button), `OiLabel` (filename), `OiScrollbar` (horizontal scroll for long lines), syntax highlighter (built-in or pluggable)

```dart
OiCodeBlock({
  required String code,
  required String label,
  String? language,
  bool showLineNumbers = true,
  bool copyButton = true,
  bool collapsible = false,
  bool defaultCollapsed = false,
  int? maxHeight,
  Set<int>? highlightLines,
  String? filename,
})
```

**Tests:** Code renders. Syntax highlighting for known languages. Line numbers shown. Copy button copies code. Filename in header. highlightLines have background tint. Collapsible expands/collapses. maxHeight adds scroll. Horizontal scroll for long lines. Semantics: code announced. Golden.

---

### OiDiffView

**What it is:** Side-by-side or unified diff view for comparing two text blocks. Highlights additions, deletions, and modifications.

**Composes:** `OiCodeBlock` (for rendering each side), `OiLabel` (headers), `OiScrollbar`

```dart
OiDiffView({
  required String before,
  required String after,
  required String label,
  OiDiffMode mode = OiDiffMode.sideBySide,
  String? beforeLabel,
  String? afterLabel,
  bool showLineNumbers = true,
  String? language,
})

enum OiDiffMode { sideBySide, unified }
```

**Tests:** Additions highlighted green. Deletions highlighted red. Modifications highlighted yellow. Side-by-side scrolls in sync. Unified shows +/- prefixes. Line numbers. Language highlighting. Golden.

---

### OiMarkdown

**What it is:** Renders Markdown content as styled widgets.

**Composes:** Markdown parser, `OiLabel` (text), `OiCodeBlock` (code blocks), `OiImage` (images), `OiDivider` (horizontal rules), `OiSurface` (blockquotes)

```dart
OiMarkdown({
  required String content,
  required String label,
  ValueChanged<String>? onLinkTap,
  bool selectable = false,
  double? maxWidth,
})
```

**Tests:** Headings render correct sizes. Bold/italic. Code blocks use OiCodeBlock. Links tappable. Images render. Lists render. Tables render. Blockquotes styled. selectable works.

---

### OiEmptyState

**What it is:** Placeholder widget shown when a list, table, or section has no content. Shows an illustration, title, description, and optional action button.

**Composes:** `OiLabel` (title, description), `OiIcon` (icon), `OiButton` (action button), `OiColumn`

```dart
OiEmptyState({
  required String title,
  String? description,
  IconData? icon,
  Widget? illustration,
  Widget? action,
})
```

**Tests:** Title renders centered. Description below. Icon/illustration above. Action button renders. All optional fields can be null. Golden.

---

### OiSkeletonGroup

**What it is:** A loading skeleton that mimics the shape of content that hasn't loaded yet. Composes multiple `OiShimmer` shapes into a pre-configured layout (list row, card, profile, table row, etc.).

**Composes:** `OiShimmer` (each skeleton shape), `OiRow`, `OiColumn`

```dart
OiSkeletonGroup.listTile({int count = 3})
OiSkeletonGroup.card({int count = 1})
OiSkeletonGroup.profile()
OiSkeletonGroup.table({int rows = 5, int columns = 4})
OiSkeletonGroup.custom({required Widget child})  // child provides shapes, OiShimmer animates them
```

**Tests:** Correct number of skeleton items. Shimmer animation plays. Matches approximate dimensions of real content. Reduced motion stops animation.

**Responsive Behavior for Display Components:**

**OiCard:**
- **Stacking on compact:** On `compact`, cards in a horizontal row should stack vertically. This is handled by the parent layout (e.g., `OiRow(collapse: OiBreakpoint.compact)`), not by the card itself.
- **Compact padding:** On `compact`, `.compact()` variant is recommended for cards to save screen space. The default card padding uses density-aware values.
- **Collapsible default on compact:** When `collapsible: true`, cards default to collapsed on `compact` to reduce initial visual load. On `expanded+`, they default to expanded (or use `defaultCollapsed`).

**OiTooltip:**
- **Touch trigger:** On touch devices, tooltips appear on long-press (300ms) instead of hover. They dismiss on the next tap anywhere. On pointer, standard hover-after-delay behavior.
- **No auto-show on touch:** Tooltips do NOT auto-appear on touch (there is no hover event). They are always user-triggered via long-press.
- **Interactive tooltips on touch:** `interactive: true` tooltips stay open until explicitly dismissed (tap outside) on touch devices.

**OiPopover:**
- **Compact → bottom sheet:** On `compact`/touch, popovers render as bottom sheets (via `OiSheet`) instead of floating panels. The trigger animation originates from the trigger element but expands to a sheet.
- **Safe area:** Popover content respects safe areas when rendered as a sheet.

**OiListTile:**
- **Swipe actions on touch:** Swipe actions (`leadingSwipeActions`, `trailingSwipeActions`) are primarily a touch interaction. On pointer, these actions appear in a right-click context menu or as hover-revealed action buttons at the trailing edge.
- **Dense on compact:** On `compact`, `dense: true` is recommended for list tiles in data-heavy views.

**OiCodeBlock / OiDiffView:**
- **Horizontal scroll on compact:** Code blocks with long lines show a horizontal scrollbar on `compact`. The scrollbar is always visible (even on touch) since code scrolling is expected.
- **DiffView stacked on compact:** On `compact`, `OiDiffView` with `mode: sideBySide` automatically switches to `mode: unified` because side-by-side doesn't fit on narrow screens.

**OiMarkdown:**
- **Image sizing:** Images in markdown content are constrained to `maxWidth` of the container. On `compact`, large images scale to 100% width.
- **Code blocks:** Inline code and code blocks within markdown follow `OiCodeBlock` responsive behavior.

**OiMetric:**
- **Compact mode:** On `compact`, `compact: true` is the default for metrics. Value text scales down slightly to fit narrow cards.

**OiEmptyState:**
- **Illustration sizing:** On `compact`, the illustration/icon is smaller (64dp vs 128dp on desktop) to save vertical space.

**OiSkeletonGroup:**
- **Responsive shapes:** Skeleton layouts adapt to the current breakpoint. `OiSkeletonGroup.table()` uses fewer columns on `compact`. `OiSkeletonGroup.card()` uses full-width cards on `compact`.

**OiBadge / OiAvatar:**
- **Minimal responsive changes.** Badges and avatars are small fixed-size elements. Avatar sizes (`xs` through `xxl`) are the same across breakpoints. Badge touch targets are enforced when badges are interactive (e.g., `removable`).

**Display Responsive Tests:**
| Test | What it verifies |
|------|-----------------|
| Tooltip on long-press on touch | Touch trigger |
| Tooltip on hover on pointer | Standard trigger |
| Popover as bottom sheet on compact | Adaptive presentation |
| DiffView switches to unified on compact | Automatic mode change |
| Code block horizontal scrollbar visible on compact | Always-visible scrollbar |
| Empty state illustration smaller on compact | 64dp vs 128dp |
| Skeleton table fewer columns on compact | Adaptive skeleton |
| Card collapsed by default on compact when collapsible | Save screen space |
| ListTile swipe actions on touch, context menu on pointer | Platform interaction |

---

## Feedback

---

### OiStarRating

**What it is:** Star-based rating input (1-5 or customizable). Tap to rate, hover to preview.

**Composes:** `OiTappable` (each star), `OiIcon` (star icons), `OiLabel` (optional value label)

```dart
OiStarRating({
  required String label,
  required double value,
  ValueChanged<double>? onChange,
  int maxStars = 5,
  bool allowHalf = true,
  double size = 24,
  bool readOnly = false,
})
```

**Tests:** Tap sets rating. Hover previews. Half stars when allowHalf. readOnly shows but doesn't interact. onChange fires. Keyboard arrow keys. Semantics: slider role. Golden.

---

### OiScaleRating

**What it is:** Numeric scale rating (e.g., 1-10 NPS, 1-7 satisfaction). Renders as a row of number buttons.

**Composes:** `OiButtonGroup` (row of toggle buttons), `OiLabel` (scale labels at ends)

```dart
OiScaleRating({
  required String label,
  required int min,
  required int max,
  int? value,
  ValueChanged<int>? onChange,
  String? minLabel,
  String? maxLabel,
})
```

**Tests:** Tap selects number. Selected button highlighted. Labels at min/max ends. onChange fires. Keyboard navigable.

---

### OiThumbs

**What it is:** Thumbs up / thumbs down binary feedback.

**Composes:** `OiIconButton` (thumb up, thumb down)

```dart
OiThumbs({
  required String label,
  OiThumbsValue? value,
  ValueChanged<OiThumbsValue>? onChange,
  bool showCount = false,
  int upCount = 0,
  int downCount = 0,
})

enum OiThumbsValue { up, down }
```

**Tests:** Tap up selects up. Tap down selects down. Tap again deselects. Counts show. onChange fires. Semantics.

---

### OiReactionBar

**What it is:** Slack/Discord-style emoji reaction bar. Shows existing reactions with counts and allows adding new ones.

**Composes:** `OiTappable` (each reaction chip), `OiLabel` (emoji + count), `OiPopover` (emoji picker for adding), `OiAnimatedList` (animate reactions in/out)

```dart
OiReactionBar({
  required List<OiReactionData> reactions,
  required ValueChanged<String> onReact,
  required ValueChanged<String> onRemoveReact,
  List<String>? quickEmojis,
  bool compact = false,
  String? label,
})

class OiReactionData {
  final String emoji;
  final int count;
  final bool reacted;
  final List<String>? reactorNames;
}
```

**Tests:** Reactions render with emoji + count. Tap own reaction removes it. Tap other's reaction adds yours. Quick emoji picker on + button. reactorNames in tooltip. Animated add/remove. Compact layout. Keyboard accessible.

---

### OiSentiment

**What it is:** Emoji-based sentiment selector (happy → sad scale). Used for quick mood/satisfaction feedback.

**Composes:** `OiTappable` (each emoji), `OiLabel`

```dart
OiSentiment({
  required String label,
  int? value,                    // 1-5 typically
  ValueChanged<int>? onChange,
  List<String> emojis = const ['😡', '😟', '😐', '🙂', '😄'],
})
```

**Tests:** Tap selects emoji. Selected emoji highlighted. onChange fires. Keyboard navigable. Semantics.

**Responsive Behavior for Feedback Components:**

**OiStarRating:**
- **Touch target:** Each star has 48dp minimum touch target on touch. Stars may need additional horizontal spacing on touch to prevent accidental mis-taps between adjacent stars.
- **Hover preview disabled on touch:** Star preview on hover is a pointer-only behavior. On touch, stars fill on tap (no preview).

**OiScaleRating:**
- **Compact layout:** On `compact`, when the number range is wide (e.g., 0-10 NPS), the number buttons may overflow. The scale wraps to two rows or the buttons become narrower. Each button still maintains 44dp minimum touch target.
- **Labels:** `minLabel` and `maxLabel` render below the scale on `compact` (instead of inline at ends) to save horizontal space.

**OiReactionBar:**
- **Compact wrapping:** On `compact`, reactions wrap to multiple lines if there are many. The "add reaction" button (+) is always visible.
- **Emoji picker presentation:** The emoji picker triggered by the + button opens as a bottom sheet on `compact`/touch, floating popover on `expanded+`/pointer.

**OiSentiment / OiThumbs:**
- **Touch targets:** Each emoji/thumb has 48dp minimum touch target on touch.

| Test | What it verifies |
|------|-----------------|
| Star 48dp touch target on touch | Touch enforcement |
| Scale rating wraps on compact when overflow | Responsive layout |
| Reaction bar wraps on compact | Multi-line reactions |
| Emoji picker as sheet on compact/touch | Adaptive presentation |
| Sentiment emoji 48dp touch target on touch | Touch enforcement |

---

## Overlays

---

### OiDialog

**What it is:** A modal dialog with backdrop, focus trapping, and ESC dismissal. Can be invoked imperatively via `OiOverlays.dialog()` or declaratively as a widget.

**Composes:** `OiSurface` (dialog surface), `OiFocusTrap`, `OiVisibility` (enter/exit animation), backdrop `AnimatedContainer`

```dart
OiDialog({
  required Widget child,
  required String label,
  bool dismissible = true,
  double? maxWidth,
  double? maxHeight,
  EdgeInsets? padding,
  VoidCallback? onDismiss,
})
```

**Considerations:**
- Usually used via `OiOverlays.of(context).dialog(content: ...)` rather than as an inline widget.
- Focus is automatically trapped. First focusable element receives focus on open.
- ESC closes when `dismissible=true`. Backdrop click also closes.

**Tests:** Content renders. Focus trapped. ESC closes. Backdrop click closes. dismissible=false blocks both. maxWidth/maxHeight constrain. Enter/exit animation. Screen reader announces label. Golden.

---

### OiToast

**What it is:** A brief notification that appears and auto-dismisses. Supports levels (info, success, warning, error) with appropriate icons and colors, a description, and an optional action button.

**Composes:** `OiSurface`, `OiLabel`, `OiIcon` (level icon), `OiButton.ghost` (action), `OiVisibility` (animation), `OiIconButton` (close button)

```dart
OiToast({
  required String title,
  String? description,
  OiToastLevel level = OiToastLevel.info,
  Duration duration = const Duration(seconds: 4),
  Widget? action,
  OiToastPosition position = OiToastPosition.bottomRight,
  bool closable = true,
  VoidCallback? onClose,
})

enum OiToastLevel { info, success, warning, error }
enum OiToastPosition { topLeft, topCenter, topRight, bottomLeft, bottomCenter, bottomRight }
```

**Tests:** Renders with title. Level icon and color match. Description shows. Auto-dismisses after duration. Action widget renders and fires. Close button dismisses. Multiple toasts stack. Position correct. Screen reader announces. Animation in/out. Golden for each level.

---

### OiContextMenu

**What it is:** A context menu (right-click menu) that appears at cursor position with a list of items, separators, and nested submenus.

**Composes:** `OiFloating` (positioning at cursor), `OiSurface` (menu surface), `OiTappable` (each item), `OiLabel` (item text), `OiIcon` (item icons), `OiArrowNav` (keyboard navigation), `OiDivider` (separators)

```dart
OiContextMenu({
  required List<OiMenuItem> items,
  required String label,
  Offset? position,              // defaults to cursor position
  VoidCallback? onDismiss,
})

class OiMenuItem {
  final String label;
  final IconData? icon;
  final String? shortcut;        // display text like "⌘C"
  final VoidCallback? onTap;
  final bool destructive;
  final bool disabled;
  final List<OiMenuItem>? children;  // submenu
}

class OiMenuSeparator extends OiMenuItem { }
```

**Tests:** Renders at cursor position. Items show label/icon/shortcut. onTap fires and closes menu. Destructive item styled red. Disabled item not clickable. Separator renders. Nested submenu opens on hover/arrow-right. Arrow key navigation. Enter selects. Escape closes (submenu first, then parent). Focus trap. Screen reader announces. Outside click closes. Golden.

---

### OiSheet

**What it is:** A modal surface that slides in from the bottom (or side) with snap points, a drag handle, and optional background dismissal. Used for mobile bottom sheets and side panels.

**Composes:** `OiSurface`, `OiFocusTrap`, `GestureDetector` (drag handle), `AnimatedBuilder` (snap animation), backdrop

```dart
OiSheet({
  required Widget child,
  required String label,
  double initialSize = 0.5,
  List<double> snapPoints = const [0.25, 0.5, 0.9],
  bool dismissible = true,
  bool showHandle = true,
  OiPanelSide side = OiPanelSide.bottom,
  VoidCallback? onDismiss,
})

enum OiPanelSide { left, right, top, bottom }
```

**Tests:** Slides in with animation. Snap points work (drag between snaps). Handle visible. Drag down past threshold dismisses. Barrier click dismisses. Focus trapped. ESC closes. Side variants (left/right). Screen reader announces. Golden.

**Responsive Behavior for Overlay Components:**

**OiDialog:**
- **Compact → full-screen:** On `compact`, dialogs render as near-full-screen (with small top margin and rounded top corners) or as a bottom sheet that expands to ~90% of screen height. On `expanded+`, centered modal with `maxWidth` (default 560dp).
- **Safe area:** Full-screen dialogs on compact respect all safe areas (notch, home indicator).
- **Keyboard avoidance:** When a dialog contains inputs and the keyboard appears, the dialog's content scrolls to keep the focused input visible.
- **Android back dismisses:** System back gesture/button dismisses the dialog when `dismissible: true`.

**OiToast:**
- **Position per platform:** Default position is `bottomCenter` on touch (above safe area + above `OiBottomBar` if present) and `topRight` on pointer. Consumers can override.
- **Touch-friendly action:** The action widget inside a toast has a minimum 48dp touch target.
- **Keyboard avoidance:** Bottom-positioned toasts move above the keyboard when it appears.

**OiContextMenu:**
- **Touch trigger:** On touch, context menus are triggered via long-press (300ms) on the target element. The menu appears centered near the long-press point, offset slightly upward.
- **Nested submenus on touch:** Nested submenus open on tap (not hover — there is no hover on touch). A back button or swipe-right-to-go-back gesture navigates up to the parent menu.
- **Compact sizing:** On `compact`, context menu items have larger padding (48dp height) for comfortable touch targets. On `expanded+`/pointer, items are more compact (32dp height).
- **Shortcut text hidden on touch:** `shortcut` display text (e.g., "⌘C") is hidden on touch devices since keyboard shortcuts are not relevant.

**OiSheet:**
- **Safe area:** Bottom sheets add safe area padding at the bottom (home indicator). The drag handle extends into the safe area but interactive content does not.
- **Snap point adaptation:** On short screens (landscape phone), snap points may need to be adjusted. A snap at 0.9 on a short screen might obscure the status bar. `OiSheet` clamps snap points to respect top safe area.
- **Side sheets on compact:** Side sheets (`OiPanelSide.left/right`) expand to full width on `compact`. On `expanded+`, they use configured width.

**Overlay Responsive Tests:**
| Test | What it verifies |
|------|-----------------|
| Dialog full-screen on compact | Adaptive presentation |
| Dialog centered with maxWidth on expanded | Standard modal |
| Dialog respects safe areas on compact | Content not obscured |
| Dialog keyboard avoidance | Input visible above keyboard |
| Toast at bottom on touch, top-right on pointer | Platform position |
| Toast action 48dp touch target | Touch enforcement |
| Toast above keyboard when keyboard visible | Keyboard avoidance |
| Context menu via long-press on touch | Touch trigger |
| Context menu items 48dp height on touch | Touch-friendly sizing |
| Context menu shortcut text hidden on touch | No keyboard shortcuts on touch |
| Sheet bottom safe area padding | Home indicator clearance |
| Sheet snap points clamped on short screens | No status bar overlap |
| Side sheet full-width on compact | Adaptive width |
| Android back dismisses dialog/sheet | System back integration |

---

## Navigation

---

### OiTabs

**What it is:** Horizontal tab bar for switching between views. Supports scrollable mode (for many tabs), closable tabs, reorderable tabs, and badge counts.

**Composes:** `OiTappable` (each tab), `OiLabel` (tab labels), `OiIcon` (tab icons), `OiBadge` (count), `OiIconButton` (close button), `OiReorderable` (when reorderable), animated underline via `CustomPainter`

```dart
OiTabs({
  required List<OiTabItem> tabs,
  required int selectedIndex,
  required ValueChanged<int> onSelect,
  bool scrollable = false,
  bool closable = false,
  ValueChanged<int>? onClose,
  bool reorderable = false,
  void Function(int oldIndex, int newIndex)? onReorder,
})

class OiTabItem {
  final String label;
  final IconData? icon;
  final int? badgeCount;
  final bool disabled;
}
```

**Tests:** Tabs render. Tap selects. selectedIndex highlights. Underline animates to selected. Scrollable with overflow. Close button fires onClose. Reorderable drag works. Badge shows. Disabled tab not selectable. Arrow keys navigate. Semantics tablist/tab roles. Golden.

---

### OiAccordion

**What it is:** Collapsible sections. One or multiple sections can be expanded simultaneously.

**Composes:** `OiTappable` (section headers), `OiLabel` (header text), `OiIcon.decorative` (chevron), `AnimatedCrossFade` or `SizeTransition` (content expand/collapse)

```dart
OiAccordion({
  required List<OiAccordionSection> sections,
  Set<int>? expandedIndices,
  ValueChanged<Set<int>>? onExpansionChange,
  bool singleExpand = false,
  bool collapsible = true,
})

class OiAccordionSection {
  final String title;
  final Widget content;
  final IconData? icon;
  final bool disabled;
}
```

**Tests:** Tap header expands. Tap again collapses. singleExpand: only one open. Content animates height. Disabled section won't open. Chevron rotates. Keyboard Enter toggles. Semantics expanded/collapsed. Golden.

---

### OiBreadcrumbs

**What it is:** Navigation path breadcrumbs. Collapses middle items when path is deep.

**Composes:** `OiTappable` (each crumb), `OiLabel`, `OiIcon.decorative` (separator), `OiPopover` (collapsed items dropdown)

```dart
OiBreadcrumbs({
  required List<OiBreadcrumbItem> items,
  bool collapsible = true,
  int maxVisible = 4,
})

class OiBreadcrumbItem {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
}
```

**Tests:** All items render when <= maxVisible. Middle collapse to "..." when > maxVisible. Clicking "..." shows popover with collapsed items. Last item is non-clickable (current page). Separator icons between items. Keyboard navigable. Semantics navigation/breadcrumb. Golden.

---

### OiDatePicker

**What it is:** A calendar popup for selecting a date. Used internally by `OiDateInput` but also available standalone. Supports single date, date range, multiple date selection, and disabled dates.

**Composes:** `OiSurface` (container), `OiTappable` (each date cell), `OiIconButton` (nav arrows), `OiLabel` (month/year header), `OiSelect` (month/year dropdown), `OiArrowNav` (keyboard navigation)

```dart
OiDatePicker({
  DateTime? value,
  ValueChanged<DateTime>? onSelect,
  DateTime? earliest,
  DateTime? latest,
  Set<DateTime>? disabledDates,
  bool showWeekNumbers = false,
  int firstDayOfWeek = DateTime.monday,
  String? label,
})

OiDatePicker.range({
  DateTimeRange? value,
  ValueChanged<DateTimeRange>? onSelect,
  List<OiDatePreset>? presets,
  DateTime? earliest,
  DateTime? latest,
})
```

**Tests:** Calendar renders current month. Navigation arrows change month. Date cell tap selects. earliest/latest dim unavailable dates. disabledDates not selectable. Range: start and end selection. Range hover preview. Week numbers show. Arrow key navigation between dates. Enter selects. Semantics. Golden.

---

### OiTimePicker

**What it is:** Time selection popup with hour and minute columns or wheels.

**Composes:** `OiSurface`, scrollable `OiVirtualList` (hour/minute columns), `OiLabel`, `OiArrowNav`

```dart
OiTimePicker({
  TimeOfDay? value,
  ValueChanged<TimeOfDay>? onSelect,
  bool use24Hour = true,
  int minuteStep = 1,
  TimeOfDay? earliest,
  TimeOfDay? latest,
  String? label,
})
```

**Tests:** Hours and minutes selectable. 12h shows AM/PM. minuteStep skips values. earliest/latest constraints. Keyboard navigation. Golden.

---

### OiEmojiPicker

**What it is:** Grid of emojis organized by category with search. Used by `OiReactionBar` and available standalone.

**Composes:** `OiSurface`, `OiTextInput.search` (search), `OiTabs` (category tabs), `OiVirtualGrid` (emoji grid), `OiTappable` (each emoji)

```dart
OiEmojiPicker({
  ValueChanged<String>? onSelect,
  List<String>? recentEmojis,
  bool showSearch = true,
  String? label,
})
```

**Tests:** Categories render. Emoji grid populates. Search filters. Recent emojis section. Tap selects and fires onSelect. Keyboard navigation. Skin tone selector. Golden.

**Responsive Behavior for Navigation Components:**

**OiTabs:**
- **Scrollable on compact:** On `compact`, tabs default to `scrollable: true` when there are more than 3 tabs, allowing horizontal scrolling. On `expanded+`, all tabs fit in a row and scrollable is only needed when many tabs exceed width.
- **Tab close on compact:** On `compact`, `closable` tabs show the close button only when the tab is selected (to save space). On `expanded+`/pointer, close buttons appear on hover for unselected tabs.
- **Reorderable on pointer only:** Tab reordering via drag is disabled on touch by default (conflicts with scroll gesture). Use a dedicated "Manage tabs" dialog for reordering on touch.

**OiAccordion:**
- **Full-width on compact:** Accordion sections are always full-width on `compact`. No horizontal padding.
- **Single expand on compact:** On `compact`, `singleExpand: true` is recommended to reduce vertical scrolling (only one section open at a time).

**OiBreadcrumbs:**
- **Aggressive collapsing on compact:** On `compact`, `maxVisible` defaults to 2 (first item + current item, middle collapsed to "…"). On `expanded+`, defaults to 4.
- **Collapsed items as sheet on touch:** Tapping "…" on touch opens collapsed items in a small bottom sheet. On pointer, opens as a floating popover.

**OiDatePicker / OiTimePicker:**
- **Presentation:** On `compact`/touch, rendered as a full-screen bottom sheet or near-full-screen sheet. On `expanded+`/pointer, as a floating popup anchored to the input.
- **Date picker layout:** On `compact`, the date grid uses compact cell sizes (44dp square minimum for touch). Month/year selectors are prominent at the top.
- **Time picker layout:** On touch, uses scroll-wheel style (iOS-like drum picker) for hour/minute. On pointer, uses column lists with click-to-select.

**OiEmojiPicker:**
- **Presentation:** On `compact`/touch, opens as a bottom sheet filling ~60% of screen height. On `expanded+`/pointer, as a floating popup (320x400dp).
- **Grid sizing:** Emoji cells are 44dp on touch (for comfortable tapping) and 36dp on pointer.

**Navigation Responsive Tests:**
| Test | What it verifies |
|------|-----------------|
| Tabs scrollable on compact with >3 tabs | Responsive scrolling |
| Tab close button only on selected tab on compact | Space-efficient close |
| Tab reorder disabled on touch | No drag conflict with scroll |
| Breadcrumbs maxVisible=2 on compact | Aggressive collapse |
| Breadcrumb collapsed items as sheet on touch | Adaptive presentation |
| DatePicker as bottom sheet on compact/touch | Adaptive presentation |
| DatePicker date cells 44dp on touch | Touch target |
| TimePicker scroll-wheel on touch | Platform-appropriate picker |
| EmojiPicker as bottom sheet on compact/touch | Adaptive presentation |
| EmojiPicker cells 44dp on touch | Touch target |
| Golden: tabs scrollable on compact | Visual regression |
| Golden: date picker as sheet | Visual regression |

---

## Panels

---

### OiResizable

**What it is:** Makes any widget resizable by dragging its edges. Used by `OiSplitPane` and `OiPanel`.

**Composes:** `GestureDetector` (drag handles on edges/corners), `MouseRegion` (resize cursors)

```dart
OiResizable({
  required Widget child,
  double? width,
  double? height,
  double? minWidth,
  double? maxWidth,
  double? minHeight,
  double? maxHeight,
  Set<OiResizeEdge> edges = const {OiResizeEdge.right, OiResizeEdge.bottom},
  ValueChanged<Size>? onResize,
  bool showHandle = true,
})

enum OiResizeEdge { top, right, bottom, left, topLeft, topRight, bottomLeft, bottomRight }
```

**Tests:** Drag right edge resizes width. Drag bottom edge resizes height. Corner drag resizes both. minWidth/maxWidth enforced. Handle visible. Resize cursor on hover. onResize fires. Keyboard: (no keyboard resize for this primitive).

---

### OiSplitPane

**What it is:** Two panels separated by a draggable divider. Horizontal (left/right) or vertical (top/bottom).

**Composes:** `OiResizable` (divider logic), `OiSurface` (optional panel backgrounds)

```dart
OiSplitPane({
  required Widget first,
  required Widget second,
  required String label,
  Axis direction = Axis.horizontal,
  double initialRatio = 0.5,
  double? minFirst,
  double? minSecond,
  bool collapsible = false,
  ValueChanged<double>? onRatioChange,
})
```

**Tests:** Panels render side by side. Drag divider changes ratio. minFirst/minSecond enforced. Collapsible: drag past min collapses. initialRatio correct. Vertical mode. onRatioChange fires. Keyboard: arrow keys on divider. Double-click divider resets. Golden.

---

### OiPanel

**What it is:** A slide-in panel from the side of the screen. Used for detail views, inspector panels, settings drawers. Managed by `OiOverlays.panel()`.

**Composes:** `OiSurface` (panel background), `OiResizable` (when resizable), `OiFocusTrap` (when modal), `OiVisibility` (slide animation), `OiIconButton` (close button)

```dart
OiPanel({
  required Widget child,
  required String label,
  OiPanelSide side = OiPanelSide.right,
  double width = 400,
  double? minWidth,
  double? maxWidth,
  bool resizable = false,
  bool dismissible = true,
  Widget? header,
  Widget? footer,
  VoidCallback? onDismiss,
})
```

**Tests:** Slides in from specified side. Close button dismisses. Resizable drag works. min/maxWidth enforced. Header/footer sticky. Content scrolls. ESC dismisses. Barrier click dismisses when dismissible. Focus trap. Screen reader announces label. Golden.

**Responsive Behavior for Panel Components:**

**OiResizable:**
- **Disabled on touch by default:** Resizing by dragging edges is awkward on touch (hard to target the edge, conflicts with scroll). On touch, `OiResizable` shows a visible drag grip indicator but resizing is opt-in. Consumers should provide alternative resize UI on touch (e.g., size presets, pinch-to-resize).
- **Handle visibility:** On touch, resize handles are always visible as grip indicators (3 dots/lines). On pointer, handles appear on hover only.

**OiSplitPane:**
- **Stacked on compact:** On `compact`, `OiSplitPane` stacks panels vertically (for horizontal split) or shows only one panel at a time with a toggle to switch. The divider becomes a toggle bar between panels rather than a drag divider.
- **Divider touch target:** The draggable divider has a 48dp hit area on touch (even if visually thinner).
- **Keyboard resize:** On pointer/keyboard, the divider can be focused and moved with arrow keys. On touch, keyboard resize works with external keyboards.

**OiPanel:**
- **Full-width on compact:** Panels expand to full viewport width on `compact`. On `expanded+`, they use their configured `width`.
- **Swipe to dismiss on touch:** On touch, panels support swipe-to-dismiss (swipe toward the edge they came from). The swipe velocity threshold matches `OiSwipeable`.
- **Resizable disabled on touch:** Panel resize handles are not shown on touch by default. Consumers can provide a "resize" button that cycles through preset widths.
- **Safe area:** Panels at screen edges respect safe areas (side notch on landscape, top status bar).

**Panel Responsive Tests:**
| Test | What it verifies |
|------|-----------------|
| Resizable disabled on touch by default | No edge drag on touch |
| Resize grip always visible on touch | Visual indicator |
| SplitPane stacks on compact | Vertical stack or toggle |
| SplitPane divider 48dp hit area on touch | Touch-friendly divider |
| Panel full-width on compact | Adaptive width |
| Panel swipe-to-dismiss on touch | Gesture dismissal |
| Panel resize disabled on touch | No resize handle |
| Panel respects side safe area | Notch clearance |
| Golden: split pane stacked on compact | Visual regression |
| Golden: panel full-width on compact | Visual regression |

---

End of Tier 2 Components. Continuing with Tier 3 Composites.
# obers_ui Specification v4 — Part 3: Tier 3 Composites & Tier 4 Modules

---

# Tier 3: Composites

Composites are complex multi-component widgets that compose many Tier 1 and Tier 2 widgets together. They implement significant business logic and interaction patterns.

---

## Data

---

### OiTable\<T\>

**What it is:** A full-featured data table supporting sorting, filtering, column management (resize, reorder, show/hide, pin), row selection, row expansion, grouping, inline cell editing, virtualized scrolling, sticky header, pinned rows, keyboard navigation, and export. THE data table for obers_ui.

**What it does:**
- Renders a table from a list of typed rows and column definitions
- Column header is interactive: click to sort, drag to reorder, drag edge to resize
- Supports single-click row selection (single or multi) with Shift+click range and Ctrl+click toggle
- Expandable rows show detail content below the row
- Groupable rows with collapsible group headers
- Inline cell editing via `OiEditable` — click a cell to edit, blur/Enter to save
- Column filters: text, number range, date range, select, custom
- Sticky header stays visible on scroll
- Pinned columns stay visible on horizontal scroll
- Virtualized rows for 10k+ rows
- Column profile management: save/load named column configurations (which columns visible, widths, order)
- Loading and empty states
- Export callback

**Composes:**
- `OiVirtualList` (virtualized rows when virtualScroll=true)
- `OiTappable` (each cell, each header cell for sort click)
- `OiReorderable` (column header reorder)
- `OiResizable` (column resize handles)
- `OiArrowNav` (keyboard navigation: arrow keys between cells)
- `OiEditable` (inline cell editing)
- `OiCheckbox` (row selection checkboxes)
- `OiSurface` (table container)
- `OiLabel` (cell text)
- `OiIcon` (sort arrows)
- `OiPopover` (column filter dropdowns, column profile picker)
- `OiContextMenu` (row right-click menu)
- `OiScrollbar` (horizontal + vertical)
- `OiEmptyState` (when no rows)
- `OiProgress.linear` (loading bar)
- `OiInfiniteScroll` (pagination)
- `OiDivider` (row/column lines)

**Props:**
```dart
OiTable<T>({
  // ── Data ──
  required List<OiTableColumn<T>> columns,
  required List<T> rows,
  required Object Function(T) rowKey,
  required Widget Function(T row, OiTableColumn<T> column) cellBuilder,

  // ── Sorting ──
  OiTableSort? sort,
  ValueChanged<OiTableSort>? onSort,
  bool multiSort = false,

  // ── Selection ──
  OiSelectionMode selectionMode = OiSelectionMode.none,  // none, single, multi
  Set<Object> selectedKeys = const {},
  ValueChanged<Set<Object>>? onSelectionChange,

  // ── Column Management ──
  OiColumnProfile? columnProfile,
  ValueChanged<OiColumnProfile>? onColumnProfileChange,
  bool reorderColumns = false,
  bool resizeColumns = false,

  // ── Virtualization ──
  bool virtualScroll = false,
  double? rowHeight,               // required when virtualScroll=true
  int overscan = 5,

  // ── Grouping ──
  Object Function(T)? groupBy,
  Widget Function(Object key, List<T> items)? groupHeader,
  bool collapsibleGroups = true,

  // ── Row Expansion ──
  Set<Object> expandedKeys = const {},
  Widget Function(T)? rowDetail,
  ValueChanged<Set<Object>>? onExpansionChange,

  // ── Inline Editing ──
  bool editableCells = false,
  void Function(T row, OiTableColumn<T> column, dynamic newValue)? onCellEdit,

  // ── Column Filters ──
  Map<String, OiColumnFilter>? filters,
  ValueChanged<Map<String, OiColumnFilter>>? onFilterChange,

  // ── Sticky / Pinned ──
  bool stickyHeader = true,
  Set<String>? pinnedColumnIds,    // pinned to left
  List<T>? pinnedRows,
  OiPinnedPosition pinnedPosition = OiPinnedPosition.top,

  // ── Pagination / Infinite ──
  AsyncCallback? onLoadMore,
  bool hasMore = false,

  // ── Export ──
  VoidCallback? onExport,

  // ── States ──
  bool loading = false,
  Widget? emptyState,
  Widget? loadingState,

  // ── Row Context Menu ──
  List<OiMenuItem> Function(T row)? rowContextMenu,

  // ── Callbacks ──
  ValueChanged<T>? onRowTap,
  ValueChanged<T>? onRowDoubleTap,

  // ── A11y ──
  required String label,
})

class OiTableColumn<T> {
  final String id;
  final String title;
  final double? width;
  final double? minWidth;
  final double? maxWidth;
  final bool sortable;
  final bool filterable;
  final bool editable;
  final OiTableColumnAlign align;
  final int Function(T a, T b)? comparator;
  final Widget Function(T)? headerBuilder;
  final OiColumnFilterType? filterType;  // text, number, date, select, custom
}

class OiTableSort {
  final String columnId;
  final OiSortDirection direction;
}

class OiColumnProfile {
  final String name;
  final List<String> visibleColumnIds;
  final Map<String, double> columnWidths;
  final List<String> columnOrder;
}

class OiColumnFilter {
  final String columnId;
  final dynamic value;               // varies by filter type
  final OiFilterOperator operator;   // equals, contains, greaterThan, between, etc.
}

enum OiSelectionMode { none, single, multi }
enum OiSortDirection { ascending, descending }
enum OiPinnedPosition { top, bottom }
enum OiTableColumnAlign { left, center, right }
```

**States:**
- **Loading:** Loading bar at top, rows may be placeholder.
- **Empty:** Renders `emptyState` or default `OiEmptyState`.
- **Normal:** Rows render with all features.
- **Row hover:** Row background changes per `OiEffectsTheme.hover`.
- **Row selected:** Row background tinted per `OiEffectsTheme.selected`.
- **Cell editing:** Active cell shows `OiEditable` edit widget.
- **Column dragging:** Column header ghost follows cursor.
- **Column resizing:** Cursor changes, column width follows mouse.
- **Filtering:** Active filter shown as badge on column header.

**Considerations:**
- Sorting is controlled (via `sort` + `onSort`). The table does NOT sort internally — the consumer sorts the `rows` list.
- Selection is also controlled (`selectedKeys` + `onSelectionChange`). Shift+click should compute range selection using rowKey ordering.
- `virtualScroll` requires `rowHeight` because the virtual list needs fixed height. Without it, the table renders all rows (fine for <500).
- Column filter dropdowns use `OiPopover` anchored to the filter icon on each column header.
- `pinnedColumnIds` pins columns to the left. Horizontal scrolling only affects non-pinned columns.
- Row context menu fires on right-click via `OiContextMenu`.
- Keyboard: Tab to reach table, then arrow keys to navigate cells, Enter to edit cell, Escape to cancel edit, Space to toggle row selection.

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Renders columns and rows | Headers + cells visible |
| Column header click sorts | onSort fires with column + direction |
| Sort toggles direction | Asc → desc → none |
| multiSort allows multiple columns | Multiple sort indicators |
| Row click selects (single mode) | onSelectionChange with single key |
| Row click selects (multi mode) | Key added to set |
| Shift+click range selects | All rows between two clicks selected |
| Ctrl+click toggles selection | Selected row deselects |
| Checkbox column (multi select) | Checkbox in each row, header checkbox for all |
| Header checkbox: all/none/indeterminate | Three states based on selection |
| Column reorder drag | onColumnProfileChange fires with new order |
| Column resize drag | Column width changes, onColumnProfileChange fires |
| Column resize respects min/max | Cannot resize below min or above max |
| Grouping: group headers render | Group header widget visible |
| Grouping: collapse group | Rows hidden under collapsed group |
| Row expansion: expand row | Detail widget appears below row |
| Row expansion: collapse row | Detail widget hidden |
| Inline editing: click cell | OiEditable switches to edit mode |
| Inline editing: Enter saves | onCellEdit fires with new value |
| Inline editing: Escape cancels | Reverts to original |
| Column filter: filter dropdown opens | Filter UI visible in popover |
| Column filter: apply filter | onFilterChange fires |
| Column filter: badge on filtered column | Visual indicator |
| Sticky header on scroll | Header stays visible |
| Pinned columns on horizontal scroll | Left columns stay visible |
| Pinned rows at top/bottom | Pinned rows always visible |
| Virtual scroll: 10k rows | Renders without lag, only visible built |
| Virtual scroll: scroll renders new rows | Items appear on scroll |
| Pagination: onLoadMore fires | Fires when scrolled near bottom |
| Loading state | Loading bar visible |
| Empty state | Empty state widget visible |
| Row context menu on right-click | Menu appears at cursor |
| onRowTap fires | Callback with row data |
| onRowDoubleTap fires | Callback with row data |
| Export button fires | onExport callback |
| Column profile save/load | Profile roundtrips correctly |
| Arrow key cell navigation | Focus moves between cells |
| Enter starts cell edit | Edit mode on focused cell |
| Tab moves to next cell | Focus advances |
| Escape from cell exits edit | Reverts to display |
| Space toggles row selection | Row selects/deselects |
| Screen reader: table role | Announced as table |
| Screen reader: column headers | Headers announced |
| Screen reader: cell content | Cells announced on navigation |
| Screen reader: sort state | "Sorted ascending" announced |
| Hover state on rows | Row highlight from theme |
| Selected state on rows | Row tint from theme |
| Golden: light + dark theme | Visual regression |
| Golden: loading state | Visual regression |
| Golden: grouped rows | Visual regression |
| Golden: filters active | Visual regression |
| Performance: 10k rows virtual | <16ms frame time |
| Performance: sort 10k rows | Responsive sort |

---

### OiTree\<T\>

**What it is:** A hierarchical tree view with expand/collapse, selection, drag-to-reparent, lazy child loading, keyboard navigation, guide lines, and virtualization.

**Composes:**
- `OiVirtualList` (when virtualScroll=true — flattened tree nodes)
- `OiTappable` (each node)
- `OiDraggable` + `OiDropZone` (drag-to-reparent)
- `OiIcon` (expand/collapse chevron)
- `OiArrowNav` (keyboard navigation)
- `OiCheckbox` (when selectionMode=multi)
- `OiLabel` (node labels)
- `OiShimmer` (loading placeholder for lazy children)
- `CustomPainter` (guide lines)

```dart
OiTree<T>({
  required List<OiTreeNode<T>> roots,
  required Widget Function(OiTreeNode<T> node, int depth, bool expanded) nodeBuilder,
  required String label,

  ValueChanged<OiTreeNode<T>>? onNodeTap,
  ValueChanged<OiTreeNode<T>>? onNodeExpand,

  OiSelectionMode selectionMode = OiSelectionMode.none,
  Set<Object> selectedKeys = const {},
  ValueChanged<Set<Object>>? onSelectionChange,

  bool draggable = false,
  void Function(OiTreeNode<T> node, OiTreeNode<T>? newParent, int index)? onNodeMove,
  bool Function(OiTreeNode<T> node, OiTreeNode<T>? target)? canDrop,

  Future<List<OiTreeNode<T>>> Function(OiTreeNode<T>)? loadChildren,

  double indent = 24,
  bool showGuideLines = false,
  bool virtualScroll = false,
  bool keyboardNav = true,
})

class OiTreeNode<T> {
  final Object key;
  final T data;
  final String label;
  final List<OiTreeNode<T>>? children;
  final bool hasChildren;
  final IconData? icon;
}
```

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Roots render | Root nodes visible |
| Expand shows children | Click chevron shows child nodes |
| Collapse hides children | Click again hides children |
| Indent increases per depth | Deeper nodes indented more |
| Guide lines render | Lines connecting parent to children |
| Selection: single select | onSelectionChange with one key |
| Selection: multi select with checkboxes | Checkboxes per node |
| Drag-to-reparent: drag node | onNodeMove fires with new parent |
| canDrop prevents invalid drops | Visual feedback for invalid |
| Lazy loading: expand loads children | loadChildren called, shimmer shown |
| Lazy loading: children appear after load | Loaded children visible |
| Arrow up/down navigates | Focus moves between nodes |
| Arrow right expands | Collapsed node expands |
| Arrow left collapses | Expanded node collapses |
| Arrow left on collapsed: goes to parent | Focus moves up |
| Enter selects / activates | onNodeTap fires |
| Virtual scroll: 10k nodes | Only visible built |
| Screen reader: tree role | Announced as tree |
| Screen reader: expanded/collapsed | State announced |
| Screen reader: level | Depth announced |
| Golden: with guide lines | Visual regression |
| Golden: with checkboxes | Visual regression |
| Performance: 10k nodes virtual | <16ms frame time |

---

## Forms

---

### OiForm

**What it is:** A form system that renders sections of fields with validation, conditional visibility, field dependencies, autosave, dirty detection, and undo/redo. Replaces manual form building.

**Composes:**
- All Tier 2 input components (`OiTextInput`, `OiNumberInput`, `OiDateInput`, `OiSelect`, etc.)
- `OiColumn` (layout)
- `OiLabel` (section titles)
- `OiDivider` (section separators)
- `OiButton` (submit/cancel)
- `OiUndoStack` (when undoRedo=true)
- `OiVisibility` (conditional field animation)

```dart
OiForm({
  required List<OiFormSection> sections,
  required OiFormController controller,
  ValueChanged<Map<String, dynamic>>? onSubmit,
  VoidCallback? onCancel,
  bool autoValidate = false,
  Map<String, bool Function(Map<String, dynamic>)>? conditions,
  Map<String, void Function(Map<String, dynamic>)>? dependencies,
  Duration? autosave,
  bool dirtyDetection = true,
  bool undoRedo = false,
  OiFormLayout layout = OiFormLayout.vertical,
})

class OiFormSection {
  final String? title;
  final String? description;
  final List<OiFormField> fields;
}

class OiFormField {
  final String key;
  final String label;
  final OiFieldType type;           // text, number, date, time, select, checkbox, switch, radio, slider, color, file, custom
  final dynamic defaultValue;
  final bool required;
  final String? Function(dynamic)? validate;
  final Map<String, dynamic>? config;  // type-specific config (e.g., min/max for number, options for select)
  final Widget Function(dynamic value, ValueChanged<dynamic>)? customBuilder;
}

enum OiFormLayout { vertical, horizontal, inline }
```

**Considerations:**
- `OiFormController` manages form state: values, validation errors, dirty flags. Consumers create it and access `controller.values`, `controller.isValid`, `controller.isDirty`.
- `conditions` map: key = field key, value = function that returns bool given all current values. Field is hidden/shown based on return. Uses `OiVisibility` for animation.
- `dependencies` map: when a field changes, the dependency function runs and can update other field values programmatically.
- `dirtyDetection` shows a warning dialog when navigating away with unsaved changes.
- `autosave` triggers `onSubmit` after the specified duration of inactivity.
- `undoRedo` pushes every field change to `OiUndoStack`.

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Fields render from config | All field types render |
| Submit collects all values | onSubmit receives Map |
| Validation: required field empty | Error shown |
| Validation: custom validator | Error from validate function |
| autoValidate: validates on blur | Errors shown as you fill |
| Conditional field: hidden when condition false | Field not visible |
| Conditional field: shown when condition true | Field appears with animation |
| Dependencies: changing field A updates field B | Programmatic update |
| Autosave: fires after inactivity | onSubmit after duration |
| Dirty detection: warn on nav | Warning shown |
| Dirty detection: no warn when clean | No warning |
| Undo/redo: Ctrl+Z reverts field change | Previous value restored |
| Cancel resets to initial values | All fields reset |
| Section titles render | Section headers visible |
| Keyboard: Tab between fields | Focus advances |
| Screen reader: form role | Announced as form |
| Screen reader: field labels | Labels announced |
| Screen reader: errors announced | Error text read |

---

### OiWizard

**What it is:** A multi-step form wizard with step navigation, validation per step, optional summary step, and persistence of intermediate values.

**Composes:** `OiStepper` (step indicator), `OiForm` or custom content per step, `OiButton` (next/previous/submit), `OiDialog` (when rendered as modal), animated step transition

```dart
OiWizard({
  required List<OiWizardStep> steps,
  ValueChanged<Map<String, dynamic>>? onComplete,
  VoidCallback? onCancel,
  ValueChanged<int>? onStepChange,
  bool linear = true,
  bool allowSkip = false,
  bool showSummary = true,
  OiStepperStyle stepperStyle = OiStepperStyle.horizontal,
  bool animated = true,
  Map<String, dynamic>? initialValues,
})

class OiWizardStep {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget Function(OiWizardContext) builder;
  final bool Function(Map<String, dynamic>)? validate;
  final bool optional;
}

class OiWizardContext {
  final Map<String, dynamic> values;
  final int currentStep;
  final int totalSteps;
  void goNext();
  void goPrevious();
  void goToStep(int step);
  void setValue(String key, dynamic value);
}
```

**Tests:** Steps render sequentially. Next advances. Previous goes back. Validation blocks next on failure. allowSkip bypasses validation. linear prevents jumping ahead. Summary shows all values. onComplete fires with all values. animated transitions. Keyboard accessible. Semantics.

---

### OiStepper

**What it is:** A visual step indicator showing progress through a multi-step process. Used by `OiWizard` but also standalone.

**Composes:** `OiProgress.steps` (base rendering), `OiTappable` (clickable steps when not linear), `OiLabel` (step titles), `OiIcon` (step icons / checkmarks)

```dart
OiStepper({
  required int totalSteps,
  required int currentStep,
  List<String>? stepLabels,
  List<IconData>? stepIcons,
  OiStepperStyle style = OiStepperStyle.horizontal,
  ValueChanged<int>? onStepTap,
  Set<int> completedSteps = const {},
  Set<int> errorSteps = const {},
})

enum OiStepperStyle { horizontal, vertical, compact }
```

**Tests:** Correct step highlighted. Completed steps show checkmark. Error steps show error icon. Tap fires onStepTap. Horizontal and vertical layouts. Compact mode. Semantics: progress indicator.

---

## Search

---

### OiComboBox\<T\>

**What it is:** A searchable select box — the user types to filter, the dropdown shows matching options. Supports async search, multi-select, grouping, create-new, recent/favorite sections, virtualization, and pagination.

**Composes:**
- `_OiInputFrame` (outer frame)
- `OiRawInput` (search typing area)
- `OiFloating` (dropdown positioning)
- `OiSurface` (dropdown surface)
- `OiVirtualList` (virtualized options when many)
- `OiArrowNav` (keyboard option navigation)
- `OiCheckbox` (multi-select mode)
- `OiLabel` (option text, group headers)
- `OiBadge` (selected chips in multi mode)
- `OiInfiniteScroll` (pagination in dropdown)
- `OiShimmer` (loading state)

```dart
OiComboBox<T>({
  required String label,
  required String Function(T) labelOf,
  List<T> items = const [],
  T? value,
  ValueChanged<T>? onSelect,
  Future<List<T>> Function(String query)? search,
  ValueChanged<String>? onCreate,
  String? placeholder,
  bool clearable = true,
  bool enabled = true,
  String? hint,
  String? error,

  bool multiSelect = false,
  List<T> selectedValues = const [],
  ValueChanged<List<T>>? onMultiSelect,
  int? maxChipsVisible,

  String Function(T)? groupBy,
  List<String>? groupOrder,

  List<T>? recentItems,
  List<T>? favoriteItems,

  bool virtualScroll = false,
  double? itemHeight,

  Future<List<T>> Function()? loadMore,
  bool hasMore = false,

  Widget Function(T, {required bool highlighted, required bool selected})? optionBuilder,
})
```

**States:**
- **Closed:** Shows selected value (or chips for multi) in trigger area.
- **Open:** Dropdown visible, search input focused, options filtered.
- **Loading:** Shimmer placeholders in dropdown while async search runs.
- **Empty results:** "No results found" + optional "Create '{query}'" if `onCreate` is set.

**Considerations:**
- `search` is async: debounced query fires the search function, shows loading shimmer, then results.
- `items` is the initial/static list. `search` overrides it when provided.
- Multi-select: selecting doesn't close dropdown. Selected items show as chips in the trigger area. `maxChipsVisible` truncates chips with "+N more".
- `recentItems` and `favoriteItems` show in separate sections above the main list, with section headers.
- `virtualScroll` + `itemHeight` enables virtualization for 1000+ items.
- `loadMore` fires when scrolled near bottom of dropdown — for paginated APIs.
- `onCreate` adds a "Create '{query}'" option at the bottom when no exact match is found.

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Typing filters items | Matching options shown |
| Select option fires onSelect | Correct value |
| Popup closes on single select | Dropdown hidden |
| Async search: loading shown | Shimmer while searching |
| Async search: results render | Options after async completes |
| Async search: debounced | Only fires after pause |
| Multi-select: checkboxes | Checkbox per option |
| Multi-select: popup stays open | Doesn't close on select |
| Multi-select: chips in trigger | Selected items as chips |
| Multi-select: maxChipsVisible | "+2 more" text |
| Multi-select: chip remove | X on chip deselects |
| Clearable: X clears all | Value becomes null / empty |
| Grouped: headers render | Group header text visible |
| Grouped: items under headers | Correct grouping |
| Recent items section | "Recent" header + items |
| Favorite items section | "Favorites" header + items |
| Create option: "Create '{query}'" | Shown when no match |
| onCreate fires | Callback with query text |
| Virtual scroll: 1000 items | No lag |
| Pagination: loadMore fires | Scrolled near bottom |
| Arrow key navigation | Up/down highlights |
| Enter selects highlighted | Selected on Enter |
| Escape closes | Popup dismissed |
| Tab closes and confirms | Current highlight selected |
| Empty state message | "No results" shown |
| Error state | Red border, error message |
| Disabled blocks interaction | Cannot open |
| Custom optionBuilder | Custom widget per option |
| Popup positioned by OiFloating | Flips when needed |
| Semantics: combobox role | Announced correctly |
| Screen reader: option count | "3 of 10 results" |
| Golden: closed, open, multi | Visual regression |

---

### OiSearch

**What it is:** A global search overlay (like Spotlight/Alfred) with multiple search sources, result categories, optional preview pane, recent searches, and filters.

**Composes:**
- `OiDialog` or `OiSurface` (full overlay)
- `OiFocusTrap`
- `OiRawInput` (search input)
- `OiArrowNav` (result navigation)
- `OiVirtualList` (results per category)
- `OiLabel` (category headers, result titles)
- `OiIcon` (result icons)
- `OiSurface` (preview pane)
- `OiShimmer` (loading)
- `OiTabs` (filter tabs)

```dart
OiSearch({
  required List<OiSearchSource> sources,
  ValueChanged<OiSearchResult>? onSelect,
  VoidCallback? onDismiss,
  bool showRecent = true,
  int maxRecent = 10,
  bool showPreview = true,
  Duration debounce = const Duration(milliseconds: 200),
  List<OiSearchFilter>? filters,
  required String label,
})

class OiSearchSource {
  final String category;
  final IconData icon;
  final Future<List<OiSearchResult>> Function(String query) search;
  final int maxResults;
}

class OiSearchResult {
  final String id;
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Widget? preview;
}

class OiSearchFilter {
  final String label;
  final IconData? icon;
  final String key;
  final List<String> options;
}
```

**Tests:** Input focuses on open. Typing searches all sources. Results grouped by category. Arrow key navigation. Enter selects. Preview pane shows on highlight. Recent searches show on empty input. Filters narrow results. Debounced. Loading state. ESC closes. Screen reader announces result count. Golden.

---

### OiCommandBar

**What it is:** A command palette (VS Code/Raycast style) for quick access to actions via fuzzy search. Supports nested commands, keyboard shortcuts display, preview pane, and context-dependent commands.

**Composes:**
- `OiDialog` (overlay container)
- `OiFocusTrap`
- `OiRawInput` (search)
- `OiArrowNav` (navigation)
- `OiLabel` (command labels, categories, shortcuts)
- `OiIcon` (command icons)
- `OiSurface` (container)
- `OiShimmer` (loading)

```dart
OiCommandBar({
  required List<OiCommand> commands,
  VoidCallback? onDismiss,
  bool showRecent = true,
  bool fuzzySearch = true,
  Widget Function(OiCommand)? previewBuilder,
  List<OiCommand> Function(BuildContext)? contextCommands,
  required String label,
})

class OiCommand {
  final String id;
  final String label;
  final String? description;
  final IconData? icon;
  final String? category;
  final ShortcutActivator? shortcut;
  final VoidCallback? onExecute;
  final List<OiCommand>? children;
  final List<String> keywords;
  final int priority;
}
```

**Tests:** Opens on Ctrl+K. Typing filters commands. Fuzzy matching works. Arrow keys navigate. Enter executes. Nested commands drill down. Backspace goes up to parent. Shortcut text shown. Category grouping. contextCommands() adds current-context actions. Recent commands on empty input. Preview pane. ESC closes. Screen reader announces. Golden.

---

## Editors

---

### OiSmartInput

**What it is:** A text input that recognizes patterns as you type and renders them inline: @mentions, #tags, :emoji:, dates, URLs, phone numbers, emails. Each pattern gets distinct styling and can be tapped for actions.

**Composes:**
- `OiRawInput` with a custom `TextEditingController` subclass (`OiHighlightingController`) that applies `TextSpan` styling to matched patterns
- `OiFloating` + `OiArrowNav` (suggestion popup for @mentions, #tags)
- `_OiInputFrame` (label, border, error)

```dart
OiSmartInput({
  required String label,
  String? value,
  ValueChanged<String>? onChange,
  List<OiPatternRecognizer> recognizers = const [],
  Future<List<OiSuggestion>> Function(String trigger, String query)? onSuggestionQuery,
  ValueChanged<OiRecognizedSpan>? onSpanTap,
  String? placeholder,
  int maxLines = 1,
  bool enabled = true,
  String? hint,
  String? error,
})

class OiPatternRecognizer {
  final String trigger;           // "@", "#", ":", etc.
  final RegExp pattern;
  final TextStyle style;
  final bool showSuggestions;
}

class OiSuggestion {
  final String value;
  final String label;
  final Widget? leading;
}

class OiRecognizedSpan {
  final String trigger;
  final String value;
  final TextRange range;
}
```

**Tests:** @mention highlights blue. #tag highlights. Typing @ opens suggestion popup. Selecting suggestion inserts text. URL auto-detected. Email auto-detected. Span tap fires callback. Multiple recognizers coexist. Custom style applied. Keyboard: arrows in suggestions. Golden.

---

### OiRichEditor

**What it is:** A block-based rich text editor with floating toolbar, slash commands, @mentions, drag-to-reorder blocks, file embeds, tables, and code blocks. Outputs HTML, Markdown, or Delta.

**Composes:**
- Custom block editor (or wraps `flutter_quill` / similar)
- `OiSurface` (editor container)
- `OiFloating` (toolbar positioning, slash command popup, mention popup)
- `OiArrowNav` (slash command / mention navigation)
- `OiReorderable` (block drag-to-reorder)
- `OiButton` / `OiToggleButton` (toolbar buttons)
- `OiCodeBlock` (code block rendering)
- `OiImage` (embedded images)
- `OiLabel` (placeholder)

```dart
OiRichEditor({
  required OiRichEditorController controller,
  required String label,
  OiToolbarMode toolbar = OiToolbarMode.floating,
  String? placeholder,
  bool readOnly = false,
  bool autoFocus = false,
  double? minHeight,
  double? maxHeight,
  Future<List<OiMention>> Function(String query)? mentionProvider,
  Future<String> Function(OiFileData file)? onFileUpload,
  List<OiSlashCommand>? slashCommands,
  bool enableDragReorder = true,
  bool enableCodeBlocks = true,
  bool enableTables = true,
  bool enableFileEmbed = true,
  bool showWordCount = false,
  ValueChanged<OiRichContent>? onChange,
  ValueChanged<bool>? onFocusChange,
})

class OiRichContent {
  String toHtml();
  String toMarkdown();
  Map<String, dynamic> toDelta();
  String toPlainText();
  int get wordCount;
}

enum OiToolbarMode { floating, fixed, minimal, none }

class OiSlashCommand {
  final String label;
  final String? description;
  final IconData icon;
  final VoidCallback onExecute;
}
```

**Tests:** Text editing works. Bold/italic/underline via toolbar. Heading levels. Bullet/numbered lists. Slash command menu opens on "/". @mention popup on "@". Code block insertion. Image upload and embed. Drag-to-reorder blocks. toHtml/toMarkdown output correct. Word count. Floating toolbar appears on text selection. Read-only mode. Keyboard shortcuts (Ctrl+B, Ctrl+I). Semantics. Golden.

---

## Navigation

---

### OiSidebar

**What it is:** The main application sidebar with collapsible sections, nested items, icons, badges, and responsive behavior (full/compact/hidden).

**Composes:** `OiSurface` (sidebar background), `OiTappable` (each item), `OiLabel`, `OiIcon`, `OiBadge`, `OiTooltip` (in compact mode), `OiDivider` (section separators), `OiResizable` (resize sidebar width)

```dart
OiSidebar({
  required List<OiSidebarSection> sections,
  required String? selectedId,
  required ValueChanged<String> onSelect,
  required String label,
  OiSidebarMode mode = OiSidebarMode.full,
  double width = 260,
  double compactWidth = 64,
  bool resizable = false,
  Widget? header,
  Widget? footer,
})

class OiSidebarSection {
  final String? title;
  final List<OiSidebarItem> items;
  final bool collapsible;
}

class OiSidebarItem {
  final String id;
  final String label;
  final IconData icon;
  final int? badgeCount;
  final List<OiSidebarItem>? children;
  final bool disabled;
}

enum OiSidebarMode { full, compact, hidden }
```

**Tests:** Items render with icon + label. Selected item highlighted. Nested items indent. Section titles render. Compact mode: only icons, tooltip on hover. Hidden mode: nothing visible. Resizable drag changes width. Badges show. Keyboard navigable. Semantics navigation role. Golden.

---

### OiNavMenu

**What it is:** A submenu / secondary navigation list with reorderable items, icons, badges, and context menu support.

**Composes:** `OiTappable` (items), `OiLabel`, `OiIcon`, `OiBadge`, `OiReorderable` (when reorderable), `OiContextMenu` (right-click)

```dart
OiNavMenu({
  required List<OiNavMenuItem> items,
  required String? selectedId,
  required ValueChanged<String> onSelect,
  required String label,
  bool reorderable = false,
  void Function(int oldIndex, int newIndex)? onReorder,
  List<OiMenuItem> Function(OiNavMenuItem)? contextMenu,
  Widget? header,
  Widget? footer,
})

class OiNavMenuItem {
  final String id;
  final String label;
  final IconData? icon;
  final int? badgeCount;
  final Color? color;
  final bool disabled;
}
```

**Tests:** Items render. Selected highlights. Reorderable drag works. Context menu on right-click. Badges. Icons. Keyboard navigable.

---

### OiFilterBar

**What it is:** A horizontal bar of filter chips/dropdowns for narrowing data. Each filter is a clickable chip that opens a filter popover. Active filters show as filled chips with an X to remove.

**Composes:** `OiTappable` (each chip), `OiBadge` (chip appearance), `OiPopover` (filter dropdown), `OiSelect` / `OiDateInput` / `OiTextInput` (filter input types), `OiButton.ghost` (clear all), `OiScrollbar` (horizontal scroll for many filters)

```dart
OiFilterBar({
  required List<OiFilterDefinition> filters,
  required Map<String, OiColumnFilter> activeFilters,
  required ValueChanged<Map<String, OiColumnFilter>> onFilterChange,
  Widget? trailing,                // "Clear all" or "Save filter" button
})

class OiFilterDefinition {
  final String key;
  final String label;
  final OiFilterType type;       // text, select, date, dateRange, number, numberRange, custom
  final List<OiSelectOption>? options;  // for select type
  final Widget Function(dynamic value, ValueChanged<dynamic>)? customBuilder;
}
```

**Tests:** Chips render for each filter. Tap chip opens filter popover. Applying filter fills chip. Active chip shows X to remove. Clear all removes all. Date range filter. Select filter. Number range. Horizontal scroll for overflow. Screen reader announces active filters.

---

### OiShortcuts

**What it is:** A keyboard shortcut manager and help overlay. Registers shortcuts globally or per-scope, shows a "?" help dialog listing all active shortcuts.

**Composes:** Flutter `Shortcuts` + `Actions`, `OiDialog` (help overlay), `OiLabel`, `OiSurface`

```dart
OiShortcuts({
  required Widget child,
  required List<OiShortcutBinding> shortcuts,
  bool showHelpOnQuestionMark = true,
})

class OiShortcutBinding {
  final ShortcutActivator activator;
  final String label;
  final String? description;
  final String? category;
  final VoidCallback onInvoke;
}
```

**Tests:** Shortcut fires callback. Help dialog on "?". Shortcuts listed with categories. Nested scopes override. Disabled shortcuts. Screen reader announces.

---

### OiArrowNav

**What it is:** Wraps a list of focusable children and enables arrow key navigation between them. The shared navigation logic for `OiSelect`, `OiComboBox`, `OiCommandBar`, `OiContextMenu`, `OiTable`, `OiTree`, etc.

**Composes:** Flutter `FocusScope`, `RawKeyboardListener`

```dart
OiArrowNav({
  required Widget child,
  required int itemCount,
  int? highlightedIndex,
  ValueChanged<int>? onHighlightChange,
  ValueChanged<int>? onSelect,        // Enter
  VoidCallback? onEscape,
  Axis direction = Axis.vertical,
  bool loop = true,
  bool typeAhead = false,              // type letters to jump to matching
})
```

**Considerations:**
- This is a behavior widget, not visual. It manages the `highlightedIndex` and fires callbacks. The visual highlighting is done by the consumer widget based on the index.
- `typeAhead=true` enables typing characters to jump to the first item whose label starts with that character (like native OS list boxes).
- `loop=true` means arrow down on last item goes to first.

**Tests:** Arrow down increments highlightedIndex. Arrow up decrements. Loop wraps around. Enter fires onSelect. Escape fires onEscape. Horizontal mode uses left/right. typeAhead jumps to matching. No wrapping when loop=false. Multiple rapid arrows don't skip.

---

## Social / Collaboration

---

### OiAvatarStack

**What it is:** A horizontal stack of overlapping `OiAvatar` widgets with a "+N more" count.

**Composes:** `OiAvatar` (each avatar), `OiLabel` (count), `OiTooltip` (names on hover)

```dart
OiAvatarStack({
  required List<OiAvatarStackItem> users,
  int maxVisible = 4,
  OiAvatarSize size = OiAvatarSize.sm,
  double overlap = 8,
  ValueChanged<OiAvatarStackItem>? onTap,
})

class OiAvatarStackItem {
  final String label;
  final String? imageUrl;
  final String? initials;
}
```

**Tests:** Avatars overlap. maxVisible caps display. "+N" shows for overflow. Tooltip shows all names. onTap fires.

---

### OiCursorPresence

**What it is:** Shows other users' cursors on a shared surface. Each cursor is a colored pointer with a name label.

**Composes:** `CustomPainter` or `Positioned` widgets for each cursor, `OiLabel` (name)

```dart
OiCursorPresence({
  required Widget child,
  required List<OiRemoteCursor> cursors,
  bool showNames = true,
  Duration fadeAfter = const Duration(seconds: 5),
})

class OiRemoteCursor {
  final String userId;
  final String name;
  final Color color;
  final Offset position;
  final DateTime lastMoved;
}
```

**Tests:** Cursors render at positions. Names shown. Fade out after inactivity. Color per user. Smooth position animation. Semantics hidden (decorative).

---

### OiSelectionPresence

**What it is:** Shows other users' text selections or element selections with colored highlights.

```dart
OiSelectionPresence({
  required Widget child,
  required List<OiRemoteSelection> selections,
})

class OiRemoteSelection {
  final String userId;
  final String name;
  final Color color;
  final TextRange? textRange;
  final Set<Object>? selectedKeys;
}
```

---

### OiTypingIndicator

**What it is:** Shows "X is typing..." with animated dots.

**Composes:** `OiLabel`, `OiAvatar` (optional), `OiPulse` (dot animation)

```dart
OiTypingIndicator({
  required List<String> typingUsers,
  bool showAvatars = false,
  List<OiAvatarStackItem>? userDetails,
})
```

**Tests:** Shows "Alice is typing..." for one user. "Alice and Bob are typing..." for two. "3 people are typing..." for many. Animated dots. Empty list renders nothing.

---

### OiLiveRing

**What it is:** A pulsing ring around an avatar or icon indicating "live" status.

**Composes:** `OiPulse`, `DecoratedBox` (ring)

```dart
OiLiveRing({required Widget child, Color? color, bool active = true})
```

---

## Onboarding

---

### OiTour

**What it is:** A guided tour that highlights target widgets with a spotlight and shows step-by-step tooltips.

**Composes:** `OiSpotlight` (highlight), `OiSurface` (tooltip), `OiLabel` (step content), `OiButton` (next/previous/skip), `OiProgress.steps` (step indicator), custom `CustomPainter` (overlay mask)

```dart
OiTour({
  required List<OiTourStep> steps,
  VoidCallback? onComplete,
  VoidCallback? onSkip,
  ValueChanged<int>? onStepChange,
  bool showProgress = true,
  bool showSkip = true,
  Color? overlayColor,
  bool dismissOnOutsideTap = false,
})

class OiTourStep {
  final GlobalKey target;
  final String title;
  final String description;
  final OiAlignment position;
  final Widget? customContent;
  final String? actionLabel;
  final VoidCallback? onAction;
}
```

**Tests:** Overlay covers screen. Target widget spotlighted. Tooltip at correct position. Next advances. Previous goes back. Skip fires onSkip. Complete fires onComplete. Progress indicator. Scroll to target if offscreen. Resize repositions. Screen reader announces step. Golden.

---

### OiSpotlight

**What it is:** Highlights a single widget by dimming everything else. Lower-level than `OiTour` — used for single-step highlighting.

**Composes:** Custom `CustomPainter` (draws overlay with cutout), `AnimatedBuilder`

```dart
OiSpotlight({
  required GlobalKey target,
  required Widget child,
  bool active = true,
  Color overlayColor = Colors.black54,
  double padding = 8,
  BorderRadius? borderRadius,
})
```

**Tests:** Overlay renders. Cutout around target. Padding around cutout. borderRadius on cutout. Active toggles. Animation.

---

### OiWhatsNew

**What it is:** A "what's new" changelog dialog that shows recent feature updates.

**Composes:** `OiDialog`, `OiLabel`, `OiIcon`, `OiImage`, `OiButton`

```dart
OiWhatsNew({
  required List<OiWhatsNewItem> items,
  VoidCallback? onDismiss,
  String title = "What's New",
})

class OiWhatsNewItem {
  final String title;
  final String description;
  final IconData? icon;
  final String? imageUrl;
  final String? version;
}
```

---

## Scheduling

---

### OiGantt

**What it is:** Gantt chart for project scheduling. Shows tasks as horizontal bars on a timeline with dependencies, drag-to-move, drag-to-resize, grouping, and zoom levels.

**Composes:** `OiSurface`, `OiTappable` (task bars), `OiScrollbar` (horizontal + vertical), `CustomPainter` (grid, dependency arrows, today line), `OiLabel` (task labels, dates), `OiPopover` (task detail on click), `OiResizable` (task resize handles)

```dart
OiGantt({
  required List<OiGanttTask> tasks,
  required String label,
  DateTime? viewStart,
  DateTime? viewEnd,
  OiGanttZoom zoom = OiGanttZoom.week,
  ValueChanged<OiGanttTask>? onTaskTap,
  void Function(OiGanttTask, DateTime start, DateTime end)? onTaskMove,
  void Function(OiGanttTask, DateTime newEnd)? onTaskResize,
  bool showDependencies = true,
  bool showToday = true,
  bool showWeekends = true,
  Object Function(OiGanttTask)? groupBy,
  Widget Function(Object key)? groupHeader,
})

class OiGanttTask {
  final Object key;
  final String label;
  final DateTime start;
  final DateTime end;
  final double progress;
  final Color? color;
  final Object? group;
  final List<Object>? dependsOn;
}

enum OiGanttZoom { day, week, month, quarter }
```

**Tests:** Tasks render as bars. Correct position/width from dates. Drag moves task. Resize changes end date. Dependencies drawn as arrows. Today line. Weekends shaded. Grouping with headers. Zoom changes scale. Keyboard navigation. Screen reader announces tasks. Golden.

---

### OiCalendar

**What it is:** A calendar view (day/week/month) for displaying and managing events. Supports drag-to-move, drag-to-resize, and drag-to-create.

**Composes:** `OiSurface`, `OiTappable` (date cells, events), `CustomPainter` (grid), `OiLabel`, `OiIconButton` (navigation), `OiPopover` (event detail)

```dart
OiCalendar({
  required List<OiCalendarEvent> events,
  required String label,
  OiCalendarMode mode = OiCalendarMode.month,
  DateTime? initialDate,
  ValueChanged<OiCalendarEvent>? onEventTap,
  ValueChanged<DateTime>? onDateTap,
  void Function(OiCalendarEvent, DateTime start, DateTime end)? onEventMove,
  void Function(OiCalendarEvent, DateTime newEnd)? onEventResize,
  bool showWeekNumbers = false,
  bool showAllDayRow = true,
  int firstDayOfWeek = DateTime.monday,
})

class OiCalendarEvent {
  final Object key;
  final String title;
  final DateTime start;
  final DateTime end;
  final bool allDay;
  final Color? color;
}

enum OiCalendarMode { day, week, month }
```

**Tests:** Month view renders grid. Events on correct dates. Multi-day events span. Week view with hours. Day view with hours. Event drag moves. Event resize. Date tap fires. Mode switching. Navigation arrows. Today highlighted. Week numbers. Screen reader announces.

---

### OiTimeline

**What it is:** A vertical timeline showing events in chronological order. Used for activity history, changelogs, project milestones.

**Composes:** `OiColumn`, `OiLabel`, `OiIcon`, `OiSurface` (event cards), `CustomPainter` (vertical line + dots)

```dart
OiTimeline({
  required List<OiTimelineEvent> events,
  required String label,
  bool showTimestamps = true,
  bool alternating = false,
  bool collapsible = false,
})

class OiTimelineEvent {
  final DateTime timestamp;
  final String title;
  final String? description;
  final Widget? content;
  final IconData? icon;
  final Color? color;
}
```

**Tests:** Events in chronological order. Vertical line connects dots. Timestamps shown. Icons per event. Alternating left/right. Collapsible sections. Semantics.

---

## Workflow

---

### OiFlowGraph

**What it is:** A node-and-edge graph editor for visual workflows. Supports adding nodes, connecting ports with edges, moving nodes, zooming, panning, grid snapping.

**Composes:** `OiPinchZoom` (zoom/pan), `OiDraggable` (node moving), `CustomPainter` (grid, edges, port dots), `OiSurface` (each node), `OiTappable` (node/port click), `OiContextMenu` (node right-click)

```dart
OiFlowGraph({
  required List<OiFlowNode> nodes,
  required List<OiFlowEdge> edges,
  required String label,
  Widget Function(OiFlowNode)? nodeBuilder,
  ValueChanged<OiFlowNode>? onNodeTap,
  void Function(OiFlowNode, Offset)? onNodeMove,
  void Function(String sourcePort, String targetPort)? onEdgeCreate,
  ValueChanged<OiFlowEdge>? onEdgeDelete,
  bool editable = true,
  bool zoomable = true,
  bool pannable = true,
  bool snapToGrid = true,
  double gridSize = 20,
})

class OiFlowNode {
  final Object key;
  final Offset position;
  final String label;
  final IconData? icon;
  final Color? color;
  final List<String> inputs;
  final List<String> outputs;
  final Map<String, dynamic>? data;
}

class OiFlowEdge {
  final Object sourceNode;
  final String sourcePort;
  final Object targetNode;
  final String targetPort;
  final String? label;
  final bool animated;
}
```

**Tests:** Nodes render at positions. Edges connect ports. Drag node moves. Snap to grid. Drag from port creates edge. Edge deletion. Zoom in/out. Pan canvas. Context menu on node. Custom nodeBuilder. Animated edges dash. Keyboard: select node, arrow to move. Screen reader: nodes and connections. Golden. Performance: 500 nodes.

---

### OiStateDiagram

**What it is:** A visual state machine diagram showing states as nodes and transitions as labeled edges. Read-only visualization (or editable like OiFlowGraph).

**Composes:** `OiFlowGraph` (extends/wraps with state-specific rendering), `OiSurface` (state nodes with rounded shape), `CustomPainter` (transition arrows with labels)

```dart
OiStateDiagram({
  required List<OiState> states,
  required List<OiTransition> transitions,
  required String label,
  Object? currentState,
  bool editable = false,
  ValueChanged<Object>? onStateSelect,
})
```

---

### OiPipeline

**What it is:** A linear pipeline/workflow view showing sequential stages with status indicators. Like CI/CD pipeline visualization.

**Composes:** `OiRow`, `OiSurface` (stage cards), `OiLabel`, `OiIcon`, `OiProgress` (stage progress), `CustomPainter` (connecting arrows)

```dart
OiPipeline({
  required List<OiPipelineStage> stages,
  required String label,
  Axis direction = Axis.horizontal,
})

class OiPipelineStage {
  final String label;
  final OiPipelineStatus status;
  final Widget? content;
  final Duration? duration;
}

enum OiPipelineStatus { pending, running, completed, failed, skipped }
```

---

## Visualization

### OiHeatmap, OiTreemap, OiSankey, OiRadarChart, OiFunnelChart, OiGauge

These all follow the same pattern:

**Composes:** `CustomPainter` (primary rendering), `OiTappable` (interactive cells/segments), `OiTooltip` (hover info), `OiLabel` (axis labels, legends), `OiSurface` (container)

Each has:
- A `required String label` for a11y
- Data props specific to the chart type
- Color customization via theme colors or explicit
- Hover tooltip with values
- Optional legend

Example `OiGauge`:
```dart
OiGauge({
  required double value,
  required String label,
  double min = 0,
  double max = 100,
  List<OiGaugeSegment>? segments,
  String Function(double)? formatValue,
  bool showValue = true,
  double? target,
})
```

**Tests per visualization:** Renders data correctly. Hover shows tooltip. Legend renders. Responsive sizing. Custom colors. Screen reader: chart description. Golden.

---

## Media

---

### OiLightbox

**What it is:** Full-screen image viewer with gallery navigation, zoom, swipe, and thumbnails.

**Composes:** `OiDialog` (full-screen overlay), `OiPinchZoom` (zoom), `OiSwipeable` (next/prev), `OiImage` (images), `OiIconButton` (close, nav arrows), `OiLabel` (captions), thumbnail strip

```dart
OiLightbox({
  required List<OiLightboxItem> items,
  required int initialIndex,
  VoidCallback? onDismiss,
  bool showThumbnails = true,
  bool enableZoom = true,
  bool enableSwipe = true,
  required String label,
})

class OiLightboxItem {
  final String src;
  final String alt;
  final String? caption;
}
```

**Tests:** Image renders full-screen. Swipe navigates. Arrow buttons navigate. Zoom works. Thumbnails strip shows. Caption text. Close button. ESC closes. Keyboard: arrow keys navigate. Screen reader: alt text. Golden.

---

### OiImageCropper

**What it is:** Image crop tool with aspect ratio lock, rotate, and flip.

**Composes:** `OiDialog` (container), `OiPinchZoom` (zoom/pan), `OiSlider` (zoom control), `OiButtonGroup` (aspect ratios, rotate, flip), `OiButton` (save/cancel), `CustomPainter` (crop mask overlay)

```dart
OiImageCropper({
  required ImageProvider image,
  ValueChanged<OiCropResult>? onCrop,
  double? aspectRatio,
  List<double>? aspectRatioOptions,
  bool enableRotate = true,
  bool enableFlip = true,
  required String label,
})
```

---

### OiGallery

**What it is:** Image/media gallery grid with selection, upload, and lightbox preview.

**Composes:** `OiVirtualGrid` (virtualized grid), `OiImage` (thumbnails), `OiCheckbox` (selection overlay), `OiTappable` (click to open lightbox), `OiLightbox` (full-screen preview), `OiFileInput` (upload area)

```dart
OiGallery({
  required List<OiGalleryItem> items,
  required String label,
  int columns = 4,
  OiSelectionMode selectionMode = OiSelectionMode.none,
  Set<Object> selectedKeys = const {},
  ValueChanged<Set<Object>>? onSelectionChange,
  ValueChanged<OiGalleryItem>? onItemTap,
  bool showUpload = false,
  ValueChanged<List<OiFileData>>? onUpload,
})
```

---

### OiVideoPlayer

**What it is:** Video player with controls, progress bar, fullscreen, and playback speed.

**Composes:** Flutter video_player, `OiSlider` (progress), `OiIconButton` (play/pause, fullscreen, volume), `OiLabel` (time), `OiSurface` (controls bar)

```dart
OiVideoPlayer({
  required String src,
  required String label,
  bool autoPlay = false,
  bool loop = false,
  bool showControls = true,
  double? aspectRatio,
})
```

---

## Responsive Behavior for All Tier 3 Composites

This section provides comprehensive responsive behavior for every Tier 3 composite, organized by sub-group.

---

### Data: OiTable, OiTree

**OiTable:**
- **Compact layout (card list):** On `compact`, the table switches from a traditional column-based table to a **card list** layout. Each row becomes a card showing key columns as label-value pairs stacked vertically. The column header row is hidden. The consumer specifies which columns are "primary" (always visible in card mode) and which are "secondary" (shown in an expandable detail section of the card). Add `compactLayout: OiTableCompactLayout.cardList | horizontalScroll | default` parameter.
- **Horizontal scroll fallback:** Alternatively, `compactLayout: horizontalScroll` keeps the traditional table but enables horizontal scrolling with pinned first column on `compact`. A swipe indicator shows that more columns are available.
- **Column hiding per breakpoint:** `OiTableColumn` adds `visibleAt: Set<OiBreakpoint>` (default: all breakpoints). Low-priority columns can be hidden on compact: `visibleAt: {expanded, large, extraLarge}`.
- **Filter as sheet:** Column filter dropdowns open as bottom sheets on `compact`/touch instead of floating popovers.
- **Selection on touch:** Row selection on touch uses a leading swipe-right gesture to reveal checkboxes, or a long-press to enter selection mode. On pointer, checkboxes are always visible in multi-select mode.
- **Cell editing on touch:** Inline cell editing on touch opens a small bottom sheet with the edit input (instead of replacing the cell inline) for more comfortable editing with the keyboard.
- **Resize/reorder disabled on touch:** Column resize and column reorder via drag are disabled on touch. Use a "Manage columns" dialog/sheet for column configuration on touch.
- **Sticky header on all platforms:** Sticky header works identically on all platforms.
- **Context menu:** Row context menu triggered by long-press on touch, right-click on pointer.
- **Pull-to-refresh:** Supported on touch when `onRefresh` callback is provided.

**OiTree:**
- **Touch-friendly indentation:** On touch, the expand/collapse chevron has a 48dp touch target. Indent per level is reduced on `compact` (16dp instead of 24dp) to save horizontal space.
- **Drag-to-reparent on touch:** Uses long-press to initiate (same as all drag on touch). Auto-scroll when dragging near edges.
- **Guide lines on compact:** Guide lines are thinner on compact (0.5dp) and may be hidden entirely on very deep trees (>5 levels) to save space.
- **Virtual scroll on mobile:** Strongly recommended for trees with >200 nodes on mobile for performance.

| Test | What it verifies |
|------|-----------------|
| Table card list layout on compact | Rows become cards |
| Table horizontal scroll with pinned first column on compact | Alternative compact layout |
| Table column hidden via visibleAt on compact | Column visibility per breakpoint |
| Table filter as bottom sheet on compact/touch | Adaptive filter |
| Table long-press enters selection mode on touch | Touch selection |
| Table cell edit as sheet on compact/touch | Adaptive inline edit |
| Table column resize/reorder disabled on touch | No drag on touch |
| Table pull-to-refresh on touch | Refresh gesture |
| Tree chevron 48dp touch target on touch | Touch enforcement |
| Tree indent 16dp on compact | Compact indent |
| Golden: table card list on compact | Visual regression |

---

### Forms: OiForm, OiWizard, OiStepper

**OiForm:**
- **Single column on compact:** On `compact`, `OiFormLayout.horizontal` (side-by-side labels) switches to `OiFormLayout.vertical` (labels above inputs). Fields stack in a single column regardless of the `layout` setting.
- **Multi-column on expanded+:** On `expanded+`, `OiFormLayout.horizontal` renders labels to the left of inputs (label: 30%, input: 70%). Multi-section forms can use 2-column grids for shorter fields.
- **Section collapsing on compact:** On `compact`, form sections are collapsible by default. Only the current section is expanded; others collapse to save screen space.
- **Sticky submit button on compact:** On `compact`, the submit/cancel buttons stick to the bottom of the screen (above safe area) rather than being at the end of a long scrolling form.

**OiWizard:**
- **Vertical stepper on compact:** On `compact`, `OiStepperStyle.horizontal` switches to `OiStepperStyle.compact` (shows "Step 2 of 5" text instead of a full horizontal step bar). The horizontal stepper doesn't fit on narrow screens.
- **Full-screen steps on compact:** Each wizard step fills the full viewport on `compact`. Navigation buttons (Next/Previous) are sticky at the bottom.
- **Step transition:** On `compact`, step transitions use slide-left/slide-right animation. On `expanded+`, crossfade.

**OiStepper:**
- **Compact mode on compact:** On `compact`, `OiStepperStyle.horizontal` automatically switches to `OiStepperStyle.compact` which shows "Step N of M" as a text label with a progress bar underneath, instead of the full step dots with labels.
- **Step labels hidden on compact:** In `compact` mode, individual step labels are hidden; only the current step label is shown.

| Test | What it verifies |
|------|-----------------|
| Form single column on compact | Vertical layout |
| Form horizontal labels on expanded | Side-by-side labels |
| Form sections collapsible on compact | Space-saving |
| Form submit button sticky on compact | Always visible |
| Wizard vertical/compact stepper on compact | Adaptive stepper |
| Wizard step fills viewport on compact | Full-screen steps |
| Wizard sticky navigation buttons on compact | Always visible |
| Stepper compact mode on compact | "Step N of M" text |

---

### Search: OiComboBox, OiSearch, OiCommandBar

**OiComboBox:**
- **Dropdown → bottom sheet:** On `compact`/touch, the dropdown opens as a bottom sheet with the search input at the top. On `expanded+`/pointer, floating dropdown anchored to the input.
- **Multi-select chips:** On `compact`, selected chips are shown as a count ("3 selected") with an expandable chip list, instead of inline chips that overflow.
- **Virtual scroll in sheet:** The bottom sheet option list uses virtualization for large option sets.

**OiSearch:**
- **Full-screen on compact:** On `compact`, the search overlay fills the entire screen (with safe area respect). The search input is at the top, results fill the remaining space. No preview pane on compact.
- **Preview pane hidden on compact:** `showPreview: false` is forced on `compact` (no room for split-pane results + preview).
- **Filter tabs scrollable on compact:** If `filters` are provided, filter tabs are horizontally scrollable on `compact`.

**OiCommandBar:**
- **Full-screen on compact:** On `compact`, the command bar fills the entire screen. On `expanded+`, it's a centered floating overlay (640px max width).
- **Recent/frequent on compact:** On `compact`, show more recent commands by default (since typing is slower on mobile).
- **Shortcut text hidden on touch:** Command shortcut labels (e.g., "⌘K") are hidden on touch devices.

| Test | What it verifies |
|------|-----------------|
| ComboBox dropdown as sheet on compact/touch | Adaptive presentation |
| ComboBox chips as count on compact | Space-efficient chips |
| Search full-screen on compact | Full-screen overlay |
| Search preview pane hidden on compact | No preview on narrow |
| CommandBar full-screen on compact | Full-screen overlay |
| CommandBar shortcuts hidden on touch | No keyboard hints on touch |

---

### Editors: OiSmartInput, OiRichEditor

**OiSmartInput:**
- **Suggestion popup as sheet:** On `compact`/touch, the @mention and #tag suggestion popup opens as a small bottom sheet instead of a floating popup.
- **Pattern tap action:** On touch, tapping a recognized span (e.g., @mention) shows the action in a bottom sheet. On pointer, it's a floating popover or inline action.

**OiRichEditor:**
- **Toolbar mode on compact:** On `compact`, `toolbar: OiToolbarMode.floating` is forced regardless of the configured mode. The toolbar appears above the keyboard (at the bottom of the editor) as a horizontal scrollable bar, similar to mobile note-taking apps. On `expanded+`, the configured toolbar mode applies.
- **Slash commands on compact:** Slash command popup opens as a bottom sheet on `compact`/touch.
- **Block reorder on touch:** Drag-to-reorder blocks uses long-press initiation on touch. A visible drag handle appears on each block when the editor is in edit mode.
- **File embed on touch:** File upload triggers the system file picker (or camera on mobile for images).
- **Table editing on compact:** Block-level tables in the rich editor switch to a simplified card-per-row editing mode on `compact`.

| Test | What it verifies |
|------|-----------------|
| SmartInput suggestions as sheet on compact/touch | Adaptive popup |
| RichEditor toolbar at bottom above keyboard on compact | Mobile toolbar |
| RichEditor slash commands as sheet on compact | Adaptive popup |
| RichEditor block reorder via long-press on touch | Touch drag |
| RichEditor file embed uses camera on mobile | Camera access |

---

### Navigation: OiSidebar, OiNavMenu, OiFilterBar, OiShortcuts, OiArrowNav

**OiSidebar:**
- **Mode per breakpoint:** See global Navigation Paradigm Adaptation section. Compact → hidden (or drawer via edge swipe). Medium → compact mode (icons only, 64px, with tooltips). Expanded+ → full mode (icons + labels, 260px).
- **Auto-collapse:** When the viewport shrinks from expanded to medium, the sidebar automatically collapses from full to compact mode. When shrinking further to compact, it hides entirely (accessible via drawer).
- **Swipe-to-open on compact:** On compact/touch, swiping from the left edge opens the sidebar as a drawer overlay.

**OiNavMenu:**
- **Item spacing on touch:** Nav menu items have 48dp minimum height on touch for comfortable tapping.
- **Reorder on touch:** Reordering uses long-press drag on touch. On pointer, immediate drag on handle.
- **Context menu on touch:** Right-click context menu on nav items becomes long-press menu on touch.

**OiFilterBar:**
- **Collapse to button on compact:** On `compact`, the filter bar collapses to a single "Filters" button (with a count badge showing active filter count). Tapping the button opens a bottom sheet with the full filter list. On `expanded+`, filter chips are shown inline.
- **Horizontal scroll:** When inline chips exceed available width on medium/expanded, the bar scrolls horizontally.

**OiShortcuts:**
- **Help dialog adaptation:** The keyboard shortcut help dialog (triggered by "?") uses a full-screen sheet on `compact` and a centered dialog on `expanded+`.
- **Touch-only devices:** On touch-only devices (no keyboard attached), the help dialog shows a message indicating that keyboard shortcuts are available when an external keyboard is connected.
- **Platform mapping:** All shortcut display labels use platform-appropriate modifier symbols (⌘ on macOS, Ctrl on others).

**OiArrowNav:**
- **Touch interaction:** `OiArrowNav` is primarily keyboard-driven. On touch, it provides no direct interaction — the consumer widget handles tap selection. However, when an external keyboard is attached to a touch device, arrow navigation activates.
- **Type-ahead on touch:** `typeAhead` is disabled on touch (no physical keyboard for typing). It activates when an external keyboard is detected.

| Test | What it verifies |
|------|-----------------|
| Sidebar hidden on compact, drawer via edge swipe | Responsive mode |
| Sidebar compact (icons only) on medium | Compact mode |
| Sidebar full on expanded+ | Full mode |
| Sidebar auto-collapses on viewport shrink | Smooth transition |
| FilterBar collapses to button on compact | Single button + sheet |
| FilterBar chip scroll on medium/expanded | Horizontal overflow |
| NavMenu items 48dp height on touch | Touch target |
| Shortcuts help as sheet on compact | Adaptive presentation |
| ArrowNav activates with external keyboard on tablet | Keyboard on touch |

---

### Social: OiAvatarStack, OiCursorPresence, OiSelectionPresence, OiTypingIndicator, OiLiveRing

**Social Widgets:**
- **Minimal responsive changes.** These are small, inline widgets. Key considerations:
- **OiAvatarStack:** On `compact`, reduce `maxVisible` to 3 (from default 4) and use `OiAvatarSize.xs` for tighter stacking.
- **OiCursorPresence:** On touch devices, cursor presence is less relevant (no persistent cursor). `OiCursorPresence` should hide remote cursors on touch-only devices since they don't map to the touch interaction model. Show them only when a pointer device is detected.
- **OiTypingIndicator:** No responsive changes — works identically on all platforms.
- **OiLiveRing:** On `reducedMotion` or `reduceAnimations`, the pulsing animation is static (just a colored ring with no pulse).

---

### Onboarding: OiTour, OiSpotlight, OiWhatsNew

**OiTour:**
- **Tooltip positioning on compact:** On `compact`, tour step tooltips render below or above the spotlight target, full-width with horizontal padding. On `expanded+`, tooltips can be positioned to the side of the target.
- **Scroll to target:** On `compact`, if the target is offscreen, the tour auto-scrolls to make the target visible before spotlighting it.
- **Step navigation on touch:** On touch, swipe left/right navigates between tour steps (in addition to Next/Previous buttons). Buttons are at the bottom of the tooltip with 48dp touch targets.
- **Overlay on compact:** The spotlight overlay extends edge-to-edge including safe areas. The cutout respects the target's position.

**OiSpotlight:**
- **Responsive cutout:** The cutout padding scales with density: more padding on touch (12dp) vs pointer (8dp) to account for finger size.

**OiWhatsNew:**
- **Presentation on compact:** On `compact`, the "What's New" dialog renders as a full-screen sheet with swipeable items (like an onboarding carousel). On `expanded+`, as a centered dialog.

| Test | What it verifies |
|------|-----------------|
| Tour tooltip full-width on compact | Compact positioning |
| Tour auto-scrolls to offscreen target | Scroll-to-target |
| Tour swipe navigation on touch | Gesture navigation |
| WhatsNew as full-screen sheet on compact | Adaptive presentation |
| Spotlight cutout larger padding on touch | Touch-friendly cutout |

---

### Scheduling: OiGantt, OiCalendar, OiScheduler, OiTimeline

**OiGantt:**
- **Horizontal scroll with pinned labels on compact:** On `compact`, the task label column is pinned to the left (140dp width) and the timeline scrolls horizontally. The time header is sticky at the top.
- **Zoom adaptation:** On `compact`, default zoom is `week` or `month` (wider view). `day` zoom is too detailed for narrow screens.
- **Drag disabled on touch:** Task drag-to-move and drag-to-resize are disabled on touch by default (too fiddly). Users tap a task to open a detail sheet with date pickers for editing.
- **Vertical layout on compact:** Optionally, Gantt can switch to a vertical timeline layout on `compact` (tasks listed vertically with date ranges as text rather than bars).

**OiCalendar:**
- **Default mode per breakpoint:** On `compact`, default to `day` mode (single day view with hourly grid). On `medium`, `week` mode (3-day view). On `expanded+`, full `week` or `month` mode.
- **Event tap on touch:** Tapping an event opens a detail sheet instead of an inline popover. On pointer, popover anchored to the event.
- **Drag-to-create on pointer only:** Drag-to-create events by dragging across time slots is pointer-only. On touch, tap an empty time slot to create an event.
- **Event drag-to-move on touch:** Long-press and drag on touch. Immediate drag on pointer.

**OiTimeline:**
- **Alternating disabled on compact:** On `compact`, `alternating: false` is forced (events only on one side of the line) to fit narrow screens.
- **Compact event cards:** On `compact`, timeline event cards are full-width with reduced padding.

| Test | What it verifies |
|------|-----------------|
| Gantt horizontal scroll with pinned labels on compact | Compact layout |
| Gantt drag disabled on touch | No drag, use sheet |
| Calendar defaults to day mode on compact | Responsive default |
| Calendar event tap opens sheet on touch | Adaptive detail |
| Calendar drag-to-create pointer-only | No drag-create on touch |
| Timeline alternating disabled on compact | Single-side layout |
| Golden: Gantt on compact | Visual regression |
| Golden: Calendar day mode on compact | Visual regression |

---

### Workflow: OiFlowGraph, OiStateDiagram, OiPipeline

**OiFlowGraph:**
- **Zoom controls on touch:** On touch, add visible zoom control buttons (+/- and "fit-to-view") since pinch-to-zoom is less precise for fine adjustments.
- **Node movement on touch:** Long-press a node to start dragging. On pointer, immediate click-and-drag.
- **Edge creation on touch:** Drag from port starts on long-press on the port dot (which has 48dp touch target). On pointer, click-and-drag from port.
- **Mini-map on compact:** On `compact`, show a mini-map in the corner for orientation when the graph is larger than the viewport.

**OiStateDiagram:**
- Same responsive behaviors as `OiFlowGraph` (it wraps/extends it).

**OiPipeline:**
- **Vertical on compact:** On `compact`, `direction: Axis.horizontal` switches to `Axis.vertical`. Pipeline stages stack vertically with connecting arrows pointing down instead of right.
- **Stage cards full-width:** Stage cards are full-width on `compact`.

| Test | What it verifies |
|------|-----------------|
| FlowGraph zoom controls visible on touch | On-screen +/- buttons |
| FlowGraph node drag via long-press on touch | Touch drag initiation |
| FlowGraph port touch target 48dp | Touch enforcement |
| Pipeline vertical on compact | Vertical layout |
| Pipeline stages full-width on compact | Adaptive card size |

---

### Visualization: OiHeatmap, OiTreemap, OiSankey, OiRadarChart, OiFunnelChart, OiGauge

**All Visualization Widgets:**
- **Responsive sizing:** All visualization widgets fill their container. They use `LayoutBuilder` to adapt to available space. On `compact`, visualizations are typically full-width in a single column.
- **Touch-friendly tooltips:** On touch, data tooltips appear on tap (not hover). Tapping a data point shows the tooltip; tapping elsewhere dismisses it. On pointer, tooltips appear on hover.
- **Legend placement:** On `compact`, legends move from the right side to below the chart to save horizontal space.
- **Minimum viable size:** Each visualization has a minimum useful size below which it renders a "View full screen" button instead of a cramped chart. `OiGauge`: 120dp. `OiRadarChart`: 200dp. `OiHeatmap`: 200x150dp.
- **Performance on mobile:** Complex visualizations (`OiSankey`, `OiTreemap` with many nodes) should reduce detail on mobile. Fewer data labels, simpler paths, reduced animation.

| Test | What it verifies |
|------|-----------------|
| Chart tooltip on tap on touch, hover on pointer | Platform interaction |
| Chart legend below chart on compact | Responsive legend |
| Chart "View full screen" below minimum size | Minimum viable size |
| Gauge renders correctly at 120dp | Minimum size |
| Golden: radar chart on compact | Visual regression |

---

### Media: OiLightbox, OiImageCropper, OiGallery, OiVideoPlayer

**OiLightbox:**
- **Gesture navigation on touch:** Swipe left/right to navigate between images. Swipe down to dismiss. Pinch-to-zoom on current image. On pointer, use arrow keys and arrow buttons.
- **Thumbnail strip on compact:** Thumbnails are hidden by default on `compact` (they take up valuable screen space). Show a "N of M" counter instead. Thumbnails can be shown on drag-up gesture.
- **Close button safe area:** Close button is positioned below the top safe area (status bar/notch).

**OiImageCropper:**
- **Full-screen on compact:** Image cropper is always full-screen on `compact`. Aspect ratio options and rotate/flip buttons are in a bottom toolbar.
- **Touch-friendly controls:** Crop handles have 48dp touch targets. Pinch-to-zoom for fine adjustment.

**OiGallery:**
- **Responsive columns:** Gallery column count adapts per breakpoint. `compact`: 2 columns. `medium`: 3 columns. `expanded`: 4 columns (or configured value). `large+`: up to 6 columns.
- **Selection on touch:** Long-press to enter selection mode (checkbox overlays appear). On pointer, checkboxes appear on hover.
- **Upload area on compact:** Upload area is a full-width button at the top on `compact` instead of a drag-and-drop zone.

**OiVideoPlayer:**
- **Controls on touch:** Controls overlay the video and auto-hide after 3s of inactivity. Tap anywhere to show controls. On pointer, controls show on hover and auto-hide on mouse exit.
- **Full-screen on compact:** A full-screen button is prominent on `compact`. In landscape + `compact`, the video fills the entire screen edge-to-edge.
- **Aspect ratio on compact:** If no `aspectRatio` is specified, default to 16:9 on `expanded+` and fit-to-width on `compact`.

| Test | What it verifies |
|------|-----------------|
| Lightbox swipe navigation on touch | Gesture navigation |
| Lightbox swipe-down to dismiss | Gesture dismissal |
| Lightbox thumbnails hidden on compact | Space-efficient |
| ImageCropper full-screen on compact | Full-screen layout |
| ImageCropper crop handles 48dp touch target | Touch enforcement |
| Gallery 2 columns on compact, 4 on expanded | Responsive columns |
| Gallery long-press enters selection on touch | Touch selection |
| VideoPlayer controls auto-hide on touch | Touch behavior |
| VideoPlayer full-screen landscape on compact | Full-screen video |
| Golden: gallery on compact | Visual regression |

---

# Tier 4: Modules

Modules are screen-level compositions that combine many composites into complete features.

---

### OiListView\<T\>

**What it is:** A complete list screen with header, search, filters, sorting, selection actions, pagination, and empty/loading states. Think "a screen that shows a list of entities" — the most common screen in any app.

**Composes:** `OiColumn` (layout), `OiTextInput.search` (search), `OiFilterBar` (filters), `OiButtonGroup` (sort), `OiVirtualList` / `OiInfiniteScroll` (list), `OiListTile` (each item), `OiEmptyState`, `OiProgress`, `OiButton` (actions)

```dart
OiListView<T>({
  required List<T> items,
  required Widget Function(T) itemBuilder,
  required Object Function(T) itemKey,
  required String label,

  // Search
  String? searchQuery,
  ValueChanged<String>? onSearch,

  // Filters
  List<OiFilterDefinition>? filters,
  Map<String, OiColumnFilter>? activeFilters,
  ValueChanged<Map<String, OiColumnFilter>>? onFilterChange,

  // Sorting
  List<OiSortOption>? sortOptions,
  OiSortOption? activeSort,
  ValueChanged<OiSortOption>? onSort,

  // Selection
  OiSelectionMode selectionMode = OiSelectionMode.none,
  Set<Object> selectedKeys = const {},
  ValueChanged<Set<Object>>? onSelectionChange,
  List<Widget> Function(Set<Object> selectedKeys)? selectionActions,

  // Pagination
  AsyncCallback? onLoadMore,
  bool hasMore = false,

  // States
  bool loading = false,
  Widget? emptyState,

  // Layout
  OiListViewLayout layout = OiListViewLayout.list,  // list, grid, table
  Widget? headerActions,         // "New" button, etc.
})
```

**Tests:** Search filters. Filters apply. Sort changes order. Selection with bulk actions. Pagination loads more. Loading state. Empty state. Layout switching. Header actions render. Keyboard navigable throughout.

---

### OiKanban\<T\>

**What it is:** A Kanban board with columns, cards, drag-between-columns, WIP limits, quick edit, collapsible columns, and add column/card.

**Composes:** `OiColumn` (each kanban column), `OiReorderable` (card reorder within column), `OiDraggable` + `OiDropZone` (cross-column), `OiSurface` (cards), `OiEditableText` (card title editing), `OiLabel` (column titles, WIP counts), `OiScrollbar` (horizontal scroll), `OiBadge` (WIP limit warning)

```dart
OiKanban<T>({
  required List<OiKanbanColumn<T>> columns,
  required String label,
  void Function(T item, Object fromColumn, Object toColumn, int newIndex)? onCardMove,
  void Function(int oldIndex, int newIndex)? onColumnReorder,
  Widget Function(T item)? cardBuilder,
  Widget Function(OiKanbanColumn<T>)? columnHeader,
  bool reorderColumns = true,
  Map<Object, int>? wipLimits,
  bool quickEdit = true,
  bool collapsibleColumns = true,
  bool addColumn = false,
  VoidCallback? onAddColumn,
})

class OiKanbanColumn<T> {
  final Object key;
  final String title;
  final List<T> items;
  final Color? color;
}
```

**Tests:** Columns render side by side. Cards in columns. Drag card within column reorders. Drag card between columns moves. onCardMove fires with correct data. Column reorder. WIP limit warning when exceeded. Quick edit title on double-click. Collapse column. Add column button. Horizontal scroll. Keyboard: Tab between columns, arrows between cards. Screen reader announces. Golden.

---

### OiChat

**What it is:** A chat/messaging interface with message list, input bar, typing indicators, reactions, threading, and file attachments.

**Composes:** `OiVirtualList` (messages, reverse scroll), `OiInfiniteScroll` (load older messages), `OiSurface` (message bubbles), `OiLabel` (message text, timestamps), `OiAvatar` (sender avatars), `OiRichEditor` or `OiTextInput` (compose bar), `OiTypingIndicator`, `OiReactionBar` (per-message reactions), `OiFileInput` (attachments), `OiImage` (inline images), `OiIconButton` (send, attach, emoji)

```dart
OiChat({
  required List<OiChatMessage> messages,
  required String currentUserId,
  required String label,
  ValueChanged<String>? onSend,
  ValueChanged<List<OiFileData>>? onAttach,
  void Function(OiChatMessage, String emoji)? onReact,
  VoidCallback? onLoadOlder,
  bool hasOlderMessages = false,
  List<String>? typingUsers,
  bool showAvatars = true,
  bool showTimestamps = true,
  bool enableReactions = true,
  bool enableAttachments = true,
  bool enableRichText = false,
})

class OiChatMessage {
  final Object key;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String content;
  final DateTime timestamp;
  final List<OiReactionData>? reactions;
  final List<OiFileData>? attachments;
  final bool pending;
}
```

**Tests:** Messages render in order. Own messages on right. Others on left. Avatars show. Timestamps show. Typing indicator. Send button fires onSend. Attachment button fires onAttach. Reactions per message. Load older on scroll to top. Pending message styling. Rich text mode. Keyboard: Enter sends. Semantics: message list. Golden.

---

### OiNotificationCenter

**What it is:** A notification panel that lists notifications grouped by time, with mark-as-read, snooze, dismiss, and real-time animation.

**Composes:** `OiPanel` or `OiPopover` (container), `OiVirtualList` (notifications), `OiTappable` (each notification), `OiLabel`, `OiIcon`, `OiAvatar` (sender), `OiBadge` (unread count), `OiAnimatedList` (real-time inserts), `OiSwipeable` (swipe to dismiss/snooze), `OiButton.ghost` (mark all read)

```dart
OiNotificationCenter({
  required List<OiNotification> notifications,
  required String label,
  ValueChanged<OiNotification>? onNotificationTap,
  ValueChanged<OiNotification>? onMarkRead,
  VoidCallback? onMarkAllRead,
  ValueChanged<OiNotification>? onSnooze,
  ValueChanged<OiNotification>? onDismiss,
  String Function(OiNotification)? groupBy,
  int unreadCount = 0,
  bool showBadge = true,
  bool realTime = false,
})

class OiNotification {
  final Object key;
  final String title;
  final String? body;
  final DateTime timestamp;
  final bool read;
  final IconData? icon;
  final Widget? leading;
  final String? category;
  final VoidCallback? onAction;
}
```

**Tests:** Notifications list renders. Grouped by time ("Today", "Yesterday"). Unread styling (bold/dot). Tap marks read + fires onTap. Mark all read. Swipe to dismiss. Swipe to snooze. Real-time: new notification animates in. Badge count. Empty state. Screen reader announces count.

---

### OiDashboard

**What it is:** A dashboard layout with draggable, resizable widget cards arranged in a grid.

**Composes:** `OiGrid` (layout), `OiResizable` (card resize), `OiReorderable` (card reorder / drag-to-move), `OiCard` (each widget card), `OiSurface`, `OiStagger` (load animation)

```dart
OiDashboard({
  required List<OiDashboardCard> cards,
  required String label,
  int columns = 4,
  double gap = 16,
  bool editable = false,
  ValueChanged<List<OiDashboardCard>>? onLayoutChange,
})

class OiDashboardCard {
  final Object key;
  final String title;
  final Widget child;
  final int columnSpan;
  final int rowSpan;
  final int? column;
  final int? row;
}
```

**Tests:** Cards render in grid. Column/row span correct. Editable: drag to move, resize handles. onLayoutChange fires. Stagger animation on load. Responsive: fewer columns on small screens.

---

### OiFileManager

**What it is:** A file browser with folder navigation, grid/list view, drag-to-move, bulk selection, rename, upload, and breadcrumb path.

**Composes:** `OiBreadcrumbs` (path), `OiTextInput.search` (search), `OiButtonGroup` (list/grid toggle), `OiVirtualList` / `OiVirtualGrid` (files), `OiListTile` (file rows), `OiCard` (file grid cards), `OiImage` (thumbnails), `OiContextMenu` (right-click), `OiReorderable` (manual sort), `OiDraggable` + `OiDropZone` (move to folder), `OiEditableText` (rename), `OiFileInput` (upload), `OiDialog` (delete confirmation)

```dart
OiFileManager({
  required List<OiFileNode> items,
  required String label,
  ValueChanged<OiFileNode>? onOpen,
  ValueChanged<OiFileNode>? onRename,
  ValueChanged<OiFileNode>? onDelete,
  void Function(OiFileNode file, OiFileNode folder)? onMove,
  ValueChanged<List<OiFileData>>? onUpload,
  OiListViewLayout layout = OiListViewLayout.grid,
  OiSelectionMode selectionMode = OiSelectionMode.multi,
})

class OiFileNode {
  final Object key;
  final String name;
  final bool isFolder;
  final int? size;
  final DateTime? modified;
  final String? thumbnailUrl;
}
```

---

### Other Tier 4 Modules

**OiActivityFeed** — Timeline of activity events with filtering by type, infinite scroll. Composes: `OiVirtualList`, `OiInfiniteScroll`, `OiTimeline`, `OiAvatar`, `OiLabel`, `OiFilterBar`.

**OiMetadataEditor** — Key-value metadata editor with add/remove/edit fields, type selection per field. Composes: `OiEditable`, `OiSelect`, `OiTextInput`, `OiDateInput`, `OiButton`, `OiReorderable`.

**OiComments** — Threaded comment system with reply, edit, delete, reactions. Composes: `OiVirtualList`, `OiAvatar`, `OiLabel`, `OiRichEditor` or `OiTextInput`, `OiReactionBar`, `OiButton`, `OiEditableText`.

**OiPermissions** — Role-based permission matrix editor. Composes: `OiTable`, `OiCheckbox`, `OiSelect`, `OiAvatar`.

---

## Responsive Behavior for All Tier 4 Modules

Tier 4 modules are screen-level compositions with the most significant responsive layout changes. Each module specifies its full layout adaptation per breakpoint.

---

### OiListView

| Breakpoint | Layout |
|------------|--------|
| compact | Force `list` layout. Search input full-width above list. Filter bar collapses to "Filters" button → opens bottom sheet. Sort becomes icon button → opens sheet. Selection actions in sticky bottom bar (above safe area). Header actions collapse to overflow menu. Pull-to-refresh on touch. |
| medium | `list` and `grid` available. Search + filter bar share a row (filter chips scroll horizontally). Selection actions as toolbar above list. |
| expanded | All layouts (`list`, `grid`, `table`) available. Search, filter bar, sort, and header actions on a single row. Selection actions replace filter row contextually. |
| large+ | Same as expanded. Grid uses more columns. Optional master-detail: tapping item shows detail panel on right. |

**Touch interactions:** Swipe-to-select (swipe right reveals checkbox). Long-press for item context menu. Pull-to-refresh.
**Pointer interactions:** Checkbox always visible in multi-select. Right-click for context menu. No pull-to-refresh (use refresh button).

---

### OiKanban

| Breakpoint | Layout |
|------------|--------|
| compact | Single column view with horizontal swipe between kanban columns. Column header shows column title + card count. Swipe left/right to navigate columns. Cards stack full-width within visible column. "Add card" button at bottom of column. |
| medium | 2-3 visible columns (horizontally scrollable if more). Cards narrower. |
| expanded+ | All columns visible (horizontally scrollable if many). Cards at configured width. Drag between columns. |

**Touch interactions:** Long-press to drag card. Swipe between columns on compact. Haptic on card pick up.
**Pointer interactions:** Click-and-drag cards. Scroll wheel for horizontal scroll.

---

### OiChat

| Breakpoint | Layout |
|------------|--------|
| compact | Full-screen. Message list fills viewport. Compose bar at bottom (above safe area, above keyboard when visible). Compose bar has: text input + send button + attachment button + emoji button. Attachment/emoji open as sheets. |
| medium | Same as compact but wider bubbles (max 80% of width). |
| expanded+ | Chat in a panel/column. Message bubbles max 60% width. Optional thread panel on the right for threaded replies. |

**Touch interactions:** Long-press message for reactions/reply/copy menu. Swipe right on message to reply. Pull down to load older messages.
**Pointer interactions:** Hover message to reveal reaction bar/reply/actions. Right-click for message context menu. Scroll up to load older.

---

### OiNotificationCenter

| Breakpoint | Layout |
|------------|--------|
| compact | Full-screen panel (slides in from right or renders as a page). Full-width notification cards. Swipe to dismiss/snooze. "Mark all read" button in header. |
| medium | Panel (320dp wide) slides in from right. Notification cards fill panel width. |
| expanded+ | Popover dropdown from notification bell icon (320x480dp). Or persistent panel on the right side. |

**Touch interactions:** Swipe left to dismiss, swipe right to snooze. Tap to open/mark read. Pull-to-refresh.
**Pointer interactions:** Hover reveals dismiss/snooze buttons. Click to open. No swipe.

---

### OiDashboard

| Breakpoint | Layout |
|------------|--------|
| compact | Single column. Cards stack vertically, full-width. Column span ignored (all cards 1 column). Drag-to-reorder disabled (use "Edit layout" mode with up/down arrows). |
| medium | 2-column grid. Cards span 1 or 2 columns. |
| expanded | 3-4 column grid (configured). Full drag-to-move and resize in edit mode. |
| large+ | Up to 6 columns. Full layout editing. |

**Touch interactions:** Long-press to enter edit mode (cards jiggle). Drag to reorder. No resize on touch (use preset sizes).
**Pointer interactions:** Drag handles visible on hover. Resize handles on card corners.

---

### OiFileManager

| Breakpoint | Layout |
|------------|--------|
| compact | Force `grid` layout (2 columns). Breadcrumb collapses to current folder name + back button. Actions bar collapses to overflow menu. File details shown in bottom sheet on tap. Long-press for context menu. |
| medium | Grid (3-4 columns) or list toggle available. Breadcrumbs partially visible. |
| expanded+ | Grid or list. Full breadcrumbs. Sidebar with folder tree optional. Drag-and-drop to move files between folders. |

**Touch interactions:** Long-press for context menu. Swipe to select. Drag between folders via long-press.
**Pointer interactions:** Right-click context menu. Drag-and-drop. Double-click to open.

---

### OiActivityFeed

| Breakpoint | Layout |
|------------|--------|
| compact | Full-width timeline. Events stack vertically. Filters collapse to "Filter" button → sheet. Pull-to-refresh. Infinite scroll. |
| expanded+ | Timeline with optional side filter panel. Events constrained to content max-width. |

---

### OiComments

| Breakpoint | Layout |
|------------|--------|
| compact | Full-width comments. Reply indentation reduced (8dp per level, max 3 visible levels — deeper replies collapse to "View N more replies" link). Compose bar at bottom. Long-press comment for actions (edit, delete, react). |
| expanded+ | Full indentation (16dp per level). Hover reveals action buttons. Compose area inline. |

---

### OiMetadataEditor

| Breakpoint | Layout |
|------------|--------|
| compact | Key-value pairs stack vertically (key label above value input). Full-width fields. Add/remove buttons below each field. |
| expanded+ | Key-value pairs in two-column layout (key label: 30%, value input: 70%). Compact layout. |

---

### OiPermissions

| Breakpoint | Layout |
|------------|--------|
| compact | Switch from matrix table to a per-role card view. Each role is a card showing its permissions as checkbox list. Horizontal scroll on the permission matrix is unusable on phone. |
| expanded+ | Full matrix table (roles as columns, permissions as rows, checkboxes at intersections). |

**Tier 4 Module Responsive Tests:**
| Test | What it verifies |
|------|-----------------|
| ListView force list layout on compact | No table/grid on phone |
| ListView filter bar collapses to button on compact | Sheet-based filters |
| ListView selection actions in sticky bottom bar on compact | Always-visible actions |
| ListView pull-to-refresh on touch | Refresh gesture |
| Kanban single column swipe on compact | Column navigation |
| Kanban card drag between columns on expanded | Cross-column drag |
| Chat compose bar above keyboard | Keyboard avoidance |
| Chat long-press for message actions on touch | Touch menu |
| Chat swipe-to-reply on touch | Gesture reply |
| NotificationCenter full-screen on compact | Full-screen panel |
| NotificationCenter swipe-to-dismiss on touch | Gesture dismiss |
| Dashboard single column on compact | Stack layout |
| Dashboard drag disabled on compact (use edit mode) | Touch-friendly edit |
| FileManager grid 2 columns on compact | Compact grid |
| FileManager breadcrumb as back button on compact | Simple navigation |
| Comments reduced indentation on compact | Max 3 visible levels |
| Permissions card-per-role on compact | Matrix → cards |
| Golden: ListView on compact with filters | Visual regression |
| Golden: Kanban single column on compact | Visual regression |
| Golden: Chat on compact | Visual regression |
| Golden: Dashboard on compact | Visual regression |

---

# Theme Tooling

### OiDynamicTheme

Already exists as `OiThemeData.fromBrand()`. Generates a complete theme from a single brand color.

### OiThemePreview

Widget that renders a grid of all component variants in the current theme. Used for visually auditing theme changes.

**Composes:** Every Tier 2 component in sample configurations.

```dart
OiThemePreview({required OiThemeData theme})
```

### OiThemeExporter

Exports an `OiThemeData` instance as JSON or Dart code.

```dart
class OiThemeExporter {
  static String toJson(OiThemeData theme);
  static String toDart(OiThemeData theme);
  static OiThemeData fromJson(String json);
}
```

### OiPlayground

Ships as the `example/` app. A storybook-like interface to browse every component, toggle props, switch themes.

---

# Responsive & Cross-Platform Behavior

> **Principle:** Mobile-first. Every widget is designed for touch on a compact screen first, then enhanced for larger screens and pointer devices. No widget should assume hover, right-click, or wide viewport availability.

This section defines library-wide responsive and cross-platform rules that every component MUST follow. Individual component sections add component-specific responsive details on top of these global rules.

---

## OiPlatform — Platform & Input Modality Detection

**What it is:** An InheritedWidget injected by `OiApp` that exposes platform, input modality, safe area, and device capability information. All components read this to adapt behavior.

**Why it exists:** Breakpoints alone are insufficient. A 1200px-wide iPad in landscape is still a touch device. A 600px-wide desktop window still has a mouse. Platform and input modality must be independent of screen width.

```dart
enum OiInputModality { touch, pointer }
enum OiDeviceClass { phone, tablet, desktop }

class OiPlatformData {
  final TargetPlatform platform;
  final OiInputModality inputModality;   // based on last PointerDeviceKind
  final OiDeviceClass deviceClass;
  final bool isWeb;
  final EdgeInsets safeArea;             // notch, status bar, home indicator
  final double pixelRatio;
  final bool isKeyboardVisible;
  final double keyboardHeight;
  final Orientation orientation;
}

extension OiPlatformExt on BuildContext {
  OiPlatformData get platform => OiPlatform.of(this);
  bool get isTouch => platform.inputModality == OiInputModality.touch;
  bool get isPointer => platform.inputModality == OiInputModality.pointer;
  bool get isMobile => platform.deviceClass == OiDeviceClass.phone;
  bool get isTablet => platform.deviceClass == OiDeviceClass.tablet;
  bool get isDesktop => platform.deviceClass == OiDeviceClass.desktop;
  bool get isWeb => platform.isWeb;
  bool get isIOS => platform.platform == TargetPlatform.iOS;
  bool get isAndroid => platform.platform == TargetPlatform.android;
  bool get isMacOS => platform.platform == TargetPlatform.macOS;
  EdgeInsets get safeArea => platform.safeArea;
  bool get isKeyboardVisible => platform.isKeyboardVisible;
  double get keyboardHeight => platform.keyboardHeight;
  Orientation get orientation => platform.orientation;

  /// Select value based on input modality (independent of screen size)
  T adaptive<T>({required T touch, required T pointer}) =>
      isTouch ? touch : pointer;
}
```

**Input Modality Detection:**
- Determined by the last `PointerDeviceKind` event received: `touch` or `stylus` → `OiInputModality.touch`, `mouse` or `trackpad` → `OiInputModality.pointer`.
- Updates dynamically: a tablet user can switch between touch and attached mouse. The UI adapts in real time.
- On web: also checks for `hover` media query support.

**Device Class Detection:**
- `phone`: `compact` breakpoint + touch modality, OR any device with shortest screen edge < 600dp.
- `tablet`: `medium`–`expanded` breakpoint + touch modality, OR touch device with shortest edge ≥ 600dp.
- `desktop`: pointer modality, OR any device with `large`+ breakpoint and non-touch.

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Input modality detects touch from PointerDeviceKind.touch | isTouch returns true |
| Input modality detects pointer from PointerDeviceKind.mouse | isPointer returns true |
| Modality updates when switching input device | Touch → mouse → isPointer now true |
| Device class returns phone for compact+touch | isMobile returns true |
| Device class returns tablet for medium+touch | isTablet returns true |
| Device class returns desktop for pointer input | isDesktop returns true |
| isWeb returns true in web environment | Correct web detection |
| safeArea returns correct EdgeInsets for notched device | Top/bottom insets present |
| isKeyboardVisible true when virtual keyboard shown | Keyboard state detected |
| keyboardHeight returns correct value | MediaQuery.viewInsets.bottom |
| orientation returns portrait/landscape correctly | Orientation detection |
| adaptive() returns touch value on touch, pointer on pointer | Correct modality selection |

---

## Touch Target Enforcement

**Rule:** Every interactive element (anything using `OiTappable`) MUST have a minimum hit area of **48x48dp on touch devices**. This applies regardless of the visual size of the element.

**Implementation:**
- `OiTappable` enforces this via a `minHitSize` property that defaults to `48.0` when `context.isTouch` is true and `0.0` when `context.isPointer`.
- When the visual child is smaller than `minHitSize`, `OiTappable` expands the gesture detection area (not the visual area) using `GestureDetector` with `HitTestBehavior.translucent` and appropriate padding.
- This is transparent to the visual design — a 24x24 icon button still looks 24x24 but has a 48x48 tap area on touch.

**Applies to:** Every `OiButton`, `OiIconButton`, `OiToggleButton`, `OiCheckbox`, `OiSwitch`, `OiRadio`, `OiTabs` tab items, `OiListTile`, `OiTreeNode`, `OiReorderable` drag handles, `OiSlider` thumbs, `OiCopyButton`, `OiStarRating` stars, `OiScaleRating` numbers, `OiContextMenu` items, `OiDatePicker` date cells, `OiTimePicker` hour/minute items, and every other tappable element.

**Tests:**
| Test | What it verifies |
|------|-----------------|
| OiTappable hit area is 48x48 minimum on touch | Tap at edge of 48x48 zone registers |
| OiTappable hit area matches visual size on pointer | No expanded hit area when pointer |
| Small icon button (24x24) has 48x48 tap area on touch | Tap outside visual but inside 48x48 registers |
| Adjacent small buttons don't have overlapping hit areas | Correct hit testing with spacing |

---

## Safe Area Handling

**Rule:** Content must never be obscured by device hardware (notch, dynamic island, home indicator, status bar, rounded screen corners).

**Implementation:**
- `OiApp` reads `MediaQuery.of(context).padding` and injects it as `OiPlatformData.safeArea`.
- `OiApp` wraps the content in `SafeArea` by default but exposes `safeArea: false` to opt out.
- Individual widgets that touch screen edges must account for safe areas:
  - `OiBottomBar`: adds bottom safe area padding.
  - `OiSheet` (bottom): content does not extend behind home indicator.
  - `OiToast` (bottom positions): positioned above bottom safe area.
  - `OiDrawer`: adds top safe area padding when header reaches status bar.
  - `OiDialog` (full-screen on compact): respects all safe areas.
  - `OiPanel`: respects side safe areas when at screen edges.
  - `OiOverlays` barrier: extends into safe areas (it should cover everything).

**Tests:**
| Test | What it verifies |
|------|-----------------|
| OiApp applies SafeArea padding on notched device | Content below notch |
| OiBottomBar adds bottom safe area padding | Items above home indicator |
| Bottom sheet content above home indicator | Content not obscured |
| Toast at bottom positioned above safe area | Toast visible |
| Full-screen dialog respects all safe areas | Content inset correctly |
| Overlay barrier extends into safe areas | Full coverage |

---

## Keyboard Shortcut Platform Mapping

**Rule:** All keyboard shortcuts automatically map `Ctrl` → `Cmd` on macOS/iOS. Developers register shortcuts using `OiShortcutActivator` which handles this mapping.

```dart
class OiShortcutActivator {
  /// Creates a platform-aware shortcut. Uses Cmd on macOS/iOS, Ctrl elsewhere.
  factory OiShortcutActivator.primary(LogicalKeyboardKey key, {bool shift = false, bool alt = false});

  /// Display string: "⌘Z" on macOS, "Ctrl+Z" on others.
  String get displayLabel;
}
```

**Standard Shortcuts:**
| Action | macOS/iOS | Windows/Linux |
|--------|-----------|---------------|
| Undo | ⌘Z | Ctrl+Z |
| Redo | ⌘⇧Z | Ctrl+Shift+Z |
| Command bar | ⌘K | Ctrl+K |
| Copy | ⌘C | Ctrl+C |
| Paste | ⌘V | Ctrl+V |
| Select all | ⌘A | Ctrl+A |
| Save | ⌘S | Ctrl+S |
| Find | ⌘F | Ctrl+F |
| Bold | ⌘B | Ctrl+B |
| Italic | ⌘I | Ctrl+I |

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Cmd+Z fires undo on macOS | Platform-mapped shortcut |
| Ctrl+Z fires undo on Windows/Linux | Platform-mapped shortcut |
| Display label shows ⌘Z on macOS | Correct display text |
| Display label shows Ctrl+Z on Windows | Correct display text |
| Shortcuts work with external keyboard on iPad | Keyboard attached to touch device |

---

## Responsive Spacing & Sizing

**Rule:** Spacing, radius, and shadows scale per breakpoint to maintain visual comfort. Mobile screens use tighter spacing; desktop screens use more generous spacing.

**OiSpacingScale per breakpoint:**
```
              compact   medium    expanded   large    extraLarge
xs:           2         2         4          4        4
sm:           4         6         8          8        8
md:           8         12        16         16       16
lg:           12        16        24         24       24
xl:           16        24        32         32       32
xxl:          24        32        48         48       48
pageGutter:   16        24        32         40       48
```

**OiTextTheme responsive scaling:**
- `display`: scales from 32px on compact to 48px on extraLarge.
- `h1`: scales from 24px on compact to 36px on extraLarge.
- `h2`: scales from 20px on compact to 28px on extraLarge.
- `h3`–`h4`: scale by smaller increments.
- `body` and below: no scaling (consistent readability).

**OiShadowScale:**
- On compact/touch devices: reduce shadow blur by 25% for performance.
- On low-DPI (1x): shadows look heavier; reduce opacity by 15%.
- On high-DPI (3x): shadows are crisper; use standard values.

**OiRadiusScale:**
- Radius values do NOT scale per breakpoint (visual consistency).
- Exception: `OiRadiusPreference.large` may reduce slightly on compact for space efficiency.

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Spacing.md returns 8 on compact, 16 on expanded | Correct per-breakpoint values |
| Display font size is 32px on compact, 48px on extraLarge | Responsive text scaling |
| Body font size is consistent across all breakpoints | No scaling for body text |
| Shadow blur reduced by 25% on compact/touch | Performance optimization |
| PageGutter returns correct value at each breakpoint | 16/24/32/40/48 |

---

## Navigation Paradigm Adaptation

**Rule:** Navigation patterns automatically adapt between breakpoints:

| Breakpoint | Navigation pattern |
|------------|-------------------|
| compact | `OiBottomBar` for primary nav. `OiSidebar` hidden or becomes `OiDrawer` (swipe from edge to open). No persistent side navigation. |
| medium | `OiSidebar` in compact mode (icons only, 64px). `OiBottomBar` optional. |
| expanded | `OiSidebar` in full mode (icons + labels, 260px). No `OiBottomBar`. |
| large+ | `OiSidebar` in full mode. Optional secondary `OiNavMenu` panel. |

**Overlay Paradigm Adaptation:**

| Component | compact (touch) | expanded+ (pointer) |
|-----------|----------------|---------------------|
| `OiPopover` | Becomes `OiSheet` (bottom sheet) | Floating popover anchored to trigger |
| `OiTooltip` | Shows on long-press, dismisses on tap-away | Shows on hover after delay |
| `OiContextMenu` | Triggered by long-press via `OiLongPressMenu` | Triggered by right-click at cursor |
| `OiDialog` | Full-screen or near-full-screen bottom sheet | Centered modal with maxWidth |
| `OiSelect` dropdown | Bottom sheet with full option list | Floating dropdown anchored to trigger |
| `OiDatePicker` | Full-screen or bottom sheet | Floating popup anchored to input |
| `OiTimePicker` | Bottom sheet with scroll wheels | Floating popup with columns |
| `OiColorInput` picker | Full-screen | Floating popup |
| `OiComboBox` dropdown | Bottom sheet with search | Floating dropdown |
| `OiCommandBar` | Full-screen overlay | Centered floating overlay |
| `OiSearch` | Full-screen overlay | Centered floating overlay |
| `OiEmojiPicker` | Full-screen or bottom sheet | Floating popup |

**Tests:**
| Test | What it verifies |
|------|-----------------|
| OiSidebar renders as drawer on compact | Drawer behavior with swipe |
| OiSidebar renders icon-only on medium | Compact mode with tooltips |
| OiSidebar renders full on expanded+ | Full sidebar visible |
| OiPopover renders as bottom sheet on compact | Sheet presentation |
| OiPopover renders as floating on expanded | Floating presentation |
| OiTooltip shows on long-press on touch | Touch alternative |
| OiTooltip shows on hover on pointer | Standard hover tooltip |
| OiContextMenu shows on long-press on touch | Touch trigger |
| OiContextMenu shows on right-click on pointer | Pointer trigger |
| OiDialog is full-screen on compact | Full-screen presentation |
| OiDialog is centered modal on expanded | Modal presentation |
| OiSelect dropdown is bottom sheet on compact | Sheet presentation |

---

## Performance Tiers

**What it is:** A performance configuration system that allows degrading visual effects on low-capability devices without affecting functionality.

```dart
class OiPerformanceConfig {
  final bool disableBlur;           // disable BackdropFilter glass effects
  final bool disableShadows;        // disable all box shadows
  final bool reduceAnimations;      // shorter durations (not same as reducedMotion which disables)
  final bool disableHalo;           // disable halo glow effects
  final double animationScale;      // 1.0 = normal, 0.5 = half duration, 0 = instant

  factory OiPerformanceConfig.auto(BuildContext context);  // detects device capability
  factory OiPerformanceConfig.full();    // all effects enabled
  factory OiPerformanceConfig.reduced(); // reduced for mid-range devices
  factory OiPerformanceConfig.minimal(); // minimal for low-end devices
}
```

**Auto-detection heuristics:**
- Device RAM < 3GB → `reduced`
- Device RAM < 2GB → `minimal`
- Web on mobile browser → `reduced`
- Refresh rate < 60Hz → `reduced`
- Developer can override via `OiApp(performanceConfig: ...)`.

**Distinction from `reducedMotion`:**
- `reducedMotion` is a user accessibility preference — animations are disabled entirely.
- `OiPerformanceConfig` is a device capability optimization — animations still play but shorter/simpler, blur becomes opaque, shadows become borders.

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Glass effect degrades to opaque on disableBlur | No BackdropFilter |
| Shadows removed on disableShadows | No BoxShadow |
| Animation duration halved on animationScale=0.5 | Shorter animations |
| Halo removed on disableHalo | No outer glow |
| Auto-detection returns reduced for low-end device | Correct tier |
| All widgets still function with minimal config | No crashes |

---

## Dense & Comfortable Mode

**Rule:** The library supports a global density toggle that affects padding, touch targets, and font sizes across all components.

```dart
enum OiDensity { comfortable, compact, dense }
```

| Property | comfortable | compact | dense |
|----------|------------|---------|-------|
| Button height (medium) | 40 | 36 | 32 |
| Input height | 40 | 36 | 32 |
| List tile height | 56 | 48 | 40 |
| Table row height | 52 | 44 | 36 |
| Icon size (default) | 20 | 18 | 16 |
| Checkbox/radio size | 20 | 18 | 16 |
| Component padding | md (16) | sm (8) | xs (4) |
| Min touch target | 48 | 44 | 44 |

**Default per platform:**
- Touch devices: `comfortable` (larger touch targets, more padding).
- Pointer devices: `compact` (balanced).
- Data-heavy apps (developer choice): `dense` (maximum information density).

**Note:** Even in `dense` mode, touch targets on touch devices never go below 44dp.

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Button height changes per density | 40/36/32 |
| Table row height changes per density | 52/44/36 |
| Touch target minimum maintained in dense mode on touch | ≥44dp |
| Default density is comfortable on touch | Correct default |
| Default density is compact on pointer | Correct default |
| Density affects all components uniformly | Consistent sizing |

---

## Platform-Adaptive Scrollbar

**Rule:** Scrollbar appearance adapts to the current input modality.

| Property | Touch | Pointer |
|----------|-------|---------|
| Visibility | Overlay, visible only during active scroll | Always visible (or hover-to-show) |
| Thickness | 3dp (fades to 0 when idle) | 8dp (12dp on hover) |
| Track | No track | Visible track with click-to-jump |
| Interaction | Touch drag to scroll (but not the scrollbar itself) | Click track to jump, drag thumb |
| Fade delay | Fades 1.5s after scroll stops | Does not fade when showAlways=true |

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Scrollbar is thin overlay on touch | 3dp, no track |
| Scrollbar is full with track on pointer | 8dp, track visible |
| Scrollbar fades after scroll stops on touch | Not visible when idle |
| Scrollbar track click jumps on pointer | Click-to-position |
| Scrollbar thumb drag works on pointer | Drag scrolling |
| Scrollbar hover expands on pointer | 8dp → 12dp |

---

## Pull-to-Refresh

**Rule:** Any scrollable list (`OiVirtualList`, `OiInfiniteScroll`, `OiTable`, `OiListView`, etc.) supports pull-to-refresh on touch devices.

```dart
// Added to OiVirtualList, OiInfiniteScroll, OiListView, OiTable, OiTree, OiChat, etc.
AsyncCallback? onRefresh,  // pull-to-refresh callback (touch only)
```

- On touch: pulling down past threshold shows a refresh indicator and triggers `onRefresh`.
- On pointer: refresh is triggered by a dedicated refresh button in the UI (not by scrolling).
- iOS: uses bouncing refresh (spinner inside overscroll area).
- Android: uses Material-style pull indicator.

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Pull-to-refresh triggers onRefresh on touch | Callback fires |
| Pull-to-refresh shows indicator | Spinner visible |
| Pull-to-refresh NOT available on pointer | No pull gesture |
| iOS uses bouncing style | Correct platform style |
| Android uses Material indicator | Correct platform style |
| Refresh indicator respects safe area | Below status bar |

---

## Hover vs Touch Interaction Fallbacks

**Rule:** Every interaction that relies on hover MUST have a touch alternative.

| Hover behavior | Touch alternative |
|----------------|-------------------|
| Tooltip on hover | Tooltip on long-press (300ms) |
| Edit overlay on hover (OiAvatar editable) | Always-visible edit icon, or tap to show overlay |
| Swipe action reveal on hover | Swipe gesture (already specified) |
| Row highlight on hover | No highlight (or highlight on touch-down) |
| Copy indicator on hover | Always-visible copy button |
| Resize cursor on hover | Dedicated resize handle grip indicator |
| Context menu on right-click | Long-press menu |
| Drag initiation on mouse-down | Long-press to initiate |
| Popover preview on hover | Not available (explicit tap to open) |
| Color preview on hover (OiColorInput) | Always show swatch |

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Tooltip appears on long-press on touch | 300ms trigger |
| Tooltip appears on hover on pointer | Standard hover delay |
| Hover styles do NOT activate on touch | No hover state on touch-only |
| Edit overlay visible without hover on touch | Always-visible on touch |
| Resize handle has visual grip on touch | Visible without hover |
| Long-press opens context menu on touch | Touch context menu |

---

## Virtual Keyboard Handling

**Rule:** When the virtual keyboard appears on mobile, the UI must adapt:

1. **Focused input scrolls into view.** The scrollable ancestor scrolls to keep the focused input visible above the keyboard.
2. **Overlays reposition.** `OiFloating` content anchored to inputs must reposition to stay visible above the keyboard.
3. **Bottom-anchored elements move up.** `OiBottomBar`, `OiToast` (bottom positions), bottom `OiSheet`, and sticky bottom bars must either move above the keyboard or hide.
4. **Full-screen dialogs reduce height.** Content area shrinks to accommodate the keyboard.

**Implementation:**
- `OiApp` monitors `MediaQuery.viewInsets.bottom` and provides `keyboardHeight` via `OiPlatformData`.
- Scrollable widgets use `Scrollable.ensureVisible` to scroll focused inputs into view.
- `OiFloating` recalculates position when `keyboardHeight` changes.
- `OiBottomBar` and bottom-positioned `OiToast` add `keyboardHeight` to their bottom offset.

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Input scrolls into view when keyboard appears | Input visible above keyboard |
| OiFloating repositions above keyboard | Popover/dropdown visible |
| OiBottomBar moves above keyboard | Not obscured |
| Bottom toast moves above keyboard | Toast visible |
| Full-screen dialog shrinks for keyboard | Content area reduced |
| Keyboard height reported correctly | OiPlatformData accurate |

---

## Browser-Specific Considerations

**Rules for web deployment:**

1. **Scrollbar:** Flutter renders its own scrollbar. It must not conflict with browser's native overflow scrollbar. Use `ScrollConfiguration` to suppress platform scrollbar and render `OiScrollbar` exclusively.
2. **Context menu:** Browser default right-click menu must be suppressed on `OiContextMenu` targets. Use `kIsWeb` check + `onContextMenu.preventDefault()`.
3. **Clipboard:** Clipboard API requires secure context (HTTPS). `OiCopyable` and `OiPasteZone` must handle permission denial gracefully with a fallback error message.
4. **Touch events:** Mobile browsers have a 300ms click delay. Flutter's web engine handles this, but `OiTappable` should use `touch-action: manipulation` CSS equivalent for immediate response.
5. **Zoom:** Browser-level pinch zoom must be prevented when `OiPinchZoom` is active (to avoid double-zoom). Conversely, `OiPinchZoom` must not interfere with browser accessibility zoom.
6. **URL bar:** Mobile browsers show/hide the URL bar on scroll, changing viewport height dynamically. `MediaQuery.size.height` updates accordingly, and layouts must not jump.
7. **Drag & Drop:** Native browser drag events conflict with Flutter's drag system. `OiDraggable` must suppress native drag on web.
8. **Tab focus:** Browser Tab key cycles through focusable elements AND the browser URL bar. `OiFocusTrap` must account for focus leaving the Flutter context.
9. **Back navigation:** Browser back button must not be consumed by Flutter without explicit opt-in. Sheets and dialogs should integrate with `Router`/browser history when appropriate.

**Tests:**
| Test | What it verifies |
|------|-----------------|
| Browser context menu suppressed on OiContextMenu targets | No native menu on web |
| Clipboard permission denial shows error gracefully | Fallback message |
| Pinch zoom does not double-zoom on web | Only widget zoom active |
| Browser native drag suppressed for OiDraggable | No ghost duplication |
| URL bar height change does not cause layout jump | Stable layout |
| Focus trap handles browser tab-out | Focus stays or restores |

---

# Testing Strategy

## Unit Tests (pure logic, no widgets)
- OiColorSwatch generation from brand color
- OiThemeData.fromBrand full derivation
- OiInteractiveStyle merging (hover + focus = combined)
- OiBorderStyle painting calculations (dash/dot spacing)
- OiHaloStyle → BoxShadow conversion
- Fuzzy search algorithm
- Date natural language parsing
- Pattern recognizers (mention, tag, URL, email)
- OiUndoStack push/undo/redo/clear
- OiColumnProfile serialization/deserialization
- OiBreakpoint calculations
- OiFormController validation logic
- OiTreeNode flattening for virtual scroll

## Widget Tests (per component — see tables above)
Every component section above includes a detailed test table. Summary requirements:
- Every component renders in both light and dark themes
- Every interactive component tests hover, focus, active, disabled states
- Every input tests value entry, validation, error display
- Every component with `label` tests Semantics label presence
- Every component with keyboard interaction tests keyboard flow
- Every animation tests reduced motion fallback
- Every composite tests its composition chain (e.g., OiButtonGroup renders actual OiButton instances)

## Golden Tests (visual regression)
- Every Tier 2 component, every variant, light + dark
- All button variants + sizes + states
- Input states: rest, focused, error, success, disabled
- Card variants: flat, outlined, interactive
- Halo effects at different intensities
- Gradient borders (solid, dashed, gradient)
- Focus ring appearance
- Dialog, sheet, panel, toast
- Table with various features active
- Responsive layouts at all breakpoints

## Integration Tests (multi-component flows)
- Complete form submit: fill fields → validate → submit → success
- Wizard flow: step 1 → step 2 → back → step 2 → step 3 → review → complete
- Table: sort → filter → select rows → bulk action → undo
- Kanban: drag card between columns → verify move → undo
- Tree: expand → select → drag reparent → verify new parent
- Command bar: Ctrl+K → search → select → execute
- Tour: start → next → next → skip → verify skip callback
- Inline edit: click cell → type → Enter → verify saved
- Search: type → results load → arrow down → Enter → navigate

## Performance Tests
- OiVirtualList with 100,000 items: <16ms frame time
- OiVirtualGrid with 10,000 images: <16ms frame time
- OiTable with 10,000 rows, sort + filter: responsive
- OiTree with 10,000 nodes: <16ms frame time
- OiFlowGraph with 500 nodes + 1000 edges: <16ms frame time
- 100 concurrent toasts: no crash
- Rapid theme switching (100 toggles): no crash, no leak
- OiOverlays: open/close 1000 times, check for memory leaks
- OiMasonry with 1,000 items: smooth scroll
- OiRichEditor with 10,000 word document: responsive typing

---

## Responsive & Cross-Platform Tests

### Platform Simulation Test Helpers

All responsive tests require platform simulation utilities:

```dart
/// Test helper: simulate touch device
Future<void> pumpTouchApp(WidgetTester tester, Widget child, {OiBreakpoint breakpoint = OiBreakpoint.compact}) async {
  // Sets PointerDeviceKind.touch, screen size per breakpoint, safe area insets
}

/// Test helper: simulate pointer device
Future<void> pumpPointerApp(WidgetTester tester, Widget child, {OiBreakpoint breakpoint = OiBreakpoint.expanded}) async {
  // Sets PointerDeviceKind.mouse, screen size per breakpoint
}

/// Test helper: simulate specific breakpoint
Future<void> pumpAtBreakpoint(WidgetTester tester, Widget child, OiBreakpoint breakpoint) async {
  // Sets screen width: compact=400, medium=720, expanded=1000, large=1400, extraLarge=1800
}

/// Test helper: simulate virtual keyboard
Future<void> showKeyboard(WidgetTester tester, {double height = 300}) async {
  // Sets MediaQuery.viewInsets.bottom = height
}

/// Test helper: simulate safe area
Future<void> withSafeArea(WidgetTester tester, Widget child, {double top = 44, double bottom = 34}) async {
  // Sets MediaQuery.padding = EdgeInsets.only(top, bottom)
}

/// Test helper: simulate platform
Future<void> withPlatform(WidgetTester tester, Widget child, TargetPlatform platform) async {
  // Sets TargetPlatform for keyboard shortcut mapping, scroll physics
}
```

### Breakpoint Golden Tests

Every Tier 2+ component must have golden tests at each breakpoint:

- **compact (400dp width):** Mobile phone portrait
- **compact landscape (700dp width, 360dp height):** Mobile phone landscape
- **medium (720dp width):** Tablet portrait or small desktop window
- **expanded (1000dp width):** Standard desktop
- **large (1400dp width):** Wide desktop
- **extraLarge (1800dp width):** Ultra-wide or multi-monitor

Golden file naming convention: `{component}_{variant}_{breakpoint}_{theme}.png`
Example: `oi_button_primary_compact_light.png`, `oi_table_card_list_compact_dark.png`

### Touch vs Pointer Interaction Tests

Every interactive component must be tested in both modalities:

- **Touch tests (via `pumpTouchApp`):** Verify 48dp touch targets, long-press menus, swipe gestures, no hover states, pull-to-refresh, haptic feedback calls (mocked).
- **Pointer tests (via `pumpPointerApp`):** Verify hover states, right-click menus, scroll wheel behavior, drag-and-drop without long-press delay, focus ring visibility, cursor changes.

### Safe Area Tests

Components that touch screen edges must be tested with simulated safe areas:

- `OiBottomBar` with 34dp bottom inset
- `OiSheet` (bottom) with 34dp bottom inset
- `OiToast` (bottom positions) with 34dp bottom inset
- `OiDrawer` with 44dp top inset
- `OiDialog` full-screen with 44dp top + 34dp bottom
- `OiPanel` at screen edge with side insets (landscape iPhone)
- `OiApp` SafeArea wrapper with top/bottom insets

### Virtual Keyboard Tests

Components containing inputs must be tested with simulated keyboard:

- Input scrolls into view when keyboard height = 300dp
- `OiFloating` repositions above keyboard
- `OiBottomBar` hides or moves above keyboard
- Bottom-positioned `OiToast` moves above keyboard
- Full-screen `OiDialog` content area shrinks
- `OiSheet` content area shrinks
- `OiChat` compose bar moves above keyboard

### Performance Tests per Platform

- OiVirtualList with 100,000 items on simulated mobile: <16ms frame time
- OiTable card list with 1,000 rows on compact: <16ms frame time
- OiSurface with glass=true on reduced performance config: no BackdropFilter in render tree
- All animations with `OiPerformanceConfig.minimal`: complete in <1ms
- Theme switching with 100 components mounted: <100ms
- OiFlowGraph with 500 nodes on touch: <16ms frame time with zoom controls

### Browser-Specific Tests (Web)

- Clipboard permission denial handled gracefully
- Browser context menu suppressed on `OiContextMenu` targets
- Browser native drag suppressed on `OiDraggable` targets
- Pinch zoom isolated from browser zoom on `OiPinchZoom`
- URL bar height change does not cause layout jump
- Scrollbar does not duplicate with browser scrollbar
- Focus trap handles browser Tab-out to URL bar

### Platform Shortcut Tests

- Every shortcut with Ctrl modifier: verify Cmd on macOS, Ctrl on Windows/Linux
- Display labels show ⌘ on macOS, Ctrl on others
- Shortcuts work with external keyboard on iPad
- "?" help dialog shows platform-correct shortcut labels

---

End of specification.
