# Concept: obers_ui Showcase Application — 2026-03-22

## Vision

Turn the `example/` project into a polished, interactive showcase that demonstrates **every usable widget** in the obers_ui library through realistic mini-applications. The showcase serves as both a living catalog and a reference implementation, helping developers discover widgets, understand usage patterns, and see how everything looks in practice.

The experience is wrapped in a fictional Austrian e-commerce company called **Alpenglueck GmbH**, adding personality and charm to the data while keeping the code clean and professional.

---

## The Company: Alpenglueck GmbH

A premium Austrian/Alpine lifestyle e-commerce company headquartered in Vienna. They sell everything from Sachertorte to hiking boots, and their internal tools are (naturally) built with obers_ui.

This framing gives us consistent, delightful mock data across all mini-apps:
- **Products** are Austrian specialties with witty descriptions
- **Employees** have food-themed surnames (Franz Knodel, Stefan Strudl, Anna Mozartkugel)
- **Chat messages** revolve around office snack disputes and alpine adventures
- **Dashboard metrics** track Schnitzel sales and customer satisfaction
- All currency is **EUR**, all addresses are Austrian, all culture references are Central European

---

## Application Structure

### Entry Point: Home Screen

A clean grid of 7 category cards, each representing a different use case:

| Card | Icon | Description | Primary Module |
| ---- | ---- | ----------- | -------------- |
| **Shop** | Cart | E-commerce product browsing, cart, checkout | OiCheckout, OiShopProductDetail |
| **Chat** | Message | Real-time messaging with channels | OiChat |
| **Admin** | Dashboard | Analytics, user management, settings | OiAppShell, OiDashboard, OiTable |
| **Projects** | Kanban | Task boards, timelines, calendars | OiKanban, OiGantt, OiCalendar |
| **Files** | Folder | File management and organization | OiFileExplorer |
| **Content** | Article | CMS with articles, editor, comments | OiListView, OiForm, OiComments |
| **Auth** | Lock | Login, registration, password reset | OiAuthPage |

Tapping a card navigates into the corresponding mini-application.

### Global Shell

Every screen is wrapped in a lightweight top bar providing:
- **Back button** to return to the home screen
- **Current section title**
- **Theme toggle** (OiThemeToggle) to switch between Alpine and Vienna Night themes

This shell is intentionally *not* an OiAppShell — that module is showcased inside the Admin and CMS mini-apps where it belongs.

---

## Themes

### Alpine (Light Theme)

Brand color: **Forest Green** (`#2E7D32`) — evoking Alpine meadows and Tyrolean landscapes.
Radius: **Rounded** — warm and approachable.
Mood: Fresh mountain morning, sunlit hiking trails, green valleys.

```dart
OiThemeData.fromBrand(
  color: Color(0xFF2E7D32),
  brightness: Brightness.light,
  radiusPreference: OiRadiusPreference.rounded,
)
```

### Vienna Night (Dark Theme)

Brand color: **Baroque Gold** (`#CFB53B`) — evoking Vienna's opera houses and coffee house chandeliers.
Radius: **Medium** — refined and elegant.
Mood: Evening at the Staatsoper, candlelit Kaffeehaus, gilded Jugendstil facades.

```dart
OiThemeData.fromBrand(
  color: Color(0xFFCFB53B),
  brightness: Brightness.dark,
  radiusPreference: OiRadiusPreference.medium,
)
```

Users can switch between themes at any time via the top bar toggle. The switch is instant and affects all screens.

---

## Mini-App Concepts

### 1. Shop — "Alpenglueck Store"

A fully navigable e-commerce experience with 5 screens.

**Browse Screen**
- Product grid (OiGrid of OiProductCard) with sidebar filters (OiProductFilters via OiSplitPane)
- Mini cart indicator in the corner (OiMiniCart)
- Command palette search (OiCommandBar) for quick product lookup
- Sort options (OiSortButton) by price, rating, name

**Product Detail Screen**
- Full product page (OiShopProductDetail) with image gallery (OiProductGallery)
- Variant selection (size, weight), quantity selector (OiQuantitySelector)
- Stock status (OiStockBadge), wishlist button (OiWishlistButton)
- Star ratings (OiStarRating), price display (OiPriceTag)
- Product description rendered as Markdown (OiMarkdown)
- "Add to Cart" shows a success toast (OiToast)

**Cart Screen**
- Full cart panel (OiCartPanel) with item list (OiCartItemRow)
- Coupon input (OiCouponInput) — valid codes: `SACHERTORTE10` (10% off), `ALPENGLUECK` (15% off), `SCHNITZEL` (5% off)
- Cart summary with Austrian 20% VAT

**Checkout Screen**
- 4-step wizard (OiCheckout): Address > Shipping > Payment > Review
- Address form (OiAddressForm) with Austrian states and country list
- Shipping methods: "Austrian Post Standard" (EUR 5.90), "Express" (EUR 12.90), "Alm-Bote Mountain Courier" (EUR 24.90)
- Payment methods: Visa, EPS bank transfer, Klarna, Nachnahme (cash on delivery)
- Desktop: two-column layout with persistent order summary; Mobile: single column

**Order Confirmation Screen**
- Order tracking timeline (OiOrderTracker)
- Order summary (OiOrderSummary) with all details

**Sample Products (10):**
1. Original Sacher-Torte — "Dense, chocolatey, and legally distinct from that other hotel's version"
2. Wiener Schnitzel Home Kit — "Includes a tiny wooden mallet for when you need to take out your feelings on the meat"
3. Alpine Hiking Boot "Gipfelstuermer" — "Conquer the Grossglockner or just look ruggedly Austrian at the office"
4. Viennese Coffee Set "Kaffeehauskultur" — "Includes a laminated card explaining the 27 types of Viennese coffee"
5. Mozartkugeln Gift Box (24 pcs) — "The perfect gift for anyone you want to impress or apologize to"
6. Dirndl "Almsommer" — "Says 'I appreciate folk traditions but also have a design degree'"
7. Lederhosen "Bergkoenig" — "Break-in period: approximately one Heuriger visit"
8. Zillertaler Graukase — "The cheese that smells like a gym locker and tastes like heaven"
9. Almdudler Party Pack — "Austria's answer to the question nobody asked: what if lemonade tasted like Alpine herbs?"
10. Manner Schnitten Tower — "The pink wafers that built a nation" (OUT OF STOCK)

---

### 2. Chat — "Alpenglueck Team Chat"

A realistic messaging interface with channels, auto-responses, and reactions.

**Layout**
- Desktop: OiSplitPane with channel list sidebar (left) and conversation (right)
- Mobile: Channel list as primary screen, tap to push into conversation

**Channels (5):**
- **#general** — Company announcements (3 unread)
- **#food-reviews** — Beisl and Heurigen reviews
- **#alpine-adventures** — Hiking plans and ski reports
- **#office-banter** — The channel HR pretends not to read (12 unread)
- **#development** — PRs, deployments, existential code reviews

**Auto-Response Engine**
When the user sends a message:
1. After 1.5 seconds, a random team member's name appears in the typing indicator
2. After another 2 seconds, their response appears as a new message
3. Responses are keyword-matched: food words trigger food responses, work words trigger work responses, otherwise general banter
4. 20% chance of a second person responding 2-5 seconds later

Example auto-responses:
- "That reminds me, has anyone tried the Kaiserschmarrn at the new place on Mariahilfer Strasse?"
- "Deploying to staging now. Everyone hold your Schnitzel."
- "LGTM, but I would rename that variable. You know which one."
- "Noted. Adding it to my growing collection of things to remember."

**Features demonstrated:**
- Channel switching with unread badges (OiBadge)
- Message grouping for consecutive messages from same sender
- Emoji reactions (long-press to react, toggle on/off)
- File attachments shown inline (e.g., "rax-trail-map.pdf")
- Typing indicator ("Franz Knodel is typing...")
- Avatars with initials

---

### 3. Admin — "Alpenglueck Dashboard"

A full admin panel using OiAppShell with sidebar navigation.

**Sidebar Navigation:**
- Section "Main": Overview, Users, Orders
- Section "System": Settings, Activity Log, Notifications

**Overview Screen (Dashboard)**
- 4 KPI metric cards (OiMetric): Revenue (EUR 127,450 +8.7%), Orders (2,847 +12.3%), Active Users (1,284 +3.2%), Satisfaction (4.7/5)
- Funnel chart (OiFunnelChart): Visitors > Product Views > Cart > Checkout > Purchase
- Heatmap (OiHeatmap): Activity by day of week and hour
- Gauge (OiGauge): Customer satisfaction score
- Radar chart (OiRadarChart): Product category performance
- All in a draggable OiDashboard grid with edit mode toggle

**Users Screen**
- Sortable, filterable data table (OiTable) with 10 employees
- Columns: Avatar, Name, Role, Department, Email, Joined Date, Orders Processed
- Row tap opens detail view in a side sheet (OiSheet)
- Multi-select with bulk action bar (OiBulkBar)
- Pagination controls (OiPagination)

**Settings Screen**
- Declarative form (OiForm) with sections:
  - "General": Store name (OiTextInput), tagline, currency (OiSelect), timezone (OiSelect)
  - "Notifications": Email (OiSwitch), push (OiSwitch), newsletter (OiCheckbox)
  - "Appearance": Brand color (OiColorInput), corner style (OiRadio), density (OiSlider)
- Save button shows success toast

**Activity Screen**
- Chronological activity feed (OiActivityFeed) with category tabs
- Events: new orders, out-of-stock alerts, 5-star reviews, returns, new registrations, coupon usage, system backups

**Notifications Screen**
- Notification center (OiNotificationCenter) with grouped notifications
- Mark as read/unread, filtering

---

### 4. Projects — "Alpenglueck Project Board"

Project management views accessed via tab navigation (OiTabs).

**Kanban Board (OiKanban)**
- 5 columns: Backlog, To Do, In Progress (WIP limit: 3), Review, Done
- Custom card builder showing: task title, assignee avatar (OiAvatar), priority badge (OiBadge), due date
- Drag-and-drop between columns
- Tasks themed around product launches, integrations, and content ("Fix Sachertorte image not loading on mobile", "Implement Kaffeepause reminder feature")

**Gantt Chart (OiGantt)**
- Project phases: "Q1 Relaunch" with sequential tasks and dependencies
- Tasks: UI/UX Redesign > Backend API v2 > Klarna Integration > QA & Testing > Launch
- Color-coded by phase, progress indicators, zoom controls

**Calendar (OiCalendar)**
- Month/week/day view switching
- Events: daily standups, Kaffeepause, sprint reviews, team Schnitzel dinner
- All-day events: holidays (Josephitag), company outings (Betriebsausflug Rax)
- Deadline markers in red

**Timeline (OiTimeline)**
- Project milestones from January to March 2026
- Milestones: Project kickoff, Design system approved, Backend API done, Beta launch, Public launch (today)
- Each with descriptions, icons, and color coding

---

### 5. Files — "Alpenglueck Drive"

Full file management using the OiFileExplorer module.

**Folder Structure:**
- **Dokumente/** — Business plans, supplier contracts, employee handbook, "Kaffeepausen-Regelwerk.md"
- **Produktbilder/** — Product photography (24 items)
- **Geheime Rezepte/** — Locked folder with secret recipes (Sachertorte Original, Schnitzel Secret Ingredient)
- **Berichte/** — Q1 sales report, customer satisfaction survey, "Schnitzel-Verbrauchsstatistik.csv"
- **Marketing/** — Shared folder with campaign assets

**Features demonstrated:**
- Folder tree sidebar with navigation
- Grid and list view toggle
- File search
- CRUD operations: create folder, rename, delete, move (all update local state)
- Context menu (right-click)
- Quick access sidebar items
- Storage indicator (2.4 GB of 10 GB)
- File type icons for PDF, DOCX, XLSX, CSV, images, markdown

---

### 6. Content — "Alpenglueck Blog CMS"

A content management system using OiAppShell with sidebar.

**Sidebar:** Articles, Categories, Media, Settings

**Article List Screen**
- Universal list view (OiListView) with search and category filter
- Each article as a card (OiCard) showing title, author avatar, date, status badge, comment count
- Layout toggle (list/grid)

**Article Detail Screen**
- Article content rendered as Markdown (OiMarkdown)
- Author info and metadata (OiDetailView, OiFieldDisplay)
- Threaded comments section (OiComments) with reactions and replies
- Example: "Wiener Kaffeehaus-Knigge" with 42 comments including nested threads about Graukase

**Article Edit Screen**
- Form (OiForm) with: title (OiTextInput), URL slug, category (OiSelect), tags (OiTagInput), publish date (OiDateTimeInput), featured checkbox (OiCheckbox), excerpt (multiline OiTextInput)
- Rich text editor (OiRichEditor) for article body
- File input (OiFileInput) for featured image

**Sample Articles:**
1. "Die Kunst des perfekten Schnitzels: Ein wissenschaftlicher Ansatz" — "We tested 47 different breading methods..."
2. "5 Wanderwege, die Ihre Lederhosen verdienen" — Hiking routes from Rax to Grossglockner
3. "Wiener Kaffeehaus-Knigge: Was Sie niemals bestellen sollten" — 42 comments, the most popular post
4. "Warum Graukase das am meisten unterschatzte Lebensmittel ist" — Draft status, zero comments

---

### 7. Auth — "Alpenglueck Login"

Authentication flows using OiAuthPage.

**Login Screen**
- Email and password fields
- Demo credentials displayed: `leopold@alpenglueck.at` / `Sachertorte42!`
- Hint: "It involves a famous Viennese dessert and the answer to everything"
- Success: toast "Welcome back! A Melange awaits you."
- Failure: toast "Wrong credentials. Maybe try again after a coffee?"

**Registration Screen**
- Name, email, password fields with validation
- Password strength: "Your password is weaker than a decaffeinated Melange"
- Success: mock 1s delay, toast "Welcome to Alpenglueck! Your account has been created."

**Forgot Password Screen**
- Email field, submit button
- Success: "We sent you an email. Check your spam too (we're not spam, promise)."

---

## Team Roster

These 8 characters appear consistently across all mini-apps:

| Name | Role | Appears In |
| ---- | ---- | ---------- |
| Leopold Brandauer | CEO & Sachertorten-Sommelier | Auth (demo user), Dashboard, Chat |
| Hans Gruber | Head of Logistics | Chat, Kanban tasks, Calendar |
| Liesl Edelweiss | Senior Developer | Chat, CMS author |
| Franz Knodel | Marketing Manager | Chat (frequent auto-responder), CMS author |
| Maria Alpenrose | Head of Design | Chat, Kanban tasks, Calendar |
| Stefan Strudl | Backend Engineer | Chat, Kanban tasks, CMS author |
| Anna Mozartkugel | Product Manager | Chat, Dashboard activity, Kanban tasks |
| Maximilian Schnitzel | QA Lead | Chat, Comments, Kanban tasks |

Additional employees in the admin user table: Klara Krapfen (Support), Wolfgang Apfelstrudel (Warehouse).

---

## Technical Architecture

### State Management
- **Global**: Theme mode via `ValueNotifier<OiThemeMode>`, propagated through `ValueListenableBuilder`
- **Per-app**: `StatefulWidget` with `setState` for all local state (cart items, messages, selected channel, etc.)
- **No external packages**: No Riverpod, Bloc, Provider, or signals. Pure Flutter state.

### Navigation
- **Home to mini-app**: `Navigator.push` / `Navigator.pop`
- **Within mini-apps**: `setState` on an enum (e.g., `AdminScreen.overview`, `AdminScreen.users`) — no nested navigators
- **OiAppShell's `onNavigate`**: Swaps the child widget based on route string matching

### Mock Data Organization
Each domain has its own data file in `example/lib/data/`:
- `mock_users.dart` — Shared user identities (referenced by all other files)
- `mock_shop.dart` — Products, cart items, shipping/payment methods, addresses, coupons
- `mock_chat.dart` — Channels, message histories, auto-response message pools + `ChatAutoResponder` class
- `mock_dashboard.dart` — KPI values, chart data, employee table records, activity feed events
- `mock_tasks.dart` — Kanban columns/tasks, Gantt chart tasks
- `mock_calendar.dart` — Calendar events, timeline milestones
- `mock_files.dart` — Folder tree and file node data
- `mock_cms.dart` — Blog posts, form field definitions, comment threads
- `mock_auth.dart` — Demo credentials, validation messages
- `mock_countries.dart` — Country/state options for address forms

### Code Organization
```
example/lib/
  main.dart                    # Entry point
  app.dart                     # OiApp wrapper
  theme/                       # Theme definitions and state
  shell/                       # Global navigation shell and home screen
  apps/                        # 7 mini-applications
    shop/                      # E-commerce (5 screens)
    chat/                      # Messaging (1 screen + auto-responder)
    admin/                     # Dashboard (5 screens)
    project/                   # Project management (4 views via tabs)
    files/                     # File manager (1 screen)
    cms/                       # Content management (3 screens)
    auth/                      # Authentication (1 screen, 3 modes)
  data/                        # Mock data files
```

---

## Widget Coverage

The showcase demonstrates **160+ unique widgets** across all 5 architectural tiers:

### Tier 0: Foundation
OiApp, OiThemeData.fromBrand, OiThemeMode, OiOverlays, OiResponsive, OiDensity, OiSettingsDriver, OiAccessibility, OiShortcutScope

### Tier 1: Primitives
OiLabel (all variants), OiIcon, OiSurface, OiDivider, OiRow, OiColumn, OiGrid, OiPage, OiSection, OiSpacer, OiContainer, OiTappable, OiStagger, OiShimmer, OiVirtualList, OiSwipeable, OiWrapLayout, OiVisibility, OiAnimatedList

### Tier 2: Components
- **Buttons**: OiButton (primary/secondary/tertiary/danger/ghost), OiButtonGroup, OiIconButton, OiToggleButton, OiSortButton, OiExportButton
- **Inputs**: OiTextInput, OiNumberInput, OiDateInput, OiTimeInput, OiDateTimeInput, OiSelect, OiCheckbox, OiRadio, OiSwitch, OiSlider, OiColorInput, OiFileInput, OiTagInput
- **Display**: OiAvatar, OiBadge, OiCard, OiEmptyState, OiFieldDisplay, OiImage, OiListTile, OiMetric, OiMarkdown, OiProgress, OiRelativeTime, OiSkeletonGroup, OiTooltip, OiPopover, OiPagination, OiCodeBlock
- **Navigation**: OiAccordion, OiBreadcrumbs, OiTabs, OiDrawer, OiThemeToggle, OiUserMenu, OiDatePicker, OiEmojiPicker
- **Overlays**: OiDialog, OiSheet, OiToast, OiContextMenu
- **Panels**: OiSplitPane, OiPanel, OiResizable
- **Feedback**: OiReactionBar, OiStarRating, OiSentiment, OiThumbs, OiBulkBar
- **Shop**: OiProductCard, OiPriceTag, OiQuantitySelector, OiCartItemRow, OiCouponInput, OiOrderSummaryLine, OiStockBadge, OiWishlistButton, OiAddressForm, OiShippingMethodPicker, OiPaymentMethodPicker, OiOrderStatusBadge
- **Inline Edit**: OiEditableText, OiEditableSelect

### Tier 3: Composites
OiTable, OiDetailView, OiTree, OiForm, OiWizard, OiStepper, OiSidebar, OiNavMenu, OiFilterBar, OiCommandBar, OiSearch, OiComboBox, OiFunnelChart, OiGauge, OiHeatmap, OiRadarChart, OiCalendar, OiGantt, OiTimeline, OiScheduler, OiGallery, OiLightbox, OiRichEditor, OiCartPanel, OiMiniCart, OiOrderSummary, OiOrderTracker, OiProductFilters, OiProductGallery, OiAvatarStack, OiTypingIndicator, OiFlowGraph, OiErrorPage, OiShortcuts

### Tier 4: Modules
OiAppShell, OiChat, OiKanban, OiDashboard, OiFileExplorer, OiListView, OiCheckout, OiShopProductDetail, OiAuthPage, OiComments, OiActivityFeed, OiNotificationCenter, OiResourcePage

---

## Integration Testing

E2E workflow tests using Flutter's `integration_test` framework, running in Chrome.

| Test | Workflow |
| ---- | -------- |
| **Home** | All 7 cards render, each navigates to the correct mini-app |
| **Shop** | Browse > tap product > add to cart > see toast > view cart > checkout wizard (all 4 steps) > order confirmation |
| **Chat** | Select channel > send message > see it appear > typing indicator shows > auto-response arrives |
| **Admin** | Dashboard metrics visible > navigate to Users via sidebar > table renders > navigate to Settings > toggle a switch |
| **Projects** | Kanban columns visible > switch to Gantt tab > Calendar tab > Timeline tab |
| **Files** | File explorer renders with sidebar + content > navigate into folder > content loads |
| **Content** | Article list renders > tap article > detail view with comments > navigate to edit screen |
| **Auth** | Login form renders > switch to register mode > switch to forgot password mode |
| **Theme** | App starts in Alpine (light) > tap theme toggle > verify dark theme is active |

---

## Implementation Order

1. Theme definitions (alpine_theme.dart, vienna_night_theme.dart, theme_state.dart)
2. Mock data files (mock_users.dart first, then all domain-specific files)
3. Shell (showcase_shell.dart, home_screen.dart)
4. App entry (main.dart, app.dart with OiApp wiring)
5. Mini-apps built one at a time: Shop > Chat > Admin > Projects > Files > Content > Auth
6. Integration tests (one per mini-app, plus home and theme tests)

---

## Design Principles

1. **English UI, Austrian data** — Navigation and labels in English for accessibility; mock content in German/Austrian for flavor
2. **No Material widgets** — Everything uses obers_ui primitives (OiLabel not Text, OiRow not Row, etc.)
3. **Humor in data, not chrome** — The product descriptions and chat messages carry personality; the widget usage stays clean
4. **Self-consistent mock data** — Product keys match between cart and catalog, user IDs match between chat and team roster, timestamps are relative to now
5. **Clean code separation** — Data files contain only data, screen files contain only UI, logic files contain only behavior
6. **No external state management** — Pure setState + ValueNotifier for simplicity and to avoid extra dependencies
7. **Every widget earns its place** — No gratuitous widget usage; each widget appears where it naturally belongs in the UX flow
