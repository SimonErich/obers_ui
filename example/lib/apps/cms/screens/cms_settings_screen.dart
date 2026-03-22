import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

/// CMS settings screen with accordion sections for site configuration.
class CmsSettingsScreen extends StatefulWidget {
  const CmsSettingsScreen({super.key});

  @override
  State<CmsSettingsScreen> createState() => _CmsSettingsScreenState();
}

class _CmsSettingsScreenState extends State<CmsSettingsScreen> {
  // General settings
  final _siteTitleController = TextEditingController(text: 'Alpenglueck Blog');
  final _taglineController = TextEditingController(
    text: 'Austrian Alpine Lifestyle & Culture',
  );
  final _siteUrlController = TextEditingController(
    text: 'https://blog.alpenglueck.at',
  );

  // SEO settings
  final _metaDescriptionController = TextEditingController(
    text: 'Discover the best of Austrian culture, cuisine, and adventure.',
  );

  // Comments settings
  bool _moderationEnabled = true;
  double _maxCommentDepth = 5;

  // Notification settings
  bool _emailOnNewComment = true;
  bool _emailOnNewArticle = false;
  bool _emailWeeklyDigest = true;

  @override
  void dispose() {
    _siteTitleController.dispose();
    _taglineController.dispose();
    _siteUrlController.dispose();
    _metaDescriptionController.dispose();
    super.dispose();
  }

  void _handleSave() {
    OiToast.show(
      context,
      message: 'Settings saved successfully',
      level: OiToastLevel.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(spacing.md),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.borderSubtle)),
          ),
          child: const OiLabel.h3('Settings'),
        ),

        // Accordion content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OiAccordion(
                  allowMultiple: true,
                  sections: [
                    // General section
                    OiAccordionSection(
                      title: 'General',
                      initiallyExpanded: true,
                      content: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OiTextInput(
                              controller: _siteTitleController,
                              label: 'Site Title',
                              placeholder: 'Enter site title',
                            ),
                            SizedBox(height: spacing.md),
                            OiTextInput(
                              controller: _taglineController,
                              label: 'Tagline',
                              placeholder: 'Enter site tagline',
                            ),
                            SizedBox(height: spacing.md),
                            OiTextInput(
                              controller: _siteUrlController,
                              label: 'Site URL',
                              placeholder: 'https://example.com',
                            ),
                          ],
                        ),
                      ),
                    ),

                    // SEO section
                    OiAccordionSection(
                      title: 'SEO',
                      content: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OiTextInput(
                              controller: _metaDescriptionController,
                              label: 'Meta Description',
                              placeholder: 'Enter meta description',
                              maxLines: 3,
                            ),
                            SizedBox(height: spacing.sm),
                            OiLabel.caption(
                              'Recommended: 150-160 characters for optimal '
                              'search engine display.',
                              color: colors.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Comments section
                    OiAccordionSection(
                      title: 'Comments',
                      content: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: OiLabel.body('Moderate new comments'),
                                ),
                                OiSwitch(
                                  value: _moderationEnabled,
                                  label: 'Comment moderation',
                                  onChanged: (v) =>
                                      setState(() => _moderationEnabled = v),
                                ),
                              ],
                            ),
                            SizedBox(height: spacing.md),
                            OiNumberInput(
                              label: 'Max Reply Depth',
                              value: _maxCommentDepth,
                              min: 1,
                              max: 10,
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() => _maxCommentDepth = v);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Notifications section
                    OiAccordionSection(
                      title: 'Notifications',
                      content: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: OiLabel.body('Email on new comment'),
                                ),
                                OiSwitch(
                                  value: _emailOnNewComment,
                                  label: 'New comment notifications',
                                  onChanged: (v) =>
                                      setState(() => _emailOnNewComment = v),
                                ),
                              ],
                            ),
                            SizedBox(height: spacing.sm),
                            Row(
                              children: [
                                const Expanded(
                                  child: OiLabel.body('Email on new article'),
                                ),
                                OiSwitch(
                                  value: _emailOnNewArticle,
                                  label: 'New article notifications',
                                  onChanged: (v) =>
                                      setState(() => _emailOnNewArticle = v),
                                ),
                              ],
                            ),
                            SizedBox(height: spacing.sm),
                            Row(
                              children: [
                                const Expanded(
                                  child: OiLabel.body('Weekly digest email'),
                                ),
                                OiSwitch(
                                  value: _emailWeeklyDigest,
                                  label: 'Weekly digest notifications',
                                  onChanged: (v) =>
                                      setState(() => _emailWeeklyDigest = v),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: spacing.xl),

                // Save button
                Align(
                  alignment: Alignment.centerLeft,
                  child: OiButton.primary(
                    label: 'Save Settings',
                    semanticLabel: 'Save settings',
                    icon: OiIcons.checkCircle,
                    onTap: _handleSave,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
