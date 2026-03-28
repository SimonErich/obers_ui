import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

const _sampleCategories = [
  OiConsentCategory(
    key: 'essential',
    name: 'Essential Cookies',
    description:
        'These cookies are strictly necessary for the site to function '
        'and cannot be switched off.',
    required: true,
    defaultValue: true,
  ),
  OiConsentCategory(
    key: 'analytics',
    name: 'Analytics Cookies',
    description:
        'Help us understand how visitors interact with our website by '
        'collecting and reporting information anonymously.',
  ),
  OiConsentCategory(
    key: 'marketing',
    name: 'Marketing Cookies',
    description:
        'Used to track visitors across websites to display relevant '
        'advertisements.',
  ),
  OiConsentCategory(
    key: 'preferences',
    name: 'Preference Cookies',
    description:
        'Allow the website to remember choices you make, such as language '
        'or region, and provide enhanced features.',
    defaultValue: true,
  ),
];

final oiConsentBannerComponent = WidgetbookComponent(
  name: 'OiConsentBanner',
  useCases: [
    WidgetbookUseCase(
      name: 'Full',
      builder: (context) {
        final position = context.knobs.object.dropdown(
          label: 'Position',
          options: OiConsentPosition.values,
          initialOption: OiConsentPosition.bottom,
          labelBuilder: (p) => p.name,
        );

        return useCaseWrapper(
          SizedBox(
            width: 900,
            height: 500,
            child: Stack(
              children: [
                OiConsentBanner(
                  categories: _sampleCategories,
                  label: 'Cookie consent banner',
                  description:
                      'We use cookies to enhance your browsing experience, '
                      'serve personalized content, and analyze our traffic.',
                  position: position,
                  onAcceptAll: () {},
                  onRejectAll: () {},
                  onSavePreferences: (_) {},
                  onPrivacyPolicyTap: () {},
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
            width: 900,
            height: 500,
            child: Stack(
              children: [
                OiConsentBanner.minimal(
                  categories: _sampleCategories,
                  label: 'Minimal cookie consent',
                  description:
                      'This site uses cookies. By continuing you agree '
                      'to our cookie policy.',
                  onAcceptAll: () {},
                  onRejectAll: () {},
                ),
              ],
            ),
          ),
        );
      },
    ),
  ],
);
