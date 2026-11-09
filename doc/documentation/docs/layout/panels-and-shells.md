# Panels & App Shells

This page covers the pieces you use to build the frame of a desktop-style app.
You start with a themed surface and a divider. You add bordered panels and their
headers. You put draggable dividers between regions. Then you assemble whole-app
frames with columns, sidebars, and page headers.

| Widget | What it does |
| --- | --- |
| `OiSurface` | The themed container primitive. Backgrounds, borders, shadows. |
| `OiDivider` | A separator line, horizontal or vertical. |
| `OiPanel` | A slide-in side panel for detail views and drawers. |
| `OiPanelHeader` | A titled header bar for a panel or a split pane. |
| `OiSplitPane` | Two panes with a draggable divider between them. |
| `OiResizable` | A container the user drags by its edges to resize. |
| `OiThreeColumnLayout` | An IDE-style left, middle, right frame with resizable dividers. |
| `OiResponsiveShell` | A navigation shell that adapts from bottom bar to rail. |
| `OiSidebar` | The desktop app sidebar with sections and badges. |
| `OiPageHeader` | A page-level header with breadcrumbs, title, and actions. |

## OiSurface

The building block for custom containers. It renders a background, an optional
border, corner radius, and a shadow, all from theme values. Reach for it when you
need a styled box and `OiCard` is too opinionated.

```dart
OiSurface(
  color: context.colors.surface,
  border: OiBorderStyle.solid(context.colors.border, 1),
  borderRadius: context.radius.md,
  padding: EdgeInsets.all(context.spacing.md),
  child: OiLabel.body('Content inside a themed surface'),
)
```

Two named constructors cover common cases.

```dart
// Transparent box that still clips and takes hits. Replaces Material(color: transparent).
OiSurface.transparent(child: myOverlayContent)

// Adds a shadow without a background fill.
OiSurface.elevated(elevation: myShadowList, child: myFloatingContent)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `color` | `Color?` | theme surface | Background fill. Falls back to `context.colors.surface`. |
| `border` | `OiBorderStyle?` | `null` | Border style. Use `OiBorderStyle.solid/.dashed/.dotted`. |
| `borderRadius` | `BorderRadius?` | `null` | Corner radius. Falls back to the border's own radius. |
| `shadow` | `List<BoxShadow>?` | `null` | Drop shadows beneath the surface. |
| `padding` | `EdgeInsetsGeometry?` | `null` | Inner padding around `child`. |
| `halo` | `OiHaloStyle?` | `null` | A glow rendered as an extra shadow. |
| `frosted` | `bool` | `false` | Frosted-glass backdrop blur behind the surface. |
| `gradient` | `OiGradientStyle?` | `null` | Background gradient. Overrides `color`. |
| `child` | `Widget?` | `null` | The content to render inside. |

!!! note
    For a standard card with a title, footer, and tap handling, use `OiCard`.
    Reach for `OiSurface` when you are composing a new layout by hand.

## OiDivider

A thin separator line. It runs horizontal by default. Set `axis` to
`Axis.vertical` to split a row. It can also carry a centered label or widget.

```dart
OiDivider()

// Vertical divider between two items in a row.
OiDivider(axis: Axis.vertical)

// A labelled divider, good for "or" separators in forms.
OiDivider.withLabel('or')
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `axis` | `Axis` | `horizontal` | Line direction. |
| `thickness` | `double` | `1.0` | Stroke thickness in logical pixels. |
| `color` | `Color?` | theme border | Line color. Falls back to `context.colors.border`. |
| `style` | `OiBorderLineStyle` | `solid` | `solid`, `dashed`, or `dotted`. |
| `spacing` | `double` | `0` | Extra space added on both sides of the line. |

The `OiDivider.withLabel(String)` and `OiDivider.withContent(Widget)`
constructors center text or a widget in the line. They take the same styling
parameters.

## OiPanel

A slide-in side panel. It animates in from one edge when `open` is `true` and
slides back out when `false`. Use it for detail views, chat, or notification
drawers on pointer-first desktop layouts. You own the `open` state.

```dart
OiPanel(
  label: 'Details',
  open: _detailsOpen,
  side: OiPanelSide.right,
  size: 360,
  showScrim: true,
  onClose: () => setState(() => _detailsOpen = false),
  child: OiColumn(
    children: [
      OiPanelHeader(label: 'Details'),
      OiLabel.body('Panel body'),
    ],
  ),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label for the panel. |
| `child` | `Widget` | **required** | The panel content. |
| `open` | `bool` | **required** | Whether the panel is currently open. |
| `onClose` | `VoidCallback?` | `null` | Called on scrim tap or Escape. |
| `side` | `OiPanelSide` | `left` | Edge to slide from: `left`, `right`, `top`, `bottom`. |
| `size` | `double?` | `null` | Fixed width or height. Sizes to content when null. |
| `dismissible` | `bool` | `true` | Whether a scrim tap dismisses the panel. |
| `showScrim` | `bool` | `false` | Show a semi-transparent scrim behind the panel. |
| `duration` | `Duration` | `240ms` | Slide animation duration. |

!!! note
    `OiPanel` is for auxiliary content, not primary navigation. For app
    navigation, use `OiSidebar`.

## OiPanelHeader

A titled header bar for the top of a panel, split pane, or any bordered region.
It gives you a label, an optional subtitle, and leading and trailing slots for
icons or actions.

```dart
OiPanelHeader(
  label: 'Properties',
  subtitle: '12 items',
  trailing: OiIconButton(icon: OiIcons.settings, semanticLabel: 'Settings'),
  size: OiPanelHeaderSize.compact,
  border: OiPanelHeaderBorder.bottom,
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | The primary title text. |
| `leading` | `Widget?` | `null` | Widget before the title, such as an icon. |
| `trailing` | `Widget?` | `null` | Widget after the title, such as action icons. |
| `subtitle` | `String?` | `null` | Subtitle shown below the label. |
| `size` | `OiPanelHeaderSize` | `medium` | `compact` (32px), `medium` (48px), or `large` (64px). |
| `border` | `OiPanelHeaderBorder` | `bottom` | `none`, `bottom`, or `all`. |
| `backgroundColor` | `Color?` | theme surface | Overrides the surface background. |
| `onTap` | `VoidCallback?` | `null` | When set, adds hover and focus states via `OiTappable`. |
| `semanticLabel` | `String?` | `null` | Screen-reader text. Falls back to `label`. |

!!! note
    Use `OiPanelHeader` inside panels and split panes. For a page-level header,
    use `OiPageHeader`.

## OiSplitPane

Two panes with a draggable divider between them. The user drags the divider to
change the split. The position is a ratio from `0.0` to `1.0` of the space given
to the leading pane. Good for a sidebar plus content, or a master-detail view.

```dart
OiSplitPane(
  initialRatio: 0.3,
  minRatio: 0.2,
  maxRatio: 0.6,
  leading: myListPane,
  trailing: myDetailPane,
  onRatioChanged: (ratio) => print('split at $ratio'),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `leading` | `Widget` | **required** | The left or top pane. |
| `trailing` | `Widget` | **required** | The right or bottom pane. |
| `direction` | `Axis` | `horizontal` | `horizontal` places panes side by side. |
| `initialRatio` | `double` | `0.5` | Starting fraction given to `leading`. |
| `minRatio` | `double` | `0.1` | Smallest allowed ratio. |
| `maxRatio` | `double` | `0.9` | Largest allowed ratio. |
| `dividerSize` | `double` | `4` | Thickness of the divider strip. |
| `onDividerDragStart` | `VoidCallback?` | `null` | Called once when a drag begins. |
| `onRatioChanged` | `void Function(double)?` | `null` | Called continuously during a drag. |
| `settingsDriver` | `OiSettingsDriver?` | `null` | Persists the ratio across sessions. |
| `settingsKey` | `String?` | `null` | Sub-key to tell multiple split panes apart. |

!!! tip
    Pass a `settingsDriver` and a `settingsKey` to remember the split position
    between app launches.

## OiResizable

A container the user resizes by dragging its edges or corners. You pick which
edges are draggable. Use it for resizable panels, floating editors, or a sidebar
you want the user to size.

```dart
OiResizable(
  initialWidth: 280,
  minWidth: 200,
  maxWidth: 480,
  resizeEdges: const {OiResizeEdge.right},
  onResized: (width, height) => print('now $width x $height'),
  child: myPanelContent,
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | **required** | The content to make resizable. |
| `resizeEdges` | `Set<OiResizeEdge>` | `{right, bottom, bottomRight}` | Which edges and corners drag. |
| `minWidth` | `double?` | `null` | Smallest allowed width. |
| `maxWidth` | `double?` | `null` | Largest allowed width. |
| `minHeight` | `double?` | `null` | Smallest allowed height. |
| `maxHeight` | `double?` | `null` | Largest allowed height. |
| `initialWidth` | `double?` | `null` | Starting width. Sizes to content when null. |
| `initialHeight` | `double?` | `null` | Starting height. Sizes to content when null. |
| `onResized` | `void Function(double, double)?` | `null` | Called with the new width and height. |
| `handleSize` | `double` | `8` | Hit area of each drag handle in logical pixels. |

`OiResizeEdge` values are `top`, `bottom`, `left`, `right`, `topLeft`,
`topRight`, `bottomLeft`, and `bottomRight`.

!!! tip
    `OiResizable` sizes one region on its own. To split a space between two
    regions, use `OiSplitPane` instead.

## OiThreeColumnLayout

An IDE-style frame: a left navigation column, a middle content area, and an
optional right detail panel. The dividers between columns are draggable, and each
side column clamps to a min and max width.

```dart
OiThreeColumnLayout(
  label: 'Workspace',
  leftColumn: mySidebar,
  middleColumn: myEditor,
  rightColumn: myInspector,
  leftColumnWidth: 260,
  rightColumnWidth: 320,
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `leftColumn` | `Widget` | **required** | The left navigation column. |
| `middleColumn` | `Widget` | **required** | The main content area. |
| `label` | `String` | **required** | Accessibility label. |
| `rightColumn` | `Widget?` | `null` | Optional detail or preview panel. |
| `leftColumnWidth` | `double` | `260` | Initial left width. |
| `leftColumnMinWidth` | `double` | `200` | Smallest left width. |
| `leftColumnMaxWidth` | `double` | `400` | Largest left width. |
| `rightColumnWidth` | `double` | `320` | Initial right width. |
| `rightColumnMinWidth` | `double` | `250` | Smallest right width. |
| `rightColumnMaxWidth` | `double` | `500` | Largest right width. |
| `showRightColumn` | `bool` | `true` | Hide the right column when false. |
| `resizable` | `bool` | `true` | Whether the dividers can be dragged. |
| `onColumnWidthChanged` | `void Function(double, double)?` | `null` | Called with the new left and right widths. |

## OiResponsiveShell

A navigation shell that adapts to the viewport. It shows a bottom bar on narrow
screens, a compact navigation rail on tablets, and an expanded rail with labels
on wide screens. You give it one list of items and it handles the rest.

```dart
OiResponsiveShell(
  items: const [
    OiNavigationItem(icon: OiIcons.house, label: 'Home'),
    OiNavigationItem(icon: OiIcons.search, label: 'Search'),
    OiNavigationItem(icon: OiIcons.user, label: 'Profile'),
  ],
  currentIndex: _index,
  onTap: (index) => setState(() => _index = index),
  body: _pages[_index],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `List<OiNavigationItem>` | **required** | Navigation destinations. |
| `currentIndex` | `int` | **required** | Index of the active item. |
| `onTap` | `ValueChanged<int>` | **required** | Called when an item is tapped. |
| `body` | `Widget` | **required** | The main content area. |
| `railLeading` | `Widget?` | `null` | Widget above the rail items, such as a logo. |
| `railTrailing` | `Widget?` | `null` | Widget below the rail items, such as a settings icon. |
| `floatingAction` | `Widget?` | `null` | A floating action widget. |
| `breakpoints` | `OiResponsiveShellBreakpoints` | rail 600, expanded 1200 | Width thresholds for switching layout. |

!!! note
    Use `OiResponsiveShell` for apps that span mobile to desktop. For a
    desktop-only admin frame, reach for `OiSidebar` or `OiAppShell`.

## OiSidebar

The desktop app sidebar. It groups navigation items into sections, shows badge
counts, and switches between full, compact, and hidden modes. You track the
selected item by id.

```dart
OiSidebar(
  label: 'Main navigation',
  selectedId: _selectedId,
  onSelect: (id) => setState(() => _selectedId = id),
  sections: const [
    OiSidebarSection(
      title: 'Workspace',
      items: [
        OiSidebarItem(id: 'home', label: 'Home', icon: OiIcons.house),
        OiSidebarItem(id: 'inbox', label: 'Inbox', icon: OiIcons.inbox, badgeCount: 3),
      ],
    ),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sections` | `List<OiSidebarSection>` | **required** | Grouped navigation items. |
| `selectedId` | `String?` | **required** | Id of the highlighted item. |
| `onSelect` | `ValueChanged<String>` | **required** | Called with the tapped item id. |
| `label` | `String` | **required** | Accessibility label for the nav landmark. |
| `mode` | `OiSidebarMode` | `full` | `full` (260px), `compact` (64px), or `hidden`. |
| `width` | `double` | `260` | Width in full mode. |
| `compactWidth` | `double` | `64` | Width in compact mode. |
| `resizable` | `bool` | `false` | Whether the sidebar edge can be dragged. |
| `header` | `Widget?` | `null` | Widget above the items, such as a logo. |
| `footer` | `Widget?` | `null` | Widget below the items, such as a user menu. |

Each `OiSidebarSection` takes `items`, an optional `title`, and a `collapsible`
flag. Each `OiSidebarItem` takes `id`, `label`, `icon`, an optional `badgeCount`,
optional nested `children`, and a `disabled` flag.

**Theme:** `context.components.sidebar` → `OiSidebarThemeData`

## OiPageHeader

`actionAlignment` controls the vertical alignment of the action group on wide
screens. Its default is `CrossAxisAlignment.start`; use `CrossAxisAlignment.end`
when actions should align with the bottom of a title and subtitle. Narrow headers
keep actions below the heading, preserving readable content and useful targets.

A page-level header. It stacks an optional breadcrumb trail, a title row with an
optional status badge and action buttons, and an optional bottom slot for tabs.
Every slot except the title is optional, so it collapses to a plain title row
when you pass nothing else.

```dart
OiPageHeader(
  title: 'Users',
  breadcrumbs: [
    OiBreadcrumbItem(label: 'Home', onTap: () => go('/')),
    OiBreadcrumbItem(label: 'Users'),
  ],
  statusBadge: OiBadge.soft(label: '142 active', color: OiBadgeColor.success),
  actions: [
    OiButton.primary(label: 'Add User', onTap: () {}),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | `String` | **required** | The page title. |
| `breadcrumbs` | `List<OiBreadcrumbItem>?` | `null` | Breadcrumb trail above the title. |
| `statusBadge` | `Widget?` | `null` | Badge shown next to the title, such as `OiBadge`. |
| `actions` | `List<Widget>?` | `null` | Action widgets at the trailing end of the title row. |
| `bottom` | `Widget?` | `null` | Widget below the title row, such as `OiTabs`. |

!!! note
    Use `OiPageHeader` for the top of a page. For the header inside a panel or
    split pane, use `OiPanelHeader`.

## Batteries included

The widgets above are the parts you assemble by hand. If you want the whole
admin frame in one widget, with a sidebar, a top bar, and a responsive drawer
already wired together, use `OiAppShell`. See
[Modules > App Shell](../modules/app-shell.md).

## Related

- [Grid System](grid.md) for laying out content inside a panel or column.
- [Page & Section](page-and-section.md) for page scaffolding and content sections.
- [Flex Layouts](flex.md) for `OiRow`, `OiColumn`, and responsive gaps.
