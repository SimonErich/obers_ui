# Building Custom Modules

Modules are the richest tier in ObersUI — complete screens composed from composites and components. You can build your own modules following the same patterns.

## The module pattern

Every ObersUI module follows this recipe:

1. **Compose from lower tiers** — Use composites, components, and primitives
2. **Accept callbacks, not manage state** — The module renders UI; your app owns the data
3. **Support settings persistence** — Let the settings driver save layout preferences
4. **Respect the theme** — Read all visual values from `context.theme`
5. **Provide semantic labels** — All overlays and interactive regions need accessibility labels

## Example: A project board module

```dart
class OiProjectBoard extends StatefulWidget {
  const OiProjectBoard({
    required this.projects,
    required this.onProjectOpen,
    this.onProjectCreate,
    this.onProjectDelete,
    this.settingsKey,
    super.key,
  });

  final List<Project> projects;
  final ValueChanged<Project> onProjectOpen;
  final VoidCallback? onProjectCreate;
  final ValueChanged<Project>? onProjectDelete;
  final String? settingsKey;

  @override
  State<OiProjectBoard> createState() => _OiProjectBoardState();
}

class _OiProjectBoardState extends State<OiProjectBoard> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return OiColumn(
      gap: spacing.md,
      children: [
        // Toolbar using existing composites
        OiRow(
          gap: spacing.sm,
          children: [
            Expanded(child: OiSearch(onSearch: _filterProjects)),
            if (widget.onProjectCreate != null)
              OiButton(
                label: 'New Project',
                onPressed: widget.onProjectCreate,
              ),
          ],
        ),

        // Content using existing components
        Expanded(
          child: OiGrid(
            columns: OiResponsive({
              OiBreakpoint.compact: 1,
              OiBreakpoint.medium: 2,
              OiBreakpoint.large: 3,
            }),
            gap: spacing.md,
            children: _filteredProjects.map((project) {
              return OiCard(
                child: OiTappable(
                  onTap: () => widget.onProjectOpen(project),
                  child: ProjectCardContent(project: project),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
```

## Key principles

### Callbacks over controllers

Modules accept `onX` callbacks rather than managing data internally. This keeps your app in control:

```dart
// Good: parent controls the data
OiFileExplorer(
  roots: [rootNode],
  onDelete: (files) async => await myApi.delete(files),
)

// Avoid: module managing its own API calls
```

### Settings persistence

If your module has user-configurable layout, mix in `OiSettingsMixin`:

1. Create a settings class implementing `OiSettingsData`
2. Mix `OiSettingsMixin` into your state class
3. Load settings in `initState`, save on change

See the existing modules (like `OiTable` or `OiFileExplorer`) as reference implementations.

### Compose, don't reinvent

Before building something custom, check if an existing composite does what you need. ObersUI has 50+ composites covering data, forms, search, media, visualization, scheduling, social, and workflow.
