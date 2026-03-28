import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiDrawerNavigationComponent = WidgetbookComponent(
  name: 'OiDrawerNavigation',
  useCases: [
    WidgetbookUseCase(
      name: 'Full',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(width: 300, height: 600, child: _FullDrawerDemo()),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Simple',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            width: 300,
            height: 500,
            child: OiDrawerNavigation(
              label: 'Simple navigation',
              sections: const [
                OiDrawerSection(
                  items: [
                    OiDrawerItem(
                      key: 'home',
                      label: 'Home',
                      icon: OiIcons.house,
                    ),
                    OiDrawerItem(
                      key: 'search',
                      label: 'Search',
                      icon: OiIcons.search,
                    ),
                    OiDrawerItem(
                      key: 'profile',
                      label: 'Profile',
                      icon: OiIcons.user,
                    ),
                  ],
                ),
              ],
              selectedKey: 'home',
              onItemTap: (OiDrawerItem _) {},
            ),
          ),
        );
      },
    ),
  ],
);

class _FullDrawerDemo extends StatefulWidget {
  @override
  State<_FullDrawerDemo> createState() => _FullDrawerDemoState();
}

class _FullDrawerDemoState extends State<_FullDrawerDemo> {
  Object _selectedKey = 'dashboard';
  bool _darkMode = false;
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return OiDrawerNavigation(
      label: 'Main navigation',
      header: const OiDrawerHeader(
        name: 'Jane Doe',
        subtitle: 'jane@example.com',
        avatarUrl: 'https://i.pravatar.cc/150?u=jane',
      ),
      selectedKey: _selectedKey,
      onItemTap: (OiDrawerItem item) => setState(() => _selectedKey = item.key),
      sections: [
        const OiDrawerSection(
          title: 'Main',
          items: [
            OiDrawerItem(
              key: 'dashboard',
              label: 'Dashboard',
              icon: OiIcons.layoutDashboard,
            ),
            OiDrawerItem(
              key: 'inbox',
              label: 'Inbox',
              icon: OiIcons.inbox,
              badge: '12',
            ),
            OiDrawerItem(
              key: 'calendar',
              label: 'Calendar',
              icon: OiIcons.calendar,
            ),
          ],
        ),
        OiDrawerSection(
          title: 'Settings',
          items: const [
            OiDrawerItem(
              key: 'settings',
              label: 'Settings',
              icon: OiIcons.settings,
              children: [
                OiDrawerItem(key: 'general', label: 'General'),
                OiDrawerItem(key: 'security', label: 'Security'),
                OiDrawerItem(key: 'billing', label: 'Billing'),
              ],
            ),
            OiDrawerItem(
              key: 'help',
              label: 'Help & Support',
              icon: OiIcons.circleHelp,
            ),
          ],
          toggles: [
            OiDrawerToggle(
              label: 'Dark Mode',
              value: _darkMode,
              icon: OiIcons.moon,
              onChanged: (bool v) => setState(() => _darkMode = v),
            ),
            OiDrawerToggle(
              label: 'Notifications',
              value: _notifications,
              icon: OiIcons.bell,
              onChanged: (bool v) => setState(() => _notifications = v),
            ),
          ],
        ),
      ],
      footer: const Padding(
        padding: EdgeInsets.all(16),
        child: OiLabel.small('App v2.4.1'),
      ),
    );
  }
}
