import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

// ── Sample data ──────────────────────────────────────────────────────────────

final _sampleFiles = <OiFileNodeData>[
  OiFileNodeData(
    id: '1',
    name: 'Documents',
    isFolder: true,
    itemCount: 12,
    modified: DateTime.now().subtract(const Duration(days: 2)),
  ),
  OiFileNodeData(
    id: '2',
    name: 'Images',
    isFolder: true,
    itemCount: 34,
    modified: DateTime.now().subtract(const Duration(days: 5)),
  ),
  OiFileNodeData(
    id: '3',
    name: 'report-q4.pdf',
    isFolder: false,
    size: 245000,
    mimeType: 'application/pdf',
    modified: DateTime.now().subtract(const Duration(hours: 3)),
  ),
  OiFileNodeData(
    id: '4',
    name: 'presentation.pptx',
    isFolder: false,
    size: 1200000,
    modified: DateTime.now().subtract(const Duration(days: 1)),
  ),
  OiFileNodeData(
    id: '5',
    name: 'notes.txt',
    isFolder: false,
    size: 4500,
    mimeType: 'text/plain',
    modified: DateTime.now().subtract(const Duration(minutes: 45)),
  ),
  OiFileNodeData(
    id: '6',
    name: 'photo.jpg',
    isFolder: false,
    size: 3200000,
    mimeType: 'image/jpeg',
    modified: DateTime.now().subtract(const Duration(hours: 12)),
  ),
];

final _sampleFolderTree = <OiTreeNode<OiFileNodeData>>[
  const OiTreeNode(
    id: 'root',
    label: 'Home',
    data: OiFileNodeData(id: 'root', name: 'Home', isFolder: true),
    children: [
      OiTreeNode(
        id: 'docs',
        label: 'Documents',
        data: OiFileNodeData(id: 'docs', name: 'Documents', isFolder: true),
        children: [
          OiTreeNode(
            id: 'work',
            label: 'Work',
            data: OiFileNodeData(id: 'work', name: 'Work', isFolder: true),
          ),
        ],
      ),
      OiTreeNode(
        id: 'images',
        label: 'Images',
        data: OiFileNodeData(id: 'images', name: 'Images', isFolder: true),
      ),
    ],
  ),
];

// ── OiFileGridView ────────────────────────────────────────────────────────────

final oiFileGridViewComponent = WidgetbookComponent(
  name: 'OiFileGridView',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final enableDragDrop = context.knobs.boolean(
          label: 'Enable Drag & Drop',
          initialValue: true,
        );
        final enableMultiSelect = context.knobs.boolean(
          label: 'Enable Multi-Select',
          initialValue: true,
        );
        final loading = context.knobs.boolean(label: 'Loading');

        var selectedKeys = <Object>{};

        return SizedBox(
          height: 500,
          width: 700,
          child: StatefulBuilder(
            builder: (context, setState) {
              return OiFileGridView(
                files: _sampleFiles,
                selectedKeys: selectedKeys,
                onSelectionChange: (keys) =>
                    setState(() => selectedKeys = keys),
                onOpen: (_) {},
                enableDragDrop: enableDragDrop,
                enableMultiSelect: enableMultiSelect,
                loading: loading,
              );
            },
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Empty',
      builder: (context) {
        return const SizedBox(
          height: 400,
          width: 600,
          child: OiFileGridView(
            files: [],
            selectedKeys: {},
            onSelectionChange: _noop,
            onOpen: _noop,
          ),
        );
      },
    ),
  ],
);

// ── OiFileListView ────────────────────────────────────────────────────────────

final oiFileListViewComponent = WidgetbookComponent(
  name: 'OiFileListView',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final showSize = context.knobs.boolean(
          label: 'Show Size',
          initialValue: true,
        );
        final showModified = context.knobs.boolean(
          label: 'Show Modified',
          initialValue: true,
        );
        final showType = context.knobs.boolean(
          label: 'Show Type',
          initialValue: true,
        );
        final enableDragDrop = context.knobs.boolean(
          label: 'Enable Drag & Drop',
          initialValue: true,
        );
        final enableMultiSelect = context.knobs.boolean(
          label: 'Enable Multi-Select',
          initialValue: true,
        );
        final loading = context.knobs.boolean(label: 'Loading');

        var selectedKeys = <Object>{};

        return SizedBox(
          height: 500,
          width: 700,
          child: StatefulBuilder(
            builder: (context, setState) {
              return OiFileListView(
                files: _sampleFiles,
                selectedKeys: selectedKeys,
                onSelectionChange: (keys) =>
                    setState(() => selectedKeys = keys),
                onOpen: (_) {},
                showSize: showSize,
                showModified: showModified,
                showType: showType,
                enableDragDrop: enableDragDrop,
                enableMultiSelect: enableMultiSelect,
                loading: loading,
              );
            },
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Empty',
      builder: (context) {
        return const SizedBox(
          height: 400,
          width: 600,
          child: OiFileListView(
            files: [],
            selectedKeys: {},
            onSelectionChange: _noop,
            onOpen: _noop,
          ),
        );
      },
    ),
  ],
);

// ── OiFileDropTarget ──────────────────────────────────────────────────────────

final oiFileDropTargetComponent = WidgetbookComponent(
  name: 'OiFileDropTarget',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final enabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );
        final dropMessage = context.knobs.string(
          label: 'Drop Message',
          initialValue: 'Drop files here',
        );

        return useCaseWrapper(
          SizedBox(
            height: 400,
            width: 600,
            child: OiFileDropTarget(
              enabled: enabled,
              dropMessage: dropMessage,
              onInternalDrop: (_, __) {},
              onExternalDrop: (_) {},
              child: ColoredBox(
                color: Colors.grey.withValues(alpha: 0.1),
                child: const Center(
                  child: Text('Drag files here to test drop target'),
                ),
              ),
            ),
          ),
        );
      },
    ),
  ],
);

// ── OiFileSidebar ─────────────────────────────────────────────────────────────

final oiFileSidebarComponent = WidgetbookComponent(
  name: 'OiFileSidebar',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final resizable = context.knobs.boolean(
          label: 'Resizable',
          initialValue: true,
        );
        final collapsible = context.knobs.boolean(
          label: 'Collapsible',
          initialValue: true,
        );
        final draggable = context.knobs.boolean(
          label: 'Draggable',
          initialValue: true,
        );
        final showStorage = context.knobs.boolean(
          label: 'Show Storage Indicator',
          initialValue: true,
        );

        return SizedBox(
          height: 600,
          child: OiFileSidebar(
            folderTree: _sampleFolderTree,
            selectedFolderId: 'docs',
            onFolderSelect: (_) {},
            draggable: draggable,
            resizable: resizable,
            collapsible: collapsible,
            quickAccess: const [
              OiQuickAccessItem(
                id: 'home',
                label: 'Home',
                icon: IconData(0xe88a, fontFamily: 'MaterialIcons'),
              ),
              OiQuickAccessItem(
                id: 'downloads',
                label: 'Downloads',
                icon: IconData(0xf090, fontFamily: 'MaterialIcons'),
              ),
              OiQuickAccessItem(
                id: 'trash',
                label: 'Trash',
                icon: IconData(0xe872, fontFamily: 'MaterialIcons'),
                badgeCount: 3,
              ),
            ],
            onQuickAccessTap: (_) {},
            favorites: const [
              OiFileNodeData(
                id: 'fav1',
                name: 'Documents',
                isFolder: true,
                isFavorite: true,
              ),
            ],
            onFavoriteTap: (_) {},
            onNewFolder: (_) {},
            onRenameFolder: (_) {},
            onDeleteFolder: (_) {},
            storage: showStorage
                ? const OiStorageData(
                    usedBytes: 5 * 1024 * 1024 * 1024,
                    totalBytes: 15 * 1024 * 1024 * 1024,
                  )
                : null,
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Minimal',
      builder: (context) {
        return SizedBox(
          height: 500,
          child: OiFileSidebar(
            folderTree: _sampleFolderTree,
            selectedFolderId: 'root',
            onFolderSelect: (_) {},
          ),
        );
      },
    ),
  ],
);

// ── Helpers ───────────────────────────────────────────────────────────────────

void _noop<T>(T _) {}
