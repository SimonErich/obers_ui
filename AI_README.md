# obers_ui — AI Integration Reference

> **Version:** Synced with codebase as of 2026-03-23 (includes Shop & Admin widgets)
> **Single import:** `import 'package:obers_ui/obers_ui.dart';`
> **Zero Material dependency** — do NOT use MaterialApp, Scaffold, AppBar, or any Material/Cupertino widgets.

---

## How to Use This Document

You are a coding AI implementing a Flutter application using the **obers_ui** library. This document is your single source of truth.

**Rules:**
1. **Always prefer an existing obers_ui widget** over building your own. Search this document by tag or use case before writing custom code.
2. **Check the tier** — use the highest-tier widget that fits. Modules > Composites > Components > Primitives.
3. **Never use Material/Cupertino widgets.** Use `OiApp` instead of `MaterialApp`, `OiButton` instead of `ElevatedButton`, `OiTextInput` instead of `TextField`, etc.
4. **All colors from theme.** Never hardcode colors. Use `context.colors.primary.base`, `context.spacing.md`, etc.
5. **All text via OiLabel.** Never use raw `Text()` widget. Use `OiLabel.body('...')`, `OiLabel.h1('...')`, etc.
6. **All layouts via Oi primitives.** Use `OiRow`, `OiColumn`, `OiGrid`, `OiPage`, `OiSection` instead of `Row`, `Column`, `GridView`.
7. **Accessibility is mandatory.** Every interactive element needs a `semanticLabel` or `label` parameter.
8. **Widgets marked [PLANNED] do NOT exist yet.** Never attempt to use them.

---

## Quick Start

```dart
import 'package:obers_ui/obers_ui.dart';

void main() {
  runApp(
    OiApp(
      theme: OiThemeData.fromBrand(color: Color(0xFF8B6914)),
      home: OiPage(
        breakpoint: OiBreakpoint.compact,
        children: [
          OiLabel.h1('Hello, ObersUI'),
          OiButton.primary(
            label: 'Get Started',
            onTap: () {},
          ),
        ],
      ),
    ),
  );
}
```

### With Router

```dart
OiApp.router(
  routerConfig: myGoRouter,
  theme: OiThemeData.light(),
  darkTheme: OiThemeData.dark(),
  themeMode: OiThemeMode.system,
)
```

---

## Architecture

### 4-Tier Composition Hierarchy

```
Tier 0: Foundation    — Theme, OiApp, overlays, responsive, accessibility, persistence
Tier 1: Primitives    — Low-level building blocks (OiLabel, OiSurface, OiTappable, OiGrid, ...)
Tier 2: Components    — Reusable UI elements (OiButton, OiTextInput, OiCard, OiDialog, ...)
Tier 3: Composites    — Multi-component patterns (OiTable, OiForm, OiSidebar, OiCalendar, ...)
Tier 4: Modules       — Full-feature screens (OiListView, OiKanban, OiChat, OiFileExplorer, ...)
```

**Rule:** Each tier only imports from the tier below. Never skip tiers in composition.

### File Structure

```
lib/
  obers_ui.dart              <- Single barrel export (use this)
  src/
    foundation/              <- Tier 0
    primitives/              <- Tier 1
    components/              <- Tier 2
    composites/              <- Tier 3
    modules/                 <- Tier 4
    models/                  <- Data classes
    tools/                   <- Dev tools
    utils/                   <- Helpers
```

---

## Theme System

### Creating Themes

```dart
// Level 1: Just works
OiThemeData.light()
OiThemeData.dark()

// Level 2: Brand it (generates full palette from one color)
OiThemeData.fromBrand(color: Color(0xFF8B6914))
OiThemeData.fromBrand(color: Color(0xFF8B6914), brightness: Brightness.dark)

// Level 3: Full control
OiThemeData.light().copyWith(
  colors: OiColorScheme.light().copyWith(
    primary: OiColorSwatch(base: myColor, light: ..., dark: ..., muted: ..., foreground: ...),
  ),
  textTheme: OiTextTheme.standard(fontFamily: 'Inter'),
)
```

### OiThemeData Properties

| Property | Type | Description |
|---|---|---|
| `brightness` | `Brightness` | Light or dark mode |
| `colors` | `OiColorScheme` | All color tokens |
| `textTheme` | `OiTextTheme` | Typography styles |
| `spacing` | `OiSpacingScale` | Spacing tokens |
| `radius` | `OiRadiusScale` | Border radius tokens |
| `shadows` | `OiShadowScale` | Elevation shadows |
| `animations` | `OiAnimationConfig` | Duration/curve settings |
| `effects` | `OiEffectsTheme` | Hover/focus/active states |
| `decoration` | `OiDecorationTheme` | Border/gradient styles |
| `components` | `OiComponentThemes` | Per-widget theme overrides |
| `fontFamily` | `String?` | Custom font family |
| `monoFontFamily` | `String?` | Monospace font family |
| `performanceConfig` | `OiPerformanceConfig` | Performance tuning |

Factory params: `fontFamily`, `monoFontFamily`, `radiusPreference` (sharp/medium/rounded), `components`, `performanceConfig`, `breakpoints`.

### Accessing Theme in Code

```dart
// Via context extensions
final colors = context.colors;       // OiColorScheme
final spacing = context.spacing;     // OiSpacingScale
final radius = context.radius;       // OiRadiusScale
final components = context.components; // OiComponentThemes

// Full theme
final theme = OiTheme.of(context);
```

### Color System — OiColorScheme

**6 Semantic Swatches** (each is an `OiColorSwatch` with `.base`, `.light`, `.dark`, `.muted`, `.foreground`):

| Swatch | Default (Light) | Usage |
|---|---|---|
| `primary` | Blue #2563EB | Brand/main actions, links, active states |
| `accent` | Teal #0D9488 | Secondary emphasis, highlights |
| `success` | Green #16A34A | Positive states, confirmations |
| `warning` | Amber #D97706 | Caution, attention needed |
| `error` | Red #DC2626 | Errors, destructive actions |
| `info` | Sky Blue #0284C7 | Informational, neutral feedback |

**Surface & Text Colors:**

| Token | Usage |
|---|---|
| `background` | Page background |
| `surface` | Card/container background |
| `surfaceHover` | Surface on hover |
| `surfaceActive` | Surface on press |
| `surfaceSubtle` | Subtle background (alternating rows, etc.) |
| `overlay` | Modal/dialog backdrop |
| `text` | Primary text |
| `textSubtle` | Secondary text |
| `textMuted` | Disabled/placeholder text |
| `textInverse` | Text on dark backgrounds |
| `textOnPrimary` | Text on primary color |
| `border` | Default borders |
| `borderSubtle` | Subtle borders |
| `borderFocus` | Focus ring color |
| `borderError` | Error state border |
| `glassBackground` | Frosted glass effect |
| `glassBorder` | Frosted glass border |
| `chart` | `List<Color>` for data viz |

### Typography — OiTextTheme

14 text style variants, used via `OiLabel`:

| Variant | Constructor | Typical Use |
|---|---|---|
| `display` | `OiLabel.display()` | Hero sections, landing pages |
| `h1` | `OiLabel.h1()` | Page titles |
| `h2` | `OiLabel.h2()` | Section titles |
| `h3` | `OiLabel.h3()` | Subsection titles |
| `h4` | `OiLabel.h4()` | Card titles, group headers |
| `body` | `OiLabel.body()` | Default body text |
| `bodyStrong` | `OiLabel.bodyStrong()` | Emphasized body text |
| `small` | `OiLabel.small()` | Secondary info, captions |
| `smallStrong` | `OiLabel.smallStrong()` | Emphasized small text |
| `tiny` | `OiLabel.tiny()` | Timestamps, footnotes |
| `caption` | `OiLabel.caption()` | Image captions, form hints |
| `code` | `OiLabel.code()` | Code snippets, monospace |
| `overline` | `OiLabel.overline()` | Category labels, section markers |
| `link` | `OiLabel.link()` | Hyperlink-styled text |

### Spacing — OiSpacingScale

| Token | Value | Usage |
|---|---|---|
| `xs` | 4dp | Tight gaps, icon spacing |
| `sm` | 8dp | Form field gaps, button padding |
| `md` | 16dp | Section gaps, card padding |
| `lg` | 24dp | Major section gaps |
| `xl` | 32dp | Page sections |
| `xxl` | 48dp | Hero spacing |

### Radius — OiRadiusScale

Controlled by `OiRadiusPreference`: `sharp`, `medium` (default), `rounded`.

| Token | Sharp | Medium | Rounded |
|---|---|---|---|
| `xs` | 0 | 4 | 8 |
| `sm` | 0 | 8 | 12 |
| `md` | 2 | 12 | 16 |
| `lg` | 4 | 16 | 24 |
| `xl` | 4 | 20 | 32 |
| `full` | 999 | 999 | 999 |

### Component Themes — OiComponentThemes

Per-widget visual overrides (all nullable, all have `copyWith`):

| Field | Type | Controls |
|---|---|---|
| `button` | `OiButtonThemeData` | borderRadius |
| `textInput` | `OiTextInputThemeData` | Input field styling |
| `select` | `OiSelectThemeData` | Dropdown styling |
| `card` | `OiCardThemeData` | Card appearance |
| `dialog` | `OiDialogThemeData` | Dialog styling |
| `toast` | `OiToastThemeData` | Toast appearance |
| `tooltip` | `OiTooltipThemeData` | Tooltip styling |
| `table` | `OiTableThemeData` | Table appearance |
| `tabs` | `OiTabsThemeData` | Tab bar styling |
| `badge` | `OiBadgeThemeData` | Badge appearance |
| `checkbox` | `OiCheckboxThemeData` | Checkbox styling |
| `switchTheme` | `OiSwitchThemeData` | Switch styling |
| `sheet` | `OiSheetThemeData` | Sheet appearance |
| `avatar` | `OiAvatarThemeData` | Avatar styling |
| `progress` | `OiProgressThemeData` | Progress bar styling |
| `sidebar` | `OiSidebarThemeData` | Sidebar appearance |
| `fileExplorer` | `OiFileExplorerThemeData` | File explorer styling |
| `fieldDisplay` | `OiFieldDisplayThemeData` | Field display styling |
| `dialogShell` | `OiDialogShellThemeData` | Dialog shell styling |
| `refreshIndicator` | `OiRefreshIndicatorThemeData` | Refresh indicator styling |
| `navigationRail` | `OiNavigationRailThemeData` | Navigation rail styling |
| `sliverHeader` | `OiSliverHeaderThemeData` | Sliver header styling |
| `formSelect` | `OiFormSelectThemeData` | Form select styling |
| `switchTile` | `OiSwitchTileThemeData` | Switch tile styling |
| `segmentedControl` | `OiSegmentedControlThemeData` | Segmented control styling |
| `tabView` | `OiTabViewThemeData` | Tab view styling |
| `reorderableList` | `OiReorderableListThemeData` | Reorderable list styling |
| `datePickerField` | `OiDatePickerFieldThemeData` | Date picker field styling |
| `dataGrid` | `OiDataGridThemeData` | Data grid styling |

### Density — OiDensity

```dart
OiApp(
  density: OiDensity.comfortable,  // Touch-friendly (default)
  // OiDensity.compact             // Desktop-optimized
  // OiDensity.dense               // Data-heavy views
)
```

Access: `OiDensityScope.of(context)`

### Dark Mode

```dart
OiApp(
  theme: OiThemeData.light(),
  darkTheme: OiThemeData.dark(),
  themeMode: OiThemeMode.system,  // .light | .dark | .system
)
```

---

## Foundation Services

### OiApp
**Tags:** `app`, `root`, `setup`, `theme`, `entry-point`

Root widget replacing `MaterialApp`. Injects theme, overlays, undo stack, accessibility, platform info, density, shortcuts, tour scope, settings.

**Key Parameters:**
- `home` (Widget, required) — Root widget for basic navigation
- `routerConfig` (RouterConfig, required for `.router()`) — For go_router / auto_route
- `theme` (OiThemeData?) — Light theme
- `darkTheme` (OiThemeData?) — Dark theme
- `themeMode` (OiThemeMode, default: system)
- `density` (OiDensity?)
- `settingsDriver` (OiSettingsDriver?) — Persistence backend
- `undoStackMaxHistory` (int, default: 50)
- `locale` (Locale?)
- `localizationsDelegates` (Iterable?)
- `supportedLocales` (Iterable, default: `[Locale('en', 'US')]`)
- `title` (String, default: '')
- `debugShowCheckedModeBanner` (bool, default: true)

### OiOverlays
**Tags:** `overlay`, `dialog`, `toast`, `sheet`, `popup`, `notification`

Singleton managing all overlays in a z-ordered stack.

**Z-Order Levels:** `base` < `dropdown` < `tooltip` < `panel` < `dialog` < `toast` < `critical`

**Static Methods:**
```dart
OiOverlays.of(context).show(label: '...', builder: (_) => widget, zOrder: ...);
// Returns OiOverlayHandle with .dismiss() and .isDismissed
```

Prefer the widget-specific static methods: `OiDialog.show()`, `OiToast.show()`, `OiSheet.show()`.
For `Future<T?>` semantics, use `showOiDialog<T>()`, `OiDialog.showAsync<T>()`, or `OiSheet.showAsync<T>()`.

### OiResponsive & Breakpoints
**Tags:** `responsive`, `breakpoint`, `adaptive`, `mobile`, `desktop`, `tablet`

**5 Standard Breakpoints:**

| Name | Min Width | Typical Device |
|---|---|---|
| `compact` | 0px | Phone portrait |
| `medium` | 600px | Phone landscape / small tablet |
| `expanded` | 840px | Tablet / small desktop |
| `large` | 1200px | Desktop |
| `extraLarge` | 1600px | Wide desktop |

**OiResponsive<T>** — Holds per-breakpoint values:
```dart
OiResponsive<int>(2)                              // Static value
OiResponsive<int>.responsive({compact: 1, expanded: 2, large: 3}) // Per-breakpoint
```

**Context Extensions:**
```dart
context.isCompact   // bool
context.isMedium
context.isExpanded  // etc.
```

### OiPlatform & OiInputModality
**Tags:** `platform`, `ios`, `android`, `web`, `desktop`, `touch`, `pointer`

Detects platform (iOS/Android/macOS/Windows/Web) and input modality (touch vs pointer) independently of screen size.

### OiAccessibility
**Tags:** `a11y`, `accessibility`, `screen-reader`, `reduced-motion`

- `OiA11y.announce(context, 'message')` — Screen reader announcement
- All components enforce 48dp minimum touch targets on touch devices
- Respects system `prefers-reduced-motion` setting

### OiUndoStack
**Tags:** `undo`, `redo`, `history`, `ctrl-z`

Global undo/redo with Ctrl+Z / Ctrl+Shift+Z. Max history configurable via `OiApp.undoStackMaxHistory`.

### OiShortcutScope
**Tags:** `keyboard`, `shortcut`, `hotkey`

Register keyboard shortcuts scoped to a widget subtree.

### OiTourScope
**Tags:** `tour`, `onboarding`, `spotlight`, `tutorial`

Scope for `OiTour` and `OiSpotlight` guided tours.

### Persistence — OiSettingsDriver
**Tags:** `settings`, `persistence`, `storage`, `preferences`

Abstract interface for persisting widget state (column widths, sort, filters, layout).

**Built-in Drivers:**
- `OiLocalStorageDriver()` — SharedPreferences-based (recommended)
- `OiInMemoryDriver()` — Memory only (testing)

**Usage:**
```dart
OiApp(
  settingsDriver: OiLocalStorageDriver(),
  // All widgets with settingsDriver parameter will auto-persist state
)
```

**Companion Classes:**
- `OiSettingsData` — Settings storage model
- `OiSettingsProvider` — Change notifier
- `OiSettingsMixin` — Convenience mixin

### OiPageRoute
**Tags:** `route`, `page`, `transition`, `navigation`, `animation`

Non-Material page route with 5 transition types. Drop-in replacement for `MaterialPageRoute` without Material dependency.

**Key Parameters:**
- `builder` (WidgetBuilder, required) — Page content builder
- `transition` (OiPageTransitionType, default: fade) — fade, slideHorizontal, slideVertical, scaleUp, none
- `transitionDuration` (Duration?) — Forward transition duration
- `reverseTransitionDuration` (Duration?) — Reverse transition duration
- `maintainState` (bool, default: true)
- `fullscreenDialog` (bool, default: false)
- `barrierColor` (Color?)
- `barrierDismissible` (bool, default: false)

**Static Methods:**
- `OiPageRoute.of(context:, builder:)` — Reads transition defaults from theme (`OiAnimationConfig`)

**Use When:** Programmatic navigation without go_router. Custom page transitions.
**Avoid When:** Using go_router — use `OiTransitionPage` instead.
**Combine With:** `Navigator`, `OiApp`

---

### OiTransitionPage
**Tags:** `route`, `page`, `go-router`, `transition`

Page subclass for go_router with OiPageRoute transitions. Use as `Page` in GoRouter route definitions.

**Key Parameters:**
- `child` (Widget, required) — Page content
- `transition` (OiPageTransitionType, default: fade) — fade, slideHorizontal, slideVertical, scaleUp, none
- `transitionDuration` (Duration?)
- `reverseTransitionDuration` (Duration?)

**Use When:** go_router navigation with custom transitions.
**Combine With:** `GoRouter`, `OiApp.router`

---

### OiPageTransitionType (Enum)
**Tags:** `route`, `transition`, `animation`, `enum`

Page transition animation type.

**Values:** `fade`, `slideHorizontal`, `slideVertical`, `scaleUp`, `none`

**Theme Integration:** `OiAnimationConfig` has `defaultPageTransition`, `pageTransitionDuration`, `pageEntryCurve`, `pageExitCurve`.

---

## Widget Catalog

---

### PRIMITIVES — Animation

---

#### OiAnimatedList
**Tags:** `animation`, `list`, `add`, `remove`, `transition`
**Tier:** Primitive

Auto-animates list differences (add/remove/reorder). Wraps Flutter's `AnimatedList` with a cleaner API.

**Use When:** You have a list where items are dynamically added or removed and want smooth transitions.
**Avoid When:** Static lists that don't change. Use regular `OiColumn` or `OiVirtualList` instead.
**Combine With:** `OiListTile`, `OiCard`, `OiSwipeable`

---

#### OiMorph
**Tags:** `animation`, `crossfade`, `morph`, `transition`, `state-change`
**Tier:** Primitive

Crossfade + size morph between two widget states.

**Use When:** Transitioning between two different widgets (e.g., loading -> content, collapsed -> expanded).
**Avoid When:** Simple show/hide — use `OiVisibility` instead.

---

#### OiPulse
**Tags:** `animation`, `pulse`, `attention`, `notification`, `live`, `dot`
**Tier:** Primitive

Pulsing attention indicator. Use for notification dots, live status indicators.

**Use When:** Drawing attention to a badge, unread count, or live status.
**Combine With:** `OiBadge`, `OiAvatar`, `OiLiveRing`

---

#### OiShimmer
**Tags:** `animation`, `loading`, `skeleton`, `placeholder`
**Tier:** Primitive

Loading skeleton shimmer effect. Use during content loading states.

**Use When:** Content is loading and you want to show a placeholder.
**Combine With:** `OiSkeletonGroup` (which orchestrates multiple shimmer placeholders)
**Avoid When:** You have a simple spinner — use `OiProgress` with indeterminate mode.

---

#### OiSpring
**Tags:** `animation`, `spring`, `physics`, `bounce`
**Tier:** Primitive

Spring physics-based animation builder. For natural-feeling motion.

**Use When:** You need physics-based animation (bouncy buttons, pull-to-refresh).
**Avoid When:** Simple fade/slide — use Flutter's built-in `AnimatedContainer`.

---

#### OiStagger
**Tags:** `animation`, `stagger`, `sequence`, `list-entrance`
**Tier:** Primitive

Children animate in sequentially with configurable delay.

**Use When:** List items should appear one by one (page load, search results).
**Combine With:** `OiPage`, `OiColumn`, any list of widgets

---

### PRIMITIVES — Clipboard

---

#### OiCopyButton
**Tags:** `clipboard`, `copy`, `button`
**Tier:** Primitive

Standalone copy button with checkmark animation on success.

**Use When:** Explicit copy action next to a value (API keys, codes, IDs).
**Combine With:** `OiCodeBlock`, `OiFieldDisplay`, `OiMetric`

---

#### OiCopyable
**Tags:** `clipboard`, `copy`, `tap-to-copy`
**Tier:** Primitive

Wraps any widget; copies text to clipboard on tap. Shows toast feedback.

**Use When:** Any text that should be copyable on click.
**Combine With:** `OiLabel`, `OiMetric`

---

#### OiPasteZone
**Tags:** `clipboard`, `paste`, `input`
**Tier:** Primitive

Detects paste events (Ctrl+V on desktop, tap-to-paste on mobile).

**Use When:** Accepting pasted content (codes, URLs, data).

---

### PRIMITIVES — Display

---

#### OiDivider
**Tags:** `divider`, `separator`, `line`, `hr`
**Tier:** Primitive

Separator line (horizontal/vertical). Supports solid/dashed/dotted styles.

**Key Parameters:**
- `axis` (Axis, default: horizontal)
- `thickness` (double, default: 1.0)
- `color` (Color?)
- `style` (OiBorderLineStyle, default: solid) — solid, dashed, dotted
- `spacing` (double, default: 0) — margin on both sides

**Factory Constructors:**
- `.withLabel(String)` — Divider with centered label text
- `.withContent(Widget)` — Divider with centered custom widget

**Use When:** Separating sections of content.
**Avoid When:** Visual grouping — use `OiCard` or `OiSection` instead.

---

#### OiIcon
**Tags:** `icon`, `glyph`, `symbol`
**Tier:** Primitive

Themed icon with required accessibility label.

**Key Parameters:**
- `icon` (IconData, required) — Use constants from `OiIcons`
- `label` (String, required) — Accessibility label
- `size` (double?)
- `color` (Color?)

**Factory Constructors:**
- `.decorative(icon:)` — For purely decorative icons (no screen reader label)

**Use When:** Any icon display. Always provide a `label` unless truly decorative.
**Avoid When:** Never use raw `Icon()` widget.

---

#### OiLabel
**Tags:** `text`, `typography`, `heading`, `body`, `caption`, `label`
**Tier:** Primitive

Text display with semantic variants. **Use this instead of `Text()` everywhere.**

**Key Parameters (all constructors):**
- First positional: `text` (String, required)
- `maxLines` (int?)
- `overflow` (TextOverflow?)
- `textAlign` (TextAlign?)
- `copyable` (bool, default: false)
- `selectable` (bool, default: false)
- `semanticsLabel` (String?)

**Named Constructors:** `OiLabel.display()`, `.h1()`, `.h2()`, `.h3()`, `.h4()`, `.body()`, `.bodyStrong()`, `.small()`, `.smallStrong()`, `.tiny()`, `.caption()`, `.code()`, `.overline()`, `.link()`, `.copyable()`

**Special Constructors:**
- `.copyable(text)` — Field-value display with built-in copy-to-clipboard. Selectable text with copy button on hover (desktop) or long-press (mobile). Ideal for IDs, API keys, URLs, error codes.

**Use When:** Any text display. Choose the variant matching the semantic level.
**Avoid When:** Never use raw `Text()` — always use `OiLabel`.

---

#### OiSurface
**Tags:** `container`, `card`, `background`, `border`, `glass`, `frosted`, `transparent`, `elevated`
**Tier:** Primitive

Themed container primitive. Renders backgrounds, borders, shadows, halos, glass effects.

**Key Parameters:**
- `color` (Color?)
- `border` (OiBorderStyle?)
- `borderRadius` (BorderRadius?)
- `shadow` (List<BoxShadow>?)
- `padding` (EdgeInsetsGeometry?)
- `halo` (OiHaloStyle?)
- `frosted` (bool, default: false) — Frosted glass blur effect
- `gradient` (OiGradientStyle?)
- `child` (Widget?)

**Named Constructors:**
- `.transparent(child:, borderRadius:)` — Transparent surface providing clipping and hit-test boundary without visual styling. Replaces `Material(color: transparent)`.
- `.elevated(elevation:, child:, borderRadius:)` — Transparent surface with elevation shadow. Adds shadow to a container without background fill.

**Use When:** Custom containers with visual styling. Building new component layouts.
**Avoid When:** Standard card layouts — use `OiCard` instead (it handles title/footer/interaction).

---

### PRIMITIVES — Drag & Drop

---

#### OiDraggable
**Tags:** `drag`, `drag-and-drop`, `draggable`, `move`
**Tier:** Primitive

Initiates drag on long-press (touch) or immediate drag (pointer). Returns typed data on drop.

**Combine With:** `OiDropZone<T>`, `OiDragGhost`

---

#### OiDropZone
**Tags:** `drop`, `drag-and-drop`, `drop-target`, `receive`
**Tier:** Primitive

Receives drops with visual feedback (hovering, canAccept states).

**Combine With:** `OiDraggable`, `OiDropHighlight`

---

#### OiDragGhost
**Tags:** `drag`, `preview`, `ghost`
**Tier:** Primitive

Visual representation during drag (translucent, elevated, slightly rotated).

---

#### OiReorderable
**Tags:** `reorder`, `drag`, `sort`, `list`, `rearrange`
**Tier:** Primitive

Drag-to-reorder list/grid. Keyboard fallback (Space-to-select, arrows-to-move, Enter-to-drop).

**Use When:** User needs to reorder items in a list.
**Combine With:** `OiListTile`, `OiCard`

---

### PRIMITIVES — Gesture

---

#### OiDoubleTap
**Tags:** `gesture`, `double-tap`, `interaction`
**Tier:** Primitive

Double-tap gesture detection.

---

#### OiLongPressMenu
**Tags:** `gesture`, `long-press`, `context-menu`, `mobile`
**Tier:** Primitive

Long-press gesture with optional menu trigger.

**Combine With:** `OiContextMenu`

---

#### OiPinchZoom
**Tags:** `gesture`, `pinch`, `zoom`, `pan`, `image`
**Tier:** Primitive

Two-finger pinch zoom + pan with min/max zoom bounds.

**Use When:** Zoomable content (images, maps, diagrams).
**Combine With:** `OiImage`, `OiLightbox`

---

#### OiSwipeable
**Tags:** `gesture`, `swipe`, `delete`, `archive`, `action`, `mobile`
**Tier:** Primitive

Swipe actions (left/right reveals action buttons).

**Use When:** List items with swipe-to-delete or swipe-to-archive patterns.
**Combine With:** `OiListTile`, `OiAnimatedList`

---

### PRIMITIVES — Input

---

#### OiRawInput
**Tags:** `input`, `text-editing`, `unstyled`, `primitive`
**Tier:** Primitive

Unstyled text editing wrapper. Used internally by all styled inputs.

**Use When:** Building a completely custom input widget.
**Avoid When:** Standard text input — use `OiTextInput` instead.

---

### PRIMITIVES — Interaction

---

#### OiFocusTrap
**Tags:** `focus`, `trap`, `modal`, `keyboard`, `accessibility`
**Tier:** Primitive

Keyboard focus confinement for modals/dialogs. Cycles focus within subtree on Tab.

**Use When:** Building custom modal-like widgets. (Built-in overlays like OiDialog already use this.)

---

#### OiTappable
**Tags:** `tap`, `press`, `hover`, `focus`, `interaction`, `clickable`
**Tier:** Primitive

Foundation of every interactive element. Manages tap/long-press/double-tap/hover/focus/active states with automatic effects.

**Key Parameters:**
- `child` (Widget, required)
- `onTap` (VoidCallback?)
- `onDoubleTap` (VoidCallback?)
- `onLongPress` (VoidCallback?)
- `onHover` (ValueChanged<bool>?)
- `onFocusChange` (ValueChanged<bool>?)
- `enabled` (bool, default: true)
- `focusable` (bool, default: true)
- `semanticLabel` (String?)
- `cursor` (MouseCursor?)

**Use When:** Making any widget interactive. All higher-tier interactive widgets use this internally.
**Avoid When:** Standard buttons — use `OiButton`. Standard list items — use `OiListTile`.

---

#### OiTouchTarget
**Tags:** `touch`, `target`, `accessibility`, `minimum-size`
**Tier:** Primitive

Enforces 48dp minimum touch target size on touch devices.

---

### PRIMITIVES — Layout

---

#### OiAspectRatio
**Tags:** `layout`, `aspect-ratio`, `proportional`
**Tier:** Primitive

Maintains aspect ratio for child widget.

---

#### OiColumn
**Tags:** `layout`, `column`, `vertical`, `stack`
**Tier:** Primitive

Enhanced Column with responsive gap and collapse support. **Use instead of `Column`.**

**Key Parameters:**
- `breakpoint` (OiBreakpoint, required)
- `children` (List<Widget>, required)
- `gap` (OiResponsive<double>, default: 0) — Spacing between children
- `mainAxisAlignment` (MainAxisAlignment, default: start)
- `crossAxisAlignment` (CrossAxisAlignment, default: center)
- `collapse` (OiBreakpoint?) — Breakpoint below which to collapse
- `scale` (OiBreakpointScale)

---

#### OiRow
**Tags:** `layout`, `row`, `horizontal`, `inline`
**Tier:** Primitive

Enhanced Row with responsive gap and collapse support. **Use instead of `Row`.**

**Key Parameters:** Same as `OiColumn`.

---

#### OiContainer
**Tags:** `layout`, `container`, `padding`, `margin`, `box`
**Tier:** Primitive

Enhanced Container with padding/margin helpers.

---

#### OiGrid
**Tags:** `layout`, `grid`, `responsive`, `columns`, `masonry`
**Tier:** Primitive

Responsive grid layout with column count or min column width.

**Key Parameters:**
- `breakpoint` (OiBreakpoint, required)
- `children` (List<Widget>, required)
- `columns` (OiResponsive<int>?) — Fixed column count per breakpoint
- `minColumnWidth` (OiResponsive<double>?) — Auto columns by min width
- `gap` (OiResponsive<double>, default: 0)
- `rowGap` (OiResponsive<double>?)

**Factory Constructors:**
- `.containerRelative()` — Uses container width instead of viewport

**Use When:** Multi-column layouts. Product grids. Dashboard cards.
**Combine With:** `OiCard`, `OiFieldDisplay.pair()`, `OiDetailView`

---

#### OiMasonry
**Tags:** `layout`, `masonry`, `pinterest`, `waterfall`
**Tier:** Primitive

Masonry/Pinterest-style layout with variable height items.

---

#### OiPage
**Tags:** `layout`, `page`, `container`, `max-width`, `responsive`
**Tier:** Primitive

Full-page layout container with responsive padding and max-width.

**Key Parameters:**
- `breakpoint` (OiBreakpoint, required)
- `children` (List<Widget>, required)
- `gap` (OiResponsive<double>, default: 0)
- `padding` (OiResponsive<EdgeInsetsGeometry>?)
- `crossAxisAlignment` (CrossAxisAlignment, default: stretch)

**Use When:** Top-level page wrapper. Controls max-width and gutters per breakpoint.

---

#### OiSection
**Tags:** `layout`, `section`, `semantic`, `grouping`
**Tier:** Primitive

Semantic layout section with optional accessibility label.

**Key Parameters:**
- `breakpoint` (OiBreakpoint, required)
- `children` (List<Widget>, required)
- `gap` (OiResponsive<double>, default: 0)
- `padding` (OiResponsive<EdgeInsetsGeometry>?)
- `semanticLabel` (String?)

**Use When:** Grouping related content within a page.
**Combine With:** `OiPage`, `OiLabel.h2()` (as section title)

---

#### OiSpacer
**Tags:** `layout`, `spacing`, `gap`, `whitespace`
**Tier:** Primitive

Flexible spacing widget.

---

#### OiWrapLayout
**Tags:** `layout`, `wrap`, `flow`, `responsive`, `tags`, `chips`
**Tier:** Primitive

Wrapping layout with gap control. Children wrap to next line when space runs out.

**Use When:** Tag/chip lists, button groups that should wrap on small screens.
**Combine With:** `OiBadge`, `OiButton`, `OiToggleButton`

---

### PRIMITIVES — Overlay

---

#### OiFloating
**Tags:** `overlay`, `positioning`, `anchor`, `dropdown`, `popover`
**Tier:** Primitive

Positioning engine for overlays. Anchors to target widgets with collision detection.

**Use When:** Building custom positioned overlays.
**Avoid When:** Standard overlays — use `OiPopover`, `OiTooltip`, `OiContextMenu`.

---

#### OiPortal
**Tags:** `overlay`, `portal`, `layer`, `escape`
**Tier:** Primitive

Renders widget into a separate overlay layer.

---

#### OiVisibility
**Tags:** `visibility`, `show`, `hide`, `conditional`
**Tier:** Primitive

Conditional widget visibility with optional animation.

**Use When:** Show/hide content based on state. Responsive visibility.

---

### PRIMITIVES — Scroll

---

#### OiInfiniteScroll
**Tags:** `scroll`, `infinite`, `pagination`, `load-more`
**Tier:** Primitive

Detects scroll-to-edge and fires load callback.

**Use When:** Infinite scrolling lists.
**Combine With:** `OiVirtualList`, `OiListView`

---

#### OiScrollbar
**Tags:** `scroll`, `scrollbar`, `custom`
**Tier:** Primitive

Themed scrollbar with hover fade.

---

#### OiVirtualList
**Tags:** `scroll`, `virtual`, `performance`, `large-list`, `lazy`
**Tier:** Primitive

Virtualized scrolling for large lists. Only renders visible items.

**Key Parameters:**
- `itemCount` (int, required)
- `itemBuilder` (IndexedWidgetBuilder, required)
- `cacheExtent` (double?)
- `onRefresh` (Future<void> Function()?)
- `controller` (ScrollController?)
- `scrollDirection` (Axis, default: vertical)
- `padding` (EdgeInsetsGeometry?)

**Use When:** Lists with 100+ items. Always use for large datasets.
**Avoid When:** Short lists (<50 items) — use `OiColumn` with children.

---

#### OiVirtualGrid
**Tags:** `scroll`, `virtual`, `grid`, `performance`, `large-grid`
**Tier:** Primitive

Virtualized grid for large datasets.

---

#### OiSliverList
**Tags:** `sliver`, `list`, `scroll`, `lazy`
**Tier:** Primitive

Themed sliver list wrapper with builder/separated/children patterns. Use inside `CustomScrollView`.

**Key Parameters:**
- `itemCount` (int, required) — Number of items
- `itemBuilder` (IndexedWidgetBuilder, required) — Item builder
- `padding` (EdgeInsetsGeometry?)
- `separated` (bool, default: false) — Add separators between items
- `separatorBuilder` (IndexedWidgetBuilder?)
- `semanticLabel` (String?)

**Named Constructors:**
- `.children(children: [...])` — From explicit widget list

**Use When:** Sliver-based scrollable lists inside `CustomScrollView`.
**Avoid When:** Standalone lists — use `OiVirtualList`. Non-sliver contexts — use `OiColumn`.
**Combine With:** `OiSliverGrid`, `OiSliverHeader`, `CustomScrollView`

---

#### OiSliverGrid
**Tags:** `sliver`, `grid`, `scroll`, `responsive`, `lazy`
**Tier:** Primitive

Themed sliver grid with fixed or extent-based columns. Use inside `CustomScrollView`.

**Key Parameters:**
- `itemCount` (int, required) — Number of items
- `itemBuilder` (IndexedWidgetBuilder, required) — Item builder
- `crossAxisCount` (int, required) — Number of columns
- `mainAxisSpacing` (double?)
- `crossAxisSpacing` (double?)
- `childAspectRatio` (double, default: 1.0)
- `padding` (EdgeInsetsGeometry?)

**Named Constructors:**
- `.extent(minItemWidth:)` — Responsive columns based on minimum item width

**Use When:** Sliver-based grid layouts inside `CustomScrollView`.
**Avoid When:** Standalone grids — use `OiGrid` or `OiVirtualGrid`.
**Combine With:** `OiSliverList`, `OiSliverHeader`, `CustomScrollView`

---

### COMPONENTS — Buttons

---

#### OiButton
**Tags:** `button`, `action`, `submit`, `click`, `tap`, `cta`
**Tier:** Component

Universal button with variant factories.

**Key Parameters:**
- `label` (String?) — Button text
- `icon` (IconData?) — Optional icon
- `iconPosition` (OiIconPosition, default: leading)
- `variant` (OiButtonVariant, default: primary)
- `size` (OiButtonSize, default: medium) — small/medium/large
- `onTap` (VoidCallback?)
- `enabled` (bool, default: true)
- `loading` (bool, default: false) — Shows spinner
- `fullWidth` (bool, default: false)
- `semanticLabel` (String?)
- `tooltip` (String?)
- `borderRadius` (BorderRadius?)

**Named Constructors (Variants):**
- `OiButton.primary()` — Main action (filled, primary color)
- `OiButton.secondary()` — Secondary action (filled, neutral)
- `OiButton.outline()` — Bordered, transparent background
- `OiButton.ghost()` — No border, transparent background
- `OiButton.destructive()` — Delete/danger action (red)
- `OiButton.soft()` — Soft fill (muted background)

**Special Constructors:**
- `OiButton.icon(icon:, label:)` — Icon-only button (label for accessibility)
- `OiButton.split(label:, onTap:, dropdown:)` — Button with dropdown
- `OiButton.countdown(label:, onTap:, seconds:)` — Countdown before action
- `OiButton.confirm(label:, confirmLabel:, onConfirm:)` — Two-click confirmation

**Theme:** `context.components.button` -> `OiButtonThemeData`

**Use When:** Any clickable action.
**Avoid When:** Navigation links (use OiLabel.link or router navigation). Toggle state (use OiToggleButton).

---

#### OiButtonGroup
**Tags:** `button`, `group`, `toggle`, `segmented`, `toolbar`
**Tier:** Component

Row of connected or spaced buttons. Supports exclusive (single-select) or non-exclusive mode.

**Key Parameters:**
- `items` (List<OiButtonGroupItem>, required) — Each has `label`, `icon`, `onTap`, `enabled`, `semanticLabel`
- `exclusive` (bool, default: false) — Single-select toggle mode
- `selectedIndex` (int?) — For exclusive mode
- `spacing` (double, default: 0) — 0 = connected, >0 = gapped
- `direction` (Axis, default: horizontal)

**Use When:** Toolbar actions, segmented controls, view toggles (list/grid).
**Combine With:** `OiListView` (for layout toggle), `OiFileExplorer`

---

#### OiIconButton
**Tags:** `button`, `icon`, `action`, `toolbar`
**Tier:** Component

Convenience wrapper around `OiButton.icon()`.

**Key Parameters:**
- `icon` (IconData, required)
- `semanticLabel` (String, required)
- `onTap` (VoidCallback?)
- `size` (OiButtonSize, default: medium)
- `variant` (OiButtonVariant, default: ghost)
- `enabled` (bool, default: true)

---

#### OiToggleButton
**Tags:** `button`, `toggle`, `on-off`, `switch`, `state`
**Tier:** Component

Button that toggles between selected/unselected states.

**Key Parameters:**
- `selected` (bool, required)
- `semanticLabel` (String, required)
- `label` (String?)
- `icon` (IconData?)
- `onChanged` (ValueChanged<bool>?)
- `size` (OiButtonSize, default: medium)
- `enabled` (bool, default: true)

**Use When:** Toggle actions (bold, italic, favorite, bookmark).
**Avoid When:** On/off settings — use `OiSwitch`. Multiple exclusive options — use `OiButtonGroup` with `exclusive: true`.

---

### COMPONENTS — Dialogs (File Operations)

---

#### OiDeleteDialog
**Tags:** `dialog`, `delete`, `confirm`, `destructive`, `file`
**Tier:** Component

Deletion confirmation dialog with optional reason field.

---

#### OiFileInfoDialog
**Tags:** `dialog`, `file`, `info`, `properties`, `metadata`
**Tier:** Component

File metadata display dialog (name, size, dates, location).

---

#### OiMoveDialog
**Tags:** `dialog`, `file`, `move`, `copy`, `destination`
**Tier:** Component

Move/copy file/folder with destination folder selector.

---

#### OiNewFolderDialog
**Tags:** `dialog`, `folder`, `create`, `new`
**Tier:** Component

Dialog to create a new folder.

---

#### OiRenameDialog
**Tags:** `dialog`, `rename`, `edit`, `name`
**Tier:** Component

Dialog to rename a file/folder.

---

#### OiUploadDialog
**Tags:** `dialog`, `upload`, `file`, `progress`
**Tier:** Component

File upload dialog with drag-drop zone, progress tracking, pause/resume.

---

### COMPONENTS — Display

---

#### OiAvatar
**Tags:** `avatar`, `user`, `profile`, `image`, `initials`, `presence`
**Tier:** Component

User/entity avatar. Shows image, initials fallback, or icon.

**Key Parameters:**
- `semanticLabel` (String, required)
- `imageUrl` (String?)
- `initials` (String?)
- `icon` (IconData?)
- `size` (OiAvatarSize, default: md) — xs(24)/sm(32)/md(40)/lg(56)/xl(72)
- `skeleton` (bool, default: false) — Loading state
- `presence` (OiPresenceStatus?) — online/offline/away/busy indicator

**Theme:** `context.components.avatar` -> `OiAvatarThemeData`
**Combine With:** `OiAvatarStack` (for multiple), `OiListTile` (as leading), `OiChat`

---

#### OiBadge
**Tags:** `badge`, `tag`, `label`, `status`, `category`, `chip`
**Tier:** Component

Status/tag badge with color variants.

**Named Constructors:**
- `OiBadge.filled(label:)` — Solid background
- `OiBadge.soft(label:)` — Muted background
- `OiBadge.outline(label:)` — Border only

**Key Parameters (all constructors):**
- `label` (String, required)
- `color` (OiBadgeColor, default: primary) — primary/accent/success/warning/error/info/neutral
- `size` (OiBadgeSize, default: medium) — small/medium/large
- `icon` (IconData?)
- `dot` (bool, default: false) — Shows dot indicator

**Theme:** `context.components.badge` -> `OiBadgeThemeData`

**Use When:** Status indicators, category labels, counts, tags.
**Combine With:** `OiListTile` (as trailing), `OiCard`, `OiFieldDisplay` (for choice fields)

---

#### OiCard
**Tags:** `card`, `container`, `panel`, `section`, `tile`, `box`
**Tier:** Component

Content container with optional title, subtitle, footer, interaction.

**Key Parameters:**
- `child` (Widget, required)
- `title` (Widget?)
- `subtitle` (Widget?)
- `leading` (Widget?)
- `trailing` (Widget?)
- `footer` (Widget?)
- `onTap` (VoidCallback?)
- `label` (String?) — Required for interactive cards
- `collapsible` (bool, default: false)
- `defaultCollapsed` (bool, default: false)
- `padding` (EdgeInsetsGeometry?)
- `border` (OiBorderStyle?)
- `gradient` (OiGradientStyle?)
- `halo` (OiHaloStyle?)

**Named Constructors:**
- `OiCard.flat()` — No shadow
- `OiCard.outlined()` — Border only, no shadow
- `OiCard.interactive()` — Hover/focus effects (requires `label`)
- `OiCard.compact()` — Reduced padding (8px)

**Theme:** `context.components.card` -> `OiCardThemeData`

**Use When:** Grouping related content. Product cards. Dashboard widgets.
**Avoid When:** Simple backgrounds — use `OiSurface`. Section grouping without visual boundary — use `OiSection`.

---

#### OiCodeBlock
**Tags:** `code`, `syntax`, `highlight`, `snippet`, `pre`, `monospace`
**Tier:** Component

Syntax-highlighted code display with copy button.

**Use When:** Showing code snippets, API responses, configuration.
**Combine With:** `OiCopyButton`, `OiDiffView`

---

#### OiDiffView
**Tags:** `diff`, `compare`, `code`, `changes`, `side-by-side`
**Tier:** Component

Side-by-side diff view highlighting added/removed/modified lines.

**Use When:** Comparing two versions of text/code.

---

#### OiDropHighlight
**Tags:** `drag-and-drop`, `drop`, `highlight`, `feedback`
**Tier:** Component

Visual feedback when item hovers over drop zone.

---

#### OiEmptyState
**Tags:** `empty`, `placeholder`, `no-data`, `no-results`, `error-page`, `404`, `illustration`
**Tier:** Component

Placeholder for empty views.

**Key Parameters:**
- `title` (String, required) — e.g., "No items found"
- `icon` (IconData?)
- `illustration` (Widget?) — Custom illustration
- `description` (String?)
- `action` (Widget?) — Usually an `OiButton`

**Use When:** Empty lists, empty search results, error pages (404/403/500).

> **Note:** Planned additions include `.notFound()`, `.forbidden()`, `.error()` factory constructors for common error states. For full-page error displays now, use `OiErrorPage`.

---

#### OiFieldDisplay
**Tags:** `field`, `display`, `read-only`, `value`, `formatted`, `detail`, `data`
**Tier:** Component

Universal read-only field renderer. Formats values by type (date, currency, boolean, etc.).

**Key Parameters:**
- `value` (dynamic, required)
- `type` (OiFieldType, default: text) — Controls formatting
- `label` (String?)
- `emptyText` (String, default: '---')
- `copyable` (bool, default: false)
- `maxLines` (int?)
- `dateFormat` (String?) — Custom date format
- `numberFormat` (String?) — Custom number format
- `currencyCode` (String?) — e.g., 'EUR'
- `currencySymbol` (String?) — e.g., 'EUR'
- `decimalPlaces` (int?)
- `choices` (Map<String, String>?) — Value->display mapping for select fields
- `choiceColors` (Map<String, OiBadgeColor>?) — Value->badge color for select fields
- `formatValue` (String Function(dynamic)?) — Custom formatter
- `onTap` (VoidCallback?) — Makes value tappable
- `leading` (Widget?) — Icon/widget before value

**Named Constructors:**
- `.pair(label:, value:)` — Label + value layout
  - Extra params: `direction` (Axis, default: horizontal), `labelWidth` (double?)

**Theme:** `context.components.fieldDisplay` -> `OiFieldDisplayThemeData`

**Use When:** Displaying read-only data fields. Detail pages. Record views.
**Combine With:** `OiDetailView` (orchestrates multiple fields), `OiCard`
**Avoid When:** Editable fields — use `OiTextInput`, `OiSelect`, etc.

---

#### OiFileGridCard
**Tags:** `file`, `grid`, `card`, `preview`, `thumbnail`
**Tier:** Component

File card for grid view with preview/thumbnail, name, selection.

---

#### OiFileIcon
**Tags:** `file`, `icon`, `type`, `extension`
**Tier:** Component

File type icon with different shapes/colors per file category.

---

#### OiFilePreview
**Tags:** `file`, `preview`, `thumbnail`, `image`
**Tier:** Component

File preview (thumbnail or type icon).

---

#### OiFileTile
**Tags:** `file`, `list`, `row`, `item`
**Tier:** Component

File list row with icon, name, size, date.

---

#### OiFolderIcon
**Tags:** `folder`, `icon`, `directory`
**Tier:** Component

Folder icon with optional custom color.

---

#### OiFolderTreeItem
**Tags:** `folder`, `tree`, `expand`, `hierarchy`
**Tier:** Component

Expandable tree node for folder hierarchy.

---

#### OiImage
**Tags:** `image`, `photo`, `picture`, `lazy`, `responsive`
**Tier:** Component

Image with required alt text, placeholder/error states, lazy loading.

**Use When:** Any image display. Always provide alt text.
**Avoid When:** Never use raw `Image()` widget.

---

#### OiListTile
**Tags:** `list`, `tile`, `row`, `item`, `cell`
**Tier:** Component

Standardized list row.

**Key Parameters:**
- `title` (String, required)
- `subtitle` (String?)
- `leading` (Widget?) — Icon, avatar, etc.
- `trailing` (Widget?) — Badge, action, etc.
- `onTap` (VoidCallback?)
- `selected` (bool, default: false)
- `enabled` (bool, default: true)
- `dense` (bool, default: false)

**Use When:** List items, settings rows, navigation menus.
**Combine With:** `OiAvatar` (leading), `OiBadge` (trailing), `OiSwipeable`

---

#### OiMarkdown
**Tags:** `markdown`, `rich-text`, `content`, `documentation`
**Tier:** Component

Rendered markdown content (headings, lists, code blocks, links, images, tables).

---

#### OiMetric
**Tags:** `metric`, `kpi`, `number`, `statistic`, `dashboard`, `value`
**Tier:** Component

KPI/metric display with large value, label, trend indicator.

**Key Parameters:**
- `label` (String, required) — Metric name
- `value` (String, required) — The number
- `subValue` (String?) — Additional context
- `trend` (OiMetricTrend?) — up/down/neutral
- `trendPercent` (double?)
- `sparkline` (Widget?) — Inline chart

**Use When:** Dashboard metrics, KPI cards.
**Combine With:** `OiCard`, `OiDashboard`, `OiGrid`

---

#### OiPathBar
**Tags:** `path`, `breadcrumb`, `navigation`, `file-path`
**Tier:** Component

Breadcrumb-style path navigation for file explorers.

---

#### OiPopover
**Tags:** `popover`, `floating`, `tooltip`, `dropdown`, `content`
**Tier:** Component

Floating content box anchored to a trigger widget.

**Use When:** Rich hover/click content (menus, previews, detail panels).
**Avoid When:** Simple text hints — use `OiTooltip`. Full page overlays — use `OiDialog` or `OiSheet`.

---

#### OiProgress
**Tags:** `progress`, `loading`, `bar`, `circular`, `spinner`, `percentage`
**Tier:** Component

Progress indicator (linear or circular). Determinate or indeterminate.

**Theme:** `context.components.progress` -> `OiProgressThemeData`

**Use When:** Loading states, upload/download progress, step completion.

---

#### OiRelativeTime
**Tags:** `time`, `relative`, `ago`, `timestamp`, `live`
**Tier:** Component

Auto-refreshing relative time display ("2m ago", "just now", "yesterday at 14:32").

**Use When:** Chat timestamps, activity feeds, notifications.
**Combine With:** `OiChatMessage`, `OiActivityFeed`, `OiComments`

---

#### OiRenameField
**Tags:** `rename`, `inline-edit`, `text-input`, `file`
**Tier:** Component

Inline text input for file/folder rename.

---

#### OiReplyPreview
**Tags:** `reply`, `quote`, `preview`, `message`, `chat`
**Tier:** Component

Quoted reply display within message bubbles.

---

#### OiSkeletonGroup
**Tags:** `skeleton`, `loading`, `placeholder`, `shimmer`
**Tier:** Component

Multiple skeleton loaders for content loading state.

**Use When:** Loading state for multiple elements (card grid, form, list).
**Combine With:** `OiShimmer`

---

#### OiStorageIndicator
**Tags:** `storage`, `usage`, `disk`, `quota`, `progress`
**Tier:** Component

Storage usage visualization (circular or linear).

---

#### OiTooltip
**Tags:** `tooltip`, `hint`, `help`, `hover`, `info`
**Tier:** Component

Hover/focus tooltip.

**Theme:** `context.components.tooltip` -> `OiTooltipThemeData`

**Use When:** Brief explanatory text on hover/focus.
**Avoid When:** Rich content — use `OiPopover`.

---

### COMPONENTS — Display (Admin)

---

#### [ADMIN] OiPriceTag
**Tags:** `price`, `currency`, `money`, `cost`, `shop`, `e-commerce`
**Tier:** Component

Formatted price display with optional compare-at (strikethrough) price.

**Key Parameters:**
- `price` (double, required)
- `label` (String, required)
- `compareAtPrice` (double?) — Shows strikethrough "was" price
- `currencyCode` / `currencySymbol` (String?)
- `decimalPlaces` (int, default: 2)
- `size` (OiPriceTagSize, default: medium) — small/medium/large

**Use When:** Any price display.
**Combine With:** OiProductCard, OiCartItemRow, OiOrderSummaryLine
**Avoid When:** Non-price numbers — use OiFieldDisplay(type: currency) for read-only data fields.

---

#### [ADMIN] OiOrderStatusBadge
**Tags:** `order`, `status`, `badge`, `shop`
**Tier:** Component

Badge displaying order status with color coding.

**Key Parameters:**
- `status` (OiOrderStatus, required) — pending/confirmed/processing/shipped/delivered/cancelled/refunded
- `label` (String, required)
- `statusLabels` (Map<OiOrderStatus, String>?) — i18n overrides
- `statusColors` (Map<OiOrderStatus, Color>?) — Theme overrides

**Default Colors:** pending->warning, confirmed->info, processing->info, shipped->primary, delivered->success, cancelled->error, refunded->muted

**Use When:** Order lists, order detail pages.
**Combine With:** OiListView, OiDetailView, OiOrderTracker

---

### COMPONENTS — Feedback

---

#### OiReactionBar
**Tags:** `reaction`, `emoji`, `like`, `social`, `feedback`
**Tier:** Component

Emoji reaction buttons (like Discord). Shows most-used first.

**Use When:** Social reactions on messages, comments, posts.
**Combine With:** `OiChat`, `OiComments`, `OiEmojiPicker`

---

#### OiScaleRating
**Tags:** `rating`, `scale`, `1-10`, `feedback`, `nps`
**Tier:** Component

Numeric scale rating (1-10) with visual feedback.

**Use When:** NPS scores, satisfaction ratings.
**Avoid When:** Simple like/dislike — use `OiThumbs`. Star rating — use `OiStarRating`.

---

#### OiSentiment
**Tags:** `sentiment`, `feedback`, `emoji`, `happy`, `sad`, `mood`
**Tier:** Component

Sentiment input (happy/neutral/sad faces).

---

#### OiStarRating
**Tags:** `rating`, `stars`, `review`, `5-star`, `feedback`
**Tier:** Component

5-star rating input/display.

**Use When:** Product reviews, content ratings.

---

#### OiThumbs
**Tags:** `thumbs`, `like`, `dislike`, `vote`, `feedback`
**Tier:** Component

Thumbs up/down voting control.

**Use When:** Simple binary feedback.

---

### COMPONENTS — Inline Edit

---

#### OiEditable
**Tags:** `inline-edit`, `editable`, `click-to-edit`, `in-place`
**Tier:** Component

Base wrapper for inline edit patterns.

---

#### OiEditableText
**Tags:** `inline-edit`, `text`, `click-to-edit`
**Tier:** Component

Display text -> inline input on click/double-click.

**Use When:** Inline text editing in tables, lists, cards.

---

#### OiEditableDate
**Tags:** `inline-edit`, `date`, `click-to-edit`
**Tier:** Component

Display date -> date picker on click.

---

#### OiEditableNumber
**Tags:** `inline-edit`, `number`, `click-to-edit`
**Tier:** Component

Display number -> number input on click.

---

#### OiEditableSelect
**Tags:** `inline-edit`, `select`, `dropdown`, `click-to-edit`
**Tier:** Component

Display value -> dropdown on click.

---

### COMPONENTS — Inputs

---

#### OiTextInput
**Tags:** `input`, `text`, `field`, `form`, `search`, `textarea`, `otp`, `password`, `validation`
**Tier:** Component

Standard text input field with validation, OTP, password, and multiline support.

**Key Parameters:**
- `controller` (TextEditingController?)
- `label` (String?)
- `hint` (String?)
- `placeholder` (String?)
- `error` (String?)
- `leading` (Widget?)
- `trailing` (Widget?)
- `maxLines` (int?, default: 1) — Set >1 for textarea
- `minLines` (int?) — Minimum lines for multiline
- `maxLength` (int?)
- `keyboardType` (TextInputType?)
- `textInputAction` (TextInputAction?)
- `textCapitalization` (TextCapitalization, default: none)
- `textAlign` (TextAlign, default: start)
- `onChanged` (ValueChanged<String>?)
- `onSubmitted` (ValueChanged<String>?)
- `onTap` (VoidCallback?)
- `onTapOutside` (VoidCallback?)
- `enabled` (bool, default: true)
- `readOnly` (bool, default: false)
- `obscureText` (bool, default: false) — For passwords
- `autofocus` (bool, default: false)
- `inputFormatters` (List<TextInputFormatter>?)
- `focusNode` (FocusNode?)
- `validator` (String? Function(String?)?) — Form validation function
- `autovalidateMode` (AutovalidateMode?)
- `onSaved` (ValueChanged<String?>?)
- `showCounter` (bool, default: false) — Show character counter
- `counterBuilder` (Widget Function(int current, int? max)?) — Custom counter widget

**Named Constructors:**
- `OiTextInput.search()` — Pre-configured search input with search icon
- `OiTextInput.password()` — Password input with visibility toggle
- `OiTextInput.multiline(minLines:)` — Multi-line text area
- `OiTextInput.otp(length:, onCompleted:, obscure:)` — OTP/PIN code input with separate digit boxes

**Theme:** `context.components.textInput` -> `OiTextInputThemeData` (includes `validationErrorColor`, `errorAnimationDuration`, `otp` -> `OiOtpThemeData`)

**Use When:** Any text entry. Email, password, search, comments, notes, OTP codes.
**Avoid When:** Number entry — use `OiNumberInput`. Date entry — use `OiDateInput`. Dropdown — use `OiSelect`.

---

#### OiNumberInput
**Tags:** `input`, `number`, `numeric`, `stepper`, `quantity`, `amount`
**Tier:** Component

Number input with stepper, min/max, decimal places.

**Key Parameters:**
- `value` (double?)
- `onChanged` (ValueChanged<double?>?)
- `min` (double?)
- `max` (double?)
- `step` (double, default: 1)
- `decimalPlaces` (int?)
- `label` (String?)
- `hint` (String?)
- `error` (String?)
- `enabled` (bool, default: true)

**Use When:** Quantity, price, percentage, any numeric value.

---

#### OiDateInput
**Tags:** `input`, `date`, `calendar`, `picker`
**Tier:** Component

Date picker input with calendar UI.

**Use When:** Date selection (birth date, event date, deadline).

---

#### OiTimeInput
**Tags:** `input`, `time`, `clock`, `picker`
**Tier:** Component

Time picker input with hour/minute/second selection.

---

#### [ADMIN] OiDateTimeInput
**Tags:** `input`, `date`, `time`, `datetime`, `combined`
**Tier:** Component

Combined date + time input in a single form field.

**Key Parameters:**
- `label` (String, required)
- `value` (DateTime?)
- `onChange` (ValueChanged<DateTime?>?)
- `min` / `max` (DateTime?)
- `error` (String?)
- `hint` (String?)
- `required` (bool, default: false)
- `readOnly` / `disabled` (bool)

**Use When:** Scheduling, event creation, deadlines requiring both date and time.
**Avoid When:** Date-only — use OiDateInput. Time-only — use OiTimeInput.

---

#### OiSelect
**Tags:** `input`, `select`, `dropdown`, `picker`, `option`, `choice`
**Tier:** Component

Dropdown selector from options list.

**Key Parameters:**
- `options` (List<OiSelectOption<T>>, required) — Each has `value`, `label`, `enabled`
- `value` (T?)
- `onChanged` (ValueChanged<T?>?)
- `label` (String?)
- `hint` (String?)
- `error` (String?)
- `placeholder` (String?)
- `enabled` (bool, default: true)
- `searchable` (bool, default: false)
- `bottomSheetOnCompact` (bool, default: false) — Use bottom sheet on mobile

**Theme:** `context.components.select` -> `OiSelectThemeData`

**Use When:** Choosing from a predefined list of options.
**Avoid When:** Async/large option lists — use `OiComboBox`. Free-text with suggestions — use `OiTagInput`.

---

#### OiComboBox (Composite-tier, but important input)
**Tags:** `input`, `combobox`, `search`, `autocomplete`, `async`, `typeahead`
**Tier:** Composite

Searchable dropdown with async option loading, fuzzy match, virtual scroll.

**Key Parameters:**
- `label` (String, required)
- `labelOf` (String Function(T), required) — How to display each item
- `items` (List<T>, default: [])
- `value` (T?)
- `onSelect` (ValueChanged<T?>?)
- `search` (Future<List<T>> Function(String)?) — Async search
- `onCreate` (ValueChanged<String>?) — Allow creating new items
- `placeholder` (String?)
- `clearable` (bool, default: true)
- `enabled` (bool, default: true)
- `hint` (String?)
- `error` (String?)
- `multiSelect` (bool, default: false)
- `selectedValues` (List<T>, default: [])
- `onMultiSelect` (ValueChanged<List<T>>?)
- `groupBy` (String Function(T)?) — Group options
- `recentItems` (List<T>?)
- `favoriteItems` (List<T>?)
- `virtualScroll` (bool, default: false)
- `loadMore` (Future<List<T>> Function()?)
- `moreAvailable` (bool, default: false)
- `optionBuilder` (Widget Function(T)?) — Custom option rendering

**Use When:** Large option lists, async search, user/entity pickers.
**Avoid When:** Small static lists (<20 options) — use `OiSelect`.

---

#### OiCheckbox
**Tags:** `input`, `checkbox`, `toggle`, `boolean`, `check`
**Tier:** Component

Checkbox with 3-state support (unchecked/checked/indeterminate).

**Key Parameters:**
- `value` (bool?, required) — null = indeterminate
- `onChanged` (ValueChanged<bool>?)
- `label` (String?)
- `enabled` (bool, default: true)

**Theme:** `context.components.checkbox` -> `OiCheckboxThemeData`

**Use When:** Boolean fields, multi-select lists, terms acceptance.

---

#### OiSwitch
**Tags:** `input`, `switch`, `toggle`, `on-off`, `setting`
**Tier:** Component

Toggle switch (on/off).

**Key Parameters:**
- `value` (bool, required)
- `onChanged` (ValueChanged<bool>?)
- `size` (OiSwitchSize, default: medium) — small/medium/large
- `enabled` (bool, default: true)
- `label` (String?)

**Theme:** `context.components.switchTheme` -> `OiSwitchThemeData`

**Use When:** Settings toggles, enable/disable features.
**Avoid When:** Form fields — use `OiCheckbox`. Button toggle — use `OiToggleButton`.

---

#### OiRadio
**Tags:** `input`, `radio`, `choice`, `single-select`, `option`
**Tier:** Component

Radio button group for single selection.

**Key Parameters:**
- `options` (List<OiRadioOption<T>>, required) — Each has `value`, `label`, `enabled`
- `value` (T?)
- `onChanged` (ValueChanged<T>?)
- `enabled` (bool, default: true)
- `direction` (Axis, default: vertical)

**Use When:** Choosing one from 2-5 mutually exclusive options (visible at once).
**Avoid When:** Many options — use `OiSelect`. Two options — consider `OiSwitch`.

---

#### OiSlider
**Tags:** `input`, `slider`, `range`, `value`, `continuous`
**Tier:** Component

Range slider (single or dual track).

**Key Parameters:**
- `value` (double, required)
- `min` (double, required)
- `max` (double, required)
- `secondaryValue` (double?) — For range slider
- `divisions` (int?) — Discrete steps
- `onChanged` (ValueChanged<double>?)
- `onRangeChanged` (void Function(double, double)?)
- `label` (String?)
- `showLabels` (bool, default: false)
- `showTicks` (bool, default: false)
- `enabled` (bool, default: true)

**Use When:** Numeric range selection, volume, brightness.

---

#### OiTagInput
**Tags:** `input`, `tag`, `multi-value`, `chips`, `labels`
**Tier:** Component

Multi-item tag input.

**Key Parameters:**
- `tags` (List<String>, required)
- `onChanged` (ValueChanged<List<String>>?)
- `label` (String?)
- `hint` (String?)
- `error` (String?)
- `placeholder` (String?)
- `enabled` (bool, default: true)
- `maxTags` (int?)

**Use When:** Multiple text values (tags, skills, categories).

> **Note:** Planned additions include `suggestions`, `asyncSuggestions`, and `allowCustomTags` props for enhanced tag entry with autocompletion.

---

#### OiColorInput
**Tags:** `input`, `color`, `picker`, `swatch`, `palette`
**Tier:** Component

Color picker with swatch palette and hex input.

---

#### OiFileInput
**Tags:** `input`, `file`, `upload`, `attachment`, `drag-drop`
**Tier:** Component

File picker input with drag-drop zone and upload progress.

---

#### OiFormSelect
**Tags:** `select`, `dropdown`, `form`, `validation`
**Tier:** Component

Form-integrated dropdown wrapping `OiSelect` with `FormField<T>`. When `validator` is non-null the widget wraps itself in a `FormField<T>` so it participates in ancestor `Form` validation, saving, and auto-validate flows. When `validator` is null, it renders a plain `OiSelect<T>`.

**Key Parameters:**
- `options` (List\<T\>, required) — Values to choose from
- `labelOf` (String Function(T), required) — Converts value to display label
- `value` (T?) — Currently selected value
- `onChanged` (ValueChanged\<T?\>?) — Selection callback
- `validator` (String? Function(T?)?) — Form validation; enables FormField wrapping
- `onSaved` (void Function(T?)?) — Called by Form.save()
- `autovalidateMode` (AutovalidateMode?) — Controls auto-validation
- `label` (String?) — Label above the input frame
- `hint` (String?) — Hint below the input frame
- `placeholder` (String?) — Placeholder when no value selected
- `error` (String?) — Manual error (takes precedence over validator error)
- `enabled` (bool, default: true)
- `searchable` (bool, default: false) — Show search field in dropdown
- `bottomSheetOnCompact` (bool, default: false) — Bottom sheet on mobile
- `semanticLabel` (String?) — Accessibility label

**Use When:** Dropdown selection inside a `Form` that needs validation. Simplifies `OiSelect` + `FormField` boilerplate.
**Avoid When:** Standalone dropdowns without form validation -- use `OiSelect` directly. Large/async lists -- use `OiComboBox`.
**Combine With:** `OiForm`, `OiTextInput` (other form fields), `OiSelect`

---

#### OiSwitchTile
**Tags:** `switch`, `toggle`, `tile`, `settings`
**Tier:** Component

A list tile with an `OiSwitch` as its trailing widget. Tapping anywhere on the tile toggles the switch. When `enabled` is `false` the tile is rendered at reduced opacity and does not respond to taps.

**Key Parameters:**
- `title` (String, required) — Primary text content
- `value` (bool, required) — Whether the switch is on
- `onChanged` (ValueChanged\<bool\>, required) — Toggle callback
- `subtitle` (String?) — Secondary text below title
- `leading` (Widget?) — Widget at the start of the row
- `enabled` (bool, default: true)
- `dense` (bool, default: false) — Reduced vertical padding
- `contentPadding` (EdgeInsetsGeometry?) — Custom padding
- `semanticLabel` (String?) — Falls back to title

**Use When:** Settings screens, preferences, feature toggles with descriptive labels.
**Avoid When:** Bare toggle without label -- use `OiSwitch`. Form checkbox -- use `OiCheckbox`.
**Combine With:** `OiListTile`, `OiSwitch`, `OiAccordion` (as section content)

---

#### OiCheckboxTile
**Tags:** `checkbox`, `tile`, `settings`
**Tier:** Component

A list tile with an `OiCheckbox` as its trailing widget. Tapping anywhere on the tile toggles the checkbox. Supports tristate (`true`/`false`/`null`) when `tristate` is `true`.

**Key Parameters:**
- `title` (String, required) — Primary text content
- `value` (bool?) — Current state (null = indeterminate when tristate)
- `onChanged` (ValueChanged\<bool\>, required) — Toggle callback
- `tristate` (bool, default: false) — Enable 3-state cycling
- `subtitle` (String?) — Secondary text below title
- `leading` (Widget?) — Widget at the start of the row
- `enabled` (bool, default: true)
- `dense` (bool, default: false) — Reduced vertical padding
- `contentPadding` (EdgeInsetsGeometry?) — Custom padding
- `semanticLabel` (String?) — Falls back to title

**Use When:** Multi-select lists with descriptions, settings with explanatory subtitles.
**Avoid When:** Bare checkbox -- use `OiCheckbox`. Single on/off -- use `OiSwitchTile`.
**Combine With:** `OiListTile`, `OiCheckbox`, `OiForm`

---

#### OiRadioTile
**Tags:** `radio`, `tile`, `settings`, `selection`
**Tier:** Component

A list tile with an `OiRadio` indicator as its trailing widget. Tapping anywhere on the tile selects this option. Generic type `T` identifies the option value.

**Key Parameters:**
- `title` (String, required) — Primary text content
- `value` (T, required) — The value this tile represents
- `groupValue` (T?, required) — Currently selected value in the radio group
- `onChanged` (ValueChanged\<T\>, required) — Selection callback
- `subtitle` (String?) — Secondary text below title
- `leading` (Widget?) — Widget at the start of the row
- `enabled` (bool, default: true)
- `dense` (bool, default: false) — Reduced vertical padding
- `contentPadding` (EdgeInsetsGeometry?) — Custom padding
- `semanticLabel` (String?) — Falls back to title

**Use When:** Radio selection lists with descriptive labels, settings with explanatory subtitles.
**Avoid When:** Simple radio group -- use `OiRadio`. Many options -- use `OiSelect`.
**Combine With:** `OiListTile`, `OiRadio`, `OiForm`

---

#### OiSegmentedControl
**Tags:** `segmented`, `toggle`, `button-group`, `exclusive`
**Tier:** Component

An exclusive segment toggle that renders 2-5 options as connected buttons. Exactly one segment is selected at a time. Renders as a horizontal row of connected segments sharing a common border. Supports keyboard navigation (Tab to focus, arrow keys to move selection).

**Key Parameters:**
- `segments` (List\<OiSegment\<T\>\>, required) — 2-5 segment entries
- `selected` (T, required) — Currently selected segment value
- `onChanged` (ValueChanged\<T\>, required) — Selection callback
- `enabled` (bool, default: true) — Whether the entire control is interactive
- `size` (OiSegmentedControlSize, default: medium) — small(28dp)/medium(36dp)/large(44dp)
- `expand` (bool, default: false) — Equal-width segments filling available space
- `semanticLabel` (String?) — Accessibility label for the group

**Companion Models:**
- `OiSegment<T>` — `value` (T), `label` (String), `icon` (IconData?), `enabled` (bool), `semanticLabel` (String?)
- `OiSegmentedControlSize` — Enum: `small`, `medium`, `large`

**Use When:** Switching between 2-5 mutually exclusive views (Day/Week/Month, List/Grid, Tab-like toggles).
**Avoid When:** More than 5 options -- use `OiTabs` or `OiSelect`. Non-exclusive toggles -- use `OiButtonGroup`.
**Combine With:** `OiPage`, `OiSection`, `OiTabView`

---

#### OiDatePickerField
**Tags:** `date`, `picker`, `field`, `form`, `calendar`
**Tier:** Component

A date input field that displays a formatted date and opens an `OiDatePicker` dialog when tapped. Renders an `OiInputFrame` with a read-only display and trailing calendar icon. Supports form validation when `validator` is provided.

**Key Parameters:**
- `value` (DateTime?) — Currently selected date
- `onChanged` (ValueChanged\<DateTime?\>?) — Selection/clear callback
- `minDate` (DateTime?) — Earliest selectable date
- `maxDate` (DateTime?) — Latest selectable date
- `selectableDayPredicate` (bool Function(DateTime)?) — Per-day enable predicate
- `label` (String?) — Label above the input frame
- `hint` (String?) — Hint below the input frame
- `placeholder` (String?) — Placeholder text (default: 'Select date')
- `error` (String?) — Manual error (takes precedence over validator)
- `dateFormat` (String?) — Date format pattern (default: 'MMM d, yyyy')
- `clearable` (bool, default: false) — Show clear icon when value is set
- `enabled` (bool, default: true)
- `readOnly` (bool, default: false)
- `validator` (String? Function(DateTime?)?) — Form validation
- `onSaved` (void Function(DateTime?)?) — Called by Form.save()
- `autovalidateMode` (AutovalidateMode?)
- `semanticLabel` (String?)

**Use When:** Date selection in forms, filters, scheduling UIs where the field itself is a read-only display that opens a calendar dialog.
**Avoid When:** Inline date editing -- use `OiDateInput`. Inline editable cells -- use `OiEditableDate`.
**Combine With:** `OiForm`, `OiDatePicker`, `OiDateRangePickerField`, `OiTimePickerField`

---

#### OiDateRangePickerField
**Tags:** `date-range`, `picker`, `field`, `form`, `filter`
**Tier:** Component

A date range input field that opens a dialog with optional preset chips and an `OiDatePicker` in range mode. Displays the selected range formatted as "Mar 1 - Mar 23, 2026". Dialog contains preset chips (Today, Last 7 days, etc.), a calendar, and Cancel/Apply buttons.

**Key Parameters:**
- `startDate` (DateTime?) — Start of selected range
- `endDate` (DateTime?) — End of selected range
- `onChanged` (void Function(DateTime start, DateTime end)?) — Selection callback
- `minDate` (DateTime?) — Earliest selectable date
- `maxDate` (DateTime?) — Latest selectable date
- `label` (String?) — Label above the input frame
- `hint` (String?) — Hint below the input frame
- `error` (String?) — Manual error
- `dateFormat` (String?) — Date format pattern (default: 'MMM d, yyyy')
- `clearable` (bool, default: false) — Show clear icon
- `enabled` (bool, default: true)
- `presets` (List\<OiDateRangePreset\>?) — Custom presets (defaults to `OiDateRangePreset.defaults`)
- `showPresets` (bool, default: true) — Whether to show preset chips
- `validator` (String? Function((DateTime, DateTime)?)?) — Form validation
- `onSaved` (void Function((DateTime, DateTime)?)?) — Called by Form.save()
- `autovalidateMode` (AutovalidateMode?)
- `semanticLabel` (String?)

**Companion Model:**
- `OiDateRangePreset` — `label` (String), `resolve` (() => (DateTime, DateTime)), `icon` (IconData?)
  - Built-in presets: `.today`, `.last7Days`, `.last30Days`, `.thisWeek`, `.thisMonth`, `.lastMonth`, `.thisYear`
  - `.defaults` — List of all built-in presets

**Use When:** Date range filtering (reports, analytics, logs), booking date ranges.
**Avoid When:** Single date selection -- use `OiDatePickerField`. Inline date range editing -- use two `OiDateInput` widgets.
**Combine With:** `OiFilterBar`, `OiForm`, `OiDatePickerField`, `OiDatePicker`

---

#### OiTimePickerField
**Tags:** `time`, `picker`, `field`, `form`, `clock`
**Tier:** Component

A time input field that displays a formatted time and opens an `OiTimePicker` dialog when tapped. Renders an `OiInputFrame` with a read-only display and trailing clock icon. Supports 24-hour and 12-hour format.

**Key Parameters:**
- `value` (OiTimeOfDay?) — Currently selected time
- `onChanged` (ValueChanged\<OiTimeOfDay?\>?) — Selection/clear callback
- `minTime` (OiTimeOfDay?) — Earliest selectable time (reserved for future)
- `maxTime` (OiTimeOfDay?) — Latest selectable time (reserved for future)
- `minuteInterval` (int, default: 1) — Minute granularity (reserved for future)
- `label` (String?) — Label above the input frame
- `hint` (String?) — Hint below the input frame
- `placeholder` (String?) — Placeholder text (default: 'Select time')
- `error` (String?) — Manual error (takes precedence over validator)
- `use24Hour` (bool, default: true) — 24h (14:30) vs 12h (2:30 PM)
- `clearable` (bool, default: false) — Show clear icon when value is set
- `enabled` (bool, default: true)
- `validator` (String? Function(OiTimeOfDay?)?) — Form validation
- `onSaved` (void Function(OiTimeOfDay?)?) — Called by Form.save()
- `autovalidateMode` (AutovalidateMode?)
- `semanticLabel` (String?)

**Use When:** Time selection in forms, scheduling UIs where the field opens a time picker dialog.
**Avoid When:** Inline time editing -- use `OiTimeInput`. Combined date+time -- use `OiDateTimeInput`.
**Combine With:** `OiForm`, `OiTimePicker`, `OiDatePickerField`

---

#### [ADMIN] OiArrayInput
**Tags:** `input`, `array`, `repeatable`, `dynamic-fields`, `form`, `list-input`
**Tier:** Component

Repeatable form field group. Add/remove/reorder rows.

**Key Parameters:**
- `label` (String, required)
- `items` (List<T>, required)
- `itemBuilder` (Widget Function(T, int, ValueChanged<T>), required)
- `createEmpty` (T Function(), required)
- `onChange` (ValueChanged<List<T>>?)
- `reorderable` (bool, default: true)
- `addable` / `removable` (bool, default: true)
- `minItems` / `maxItems` (int?)
- `addLabel` (String, default: 'Add')
- `error` (String?)

**Use When:** Multiple addresses, phone numbers, line items, ingredients, any repeatable field group.
**Combine With:** OiForm

---

### COMPONENTS — Inputs (Admin)

---

#### [ADMIN] OiCouponInput
**Tags:** `coupon`, `discount`, `promo`, `voucher`, `shop`
**Tier:** Component

Coupon/discount code input with Apply button and success/error feedback.

**Key Parameters:**
- `label` (String, required)
- `onApply` (Future<OiCouponResult> Function(String), required) — Returns `{valid, message, discountAmount}`
- `onRemove` (VoidCallback?)
- `appliedCode` (String?)
- `loading` (bool, default: false)

**Use When:** Cart/checkout for discount codes.
**Combine With:** OiCartPanel, OiCheckout

---

### COMPONENTS — Inputs (Shop)

---

#### [SHOP] OiQuantitySelector
**Tags:** `quantity`, `stepper`, `counter`, `amount`, `shop`, `cart`
**Tier:** Component

Compact number stepper for product quantities. Minus/value/plus layout.

**Key Parameters:**
- `value` (int, required)
- `label` (String, required)
- `onChange` (ValueChanged<int>?)
- `min` (int, default: 1)
- `max` (int, default: 99)
- `compact` (bool, default: false)
- `disabled` (bool, default: false)

**Use When:** Cart item quantities, product detail add-to-cart.
**Combine With:** OiCartItemRow, OiShopProductDetail
**Avoid When:** General number input — use OiNumberInput.

---

#### [SHOP] OiAddressForm
**Tags:** `address`, `form`, `shipping`, `billing`, `location`, `shop`
**Tier:** Component

Standardized address form (name, company, address lines, city, state, postal, country, phone).

**Key Parameters:**
- `label` (String, required)
- `initialValue` (OiAddressData?)
- `onChange` (ValueChanged<OiAddressData>?)
- `onSubmit` (ValueChanged<OiAddressData>?)
- `countries` (List<OiCountryOption>?) — Each has `code`, `name`, `states`
- `showCompany` / `showPhone` / `showName` (bool, default: true)
- `readOnly` (bool, default: false)
- `error` (String?)

**Use When:** Checkout shipping/billing, user profile address.
**Combine With:** OiCheckout, OiForm

---

#### [SHOP] OiShippingMethodPicker
**Tags:** `shipping`, `delivery`, `method`, `picker`, `shop`
**Tier:** Component

Radio-style selector for shipping methods with label, price, and delivery estimate.

**Key Parameters:**
- `methods` (List<OiShippingMethod>, required) — Each has `key`, `label`, `description`, `price`, `estimatedDelivery`, `icon`
- `label` (String, required)
- `selectedKey` (Object?)
- `onSelect` (ValueChanged<OiShippingMethod>?)
- `loading` (bool, default: false)

**Use When:** Checkout shipping step.
**Combine With:** OiCheckout

---

#### [SHOP] OiPaymentMethodPicker
**Tags:** `payment`, `method`, `credit-card`, `picker`, `shop`
**Tier:** Component

Selector for payment methods (credit card, PayPal, bank transfer, saved cards).

**Key Parameters:**
- `methods` (List<OiPaymentMethod>, required) — Each has `key`, `label`, `icon`, `lastFour`, `expiryDate`, `logo`
- `label` (String, required)
- `selectedKey` (Object?)
- `onSelect` (ValueChanged<OiPaymentMethod>?)
- `addNewCard` (Widget?)

**Use When:** Checkout payment step.
**Combine With:** OiCheckout

---

### COMPONENTS — Interaction

---

#### OiSelectionOverlay
**Tags:** `selection`, `rubber-band`, `multi-select`, `lasso`
**Tier:** Component

Rubber-band selection rectangle for multi-select in list/grid.

---

### COMPONENTS — Navigation

---

#### OiAccordion
**Tags:** `accordion`, `collapse`, `expand`, `faq`, `section`
**Tier:** Component

Collapsible sections.

**Key Parameters:**
- `sections` (List<OiAccordionSection>, required) — Each has `title`, `content`, `initiallyExpanded`
- `allowMultiple` (bool, default: false)
- `settingsDriver` / `settingsKey` / `settingsNamespace` — Persistence

**Use When:** FAQ sections, settings groups, collapsible content areas.

---

#### OiBottomBar
**Tags:** `navigation`, `bottom-bar`, `mobile`, `tab-bar`, `app-bar`
**Tier:** Component

Mobile bottom navigation bar.

**Key Parameters:**
- `items` (List<OiBottomBarItem>, required) — Each has `icon`, `label`, `activeIcon`, `badgeCount`
- `currentIndex` (int, required)
- `onTap` (ValueChanged<int>, required)
- `style` (OiBottomBarStyle, default: fixed) — fixed/shifting/labeled/iconOnly
- `floatingAction` (Widget?) — FAB
- `showLabels` (bool, default: true)
- `landscapeMode` (OiBottomBarLandscapeMode, default: compact) — compact/rail/hidden

> **Note:** `OiBottomBarItem` is being superseded by `OiNavigationItem` for shared use with `OiNavigationRail` and `OiResponsiveShell`. Use `OiNavigationItem.fromLegacy()` to convert existing `OiBottomBarItem` instances.

**Use When:** Mobile app navigation (3-5 tabs).
**Avoid When:** Desktop — use `OiSidebar` or `OiTabs`. Responsive apps — use `OiResponsiveShell` instead.

---

#### OiBreadcrumbs
**Tags:** `navigation`, `breadcrumb`, `path`, `hierarchy`, `trail`
**Tier:** Component

Navigation breadcrumb trail.

**Key Parameters:**
- `items` (List<OiBreadcrumbItem>, required) — Each has `label`, `onTap`
- `separator` (String, default: '/')
- `maxVisible` (int?) — Collapse middle items if too many

**Use When:** Page hierarchy navigation. Admin pages. Detail pages.

---

#### OiDatePicker
**Tags:** `picker`, `date`, `calendar`, `month`, `year`
**Tier:** Component

Calendar UI for date selection with month/year navigation.

**Static Method:**

```dart
/// Shows date picker in dialog, returns selected date.
static Future<DateTime?> OiDatePicker.show(
  BuildContext context, {
  DateTime? initialDate,
  DateTime? minDate,
  DateTime? maxDate,
  String semanticLabel,
})
```

---

#### OiTimePicker
**Tags:** `picker`, `time`, `hours`, `minutes`
**Tier:** Component

Time selection with hours/minutes/seconds.

**Static Method:**

```dart
/// Shows time picker in dialog, returns selected time.
static Future<OiTimeOfDay?> OiTimePicker.show(
  BuildContext context, {
  OiTimeOfDay? initialTime,
  bool use24Hour,
  String semanticLabel,
})
```

---

#### OiDrawer
**Tags:** `navigation`, `drawer`, `side-panel`, `menu`, `mobile`
**Tier:** Component

Side drawer (left/right).

**Key Parameters:**
- `child` (Widget, required)
- `open` (bool, required)
- `width` (double, default: 280)
- `onClose` (VoidCallback?)

**Use When:** Mobile navigation menu.
**Avoid When:** Desktop sidebar — use `OiSidebar`. Slide-in panels — use `OiPanel` or `OiSheet`.

---

#### OiEmojiPicker
**Tags:** `picker`, `emoji`, `reaction`, `smiley`
**Tier:** Component

Emoji selector with search and category tabs.

---

#### OiTabs
**Tags:** `navigation`, `tabs`, `tab-bar`, `switch`, `view`
**Tier:** Component

Horizontal tab navigation.

**Key Parameters:**
- `tabs` (List<OiTabItem>, required) — Each has `label`, `icon`, `badge`
- `selectedIndex` (int, required)
- `onSelected` (ValueChanged<int>, required)
- `indicatorStyle` (OiTabIndicatorStyle, default: underline) — underline/filled/pill
- `scrollable` (bool, default: false)
- `content` (Widget?) — Auto-switch content per tab
- Persistence params: `settingsDriver`, `settingsKey`, `settingsNamespace`

**Theme:** `context.components.tabs` -> `OiTabsThemeData`

**Use When:** Switching between views/sections on the same page.
**Combine With:** `OiPage`, `OiSection`, `OiTabView`

---

#### OiTabView
**Tags:** `tabs`, `tab-view`, `content`, `switching`, `swipe`
**Tier:** Component

A tab bar with integrated content switching, lazy loading, and swipe support. Combines `OiTabs` (the tab bar) with a content area that displays the widget built by the selected `OiTabViewItem.builder`. Supports uncontrolled (manages own state) and controlled (parent manages state) modes.

**Key Parameters:**
- `tabs` (List\<OiTabViewItem\>, required) — Tab definitions with builders
- `initialIndex` (int, default: 0) — Initial tab for uncontrolled mode
- `onTabChanged` (ValueChanged\<int\>?) — Tab selection callback
- `indicatorStyle` (OiTabIndicatorStyle, default: underline) — underline/filled/pill
- `scrollable` (bool, default: false) — Scrollable tab bar
- `tabBarPadding` (EdgeInsetsGeometry?) — Padding around the tab bar
- `keepAlive` (bool, default: false) — Retain all tab content via IndexedStack
- `swipeable` (bool, default: true) — Horizontal swipe to switch tabs
- `animationDuration` (Duration?) — Content transition duration
- `semanticLabel` (String?) — Accessibility label

**Named Constructors:**
- `.controlled(tabs:, selectedIndex:, onTabChanged:, ...)` — Parent manages selection state

**Companion Model:**
- `OiTabViewItem` — `label` (String), `builder` (WidgetBuilder), `icon` (IconData?), `badge` (String?), `enabled` (bool)

**Use When:** Tabbed content pages where you want tab bar + content switching in one widget. Replaces manual `OiTabs` + content switching boilerplate.
**Avoid When:** Tab bar without content area -- use `OiTabs` directly. Complex page-level navigation -- use `OiBottomBar` or `OiSidebar`.
**Combine With:** `OiPage`, `OiSection`, `OiTabs`

---

#### OiNavigationRail
**Tags:** `navigation`, `rail`, `vertical`, `desktop`, `sidebar-lite`
**Tier:** Component

Compact vertical navigation rail. Lighter alternative to `OiSidebar` for apps with fewer navigation items.

**Key Parameters:**
- `items` (List<OiNavigationItem>, required) — Navigation destinations
- `currentIndex` (int, required)
- `onTap` (ValueChanged<int>, required)
- `leading` (Widget?) — Widget above items (e.g., logo)
- `trailing` (Widget?) — Widget below items (e.g., settings)
- `width` (double, default: 72)
- `labelBehavior` (OiRailLabelBehavior, default: all) — all/selected/none
- `groupAlignment` (double, default: -1.0) — Vertical alignment of items
- `backgroundColor` (Color?)
- `indicatorColor` (Color?)
- `indicatorShape` (ShapeBorder?)
- `elevation` (double?)
- `semanticLabel` (String?)

**Theme:** `context.components.navigationRail` -> `OiNavigationRailThemeData`

**Use When:** Desktop/tablet vertical navigation with 3-7 items.
**Avoid When:** Mobile — use `OiBottomBar`. Full sidebar with sections — use `OiSidebar`.
**Combine With:** `OiNavigationItem`, `OiResponsiveShell`, `OiPage`

---

#### OiSliverHeader
**Tags:** `header`, `sliver`, `sticky`, `appbar`, `scroll`, `toolbar`
**Tier:** Component

Sticky scroll header using `SliverPersistentHeaderDelegate`. Collapses/expands on scroll within `CustomScrollView`.

**Key Parameters:**
- `leading` (Widget?) — Back button or icon
- `title` (Widget?)
- `subtitle` (Widget?)
- `trailing` (Widget?)
- `actions` (List<Widget>, default: [])
- `pinned` (bool, default: true)
- `floating` (bool, default: false)
- `snap` (bool, default: false)
- `expandedHeight` (double?)
- `collapsedHeight` (double?)
- `backgroundColor` (Color?)
- `foregroundColor` (Color?)
- `elevation` (double?)
- `border` (OiBorderStyle?)
- `flexibleSpace` (Widget?) — Content shown when expanded
- `centerTitle` (bool, default: false)
- `titleSpacing` (double?)
- `toolbarHeight` (double, default: 56)
- `semanticLabel` (String?)

**Named Constructors:**
- `.simple(title:, onBack:)` — Basic header with back button
- `.large(title:, subtitle:, expandedHeight:)` — Large expanding title
- `.hero(flexibleSpace:, expandedHeight:)` — Hero image/content header

**Theme:** `context.components.sliverHeader` -> `OiSliverHeaderThemeData`

**Use When:** Scroll-aware headers in `CustomScrollView`. Detail pages with collapsing headers.
**Avoid When:** Static page headers — use `OiSection` with `OiLabel.h1()`.
**Combine With:** `OiSliverList`, `OiSliverGrid`, `OiBackButton`, `CustomScrollView`

---

#### OiBackButton
**Tags:** `back`, `navigation`, `button`, `header`
**Tier:** Component

RTL-aware back navigation button. Automatically mirrors arrow direction for right-to-left locales.

**Key Parameters:**
- `onPressed` (VoidCallback?) — Back action (defaults to Navigator.pop)
- `color` (Color?)
- `size` (double, default: 24)
- `semanticLabel` (String, default: 'Back')

**Use When:** Back navigation in headers, detail pages.
**Combine With:** `OiSliverHeader`, `OiPage`

---

#### OiPageIndicator
**Tags:** `indicator`, `dots`, `page`, `carousel`, `pagination`
**Tier:** Component

Dot indicators for paged content (carousels, onboarding, image galleries).

**Key Parameters:**
- `count` (int, required) — Total pages
- `current` (int, required) — Active page index
- `color` (Color?) — Inactive dot color
- `activeColor` (Color?) — Active dot color
- `size` (double, default: 8)
- `activeSize` (double?) — Active dot size (for asymmetric indicators)
- `spacing` (double, default: 8)
- `semanticLabel` (String?)

**Named Constructors:**
- `.pill()` — Pill-shaped active indicator instead of dot

**Use When:** Page indicators for carousels, onboarding flows, image galleries.
**Combine With:** `PageView`, `OiProductGallery`, `OiWizard`

---

#### OiScrollToTop
**Tags:** `scroll`, `fab`, `floating`, `scroll-to-top`
**Tier:** Component

Floating scroll-to-top button that appears after scrolling past a threshold.

**Key Parameters:**
- `controller` (ScrollController, required) — Scroll controller to monitor
- `child` (Widget, required) — Scrollable content
- `threshold` (double, default: 200) — Scroll offset before button appears
- `button` (Widget?) — Custom button widget
- `alignment` (Alignment, default: bottomRight)
- `padding` (EdgeInsetsGeometry?)
- `semanticLabel` (String, default: 'Scroll to top')

**Use When:** Long scrollable pages where users need quick access to the top.
**Combine With:** `OiVirtualList`, `OiPage`, `OiListView`

---

#### OiRefreshIndicator
**Tags:** `refresh`, `pull-to-refresh`, `scroll`, `loading`, `gesture`
**Tier:** Component

Pull-to-refresh wrapper using `OiProgress.circular`. Non-Material replacement for Flutter's `RefreshIndicator`.

**Key Parameters:**
- `child` (Widget, required) — Scrollable content
- `onRefresh` (Future<void> Function(), required) — Refresh callback
- `color` (Color?)
- `backgroundColor` (Color?)
- `displacement` (double, default: 40)
- `edgeOffset` (double, default: 0)
- `triggerDistance` (double, default: 100)
- `indicatorSize` (double, default: 40)
- `strokeWidth` (double?)
- `semanticLabel` (String?)
- `notificationPredicate` (bool Function(ScrollNotification)?)

**Theme:** `context.components.refreshIndicator` -> `OiRefreshIndicatorThemeData`

**Use When:** Pull-to-refresh on scrollable content.
**Avoid When:** Desktop-only apps — use a refresh button instead.
**Combine With:** `OiVirtualList`, `OiListView`, `OiPage`

---

### COMPONENTS — Navigation (Admin)

---

#### [ADMIN] OiPagination
**Tags:** `pagination`, `page`, `navigation`, `list`, `data`
**Tier:** Component

Standalone pagination control — page numbers, prev/next, per-page selector, total count. Extracted from OiTable for use outside tables.

**Key Parameters:**
- `totalItems` (int, required)
- `currentPage` (int, required)
- `label` (String, required)
- `perPage` (int, default: 25)
- `perPageOptions` (List<int>, default: [10, 25, 50, 100])
- `onPageChange` (ValueChanged<int>?)
- `onPerPageChange` (ValueChanged<int>?)
- `showPerPage` (bool, default: true)
- `showTotal` (bool, default: true)
- `showFirstLast` (bool, default: true)
- `siblingCount` (int, default: 1)
- `variant` (OiPaginationVariant, default: pages) — pages/compact

**Factory Constructors:**
- `.loadMore(loadedCount:, totalItems:, label:, onLoadMore:, loading:)` — "Load more" button variant

**Use When:** Paginated data outside OiTable (card grids, activity feeds).
**Combine With:** OiListView, OiResourcePage
**Avoid When:** Inside OiTable — use its built-in pagination.

---

#### [ADMIN] OiSortButton
**Tags:** `sort`, `order`, `ascending`, `descending`, `dropdown`
**Tier:** Component

Dropdown button for sorting non-table lists. Shows current sort field and direction.

**Key Parameters:**
- `options` (List<OiSortOption>, required) — Each has `field`, `label`, `direction`
- `currentSort` (OiSortOption, required)
- `label` (String, required)
- `onSortChange` (ValueChanged<OiSortOption>?)

**OiSortDirection enum:** asc, desc

**Use When:** Sorting card grids, activity feeds, any non-table list.
**Combine With:** OiListView, OiFilterBar
**Avoid When:** Inside OiTable — use column sort headers.

---

#### [ADMIN] OiExportButton
**Tags:** `export`, `download`, `csv`, `xlsx`, `json`, `pdf`
**Tier:** Component

Data export button. Single format = direct button. Multiple formats = split dropdown.

**Key Parameters:**
- `label` (String, required)
- `onExport` (Future<void> Function(OiExportFormat), required)
- `formats` (List<OiExportFormat>, default: [csv]) — csv/xlsx/json/pdf
- `loading` (bool, default: false)

**Use When:** Data export from tables, lists, reports.
**Combine With:** OiTable, OiListView, OiBulkBar

---

#### [ADMIN] OiThemeToggle
**Tags:** `theme`, `dark-mode`, `light-mode`, `toggle`, `switch`
**Tier:** Component

Toggle between light/dark/system theme modes. Shows sun/moon/monitor icon.

**Key Parameters:**
- `currentMode` (ThemeMode, required)
- `onModeChange` (ValueChanged<ThemeMode>, required)
- `label` (String, default: 'Toggle theme')
- `showSystemOption` (bool, default: true)

**Use When:** App header/toolbar for theme switching.
**Combine With:** OiAppShell, OiUserMenu

---

#### [ADMIN] OiUserMenu
**Tags:** `user`, `menu`, `account`, `profile`, `dropdown`, `avatar`
**Tier:** Component

Avatar-triggered dropdown with user info and actions (profile, settings, logout).

**Key Parameters:**
- `label` (String, required)
- `userName` (String, required)
- `userEmail` (String?)
- `avatarUrl` (String?)
- `avatarInitials` (String?)
- `items` (List<OiMenuItem>, required)
- `header` (Widget?)

**Use When:** Top-right user account menu in any app.
**Combine With:** OiAppShell, OiAvatar, OiMenuItem

---

#### [ADMIN] OiLocaleSwitcher
**Tags:** `locale`, `language`, `i18n`, `internationalization`, `dropdown`
**Tier:** Component

Locale dropdown with flag emoji, language name, and code.

**Key Parameters:**
- `currentLocale` (Locale, required)
- `locales` (List<OiLocaleOption>, required) — Each has `locale`, `name`, `flagEmoji`
- `onLocaleChange` (ValueChanged<Locale>, required)
- `label` (String, default: 'Language')
- `showFlag` / `showCode` / `showName` (bool)

**Use When:** Multi-language apps.
**Combine With:** OiAppShell

---

### COMPONENTS — Navigation (Shop)

---

#### [SHOP] OiProductCard
**Tags:** `product`, `card`, `shop`, `e-commerce`, `catalog`, `grid`
**Tier:** Component

Product display card with image, name, price, rating, and actions.

**Key Parameters:**
- `product` (OiProductData, required)
- `label` (String, required)
- `onTap` (VoidCallback?) — Navigate to detail
- `onAddToCart` (VoidCallback?)
- `onWishlist` (VoidCallback?)
- `showRating` / `showAddToCart` (bool, default: true)
- `showWishlist` (bool, default: false)
- `variant` (OiProductCardVariant, default: vertical) — vertical/horizontal/compact

**Factory Constructors:**
- `.horizontal()` — Image left, details right (for list views)

**Use When:** Product grids, product listings, related products.
**Combine With:** OiGrid, OiListView, OiShopProductDetail (related)

---

#### [SHOP] OiCartItemRow
**Tags:** `cart`, `item`, `line-item`, `shop`, `quantity`, `row`
**Tier:** Component

Shopping cart line item row. Thumbnail, name, variant, quantity, total, remove.

**Key Parameters:**
- `item` (OiCartItem, required)
- `label` (String, required)
- `onQuantityChange` (ValueChanged<int>?)
- `onRemove` (VoidCallback?)
- `onTap` (VoidCallback?)
- `editable` (bool, default: true)
- `compact` (bool, default: false)
- `currencyCode` (String, default: 'EUR')

**Use When:** Cart views, checkout review, order confirmation.
**Combine With:** OiCartPanel, OiMiniCart, OiCheckout

---

#### [SHOP] OiOrderSummaryLine
**Tags:** `order`, `summary`, `subtotal`, `tax`, `total`, `shop`
**Tier:** Component

Summary row with label left and amount right (subtotal, discount, shipping, tax, total).

**Key Parameters:**
- `label` (String, required)
- `amount` (double, required)
- `currencyCode` (String?)
- `bold` (bool, default: false) — For total row
- `negative` (bool, default: false) — For discounts
- `loading` (bool, default: false) — Shimmer
- `subtitle` (String?) — e.g., coupon code

**Use When:** Cart summary, order summary, checkout.
**Combine With:** OiCartPanel, OiOrderSummary, OiCheckout

---

### COMPONENTS — Overlays

---

#### OiContextMenu
**Tags:** `overlay`, `context-menu`, `right-click`, `long-press`, `menu`
**Tier:** Component

Right-click/long-press context menu.

**Companion:** `OiMenuItem` with `label`, `icon`, `onTap`, `disabled`, `separator`, `subMenu`.

**Use When:** Context-specific actions on items.
**Combine With:** `OiTable` (row context menu), `OiFileExplorer`, `OiListTile`

---

#### OiDialog
**Tags:** `overlay`, `dialog`, `modal`, `popup`, `confirm`, `alert`
**Tier:** Component

Modal dialog with variants.

**Named Constructors:**
- `OiDialog.standard(label:)` — General purpose
- `OiDialog.alert(label:)` — Alert/info
- `OiDialog.confirm(label:)` — Confirmation
- `OiDialog.form(label:)` — Form dialog
- `OiDialog.fullScreen(label:)` — Full screen

**Key Parameters (all constructors):**
- `label` (String, required) — Accessibility label
- `title` (String?)
- `content` (Widget?)
- `actions` (List<Widget>?) — Footer buttons
- `onClose` (VoidCallback?)
- `dismissible` (bool, default: true)

**Static Methods:**
```dart
// Fire-and-forget (returns OiOverlayHandle)
OiDialog.show(context, label: '...', dialog: OiDialog.confirm(...));

// Async — returns Future<T?> (recommended for getting a result back)
final result = await OiDialog.showAsync<T>(context, label: '...', title: '...', content: widget, actions: [...]);
```

**Top-level function (recommended replacement for Material's `showDialog()`):**
```dart
/// Shows a modal dialog returning Future<T?>.
Future<T?> showOiDialog<T>(
  BuildContext context, {
  required Widget Function(BuildContext, void Function([T?]) close) builder,
  bool dismissible = true,
  String? semanticLabel,
})
```

> **Note:** `showOiDialog<T>()` is the recommended replacement for Material's `showDialog()`. The builder receives a `close` callback — call `close(result)` to dismiss and return a value.

**Theme:** `context.components.dialog` -> `OiDialogThemeData`

**Use When:** User confirmation, forms, alerts, important info.
**Avoid When:** Non-blocking notifications — use `OiToast`. Side content — use `OiSheet`.

---

#### OiDialogShell
**Tags:** `dialog`, `modal`, `overlay`, `container`, `shell`
**Tier:** Component

Low-level dialog container for custom dialog layouts. Use when `OiDialog` variants are too opinionated and you need full control over dialog content.

**Key Parameters:**
- `child` (Widget, required) — Dialog content
- `width` (double?)
- `minWidth` (double?)
- `maxWidth` (double?)
- `maxHeight` (double?)
- `backgroundColor` (Color?)
- `borderRadius` (BorderRadius?)
- `elevation` (double?)
- `padding` (EdgeInsetsGeometry?)
- `semanticLabel` (String?)

**Static Methods:**
- `OiDialogShell.show<T>(context:, builder:)` — Shows dialog, returns `Future<T?>`

**Theme:** `context.components.dialogShell` -> `OiDialogShellThemeData`

**Use When:** Building fully custom dialog layouts that don't fit `OiDialog` variants.
**Avoid When:** Standard dialogs — use `OiDialog.standard()`, `.confirm()`, `.form()`, etc.
**Combine With:** Custom dialog content widgets

---

#### OiSnackBar
**Tags:** `snackbar`, `feedback`, `action`, `notification`, `overlay`
**Tier:** Component

Brief action feedback shown at bottom or top of screen. Lighter weight than `OiToast` for inline action feedback.

**Key Parameters:**
- `message` (String, required) — Feedback text
- `action` (Widget?)
- `actionLabel` (String?)
- `onAction` (VoidCallback?)
- `duration` (Duration, default: 4s)
- `onDismissed` (VoidCallback?)
- `leading` (Widget?)
- `backgroundColor` (Color?)
- `dismissible` (bool, default: true)
- `position` (OiSnackBarPosition, default: bottom) — bottom/top

**Static Methods:**
- `OiSnackBar.show(context, message:, actionLabel:, onAction:)` — Shows via overlay

**Use When:** Brief action feedback ("Item deleted", "Undo available").
**Avoid When:** Rich notifications — use `OiToast`. Critical alerts — use `OiDialog`.
**Combine With:** `OiButton`, `OiListView`

---

#### OiSheet
**Tags:** `overlay`, `sheet`, `bottom-sheet`, `side-sheet`, `panel`, `drawer`
**Tier:** Component

Bottom sheet / side sheet.

**Key Parameters:**
- `label` (String, required)
- `child` (Widget, required)
- `open` (bool, required)
- `onClose` (VoidCallback?)
- `side` (OiPanelSide, default: bottom) — top/bottom/left/right
- `size` (double?) — Height (for top/bottom) or width (for left/right)
- `dismissible` (bool, default: true)
- `dragHandle` (bool, default: false)
- `snapPoints` (List<double>?) — Snap heights for drag

**Static Methods:**

- `OiSheet.show(context, ...)` — Fire-and-forget, returns `OiOverlayHandle`
- `OiSheet.showAsync<T>(context, ...)` — Returns `Future<T?>` (new)

```dart
/// Shows sheet returning Future<T?>.
static Future<T?> OiSheet.showAsync<T>(
  BuildContext context, {
  required String label,
  required Widget Function(void Function([T?]) close) builder,
  OiPanelSide side,
  double? size,
  bool dismissible,
  bool dragHandle,
  List<double>? snapPoints,
})
```

> **Note:** Existing `OiSheet.show()` returns `OiOverlayHandle` (still available). `showAsync` is the new method for `Future<T?>` semantics.

**Theme:** `context.components.sheet` -> `OiSheetThemeData`

**Use When:** Detail panels, filters, forms on mobile.
**Avoid When:** Critical actions requiring attention — use `OiDialog`.

---

#### OiToast
**Tags:** `overlay`, `toast`, `notification`, `snackbar`, `message`, `feedback`
**Tier:** Component

Auto-dismissing notification.

**Key Parameters:**
- `message` (String, required)
- `level` (OiToastLevel, default: info) — info/success/warning/error
- `position` (OiToastPosition, default: bottomRight) — 6 positions
- `duration` (Duration, default: 4s)
- `pauseOnHover` (bool, default: true)
- `action` (Widget?) — Action button
- `onDismiss` (VoidCallback?)

**Static Method:** `OiToast.show(context, message: '...', level: OiToastLevel.success)`

**Theme:** `context.components.toast` -> `OiToastThemeData`

**Use When:** Non-blocking feedback (save success, copy confirmation, errors).
**Avoid When:** Critical info — use `OiDialog`.

---

### COMPONENTS — Panels

---

#### OiPanel
**Tags:** `panel`, `side-panel`, `slide`, `drawer`, `content`
**Tier:** Component

Slide-in panel from any side.

**Key Parameters:**
- `label` (String, required)
- `child` (Widget, required)
- `open` (bool, required)
- `onClose` (VoidCallback?)
- `side` (OiPanelSide, default: left) — top/bottom/left/right
- `size` (double?)
- `dismissible` (bool, default: true)
- `showScrim` (bool, default: false)

**Use When:** Side panels for detail views, chat, notifications.
**Avoid When:** Page navigation — use `OiSidebar`.

---

#### OiResizable
**Tags:** `panel`, `resize`, `drag`, `handle`, `adjustable`
**Tier:** Component

Resizable container with drag handles.

**Key Parameters:**
- `child` (Widget, required)
- `resizeEdges` (Set<OiResizeEdge>, default: {right, bottom, bottomRight})
- `minWidth` / `maxWidth` / `minHeight` / `maxHeight` (double?)
- `initialWidth` / `initialHeight` (double?)
- `onResized` (void Function(double, double)?)
- `handleSize` (double, default: 8)

**Use When:** User-resizable panels, editors, sidebars.

---

#### OiSplitPane
**Tags:** `panel`, `split`, `two-pane`, `divider`, `resize`
**Tier:** Component

Two-pane split layout with draggable divider.

**Key Parameters:**
- `leading` (Widget, required)
- `trailing` (Widget, required)
- `direction` (Axis, default: horizontal)
- `initialRatio` (double, default: 0.5)
- `minRatio` / `maxRatio` (double, defaults: 0.1/0.9)
- `dividerSize` (double, default: 4)
- `onRatioChanged` (void Function(double)?)
- Persistence: `settingsDriver`, `settingsKey`

**Use When:** Two-panel layouts (sidebar + content, master-detail).
**Combine With:** `OiSidebar`, `OiTable`, `OiDetailView`

---

### COMPONENTS — Toolbars (Admin)

---

#### [ADMIN] OiBulkBar
**Tags:** `bulk`, `selection`, `toolbar`, `actions`, `batch`
**Tier:** Component

Floating toolbar that appears when items are selected. Shows count and action buttons. Animates in from bottom.

**Key Parameters:**
- `selectedCount` (int, required)
- `totalCount` (int, required)
- `label` (String, required)
- `actions` (List<OiBulkAction>, required) — Each has `label`, `icon`, `onTap`, `variant`, `loading`, `confirm`
- `onSelectAll` (VoidCallback?)
- `onDeselectAll` (VoidCallback?)
- `allSelected` (bool, default: false)

**Use When:** Bulk operations on selected items (delete, export, assign).
**Combine With:** OiTable (via bulkActions prop), OiListView
**Avoid When:** Single-item actions — use OiContextMenu.

---

### COMPOSITES — Data

---

#### OiTable
**Tags:** `table`, `data-grid`, `datagrid`, `spreadsheet`, `rows`, `columns`, `sort`, `filter`, `pagination`
**Tier:** Composite

Advanced data table with virtual scroll, column operations, inline editing, bulk selection.

**Key Parameters:**
- `label` (String, required)
- `rows` (List<T>, required)
- `columns` (List<OiTableColumn<T>>, required)
- `controller` (OiTableController?)
- `selectable` (bool, default: false)
- `multiSelect` (bool, default: false)
- `rowKey` (String Function(T)?)
- `onSelectionChanged` (ValueChanged<Set<String>>?)
- `onRowTap` / `onRowDoubleTap` (void Function(T)?)
- `serverSideSort` (bool, default: false) + `onSort` callback
- `serverSideFilter` (bool, default: false) + `onFilter` callback
- `paginationMode` (OiTablePaginationMode, default: none) — none/pages/infinite/virtual
- `totalRows` (int?)
- `onLoadMore` (Future<void> Function()?)
- `pageSizeOptions` (List<int>, default: [10, 25, 50, 100])
- `showColumnManager` (bool, default: false)
- `onCellChanged` (void Function(T, String, dynamic)?) — Inline editing
- `reorderable` (bool, default: false)
- `copyable` (bool, default: false)
- `groupBy` (String Function(T)?)
- `emptyState` (Widget?)
- `loading` (bool, default: false)
- `striped` (bool, default: false)
- `dense` (bool, default: false)
- `showStatusBar` (bool, default: true)
- Persistence: `settingsDriver`, `settingsKey`, `settingsNamespace`

**OiTableColumn<T> Parameters:**
- `id` (String, required)
- `header` (String, required)
- `width` / `minWidth` / `maxWidth` (double?)
- `sortable` / `filterable` / `resizable` / `reorderable` / `hidden` / `frozen` (bool)
- `cellBuilder` (Widget Function(context, row, index)?)
- `valueGetter` (String Function(T)?)
- `comparator` (int Function(T, T)?)
- `textAlign` (TextAlign, default: start)

**OiTableController:** Manages sort state, selection, column visibility/order/widths, filters, pagination.

**Theme:** `context.components.table` -> `OiTableThemeData`

**Use When:** Tabular data display with sort/filter/pagination needs.
**Combine With:** `OiFilterBar`, `OiDetailView` (for row detail), `OiEditableText` (for inline edit)
**Avoid When:** Simple lists — use `OiListView` module.

> **Note:** Planned addition of `bulkActions` prop for integrated OiBulkBar support within the table.

---

#### OiDetailView
**Tags:** `detail`, `view`, `record`, `read-only`, `fields`, `data`, `show`, `display`
**Tier:** Composite

Read-only record detail layout using `OiFieldDisplay.pair()` in sections.

**Key Parameters:**
- `sections` (List<OiDetailSection>, required)
- `columns` (int, default: 1) — Multi-column grid
- `columnGap` (double, default: 16)
- `rowGap` (double, default: 12)
- `fieldDirection` (Axis, default: horizontal) — Label-value layout
- `labelWidth` (double?)
- `emptyText` (String, default: '---')
- `showDividers` (bool, default: true)
- `wrapInCard` (bool, default: true)
- `padding` (EdgeInsetsGeometry?)

**OiDetailSection:** `title` (String?), `description` (String?), `fields` (List<OiDetailField>)
**OiDetailField:** `label`, `value`, `type` (OiFieldType), `columnSpan`, `copyable`, formatting params (same as OiFieldDisplay)

**Use When:** Displaying object details (user profile, order info, product specs).
**Combine With:** `OiCard`, `OiButton` (for edit action), `OiBreadcrumbs`
**Avoid When:** Editing — use `OiForm`.

---

#### OiTree
**Tags:** `tree`, `hierarchy`, `expand`, `collapse`, `treeview`, `nested`
**Tier:** Composite

Hierarchical tree view with expand/collapse.

**Companion Classes:**
- `OiTreeNode<T>` — `id`, `label`, `data`, `children`, `leaf`, `icon`
- `OiTreeController` — Manages state, `multiSelect` option

**Use When:** File trees, category hierarchies, org charts.
**Combine With:** `OiSidebar`, `OiFileExplorer`

---

#### OiPaginationController
**Tags:** `pagination`, `page`, `controller`, `state`
**Tier:** Composite

State management for paginated data.

---

#### OiTableController
**Tags:** `table`, `controller`, `state`, `sort`, `filter`
**Tier:** Composite

State management for OiTable. Manages sort, selection, column state, pagination.

---

#### OiReorderableList
**Tags:** `reorder`, `drag`, `list`, `sortable`
**Tier:** Composite

A drag-to-reorder list that supports drag handles, long-press drag, keyboard reordering, and animated gap insertion. Each item is built by `itemBuilder` which receives the item, its index, and an optional drag handle widget.

**Key Parameters:**
- `items` (List\<T\>, required) — Data items to display
- `itemBuilder` (Widget Function(BuildContext, T, int, Widget?), required) — Item builder; fourth param is drag handle widget (or null)
- `onReorder` (void Function(int oldIndex, int newIndex), required) — Reorder callback
- `itemKey` (ValueKey\<Object\> Function(T)?) — Unique key extractor (defaults to index)
- `dragHandle` (bool, default: true) — Show grip icon on each item
- `longPressDrag` (bool, default: false) — Long-press to drag (when dragHandle is false)
- `axis` (Axis, default: vertical) — Scroll axis
- `padding` (EdgeInsetsGeometry?) — Padding around the list
- `separator` (Widget?) — Separator between items
- `shrinkWrap` (bool, default: false) — Use inside unbounded containers
- `onDragStart` (void Function(int)?) — Drag start callback
- `onDragEnd` (void Function(int)?) — Drag end callback
- `canReorder` (bool Function(int)?) — Per-item reorder predicate
- `semanticLabel` (String?) — Accessibility label

**Drag Modes:**
- `dragHandle: true` (default) — Grip icon initiates drag
- `dragHandle: false, longPressDrag: true` — Long-press entire item to drag
- `dragHandle: false, longPressDrag: false` — Immediate drag on entire item

**Keyboard:** Focus an item, press Space to pick up, arrow keys to move, Enter to drop, Escape to cancel.

**Use When:** User-sortable lists (task priority, playlist order, form field order).
**Avoid When:** Simple display lists -- use `OiVirtualList`. Grid reorder -- use `OiReorderable` primitive.
**Combine With:** `OiListTile`, `OiCard`, `OiDivider` (as separator)

---

### COMPOSITES — Data (Admin)

---

#### [ADMIN] OiErrorPage
**Tags:** `error`, `404`, `403`, `500`, `not-found`, `forbidden`
**Tier:** Composite

Full-page error display for HTTP error states.

**Key Parameters:**
- `title` (String, required)
- `label` (String, required)
- `description` (String?)
- `errorCode` (String?) — "404", "403", "500" shown large
- `illustration` (Widget?)
- `actionLabel` (String?)
- `onAction` (VoidCallback?)

**Factory Constructors:**
- `.notFound()` — 404 page
- `.forbidden()` — 403 page
- `.serverError()` — 500 page

**Use When:** Error routes, unauthorized access, server errors.

---

### COMPOSITES — Data (Shop)

---

#### [SHOP] OiCartPanel
**Tags:** `cart`, `shopping-cart`, `panel`, `checkout`, `shop`
**Tier:** Composite

Full cart view — item list, coupon input, order summary, checkout button.

**Key Parameters:**
- `items` (List<OiCartItem>, required)
- `summary` (OiCartSummary, required)
- `label` (String, required)
- `onQuantityChange` (void Function(OiCartItem, int)?)
- `onRemove` (ValueChanged<OiCartItem>?)
- `onApplyCoupon` (Future<OiCouponResult> Function(String)?)
- `onRemoveCoupon` / `appliedCouponCode`
- `onCheckout` / `onContinueShopping` (VoidCallback?)
- `checkoutLabel` (String, default: 'Proceed to Checkout')
- `currencyCode` (String, default: 'EUR')
- `loading` (bool, default: false)

**Use When:** Cart page or cart side panel.
**Combine With:** OiSheet (side cart), OiPage (cart page)
**Avoid When:** Compact cart preview — use OiMiniCart.

---

#### [SHOP] OiMiniCart
**Tags:** `cart`, `mini`, `preview`, `popover`, `icon`, `shop`
**Tier:** Composite

Compact cart icon with badge + popover/sheet preview.

**Key Parameters:**
- `items` (List<OiCartItem>, required)
- `summary` (OiCartSummary, required)
- `label` (String, required)
- `onViewCart` / `onCheckout` (VoidCallback?)
- `onRemove` (ValueChanged<OiCartItem>?)
- `maxVisibleItems` (int, default: 3)
- `display` (OiMiniCartDisplay, default: popover) — popover/sheet
- `currencyCode` (String, default: 'EUR')

**Use When:** Header cart icon with quick preview.
**Combine With:** OiAppShell header, OiBottomBar

---

#### [SHOP] OiOrderSummary
**Tags:** `order`, `summary`, `total`, `card`, `shop`
**Tier:** Composite

Order summary card with all line items (subtotal, discount, shipping, tax, total).

**Key Parameters:**
- `summary` (OiCartSummary, required)
- `label` (String, required)
- `items` (List<OiCartItem>?) — Expandable item list
- `showItems` (bool, default: true)
- `expandedByDefault` (bool, default: false)
- `currencyCode` (String, default: 'EUR')

**Use When:** Checkout sidebar, order confirmation.
**Combine With:** OiCheckout, OiCartPanel

---

#### [SHOP] OiProductGallery
**Tags:** `gallery`, `product`, `images`, `zoom`, `lightbox`, `shop`
**Tier:** Composite

Product image gallery with main image, thumbnails, zoom, and lightbox.

**Key Parameters:**
- `imageUrls` (List<String>, required)
- `label` (String, required)
- `initialIndex` (int, default: 0)
- `showThumbnails` (bool, default: true)
- `zoomOnHover` (bool, default: true)
- `lightboxOnTap` (bool, default: true)
- `thumbnailDirection` (Axis, default: horizontal)

**Use When:** Product detail pages.
**Combine With:** OiShopProductDetail

---

#### [SHOP] OiOrderTracker
**Tags:** `order`, `tracking`, `status`, `stepper`, `timeline`, `shop`
**Tier:** Composite

Visual order status progression tracker (pending -> confirmed -> shipped -> delivered).

**Key Parameters:**
- `currentStatus` (OiOrderStatus, required)
- `label` (String, required)
- `timeline` (List<OiOrderEvent>?) — Detailed event history
- `showTimeline` (bool, default: false)
- `statusLabels` (Map<OiOrderStatus, String>?)

**Use When:** Order detail pages, order tracking.
**Combine With:** OiDetailView, OiTimeline

---

### COMPOSITES — Dialogs

---

#### OiNameDialog
**Tags:** `dialog`, `name`, `input`, `prompt`
**Tier:** Composite

Name input dialog for creating/renaming items.

---

### COMPOSITES — Editors

---

#### OiRichEditor
**Tags:** `editor`, `rich-text`, `wysiwyg`, `formatting`, `content`
**Tier:** Composite

Rich text editor with formatting toolbar, undo/redo, keyboard shortcuts.

**Use When:** Content editing (comments, descriptions, articles).
**Combine With:** `OiMarkdown` (for display)

---

#### OiSmartInput
**Tags:** `editor`, `smart`, `syntax`, `code`, `structured`
**Tier:** Composite

Input with syntax highlighting for code/structured data.

---

### COMPOSITES — Files

---

#### OiFileDropTarget
**Tags:** `file`, `drop`, `upload`, `drag-and-drop`
**Tier:** Composite

Native OS file drop zone with visual feedback.

---

#### OiFileGridView
**Tags:** `file`, `grid`, `thumbnails`, `gallery`
**Tier:** Composite

Grid display of files with preview cards.

---

#### OiFileListView
**Tags:** `file`, `list`, `table`, `rows`
**Tier:** Composite

List display of files with sortable columns.

---

#### OiFileSidebar
**Tags:** `file`, `sidebar`, `tree`, `navigation`, `folders`
**Tier:** Composite

File explorer sidebar with folder tree and storage indicator.

---

### COMPOSITES — Forms

---

#### OiForm
**Tags:** `form`, `input`, `validation`, `submit`, `fields`, `edit`, `create`, `data-entry`
**Tier:** Composite

Dynamic form builder with validation, auto-layout, and field binding.

**Key Parameters:**
- `sections` (List<OiFormSection>, required)
- `controller` (OiFormController, required)
- `onSubmit` (ValueChanged<Map<String, dynamic>>?)
- `onCancel` (VoidCallback?)
- `autoValidate` (bool, default: false)
- `conditions` (Map<String, bool Function(Map)>?) — Conditional field visibility
- `dependencies` (Map<String, void Function(Map)>?) — Field dependencies
- `autosave` (Duration?) — Auto-save interval
- `dirtyDetection` (bool, default: true)
- `undoRedo` (bool, default: false)
- `layout` (OiFormLayout, default: vertical) — vertical/horizontal/inline

**OiFormSection:** `title`, `description`, `fields` (List<OiFormField>)

**OiFormField:**
- `key` (String, required) — Unique field identifier
- `label` (String, required)
- `type` (OiFieldType, required) — Maps to input widget
- `defaultValue` (dynamic?)
- `required` (bool, default: false)
- `validate` (String? Function(dynamic)?) — Custom validator
- `config` (Map<String, dynamic>?) — Field-specific config
- `customBuilder` (Widget Function(value, onChanged)?) — Custom widget

**OiFormController:**
- `OiFormController({initialValues})` — Constructor
- `.values` — All current values
- `.getValue<T>(key)` / `.setValue(key, value)`
- `.getError(key)` / `.setError(key, error)`
- `.isValid` / `.isDirty`
- `.reset()` / `.validate(validators)`

**Use When:** Any data entry form (create, edit, settings).
**Combine With:** `OiCard`, `OiWizard` (multi-step), `OiDialog.form()`
**Avoid When:** Read-only display — use `OiDetailView`.

> **Note:** Planned additions include `onSubmitAsync`, `onCancel`, `showCancelButton`, and `warnOnUnsavedChanges` props for enhanced form workflow.

---

#### OiWizard
**Tags:** `wizard`, `multi-step`, `workflow`, `onboarding`, `setup`
**Tier:** Composite

Multi-step form/workflow with step indicator.

**Key Parameters:**
- `steps` (List<OiWizardStep>, required)

**OiWizardStep:**
- `title` (String, required)
- `builder` (Widget Function(OiWizardContext), required)
- `subtitle` (String?)
- `icon` (IconData?)
- `validate` (bool Function(Map)?) — Step validation
- `optional` (bool, default: false)

**OiWizardContext:** Provides `values`, `currentStep`, `totalSteps`, `goNext()`, `goPrevious()`, `goToStep()`, `setValue()`.

**Use When:** Multi-step forms, setup flows, checkout processes.
**Combine With:** `OiStepper` (visual step indicator)

---

#### OiStepper
**Tags:** `stepper`, `steps`, `progress`, `indicator`, `wizard`
**Tier:** Composite

Visual step indicator (horizontal/vertical/compact).

**Key Parameters:**
- `totalSteps` (int, required)
- `currentStep` (int, required)
- `stepLabels` (List<String>?)
- `stepIcons` (List<IconData>?)
- `style` (OiStepperStyle, default: horizontal) — horizontal/vertical/compact
- `onStepTap` (ValueChanged<int>?)
- `completedSteps` (Set<int>, default: {})
- `errorSteps` (Set<int>, default: {})

**Use When:** Showing progress through a multi-step process.
**Combine With:** `OiWizard`, `OiForm`

---

#### OiFormDialog
**Tags:** `dialog`, `form`, `modal`, `validation`
**Tier:** Composite

A static-only utility for showing form dialogs with a managed lifecycle. Presents a modal dialog containing a title, custom form content, an optional error area, and cancel/submit action buttons. The dialog's state (loading, error, submit-enabled) is managed through an `OiFormDialogController` provided to the builder.

**Static Methods:**
- `OiFormDialog.showCustom<T>(context, title:, builder:, ...)` — Shows dialog, returns `Future<T?>`

**Key Parameters (showCustom):**
- `title` (String, required) — Dialog heading
- `builder` (Widget Function(OiFormDialogController\<T\>), required) — Form content builder
- `submitLabel` (String, default: 'Save') — Primary action button label
- `cancelLabel` (String, default: 'Cancel') — Cancel button label
- `dismissible` (bool, default: true) — Barrier tap to close (blocked while loading)
- `maxWidth` (double?) — Maximum dialog width
- `semanticLabel` (String?) — Accessibility label

**OiFormDialogController\<T\>:**
- `.submit(T result)` — Sets loading, then closes with result
- `.cancel()` — Closes without result
- `.setLoading(loading:)` — Toggle loading state (shows spinner on submit button)
- `.setError(String?)` — Show/clear error message
- `.setSubmitEnabled(enabled:)` — Enable/disable submit button

**Use When:** Quick create/edit dialogs with loading/error state management. CRUD forms that don't need a full page.
**Avoid When:** Complex multi-step forms -- use `OiWizard`. Full-page forms -- use `OiForm`.
**Combine With:** `OiTextInput`, `OiSelect`, `OiForm`, `OiDialogShell`

---

### COMPOSITES — Media

---

#### OiGallery
**Tags:** `gallery`, `images`, `photos`, `grid`, `lightbox`
**Tier:** Composite

Image gallery grid with thumbnails, lightbox on tap.

**Use When:** Image collections, photo albums, product images.
**Combine With:** `OiLightbox`, `OiImage`

---

#### OiImageAnnotator
**Tags:** `image`, `annotate`, `draw`, `markup`, `screenshot`
**Tier:** Composite

Image drawing tool with brush, shapes, color picker, undo/redo.

---

#### OiImageCropper
**Tags:** `image`, `crop`, `resize`, `aspect-ratio`
**Tier:** Composite

Image crop tool with aspect ratio presets.

---

#### OiLightbox
**Tags:** `lightbox`, `image`, `fullscreen`, `zoom`, `gallery`
**Tier:** Composite

Full-screen image viewer with navigation, zoom, download.

---

#### OiVideoPlayer
**Tags:** `video`, `player`, `media`, `playback`
**Tier:** Composite

Video player with play/pause, seek, volume, fullscreen.

---

### COMPOSITES — Navigation

---

#### OiSidebar
**Tags:** `sidebar`, `navigation`, `menu`, `rail`, `desktop`, `admin`
**Tier:** Composite

Application sidebar with collapsible sections, badges, icons.

**Key Parameters:**
- `sections` (List<OiSidebarSection>, required) — Each has `items`, `title`, `collapsible`
- `selectedId` (String?, required)
- `onSelect` (ValueChanged<String>, required)
- `label` (String, required)
- `mode` (OiSidebarMode, default: full) — full(260px)/compact(64px)/hidden
- `width` / `compactWidth` (double)
- `resizable` (bool, default: false)
- `header` / `footer` (Widget?)
- Persistence params

**OiSidebarItem:** `id`, `label`, `icon`, `badgeCount`, `children`, `disabled`

**Theme:** `context.components.sidebar` -> `OiSidebarThemeData`

**Use When:** Desktop app navigation, admin panels.
**Combine With:** `OiSplitPane`, `OiPage`, `OiBreadcrumbs`
**Avoid When:** Mobile — use `OiBottomBar` or `OiDrawer`.

---

#### OiFilterBar
**Tags:** `filter`, `search`, `query`, `criteria`, `faceted`
**Tier:** Composite

Advanced filter control with multiple filter types.

**Key Parameters:**
- `filters` (List<OiFilterDefinition>, required) — Each has `key`, `label`, `type`, `options`
- `activeFilters` (Map<String, OiColumnFilter>, required)
- `onFilterChange` (ValueChanged<Map<String, OiColumnFilter>>, required)
- `trailing` (Widget?)
- Persistence params

**OiFilterType:** text, select, date, dateRange, number, numberRange, custom
**OiFilterOperator:** equals, contains, greaterThan, lessThan, between

**Use When:** Data list filtering, search refinement.
**Combine With:** `OiTable`, `OiListView`

---

#### OiNavMenu
**Tags:** `navigation`, `menu`, `list`, `items`
**Tier:** Composite

Navigation menu with items, badges, reorder.

**Key Parameters:**
- `items` (List<OiNavMenuItem>, required)
- `selectedId` (String?, required)
- `onSelect` (ValueChanged<String>, required)
- `label` (String, required)
- `reorderable` (bool, default: false)
- `contextMenu` (List<OiMenuItem> Function(item)?)
- `header` / `footer` (Widget?)

---

#### OiArrowNav
**Tags:** `navigation`, `previous`, `next`, `arrow`
**Tier:** Composite

Previous/next arrow navigation for stepping through items.

---

#### OiFileToolbar
**Tags:** `toolbar`, `file`, `actions`, `breadcrumb`
**Tier:** Composite

Top toolbar for file explorer.

---

#### OiShortcuts
**Tags:** `keyboard`, `shortcuts`, `help`, `hotkeys`
**Tier:** Composite

Keyboard shortcut display and help dialog.

---

#### OiResponsiveShell
**Tags:** `responsive`, `shell`, `navigation`, `layout`, `adaptive`
**Tier:** Composite

Responsive navigation shell that auto-switches between `OiBottomBar` (mobile) and `OiNavigationRail` (tablet/desktop) based on breakpoints.

**Key Parameters:**
- `items` (List<OiNavigationItem>, required) — Navigation destinations
- `currentIndex` (int, required)
- `onTap` (ValueChanged<int>, required)
- `body` (Widget, required) — Main content
- `railLeading` (Widget?) — Leading widget for rail mode (e.g., logo)
- `railTrailing` (Widget?) — Trailing widget for rail mode (e.g., settings)
- `floatingAction` (Widget?) — FAB passed to bottom bar
- `breakpoints` (OiResponsiveShellBreakpoints?) — Custom breakpoints (default: rail at 600, expanded at 1200)

**Use When:** Apps that need adaptive navigation across mobile, tablet, and desktop.
**Avoid When:** Mobile-only apps — use `OiBottomBar`. Desktop-only — use `OiSidebar`. Admin apps — use `OiAppShell`.
**Combine With:** `OiNavigationItem`, `OiPage`, `GoRouter` shell routes

---

### COMPOSITES — Onboarding

---

#### OiTour
**Tags:** `tour`, `onboarding`, `guide`, `tutorial`, `walkthrough`
**Tier:** Composite

Interactive guided tour with spotlight highlights and tooltips.

**Use When:** First-time user onboarding, feature discovery.
**Combine With:** `OiSpotlight`

---

#### OiSpotlight
**Tags:** `spotlight`, `highlight`, `focus`, `onboarding`
**Tier:** Composite

Spotlight effect highlighting a single element.

---

#### OiWhatsNew
**Tags:** `changelog`, `updates`, `new-features`, `announcement`
**Tier:** Composite

"What's new" panel showing new features/changes.

---

### COMPOSITES — Scheduling

---

#### OiCalendar
**Tags:** `calendar`, `events`, `schedule`, `day`, `week`, `month`
**Tier:** Composite

Day/week/month event calendar with drag-to-create and drag-to-move.

**Use When:** Event scheduling, appointment booking, content calendar.
**Avoid When:** Project timelines — use `OiGantt`. Time tracking — use `OiTimeline`.

---

#### OiGantt
**Tags:** `gantt`, `timeline`, `project`, `tasks`, `planning`, `schedule`
**Tier:** Composite

Gantt chart with horizontal task bars, dependencies, zoom levels.

**Use When:** Project planning, task timelines, resource allocation.

---

#### OiScheduler
**Tags:** `scheduler`, `booking`, `time-slots`, `availability`
**Tier:** Composite

Scheduling interface with time grid and event blocks.

---

#### OiTimeline
**Tags:** `timeline`, `chronological`, `history`, `events`, `log`
**Tier:** Composite

Vertical chronological event timeline.

**Use When:** Activity logs, history views, process flows.
**Combine With:** `OiActivityFeed`, `OiRelativeTime`

---

### COMPOSITES — Search

---

#### OiCommandBar
**Tags:** `command`, `palette`, `search`, `cmd-k`, `spotlight`, `launcher`
**Tier:** Composite

Command palette (Cmd+K / Ctrl+K). Fuzzy search, keyboard shortcuts display.

**Key Parameters:**
- `commands` (List<OiCommand>, required) — Each has `id`, `label`, `description`, `icon`, `category`, `shortcut`, `onExecute`, `children`, `keywords`, `priority`
- `label` (String, required)
- `showRecent` (bool, default: true)
- `fuzzySearch` (bool, default: true)
- `previewBuilder` (Widget Function(OiCommand)?)

**Use When:** Global app search/navigation, power-user commands.

---

#### OiSearch
**Tags:** `search`, `full-page`, `results`, `query`
**Tier:** Composite

Full-page search interface with filters and results.

---

### COMPOSITES — Social

---

#### OiAvatarStack
**Tags:** `avatar`, `stack`, `group`, `team`, `users`
**Tier:** Composite

Multiple avatars stacked/overlapping with overflow count.

**Use When:** Showing team members, participants, assignees.

---

#### OiCursorPresence
**Tags:** `presence`, `cursor`, `collaboration`, `live`, `real-time`
**Tier:** Composite

Shows who is viewing/editing with colored cursors.

---

#### OiLiveRing
**Tags:** `live`, `indicator`, `pulse`, `online`, `streaming`
**Tier:** Composite

Pulsing live indicator ring (red dot + glow).

---

#### OiSelectionPresence
**Tags:** `presence`, `selection`, `collaboration`, `multi-user`
**Tier:** Composite

Shows user text selections color-coded.

---

#### OiTypingIndicator
**Tags:** `typing`, `indicator`, `chat`, `dots`, `composing`
**Tier:** Composite

"User is typing..." animated dots indicator.

**Combine With:** `OiChat`

---

### COMPOSITES — Visualization

---

#### OiFunnelChart
**Tags:** `chart`, `funnel`, `conversion`, `stages`, `pipeline`
**Tier:** Composite

Funnel chart for conversion/pipeline visualization.

---

#### OiGauge
**Tags:** `chart`, `gauge`, `speedometer`, `meter`, `value`
**Tier:** Composite

Gauge/speedometer chart with min-max range and colored zones.

---

#### OiHeatmap
**Tags:** `chart`, `heatmap`, `grid`, `density`, `correlation`
**Tier:** Composite

2D heatmap grid visualization.

---

#### OiRadarChart
**Tags:** `chart`, `radar`, `spider`, `comparison`, `multi-axis`
**Tier:** Composite

Radar/spider chart for multi-dimensional comparison.

---

#### OiSankey
**Tags:** `chart`, `sankey`, `flow`, `allocation`, `distribution`
**Tier:** Composite

Flow diagram showing weighted flows between nodes.

---

#### OiTreemap
**Tags:** `chart`, `treemap`, `hierarchy`, `proportional`, `space-filling`
**Tier:** Composite

Hierarchical rectangle treemap visualization.

---

### COMPOSITES — Workflow

---

#### OiFlowGraph
**Tags:** `workflow`, `flow`, `graph`, `nodes`, `edges`, `diagram`
**Tier:** Composite

Interactive node-edge graph editor with drag, ports, pan/zoom.

**Use When:** Workflow builders, integration pipelines, data flow diagrams.

---

#### OiPipeline
**Tags:** `workflow`, `pipeline`, `stages`, `ci-cd`, `status`
**Tier:** Composite

Linear pipeline stage visualization with status indicators.

**Use When:** CI/CD pipelines, data processing stages.

---

#### OiStateDiagram
**Tags:** `workflow`, `state-machine`, `diagram`, `states`, `transitions`
**Tier:** Composite

State machine visualization extending OiFlowGraph.

---

### MODULES — Full Features

---

#### OiListView
**Tags:** `list`, `data`, `search`, `filter`, `sort`, `pagination`, `grid`, `table`, `module`, `crud`, `admin`
**Tier:** Module

Full-featured data list with search, filters, sort, pagination, bulk actions, layout toggle.

**Key Parameters:**
- `items` (List<T>, required)
- `itemBuilder` (Widget Function(T), required)
- `itemKey` (Object Function(T), required)
- `label` (String, required)
- `searchQuery` (String?) + `onSearch` (ValueChanged<String>?)
- `filters` (List<OiFilterDefinition>?)
- `activeFilters` (Map<String, OiColumnFilter>) + `onFilterChange`
- `sortOptions` (List<OiSortOption>?) + `activeSort` + `onSort`
- `selectionMode` (OiSelectionMode, default: none) — none/single/multi
- `selectedKeys` (Set<Object>) + `onSelectionChange`
- `selectionActions` (List<Widget>?) — Bulk action buttons
- `onLoadMore` (VoidCallback?) + `moreAvailable` (bool)
- `loading` (bool, default: false)
- `emptyState` (Widget?)
- `layout` (OiListViewLayout, default: list) — list/grid/table
- `headerActions` (List<Widget>?)
- `onRefresh` (Future<void> Function()?)
- Persistence params

**Use When:** Any data list page (users, orders, products, articles).
**Combine With:** `OiFilterBar`, `OiCard`, `OiListTile`
**Avoid When:** Tabular data with column operations — use `OiTable`. Kanban-style — use `OiKanban`.

---

#### OiKanban
**Tags:** `kanban`, `board`, `columns`, `cards`, `drag-and-drop`, `project`, `status`, `workflow`, `trello`
**Tier:** Module

Kanban board with draggable cards between columns.

**Key Parameters:**
- `columns` (List<OiKanbanColumn<T>>, required) — Each has `key`, `title`, `items`, `color`
- `label` (String, required)
- `onCardMove` (void Function(T, fromCol, toCol, newIndex)?)
- `onColumnReorder` (void Function(oldIndex, newIndex)?)
- `cardBuilder` (Widget Function(T)?)
- `columnHeader` (Widget Function(OiKanbanColumn<T>)?)
- `reorderColumns` (bool, default: true)
- `wipLimits` (Map<Object, int>?) — Work-in-progress limits
- `quickEdit` (bool, default: true)
- `collapsibleColumns` (bool, default: true)
- `addColumn` (bool, default: false) + `onAddColumn`
- `cardKey` (Object Function(T)?)
- Persistence params

**Use When:** Task management, project boards, pipeline views.
**Avoid When:** Simple lists — use `OiListView`. Tabular data — use `OiTable`.

---

#### OiChat
**Tags:** `chat`, `messaging`, `real-time`, `conversation`, `im`, `inbox`, `messages`
**Tier:** Module

Real-time messaging interface.

**Key Parameters:**
- `messages` (List<OiChatMessage>, required)
- `currentUserId` (String, required)
- `label` (String, required)
- `onSend` (ValueChanged<String>?) — Send message callback
- `onAttach` (VoidCallback?) — File attachment
- `onReact` (void Function(OiChatMessage, String)?) — Emoji reaction
- `onLoadOlder` (VoidCallback?) — Load older messages
- `olderMessagesAvailable` (bool, default: false)
- `typingUsers` (List<String>?)
- `showAvatars` / `showTimestamps` (bool, default: true)
- `enableReactions` / `enableAttachments` / `enableRichText` (bool)
- `groupConsecutive` (bool, default: true)
- `consecutiveThreshold` (Duration, default: 2min)

**OiChatMessage:** `key`, `senderId`, `senderName`, `content`, `timestamp`, `senderAvatar`, `reactions`, `attachments`, `pending`

**Use When:** Messaging, customer support chat, team chat.
**Combine With:** `OiAvatar`, `OiReactionBar`, `OiTypingIndicator`

---

#### OiComments
**Tags:** `comments`, `discussion`, `thread`, `reply`, `forum`, `feedback`
**Tier:** Module

Threaded discussion with replies, reactions, edit/delete.

**Key Parameters:**
- `comments` (List<OiComment>, required) — Supports nested `replies`
- `currentUserId` (String, required)
- `label` (String, required)
- `onComment` / `onReply` / `onEdit` / `onDelete` / `onReact` callbacks
- `maxDepth` (int, default: 5)
- `showAvatars` / `showTimestamps` (bool)
- `emptyTitle` / `emptyDescription` (String)

**Use When:** Comment sections, discussions, reviews.
**Avoid When:** Real-time chat — use `OiChat`. Comments flow top-to-bottom; chat flows bottom-to-top.

---

#### OiDashboard
**Tags:** `dashboard`, `widgets`, `grid`, `kpi`, `analytics`, `overview`, `admin`
**Tier:** Module

Dashboard builder with grid layout and resizable cards.

**Key Parameters:**
- `cards` (List<OiDashboardCard>, required) — Each has `key`, `title`, `child`, `columnSpan`, `rowSpan`
- `label` (String, required)
- `columns` (int, default: 4)
- `gap` (double, default: 16)
- `editable` (bool, default: false) — Allow drag/resize
- `onLayoutChange` (ValueChanged<List<OiDashboardCard>>?)
- Persistence params

**Use When:** Admin dashboards, analytics pages, overview screens.
**Combine With:** `OiMetric`, `OiCard`, `OiProgress`, charts

---

#### OiFileExplorer
**Tags:** `file`, `explorer`, `manager`, `upload`, `download`, `folder`, `browser`, `storage`
**Tier:** Module

Complete file manager with sidebar, list/grid views, drag-drop, upload.

**Key Parameters:**
- `controller` (OiFileExplorerController, required)
- `label` (String, required)
- `loadFolder` (Future<List<OiFileNodeData>> Function(String), required)
- `loadFolderTree` (Future<List<OiTreeNode<OiFileNodeData>>> Function(String), required)
- `onCreateFolder` / `onRename` / `onDelete` / `onMove` / `onUpload` (required callbacks)
- `onCopy` / `onDownload` / `onOpen` / `onPreview` / `onShare` (optional)
- `defaultViewMode` (OiFileViewMode, default: list)
- `defaultSortField` / `defaultSortDirection`
- `quickAccess` (List<OiQuickAccessItem>?)
- `storage` (OiStorageData?)
- Feature flags: `showSidebar`, `enableUpload`, `enableDelete`, `enableRename`, `enableMove`, `enableCopy`, `enableSearch`, `enableDragDrop`, `enableMultiSelect`, `enableFavorites`, `enableKeyboardShortcuts`
- `allowedUploadExtensions` (List<String>?)
- `maxUploadFileSize` (int?)

**Theme:** `context.components.fileExplorer` -> `OiFileExplorerThemeData`

**Use When:** File management, document libraries, media libraries.

---

#### OiFileManager
**Tags:** `file`, `manager`, `operations`, `advanced`
**Tier:** Module

Advanced file operations module.

---

#### OiActivityFeed
**Tags:** `activity`, `feed`, `log`, `events`, `stream`, `history`
**Tier:** Module

Activity log display with categories.

**Key Parameters:**
- `events` (List<OiActivityEvent>, required) — Each has `key`, `title`, `description`, `timestamp`, `icon`, `category`
- `label` (String, required)
- `onEventTap` (ValueChanged<OiActivityEvent>?)
- `onLoadMore` + `moreAvailable` + `loading`
- `emptyState` (Widget?)
- `showTimestamps` (bool, default: true)
- `categories` / `activeCategory` / `onCategoryChange`

**Use When:** Activity logs, audit trails, event streams.

---

#### OiNotificationCenter
**Tags:** `notification`, `inbox`, `bell`, `alerts`, `unread`
**Tier:** Module

Notification inbox with categories, read/unread, bulk actions.

**Key Parameters:**
- `notifications` (List<OiNotification>, required) — Each has `key`, `title`, `timestamp`, `body`, `read`, `icon`, `category`
- `label` (String, required)
- `onNotificationTap` / `onMarkRead` / `onMarkAllRead` / `onSnooze` / `onDismiss` callbacks
- `groupBy` (String Function(OiNotification)?)
- `unreadCount` (int)
- `showBadge` / `realTime` (bool)

**Use When:** App notification systems.

---

#### OiMetadataEditor
**Tags:** `metadata`, `key-value`, `properties`, `tags`, `attributes`, `editor`
**Tier:** Module

Edit structured metadata (key-value pairs, tags).

---

#### OiPermissions
**Tags:** `permissions`, `roles`, `access`, `matrix`, `security`, `admin`
**Tier:** Module

Permission matrix editor (roles vs resources).

---

### MODULES — Full Features (Admin)

---

#### [ADMIN] OiAppShell
**Tags:** `app`, `shell`, `layout`, `admin`, `sidebar`, `header`, `scaffold`
**Tier:** Module

Master layout scaffold for admin apps. Sidebar + top bar + breadcrumbs + content.

**Key Parameters:**
- `child` (Widget, required) — Main content
- `label` (String, required)
- `navigation` (List<OiNavItem>, required) — Each has `label`, `icon`, `route`, `children`, `badge`, `section`
- `leading` (Widget?) — Logo area
- `title` (Widget?) — Page title
- `actions` (List<Widget>?) — Top bar right side
- `userMenu` (Widget?) — OiUserMenu
- `sidebarCollapsible` (bool, default: true)
- `sidebarDefaultCollapsed` (bool, default: false)
- `sidebarWidth` / `sidebarCollapsedWidth` (double)
- `breadcrumbs` (List<OiBreadcrumbItem>?)
- `showBreadcrumbs` (bool, default: true)
- `mobileBreakpoint` (OiBreakpoint, default: medium)

**Behavior:**
- Desktop: sidebar + top bar + content
- Mobile: drawer + hamburger + content
- Sidebar collapse animates width

**Use When:** Any admin panel or dashboard app.
**Combine With:** OiUserMenu, OiThemeToggle, OiLocaleSwitcher, OiBreadcrumbs

---

#### [ADMIN] OiResourcePage
**Tags:** `resource`, `crud`, `admin`, `list`, `show`, `edit`, `create`, `scaffold`
**Tier:** Module

CRUD page scaffold. Title + action buttons + content area + optional filters/pagination.

**Key Parameters:**
- `title` (String, required)
- `label` (String, required)
- `child` (Widget, required)
- `variant` (OiResourcePageVariant, default: list) — list/show/edit/create
- `actions` (List<Widget>?)
- `filters` (Widget?) — Filter bar (list variant)
- `pagination` (Widget?) — Bottom pagination (list variant)
- `breadcrumbs` (List<OiBreadcrumbItem>?)
- `wrapInCard` (bool, default: true)

**Variant defaults:**
- list: CreateButton in actions, filters + pagination slots
- show: EditButton + DeleteButton in actions
- edit: SaveButton + CancelButton in actions
- create: SaveButton + CancelButton in actions

**Use When:** Admin CRUD pages.
**Combine With:** OiAppShell, OiTable, OiDetailView, OiForm

---

#### [ADMIN] OiAuthPage
**Tags:** `auth`, `login`, `register`, `signup`, `password`, `authentication`
**Tier:** Module

Pre-built authentication page layouts.

**Factory Constructors:**
- `.login(label:, onLogin:, logo:, title:, subtitle:, showRememberMe:, showForgotPassword:, onForgotPassword:, onRegister:, socialLogins:, footer:)`
- `.register(label:, onRegister:, logo:, title:, onLogin:, socialLogins:, extraFields:, terms:)`
- `.forgotPassword(label:, onSubmit:, logo:, onBackToLogin:)`
- `.resetPassword(label:, onSubmit:, logo:, onBackToLogin:)`

**OiSocialLogin:** `label`, `icon`, `onTap`

**Use When:** Any app with authentication.

---

### MODULES — Full Features (Shop)

---

#### [SHOP] OiCheckout
**Tags:** `checkout`, `payment`, `order`, `wizard`, `shop`, `e-commerce`
**Tier:** Module

Complete multi-step checkout flow (address -> shipping -> payment -> review).

**Key Parameters:**
- `items` (List<OiCartItem>, required)
- `summary` (OiCartSummary, required)
- `label` (String, required)
- `steps` (List<OiCheckoutStep>, default: [address, shipping, payment, review])
- `onShippingAddressChange` / `onBillingAddressChange` (ValueChanged<OiAddressData>?)
- `onShippingMethodChange` (ValueChanged<OiShippingMethod>?)
- `onPaymentMethodChange` (ValueChanged<OiPaymentMethod>?)
- `onPlaceOrder` (Future<OiOrderData> Function(OiCheckoutData)?)
- `onCancel` (VoidCallback?)
- `initialShippingAddress` / `initialBillingAddress` (OiAddressData?)
- `shippingMethods` (List<OiShippingMethod>?)
- `paymentMethods` (List<OiPaymentMethod>?)
- `countries` (List<OiCountryOption>?)
- `showSummary` (bool, default: true) — Persistent right column on desktop
- `sameBillingDefault` (bool, default: true)
- `currencyCode` (String, default: 'EUR')
- `placeOrderLabel` (String, default: 'Place Order')

**Layout:**
- Desktop: two columns — wizard left, summary right
- Mobile: single column — collapsible summary + wizard

**Use When:** E-commerce checkout.
**Combine With:** OiCartPanel (before), OiOrderTracker (after)

---

#### [SHOP] OiShopProductDetail
**Tags:** `product`, `detail`, `shop`, `e-commerce`, `gallery`, `variants`
**Tier:** Module

Complete product detail page.

**Key Parameters:**
- `product` (OiProductData, required)
- `label` (String, required)
- `onAddToCart` (VoidCallback?)
- `onVariantChange` (ValueChanged<OiProductVariant>?)
- `onQuantityChange` (ValueChanged<int>?)
- `onWishlist` (VoidCallback?)
- `selectedVariant` (OiProductVariant?)
- `quantity` (int, default: 1)
- `description` (Widget?) — Rich description
- `reviews` (Widget?) — Reviews tab content
- `specifications` (Widget?) — Specs tab content
- `related` (List<OiProductData>?) — Related products grid

**Use When:** Product detail pages in e-commerce.
**Combine With:** OiProductGallery, OiPriceTag, OiQuantitySelector

---

## Models

### OiNavigationItem
**Tags:** `navigation`, `item`, `destination`, `model`, `rail`, `bottom-bar`

Shared navigation destination model for `OiNavigationRail`, `OiBottomBar`, and `OiResponsiveShell`.

**Fields:** `icon` (IconData, required), `label` (String, required), `activeIcon` (IconData?), `badge` (Widget?), `tooltip` (String?), `semanticLabel` (String?)

**Factory Constructors:**
- `.fromLegacy(icon:, label:, badgeCount:, showBadge:)` — Converts from old `OiBottomBarItem`

---

### OiRailLabelBehavior (Enum)
**Tags:** `navigation`, `rail`, `label`, `enum`

Controls label visibility on `OiNavigationRail`.

**Values:** `all`, `selected`, `none`

---

### OiSnackBarPosition (Enum)
**Tags:** `snackbar`, `position`, `enum`

Position for `OiSnackBar` display.

**Values:** `bottom`, `top`

---

### OiResponsiveShellBreakpoints
**Tags:** `responsive`, `breakpoint`, `shell`, `config`

Breakpoint configuration for `OiResponsiveShell`.

**Fields:** `rail` (double, default: 600) — Width at which to switch from bottom bar to rail, `expanded` (double, default: 1200) — Width at which to show expanded rail

---

### OiFieldType (Enum)
**Tags:** `field`, `type`, `form`, `display`, `enum`

Controls how forms render inputs and how `OiFieldDisplay` formats values.

**Values:** `text`, `number`, `currency`, `date`, `dateTime`, `boolean`, `email`, `url`, `phone`, `time`, `select`, `checkbox`, `switchField`, `radio`, `slider`, `color`, `file`, `image`, `tag`, `tags`, `json`, `custom`

### OiProductData
**Tags:** `product`, `shop`, `e-commerce`, `catalog`, `item`

**Fields:** `key` (Object), `name` (String), `price` (double), `description` (String?), `compareAtPrice` (double?), `currencyCode` (String, default: 'USD'), `imageUrl` (String?), `imageUrls` (List<String>), `variants` (List<OiProductVariant>), `attributes` (Map<String, String>), `inStock` (bool), `stockCount` (int?), `rating` (double?), `reviewCount` (int?), `tags` (List<String>), `sku` (String?)

### OiProductVariant
**Tags:** `variant`, `option`, `sku`, `shop`

**Fields:** `key` (Object), `label` (String), `price` (double?), `imageUrl` (String?), `inStock` (bool), `stockCount` (int?), `attributes` (Map<String, String>)

### OiCartItem
**Tags:** `cart`, `shopping`, `line-item`, `order`

**Fields:** `productKey` (Object), `variantKey` (Object?), `name` (String), `variantLabel` (String?), `unitPrice` (double), `quantity` (int, default: 1), `imageUrl` (String?), `maxQuantity` (int?), `attributes` (Map<String, String>)
**Computed:** `lineTotal` (double) — `unitPrice * quantity`

### OiCartSummary
**Tags:** `cart`, `total`, `summary`, `checkout`

**Fields:** `subtotal` (double, default: 0), `discount` (double, default: 0), `discountLabel` (String?, e.g. "SUMMER20 (-20%)"), `shipping` (double, default: 0), `shippingLabel` (String?, e.g. "Express Shipping"), `tax` (double, default: 0), `taxLabel` (String?, e.g. "VAT 20%"), `total` (double, required), `currencyCode` (String, default: 'USD')

### OiFileNodeData
**Tags:** `file`, `node`, `path`, `metadata`

Represents a file/folder node with path, name, size, dates, permissions.

### OiFileExplorerController
**Tags:** `file`, `controller`, `state`

State management for OiFileExplorer.

### Settings Models
**Tags:** `settings`, `persistence`, `state`

Persist widget state: `OiAccordionSettings`, `OiCalendarSettings`, `OiDashboardSettings`, `OiFileExplorerSettings`, `OiFilterBarSettings`, `OiGanttSettings`, `OiKanbanSettings`, `OiListViewSettings`, `OiSidebarSettings`, `OiSplitPaneSettings`, `OiTableSettings`, `OiTabsSettings`

---

### Models — Shop

---

#### [SHOP] OiShippingMethod
**Tags:** `shipping`, `delivery`, `model`, `shop`

**Fields:** `key` (Object), `label` (String), `description` (String?), `price` (double), `estimatedDelivery` (String?), `icon` (IconData?)

---

#### [SHOP] OiPaymentMethod
**Tags:** `payment`, `credit-card`, `model`, `shop`

**Fields:** `key` (Object), `label` (String), `icon` (IconData?), `lastFour` (String?), `expiryDate` (String?), `logo` (Widget?)

---

#### [SHOP] OiAddressData
**Tags:** `address`, `location`, `model`, `shop`

**Fields:** `firstName` (String?), `lastName` (String?), `company` (String?), `line1` (String), `line2` (String?), `city` (String), `state` (String?), `postalCode` (String), `country` (String), `phone` (String?)

---

#### [SHOP] OiOrderData
**Tags:** `order`, `model`, `shop`

**Fields:** `key` (Object), `orderNumber` (String), `createdAt` (DateTime), `status` (OiOrderStatus), `items` (List<OiCartItem>), `summary` (OiCartSummary), `shippingAddress` (OiAddressData?), `billingAddress` (OiAddressData?), `paymentMethod` (OiPaymentMethod?), `shippingMethod` (OiShippingMethod?), `timeline` (List<OiOrderEvent>?)

---

#### [SHOP] OiOrderEvent
**Tags:** `order`, `event`, `timeline`, `model`, `shop`

**Fields:** `timestamp` (DateTime), `title` (String), `description` (String?), `status` (OiOrderStatus)

---

#### [SHOP] OiOrderStatus (Enum)
**Tags:** `order`, `status`, `enum`, `shop`

**Values:** pending, confirmed, processing, shipped, delivered, cancelled, refunded

---

#### [SHOP] OiCouponResult
**Tags:** `coupon`, `discount`, `result`, `shop`

**Fields:** `valid` (bool), `message` (String?), `discountAmount` (double?)

---

#### [SHOP] OiCheckoutData
**Tags:** `checkout`, `data`, `model`, `shop`

**Fields:** `shippingAddress` (OiAddressData), `billingAddress` (OiAddressData), `shippingMethod` (OiShippingMethod), `paymentMethod` (OiPaymentMethod)

---

### Models — Admin

---

#### [ADMIN] OiSocialLogin
**Tags:** `auth`, `social`, `login`, `model`

**Fields:** `label` (String), `icon` (IconData), `onTap` (VoidCallback)

---

#### [ADMIN] OiCountryOption
**Tags:** `country`, `locale`, `model`

**Fields:** `code` (String), `name` (String), `states` (List<String>?)

---

#### [ADMIN] OiLocaleOption
**Tags:** `locale`, `language`, `model`

**Fields:** `locale` (Locale), `name` (String), `flagEmoji` (String?)

---

## Tools

### OiDynamicTheme
**Tags:** `theme`, `dynamic`, `runtime`, `switch`

Runtime theme modification (hot-swap themes).

### OiPlayground
**Tags:** `playground`, `sandbox`, `demo`, `testing`

Component showcase/sandbox for testing.

### OiThemeExporter
**Tags:** `theme`, `export`, `json`, `code`

Export theme as JSON or Dart code.

### OiThemePreview
**Tags:** `theme`, `preview`, `visual`

Visual theme preview interface.

---

## Utilities

### Formatters (`formatters.dart`)
**Tags:** `format`, `number`, `date`, `text`, `currency`

Number, date, and text formatting helpers.

### Color Utils (`color_utils.dart`)
**Tags:** `color`, `convert`, `hsl`, `lighten`, `darken`

Color manipulation (lighten, darken, HSL conversion).

### Calendar Utils (`calendar_utils.dart`)
**Tags:** `date`, `calendar`, `month`, `week`

Date/calendar calculation helpers.

### File Utils (`file_utils.dart`)
**Tags:** `file`, `size`, `extension`, `mime`

File system utilities (size formatting, extension detection).

### Fuzzy Search (`fuzzy_search.dart`)
**Tags:** `search`, `fuzzy`, `match`, `filter`

Fuzzy string matching for search.

### Spring Physics (`spring_physics.dart`)
**Tags:** `animation`, `spring`, `physics`

Spring physics calculations.

---

## Icons — OiIcons

Static class with 1,950+ `IconData` constants backed by [Lucide](https://lucide.dev) v0.577.0, organized by category:

- **Arrows & Navigation:** `chevronLeft`, `chevronRight`, `chevronUp`, `chevronDown`, `chevronsLeft`, `chevronsRight`, `arrowLeft`, `arrowRight`, `arrowUp`, `arrowDown`, `undo2`, `redo2`, `trendingUp`, `externalLink`
- **Actions:** `plus`, `minus`, `x`, `check`, `search`, `download`, `upload`, `copy`, `send`, `share2`, `trash2`, `squarePen`
- **Files & Folders:** `file`, `fileText`, `filePlus`, `fileCheck`, `fileSearch`, `folder`, `folderOpen`, `folderPlus`, `archive`, `clipboardList`
- **Media & Communication:** `image`, `video`, `music`, `play`, `circlePlay`, `volume2`, `mail`, `messageSquare`, `messagesSquare`, `phone`, `bell`
- **Users & People:** `user`, `users`, `userPlus`, `circleUser`
- **Status & Feedback:** `circleCheck`, `circleAlert`, `triangleAlert`, `info`, `circleHelp`, `ban`
- **Layout:** `menu`, `layoutGrid`, `columns3`, `table`, `list`, `alignJustify`, `slidersHorizontal`
- **Data & Charts:** `barChart3`, `pieChart`, `trendingUp`, `presentation`
- **Devices & Hardware:** `monitor`, `server`, `database`, `cpu`, `lock`
- **Tools & Utilities:** `settings`, `search`, `clock`, `calendar`, `calendarDays`, `paperclip`, `link`, `scissors`
- **Appearance:** `sun`, `moon`, `eye`, `eyeOff`, `sparkles`, `paintbrush`, `palette`
- **Shapes:** `star`, `heart`, `flag`, `house`, `mapPin`, `shoppingCart`, `creditCard`, `tag`, `rocket`, `zap`
- **And 1,500+ more...** — browse all at [lucide.dev](https://lucide.dev)

Always use `OiIcons.xxx` instead of `Icons.xxx` from Material.

---

## Decision Matrix

Use this table to pick the right widget for your use case.

| I need... | Use this | Not this |
|---|---|---|
| **App root** | `OiApp` / `OiApp.router` | `MaterialApp` |
| **Any text** | `OiLabel.body()` / `.h1()` / etc. | `Text()` |
| **Any icon** | `OiIcon(icon:, label:)` | `Icon()` |
| **Any layout row** | `OiRow` | `Row` |
| **Any layout column** | `OiColumn` | `Column` |
| **Any grid** | `OiGrid` | `GridView` |
| **Page wrapper** | `OiPage` | `Scaffold` |
| **Content section** | `OiSection` | `Container` with padding |
| **Button** | `OiButton.primary()` / `.secondary()` / etc. | `ElevatedButton` / `TextButton` |
| **Text input** | `OiTextInput` | `TextField` |
| **Number input** | `OiNumberInput` | `TextField` with formatter |
| **Date input** | `OiDateInput` | `showDatePicker` |
| **Date+time input** | `OiDateTimeInput` | OiDateInput + OiTimeInput separately |
| **Dropdown** | `OiSelect` (small lists) / `OiComboBox` (large/async) | `DropdownButton` |
| **Checkbox** | `OiCheckbox` | `Checkbox` |
| **Switch** | `OiSwitch` | `Switch` |
| **Radio** | `OiRadio` | `Radio` |
| **Slider** | `OiSlider` | `Slider` |
| **Repeatable fields** | `OiArrayInput` | Custom dynamic form rows |
| **Card** | `OiCard` | `Card` |
| **List item** | `OiListTile` | `ListTile` |
| **Dialog** | `OiDialog.show()` | `showDialog()` |
| **Dialog that returns a value** | `showOiDialog<T>()` or `OiDialog.showAsync<T>()` | `showDialog()` |
| **Toast** | `OiToast.show()` | `ScaffoldMessenger` / `SnackBar` |
| **Bottom sheet** | `OiSheet.show()` | `showModalBottomSheet()` |
| **Sheet that returns a value** | `OiSheet.showAsync<T>()` | `showModalBottomSheet()` |
| **Pick a date via dialog** | `OiDatePicker.show()` | `showDatePicker()` |
| **Pick a time via dialog** | `OiTimePicker.show()` | `showTimePicker()` |
| **Navigation bar** | `OiBottomBar` (mobile) / `OiNavigationRail` (tablet) / `OiSidebar` (desktop) | `BottomNavigationBar` |
| **Responsive nav shell** | `OiResponsiveShell` | Custom adaptive layout |
| **Vertical nav rail** | `OiNavigationRail` | Custom icon column |
| **Tabs** | `OiTabs` | `TabBar` |
| **Drawer** | `OiDrawer` | `Drawer` |
| **Progress** | `OiProgress` | `CircularProgressIndicator` |
| **Tooltip** | `OiTooltip` | `Tooltip` |
| **Divider** | `OiDivider` | `Divider` |
| **Image** | `OiImage` | `Image` |
| **Data table** | `OiTable` | `DataTable` |
| **Data list page** | `OiListView` (module) | Custom list + filter + sort |
| **Detail page** | `OiDetailView` + `OiFieldDisplay` | Custom layout |
| **Form** | `OiForm` | Custom form widgets |
| **Multi-step form** | `OiWizard` | Custom stepper |
| **File manager** | `OiFileExplorer` | Custom file UI |
| **Chat** | `OiChat` | Custom chat UI |
| **Comments** | `OiComments` | Custom comment thread |
| **Kanban board** | `OiKanban` | Custom drag-drop board |
| **Dashboard** | `OiDashboard` | Custom grid layout |
| **Activity log** | `OiActivityFeed` | Custom timeline |
| **Notifications** | `OiNotificationCenter` | Custom notification list |
| **Sidebar nav** | `OiSidebar` | Custom navigation |
| **Filters** | `OiFilterBar` | Custom filter widgets |
| **Command palette** | `OiCommandBar` | Custom search dialog |
| **Star rating** | `OiStarRating` | Custom star row |
| **Gantt chart** | `OiGantt` | Third-party chart lib |
| **Calendar** | `OiCalendar` | Third-party calendar |
| **Timeline** | `OiTimeline` | Custom timeline |
| **Heatmap** | `OiHeatmap` | Third-party chart |
| **Radar chart** | `OiRadarChart` | Third-party chart |
| **Funnel chart** | `OiFunnelChart` | Third-party chart |
| **Gauge** | `OiGauge` | Third-party chart |
| **Treemap** | `OiTreemap` | Third-party chart |
| **Flow diagram** | `OiFlowGraph` | Third-party graph |
| **Pipeline view** | `OiPipeline` | Custom stage display |
| **Rich text editor** | `OiRichEditor` | flutter_quill directly |
| **Code display** | `OiCodeBlock` | Custom code widget |
| **Markdown** | `OiMarkdown` | flutter_markdown directly |
| **User avatar** | `OiAvatar` | `CircleAvatar` |
| **Status badge** | `OiBadge` | `Chip` |
| **Empty state** | `OiEmptyState` | Custom empty placeholder |
| **Loading** | `OiShimmer` / `OiSkeletonGroup` / `OiProgress` | Custom loading |
| **Copy text** | `OiCopyable` / `OiCopyButton` | Custom clipboard code |
| **Inline edit** | `OiEditableText` / `OiEditableSelect` / etc. | Custom inline edit |
| **Large list** | `OiVirtualList` (>100 items) | `ListView.builder` |
| **Form dropdown with validation** | `OiFormSelect` | `OiSelect` + manual `FormField` |
| **Switch with label tile** | `OiSwitchTile` | `OiListTile` + `OiSwitch` manually |
| **Checkbox with label tile** | `OiCheckboxTile` | `OiListTile` + `OiCheckbox` manually |
| **Radio with label tile** | `OiRadioTile` | `OiListTile` + `OiRadio` manually |
| **Segmented toggle (2-5)** | `OiSegmentedControl` | `OiButtonGroup(exclusive)` |
| **Date field with dialog** | `OiDatePickerField` | `OiDateInput` + manual dialog |
| **Date range field** | `OiDateRangePickerField` | Two `OiDateInput` + custom dialog |
| **Time field with dialog** | `OiTimePickerField` | `OiTimeInput` + manual dialog |
| **Tabs with content** | `OiTabView` | `OiTabs` + manual content switching |
| **Reorderable list** | `OiReorderableList` | `OiReorderable` (primitive) |
| **Form dialog with lifecycle** | `OiFormDialog.showCustom()` | `showOiDialog` + manual state |
| **Drag to reorder** | `OiReorderable` | `ReorderableListView` |
| **Pull-to-refresh** | `OiRefreshIndicator` | `RefreshIndicator` |
| **Scroll-to-top button** | `OiScrollToTop` | Custom FAB |
| **Page dots** | `OiPageIndicator` | Custom dot row |
| **Back button** | `OiBackButton` | Custom back icon |
| **Snackbar feedback** | `OiSnackBar.show()` | `ScaffoldMessenger` |
| **Sliver list** | `OiSliverList` | `SliverList` |
| **Sliver grid** | `OiSliverGrid` | `SliverGrid` |
| **Sticky scroll header** | `OiSliverHeader` | `SliverAppBar` |
| **Custom dialog shell** | `OiDialogShell` | Custom overlay |
| **Page transitions** | `OiPageRoute` / `OiTransitionPage` | `MaterialPageRoute` |
| **OTP input** | `OiTextInput.otp()` | Custom pin boxes |
| **Password input** | `OiTextInput.password()` | `TextField(obscure)` |
| **Swipe actions** | `OiSwipeable` | `Dismissible` |
| **Onboarding tour** | `OiTour` + `OiSpotlight` | Custom spotlight |
| **Metrics/KPI** | `OiMetric` | Custom number display |
| **User menu** | `OiUserMenu` | Custom avatar menu |
| **Admin app layout** | `OiAppShell` | Custom sidebar + header |
| **CRUD list page** | `OiResourcePage(variant: list)` | Custom page layout |
| **CRUD detail page** | `OiResourcePage(variant: show)` + `OiDetailView` | Custom detail layout |
| **CRUD edit page** | `OiResourcePage(variant: edit)` + `OiForm` | Custom form page |
| **Login page** | `OiAuthPage.login()` | Custom login form |
| **Register page** | `OiAuthPage.register()` | Custom register form |
| **Error page** | `OiErrorPage.notFound()` / `.forbidden()` | Custom error layout |
| **Standalone pagination** | `OiPagination` | Custom page buttons |
| **Bulk actions** | `OiBulkBar` | Custom selection toolbar |
| **Sort dropdown** | `OiSortButton` | Custom sort UI |
| **Data export** | `OiExportButton` | Custom export logic |
| **Theme toggle** | `OiThemeToggle` | Custom theme switch |
| **User account menu** | `OiUserMenu` | Custom avatar menu |
| **Language switcher** | `OiLocaleSwitcher` | Custom locale picker |
| **Product card** | `OiProductCard` | Custom product display |
| **Product detail page** | `OiShopProductDetail` | Custom product page |
| **Shopping cart** | `OiCartPanel` | Custom cart UI |
| **Mini cart preview** | `OiMiniCart` | Custom cart popover |
| **Checkout flow** | `OiCheckout` | Custom checkout wizard |
| **Price display** | `OiPriceTag` | OiLabel + manual formatting |
| **Quantity selector** | `OiQuantitySelector` | OiNumberInput |
| **Cart line item** | `OiCartItemRow` | Custom cart row |
| **Order summary** | `OiOrderSummary` | Custom summary layout |
| **Coupon input** | `OiCouponInput` | Custom code input |
| **Address form** | `OiAddressForm` | Custom address fields |
| **Shipping picker** | `OiShippingMethodPicker` | Custom radio list |
| **Payment picker** | `OiPaymentMethodPicker` | Custom payment selector |
| **Order status** | `OiOrderStatusBadge` | OiBadge with manual colors |
| **Order tracking** | `OiOrderTracker` | OiStepper manually |
| **Product gallery** | `OiProductGallery` | Custom image carousel |

---

## Best Practices

1. **Always wrap your app in `OiApp`** — it provides theme, overlays, undo, accessibility, and platform detection.
2. **Use `OiThemeData.fromBrand(color:)` for quick branding** — generates a complete color palette.
3. **Never hardcode colors** — always `context.colors.x`.
4. **Never use `Text()`** — always `OiLabel.variant()`.
5. **Never use `Row`/`Column`/`GridView`** — use `OiRow`/`OiColumn`/`OiGrid` with breakpoint.
6. **Provide `label`/`semanticLabel` on all interactive elements** — it's an accessibility requirement.
7. **Use modules when available** — `OiListView`, `OiKanban`, `OiChat` etc. save hundreds of lines.
8. **Use `OiFieldDisplay` for read-only data** — it handles formatting (dates, currencies, booleans).
9. **Use `OiForm` for data entry** — it handles validation, layout, and field rendering.
10. **Use `OiDetailView` for record details** — it formats and lays out fields in sections.
11. **Persist user preferences** — pass `settingsDriver` to widgets that support it.
12. **Use `OiVirtualList`/`OiVirtualGrid` for lists > 100 items** — prevents performance issues.
13. **Respect density** — use `OiDensityScope.of(context)` when sizing custom components.
14. **Test at all 5 breakpoints** — compact, medium, expanded, large, extraLarge.
15. **Provide both light and dark themes** when customizing colors.

16. **Returning values from dialogs:**
Use `showOiDialog<T>()` or `OiDialogShell.show<T>()` instead of Material's `showDialog()`.
The builder receives a `close` callback — call `close(result)` to dismiss and return a value.

```dart
final confirmed = await showOiDialog<bool>(context, builder: (ctx, close) {
  return Column(children: [
    OiLabel.body('Are you sure?'),
    OiButton.primary(label: 'Yes', onTap: () => close(true)),
    OiButton.ghost(label: 'No', onTap: () => close(false)),
  ]);
});
```

## Anti-Patterns

1. **DO NOT import `material.dart`** — obers_ui replaces Material entirely.
2. **DO NOT use `Scaffold`, `AppBar`, `BottomNavigationBar`** — use `OiPage`, custom headers, `OiBottomBar`.
3. **DO NOT hardcode colors** (`Colors.blue`, `Color(0xFF...)`) — use `context.colors`.
4. **DO NOT use `Text()` widget** — use `OiLabel`.
5. **DO NOT use `Icon()` widget** — use `OiIcon`.
6. **DO NOT use `Row`/`Column` directly** — use `OiRow`/`OiColumn` for responsive gap/collapse.
7. **DO NOT wrap inputs in `OiSurface` manually** — styled inputs handle their own frame.
8. **DO NOT create custom hover/focus effects** — rely on `OiTappable` and `OiEffectsTheme`.
9. **DO NOT hardcode safe area padding** — use platform-aware layout primitives.
10. **DO NOT build custom list/filter/sort UI** when `OiListView` module exists.
11. **DO NOT build custom form validation** when `OiForm` handles it.
12. **DO NOT build custom file management UI** when `OiFileExplorer` exists.
13. **DO NOT ignore the widget's `enabled` parameter** — always pass it for disabled states.
14. **DO NOT use `Icons.x`** — use `OiIcons.x`.

---

## Tags Index

Searchable keyword -> widget mapping for quick lookup.

| Tag | Widgets |
|---|---|
| `accordion` | OiAccordion |
| `action` | OiButton, OiIconButton, OiContextMenu |
| `activity` | OiActivityFeed, OiTimeline |
| `address` | OiAddressForm, OiAddressData |
| `admin` | OiListView, OiDashboard, OiSidebar, OiFilterBar, OiAppShell, OiResourcePage, OiAuthPage |
| `alert` | OiDialog.alert, OiToast |
| `adaptive` | OiResponsiveShell |
| `animation` | OiAnimatedList, OiMorph, OiPulse, OiShimmer, OiSpring, OiStagger, OiPageTransitionType |
| `app` | OiApp |
| `appbar` | OiSliverHeader |
| `auth` | OiAuthPage, OiSocialLogin |
| `avatar` | OiAvatar, OiAvatarStack |
| `back` | OiBackButton |
| `badge` | OiBadge, OiBottomBar |
| `billing` | OiAddressForm, OiCheckout |
| `board` | OiKanban |
| `boolean` | OiCheckbox, OiSwitch, OiFieldDisplay(boolean) |
| `breadcrumb` | OiBreadcrumbs, OiPathBar |
| `bulk` | OiBulkBar |
| `button` | OiButton, OiButtonGroup, OiIconButton, OiToggleButton |
| `button-group` | OiButtonGroup, OiSegmentedControl |
| `calendar` | OiCalendar, OiDatePicker, OiDateInput, OiDatePickerField |
| `carousel` | OiPageIndicator |
| `card` | OiCard, OiDashboardCard, OiFileGridCard |
| `cart` | OiCartItem, OiCartSummary, OiCartPanel, OiMiniCart, OiCartItemRow, OiQuantitySelector |
| `chart` | OiFunnelChart, OiGauge, OiHeatmap, OiRadarChart, OiSankey, OiTreemap |
| `chat` | OiChat, OiChatMessage, OiTypingIndicator |
| `checkbox` | OiCheckbox, OiCheckboxTile |
| `checkout` | OiCheckout, OiCheckoutData |
| `clipboard` | OiCopyButton, OiCopyable, OiPasteZone, OiLabel.copyable |
| `clock` | OiTimePickerField, OiTimePicker |
| `code` | OiCodeBlock, OiLabel.code, OiDiffView |
| `collapse` | OiAccordion, OiCard(collapsible) |
| `color` | OiColorInput, OiColorScheme, OiColorSwatch |
| `column` | OiColumn, OiTableColumn |
| `combobox` | OiComboBox |
| `command` | OiCommandBar |
| `comment` | OiComments |
| `confirm` | OiButton.confirm, OiDialog.confirm, OiDeleteDialog |
| `container` | OiContainer, OiSurface, OiSurface.transparent, OiCard, OiDialogShell |
| `content` | OiTabView |
| `context-menu` | OiContextMenu |
| `copy` | OiCopyButton, OiCopyable, OiFieldDisplay(copyable), OiLabel.copyable |
| `coupon` | OiCouponInput, OiCouponResult |
| `crud` | OiListView, OiForm, OiDetailView, OiResourcePage |
| `currency` | OiFieldDisplay(currency), OiNumberInput |
| `dashboard` | OiDashboard, OiMetric |
| `data` | OiTable, OiDetailView, OiListView, OiFieldDisplay |
| `date` | OiDateInput, OiDatePicker, OiDatePicker.show, OiDatePickerField, OiDateRangePickerField, OiFieldDisplay(date) |
| `date-picker` | OiDatePicker, OiDatePicker.show, OiDatePickerField |
| `date-range` | OiDateRangePickerField, OiDateRangePreset |
| `delete` | OiDeleteDialog, OiButton.destructive |
| `delivery` | OiShippingMethod, OiShippingMethodPicker |
| `detail` | OiDetailView, OiFieldDisplay |
| `destination` | OiNavigationItem |
| `dialog` | OiDialog, OiDialog.showAsync, showOiDialog, OiDialogShell, OiDeleteDialog, OiNameDialog, OiRenameDialog, OiFormDialog |
| `dots` | OiPageIndicator |
| `diff` | OiDiffView |
| `divider` | OiDivider |
| `drag` | OiDraggable, OiReorderable, OiReorderableList, OiDragGhost |
| `drag-and-drop` | OiDraggable, OiDropZone, OiReorderable, OiDragGhost |
| `drawer` | OiDrawer |
| `dropdown` | OiSelect, OiComboBox, OiButton.split, OiFormSelect |
| `e-commerce` | OiCheckout, OiShopProductDetail, OiProductCard, OiPriceTag |
| `editor` | OiRichEditor, OiSmartInput |
| `email` | OiFieldDisplay(email), OiTextInput |
| `emoji` | OiEmojiPicker, OiReactionBar |
| `empty` | OiEmptyState |
| `error-page` | OiErrorPage |
| `explorer` | OiFileExplorer |
| `export` | OiThemeExporter, OiExportButton |
| `feed` | OiActivityFeed |
| `feedback` | OiStarRating, OiScaleRating, OiThumbs, OiSentiment, OiReactionBar |
| `elevated` | OiSurface.elevated |
| `exclusive` | OiSegmentedControl, OiButtonGroup(exclusive) |
| `field` | OiFieldDisplay, OiFormField, OiDetailField, OiDatePickerField, OiDateRangePickerField, OiTimePickerField |
| `file` | OiFileExplorer, OiFileInput, OiFileIcon, OiFileTile, OiFileGridCard |
| `filter` | OiFilterBar, OiListView, OiTable, OiDateRangePickerField |
| `flow` | OiFlowGraph, OiStateDiagram |
| `folder` | OiFolderIcon, OiFolderTreeItem, OiNewFolderDialog |
| `form` | OiForm, OiFormField, OiFormSection, OiWizard, OiFormSelect, OiFormDialog, OiDatePickerField, OiDateRangePickerField, OiTimePickerField |
| `funnel` | OiFunnelChart |
| `future` | showOiDialog, OiDialog.showAsync, OiSheet.showAsync, OiDatePicker.show, OiTimePicker.show |
| `gallery` | OiGallery, OiLightbox, OiProductGallery |
| `gantt` | OiGantt |
| `gauge` | OiGauge |
| `floating` | OiScrollToTop |
| `gesture` | OiTappable, OiSwipeable, OiDoubleTap, OiLongPressMenu, OiPinchZoom, OiRefreshIndicator |
| `go-router` | OiTransitionPage |
| `graph` | OiFlowGraph |
| `grid` | OiGrid, OiMasonry, OiVirtualGrid, OiFileGridView |
| `group` | OiButtonGroup, OiAccordion, OiFormSection |
| `header` | OiSliverHeader |
| `heading` | OiLabel.h1, .h2, .h3, .h4 |
| `heatmap` | OiHeatmap |
| `hierarchy` | OiTree, OiFolderTreeItem, OiTreemap |
| `i18n` | OiLocaleSwitcher, OiLocaleOption |
| `icon` | OiIcon, OiIconButton, OiFileIcon, OiFolderIcon |
| `image` | OiImage, OiAvatar, OiGallery, OiLightbox, OiImageCropper, OiImageAnnotator |
| `indicator` | OiProgress, OiLiveRing, OiPulse, OiStorageIndicator, OiPageIndicator |
| `inline-edit` | OiEditable, OiEditableText, OiEditableSelect, OiEditableDate, OiEditableNumber |
| `input` | OiTextInput, OiNumberInput, OiDateInput, OiTimeInput, OiDateTimeInput, OiSelect, OiFormSelect, OiComboBox, OiCheckbox, OiSwitch, OiRadio, OiSlider, OiTagInput, OiColorInput, OiFileInput, OiArrayInput, OiDatePickerField, OiDateRangePickerField, OiTimePickerField |
| `lazy` | OiSliverList, OiSliverGrid, OiVirtualList |
| `kanban` | OiKanban |
| `keyboard` | OiShortcutScope, OiShortcuts, OiCommandBar, OiFocusTrap |
| `kpi` | OiMetric |
| `label` | OiLabel |
| `layout` | OiRow, OiColumn, OiGrid, OiPage, OiSection, OiMasonry, OiWrapLayout, OiSpacer |
| `lightbox` | OiLightbox |
| `list` | OiListView, OiListTile, OiVirtualList, OiAnimatedList |
| `live` | OiLiveRing, OiCursorPresence, OiSelectionPresence |
| `loading` | OiProgress, OiShimmer, OiSkeletonGroup, OiButton(loading), OiRefreshIndicator |
| `log` | OiActivityFeed, OiTimeline |
| `login` | OiAuthPage.login |
| `markdown` | OiMarkdown |
| `media` | OiVideoPlayer, OiGallery, OiLightbox, OiImageCropper, OiImageAnnotator |
| `menu` | OiNavMenu, OiContextMenu, OiBottomBar, OiSidebar |
| `message` | OiChat, OiChatMessage, OiToast |
| `metadata` | OiMetadataEditor, OiFileInfoDialog |
| `metric` | OiMetric |
| `modal` | OiDialog, OiDialogShell, OiFocusTrap |
| `navigation` | OiSidebar, OiBottomBar, OiNavigationRail, OiTabs, OiBreadcrumbs, OiDrawer, OiNavMenu, OiResponsiveShell, OiPageRoute, OiTransitionPage, OiBackButton, OiNavigationItem |
| `notification` | OiNotificationCenter, OiToast |
| `number` | OiNumberInput, OiFieldDisplay(number) |
| `onboarding` | OiTour, OiSpotlight, OiWhatsNew |
| `order` | OiCartItem, OiCartSummary, OiProductData, OiOrderData, OiOrderEvent, OiOrderStatus, OiOrderStatusBadge, OiOrderSummary, OiOrderSummaryLine, OiOrderTracker |
| `otp` | OiTextInput.otp |
| `overlay` | OiDialog, OiDialogShell, OiToast, OiSnackBar, OiSheet, OiContextMenu, OiPopover, OiPanel |
| `page` | OiPageRoute, OiTransitionPage, OiPageIndicator |
| `pagination` | OiPaginationController, OiTable, OiListView, OiPagination, OiPageIndicator |
| `password` | OiTextInput.password |
| `panel` | OiPanel, OiResizable, OiSplitPane |
| `path` | OiPathBar, OiBreadcrumbs |
| `payment` | OiPaymentMethod, OiPaymentMethodPicker |
| `permission` | OiPermissions |
| `phone` | OiFieldDisplay(phone) |
| `picker` | OiDatePicker, OiDatePicker.show, OiTimePicker, OiTimePicker.show, OiEmojiPicker, OiColorInput, OiDatePickerField, OiDateRangePickerField, OiTimePickerField |
| `pipeline` | OiPipeline |
| `pinned` | OiSliverHeader |
| `popover` | OiPopover |
| `pull-to-refresh` | OiRefreshIndicator |
| `presence` | OiAvatar(presence), OiCursorPresence, OiLiveRing |
| `price` | OiPriceTag |
| `product` | OiProductData, OiProductVariant, OiProductCard, OiProductGallery, OiShopProductDetail |
| `progress` | OiProgress, OiStepper |
| `quantity` | OiQuantitySelector |
| `radar` | OiRadarChart |
| `rail` | OiNavigationRail, OiRailLabelBehavior |
| `radio` | OiRadio, OiRadioTile |
| `refresh` | OiRefreshIndicator |
| `rating` | OiStarRating, OiScaleRating |
| `reaction` | OiReactionBar |
| `register` | OiAuthPage.register |
| `reorder` | OiReorderable, OiReorderableList, OiKanban |
| `resize` | OiResizable, OiSplitPane |
| `resource` | OiResourcePage |
| `responsive` | OiResponsive, OiBreakpoint, OiGrid, OiPage, OiResponsiveShell, OiSliverGrid |
| `route` | OiPageRoute, OiTransitionPage, OiPageTransitionType |
| `rich-text` | OiRichEditor, OiMarkdown |
| `row` | OiRow, OiListTile |
| `sankey` | OiSankey |
| `schedule` | OiCalendar, OiGantt, OiScheduler |
| `scroll` | OiVirtualList, OiVirtualGrid, OiInfiniteScroll, OiScrollbar, OiSliverList, OiSliverGrid, OiSliverHeader, OiScrollToTop, OiRefreshIndicator |
| `scroll-to-top` | OiScrollToTop |
| `shell` | OiAppShell, OiResponsiveShell, OiDialogShell |
| `sidebar-lite` | OiNavigationRail |
| `search` | OiSearch, OiComboBox, OiCommandBar, OiFilterBar, OiTextInput.search |
| `segmented` | OiSegmentedControl |
| `select` | OiSelect, OiComboBox, OiRadio, OiFormSelect |
| `selection` | OiRadioTile, OiSegmentedControl |
| `settings` | OiSettingsDriver, OiAccordionSettings, OiSwitchTile, OiCheckboxTile, OiRadioTile, etc. |
| `sheet` | OiSheet, OiSheet.showAsync |
| `show-dialog` | showOiDialog, OiDialog.showAsync, OiDialogShell.show |
| `shipping` | OiShippingMethod, OiShippingMethodPicker |
| `shop` | OiProductData, OiCartItem, OiCartSummary, OiPriceTag, OiQuantitySelector, OiProductCard, OiCartItemRow, OiOrderSummaryLine, OiCouponInput, OiAddressForm, OiShippingMethodPicker, OiPaymentMethodPicker, OiOrderStatusBadge, OiCartPanel, OiMiniCart, OiOrderSummary, OiProductGallery, OiOrderTracker, OiCheckout, OiShopProductDetail |
| `sidebar` | OiSidebar, OiFileSidebar |
| `skeleton` | OiSkeletonGroup, OiShimmer |
| `sliver` | OiSliverList, OiSliverGrid, OiSliverHeader |
| `slider` | OiSlider |
| `snackbar` | OiSnackBar |
| `social` | OiChat, OiComments, OiReactionBar, OiAvatarStack |
| `sort` | OiTable, OiListView, OiFilterBar, OiSortButton |
| `split` | OiSplitPane, OiButton.split |
| `state-diagram` | OiStateDiagram |
| `stepper` | OiStepper, OiWizard |
| `sticky` | OiSliverHeader |
| `storage` | OiStorageIndicator, OiSettingsDriver |
| `surface` | OiSurface, OiSurface.transparent, OiSurface.elevated |
| `switch` | OiSwitch, OiSwitchTile |
| `switching` | OiTabView |
| `swipe` | OiTabView, OiSwipeable |
| `tab` | OiTabs, OiTabView |
| `tab-view` | OiTabView |
| `table` | OiTable, OiTableColumn, OiTableController |
| `tag` | OiTagInput, OiBadge |
| `text` | OiLabel, OiLabel.copyable, OiTextInput |
| `theme` | OiThemeData, OiColorScheme, OiDynamicTheme, OiThemePreview, OiThemeToggle |
| `thumbs` | OiThumbs |
| `tile` | OiSwitchTile, OiCheckboxTile, OiRadioTile, OiListTile |
| `time` | OiTimeInput, OiTimePicker, OiTimePicker.show, OiTimePickerField, OiRelativeTime |
| `time-picker` | OiTimePicker, OiTimePicker.show, OiTimePickerField |
| `timeline` | OiTimeline, OiGantt |
| `toast` | OiToast |
| `toggle` | OiToggleButton, OiSwitch, OiCheckbox, OiSwitchTile, OiSegmentedControl |
| `transparent` | OiSurface.transparent |
| `toolbar` | OiButtonGroup, OiFileToolbar, OiSliverHeader |
| `transition` | OiPageRoute, OiTransitionPage, OiPageTransitionType |
| `tooltip` | OiTooltip |
| `tour` | OiTour, OiSpotlight |
| `tracking` | OiOrderTracker |
| `tree` | OiTree, OiFolderTreeItem, OiTreemap |
| `treemap` | OiTreemap |
| `typography` | OiLabel, OiTextTheme |
| `upload` | OiUploadDialog, OiFileInput, OiFileExplorer |
| `url` | OiFieldDisplay(url) |
| `user` | OiAvatar, OiAvatarStack, OiUserMenu |
| `validation` | OiForm, OiFormField, OiTextInput, OiFormSelect, OiFormDialog, OiDatePickerField, OiDateRangePickerField, OiTimePickerField |
| `video` | OiVideoPlayer |
| `virtual-scroll` | OiVirtualList, OiVirtualGrid |
| `visibility` | OiVisibility |
| `visualization` | OiFunnelChart, OiGauge, OiHeatmap, OiRadarChart, OiSankey, OiTreemap |
| `wizard` | OiWizard, OiStepper |
| `workflow` | OiFlowGraph, OiPipeline, OiStateDiagram |

---

## Planned / Not Yet Available

> **WARNING:** The following widgets are defined in concept specifications but are NOT yet implemented in the codebase. Do NOT attempt to use them. They are listed here for awareness of future direction only.

### Planned Layout

- **OiFlex** — Flex layout with responsive direction and wrap
- **OiFieldset** — Semantic form field grouping with legend
- **OiShow / OiHide** — Responsive visibility per breakpoint

### Planned Social/Messaging

- **OiMessageBubble** — Full message display with avatar, timestamp, reactions, thread
- **OiThreadSummary** — "3 replies" indicator with last-reply preview
- **OiReactionPicker** — Emoji picker for message reactions
- **OiMessageActions** — Context menu for messages (edit, delete, react, reply)
- **OiComposeBar** — Message composition area with formatting and file attach
- **OiUnreadIndicator** — Unread message separator + count badge
- **OiTimestamp** — Interactive timestamp with hover tooltip
- **OiThread** — Thread/reply view within OiChat

---

## Maintenance

This document must be kept in sync with the codebase. When widgets are added, modified, or removed:
1. Update the relevant section in this file
2. Update the Tags Index
3. Update the Decision Matrix if applicable
4. Move items from "Planned" to the main catalog when implemented
5. Update the doc/ documentation folder as well
