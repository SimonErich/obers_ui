import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_autoforms/obers_ui_autoforms.dart';
import 'package:obers_ui_example/data/mock_dashboard.dart';

// ── Field enums ──────────────────────────────────────────────────────────────

enum _GeneralField { siteName, tagline, currency, timezone }

enum _NotificationsField { emailNotifications, pushNotifications, newsletter }

enum _AppearanceField { brandColor, cornerStyle, density }

// ── Options ──────────────────────────────────────────────────────────────────

const _currencyOptions = [
  OiAfOption(value: 'EUR', label: 'EUR (Euro)'),
  OiAfOption(value: 'CHF', label: 'CHF (Swiss Franc)'),
  OiAfOption(value: 'USD', label: 'USD (US Dollar)'),
];

const _timezoneOptions = [
  OiAfOption(value: 'Europe/Vienna', label: 'Europe/Vienna'),
  OiAfOption(value: 'Europe/Berlin', label: 'Europe/Berlin'),
  OiAfOption(value: 'Europe/Zurich', label: 'Europe/Zurich'),
];

const _cornerStyleOptions = [
  OiAfOption(value: 'rounded', label: 'Rounded'),
  OiAfOption(value: 'square', label: 'Square'),
  OiAfOption(value: 'pill', label: 'Pill'),
];

// ── Controllers ──────────────────────────────────────────────────────────────

class _GeneralController
    extends OiAfController<_GeneralField, Map<String, dynamic>> {
  @override
  void defineFields() {
    addTextField(
      _GeneralField.siteName,
      initialValue: 'Alpenglueck Shop',
      required: true,
    );
    addTextField(
      _GeneralField.tagline,
      initialValue: 'Premium Alpine Products since 2019',
    );
    addSelectField<String>(
      _GeneralField.currency,
      initialValue: 'EUR',
      options: _currencyOptions,
    );
    addSelectField<String>(
      _GeneralField.timezone,
      initialValue: 'Europe/Vienna',
      options: _timezoneOptions,
    );
  }

  @override
  Map<String, dynamic> buildData() => json();
}

class _NotificationsController
    extends OiAfController<_NotificationsField, Map<String, dynamic>> {
  @override
  void defineFields() {
    addBoolField(_NotificationsField.emailNotifications, initialValue: true);
    addBoolField(_NotificationsField.pushNotifications, initialValue: false);
    addBoolField(_NotificationsField.newsletter, initialValue: true);
  }

  @override
  Map<String, dynamic> buildData() => json();
}

class _AppearanceController
    extends OiAfController<_AppearanceField, Map<String, dynamic>> {
  @override
  void defineFields() {
    addColorField(
      _AppearanceField.brandColor,
      initialValue: const Color(0xFF2E7D32),
    );
    addRadioField<String>(
      _AppearanceField.cornerStyle,
      initialValue: 'rounded',
      options: _cornerStyleOptions,
    );
    addSliderField(_AppearanceField.density, min: 0, max: 2, divisions: 2);
  }

  @override
  Map<String, dynamic> buildData() => json();
}

// ── Screen ───────────────────────────────────────────────────────────────────

/// Settings form with collapsible General, Notifications, Appearance, and
/// API Keys sections.
class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  late final _GeneralController _generalController;
  late final _NotificationsController _notificationsController;
  late final _AppearanceController _appearanceController;

  @override
  void initState() {
    super.initState();
    _generalController = _GeneralController();
    _notificationsController = _NotificationsController();
    _appearanceController = _AppearanceController();
  }

  @override
  void dispose() {
    _generalController.dispose();
    _notificationsController.dispose();
    _appearanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OiAccordion(
            allowMultiple: true,
            sections: [
              // ── General ──────────────────────────────────────────────
              OiAccordionSection(
                title: 'General',
                initiallyExpanded: true,
                headerBackgroundColor: colors.surfaceSubtle,
                content: OiAfForm<_GeneralField, Map<String, dynamic>>(
                  controller: _generalController,
                  onSubmit: (_, __) async {},
                  child: const OiFormSection(
                    description: 'Basic application settings',
                    children: [
                      OiAfTextInput(
                        field: _GeneralField.siteName,
                        label: 'Store Name',
                      ),
                      OiAfTextInput(
                        field: _GeneralField.tagline,
                        label: 'Tagline',
                      ),
                      OiAfSelect<_GeneralField, String>(
                        field: _GeneralField.currency,
                        label: 'Currency',
                        options: _currencyOptions,
                      ),
                      OiAfSelect<_GeneralField, String>(
                        field: _GeneralField.timezone,
                        label: 'Timezone',
                        options: _timezoneOptions,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Notifications ────────────────────────────────────────
              OiAccordionSection(
                title: 'Notifications',
                headerBackgroundColor: colors.surfaceSubtle,
                content: OiAfForm<_NotificationsField, Map<String, dynamic>>(
                  controller: _notificationsController,
                  onSubmit: (_, __) async {},
                  child: const OiFormSection(
                    description: 'Configure how you receive notifications',
                    children: [
                      OiAfSwitch(
                        field: _NotificationsField.emailNotifications,
                        label: 'Email Notifications',
                      ),
                      OiAfSwitch(
                        field: _NotificationsField.pushNotifications,
                        label: 'Push Notifications',
                      ),
                      OiAfCheckbox(
                        field: _NotificationsField.newsletter,
                        label: 'Newsletter',
                      ),
                    ],
                  ),
                ),
              ),

              // ── Appearance ───────────────────────────────────────────
              OiAccordionSection(
                title: 'Appearance',
                headerBackgroundColor: colors.surfaceSubtle,
                content: OiAfForm<_AppearanceField, Map<String, dynamic>>(
                  controller: _appearanceController,
                  onSubmit: (_, __) async {},
                  child: const OiFormSection(
                    description: 'Customize the look and feel',
                    children: [
                      OiAfColorInput(
                        field: _AppearanceField.brandColor,
                        label: 'Brand Color',
                      ),
                      OiAfRadio<_AppearanceField, String>(
                        field: _AppearanceField.cornerStyle,
                        options: _cornerStyleOptions,
                      ),
                      OiAfSlider(
                        field: _AppearanceField.density,
                        min: 0,
                        max: 2,
                        divisions: 2,
                        label: 'UI Density',
                      ),
                    ],
                  ),
                ),
              ),

              // ── API Keys ─────────────────────────────────────────────
              OiAccordionSection(
                title: 'API Keys',
                headerBackgroundColor: colors.surfaceSubtle,
                content: _buildApiKeysSection(context),
              ),
            ],
          ),

          SizedBox(height: spacing.lg),

          // ── Save button ──────────────────────────────────────────────
          Align(
            alignment: Alignment.centerRight,
            child: OiButton.primary(
              label: 'Save Settings',
              onTap: () {
                OiToast.show(
                  context,
                  message: 'Settings saved successfully',
                  level: OiToastLevel.success,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeysSection(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OiLabel.body(
          'Manage your API keys for external integrations.',
          color: colors.textMuted,
        ),
        SizedBox(height: spacing.md),
        for (final apiKey in kMockApiKeys) ...[
          OiCard(
            child: Padding(
              padding: EdgeInsets.all(spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: OiLabel.bodyStrong(apiKey.name)),
                      if (apiKey.active)
                        const OiBadge.soft(
                          label: 'Active',
                          color: OiBadgeColor.success,
                          size: OiBadgeSize.small,
                        )
                      else
                        const OiBadge.soft(
                          label: 'Inactive',
                          color: OiBadgeColor.neutral,
                          size: OiBadgeSize.small,
                        ),
                    ],
                  ),
                  SizedBox(height: spacing.sm),
                  OiCodeBlock(code: apiKey.key, showCopyButton: false),
                  SizedBox(height: spacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: OiLabel.caption(
                          'Created: ${apiKey.created}',
                          color: colors.textMuted,
                        ),
                      ),
                      OiCopyButton(
                        value: apiKey.key,
                        semanticLabel: 'Copy ${apiKey.name}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: spacing.sm),
        ],
      ],
    );
  }
}
