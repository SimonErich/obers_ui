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
                child: SizedBox(
                  height: 350,
                  child: OiKanban<String>(
                    label: 'Sprint Board',
                    columns: const [
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
                    ],
                    onCardMove: (_, __, ___, ____) {},
                  ),
                ),
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
                            OiProductVariant(
                              key: 'black',
                              label: 'Black',
                            ),
                            OiProductVariant(
                              key: 'white',
                              label: 'White',
                            ),
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
        ],
      ),
    );
  }
}
