import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_example/apps/component_library/shared/component_showcase_section.dart';

/// Showcase screen listing all full-feature modules with descriptions.
class ModulesScreen extends StatelessWidget {
  const ModulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

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
                'breadcrumbs, and responsive layout. \n\n'
                'OiAppShell is the top-level layout module that provides '
                'sidebar navigation, a header bar with breadcrumbs, and '
                'responsive breakpoint handling. See the Admin and CMS '
                'mini-apps for live demos.',
            examples: [
              ComponentExample(
                title: 'Mini App Shell',
                child: SizedBox(
                  height: 300,
                  child: OiAppShell(
                    label: 'Demo App',
                    navigation: const [
                      OiNavItem(
                        label: 'Dashboard',
                        icon: OiIcons.layoutDashboard,
                        route: '/dashboard',
                        section: 'Main',
                      ),
                      OiNavItem(
                        label: 'Products',
                        icon: OiIcons.shoppingBag,
                        route: '/products',
                      ),
                      OiNavItem(
                        label: 'Orders',
                        icon: OiIcons.clipboardList,
                        route: '/orders',
                      ),
                      OiNavItem(
                        label: 'Settings',
                        icon: OiIcons.settings,
                        route: '/settings',
                        dividerBefore: true,
                        section: 'System',
                      ),
                    ],
                    currentRoute: '/dashboard',
                    onNavigate: (_) {},
                    child: const Center(
                      child: OiLabel.body('Page content goes here'),
                    ),
                  ),
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
                'pagination, and layout switching. \n\n'
                'OiListView provides a complete data listing experience '
                'with column sorting, search filtering, pagination, and '
                'switchable layouts. Supports single and multi-select '
                'with bulk action toolbars. Used across many mini-apps.',
            examples: [
              ComponentExample(
                title: 'Product List',
                child: SizedBox(
                  height: 350,
                  child: OiListView<String>(
                    label: 'Products',
                    items: const [
                      'Wireless Headphones',
                      'USB-C Cable',
                      'Laptop Stand',
                      'Mechanical Keyboard',
                      'Monitor Arm',
                    ],
                    itemKey: (item) => item,
                    itemBuilder: (item) => Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      child: OiLabel.body(item),
                    ),
                    onSearch: (_) {},
                    sortOptions: const [
                      OiListSortOption(id: 'name', label: 'Name'),
                      OiListSortOption(id: 'price', label: 'Price'),
                    ],
                  ),
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
                'Supports swimlanes and WIP limits. \n\n'
                'OiKanban renders a multi-column board where cards can '
                'be dragged between columns. Supports column '
                'reordering, WIP limits, swimlanes, and custom card '
                'renderers. See the Projects mini-app for a live demo.',
            examples: [
              ComponentExample(
                title: 'Task Board',
                child: SizedBox(height: 350, child: const _KanbanDemo()),
              ),
            ],
          ),

          // ── OiChat ────────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Chat',
            widgetName: 'OiChat',
            description:
                'A full messaging module with reactions, replies, '
                'file attachments, and typing indicators. \n\n'
                'OiChat provides a complete messaging experience with '
                'channel sidebar, message bubbles, emoji reactions, '
                'threaded replies, file attachments, and real-time '
                'typing indicators. See the Chat mini-app for a live '
                'demo.',
            examples: [
              ComponentExample(
                title: 'Conversation',
                child: SizedBox(
                  height: 400,
                  child: OiChat(
                    label: 'Team chat',
                    currentUserId: 'user-1',
                    messages: [
                      OiChatMessage(
                        key: 'm1',
                        senderId: 'user-2',
                        senderName: 'Alice',
                        content: 'Hey, how is the sprint going?',
                        timestamp: DateTime(2026, 3, 23, 9, 15),
                      ),
                      OiChatMessage(
                        key: 'm2',
                        senderId: 'user-1',
                        senderName: 'You',
                        content: 'Good! I just finished the auth module.',
                        timestamp: DateTime(2026, 3, 23, 9, 17),
                      ),
                      OiChatMessage(
                        key: 'm3',
                        senderId: 'user-2',
                        senderName: 'Alice',
                        content: 'Nice work! Ready for code review?',
                        timestamp: DateTime(2026, 3, 23, 9, 18),
                      ),
                    ],
                    onSend: (_) {},
                  ),
                ),
              ),
            ],
          ),

          // ── OiComments ────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Comments',
            widgetName: 'OiComments',
            description:
                'A threaded discussion module with nested replies, '
                'reactions, and moderation tools. \n\n'
                'OiComments renders a threaded comment list with nested '
                'replies, user avatars, timestamps, reactions, and '
                'moderation actions (edit, delete, report). Supports '
                'rich text input and @mentions.',
            examples: [
              ComponentExample(
                title: 'Discussion Thread',
                child: SizedBox(
                  height: 400,
                  child: OiComments(
                    label: 'Comments',
                    currentUserId: 'user-1',
                    comments: [
                      OiComment(
                        key: 'c1',
                        authorId: 'user-2',
                        authorName: 'Alice',
                        content:
                            'This looks great! One small suggestion '
                            'on the layout.',
                        timestamp: DateTime(2026, 3, 22, 14, 30),
                        replies: [
                          OiComment(
                            key: 'c1-r1',
                            authorId: 'user-1',
                            authorName: 'You',
                            content: 'Thanks! What did you have in mind?',
                            timestamp: DateTime(2026, 3, 22, 15),
                          ),
                        ],
                      ),
                      OiComment(
                        key: 'c2',
                        authorId: 'user-3',
                        authorName: 'Bob',
                        content: 'Approved — ship it!',
                        timestamp: DateTime(2026, 3, 23, 9),
                      ),
                    ],
                    onComment: (_) {},
                  ),
                ),
              ),
            ],
          ),

          // ── OiDashboard ───────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Dashboard',
            widgetName: 'OiDashboard',
            description:
                'A dashboard module with configurable widget cards '
                'and responsive grid layout. \n\n'
                'OiDashboard arranges widget cards in a responsive grid '
                'with drag-and-drop repositioning. Cards can display '
                'charts, stats, tables, or custom content. See the '
                'Admin mini-app for a live demo.',
            examples: [
              ComponentExample(
                title: 'Analytics Dashboard',
                child: SizedBox(
                  height: 350,
                  child: OiDashboard(
                    label: 'Dashboard',
                    columns: 2,
                    cards: [
                      OiDashboardCard(
                        key: 'd1',
                        title: 'Total Revenue',
                        child: Center(
                          child: OiMetric(label: 'Revenue', value: r'$24,500'),
                        ),
                      ),
                      OiDashboardCard(
                        key: 'd2',
                        title: 'Orders',
                        child: Center(
                          child: OiMetric(label: 'Orders', value: '142'),
                        ),
                      ),
                      OiDashboardCard(
                        key: 'd3',
                        title: 'Conversion Rate',
                        child: Center(
                          child: OiMetric(label: 'Conversion', value: '3.2%'),
                        ),
                      ),
                      OiDashboardCard(
                        key: 'd4',
                        title: 'Active Users',
                        child: Center(
                          child: OiMetric(label: 'Users', value: '1,024'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── OiFileManager ─────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'File Manager',
            widgetName: 'OiFileManager',
            description:
                'A file management module with grid/list views, upload, '
                'and drag-and-drop operations. \n\n'
                'OiFileManager provides full CRUD file operations with '
                'upload progress, batch operations, conflict resolution, '
                'and undo support. Works alongside OiFileExplorer for '
                'the complete file management experience.',
            examples: [
              ComponentExample(
                title: 'File Browser',
                child: SizedBox(
                  height: 350,
                  child: OiFileManager(
                    label: 'Files',
                    items: [
                      const OiFileNode(
                        key: 'f1',
                        name: 'Documents',
                        folder: true,
                      ),
                      const OiFileNode(key: 'f2', name: 'Photos', folder: true),
                      OiFileNode(
                        key: 'f3',
                        name: 'report.pdf',
                        folder: false,
                        size: 2457600,
                        modified: DateTime(2026, 3, 23),
                      ),
                      OiFileNode(
                        key: 'f4',
                        name: 'presentation.pptx',
                        folder: false,
                        size: 5242880,
                        modified: DateTime(2026, 3, 21),
                      ),
                    ],
                    currentPath: const ['Home', 'Documents'],
                  ),
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
                'shipping, payment, and confirmation steps. \n\n'
                'OiCheckout orchestrates a multi-step checkout flow: '
                'cart review, shipping address, shipping method, '
                'payment method, and order confirmation. Each step '
                'validates before proceeding. See the Shop mini-app '
                'for a live demo.',
            examples: [
              ComponentExample(
                title: 'Checkout Flow',
                child: SizedBox(
                  height: 700,
                  child: SingleChildScrollView(
                    child: OiCheckout(
                      label: 'Checkout',
                      items: const [
                        OiCartItem(
                          productKey: 'p1',
                          name: 'Wireless Headphones',
                          unitPrice: 79.99,
                        ),
                        OiCartItem(
                          productKey: 'p2',
                          name: 'USB-C Cable',
                          unitPrice: 12.99,
                          quantity: 2,
                        ),
                      ],
                      summary: const OiCartSummary(
                        subtotal: 105.97,
                        shipping: 5.99,
                        tax: 8.48,
                        total: 120.44,
                      ),
                      onPlaceOrder: (checkout) async => OiOrderData(
                        key: 'order-1',
                        orderNumber: 'ORD-2026-001',
                        createdAt: DateTime(2026, 3, 23),
                        status: OiOrderStatus.confirmed,
                        items: const [
                          OiCartItem(
                            productKey: 'p1',
                            name: 'Wireless Headphones',
                            unitPrice: 79.99,
                          ),
                          OiCartItem(
                            productKey: 'p2',
                            name: 'USB-C Cable',
                            unitPrice: 12.99,
                            quantity: 2,
                          ),
                        ],
                        summary: const OiCartSummary(
                          subtotal: 105.97,
                          shipping: 5.99,
                          tax: 8.48,
                          total: 120.44,
                        ),
                        shippingAddress: checkout.shippingAddress,
                        paymentMethod: checkout.paymentMethod,
                        shippingMethod: checkout.shippingMethod,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── OiAuthPage ────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Auth Page',
            widgetName: 'OiAuthPage',
            description:
                'Authentication screens for login, registration, '
                'and password reset. \n\n'
                'OiAuthPage provides pre-built authentication screens '
                'with form validation, social login buttons, password '
                'strength indicators, and error handling. Supports '
                'login, register, forgot password, and email '
                'verification flows. See the Auth mini-app for a '
                'live demo.',
            examples: [
              ComponentExample(
                title: 'Login Form',
                child: SizedBox(
                  height: 400,
                  child: OiAuthPage(
                    label: 'Authentication',
                    onLogin: (_, __) async => false,
                    onRegister: (_, __, ___) async => false,
                  ),
                ),
              ),
            ],
          ),

          // ── OiActivityFeed ────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Activity Feed',
            widgetName: 'OiActivityFeed',
            description:
                'An activity log timeline showing user actions '
                'and system events. \n\n'
                'OiActivityFeed renders a chronological timeline of '
                'events with user avatars, timestamps, action '
                'descriptions, and grouping by date. Supports filtering '
                'by event type and infinite scroll loading.',
            examples: [
              ComponentExample(
                title: 'Recent Activity',
                child: SizedBox(
                  height: 300,
                  child: OiActivityFeed(
                    label: 'Activity',
                    events: [
                      OiActivityEvent(
                        key: 'a1',
                        title: 'Alice merged PR #42',
                        description: 'feat: add auth module',
                        timestamp: DateTime(2026, 3, 23, 10, 30),
                        icon: OiIcons.gitMerge,
                      ),
                      OiActivityEvent(
                        key: 'a2',
                        title: 'Bob deployed v2.1.0',
                        description: 'Production deployment',
                        timestamp: DateTime(2026, 3, 23, 11),
                        icon: OiIcons.rocket,
                      ),
                      OiActivityEvent(
                        key: 'a3',
                        title: 'System backup completed',
                        timestamp: DateTime(2026, 3, 23, 12),
                        icon: OiIcons.database,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── OiNotificationCenter ──────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Notification Center',
            widgetName: 'OiNotificationCenter',
            description:
                'A notification management module with categories '
                'and read/unread state. \n\n'
                'OiNotificationCenter displays a categorized list of '
                'notifications with read/unread indicators, timestamps, '
                'action buttons, and bulk mark-as-read/dismiss. '
                'Supports real-time notification delivery.',
            examples: [
              ComponentExample(
                title: 'Notifications',
                child: SizedBox(
                  height: 300,
                  child: OiNotificationCenter(
                    label: 'Notifications',
                    unreadCount: 2,
                    notifications: [
                      OiNotification(
                        key: 'n1',
                        title: 'New comment on your PR',
                        body: 'Alice left a review comment.',
                        timestamp: DateTime(2026, 3, 23, 9),
                        icon: OiIcons.messageSquare,
                      ),
                      OiNotification(
                        key: 'n2',
                        title: 'Deploy succeeded',
                        body: 'v2.1.0 is now live.',
                        timestamp: DateTime(2026, 3, 23, 11),
                        icon: OiIcons.circleCheck,
                        read: true,
                      ),
                      OiNotification(
                        key: 'n3',
                        title: 'Sprint review in 30 min',
                        timestamp: DateTime(2026, 3, 23, 13, 30),
                        icon: OiIcons.clock,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── OiPermissions ─────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Permissions',
            widgetName: 'OiPermissions',
            description:
                'A role-based permissions matrix for managing '
                'access control. \n\n'
                'OiPermissions provides a matrix-style UI for assigning '
                'permissions to roles. Supports role creation, '
                'permission grouping, inheritance visualization, and '
                'bulk permission toggling.',
            examples: [
              ComponentExample(
                title: 'Permission Matrix',
                child: OiPermissions(
                  label: 'Permissions',
                  permissions: const [
                    OiPermissionItem(
                      key: 'read',
                      label: 'Read',
                      description: 'View resources',
                    ),
                    OiPermissionItem(
                      key: 'write',
                      label: 'Write',
                      description: 'Create and edit',
                    ),
                    OiPermissionItem(
                      key: 'delete',
                      label: 'Delete',
                      description: 'Remove resources',
                    ),
                    OiPermissionItem(
                      key: 'admin',
                      label: 'Admin',
                      description: 'Full access',
                    ),
                  ],
                  roles: const [
                    OiRole(key: 'viewer', label: 'Viewer'),
                    OiRole(key: 'editor', label: 'Editor'),
                    OiRole(key: 'admin', label: 'Admin'),
                  ],
                  matrix: const {
                    'viewer': {'read'},
                    'editor': {'read', 'write'},
                    'admin': {'read', 'write', 'delete', 'admin'},
                  },
                  onChange: (_) {},
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
                'sections and action bar. \n\n'
                'OiResourcePage provides a standardized layout for '
                'viewing and editing any resource type. Includes form '
                'sections, a metadata sidebar, revision history, and '
                'save/publish/delete actions.',
            examples: [
              ComponentExample(
                title: 'Resource Detail',
                child: SizedBox(
                  height: 300,
                  child: OiResourcePage(
                    label: 'Product Detail',
                    title: 'Wireless Headphones',
                    breadcrumbs: [
                      OiBreadcrumbItem(label: 'Products', onTap: () {}),
                      const OiBreadcrumbItem(label: 'Wireless Headphones'),
                    ],
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: OiLabel.body(
                        'Resource content, forms, and metadata '
                        'would appear here.',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── OiMetadataEditor ──────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Metadata Editor',
            widgetName: 'OiMetadataEditor',
            description:
                'A metadata editing panel for managing key-value pairs '
                'and custom fields. \n\n'
                'OiMetadataEditor provides a sidebar panel for editing '
                'resource metadata including key-value pairs, tags, '
                'categories, SEO fields, and custom attributes. '
                'Supports validation and auto-save.',
            examples: [
              ComponentExample(
                title: 'Product Metadata',
                child: OiMetadataEditor(
                  label: 'Metadata',
                  fields: const [
                    OiMetadataField(key: 'SKU', value: 'WH-2026-BLK'),
                    OiMetadataField(key: 'Weight', value: '250g'),
                    OiMetadataField(
                      key: 'In Stock',
                      value: true,
                      type: OiMetadataType.boolean,
                    ),
                    OiMetadataField(
                      key: 'Price',
                      value: 79.99,
                      type: OiMetadataType.number,
                    ),
                  ],
                  onChange: (_) {},
                ),
              ),
            ],
          ),

          // ── OiShopProductDetail ───────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Shop Product Detail',
            widgetName: 'OiShopProductDetail',
            description:
                'A product detail page with gallery, variant selection, '
                'reviews, and add-to-cart. \n\n'
                'OiShopProductDetail combines product gallery, '
                'description, variant picker, price display, stock '
                'badge, reviews section, and add-to-cart into a '
                'complete product detail page. See the Shop mini-app '
                'for a live demo.',
            examples: [
              ComponentExample(
                title: 'Product Page',
                child: SizedBox(
                  height: 700,
                  child: SingleChildScrollView(
                    child: Center(
                      child: OiShopProductDetail(
                        label: 'Product detail',
                        product: const OiProductData(
                          key: 'prod-1',
                          name: 'Wireless Headphones Pro',
                          price: 79.99,
                          compareAtPrice: 99.99,
                          description:
                              'Premium noise-cancelling wireless headphones '
                              'with 30-hour battery life and Hi-Res audio.',
                          rating: 4.5,
                          reviewCount: 128,
                          stockCount: 45,
                          variants: [
                            OiProductVariant(key: 'black', label: 'Black'),
                            OiProductVariant(key: 'white', label: 'White'),
                            OiProductVariant(
                              key: 'blue',
                              label: 'Navy Blue',
                              inStock: false,
                            ),
                          ],
                        ),
                        onAddToCart: (_) {},
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── OiFileExplorer ──────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'File Explorer',
            widgetName: 'OiFileExplorer',
            description:
                'A complete file browser module with sidebar folder tree, '
                'toolbar, path bar, search, view mode toggle (grid/list), '
                'sort, context menus, keyboard shortcuts, drag-and-drop, '
                'file previews, and settings persistence. See the Files '
                'mini-app for a live demo.',
            examples: [
              ComponentExample(
                title: 'Basic file explorer',
                child: SizedBox(
                  height: 400,
                  child: OiFileExplorer(
                    controller: OiFileExplorerController(),
                    label: 'File browser',
                    loadFolder: (_) async => [],
                    loadFolderTree: (_) async => [],
                    onCreateFolder: (_, name) async =>
                        OiFileNodeData(id: name, name: name, folder: true),
                    onRename: (_, __) async {},
                    onDelete: (_) async {},
                    onMove: (_, __) async {},
                    onUpload: (_, __) async {},
                  ),
                ),
              ),
            ],
          ),

          // ── OiChatWindow ────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Chat Window (LLM)',
            widgetName: 'OiChatWindow',
            description:
                'An LLM-focused chat interface with streaming support, '
                'suggestion chips, and provider selection. Different from '
                'OiChat (social messaging) — OiChatWindow is purpose-built '
                'for AI assistant interactions.',
            examples: [
              ComponentExample(
                title: 'AI Assistant',
                child: SizedBox(
                  height: 400,
                  child: OiChatWindow(
                    label: 'AI Assistant',
                    messages: [
                      OiChatWindowMessage(
                        id: '1',
                        role: 'user',
                        content: 'Help me design a login screen',
                        timestamp: DateTime(2026, 3, 28, 10, 30),
                      ),
                      OiChatWindowMessage(
                        id: '2',
                        role: 'assistant',
                        content:
                            'Here are some suggestions for your login '
                            'screen:\n\n1. **Centered card layout** with '
                            'logo\n2. **Email + password** fields\n'
                            '3. Social login buttons below',
                        timestamp: DateTime(2026, 3, 28, 10, 31),
                        suggestions: const [
                          OiChatSuggestion(id: 's1', text: 'Add social login'),
                          OiChatSuggestion(
                            id: 's2',
                            text: 'Add forgot password',
                          ),
                        ],
                      ),
                    ],
                    onSendMessage: (_) {},
                  ),
                ),
              ),
            ],
          ),

          // ── OiChangelogView ─────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Changelog View',
            widgetName: 'OiChangelogView',
            description:
                'A versioned changelog viewer with expandable releases, '
                'change-type filters (added, changed, fixed, removed, '
                'security, deprecated), and search.',
            examples: [
              ComponentExample(
                title: 'Release notes',
                child: SizedBox(
                  height: 400,
                  child: OiChangelogView(
                    label: 'Release notes',
                    versions: [
                      OiVersionEntry(
                        version: '2.1.0',
                        isLatest: true,
                        date: DateTime(2026, 3, 28),
                        changes: const [
                          OiChangeEntry(
                            description: 'Added dark mode support',
                            type: OiChangeType.added,
                          ),
                          OiChangeEntry(
                            description: 'Improved chart rendering',
                            type: OiChangeType.changed,
                          ),
                          OiChangeEntry(
                            description: 'Fixed date picker timezone bug',
                            type: OiChangeType.fixed,
                          ),
                        ],
                      ),
                      OiVersionEntry(
                        version: '2.0.0',
                        date: DateTime(2026, 2, 15),
                        changes: const [
                          OiChangeEntry(
                            description: 'New component architecture',
                            type: OiChangeType.added,
                          ),
                          OiChangeEntry(
                            description: 'Removed legacy theme API',
                            type: OiChangeType.removed,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── OiConsentBanner ─────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Consent Banner',
            widgetName: 'OiConsentBanner',
            description:
                'A GDPR-style cookie consent banner with accept/reject '
                'all, manage preferences, and per-category toggles. '
                'Supports top or bottom positioning.',
            examples: [
              ComponentExample(
                title: 'Cookie consent',
                child: OiConsentBanner(
                  label: 'Cookie consent',
                  categories: const [
                    OiConsentCategory(
                      key: 'essential',
                      name: 'Essential',
                      description: 'Required for the site to function',
                      required: true,
                    ),
                    OiConsentCategory(
                      key: 'analytics',
                      name: 'Analytics',
                      description: 'Helps us understand how you use the site',
                    ),
                    OiConsentCategory(
                      key: 'marketing',
                      name: 'Marketing',
                      description: 'Used for targeted advertising',
                    ),
                  ],
                  onAcceptAll: () {},
                  onRejectAll: () {},
                  onSavePreferences: (_) {},
                ),
              ),
            ],
          ),

          // ── OiDevMenu ───────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Dev Menu',
            widgetName: 'OiDevMenu',
            description:
                'A developer/debug menu with environment switching, '
                'feature flags, quick actions, and log viewer. Use '
                'OiDevMenu.trigger() to add a hidden triple-tap '
                'activation.',
            examples: [
              ComponentExample(
                title: 'Debug panel',
                child: SizedBox(
                  height: 400,
                  child: OiDevMenu(
                    label: 'Dev menu',
                    environments: const [
                      OiDevEnvironment(
                        key: 'dev',
                        label: 'Development',
                        url: 'http://localhost:3000',
                      ),
                      OiDevEnvironment(
                        key: 'staging',
                        label: 'Staging',
                        url: 'https://staging.example.com',
                      ),
                      OiDevEnvironment(
                        key: 'prod',
                        label: 'Production',
                        url: 'https://example.com',
                      ),
                    ],
                    currentEnvironment: 'dev',
                    onEnvironmentChange: (_) {},
                    featureFlags: const [
                      OiFeatureFlag(
                        key: 'dark_mode',
                        label: 'Dark Mode',
                        description: 'Enable dark theme',
                      ),
                      OiFeatureFlag(
                        key: 'new_dashboard',
                        label: 'New Dashboard',
                        description: 'Use redesigned dashboard',
                      ),
                    ],
                    featureFlagValues: const {
                      'dark_mode': true,
                      'new_dashboard': false,
                    },
                    onFeatureFlagChange: (_, {required value}) {},
                    actions: [
                      OiDevAction(
                        label: 'Clear cache',
                        icon: OiIcons.trash,
                        onTap: () {},
                      ),
                      OiDevAction(
                        label: 'Reset onboarding',
                        icon: OiIcons.refreshCw,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── OiDrawerNavigation ──────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Drawer Navigation',
            widgetName: 'OiDrawerNavigation',
            description:
                'A structured mobile-first drawer with header (avatar, '
                'name), grouped navigation sections, nested items, '
                'badges, and toggles.',
            examples: [
              ComponentExample(
                title: 'App drawer',
                child: SizedBox(
                  height: 400,
                  width: 300,
                  child: OiDrawerNavigation(
                    label: 'Navigation',
                    header: const OiDrawerHeader(
                      name: 'Jane Doe',
                      subtitle: 'jane@example.com',
                    ),
                    selectedKey: 'home',
                    onItemTap: (_) {},
                    sections: const [
                      OiDrawerSection(
                        items: [
                          OiDrawerItem(
                            key: 'home',
                            label: 'Home',
                            icon: OiIcons.house,
                          ),
                          OiDrawerItem(
                            key: 'projects',
                            label: 'Projects',
                            icon: OiIcons.folder,
                            badge: '3',
                          ),
                          OiDrawerItem(
                            key: 'messages',
                            label: 'Messages',
                            icon: OiIcons.messageSquare,
                          ),
                        ],
                      ),
                      OiDrawerSection(
                        title: 'Settings',
                        items: [
                          OiDrawerItem(
                            key: 'account',
                            label: 'Account',
                            icon: OiIcons.user,
                          ),
                          OiDrawerItem(
                            key: 'prefs',
                            label: 'Preferences',
                            icon: OiIcons.settings,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── OiFeedbackSheet ─────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Feedback Sheet',
            widgetName: 'OiFeedbackSheet',
            description:
                'A user-feedback form with category selection, '
                'rating (stars or sentiment), message input, and '
                'optional email. Shows a thank-you state on submit.',
            examples: [
              ComponentExample(
                title: 'Bug report',
                child: SizedBox(
                  height: 400,
                  child: OiFeedbackSheet(
                    label: 'Send feedback',
                    onSubmit: (_) async => true,
                  ),
                ),
              ),
            ],
          ),

          // ── OiHelpCenter ────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Help Center',
            widgetName: 'OiHelpCenter',
            description:
                'A tabbed help center with FAQ, knowledge base articles, '
                'contact form, and feedback collection. Searchable across '
                'all sections.',
            examples: [
              ComponentExample(
                title: 'Support center',
                child: SizedBox(
                  height: 450,
                  child: OiHelpCenter(
                    label: 'Help',
                    faq: const [
                      OiFaqItem(
                        question: 'How do I reset my password?',
                        answer: 'Go to Settings > Account > Reset Password.',
                      ),
                      OiFaqItem(
                        question: 'How do I export my data?',
                        answer:
                            'Navigate to Settings > Data > Export and '
                            'choose your preferred format.',
                      ),
                      OiFaqItem(
                        question: 'What payment methods are accepted?',
                        answer: 'We accept Visa, Mastercard, and PayPal.',
                      ),
                    ],
                    onContactSubmit:
                        ({required subject, required message, email}) async =>
                            true,
                  ),
                ),
              ),
            ],
          ),

          // ── OiMaintenancePage ───────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Maintenance Page',
            widgetName: 'OiMaintenancePage',
            description:
                'A full-page maintenance/error screen. Includes factory '
                'constructors for common scenarios: .maintenance(), '
                '.notFound(), .serverError(), .offline(). Supports '
                'countdown timer, retry button, and social links.',
            examples: [
              ComponentExample(
                title: 'Scheduled maintenance',
                child: SizedBox(
                  height: 350,
                  child: OiMaintenancePage.maintenance(
                    estimatedReturn: DateTime.now().add(
                      const Duration(hours: 2),
                    ),
                  ),
                ),
              ),
              ComponentExample(
                title: '404 Not Found',
                child: SizedBox(
                  height: 300,
                  child: OiMaintenancePage.notFound(onRetry: () {}),
                ),
              ),
            ],
          ),

          // ── OiMediaPicker ───────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Media Picker',
            widgetName: 'OiMediaPicker',
            description:
                'A media selection module with gallery grid, file upload, '
                'type filtering, multi-select, and upload progress. '
                'Supports image, video, and document types.',
            examples: [
              ComponentExample(
                title: 'Image gallery',
                child: SizedBox(
                  height: 350,
                  child: OiMediaPicker(
                    label: 'Select images',
                    galleryItems: const [
                      OiMediaItem(key: '1', name: 'Photo 1.jpg'),
                      OiMediaItem(key: '2', name: 'Photo 2.jpg'),
                      OiMediaItem(key: '3', name: 'Banner.png'),
                      OiMediaItem(key: '4', name: 'Icon.svg'),
                    ],
                    onSelect: (_) {},
                  ),
                ),
              ),
            ],
          ),

          // ── OiOnboardingFlow ────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Onboarding Flow',
            widgetName: 'OiOnboardingFlow',
            description:
                'A multi-step onboarding experience with page indicator, '
                'skip button, and completion callback. Each page has a '
                'title, description, and optional illustration.',
            examples: [
              ComponentExample(
                title: 'Welcome flow',
                child: SizedBox(
                  height: 400,
                  child: OiOnboardingFlow(
                    label: 'Getting started',
                    onComplete: () {},
                    pages: const [
                      OiOnboardingPage(
                        title: 'Welcome',
                        description:
                            'Discover everything our platform has to offer.',
                      ),
                      OiOnboardingPage(
                        title: 'Collaborate',
                        description:
                            'Work together with your team in real-time.',
                      ),
                      OiOnboardingPage(
                        title: 'Get Started',
                        description:
                            "You're all set! Start building amazing things.",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── OiPricingTable ──────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Pricing Table',
            widgetName: 'OiPricingTable',
            description:
                'A responsive pricing comparison table with monthly/yearly '
                'billing toggle, feature matrix, recommended '
                'plan highlighting, and CTA buttons.',
            examples: [
              ComponentExample(
                title: 'SaaS pricing',
                child: SizedBox(
                  height: 450,
                  child: OiPricingTable(
                    label: 'Choose a plan',
                    onPlanSelect: (_, __) {},
                    plans: const [
                      OiPricingPlan(
                        key: 'free',
                        name: 'Free',
                        monthlyPrice: 0,
                        description: 'For individuals',
                      ),
                      OiPricingPlan(
                        key: 'pro',
                        name: 'Pro',
                        monthlyPrice: 29,
                        yearlyPrice: 290,
                        description: 'For teams',
                        recommended: true,
                        ctaLabel: 'Start Trial',
                      ),
                      OiPricingPlan(
                        key: 'enterprise',
                        name: 'Enterprise',
                        monthlyPrice: 99,
                        yearlyPrice: 990,
                        description: 'For organizations',
                        ctaLabel: 'Contact Sales',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── OiProfilePage ───────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Profile Page',
            widgetName: 'OiProfilePage',
            description:
                'A user profile management page with avatar upload, '
                'inline-editable fields, password change, linked '
                'accounts, and danger zone (delete account).',
            examples: [
              ComponentExample(
                title: 'User profile',
                child: SizedBox(
                  height: 450,
                  child: SingleChildScrollView(
                    child: OiProfilePage(
                      label: 'My profile',
                      profile: const OiProfileData(
                        name: 'Jane Doe',
                        email: 'jane@example.com',
                        role: 'Admin',
                        phone: '+1 555-0123',
                        bio: 'Full-stack developer passionate about UI.',
                      ),
                      onFieldSave: (_, __) async => true,
                      onPasswordChange: (_, __) async => true,
                      linkedAccounts: const [
                        OiLinkedAccount(
                          provider: 'google',
                          label: 'Google',
                          connected: true,
                          username: 'jane@gmail.com',
                        ),
                        OiLinkedAccount(provider: 'github', label: 'GitHub'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── OiSearchOverlay ─────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Search Overlay',
            widgetName: 'OiSearchOverlay',
            description:
                'A full-screen search overlay with recent searches, '
                'category filtering, debounced results, and keyboard '
                'navigation. Use as a spotlight-style command palette.',
            examples: [
              ComponentExample(
                title: 'Global search',
                child: SizedBox(
                  height: 450,
                  child: OiSearchOverlay(
                    label: 'Search',
                    categories: const [
                      OiSearchCategory(key: 'all', label: 'All'),
                      OiSearchCategory(key: 'docs', label: 'Docs'),
                      OiSearchCategory(key: 'users', label: 'Users'),
                    ],
                    recentSearches: const ['dashboard', 'settings'],
                    onSearch: (query, _) async {
                      // Simulate network delay.
                      await Future<void>.delayed(
                        const Duration(milliseconds: 600),
                      );
                      return [
                        const OiSearchSuggestion(
                          key: '1',
                          title: 'Dashboard Overview',
                          subtitle: 'Main dashboard page',
                          category: 'Docs',
                        ),
                        const OiSearchSuggestion(
                          key: '2',
                          title: 'User Settings',
                          subtitle: 'Account preferences',
                          category: 'Users',
                        ),
                        const OiSearchSuggestion(
                          key: '3',
                          title: 'Team Management',
                          subtitle: 'Invite and manage team members',
                          category: 'Users',
                        ),
                        const OiSearchSuggestion(
                          key: '4',
                          title: 'Billing & Invoices',
                          subtitle: 'View payment history',
                          category: 'Docs',
                        ),
                        const OiSearchSuggestion(
                          key: '5',
                          title: 'API Documentation',
                          subtitle: 'REST API reference guide',
                          category: 'Docs',
                        ),
                        const OiSearchSuggestion(
                          key: '6',
                          title: 'Notification Preferences',
                          subtitle: 'Configure email and push alerts',
                        ),
                        const OiSearchSuggestion(
                          key: '7',
                          title: 'Security & Privacy',
                          subtitle: 'Two-factor auth, sessions, data export',
                        ),
                        const OiSearchSuggestion(
                          key: '8',
                          title: 'Integrations',
                          subtitle: 'Connect Slack, GitHub, Jira and more',
                          category: 'Docs',
                        ),
                      ];
                    },
                  ),
                ),
              ),
            ],
          ),

          // ── OiSettingsPage ──────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Settings Page',
            widgetName: 'OiSettingsPage',
            description:
                'A structured settings page with grouped sections, '
                'toggle/select/slider/navigation item types, search, '
                'and reset buttons.',
            examples: [
              ComponentExample(
                title: 'App settings',
                child: SizedBox(
                  height: 400,
                  child: OiSettingsPage(
                    label: 'Settings',
                    onSettingChanged: (_, __, ___) {},
                    groups: const [
                      OiSettingsGroup(
                        key: 'appearance',
                        title: 'Appearance',
                        icon: OiIcons.palette,
                        items: [
                          OiSettingsItem(
                            key: 'dark_mode',
                            title: 'Dark Mode',
                            subtitle: 'Use dark color scheme',
                            type: OiSettingsItemType.toggle,
                            value: false,
                          ),
                          OiSettingsItem(
                            key: 'font_size',
                            title: 'Font Size',
                            type: OiSettingsItemType.slider,
                            value: 14.0,
                            min: 10,
                            max: 24,
                          ),
                        ],
                      ),
                      OiSettingsGroup(
                        key: 'notifications',
                        title: 'Notifications',
                        icon: OiIcons.bell,
                        items: [
                          OiSettingsItem(
                            key: 'push',
                            title: 'Push Notifications',
                            type: OiSettingsItemType.toggle,
                            value: true,
                          ),
                          OiSettingsItem(
                            key: 'email_digest',
                            title: 'Email Digest',
                            subtitle: 'How often to receive summaries',
                            type: OiSettingsItemType.select,
                            value: 'weekly',
                            options: ['Daily', 'Weekly', 'Never'],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── OiSubscriptionManager ───────────────────────────────────
          ComponentShowcaseSection(
            title: 'Subscription Manager',
            widgetName: 'OiSubscriptionManager',
            description:
                'A subscription management module showing current plan, '
                'usage quotas, billing history, payment method, and '
                'upgrade/downgrade/cancel actions.',
            examples: [
              ComponentExample(
                title: 'Pro subscription',
                child: SizedBox(
                  height: 450,
                  child: SingleChildScrollView(
                    child: OiSubscriptionManager(
                      label: 'Subscription',
                      currentPlan: OiSubscriptionPlan(
                        key: 'pro',
                        name: 'Pro',
                        price: 29,
                        renewalDate: DateTime(2026, 4, 28),
                        features: const [
                          'Unlimited projects',
                          '50 GB storage',
                          'Priority support',
                        ],
                      ),
                      usage: const [
                        OiUsageQuota(
                          label: 'Storage',
                          used: 32,
                          limit: 50,
                          unit: 'GB',
                        ),
                        OiUsageQuota(label: 'Projects', used: 12, limit: -1),
                      ],
                      invoices: [
                        OiInvoice(
                          key: 'inv-1',
                          date: DateTime(2026, 3),
                          description: 'Pro Plan - March 2026',
                          amount: 29,
                        ),
                        OiInvoice(
                          key: 'inv-2',
                          date: DateTime(2026, 2),
                          description: 'Pro Plan - February 2026',
                          amount: 29,
                        ),
                      ],
                      paymentMethod: const OiPaymentMethodInfo(
                        label: 'Visa ending in 4242',
                        last4: '4242',
                        brand: 'visa',
                      ),
                      onUpgrade: () {},
                      onCancel: () async => true,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KanbanDemo extends StatefulWidget {
  const _KanbanDemo();

  @override
  State<_KanbanDemo> createState() => _KanbanDemoState();
}

class _KanbanDemoState extends State<_KanbanDemo> {
  static const List<OiKanbanColumn<String>> _initialColumns = [
    OiKanbanColumn(
      key: 'todo',
      title: 'To Do',
      items: ['Design homepage', 'Write API docs'],
    ),
    OiKanbanColumn(
      key: 'progress',
      title: 'In Progress',
      items: ['Implement auth', 'Setup CI/CD'],
    ),
    OiKanbanColumn(
      key: 'done',
      title: 'Done',
      items: ['Project setup', 'Database schema'],
    ),
  ];

  late List<OiKanbanColumn<String>> _columns;

  @override
  void initState() {
    super.initState();
    _columns = _initialColumns
        .map(
          (column) => OiKanbanColumn<String>(
            key: column.key,
            title: column.title,
            items: List<String>.from(column.items),
            color: column.color,
          ),
        )
        .toList();
  }

  void _handleCardMove(
    String item,
    Object fromColumn,
    Object toColumn,
    int newIndex,
  ) {
    final nextColumns = _columns
        .map(
          (column) => OiKanbanColumn<String>(
            key: column.key,
            title: column.title,
            items: List<String>.from(column.items),
            color: column.color,
          ),
        )
        .toList();

    final fromIndex = nextColumns.indexWhere(
      (column) => column.key == fromColumn,
    );
    final toIndex = nextColumns.indexWhere((column) => column.key == toColumn);
    if (fromIndex == -1 || toIndex == -1) return;

    final fromItems = nextColumns[fromIndex].items;
    final removeIndex = fromItems.indexOf(item);
    if (removeIndex == -1) return;

    fromItems.removeAt(removeIndex);

    final toItems = nextColumns[toIndex].items;
    var insertIndex = newIndex;
    if (insertIndex < 0) insertIndex = 0;
    if (insertIndex > toItems.length) insertIndex = toItems.length;
    toItems.insert(insertIndex, item);

    setState(() => _columns = nextColumns);
  }

  @override
  Widget build(BuildContext context) {
    return OiKanban<String>(
      label: 'Sprint Board',
      columns: _columns,
      onCardMove: _handleCardMove,
    );
  }
}
