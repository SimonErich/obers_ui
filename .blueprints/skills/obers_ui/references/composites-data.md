# Composites — data views

Overview: dense data UI—tables, trees, grouped lists, detail layouts, reordering, property grids, and shop cart/order summaries. [← Skill](../SKILL.md)

Paths: `lib/src/composites/<area>/...`.

## Data core

| Name | Path | Role |
|------|------|------|
| `OiDataGrid` | `data/oi_data_grid.dart` | Columnar grid; **`OiDataGridColumn`** |
| `OiTable` | `data/oi_table.dart` | Virtualized table; **`OiTableColumn`** |
| `OiTableController` | `data/oi_table_controller.dart` | Table state (sort, filter, selection) |
| `OiPaginationController` | `data/oi_pagination_controller.dart` | Page index/size for paged data |
| `OiGroupedList` | `data/oi_grouped_list.dart` | Grouped sections; **`OiGroupedListController`** |
| `OiTree` | `data/oi_tree.dart` | Hierarchical tree; **`OiTreeNode`**, **`OiTreeController`** |
| `OiDetailView` | `data/oi_detail_view.dart` | Label/value detail page; **`OiDetailField`**, **`OiDetailSection`** |
| `OiReorderableList` | `data/oi_reorderable_list.dart` | Drag-reorder list |
| `OiPropertyGrid` | `data/oi_property_grid.dart` | Key/value property editor; **`OiPropertyRow`** |

## Shop data

| Name | Path | Role |
|------|------|------|
| `OiCartPanel` | `shop/oi_cart_panel.dart` | Side cart panel |
| `OiMiniCart` | `shop/oi_mini_cart.dart` | Compact cart popover |
| `OiOrderSummary` | `shop/oi_order_summary.dart` | Checkout totals block |
| `OiProductGallery` | `shop/oi_product_gallery.dart` | Product image gallery |
| `OiOrderTracker` | `shop/oi_order_tracker.dart` | Shipment/delivery timeline |
| `OiProductFilters` | `shop/oi_product_filters.dart` | Faceted filters; **`OiProductFilterData`** |

## Related search (data entry)

| Name | Path | Role |
|------|------|------|
| `OiComboBox` | `search/oi_combo_box.dart` | Combo list (see also [components-inputs-actions.md](components-inputs-actions.md)) |
