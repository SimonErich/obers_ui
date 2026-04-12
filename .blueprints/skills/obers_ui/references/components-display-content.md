# Components — display, feedback, dialogs

Overview: read-only and rich content, loading/empty states, ratings, file-operation dialogs, and shop merchandising rows. [← Skill](../SKILL.md)

Paths: `lib/src/components/<area>/...` unless noted.

## Display

| Name | Path | Role |
|------|------|------|
| `OiAvatar` | `display/oi_avatar.dart` | User or entity avatar |
| `OiBadge` | `display/oi_badge.dart` | Status or count chip |
| `OiCard` | `display/oi_card.dart` | Content card container |
| `OiCodeBlock` | `display/oi_code_block.dart` | Syntax-highlighted code |
| `OiDiffView` | `display/oi_diff_view.dart` | Line-by-line diff |
| `OiDropHighlight` | `display/oi_drop_highlight.dart` | Drop-target highlight |
| `OiEmptyState` | `display/oi_empty_state.dart` | Empty placeholder |
| `OiFieldDisplay` | `display/oi_field_display.dart` | Read-only labeled value |
| `OiFileGridCard` | `display/oi_file_grid_card.dart` | File card for grids |
| `OiFileIcon` | `display/oi_file_icon.dart` | File type icon |
| `OiFilePreview` | `display/oi_file_preview.dart` | Inline file preview |
| `OiFileTile` | `display/oi_file_tile.dart` | File row |
| `OiFolderIcon` | `display/oi_folder_icon.dart` | Folder glyph |
| `OiFolderTreeItem` | `display/oi_folder_tree_item.dart` | Tree row for folders |
| `OiImage` | `display/oi_image.dart` | Themed image |
| `OiImagePreviewCard` | `display/oi_image_preview_card.dart` | Image preview card |
| `OiKeyValue` | `display/oi_key_value.dart` | Key/value row |
| `OiListTile` | `display/oi_list_tile.dart` | Standard list row |
| `OiMarkdown` | `display/oi_markdown.dart` | Markdown body |
| `OiMetric` | `display/oi_metric.dart` | KPI or stat |
| `OiPageIndicator` | `display/oi_page_indicator.dart` | Pager dots |
| `OiPagination` | `display/oi_pagination.dart` | Page controls |
| `OiPathBar` | `display/oi_path_bar.dart` | Breadcrumb path |
| `OiPopover` | `display/oi_popover.dart` | Anchored popover |
| `OiProgress` | `display/oi_progress.dart` | Linear or circular progress |
| `OiRefreshIndicator` | `display/oi_refresh_indicator.dart` | Pull-to-refresh |
| `OiRelativeTime` | `display/oi_relative_time.dart` | Relative timestamp |
| `OiRenameField` | `display/oi_rename_field.dart` | Inline rename display |
| `OiReplyPreview` | `display/oi_reply_preview.dart` | Thread reply snippet |
| `OiScrollToTop` | `display/oi_scroll_to_top.dart` | Floating scroll affordance |
| `OiSkeletonGroup` | `display/oi_skeleton_group.dart` | Skeleton placeholders |
| `OiSliverHeader` | `display/oi_sliver_header.dart` | Collapsing sliver header |
| `OiStatusDot` | `display/oi_status_dot.dart` | Small status indicator |
| `OiStorageIndicator` | `display/oi_storage_indicator.dart` | Storage usage bar |
| `OiTooltip` | `display/oi_tooltip.dart` | Hover/focus tooltip |

## Shop display

| Name | Path | Role |
|------|------|------|
| `OiOrderStatusBadge` | `shop/oi_order_status_badge.dart` | Order state badge |
| `OiPriceTag` | `shop/oi_price_tag.dart` | Price presentation |
| `OiProductCard` | `shop/oi_product_card.dart` | Product summary card |
| `OiCartItemRow` | `shop/oi_cart_item_row.dart` | Line item in cart |
| `OiOrderSummaryLine` | `shop/oi_order_summary_line.dart` | Checkout summary row |
| `OiStockBadge` | `shop/oi_stock_badge.dart` | Inventory badge |
| `OiShippingOption` | `shop/oi_shipping_option.dart` | Shipping choice tile |
| `OiPaymentOption` | `shop/oi_payment_option.dart` | Payment choice tile |

## Feedback

| Name | Path | Role |
|------|------|------|
| `OiBanner` | `feedback/oi_banner.dart` | Inline alert banner |
| `OiBulkBar` | `feedback/oi_bulk_bar.dart` | Multi-select action bar |
| `OiPipelineProgress` | `feedback/oi_pipeline_progress.dart` | Multi-step pipeline UI |
| `OiReactionBar` | `feedback/oi_reaction_bar.dart` | Emoji reactions |
| `OiScaleRating` | `feedback/oi_scale_rating.dart` | Discrete scale rating |
| `OiSentiment` | `feedback/oi_sentiment.dart` | Sentiment selector |
| `OiSkeletonPreset` | `feedback/oi_skeleton_preset.dart` | Named skeleton layouts |
| `OiStarRating` | `feedback/oi_star_rating.dart` | Star rating |
| `OiThumbs` | `feedback/oi_thumbs.dart` | Thumbs up/down |

## Dialogs (file operations)

| Name | Path | Role |
|------|------|------|
| `OiDeleteDialog` | `dialogs/oi_delete_dialog.dart` | Confirm delete |
| `OiFileInfoDialog` | `dialogs/oi_file_info_dialog.dart` | File metadata |
| `OiMoveDialog` | `dialogs/oi_move_dialog.dart` | Move destination |
| `OiNewFolderDialog` | `dialogs/oi_new_folder_dialog.dart` | Create folder |
| `OiRenameDialog` | `dialogs/oi_rename_dialog.dart` | Rename entity |
| `OiUploadDialog` | `dialogs/oi_upload_dialog.dart` | Upload flow |
