part of '../oi_file_explorer.dart';

// ── Dialog helpers ───────────────────────────────────────────────────────────

extension _OiFileExplorerDialogs on _OiFileExplorerState {
  void _dismissDialog() {
    _dialogHandle?.dismiss();
    _dialogHandle = null;
    if (_isDialogOpen) _setDialogOpen(open: false);
  }

  void _showDeleteDialog(List<OiFileNodeData> files) {
    _dismissDialog();
    _dialogHandle = OiDialog.show(
      context,
      label: 'Delete confirmation',
      dialog: OiDialog.confirm(
        label: 'Delete confirmation',
        content: OiDeleteDialog(
          files: files,
          onDelete: () async {
            _dismissDialog();
            await widget.onDelete(files);
            widget.controller.clearSelection();
            unawaited(widget.controller.refresh());
            _announce(
              '${files.length} item${files.length == 1 ? '' : 's'} deleted',
            );
          },
          onCancel: _dismissDialog,
          permanent: true,
        ),
        onClose: _dismissDialog,
      ),
    );
  }

  void _showMoveDialog(List<OiFileNodeData> files, {bool copyMode = false}) {
    if (!copyMode && !widget.enableMove) return;
    if (copyMode && widget.onCopy == null) return;
    _dismissDialog();
    _dialogHandle = OiDialog.show(
      context,
      label: copyMode ? 'Copy dialog' : 'Move dialog',
      dialog: OiDialog.form(
        label: copyMode ? 'Copy dialog' : 'Move dialog',
        content: OiMoveDialog(
          files: files,
          folderTree: _folderTree,
          copyMode: copyMode,
          onMove: (destination) async {
            _dismissDialog();
            if (copyMode) {
              await widget.onCopy?.call(files, destination);
            } else {
              await widget.onMove(files, destination);
            }
            widget.controller.clearSelection();
            unawaited(widget.controller.refresh());
            final action = copyMode ? 'copied' : 'moved';
            _announce(
              '${files.length} item${files.length == 1 ? '' : 's'} $action to ${destination.name}',
            );
          },
          onCancel: _dismissDialog,
        ),
        onClose: _dismissDialog,
      ),
    );
  }

  void _showUploadDialog() {
    _dismissDialog();
    final folderId = widget.controller.currentFolder?.id.toString() ?? 'root';
    _dialogHandle = OiDialog.show(
      context,
      label: 'Upload dialog',
      dialog: OiDialog.form(
        label: 'Upload dialog',
        content: OiUploadDialog(
          allowedExtensions: widget.allowedUploadExtensions,
          maxFileSize: widget.maxUploadFileSize,
          destinationPath: widget.controller.currentFolder?.name,
          onUpload: (files, _) async {
            _dismissDialog();
            await widget.onUpload(files, folderId);
            unawaited(widget.controller.refresh());
            _announce(
              '${files.length} file${files.length == 1 ? '' : 's'} uploaded',
            );
          },
          onCancel: _dismissDialog,
        ),
        onClose: _dismissDialog,
      ),
    );
    _setDialogOpen(open: true);
  }

  void _showNewFolderDialog() {
    _dismissDialog();
    final nameController = TextEditingController(text: 'New Folder');

    void closeAndDispose() {
      _dismissDialog();
      nameController.dispose();
    }

    _dialogHandle = OiDialog.show(
      context,
      label: 'New folder',
      dialog: OiDialog.form(
        label: 'New folder',
        title: 'New Folder',
        content: _NewFolderDialogContent(
          nameController: nameController,
          onApply: () async {
            final name = nameController.text.trim();
            if (name.isEmpty) return;
            closeAndDispose();
            final folderId =
                widget.controller.currentFolder?.id.toString() ?? 'root';
            await widget.onCreateFolder(folderId, name);
            unawaited(widget.controller.refresh());
            unawaited(_loadFolderTree());
            _announce('Folder "$name" created');
          },
          onCancel: closeAndDispose,
        ),
        onClose: closeAndDispose,
      ),
    );
  }
}

// ── _NewFolderDialogContent ──────────────────────────────────────────────────

/// Dialog content for creating a new folder.
class _NewFolderDialogContent extends StatelessWidget {
  const _NewFolderDialogContent({
    required this.nameController,
    required this.onApply,
    required this.onCancel,
  });

  final TextEditingController nameController;
  final VoidCallback onApply;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OiTextInput(
          label: 'Folder name',
          controller: nameController,
          autofocus: true,
          onSubmitted: (_) => onApply(),
        ),
        SizedBox(height: spacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OiButton.ghost(label: 'Cancel', onTap: onCancel),
            SizedBox(width: spacing.sm),
            OiButton.primary(label: 'Apply', onTap: onApply),
          ],
        ),
      ],
    );
  }
}
