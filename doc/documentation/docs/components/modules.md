# Modules

Modules are complete, feature-rich screens you can drop into your app. They compose composites and components into full experiences with complex interactions, keyboard shortcuts, and settings persistence built in.

Think of modules as the "just add data" layer — the cream on top.

## Overview

| Module | Description |
|---|---|
| `OiFileExplorer` | Full file browser with sidebar, toolbar, grid/list views, search, drag-drop |
| `OiFileManager` | File operations UI (move, copy, delete, upload) |
| `OiDashboard` | Draggable, resizable widget grid |
| `OiKanban` | Kanban board with drag-and-drop columns |
| `OiChat` | Messaging interface with threads, reactions, typing indicators |
| `OiComments` | Threaded discussion system |
| `OiActivityFeed` | Chronological activity stream |
| `OiListView` | Complete list screen with sort, filter, pagination |
| `OiMetadataEditor` | Key-value metadata editor |
| `OiNotificationCenter` | Notification panel |
| `OiPermissions` | Role-based permission matrix |
| `OiCheckout` | Multi-step checkout flow with address, shipping, payment, review |
| `OiShopProductDetail` | Complete product detail page with gallery, variants, cart |
| `OiAuthPage` | Authentication page with login, register, forgot-password flows |
| `OiAppShell` | Admin layout scaffold with sidebar, top bar, responsive drawer |
| `OiResourcePage` | Generic CRUD page scaffold for list/show/edit/create views |
| `OiChatWindow` | LLM-focused chat with streaming, suggestion chips, provider selector |
| `OiChangelogView` | Versioned changelog viewer with type filters and search |
| `OiConsentBanner` | GDPR cookie consent banner with category toggles |
| `OiDevMenu` | Developer debug menu with environment switching and feature flags |
| `OiDrawerNavigation` | Structured drawer with header, grouped sections, and nested items |
| `OiFeedbackSheet` | User feedback form with rating, category, and message |
| `OiHelpCenter` | Tabbed help center with FAQ, knowledge base, and contact form |
| `OiMaintenancePage` | Full-page maintenance/error screen with countdown and retry |
| `OiMediaPicker` | Media selection with gallery grid, file upload, and type filtering |
| `OiOnboardingFlow` | Multi-step onboarding with illustrations and page indicators |
| `OiPricingTable` | Pricing comparison table with billing toggle and feature matrix |
| `OiProfilePage` | User profile management with editable fields and linked accounts |
| `OiSearchOverlay` | Full-screen search overlay with categories and recent searches |
| `OiSettingsPage` | Structured settings page with toggle/select/slider item types |
| `OiSubscriptionManager` | Subscription management with usage, billing, and payment |

---

## OiFileExplorer

A complete file browser — the Swiss Army knife of file UIs.

```dart
OiFileExplorer(
  roots: [rootNode],
  onOpen: (file) => openFile(file),
  onDelete: (files) async => await api.delete(files),
  onRename: (file, name) async => await api.rename(file, name),
  onMove: (files, destination) async => await api.move(files, destination),
  onUpload: (destination) async => await pickAndUpload(destination),
)
```

**Includes:** sidebar folder tree, toolbar, path bar, search, view mode toggle (grid/list), sort, context menus, keyboard shortcuts, drag-and-drop, file previews, favorites, and settings persistence.

---

## OiDashboard

A draggable, resizable widget grid — like a home screen for data:

```dart
OiDashboard(
  cards: [
    OiDashboardCard(
      id: 'revenue',
      title: 'Revenue',
      defaultSpan: OiGridSpan(columns: 2, rows: 1),
      child: RevenueChart(),
    ),
    OiDashboardCard(
      id: 'users',
      title: 'Active Users',
      child: UserMetric(),
    ),
  ],
)
```

Card positions and sizes persist automatically.

---

## OiKanban

Kanban board with columns, cards, and drag-and-drop:

```dart
OiKanban(
  columns: [
    OiKanbanColumn(id: 'todo', title: 'To Do', cards: todoCards),
    OiKanbanColumn(id: 'progress', title: 'In Progress', cards: progressCards),
    OiKanbanColumn(id: 'done', title: 'Done', cards: doneCards),
  ],
  onCardMoved: (card, fromColumn, toColumn, index) async {
    await api.moveCard(card.id, toColumn, index);
  },
)
```

**Features:** column reordering, card drag between columns, WIP limits, collapsed columns, settings persistence.

---

## OiChat

Full messaging interface with threads and reactions:

```dart
OiChat(
  messages: messages,
  currentUser: currentUser,
  onSend: (payload) async => await api.sendMessage(payload),
  onReact: (messageId, emoji) async => await api.react(messageId, emoji),
  onThreadOpen: (messageId) => openThread(messageId),
)
```

**Features:** reverse scroll, infinite message loading, message bubbles (bubble/flat/compact), reply quotes, thread summaries, reactions, typing indicators, compose bar with attachments and mentions.

---

## OiComments

Threaded discussion — like GitHub issue comments:

```dart
OiComments(
  comments: comments,
  currentUser: currentUser,
  onPost: (payload) async => await api.postComment(payload),
  onReply: (parentId, payload) async => await api.reply(parentId, payload),
)
```

---

## OiListView

A complete list screen with sort, filter, and pagination:

```dart
OiListView<Project>(
  items: projects,
  itemBuilder: (project) => OiListTile(
    title: Text(project.name),
    subtitle: Text(project.description),
  ),
  sortOptions: [
    OiSortOption(label: 'Name', comparator: (a, b) => a.name.compareTo(b.name)),
    OiSortOption(label: 'Created', comparator: (a, b) => a.createdAt.compareTo(b.createdAt)),
  ],
)
```

---

## Settings persistence

All modules that support persistence auto-save user preferences when you provide a `settingsDriver` to `OiApp`:

| Module | What's persisted |
|---|---|
| `OiFileExplorer` | View mode, sort, sidebar state, favorites, recent paths |
| `OiKanban` | Column order, collapsed columns, WIP limits |
| `OiDashboard` | Card positions and sizes |
| `OiListView` | Layout mode, sort, filters, page size |
| `OiTable` | Column order, widths, visibility, sort, filters, page size |

No extra configuration needed — just wrap your app with a settings driver and it works. See [Settings](../settings/index.md) for details.

---

## OiCheckout

A complete multi-step checkout flow orchestrating address entry, shipping selection, payment selection, and order review as a wizard.

```dart
OiCheckout(
  items: cartItems,
  summary: cartSummary,
  label: 'Checkout',
  shippingMethods: shippingOptions,
  paymentMethods: paymentOptions,
  countries: countryOptions,
  onShippingAddressChange: (addr) => handleAddress(addr),
  onShippingMethodChange: (method) => handleShipping(method),
  onPaymentMethodChange: (method) => handlePayment(method),
  onPlaceOrder: () async => await api.placeOrder(),
  onCancel: () => navigator.pop(),
)
```

| Parameter | Type | Description |
|---|---|---|
| `items` | `List<OiCartItem>` | Cart items being checked out (required) |
| `summary` | `OiCartSummary` | Cart summary totals (required) |
| `label` | `String` | Accessibility label (required) |
| `steps` | `List<OiCheckoutStep>` | Steps in order. Defaults to address → shipping → payment → review |
| `onShippingAddressChange` | `ValueChanged<OiAddressData>?` | Called when shipping address changes |
| `onBillingAddressChange` | `ValueChanged<OiAddressData>?` | Called when billing address changes |
| `onShippingMethodChange` | `ValueChanged<OiShippingMethod>?` | Called when shipping method changes |
| `onPaymentMethodChange` | `ValueChanged<OiPaymentMethod>?` | Called when payment method changes |
| `onPlaceOrder` | `Future<OiOrderData> Function()?` | Called to place the order |
| `onCancel` | `VoidCallback?` | Called when user cancels |
| `shippingMethods` | `List<OiShippingMethod>?` | Available shipping methods |
| `paymentMethods` | `List<OiPaymentMethod>?` | Available payment methods |
| `countries` | `List<OiSelectOption<String>>?` | Country options for address selector |
| `showSummary` | `bool` | Show order summary panel. Defaults to `true` |
| `sameBillingDefault` | `bool` | Default "same as shipping" checkbox. Defaults to `true` |
| `currencyCode` | `String` | ISO 4217 currency code. Defaults to `'USD'` |

**Features:** Desktop two-column layout (wizard left, persistent order summary right), mobile single-column with collapsible summary, step validation before advancing, review step with "Edit" links back to each section, stepper progress indicator, and billing address toggle.

**OiCheckoutStep enum:** `address`, `shipping`, `payment`, `review`.

---

## OiShopProductDetail

A complete product detail page layout showing gallery, title, price, description, variant selectors, quantity, add to cart, and related products.

```dart
OiShopProductDetail(
  product: productData,
  label: 'Product detail',
  onAddToCart: (cartItem) => cart.add(cartItem),
  onVariantChange: (variant) => handleVariant(variant),
  onWishlist: () => toggleWishlist(),
  description: OiLabel.body('Product description text...'),
  reviews: reviewsWidget,
  specifications: specsWidget,
  related: relatedProducts,
)
```

| Parameter | Type | Description |
|---|---|---|
| `product` | `OiProductData` | Product to display (required) |
| `label` | `String` | Accessibility label (required) |
| `onAddToCart` | `ValueChanged<OiCartItem>?` | Called when user taps "Add to Cart" |
| `onVariantChange` | `ValueChanged<OiProductVariant>?` | Called on variant selection change |
| `onQuantityChange` | `ValueChanged<int>?` | Called on quantity change |
| `onWishlist` | `VoidCallback?` | Called on wishlist button tap |
| `selectedVariant` | `OiProductVariant?` | Currently selected variant |
| `quantity` | `int` | Current quantity. Defaults to `1` |
| `description` | `Widget?` | Description tab content |
| `reviews` | `Widget?` | Reviews tab content |
| `specifications` | `Widget?` | Specifications tab content |
| `related` | `List<OiProductData>?` | Related products carousel |

**Features:** Desktop side-by-side layout (gallery left, info right), mobile stacked layout, image gallery with thumbnail strip, star rating display, price tag with compare-at price, variant selectors grouped by attribute, quantity selector, content tabs (description/specifications/reviews), and horizontal related products carousel.

---

## OiAuthPage

A full-page authentication module with login, registration, and forgot-password flows.

```dart
// Full auth page with all modes
OiAuthPage(
  label: 'Authentication',
  onLogin: (email, password) async => await api.login(email, password),
  onRegister: (name, email, password) async => await api.register(name, email, password),
  onForgotPassword: (email) async => await api.resetPassword(email),
  logo: Image.asset('assets/logo.png'),
)

// Login-only page
OiAuthPage.login(
  label: 'Sign in',
  onLogin: (email, password) async => await api.login(email, password),
)

// Register-only page
OiAuthPage.register(
  label: 'Create account',
  onRegister: (name, email, password) async => await api.register(name, email, password),
)
```

| Parameter | Type | Description |
|---|---|---|
| `label` | `String` | Accessibility label (required) |
| `initialMode` | `OiAuthMode` | Starting mode. Defaults to `OiAuthMode.login` |
| `onModeChanged` | `ValueChanged<OiAuthMode>?` | Called when user switches modes |
| `onLogin` | `Future<bool> Function(String, String)?` | Login callback (email, password) |
| `onRegister` | `Future<bool> Function(String, String, String)?` | Register callback (name, email, password) |
| `onForgotPassword` | `Future<bool> Function(String)?` | Forgot-password callback (email) |
| `logo` | `Widget?` | Logo widget above the form |
| `footer` | `Widget?` | Footer widget below the form |

**Features:** Three forms (login, register, forgot-password) with smooth mode switching, centred card layout (max 400 dp), loading states, error display, and navigation links between modes.

**OiAuthMode enum:** `login`, `register`, `forgotPassword`.

**Factory constructors:** `OiAuthPage.login()`, `OiAuthPage.register()` for locking to a single mode.

---

## OiAppShell

A master layout scaffold for admin-style applications with sidebar navigation, top bar, and responsive mobile drawer.

```dart
OiAppShell(
  label: 'Admin',
  navigation: [
    OiNavItem(label: 'Dashboard', icon: Icons.dashboard, route: '/dashboard'),
    OiNavItem(label: 'Users', icon: Icons.people, route: '/users', section: 'Management'),
    OiNavItem(label: 'Settings', icon: Icons.settings, route: '/settings', section: 'Management'),
  ],
  currentRoute: '/dashboard',
  onNavigate: (route) => router.go(route),
  leading: Image.asset('assets/logo.png'),
  title: 'Dashboard',
  actions: [notificationButton],
  userMenu: userAvatar,
  child: DashboardContent(),
)
```

| Parameter | Type | Description |
|---|---|---|
| `child` | `Widget` | Main content area (required) |
| `label` | `String` | Accessibility label (required) |
| `navigation` | `List<OiNavItem>` | Navigation items for the sidebar (required) |
| `leading` | `Widget?` | Logo/app name in the sidebar header |
| `title` | `String?` | Page title in the top bar |
| `actions` | `List<Widget>?` | Action widgets in the top bar |
| `userMenu` | `Widget?` | User menu widget in the top bar |
| `sidebarCollapsible` | `bool` | Whether sidebar can collapse. Defaults to `true` |
| `sidebarDefaultCollapsed` | `bool` | Start collapsed. Defaults to `false` |
| `sidebarWidth` | `double` | Expanded sidebar width. Defaults to `256` |
| `sidebarCollapsedWidth` | `double` | Collapsed sidebar width. Defaults to `64` |
| `breadcrumbs` | `List<OiBreadcrumbItem>?` | Breadcrumb items for the top bar |
| `currentRoute` | `String?` | Currently active route for highlighting |
| `onNavigate` | `ValueChanged<String>?` | Called when a navigation item is selected |
| `settingsDriver` | `OiSettingsDriver?` | Driver for persisting sidebar state |

**Features:** Desktop sidebar + top bar + content layout, mobile drawer with hamburger icon, animated sidebar collapse/expand, sidebar state persistence, breadcrumbs, grouped navigation sections, nested navigation items, and active route highlighting.

**OiNavItem:** Data class with `label`, `icon`, `route`, `children`, `badge`, `dividerBefore`, `section` fields for flexible navigation trees.

---

## OiResourcePage

A generic CRUD page scaffold providing layout for list, show, edit, and create views.

```dart
// List view
OiResourcePage(
  label: 'Users',
  title: 'Users',
  variant: OiResourcePageVariant.list,
  filters: myFilterWidget,
  pagination: OiPagination(totalItems: 250, currentPage: 1, label: 'users', perPage: 25, onPageChange: (p) => setPage(p)),
  onAction: (action) {
    if (action == 'create') router.go('/users/new');
  },
  child: userTable,
)

// Detail view
OiResourcePage(
  label: 'User Detail',
  title: 'Jane Doe',
  variant: OiResourcePageVariant.show,
  breadcrumbs: [OiBreadcrumbItem(label: 'Users', route: '/users'), OiBreadcrumbItem(label: 'Jane Doe')],
  onAction: (action) {
    if (action == 'edit') router.go('/users/1/edit');
    if (action == 'delete') showDeleteDialog();
  },
  child: userDetail,
)

// Edit/Create view
OiResourcePage(
  label: 'Edit User',
  title: 'Edit User',
  variant: OiResourcePageVariant.edit,
  onAction: (action) {
    if (action == 'save') saveUser();
    if (action == 'cancel') router.back();
  },
  child: userForm,
)
```

| Parameter | Type | Description |
|---|---|---|
| `child` | `Widget` | Main content area (required) |
| `label` | `String` | Accessibility label (required) |
| `title` | `String?` | Page title heading |
| `variant` | `OiResourcePageVariant` | Page variant. Defaults to `list` |
| `actions` | `List<Widget>?` | Custom actions (overrides variant defaults) |
| `filters` | `Widget?` | Filter widget (list variant only) |
| `pagination` | `Widget?` | Pagination widget (list variant only) |
| `breadcrumbs` | `List<OiBreadcrumbItem>?` | Breadcrumb items above the title |
| `wrapInCard` | `bool` | Wrap content in OiCard. Defaults to `true` |
| `onAction` | `OiResourceAction?` | Called when a default action button is pressed |

**OiResourcePageVariant enum:** `list` (Create button + filters + pagination), `show` (Edit + Delete buttons), `edit` (Save + Cancel buttons), `create` (Save + Cancel buttons).

**Action names:** `'create'`, `'edit'`, `'delete'`, `'save'`, `'cancel'`.

---

## OiChatWindow

An LLM-focused chat interface with streaming support, suggestion chips, and provider selection. Different from `OiChat` (which is designed for social messaging with threads and reactions), `OiChatWindow` is purpose-built for AI assistant interactions.

```dart
OiChatWindow(
  label: 'AI Assistant',
  messages: [
    OiChatWindowMessage(
      id: '1', role: 'user',
      content: 'Help me design a login screen',
      timestamp: DateTime.now(),
    ),
    OiChatWindowMessage(
      id: '2', role: 'assistant',
      content: 'Here are some suggestions for your login screen...',
      timestamp: DateTime.now(),
      suggestions: [
        OiChatSuggestion(id: 's1', text: 'Add social login'),
        OiChatSuggestion(id: 's2', text: 'Add forgot password'),
      ],
    ),
  ],
  streamingContent: 'Generating response...',
  streaming: true,
  onSendMessage: (text) => sendToLlm(text),
  providerSelector: ProviderDropdown(),
)
```

**Key features:**

- Markdown rendering in message bubbles via `OiMarkdown`
- Token-by-token streaming with blinking cursor
- Suggestion chips (single/multi select)
- Auto-scroll to bottom
- Provider selector slot
- Session management

| Parameter | Type | Description |
|---|---|---|
| `messages` | `List<OiChatWindowMessage>` | Chat message history (required) |
| `label` | `String` | Accessibility label (required) |
| `onSendMessage` | `ValueChanged<String>?` | Called when user sends a message |
| `streaming` | `bool` | Whether the assistant is currently streaming a response |
| `streamingContent` | `String?` | Partial content being streamed (renders with blinking cursor) |
| `onSuggestionTap` | `ValueChanged<OiChatSuggestion>?` | Called when user taps a suggestion chip |
| `providerSelector` | `Widget?` | Optional widget slot for LLM provider selection |
| `onNewSession` | `VoidCallback?` | Called when user starts a new chat session |
| `inputPlaceholder` | `String?` | Placeholder text for the compose input |

**OiChatWindowMessage fields:** `id`, `role` (`'user'` / `'assistant'` / `'system'`), `content` (markdown string), `timestamp`, `suggestions` (list of `OiChatSuggestion`).

**Related components:** `OiChat`, `OiMarkdown`, `OiSmartInput`

---

## OiFileManager

A file operations manager providing UI for move, copy, delete, upload, and download actions. Works alongside `OiFileExplorer` or as a standalone operations panel.

```dart
OiFileManager(
  label: 'File operations',
  files: selectedFiles,
  onMove: (files, destination) async => await api.move(files, destination),
  onCopy: (files, destination) async => await api.copy(files, destination),
  onDelete: (files) async => await api.delete(files),
  onDownload: (files) => download(files),
)
```

**Features:** batch operations, progress tracking, conflict resolution dialogs, undo support.

---

## OiActivityFeed

A chronological activity stream showing user actions, system events, and notifications.

```dart
OiActivityFeed(
  label: 'Activity',
  activities: activities,
  onLoadMore: () async => await fetchMore(),
  activityBuilder: (activity) => OiListTile(
    title: OiLabel.body(activity.message),
    leading: OiAvatar(initials: activity.user.initials),
  ),
)
```

**Features:** infinite scroll, grouped by date, activity type icons, user avatars, and relative timestamps.

---

## OiMetadataEditor

A key-value metadata editor for adding, editing, and removing custom fields on any entity.

```dart
OiMetadataEditor(
  label: 'Metadata',
  entries: metadata,
  onAdd: (key, value) async => await api.addMeta(key, value),
  onEdit: (key, value) async => await api.updateMeta(key, value),
  onRemove: (key) async => await api.removeMeta(key),
)
```

**Features:** inline editing, type-aware value inputs, validation, and add/remove rows.

---

## OiNotificationCenter

A notification panel for displaying and managing user notifications.

```dart
OiNotificationCenter(
  label: 'Notifications',
  notifications: notifications,
  onMarkRead: (id) async => await api.markRead(id),
  onMarkAllRead: () async => await api.markAllRead(),
  onDismiss: (id) async => await api.dismiss(id),
)
```

**Features:** unread badge count, mark all read, dismiss individual items, grouped by date, empty state.

---

## OiPermissions

A role-based permission matrix for managing access control.

```dart
OiPermissions(
  label: 'Permissions',
  roles: roles,
  resources: resources,
  matrix: permissionMatrix,
  onChange: (role, resource, permission) async {
    await api.setPermission(role, resource, permission);
  },
)
```

**Features:** grid-based role-resource matrix, toggle/tri-state permissions, role management, and visual permission inheritance.

---

## OiChangelogView

A versioned changelog viewer with expandable releases, change-type badges, filtering, and search.

```dart
OiChangelogView(
  label: 'Release notes',
  versions: [
    OiVersionEntry(
      version: '2.1.0',
      date: DateTime(2026, 3, 28),
      isLatest: true,
      changes: [
        OiChangeEntry(description: 'Added dark mode', type: OiChangeType.added),
        OiChangeEntry(description: 'Fixed timezone bug', type: OiChangeType.fixed),
      ],
    ),
  ],
)
```

| Parameter | Type | Description |
|---|---|---|
| `versions` | `List<OiVersionEntry>` | Release versions to display (required) |
| `label` | `String` | Accessibility label (required) |
| `onVersionTap` | `ValueChanged<OiVersionEntry>?` | Called when a version header is tapped |
| `initiallyExpandedCount` | `int` | Number of versions expanded initially. Defaults to `3` |
| `showSearch` | `bool` | Show search bar. Defaults to `true` |
| `showTypeFilters` | `bool` | Show change-type filter chips. Defaults to `true` |
| `maxWidth` | `double` | Maximum content width. Defaults to `720` |

**OiChangeType enum:** `added`, `changed`, `fixed`, `removed`, `security`, `deprecated`.

---

## OiConsentBanner

A GDPR-style cookie consent banner with accept/reject all, manage preferences, and per-category toggles.

```dart
OiConsentBanner(
  label: 'Cookie consent',
  categories: [
    OiConsentCategory(key: 'essential', name: 'Essential', required: true),
    OiConsentCategory(key: 'analytics', name: 'Analytics', description: 'Usage data'),
    OiConsentCategory(key: 'marketing', name: 'Marketing'),
  ],
  onAcceptAll: () => saveAll(true),
  onRejectAll: () => saveAll(false),
  onSavePreferences: (prefs) => savePreferences(prefs),
)

// Minimal variant
OiConsentBanner.minimal(
  label: 'Cookies',
  onAcceptAll: () => accept(),
)
```

| Parameter | Type | Description |
|---|---|---|
| `categories` | `List<OiConsentCategory>` | Consent categories (required) |
| `label` | `String` | Accessibility label (required) |
| `title` | `String` | Banner title. Defaults to `'We use cookies'` |
| `onAcceptAll` | `VoidCallback?` | Called when user accepts all |
| `onRejectAll` | `VoidCallback?` | Called when user rejects all |
| `onSavePreferences` | `ValueChanged<Map<String, bool>>?` | Called when user saves custom preferences |
| `position` | `OiConsentPosition` | Top or bottom. Defaults to `bottom` |
| `visible` | `bool` | Show/hide the banner. Defaults to `true` |

**Factory constructors:** `OiConsentBanner.minimal()` for a simple accept/reject banner without category management.

---

## OiDevMenu

A developer/debug menu with environment switching, feature flags, quick actions, and log viewer.

```dart
OiDevMenu(
  label: 'Dev menu',
  environments: [
    OiDevEnvironment(key: 'dev', label: 'Development', url: 'http://localhost:3000'),
    OiDevEnvironment(key: 'prod', label: 'Production', url: 'https://example.com'),
  ],
  currentEnvironment: 'dev',
  onEnvironmentChange: (key) => switchEnv(key),
  featureFlags: [
    OiFeatureFlag(key: 'dark_mode', label: 'Dark Mode'),
    OiFeatureFlag(key: 'new_ui', label: 'New UI', description: 'Redesigned dashboard'),
  ],
  featureFlagValues: {'dark_mode': true, 'new_ui': false},
  onFeatureFlagChange: (key, {required value}) => setFlag(key, value),
  actions: [
    OiDevAction(label: 'Clear cache', icon: OiIcons.trash, onTap: () => clearCache()),
  ],
)

// Hidden trigger variant (triple-tap to open)
OiDevMenu.trigger(
  label: 'Dev',
  child: MyApp(),
  tapCount: 3,
  // ... same params as above
)
```

| Parameter | Type | Description |
|---|---|---|
| `label` | `String` | Accessibility label (required) |
| `environments` | `List<OiDevEnvironment>` | Available environments |
| `currentEnvironment` | `String?` | Currently active environment key |
| `onEnvironmentChange` | `ValueChanged<String>?` | Called on environment switch |
| `featureFlags` | `List<OiFeatureFlag>` | Feature flag definitions |
| `featureFlagValues` | `Map<String, bool>` | Current flag states |
| `onFeatureFlagChange` | `Function(String, {required bool value})?` | Called on flag toggle |
| `actions` | `List<OiDevAction>` | Quick action buttons |
| `logs` | `List<OiLogEntry>` | Log entries for the log viewer |

**OiLogLevel enum:** `debug`, `info`, `warning`, `error`.

---

## OiDrawerNavigation

A structured mobile-first drawer with user header, grouped navigation sections, nested items, badges, and toggles.

```dart
OiDrawerNavigation(
  label: 'Navigation',
  header: OiDrawerHeader(
    name: 'Jane Doe',
    subtitle: 'jane@example.com',
  ),
  selectedKey: 'home',
  onItemTap: (item) => navigate(item.key),
  sections: [
    OiDrawerSection(
      items: [
        OiDrawerItem(key: 'home', label: 'Home', icon: OiIcons.house),
        OiDrawerItem(key: 'projects', label: 'Projects', icon: OiIcons.folder, badge: '3'),
      ],
    ),
    OiDrawerSection(
      title: 'Settings',
      items: [
        OiDrawerItem(key: 'account', label: 'Account', icon: OiIcons.user),
      ],
    ),
  ],
)
```

| Parameter | Type | Description |
|---|---|---|
| `sections` | `List<OiDrawerSection>` | Navigation sections (required) |
| `label` | `String` | Accessibility label (required) |
| `header` | `OiDrawerHeader?` | User header with avatar, name, subtitle |
| `footer` | `Widget?` | Footer widget at the bottom |
| `selectedKey` | `Object?` | Currently selected item key |
| `onItemTap` | `ValueChanged<OiDrawerItem>?` | Called when item is tapped |
| `width` | `double` | Drawer width. Defaults to `300` |
| `showDividers` | `bool` | Show section dividers. Defaults to `true` |

**Features:** avatar display, nested child items with expand/collapse, badge counts, section-level toggles, and disabled items.

---

## OiFeedbackSheet

A user-feedback form with category selection, rating (stars or sentiment), free-text message, and optional email field.

```dart
OiFeedbackSheet(
  label: 'Send feedback',
  onSubmit: (data) async {
    await api.submitFeedback(data);
    return true;
  },
  ratingType: OiFeedbackRatingType.stars,
  showEmail: true,
)
```

| Parameter | Type | Description |
|---|---|---|
| `label` | `String` | Accessibility label (required) |
| `onSubmit` | `Future<bool> Function(OiFeedbackData)?` | Submit callback, returns `true` on success |
| `ratingType` | `OiFeedbackRatingType` | Stars or sentiment. Defaults to `sentiment` |
| `categories` | `List<OiFeedbackCategory>` | Feedback categories |
| `showEmail` | `bool` | Show email input. Defaults to `true` |
| `metadata` | `Map<String, String>` | Extra metadata sent with submission |

**OiFeedbackCategory enum:** `bug`, `featureRequest`, `general`, `other`.

**Features:** multi-step flow (category → rating → message → thank you), animated transitions, thank-you confirmation screen.

---

## OiHelpCenter

A tabbed help center with FAQ, knowledge base articles, contact form, and feedback collection. Searchable across all sections.

```dart
OiHelpCenter(
  label: 'Help',
  faq: [
    OiFaqItem(question: 'How do I reset my password?', answer: 'Go to Settings > Account.'),
    OiFaqItem(question: 'How do I export data?', answer: 'Settings > Data > Export.'),
  ],
  articles: [
    OiKnowledgeArticle(key: 'getting-started', title: 'Getting Started', content: '...'),
  ],
  onContactSubmit: ({required subject, required message, email}) async => true,
)
```

| Parameter | Type | Description |
|---|---|---|
| `label` | `String` | Accessibility label (required) |
| `faq` | `List<OiFaqItem>` | FAQ items with question/answer |
| `articles` | `List<OiKnowledgeArticle>` | Knowledge base articles |
| `onContactSubmit` | `Future<bool> Function({...})?` | Contact form callback |
| `onFeedbackSubmit` | `Future<bool> Function({...})?` | Feedback callback |
| `showFaq` | `bool` | Show FAQ tab. Defaults to `true` |
| `showContact` | `bool` | Show contact tab. Defaults to `true` |
| `showKnowledgeBase` | `bool` | Show articles tab. Defaults to `true` |
| `searchEnabled` | `bool` | Enable cross-section search. Defaults to `true` |

**Features:** tab navigation, expandable FAQ accordion, article search, contact form with email/subject/message, and feedback rating.

---

## OiMaintenancePage

A full-page maintenance/error screen with factory constructors for common scenarios.

```dart
// Scheduled maintenance with countdown
OiMaintenancePage.maintenance(
  estimatedReturn: DateTime.now().add(Duration(hours: 2)),
)

// 404 page
OiMaintenancePage.notFound(onRetry: () => router.go('/'))

// Server error
OiMaintenancePage.serverError(onRetry: () => reload())

// Offline
OiMaintenancePage.offline(onRetry: () => checkConnection())

// Custom
OiMaintenancePage(
  title: 'Coming Soon',
  label: 'Coming soon page',
  description: 'We are working on something amazing.',
  icon: OiIcons.rocket,
)
```

| Parameter | Type | Description |
|---|---|---|
| `title` | `String` | Page title (required) |
| `label` | `String` | Accessibility label (required) |
| `description` | `String?` | Description text below title |
| `icon` | `IconData?` | Large icon above title |
| `illustration` | `Widget?` | Custom illustration widget |
| `estimatedReturn` | `DateTime?` | Countdown target time |
| `showCountdown` | `bool` | Show countdown timer. Defaults to `true` |
| `onRetry` | `VoidCallback?` | Retry/go-back button callback |
| `socialLinks` | `List<OiSocialLink>` | Social media links |
| `maxWidth` | `double` | Maximum content width. Defaults to `480` |

**Factory constructors:** `.maintenance()`, `.notFound()`, `.serverError()`, `.offline()`.

---

## OiMediaPicker

A media selection module with gallery grid, file upload, type filtering, multi-select, and upload progress tracking.

```dart
OiMediaPicker(
  label: 'Select media',
  galleryItems: existingMedia,
  onSelect: (items) => handleSelection(items),
  onRemove: (item) => handleRemove(item),
  allowedTypes: OiMediaType.image,
  maxItems: 5,
)
```

| Parameter | Type | Description |
|---|---|---|
| `label` | `String` | Accessibility label (required) |
| `sources` | `List<OiMediaSource>` | Available sources. Defaults to `[gallery, files]` |
| `allowedTypes` | `OiMediaType` | Allowed media types. Defaults to `any` |
| `maxItems` | `int` | Max selectable items. Defaults to `10` |
| `selected` | `List<OiMediaItem>` | Currently selected items |
| `onSelect` | `ValueChanged<List<OiMediaItem>>?` | Selection callback |
| `galleryItems` | `List<OiMediaItem>` | Gallery items to display |
| `uploadProgress` | `List<OiMediaUploadProgress>` | Upload progress indicators |

**OiMediaType enum:** `image`, `video`, `document`, `any`.

---

## OiOnboardingFlow

A multi-step onboarding experience with page indicator, skip/next buttons, and completion callback.

```dart
OiOnboardingFlow(
  label: 'Getting started',
  onComplete: () => markOnboardingDone(),
  pages: [
    OiOnboardingPage(
      title: 'Welcome',
      description: 'Discover everything our platform has to offer.',
      illustration: Image.asset('assets/welcome.svg'),
    ),
    OiOnboardingPage(
      title: 'Collaborate',
      description: 'Work together with your team in real-time.',
    ),
    OiOnboardingPage(
      title: 'Get Started',
      description: "You're all set!",
      actionLabel: 'Create First Project',
      onAction: () => router.go('/new'),
    ),
  ],
)
```

| Parameter | Type | Description |
|---|---|---|
| `pages` | `List<OiOnboardingPage>` | Onboarding pages (required) |
| `label` | `String` | Accessibility label (required) |
| `onComplete` | `VoidCallback?` | Called when user finishes all pages |
| `onSkip` | `VoidCallback?` | Called when user skips |
| `showSkip` | `bool` | Show skip button. Defaults to `true` |
| `showPageIndicator` | `bool` | Show dot indicator. Defaults to `true` |
| `skipLabel` | `String` | Skip button text. Defaults to `'Skip'` |
| `nextLabel` | `String` | Next button text. Defaults to `'Next'` |
| `doneLabel` | `String` | Done button text. Defaults to `'Get Started'` |
| `maxWidth` | `double` | Maximum content width. Defaults to `600` |

**Features:** swipe navigation, animated page transitions, per-page action buttons, and configurable button labels.

---

## OiPricingTable

A responsive pricing comparison table with monthly/yearly billing toggle, feature matrix, and recommended plan highlighting.

```dart
OiPricingTable(
  label: 'Choose a plan',
  plans: [
    OiPricingPlan(key: 'free', name: 'Free', monthlyPrice: 0, ctaLabel: 'Get Started'),
    OiPricingPlan(key: 'pro', name: 'Pro', monthlyPrice: 29, yearlyPrice: 290, recommended: true),
    OiPricingPlan(key: 'enterprise', name: 'Enterprise', monthlyPrice: 99, contactSales: true),
  ],
  onPlanSelect: (plan, cycle) => handlePlanSelect(plan, cycle),
)
```

| Parameter | Type | Description |
|---|---|---|
| `plans` | `List<OiPricingPlan>` | Pricing plans (required) |
| `label` | `String` | Accessibility label (required) |
| `features` | `List<OiPricingFeature>` | Feature comparison rows |
| `onPlanSelect` | `Function(OiPricingPlan, OiBillingCycle)?` | Called when user selects a plan |
| `billingCycle` | `OiBillingCycle` | Current billing cycle. Defaults to `monthly` |
| `showBillingToggle` | `bool` | Show monthly/yearly toggle. Defaults to `true` |
| `yearlyDiscount` | `String?` | Discount badge text (e.g. "Save 20%") |
| `currencySymbol` | `String` | Currency symbol. Defaults to `'$'` |
| `showFeatureMatrix` | `bool` | Show feature comparison. Defaults to `true` |

**OiBillingCycle enum:** `monthly`, `yearly`.

---

## OiProfilePage

A user profile management page with avatar upload, inline-editable fields, password change, linked accounts, and danger zone.

```dart
OiProfilePage(
  label: 'My profile',
  profile: OiProfileData(name: 'Jane Doe', email: 'jane@example.com', role: 'Admin'),
  onFieldSave: (field, value) async => await api.updateProfile(field, value),
  onPasswordChange: (current, newPassword) async => await api.changePassword(current, newPassword),
  onAvatarChange: () async => await pickAndUploadAvatar(),
  linkedAccounts: [
    OiLinkedAccount(provider: 'google', label: 'Google', connected: true, username: 'jane@gmail.com'),
    OiLinkedAccount(provider: 'github', label: 'GitHub', connected: false),
  ],
  onDeleteAccount: () async => await confirmAndDelete(),
)
```

| Parameter | Type | Description |
|---|---|---|
| `profile` | `OiProfileData` | User profile data (required) |
| `label` | `String` | Accessibility label (required) |
| `onAvatarChange` | `VoidCallback?` | Called to change avatar |
| `onFieldSave` | `Future<bool> Function(String, String)?` | Called to save a profile field |
| `onPasswordChange` | `Future<bool> Function(String, String)?` | Called to change password |
| `linkedAccounts` | `List<OiLinkedAccount>?` | Linked social/OAuth accounts |
| `onAccountLink` | `ValueChanged<String>?` | Called to link an account |
| `onAccountUnlink` | `ValueChanged<String>?` | Called to unlink an account |
| `onDeleteAccount` | `VoidCallback?` | Called to delete the account |
| `showDangerZone` | `bool` | Show delete account section. Defaults to `true` |

**Features:** avatar with upload overlay, inline-editable text fields, password change form with confirmation, linked accounts with connect/disconnect, and destructive "delete account" zone.

---

## OiSearchOverlay

A full-screen search overlay with recent searches, category filtering, debounced results, and keyboard navigation.

```dart
OiSearchOverlay(
  label: 'Search',
  categories: [
    OiSearchCategory(key: 'all', label: 'All'),
    OiSearchCategory(key: 'docs', label: 'Docs'),
    OiSearchCategory(key: 'users', label: 'Users'),
  ],
  recentSearches: ['dashboard', 'API keys'],
  onSearch: (query, category) async {
    return await api.search(query, category: category);
  },
  onSuggestionTap: (suggestion) => navigate(suggestion.key),
)
```

| Parameter | Type | Description |
|---|---|---|
| `label` | `String` | Accessibility label (required) |
| `onSearch` | `Future<List<OiSearchSuggestion>> Function(String, String?)?` | Search callback |
| `onSuggestionTap` | `ValueChanged<OiSearchSuggestion>?` | Called when result is selected |
| `categories` | `List<OiSearchCategory>` | Search category tabs |
| `recentSearches` | `List<String>` | Recent search terms |
| `onClearRecents` | `VoidCallback?` | Called to clear recent searches |
| `placeholder` | `String` | Input placeholder. Defaults to `'Search...'` |
| `debounce` | `Duration` | Search debounce. Defaults to `300ms` |
| `maxWidth` | `double` | Maximum overlay width. Defaults to `640` |

**Features:** keyboard navigation (arrow keys + enter), search debouncing, category filtering, recent searches with clear, empty state, and auto-focus on open.

---

## OiSettingsPage

A structured settings page with grouped sections, multiple item types, search, and reset functionality.

```dart
OiSettingsPage(
  label: 'Settings',
  onSettingChanged: (groupKey, itemKey, value) => saveSetting(groupKey, itemKey, value),
  groups: [
    OiSettingsGroup(
      key: 'appearance',
      title: 'Appearance',
      icon: OiIcons.palette,
      items: [
        OiSettingsItem(key: 'dark_mode', title: 'Dark Mode', type: OiSettingsItemType.toggle, value: false),
        OiSettingsItem(key: 'font_size', title: 'Font Size', type: OiSettingsItemType.slider, value: 14.0, min: 10, max: 24),
        OiSettingsItem(key: 'language', title: 'Language', type: OiSettingsItemType.select, value: 'en', options: ['English', 'German', 'French']),
      ],
    ),
  ],
)
```

| Parameter | Type | Description |
|---|---|---|
| `groups` | `List<OiSettingsGroup>` | Settings groups (required) |
| `label` | `String` | Accessibility label (required) |
| `onSettingChanged` | `Function(String, String, dynamic)?` | Called when any setting changes (groupKey, itemKey, value) |
| `onNavigate` | `ValueChanged<String>?` | Called for navigation-type items |
| `onResetGroup` | `ValueChanged<String>?` | Called to reset a group |
| `onResetAll` | `VoidCallback?` | Called to reset all settings |
| `searchEnabled` | `bool` | Enable search. Defaults to `true` |
| `showResetButtons` | `bool` | Show reset buttons. Defaults to `true` |

**OiSettingsItemType enum:** `toggle`, `navigation`, `select`, `slider`, `custom`.

---

## OiSubscriptionManager

A subscription management module showing current plan details, usage quotas, billing history, payment method, and plan change actions.

```dart
OiSubscriptionManager(
  label: 'Subscription',
  currentPlan: OiSubscriptionPlan(
    key: 'pro',
    name: 'Pro',
    price: 29,
    billingCycle: OiBillingCycle.monthly,
    status: OiSubscriptionStatus.active,
    renewalDate: DateTime(2026, 4, 28),
  ),
  usage: [
    OiUsageQuota(label: 'Storage', used: 32, limit: 50, unit: 'GB'),
    OiUsageQuota(label: 'API Calls', used: 8500, limit: 10000),
  ],
  invoices: [
    OiInvoice(key: 'inv-1', date: DateTime(2026, 3, 1), description: 'Pro - March', amount: 29),
  ],
  paymentMethod: OiPaymentMethodInfo(label: 'Visa ending in 4242', last4: '4242', brand: 'visa'),
  onUpgrade: () => showUpgradeDialog(),
  onCancel: () async => await confirmCancel(),
)
```

| Parameter | Type | Description |
|---|---|---|
| `currentPlan` | `OiSubscriptionPlan` | Current subscription plan (required) |
| `label` | `String` | Accessibility label (required) |
| `usage` | `List<OiUsageQuota>` | Usage quota meters |
| `invoices` | `List<OiInvoice>` | Billing history |
| `paymentMethod` | `OiPaymentMethodInfo?` | Current payment method |
| `onUpgrade` | `VoidCallback?` | Called to upgrade plan |
| `onDowngrade` | `VoidCallback?` | Called to downgrade plan |
| `onCancel` | `Future<bool> Function()?` | Called to cancel subscription |
| `onUpdatePayment` | `VoidCallback?` | Called to update payment method |
| `onInvoiceDownload` | `ValueChanged<OiInvoice>?` | Called to download an invoice |
| `currencySymbol` | `String` | Currency symbol. Defaults to `'$'` |

**OiSubscriptionStatus enum:** `active`, `trialing`, `pastDue`, `canceled`, `expired`.

**Features:** plan summary card with status badge, usage quota progress bars, billing history table, payment method display with update, and plan change actions.
