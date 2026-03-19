import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiNameDialogComponent = WidgetbookComponent(
  name: 'OiNameDialog',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        final title = context.knobs.string(
          label: 'Title',
          initialValue: 'New Folder',
        );
        final defaultName = context.knobs.string(
          label: 'Default name',
          initialValue: 'Untitled',
        );
        return useCaseWrapper(
          _NameDialogDemo(title: title, defaultName: defaultName),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Rename',
      builder: (context) => useCaseWrapper(
        const _NameDialogDemo(
          title: 'Rename file',
          defaultName: 'report-final.pdf',
        ),
      ),
    ),
  ],
);

class _NameDialogDemo extends StatefulWidget {
  const _NameDialogDemo({required this.title, required this.defaultName});

  final String title;
  final String defaultName;

  @override
  State<_NameDialogDemo> createState() => _NameDialogDemoState();
}

class _NameDialogDemoState extends State<_NameDialogDemo> {
  String? _lastCreated;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OiButton.primary(
          label: 'Open Name Dialog',
          onTap: () {
            showDialog<void>(
              context: context,
              builder: (_) => OiNameDialog(
                title: widget.title,
                defaultName: widget.defaultName,
                onCreate: (name) {
                  setState(() => _lastCreated = name);
                  Navigator.of(context, rootNavigator: true).pop();
                },
                onCancel: () =>
                    Navigator.of(context, rootNavigator: true).pop(),
              ),
            );
          },
        ),
        if (_lastCreated != null) ...[
          const SizedBox(height: 16),
          Text('Created: $_lastCreated'),
        ],
      ],
    );
  }
}
