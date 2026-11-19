# obers_ui Showcase

Interactive showcase application for the [obers_ui](../) Flutter UI library. Demonstrates **160+ widgets** across 10 mini-applications, all themed around **Alpenglueck GmbH** — a fictional Austrian e-commerce company.

## Quick Start

```bash
flutter run -d chrome
```

## Mini-Applications

| App | Description | Key Widgets |
| --- | ----------- | ----------- |
| **Component Library** | Catalog of the library's widgets with live previews | Primitives, components, composites, modules |
| **Shop** | Product browsing, cart, checkout wizard | OiCheckout, OiShopProductDetail, OiCartPanel, OiProductCard |
| **Chat** | Team messaging with auto-responses | OiChat, OiSplitPane, typing indicators, emoji reactions |
| **Admin** | Dashboard, user table, settings forms | OiAppShell, OiDashboard, OiTable, OiAfForm, OiActivityFeed |
| **Projects** | Kanban, Gantt, calendar, timeline | OiKanban, OiGantt, OiCalendar, OiTimeline |
| **Files** | File explorer with CRUD operations | OiFileExplorer, OiTree, context menus |
| **Content** | CMS with articles, editor, comments | OiListView, OiComments, OiAfForm, OiRichEditor |
| **Auth** | Login, registration, password reset | OiAuthPage |
| **AutoForms** | Form handling with the `obers_ui_autoforms` package | OiAfForm, OiAfTextInput, OiAfSelect |
| **Icons** | Searchable browser for the Lucide icon set | OiIcon, OiIcons |

## Themes

Four theme presets, each with a light and a dark variant. The top bar switches the preset and toggles light/dark:

- **Alpine** — Forest green brand, rounded corners; its dark variant is **Vienna Night** (baroque gold brand, medium corners)
- **Blue Danube** — Teal/cyan brand
- **Arco** — Blue brand
- **Finesse** — Indigo/violet brand

## Project Structure

```
lib/
  main.dart              Entry point
  app.dart               OiApp wrapper with theme state
  theme/                 Theme definitions and toggle state
  shell/                 Global navigation shell and home screen
  apps/                  10 mini-applications
    component_library/   Widget catalog
    shop/                E-commerce (5 screens)
    chat/                Messaging (1 screen + auto-responder)
    admin/               Dashboard (5 screens)
    project/             Project management (4 tab views)
    files/               File manager (1 screen)
    cms/                 Content management (3 screens)
    auth/                Authentication (1 screen, 3 modes)
    autoforms/           obers_ui_autoforms showcase
    icons/               Icon browser
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

Tests cover the Shop, Chat, Admin, Projects, Files, Content and Auth apps, home screen navigation, and theme switching.

## Demo Credentials

For the Auth screen: `leopold@alpenglueck.at` / `Sachertorte42!`
