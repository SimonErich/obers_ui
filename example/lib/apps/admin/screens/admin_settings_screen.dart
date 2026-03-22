import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_example/data/mock_dashboard.dart';

/// Settings form with collapsible General, Notifications, Appearance, and
/// API Keys sections.
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
        'tagline': 'Premium Alpine Products since 2019',
        'currency': 'EUR',
        'timezone': 'Europe/Vienna',
        'emailNotifications': true,
        'pushNotifications': false,
        'newsletter': true,
        'brandColor': const Color(0xFF2E7D32),
        'cornerStyle': 'rounded',
        'density': 1.0,
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
                content: OiForm(
                  controller: _controller,
                  onSubmit: (_) {},
                  dirtyDetection: false,
                  sections: const [
                    OiFormSection(
                      title: 'General',
                      description: 'Basic application settings',
                      fields: [
                        OiFormField(
                          key: 'siteName',
                          label: 'Store Name',
                          type: OiFieldType.text,
                          required: true,
                        ),
                        OiFormField(
                          key: 'tagline',
                          label: 'Tagline',
                          type: OiFieldType.text,
                        ),
                        OiFormField(
                          key: 'currency',
                          label: 'Currency',
                          type: OiFieldType.select,
                          config: {
                            'options': <OiSelectOption<dynamic>>[
                              OiSelectOption(value: 'EUR', label: 'EUR (Euro)'),
                              OiSelectOption(
                                value: 'CHF',
                                label: 'CHF (Swiss Franc)',
                              ),
                              OiSelectOption(
                                value: 'USD',
                                label: 'USD (US Dollar)',
                              ),
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
                  ],
                ),
              ),

              // ── Notifications ────────────────────────────────────────
              OiAccordionSection(
                title: 'Notifications',
                content: OiForm(
                  controller: _controller,
                  onSubmit: (_) {},
                  dirtyDetection: false,
                  sections: const [
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
                          key: 'newsletter',
                          label: 'Newsletter',
                          type: OiFieldType.checkbox,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Appearance ───────────────────────────────────────────
              OiAccordionSection(
                title: 'Appearance',
                content: OiForm(
                  controller: _controller,
                  onSubmit: (_) {},
                  dirtyDetection: false,
                  sections: const [
                    OiFormSection(
                      title: 'Appearance',
                      description: 'Customize the look and feel',
                      fields: [
                        OiFormField(
                          key: 'brandColor',
                          label: 'Brand Color',
                          type: OiFieldType.color,
                        ),
                        OiFormField(
                          key: 'cornerStyle',
                          label: 'Corner Style',
                          type: OiFieldType.radio,
                          config: {
                            'options': <OiRadioOption<dynamic>>[
                              OiRadioOption(value: 'rounded', label: 'Rounded'),
                              OiRadioOption(value: 'square', label: 'Square'),
                              OiRadioOption(value: 'pill', label: 'Pill'),
                            ],
                          },
                        ),
                        OiFormField(
                          key: 'density',
                          label: 'UI Density',
                          type: OiFieldType.slider,
                          config: {'min': 0.0, 'max': 2.0, 'divisions': 2},
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── API Keys ─────────────────────────────────────────────
              OiAccordionSection(
                title: 'API Keys',
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
