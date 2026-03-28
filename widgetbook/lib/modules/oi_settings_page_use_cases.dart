import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

const _generalGroup = OiSettingsGroup(
  key: 'general',
  title: 'General',
  description: 'Core application settings',
  icon: OiIcons.settings,
  items: [
    OiSettingsItem(
      key: 'notifications',
      title: 'Enable Notifications',
      type: OiSettingsItemType.toggle,
      subtitle: 'Receive push notifications for updates',
      value: true,
      searchKeywords: ['alerts', 'push'],
    ),
    OiSettingsItem(
      key: 'auto_save',
      title: 'Auto-save',
      type: OiSettingsItemType.toggle,
      subtitle: 'Automatically save changes',
      value: false,
    ),
    OiSettingsItem(
      key: 'account',
      title: 'Account Settings',
      type: OiSettingsItemType.navigation,
      subtitle: 'Manage your profile and credentials',
      icon: OiIcons.user,
    ),
  ],
);

const _appearanceGroup = OiSettingsGroup(
  key: 'appearance',
  title: 'Appearance',
  description: 'Customize the look and feel',
  icon: OiIcons.palette,
  items: [
    OiSettingsItem(
      key: 'dark_mode',
      title: 'Dark Mode',
      type: OiSettingsItemType.toggle,
      value: false,
      searchKeywords: ['theme', 'night'],
    ),
    OiSettingsItem(
      key: 'language',
      title: 'Language',
      type: OiSettingsItemType.select,
      value: 'English',
      options: ['English', 'German', 'French', 'Spanish'],
      searchKeywords: ['locale', 'translation'],
    ),
  ],
);

const _privacyGroup = OiSettingsGroup(
  key: 'privacy',
  title: 'Privacy',
  description: 'Control your data and privacy preferences',
  icon: OiIcons.shield,
  items: [
    OiSettingsItem(
      key: 'analytics',
      title: 'Share Analytics',
      type: OiSettingsItemType.toggle,
      subtitle: 'Help us improve by sharing anonymous usage data',
      value: true,
      searchKeywords: ['telemetry', 'tracking'],
    ),
    OiSettingsItem(
      key: 'crash_reports',
      title: 'Send Crash Reports',
      type: OiSettingsItemType.toggle,
      subtitle: 'Automatically send crash reports',
      value: true,
    ),
  ],
);

const _allGroups = [_generalGroup, _appearanceGroup, _privacyGroup];

final oiSettingsPageComponent = WidgetbookComponent(
  name: 'OiSettingsPage',
  useCases: [
    WidgetbookUseCase(
      name: 'Full',
      builder: (context) {
        final searchEnabled = context.knobs.boolean(
          label: 'Search Enabled',
          initialValue: true,
        );
        final showReset = context.knobs.boolean(
          label: 'Show Reset Buttons',
          initialValue: true,
        );

        return useCaseWrapper(
          SizedBox(
            width: 720,
            height: 700,
            child: OiSettingsPage(
              label: 'Application Settings',
              groups: _allGroups,
              searchEnabled: searchEnabled,
              showResetButtons: showReset,
              onSettingChanged: (group, key, value) {},
              onNavigate: (item) {},
              onResetGroup: (key) {},
              onResetAll: () {},
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Search Demo',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            width: 720,
            height: 700,
            child: OiSettingsPage(
              label: 'Search Settings',
              groups: _allGroups,
              showResetButtons: false,
              onSettingChanged: (group, key, value) {},
              onNavigate: (item) {},
            ),
          ),
        );
      },
    ),
  ],
);
