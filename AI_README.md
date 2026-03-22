# obers_ui — AI Integration Reference

> **Version:** Synced with codebase as of 2026-03-21
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
  obers_ui.dart              ← Single barrel export (use this)
  src/
    foundation/              ← Tier 0
    primitives/              ← Tier 1
    components/              ← Tier 2
    composites/              ← Tier 3
    modules/                 ← Tier 4
    models/                  ← Data classes
    tools/                   ← Dev tools
    utils/                   ← Helpers
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

**Use When:** Transitioning between two different widgets (e.g., loading → content, collapsed → expanded).
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

**Named Constructors:** `OiLabel.display()`, `.h1()`, `.h2()`, `.h3()`, `.h4()`, `.body()`, `.bodyStrong()`, `.small()`, `.smallStrong()`, `.tiny()`, `.caption()`, `.code()`, `.overline()`, `.link()`

**Use When:** Any text display. Choose the variant matching the semantic level.
**Avoid When:** Never use raw `Text()` — always use `OiLabel`.

---

#### OiSurface
**Tags:** `container`, `card`, `background`, `border`, `glass`, `frosted`
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

**Theme:** `context.components.button` → `OiButtonThemeData`

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

**Theme:** `context.components.avatar` → `OiAvatarThemeData`
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

**Theme:** `context.components.badge` → `OiBadgeThemeData`

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

**Theme:** `context.components.card` → `OiCardThemeData`

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

---

#### OiFieldDisplay
**Tags:** `field`, `display`, `read-only`, `value`, `formatted`, `detail`, `data`
**Tier:** Component

Universal read-only field renderer. Formats values by type (date, currency, boolean, etc.).

**Key Parameters:**
- `value` (dynamic, required)
- `type` (OiFieldType, default: text) — Controls formatting
- `label` (String?)
- `emptyText` (String, default: '—')
- `copyable` (bool, default: false)
- `maxLines` (int?)
- `dateFormat` (String?) — Custom date format
- `numberFormat` (String?) — Custom number format
- `currencyCode` (String?) — e.g., 'EUR'
- `currencySymbol` (String?) — e.g., '€'
- `decimalPlaces` (int?)
- `choices` (Map<String, String>?) — Value→display mapping for select fields
- `choiceColors` (Map<String, OiBadgeColor>?) — Value→badge color for select fields
- `formatValue` (String Function(dynamic)?) — Custom formatter
- `onTap` (VoidCallback?) — Makes value tappable
- `leading` (Widget?) — Icon/widget before value

**Named Constructors:**
- `.pair(label:, value:)` — Label + value layout
  - Extra params: `direction` (Axis, default: horizontal), `labelWidth` (double?)

**Theme:** `context.components.fieldDisplay` → `OiFieldDisplayThemeData`

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

**Theme:** `context.components.progress` → `OiProgressThemeData`

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

**Theme:** `context.components.tooltip` → `OiTooltipThemeData`

**Use When:** Brief explanatory text on hover/focus.
**Avoid When:** Rich content — use `OiPopover`.

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

Display text → inline input on click/double-click.

**Use When:** Inline text editing in tables, lists, cards.

---

#### OiEditableDate
**Tags:** `inline-edit`, `date`, `click-to-edit`
**Tier:** Component

Display date → date picker on click.

---

#### OiEditableNumber
**Tags:** `inline-edit`, `number`, `click-to-edit`
**Tier:** Component

Display number → number input on click.

---

#### OiEditableSelect
**Tags:** `inline-edit`, `select`, `dropdown`, `click-to-edit`
**Tier:** Component

Display value → dropdown on click.

---

### COMPONENTS — Inputs

---

#### OiTextInput
**Tags:** `input`, `text`, `field`, `form`, `search`, `textarea`
**Tier:** Component

Standard text input field.

**Key Parameters:**
- `controller` (TextEditingController?)
- `label` (String?)
- `hint` (String?)
- `placeholder` (String?)
- `error` (String?)
- `leading` (Widget?)
- `trailing` (Widget?)
- `maxLines` (int?, default: 1) — Set >1 for textarea
- `maxLength` (int?)
- `keyboardType` (TextInputType?)
- `textInputAction` (TextInputAction?)
- `onChanged` (ValueChanged<String>?)
- `onSubmitted` (ValueChanged<String>?)
- `enabled` (bool, default: true)
- `readOnly` (bool, default: false)
- `obscureText` (bool, default: false) — For passwords
- `autofocus` (bool, default: false)
- `inputFormatters` (List<TextInputFormatter>?)
- `focusNode` (FocusNode?)

**Named Constructors:**
- `OiTextInput.search()` — Pre-configured search input with search icon

**Theme:** `context.components.textInput` → `OiTextInputThemeData`

**Use When:** Any text entry. Email, password, search, comments, notes.
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

#### OiDateTimeInput
**Tags:** `input`, `date`, `time`, `datetime`, `combined`, `picker`
**Tier:** Component

Combined date + time input that renders `OiDateInput` and `OiTimeInput` side by side within a single form field sharing one label and one error message. Changing the date portion updates the date part of the `DateTime` value; changing the time portion updates the time part. When `value` is `null` and one half is set, the other half defaults to today / 00:00.

**Key Parameters:**
- `value` (DateTime?) — Currently selected date and time
- `onChanged` (ValueChanged<DateTime?>?) — Called when date or time changes
- `label` (String?) — Label above the input pair
- `hint` (String?) — Hint below inputs when no error
- `error` (String?) — Validation error message
- `min` (DateTime?) — Earliest selectable date-time
- `max` (DateTime?) — Latest selectable date-time
- `required` (bool, default: false) — Renders asterisk next to label
- `readOnly` (bool, default: false) — Read-only state
- `enabled` (bool, default: true) — Whether field accepts interaction

**Use When:** Collecting a full date + time value in one field.
**Avoid When:** Date-only — use `OiDateInput`. Time-only — use `OiTimeInput`.

---

#### OiArrayInput
**Tags:** `input`, `array`, `repeatable`, `list`, `dynamic`, `reorder`, `form-group`
**Tier:** Component

A repeatable form field group where each row contains a set of form inputs with add, remove, and reorder controls. Rows are built via `itemBuilder` and new blank rows via `createEmpty`. Supports drag-to-reorder via `OiReorderable` and animated insert/remove via `OiAnimatedList`.

**Key Parameters:**
- `items` (List<T>, required) — Current list of items
- `itemBuilder` (Widget Function(BuildContext, int, T, ValueChanged<T>), required) — Builds each row
- `createEmpty` (T Function(), required) — Factory for new blank items
- `onChanged` (ValueChanged<List<T>>?) — Called after add/remove/reorder/edit
- `label` (String?) — Label above the list
- `error` (String?) — Validation error below the list
- `reorderable` (bool, default: true) — Enable drag-to-reorder
- `addable` (bool, default: true) — Show Add button
- `removable` (bool, default: true) — Show Remove buttons
- `minItems` (int?) — Minimum items; hides Remove at this count
- `maxItems` (int?) — Maximum items; hides Add at this count
- `addLabel` (String, default: 'Add') — Label for Add button

**Use When:** Dynamic-length form sections (line items, tags, addresses, schedule entries).
**Avoid When:** Static field lists — use regular form layout instead.

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

**Theme:** `context.components.select` → `OiSelectThemeData`

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

**Theme:** `context.components.checkbox` → `OiCheckboxThemeData`

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

**Theme:** `context.components.switchTheme` → `OiSwitchThemeData`

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

**Use When:** Mobile app navigation (3-5 tabs).
**Avoid When:** Desktop — use `OiSidebar` or `OiTabs`.

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

---

#### OiTimePicker
**Tags:** `picker`, `time`, `hours`, `minutes`
**Tier:** Component

Time selection with hours/minutes/seconds.

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

#### OiThemeToggle
**Tags:** `theme-toggle`, `dark-mode`, `light-mode`, `system-mode`, `appearance`
**Tier:** Component

Toggle button that switches between light, dark, and system theme modes. Shows sun (light), moon (dark), or monitor (system) icons. Three-way popover when `showSystemOption` is true; two-way cycle when false.

**Key Parameters:**
- `currentMode` (OiThemeMode, required) — The active theme mode
- `onModeChange` (ValueChanged<OiThemeMode>?, required) — Called when user selects a mode
- `label` (String, default: 'Toggle theme') — Accessibility label
- `showSystemOption` (bool, default: true) — When true, opens popover with three options; when false, cycles light↔dark

**Composes:** OiIconButton, OiIcon, OiPopover, OiTooltip, OiListTile

**Use When:** App header or settings page for theme switching.
**Avoid When:** You need a full theme editor — build a custom settings panel instead.

---

#### OiUserMenu
**Tags:** `user-menu`, `avatar-menu`, `account`, `profile`, `dropdown`
**Tier:** Component

Avatar-triggered dropdown menu showing user info and account actions. Tapping the avatar opens a popover with a header (user name and email) followed by grouped menu items separated by OiDivider.

**Key Parameters:**
- `label` (String, required) — Accessibility label
- `userName` (String, required) — Display name in header
- `userEmail` (String?) — Email below name
- `avatarUrl` (String?) — URL for avatar image
- `avatarInitials` (String?) — Fallback initials when no image
- `items` (List<OiMenuItem>, required) — Menu items (reuses OiMenuItem from OiContextMenu)
- `header` (Widget?) — Custom widget replacing default header

**Composes:** OiAvatar, OiTappable, OiPopover, OiLabel, OiDivider, OiListTile, OiIcon

**Use When:** App header user account dropdown with profile, settings, logout.
**Avoid When:** Simple icon menus — use OiContextMenu or OiPopover directly.

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

**Theme:** `context.components.tabs` → `OiTabsThemeData`

**Use When:** Switching between views/sections on the same page.
**Combine With:** `OiPage`, `OiSection`

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

**Static Method:**
```dart
OiDialog.show(context, label: '...', dialog: OiDialog.confirm(...));
```

**Theme:** `context.components.dialog` → `OiDialogThemeData`

**Use When:** User confirmation, forms, alerts, important info.
**Avoid When:** Non-blocking notifications — use `OiToast`. Side content — use `OiSheet`.

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

**Static Method:** `OiSheet.show(context, ...)`

**Theme:** `context.components.sheet` → `OiSheetThemeData`

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

**Theme:** `context.components.toast` → `OiToastThemeData`

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

### COMPONENTS — Shop

---

#### OiPriceTag
**Tags:** `shop`, `price`, `currency`, `money`, `sale`, `discount`, `strikethrough`, `e-commerce`
**Tier:** Component

Formatted price display with optional compare-at (strikethrough) price and currency symbol. Composes `OiRow` and `OiLabel`.

**Props:**
- `price` (double, required) — current price
- `label` (String, required) — accessibility label
- `compareAtPrice` (double?) — original price; shown with strikethrough when > `price`
- `currencyCode` (String?, default 'USD') — ISO 4217 currency code
- `currencySymbol` (String?) — explicit symbol override (takes priority over `currencyCode`)
- `decimalPlaces` (int, default 2) — number of decimal places
- `size` (OiPriceTagSize, default medium) — small / medium / large

**Behavior:**
- Zero price shows "Free" in success color
- Negative price shown in success color
- `compareAtPrice <= price` → ignored, no strikethrough
- Currency symbol positioned per locale convention ($ before for USD, € after for EUR)
- Unknown currency code falls back to code string after amount

**Use When:** Product prices, cart line items, order summaries.
**Combine With:** `OiQuantitySelector`, `OiCard`, `OiListTile`

---

#### OiQuantitySelector
**Tags:** `shop`, `quantity`, `stepper`, `counter`, `cart`, `e-commerce`, `number`
**Tier:** Component

Number stepper for product quantities with minus/plus buttons and display value. Composes `OiRow`, `OiIconButton`, `OiLabel`, `OiSurface`.

**Props:**
- `value` (int, required) — current quantity
- `label` (String, required) — accessibility label
- `onChange` (ValueChanged<int>?) — callback; null disables interaction
- `min` (int, default 1) — minimum allowed value
- `max` (int, default 99) — maximum allowed value
- `compact` (bool, default false) — reduced padding for dense layouts
- `disabled` (bool, default false) — disables all controls (opacity 0.4)

**Behavior:**
- Min boundary disables minus button; max boundary disables plus button
- Keyboard arrow up/down support for accessibility
- Semantics announces label, value, min, and max

**Use When:** Cart quantity adjustment, inventory counts.
**Combine With:** `OiPriceTag`, `OiCard`, `OiListTile`

---

#### OiCartItemRow
**Tags:** `shop`, `cart`, `line-item`, `e-commerce`, `row`
**Tier:** Component

A single line item row for the shopping cart. Shows thumbnail, name, variant info, quantity selector, line total, and remove button. Supports swipe-to-remove on mobile and compact mode for mini-cart overlays.

**Props:**
- `item` (OiCartItem, required) — cart item data
- `label` (String, required) — accessibility label
- `onQuantityChange` (ValueChanged<int>?) — quantity change callback
- `onRemove` (VoidCallback?) — remove callback
- `onTap` (VoidCallback?) — row tap callback
- `editable` (bool, default true) — show/hide quantity selector and remove button
- `compact` (bool, default false) — smaller layout for mini-cart
- `currencyCode` (String, default 'EUR') — ISO 4217 currency code

**Behavior:**
- Compact mode renders smaller thumbnail (48px vs 72px) and smaller text
- Non-editable mode hides quantity selector and remove button, shows "× quantity" text
- Swipe-to-remove via OiSwipeable when editable and onRemove is provided
- Thumbnail falls back to placeholder icon when imageUrl is null

**Use When:** Cart line items, order confirmation item lists.
**Combine With:** `OiCartPanel`, `OiMiniCart`, `OiOrderSummary`

---

#### OiCouponInput
**Tags:** `shop`, `coupon`, `discount`, `promo`, `e-commerce`, `input`
**Tier:** Component

Text input with 'Apply' button for discount/coupon codes. Shows success or error inline. Applied mode shows green check, code, and remove button.

**Props:**
- `label` (String, required) — accessibility label / visible label
- `onApply` (Future<OiCouponResult> Function(String), required) — apply callback returning success/failure
- `onRemove` (VoidCallback?) — remove applied coupon callback
- `appliedCode` (String?) — currently applied code; non-null shows applied mode
- `loading` (bool, default false) — loading state for Apply button

**Behavior:**
- Empty submit prevented (button disabled when input empty)
- Invalid code shows red error message inline
- Applied mode shows green check icon, bold code, and remove (X) button
- Error clears when user types new text
- Exception during apply shows generic error message

**Use When:** Cart coupon/promo code entry.
**Combine With:** `OiCartPanel`

---

#### OiOrderSummaryLine
**Tags:** `shop`, `summary`, `total`, `subtotal`, `checkout`, `e-commerce`
**Tier:** Component

A single summary row showing label on the left and amount on the right. Used for subtotal, discount, shipping, tax, and total lines.

**Props:**
- `label` (String, required) — line label (e.g. 'Subtotal', 'Tax')
- `amount` (double, required) — monetary amount
- `currencyCode` (String, default 'EUR') — ISO 4217 currency code
- `bold` (bool, default false) — bold styling for total row
- `negative` (bool, default false) — discount styling (green, minus prefix)
- `loading` (bool, default false) — shimmer placeholder instead of amount
- `subtitle` (String?) — optional subtitle below label (e.g. coupon code)

**Behavior:**
- Bold mode uses bodyStrong label and medium price tag size
- Negative mode inverts amount sign for discount display
- Loading mode shows OiShimmer placeholder instead of price
- Subtitle shown below label when provided

**Use When:** Checkout summaries, order totals, invoice line items.
**Combine With:** `OiCartPanel`, `OiOrderSummary`

---

#### OiProductCard
**Tags:** `shop`, `product`, `card`, `catalog`, `e-commerce`, `grid`
**Tier:** Component

Product display card for grid/list layouts. Shows image, name, price, rating, and quick-action buttons. Three layout variants.

**Props:**
- `product` (OiProductData, required) — product data
- `label` (String, required) — accessibility label
- `onTap` (VoidCallback?) — card tap callback
- `onAddToCart` (VoidCallback?) — add-to-cart callback
- `onWishlist` (VoidCallback?) — wishlist callback
- `showRating` (bool, default true) — show star rating
- `showAddToCart` (bool, default true) — show add-to-cart button
- `showWishlist` (bool, default false) — show wishlist button
- `isLoading` (bool, default false) — skeleton loading state
- `variant` (OiProductCardVariant, default vertical) — vertical / horizontal / compact

**Constructors:**
- `OiProductCard()` — default vertical layout
- `OiProductCard.horizontal()` — image-left layout for list views

**Behavior:**
- "Sale" badge when compareAtPrice > price
- "Out of Stock" badge when inStock is false; disables add-to-cart
- Skeleton loading via OiShimmer when isLoading is true
- Compact variant hides action buttons, shows single-line name
- Image placeholder with icon when imageUrl is null

**Use When:** Product grids, catalog pages, search results.
**Combine With:** `OiGrid`, `OiVirtualGrid`, `OiFilterBar`

---

### COMPONENTS — Shop (continued)

---

#### OiPaymentOption
**Tags:** `shop`, `payment`, `radio`, `select`, `e-commerce`, `checkout`
**Tier:** Component

Selectable payment method row with radio indicator. Displays payment method label and optional description with a radio-style selection circle.

**Props:**
- `method` (OiPaymentMethod, required) — payment method data
- `label` (String, required) — accessibility label
- `selected` (bool, default false) — whether this option is selected
- `onSelect` (ValueChanged<OiPaymentMethod>?) — callback when selected

**Behavior:**
- Shows filled radio dot when selected, empty circle when not
- Tapping anywhere on the row selects it
- Description shown below label in subtle text when available

**Use When:** Payment method selection in checkout flows.
**Combine With:** `OiCheckout`, `OiCard`

---

#### OiShippingOption
**Tags:** `shop`, `shipping`, `radio`, `select`, `e-commerce`, `checkout`, `delivery`
**Tier:** Component

Selectable shipping method row with price display and radio indicator. Shows method name, estimated delivery, and price with locale-aware currency formatting.

**Props:**
- `method` (OiShippingMethod, required) — shipping method data
- `label` (String, required) — accessibility label
- `selected` (bool, default false) — whether this option is selected
- `onSelect` (ValueChanged<OiShippingMethod>?) — callback when selected
- `currencyCode` (String, default 'EUR') — ISO 4217 currency code

**Behavior:**
- Shows filled radio dot when selected, empty circle when not
- Price displayed on the right with locale-aware currency positioning
- Estimated delivery shown as subtitle when available
- Zero price shows "Free" in success color

**Use When:** Shipping method selection in checkout flows.
**Combine With:** `OiCheckout`, `OiCard`

---

#### OiStockBadge
**Tags:** `shop`, `stock`, `inventory`, `availability`, `badge`, `e-commerce`
**Tier:** Component

Stock status badge showing in stock, low stock, or out of stock with optional count. Color-coded: success for in stock, warning for low stock, error for out of stock.

**Props:**
- `status` (OiStockStatus, required) — inStock / lowStock / outOfStock
- `label` (String, required) — accessibility label
- `count` (int?) — optional stock count to display

**Named Constructors:**
- `OiStockBadge.fromCount(stockCount:, label:, lowStockThreshold:)` — Auto-determines status from count. `null` or `> threshold` → inStock, `1..threshold` → lowStock, `0` → outOfStock. Default `lowStockThreshold: 5`.

**Behavior:**
- In stock: green dot + "In Stock" (or "N in stock")
- Low stock: amber dot + "Low Stock" (or "Only N left")
- Out of stock: red dot + "Out of Stock"

**Use When:** Product detail pages, product cards, inventory displays.
**Combine With:** `OiProductCard`, `OiShopProductDetail`

---

#### OiWishlistButton
**Tags:** `shop`, `wishlist`, `favorite`, `heart`, `toggle`, `e-commerce`
**Tier:** Component

Heart toggle button for wishlist/favorite functionality. Shows filled heart when active, outline when inactive.

**Props:**
- `label` (String, required) — accessibility label
- `active` (bool, default false) — whether item is in wishlist
- `onToggle` (VoidCallback?) — callback when toggled
- `loading` (bool, default false) — loading state

**Behavior:**
- Filled heart icon in error color when active
- Outline heart when inactive
- Spring animation on toggle
- Loading spinner replaces icon when loading

**Use When:** Product cards, product detail pages, catalog listings.
**Combine With:** `OiProductCard`, `OiShopProductDetail`

---

### COMPONENTS — Buttons (continued)

---

#### OiExportButton
**Tags:** `button`, `export`, `download`, `csv`, `xlsx`, `json`, `pdf`, `data`
**Tier:** Component

Export data button supporting CSV, XLSX, JSON, PDF formats. Renders as a plain outline button for a single format, or a split button with dropdown for multiple formats.

**Props:**
- `label` (String, required) — accessibility label
- `onExport` (Future<void> Function(OiExportFormat), required) — export callback receiving selected format
- `formats` (List<OiExportFormat>, default [OiExportFormat.csv]) — available formats
- `loading` (bool, default false) — loading state during export

**Companion: `OiExportFormat` enum** — `csv`, `xlsx`, `json`, `pdf` (each has a `label` getter)

**Behavior:**
- Single format: renders OiButton.outline with direct action
- Multiple formats: renders OiButton.split with dropdown menu
- Loading state shows spinner and disables button
- Format labels: "CSV", "Excel", "JSON", "PDF"

**Use When:** Data export from tables, lists, reports.
**Combine With:** `OiTable`, `OiListView`, `OiFilterBar`

---

#### OiSortButton
**Tags:** `button`, `sort`, `dropdown`, `order`, `ascending`, `descending`, `list`
**Tier:** Component

Dropdown button for sorting non-table lists (card grids, feeds). Shows current sort field and direction, with popover for field selection and direction toggle.

**Props:**
- `options` (List<OiSortOption>, required) — available sort fields
- `currentSort` (OiSortOption, required) — currently active sort
- `label` (String, required) — accessibility label
- `onSortChange` (ValueChanged<OiSortOption>, required) — callback when sort changes

**Companion: `OiSortOption`** — `field` (String), `label` (String), `direction` (OiSortDirection, default asc). Methods: `toggleDirection()`, `withDirection(OiSortDirection)`.

**Companion: `OiSortDirection` enum** — `asc`, `desc`

**Behavior:**
- Shows current sort label and direction arrow in button
- Popover lists all options with checkmark on current
- Tapping same option toggles direction
- Tapping different option selects it with its current direction

**Use When:** Non-table list sorting (card grids, activity feeds, search results).
**Combine With:** `OiListView`, `OiGrid`, `OiProductCard`

---

### COMPONENTS — Feedback (continued)

---

#### OiBulkBar
**Tags:** `bulk`, `selection`, `toolbar`, `actions`, `batch`, `feedback`
**Tier:** Component

Floating toolbar that appears when items are selected, showing selection count and bulk action buttons. Supports select all, deselect all, and custom actions.

**Props:**
- `selectedCount` (int, required) — number of selected items
- `totalCount` (int, required) — total number of items
- `label` (String, required) — accessibility label
- `actions` (List<OiBulkAction>, required) — available bulk actions
- `onSelectAll` (VoidCallback?) — select all callback
- `onDeselectAll` (VoidCallback?) — deselect all callback
- `allSelected` (bool, default false) — whether all items are selected

**Companion: `OiBulkAction`** — `label` (String), `icon` (IconData), `onTap` (VoidCallback), `variant` (OiBulkActionVariant, default ghost), `loading` (bool), `confirm` (bool), `confirmLabel` (String?)

**Companion: `OiBulkActionVariant` enum** — `ghost`, `destructive`

**Behavior:**
- Floats at bottom of screen with slide-up animation
- Shows "N of M selected" with select/deselect all toggle
- Actions render as icon buttons; destructive variant shows in error color
- Confirm mode requires double-tap for destructive actions

**Use When:** Multi-select lists, tables, file explorers with bulk operations.
**Combine With:** `OiTable`, `OiListView`, `OiFileExplorer`

---

### COMPONENTS — Display (continued)

---

#### OiPagination
**Tags:** `pagination`, `paging`, `page`, `navigation`, `display`, `load-more`
**Tier:** Component

Standalone pagination control with three variants: full pages, compact, and load-more. Supports per-page selector and total count display.

**Props:**
- `totalItems` (int, required) — total number of items
- `currentPage` (int, required) — current page (1-based)
- `label` (String?) — accessibility label
- `perPage` (int, default 25) — items per page
- `perPageOptions` (List<int>, default [10, 25, 50, 100]) — per-page dropdown options
- `onPageChange` (ValueChanged<int>?) — page change callback
- `onPerPageChange` (ValueChanged<int>?) — per-page change callback
- `showPerPage` (bool, default true) — show per-page selector
- `showTotal` (bool, default true) — show total count
- `showFirstLast` (bool, default true) — show first/last page buttons
- `siblingCount` (int, default 1) — visible page buttons around current
- `variant` (OiPaginationVariant, default pages) — pages / compact

**Named Constructors:**
- `OiPagination.compact(totalItems:, currentPage:, label:, perPage:, onPageChange:, showFirstLast:)` — Compact variant showing "Page X of Y" with prev/next arrows only.
- `OiPagination.loadMore(loadedCount:, totalItems:, onLoadMore:, loading:)` — Load-more button with "Showing X of Y" count.

**Static Method:** `computeVisiblePages(currentPage, totalPages, siblingCount)` — Returns list of page numbers with null gaps for ellipsis rendering.

**Behavior:**
- Pages variant: numbered page buttons with ellipsis for large ranges
- Compact variant: "Page X of Y" with prev/next arrows
- Load-more variant: single button with progress text
- First/last page buttons disabled at boundaries
- Per-page selector shown as dropdown

**Use When:** Paginated data lists, search results, table pagination.
**Combine With:** `OiTable`, `OiListView`, `OiGrid`

---

### COMPONENTS — Navigation (continued)

---

#### OiLocaleSwitcher
**Tags:** `locale`, `language`, `i18n`, `internationalization`, `dropdown`, `navigation`
**Tier:** Component

Locale/language dropdown selector with optional flag emoji support. Renders as a dropdown showing the current locale with flag and name.

**Props:**
- `currentLocale` (Locale, required) — currently selected locale
- `locales` (List<OiLocaleOption>, required) — available locales
- `onLocaleChange` (ValueChanged<Locale>?) — locale change callback
- `label` (String, default 'Language') — accessibility label
- `showFlag` (bool, default true) — show flag emoji
- `showCode` (bool, default true) — show locale code (e.g. "EN")
- `showName` (bool, default true) — show locale name (e.g. "English")

**Companion: `OiLocaleOption`** — `locale` (Locale), `name` (String), `flagEmoji` (String?)

**Behavior:**
- Dropdown trigger shows current locale with flag + code/name
- Popover lists all locales with flag, code, and full name
- Selected locale highlighted with checkmark

**Use When:** App header, settings page, footer language selection.
**Combine With:** `OiAppShell`, `OiUserMenu`, `OiBottomBar`

---

### COMPOSITES — Shop

---

#### OiCartPanel
**Tags:** `shop`, `cart`, `checkout`, `e-commerce`, `composite`, `panel`
**Tier:** Composite

Full shopping cart view with item list, optional coupon input, order summary lines, checkout button, and continue-shopping link. Shows OiEmptyState when cart is empty. Supports shimmer loading on summary lines.

**Props:**
- `items` (List<OiCartItem>, required) — cart items
- `summary` (OiCartSummary, required) — subtotal/discount/shipping/tax/total
- `label` (String, required) — accessibility label
- `onQuantityChange` (ValueChanged<({Object productKey, int quantity})>?) — quantity change callback
- `onRemove` (ValueChanged<Object>?) — remove item callback (receives productKey)
- `onApplyCoupon` (Future<OiCouponResult> Function(String)?) — coupon apply callback; null hides coupon section
- `onRemoveCoupon` (VoidCallback?) — remove coupon callback
- `appliedCouponCode` (String?) — currently applied coupon code
- `onCheckout` (VoidCallback?) — checkout callback; null disables button
- `onContinueShopping` (VoidCallback?) — continue shopping link; null hides it
- `checkoutLabel` (String, default 'Proceed to Checkout') — checkout button text
- `currencyCode` (String, default 'EUR') — ISO 4217 currency code
- `loading` (bool, default false) — shimmer on summary lines

**Composition:** OiColumn, OiCartItemRow, OiDivider, OiCouponInput, OiOrderSummaryLine, OiButton.primary, OiEmptyState.

**Behavior:**
- Empty items list → OiEmptyState with cart icon and optional continue-shopping button
- Coupon section hidden when onApplyCoupon is null
- Summary shows conditional discount/shipping/tax lines based on null checks
- Checkout button disabled when onCheckout is null

**Use When:** Cart page, cart side panel, cart sheet.
**Combine With:** `OiMiniCart`, `OiOrderSummary`

---

#### OiMiniCart
**Tags:** `shop`, `cart`, `mini`, `popover`, `badge`, `e-commerce`, `composite`
**Tier:** Composite

Compact cart widget: icon button with badge count that opens a popover or sheet with condensed cart preview. Badge hidden when cart is empty.

**Props:**
- `items` (List<OiCartItem>, required) — cart items
- `summary` (OiCartSummary, required) — for total price display
- `label` (String, required) — accessibility label
- `onViewCart` (VoidCallback?) — 'View Cart' button callback
- `onCheckout` (VoidCallback?) — 'Checkout' button callback
- `onRemove` (ValueChanged<Object>?) — remove item callback (receives productKey)
- `maxVisibleItems` (int, default 3) — max items in preview
- `display` (OiMiniCartDisplay, default popover) — popover or sheet
- `currencyCode` (String, default 'EUR') — ISO 4217 currency code

**Composition:** OiIconButton, OiBadge, OiPopover/OiSheet, OiColumn, OiCartItemRow (compact), OiPriceTag, OiButton, OiLabel.

**Behavior:**
- Badge shows total quantity (sum of all item quantities); hidden when empty
- Overflow indicator: "X more item(s)" when items exceed maxVisibleItems
- Singular "1 more item" vs plural "2 more items"
- Empty state shows "Cart is empty" centered text
- Popover mode: constrained to 360px max width
- Sheet mode: uses OiSheet with close callback

**Use When:** Header cart icon, navigation bar cart indicator.
**Combine With:** `OiCartPanel`, `OiSidebar`, `OiBottomBar`

---

#### OiOrderSummary
**Tags:** `shop`, `order`, `summary`, `checkout`, `e-commerce`, `composite`
**Tier:** Composite

Complete order summary card showing all summary lines with optional expandable item list inside an OiAccordion.

**Props:**
- `summary` (OiCartSummary, required) — subtotal/discount/shipping/tax/total
- `label` (String, required) — accessibility label
- `items` (List<OiCartItem>?) — optional items for expandable list
- `showItems` (bool, default true) — whether to show item accordion
- `expandedByDefault` (bool, default false) — accordion starts expanded
- `currencyCode` (String, default 'EUR') — ISO 4217 currency code

**Composition:** OiCard, OiColumn, OiOrderSummaryLine, OiDivider, OiAccordion, OiCartItemRow (read-only), OiLabel.

**Behavior:**
- Items shown in accordion with "Items (N)" header
- Items rendered as non-editable OiCartItemRow widgets
- Summary lines: subtotal always shown; discount/shipping/tax conditional on null
- Total line shown in bold

**Use When:** Checkout page, order confirmation, order detail view.
**Combine With:** `OiCartPanel`, `OiWizard`, `OiDetailView`

---

#### OiProductFilters
**Tags:** `shop`, `filter`, `price`, `category`, `rating`, `stock`, `e-commerce`, `composite`
**Tier:** Composite

Filter panel for product listings with price range slider, category checkboxes, minimum rating selector, and in-stock-only toggle.

**Props:**
- `label` (String, required) — accessibility label
- `value` (OiProductFilterData?) — current filter state
- `onChanged` (ValueChanged<OiProductFilterData>?) — filter change callback
- `availableCategories` (List<String>, default []) — available categories for checkbox list
- `currencyCode` (String, default 'EUR') — ISO 4217 currency code for price labels
- `priceRangeMin` (double, default 0) — minimum price slider bound
- `priceRangeMax` (double, default 1000) — maximum price slider bound

**Companion: `OiProductFilterData`** — `minPrice` (double?), `maxPrice` (double?), `categories` (List<String>), `minRating` (double?), `inStockOnly` (bool). Has `copyWith()` method.

**Composition:** OiCard, OiColumn, OiLabel, OiSlider (range), OiCheckbox, OiStarRating, OiSwitch, OiButton.

**Behavior:**
- Price range shown as dual slider with currency-formatted labels
- Categories shown as checkbox list
- Rating shown as interactive star row
- "In Stock Only" toggle at bottom
- Clear all filters button when any filter is active

**Use When:** Product catalog filtering, shop search refinement.
**Combine With:** `OiProductCard`, `OiGrid`, `OiListView`, `OiSplitPane`

---

#### OiProductGallery
**Tags:** `shop`, `gallery`, `image`, `product`, `thumbnail`, `carousel`, `e-commerce`, `composite`
**Tier:** Composite

Image gallery with large main image and thumbnail strip for product images. Supports click-to-select thumbnails and index change callback.

**Props:**
- `imageUrls` (List<String>, required) — list of image URLs
- `label` (String, required) — accessibility label
- `initialIndex` (int, default 0) — initially selected image index
- `onIndexChanged` (ValueChanged<int>?) — index change callback
- `showThumbnails` (bool, default true) — show thumbnail strip below main image

**Composition:** OiColumn, OiImage, OiRow, OiTappable, OiSurface.

**Behavior:**
- Main image fills available width with aspect ratio maintained
- Thumbnail strip shows all images as small clickable squares
- Selected thumbnail highlighted with primary border
- Handles empty imageUrls gracefully with placeholder

**Use When:** Product detail pages, any multi-image display.
**Combine With:** `OiShopProductDetail`, `OiLightbox`

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

**Theme:** `context.components.table` → `OiTableThemeData`

**Use When:** Tabular data display with sort/filter/pagination needs.
**Combine With:** `OiFilterBar`, `OiDetailView` (for row detail), `OiEditableText` (for inline edit)
**Avoid When:** Simple lists — use `OiListView` module.

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
- `emptyText` (String, default: '—')
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

**Theme:** `context.components.sidebar` → `OiSidebarThemeData`

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

#### OiErrorPage
**Tags:** `error`, `404`, `403`, `500`, `not-found`, `forbidden`, `server-error`, `navigation`, `composite`
**Tier:** Composite

Full-page error display for HTTP error states. Shows error code, title, description, optional illustration, and action button. Three factory constructors for common HTTP errors.

**Props:**
- `title` (String, required) — error title
- `label` (String, required) — accessibility label
- `description` (String?) — descriptive text
- `errorCode` (String?) — error code display (e.g. "404")
- `illustration` (Widget?) — custom illustration widget
- `icon` (IconData?) — icon shown when no illustration
- `actionLabel` (String?) — action button label
- `onAction` (VoidCallback?) — action button callback

**Named Constructors:**
- `OiErrorPage.notFound(label:, onAction:, actionLabel:)` — 404 page with "Page Not Found" defaults
- `OiErrorPage.forbidden(label:, onAction:, actionLabel:)` — 403 page with "Access Denied" defaults
- `OiErrorPage.serverError(label:, onAction:, actionLabel:)` — 500 page with "Server Error" defaults

**Composition:** OiPage, OiColumn, OiLabel, OiIcon, OiButton.primary.

**Behavior:**
- Error code displayed in large display text
- Title and description centered below
- Action button centered at bottom (e.g. "Go Home", "Try Again")
- Content vertically centered on page

**Use When:** Router error pages, unauthorized access, server errors.
**Combine With:** Router configuration, `OiAppShell`

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

**Theme:** `context.components.fileExplorer` → `OiFileExplorerThemeData`

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

#### OiCheckout
**Tags:** `checkout`, `shop`, `e-commerce`, `wizard`, `payment`, `shipping`, `address`, `order`, `module`
**Tier:** Module

Multi-step checkout flow orchestrating address entry, shipping selection, payment selection, and order review. Responsive layout with side-by-side summary on desktop.

**Key Parameters:**
- `items` (List<OiCartItem>, required) — cart items
- `summary` (OiCartSummary, required) — order summary data
- `label` (String, required) — accessibility label
- `steps` (List<OiCheckoutStep>, default [address, shipping, payment, review]) — checkout steps
- `onShippingAddressChange` (ValueChanged<OiAddressData>?) — shipping address callback
- `onBillingAddressChange` (ValueChanged<OiAddressData>?) — billing address callback
- `onShippingMethodChange` (ValueChanged<OiShippingMethod>?) — shipping method callback
- `onPaymentMethodChange` (ValueChanged<OiPaymentMethod>?) — payment method callback
- `onPlaceOrder` (VoidCallback?) — place order callback
- `onCancel` (VoidCallback?) — cancel callback
- `initialShippingAddress` (OiAddressData?) — pre-filled shipping address
- `initialBillingAddress` (OiAddressData?) — pre-filled billing address
- `shippingMethods` (List<OiShippingMethod>?) — available shipping methods
- `paymentMethods` (List<OiPaymentMethod>?) — available payment methods
- `countries` (List<String>?) — country list for address dropdown
- `showSummary` (bool, default true) — show order summary sidebar
- `sameBillingDefault` (bool, default true) — "same as shipping" checkbox default
- `currencyCode` (String, default 'USD') — ISO 4217 currency code
- `placeOrderLabel` (String?) — custom place order button text

**Companion: `OiCheckoutStep` enum** — `address`, `shipping`, `payment`, `review`

**Composition:** OiStepper, OiOrderSummary, OiButton, OiCheckbox, OiSelect, OiTextInput, OiAccordion, OiShippingOption, OiPaymentOption.

**Behavior:**
- Steps are navigated via OiStepper with validation per step
- Address step: shipping address form with optional separate billing address
- Shipping step: list of OiShippingOption radio cards
- Payment step: list of OiPaymentOption radio cards
- Review step: read-only summary of all selections
- Desktop: 2-column layout (form + summary sidebar)
- Mobile: single-column with summary below

**Use When:** E-commerce checkout flow.
**Combine With:** `OiCartPanel`, `OiOrderSummary`

---

#### OiShopProductDetail
**Tags:** `product`, `detail`, `shop`, `e-commerce`, `gallery`, `variants`, `module`
**Tier:** Module

Complete product detail page with gallery, variant selectors, quantity, pricing, and tabbed content sections.

**Key Parameters:**
- `product` (OiProductData, required) — product data
- `label` (String, required) — accessibility label
- `onAddToCart` (VoidCallback?) — add-to-cart callback
- `onVariantChange` (ValueChanged<OiProductVariant>?) — variant selection callback
- `onQuantityChange` (ValueChanged<int>?) — quantity change callback
- `onWishlist` (VoidCallback?) — wishlist toggle callback
- `selectedVariant` (OiProductVariant?) — currently selected variant
- `quantity` (int, default 1) — current quantity
- `description` (Widget?) — description tab content
- `reviews` (Widget?) — reviews tab content
- `specifications` (Widget?) — specifications tab content
- `related` (Widget?) — related products section

**Composition:** OiProductGallery, OiLabel, OiPriceTag, OiStockBadge, OiStarRating, OiQuantitySelector, OiWishlistButton, OiButton.primary, OiTabs, OiSelect, OiBadge.

**Behavior:**
- Desktop: side-by-side layout (gallery left, info right)
- Mobile: stacked layout (gallery on top, info below)
- Gallery with thumbnail strip for product images
- Variant selectors as dropdowns when variants available
- Add-to-cart disabled when out of stock
- Tabbed content for description/specifications/reviews
- Related products shown as horizontal scroll section

**Use When:** Product detail pages in e-commerce applications.
**Combine With:** `OiProductCard`, `OiCartPanel`

---

#### OiAuthPage
**Tags:** `auth`, `authentication`, `login`, `register`, `signup`, `forgot-password`, `module`
**Tier:** Module

Full-page authentication module with login, register, and forgot-password flows. Centered form layout with optional logo and footer.

**Key Parameters:**
- `label` (String, required) — accessibility label
- `initialMode` (OiAuthMode, default login) — starting auth mode
- `onModeChanged` (ValueChanged<OiAuthMode>?) — mode switch callback
- `onLogin` (Future<bool> Function(String email, String password)?) — login callback
- `onRegister` (Future<bool> Function(String name, String email, String password)?) — register callback
- `onForgotPassword` (Future<bool> Function(String email)?) — forgot password callback
- `logo` (Widget?) — logo widget above form
- `footer` (Widget?) — footer widget below form

**Named Constructors:**
- `OiAuthPage.login(label:, onLogin:, ...)` — Pre-configured for login mode
- `OiAuthPage.register(label:, onRegister:, ...)` — Pre-configured for register mode

**Companion: `OiAuthMode` enum** — `login`, `register`, `forgotPassword`

**Composition:** OiPage, OiColumn, OiCard, OiTextInput, OiButton.primary, OiLabel.link.

**Behavior:**
- Centered form card (max 400dp wide)
- Login: email + password fields with "Forgot Password?" link
- Register: name + email + password fields
- Forgot Password: email field with "Back to login" link
- Mode switching links at bottom of form
- Error display inline when callbacks return false
- Loading state on submit button during async callbacks

**Use When:** Authentication pages for web/mobile apps.
**Combine With:** `OiAppShell`, router configuration

---

#### OiAppShell
**Tags:** `app-shell`, `layout`, `scaffold`, `sidebar`, `admin`, `navigation`, `module`
**Tier:** Module

Master layout scaffold for admin/dashboard applications with sidebar navigation, top bar, and content area. Supports responsive collapse and settings persistence.

**Key Parameters:**
- `child` (Widget, required) — main content area
- `label` (String, required) — accessibility label
- `navigation` (List<OiNavItem>, required) — sidebar navigation items
- `leading` (Widget?) — sidebar header widget (logo/brand)
- `title` (Widget?) — top bar title
- `actions` (List<Widget>?) — top bar action widgets
- `userMenu` (Widget?) — user menu widget in top bar
- `sidebarCollapsible` (bool, default true) — allow sidebar collapse
- `sidebarDefaultCollapsed` (bool, default false) — initial sidebar state
- `sidebarWidth` (double, default 256) — expanded sidebar width
- `sidebarCollapsedWidth` (double, default 64) — collapsed sidebar width
- `breadcrumbs` (List<OiBreadcrumbItem>?) — breadcrumb items
- `showBreadcrumbs` (bool, default true) — show breadcrumb trail
- `mobileBreakpoint` (OiBreakpoint, default medium) — breakpoint for mobile layout
- `currentRoute` (String?) — current route for nav highlighting
- `onNavigate` (ValueChanged<String>?) — navigation callback
- `settingsDriver` / `settingsKey` / `settingsNamespace` — persistence params

**Companion: `OiNavItem`** — `label` (String), `icon` (IconData), `route` (String?), `children` (List<OiNavItem>?), `badge` (String?), `dividerBefore` (bool), `section` (String?)

**Composition:** OiSidebar, OiBreadcrumbs, OiDrawer, OiIconButton, OiLabel, OiDivider.

**Behavior:**
- Desktop: sidebar (collapsible) + top bar + content area
- Mobile: hamburger menu → drawer with navigation
- Sidebar collapse state persisted via OiSettingsMixin
- Active nav item highlighted based on currentRoute
- Nested nav items support expand/collapse
- Section headers group navigation items

**Use When:** Admin panels, dashboard apps, internal tools.
**Combine With:** `OiResourcePage`, `OiDashboard`, `OiBreadcrumbs`

---

#### OiResourcePage
**Tags:** `resource`, `crud`, `scaffold`, `list`, `show`, `edit`, `create`, `admin`, `module`
**Tier:** Module

Generic CRUD page scaffold providing consistent layout for list, show, edit, and create views with title area, action bar, content, and optional pagination/filters.

**Key Parameters:**
- `child` (Widget, required) — main content widget
- `label` (String, required) — accessibility label
- `title` (String?) — page title
- `variant` (OiResourcePageVariant, default list) — page variant
- `actions` (List<Widget>?) — custom action buttons
- `filters` (Widget?) — filter bar widget
- `pagination` (Widget?) — pagination widget
- `breadcrumbs` (List<OiBreadcrumbItem>?) — breadcrumb items
- `wrapInCard` (bool, default true) — wrap content in OiCard
- `onAction` (OiResourceAction?) — default action callback (receives action name string)

**Companion: `OiResourcePageVariant` enum** — `list`, `show`, `edit`, `create`

**Companion: `OiResourceAction` typedef** — `void Function(String action)`

**Composition:** OiPage, OiColumn, OiRow, OiCard, OiButton, OiBreadcrumbs, OiLabel.

**Behavior:**
- List variant: shows "Create" button in actions
- Show variant: shows "Edit" and "Delete" buttons
- Edit/Create variant: shows "Save" and "Cancel" buttons
- Default action buttons trigger onAction with action name ('create', 'edit', 'delete', 'save', 'cancel')
- Custom actions replace default buttons when provided
- Content wrapped in OiCard by default (configurable)

**Use When:** CRUD pages in admin applications.
**Combine With:** `OiAppShell`, `OiTable`, `OiForm`, `OiDetailView`

---

## Models

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

### OiAddressData
**Tags:** `address`, `shipping`, `billing`, `shop`, `e-commerce`, `model`

Immutable address model for shipping/billing addresses with completeness check.

**Fields:** `firstName` (String?), `lastName` (String?), `company` (String?), `address1` (String?), `address2` (String?), `city` (String?), `state` (String?), `postalCode` (String?), `country` (String?), `phone` (String?), `email` (String?)
**Computed:** `isComplete` (bool) — true when firstName, lastName, address1, city, postalCode, and country are all non-null and non-empty
**Methods:** `copyWith(...)` with full nullable support

### OiPaymentMethod
**Tags:** `payment`, `method`, `shop`, `e-commerce`, `checkout`, `model`

Payment method model for checkout flows.

**Fields:** `key` (String), `label` (String), `description` (String?), `icon` (String?), `isDefault` (bool, default false)
**Methods:** `copyWith(...)`

### OiShippingMethod
**Tags:** `shipping`, `method`, `delivery`, `shop`, `e-commerce`, `checkout`, `model`

Shipping method model with price and estimated delivery info.

**Fields:** `key` (String), `label` (String), `price` (double), `description` (String?), `estimatedDelivery` (String?), `currencyCode` (String, default 'USD')
**Methods:** `copyWith(...)`

### OiCouponResult
**Tags:** `coupon`, `discount`, `promo`, `validation`, `shop`, `e-commerce`, `model`

Coupon validation result returned from the apply callback.

**Fields:** `valid` (bool), `message` (String?), `discountAmount` (double?)
**Methods:** `copyWith(...)`

### OiOrderData
**Tags:** `order`, `checkout`, `shop`, `e-commerce`, `model`

Complete order data aggregation combining all checkout selections.

**Fields:** `shippingAddress` (OiAddressData), `shippingMethod` (OiShippingMethod), `paymentMethod` (OiPaymentMethod), `items` (List<OiCartItem>), `summary` (OiCartSummary), `billingAddress` (OiAddressData?)
**Methods:** `copyWith(...)`

### Settings Models
**Tags:** `settings`, `persistence`, `state`

Persist widget state: `OiAccordionSettings`, `OiAppShellSettings`, `OiCalendarSettings`, `OiDashboardSettings`, `OiFileExplorerSettings`, `OiFilterBarSettings`, `OiGanttSettings`, `OiKanbanSettings`, `OiListViewSettings`, `OiSidebarSettings`, `OiSplitPaneSettings`, `OiTableSettings`, `OiTabsSettings`

All settings models implement `OiSettingsData` with JSON serialization (`toJson`/`fromJson`). Key additions:

- **OiAppShellSettings** — Persists sidebar collapsed state (bool). Used by `OiAppShell`.

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

Static class with 150+ `IconData` constants organized by category:

- **Navigation:** `chevronLeft`, `chevronRight`, `navigateNext`, `expandMore`, `expandLess`, `arrowDropDown`, `arrowUpward`
- **Actions:** `add`, `edit`, `delete`, `close`, `check`, `search`, `download`, `cloudUpload`, `playArrow`, `reply`
- **Clipboard:** `contentCopy`, `contentPaste`, `attachFile`
- **Files:** `folder`, `folderOpen`, `createNewFolder`, `insertDriveFile`, `description`
- **File Types:** `image`, `videoFile`, `audioFile`, `pictureAsPdf`, `tableChart`, `code`, `dataObject`
- **Layout:** `viewList`, `viewModule`, `viewAgenda`, `splitscreen`, `dashboardCustomize`
- **Media:** `playArrow`, `pause`, `fullscreen`, `volumeUp`
- **And more...**

Always use `OiIcons.x` instead of `Icons.x` from Material.

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
| **Dropdown** | `OiSelect` (small lists) / `OiComboBox` (large/async) | `DropdownButton` |
| **Checkbox** | `OiCheckbox` | `Checkbox` |
| **Switch** | `OiSwitch` | `Switch` |
| **Radio** | `OiRadio` | `Radio` |
| **Slider** | `OiSlider` | `Slider` |
| **Card** | `OiCard` | `Card` |
| **List item** | `OiListTile` | `ListTile` |
| **Dialog** | `OiDialog.show()` | `showDialog()` |
| **Toast** | `OiToast.show()` | `ScaffoldMessenger` / `SnackBar` |
| **Bottom sheet** | `OiSheet.show()` | `showModalBottomSheet()` |
| **Navigation bar** | `OiBottomBar` (mobile) / `OiSidebar` (desktop) | `BottomNavigationBar` |
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
| **Shopping cart** | `OiCartPanel` (full) / `OiMiniCart` (compact) | Custom cart UI |
| **Product card** | `OiProductCard` | Custom product display |
| **Order summary** | `OiOrderSummary` | Custom totals layout |
| **Checkout flow** | `OiCheckout` | Custom multi-step checkout |
| **Product detail** | `OiShopProductDetail` | Custom product page |
| **Auth page** | `OiAuthPage` | Custom login/register forms |
| **Admin layout** | `OiAppShell` | Custom sidebar + content layout |
| **CRUD page** | `OiResourcePage` | Custom list/edit scaffolds |
| **Error page** | `OiErrorPage` | Custom 404/403/500 pages |
| **Product filters** | `OiProductFilters` | Custom filter panel |
| **Stock status** | `OiStockBadge` | Custom availability indicator |
| **Wishlist toggle** | `OiWishlistButton` | Custom heart button |
| **Bulk actions** | `OiBulkBar` | Custom selection toolbar |
| **Pagination** | `OiPagination` | Custom page controls |
| **Sort control** | `OiSortButton` | Custom sort dropdown |
| **Export data** | `OiExportButton` | Custom export UI |
| **Language switch** | `OiLocaleSwitcher` | Custom locale picker |
| **Price display** | `OiPriceTag` | Custom formatted text |
| **Quantity stepper** | `OiQuantitySelector` | Custom counter |
| **Empty state** | `OiEmptyState` | Custom empty placeholder |
| **Loading** | `OiShimmer` / `OiSkeletonGroup` / `OiProgress` | Custom loading |
| **Copy text** | `OiCopyable` / `OiCopyButton` | Custom clipboard code |
| **Inline edit** | `OiEditableText` / `OiEditableSelect` / etc. | Custom inline edit |
| **Large list** | `OiVirtualList` (>100 items) | `ListView.builder` |
| **Drag to reorder** | `OiReorderable` | `ReorderableListView` |
| **Swipe actions** | `OiSwipeable` | `Dismissible` |
| **Onboarding tour** | `OiTour` + `OiSpotlight` | Custom spotlight |
| **Metrics/KPI** | `OiMetric` | Custom number display |
| **User menu** | `OiAvatar` + `OiPopover` + `OiNavMenu` | Custom menu |

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

Searchable keyword → widget mapping for quick lookup.

| Tag | Widgets |
|---|---|
| `accordion` | OiAccordion |
| `action` | OiButton, OiIconButton, OiContextMenu |
| `activity` | OiActivityFeed, OiTimeline |
| `address` | OiAddressData, OiCheckout |
| `admin` | OiListView, OiDashboard, OiSidebar, OiFilterBar, OiAppShell, OiResourcePage |
| `app-shell` | OiAppShell |
| `auth` | OiAuthPage |
| `authentication` | OiAuthPage |
| `alert` | OiDialog.alert, OiToast |
| `animation` | OiAnimatedList, OiMorph, OiPulse, OiShimmer, OiSpring, OiStagger |
| `app` | OiApp |
| `avatar` | OiAvatar, OiAvatarStack |
| `badge` | OiBadge, OiBottomBar |
| `board` | OiKanban |
| `boolean` | OiCheckbox, OiSwitch, OiFieldDisplay(boolean) |
| `breadcrumb` | OiBreadcrumbs, OiPathBar |
| `bulk` | OiBulkBar |
| `button` | OiButton, OiButtonGroup, OiIconButton, OiToggleButton, OiExportButton, OiSortButton |
| `calendar` | OiCalendar, OiDatePicker, OiDateInput |
| `card` | OiCard, OiDashboardCard, OiFileGridCard |
| `cart` | OiCartItem, OiCartSummary, OiCartPanel, OiMiniCart, OiCartItemRow, OiCheckout |
| `checkout` | OiCheckout, OiOrderSummary, OiCartPanel, OiPaymentOption, OiShippingOption |
| `chart` | OiFunnelChart, OiGauge, OiHeatmap, OiRadarChart, OiSankey, OiTreemap |
| `chat` | OiChat, OiChatMessage, OiTypingIndicator |
| `checkbox` | OiCheckbox |
| `clipboard` | OiCopyButton, OiCopyable, OiPasteZone |
| `code` | OiCodeBlock, OiLabel.code, OiDiffView |
| `collapse` | OiAccordion, OiCard(collapsible) |
| `color` | OiColorInput, OiColorScheme, OiColorSwatch |
| `column` | OiColumn, OiTableColumn |
| `combobox` | OiComboBox |
| `command` | OiCommandBar |
| `comment` | OiComments |
| `confirm` | OiButton.confirm, OiDialog.confirm, OiDeleteDialog |
| `container` | OiContainer, OiSurface, OiCard |
| `context-menu` | OiContextMenu |
| `copy` | OiCopyButton, OiCopyable, OiFieldDisplay(copyable) |
| `crud` | OiListView, OiForm, OiDetailView, OiResourcePage |
| `coupon` | OiCouponInput, OiCouponResult, OiCartPanel |
| `currency` | OiFieldDisplay(currency), OiNumberInput |
| `dashboard` | OiDashboard, OiMetric |
| `data` | OiTable, OiDetailView, OiListView, OiFieldDisplay |
| `date` | OiDateInput, OiDatePicker, OiFieldDisplay(date) |
| `delete` | OiDeleteDialog, OiButton.destructive |
| `detail` | OiDetailView, OiFieldDisplay |
| `dialog` | OiDialog, OiDeleteDialog, OiNameDialog, OiRenameDialog |
| `diff` | OiDiffView |
| `divider` | OiDivider |
| `drag-and-drop` | OiDraggable, OiDropZone, OiReorderable, OiDragGhost |
| `drawer` | OiDrawer |
| `dropdown` | OiSelect, OiComboBox, OiButton.split |
| `editor` | OiRichEditor, OiSmartInput |
| `email` | OiFieldDisplay(email), OiTextInput |
| `emoji` | OiEmojiPicker, OiReactionBar |
| `delivery` | OiShippingOption, OiShippingMethod |
| `e-commerce` | OiPriceTag, OiQuantitySelector, OiProductCard, OiCartItemRow, OiCouponInput, OiOrderSummaryLine, OiCartPanel, OiMiniCart, OiOrderSummary, OiPaymentOption, OiShippingOption, OiStockBadge, OiWishlistButton, OiProductFilters, OiProductGallery, OiCheckout, OiShopProductDetail |
| `empty` | OiEmptyState |
| `error-page` | OiErrorPage |
| `explorer` | OiFileExplorer |
| `export` | OiExportButton, OiThemeExporter |
| `feed` | OiActivityFeed |
| `feedback` | OiStarRating, OiScaleRating, OiThumbs, OiSentiment, OiReactionBar |
| `field` | OiFieldDisplay, OiFormField, OiDetailField |
| `file` | OiFileExplorer, OiFileInput, OiFileIcon, OiFileTile, OiFileGridCard |
| `filter` | OiFilterBar, OiListView, OiTable, OiProductFilters |
| `flow` | OiFlowGraph, OiStateDiagram |
| `folder` | OiFolderIcon, OiFolderTreeItem, OiNewFolderDialog |
| `form` | OiForm, OiFormField, OiFormSection, OiWizard |
| `funnel` | OiFunnelChart |
| `gallery` | OiGallery, OiLightbox, OiProductGallery |
| `gantt` | OiGantt |
| `gauge` | OiGauge |
| `gesture` | OiTappable, OiSwipeable, OiDoubleTap, OiLongPressMenu, OiPinchZoom |
| `graph` | OiFlowGraph |
| `grid` | OiGrid, OiMasonry, OiVirtualGrid, OiFileGridView |
| `group` | OiButtonGroup, OiAccordion, OiFormSection |
| `heading` | OiLabel.h1, .h2, .h3, .h4 |
| `heatmap` | OiHeatmap |
| `hierarchy` | OiTree, OiFolderTreeItem, OiTreemap |
| `i18n` | OiLocaleSwitcher |
| `icon` | OiIcon, OiIconButton, OiFileIcon, OiFolderIcon |
| `image` | OiImage, OiAvatar, OiGallery, OiLightbox, OiImageCropper, OiImageAnnotator |
| `indicator` | OiProgress, OiLiveRing, OiPulse, OiStorageIndicator |
| `inline-edit` | OiEditable, OiEditableText, OiEditableSelect, OiEditableDate, OiEditableNumber |
| `input` | OiTextInput, OiNumberInput, OiDateInput, OiTimeInput, OiSelect, OiComboBox, OiCheckbox, OiSwitch, OiRadio, OiSlider, OiTagInput, OiColorInput, OiFileInput |
| `inventory` | OiStockBadge |
| `kanban` | OiKanban |
| `keyboard` | OiShortcutScope, OiShortcuts, OiCommandBar, OiFocusTrap |
| `kpi` | OiMetric |
| `label` | OiLabel |
| `layout` | OiRow, OiColumn, OiGrid, OiPage, OiSection, OiMasonry, OiWrapLayout, OiSpacer |
| `lightbox` | OiLightbox |
| `list` | OiListView, OiListTile, OiVirtualList, OiAnimatedList |
| `live` | OiLiveRing, OiCursorPresence, OiSelectionPresence |
| `loading` | OiProgress, OiShimmer, OiSkeletonGroup, OiButton(loading) |
| `locale` | OiLocaleSwitcher |
| `log` | OiActivityFeed, OiTimeline |
| `markdown` | OiMarkdown |
| `media` | OiVideoPlayer, OiGallery, OiLightbox, OiImageCropper, OiImageAnnotator |
| `menu` | OiNavMenu, OiContextMenu, OiBottomBar, OiSidebar |
| `message` | OiChat, OiChatMessage, OiToast |
| `metadata` | OiMetadataEditor, OiFileInfoDialog |
| `metric` | OiMetric |
| `modal` | OiDialog, OiFocusTrap |
| `navigation` | OiSidebar, OiBottomBar, OiTabs, OiBreadcrumbs, OiDrawer, OiNavMenu |
| `notification` | OiNotificationCenter, OiToast |
| `number` | OiNumberInput, OiFieldDisplay(number) |
| `onboarding` | OiTour, OiSpotlight, OiWhatsNew |
| `order` | OiCartItem, OiCartSummary, OiProductData, OiOrderSummary, OiOrderSummaryLine |
| `overlay` | OiDialog, OiToast, OiSheet, OiContextMenu, OiPopover, OiPanel |
| `pagination` | OiPaginationController, OiPagination, OiTable, OiListView |
| `panel` | OiPanel, OiResizable, OiSplitPane |
| `path` | OiPathBar, OiBreadcrumbs |
| `payment` | OiPaymentOption, OiPaymentMethod |
| `permission` | OiPermissions |
| `phone` | OiFieldDisplay(phone) |
| `picker` | OiDatePicker, OiTimePicker, OiEmojiPicker, OiColorInput |
| `pipeline` | OiPipeline |
| `popover` | OiPopover |
| `presence` | OiAvatar(presence), OiCursorPresence, OiLiveRing |
| `product` | OiProductData, OiProductVariant, OiProductCard, OiProductFilters, OiProductGallery, OiShopProductDetail |
| `progress` | OiProgress, OiStepper |
| `radar` | OiRadarChart |
| `radio` | OiRadio |
| `rating` | OiStarRating, OiScaleRating |
| `reaction` | OiReactionBar |
| `reorder` | OiReorderable, OiKanban |
| `resource` | OiResourcePage |
| `resize` | OiResizable, OiSplitPane |
| `responsive` | OiResponsive, OiBreakpoint, OiGrid, OiPage |
| `rich-text` | OiRichEditor, OiMarkdown |
| `row` | OiRow, OiListTile |
| `sankey` | OiSankey |
| `schedule` | OiCalendar, OiGantt, OiScheduler |
| `scroll` | OiVirtualList, OiVirtualGrid, OiInfiniteScroll, OiScrollbar |
| `search` | OiSearch, OiComboBox, OiCommandBar, OiFilterBar, OiTextInput.search |
| `select` | OiSelect, OiComboBox, OiRadio |
| `settings` | OiSettingsDriver, OiAccordionSettings, etc. |
| `sheet` | OiSheet |
| `shipping` | OiShippingOption, OiShippingMethod |
| `shop` | OiPriceTag, OiQuantitySelector, OiProductData, OiCartItem, OiCartSummary, OiCartPanel, OiMiniCart, OiOrderSummary, OiCartItemRow, OiCouponInput, OiOrderSummaryLine, OiProductCard, OiPaymentOption, OiShippingOption, OiStockBadge, OiWishlistButton, OiProductFilters, OiProductGallery, OiCheckout, OiShopProductDetail |
| `sidebar` | OiSidebar, OiFileSidebar |
| `skeleton` | OiSkeletonGroup, OiShimmer |
| `slider` | OiSlider |
| `social` | OiChat, OiComments, OiReactionBar, OiAvatarStack |
| `sort` | OiTable, OiListView, OiFilterBar, OiSortButton |
| `split` | OiSplitPane, OiButton.split |
| `state-diagram` | OiStateDiagram |
| `stepper` | OiStepper, OiWizard |
| `stock` | OiStockBadge |
| `storage` | OiStorageIndicator, OiSettingsDriver |
| `surface` | OiSurface |
| `switch` | OiSwitch |
| `tab` | OiTabs |
| `table` | OiTable, OiTableColumn, OiTableController |
| `tag` | OiTagInput, OiBadge |
| `text` | OiLabel, OiTextInput |
| `theme` | OiThemeData, OiColorScheme, OiDynamicTheme, OiThemePreview |
| `theme-toggle` | OiThemeToggle |
| `thumbs` | OiThumbs |
| `time` | OiTimeInput, OiTimePicker, OiRelativeTime |
| `timeline` | OiTimeline, OiGantt |
| `toast` | OiToast |
| `toggle` | OiToggleButton, OiSwitch, OiCheckbox |
| `toolbar` | OiButtonGroup, OiFileToolbar |
| `tooltip` | OiTooltip |
| `tour` | OiTour, OiSpotlight |
| `tree` | OiTree, OiFolderTreeItem, OiTreemap |
| `treemap` | OiTreemap |
| `typography` | OiLabel, OiTextTheme |
| `upload` | OiUploadDialog, OiFileInput, OiFileExplorer |
| `url` | OiFieldDisplay(url) |
| `user` | OiAvatar, OiAvatarStack, OiUserMenu |
| `user-menu` | OiUserMenu |
| `validation` | OiForm, OiFormField |
| `video` | OiVideoPlayer |
| `virtual-scroll` | OiVirtualList, OiVirtualGrid |
| `visibility` | OiVisibility |
| `visualization` | OiFunnelChart, OiGauge, OiHeatmap, OiRadarChart, OiSankey, OiTreemap |
| `wizard` | OiWizard, OiStepper |
| `wishlist` | OiWishlistButton |
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

### Planned Shop/E-commerce Modules

- **OiProductCatalog** — Product grid/list with filters and search
- **OiOrderHistory** — Order list with status and dates
- **OiOrderDetail** — Single order with items, timeline, invoice

---

## Maintenance

This document must be kept in sync with the codebase. When widgets are added, modified, or removed:
1. Update the relevant section in this file
2. Update the Tags Index
3. Update the Decision Matrix if applicable
4. Move items from "Planned" to the main catalog when implemented
5. Update the doc/ documentation folder as well
