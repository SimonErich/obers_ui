import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiRelativeTimeComponent = WidgetbookComponent(
  name: 'OiRelativeTime',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final style = context.knobs.enumKnob<OiRelativeTimeStyle>(
          label: 'Style',
          values: OiRelativeTimeStyle.values,
          initialValue: OiRelativeTimeStyle.short,
        );

        return useCaseWrapper(
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Just now:'),
              OiRelativeTime(
                dateTime: DateTime.now().subtract(const Duration(seconds: 5)),
                style: style,
              ),
              const SizedBox(height: 12),
              const Text('5 minutes ago:'),
              OiRelativeTime(
                dateTime: DateTime.now().subtract(const Duration(minutes: 5)),
                style: style,
              ),
              const SizedBox(height: 12),
              const Text('3 hours ago:'),
              OiRelativeTime(
                dateTime: DateTime.now().subtract(const Duration(hours: 3)),
                style: style,
              ),
              const SizedBox(height: 12),
              const Text('Yesterday:'),
              OiRelativeTime(
                dateTime: DateTime.now().subtract(const Duration(hours: 30)),
                style: style,
              ),
            ],
          ),
        );
      },
    ),
  ],
);
