part of '../oi_file_explorer.dart';

// ── Context menu builders ────────────────────────────────────────────────────

extension _OiFileExplorerContextMenus on _OiFileExplorerState {
  List<OiMenuItem> _buildFileContextMenu(OiFileNodeData file) {
    final custom = widget.customContextMenuItems?.call(file) ?? [];
    return [
      if (file.folder)
        OiMenuItem(
          label: 'Open',
          icon: OiIcons.externalLink,
          onTap: () =>
              widget.controller.navigateTo(file.id.toString(), folder: file),
        )
      else ...[
        if (widget.onOpen != null)
          OiMenuItem(
            label: 'Open',
            icon: OiIcons.externalLink,
            onTap: () => widget.onOpen!(file),
          ),
        if (widget.onPreview != null)
          OiMenuItem(
            label: 'Preview',
            icon: OiIcons.scissors,
            onTap: () => widget.onPreview!(file),
          ),
      ],
      if (custom.isNotEmpty) ...[const OiMenuDivider(), ...custom],
      const OiMenuDivider(),
      if (widget.enableRename)
        OiMenuItem(
          label: 'Rename',
          icon: OiIcons.pencil,
          onTap: () => widget.controller.startRename(file.id),
        ),
      if (widget.enableMove)
        OiMenuItem(
          label: 'Move to...',
          icon: OiIcons.arrowRight,
          onTap: () => _showMoveDialog([file]),
        ),
      if (widget.enableCopy && widget.onCopy != null)
        OiMenuItem(
          label: 'Copy to...',
          icon: OiIcons.copy,
          onTap: () => _showMoveDialog([file], copyMode: true),
        ),
      if (widget.onDownload != null)
        OiMenuItem(
          label: 'Download',
          icon: OiIcons.share2,
          onTap: () => widget.onDownload!(file),
        ),
      if (widget.onShare != null)
        OiMenuItem(
          label: 'Share',
          icon: OiIcons.info,
          onTap: () => widget.onShare!(file),
        ),
      const OiMenuDivider(),
      if (widget.enableDelete)
        OiMenuItem(
          label: 'Delete',
          icon: OiIcons.trash2,
          onTap: () => _showDeleteDialog([file]),
        ),
    ];
  }

  List<OiMenuItem> _buildBackgroundContextMenu() {
    return [
      OiMenuItem(
        label: 'New folder',
        icon: OiIcons.folderOpen,
        onTap: () async {
          final folderId =
              widget.controller.currentFolder?.id.toString() ?? 'root';
          await widget.onCreateFolder(folderId, 'New Folder');
          unawaited(widget.controller.refresh());
        },
      ),
      if (widget.enableUpload)
        OiMenuItem(
          label: 'Upload files',
          icon: OiIcons.cloudUpload,
          onTap: _showUploadDialog,
        ),
      if (widget.controller.selectedKeys.isNotEmpty) ...[
        const OiMenuDivider(),
        OiMenuItem(
          label: 'Select all',
          icon: OiIcons.send,
          onTap: widget.controller.selectAll,
        ),
        OiMenuItem(
          label: 'Clear selection',
          onTap: widget.controller.clearSelection,
        ),
      ],
    ];
  }
}
