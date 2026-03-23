// ignore_for_file: deprecated_member_use — widgetbook demo uses OiBottomBarItem directly; OiBottomBar still accepts it
import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiBottomBarComponent = WidgetbookComponent(
  name: 'OiBottomBar',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final style = context.knobs.enumKnob<OiBottomBarStyle>(
          label: 'Style',
          values: OiBottomBarStyle.values,
        );
        final showLabels = context.knobs.boolean(
          label: 'Show Labels',
          initialValue: true,
        );

        return StatefulBuilder(
          builder: (context, setState) {
            var currentIndex = 0;
            return SizedBox(
              width: 400,
              height: 300,
              child: Column(
                children: [
                  const Expanded(child: Center(child: Text('Page content'))),
                  OiBottomBar(
                    items: const [
                      OiBottomBarItem(icon: Icons.home, label: 'Home'),
                      OiBottomBarItem(icon: Icons.search, label: 'Search'),
                      OiBottomBarItem(
                        icon: Icons.notifications,
                        label: 'Alerts',
                        badgeCount: 5,
                      ),
                      OiBottomBarItem(icon: Icons.person, label: 'Profile'),
                    ],
                    currentIndex: currentIndex,
                    onTap: (i) => setState(() => currentIndex = i),
                    style: style,
                    showLabels: showLabels,
                  ),
                ],
              ),
            );
          },
        );
      },
    ),
  ],
);
