# Theme Customizability Extension Analysis

**Date:** 2026-03-26
**Updated:** 2026-03-27 — Phase 1–5 of the extension plan implemented
**Context:** Applying the TapTap Design System (Figma) as "Blue Danube" theme to obers_ui

---

## 1. Theme Gaps — Things That Need More Customizability

### 1.1 Button: No per-variant color overrides — **IMPLEMENTED**

**Resolved:** `OiButtonThemeData` now exposes `height`, `minWidth`, `iconSize`, `iconGap`, and per-variant style overrides (`primaryStyle`, `outlineStyle`, `ghostStyle`, `destructiveStyle`, `softStyle`, `secondaryStyle`) via the new `OiButtonVariantStyle` class. All new fields are nullable (opt-in). Components read these fields with fallback to swatch-derived defaults. Blue Danube, Finesse themes use the new fields.

**Original problem:** The TapTap design system uses distinct color schemes per button variant:
- **Primary:** bg #15C5CE, hover #47CFD6, pressed #00ABB6, disabled #B0EBEC
- **Outline:** border #E1E1E1 default, border #47CFD6 on hover, text changes to match
- **Ghost:** transparent bg, hover #F5F5F5, pressed #E1E1E1
- **Link:** text #15C5CE, hover #47CFD6

Currently `OiButtonThemeData` only exposes `borderRadius`, `padding`, and `textStyle`. There is no way to customize per-variant background colors, hover states, border colors, or disabled appearance.

**Recommendation:** Extend `OiButtonThemeData` with:
```dart
class OiButtonThemeData {
  // existing
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final TextStyle? textStyle;

  // NEW: per-variant color overrides
  final OiButtonVariantColors? primaryColors;
  final OiButtonVariantColors? outlineColors;
  final OiButtonVariantColors? ghostColors;
  final OiButtonVariantColors? linkColors;
  final OiButtonVariantColors? dangerColors;

  // NEW: size variants
  final double? height;
  final double? minWidth;
  final double? iconSize;
  final double? iconGap; // gap between icon and label
}

class OiButtonVariantColors {
  final Color? background;
  final Color? backgroundHover;
  final Color? backgroundPressed;
  final Color? backgroundDisabled;
  final Color? foreground;
  final Color? foregroundHover;
  final Color? foregroundDisabled;
  final Color? border;
  final Color? borderHover;
  final Color? borderPressed;
  final Color? borderDisabled;
}
```

### 1.2 Slider: No theme data at all — **IMPLEMENTED**

**Resolved:** `OiSliderThemeData` added to `OiComponentThemes` as `slider`. Covers `trackHeight`, `trackRadius`, `activeTrackColor`, `inactiveTrackColor`, `thumbSize`, `thumbColor`, `thumbBorderColor`, `thumbBorderWidth`, `tooltipBackgroundColor`, `tooltipBorderRadius`, `tooltipTextStyle`, `markColor`, `markLabelColor`, `markLabelStyle`. Note: the `OiSlider` widget itself does not yet exist — this is theme scaffolding for when it is built.

**Original problem:** There is no `OiSliderThemeData` in `OiComponentThemes`. The TapTap slider has very specific styling:
- Track: 4px height, #EEEEEE inactive, #47CFD6 active, 10px pill radius
- Thumb: 12px circle, white with primary border
- Tooltip: black at 80% opacity, 4px radius, 8px padding
- Marks: 2px wide, 8px tall ticks with #CACACA labels

**Recommendation:** Add a new component theme:
```dart
class OiSliderThemeData {
  final double? trackHeight;
  final BorderRadius? trackRadius;
  final Color? activeTrackColor;
  final Color? inactiveTrackColor;
  final double? thumbSize;
  final Color? thumbColor;
  final Color? thumbBorderColor;
  final double? thumbBorderWidth;
  final Color? tooltipBackground;
  final double? tooltipOpacity;
  final BorderRadius? tooltipRadius;
  final Color? markColor;
  final Color? markLabelColor;
  final TextStyle? markLabelStyle;
  final TextStyle? tooltipTextStyle;
}
```

### 1.3 Toast/Message: No color or layout overrides — **IMPLEMENTED**

**Resolved:** `OiToastThemeData` extended with `padding`, `iconSize`, `gap`, `backgroundColor`, `shadow`. `OiToast` reads all new fields with fallback to prior defaults. Finesse theme applies custom padding (20×12).

**Original problem:** `OiToastThemeData` only has `borderRadius` and `elevation`. TapTap toasts use:
- Specific padding (16px horizontal, 8px vertical)
- Icon+text gap of 8px
- Status-specific icon colors
- White bg with Elevation 3 shadow

**Recommendation:** Extend:
```dart
class OiToastThemeData {
  final BorderRadius? borderRadius;
  final double? elevation;
  // NEW
  final EdgeInsets? padding;
  final double? iconSize;
  final double? gap; // between icon and text
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final Color? infoIconColor;
  final Color? successIconColor;
  final Color? errorIconColor;
  final Color? warningIconColor;
}
```

### 1.4 Dialog: No padding, shadow, or button layout overrides — **IMPLEMENTED**

**Resolved:** `OiDialogThemeData` extended with `contentPadding`, `titleBodyGap`, `contentButtonGap`, `buttonGap`, `backgroundColor`, `shadow`. `OiDialog` reads all new fields. Finesse theme applies `contentPadding: EdgeInsets.all(24)`.

**Original problem:** `OiDialogThemeData` only has `borderRadius` and `maxWidth`. TapTap dialogs have:
- 24px padding
- Specific gap between content and button grid (32px)
- 16px gap between title and body
- 8px gap between buttons
- Right-aligned button grid

**Recommendation:** Extend:
```dart
class OiDialogThemeData {
  final BorderRadius? borderRadius;
  final double? maxWidth;
  // NEW
  final EdgeInsets? padding;
  final double? titleBodyGap;
  final double? contentButtonGap;
  final double? buttonGap;
  final TextStyle? titleStyle;
  final TextStyle? bodyStyle;
  final Color? backgroundColor;
  final List<BoxShadow>? shadow;
}
```

### 1.5 Input/TextField: No height, placeholder color, or label style — **PARTIALLY IMPLEMENTED**

**Resolved:** `OiTextInputThemeData` extended with `height`, `placeholderColor`, `backgroundColor`, `focusBackgroundColor`, `disabledBackgroundColor`. `OiInputFrame` reads background colors; `OiRawInput` reads `placeholderColor`. Label text style above the field remains unimplemented.

**Original problem:** `OiTextInputThemeData` covers borders well but misses:
- Input field height
- Placeholder/hint text color (TapTap uses #CACACA / Neutral 400)
- Label text style above the field
- Focused label color

**Recommendation:** Extend:
```dart
class OiTextInputThemeData {
  // existing fields...
  // NEW
  final double? height;
  final Color? placeholderColor;
  final TextStyle? labelStyle;
  final Color? labelFocusColor;
  final Color? backgroundColor;
  final Color? focusBackgroundColor;
}
```

### 1.6 Badge: No color variant overrides — **IMPLEMENTED**

**Resolved:** `OiBadgeThemeData` extended with `padding`, `textStyle`, `height`. `OiBadge` reads all new fields. Arco theme uses `borderRadius: BorderRadius.circular(2)` (sharp); Blue Danube uses `circular(4)`.

**Original problem:** `OiBadgeThemeData` only has `borderRadius`. TapTap badges have specific colors per status variant and the padding/text size differs from our defaults.

**Recommendation:** Extend:
```dart
class OiBadgeThemeData {
  final BorderRadius? borderRadius;
  // NEW
  final EdgeInsets? padding;
  final TextStyle? textStyle;
  final double? height;
}
```

### 1.7 Checkbox/Switch: No color overrides — **IMPLEMENTED**

**Resolved:** `OiCheckboxThemeData` extended with `checkedColor`, `uncheckedBorderColor`, `checkmarkColor`. `OiSwitchThemeData` extended with `activeTrackColor`, `inactiveTrackColor`, `thumbColor`. Both components read the new fields. Arco themes apply all six overrides to match the Arco blue palette.

**Original problem:** `OiCheckboxThemeData` only has `size` and `borderRadius`. `OiSwitchThemeData` only has `width` and `height`. Neither allows customizing:
- Checked/unchecked colors
- Border colors
- Track/thumb colors for switch

**Recommendation:**
```dart
class OiCheckboxThemeData {
  final double? size;
  final BorderRadius? borderRadius;
  // NEW
  final Color? checkedColor;
  final Color? uncheckedBorderColor;
  final Color? checkmarkColor;
}

class OiSwitchThemeData {
  final double? width;
  final double? height;
  // NEW
  final Color? activeTrackColor;
  final Color? inactiveTrackColor;
  final Color? thumbColor;
}
```

### 1.8 Card: No border or shadow override — **IMPLEMENTED**

**Resolved:** `OiCardThemeData` extended with `backgroundColor`, `borderColor`, `borderWidth`, `shadow`. `OiCard` reads all new fields, constructing an `OiBorderStyle` from `borderColor`/`borderWidth` when set, and using `shadow` in place of the elevation-derived default. Finesse themes apply indigo-tinted card shadows.

**Original problem:** `OiCardThemeData` has `borderRadius`, `elevation`, `padding` but no way to set:
- Border color/width
- Specific shadow (instead of elevation integer)
- Background color override

**Recommendation:**
```dart
class OiCardThemeData {
  // existing...
  // NEW
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final List<BoxShadow>? shadow; // explicit shadow instead of elevation
}
```

### 1.9 Tabs: Missing tab text style, height, padding — **IMPLEMENTED**

**Resolved:** `OiTabsThemeData` extended with `indicatorThickness`, `labelStyle`, `activeLabelColor`, `inactiveLabelColor`, `tabPadding`. `OiTabs` reads all new fields. Arco and Finesse themes apply label colors; Blue Danube inherits from primary swatch.

**Original problem:** `OiTabsThemeData` only has `indicatorColor` and `height`. TapTap tabs need:
- Tab text style customization
- Active/inactive text colors
- Indicator thickness
- Tab padding

**Recommendation:**
```dart
class OiTabsThemeData {
  final Color? indicatorColor;
  final double? height;
  // NEW
  final double? indicatorThickness;
  final TextStyle? labelStyle;
  final Color? activeLabelColor;
  final Color? inactiveLabelColor;
  final EdgeInsets? tabPadding;
}
```

### 1.10 Global: No per-state color transformation control

**Problem:** The `OiEffectsTheme` allows hover/focus/active overlays, but the TapTap design uses specific color steps from its palette (e.g., hover = Primary 500, pressed = Primary 700) rather than computed overlays. There's no way to say "use this exact color for the hover state of primary elements."

**Recommendation:** Consider allowing `OiEffectsTheme` to accept optional color overrides per semantic swatch state, or alternatively let the `OiColorSwatch` fields map directly to interactive states:
```dart
class OiColorSwatch {
  final Color base;      // default
  final Color light;     // hover (currently: +20% lightness)
  final Color dark;      // pressed (currently: -20% lightness)
  final Color muted;     // disabled
  final Color foreground; // text on swatch
}
```
This already maps well! The issue is that components may not consistently use `swatch.light` for hover and `swatch.dark` for pressed. Ensure all interactive components follow this contract.

---

## 2. Missing UI Elements

### 2.1 Slider Component (OiSlider)

**Status:** Not found in obers_ui component library.

**Description:** A range slider with single and double thumb support.

**Features:**
- Single value slider
- Range slider (double thumb)
- Tooltip showing current value
- Tick marks with labels
- Disabled state
- Step increments

**Recommended API:**
```dart
OiSlider({
  required double value,
  required ValueChanged<double> onChanged,
  double min = 0,
  double max = 100,
  int? divisions,
  String? label,
  bool showTooltip = false,
  bool showMarks = false,
  bool enabled = true,
  String semanticLabel,
})

OiRangeSlider({
  required RangeValues values,
  required ValueChanged<RangeValues> onChanged,
  double min = 0,
  double max = 100,
  int? divisions,
  bool showTooltip = false,
  bool showMarks = false,
  bool enabled = true,
  String semanticLabel,
})
```

### 2.2 Tag Component (OiTag)

**Status:** Not in obers_ui. TapTap has tag/chip components on the cover.

**Description:** Compact labels for categorization, filtering, or selection.

**Features:**
- Removable (with X button)
- Selectable (toggle)
- Color variants (primary, neutral, status colors)
- Size variants (small, medium)
- Icon prefix support

**Recommended API:**
```dart
OiTag({
  required String label,
  VoidCallback? onRemove,
  VoidCallback? onTap,
  bool selected = false,
  OiTagVariant variant = OiTagVariant.neutral,
  OiTagSize size = OiTagSize.medium,
  Widget? leading,
  String semanticLabel,
})

enum OiTagVariant { primary, neutral, success, warning, error, info }
enum OiTagSize { small, medium }
```

### 2.3 Message/Banner Component (OiMessage)

**Status:** Partially covered by OiToast. TapTap has inline persistent messages vs temporary toasts.

**Description:** Inline feedback messages that persist in the layout (not floating overlays).

**Features:**
- Status variants: info, success, error, warning
- Icon + text layout
- Optional close button
- Optional action button
- Can be used inline in forms or at page top

**Recommended API:**
```dart
OiMessage({
  required String message,
  OiMessageStatus status = OiMessageStatus.info,
  VoidCallback? onClose,
  Widget? action,
  String semanticLabel,
})

enum OiMessageStatus { info, success, error, warning }
```

### 2.4 Donut/Ring Chart (for data visualization)

**Status:** The TapTap cover shows a donut chart with labels. obers_ui_charts may already cover this, but worth verifying.

**Description:** Ring chart showing proportional segments with center label.

**Features:**
- Multiple segments with colors from chart palette
- Center content (total, label)
- External labels with leader lines
- Hover/tap interaction per segment
- Configurable ring thickness

### 2.5 Elevation/Surface Preview Component

**Status:** Not in obers_ui — TapTap shows an elevation reference card.

**Description:** Not a user-facing component but useful for a theme preview tool showing all shadow levels. Useful for the `OiThemePreview` tool.

---

## 3. Additional Findings from Arco Design System

### 3.1 Component Size Scale — **IMPLEMENTED**

**Resolved:** `OiComponentSizeScale` added to `OiThemeData` as `componentSizes`. Ships with `OiComponentSizeScale.standard()` (28/36/44) and `OiComponentSizeScale.arco()` (28/32/36) presets. Arco themes pass `componentSizes: const OiComponentSizeScale.arco()`. Components can reference `context.theme.componentSizes.medium` for the default interactive height.

**Original problem:** Arco Design defines 4 component sizes (mini=24px, small=28px, default=32px, large=36px). Our theme system has no global component size scale. Each component defines its own heights internally.

**Recommendation:** Add a global `OiSizeScale` to the theme:
```dart
class OiSizeScale {
  final double mini;    // 24px
  final double small;   // 28px
  final double medium;  // 32px  (default)
  final double large;   // 36px
}
```
This would allow buttons, inputs, selects, and other interactive components to reference a consistent height scale from the theme.

### 3.2 Fill Colors

**Problem:** Arco distinguishes between "fill" colors (for interactive element backgrounds like hover fills on ghost buttons, input fills) and "surface" colors (for cards, panels). Our `OiColorScheme` has `surfaceHover` / `surfaceActive` but no distinct fill scale.

**Recommendation:** Consider adding `fill1`-`fill4` to `OiColorScheme` for subtle interactive fills that differ from surface colors. Arco uses `fill-1` through `fill-4` with progressively darker neutrals.

### 3.3 Extended Color Palette (13+ hue families)

**Problem:** Arco provides 13 hue families (red, orangeRed, orange, gold, yellow, lime, green, cyan, blue, arcoblue, purple, pinkPurple, magenta). Our theme exposes 6 semantic swatches (primary, accent, success, warning, error, info) plus a chart palette.

**Recommendation:** The current approach of semantic swatches + chart palette is sufficient for theming. The 13-hue families are mainly for data visualization and custom use cases, which can be handled via the `chart` list or custom extensions. No change needed.

### 3.4 Multiple Shadow Directions

**Problem:** Arco defines directional shadow variants (shadow-up, shadow-down, shadow-left, shadow-right) in addition to centered shadows. Our `OiShadowScale` only provides centered shadows.

**Recommendation:** Low priority — directional shadows are rarely needed. If required, they can be constructed ad-hoc from the existing shadow colors.

---

## 4. Summary of Priority Actions

| Priority | Item | Effort | Status |
| -------- | ---- | ------ | ------ |
| **High** | Extend OiButtonThemeData with per-variant colors | Medium | ✅ DONE |
| **High** | Add OiSliderThemeData | Small | ✅ DONE |
| **High** | Extend OiToastThemeData with padding/colors | Small | ✅ DONE |
| **Medium** | Extend OiDialogThemeData with padding/gaps | Small | ✅ DONE |
| **Medium** | Extend OiTextInputThemeData with height/placeholder | Small | ✅ DONE (label style pending) |
| **Medium** | Add global OiComponentSizeScale | Small | ✅ DONE |
| **Medium** | Extend OiCardThemeData with border/shadow | Small | ✅ DONE |
| **Medium** | Extend OiCheckboxThemeData with colors | Small | ✅ DONE |
| **Medium** | Extend OiSwitchThemeData with colors | Small | ✅ DONE |
| **Medium** | Extend OiTabsThemeData with label styles | Small | ✅ DONE |
| **Low** | Extend OiBadgeThemeData with padding/textStyle | Small | ✅ DONE |
| **Medium** | Add OiSlider/OiRangeSlider component | Large | ⬜ TODO |
| **Medium** | Add OiTag component | Medium | ⬜ TODO |
| **Low** | Add OiMessage inline component | Medium | ⬜ TODO |
| **Low** | Ensure swatch.light/dark used consistently for hover/pressed | Medium | ⬜ TODO |
