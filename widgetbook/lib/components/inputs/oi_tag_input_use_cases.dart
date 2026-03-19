import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiTagInputComponent = WidgetbookComponent(
  name: 'OiTagInput',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final label = context.knobs.string(
          label: 'Label',
          initialValue: 'Tags',
        );
        final enabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );

        return useCaseWrapper(
          SizedBox(
            width: 350,
            child: _TagInputDemo(label: label, enabled: enabled),
          ),
        );
      },
    ),
  ],
);

class _TagInputDemo extends StatefulWidget {
  const _TagInputDemo({required this.label, required this.enabled});

  final String label;
  final bool enabled;

  @override
  State<_TagInputDemo> createState() => _TagInputDemoState();
}

class _TagInputDemoState extends State<_TagInputDemo> {
  List<String> _tags = ['Flutter', 'Dart', 'Widgetbook'];

  @override
  Widget build(BuildContext context) {
    return OiTagInput(
      tags: _tags,
      label: widget.label.isEmpty ? null : widget.label,
      enabled: widget.enabled,
      placeholder: 'Add tag...',
      onChanged: (v) => setState(() => _tags = v),
    );
  }
}
