import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiFeedbackSheetComponent = WidgetbookComponent(
  name: 'OiFeedbackSheet',
  useCases: [
    WidgetbookUseCase(
      name: 'Sentiment Rating',
      builder: (context) {
        final showEmail = context.knobs.boolean(
          label: 'Show Email',
          initialValue: true,
        );

        return useCaseWrapper(
          SizedBox(
            width: 420,
            height: 600,
            child: OiFeedbackSheet(
              label: 'Feedback',
              showEmail: showEmail,
              onSubmit: (OiFeedbackData data) async {
                debugPrint(
                  'Feedback submitted: ${data.category.name}, '
                  'rating=${data.rating}, '
                  'message=${data.message}',
                );
                return true;
              },
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Star Rating',
      builder: (context) {
        final showEmail = context.knobs.boolean(
          label: 'Show Email',
          initialValue: true,
        );

        return useCaseWrapper(
          SizedBox(
            width: 420,
            height: 600,
            child: OiFeedbackSheet(
              label: 'Feedback',
              ratingType: OiFeedbackRatingType.stars,
              showEmail: showEmail,
              onSubmit: (OiFeedbackData data) async {
                debugPrint(
                  'Feedback submitted: ${data.category.name}, '
                  'rating=${data.rating}, '
                  'message=${data.message}',
                );
                return true;
              },
            ),
          ),
        );
      },
    ),
  ],
);
