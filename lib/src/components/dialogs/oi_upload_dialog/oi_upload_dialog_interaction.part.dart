part of '../oi_upload_dialog.dart';

extension _OiUploadDialogInteraction on _OiUploadDialogState {
  void _addFiles(List<OiFileData> files) {
    _updateState(() {
      for (final file in files) {
        if (widget.maxFiles != null && _entries.length >= widget.maxFiles!) {
          break;
        }
        _entries.add(_UploadEntry(file: file, error: _validateFile(file)));
      }
    });
  }

  Future<void> _pickFiles() async {
    if (_picking) return;
    _updateState(() => _picking = true);
    try {
      final result = await FilePicker.pickFiles(
        type: widget.allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: widget.allowedExtensions,
      );
      if (result != null) {
        // Read eagerly: the picker no longer populates `bytes` itself, and the
        // dialog hands complete [OiFileData] to its caller.
        final files = <OiFileData>[];
        for (final file in result.files) {
          files.add(
            OiFileData(
              name: file.name,
              size: file.size,
              bytes: await file.readAsBytes(),
              mimeType: OiFileUtils.mimeType(OiFileUtils.extension(file.name)),
            ),
          );
        }
        if (mounted) _addFiles(files);
      }
    } finally {
      if (mounted) _escapeFocusNode.requestFocus();
      _updateState(() => _picking = false);
    }
  }

  Future<void> _handleDroppedFiles(DropDoneDetails details) async {
    final files = <OiFileData>[];
    for (final item in details.files) {
      // Skip directories.
      if (item is DropItemDirectory) continue;
      try {
        final bytes = await item.readAsBytes();
        files.add(
          OiFileData(
            name: item.name,
            size: bytes.length,
            bytes: bytes,
            mimeType:
                item.mimeType ??
                OiFileUtils.mimeType(OiFileUtils.extension(item.name)),
          ),
        );
      } on Exception {
        // Skip files that cannot be read (e.g. sandbox restrictions).
        continue;
      }
    }
    if (files.isNotEmpty && mounted) _addFiles(files);
  }

  void _removeEntry(int index) {
    _updateState(() => _entries.removeAt(index));
  }

  void _submit() {
    if (_validFiles.isEmpty) return;
    widget.onUpload(_validFiles, _resolution);
  }
}
