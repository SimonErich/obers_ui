import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiCodeBlockComponent = WidgetbookComponent(
  name: 'OiCodeBlock',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final code = context.knobs.string(
          label: 'Code',
          initialValue:
              'void main() {\n  final greeting = "Hello, World!";\n  print(greeting);\n}',
        );
        final language = context.knobs.string(
          label: 'Language',
          initialValue: 'dart',
        );
        final lineNumbers = context.knobs.boolean(
          label: 'Line Numbers',
          initialValue: true,
        );
        final showCopyButton = context.knobs.boolean(
          label: 'Show Copy Button',
          initialValue: true,
        );

        return useCaseWrapper(
          SizedBox(
            width: 400,
            child: OiCodeBlock(
              code: code,
              language: language,
              lineNumbers: lineNumbers,
              showCopyButton: showCopyButton,
            ),
          ),
        );
      },
    ),
  ],
);
