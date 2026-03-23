import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_example/apps/component_library/shared/component_showcase_section.dart';

/// Showcase screen listing all full-feature modules with descriptions.
class ModulesScreen extends StatelessWidget {
  const ModulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── OiAppShell ────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'App Shell',
            widgetName: 'OiAppShell',
            description:
                'Full application shell with collapsible sidebar, top bar, '
                'breadcrumbs, and responsive layout. The foundation for '
                'building complete applications.',
            examples: [
              ComponentExample(
                title: 'Full-Feature Module',
                child: OiLabel.body(
                  'OiAppShell is the top-level layout module that provides '
                  'sidebar navigation, a header bar with breadcrumbs, and '
                  'responsive breakpoint handling. See the Admin and CMS '
                  'mini-apps for live demos.',
                  color: colors.textSubtle,
                ),
              ),
            ],
          ),

          // ── OiListView ────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'List View',
            widgetName: 'OiListView',
            description:
                'A customizable list module with sorting, filtering, '
                'pagination, layout switching (list/grid/table), and bulk '
                'actions.',
            examples: [
              ComponentExample(
                title: 'Full-Feature Module',
                child: OiLabel.body(
                  'OiListView provides a complete data listing experience '
                  'with column sorting, search filtering, pagination, and '
                  'switchable layouts. Supports single and multi-select '
                  'with bulk action toolbars. Used across many mini-apps.',
                  color: colors.textSubtle,
                ),
              ),
            ],
          ),

          // ── OiKanban ──────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Kanban',
            widgetName: 'OiKanban',
            description:
                'A kanban board with drag-and-drop columns and cards. '
                'Supports swimlanes, WIP limits, and card customization.',
            examples: [
              ComponentExample(
                title: 'Full-Feature Module',
                child: OiLabel.body(
                  'OiKanban renders a multi-column board where cards can '
                  'be dragged between columns. Supports column '
                  'reordering, WIP limits, swimlanes, and custom card '
                  'renderers. See the Projects mini-app for a live demo.',
                  color: colors.textSubtle,
                ),
              ),
            ],
          ),

          // ── OiChat ────────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Chat',
            widgetName: 'OiChat',
            description:
                'A full messaging module with channels, reactions, replies, '
                'file attachments, and typing indicators.',
            examples: [
              ComponentExample(
                title: 'Full-Feature Module',
                child: OiLabel.body(
                  'OiChat provides a complete messaging experience with '
                  'channel sidebar, message bubbles, emoji reactions, '
                  'threaded replies, file attachments, and real-time '
                  'typing indicators. See the Chat mini-app for a live '
                  'demo.',
                  color: colors.textSubtle,
                ),
              ),
            ],
          ),

          // ── OiComments ────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Comments',
            widgetName: 'OiComments',
            description:
                'A threaded discussion and comments module with nested '
                'replies, reactions, and moderation tools.',
            examples: [
              ComponentExample(
                title: 'Full-Feature Module',
                child: OiLabel.body(
                  'OiComments renders a threaded comment list with nested '
                  'replies, user avatars, timestamps, reactions, and '
                  'moderation actions (edit, delete, report). Supports '
                  'rich text input and @mentions.',
                  color: colors.textSubtle,
                ),
              ),
            ],
          ),

          // ── OiDashboard ───────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Dashboard',
            widgetName: 'OiDashboard',
            description:
                'A dashboard module with configurable widget cards, '
                'drag-and-drop layout, and responsive grid.',
            examples: [
              ComponentExample(
                title: 'Full-Feature Module',
                child: OiLabel.body(
                  'OiDashboard arranges widget cards in a responsive grid '
                  'with drag-and-drop repositioning. Cards can display '
                  'charts, stats, tables, or custom content. See the '
                  'Admin mini-app for a live demo.',
                  color: colors.textSubtle,
                ),
              ),
            ],
          ),

          // ── OiFileExplorer ────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'File Explorer',
            widgetName: 'OiFileExplorer',
            description:
                'A file browser module with folder tree, grid/list views, '
                'breadcrumb navigation, and file preview.',
            examples: [
              ComponentExample(
                title: 'Full-Feature Module',
                child: OiLabel.body(
                  'OiFileExplorer combines folder tree sidebar, path bar, '
                  'file grid/list views, toolbar, and preview panel into '
                  'a complete file browsing experience. See the Files '
                  'mini-app for a live demo.',
                  color: colors.textSubtle,
                ),
              ),
            ],
          ),

          // ── OiFileManager ─────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'File Manager',
            widgetName: 'OiFileManager',
            description:
                'A file management module with upload, move, copy, delete, '
                'rename, and drag-and-drop operations.',
            examples: [
              ComponentExample(
                title: 'Full-Feature Module',
                child: OiLabel.body(
                  'OiFileManager provides full CRUD file operations with '
                  'upload progress, batch operations, conflict resolution, '
                  'and undo support. Works alongside OiFileExplorer for '
                  'the complete file management experience.',
                  color: colors.textSubtle,
                ),
              ),
            ],
          ),

          // ── OiCheckout ────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Checkout',
            widgetName: 'OiCheckout',
            description:
                'An e-commerce checkout flow with cart review, address, '
                'shipping, payment, and confirmation steps.',
            examples: [
              ComponentExample(
                title: 'Full-Feature Module',
                child: OiLabel.body(
                  'OiCheckout orchestrates a multi-step checkout flow: '
                  'cart review, shipping address, shipping method, '
                  'payment method, and order confirmation. Each step '
                  'validates before proceeding. See the Shop mini-app '
                  'for a live demo.',
                  color: colors.textSubtle,
                ),
              ),
            ],
          ),

          // ── OiAuthPage ────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Auth Page',
            widgetName: 'OiAuthPage',
            description:
                'Authentication screens for login, registration, password '
                'reset, and email verification.',
            examples: [
              ComponentExample(
                title: 'Full-Feature Module',
                child: OiLabel.body(
                  'OiAuthPage provides pre-built authentication screens '
                  'with form validation, social login buttons, password '
                  'strength indicators, and error handling. Supports '
                  'login, register, forgot password, and email '
                  'verification flows. See the Auth mini-app for a '
                  'live demo.',
                  color: colors.textSubtle,
                ),
              ),
            ],
          ),

          // ── OiActivityFeed ────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Activity Feed',
            widgetName: 'OiActivityFeed',
            description:
                'An activity log timeline showing user actions, system '
                'events, and status changes.',
            examples: [
              ComponentExample(
                title: 'Full-Feature Module',
                child: OiLabel.body(
                  'OiActivityFeed renders a chronological timeline of '
                  'events with user avatars, timestamps, action '
                  'descriptions, and grouping by date. Supports filtering '
                  'by event type and infinite scroll loading.',
                  color: colors.textSubtle,
                ),
              ),
            ],
          ),

          // ── OiNotificationCenter ──────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Notification Center',
            widgetName: 'OiNotificationCenter',
            description:
                'A notification management module with categories, '
                'read/unread state, and bulk actions.',
            examples: [
              ComponentExample(
                title: 'Full-Feature Module',
                child: OiLabel.body(
                  'OiNotificationCenter displays a categorized list of '
                  'notifications with read/unread indicators, timestamps, '
                  'action buttons, and bulk mark-as-read/dismiss. '
                  'Supports real-time notification delivery.',
                  color: colors.textSubtle,
                ),
              ),
            ],
          ),

          // ── OiPermissions ─────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Permissions',
            widgetName: 'OiPermissions',
            description:
                'A role-based permissions UI for managing user roles, '
                'permissions, and access control.',
            examples: [
              ComponentExample(
                title: 'Full-Feature Module',
                child: OiLabel.body(
                  'OiPermissions provides a matrix-style UI for assigning '
                  'permissions to roles. Supports role creation, '
                  'permission grouping, inheritance visualization, and '
                  'bulk permission toggling.',
                  color: colors.textSubtle,
                ),
              ),
            ],
          ),

          // ── OiResourcePage ────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Resource Page',
            widgetName: 'OiResourcePage',
            description:
                'A generic resource detail and edit page with form '
                'sections, metadata sidebar, and action bar.',
            examples: [
              ComponentExample(
                title: 'Full-Feature Module',
                child: OiLabel.body(
                  'OiResourcePage provides a standardized layout for '
                  'viewing and editing any resource type. Includes form '
                  'sections, a metadata sidebar, revision history, and '
                  'save/publish/delete actions.',
                  color: colors.textSubtle,
                ),
              ),
            ],
          ),

          // ── OiMetadataEditor ──────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Metadata Editor',
            widgetName: 'OiMetadataEditor',
            description:
                'A metadata editing panel for managing key-value pairs, '
                'tags, categories, and custom fields.',
            examples: [
              ComponentExample(
                title: 'Full-Feature Module',
                child: OiLabel.body(
                  'OiMetadataEditor provides a sidebar panel for editing '
                  'resource metadata including key-value pairs, tags, '
                  'categories, SEO fields, and custom attributes. '
                  'Supports validation and auto-save.',
                  color: colors.textSubtle,
                ),
              ),
            ],
          ),

          // ── OiShopProductDetail ───────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Shop Product Detail',
            widgetName: 'OiShopProductDetail',
            description:
                'A product detail page with gallery, description, variant '
                'selection, reviews, and add-to-cart.',
            examples: [
              ComponentExample(
                title: 'Full-Feature Module',
                child: OiLabel.body(
                  'OiShopProductDetail combines product gallery, '
                  'description, variant picker, price display, stock '
                  'badge, reviews section, and add-to-cart into a '
                  'complete product detail page. See the Shop mini-app '
                  'for a live demo.',
                  color: colors.textSubtle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
