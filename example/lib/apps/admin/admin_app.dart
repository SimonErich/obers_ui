import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/apps/admin/screens/admin_activity_screen.dart';
import 'package:obers_ui_example/apps/admin/screens/admin_notifications_screen.dart';
import 'package:obers_ui_example/apps/admin/screens/admin_orders_screen.dart';
import 'package:obers_ui_example/apps/admin/screens/admin_overview_screen.dart';
import 'package:obers_ui_example/apps/admin/screens/admin_permissions_screen.dart';
import 'package:obers_ui_example/apps/admin/screens/admin_returns_screen.dart';
import 'package:obers_ui_example/apps/admin/screens/admin_settings_screen.dart';
import 'package:obers_ui_example/apps/admin/screens/admin_users_screen.dart';
import 'package:obers_ui_example/data/mock_dashboard.dart';
import 'package:obers_ui_example/data/mock_users.dart';
import 'package:obers_ui_example/theme/theme_state.dart';

/// Admin mini-app showcasing OiAppShell with nested navigation, OiUserMenu,
/// OiBreadcrumbs, OiCommandBar, OiDashboard, OiTable, OiPermissions,
/// OiResourcePage, OiPipeline, OiForm, OiActivityFeed, OiNotificationCenter,
/// and many more widgets.
class AdminApp extends StatefulWidget {
  const AdminApp({required this.themeState, super.key});

  final ThemeState themeState;

  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> {
  String _currentRoute = 'overview';
  bool _showCommandBar = false;

  // ── Route → screen mapping ──────────────────────────────────────────────

  Widget _buildScreen() {
    switch (_currentRoute) {
      case 'users':
        return const AdminUsersScreen();
      case 'permissions':
        return const AdminPermissionsScreen();
      case 'orders':
        return const AdminOrdersScreen();
      case 'returns':
        return const AdminReturnsScreen();
      case 'settings':
        return const AdminSettingsScreen();
      case 'activity':
        return const AdminActivityScreen();
      case 'notifications':
        return const AdminNotificationsScreen();
      case 'overview':
      default:
        return const AdminOverviewScreen();
    }
  }

  // ── Breadcrumbs ─────────────────────────────────────────────────────────

  List<OiBreadcrumbItem> _buildBreadcrumbs() {
    final crumbs = <OiBreadcrumbItem>[
      OiBreadcrumbItem(
        label: 'Admin',
        onTap: () => setState(() => _currentRoute = 'overview'),
      ),
    ];

    switch (_currentRoute) {
      case 'users':
        crumbs.addAll([
          const OiBreadcrumbItem(label: 'Users'),
          const OiBreadcrumbItem(label: 'User List'),
        ]);
      case 'permissions':
        crumbs.addAll([
          const OiBreadcrumbItem(label: 'Users'),
          const OiBreadcrumbItem(label: 'Roles & Permissions'),
        ]);
      case 'orders':
        crumbs.addAll([
          const OiBreadcrumbItem(label: 'Orders'),
          const OiBreadcrumbItem(label: 'All Orders'),
        ]);
      case 'returns':
        crumbs.addAll([
          const OiBreadcrumbItem(label: 'Orders'),
          const OiBreadcrumbItem(label: 'Returns'),
        ]);
      case 'settings':
        crumbs.add(const OiBreadcrumbItem(label: 'Settings'));
      case 'activity':
        crumbs.add(const OiBreadcrumbItem(label: 'Activity Log'));
      case 'notifications':
        crumbs.add(const OiBreadcrumbItem(label: 'Notifications'));
      default:
        crumbs.add(const OiBreadcrumbItem(label: 'Overview'));
    }

    return crumbs;
  }

  // ── Command bar ─────────────────────────────────────────────────────────

  List<OiCommand> _buildCommands() => [
    for (final entry in kAdminCommandEntries)
      OiCommand(
        id: entry.id,
        label: entry.label,
        description: entry.description,
        category: entry.category,
        icon: _commandIcon(entry.id),
        onExecute: () {
          setState(() => _showCommandBar = false);
          _executeCommand(entry.id);
        },
      ),
  ];

  IconData _commandIcon(String id) {
    if (id.startsWith('nav-')) return OiIcons.arrowRight;
    if (id == 'act-export-users' || id == 'act-export-orders') {
      return OiIcons.download;
    }
    if (id == 'act-new-user') return OiIcons.userPlus;
    if (id == 'act-toggle-theme') return OiIcons.sun;
    return OiIcons.terminal;
  }

  void _executeCommand(String id) {
    switch (id) {
      case 'nav-overview':
        setState(() => _currentRoute = 'overview');
      case 'nav-users':
        setState(() => _currentRoute = 'users');
      case 'nav-permissions':
        setState(() => _currentRoute = 'permissions');
      case 'nav-orders':
        setState(() => _currentRoute = 'orders');
      case 'nav-returns':
        setState(() => _currentRoute = 'returns');
      case 'nav-settings':
        setState(() => _currentRoute = 'settings');
      case 'nav-activity':
        setState(() => _currentRoute = 'activity');
      case 'nav-notifications':
        setState(() => _currentRoute = 'notifications');
      case 'act-toggle-theme':
        widget.themeState.toggle();
      default:
        if (mounted) {
          OiToast.show(
            context,
            message: 'Command: $id',
          );
        }
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.keyK, control: true):
            VoidCallbackIntent(_handleCtrlK),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          VoidCallbackIntent: CallbackAction<VoidCallbackIntent>(
            onInvoke: (intent) => intent.callback(),
          ),
        },
        child: Focus(
          autofocus: true,
          child: Stack(
            children: [
              OiAppShell(
                label: 'Admin panel',
                currentRoute: _currentRoute,
                onNavigate: (route) => setState(() => _currentRoute = route),
                breadcrumbs: _buildBreadcrumbs(),
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OiTappable(
                      semanticLabel: 'Go back to showcase',
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(
                        OiIcons.chevronLeft,
                        size: 20,
                        color: colors.text,
                      ),
                    ),
                    const SizedBox(width: 4),
                    OiLabel.h4(
                      'Alpenglueck Admin',
                      color: colors.primary.base,
                    ),
                  ],
                ),
                // Nested navigation: Users and Orders have sub-items.
                navigation: const [
                  OiNavItem(
                    label: 'Overview',
                    icon: OiIcons.barChart3,
                    route: 'overview',
                    section: 'Main',
                  ),
                  OiNavItem(
                    label: 'Users',
                    icon: OiIcons.users,
                    section: 'Main',
                    children: [
                      OiNavItem(
                        label: 'User List',
                        icon: OiIcons.list,
                        route: 'users',
                      ),
                      OiNavItem(
                        label: 'Roles & Permissions',
                        icon: OiIcons.shieldCheck,
                        route: 'permissions',
                      ),
                    ],
                  ),
                  OiNavItem(
                    label: 'Orders',
                    icon: OiIcons.shoppingCart,
                    section: 'Main',
                    children: [
                      OiNavItem(
                        label: 'All Orders',
                        icon: OiIcons.clipboardList,
                        route: 'orders',
                      ),
                      OiNavItem(
                        label: 'Returns',
                        icon: OiIcons.receiptText,
                        route: 'returns',
                      ),
                    ],
                  ),
                  OiNavItem(
                    label: 'Settings',
                    icon: OiIcons.settings,
                    route: 'settings',
                    section: 'System',
                  ),
                  OiNavItem(
                    label: 'Activity',
                    icon: OiIcons.clock,
                    route: 'activity',
                    section: 'System',
                  ),
                  OiNavItem(
                    label: 'Notifications',
                    icon: OiIcons.bell,
                    route: 'notifications',
                    badge: '3',
                    section: 'System',
                  ),
                ],
                userMenu: OiUserMenu(
                  label: 'User menu',
                  userName: kCurrentUser.name,
                  userEmail: kCurrentUser.email,
                  avatarInitials: kCurrentUser.initials,
                  items: [
                    OiMenuItem(
                      label: 'Profile',
                      icon: OiIcons.user,
                      onTap: () =>
                          OiToast.show(context, message: 'Profile clicked'),
                    ),
                    OiMenuItem(
                      label: 'Preferences',
                      icon: OiIcons.slidersHorizontal,
                      onTap: () =>
                          OiToast.show(context, message: 'Preferences clicked'),
                    ),
                    const OiMenuItem(label: '', separator: true),
                    OiMenuItem(
                      label: 'Sign Out',
                      icon: OiIcons.logOut,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                actions: [
                  OiTappable(
                    semanticLabel: 'Open command bar',
                    onTap: () => setState(() => _showCommandBar = true),
                    child: Icon(
                      OiIcons.search,
                      size: 20,
                      color: colors.text,
                    ),
                  ),
                  OiThemeToggle(
                    currentMode: widget.themeState.value,
                    onModeChange: (_) => widget.themeState.toggle(),
                  ),
                ],
                child: _buildScreen(),
              ),
              if (_showCommandBar)
                OiCommandBar(
                  label: 'Admin command bar',
                  commands: _buildCommands(),
                  onDismiss: () => setState(() => _showCommandBar = false),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCtrlK() {
    setState(() => _showCommandBar = !_showCommandBar);
  }
}
