# Support & System Pages

These modules cover the screens people see around the edges of your app. They
answer questions, collect feedback, ask for consent, and stand in when something
breaks or the app is down. Each one reads its colors, spacing, and radius from
the theme, so they match the rest of your product.

| Widget | What it does |
| --- | --- |
| `OiHelpCenter` | A tabbed help page with FAQ, contact, articles, and feedback. |
| `OiResourcePage` | A CRUD scaffold for list, show, edit, and create views. |
| `OiFeedbackSheet` | A compact form that collects a rating and a message. |
| `OiConsentBanner` | A cookie and consent banner with a preferences dialog. |
| `OiErrorPage` | A full-page state for 404, 403, 500, and custom errors. |
| `OiMaintenancePage` | A full-page state for downtime, offline, and errors. |
| `OiDevMenu` | A developer overlay with env switch, flags, actions, and logs. |
| `OiSearchOverlay` | A command-palette-style global search. |

## OiHelpCenter

A self-serve support page. It bundles four sections into one tabbed layout: an
FAQ, a contact form, a knowledge base, and a feedback form. Each section is
optional. A search bar filters the FAQ and articles.

```dart
OiHelpCenter(
  label: 'Help center',
  faq: [
    OiFaqItem(
      question: 'How do I reset my password?',
      answer: 'Open **Settings**, then tap _Reset password_.',
      keywords: ['password', 'login'],
    ),
  ],
  articles: [
    OiKnowledgeArticle(
      key: 'getting-started',
      title: 'Getting started',
      content: '# Welcome\n\nThis guide walks you through setup.',
      category: 'Basics',
    ),
  ],
  onContactSubmit: ({required subject, required message, email}) async {
    await sendSupportTicket(subject, message, email);
    return true;
  },
  onFeedbackSubmit: ({required rating, comment}) async {
    await sendRating(rating, comment);
    return true;
  },
)
```

FAQ answers and article content render as Markdown. On wide screens the tabs
show as a sidebar. On narrow screens they show as a scrolling tab row.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label for the page. |
| `faq` | `List<OiFaqItem>` | `[]` | FAQ entries. Each has `question`, `answer`, `category`, `keywords`. |
| `articles` | `List<OiKnowledgeArticle>` | `[]` | Knowledge base articles. Each has `key`, `title`, `content`, `category`, `tags`, `lastUpdated`. |
| `onContactSubmit` | `Future<bool> Function({subject, message, email})?` | `null` | Handles the contact form. Return `true` on success. |
| `onFeedbackSubmit` | `Future<bool> Function({rating, comment})?` | `null` | Handles the feedback form. Return `true` on success. |
| `showFaq` | `bool` | `true` | Show the FAQ tab. |
| `showContact` | `bool` | `true` | Show the Contact tab. |
| `showKnowledgeBase` | `bool` | `true` | Show the Articles tab. |
| `showFeedback` | `bool` | `true` | Show the Feedback tab. |
| `searchEnabled` | `bool` | `true` | Show the search bar. |

## OiResourcePage

A layout scaffold for admin CRUD screens. Pick a `variant` and the page lays out
a title, the right action buttons, your content, and optional pagination. It is
pure layout. You supply the table, form, or detail view as `child`.

```dart
OiResourcePage(
  label: 'Products',
  title: 'Products',
  variant: OiResourcePageVariant.list,
  onAction: (action) {
    if (action == 'create') openCreateForm();
  },
  child: OiTable(/* ... */),
)
```

The `variant` decides the default action buttons:

- `list`: a Create button, plus optional `filters` and `pagination`.
- `show`: Edit and Delete buttons.
- `edit` and `create`: Save and Cancel buttons, content wrapped in a card.

The `onAction` callback fires with the action name: `'create'`, `'edit'`,
`'delete'`, `'save'`, or `'cancel'`. Pass your own `actions` list to replace the
defaults entirely.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | **required** | The main content area. |
| `label` | `String` | **required** | Accessibility label for the page. |
| `title` | `String?` | `null` | Optional heading shown above the content. |
| `variant` | `OiResourcePageVariant` | `list` | `list`, `show`, `edit`, or `create`. |
| `actions` | `List<Widget>?` | `null` | Custom actions. Overrides the variant defaults. |
| `filters` | `Widget?` | `null` | Filter widgets. Shown only for the `list` variant. |
| `pagination` | `Widget?` | `null` | Pagination widget. Shown only for the `list` variant. |
| `breadcrumbs` | `List<OiBreadcrumbItem>?` | `null` | Breadcrumb items shown above the title. |
| `wrapInCard` | `bool` | `true` | Wrap the content in a card or surface. |
| `onAction` | `OiResourceAction?` | `null` | Fires with the tapped action name. |

## OiFeedbackSheet

A short in-app feedback form. It collects a rating, a category, a message, and an
optional email. After a successful submit it swaps to a thank-you state. Drop it
in a dialog, a bottom sheet, or a settings page.

```dart
OiFeedbackSheet(
  label: 'Send feedback',
  ratingType: OiFeedbackRatingType.sentiment,
  onSubmit: (data) async {
    await sendFeedback(
      category: data.category,
      rating: data.rating,
      message: data.message,
      email: data.email,
    );
    return true;
  },
)
```

`onSubmit` receives an `OiFeedbackData` with `category`, `rating`, `message`,
`email`, and `metadata`. Return `true` to show the thank-you state, `false` to
keep the form open (for example, after a network error).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label for the sheet. |
| `onSubmit` | `Future<bool> Function(OiFeedbackData)?` | `null` | Handles the submit. Return `true` on success. |
| `ratingType` | `OiFeedbackRatingType` | `sentiment` | `sentiment` emoji picker or `stars`. |
| `categories` | `List<OiFeedbackCategory>` | all four | Which categories to offer: `bug`, `featureRequest`, `general`, `other`. |
| `showEmail` | `bool` | `true` | Show the optional email field. |
| `metadata` | `Map<String, String>` | `{}` | Extra data attached to every submission. |
| `thankYouTitle` | `String` | `'Thank you!'` | Heading shown after submit. |
| `thankYouDescription` | `String` | `'Your feedback helps us improve.'` | Text shown after submit. |

!!! note
    The user must pick a category before the Submit button enables. The rating is
    optional.

## OiConsentBanner

A cookie and consent banner. It slides in from the top or bottom with accept-all,
reject-all, and manage-preferences actions. The manage action opens a dialog that
lists each category with a switch. Categories marked `required` stay on and lock.

```dart
OiConsentBanner(
  label: 'Cookie consent',
  description: 'We use cookies to improve your experience.',
  categories: [
    OiConsentCategory(
      key: 'essential',
      name: 'Essential',
      description: 'Required for the site to work.',
      required: true,
    ),
    OiConsentCategory(
      key: 'analytics',
      name: 'Analytics',
      description: 'Helps us understand usage.',
    ),
  ],
  onAcceptAll: () => saveConsent(all: true),
  onRejectAll: () => saveConsent(all: false),
  onSavePreferences: (prefs) => saveConsent(prefs),
)
```

For a two-button banner with no manage action, use `OiConsentBanner.minimal`. It
drops the manage button and the `onSavePreferences` callback.

```dart
OiConsentBanner.minimal(
  label: 'Cookie consent',
  categories: categories,
  onAcceptAll: acceptAll,
  onRejectAll: rejectAll,
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `categories` | `List<OiConsentCategory>` | **required** | Consent categories. Each has `key`, `name`, `description`, `required`, `defaultValue`. |
| `label` | `String` | **required** | Accessibility label for the banner. |
| `title` | `String` | `'We use cookies'` | Banner heading. |
| `description` | `String?` | `null` | Text shown below the title. |
| `onAcceptAll` | `VoidCallback?` | `null` | Fires when the user accepts everything. |
| `onRejectAll` | `VoidCallback?` | `null` | Fires when the user rejects non-required categories. |
| `onSavePreferences` | `void Function(Map<String, bool>)?` | `null` | Fires with per-category consent from the dialog. |
| `onPrivacyPolicyTap` | `VoidCallback?` | `null` | Fires when the privacy link is tapped. When `null` no link shows. |
| `visible` | `bool` | `true` | Set `false` to hide with an exit animation. |
| `position` | `OiConsentPosition` | `bottom` | `top` or `bottom`. |
| `maxWidth` | `double` | `960` | Maximum width of the banner content. |

## OiErrorPage

A full-page error state. It shows an icon or illustration, a large error code, a
title, an optional description, and an optional action button. Use it for 404,
403, and 500 pages, or build a custom one.

```dart
OiErrorPage.notFound(
  onAction: () => goHome(),
  actionLabel: 'Back to home',
)
```

Three factory constructors fill in the common codes. Each accepts overrides for
`title`, `description`, `actionLabel`, and `onAction`.

```dart
OiErrorPage.notFound(onAction: goHome, actionLabel: 'Go home')     // 404
OiErrorPage.forbidden(onAction: goHome, actionLabel: 'Go home')    // 403
OiErrorPage.serverError(onAction: retry, actionLabel: 'Try again') // 500
```

For a custom error, use the default constructor.

```dart
OiErrorPage(
  label: 'Payment failed',
  title: 'Payment failed',
  description: 'We could not process your card.',
  errorCode: '402',
  icon: OiIcons.circleAlert,
  actionLabel: 'Try again',
  onAction: retryPayment,
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | `String` | **required** | The heading below the error code. |
| `label` | `String` | **required** | Accessibility label for the page. |
| `description` | `String?` | `null` | Text shown below the title. |
| `errorCode` | `String?` | `null` | Large code shown at the top (for example `'404'`). |
| `illustration` | `Widget?` | `null` | Custom art above the code. Takes priority over `icon`. |
| `icon` | `IconData?` | `null` | Icon shown when there is no illustration. |
| `actionLabel` | `String?` | `null` | Button text. The button shows only when both this and `onAction` are set. |
| `onAction` | `VoidCallback?` | `null` | Fires when the button is tapped. |

## OiMaintenancePage

A full-page state for planned downtime and connectivity problems. It shows an
icon, a title, a description, an optional countdown to the estimated return, a
retry button, a status-page link, and social links.

```dart
OiMaintenancePage.maintenance(
  estimatedReturn: DateTime.now().add(const Duration(hours: 2)),
  onRetry: () => reload(),
  statusPageUrl: 'https://status.example.com',
  onStatusPageTap: () => openStatusPage(),
)
```

Four factory constructors cover the usual cases. Each accepts overrides for
`title`, `description`, and the callbacks.

```dart
OiMaintenancePage.maintenance(estimatedReturn: eta, onRetry: reload)
OiMaintenancePage.notFound(onRetry: goHome)
OiMaintenancePage.serverError(onRetry: reload)
OiMaintenancePage.offline(onRetry: reload)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | `String` | **required** | The main heading. |
| `label` | `String` | **required** | Accessibility label for the page. |
| `description` | `String?` | `null` | Text shown below the title. |
| `illustration` | `Widget?` | `null` | Custom art above the title. Takes priority over `icon`. |
| `icon` | `IconData?` | `null` | Icon shown when there is no illustration. |
| `estimatedReturn` | `DateTime?` | `null` | Target return time for the countdown. |
| `showCountdown` | `bool` | `true` | Show the countdown when `estimatedReturn` is set. |
| `statusPageUrl` | `String?` | `null` | Status page URL, stored for your handler. |
| `statusPageLabel` | `String` | `'Status Page'` | Label for the status-page button. |
| `onStatusPageTap` | `VoidCallback?` | `null` | Fires when the status button is tapped. When `null` no button shows. |
| `onRetry` | `VoidCallback?` | `null` | Fires when the retry button is tapped. When `null` no button shows. |
| `retryLabel` | `String` | `'Try Again'` | Label for the retry button. |
| `socialLinks` | `List<OiSocialLink>` | `[]` | Links shown at the bottom. Each has `label`, `onTap`, `icon`. |
| `maxWidth` | `double` | `480` | Maximum width of the content. |

## OiDevMenu

A developer overlay for internal builds. It has four tabs: an environment
switcher, feature-flag toggles, custom actions, and a searchable log viewer. Use
the default constructor for a standalone panel, or `OiDevMenu.trigger` to wrap
your app and open the menu with a triple-tap.

```dart
OiDevMenu.trigger(
  label: 'Developer menu',
  child: MyApp(),
  environments: [
    OiDevEnvironment(key: 'prod', label: 'Production', url: 'https://api.example.com'),
    OiDevEnvironment(key: 'staging', label: 'Staging', url: 'https://staging.example.com'),
  ],
  currentEnvironment: 'staging',
  onEnvironmentChange: (key) => switchEnvironment(key),
  featureFlags: [
    OiFeatureFlag(key: 'new_ui', label: 'New UI', description: 'Enable the redesign.'),
  ],
  featureFlagValues: {'new_ui': true},
  onFeatureFlagChange: (key, {required value}) => setFlag(key, value),
  actions: [
    OiDevAction(label: 'Clear cache', icon: OiIcons.trash2, onTap: clearCache),
  ],
  logs: [
    OiLogEntry(message: 'App started', level: OiLogLevel.info, timestamp: DateTime.now()),
  ],
  onCopyLogs: copyLogsToClipboard,
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label for the menu. |
| `child` | `Widget` | **required** (trigger) | Widget wrapped by `OiDevMenu.trigger`. |
| `tapCount` | `int` | `3` | Taps within 500 ms that open the menu in trigger mode. |
| `environments` | `List<OiDevEnvironment>` | `[]` | Environment options. Each has `key`, `label`, `url`. |
| `currentEnvironment` | `String?` | `null` | Key of the selected environment. |
| `onEnvironmentChange` | `ValueChanged<String>?` | `null` | Fires with the chosen environment key. |
| `featureFlags` | `List<OiFeatureFlag>` | `[]` | Flags shown as toggles. Each has `key`, `label`, `description`, `defaultValue`. |
| `featureFlagValues` | `Map<String, bool>` | `{}` | Current on/off state per flag key. |
| `onFeatureFlagChange` | `void Function(String key, {required bool value})?` | `null` | Fires when a flag is toggled. |
| `actions` | `List<OiDevAction>` | `[]` | Custom action buttons. Each has `label`, `onTap`, `icon`, `destructive`. |
| `logs` | `List<OiLogEntry>` | `[]` | Log entries. Each has `message`, `level`, `timestamp`, `source`. |
| `onCopyLogs` | `VoidCallback?` | `null` | Fires when "Copy all logs" is tapped. |

!!! warning
    This is a debug tool. Gate it behind a debug or internal-build check so it
    never ships to real users.

## OiSearchOverlay

A global search panel, in the style of a command palette. It shows a search
input, optional category chips, recent searches, and async results. Arrow keys
move the highlight, Enter selects, and Escape clears the query.

```dart
OiSearchOverlay(
  label: 'Global search',
  recentSearches: ['invoices', 'settings'],
  categories: [
    OiSearchCategory(key: 'pages', label: 'Pages', icon: OiIcons.fileText),
    OiSearchCategory(key: 'people', label: 'People', icon: OiIcons.users),
  ],
  onSearch: (query, categoryKey) async {
    final hits = await search(query, categoryKey);
    return hits
        .map((h) => OiSearchSuggestion(key: h.id, title: h.title, subtitle: h.path))
        .toList();
  },
  onSuggestionTap: (suggestion) => open(suggestion.key),
  onRecentTap: (query) => runSearch(query),
  onClearRecents: () => clearRecents(),
)
```

`onSearch` runs after a debounce and returns a list of `OiSearchSuggestion`. When
the input is empty and `recentSearches` is set, the panel shows recent terms
instead. Show the overlay yourself with a dialog or overlay host.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label for the overlay. |
| `onSearch` | `Future<List<OiSearchSuggestion>> Function(String, String?)?` | `null` | Runs the search. Receives the query and selected category key. |
| `onSuggestionTap` | `void Function(OiSearchSuggestion)?` | `null` | Fires when a result is chosen. |
| `onRecentTap` | `void Function(String)?` | `null` | Fires when a recent term is tapped. |
| `onClearRecents` | `VoidCallback?` | `null` | Fires when Clear is tapped in the recent header. |
| `categories` | `List<OiSearchCategory>` | `[]` | Filter chips. Each has `key`, `label`, `icon`. |
| `recentSearches` | `List<String>` | `[]` | Recent terms shown when the query is empty. |
| `placeholder` | `String` | `'Search...'` | Search input placeholder. |
| `debounce` | `Duration` | `300ms` | Wait before running `onSearch`. |
| `maxRecents` | `int` | `5` | Max recent terms to show. |
| `emptyStateTitle` | `String` | `'No results found'` | Title when a search returns nothing. |
| `emptyStateDescription` | `String` | `'Try a different search term.'` | Text when a search returns nothing. |
| `maxWidth` | `double` | `640` | Maximum width of the overlay. |

## Related

- [Search & Command](../widgets/search-command.md) for the search input and command bar.
- [Feedback & Status](../widgets/feedback.md) for ratings, sentiment, and progress.
- [Overlays & Menus](../widgets/overlays.md) for the dialog and overlay hosts these pages open in.
- [Navigation](../widgets/navigation.md) for breadcrumbs and page structure.
