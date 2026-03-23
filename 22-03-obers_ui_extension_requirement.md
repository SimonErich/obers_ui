# obers_ui Extension Requirements — 2026-03-22

> **Scope:** New widgets and enhancements to existing widgets in the `obers_ui` library.
> **Motivation:** Consumer projects cannot fully eliminate Material/Cupertino dependencies without these additions.
> **Priority:** Items are ordered by impact (number of Material widgets they unblock).

---

## Table of Contents

1. [REQ-01: OiTextInput — Form Validation & Missing Properties](#req-01-oitextinput--form-validation--missing-properties)
2. [REQ-02: OiDialogShell — Low-Level Dialog Container](#req-02-oidialogshell--low-level-dialog-container)
3. [REQ-03: OiRefreshIndicator — Pull-to-Refresh](#req-03-oirefreshindicator--pull-to-refresh)
4. [REQ-04: OiNavigationRail — Vertical Navigation Rail](#req-04-oinavigationrail--vertical-navigation-rail)
5. [REQ-05: OiSliverHeader — Sticky Scroll Header](#req-05-oisliverheader--sticky-scroll-header)
6. [REQ-06: OiPageTransition — Non-Material Page Route](#req-06-oipagetransition--non-material-page-route)

---

## REQ-01: OiTextInput — Form Validation & Missing Properties

**Priority:** Critical
**Tier:** Component (Tier 2)
**Type:** Enhancement to existing widget

### Problem

`OiTextInput` currently supports text entry with label, hint, error display, input formatters, and keyboard type. However, it **cannot participate in Flutter's `Form` widget validation lifecycle**. Projects that need form validation (login forms, address forms, checkout flows, OTP entry) are forced to fall back to Material's `TextFormField`.

Additionally, several common text input use cases require properties that `OiTextInput` does not expose.

### Required New Properties

#### 1. Form Validation Integration

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `validator` | `String? Function(String?)?` | `null` | Validation function called by ancestor `Form.validate()`. Return `null` for valid, error string for invalid. When non-null, the widget internally wraps with `FormField<String>`. |
| `autovalidateMode` | `AutovalidateMode?` | `null` | Controls when validation runs automatically. `null` defers to the ancestor `Form`'s mode. Values: `disabled`, `onUserInteraction`, `always`. |
| `onSaved` | `void Function(String?)?` | `null` | Called by `Form.save()` with the current value. |

**Implementation Notes:**
- When `validator` is provided, `OiTextInput` should internally use a `FormField<String>` to integrate with Flutter's `Form` widget.
- The `error` prop (existing, manually set) should take priority over `validator`-generated errors when both are present. This allows external async validation to override sync form validation.
- When a `validator` error is active, it should render identically to a manually set `error` — same color, same position, same animation.
- The widget must expose a `FormFieldState` via a `GlobalKey<FormFieldState<String>>` so consumers can imperatively validate, reset, or read the value.

#### 2. Text Behavior Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `textCapitalization` | `TextCapitalization` | `.none` | Controls automatic capitalization. `.words` for names, `.sentences` for prose, `.characters` for codes. |
| `textAlign` | `TextAlign` | `.start` | Text alignment within the input. `.center` for OTP/PIN fields, `.end` for right-aligned numeric entry. |
| `showCounter` | `bool` | `false` | When `true` and `maxLength` is set, shows a character counter (e.g., "3/50") below the input. When `false`, the counter is hidden even if `maxLength` is set. |
| `counterBuilder` | `Widget Function(BuildContext, {required int currentLength, required int? maxLength, required bool isFocused})?` | `null` | Custom counter widget builder. Overrides default counter when provided. |

#### 3. Interaction Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `onTap` | `VoidCallback?` | `null` | Called when the input is tapped. Useful for opening pickers or custom overlays on tap. |
| `onTapOutside` | `void Function(PointerDownEvent)?` | `null` | Called when a tap occurs outside the input. Useful for custom dismiss/blur behavior. |
| `onEditingComplete` | `VoidCallback?` | `null` | Called when the user submits (e.g., presses Enter) before `onSubmitted`. Useful for preventing focus from advancing. |

### Named Constructor Addition

#### `OiTextInput.otp()`

A preconfigured constructor optimized for one-time-password / PIN / verification code entry:

```dart
OiTextInput.otp({
  required int length,            // Number of digits (typically 4 or 6)
  ValueChanged<String>? onCompleted, // Called when all digits are entered
  ValueChanged<String>? onChanged,
  bool obscure = false,           // Hide entered digits (for PINs)
  bool autofocus = true,
  bool enabled = true,
  String? error,
})
```

**Behavior:**
- Renders as a row of individual digit boxes (not a single text field)
- Each box is a fixed square (48x56 dp default, respects density)
- Digits-only input filtering applied automatically
- Auto-advances focus to next box on digit entry
- Supports backspace to move to previous box
- Supports paste of full code (distributes across boxes)
- Shows a cursor/highlight in the currently focused box
- `onCompleted` fires when all boxes are filled
- Error state highlights all boxes with error color/border
- Accessible: announces "digit N of M" for each box

**Theming:** Should use `OiTextInputThemeData` for colors/borders, with additional `otp` sub-theme for box dimensions and gap spacing.

**Why as a named constructor:** OTP entry is a common cross-project pattern (auth flows, checkout verification, 2FA). Building it into `OiTextInput` avoids every consumer project reimplementing the same complex focus-management logic.

### Updated API Surface

```dart
class OiTextInput extends StatelessWidget {
  const OiTextInput({
    // --- Existing (unchanged) ---
    this.controller,
    this.label,
    this.hint,
    this.placeholder,
    this.error,
    this.leading,
    this.trailing,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.autofocus = false,
    this.inputFormatters,
    this.focusNode,

    // --- NEW ---
    this.validator,
    this.autovalidateMode,
    this.onSaved,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.showCounter = false,
    this.counterBuilder,
    this.onTap,
    this.onTapOutside,
    this.onEditingComplete,
  });

  const OiTextInput.search({ /* existing */ });

  const OiTextInput.otp({
    required this.length,
    this.onCompleted,
    this.onChanged,
    this.obscure = false,
    this.autofocus = true,
    this.enabled = true,
    this.error,
  });
}
```

### Theming

Extend `OiTextInputThemeData` with:

```dart
class OiTextInputThemeData {
  // ... existing fields ...

  /// Border color when validation fails (defaults to colorScheme.error.base)
  final Color? validationErrorColor;

  /// Animation duration for error text appearance
  final Duration? errorAnimationDuration;

  /// OTP-specific sub-theme
  final OiOtpThemeData? otp;
}

class OiOtpThemeData {
  final double boxWidth;          // Default: 48
  final double boxHeight;         // Default: 56
  final double gap;               // Default: 8 (spacing between boxes)
  final BorderRadius boxRadius;   // Default: medium
  final Color? filledBoxColor;    // Background when digit is entered
  final Color? emptyBoxColor;     // Background when empty
  final Color? focusedBoxColor;   // Background when focused
  final TextStyle? digitStyle;    // Text style for digits
}
```

### Accessibility

- Error messages must be announced via `Semantics(liveRegion: true)` when they appear
- Counter text must be part of the semantic description when visible
- OTP boxes: each box must have `Semantics(label: 'Digit $n of $total')` and announce the entered digit
- OTP paste: announce "Code pasted" via live region
- `textCapitalization` should not affect screen reader behavior

### Test Scenarios

#### Form Validation Tests
1. **Sync validator displays error:** Provide a validator that returns "Required". Submit form. Assert error text is visible and styled with error color.
2. **Validator clears on valid input:** Enter valid text. Assert error text is gone.
3. **autovalidateMode.onUserInteraction:** Type, then clear. Assert error appears after clearing without explicit form.validate().
4. **autovalidateMode.always:** Assert error is visible immediately on mount for empty required field.
5. **Manual error overrides validator:** Set `error: "Server error"` AND provide a passing validator. Assert "Server error" is displayed, not validator result.
6. **Form.save() calls onSaved:** Provide onSaved callback. Call form.save(). Assert callback received current value.
7. **FormField key access:** Create with GlobalKey<FormFieldState>. Assert key.currentState is non-null and `.value` matches controller text.
8. **Multiple OiTextInputs in one Form:** Place 3 inputs with validators in a Form. Validate. Assert all 3 show their respective errors.

#### Text Behavior Tests
9. **textCapitalization.words:** Type "john doe". Assert displayed text is "John Doe" (on supported platforms; test the property is forwarded to underlying input).
10. **textAlign.center:** Assert text content is centered within the input bounds.
11. **showCounter true with maxLength:** Set maxLength=50, showCounter=true. Type "Hello". Assert counter shows "5/50".
12. **showCounter false with maxLength:** Set maxLength=50, showCounter=false. Assert no counter widget is rendered.
13. **Custom counterBuilder:** Provide a counterBuilder. Assert the custom widget is rendered instead of default counter.

#### OTP Constructor Tests
14. **Renders correct number of boxes:** `OiTextInput.otp(length: 6)`. Assert 6 input boxes are rendered.
15. **Digit entry auto-advances focus:** Enter "1" in box 0. Assert focus moved to box 1.
16. **Backspace moves to previous box:** Focus box 3 (empty). Press backspace. Assert focus moved to box 2 and its content is cleared.
17. **Paste distributes digits:** Paste "123456" into box 0. Assert boxes show [1,2,3,4,5,6] and `onCompleted` is called with "123456".
18. **Partial paste:** Paste "12" into box 0. Assert boxes show [1,2,_,_,_,_] and focus is on box 2.
19. **onCompleted fires when full:** Enter digits one by one until all boxes filled. Assert `onCompleted` called exactly once.
20. **Error state on all boxes:** Set `error: "Invalid code"`. Assert all boxes have error border color and error text is visible below.
21. **Disabled state:** Set `enabled: false`. Assert all boxes are non-interactive and visually dimmed.
22. **Non-digit input rejected:** Type "a" in a box. Assert the box remains empty.
23. **Obscured digits:** Set `obscure: true`. Enter digits. Assert dots/bullets are shown instead of digits.

#### Interaction Tests
24. **onTap fires on tap:** Tap the input. Assert onTap callback was called.
25. **onTapOutside fires:** Focus input, tap outside. Assert onTapOutside callback was called.
26. **onEditingComplete fires before onSubmitted:** Press Enter. Assert onEditingComplete fires first, then onSubmitted.

#### Accessibility Tests
27. **Error announced as live region:** Set validator, trigger error. Assert Semantics tree contains a live region with the error text.
28. **OTP box semantic labels:** Assert each box has "Digit N of M" semantic label.
29. **OTP paste announcement:** Paste code. Assert "Code pasted" is announced.

---

## REQ-02: OiDialogShell — Low-Level Dialog Container

**Priority:** High
**Tier:** Component (Tier 2)
**Type:** New widget

### Problem

`OiDialog` provides an opinionated dialog with title bar, content area, and action buttons. This is ideal for standard confirm/form dialogs but **too restrictive** for custom dialog layouts — wizards, multi-step flows, embedded content, or branded experiences that need full control over the dialog body.

Projects need a **minimal dialog container** that provides only the visual shell (rounded card with shadow, centered in overlay, constrained sizing) without any internal layout decisions.

### Description

`OiDialogShell` is a low-level dialog container. It renders a themed surface (card with shadow) centered in the viewport, constrained to reasonable max dimensions, and accepts a single `child` widget with no further layout imposed.

It is to `OiDialog` what `OiRawInput` is to `OiTextInput` — the unstyled/minimal building block.

### API Design

```dart
class OiDialogShell extends StatelessWidget {
  const OiDialogShell({
    required this.child,
    this.width,
    this.minWidth,
    this.maxWidth,
    this.maxHeight,
    this.backgroundColor,
    this.borderRadius,
    this.elevation,
    this.padding,
    this.barrierDismissible = true,
    this.barrierColor,
    this.semanticLabel,
    super.key,
  });

  /// The dialog content. No layout constraints are applied to the child
  /// beyond the container's own max width/height.
  final Widget child;

  /// Fixed width. When set, overrides min/maxWidth.
  final double? width;

  /// Minimum width constraint. Default: 280 (readable minimum).
  final double? minWidth;

  /// Maximum width constraint. Default: 90% of viewport width.
  final double? maxWidth;

  /// Maximum height constraint. Default: 90% of viewport height.
  final double? maxHeight;

  /// Background color. Default: theme surface color.
  final Color? backgroundColor;

  /// Corner radius. Default: theme dialog radius.
  final BorderRadius? borderRadius;

  /// Shadow elevation tier. Default: `OiElevation.dialog` (large shadow).
  final OiElevation? elevation;

  /// Inner padding. Default: none (child controls its own padding).
  final EdgeInsets? padding;

  /// Whether tapping the barrier dismisses the dialog.
  /// Only meaningful when shown via OiDialogShell.show().
  final bool barrierDismissible;

  /// Barrier (scrim) color. Default: semi-transparent black.
  final Color? barrierColor;

  /// Semantic label for the dialog (for screen readers).
  /// Announced when the dialog opens.
  final String? semanticLabel;

  /// Show the dialog shell in the overlay.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? semanticLabel,
    // ... all other OiDialogShell props forwarded
  });
}
```

### Static Show Method

`OiDialogShell.show()` provides the complete show-and-dismiss lifecycle:
- Pushes a route (or overlay entry via `OiOverlays`) with barrier
- Returns a `Future<T?>` that completes when the dialog is dismissed
- Handles `Navigator.pop(context, result)` to return values
- Manages barrier tap dismiss (if `barrierDismissible`)
- Traps focus within the dialog (uses `OiFocusTrap` internally)
- Restores focus to the previously focused element on dismiss
- Animates in/out using theme animation curves and durations

### Theming

Add to `OiComponentThemes`:

```dart
class OiDialogShellThemeData {
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final OiElevation? elevation;
  final Color? barrierColor;
  final double? defaultMinWidth;
  final double? defaultMaxWidthFraction;  // 0.0-1.0, default 0.9
  final double? defaultMaxHeightFraction; // 0.0-1.0, default 0.9
  final Duration? enterDuration;
  final Duration? exitDuration;
  final Curve? enterCurve;
  final Curve? exitCurve;
}
```

### Relationship to OiDialog

`OiDialog` should internally use `OiDialogShell` as its container. This ensures visual consistency (same shadows, radius, barrier) between opinionated and custom dialogs.

### Accessibility

- On open: focus moves inside the dialog; previous focus is remembered
- On close: focus returns to the previously focused element
- `OiFocusTrap` wraps the child — Tab cycles within the dialog
- Escape key dismisses (when `barrierDismissible` is true)
- `Semantics(scopesRoute: true, namesRoute: true, label: semanticLabel)` wraps the dialog
- Barrier has `Semantics(label: 'Close dialog')` when dismissible

### Test Scenarios

1. **Renders child:** Provide a child widget. Assert it is visible and centered on screen.
2. **Respects width:** Set `width: 400`. Assert the rendered container is exactly 400px wide.
3. **Respects maxWidth:** Set no width, child wants 2000px. Assert container is at most 90% of viewport width.
4. **Respects maxHeight:** Child wants 5000px tall. Assert container is at most 90% of viewport height (with scroll or clip).
5. **Custom backgroundColor:** Set a custom color. Assert the container background matches.
6. **Custom borderRadius:** Set custom radius. Assert corners are clipped to that radius.
7. **Default elevation shadow:** Assert a box shadow is present matching the dialog elevation tier.
8. **Barrier dismisses:** Show via `.show()` with `barrierDismissible: true`. Tap barrier. Assert dialog is dismissed.
9. **Barrier does not dismiss:** Show with `barrierDismissible: false`. Tap barrier. Assert dialog remains.
10. **Escape key dismisses:** Show dialog. Press Escape. Assert dialog is dismissed.
11. **Focus trap:** Show dialog with two buttons. Press Tab repeatedly. Assert focus cycles within the dialog only.
12. **Focus restore on dismiss:** Focus a button. Show dialog. Dismiss. Assert the original button regains focus.
13. **Returns value on pop:** Show dialog. Call `Navigator.pop(context, 42)`. Assert the returned future completes with 42.
14. **Semantic label announced:** Set `semanticLabel: 'Settings dialog'`. Assert semantics tree contains the label.
15. **Dark/light theme consistency:** Render in both light and dark themes. Assert colors come from theme (not hardcoded).
16. **Nested dialogs:** Show a dialog shell inside another dialog shell. Assert both render correctly with independent barriers.
17. **Animation:** Show and dismiss. Assert enter/exit animations play with theme-defined durations and curves.
18. **No padding by default:** Assert the child fills the container with no implicit padding.
19. **Custom padding:** Set `padding: EdgeInsets.all(24)`. Assert child is inset by 24px from container edges.

---

## REQ-03: OiRefreshIndicator — Pull-to-Refresh

**Priority:** High
**Tier:** Component (Tier 2)
**Type:** New widget

### Problem

Flutter's built-in `RefreshIndicator` depends on `MaterialLocalizations`, making it unusable in projects that avoid Material. Projects need a pull-to-refresh gesture handler that:
- Works without any Material dependency
- Uses `OiProgress.circular` for the spinner (visual consistency)
- Is fully themeable via `OiThemeData`
- Meets accessibility requirements (screen reader announcements)

### API Design

```dart
class OiRefreshIndicator extends StatefulWidget {
  const OiRefreshIndicator({
    required this.child,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
    this.triggerDistance = 80.0,
    this.indicatorSize = 28.0,
    this.strokeWidth,
    this.semanticLabel,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    super.key,
  });

  /// The scrollable child widget. Must contain a scrollable
  /// (ListView, CustomScrollView, SingleChildScrollView, etc.).
  final Widget child;

  /// Async callback invoked when the user triggers a refresh.
  /// The indicator remains visible until the Future completes.
  final Future<void> Function() onRefresh;

  /// Color of the progress spinner.
  /// Default: theme primary color.
  final Color? color;

  /// Background color of the indicator container (circle behind spinner).
  /// Default: theme surface color.
  final Color? backgroundColor;

  /// Distance the indicator is inset from the top of the scrollable.
  /// Default: 40.0
  final double displacement;

  /// Additional offset from the top edge (e.g., below a sticky header).
  /// Default: 0.0
  final double edgeOffset;

  /// How far the user must overscroll before a refresh is triggered.
  /// Default: 80.0 dp.
  final double triggerDistance;

  /// Diameter of the progress indicator.
  /// Default: 28.0
  final double indicatorSize;

  /// Stroke width of the progress spinner.
  /// Default: uses OiProgress default.
  final double? strokeWidth;

  /// Screen reader announcement when refresh starts.
  /// Default: "Refreshing".
  final String? semanticLabel;

  /// Predicate to determine which scroll notifications trigger the indicator.
  /// Default: only the primary scrollable.
  final bool Function(ScrollNotification) notificationPredicate;
}
```

### Behavior Specification

#### Pull Phase
1. User overscrolls past the top edge of the scrollable (negative overscroll).
2. As the user drags, a circular progress indicator appears at the top, with opacity and fill proportional to `dragOffset / triggerDistance`.
3. The indicator slides down from `edgeOffset` to `edgeOffset + displacement` as the user pulls.
4. If the user releases before reaching `triggerDistance`, the indicator animates back to hidden.

#### Refresh Phase
5. Once `dragOffset >= triggerDistance`, the refresh is triggered (even before release).
6. The progress indicator switches to indeterminate mode (`OiProgress.circular(indeterminate: true)`).
7. The indicator stays visible at `displacement + edgeOffset` until `onRefresh` completes.
8. A screen reader announcement ("Refreshing" or `semanticLabel`) is made.

#### Completion Phase
9. When the `onRefresh` future completes, the indicator animates back to hidden.
10. A screen reader announcement ("Refresh complete") is made.

#### Edge Cases
- If the user triggers a refresh while one is already in progress, ignore the second pull.
- If the widget is disposed while refreshing, cancel gracefully (no setState after dispose).
- On platforms without overscroll (e.g., desktop with mouse wheel), the indicator should not appear. Desktop users can use an explicit refresh button instead.

### Inner Workings

- Uses `NotificationListener<ScrollNotification>` to detect `OverscrollNotification` (negative direction).
- Tracks cumulative drag offset via `OverscrollNotification.overscroll`.
- Resets on `ScrollEndNotification` (if not refreshing) or when scroll position goes positive.
- Renders via `Stack` with the indicator `Positioned` above the child.
- Uses `AnimationController` for smooth opacity/position transitions (not just `setState`).
- The indicator container is a small circular `OiSurface` with the `OiProgress.circular` inside.

### Theming

Add to `OiComponentThemes`:

```dart
class OiRefreshIndicatorThemeData {
  final Color? indicatorColor;
  final Color? indicatorBackgroundColor;
  final double? displacement;
  final double? triggerDistance;
  final double? indicatorSize;
  final double? strokeWidth;
  final Duration? snapBackDuration;      // Animation when drag released without trigger
  final Duration? completionHideDuration; // Animation when refresh completes
  final Curve? snapBackCurve;
  final Curve? completionCurve;
}
```

### Accessibility

- When refresh starts: announce `semanticLabel` (default: "Refreshing") via `SemanticsService.announce`
- When refresh completes: announce "Refresh complete"
- The indicator itself should be marked as a decorative element (`Semantics(excludeSemantics: true)`) — the announcements handle the information
- Reduced-motion: skip the pull animation, just show/hide the indicator immediately

### Test Scenarios

1. **Indicator appears on overscroll:** Overscroll the child. Assert the progress indicator becomes visible.
2. **Opacity scales with drag distance:** Drag 50% of triggerDistance. Assert indicator opacity is ~0.5.
3. **Trigger fires at triggerDistance:** Drag past triggerDistance. Assert `onRefresh` was called.
4. **Indicator stays during refresh:** Trigger refresh. Assert indicator remains visible (indeterminate mode) until future completes.
5. **Indicator hides after completion:** Complete the refresh future. Assert indicator animates out.
6. **Release before trigger hides indicator:** Drag 50% then release. Assert indicator animates back to hidden. Assert `onRefresh` was NOT called.
7. **No double-trigger:** Trigger refresh, then overscroll again while refreshing. Assert `onRefresh` called only once.
8. **Disposed during refresh:** Trigger refresh, then dispose widget. Assert no errors (no setState after dispose).
9. **Custom color:** Set a custom color. Assert the spinner uses that color.
10. **Custom displacement:** Set `displacement: 100`. Assert indicator appears 100dp from top.
11. **Edge offset:** Set `edgeOffset: 56` (below a header). Assert indicator starts at 56dp.
12. **Custom triggerDistance:** Set `triggerDistance: 40`. Assert refresh triggers after only 40dp of overscroll.
13. **Notification predicate:** Provide a predicate that rejects notifications. Assert indicator never appears.
14. **Screen reader announcement:** Trigger refresh. Assert "Refreshing" is announced. Complete. Assert "Refresh complete" is announced.
15. **Works with ListView:** Wrap a `ListView` in `OiRefreshIndicator`. Pull to refresh. Assert it works.
16. **Works with CustomScrollView:** Wrap a `CustomScrollView`. Pull to refresh. Assert it works.
17. **Works with SingleChildScrollView:** Wrap a `SingleChildScrollView`. Pull to refresh. Assert it works.
18. **Reduced motion:** Enable reduced-motion in accessibility settings. Assert no animation, just show/hide.
19. **Dark theme:** Render in dark theme. Assert colors come from theme (no hardcoded light colors).

---

## REQ-04: OiNavigationRail — Vertical Navigation Rail

**Priority:** Medium
**Tier:** Component (Tier 2)
**Type:** New widget

### Problem

`OiSidebar` (Tier 3) is a full-featured desktop sidebar with collapsible sections, headers, footers, and resizable width. It is too heavyweight for simple app shells that need a compact vertical navigation strip with 3-8 items.

`OiBottomBar` handles mobile navigation but there is no equivalent compact vertical component for desktop/tablet layouts. Flutter's `NavigationRail` fills this role but depends on Material.

### Description

`OiNavigationRail` is a compact vertical navigation bar (64-80dp wide) that displays a column of icon+label destinations. It is the desktop counterpart to `OiBottomBar` — same data model, different layout orientation.

### API Design

```dart
class OiNavigationRail extends StatelessWidget {
  const OiNavigationRail({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.leading,
    this.trailing,
    this.width = 72.0,
    this.labelBehavior = OiRailLabelBehavior.all,
    this.groupAlignment = -1.0,
    this.backgroundColor,
    this.indicatorColor,
    this.indicatorShape,
    this.elevation,
    this.semanticLabel,
    super.key,
  });

  /// Navigation destinations. Same model as OiBottomBar for easy switching.
  final List<OiNavigationItem> items;

  /// Currently selected index.
  final int currentIndex;

  /// Called when a destination is tapped.
  final ValueChanged<int> onTap;

  /// Widget displayed above the destinations (e.g., back button, logo, menu toggle).
  final Widget? leading;

  /// Widget displayed below the destinations (e.g., settings icon, user avatar).
  final Widget? trailing;

  /// Width of the rail. Default: 72.
  final double width;

  /// How labels are displayed.
  final OiRailLabelBehavior labelBehavior;

  /// Vertical alignment of the destination group within the rail.
  /// -1.0 = top, 0.0 = center, 1.0 = bottom. Default: -1.0 (top).
  final double groupAlignment;

  /// Background color. Default: theme surface color.
  final Color? backgroundColor;

  /// Background color/shape of the selected item indicator.
  final Color? indicatorColor;

  /// Shape of the selected indicator (pill, rectangle, etc.).
  final ShapeBorder? indicatorShape;

  /// Shadow elevation. Default: none (flat).
  final OiElevation? elevation;

  /// Accessibility label for the entire rail.
  final String? semanticLabel;
}

enum OiRailLabelBehavior {
  /// Always show labels below icons.
  all,

  /// Show label only on the selected destination.
  selected,

  /// Never show labels (icon-only mode).
  none,
}

/// Shared navigation item model (used by both OiBottomBar and OiNavigationRail).
class OiNavigationItem {
  const OiNavigationItem({
    required this.icon,
    required this.label,
    this.activeIcon,
    this.badge,
    this.tooltip,
    this.semanticLabel,
  });

  /// Icon shown when this destination is not selected.
  final IconData icon;

  /// Text label for this destination.
  final String label;

  /// Icon shown when this destination is selected.
  /// Falls back to [icon] if null.
  final IconData? activeIcon;

  /// Badge content (e.g., notification count). Null = no badge.
  final String? badge;

  /// Tooltip shown on hover (desktop).
  final String? tooltip;

  /// Accessibility label. Falls back to [label] if null.
  final String? semanticLabel;
}
```

### Shared Data Model with OiBottomBar

`OiNavigationItem` should be the **same class** used by `OiBottomBar`. This allows consumers to build responsive layouts that switch between `OiBottomBar` (mobile) and `OiNavigationRail` (desktop) using the same item list:

```dart
final navItems = [
  OiNavigationItem(icon: Icons.home, label: 'Home'),
  OiNavigationItem(icon: Icons.search, label: 'Search'),
  OiNavigationItem(icon: Icons.settings, label: 'Settings'),
];

// Desktop layout
OiNavigationRail(items: navItems, currentIndex: idx, onTap: onTap);

// Mobile layout
OiBottomBar(items: navItems, currentIndex: idx, onTap: onTap);
```

If `OiBottomBar` currently uses a different item model, unify them or provide a common interface/adapter.

### Visual Specification

```
 ┌──────────┐
 │ [leading] │  ← optional leading widget
 │           │
 │  ○ icon   │  ← unselected item
 │  label    │
 │           │
 │ [●] icon  │  ← selected item (indicator behind icon)
 │  label    │
 │           │
 │  ○ icon   │
 │  label    │
 │           │
 │  ...      │
 │           │
 │ [trailing]│  ← optional trailing widget
 └──────────┘
     72dp
```

- Selected indicator: pill-shaped or rounded-rectangle background behind the icon
- Icon size: 24dp (default, respects density)
- Label: small text below icon (8dp gap)
- Item vertical padding: 12dp
- Rail has a subtle right border (1dp, theme border color)

### Theming

```dart
class OiNavigationRailThemeData {
  final double? width;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final ShapeBorder? indicatorShape;
  final Color? selectedIconColor;
  final Color? unselectedIconColor;
  final TextStyle? selectedLabelStyle;
  final TextStyle? unselectedLabelStyle;
  final double? iconSize;
  final double? itemSpacing;         // Vertical gap between items
  final EdgeInsets? itemPadding;     // Padding around each item
  final Color? borderColor;         // Right border color
  final double? borderWidth;        // Right border width (0 = no border)
  final OiElevation? elevation;
}
```

### Accessibility

- The rail is a `Semantics(container: true, label: semanticLabel ?? 'Navigation')`
- Each item is `Semantics(selected: isSelected, button: true, label: item.semanticLabel ?? item.label)`
- Badge content is announced as part of the item label: "Search, 3 new"
- Focus indicators (visible ring) on keyboard navigation
- Arrow keys (Up/Down) navigate between items when the rail has focus

### Test Scenarios

1. **Renders all items:** Provide 5 items. Assert 5 icons and 5 labels are visible.
2. **Selected item highlighted:** Set `currentIndex: 2`. Assert item 2 has the indicator background.
3. **onTap called on tap:** Tap item 3. Assert `onTap(3)` was called.
4. **Leading widget rendered:** Provide a leading widget. Assert it appears above the items.
5. **Trailing widget rendered:** Provide a trailing widget. Assert it appears below the items.
6. **Active icon swap:** Provide `activeIcon` on item 1. Select item 1. Assert `activeIcon` is displayed (not `icon`).
7. **Badge displayed:** Set `badge: '5'` on item 0. Assert badge is visible on item 0.
8. **Label behavior: selected only:** Set `labelBehavior: .selected`. Assert only the selected item shows a label.
9. **Label behavior: none:** Set `labelBehavior: .none`. Assert no labels are shown.
10. **Custom width:** Set `width: 88`. Assert the rail is 88dp wide.
11. **groupAlignment center:** Set `groupAlignment: 0.0`. Assert items are vertically centered.
12. **Keyboard navigation:** Focus the rail. Press Down arrow. Assert focus moves to the next item.
13. **Tooltip on hover:** Hover over an item with `tooltip: 'Home page'`. Assert tooltip appears.
14. **Semantic selected state:** Assert selected item has `Semantics(selected: true)`.
15. **Dark theme:** Render in dark theme. Assert colors come from dark theme.
16. **Same items work in OiBottomBar:** Use the same `OiNavigationItem` list in both `OiNavigationRail` and `OiBottomBar`. Assert both render correctly.
17. **Responsive switch:** In a layout that switches between rail and bottom bar at a breakpoint, assert both render the same items with correct selection state.

---

## REQ-05: OiSliverHeader — Sticky Scroll Header

**Priority:** Medium
**Tier:** Component (Tier 2)
**Type:** New widget

### Problem

Detail pages (order details, product details, user profiles) commonly use a scrollable layout with a header that stays pinned at the top as the user scrolls through content. Flutter's `SliverAppBar` provides this behavior but depends on Material.

obers_ui has no sliver-compatible header widget. Projects are forced to either use Material `SliverAppBar` or build complex custom sliver delegates.

### Description

`OiSliverHeader` is a sliver widget that renders a sticky/pinned header bar within a `CustomScrollView`. It provides slots for leading, title, and trailing widgets — the structural equivalent of an app bar for sliver-based layouts.

### API Design

```dart
class OiSliverHeader extends StatelessWidget {
  const OiSliverHeader({
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.actions = const [],
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.expandedHeight,
    this.collapsedHeight,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.border,
    this.flexibleSpace,
    this.centerTitle = false,
    this.titleSpacing,
    this.toolbarHeight = 56.0,
    this.semanticLabel,
    super.key,
  });

  /// Leading widget (typically a back button).
  final Widget? leading;

  /// Primary title widget or text.
  final Widget? title;

  /// Secondary subtitle text displayed below the title.
  final Widget? subtitle;

  /// Single trailing widget (for a primary action).
  final Widget? trailing;

  /// List of action widgets displayed after [trailing].
  final List<Widget> actions;

  /// Whether the header remains visible at the top when scrolled.
  /// Default: true.
  final bool pinned;

  /// Whether the header reappears when scrolling up (even mid-content).
  /// Default: false.
  final bool floating;

  /// Whether the header snaps fully open/closed (only with floating=true).
  /// Default: false.
  final bool snap;

  /// Height when fully expanded (for flexible space content).
  /// If null, only the toolbar is shown (no flexible space).
  final double? expandedHeight;

  /// Height when collapsed (pinned). Default: [toolbarHeight].
  final double? collapsedHeight;

  /// Background color. Default: theme surface color.
  final Color? backgroundColor;

  /// Foreground color for title/icons. Default: theme text color.
  final Color? foregroundColor;

  /// Shadow elevation when scrolled under content.
  final OiElevation? elevation;

  /// Bottom border. Default: subtle border (1dp, theme border color).
  final BorderSide? border;

  /// Widget displayed behind the toolbar when expanded.
  /// Useful for hero images, gradients, or large title displays.
  final Widget? flexibleSpace;

  /// Whether to center the title.
  final bool centerTitle;

  /// Horizontal spacing around the title. Default: 16.
  final double? titleSpacing;

  /// Height of the toolbar area. Default: 56.
  final double toolbarHeight;

  /// Semantic label for the header.
  final String? semanticLabel;
}
```

### Behavior Specification

#### Pinned Mode (default)
- The header scrolls with content until it reaches the top of the viewport, then stays fixed.
- When content scrolls under the header, an optional elevation shadow or bottom border appears.

#### Floating Mode
- The header is hidden when scrolling down but reappears immediately when scrolling up.
- With `snap: true`, a small upward scroll snaps the header fully visible.

#### Expanded Mode
- When `expandedHeight` is set, the header starts tall and collapses to `collapsedHeight` (or `toolbarHeight`) as the user scrolls.
- `flexibleSpace` content fades out / scales down during collapse.
- Title, leading, and actions remain visible in the collapsed state.

### Inner Workings

- Implements via `SliverPersistentHeaderDelegate` (Flutter foundation, no Material dependency).
- Calculates `minExtent` from `collapsedHeight ?? toolbarHeight`.
- Calculates `maxExtent` from `expandedHeight ?? toolbarHeight`.
- Uses `shrinkOffset` / `overlapsContent` to drive visual state (shadow, opacity, transform).
- Does NOT use `SliverAppBar`, `AppBar`, `Scaffold`, or any Material widget internally.

### Theming

```dart
class OiSliverHeaderThemeData {
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? scrolledUnderBackgroundColor;  // Background when content is scrolled under
  final OiElevation? scrolledUnderElevation;
  final BorderSide? border;
  final double? toolbarHeight;
  final double? titleSpacing;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final bool? centerTitle;
}
```

### Convenience Constructors

```dart
/// Simple header with just a title and optional back button.
OiSliverHeader.simple({
  required String title,
  VoidCallback? onBack,
  List<Widget> actions = const [],
});

/// Header with a large expandable title that collapses on scroll.
OiSliverHeader.large({
  required String title,
  String? subtitle,
  VoidCallback? onBack,
  List<Widget> actions = const [],
  double expandedHeight = 120.0,
});

/// Header with a hero image/widget that collapses into a standard toolbar.
OiSliverHeader.hero({
  required Widget flexibleSpace,
  Widget? title,
  VoidCallback? onBack,
  List<Widget> actions = const [],
  double expandedHeight = 200.0,
});
```

### Accessibility

- `Semantics(header: true, label: semanticLabel ?? titleText)` on the header bar
- Leading/trailing buttons must have their own semantic labels (consumer responsibility)
- When the header state changes (pinned vs. floating visibility), no announcement is needed (visual-only transition)
- Focus should be able to reach items in the header via Tab navigation

### Test Scenarios

1. **Renders title and leading:** Provide title text and a leading widget. Assert both are visible.
2. **Renders actions:** Provide 3 action widgets. Assert all 3 are visible in the trailing area.
3. **Subtitle renders below title:** Provide title and subtitle. Assert subtitle appears below title.
4. **Pinned behavior:** Scroll down. Assert header remains visible at top.
5. **Not pinned:** Set `pinned: false`. Scroll down. Assert header scrolls off-screen.
6. **Floating behavior:** Set `floating: true, pinned: false`. Scroll down (header hidden). Scroll up. Assert header reappears.
7. **Snap behavior:** Set `floating: true, snap: true`. Small scroll up. Assert header snaps to fully visible.
8. **Expanded height:** Set `expandedHeight: 200`. Assert header starts at 200dp and collapses to toolbar height on scroll.
9. **Flexible space:** Provide a `flexibleSpace` widget. Assert it is visible when expanded and fades on collapse.
10. **Elevation on scroll:** Scroll content under header. Assert a shadow appears (or border intensifies).
11. **Custom background color:** Set custom color. Assert header uses it.
12. **Center title:** Set `centerTitle: true`. Assert title is horizontally centered.
13. **Works in CustomScrollView:** Place in a `CustomScrollView` with `SliverList`. Assert layout is correct.
14. **Multiple slivers:** Use with `SliverGrid` and `SliverPadding`. Assert they interact correctly.
15. **OiSliverHeader.simple:** Use `.simple(title: 'Details', onBack: ..., actions: [...])`. Assert correct layout.
16. **OiSliverHeader.large:** Use `.large()`. Assert large title that collapses.
17. **OiSliverHeader.hero:** Use `.hero()` with an image. Assert image collapses into toolbar.
18. **Dark theme:** Render in dark theme. Assert themed colors.
19. **Semantic header role:** Assert `Semantics(header: true)` is present.

---

## REQ-06: OiPageTransition — Non-Material Page Route

**Priority:** Low
**Tier:** Foundation (Tier 0)
**Type:** New utility

### Problem

Projects that use `go_router` for primary navigation may still need imperative `Navigator.push()` for edge cases (in-feature sub-navigation, wizard steps, preview screens). Flutter's `MaterialPageRoute` and `CupertinoPageRoute` impose Material/Cupertino visual transitions and dependencies.

obers_ui needs a page route that provides smooth, themed transitions without any Material/Cupertino dependency.

### API Design

```dart
class OiPageRoute<T> extends PageRoute<T> {
  OiPageRoute({
    required this.builder,
    this.transition = OiPageTransitionType.fade,
    this.transitionDuration = const Duration(milliseconds: 250),
    this.reverseTransitionDuration = const Duration(milliseconds: 200),
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.barrierColor,
    this.barrierDismissible = false,
    super.settings,
  });

  final Widget Function(BuildContext context) builder;
  final OiPageTransitionType transition;

  @override
  final Duration transitionDuration;

  @override
  final Duration reverseTransitionDuration;

  @override
  final bool maintainState;

  @override
  final bool fullscreenDialog;

  @override
  final Color? barrierColor;

  @override
  final bool barrierDismissible;
}

enum OiPageTransitionType {
  /// Crossfade between pages. Good default for most cases.
  fade,

  /// New page slides in from the right (LTR) or left (RTL).
  slideHorizontal,

  /// New page slides in from the bottom. Good for fullscreen dialogs.
  slideVertical,

  /// New page scales up from center with fade. Good for detail views.
  scaleUp,

  /// No animation. Instant swap.
  none,
}
```

### Convenience Constructor

```dart
/// Creates a page route with theme-aware transition.
/// Reads transition preferences from OiThemeData.animations.
static OiPageRoute<T> of<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  OiPageTransitionType? transition, // Falls back to theme default
  RouteSettings? settings,
});
```

### Companion: OiPage for go_router

For projects using `go_router`, provide an `OiPage` subclass of `Page` that uses the same transition system:

```dart
class OiTransitionPage<T> extends Page<T> {
  const OiTransitionPage({
    required this.child,
    this.transition = OiPageTransitionType.fade,
    this.transitionDuration,
    this.reverseTransitionDuration,
    super.key,
    super.name,
    super.arguments,
  });

  final Widget child;
  final OiPageTransitionType transition;
  final Duration? transitionDuration;
  final Duration? reverseTransitionDuration;

  @override
  Route<T> createRoute(BuildContext context) => OiPageRoute<T>(
    builder: (_) => child,
    transition: transition,
    transitionDuration: transitionDuration ?? const Duration(milliseconds: 250),
    reverseTransitionDuration: reverseTransitionDuration ?? const Duration(milliseconds: 200),
    settings: this,
  );
}
```

### Theming

Add to `OiThemeData.animations`:

```dart
class OiAnimationConfig {
  // ... existing fields ...

  /// Default page transition type.
  final OiPageTransitionType defaultPageTransition;

  /// Duration for page transitions.
  final Duration pageTransitionDuration;

  /// Curve for page entry animations.
  final Curve pageEntryCurve;

  /// Curve for page exit animations.
  final Curve pageExitCurve;
}
```

### Accessibility

- Respects `MediaQuery.disableAnimations` — uses `OiPageTransitionType.none` when animations are disabled
- Route announcements work the same as standard Flutter routes (via `RouteSettings.name`)
- Focus moves to the new page content on push
- Focus returns to the previous page element on pop

### Test Scenarios

1. **Fade transition:** Push with `.fade`. Assert the new page fades in.
2. **Slide horizontal transition:** Push with `.slideHorizontal`. Assert new page slides from right.
3. **Slide vertical transition:** Push with `.slideVertical`. Assert new page slides from bottom.
4. **Scale up transition:** Push with `.scaleUp`. Assert new page scales from center.
5. **No transition:** Push with `.none`. Assert instant page swap.
6. **Pop returns value:** Push route. Pop with value. Assert the returned future completes with value.
7. **maintainState false:** Push with `maintainState: false`. Push another route on top. Assert the first route's state is not preserved.
8. **fullscreenDialog:** Push with `fullscreenDialog: true`. Assert route is marked as fullscreen dialog.
9. **Custom duration:** Set `transitionDuration: Duration(milliseconds: 500)`. Assert animation takes ~500ms.
10. **Reduced motion:** Enable `disableAnimations`. Assert no transition animation plays.
11. **OiTransitionPage with go_router:** Use `OiTransitionPage` in a `GoRoute.pageBuilder`. Assert correct transition.
12. **Theme default transition:** Configure theme with `defaultPageTransition: .slideHorizontal`. Use `OiPageRoute.of(context: ...)`. Assert slide transition is used.
13. **RTL slide direction:** Set text direction to RTL. Use `.slideHorizontal`. Assert slide comes from the left.
14. **Reverse transition on pop:** Push with `.slideHorizontal`. Pop. Assert the page slides out to the right.

---

## Summary Matrix

| REQ | Widget | Tier | Type | Estimated Complexity |
|-----|--------|------|------|---------------------|
| REQ-01 | OiTextInput (enhancement + OTP constructor) | T2 | Enhancement | High — form integration touches validation lifecycle, OTP is a complex sub-widget |
| REQ-02 | OiDialogShell | T2 | New | Low — thin container, most logic is in `.show()` overlay management |
| REQ-03 | OiRefreshIndicator | T2 | New | Medium — scroll physics, gesture tracking, animation coordination |
| REQ-04 | OiNavigationRail | T2 | New | Medium — layout, selection state, shared data model with OiBottomBar |
| REQ-05 | OiSliverHeader | T2 | New | High — SliverPersistentHeaderDelegate, expand/collapse physics, multiple modes |
| REQ-06 | OiPageTransition | T0 | New | Low — PageRoute subclass with animation builders |

### Suggested Implementation Order

1. **REQ-01** (OiTextInput) — Unblocks 16 Material widget replacements, most impactful
2. **REQ-02** (OiDialogShell) — Small effort, immediate value for custom dialog patterns
3. **REQ-03** (OiRefreshIndicator) — Required for any list-based UI with refresh
4. **REQ-06** (OiPageTransition) — Small effort, enables full Material removal
5. **REQ-04** (OiNavigationRail) — Needed for desktop layouts
6. **REQ-05** (OiSliverHeader) — Needed for detail pages with scroll-collapse headers

### Cross-Cutting Concerns

- **All new widgets must be theme-aware:** Read defaults from `OiThemeData`, allow per-instance overrides.
- **All new widgets must support dark mode:** Never hardcode colors. Always use `context.colors.*`.
- **All new widgets must support density:** Respect `OiDensity` (comfortable/compact/dense) for touch targets and spacing.
- **All new widgets must be accessible:** Semantic labels, focus management, reduced-motion support, screen reader announcements.
- **All new widgets need `OiComponentThemes` entries:** Add `XxxThemeData` for each new widget.
- **Zero Material/Cupertino dependency:** None of these widgets may import from `package:flutter/material.dart` or `package:flutter/cupertino.dart`. Use only `package:flutter/widgets.dart`, `package:flutter/rendering.dart`, `package:flutter/services.dart`, and `package:flutter/foundation.dart`.
