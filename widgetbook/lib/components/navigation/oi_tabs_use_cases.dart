import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiTabsComponent = WidgetbookComponent(
  name: 'OiTabs',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final indicatorStyle = context.knobs.enumKnob<OiTabIndicatorStyle>(
          label: 'Indicator Style',
          values: OiTabIndicatorStyle.values,
        );
        final scrollable = context.knobs.boolean(label: 'Scrollable');

        return useCaseWrapper(
          StatefulBuilder(
            builder: (context, setState) {
              var selectedIndex = 0;
              return SizedBox(
                width: 400,
                child: OiTabs(
                  tabs: const [
                    OiTabItem(label: 'Overview'),
                    OiTabItem(label: 'Activity'),
                    OiTabItem(label: 'Settings'),
                    OiTabItem(label: 'Members', badge: 3),
                  ],
                  selectedIndex: selectedIndex,
                  onSelected: (i) => setState(() => selectedIndex = i),
                  indicatorStyle: indicatorStyle,
                  scrollable: scrollable,
                ),
              );
            },
          ),
        );
      },
    ),
  ],
);
