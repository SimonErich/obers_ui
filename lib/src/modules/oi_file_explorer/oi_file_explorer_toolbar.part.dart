part of '../oi_file_explorer.dart';

// ── Toolbar rendering ────────────────────────────────────────────────────────

extension _OiFileExplorerToolbar on _OiFileExplorerState {
  Widget _buildToolbar(OiFileExplorerController controller) {
    final colors = context.colors;
    final spacing = context.spacing;
    final isSelectionMode = controller.selectedKeys.isNotEmpty;

    return Semantics(
      label: 'File explorer toolbar',
      child: ClipRect(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.sm,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colors.borderSubtle),
            ),
          ),
          child: isSelectionMode
              ? _buildSelectionToolbar(controller)
              : _buildNormalToolbar(controller),
        ),
      ),
    );
  }

  Widget _buildNormalToolbar(OiFileExplorerController controller) {
    final spacing = context.spacing;
    return Row(
      children: [
        // Path bar (breadcrumbs)
        Expanded(
          child: OiPathBar(
            segments: _pathSegments,
            onNavigate: (segment) {
              unawaited(controller.navigateTo(segment.id));
            },
          ),
        ),
        // Search input (constrained width)
        if (widget.enableSearch && _searchActive)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: Semantics(
              label: 'Search files',
              child: OiTextInput.search(
                autofocus: true,
                onChanged: (q) {
                  _searchDebounce.call(q, _onSearch);
                },
              ),
            ),
          ),
        // Search toggle
        if (widget.enableSearch)
          OiIconButton(
            icon: _searchActive ? OiIcons.x : OiIcons.search,
            semanticLabel: _searchActive ? 'Close search' : 'Search',
            onTap: () {
              _setSearchActive(active: !_searchActive);
              if (!_searchActive) controller.setSearchQuery('');
            },
          ),
        SizedBox(width: spacing.sm),
        // View toggle
        OiButtonGroup(
          label: 'View mode',
          exclusive: true,
          selectedIndex: controller.viewMode == OiFileViewMode.list ? 0 : 1,
          onSelect: (index) {
            controller.setViewMode(
              index == 0 ? OiFileViewMode.list : OiFileViewMode.grid,
            );
          },
          items: const [
            OiButtonGroupItem(icon: OiIcons.layoutList, label: 'List view'),
            OiButtonGroupItem(icon: OiIcons.layoutGrid, label: 'Grid view'),
          ],
        ),
        SizedBox(width: spacing.sm),
        // Actions
        if (widget.enableUpload)
          OiTooltip(
            label: 'Upload File',
            message: 'Upload File',
            child: OiIconButton(
              icon: OiIcons.cloudUpload,
              semanticLabel: 'Upload files',
              onTap: _showUploadDialog,
            ),
          ),
        OiTooltip(
          label: 'Add New Folder',
          message: 'Add New Folder',
          child: OiIconButton(
            icon: OiIcons.folderOpen,
            semanticLabel: 'New folder',
            onTap: _showNewFolderDialog,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionToolbar(OiFileExplorerController controller) {
    final colors = context.colors;
    final count = controller.selectedKeys.length;
    return Row(
      children: [
        Expanded(
          child: Semantics(
            liveRegion: true,
            child: Text(
              '$count selected',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.text,
              ),
            ),
          ),
        ),
        if (widget.enableMove)
          OiButton.ghost(
            label: 'Move',
            onTap: () => _showMoveDialog(controller.selectedFiles),
          ),
        if (widget.enableCopy && widget.onCopy != null)
          OiButton.ghost(
            label: 'Copy',
            onTap: () =>
                _showMoveDialog(controller.selectedFiles, copyMode: true),
          ),
        if (widget.enableDelete)
          OiButton.ghost(
            label: 'Delete',
            onTap: () => _showDeleteDialog(controller.selectedFiles),
          ),
        OiButton.ghost(
          label: 'Clear',
          onTap: () {
            controller.clearSelection();
            _announce('Selection cleared');
          },
        ),
      ],
    );
  }
}
