part of '../oi_upload_dialog.dart';

extension _OiUploadDialogLayout on _OiUploadDialogState {
  Widget _buildDialog(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Semantics(
      label: 'Upload dialog',
      child: Focus(
        focusNode: _escapeFocusNode,
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.escape) {
            widget.onCancel?.call();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Padding(
          padding: EdgeInsets.all(spacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.destinationPath != null)
                Text(
                  'Upload to: ${widget.destinationPath}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                )
              else
                Text(
                  'Upload Files',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
              SizedBox(height: spacing.md),
              _buildDropZone(colors, spacing),
              if (_entries.isNotEmpty) ...[
                SizedBox(height: spacing.md),
                Text(
                  'Files to upload:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colors.textSubtle,
                  ),
                ),
                SizedBox(height: spacing.xs),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _entries.length,
                    itemBuilder: (context, index) {
                      final entry = _entries[index];
                      return _buildFileEntry(
                        context,
                        entry,
                        index,
                        colors,
                        spacing,
                      );
                    },
                  ),
                ),
              ],
              if (widget.maxFiles != null &&
                  _entries.length >= widget.maxFiles!)
                Padding(
                  padding: EdgeInsets.only(top: spacing.xs),
                  child: Text(
                    'Maximum ${widget.maxFiles} files allowed',
                    style: TextStyle(fontSize: 11, color: colors.warning.base),
                  ),
                ),
              SizedBox(height: spacing.md),
              Row(
                children: [
                  Text(
                    'If file exists:',
                    style: TextStyle(fontSize: 12, color: colors.textSubtle),
                  ),
                  SizedBox(width: spacing.sm),
                  Expanded(
                    child: OiSelect<OiConflictResolution>(
                      value: _resolution,
                      options: OiConflictResolution.values
                          .map(
                            (r) => OiSelectOption(
                              value: r,
                              label:
                                  r.name[0].toUpperCase() + r.name.substring(1),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) _updateState(() => _resolution = v);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OiButton.ghost(label: 'Cancel', onTap: widget.onCancel),
                  SizedBox(width: spacing.sm),
                  OiButton.primary(
                    label: _validFiles.isEmpty
                        ? 'Upload'
                        : 'Upload ${_validFiles.length} file${_validFiles.length == 1 ? '' : 's'}',
                    onTap: _validFiles.isNotEmpty ? _submit : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropZone(OiColorScheme colors, OiSpacingScale spacing) {
    return DropTarget(
      onDragEntered: (_) => _updateState(() => _isDragOver = true),
      onDragExited: (_) => _updateState(() => _isDragOver = false),
      onDragDone: (details) {
        _updateState(() => _isDragOver = false);
        unawaited(_handleDroppedFiles(details));
      },
      child: GestureDetector(
        onTap: _pickFiles,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(
              color: _isDragOver ? colors.primary.base : colors.borderSubtle,
              width: _isDragOver ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: _isDragOver
                ? colors.primary.muted.withValues(alpha: 0.12)
                : colors.surfaceSubtle,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  OiIcons.cloudUpload,
                  size: 28,
                  color: _isDragOver ? colors.primary.base : colors.textMuted,
                ),
                SizedBox(height: spacing.xs),
                Text(
                  _isDragOver
                      ? 'Release to add files'
                      : 'Drop files here or browse',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: _isDragOver
                        ? FontWeight.w500
                        : FontWeight.normal,
                    color: _isDragOver ? colors.primary.base : colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileEntry(
    BuildContext context,
    _UploadEntry entry,
    int index,
    OiColorScheme colors,
    OiSpacingScale spacing,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: spacing.xs),
      child: Row(
        children: [
          OiFileIcon(fileName: entry.file.name, size: OiFileIconSize.sm),
          SizedBox(width: spacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.file.name,
                  style: TextStyle(fontSize: 12, color: colors.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (entry.error != null)
                  Text(
                    entry.error!,
                    style: TextStyle(fontSize: 10, color: colors.error.base),
                  ),
              ],
            ),
          ),
          SizedBox(width: spacing.xs),
          Text(
            OiFileUtils.formatSize(entry.file.size),
            style: TextStyle(fontSize: 11, color: colors.textMuted),
          ),
          SizedBox(width: spacing.xs),
          GestureDetector(
            onTap: () => _removeEntry(index),
            child: Icon(OiIcons.x, size: 14, color: colors.textMuted),
          ),
        ],
      ),
    );
  }
}
