# Comprehensive Example App Enhancement Plan

## Context

The obers_ui library has 160+ widgets but the example showcase app only demonstrates ~60% of them, with many features shown at a basic level. The goal is to make every mini-app a rich, realistic demonstration of all available library features so developers can see what production apps built with obers_ui truly look like.

**Key gaps:** Admin has no nested nav/advanced tables/permissions, Chat has no threads/replies/user profiles, CMS has 3 placeholder screens and dead OiComments, Shop has no reviews/related products/multi-image galleries, Projects missing Pipeline/Scheduler/FlowGraph, and many widgets (OiSankey, OiTreemap, OiWhatsNew, OiTour, OiLiveRing, OiThumbs, OiScaleRating, etc.) aren't showcased anywhere.

---

## Phase 1: Admin App Enhancement

### 1.1 Expand mock data
**File:** `example/lib/data/mock_dashboard.dart`
- Add 15 more employees (25 total) with new fields: `status` (active/inactive/on-leave), `phone`, `location`
- Add order line items to each order (product, quantity, unitPrice, total) + shippingAddress, paymentMethod
- Add `kMockReturns` (6-8 return requests with statuses: requested/approved/shipped-back/refunded)
- Add `kMockRoles` (OiRole: admin/editor/viewer/support with colors) and `kMockPermissions` (12 OiPermissionItem entries) and `kMockPermissionMatrix` (Map<String, Set<String>>)
- Add `kMockApiKeys` (2 entries with name, key, created)
- Add `kAdminCommands` (List<OiCommand> for command bar: Go to Users, Go to Orders, Create User, Export, etc.)
- Add `kSankeyNodes`/`kSankeyLinks` (customer journey flow) and `kTreemapNodes` (revenue by category)

**File:** `example/lib/data/mock_users.dart`
- Add MockUser constants for the 15 new employees

### 1.2 Enhance admin sidebar navigation
**File:** `example/lib/apps/admin/admin_app.dart`
- Convert flat nav to nested: `Users` → children `[User List, Roles & Permissions]`, `Orders` → children `[All Orders, Returns]`
- Add `userMenu:` OiUserMenu with Leopold Brandauer, profile/preferences/sign-out items
- Add `breadcrumbs:` computed from `_currentRoute` (e.g. Admin > Users > User List)
- Add OiCommandBar overlay triggered by Ctrl+K (wrap in OiShortcutScope)
- Add search icon button in actions that triggers command bar
- Add new route cases: `'permissions'` → AdminPermissionsScreen, `'returns'` → AdminReturnsScreen

### 1.3 Enhance Users table (advanced OiTable features)
**File:** `example/lib/apps/admin/screens/admin_users_screen.dart`
- Enable `paginationMode: OiTablePaginationMode.pages`, `pageSizeOptions: [5, 10, 25]`
- Enable `showColumnManager: true`, `striped: true`
- Add `groupBy:` with a dropdown to toggle between none/department/role
- Add inline editing via `cellBuilder` using OiEditableText (name) and OiEditableSelect (role, department)
- Add trailing actions column with "..." button opening OiContextMenu (Edit, Deactivate, Send Email, Delete)
- Enhance detail sheet: OiTabs (Profile / Activity / Metadata), OiMetadataEditor in Metadata tab
- Add OiTooltip on column headers for explanations

### 1.4 New: Roles & Permissions screen
**New file:** `example/lib/apps/admin/screens/admin_permissions_screen.dart`
- OiPermissions widget with kMockRoles, kMockPermissions, kMockPermissionMatrix
- Mutable `_matrix` state, onChange updates via setState
- Save button shows success OiToast
- Header with OiLabel.h3 title + save button

### 1.5 Enhance Orders screen
**File:** `example/lib/apps/admin/screens/admin_orders_screen.dart`
- Wrap in OiResourcePage (variant: list)
- Add OiFilterBar with status (select), date (dateRange), customer (text) filters
- Convert to StatefulWidget for filter state
- Add `paginationMode: OiTablePaginationMode.pages`
- Row tap opens OiSheet with: OiStepper showing order progress, OiDetailView with metadata, inner OiTable of line items

### 1.6 New: Returns screen
**New file:** `example/lib/apps/admin/screens/admin_returns_screen.dart`
- Top: OiPipeline showing return workflow (Requested → Approved → Shipped Back → Inspected → Refunded)
- Below: OiTable of return requests with status OiBadge
- Row tap updates pipeline to reflect selected return's status

### 1.7 Enhance Settings screen
**File:** `example/lib/apps/admin/screens/admin_settings_screen.dart`
- Wrap form sections in OiAccordion (General, Notifications, Appearance, API Keys)
- Add API Keys section with OiCodeBlock displaying masked keys + OiCopyButton
- Add OiDiffView section showing unsaved changes (compare initial values vs current)

### 1.8 Enhance Activity screen
**File:** `example/lib/apps/admin/screens/admin_activity_screen.dart`
- Add OiTabs toggle between "Feed" and "Timeline" views
- Timeline view uses OiTimeline with same events
- Add "Load More" button with `_visibleCount` state

### 1.9 Enhance Notifications screen
**File:** `example/lib/apps/admin/screens/admin_notifications_screen.dart`
- Add dismiss with undo: OiToast with "Undo" action that restores dismissed notification

### 1.10 Enhance Overview (Dashboard)
**File:** `example/lib/apps/admin/screens/admin_overview_screen.dart`
- Add OiTooltip on each OiMetric card
- Add OiSankey card (customer journey flow, 4-col span)
- Add OiTreemap card (revenue by category, 2-col span)
- Add Ctrl+K hint text in toolbar

---

## Phase 2: Chat App Enhancement

### 2.1 Expand chat mock data
**File:** `example/lib/data/mock_chat.dart`
- Add `topic` and `members` fields to MockChannel
- Add 3 DM channels (Leopold↔Hans, Leopold↔Liesl, Leopold↔Anna) with `isDM: true`
- Add `kOnlineUsers` set for online status
- Add `kPinnedMessages` map (channelId → list of message keys)
- Add channel topics (e.g., "Company-wide announcements and water-cooler chat")
- Build DM messages in `buildChannelMessages()`
- Add some messages with `replyToKey` for quoted reply demo

### 2.2 Restructure channel sidebar
**File:** `example/lib/apps/chat/chat_app.dart`
- Add OiTextInput.search() at top for channel filtering
- Split into sections with OiLabel.caption headers: "Channels" and "Direct Messages"
- DM entries show OiAvatar wrapped in OiLiveRing (active from kOnlineUsers)
- Channel entries show `#` prefix with OiBadge for unread
- Add "New Channel" ghost button below Channels header

### 2.3 Add channel header bar
**File:** `example/lib/apps/chat/chat_app.dart`
- Build header above OiChat in a Column
- Show channel name + topic (OiLabel.caption)
- OiAvatarStack showing channel members (maxVisible: 4)
- Pin icon button (count badge) → OiSheet listing pinned messages
- Info button → OiSheet with channel details, member list (OiListTile per member)

### 2.4 Add message reply support
**File:** `example/lib/apps/chat/chat_app.dart`
- Add `_replyingTo` state (OiChatMessage?)
- Show OiReplyPreview between header and OiChat when replying
- Dismissible via X button (onDismiss clears _replyingTo)
- Add reply context menu option (build action row or long-press handler)

### 2.5 Add user profile popover
**File:** `example/lib/apps/chat/chat_app.dart`
- On DM avatar tap in sidebar → OiPopover showing user card
- Card shows OiAvatar (large), name, role, email, "Send Message" button

### 2.6 Add chat command bar
**File:** `example/lib/apps/chat/chat_app.dart`
- Add OiCommandBar with commands: search messages, go-to-channel (one per channel/DM)
- Trigger via Ctrl+K or search icon in header

---

## Phase 3: CMS App Enhancement

### 3.1 Wire OiComments callbacks
**File:** `example/lib/apps/cms/screens/cms_article_show_screen.dart`
- Convert to StatefulWidget
- Add mutable `_comments` state initialized from buildBlogComments()
- Wire all 5 callbacks: onComment, onReply, onEdit, onDelete, onReact
- Implement recursive helpers: _addReply, _editComment, _removeComment, _toggleReaction

### 3.2 Implement Categories screen (OiTree)
**New file:** `example/lib/apps/cms/screens/cms_categories_screen.dart`
**Mock data:** Add `buildCategoryTree()` to mock_cms.dart returning hierarchical OiTreeNode<String> list
- OiTree with selectable nodes, OiTreeController
- OiSplitPane: tree left, detail/actions right
- Context menu (OiContextMenu) on nodes: Rename, Add Subcategory, Delete
- Add/rename via OiDialog, delete via OiDeleteDialog
**File:** `example/lib/apps/cms/cms_app.dart` — replace placeholder with CmsCategoriesScreen

### 3.3 Implement Media screen (OiGallery)
**New file:** `example/lib/apps/cms/screens/cms_media_screen.dart`
**Mock data:** Add `kMediaItems` list to mock_cms.dart
- OiGallery grid for image display
- OiFilterBar for media type filtering (Images, Documents, Videos)
- OiLightbox on item tap for full-screen preview
- OiFileInput/OiFileDropTarget for upload
- Selection mode with bulk delete
**File:** `example/lib/apps/cms/cms_app.dart` — replace placeholder with CmsMediaScreen

### 3.4 Implement Settings screen
**New file:** `example/lib/apps/cms/screens/cms_settings_screen.dart`
- OiAccordion with sections: General, SEO, Comments, Notifications
- Each section has OiForm fields (OiTextInput, OiSwitch, OiNumberInput, OiTagInput, OiFileInput)
- Save button with OiToast
**File:** `example/lib/apps/cms/cms_app.dart` — replace placeholder with CmsSettingsScreen

### 3.5 Enhance Articles list
**File:** `example/lib/apps/cms/screens/cms_articles_screen.dart`
- Add sorting options to OiListView (date, title, comments)
- Add multi-select mode with bulk actions (Publish, Unpublish, Delete)
- Add inline OiEditableSelect for article status on cards

### 3.6 Add article version diff (stretch)
**File:** `example/lib/apps/cms/screens/cms_article_show_screen.dart`
- "Version History" button → OiDialog with OiDiffView showing mock diff lines

---

## Phase 4: Shop App Enhancement

### 4.1 Add multi-image product data
**File:** `example/lib/data/mock_shop.dart`
- Add 3-5 imageUrls per product (placeholder URLs)
- This auto-enables OiProductGallery thumbnail strip in OiShopProductDetail

### 4.2 Add related products
**File:** `example/lib/data/mock_shop.dart` — add `getRelatedProducts(key)` mapping
**File:** `example/lib/apps/shop/shop_product_screen.dart` — pass `related: getRelatedProducts(product.key)` to OiShopProductDetail
**File:** `example/lib/apps/shop/shop_app.dart` — wire onSelectProduct callback for navigation from related products

### 4.3 Add product reviews
**File:** `example/lib/data/mock_shop.dart` — add MockReview class and `kProductReviews` map (5-10 reviews across products)
**File:** `example/lib/apps/shop/shop_product_screen.dart` — build reviews widget with OiStarRating distribution, review cards with OiAvatar + OiStarRating + content + OiThumbs ("was this helpful?"), pass as `reviews:` parameter

### 4.4 Add wishlist screen
**New file:** `example/lib/apps/shop/shop_wishlist_screen.dart`
- OiGrid of wishlisted OiProductCards
- OiEmptyState when empty
**File:** `example/lib/apps/shop/shop_app.dart` — add wishlist route + button in browse header
**File:** `example/lib/apps/shop/shop_browse_screen.dart` — add wishlist icon button with badge count

### 4.5 Enhance cart
**File:** `example/lib/apps/shop/shop_cart_screen.dart` (or where cart panel lives)
- Add OiProgress bar for free shipping threshold
- Show "EUR X more for free shipping!" or success badge

---

## Phase 5: Projects App Enhancement

### 5.1 Enhance Kanban
**File:** `example/lib/data/mock_tasks.dart` — add extra task to "In Progress" to trigger WIP warning
**File:** `example/lib/apps/project/screens/project_kanban_screen.dart`
- Add OiContextMenu on cards (Edit, Move to..., Delete)
- Ensure WIP limit warning is visible (adjust limit or add tasks)

### 5.2 Enhance Calendar
**File:** `example/lib/apps/project/screens/project_calendar_screen.dart`
- Convert to StatefulWidget with mutable `_events`
- Wire `onDateTap:` → OiDialog for event creation
- Wire `onEventMove:` → update event start/end in state

### 5.3 Add Pipeline tab
**New file:** `example/lib/apps/project/screens/project_pipeline_screen.dart`
- OiPipeline with 5 stages (Development → Code Review → QA → Staging → Production)
**File:** `example/lib/apps/project/project_app.dart` — add Pipeline tab

### 5.4 Add Scheduler tab
**New file:** `example/lib/apps/project/screens/project_scheduler_screen.dart`
- OiScheduler with team schedule slots (8am-6pm, week view)
- Mock schedule data in mock_calendar.dart
**File:** `example/lib/apps/project/project_app.dart` — add Scheduler tab

### 5.5 Add Flow Graph tab (stretch)
**New file:** `example/lib/apps/project/screens/project_flow_screen.dart`
- OiFlowGraph showing deployment pipeline as node graph
- OiStateDiagram showing order lifecycle states
**File:** `example/lib/apps/project/project_app.dart` — add Workflows tab

---

## Phase 6: Files App Enhancement

### 6.1 Add file preview
**File:** `example/lib/apps/files/files_app.dart`
- Wire `filePreviewBuilder:` — image preview for image mimeTypes, OiMarkdown for .md, generic OiFilePreview otherwise
- Wire `onPreview:` — open OiLightbox for images via OiSheet
- Add `customContextMenuItems:` — "Annotate" option for images (opens OiImageAnnotator placeholder)

### 6.2 Add mock video file
**File:** `example/lib/data/mock_files.dart`
- Add a video file node in Marketing folder
- Preview builder handles video/mp4 with OiVideoPlayer

---

## Phase 7: Unused Widgets Integration

### 7.1 OiWhatsNew on home screen
**File:** `example/lib/shell/home_screen.dart`
- Convert to StatefulWidget
- Show OiWhatsNew dialog on first render (or via "What's New" button)
- 3-4 changelog items highlighting showcase features

### 7.2 Feedback widgets (integrated into earlier phases)
- OiThumbs → product reviews (Phase 4.3)
- OiScaleRating → CMS settings "Rate your experience" (Phase 3.4)
- OiSentiment → Admin activity or notification feedback

### 7.3 Social presence widgets (integrated into Chat)
- OiLiveRing → DM avatars (Phase 2.2)
- OiAvatarStack → channel header (Phase 2.3)
- OiTypingIndicator → already used by OiChat internally

---

## New Files to Create (10 total)

| File | Purpose |
|------|---------|
| `example/lib/apps/admin/screens/admin_permissions_screen.dart` | OiPermissions matrix |
| `example/lib/apps/admin/screens/admin_returns_screen.dart` | OiPipeline + returns table |
| `example/lib/apps/cms/screens/cms_categories_screen.dart` | OiTree category management |
| `example/lib/apps/cms/screens/cms_media_screen.dart` | OiGallery media library |
| `example/lib/apps/cms/screens/cms_settings_screen.dart` | OiAccordion + OiForm settings |
| `example/lib/apps/shop/shop_wishlist_screen.dart` | Wishlist grid |
| `example/lib/apps/project/screens/project_pipeline_screen.dart` | OiPipeline visualization |
| `example/lib/apps/project/screens/project_scheduler_screen.dart` | OiScheduler team scheduling |
| `example/lib/apps/project/screens/project_flow_screen.dart` | OiFlowGraph + OiStateDiagram |

## Existing Files to Modify (20+ files)

**Mock data (5):** mock_dashboard.dart, mock_users.dart, mock_chat.dart, mock_shop.dart, mock_cms.dart, mock_tasks.dart, mock_calendar.dart
**Admin (7):** admin_app.dart, admin_overview_screen.dart, admin_users_screen.dart, admin_orders_screen.dart, admin_settings_screen.dart, admin_activity_screen.dart, admin_notifications_screen.dart
**Chat (1):** chat_app.dart
**CMS (3):** cms_app.dart, cms_article_show_screen.dart, cms_articles_screen.dart
**Shop (4):** mock_shop.dart, shop_app.dart, shop_product_screen.dart, shop_browse_screen.dart
**Projects (3):** project_app.dart, project_kanban_screen.dart, project_calendar_screen.dart
**Files (2):** files_app.dart, mock_files.dart
**Shell (1):** home_screen.dart

---

## Newly Showcased Widgets (40+)

OiNavItem.children (nested nav), OiUserMenu, OiBreadcrumbs, OiCommandBar, OiShortcutScope, OiEditableText, OiEditableSelect, OiContextMenu, OiTooltip, OiPermissions, OiMetadataEditor, OiResourcePage, OiFilterBar, OiStepper, OiPipeline, OiAccordion, OiCodeBlock, OiDiffView, OiTimeline (in admin), OiReplyPreview, OiAvatarStack, OiLiveRing, OiPopover, OiListTile, OiSearch, OiTree, OiGallery, OiLightbox, OiFileDropTarget, OiWhatsNew, OiSankey, OiTreemap, OiThumbs, OiScaleRating, OiSentiment, OiFlowGraph, OiStateDiagram, OiScheduler, OiVideoPlayer, OiImageAnnotator, OiEmptyState (in wishlist), OiTable.groupBy/showColumnManager/striped/paginationMode

---

## Implementation Order

1. **Mock data first** (all data files — foundation for everything)
2. **Admin** (1.2→1.3→1.4→1.5→1.6→1.7→1.8→1.9→1.10)
3. **Chat** (2.2→2.3→2.4→2.5→2.6)
4. **CMS** (3.1→3.2→3.3→3.4→3.5)
5. **Shop** (4.1→4.2→4.3→4.4→4.5)
6. **Projects** (5.1→5.2→5.3→5.4→5.5)
7. **Files** (6.1→6.2)
8. **Shell** (7.1)

---

## Verification

After each phase:
1. `dart analyze` — ensure no analyzer errors
2. `cd example && flutter build web` — ensure example compiles
3. `flutter test` — ensure existing tests still pass
4. Manual check: run `cd example && flutter run` and navigate through each mini-app to verify features work
