# Composites

Composites combine multiple components into complex UI patterns. They handle interactions, state management, and data flow so you don't have to wire everything together yourself.

## Data

| Widget | Description |
|---|---|
| `OiTable` | Full data table with sort, filter, resize, paginate, inline edit, column management |
| `OiTree` | Hierarchical tree view with expand/collapse |

### OiTable

The flagship composite. Handles everything from simple lists to 100k-row enterprise tables:

```dart
OiTable<User>(
  columns: [
    OiTableColumn(
      id: 'name',
      header: 'Name',
      cellBuilder: (user) => Text(user.name),
      sortable: true,
    ),
    OiTableColumn(
      id: 'email',
      header: 'Email',
      cellBuilder: (user) => Text(user.email),
    ),
    OiTableColumn(
      id: 'role',
      header: 'Role',
      cellBuilder: (user) => OiBadge.soft(label: user.role),
    ),
  ],
  rows: users,
  onSort: (columnId, ascending) { /* ... */ },
)
```

**Key features:**

- Virtual scrolling (100k+ rows)
- Column resizing, reordering, visibility toggle, freeze
- Inline editing with per-column type hints
- Four pagination modes: pages, load more, infinite, cursor
- Settings persistence (column widths, sort, filters auto-saved)
- Row selection (single/multi), expansion, reordering
- Status bar with aggregations
- Column groups (spanning headers)

## Forms

| Widget | Description |
|---|---|
| `OiForm` | Form container with validation |
| `OiStepper` | Step-by-step form |
| `OiWizard` | Multi-page wizard with progress |

### OiForm

```dart
OiForm(
  onSubmit: (values) async {
    await api.save(values);
  },
  children: [
    OiTextInput(label: 'Name', name: 'name'),
    OiSelect(label: 'Role', name: 'role', items: roles),
    OiButton(label: 'Submit', type: OiButtonType.submit),
  ],
)
```

## Editors

| Widget | Description |
|---|---|
| `OiRichEditor` | Rich text editor with markdown support |
| `OiSmartInput` | Smart input with mentions and autocomplete |

## Navigation

| Widget | Description |
|---|---|
| `OiSidebar` | Collapsible sidebar with sections |
| `OiNavMenu` | Navigation menu |
| `OiFilterBar` | Advanced filter bar with chips |
| `OiFileToolbar` | File actions toolbar |
| `OiArrowNav` | Previous/next navigation |
| `OiShortcuts` | Keyboard shortcut hint display |

## Search

| Widget | Description |
|---|---|
| `OiSearch` | Full-text search with results |
| `OiCommandBar` | Ctrl+K command palette |
| `OiComboBox` | Searchable dropdown |

### OiCommandBar

A power-user favorite — the Ctrl+K command palette:

```dart
OiCommandBar(
  commands: [
    OiCommand(label: 'Go to Dashboard', action: () => navigate('/dashboard')),
    OiCommand(label: 'Create New File', action: () => createFile()),
    OiCommand(label: 'Toggle Dark Mode', action: () => toggleTheme()),
  ],
)
```

## Files

| Widget | Description |
|---|---|
| `OiFileDropTarget` | Drag-and-drop file zone |
| `OiFileGridView` | Grid file browser |
| `OiFileListView` | List file browser |
| `OiFileSidebar` | File tree navigation |

## Media

| Widget | Description |
|---|---|
| `OiGallery` | Image/media grid |
| `OiLightbox` | Full-screen image viewer |
| `OiVideoPlayer` | Video player with controls |
| `OiImageCropper` | Image crop interface |
| `OiImageAnnotator` | Image markup tool |

## Visualization

| Widget | Description |
|---|---|
| `OiHeatmap` | 2D heat grid |
| `OiRadarChart` | Radar/spider chart |
| `OiFunnelChart` | Funnel/conversion chart |
| `OiGauge` | Circular gauge dial |
| `OiSankey` | Flow diagram |
| `OiTreemap` | Nested rectangles |

All visualization widgets use the `context.colors.chart` palette by default.

## Scheduling

| Widget | Description |
|---|---|
| `OiCalendar` | Day/week/month calendar view |
| `OiTimeline` | Chronological timeline |
| `OiGantt` | Gantt chart |

## Social

| Widget | Description |
|---|---|
| `OiAvatarStack` | Overlapping avatar group |
| `OiCursorPresence` | Live cursor position display |
| `OiLiveRing` | Live/active status indicator |
| `OiSelectionPresence` | User selection highlighting |
| `OiTypingIndicator` | "User is typing..." animation |

## Onboarding

| Widget | Description |
|---|---|
| `OiTour` | Multi-step guided tour |
| `OiSpotlight` | Feature highlight overlay |
| `OiWhatsNew` | Release notes dialog |

### OiTour

```dart
OiTour(
  steps: [
    OiTourStep(
      target: sidebarKey,
      title: 'Navigation',
      body: 'Use the sidebar to browse files.',
    ),
    OiTourStep(
      target: searchKey,
      title: 'Search',
      body: 'Press Ctrl+K to search anything.',
    ),
  ],
)
```

## Workflow

| Widget | Description |
|---|---|
| `OiFlowGraph` | Node-edge graph editor |
| `OiPipeline` | Linear stage pipeline |
| `OiStateDiagram` | State machine visualization |
