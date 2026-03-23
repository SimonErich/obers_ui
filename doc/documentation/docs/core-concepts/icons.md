# Icons

ObersUI ships with [Lucide](https://lucide.dev) v0.577.0 — a comprehensive open-source icon set with **1,950+ icons** embedded as a font. Zero external dependencies, zero network requests.

## Quick Start

```dart
import 'package:obers_ui/obers_ui.dart';

// Semantic icon (requires accessibility label)
OiIcon(icon: OiIcons.search, label: 'Search')

// Decorative icon (excluded from accessibility tree)
OiIcon.decorative(icon: OiIcons.chevronRight)

// Icon button
OiIconButton(icon: OiIcons.settings, label: 'Settings', onPressed: () {})
```

## OiIcons Reference

All icons are accessed as static constants on the `OiIcons` class. Names use **camelCase** converted from Lucide's kebab-case naming.

```dart
OiIcons.chevronLeft   // chevron-left
OiIcons.arrowRight    // arrow-right
OiIcons.fileText      // file-text
OiIcons.circleCheck   // circle-check
```

Browse the full catalog at [lucide.dev/icons](https://lucide.dev/icons).

### Arrows & Navigation

| Icon | Constant |
|------|----------|
| Chevrons | `chevronLeft`, `chevronRight`, `chevronUp`, `chevronDown` |
| Double chevrons | `chevronsLeft`, `chevronsRight`, `chevronsUp`, `chevronsDown`, `chevronsUpDown` |
| Arrows | `arrowLeft`, `arrowRight`, `arrowUp`, `arrowDown`, `arrowUpLeft`, `arrowUpRight`, `arrowDownLeft`, `arrowDownRight` |
| Undo/Redo | `undo2`, `redo2` |
| Trends | `trendingUp`, `trendingDown` |
| External | `externalLink`, `logIn`, `logOut` |
| Download/Upload | `download`, `upload` |

### Actions

| Icon | Constant |
|------|----------|
| Add/Remove | `plus`, `minus`, `x`, `check` |
| Circle variants | `circlePlus`, `circleMinus`, `circleX`, `circleCheck` |
| Edit | `pencil`, `squarePen`, `eraser` |
| Search | `search`, `zoomIn`, `zoomOut` |
| Clipboard | `copy`, `clipboard`, `clipboardList`, `clipboardCheck` |
| Misc | `trash2`, `share2`, `send`, `link`, `scissors`, `power` |

### Files & Folders

| Icon | Constant |
|------|----------|
| Files | `file`, `fileText`, `filePlus`, `fileMinus`, `fileCheck`, `fileSearch`, `fileUp`, `fileDown` |
| Folders | `folder`, `folderOpen`, `folderPlus`, `folderMinus` |
| Archive | `archive`, `archiveRestore`, `archiveX` |
| Storage | `database`, `server`, `layers`, `hardDrive` |

### Media & Communication

| Icon | Constant |
|------|----------|
| Images | `image`, `camera` |
| Video/Audio | `video`, `videoOff`, `music`, `play`, `circlePlay`, `pause`, `volume2`, `volumeX` |
| Messages | `mail`, `mailOpen`, `messageSquare`, `messagesSquare`, `messageCircle` |
| Notifications | `bell`, `bellRing`, `bellOff` |
| Contact | `phone`, `send`, `paperclip`, `atSign` |

### Users & People

| Icon | Constant |
|------|----------|
| Single | `user`, `circleUser`, `userPlus`, `userMinus`, `userCheck`, `userX` |
| Group | `users` |
| Reactions | `thumbsUp`, `thumbsDown`, `hand` |

### Status & Feedback

| Icon | Constant |
|------|----------|
| Success | `circleCheck`, `badgeCheck`, `shieldCheck` |
| Warning | `circleAlert`, `triangleAlert` |
| Info | `info`, `circleHelp` |
| Error | `circleX`, `ban` |

### Layout & Display

| Icon | Constant |
|------|----------|
| Menu | `menu`, `alignJustify`, `alignLeft` |
| Grid | `layoutGrid`, `columns3`, `table`, `list` |
| Settings | `slidersHorizontal`, `slidersVertical`, `settings` |
| Overflow | `ellipsis`, `ellipsisVertical` |

### Data & Charts

| Icon | Constant |
|------|----------|
| Charts | `barChart3`, `pieChart`, `trendingUp`, `trendingDown` |
| Presentation | `presentation` |

### Appearance

| Icon | Constant |
|------|----------|
| Theme | `sun`, `moon`, `monitor` |
| Visibility | `eye`, `eyeOff` |
| Design | `sparkles`, `paintbrush`, `palette`, `pipette` |

### Objects & Symbols

| Icon | Constant |
|------|----------|
| Places | `house`, `mapPin`, `globe`, `flag` |
| Commerce | `shoppingCart`, `creditCard`, `tag`, `receiptText` |
| Favorites | `star`, `heart`, `bookmark` |
| Time | `clock`, `calendar`, `calendarDays`, `calendarRange` |
| Security | `lock`, `lockOpen`, `key`, `fingerprint`, `shield` |
| Dev | `code`, `terminal`, `flaskConical`, `rocket`, `zap`, `cpu` |
| Text | `hash`, `languages`, `newspaper`, `bookOpen` |

## OiIcon Widget

The `OiIcon` primitive renders an icon with proper sizing and accessibility semantics.

```dart
// Semantic: announced by screen readers
OiIcon(icon: OiIcons.lock, label: 'Locked')

// Decorative: hidden from accessibility tree
OiIcon.decorative(icon: OiIcons.chevronRight)

// Custom size and color
OiIcon(icon: OiIcons.star, label: 'Favorite', size: 24, color: Colors.amber)
```

**Size** defaults to the theme's body font size. Override with `size`.

## OiIconButton

An icon-only button with built-in tooltip and accessibility label.

```dart
OiIconButton(
  icon: OiIcons.trash2,
  label: 'Delete',
  onPressed: () {},
)
```

## Best Practices

!!! tip "Do"
    - Use `OiIcon` with a `label` for interactive/meaningful icons
    - Use `OiIcon.decorative()` for purely visual icons (e.g., chevrons in accordions)
    - Use `OiIcons.xxx` constants — never `Icons.xxx` from Material
    - Browse [lucide.dev](https://lucide.dev) to find the right icon name

!!! warning "Don't"
    - Don't use `Icon()` directly — use `OiIcon()` for consistent sizing and semantics
    - Don't use Material `Icons.xxx` — use `OiIcons.xxx`
    - Don't hardcode icon codepoints — always use named constants
