import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final _sampleFiles = [
  OiFileNodeData(
    id: 'folder-1',
    name: 'Documents',
    folder: true,
    parentId: 'root',
    itemCount: 12,
    modified: DateTime.now().subtract(const Duration(days: 2)),
  ),
  OiFileNodeData(
    id: 'folder-2',
    name: 'Images',
    folder: true,
    parentId: 'root',
    itemCount: 34,
    modified: DateTime.now().subtract(const Duration(days: 5)),
  ),
  OiFileNodeData(
    id: 'file-1',
    name: 'report-q4.pdf',
    folder: false,
    parentId: 'root',
    size: 245000,
    mimeType: 'application/pdf',
    modified: DateTime.now().subtract(const Duration(hours: 3)),
  ),
  OiFileNodeData(
    id: 'file-2',
    name: 'screenshot.png',
    folder: false,
    parentId: 'root',
    size: 1800000,
    mimeType: 'image/png',
    modified: DateTime.now().subtract(const Duration(days: 1)),
  ),
  OiFileNodeData(
    id: 'file-3',
    name: 'notes.txt',
    folder: false,
    parentId: 'root',
    size: 4500,
    mimeType: 'text/plain',
    modified: DateTime.now().subtract(const Duration(minutes: 45)),
  ),
];

final oiFileExplorerComponent = WidgetbookComponent(
  name: 'OiFileExplorer',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final showSidebar = context.knobs.boolean(
          label: 'Show Sidebar',
          initialValue: true,
        );
        final enableSearch = context.knobs.boolean(
          label: 'Enable Search',
          initialValue: true,
        );
        final enableUpload = context.knobs.boolean(
          label: 'Enable Upload',
          initialValue: true,
        );
        final enableDragDrop = context.knobs.boolean(
          label: 'Enable Drag & Drop',
          initialValue: true,
        );

        final controller = OiFileExplorerController();

        return useCaseWrapper(
          SizedBox(
            height: 600,
            width: 900,
            child: OiFileExplorer(
              controller: controller,
              label: 'File explorer',
              showSidebar: showSidebar,
              enableSearch: enableSearch,
              enableUpload: enableUpload,
              enableDragDrop: enableDragDrop,
              loadFolder: (_) async => _sampleFiles,
              loadFolderTree: (_) async => [],
              onCreateFolder: (_, __) async => _sampleFiles.first,
              onRename: (_, __) async {},
              onDelete: (_) async {},
              onMove: (_, __) async {},
              onUpload: (_, __) async {},
              onOpen: (_) {},
            ),
          ),
        );
      },
    ),
  ],
);
