# Layout

These are the primitives that arrange widgets on screen. They read spacing from the
theme and adapt to the current breakpoint, so a layout that looks right on a phone
also holds up on a wide desktop. Prefer them over Flutter's raw `Row`, `Column`,
and `GridView`.

- [**Rows & Columns**](flex.md) for `OiRow`, `OiColumn`, `OiWrapLayout`, and `OiSpacer`.
- [**Grid System**](grid.md) for `OiGrid` and `OiMasonry`.
- [**Page & Section**](page-and-section.md) for framing a screen with `OiPage`, `OiSection`, and `OiContainer`.
- [**Panels & App Shells**](panels-and-shells.md) for `OiSurface`, `OiPanel`, `OiSplitPane`, `OiResizable`, and full app frames.

## One rule to remember

Most layout primitives take a `breakpoint`. This is on purpose. Resolve it once at
the top of a screen with `context.breakpoint` and pass it down. Every layout stays
self-contained, with no hidden state, so it is easy to reason about and easy to test.

Values that change by breakpoint use `OiResponsive<T>`. Pass a single value with
`OiResponsive(value)`, or per-breakpoint values with `OiResponsive.breakpoints({...})`.

```dart
OiColumn(
  breakpoint: context.breakpoint,
  gap: const OiResponsive<double>(16),
  children: [
    OiLabel.h2('Profile'),
    OiLabel.body('Your account details.'),
  ],
)
```
