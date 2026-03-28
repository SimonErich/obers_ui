import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

const _sampleFile = OiFileNodeData(
  id: '1',
  name: 'report.pdf',
  folder: false,
  size: 1024 * 512,
  mimeType: 'application/pdf',
);

const _sampleFolder = OiFileNodeData(
  id: '2',
  name: 'images',
  folder: true,
  itemCount: 14,
);

final oiComponentDialogsComponent = WidgetbookComponent(
  name: 'Component Dialogs',
  useCases: [
    WidgetbookUseCase(
      name: 'Delete Dialog',
      builder: (context) {
        final permanent = context.knobs.boolean(label: 'Permanent delete');
        final showDontAsk = context.knobs.boolean(
          label: "Show 'Don't ask again'",
        );
        return useCaseWrapper(
          _DeleteDialogDemo(
            permanent: permanent,
            showDontAskAgain: showDontAsk,
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'New Folder Dialog',
      builder: (context) => useCaseWrapper(_NewFolderDialogDemo()),
    ),
    WidgetbookUseCase(
      name: 'Rename Dialog',
      builder: (context) {
        final isFolder = context.knobs.boolean(label: 'Is folder');
        return useCaseWrapper(_RenameDialogDemo(folder: isFolder));
      },
    ),
  ],
);

class _DeleteDialogDemo extends StatelessWidget {
  const _DeleteDialogDemo({
    required this.permanent,
    required this.showDontAskAgain,
  });

  final bool permanent;
  final bool showDontAskAgain;

  @override
  Widget build(BuildContext context) {
    return OiButton.destructive(
      label: 'Delete Files…',
      onTap: () {
        showDialog<void>(
          context: context,
          builder: (_) => OiDeleteDialog(
            files: const [_sampleFile, _sampleFolder],
            permanent: permanent,
            showDontAskAgain: showDontAskAgain,
            onDelete: ({dontAskAgain}) =>
                Navigator.of(context, rootNavigator: true).pop(),
            onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
          ),
        );
      },
    );
  }
}

class _NewFolderDialogDemo extends StatefulWidget {
  @override
  State<_NewFolderDialogDemo> createState() => _NewFolderDialogDemoState();
}

class _NewFolderDialogDemoState extends State<_NewFolderDialogDemo> {
  String? _created;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OiButton.primary(
          label: 'New Folder…',
          onTap: () {
            showDialog<void>(
              context: context,
              builder: (_) => OiNewFolderDialog(
                onCreate: (name) {
                  setState(() => _created = name);
                  Navigator.of(context, rootNavigator: true).pop();
                },
                onCancel: () =>
                    Navigator.of(context, rootNavigator: true).pop(),
              ),
            );
          },
        ),
        if (_created != null) ...[
          const SizedBox(height: 12),
          Text('Created: $_created'),
        ],
      ],
    );
  }
}

class _RenameDialogDemo extends StatefulWidget {
  const _RenameDialogDemo({required this.folder});
  final bool folder;

  @override
  State<_RenameDialogDemo> createState() => _RenameDialogDemoState();
}

class _RenameDialogDemoState extends State<_RenameDialogDemo> {
  String? _renamed;

  @override
  Widget build(BuildContext context) {
    final file = OiFileNodeData(
      id: '1',
      name: widget.folder ? 'My Folder' : 'document.pdf',
      folder: widget.folder,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OiButton.primary(
          label: 'Rename…',
          onTap: () {
            showDialog<void>(
              context: context,
              builder: (_) => OiRenameDialog(
                file: file,
                onRename: (newName) {
                  setState(() => _renamed = newName);
                  Navigator.of(context, rootNavigator: true).pop();
                },
                onCancel: () =>
                    Navigator.of(context, rootNavigator: true).pop(),
              ),
            );
          },
        ),
        if (_renamed != null) ...[
          const SizedBox(height: 12),
          Text('Renamed to: $_renamed'),
        ],
      ],
    );
  }
}
