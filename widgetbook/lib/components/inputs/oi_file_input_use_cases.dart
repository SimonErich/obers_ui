import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiFileInputComponent = WidgetbookComponent(
  name: 'OiFileInput',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final multipleFiles = context.knobs.boolean(
          label: 'Multiple Files',
          initialValue: false,
        );
        final dropZone = context.knobs.boolean(
          label: 'Drop Zone',
          initialValue: false,
        );
        final enabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );
        final label = context.knobs.string(
          label: 'Label',
          initialValue: 'Attachment',
        );

        return useCaseWrapper(
          SizedBox(
            width: 350,
            child: _FileInputDemo(
              multipleFiles: multipleFiles,
              dropZone: dropZone,
              enabled: enabled,
              label: label,
            ),
          ),
        );
      },
    ),
  ],
);

class _FileInputDemo extends StatefulWidget {
  const _FileInputDemo({
    required this.multipleFiles,
    required this.dropZone,
    required this.enabled,
    required this.label,
  });

  final bool multipleFiles;
  final bool dropZone;
  final bool enabled;
  final String label;

  @override
  State<_FileInputDemo> createState() => _FileInputDemoState();
}

class _FileInputDemoState extends State<_FileInputDemo> {
  List<String>? _files;

  @override
  Widget build(BuildContext context) {
    return OiFileInput(
      value: _files,
      multipleFiles: widget.multipleFiles,
      dropZone: widget.dropZone,
      enabled: widget.enabled,
      label: widget.label.isEmpty ? null : widget.label,
      onChanged: (v) => setState(() => _files = v),
    );
  }
}
