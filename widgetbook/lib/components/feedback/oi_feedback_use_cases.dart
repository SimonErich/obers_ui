import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiFeedbackComponent = WidgetbookComponent(
  name: 'Feedback Widgets',
  useCases: [
    WidgetbookUseCase(
      name: 'OiStarRating',
      builder: (context) {
        final maxStars = context.knobs.int.slider(
          label: 'Max Stars',
          initialValue: 5,
          min: 3,
          max: 10,
        );
        final allowHalf = context.knobs.boolean(label: 'Allow Half');
        final readOnly = context.knobs.boolean(label: 'Read Only');

        return useCaseWrapper(
          StatefulBuilder(
            builder: (context, setState) {
              var value = 3.0;
              return OiStarRating(
                value: value,
                maxStars: maxStars,
                allowHalf: allowHalf,
                readOnly: readOnly,
                onChanged: (v) => setState(() => value = v),
              );
            },
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'OiScaleRating',
      builder: (context) {
        final min = context.knobs.int.slider(
          label: 'Min',
          initialValue: 1,
          max: 5,
        );
        final max = context.knobs.int.slider(
          label: 'Max',
          initialValue: 10,
          min: 5,
          max: 15,
        );

        return useCaseWrapper(
          StatefulBuilder(
            builder: (context, setState) {
              int? value;
              return OiScaleRating(
                value: value,
                min: min,
                max: max,
                minLabel: 'Not likely',
                maxLabel: 'Very likely',
                onChanged: (v) => setState(() => value = v),
              );
            },
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'OiThumbs',
      builder: (context) {
        final showCount = context.knobs.boolean(
          label: 'Show Count',
          initialValue: true,
        );

        return useCaseWrapper(
          StatefulBuilder(
            builder: (context, setState) {
              var value = OiThumbsValue.none;
              return OiThumbs(
                value: value,
                showCount: showCount,
                upCount: 12,
                downCount: 3,
                onChanged: (v) => setState(() => value = v),
              );
            },
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'OiSentiment',
      builder: (context) {
        return useCaseWrapper(
          StatefulBuilder(
            builder: (context, setState) {
              String? value;
              return OiSentiment(
                value: value,
                onChanged: (v) => setState(() => value = v),
              );
            },
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'OiReactionBar',
      builder: (context) {
        return useCaseWrapper(
          OiReactionBar(
            reactions: const [
              OiReactionData(emoji: '\u{1F44D}', count: 5, selected: true),
              OiReactionData(emoji: '\u{2764}\u{FE0F}', count: 3),
              OiReactionData(emoji: '\u{1F602}', count: 2),
            ],
            onReact: (_) {},
          ),
        );
      },
    ),
  ],
);
