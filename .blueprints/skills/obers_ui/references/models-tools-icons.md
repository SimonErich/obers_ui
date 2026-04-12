# Models, tools, utilities, icons

Overview: shared DTOs and controllers, persisted settings blobs, dev tools, pure helpers, and the icon constant registry. [← Skill](../SKILL.md)

Paths: `lib/src/models/...`, `lib/src/tools/...`, `lib/src/utils/...`, `lib/src/foundation/...` (icons).

## Domain models

| Name | Path | Role |
|------|------|------|
| `OiNavigationItem` | `models/oi_navigation_item.dart` | Sidebar/rail item payload |
| `OiFieldType` | `models/oi_field_type.dart` | Enum for field kinds |
| `OiProductData` | `models/oi_product_data.dart` | Product; **`OiProductVariant`** |
| `OiCartItem` | `models/oi_cart_item.dart` | Cart line |
| `OiCartSummary` | `models/oi_cart_summary.dart` | Cart totals |
| `OiAddressData` | `models/oi_address_data.dart` | Postal address |
| `OiCheckoutData` | `models/oi_checkout_data.dart` | Checkout session payload |
| `OiOrderData` | `models/oi_order_data.dart` | Order + **`OiOrderEvent`** |
| `OiShippingMethod` | `models/oi_shipping_method.dart` | Shipping option model |
| `OiPaymentMethod` | `models/oi_payment_method.dart` | Payment option model |
| `OiCouponResult` | `models/oi_coupon_result.dart` | Coupon apply result |
| `OiFileNodeData` | `models/oi_file_node_data.dart` | File tree node |
| `OiFileExplorerController` | `models/oi_file_explorer_controller.dart` | Explorer selection/state |
| `OiCountryOption` | `models/oi_country_option.dart` | Country; **`OiStateOption`** |

## Settings models (`OiSettingsData`)

Immutable JSON-friendly state for widgets that persist UI. Each file in `models/settings/` defines one `*Settings` class mixin `OiSettingsData` (accordion, app shell, calendar, consent banner, dashboard, file explorer, filter bar, gantt, grouped list, kanban, list view, sidebar, split pane, table, tabs). Pair with [`OiSettingsDriver`](foundation.md) from foundation.

| Path pattern | Role |
|--------------|------|
| `models/settings/oi_*_settings.dart` | Per-feature persisted layout/state |

## Tools (development)

| Name | Path | Role |
|------|------|------|
| `OiDynamicTheme` | `tools/oi_dynamic_theme.dart` | Runtime theme tweaking |
| `OiPlayground` | `tools/oi_playground.dart` | Widget playground shell |
| `OiThemeExporter` | `tools/oi_theme_exporter.dart` | Export theme tokens |
| `OiThemePreview` | `tools/oi_theme_preview.dart` | Preview theme variants |

## Utilities (pure helpers)

| Module | Path | Role |
|--------|------|------|
| Formatters | `utils/formatters.dart` | **`OiFormatters`** static helpers |
| Color utils | `utils/color_utils.dart` | Color math |
| Calendar utils | `utils/calendar_utils.dart` | Date range helpers |
| File utils | `utils/file_utils.dart` | Paths, sizes, mime hints |
| Fuzzy search | `utils/fuzzy_search.dart` | Fuzzy string match |
| Spring physics | `utils/spring_physics.dart` | Spring simulation |

## Icons

| Name | Path | Role |
|------|------|------|
| `OiIcons` | `foundation/oi_icons.dart` | Large Lucide-aligned constant set—use instead of `Icons.*` |
| `OiIconData` | `foundation/icons/oi_icon_data.dart` | Icon descriptor type |
