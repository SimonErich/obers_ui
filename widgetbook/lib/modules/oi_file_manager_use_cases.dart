import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../helpers/knob_helpers.dart';

final _sampleFiles = [
  OiFileNode(
    key: '1',
    name: 'Documents',
    folder: true,
    modified: DateTime.now().subtract(const Duration(days: 2)),
  ),
  OiFileNode(
    key: '2',
    name: 'Images',
    folder: true,
    modified: DateTime.now().subtract(const Duration(days: 5)),
  ),
  OiFileNode(
    key: '3',
    name: 'report-q4.pdf',
    folder: false,
    size: 245000,
    modified: DateTime.now().subtract(const Duration(hours: 3)),
  ),
  OiFileNode(
    key: '4',
    name: 'presentation.pptx',
    folder: false,
    size: 1200000,
    modified: DateTime.now().subtract(const Duration(days: 1)),
  ),
  OiFileNode(
    key: '5',
    name: 'notes.txt',
    folder: false,
    size: 4500,
    modified: DateTime.now().subtract(const Duration(minutes: 45)),
  ),
];

final oiFileManagerComponent = WidgetbookComponent(
  name: 'OiFileManager',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final layout = context.knobs.enumKnob<OiFileManagerLayout>(
          label: 'Layout',
          values: OiFileManagerLayout.values,
        );
        final selectionMode = context.knobs.enumKnob<OiFileManagerSelectionMode>(
          label: 'Selection Mode',
          values: OiFileManagerSelectionMode.values,
          initialValue: OiFileManagerSelectionMode.multi,
        );
        final showBreadcrumbs = context.knobs.boolean(
          label: 'Show Breadcrumbs',
          initialValue: true,
        );

        return useCaseWrapper(
          SizedBox(
            height: 600,
            width: 800,
            child: OiFileManager(
              items: _sampleFiles,
              label: 'File manager',
              layout: layout,
              selectionMode: selectionMode,
              currentPath: showBreadcrumbs
                  ? const ['Home', 'Projects', 'obers-ui']
                  : null,
              onNavigate: (_) {},
              onOpen: (_) {},
              onRename: (_) {},
              onDelete: (_) {},
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Empty Folder',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            height: 400,
            width: 600,
            child: OiFileManager(
              items: const [],
              label: 'Empty file manager',
              onUpload: (_) {},
            ),
          ),
        );
      },
    ),
  ],
);
