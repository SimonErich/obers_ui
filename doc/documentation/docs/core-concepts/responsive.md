# Responsive Design

ObersUI is responsive by default. Layouts, spacing, and component behavior adapt across screen sizes — from compact phones to ultra-wide desktops.

## Breakpoints

The library defines five breakpoints:

| Breakpoint | Width | Typical device |
|---|---|---|
| **compact** | 0 – 599 | Phones |
| **medium** | 600 – 839 | Small tablets, landscape phones |
| **expanded** | 840 – 1199 | Tablets, small desktops |
| **large** | 1200 – 1599 | Desktops |
| **extraLarge** | 1600+ | Wide monitors |

These are defined in `OiBreakpointScale.standard()` and can be customized in your theme.

## Responsive values

Any property can vary by breakpoint using `OiResponsive<T>`:

```dart
OiGrid(
  columns: OiResponsive({
    OiBreakpoint.compact: 1,
    OiBreakpoint.medium: 2,
    OiBreakpoint.expanded: 3,
    OiBreakpoint.large: 4,
  }),
  children: [...],
)
```

Values cascade upward — if you only define `compact` and `expanded`, medium inherits from compact, and large/extraLarge inherit from expanded. Mobile-first.

## Adaptive layouts

Several primitives respond to breakpoints automatically:

| Widget | Behavior |
|---|---|
| `OiGrid` | Column count adapts to viewport width |
| `OiPage` | Gutters widen at larger breakpoints |
| `OiSection` | Aside layout on wide screens, stacked on narrow |
| `OiFlex` | Horizontal on wide screens, stacks below a threshold |
| `OiShow` / `OiHide` | Show or hide children at specific breakpoints |

## Navigation adaptation

ObersUI adapts navigation paradigms per breakpoint:

| Breakpoint | Navigation pattern |
|---|---|
| **compact** | `OiBottomBar` + `OiDrawer` overlay |
| **medium** | `OiSidebar` as compact 64dp rail |
| **expanded+** | `OiSidebar` at 260dp with labels |

## Page gutters

Spacing automatically adjusts by breakpoint:

| Breakpoint | Gutter |
|---|---|
| compact | 16dp |
| medium | 24dp |
| expanded | 32dp |
| large | 40dp |
| extraLarge | 48dp |

## Custom breakpoints

Override the default scale in your theme:

```dart
OiThemeData.light(
  breakpoints: OiBreakpointScale(
    breakpoints: {
      OiBreakpoint.compact: 0,
      OiBreakpoint.medium: 480,    // narrower medium
      OiBreakpoint.expanded: 768,
      OiBreakpoint.large: 1024,
      OiBreakpoint.extraLarge: 1440,
    },
  ),
)
```
