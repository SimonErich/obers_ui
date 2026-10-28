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
      label: widget.labels.deleteConfirmation,
      dialog: OiDialog.confirm(
        label: widget.labels.deleteConfirmation,
        content: OiDeleteDialog(
          files: files,
          onDelete: () async {
            _dismissDialog();
            await widget.onDelete(files);
            widget.controller.clearSelection();
            unawaited(widget.controller.refresh());
            _announce(widget.labels.announcements.deleted(files.length));
          },
          onCancel: _dismissDialog,
          permanent: true,
          labels: widget.labels.deleteDialog,
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
      label: copyMode
          ? widget.labels.copyDialogLabel
          : widget.labels.moveDialogLabel,
      dialog: OiDialog.form(
        label: copyMode
            ? widget.labels.copyDialogLabel
            : widget.labels.moveDialogLabel,
        content: OiMoveDialog(
          files: files,
          folderTree: _folderTree,
          copyMode: copyMode,
          labels: widget.labels.moveDialog,
          onMove: (destination) async {
            _dismissDialog();
            if (copyMode) {
              await widget.onCopy?.call(files, destination);
            } else {
              await widget.onMove(files, destination);
            }
            widget.controller.clearSelection();
            unawaited(widget.controller.refresh());
            _announce(
              copyMode
                  ? widget.labels.announcements.copiedTo(
                      files.length,
                      destination.name,
                    )
                  : widget.labels.announcements.movedTo(
                      files.length,
                      destination.name,
                    ),
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
      label: widget.labels.uploadDialogLabel,
      dialog: OiDialog.form(
        label: widget.labels.uploadDialogLabel,
        content: OiUploadDialog(
          allowedExtensions: widget.allowedUploadExtensions,
          maxFileSize: widget.maxUploadFileSize,
          destinationPath: widget.controller.currentFolder?.name,
          labels: widget.labels.uploadDialog,
          onUpload: (files, _) async {
            _dismissDialog();
            await widget.onUpload(files, folderId);
            unawaited(widget.controller.refresh());
            _announce(widget.labels.announcements.uploaded(files.length));
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
    final nameController = TextEditingController(
      text: widget.labels.newFolderName,
    );

    void closeAndDispose() {
      _dismissDialog();
      nameController.dispose();
    }

    _dialogHandle = OiDialog.show(
      context,
      label: widget.labels.newFolder,
      dialog: OiDialog.form(
        label: widget.labels.newFolder,
        title: widget.labels.newFolderTitle,
        content: _NewFolderDialogContent(
          nameController: nameController,
          labels: widget.labels,
          onApply: () async {
            final name = nameController.text.trim();
            if (name.isEmpty) return;
            closeAndDispose();
            final folderId =
                widget.controller.currentFolder?.id.toString() ?? 'root';
            await widget.onCreateFolder(folderId, name);
            unawaited(widget.controller.refresh());
            unawaited(_loadFolderTree());
            _announce(widget.labels.announcements.folderCreated(name));
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
    required this.labels,
    required this.onApply,
    required this.onCancel,
  });

  final TextEditingController nameController;
  final OiFileExplorerLabels labels;
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
          label: labels.folderName,
          controller: nameController,
          autofocus: true,
          onSubmitted: (_) => onApply(),
        ),
        SizedBox(height: spacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OiButton.ghost(label: labels.cancel, onTap: onCancel),
            SizedBox(width: spacing.sm),
            OiButton.primary(label: labels.apply, onTap: onApply),
          ],
        ),
      ],
    );
  }
}
