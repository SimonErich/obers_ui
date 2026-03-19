import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final _sampleLines = [
  const OiDiffLine(
    content: 'import "package:flutter/widgets.dart";',
    lineNumber: 1,
    unchanged: true,
  ),
  const OiDiffLine(
    content: 'import "package:obers_ui/obers_ui.dart";',
    lineNumber: 2,
    removed: true,
  ),
  const OiDiffLine(
    content: 'import "package:obers_ui/src/core.dart";',
    lineNumber: 2,
    added: true,
  ),
  const OiDiffLine(content: '', lineNumber: 3, unchanged: true),
  const OiDiffLine(
    content: 'class MyWidget extends StatelessWidget {',
    lineNumber: 4,
    unchanged: true,
  ),
  const OiDiffLine(
    content: '  final String title;',
    lineNumber: 5,
    removed: true,
  ),
  const OiDiffLine(
    content: '  final String label;',
    lineNumber: 5,
    added: true,
  ),
];

final oiDiffViewComponent = WidgetbookComponent(
  name: 'OiDiffView',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final mode = context.knobs.enumKnob<OiDiffMode>(
          label: 'Mode',
          values: OiDiffMode.values,
          initialValue: OiDiffMode.unified,
        );
        final showLineNumbers = context.knobs.boolean(
          label: 'Show Line Numbers',
          initialValue: true,
        );

        return useCaseWrapper(
          SizedBox(
            width: 500,
            child: OiDiffView(
              lines: _sampleLines,
              mode: mode,
              showLineNumbers: showLineNumbers,
            ),
          ),
        );
      },
    ),
  ],
);
