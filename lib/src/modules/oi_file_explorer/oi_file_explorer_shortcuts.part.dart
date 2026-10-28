part of '../oi_file_explorer.dart';

// ── Keyboard shortcut bindings ───────────────────────────────────────────────

extension _OiFileExplorerShortcuts on _OiFileExplorerState {
  void _deleteSelectedFiles() {
    if (!widget.enableDelete) return;
    final selected = widget.controller.selectedFiles;
    if (selected.isEmpty) return;
    _showDeleteDialog(selected);
  }

  List<OiShortcutBinding> get _shortcuts => [
    OiShortcutBinding(
      activator: OiShortcutActivator.primary(LogicalKeyboardKey.keyA),
      label: widget.labels.shortcuts.selectAll,
      category: widget.labels.shortcuts.selection,
      onInvoke: () {
        if (!widget.enableMultiSelect) return;
        widget.controller.selectAll();
        _announce(widget.labels.announcements.allSelected);
      },
    ),
    OiShortcutBinding(
      activator: const SingleActivator(LogicalKeyboardKey.delete),
      label: widget.labels.shortcuts.delete,
      category: widget.labels.shortcuts.actions,
      onInvoke: _deleteSelectedFiles,
    ),
    OiShortcutBinding(
      activator: const SingleActivator(LogicalKeyboardKey.backspace),
      label: widget.labels.shortcuts.delete,
      category: widget.labels.shortcuts.actions,
      onInvoke: _deleteSelectedFiles,
    ),
    OiShortcutBinding(
      activator: const SingleActivator(LogicalKeyboardKey.f2),
      label: widget.labels.shortcuts.rename,
      category: widget.labels.shortcuts.actions,
      onInvoke: () {
        if (!widget.enableRename) return;
        final selected = widget.controller.selectedFiles;
        if (selected.length != 1) return;
        widget.controller.startRename(selected.first.id);
      },
    ),
    OiShortcutBinding(
      activator: OiShortcutActivator.primary(LogicalKeyboardKey.keyF),
      label: widget.labels.shortcuts.search,
      category: widget.labels.shortcuts.navigation,
      onInvoke: () {
        if (!widget.enableSearch) return;
        _setSearchActive(active: true);
      },
    ),
    OiShortcutBinding(
      activator: const SingleActivator(LogicalKeyboardKey.escape),
      label: widget.labels.shortcuts.closeSearch,
      category: widget.labels.shortcuts.navigation,
      onInvoke: () {
        if (_searchActive) {
          _setSearchActive(active: false);
          widget.controller.setSearchQuery('');
        } else if (widget.controller.renamingKey != null) {
          widget.controller.cancelRename();
        } else if (widget.controller.selectedKeys.isNotEmpty) {
          widget.controller.clearSelection();
          _announce(widget.labels.announcements.selectionCleared);
        }
      },
    ),
    OiShortcutBinding(
      activator: OiShortcutActivator.primary(LogicalKeyboardKey.keyX),
      label: widget.labels.shortcuts.cut,
      category: widget.labels.shortcuts.clipboard,
      onInvoke: () {
        final selected = widget.controller.selectedFiles;
        if (selected.isEmpty) return;
        _clipboard = List.of(selected);
        _clipboardIsCut = true;
        _announce(widget.labels.announcements.cut(selected.length));
      },
    ),
    OiShortcutBinding(
      activator: OiShortcutActivator.primary(LogicalKeyboardKey.keyC),
      label: widget.labels.shortcuts.copy,
      category: widget.labels.shortcuts.clipboard,
      onInvoke: () {
        if (widget.onCopy == null) return;
        final selected = widget.controller.selectedFiles;
        if (selected.isEmpty) return;
        _clipboard = List.of(selected);
        _clipboardIsCut = false;
        _announce(
          widget.labels.announcements.copiedToClipboard(selected.length),
        );
      },
    ),
    OiShortcutBinding(
      activator: OiShortcutActivator.primary(LogicalKeyboardKey.keyV),
      label: widget.labels.shortcuts.paste,
      category: widget.labels.shortcuts.clipboard,
      onInvoke: () async {
        if (_clipboard.isEmpty) return;
        final folder = widget.controller.currentFolder;
        if (folder == null) return;
        if (_clipboardIsCut) {
          await widget.onMove(_clipboard, folder);
          _announce(widget.labels.announcements.movedHere(_clipboard.length));
        } else {
          await widget.onCopy?.call(_clipboard, folder);
          _announce(widget.labels.announcements.copiedHere(_clipboard.length));
        }
        _clipboard = [];
        _clipboardIsCut = false;
        widget.controller.clearSelection();
        unawaited(widget.controller.refresh());
      },
    ),
    OiShortcutBinding(
      activator: OiShortcutActivator.primary(LogicalKeyboardKey.keyU),
      label: widget.labels.shortcuts.upload,
      category: widget.labels.shortcuts.actions,
      onInvoke: () {
        if (!widget.enableUpload) return;
        _showUploadDialog();
      },
    ),
    OiShortcutBinding(
      activator: OiShortcutActivator.primary(
        LogicalKeyboardKey.keyN,
        shift: true,
      ),
      label: widget.labels.shortcuts.newFolder,
      category: widget.labels.shortcuts.actions,
      onInvoke: () async {
        final folderId =
            widget.controller.currentFolder?.id.toString() ?? 'root';
        await widget.onCreateFolder(folderId, widget.labels.newFolderName);
        unawaited(widget.controller.refresh());
        _announce(widget.labels.announcements.newFolderCreated);
      },
    ),
    OiShortcutBinding(
      activator: const SingleActivator(LogicalKeyboardKey.backspace, alt: true),
      label: widget.labels.shortcuts.goBack,
      category: widget.labels.shortcuts.navigation,
      onInvoke: () {
        if (widget.controller.canGoBack) {
          widget.controller.goBack();
        }
      },
    ),
    OiShortcutBinding(
      activator: const SingleActivator(
        LogicalKeyboardKey.backspace,
        alt: true,
        shift: true,
      ),
      label: widget.labels.shortcuts.goForward,
      category: widget.labels.shortcuts.navigation,
      onInvoke: () {
        if (widget.controller.canGoForward) {
          widget.controller.goForward();
        }
      },
    ),
  ];
}
