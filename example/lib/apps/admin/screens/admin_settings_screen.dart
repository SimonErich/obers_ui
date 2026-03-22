import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

/// Settings form with General and Notification sections.
class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  late final OiFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OiFormController(
      initialValues: {
        'siteName': 'Alpenglueck Shop',
        'language': 'de',
        'timezone': 'Europe/Vienna',
        'emailNotifications': true,
        'pushNotifications': false,
        'weeklyReport': true,
        'maintenanceMode': false,
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: OiForm(
        controller: _controller,
        onSubmit: (values) {
          OiToast.show(
            context,
            message: 'Settings saved successfully',
            level: OiToastLevel.success,
          );
        },
        sections: const [
          OiFormSection(
            title: 'General',
            description: 'Basic application settings',
            fields: [
              OiFormField(
                key: 'siteName',
                label: 'Site Name',
                type: OiFieldType.text,
                required: true,
              ),
              OiFormField(
                key: 'language',
                label: 'Language',
                type: OiFieldType.select,
                config: {
                  'options': <OiSelectOption<dynamic>>[
                    OiSelectOption(value: 'de', label: 'Deutsch'),
                    OiSelectOption(value: 'en', label: 'English'),
                    OiSelectOption(value: 'fr', label: 'Fran\u00e7ais'),
                  ],
                },
              ),
              OiFormField(
                key: 'timezone',
                label: 'Timezone',
                type: OiFieldType.select,
                config: {
                  'options': <OiSelectOption<dynamic>>[
                    OiSelectOption(
                      value: 'Europe/Vienna',
                      label: 'Europe/Vienna',
                    ),
                    OiSelectOption(
                      value: 'Europe/Berlin',
                      label: 'Europe/Berlin',
                    ),
                    OiSelectOption(
                      value: 'Europe/Zurich',
                      label: 'Europe/Zurich',
                    ),
                  ],
                },
              ),
            ],
          ),
          OiFormSection(
            title: 'Notifications',
            description: 'Configure how you receive notifications',
            fields: [
              OiFormField(
                key: 'emailNotifications',
                label: 'Email Notifications',
                type: OiFieldType.switchField,
              ),
              OiFormField(
                key: 'pushNotifications',
                label: 'Push Notifications',
                type: OiFieldType.switchField,
              ),
              OiFormField(
                key: 'weeklyReport',
                label: 'Weekly Report',
                type: OiFieldType.checkbox,
              ),
              OiFormField(
                key: 'maintenanceMode',
                label: 'Maintenance Mode',
                type: OiFieldType.switchField,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
