import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiReplyPreviewComponent = WidgetbookComponent(
  name: 'OiReplyPreview',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final senderName = context.knobs.string(
          label: 'Sender Name',
          initialValue: 'Alice Johnson',
        );
        final content = context.knobs.string(
          label: 'Content',
          initialValue:
              'Sure, let me check the latest build and get back to you.',
        );
        final dismissible = context.knobs.boolean(
          label: 'Dismissible',
          initialValue: true,
        );

        return useCaseWrapper(
          SizedBox(
            width: 360,
            child: OiReplyPreview(
              senderName: senderName,
              content: content,
              dismissible: dismissible,
              onDismiss: () {},
            ),
          ),
        );
      },
    ),
  ],
);
