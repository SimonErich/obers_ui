# Modules

Modules are whole features you can drop into an app. Each one wraps the smaller
widgets into a complete, working surface: a dashboard, a chat panel, a file
explorer, a settings screen. You give it data and callbacks, it handles the rest,
including layout, responsiveness, and (where it makes sense) persistence.

Reach for a module before you hand-build a feature. If it fits, you save a lot of
wiring. If you need something the module does not offer, drop down to the
[composites and components](../widgets/index.md) it is built from.

## What's here

| Page | Modules |
| --- | --- |
| [App Shell & Navigation](app-shell.md) | `OiAppShell`, `OiDrawerNavigation` |
| [Dashboards, Lists & Boards](data-views.md) | `OiDashboard`, `OiListView`, `OiKanban` |
| [File Management](files.md) | `OiFileExplorer`, `OiFileManager` |
| [Chat, Comments & Notifications](communication.md) | `OiChat`, `OiChatWindow`, `OiComments`, `OiActivityFeed`, `OiNotificationCenter` |
| [Accounts & Settings](account.md) | `OiAuthPage`, `OiProfilePage`, `OiSettingsPage`, `OiSubscriptionManager`, `OiPermissions` |
| [Commerce Screens](commerce.md) | `OiCheckout`, `OiShopProductDetail`, `OiPricingTable` |
| [Support & System Pages](support-and-system.md) | `OiHelpCenter`, `OiResourcePage`, `OiFeedbackSheet`, `OiConsentBanner`, `OiErrorPage`, `OiMaintenancePage`, `OiDevMenu`, `OiSearchOverlay` |

## A note on data

Modules are presentational. They do not fetch data or talk to your backend. You
pass in the data and a set of callbacks, and the module calls those callbacks when
the user acts. This keeps them easy to test and free of any assumption about your
state management or API.

## Related

- [Widgets](../widgets/index.md) for the building blocks modules are made of.
- [Custom Modules](../advanced/custom-modules.md) to compose your own when none fit.
- [State, Undo & Persistence](../core-concepts/state-and-persistence.md) for the settings driver that saves module layout and preferences.
