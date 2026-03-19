import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiRichEditorComponent = WidgetbookComponent(
  name: 'OiRichEditor',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final toolbarMode = context.knobs.enumKnob<OiToolbarMode>(
          label: 'Toolbar Mode',
          values: OiToolbarMode.values,
        );

        final controller = OiRichEditorController(
          initialContent: OiRichContent.fromPlainText(
            'Hello world!\n\nThis is a sample rich editor.',
          ),
        );

        return useCaseWrapper(
          SizedBox(
            width: 500,
            child: OiRichEditor(
              controller: controller,
              label: 'Rich text editor',
              toolbar: toolbarMode,
              placeholder: 'Start typing...',
              showWordCount: true,
            ),
          ),
        );
      },
    ),
  ],
);
