part of '../oi_upload_dialog.dart';

extension _OiUploadDialogValidation on _OiUploadDialogState {
  String? _validateFile(OiFileData file) {
    // Extension check
    if (widget.allowedExtensions != null) {
      final ext = OiFileUtils.extension(file.name).toLowerCase();
      if (!widget.allowedExtensions!.contains(ext)) {
        return 'File type .$ext not allowed';
      }
    }
    // Size check
    if (widget.maxFileSize != null && file.size > widget.maxFileSize!) {
      return 'Exceeds ${OiFileUtils.formatSize(widget.maxFileSize!)} limit';
    }
    return null;
  }
}
