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
  pagination: OiPagination(currentPage: 1, totalPages: 10, onPageChanged: setPage),
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
