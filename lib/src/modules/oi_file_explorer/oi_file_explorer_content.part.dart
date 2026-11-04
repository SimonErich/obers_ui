part of '../oi_file_explorer.dart';

// ── Content area, sidebar, and main content ──────────────────────────────────

extension _OiFileExplorerContent on _OiFileExplorerState {
  // ── Shared callbacks ──────────────────────────────────────────────────────

  void _onFileOpen(OiFileNodeData file) {
    if (file.folder) {
      unawaited(
        widget.controller.navigateTo(file.id.toString(), folder: file),
      );
    } else {
      widget.onOpen?.call(file);
    }
  }

  Future<void> _onFileRenamed(String newName) async {
    final controller = widget.controller;
    final renamingFile = controller.files
        .where((f) => f.id == controller.renamingKey)
        .firstOrNull;
    if (renamingFile != null) {
      await widget.onRename(renamingFile, newName);
      controller.cancelRename();
      await controller.refresh();
      _announce(widget.labels.announcements.renamedTo(newName));
    }
  }

  Future<void> Function(List<OiFileNodeData>, OiFileNodeData)?
  get _onMoveToFolder {
    if (!widget.enableMove) return null;
    return (movedFiles, folder) async {
      await widget.onMove(movedFiles, folder);
      widget.controller.clearSelection();
      await widget.controller.refresh();
      _announce(
        widget.labels.announcements.movedTo(movedFiles.length, folder.name),
      );
    };
  }

  // ── Build methods ─────────────────────────────────────────────────────────
  Widget _buildSidebar() {
    return OiFileSidebar(
      folderTree: _folderTree,
      selectedFolderId: widget.controller.currentFolder?.id.toString(),
      onFolderSelect: (folder) {
        unawaited(
          widget.controller.navigateTo(folder.id.toString(), folder: folder),
        );
      },
      quickAccess: widget.quickAccess,
      storage: widget.storage,
      width: widget.sidebarWidth,
      onNewFolder: (_) => _showNewFolderDialog(),
      onFileDrop: widget.enableDragDrop
          ? (files, folder) async {
              await widget.onMove(files, folder);
              widget.controller.clearSelection();
              unawaited(widget.controller.refresh());
              _announce(
                widget.labels.announcements.movedTo(files.length, folder.name),
              );
            }
          : null,
      semanticsLabel: widget.labels.sidebarLabel,
      labels: widget.labels.sidebar,
    );
  }

  Widget _buildMainContent(
    List<OiFileNodeData> files,
    OiFileExplorerController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Toolbar
        _buildToolbar(controller),
        // Content
        Expanded(
          child: OiFileDropTarget(
            onInternalDrop: (droppedFiles, targetFolder) async {
              if (targetFolder != null) {
                await widget.onMove(droppedFiles, targetFolder);
                unawaited(controller.refresh());
                _announce(
                  widget.labels.announcements.movedTo(
                    droppedFiles.length,
                    targetFolder.name,
                  ),
                );
              }
            },
            onExternalDrop: (externalFiles) async {
              final folderId =
                  controller.currentFolder?.id.toString() ?? 'root';
              await widget.onUpload(externalFiles, folderId);
              unawaited(controller.refresh());
              _announce(
                widget.labels.announcements.uploaded(externalFiles.length),
              );
            },
            enabled: widget.enableDragDrop && !_isDialogOpen,
            child: _buildContentArea(files, controller),
          ),
        ),
      ],
    );
  }

  Widget _buildContentArea(
    List<OiFileNodeData> files,
    OiFileExplorerController controller,
  ) {
    if (controller.loading) {
      if (controller.viewMode == OiFileViewMode.list) {
        return OiFileListView(
          files: const [],
          selectedKeys: const {},
          onSelectionChange: (_) {},
          onOpen: (_) {},
          loading: true,
        );
      }
      return OiFileGridView(
        files: const [],
        selectedKeys: const {},
        onSelectionChange: (_) {},
        onOpen: (_) {},
        loading: true,
      );
    }

    if (files.isEmpty) {
      if (controller.searchQuery.isNotEmpty) {
        return OiEmptyState(
          icon: OiIcons.search,
          title: widget.labels.noMatches(controller.searchQuery),
          action: OiButton.ghost(
            label: widget.labels.clearSearch,
            onTap: () {
              controller.setSearchQuery('');
              _setSearchActive(active: false);
            },
          ),
        );
      }
      return OiContextMenu(
        label: widget.labels.emptyFolderMenu,
        items: _buildBackgroundContextMenu(),
        child: OiEmptyState(
          icon: OiIcons.folder,
          title: widget.labels.emptyFolder,
          action: widget.enableUpload
              ? OiButton.primary(
                  label: widget.labels.uploadFiles,
                  icon: OiIcons.cloudUpload,
                  onTap: _showUploadDialog,
                )
              : null,
        ),
      );
    }

    if (controller.viewMode == OiFileViewMode.list) {
      return OiFileListView(
        files: files,
        selectedKeys: controller.selectedKeys,
        onSelectionChange: controller.setSelection,
        onOpen: _onFileOpen,
        sortField: controller.sortField,
        sortDirection: controller.sortDirection,
        onSortFieldChange: controller.setSortField,
        onSortDirectionChange: controller.setSortDirection,
        renamingKey: controller.renamingKey,
        onRename: _onFileRenamed,
        onCancelRename: controller.cancelRename,
        onMoveToFolder: _onMoveToFolder,
        enableDragDrop: widget.enableDragDrop,
        enableMultiSelect: widget.enableMultiSelect,
        contextMenuBuilder: _buildFileContextMenu,
        backgroundContextMenu: _buildBackgroundContextMenu,
        searchQuery: controller.searchQuery,
        semanticsLabel: widget.labels.listWithCount(files.length),
        labels: widget.labels.listViewLabels,
      );
    }

    return OiFileGridView(
      files: files,
      selectedKeys: controller.selectedKeys,
      onSelectionChange: controller.setSelection,
      onOpen: _onFileOpen,
      renamingKey: controller.renamingKey,
      onRename: _onFileRenamed,
      onCancelRename: controller.cancelRename,
      onMoveToFolder: _onMoveToFolder,
      enableDragDrop: widget.enableDragDrop,
      enableMultiSelect: widget.enableMultiSelect,
      contextMenuBuilder: _buildFileContextMenu,
      backgroundContextMenu: _buildBackgroundContextMenu,
      searchQuery: controller.searchQuery,
      semanticsLabel: widget.labels.gridWithCount(files.length),
      labels: widget.labels.gridViewLabels,
    );
  }
}
