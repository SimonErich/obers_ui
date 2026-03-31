# Flex Layouts

ObersUI provides enhanced flex widgets that add gaps and responsive behavior on top of Flutter's built-in layout.

## OiRow and OiColumn

Drop-in replacements for `Row` and `Column` with a `gap` parameter:

```dart
// Horizontal layout with 8dp gaps
OiRow(
  gap: context.spacing.sm,
  children: [
    OiButton(label: 'Cancel', variant: OiButtonVariant.ghost, onPressed: () {}),
    OiButton(label: 'Save', onPressed: () {}),
  ],
)

// Vertical layout with 16dp gaps
OiColumn(
  gap: context.spacing.md,
  children: [
    OiTextInput(label: 'Name'),
    OiTextInput(label: 'Email'),
    OiTextInput(label: 'Message', maxLines: 5),
  ],
)
```

No more `SizedBox(height: 16)` between every child.

## OiFlex

Advanced flex with `grow` and `fixed` children:

```dart
OiFlex(
  gap: context.spacing.md,
  children: [
    OiFlex.fixed(width: 240, child: SidePanel()),
    OiFlex.grow(child: MainContent()),       // Takes remaining space
    OiFlex.fixed(width: 300, child: DetailPanel()),
  ],
)
```

### Responsive stacking

`OiFlex` can stack vertically below a breakpoint:

```dart
OiFlex(
  gap: context.spacing.md,
  stackBelow: OiBreakpoint.medium,  // Stack vertically on compact
  children: [
    OiFlex.fixed(width: 240, child: SidePanel()),
    OiFlex.grow(child: MainContent()),
  ],
)
```

Above the breakpoint: horizontal side-by-side. Below: vertical stack.

## OiWrapLayout

Like `Wrap` but with consistent gap handling:

```dart
OiWrapLayout(
  gap: context.spacing.sm,
  children: tags.map((tag) => OiBadge.soft(label: tag)).toList(),
)
```

Children flow horizontally and wrap to the next line when they run out of space.

## When to use which

| Widget | Use for |
| --- | --- |
| `OiGrid` | Multi-column layouts, dashboard cards, form fields |
| `OiRow` | Simple horizontal groups (buttons, icons, labels) |
| `OiColumn` | Simple vertical groups (form fields, list items) |
| `OiFlex` | Sidebar + main content, split layouts |
| `OiWrapLayout` | Tags, chips, badges, filter pills |
| `OiPage` | Top-level page structure |
| `OiSection` | Content groups within a page |
