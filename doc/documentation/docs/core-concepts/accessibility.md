# Accessibility

ObersUI is built accessibility-first. Every component ships with proper semantics, keyboard navigation, and adaptive behavior — not as an afterthought, but as a core requirement.

## WCAG AA compliance

All color combinations in the default themes meet **WCAG AA contrast ratios**. The `OiColorSwatch.from()` factory automatically generates swatch variants (light, dark, muted, foreground) that maintain contrast.

## Touch targets

On touch devices, all interactive widgets enforce a **48x48dp minimum touch target** — the WCAG recommended size. This happens automatically:

- `OiTappable` (the base for all interactive widgets) checks input modality
- Touch → 48dp minimum; Pointer → no minimum enforced
- The visual size can be smaller — the tap area expands invisibly

## Reduced motion

ObersUI respects the system's reduced-motion preference:

- Animations check `OiAnimationConfig.reducedMotion` before running
- When reduced motion is enabled, durations drop to zero
- This is detected automatically from `MediaQuery.disableAnimationsOf()`
- Platform-specific: works on iOS, Android, macOS, web, and more

No opt-in required. If a user enables reduced motion in their OS settings, ObersUI responds.

## Semantic labels

Every overlay, dialog, and panel takes an accessibility label used by screen readers to announce the surface. Named constructors on [OiDialog](lib/src/components/overlays/oi_dialog.dart) require `label:`; the `showOiDialog` helper accepts `semanticLabel:`.

```dart
// Named constructor — label is required.
OiDialog.confirm(
  label: 'Delete confirmation',
  title: 'Delete this file?',
  content: const Text('This action cannot be undone.'),
  actions: [/* ... */],
)

// Helper — semanticLabel is optional but strongly recommended.
showOiDialog<bool>(
  context,
  semanticLabel: 'Delete confirmation',
  builder: (context, close) => /* ... */,
)
```

## Screen reader support

The `OiA11y` utility class provides:

```dart
// Announce a message to screen readers
OiA11y.announce(context, 'File uploaded successfully');

// Assertive announcement (interrupts current speech)
OiA11y.announce(context, 'Error: upload failed', assertive: true);
```

## Links carry link semantics

Use [OiLink](lib/src/components/interaction/oi_link.dart) — not a tappable with text inside — for anything that is conceptually a hyperlink. It sets link semantics so assistive technology announces "link" instead of "button", supports `semanticLabel` / `semanticHint`, and on web renders a real anchor with `target: OiLinkTarget.blank` applying `rel="noopener noreferrer"` automatically.

## Keyboard navigation

All interactive components support keyboard navigation:

- **Tab** / **Shift+Tab** to move focus
- **Enter** / **Space** to activate buttons and controls
- **Escape** to close overlays
- **Arrow keys** for lists, grids, tabs, menus
- `OiFocusTrap` confines focus within dialogs and panels

## Checking accessibility state

```dart
// Is reduced motion enabled?
final reducedMotion = OiA11y.reducedMotion(context);

// Is high contrast mode active?
final highContrast = OiA11y.highContrast(context);

// Current text scale factor
final textScale = OiA11y.textScale(context);

// Is bold text preferred?
final boldText = OiA11y.boldText(context);
```
