# Page & Section

`OiPage` and `OiSection` work together to structure your content into well-organized, responsive pages.

## OiPage

A scrollable, max-width-centered container with responsive gutters:

```dart
OiPage(
  children: [
    OiSection(title: 'Profile', child: ProfileForm()),
    OiSection(title: 'Settings', child: SettingsPanel()),
  ],
)
```

**What it does:**

- Centers content with a max width (configurable)
- Adds responsive page gutters (16dp on compact, up to 48dp on extra-large)
- Provides consistent vertical spacing between children
- Optionally scrollable

## OiSection

Groups content with an optional header, description, icon, and actions:

```dart
OiSection(
  title: 'Notifications',
  description: 'Choose how you want to be notified.',
  icon: Icons.notifications,
  actions: [
    OiButton(label: 'Reset', variant: OiButtonVariant.ghost, onPressed: () {}),
  ],
  child: NotificationSettings(),
)
```

### Aside layout

On wider screens, the header can sit to the left of the content:

```dart
OiSection(
  title: 'Billing',
  description: 'Manage your subscription and payment.',
  aside: true,  // Header left, content right on expanded+
  child: BillingForm(),
)
```

On compact screens, it stacks vertically automatically.

### Collapsible sections

```dart
OiSection(
  title: 'Advanced Options',
  collapsible: true,
  initiallyCollapsed: true,
  child: AdvancedSettings(),
)
```

Collapsed state can be persisted via the settings system.

### Section with grid

Combine sections with grids for form layouts:

```dart
OiSection(
  title: 'Contact Information',
  child: OiGrid(
    columns: OiResponsive({
      OiBreakpoint.compact: 1,
      OiBreakpoint.medium: 2,
    }),
    gap: context.spacing.md,
    children: [
      OiTextInput(label: 'First Name'),
      OiTextInput(label: 'Last Name'),
      OiSpan(columnSpan: 2, child: OiTextInput(label: 'Email')),
    ],
  ),
)
```
