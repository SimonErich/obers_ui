# Onboarding & Tours

These widgets help new users get their bearings and help returning users catch
up on what changed. You get a first-run walkthrough, in-app guided tours that
point at real UI, a "what's new" panel, and a full changelog viewer.

| Widget | What it does |
| --- | --- |
| `OiSpotlight` | Dims the page and cuts a hole around one widget to draw the eye. |
| `OiTour` | A multi-step guided tour that spotlights widgets and shows tooltips. |
| `OiWhatsNew` | A compact dialog listing recent features and changes. |
| `OiOnboardingFlow` | A multi-page welcome flow with illustrations and progress dots. |
| `OiChangelogView` | A searchable, version-grouped release-notes viewer. |

## OiSpotlight

Highlights a single widget by dimming everything else around it. You give it the
`GlobalKey` of the target widget, and it paints a cutout at that widget's
position. Use it for a one-off hint. For a sequence of hints, reach for `OiTour`
instead.

```dart
final saveButtonKey = GlobalKey();

OiSpotlight(
  target: saveButtonKey,
  active: _showHint,
  onTapOutside: () => setState(() => _showHint = false),
  child: myPageContent,
)
```

Attach the same `GlobalKey` to the widget you want to spotlight, for example
`OiButton.primary(key: saveButtonKey, ...)`. When `active` is `false`, only the
child renders and there is no overlay.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `target` | `GlobalKey` | **required** | The key of the widget to spotlight. |
| `child` | `Widget` | **required** | The full page content shown underneath. |
| `active` | `bool` | `true` | Set `false` to render the child with no overlay. |
| `overlayColor` | `Color?` | `null` | Dim color. Defaults to black at 54% opacity. |
| `padding` | `double` | `8` | Space in logical pixels around the target cutout. |
| `borderRadius` | `BorderRadius?` | `null` | Rounds the cutout. `null` gives a plain rectangle. |
| `onTapOutside` | `VoidCallback?` | `null` | Called when the user taps the dimmed area. |

## OiTour

A guided tour that walks through a list of steps. Each step spotlights a target
widget and shows a tooltip with a title, a description, and Next, Previous, and
Skip controls. It manages the current step and the navigation buttons for you.

```dart
final searchKey = GlobalKey();
final filterKey = GlobalKey();

OiTour(
  steps: [
    OiTourStep(
      target: searchKey,
      title: 'Search anything',
      description: 'Type here to find records across every table.',
    ),
    OiTourStep(
      target: filterKey,
      title: 'Narrow it down',
      description: 'Add filters to focus on the rows you care about.',
    ),
  ],
  onComplete: () => markTourSeen(),
  onSkip: () => markTourSeen(),
  child: myPageContent,
)
```

The tour renders `child` underneath and layers the spotlight and tooltip on top.
Give each target widget the matching `GlobalKey`. On the last step the Next
button reads "Finish".

### OiTourStep

Each step is an `OiTourStep`. Only the target, title, and description are
required.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `target` | `GlobalKey` | **required** | The key of the widget this step highlights. |
| `title` | `String` | **required** | The tooltip heading. |
| `description` | `String` | **required** | The tooltip body text. |
| `position` | `OiFloatingAlignment` | `bottomCenter` | Where the tooltip sits relative to the target. |
| `customContent` | `Widget?` | `null` | Extra content rendered below the description. |
| `actionLabel` | `String?` | `null` | Label for an optional extra action button. |
| `onAction` | `VoidCallback?` | `null` | Called when the extra action button is tapped. |

`position` accepts any `OiFloatingAlignment` value, such as `topCenter`,
`bottomStart`, `leftCenter`, or `rightEnd`.

### OiTour attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `steps` | `List<OiTourStep>` | **required** | The ordered tour steps. |
| `child` | `Widget?` | `null` | The page content rendered beneath the tour overlay. |
| `onComplete` | `VoidCallback?` | `null` | Called when the user finishes the last step. |
| `onSkip` | `VoidCallback?` | `null` | Called when the user taps Skip. |
| `onStepChange` | `ValueChanged<int>?` | `null` | Called with the new index on each step change. |
| `showProgress` | `bool` | `true` | Shows "Step 1 of 3" in the tooltip. |
| `showSkip` | `bool` | `true` | Shows the Skip button. |
| `overlayColor` | `Color?` | `null` | Dim color passed through to the spotlight. |
| `dismissOnOutsideTap` | `bool` | `false` | When `true`, a tap outside the spotlight skips the tour. |

!!! tip
    Store a "tour seen" flag once `onComplete` or `onSkip` fires, so returning
    users do not see the tour again.

## OiWhatsNew

A compact dialog that lists recent features and changes. Show it once after an
update so users notice what is new. Each entry has a title and a description,
plus an optional icon and version badge.

```dart
OiWhatsNew(
  items: [
    OiWhatsNewItem(
      title: 'Dark mode',
      description: 'Switch themes from the top-right menu.',
      icon: OiIcons.moon,
      version: 'v2.1.0',
    ),
    OiWhatsNewItem(
      title: 'Faster search',
      description: 'Results now appear as you type.',
      icon: OiIcons.search,
    ),
  ],
  onDismiss: () => Navigator.of(context).pop(),
)
```

The widget renders a centered card. Show it inside a dialog or overlay. See
[Overlays & Menus](overlays.md) for how to present it.

### OiWhatsNewItem

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | `String` | **required** | The entry headline. |
| `description` | `String` | **required** | A short description of the change. |
| `icon` | `IconData?` | `null` | Optional icon shown beside the entry. |
| `version` | `String?` | `null` | Optional version badge next to the title. |
| `imageUrl` | `String?` | `null` | Metadata for custom builders. Not rendered by default. |

### OiWhatsNew attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `List<OiWhatsNewItem>` | **required** | The changelog entries. |
| `title` | `String` | `"What's New"` | The dialog heading. |
| `onDismiss` | `VoidCallback?` | `null` | Called when the user taps the dismiss button. |

!!! note
    `OiWhatsNew` is a short highlight reel for one update. For the full version
    history with search and filters, use `OiChangelogView`.

## OiOnboardingFlow

A multi-page welcome flow. Each page has a title, a description, and an optional
illustration. The widget handles page swiping, the Skip and Next buttons, the
Get Started button on the last page, and the progress dots.

```dart
OiOnboardingFlow(
  label: 'Welcome onboarding',
  pages: [
    OiOnboardingPage(
      title: 'Welcome to Acme',
      description: 'Manage your whole workspace in one place.',
      illustration: Icon(OiIcons.rocket, size: 96),
    ),
    OiOnboardingPage(
      title: 'Stay in sync',
      description: 'Your team sees changes the moment you make them.',
    ),
    OiOnboardingPage(
      title: 'You are set',
      description: 'Let us get started.',
    ),
  ],
  onComplete: () => Navigator.of(context).pushReplacementNamed('/home'),
  onSkip: () => Navigator.of(context).pushReplacementNamed('/home'),
)
```

### OiOnboardingPage

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | `String` | **required** | The page heading. |
| `description` | `String` | **required** | The paragraph below the title. |
| `illustration` | `Widget?` | `null` | A widget rendered above the text, such as an image or icon. |
| `actionLabel` | `String?` | `null` | Label for a per-page action button. |
| `onAction` | `VoidCallback?` | `null` | Called when the per-page action button is tapped. |

### OiOnboardingFlow attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pages` | `List<OiOnboardingPage>` | **required** | The pages to show. |
| `label` | `String` | **required** | Accessibility label for the flow. |
| `onComplete` | `VoidCallback?` | `null` | Called when the user taps done on the last page. |
| `onSkip` | `VoidCallback?` | `null` | Called when the user taps skip. |
| `onPageChange` | `ValueChanged<int>?` | `null` | Called with the new page index. |
| `skipLabel` | `String` | `'Skip'` | Text for the skip button. |
| `nextLabel` | `String` | `'Next'` | Text for the next button. |
| `doneLabel` | `String` | `'Get Started'` | Text for the last-page button. |
| `showSkip` | `bool` | `true` | Shows the skip button on non-final pages. |
| `showPageIndicator` | `bool` | `true` | Shows the progress dots. |
| `maxWidth` | `double` | `600` | Maximum width of the content. |

!!! tip
    This flow fills its space and expects to be a full screen or a large sheet.
    For a short post-update summary inside the app, use `OiWhatsNew` instead.

## OiChangelogView

A full release-notes viewer. It groups changes by version, color-codes each
change by type, and offers a search box and type filter chips. Use it on a
dedicated "What's changed" page.

```dart
OiChangelogView(
  label: 'Release notes',
  versions: [
    OiVersionEntry(
      version: '2.1.0',
      date: DateTime(2026, 6, 20),
      latest: true,
      summary: 'Theming and speed improvements.',
      changes: [
        OiChangeEntry(description: 'Added dark mode.', type: OiChangeType.added),
        OiChangeEntry(description: 'Faster search.', type: OiChangeType.changed),
        OiChangeEntry(description: 'Fixed a crash on export.', type: OiChangeType.fixed),
      ],
    ),
    OiVersionEntry(
      version: '2.0.1',
      date: DateTime(2026, 5, 2),
      changes: [
        OiChangeEntry(description: 'Patched a login redirect.', type: OiChangeType.security),
      ],
    ),
  ],
)
```

### OiChangeType

Each change carries a type. The type sets the badge label and color.

- `added`, shown in the success color.
- `changed`, shown in the info color.
- `fixed`, shown in the warning color.
- `removed`, shown in the error color.
- `security`, shown in the error color.
- `deprecated`, shown in the warning color.

### OiVersionEntry

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `version` | `String` | **required** | The version string, such as "2.1.0". |
| `changes` | `List<OiChangeEntry>` | **required** | The changes in this version. |
| `date` | `DateTime?` | `null` | The release date, shown in the header. |
| `latest` | `bool` | `false` | Marks the version with a "NEW" badge. |
| `summary` | `String?` | `null` | An optional line of summary text. |

`OiChangeEntry` takes a `description` and a `type`, both required.

### OiChangelogView attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `versions` | `List<OiVersionEntry>` | **required** | Version entries, newest first. |
| `label` | `String` | **required** | Accessibility label for the viewer. |
| `onVersionTap` | `void Function(OiVersionEntry)?` | `null` | Called when a version header is tapped. |
| `initiallyExpandedCount` | `int` | `3` | How many versions to show before "Show older". |
| `showSearch` | `bool` | `true` | Shows the search bar. |
| `showTypeFilters` | `bool` | `true` | Shows the change-type filter chips. |
| `maxWidth` | `double` | `720` | Maximum width of the content. |

## Related

- [Overlays & Menus](overlays.md) for the dialogs that host `OiWhatsNew`.
- [Feedback & Status](feedback.md) for empty states and progress indicators.
- [Buttons & Actions](buttons.md) for the buttons these flows use.
