part of '../oi_upload_dialog.dart';

extension _OiUploadDialogLayout on _OiUploadDialogState {
  Widget _buildDialog(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Semantics(
      label: widget.labels.dialog,
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
                  widget.labels.uploadTo(widget.destinationPath!),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                )
              else
                Text(
                  widget.labels.title,
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
                  widget.labels.filesToUpload,
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
                    widget.labels.maxFiles(widget.maxFiles!),
                    style: TextStyle(fontSize: 11, color: colors.warning.base),
                  ),
                ),
              SizedBox(height: spacing.md),
              Row(
                children: [
                  Text(
                    widget.labels.ifFileExists,
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
                              label: widget.labels.conflictResolution(r),
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
                  OiButton.ghost(
                    label: widget.labels.cancel,
                    onTap: widget.onCancel,
                  ),
                  SizedBox(width: spacing.sm),
                  OiButton.primary(
                    label: _validFiles.isEmpty
                        ? widget.labels.upload
                        : widget.labels.uploadCount(_validFiles.length),
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
                      ? widget.labels.releaseToAdd
                      : widget.labels.dropFiles,
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
