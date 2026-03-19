import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiOnboardingComponent = WidgetbookComponent(
  name: 'Onboarding',
  useCases: [
    WidgetbookUseCase(
      name: 'OiSpotlight',
      builder: (context) {
        final targetKey = GlobalKey();
        return useCaseWrapper(
          OiSpotlight(
            target: targetKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Content above'),
                const SizedBox(height: 16),
                Container(
                  key: targetKey,
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFFEFF6FF),
                  child: const Text('Spotlighted widget'),
                ),
                const SizedBox(height: 16),
                const Text('Content below'),
              ],
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'OiTour',
      builder: (context) {
        final key1 = GlobalKey();
        final key2 = GlobalKey();
        return OiTour(
          steps: [
            OiTourStep(
              target: key1,
              title: 'Welcome',
              description: 'This is the first feature to explore.',
            ),
            OiTourStep(
              target: key2,
              title: 'Next Feature',
              description: 'Here is another feature.',
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  key: key1,
                  padding: const EdgeInsets.all(12),
                  color: const Color(0xFFEFF6FF),
                  child: const Text('Feature 1'),
                ),
                const SizedBox(height: 32),
                Container(
                  key: key2,
                  padding: const EdgeInsets.all(12),
                  color: const Color(0xFFFEF2F2),
                  child: const Text('Feature 2'),
                ),
              ],
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'OiWhatsNew',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            width: 480,
            height: 400,
            child: OiWhatsNew(
              items: const [
                OiWhatsNewItem(
                  title: 'Dark Mode',
                  description: 'Full dark mode support across all components.',
                  icon: Icons.dark_mode,
                  version: 'v2.1.0',
                ),
                OiWhatsNewItem(
                  title: 'Keyboard Shortcuts',
                  description: 'Added customizable keyboard shortcut manager.',
                  icon: Icons.keyboard,
                  version: 'v2.1.0',
                ),
                OiWhatsNewItem(
                  title: 'Performance',
                  description: 'Improved rendering performance for large lists.',
                  icon: Icons.speed,
                ),
              ],
            ),
          ),
        );
      },
    ),
  ],
);
