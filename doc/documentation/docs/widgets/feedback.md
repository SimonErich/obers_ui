# Feedback & Status

These widgets tell people what is happening. They show progress, fill space
while data loads, pull to refresh, and collect quick reactions or ratings. Every
one reads its colors and spacing from the theme, so they match the rest of your
app without extra styling.

| Widget | What it does |
| --- | --- |
| `OiBanner` | An inline message bar with severity levels. Stays in the page flow. |
| `OiProgress` | A progress indicator: linear, circular, steps, or bulk. |
| `OiPipelineProgress` | A vertical multi-step progress list for long operations. |
| `OiSkeletonGroup` | A container that shimmers its placeholder children together. |
| `OiSkeletonPreset` | Ready-made skeleton shapes: text, avatar, card, list tile, and more. |
| `OiRefreshIndicator` | Pull-to-refresh for any scrollable. |
| `OiScrollToTop` | A floating button that appears after you scroll down. |
| `OiStarRating` | A five-star rating input or display, with half-star support. |
| `OiScaleRating` | A numeric scale rating (1 to 10) for NPS and satisfaction. |
| `OiSentiment` | A row of emoji faces for mood feedback. |
| `OiThumbs` | A thumbs-up / thumbs-down vote. |
| `OiReactionBar` | Emoji reaction chips with counts, plus an add button. |

## OiBanner

An inline notification bar. Use it for a message that should stay visible in the
page until the user or the system clears it. It has no default constructor. You
pick a severity with a named constructor.

```dart
OiBanner.info(message: 'Your trial expires in 3 days')
```

### Variants

Six named constructors set the severity styling. Each one tints the background,
picks a default icon, and colors the left accent border.

```dart
OiBanner.info(message: 'A new version is available')
OiBanner.success(message: 'Changes saved')
OiBanner.warning(message: 'Storage is almost full')
OiBanner.error(message: 'Payment failed', dismissible: false)
OiBanner.neutral(message: 'You are viewing an archived record')

// Loading is non-dismissible and shows an indeterminate bar at the top.
// Pass onDismiss as an async callback to auto-fade when the work finishes.
OiBanner.loading(
  message: 'Analyzing connections...',
  onDismiss: () async => runAnalysis(),
)
```

### Title, actions, and compact mode

Add a bold `title`, up to two action buttons, and turn on `compact` for a
tighter bar with no icon.

```dart
OiBanner.warning(
  title: 'Heads up',
  message: 'Maintenance is scheduled for tonight.',
  action: OiButton.ghost(label: 'Learn more', onTap: () {}),
  secondaryAction: OiButton.ghost(label: 'Dismiss', onTap: () {}),
)
```

### Attributes

Shared by the severity constructors (`info`, `success`, `warning`, `error`,
`neutral`):

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `message` | `String` | **required** | The main message text. |
| `title` | `String?` | `null` | Optional bold title above the message. |
| `icon` | `IconData?` | `null` | Overrides the default level icon. |
| `action` | `Widget?` | `null` | Primary action, usually an `OiButton.ghost`. |
| `secondaryAction` | `Widget?` | `null` | Secondary action button. |
| `onDismiss` | `VoidCallback?` | `null` | Called on dismiss. If `null`, the banner removes itself with an animation. |
| `dismissible` | `bool` | `true` | Shows the close button. |
| `compact` | `bool` | `false` | Hides the icon and reduces padding. |
| `border` | `bool` | `true` | Shows the left accent border. |
| `visible` | `bool?` | `null` | Control visibility from outside. When `null`, the banner manages its own. |
| `semanticLabel` | `String?` | `null` | Screen-reader text. Defaults to "level: message". |
| `padding` | `EdgeInsetsGeometry?` | `null` | Overrides the default padding. |

The `loading` constructor drops the action, icon, and dismiss params. Its
`onDismiss` is a `Future<void> Function()?` that fades the banner out once the
future resolves.

**Theme:** `context.components.banner` → `OiBannerThemeData`

!!! tip "When to reach for something else"
    Use `OiBanner` for messages that persist. For a message that pops up and
    fades, use `OiToast` or `OiSnackBar`. For a decision the user must make
    before continuing, use `OiDialog`.

## OiProgress

A progress indicator with four styles. It works determinate (you set `value`
from 0.0 to 1.0) or indeterminate (it animates on its own). It has no default
constructor. Pick a style with a named constructor.

```dart
OiProgress.linear(value: 0.6)
```

### Variants

```dart
// A horizontal bar. Set indeterminate for an unknown duration.
OiProgress.linear(value: 0.4)
OiProgress.linear(indeterminate: true)

// A circular arc.
OiProgress.circular(value: 0.75)
OiProgress.circular(indeterminate: true, size: 24)

// A row of step dots. Completed dots show a checkmark.
OiProgress.steps(steps: 5, currentStep: 3)

// A bulk counter: "label (current/total)" with a percentage and cancel.
OiProgress.bulk(
  current: 5,
  total: 18,
  label: 'Generating specs',
  currentItemLabel: 'Authentication screen',
  onCancel: () => cancel(),
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `double` | `0` | Progress from 0.0 to 1.0. Ignored when `indeterminate` is on. |
| `indeterminate` | `bool` | `false` | Animate instead of showing a fixed value. `linear` and `circular` only. |
| `label` | `String?` | `null` | Text rendered below the indicator. |
| `color` | `Color?` | `null` | Fill color. Defaults to `context.colors.primary.base`. |
| `strokeWidth` | `double` | `4` | Line width for linear and circular. |
| `size` | `double?` | `null` | Diameter for circular, height for linear. |
| `steps` | `int?` | `5` | Number of dots for the `steps` style. |
| `currentStep` | `int?` | `null` | Completed step count for the `steps` style. |
| `current` | `int` | **required** | Items done, for `bulk`. |
| `total` | `int` | **required** | Total items, for `bulk`. |
| `currentItemLabel` | `String?` | `null` | Description of the item in progress, for `bulk`. |
| `showPercentage` | `bool` | `true` | Show a percentage next to the counter, for `bulk`. |
| `onCancel` | `VoidCallback?` | `null` | Shows a cancel button, for `bulk`. |

**Theme:** `context.components.progress` → `OiProgressThemeData`

## OiPipelineProgress

A vertical list of steps for a multi-step operation. Completed steps show a
checkmark, the active step shows a spinner, and future steps show a grey circle.
Use it for export pipelines, deploy sequences, and setup wizards.

```dart
OiPipelineProgress(
  label: 'Deploying service',
  currentStepIndex: 1,
  steps: [
    OiPipelineProgressStep(label: 'Build'),
    OiPipelineProgressStep(label: 'Test', detail: 'Running 48 tests'),
    OiPipelineProgressStep(label: 'Deploy'),
  ],
)
```

### Error and retry

Pass `error` to put the active step into an error state. Add `onRetry` to show a
retry button, and `onCancel` for a cancel button at the bottom.

```dart
OiPipelineProgress(
  label: 'Deploying service',
  currentStepIndex: 1,
  error: 'Tests failed: 2 of 48',
  onRetry: () => retry(),
  onCancel: () => cancel(),
  steps: [
    OiPipelineProgressStep(label: 'Build'),
    OiPipelineProgressStep(label: 'Test'),
    OiPipelineProgressStep(label: 'Deploy'),
  ],
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `steps` | `List<OiPipelineProgressStep>` | **required** | The ordered steps. |
| `currentStepIndex` | `int` | **required** | Zero-based index of the active step. |
| `label` | `String` | **required** | Accessibility label. |
| `error` | `String?` | `null` | Puts the active step in an error state with this message. |
| `onRetry` | `VoidCallback?` | `null` | Shows a retry button in the error state. |
| `onCancel` | `VoidCallback?` | `null` | Shows a cancel button at the bottom. |
| `collapseCompleted` | `bool` | `false` | Collapse finished steps into a single summary line. |

Each `OiPipelineProgressStep` takes a `label`, an optional `detail` shown when
active, an optional `subProgress` widget (such as an `OiProgress.linear`), and an
optional `estimatedDuration` string.

## OiSkeletonGroup

A container that renders shimmer placeholders while content loads. It lays out
its children in a column and drives their shimmer together. Set `active` to
`false` to freeze the animation.

```dart
OiSkeletonGroup(
  children: [
    OiSkeletonLine(),
    SizedBox(height: 8),
    OiSkeletonLine(width: 160),
    SizedBox(height: 8),
    OiSkeletonBox(height: 120),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | **required** | The placeholder elements. |
| `active` | `bool` | `true` | Set `false` to stop the shimmer. |

The building blocks are `OiSkeletonLine` (a rounded line, `width` and `height`)
and `OiSkeletonBox` (a rectangle, `width` and `height`). For common shapes,
reach for `OiSkeletonPreset` below instead of composing these by hand.

## OiSkeletonPreset

Ready-made skeleton shapes so you do not build every loading state from lines
and boxes. Each preset is a named constructor. Compose several to match your real
layout.

```dart
OiSkeletonPreset.text(lines: 3)
```

### Variants

```dart
OiSkeletonPreset.text(lines: 3, lastLineWidth: 0.6)   // paragraph lines
OiSkeletonPreset.avatar(size: OiAvatarSize.md)         // circular avatar
OiSkeletonPreset.card(height: 120)                     // rounded card
OiSkeletonPreset.image(height: 200, aspectRatio: 16 / 9) // banner or image
OiSkeletonPreset.badge(width: 60)                      // chip or badge
OiSkeletonPreset.listTile(showAvatar: true, showTrailing: true) // list row
OiSkeletonPreset.tableRow(columns: 4)                  // table row
OiSkeletonPreset.metric()                              // metric card
```

### Repeat a preset in a list

Use the static `list` helper to stack a preset several times.

```dart
OiSkeletonPreset.list(
  itemSkeleton: OiSkeletonPreset.listTile(),
  count: 6,
)
```

### Attributes

The important params vary by constructor:

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `lines` | `int` | `3` | Number of text lines, for `text`. |
| `lastLineWidth` | `double` | `0.6` | Width fraction of the last text line. |
| `lineHeight` | `double` | `14` | Height of each text line. |
| `size` | `OiAvatarSize` | `md` | Avatar size, for `avatar`. |
| `height` | `double` | `120` / `200` | Height for `card` (120) and `image` (200). |
| `aspectRatio` | `double?` | `null` | Ratio used when height and width are unset. |
| `width` | `double` | `60` | Chip width, for `badge`. |
| `showAvatar` | `bool` | `true` | Show a leading avatar, for `listTile`. |
| `showTrailing` | `bool` | `false` | Show a trailing block, for `listTile`. |
| `columns` | `int` | `4` | Column count, for `tableRow`. |

The `list` helper takes `itemSkeleton` (**required**), `count` (default `5`), and
an optional `separator`.

!!! note
    For a simple spinner, use `OiProgress` instead. Skeletons pay off when they
    match the shape of the content that will replace them.

## OiRefreshIndicator

Pull-to-refresh for any scrollable. Wrap the scrollable and give it an
`onRefresh` callback that returns a `Future`. It shows a circular spinner while
the future runs. It is the non-Material replacement for Flutter's
`RefreshIndicator`.

```dart
OiRefreshIndicator(
  onRefresh: () async => fetchLatest(),
  child: ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, i) => OiListTile(label: items[i]),
  ),
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | **required** | The scrollable content. |
| `onRefresh` | `Future<void> Function()` | **required** | Runs the refresh. The spinner shows until it completes. |
| `color` | `Color?` | `null` | Spinner color. Defaults to the theme primary. |
| `backgroundColor` | `Color?` | `null` | Indicator background. Defaults to the surface color. |
| `displacement` | `double` | `40.0` | Distance from the top where the indicator settles. |
| `edgeOffset` | `double` | `0.0` | Extra offset from the top edge. |
| `triggerDistance` | `double` | `80.0` | Overscroll distance needed to trigger a refresh. |
| `indicatorSize` | `double` | `28.0` | Spinner diameter. |
| `strokeWidth` | `double` | `3.0` | Spinner stroke width. |
| `semanticLabel` | `String?` | `null` | Announced when a refresh starts. Defaults to "Refreshing". |
| `notificationPredicate` | `ScrollNotificationPredicate` | `defaultScrollNotificationPredicate` | Which scroll notifications to handle. |

**Theme:** `context.components.refreshIndicator` → `OiRefreshIndicatorThemeData`

!!! note
    Pull-to-refresh is a touch gesture. On desktop-only apps, give people a
    refresh button instead.

## OiScrollToTop

A floating button that fades in once the user scrolls past a threshold, then
scrolls smoothly back to the top on tap. Wrap your scrollable and pass the same
`ScrollController` it uses.

```dart
final controller = ScrollController();

OiScrollToTop(
  controller: controller,
  child: ListView(
    controller: controller,
    children: const [/* ... */],
  ),
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `controller` | `ScrollController` | **required** | The controller the scrollable uses. |
| `child` | `Widget` | **required** | The scrollable content. |
| `threshold` | `double` | `200.0` | Scroll offset before the button appears. |
| `button` | `Widget?` | `null` | Custom button. Defaults to a themed circular chevron. |
| `alignment` | `Alignment` | `bottomRight` | Where the button sits over the content. |
| `padding` | `EdgeInsets` | `EdgeInsets.all(16)` | Space around the button. |
| `semanticLabel` | `String` | `'Scroll to top'` | Screen-reader text. |

## OiStarRating

A five-star rating. Use it as an input (pass `onChanged`) or a read-only display
(`readOnly: true`). Turn on `allowHalf` for half-star values. You own the
`value` and update it in `onChanged`.

```dart
double _rating = 3.5;

OiStarRating(
  label: 'Product rating',
  value: _rating,
  allowHalf: true,
  onChanged: (value) => setState(() => _rating = value),
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `double` | `0.0` | Current rating, from 0.0 to `maxStars`. |
| `onChanged` | `ValueChanged<double>?` | `null` | Fires with the new rating. `null` makes it display-only. |
| `label` | `String?` | `null` | Accessibility label. |
| `maxStars` | `int` | `5` | Number of stars. |
| `allowHalf` | `bool` | `false` | Allow half-star values like 3.5. |
| `readOnly` | `bool` | `false` | Disable taps, hover, and keyboard. |
| `size` | `double` | `20.0` | Size of each star in logical pixels. |
| `activeColor` | `Color?` | `null` | Filled-star color. Defaults to `context.colors.warning.base`. |
| `inactiveColor` | `Color?` | `null` | Empty-star color. Defaults to the theme border. |

## OiScaleRating

A numeric scale, useful for Net Promoter Score and satisfaction surveys. It
renders a connected row of numbered buttons from `min` to `max`. Add end labels
so the scale reads clearly.

```dart
int? _score;

OiScaleRating(
  label: 'How likely are you to recommend us?',
  value: _score,
  min: 0,
  max: 10,
  minLabel: 'Not likely',
  maxLabel: 'Very likely',
  onChanged: (value) => setState(() => _score = value),
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `int?` | `null` | The selected number, or `null` for no selection. |
| `onChanged` | `ValueChanged<int>?` | `null` | Fires with the tapped number. |
| `label` | `String?` | `null` | Accessibility label. |
| `min` | `int` | `1` | Lowest value on the scale. |
| `max` | `int` | `10` | Highest value on the scale. |
| `minLabel` | `String?` | `null` | Caption under the left end. |
| `maxLabel` | `String?` | `null` | Caption under the right end. |
| `enabled` | `bool` | `true` | Set `false` to disable interaction. |

!!! note
    For a simple like or dislike, use `OiThumbs`. For a star review, use
    `OiStarRating`.

## OiSentiment

A row of emoji faces for mood feedback. Tapping a face calls `onChanged` with
that emoji string. The default set runs from angry to happy. You own the `value`.

```dart
String? _mood;

OiSentiment(
  value: _mood,
  onChanged: (emoji) => setState(() => _mood = emoji),
)
```

Pass your own faces with `emojis`:

```dart
OiSentiment(
  emojis: const ['😞', '😐', '😊'],
  value: _mood,
  onChanged: (emoji) => setState(() => _mood = emoji),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `String?` | `null` | The selected emoji string, or `null`. |
| `onChanged` | `ValueChanged<String>?` | `null` | Fires with the tapped emoji. |
| `emojis` | `List<String>?` | `['😡','😕','😐','🙂','😄']` | The face options. |
| `enabled` | `bool` | `true` | Set `false` to ignore taps. |

## OiThumbs

A thumbs-up / thumbs-down vote. Tapping the selected thumb again clears it, so
the value can be up, down, or none. Turn on `showCount` to display vote counts.

```dart
OiThumbsValue _vote = OiThumbsValue.none;

OiThumbs(
  label: 'Was this helpful?',
  value: _vote,
  onChanged: (value) => setState(() => _vote = value),
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `OiThumbsValue` | `none` | Current selection: `up`, `down`, or `none`. |
| `onChanged` | `ValueChanged<OiThumbsValue>?` | `null` | Fires with the next state. |
| `label` | `String?` | `null` | Group accessibility label. |
| `enabled` | `bool` | `true` | Set `false` to ignore taps. |
| `showCount` | `bool` | `false` | Show vote counts next to each thumb. |
| `upCount` | `int` | `0` | Up votes shown when `showCount` is on. |
| `downCount` | `int` | `0` | Down votes shown when `showCount` is on. |

## OiReactionBar

A row of emoji reaction chips with counts, plus an add button that opens a small
emoji picker. Use it for social reactions on messages, comments, and posts. You
build the `reactions` list and handle `onReact`.

```dart
OiReactionBar(
  reactions: const [
    OiReactionData(emoji: '👍', count: 4, selected: true),
    OiReactionData(emoji: '🎉', count: 2),
  ],
  onReact: (emoji) => toggleReaction(emoji),
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reactions` | `List<OiReactionData>` | **required** | The reaction chips to show. |
| `onReact` | `void Function(String emoji)?` | `null` | Fires with the emoji when a chip or picker item is tapped. |
| `onAddReaction` | `VoidCallback?` | `null` | Fires when the add button is tapped. |

Each `OiReactionData` takes an `emoji` (**required**), a `count` (**required**),
and a `selected` flag (default `false`) for the current user's own reaction.

## Related

- [Buttons & Actions](buttons.md) for the action buttons a banner hosts.
- [Overlays & Menus](overlays.md) for transient toasts and dialogs.
- [Selection Controls](selection-controls.md) for switches and other input toggles.
