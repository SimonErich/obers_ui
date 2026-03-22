import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/apps/admin/screens/admin_activity_screen.dart';
import 'package:obers_ui_example/apps/admin/screens/admin_notifications_screen.dart';
import 'package:obers_ui_example/apps/admin/screens/admin_overview_screen.dart';
import 'package:obers_ui_example/apps/admin/screens/admin_settings_screen.dart';
import 'package:obers_ui_example/apps/admin/screens/admin_users_screen.dart';
import 'package:obers_ui_example/theme/theme_state.dart';

/// Admin mini-app showcasing OiAppShell, OiDashboard, OiTable, OiForm,
/// OiActivityFeed, and OiNotificationCenter.
class AdminApp extends StatefulWidget {
  const AdminApp({required this.themeState, super.key});

  final ThemeState themeState;

  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> {
  String _currentRoute = 'overview';

  Widget _buildScreen() {
    switch (_currentRoute) {
      case 'users':
        return const AdminUsersScreen();
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return OiAppShell(
      label: 'Admin panel',
      currentRoute: _currentRoute,
      onNavigate: (route) => setState(() => _currentRoute = route),
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: OiLabel.h4('Alpenglueck Admin', color: colors.primary.base),
      ),
      navigation: const [
        OiNavItem(
          label: 'Overview',
          icon: IconData(0xe871, fontFamily: 'MaterialIcons'),
          route: 'overview',
          section: 'Main',
        ),
        OiNavItem(
          label: 'Users',
          icon: IconData(0xe7fb, fontFamily: 'MaterialIcons'),
          route: 'users',
          section: 'Main',
        ),
        OiNavItem(
          label: 'Settings',
          icon: IconData(0xe8b8, fontFamily: 'MaterialIcons'),
          route: 'settings',
          section: 'System',
        ),
        OiNavItem(
          label: 'Activity',
          icon: IconData(0xe192, fontFamily: 'MaterialIcons'),
          route: 'activity',
          section: 'System',
        ),
        OiNavItem(
          label: 'Notifications',
          icon: IconData(0xe7f4, fontFamily: 'MaterialIcons'),
          route: 'notifications',
          badge: '3',
          section: 'System',
        ),
      ],
      actions: [
        OiTappable(
          semanticLabel: 'Go back to showcase',
          onTap: () => Navigator.of(context).pop(),
          child: Icon(
            OiIcons.chevronLeft,
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
    );
  }
}
