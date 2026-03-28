import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

const _fullProfile = OiProfileData(
  name: 'Jane Doe',
  email: 'jane.doe@company.com',
  role: 'Product Designer',
  phone: '+1 555 123 4567',
  bio: 'Passionate about user-centered design and accessible interfaces.',
);

const _minimalProfile = OiProfileData(name: 'John', email: 'john@example.com');

const _linkedAccounts = [
  OiLinkedAccount(
    provider: 'google',
    label: 'Google',
    icon: OiIcons.mail,
    connected: true,
    username: 'jane.doe@gmail.com',
  ),
  OiLinkedAccount(
    provider: 'github',
    label: 'GitHub',
    icon: OiIcons.link,
    connected: true,
    username: 'janedoe',
  ),
  OiLinkedAccount(provider: 'slack', label: 'Slack', icon: OiIcons.link),
];

/// Widgetbook component for [OiProfilePage].
final oiProfilePageComponent = WidgetbookComponent(
  name: 'OiProfilePage',
  useCases: [
    WidgetbookUseCase(
      name: 'Full Profile',
      builder: (context) {
        final showDangerZone = context.knobs.boolean(
          label: 'Show Danger Zone',
          initialValue: true,
        );

        return useCaseWrapper(
          SizedBox(
            width: 700,
            height: 900,
            child: OiProfilePage(
              label: 'User Profile',
              profile: _fullProfile,
              linkedAccounts: _linkedAccounts,
              showDangerZone: showDangerZone,
              onAvatarChange: (_) async {},
              onFieldSave: (field, value) async => true,
              onAccountLink: (_) {},
              onAccountUnlink: (_) {},
              onDeleteAccount: () async => true,
              sections: const [
                OiProfileSection(
                  title: 'Preferences',
                  icon: OiIcons.settings,
                  child: OiLabel.body('Notification and theme settings'),
                ),
              ],
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Minimal',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            width: 700,
            height: 500,
            child: OiProfilePage(
              label: 'User Profile',
              profile: _minimalProfile,
              showDangerZone: false,
              onFieldSave: (field, value) async => true,
            ),
          ),
        );
      },
    ),
  ],
);
