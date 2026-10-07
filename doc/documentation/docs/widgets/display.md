# Display & Content

These widgets show data. Cards group content, badges and status dots flag state,
avatars and metrics summarize an entity, and read-only field widgets render values
without an editor. Tooltips and popovers layer extra detail on hover or tap. Every
Most read their colors, spacing, and radius from the theme. `OiHatch` instead
uses explicit authored colors and geometry.

| Widget | What it does |
| --- | --- |
| `OiCard` | A content container with header, footer, and optional tap. |
| `OiBadge` | A small status or category chip, three styles. |
| `OiAvatar` | A user or entity avatar with image, initials, or icon fallback. |
| `OiKeyValue` | A label and value pair for read-only detail rows. |
| `OiListTile` | A standard single-row list item. |
| `OiMetric` | A KPI display with a large value, label, and trend. |
| `OiStatusDot` | A small live-status dot, optionally pulsing. |
| `OiRelativeTime` | An auto-refreshing "2m ago" timestamp. |
| `OiFieldDisplay` | A read-only field that formats a value by type. |
| `OiEmptyState` | A placeholder for empty views and error pages. |
| `OiTooltip` | A short hint shown on hover or long-press. |
| `OiPopover` | A floating content box anchored to a trigger. |
| `OiImage` | An image with required alt text and placeholder states. |
| `OiStorageIndicator` | A used/total storage bar with optional breakdown. |
| `OiPageIndicator` | A row of dots for carousels and onboarding. |
| `OiPagination` | A standalone page control for lists outside a table. |
| `OiHatch` | Static decorative diagonal bands behind optional content. |

## OiHatch

Continuous135-degree hatch bands. Supply a size through the parent and explicit
ink; this low-level primitive does not infer theme colors or create animation.

```dart
SizedBox(
  width: 160,
  height: 24,
  child: OiHatch(
    stripeColor: const Color(0x47131417),
    pitch: 5,
    stripeWidth: 1,
  ),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `stripeColor` | `Color` | **required** | Ink, including authored alpha. |
| `backgroundColor` | `Color` | transparent | Color beneath the bands. |
| `pitch` | `double` | `5` | Finite positive perpendicular repeat distance. |
| `stripeWidth` | `double` | `1` | Finite thickness between zero and pitch, inclusive. |
| `phase` | `double` | `0` | Finite perpendicular translation; wraps at pitch. |
| `child` | `Widget?` | `null` | Content painted above the pattern. |

Distances are perpendicular to the bands, not horizontal spacing. Positive
phase advances them along `(x+y)/sqrt(2)`; finite floating-point precision still
limits representable distances. Zero thickness paints only the background;
thickness equal to pitch paints solid ink over it. Invalid geometry throws an
`ArgumentError` in release builds too.

Only its own paint clips to the box. Child clipping, semantics and interaction
remain caller-owned. The hatch adds no intrinsic size, semantic label, hit
target or self-scheduled frame. It is distinct from the unchanged themed
`OiHatchPlaceholder`; continuous phase control does not certify CSS
background-image tile motion. Subpixel rendering is backend dependent.

## OiCard

The container you reach for to group related content. It takes any `child`, plus
optional header slots (`title`, `subtitle`, `leading`, `trailing`) and a `footer`.
The default constructor is elevated with a shadow.

```dart
OiCard(
  title: OiLabel.h4('Invoice #1024'),
  child: OiLabel.body('Paid on July 2, 2026.'),
)
```

### Variants

Four named constructors cover the common looks. `interactive` requires a `label`
because it responds to hover and focus.

```dart
OiCard.flat(child: content)                          // no shadow
OiCard.outlined(child: content)                      // border, no shadow
OiCard.compact(child: content)                       // 8px padding
OiCard.interactive(
  label: 'Open project',
  onTap: () => open(),
  child: content,
)                                                    // hover and focus effects
```

Set `collapsible: true` to add a chevron in the header that expands and collapses
the body. Use `statusBadge` to overlay a badge at one corner.

```dart
OiCard(
  title: OiLabel.h4('Server'),
  statusBadge: const OiBadge.filled(label: 'Live', color: OiBadgeColor.success),
  statusBadgePosition: OiBadgePosition.topRight,
  child: OiLabel.body('Region: eu-central-1'),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | **required** | The body content. |
| `title` | `Widget?` | `null` | Header title, usually an `OiLabel`. |
| `subtitle` | `Widget?` | `null` | Header text below the title. |
| `leading` | `Widget?` | `null` | Widget left of the title. |
| `trailing` | `Widget?` | `null` | Widget right of the title. |
| `footer` | `Widget?` | `null` | Content below the body, separated by a line. |
| `onTap` | `VoidCallback?` | `null` | Makes the card tappable. Requires `label`. |
| `label` | `String?` | `null` | Accessibility label. Required when `onTap` is set. |
| `collapsible` | `bool` | `false` | Adds an expand/collapse chevron. |
| `defaultCollapsed` | `bool` | `false` | Start collapsed when `collapsible`. |
| `padding` | `EdgeInsetsGeometry?` | `EdgeInsets.all(16)` | Inner padding. `compact` uses `8`. |
| `headerGap` | `double` | `0` | Space between the optional header and body. |
| `border` | `OiBorderStyle?` | `null` | Explicit border override. |
| `gradient` | `OiGradientStyle?` | `null` | Background gradient. |
| `halo` | `OiHaloStyle?` | `null` | Glow effect around the card. |
| `statusBadge` | `Widget?` | `null` | Badge overlaid at a corner. |
| `statusBadgePosition` | `OiBadgePosition` | `topRight` | Corner for `statusBadge`. |

**Theme:** `context.components.card` → `OiCardThemeData`

A card without a header or footer forwards its height constraints to its child,
so bounded tables and scrolling content can fill the available area. Surface
borders participate in layout; use a spread shadow when the design calls for an
outside edge that must not change content insets.

!!! tip "When to reach for something else"
    For a plain background with no header or shadow, use `OiSurface`. For section
    grouping without a visual boundary, use `OiSection`.

## OiBadge

`showDot: true` adds a decorative status marker before the visible label, using
its foreground color so it stays legible for filled, soft and outline styles.
The label remains the accessible name. Use the existing `dot: true` only when
the badge should have no visible text; it takes precedence over `showDot`.

A small chip for status, category, or a count. It has no default constructor. Pick
a style with a named constructor, then set a semantic `color`.

```dart
OiBadge.filled(label: 'New')
```

### Variants

```dart
OiBadge.filled(label: 'Active', color: OiBadgeColor.success)   // solid fill
OiBadge.soft(label: 'Draft', color: OiBadgeColor.warning)      // muted tint
OiBadge.outline(label: 'v2.1', color: OiBadgeColor.neutral)    // border only
```

Set `dot: true` to render a small circle with no text, handy as a status marker.
Semantic colors also add a distinct icon so color is never the only signal.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | The badge text. Ignored when `dot` is true. |
| `color` | `OiBadgeColor` | `primary` | `primary`, `accent`, `success`, `warning`, `error`, `info`, `neutral`. |
| `size` | `OiBadgeSize` | `medium` | `small`, `medium`, or `large`. |
| `icon` | `IconData?` | `null` | Optional icon left of the label. |
| `dot` | `bool` | `false` | Render a dot with no text. |

**Theme:** `context.components.badge` → `OiBadgeThemeData`

!!! note
    For a live health or online/offline signal, use `OiStatusDot`, which can pulse.
    Use `OiBadge` for category labels and counts.

## OiAvatar

A circular avatar for a user or entity. It shows an image first, then initials,
then an icon, whichever you provide. It always needs a `semanticLabel`.

```dart
OiAvatar(
  semanticLabel: 'Jane Doe',
  imageUrl: user.photoUrl,
  initials: 'JD',
  presence: OiPresenceStatus.online,
)
```

If `imageUrl` fails or is null, the avatar falls back to `initials`, then `icon`.
Set `skeleton: true` for a shimmer placeholder while data loads.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `semanticLabel` | `String` | **required** | Screen-reader text. |
| `imageUrl` | `String?` | `null` | Image URL. Must start with `http://` or `https://`. |
| `initials` | `String?` | `null` | Up to two characters, shown if no image. |
| `icon` | `IconData?` | `null` | Icon shown if no image or initials. |
| `size` | `OiAvatarSize` | `md` | `xs` (24), `sm` (32), `md` (40), `lg` (56), `xl` (72). |
| `skeleton` | `bool` | `false` | Show a loading shimmer. |
| `presence` | `OiPresenceStatus?` | `null` | `online`, `offline`, `away`, or `busy` ring. |
| `backgroundColor` | `Color?` | `null` | Override the fallback circle color. |

**Theme:** `context.components.avatar` → `OiAvatarThemeData`

## OiKeyValue

A label and value pair for read-only detail rows. Simpler than `OiFieldDisplay`,
with no type-based formatting. You pass strings, it shows them.

```dart
OiKeyValue(label: 'Email', value: 'jane@example.com')
```

When `value` is null or empty, it shows `emptyText`. On desktop the layout is
horizontal; on compact widths it stacks. Use `OiKeyValue.group` to stack several
rows with dividers.

```dart
OiKeyValue.group(
  title: 'Contact',
  wrapInCard: true,
  children: const [
    OiKeyValue(label: 'Name', value: 'Jane Doe'),
    OiKeyValue(label: 'Phone', value: null, emptyText: 'Not provided'),
    OiKeyValue(label: 'Role', value: 'Admin'),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | The field label. |
| `value` | `String?` | **required** | The value. Null or empty shows `emptyText`. |
| `direction` | `Axis?` | `null` | Horizontal on desktop, vertical on compact by default. |
| `labelWidth` | `double?` | `null` | Fixed label width to align rows. |
| `leading` | `Widget?` | `null` | Widget before the label. |
| `trailing` | `Widget?` | `null` | Widget after the value. |
| `valueWidget` | `Widget?` | `null` | Custom widget instead of a text value. |
| `emptyText` | `String` | `'---'` | Placeholder for null or empty. |
| `copyable` | `bool` | `false` | Tap the value to copy it. |
| `onTap` | `VoidCallback?` | `null` | Makes the whole row tappable. |
| `dense` | `bool` | `false` | Reduced vertical padding. |

**Theme:** `context.components.keyValue` → `OiKeyValueThemeData`

## OiListTile

A standard single-row list item with leading, trailing, title, and subtitle slots.
Use it for settings rows, menus, and simple lists.

```dart
OiListTile(
  title: 'Notifications',
  subtitle: 'Email and push',
  leading: OiAvatar(semanticLabel: 'Jane', initials: 'JD'),
  trailing: const OiBadge.soft(label: '3'),
  onTap: () => open(),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | `String` | **required** | Primary text. |
| `subtitle` | `String?` | `null` | Secondary text below the title. |
| `leading` | `Widget?` | `null` | Widget at the start, often an `OiAvatar`. |
| `trailing` | `Widget?` | `null` | Widget at the end, often an `OiBadge`. |
| `onTap` | `VoidCallback?` | `null` | Called on tap. |
| `selected` | `bool` | `false` | Highlights the row. |
| `enabled` | `bool` | `true` | Set `false` to disable. |
| `dense` | `bool` | `false` | Reduced vertical padding. |

## OiMetric

A KPI display with a large value, a label, and an optional trend arrow. Good for
dashboards. Drop it inside an `OiCard` for a metric card.

```dart
OiMetric(
  label: 'Revenue',
  value: 'EUR 42,180',
  trend: OiMetricTrend.up,
  trendPercent: 12.4,
)
```

The trend arrow is colored by direction: green for `up`, red for `down`, muted for
`neutral`. Pass a `sparkline` widget for an inline mini-chart.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | The metric name. |
| `value` | `String` | **required** | The formatted value. |
| `subValue` | `String?` | `null` | Extra context below the value. |
| `trend` | `OiMetricTrend?` | `null` | `up`, `down`, or `neutral`. |
| `trendPercent` | `double?` | `null` | Percent change next to the arrow. |
| `sparkline` | `Widget?` | `null` | Inline chart widget. |

## OiStatusDot

A small colored dot for live status: health checks, online/offline, build results.
It always needs a `label` for screen readers, and it can pulse.

```dart
OiStatusDot(
  label: 'Service health',
  variant: OiStatusVariant.success,
  pulsing: true,
)
```

Use the `active` shorthand when the state is a simple boolean. `active: true` maps
to a pulsing success dot, `active: false` to a muted dot.

```dart
OiStatusDot.active(active: isOnline, label: 'Connection status')
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label. |
| `variant` | `OiStatusVariant` | `neutral` | `success`, `warning`, `error`, `info`, `neutral`, `muted`. |
| `color` | `Color?` | `null` | Explicit color, overrides `variant`. |
| `size` | `double` | `8.0` | Diameter in logical pixels. |
| `pulsing` | `bool` | `false` | Animate with a pulsing glow. |

!!! note
    For presence on an avatar, use `OiAvatar(presence:)`. For a category label,
    use `OiBadge`. Reach for `OiStatusDot` for live health signals.

## OiRelativeTime

A text widget that shows a `DateTime` as a relative string like "just now" or
"2m ago". By default it refreshes on a timer, so "just now" becomes "1m ago" on
its own.

```dart
OiRelativeTime(dateTime: message.sentAt)
```

Pick a `style` for how verbose the text is. Set `live: false` to compute once and
never update, for example in a list that already rebuilds.

```dart
OiRelativeTime(dateTime: event.time, style: OiRelativeTimeStyle.long)
OiRelativeTime(dateTime: event.time, live: false)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `dateTime` | `DateTime` | **required** | The time to display relative to now. |
| `style` | `OiRelativeTimeStyle` | `short` | `narrow` ("2m"), `short` ("2m ago"), `long` ("2 minutes ago"). |
| `capitalize` | `bool` | `false` | Capitalize the first letter. |
| `live` | `bool` | `true` | Auto-refresh on a timer. |
| `formatAbsolute` | `String Function(DateTime)?` | `null` | Custom format for dates past the relative range. |
| `semanticsLabel` | `String?` | `null` | Override the screen-reader text. |

## OiFieldDisplay

A read-only field renderer that formats a value by type: dates, currency, booleans,
emails, and more. Reach for it on detail and record views where you show data, not
edit it.

```dart
OiFieldDisplay(
  label: 'Created',
  value: order.createdAt,
  type: OiFieldType.date,
)
```

Use `OiFieldDisplay.pair` for a label and value side by side or stacked. Set
`labelWidth` in horizontal mode to align several pairs. For select fields, pass
`choices` to map raw values to display text and `choiceColors` to badge them.

```dart
OiFieldDisplay.pair(
  label: 'Total',
  value: 42.18,
  type: OiFieldType.currency,
  currencyCode: 'EUR',
  labelWidth: 120,
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Field label and accessibility text. |
| `value` | `dynamic` | **required** | The value. Coerced based on `type`. |
| `type` | `OiFieldType` | `text` | Formatting type: `date`, `currency`, `boolean`, `email`, `url`, and more. |
| `emptyText` | `String` | em dash | Shown when `value` is null or empty. |
| `copyable` | `bool` | `false` | Tap the value to copy it. |
| `maxLines` | `int?` | `null` | Truncate text past this many lines. |
| `dateFormat` | `String?` | `null` | Custom date pattern (e.g. `'yyyy-MM-dd'`). |
| `numberFormat` | `String?` | `null` | Custom number pattern. |
| `currencyCode` | `String?` | `null` | ISO code, e.g. `'EUR'`. Defaults to `'USD'` for currency. |
| `currencySymbol` | `String?` | `null` | Symbol, takes precedence over `currencyCode`. |
| `decimalPlaces` | `int?` | `null` | Decimal places for numbers and currency. |
| `choices` | `Map<String, String>?` | `null` | Value to display-text map for select fields. |
| `choiceColors` | `Map<String, OiBadgeColor>?` | `null` | Value to badge-color map for select fields. |
| `formatValue` | `String Function(dynamic)?` | `null` | Custom formatter. |
| `onTap` | `VoidCallback?` | `null` | Makes the value tappable. |
| `leading` | `Widget?` | `null` | Widget before the value. |

**Theme:** `context.components.fieldDisplay` → `OiFieldDisplayThemeData`

!!! note
    `OiFieldDisplay` is read-only. For editable fields, use `OiTextInput`,
    `OiSelect`, and the other input widgets.

## OiEmptyState

A centered placeholder for empty views: empty lists, no search results, and error
pages. It shows an icon or illustration, a title, an optional description, and an
optional action.

Short containers use compact spacing. When bounded height cannot fit all of the
content, the placeholder scrolls vertically so descriptions and actions remain
reachable without reducing text size.

```dart
OiEmptyState(
  title: 'No invoices yet',
  icon: OiIcons.fileText,
  description: 'Invoices you create will show up here.',
  action: OiButton.primary(
    label: 'New invoice',
    onTap: () => create(),
    semanticLabel: 'New invoice',
  ),
)
```

### Error-page factories

Three factories cover common error states. Each takes optional overrides plus an
`actionLabel` and `onAction` for a primary button.

```dart
OiEmptyState.notFound(onAction: goHome, actionLabel: 'Go home')      // 404
OiEmptyState.forbidden(description: 'You do not have access.')         // 403
OiEmptyState.error(error: exception, onAction: retry, actionLabel: 'Retry') // 500
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | `String` | **required** | The headline, e.g. "No items found". |
| `icon` | `IconData?` | `null` | Icon shown above the title. |
| `illustration` | `Widget?` | `null` | Custom illustration instead of an icon. |
| `description` | `String?` | `null` | Supporting text below the title. |
| `action` | `Widget?` | `null` | Action widget, usually an `OiButton`. |

!!! note
    The `.error()` factory shows `error.toString()` only in debug builds, so
    stack details never leak to users in release.

## OiTooltip

A short hint shown near a widget on hover, or on long-press on touch devices. It
wraps a `child` and needs both a `label` (for screen readers) and a `message`.

```dart
OiTooltip(
  label: 'Refresh help',
  message: 'Reload the latest data',
  child: OiIconButton(
    icon: OiIcons.refresh,
    semanticLabel: 'Refresh',
    onTap: () => refresh(),
  ),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label. |
| `message` | `String` | **required** | The tooltip text. Ignored when `content` is set. |
| `child` | `Widget` | **required** | The widget the tooltip attaches to. |
| `content` | `Widget?` | `null` | Rich content that overrides `message`. |
| `showDelay` | `Duration` | `600ms` | Delay before the tooltip appears. |
| `alignment` | `OiFloatingAlignment` | `topCenter` | Where it appears relative to `child`. |

**Theme:** `context.components.tooltip` → `OiTooltipThemeData`

!!! tip
    For anything richer than a line of text, such as a menu or a preview panel,
    use `OiPopover`.

## OiPopover

A floating content box anchored to a trigger widget. You own the `open` state and
pass content to show. It traps focus and closes on Escape or a tap outside.
The `label` names the open content; the anchor owns its trigger semantics.
This keeps a named button from announcing the popover label a second time.

```dart
bool _open = false;

OiPopover(
  label: 'Filters',
  open: _open,
  onClose: () => setState(() => _open = false),
  anchor: OiButton.outline(
    label: 'Filters',
    onTap: () => setState(() => _open = true),
  ),
  content: const Padding(
    padding: EdgeInsets.all(16),
    child: OiLabel.body('Filter options here'),
  ),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label for the open content. |
| `anchor` | `Widget` | **required** | The trigger, with its own accessible name, that the popover positions against. |
| `content` | `Widget` | **required** | Shown when `open` is true. |
| `open` | `bool` | `false` | Whether the popover is visible. |
| `onClose` | `VoidCallback?` | `null` | Called on Escape or tap outside. |
| `alignment` | `OiFloatingAlignment` | `bottomStart` | Position relative to `anchor`. |
| `initialFocus` | `bool` | `true` | Focus the first focusable child on open. |

!!! note
    For a plain text hint, use `OiTooltip`. For full-page overlays, use `OiDialog`
    or `OiSheet`.

## OiImage

An image with required alt text. It picks `Image.network` for URLs and
`Image.asset` for everything else, and supports placeholder and error widgets.
Never use the raw `Image()` widget.

```dart
OiImage(
  src: 'https://example.com/cover.jpg',
  alt: 'Book cover',
  width: 120,
  height: 160,
  fit: BoxFit.cover,
)
```

For images that carry no information, use `OiImage.decorative`. It drops the image
from the accessibility tree and needs no alt text.

```dart
OiImage.decorative(src: 'assets/texture.png', fit: BoxFit.cover)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `src` | `String` | **required** | Network URL or asset path. |
| `alt` | `String` | **required** | Accessibility description (not on `.decorative`). |
| `width` | `double?` | `null` | Width in logical pixels. |
| `height` | `double?` | `null` | Height in logical pixels. |
| `fit` | `BoxFit?` | `null` | How the image fills its box. |
| `placeholder` | `Widget?` | `null` | Shown while a network image loads. |
| `errorWidget` | `Widget?` | `null` | Shown when loading fails. |

## OiStorageIndicator

A used/total storage bar. It formats byte counts for you and colors the bar by
usage: green under 70 percent, amber over 70, red over 90. Pass a `breakdown` to
split the bar by category.

```dart
OiStorageIndicator(
  usedBytes: 6500000000,
  totalBytes: 10000000000,
)
```

```dart
OiStorageIndicator(
  usedBytes: 6500000000,
  totalBytes: 10000000000,
  breakdown: [
    OiStorageCategory(label: 'Documents', bytes: 4000000000, color: context.colors.primary.base),
    OiStorageCategory(label: 'Media', bytes: 2500000000, color: context.colors.accent.base),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `usedBytes` | `int` | **required** | Bytes currently used. |
| `totalBytes` | `int` | **required** | Total available bytes. |
| `breakdown` | `List<OiStorageCategory>?` | `null` | Split the bar by category. |
| `compact` | `bool` | `false` | Single-line layout. |
| `semanticsLabel` | `String?` | `null` | Override the screen-reader text. |

Each `OiStorageCategory` takes a `label`, a `bytes` count, and a `color`.

## OiPageIndicator

A row of dots showing the current page in a carousel, onboarding flow, or gallery.
You drive `current` from your page controller.

```dart
OiPageIndicator(
  count: 4,
  current: _page,
  onDotTap: (index) => controller.animateToPage(index),
)
```

Use `OiPageIndicator.pill` for a wider pill-shaped active indicator instead of a
dot.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `count` | `int` | **required** | Total pages. |
| `current` | `int` | **required** | Active page index, zero-based. |
| `onDotTap` | `ValueChanged<int>?` | `null` | Called with the tapped dot index. |
| `color` | `Color?` | `null` | Inactive dot color. Defaults to a subtle border color. |
| `activeColor` | `Color?` | `null` | Active dot color. Defaults to primary. |
| `size` | `double` | `8.0` | Dot diameter. |
| `activeSize` | `double?` | `null` | Active dot size, for asymmetric indicators. |
| `spacing` | `double` | `8.0` | Gap between dots. |
| `semanticLabel` | `String?` | `null` | Accessibility label for the group. |

## OiPagination

Set `context.components.pagination.buttonSize` for a consistent compact control
size: arrows use that size, numbered pages use it as their minimum, and the
page-size select follows its height without affecting other inputs. Long page
numbers and scaled text can grow without clipping. `buttonSpacing` controls the
space beside numbered buttons independently.

A standalone page control for paged data that lives outside an `OiTable`, such as
card grids and feeds. `currentPage` is zero-based, and `totalItems` is the full
count, not the page count.

```dart
OiPagination(
  totalItems: 240,
  currentPage: _page,
  label: 'products',
  onPageChange: (page) => setState(() => _page = page),
  onPerPageChange: (n) => setState(() => _perPage = n),
)
```

### Variants

```dart
// Compact: just "X / Y" with prev/next arrows.
OiPagination.compact(
  totalItems: 240,
  currentPage: _page,
  label: 'products',
  onPageChange: (page) => setState(() => _page = page),
)

// Load-more: a button for infinite-scroll patterns. Hides when fully loaded.
OiPagination.loadMore(
  loadedCount: _items.length,
  totalItems: 240,
  label: 'products',
  onLoadMore: loadNextPage,
  loading: _loading,
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `totalItems` | `int` | **required** | Total item count across all pages. |
| `currentPage` | `int` | **required** | Zero-based current page index. |
| `label` | `String` | **required** | Item noun for a11y, e.g. 'products'. |
| `perPage` | `int` | `25` | Items shown per page. |
| `perPageOptions` | `List<int>` | `[10, 25, 50, 100]` | Choices in the per-page selector. |
| `onPageChange` | `ValueChanged<int>?` | `null` | Fires with the new zero-based page. |
| `onPerPageChange` | `ValueChanged<int>?` | `null` | Fires with the new per-page value. |
| `showPerPage` | `bool` | `true` | Show the per-page selector. |
| `showTotal` | `bool` | `true` | Show the total count. |
| `showFirstLast` | `bool` | `true` | Show first and last page buttons. |
| `siblingCount` | `int` | `1` | Page numbers shown either side of the current page. |
| `variant` | `OiPaginationVariant` | `pages` | `pages` or `compact`. |

!!! note
    Inside an `OiTable`, use its built-in pagination. Reach for `OiPagination`
    only for lists that are not tables.

## Related

- [Buttons & Actions](buttons.md) for the buttons a card or popover triggers.
- [Overlays & Menus](overlays.md) for dialogs, sheets, and menus.
- [Feedback & Status](feedback.md) for progress bars and loading states.
- [Text Inputs](text-inputs.md) for the editable counterparts to `OiFieldDisplay`.

## Capacity and budget ratios

`OiCapacityIndicator(value:, max:, label:)` presents a bounded resource with a thin progress track and an optional striped remainder. Configure `subtitle`, `warningThreshold`, `warningText`, `color`, `warningColor` and `valueLabel` for capacity, budget or storage displays. Values above the maximum remain visible in the label while the fill is clamped. A zero maximum renders an empty track. The control exposes the actual ratio through semantics and supports right-to-left layouts. Set `horizontal: true` and optionally `trackWidth` for compact label / track / ratio rows.

`OiAvatar.foregroundColor` complements `backgroundColor` for legible initials and icons on pale brand backgrounds.
