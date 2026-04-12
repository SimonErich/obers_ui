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
      label: 'Select all',
      category: 'Selection',
      onInvoke: () {
        if (!widget.enableMultiSelect) return;
        widget.controller.selectAll();
        _announce('All items selected');
      },
    ),
    OiShortcutBinding(
      activator: const SingleActivator(LogicalKeyboardKey.delete),
      label: 'Delete',
      category: 'Actions',
      onInvoke: _deleteSelectedFiles,
    ),
    OiShortcutBinding(
      activator: const SingleActivator(LogicalKeyboardKey.backspace),
      label: 'Delete',
      category: 'Actions',
      onInvoke: _deleteSelectedFiles,
    ),
    OiShortcutBinding(
      activator: const SingleActivator(LogicalKeyboardKey.f2),
      label: 'Rename',
      category: 'Actions',
      onInvoke: () {
        if (!widget.enableRename) return;
        final selected = widget.controller.selectedFiles;
        if (selected.length != 1) return;
        widget.controller.startRename(selected.first.id);
      },
    ),
    OiShortcutBinding(
      activator: OiShortcutActivator.primary(LogicalKeyboardKey.keyF),
      label: 'Search',
      category: 'Navigation',
      onInvoke: () {
        if (!widget.enableSearch) return;
        _setSearchActive(active: true);
      },
    ),
    OiShortcutBinding(
      activator: const SingleActivator(LogicalKeyboardKey.escape),
      label: 'Cancel / close search',
      category: 'Navigation',
      onInvoke: () {
        if (_searchActive) {
          _setSearchActive(active: false);
          widget.controller.setSearchQuery('');
        } else if (widget.controller.renamingKey != null) {
          widget.controller.cancelRename();
        } else if (widget.controller.selectedKeys.isNotEmpty) {
          widget.controller.clearSelection();
          _announce('Selection cleared');
        }
      },
    ),
    OiShortcutBinding(
      activator: OiShortcutActivator.primary(LogicalKeyboardKey.keyX),
      label: 'Cut (for keyboard move)',
      category: 'Clipboard',
      onInvoke: () {
        final selected = widget.controller.selectedFiles;
        if (selected.isEmpty) return;
        _clipboard = List.of(selected);
        _clipboardIsCut = true;
        _announce(
          '${selected.length} item${selected.length == 1 ? '' : 's'} cut',
        );
      },
    ),
    OiShortcutBinding(
      activator: OiShortcutActivator.primary(LogicalKeyboardKey.keyC),
      label: 'Copy (for keyboard copy)',
      category: 'Clipboard',
      onInvoke: () {
        if (widget.onCopy == null) return;
        final selected = widget.controller.selectedFiles;
        if (selected.isEmpty) return;
        _clipboard = List.of(selected);
        _clipboardIsCut = false;
        _announce(
          '${selected.length} item${selected.length == 1 ? '' : 's'} copied to clipboard',
        );
      },
    ),
    OiShortcutBinding(
      activator: OiShortcutActivator.primary(LogicalKeyboardKey.keyV),
      label: 'Paste (move/copy here)',
      category: 'Clipboard',
      onInvoke: () async {
        if (_clipboard.isEmpty) return;
        final folder = widget.controller.currentFolder;
        if (folder == null) return;
        if (_clipboardIsCut) {
          await widget.onMove(_clipboard, folder);
          _announce(
            '${_clipboard.length} item${_clipboard.length == 1 ? '' : 's'} moved here',
          );
        } else {
          await widget.onCopy?.call(_clipboard, folder);
          _announce(
            '${_clipboard.length} item${_clipboard.length == 1 ? '' : 's'} copied here',
          );
        }
        _clipboard = [];
        _clipboardIsCut = false;
        widget.controller.clearSelection();
        unawaited(widget.controller.refresh());
      },
    ),
    OiShortcutBinding(
      activator: OiShortcutActivator.primary(LogicalKeyboardKey.keyU),
      label: 'Upload',
      category: 'Actions',
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
      label: 'New folder',
      category: 'Actions',
      onInvoke: () async {
        final folderId =
            widget.controller.currentFolder?.id.toString() ?? 'root';
        await widget.onCreateFolder(folderId, 'New Folder');
        unawaited(widget.controller.refresh());
        _announce('New folder created');
      },
    ),
    OiShortcutBinding(
      activator: const SingleActivator(LogicalKeyboardKey.backspace, alt: true),
      label: 'Go back',
      category: 'Navigation',
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
      label: 'Go forward',
      category: 'Navigation',
      onInvoke: () {
        if (widget.controller.canGoForward) {
          widget.controller.goForward();
        }
      },
    ),
  ];
}
