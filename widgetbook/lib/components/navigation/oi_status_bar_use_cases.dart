import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiStatusBarComponent = WidgetbookComponent(
  name: 'OiStatusBar',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final showLeadingIcon = context.knobs.boolean(
          label: 'Show Leading Icon',
          initialValue: true,
        );
        final showStatusDot = context.knobs.boolean(
          label: 'Show Status Dot',
          initialValue: true,
        );

        return useCaseWrapper(
          SizedBox(
            width: 800,
            child: OiStatusBar(
              label: 'Application status bar',
              leading: [
                if (showLeadingIcon)
                  OiStatusBarItem(
                    label: 'main',
                    icon: OiIcons.gitBranch,
                    onTap: () {},
                  ),
                const OiStatusBarItem(label: 'UTF-8'),
                const OiStatusBarItem(label: 'Dart'),
              ],
              trailing: [
                const OiStatusBarItem(label: 'Ln 42, Col 8'),
                const OiStatusBarItem(label: 'Spaces: 2'),
                OiStatusBarItem(
                  label: 'Connected',
                  color: showStatusDot ? const Color(0xFF22C55E) : null,
                ),
              ],
            ),
          ),
        );
      },
    ),
  ],
);
