# obers_ui Showcase

Interactive showcase application for the [obers_ui](../) Flutter UI library. Demonstrates **160+ widgets** across 7 mini-applications, all themed around **Alpenglueck GmbH** — a fictional Austrian e-commerce company.

## Quick Start

```bash
flutter run -d chrome
```

## Mini-Applications

| App | Description | Key Widgets |
| --- | ----------- | ----------- |
| **Shop** | Product browsing, cart, checkout wizard | OiCheckout, OiShopProductDetail, OiCartPanel, OiProductCard |
| **Chat** | Team messaging with auto-responses | OiChat, OiSplitPane, typing indicators, emoji reactions |
| **Admin** | Dashboard, user table, settings forms | OiAppShell, OiDashboard, OiTable, OiForm, OiActivityFeed |
| **Projects** | Kanban, Gantt, calendar, timeline | OiKanban, OiGantt, OiCalendar, OiTimeline |
| **Files** | File explorer with CRUD operations | OiFileExplorer, OiTree, context menus |
| **Content** | CMS with articles, editor, comments | OiListView, OiComments, OiForm, OiRichEditor |
| **Auth** | Login, registration, password reset | OiAuthPage |

## Themes

Two switchable themes accessible via the top bar toggle:

- **Alpine** (light) — Forest green brand, rounded corners
- **Vienna Night** (dark) — Baroque gold brand, medium corners

## Project Structure

```
lib/
  main.dart              Entry point
  app.dart               OiApp wrapper with theme state
  theme/                 Theme definitions and toggle state
  shell/                 Global navigation shell and home screen
  apps/                  7 mini-applications
    shop/                E-commerce (5 screens)
    chat/                Messaging (1 screen + auto-responder)
    admin/               Dashboard (5 screens)
    project/             Project management (4 tab views)
    files/               File manager (1 screen)
    cms/                 Content management (3 screens)
    auth/                Authentication (1 screen, 3 modes)
  data/                  Mock data files

integration_test/        E2E workflow tests
```

## Mock Data

All data is local — no backend required. The mock data features:

- **10 Austrian products** with witty descriptions (Sachertorte, Schnitzel Kit, Mozartkugeln, ...)
- **8 team members** with food-themed surnames (Franz Knödel, Stefan Strudl, Anna Mozartkugel, ...)
- **5 chat channels** with realistic conversations and an auto-response engine
- **Dashboard metrics**, chart data, and activity feed events
- **Kanban tasks**, Gantt chart timelines, and calendar events
- **File system** with folders, documents, and secret recipes
- **CMS articles** with threaded comments

## Integration Tests

```bash
flutter test integration_test/ -d chrome
```

Tests cover all 7 mini-apps, home screen navigation, and theme switching.

## Demo Credentials

For the Auth screen: `leopold@alpenglueck.at` / `Sachertorte42!`
