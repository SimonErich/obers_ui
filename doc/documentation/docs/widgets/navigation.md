# Navigation

Navigation widgets move people between views, sections, and places in your app.
ObersUI covers the common cases: tabs on a page, a rail or drawer on the side,
a bottom bar on mobile, breadcrumbs for hierarchy, and a set of header controls
for accounts, users, language, and theme. Every one reads its colors, spacing,
and radius from the theme.

| Widget | What it does |
| --- | --- |
| `OiTabs` | Horizontal tab bar for switching views on one page. |
| `OiTabView` | A tab bar plus the content area, with lazy loading and swipe. |
| `OiAccordion` | Collapsible sections, one or many open at a time. |
| `OiBreadcrumbs` | A path trail showing where you are in a hierarchy. |
| `OiNavigationRail` | A compact vertical rail for desktop and tablet. |
| `OiDrawer` | A side panel that slides in for mobile menus. |
| `OiBottomBar` | The mobile bottom navigation bar, 3 to 5 tabs. |
| `OiMenuBar` | A desktop menu bar (File, Edit, View) with dropdowns. |
| `OiStatusBar` | A thin bottom status bar with leading and trailing slots. |
| `OiIndexBar` | An A to Z sidebar for fast jumping in long lists. |
| `OiAccountSwitcher` | A workspace or organization selector dropdown. |
| `OiUserMenu` | An avatar-triggered menu for profile, settings, logout. |
| `OiLocaleSwitcher` | A language dropdown with flag, name, and code. |
| `OiThemeToggle` | Switches between light, dark, and system theme. |
| `OiPathBar` | An editable file-path breadcrumb for file explorers. |
| `OiNavMenu` | A flat navigation list with badges and optional reorder. |
| `OiArrowNav` | Keyboard arrow-key navigation wrapped around a child. |
| `OiFilterableNavList` | A searchable, chip-filtered, grouped navigation list. |

## OiTabs

The tab bar you reach for most. It shows a row of tabs and tells you which one
was tapped. You own the `selectedIndex` and update it in `onSelected`.

```dart
int _tab = 0;

OiTabs(
  selectedIndex: _tab,
  onSelected: (index) => setState(() => _tab = index),
  tabs: const [
    OiTabItem(label: 'Overview'),
    OiTabItem(label: 'Activity', badge: 3),
    OiTabItem(label: 'Settings', icon: OiIcons.settings),
  ],
)
```

Pass a `content` widget and `OiTabs` swaps it as the selection changes, so you
do not have to wire that up yourself.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tabs` | `List<OiTabItem>` | **required** | Each has `label`, optional `icon`, optional `badge` (int). |
| `selectedIndex` | `int` | **required** | The active tab index. |
| `onSelected` | `ValueChanged<int>` | **required** | Fires with the tapped index. |
| `indicatorStyle` | `OiTabIndicatorStyle` | `underline` | `underline`, `filled`, or `pill`. |
| `scrollable` | `bool` | `false` | Let the tab bar scroll when tabs overflow. |
| `content` | `Widget?` | `null` | Optional content shown below the bar. |
| `settingsKey` | `String?` | `null` | Persists the selected tab when set. |

**Theme:** `context.components.tabs` → `OiTabsThemeData`

## OiTabView

Use this when you want the tab bar and the content in one widget. Each tab
carries a `builder`, and `OiTabView` builds only the selected tab, with swipe
and an optional keep-alive. It manages its own state by default.

```dart
OiTabView(
  tabs: [
    OiTabViewItem(label: 'Profile', builder: (context) => const ProfilePane()),
    OiTabViewItem(label: 'Billing', builder: (context) => const BillingPane()),
  ],
)
```

For a parent-managed selection, use the controlled constructor and update
`selectedIndex` yourself when `onTabChanged` fires.

```dart
OiTabView.controlled(
  selectedIndex: _index,
  onTabChanged: (i) => setState(() => _index = i),
  tabs: [
    OiTabViewItem(label: 'Profile', builder: (context) => const ProfilePane()),
    OiTabViewItem(label: 'Billing', builder: (context) => const BillingPane()),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tabs` | `List<OiTabViewItem>` | **required** | Each has `label`, `builder`, optional `icon`, `badge` (String), `enabled`. |
| `initialIndex` | `int` | `0` | Starting tab in uncontrolled mode. |
| `onTabChanged` | `ValueChanged<int>?` | `null` | Fires when the tab changes. Required by `.controlled`. |
| `indicatorStyle` | `OiTabIndicatorStyle` | `underline` | `underline`, `filled`, or `pill`. |
| `scrollable` | `bool` | `false` | Scroll the tab bar on overflow. |
| `keepAlive` | `bool` | `false` | Keep all tab content alive in an `IndexedStack`. |
| `swipeable` | `bool` | `true` | Allow horizontal swipe to switch tabs. |
| `semanticLabel` | `String?` | `null` | Screen-reader label for the tab bar. |

!!! tip
    Use `OiTabView` when the tabs own their content. Use `OiTabs` when you need
    the bar alone, for example above a shared scroll view.

## OiAccordion

Collapsible sections for FAQs, settings groups, and long forms. By default one
section is open at a time. Set `allowMultiple` to keep several open.

```dart
OiAccordion(
  sections: const [
    OiAccordionSection(
      title: 'Shipping',
      content: OiLabel.body('We ship worldwide within 3 days.'),
    ),
    OiAccordionSection(
      title: 'Returns',
      content: OiLabel.body('Return any item within 30 days.'),
      initiallyExpanded: true,
    ),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sections` | `List<OiAccordionSection>` | **required** | Each has `title`, `content`, `initiallyExpanded`, `headerBackgroundColor`. |
| `allowMultiple` | `bool` | `false` | Allow more than one section open at once. |
| `settingsKey` | `String?` | `null` | Persists which sections are open when set. |

## OiBreadcrumbs

A trail that shows where the current page sits in a hierarchy. Each item except
the last gets an `onTap` to navigate back up.

```dart
OiBreadcrumbs(
  items: [
    OiBreadcrumbItem(label: 'Home', onTap: () => goHome()),
    OiBreadcrumbItem(label: 'Projects', onTap: () => goProjects()),
    OiBreadcrumbItem(label: 'ObersUI'),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `List<OiBreadcrumbItem>` | **required** | Each has `label` and optional `onTap`. |
| `separator` | `String` | `'/'` | The character drawn between items. |
| `maxVisible` | `int?` | `null` | Collapse the middle items behind an ellipsis when the trail is long. |

## OiNavigationRail

A compact vertical rail for desktop and tablet. It is lighter than a full
sidebar and fits 3 to 7 destinations. You own `currentIndex` and update it in
`onTap`.

```dart
int _index = 0;

OiNavigationRail(
  currentIndex: _index,
  onTap: (i) => setState(() => _index = i),
  items: const [
    OiNavigationItem(icon: OiIcons.home, label: 'Home'),
    OiNavigationItem(icon: OiIcons.search, label: 'Search'),
    OiNavigationItem(icon: OiIcons.settings, label: 'Settings', badge: '2'),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `List<OiNavigationItem>` | **required** | Each has `icon`, `label`, optional `activeIcon`, `badge` (String), `tooltip`. |
| `currentIndex` | `int` | **required** | The selected destination. |
| `onTap` | `ValueChanged<int>` | **required** | Fires with the tapped index. |
| `leading` | `Widget?` | `null` | Widget above the items, such as a logo. |
| `trailing` | `Widget?` | `null` | Widget below the items, such as settings. |
| `width` | `double` | `72` | Rail width in logical pixels. |
| `labelBehavior` | `OiRailLabelBehavior` | `all` | `all`, `selected`, or `none`. |
| `semanticLabel` | `String?` | `null` | Screen-reader label for the rail. |

!!! note
    On mobile, reach for `OiBottomBar`. For a full sidebar with sections and
    nesting, use `OiSidebar`. To switch between rail and bottom bar by
    breakpoint automatically, use `OiResponsiveShell`.

**Theme:** `context.components.navigationRail` → `OiNavigationRailThemeData`

Keep selected and hover colors separate when placing a light indicator on a
contrasting rail. `selectedIconColor` is only used over the selected indicator.
Unselected hover preserves `unselectedIconColor`, or uses the default primary
color when no custom foreground is configured. Set `hoverIconColor`, `hoverColor`
and `hoverLabelStyle` for an explicit hover treatment. Hover label styles merge
over `unselectedLabelStyle`; hovering the selected destination keeps its selected
foreground and indicator. The same rules apply to expanded rails.

## OiDrawer

A side panel that slides in from the edge. It is common for mobile menus. You
control `open` and hide it in `onClose`.

```dart
OiDrawer(
  open: _menuOpen,
  onClose: () => setState(() => _menuOpen = false),
  child: OiColumn(
    children: [
      OiLabel.h3('Menu'),
      OiLabel.body('Home'),
      OiLabel.body('Profile'),
    ],
  ),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | **required** | The drawer content. |
| `open` | `bool` | **required** | Whether the drawer is showing. |
| `width` | `double` | `280` | Drawer width in logical pixels. |
| `onClose` | `VoidCallback?` | `null` | Called when the user taps the scrim to dismiss. |

## OiBottomBar

The bottom navigation bar for mobile apps. Give it 3 to 5 destinations and it
handles the layout, badges, and safe-area insets.

```dart
int _index = 0;

OiBottomBar(
  currentIndex: _index,
  onTap: (i) => setState(() => _index = i),
  items: const [
    OiNavigationItem(icon: OiIcons.home, label: 'Home'),
    OiNavigationItem(icon: OiIcons.search, label: 'Search'),
    OiNavigationItem(icon: OiIcons.user, label: 'Profile', badge: '9+'),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `List<OiNavigationItem>` | **required** | Destinations. Each has `icon`, `label`, `activeIcon`, `badge`. |
| `currentIndex` | `int` | **required** | The active destination. |
| `onTap` | `ValueChanged<int>` | **required** | Fires with the tapped index. |
| `style` | `OiBottomBarStyle` | `fixed` | `fixed`, `shifting`, `labeled`, or `iconOnly`. |
| `floatingAction` | `Widget?` | `null` | A floating action button docked in the center. |
| `showLabels` | `bool` | `true` | Show text labels under the icons. |
| `landscapeMode` | `OiBottomBarLandscapeMode` | `compact` | `compact`, `rail`, or `hidden` in landscape. |

!!! warning
    On desktop, use `OiNavigationRail`, `OiSidebar`, or `OiTabs` instead. For an
    app that adapts across sizes, use `OiResponsiveShell`.

## OiMenuBar

A horizontal menu bar for desktop apps, the File / Edit / View row. Each top
item opens a dropdown built from `OiMenuItem` entries.

```dart
OiMenuBar(
  label: 'Main menu',
  items: [
    OiMenuItem(
      label: 'File',
      children: [
        OiMenuItem(label: 'New', shortcut: 'Ctrl+N', onTap: newFile),
        OiMenuItem(label: 'Open...', shortcut: 'Ctrl+O', onTap: openFile),
        const OiMenuDivider(),
        OiMenuItem(label: 'Exit', onTap: quit),
      ],
    ),
    OiMenuItem(
      label: 'Edit',
      children: [
        OiMenuItem(label: 'Undo', shortcut: 'Ctrl+Z', onTap: undo),
        OiMenuItem(label: 'Redo', shortcut: 'Ctrl+Y', onTap: redo),
      ],
    ),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `List<OiMenuItem>` | **required** | Top-level menus. Each carries `children` for its dropdown. |
| `label` | `String` | **required** | Accessibility label for the bar. |
| `height` | `double` | `28` | Bar height in logical pixels. |
| `backgroundColor` | `Color?` | `null` | Overrides the bar background. |

Each `OiMenuItem` supports `icon`, `shortcut`, `checked`, `destructive`, and
nested `children`. Use `OiMenuDivider` to group entries.

!!! note
    `OiMenuBarItem` and `OiMenuBarDivider` are deprecated aliases. Use
    `OiMenuItem` and `OiMenuDivider`.

## OiStatusBar

A thin bar for the bottom of a desktop window, like an IDE status bar. It takes
lists of widgets for its leading and trailing edges.

```dart
OiStatusBar(
  label: 'Editor status',
  leading: const [
    OiStatusBarItem(label: 'main', icon: OiIcons.gitBranch),
  ],
  trailing: [
    OiStatusBarItem(label: 'UTF-8'),
    OiStatusBarItem(label: 'Ln 12, Col 4', onTap: goToLine),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label for the bar. |
| `leading` | `List<Widget>` | `[]` | Widgets pinned to the start. |
| `trailing` | `List<Widget>` | `[]` | Widgets pinned to the end. |
| `height` | `double` | `24` | Bar height in logical pixels. |
| `backgroundColor` | `Color?` | `null` | Overrides the bar background. |

`OiStatusBarItem` shows an optional `icon`, a `label`, and an optional `color`
status dot. It becomes tappable when you pass `onTap`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | The item text. |
| `icon` | `OiIconData?` | `null` | Optional leading icon. |
| `color` | `Color?` | `null` | Draws a status dot in this color. |
| `onTap` | `VoidCallback?` | `null` | Makes the item tappable. |

## OiIndexBar

A vertical A to Z bar for fast jumping in long, grouped lists. Put it against
the right edge of a contacts list or directory.

```dart
OiIndexBar.alphabet(
  semanticLabel: 'Jump to letter',
  activeLabel: _letter,
  availableLabels: _lettersWithContacts,
  onLabelSelected: (letter) => scrollToLetter(letter),
)
```

For custom labels, use the default constructor with your own list.

```dart
OiIndexBar(
  semanticLabel: 'Jump to section',
  labels: const ['1', '2', '3', 'A', 'B'],
  onLabelSelected: (label) => scrollTo(label),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `labels` | `List<String>` | **required** | The index labels to show (default constructor). |
| `onLabelSelected` | `ValueChanged<String>` | **required** | Fires with the touched label. |
| `semanticLabel` | `String` | **required** | Screen-reader label. |
| `activeLabel` | `String?` | `null` | The currently highlighted label. |
| `availableLabels` | `Set<String>?` | `null` | Labels that have content. Others render dimmed. |
| `size` | `OiIndexBarSize` | `medium` | `small`, `medium`, or `large`. |
| `includeHash` | `bool` | `true` | `.alphabet` only. Append `#` after Z. |

**Theme:** `context.components.indexBar` → `OiIndexBarThemeData`

!!! note
    `OiIndexBar` earns its keep on long lists. Skip it under about 50 items.

## OiAccountSwitcher

A generic dropdown for switching the active workspace, organization, or tenant.
It is typed, so `accounts` can be any model you already have. Selecting one
usually changes the whole app context.

```dart
OiAccountSwitcher<Workspace>(
  label: 'Switch workspace',
  accounts: workspaces,
  activeAccount: current,
  labelOf: (w) => w.name,
  descriptionOf: (w) => w.plan,
  avatarOf: (w) => w.initials,
  onSelect: (w) => switchWorkspace(w),
  onAddAccount: () => createWorkspace(),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `accounts` | `List<T>` | **required** | All available accounts. |
| `activeAccount` | `T` | **required** | The currently active account. |
| `onSelect` | `ValueChanged<T>` | **required** | Fires with the chosen account. |
| `label` | `String` | **required** | Accessibility label. |
| `labelOf` | `String Function(T)?` | `null` | Display name for an account. |
| `avatarOf` | `String Function(T)?` | `null` | Avatar initials or URL. |
| `descriptionOf` | `String Function(T)?` | `null` | Subtitle under each account. |
| `onAddAccount` | `VoidCallback?` | `null` | Adds an "Add account" action. |
| `searchable` | `bool` | `false` | Show a search field in the dropdown. |
| `compact` | `bool` | `false` | Avatar-only trigger. |

**Theme:** `context.components.accountSwitcher` → `OiAccountSwitcherThemeData`

!!! tip
    Use `OiAccountSwitcher` for workspace or org context. For the signed-in
    person's profile and logout, use `OiUserMenu`.

## OiUserMenu

An avatar in the top-right corner that opens a menu of user actions: profile,
settings, sign out. The menu entries are `OiMenuItem`s.

```dart
OiUserMenu(
  label: 'Account menu',
  userName: 'Ada Lovelace',
  userEmail: 'ada@example.com',
  avatarInitials: 'AL',
  items: [
    OiMenuItem(label: 'Profile', icon: OiIcons.user, onTap: openProfile),
    OiMenuItem(label: 'Settings', icon: OiIcons.settings, onTap: openSettings),
    const OiMenuDivider(),
    OiMenuItem(label: 'Sign out', destructive: true, onTap: signOut),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label. |
| `userName` | `String` | **required** | The signed-in user's name. |
| `items` | `List<OiMenuItem>` | **required** | The menu actions. |
| `userEmail` | `String?` | `null` | Shown under the name in the header. |
| `avatarUrl` | `String?` | `null` | Avatar image URL. |
| `avatarInitials` | `String?` | `null` | Fallback initials when there is no image. |
| `header` | `Widget?` | `null` | Replaces the default user header. |

## OiLocaleSwitcher

A language dropdown with a flag emoji, the language name, and its code. You own
the `currentLocale` and update it in `onLocaleChange`.

```dart
OiLocaleSwitcher(
  currentLocale: _locale,
  onLocaleChange: (l) => setState(() => _locale = l),
  locales: const [
    OiLocaleOption(locale: Locale('en'), name: 'English', flagEmoji: '🇬🇧'),
    OiLocaleOption(locale: Locale('de'), name: 'Deutsch', flagEmoji: '🇩🇪'),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `currentLocale` | `Locale` | **required** | The active locale. |
| `locales` | `List<OiLocaleOption>` | **required** | Each has `locale`, `name`, optional `flagEmoji`. |
| `onLocaleChange` | `ValueChanged<Locale>?` | `null` | Fires with the chosen locale. |
| `label` | `String` | `'Language'` | Accessibility label. |
| `showFlag` | `bool` | `true` | Show the flag emoji. |
| `showCode` | `bool` | `false` | Show the language code. |
| `showName` | `bool` | `true` | Show the language name. |

## OiThemeToggle

Switches the app between light, dark, and system theme. It shows a sun, moon, or
monitor icon for the current mode.

```dart
OiThemeToggle(
  currentMode: _mode,
  onModeChange: (m) => setState(() => _mode = m),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `currentMode` | `OiThemeMode` | **required** | The active mode: `light`, `dark`, or `system`. |
| `onModeChange` | `ValueChanged<OiThemeMode>?` | `null` | Fires with the next mode. |
| `label` | `String` | `'Toggle theme'` | Accessibility label. |
| `showSystemOption` | `bool` | `true` | Include the "system" choice in the cycle. |

!!! note
    This uses `OiThemeMode` from ObersUI, not Flutter's `ThemeMode`. The values
    are `light`, `dark`, and `system`.

## OiPathBar

A breadcrumb built for file paths. It shows each segment, lets you tap a segment
to jump there, and can turn into an editable text field for typing a path.

```dart
OiPathBar(
  segments: const [
    OiPathSegment(id: 'root', label: 'Home', icon: OiIcons.home),
    OiPathSegment(id: 'docs', label: 'Documents'),
    OiPathSegment(id: 'work', label: 'Work'),
  ],
  onNavigate: (segment) => openFolder(segment.id),
  onPathSubmit: (path) => openPath(path),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `segments` | `List<OiPathSegment>` | **required** | Each has `id`, `label`, optional `icon`, `onTap`. |
| `onNavigate` | `ValueChanged<OiPathSegment>` | **required** | Fires when a segment is tapped. |
| `onPathSubmit` | `ValueChanged<String>?` | `null` | Fires when the user types and submits a path. |
| `editable` | `bool` | `true` | Allow switching to a text field to type a path. |
| `showIcon` | `bool` | `true` | Show segment icons. |
| `semanticsLabel` | `String?` | `null` | Accessibility label. |

!!! note
    The accessibility parameter here is `semanticsLabel`, with an s, unlike most
    other widgets that use `semanticLabel`.

## OiNavMenu

A flat list of navigation items with icons and badge counts. It can reorder by
drag and open a context menu per item. You own `selectedId` and update it in
`onSelect`.

```dart
OiNavMenu(
  label: 'Sections',
  selectedId: _selected,
  onSelect: (id) => setState(() => _selected = id),
  items: const [
    OiNavMenuItem(id: 'inbox', label: 'Inbox', icon: OiIcons.mail, badgeCount: 4),
    OiNavMenuItem(id: 'sent', label: 'Sent', icon: OiIcons.send),
    OiNavMenuItem(id: 'archive', label: 'Archive', icon: OiIcons.archive),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `List<OiNavMenuItem>` | **required** | Each has `id`, `label`, optional `icon`, `badgeCount`, `color`, `disabled`. |
| `selectedId` | `String?` | **required** | The selected item id, or `null` for none. |
| `onSelect` | `ValueChanged<String>` | **required** | Fires with the tapped item id. |
| `label` | `String` | **required** | Accessibility label. |
| `reorderable` | `bool` | `false` | Allow drag-to-reorder. |
| `onReorder` | `void Function(int, int)?` | `null` | Fires with old and new index when reordered. |
| `contextMenu` | `List<OiMenuItem> Function(OiNavMenuItem)?` | `null` | Builds a right-click menu per item. |
| `header` / `footer` | `Widget?` | `null` | Fixed widgets above and below the list. |

## OiArrowNav

A wrapper that adds arrow-key navigation to a child. It does not draw anything
itself. You tell it how many items there are and which one is highlighted, and
it maps the arrow, Enter, and Escape keys to callbacks. Good for custom lists,
menus, and command palettes.

```dart
OiArrowNav(
  itemCount: results.length,
  highlightedIndex: _highlighted,
  onHighlightChange: (i) => setState(() => _highlighted = i),
  onSelect: (i) => choose(results[i]),
  onEscape: () => close(),
  child: OiColumn(
    children: [
      for (var i = 0; i < results.length; i++)
        ResultRow(result: results[i], highlighted: i == _highlighted),
    ],
  ),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | **required** | The list or content to navigate. |
| `itemCount` | `int` | **required** | How many items the arrows step through. |
| `highlightedIndex` | `int?` | `null` | The currently highlighted index. |
| `onHighlightChange` | `ValueChanged<int>?` | `null` | Fires when the arrow keys move the highlight. |
| `onSelect` | `ValueChanged<int>?` | `null` | Fires on Enter with the highlighted index. |
| `onEscape` | `VoidCallback?` | `null` | Fires on Escape. |
| `direction` | `Axis` | `vertical` | Which arrow keys step, up/down or left/right. |
| `loop` | `bool` | `true` | Wrap from the last item back to the first. |
| `typeAhead` | `bool` | `false` | Jump by typing, using `itemLabel`. |
| `itemLabel` | `String Function(int)?` | `null` | Label per index for type-ahead. |

## OiFilterableNavList

A typed navigation list with a pinned search field, toggleable chip filters, and
collapsible groups. It auto-expands a group when a search matches inside it. Use
it for filterable sidebars, requirement lists, and inventories.

```dart
OiFilterableNavList<Screen>(
  label: 'Screens',
  items: screens,
  groups: const [
    OiNavGroup(id: 'auth', label: 'Auth'),
    OiNavGroup(id: 'admin', label: 'Admin'),
  ],
  idOf: (s) => s.id,
  groupIdOf: (s) => s.groupId,
  titleOf: (s) => s.name,
  selectedItemId: _selectedId,
  onItemSelected: (s) => open(s),
  chipFilters: const [
    OiChipFilter(id: 'wip', label: 'In progress'),
  ],
  chipFilterOf: (s) => s.tags,
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `List<T>` | **required** | The items to list. |
| `groups` | `List<OiNavGroup>` | **required** | Group definitions with `id`, `label`, `sortOrder`. |
| `idOf` | `String Function(T)` | **required** | The stable id for an item. |
| `groupIdOf` | `String Function(T)` | **required** | Which group an item belongs to. |
| `titleOf` | `String Function(T)` | **required** | The item's display title. |
| `label` | `String` | **required** | Accessibility label. |
| `subtitleOf` | `String Function(T)?` | `null` | Optional subtitle per item. |
| `iconOf` | `IconData Function(T)?` | `null` | Optional icon per item. |
| `searchPlaceholder` | `String` | `'Search...'` | Placeholder for the search field. |
| `chipFilters` | `List<OiChipFilter>?` | `null` | The filter chips to show. |
| `chipFilterOf` | `Set<String> Function(T)?` | `null` | Which chip ids an item matches. |
| `selectedItemId` | `String?` | `null` | The selected item id. |
| `onItemSelected` | `void Function(T)?` | `null` | Fires with the tapped item. |
| `itemLoadingIds` | `Set<String>?` | `null` | Ids to render in a loading state. |

## Related

- [Overlays & Menus](overlays.md) for the menus a menu bar or user menu opens.
- [Buttons & Actions](buttons.md) for back buttons, action bars, and toolbars.
- [Layout & Shell](../layout/index.md) for sidebars, split panes, and responsive shells.
