import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiCardComponent = WidgetbookComponent(
  name: 'OiCard',
  useCases: [
    WidgetbookUseCase(
      name: 'Default (Elevated)',
      builder: (context) {
        final collapsible = context.knobs.boolean(label: 'Collapsible');
        final titleText = context.knobs.string(
          label: 'Title',
          initialValue: 'Card Title',
        );

        return useCaseWrapper(
          SizedBox(
            width: 320,
            child: OiCard(
              title: Text(titleText),
              collapsible: collapsible,
              child: const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Card content goes here.'),
              ),
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Flat',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            width: 320,
            child: OiCard.flat(
              title: const Text('Flat Card'),
              child: const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('No shadow variant.'),
              ),
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Outlined',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            width: 320,
            child: OiCard.outlined(
              title: const Text('Outlined Card'),
              child: const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Border only, no shadow.'),
              ),
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Interactive',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            width: 320,
            child: OiCard.interactive(
              label: 'Interactive card',
              title: const Text('Interactive Card'),
              onTap: () {},
              child: const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Hover and focus effects.'),
              ),
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Compact',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            width: 320,
            child: OiCard.compact(
              title: const Text('Compact Card'),
              child: const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('Reduced padding.'),
              ),
            ),
          ),
        );
      },
    ),
  ],
);
