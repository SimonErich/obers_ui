# App Shell & Navigation

These are batteries-included app frames. You give them your navigation and your
content, and they wire up the sidebar, the top bar, and the responsive behavior
for you. Reach for them when you want a working app layout without assembling the
lower-level panels by hand.

| Widget | What it does |
| --- | --- |
| `OiAppShell` | A full admin frame: sidebar, top bar, and content area with responsive collapse. |
| `OiDrawerNavigation` | A slide-out navigation drawer with a user header, sections, and nested submenus. |

## OiAppShell

The main scaffold for admin-style apps and dashboards. It composes a sidebar, a
top bar (title, breadcrumbs, actions, user menu), and your content area. On wide
screens the sidebar sits on the left. Below `mobileBreakpoint` the sidebar
becomes a slide-in drawer with a hamburger button in the top bar.

You always pass three things: the `child` content, a `label` for accessibility,
and the `navigation` items.

```dart
OiAppShell(
  label: 'Admin',
  currentRoute: '/dashboard',
  onNavigate: (route) => context.go(route),
  leading: OiLabel.h4('Acme'),
  title: 'Dashboard',
  navigation: [
    OiNavItem(label: 'Dashboard', icon: OiIcons.home, route: '/dashboard'),
    OiNavItem(label: 'Users', icon: OiIcons.users, route: '/users', badge: '12'),
    OiNavItem(label: 'Settings', icon: OiIcons.settings, route: '/settings'),
  ],
  child: const DashboardPage(),
)
```

### Navigation items

Each entry is an `OiNavItem`. Set `route` for active-state matching against
`currentRoute`. Group items under a header with `section`. Nest items with
`children` to get an accordion. A numeric `badge` string shows a count beside the
label.

```dart
OiAppShell(
  label: 'Admin',
  currentRoute: _route,
  onNavigate: (route) => setState(() => _route = route),
  navigation: [
    OiNavItem(label: 'Overview', icon: OiIcons.home, route: '/', section: 'Main'),
    OiNavItem(label: 'Orders', icon: OiIcons.cart, route: '/orders', section: 'Main'),
    OiNavItem(
      label: 'Reports',
      icon: OiIcons.chart,
      section: 'Insights',
      children: [
        OiNavItem(label: 'Sales', icon: OiIcons.chart, route: '/reports/sales'),
        OiNavItem(label: 'Traffic', icon: OiIcons.chart, route: '/reports/traffic'),
      ],
    ),
  ],
  child: const OverviewPage(),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | **required** | The main content area. |
| `label` | `String` | **required** | Accessibility label for the shell. |
| `navigation` | `List<OiNavItem>` | **required** | Sidebar navigation items. |
| `currentRoute` | `String?` | `null` | The active route, matched against each item's `route`. |
| `onNavigate` | `ValueChanged<String>?` | `null` | Fires with the selected item's `route` (or `label` if it has no route). |
| `leading` | `Widget?` | `null` | Logo or app name shown in the sidebar header. |
| `title` | `String?` | `null` | Page title shown in the top bar. |
| `actions` | `List<Widget>?` | `null` | Widgets pinned to the right of the top bar. |
| `userMenu` | `Widget?` | `null` | User menu widget at the far right of the top bar. |
| `breadcrumbs` | `List<OiBreadcrumbItem>?` | `null` | Breadcrumb trail for the top bar. |
| `showBreadcrumbs` | `bool` | `true` | Whether to render the breadcrumbs. |
| `sidebarCollapsible` | `bool` | `true` | Whether the collapse toggle is shown. |
| `sidebarDefaultCollapsed` | `bool` | `false` | Whether the sidebar starts collapsed. |
| `sidebarWidth` | `double` | `256` | Sidebar width when expanded. |
| `sidebarCollapsedWidth` | `double` | `64` | Sidebar width in icon-only mode. |
| `mobileBreakpoint` | `OiBreakpoint` | `OiBreakpoint.medium` | Below this width the sidebar becomes a drawer. |

### OiNavItem

The model for each sidebar entry.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Display text. |
| `icon` | `IconData` | **required** | Leading icon. |
| `route` | `String?` | `null` | Route used for active-state matching and `onNavigate`. |
| `children` | `List<OiNavItem>?` | `null` | Nested items rendered as an accordion. |
| `badge` | `String?` | `null` | Badge text beside the label. A numeric string shows as a count. |
| `section` | `String?` | `null` | Group header. Items sharing a value sit under one header. |
| `dividerBefore` | `bool` | `false` | Inserts a divider before this item. |

### Responsive behavior and persistence

The layout switches on width. At or above `mobileBreakpoint` you get the sidebar
plus top bar. Below it, the sidebar collapses into a drawer that opens from the
hamburger button, and tapping an item closes the drawer.

The collapsed state animates the sidebar width. To remember it across sessions,
pass a `settingsDriver`. The shell then persists `sidebarCollapsed` under
`settingsNamespace` (default `oi_app_shell`), scoped by an optional `settingsKey`.

```dart
OiAppShell(
  label: 'Admin',
  navigation: navItems,
  settingsDriver: mySettingsDriver,
  settingsKey: 'primary',
  child: const HomePage(),
)
```

!!! note
    If you do not pass a `settingsDriver`, the shell falls back to an
    `OiSettingsProvider` above it in the tree. With neither, the collapsed state
    is not persisted and resets on reload.

## OiDrawerNavigation

A slide-out navigation drawer. It shows an optional user header, one or more
sections of tappable items, and an optional footer pinned to the bottom. Items
with `children` open a nested submenu that slides in, with a back button to
return. Reach for it for mobile-first navigation or a hamburger menu.

```dart
OiDrawerNavigation(
  label: 'Main navigation',
  selectedKey: _selected,
  onItemTap: (item) => setState(() => _selected = item.key),
  header: OiDrawerHeader(name: 'Jane Doe', subtitle: 'Admin'),
  sections: [
    OiDrawerSection(
      title: 'Main',
      items: [
        OiDrawerItem(key: 'home', label: 'Home', icon: OiIcons.home),
        OiDrawerItem(key: 'settings', label: 'Settings', icon: OiIcons.settings),
      ],
    ),
  ],
)
```

### Sections, submenus, and toggles

Each `OiDrawerSection` has a list of `items` and an optional `title`. A section
can also carry `toggles`, which render as switch tiles below its items. Give an
item `children` to turn it into a submenu.

```dart
OiDrawerSection(
  title: 'Workspace',
  items: [
    OiDrawerItem(
      key: 'projects',
      label: 'Projects',
      icon: OiIcons.folder,
      badge: '4',
      children: [
        OiDrawerItem(key: 'active', label: 'Active'),
        OiDrawerItem(key: 'archived', label: 'Archived'),
      ],
    ),
  ],
  toggles: [
    OiDrawerToggle(
      label: 'Compact mode',
      value: _compact,
      onChanged: (v) => setState(() => _compact = v),
    ),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sections` | `List<OiDrawerSection>` | **required** | The grouped navigation content. |
| `label` | `String` | **required** | Accessibility label for the drawer. |
| `header` | `OiDrawerHeader?` | `null` | User or account header at the top. |
| `footer` | `Widget?` | `null` | Widget pinned to the bottom. |
| `selectedKey` | `Object?` | `null` | Key of the active item, highlighted in the list. |
| `onItemTap` | `ValueChanged<OiDrawerItem>?` | `null` | Fires when a leaf item is tapped. |
| `width` | `double` | `300` | Drawer width in logical pixels. |
| `showDividers` | `bool` | `true` | Whether to draw dividers between sections. |

### OiDrawerItem

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `Object` | **required** | Unique identifier used for selection. |
| `label` | `String` | **required** | Display text. |
| `icon` | `IconData?` | `null` | Optional leading icon. |
| `badge` | `String?` | `null` | Badge text at the end of the row. |
| `children` | `List<OiDrawerItem>?` | `null` | Nested items shown in a slide-in submenu. |
| `trailing` | `Widget?` | `null` | Widget at the end of the row. |
| `onTap` | `VoidCallback?` | `null` | Called when the item is tapped (leaf items only). |
| `disabled` | `bool` | `false` | Set `true` to dim and block the item. |

### OiDrawerHeader

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `String` | **required** | Account or user name. |
| `subtitle` | `String?` | `null` | Secondary text below the name. |
| `avatarUrl` | `String?` | `null` | Image URL for the avatar. |
| `avatarWidget` | `Widget?` | `null` | Custom avatar that overrides the default. |
| `onTap` | `VoidCallback?` | `null` | Called when the header is tapped. |

!!! tip
    Use `OiDrawerNavigation` on its own for a mobile menu you control. For a full
    desktop admin frame with a top bar, reach for `OiAppShell`, which already
    turns its sidebar into a drawer on small screens.

## Related

- [Page & Section](../layout/page-and-section.md) for the lower-level page and panel layout pieces.
- [Layout](../layout/index.md) for the grid, flex, and structural primitives an app shell holds.
- [Navigation](../widgets/navigation.md) for tabs, breadcrumbs, rails, and bottom bars.

## Primary and contextual navigation

`OiAppShell.primaryNavigation` adds an optional icon rail beside the existing
`navigation` sidebar. Both use `OiNavItem` and stable route strings. Supply
`currentPrimaryRoute` and `onPrimaryNavigate` when primary destinations have a
separate selection from contextual routes. `primaryLeading` and `primaryTrailing`
host branding and utility controls; `navigationHeader` and `navigationFooter`
belong to the contextual sidebar. The `search` slot sits in the shared top bar.
Routed content has its own accessibility boundary. A nested navigator can
manage page semantics without hiding the shell header or navigation controls.

On compact screens the shell presents both navigation levels in its drawer.
Closed drawers keep their animated content mounted but remove it from pointer,
keyboard and accessibility interaction until reopened.

Set `onSearch` and `searchLabel` alongside the `search` field to provide an
accessible icon-button fallback below 600px of header width. The shell reserves
the themed button width instead of shrinking an input until its icon disappears.
The compact button uses the same callback and supports Enter/Space activation.
With `onSearch` and no `search` widget, the icon button appears at every width.

`OiAppShellThemeData` configures top-bar height/padding, rail width, search maximum
width and surfaces. Sidebar and rail component themes control their individual
items, colors, typography and dimensions. Explicit widget dimensions take
precedence; omitted dimensions resolve from the nearest component theme.

`OiPageHeader` supports description, metadata, leading/trailing content and wrapping
actions. Its existing `breadcrumbs`, `statusBadge` and `bottom` slots remain.
Choose `titleVariant: OiLabelVariant.h1` for a large page heading; the default
remains h4. `OiPageLayout` places header, navigation, content, aside and pinned
footer into shared regions. Set `scrollable: true` for intrinsic content; keep it
false for tables or widgets which own their scroll view. Narrow layouts expose
the aside through a keyboard-accessible sheet.
