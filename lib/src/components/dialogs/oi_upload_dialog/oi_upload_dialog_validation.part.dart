part of '../oi_upload_dialog.dart';

extension _OiUploadDialogValidation on _OiUploadDialogState {
  String? _validateFile(OiFileData file) {
    // Extension check
    if (widget.allowedExtensions != null) {
      final ext = OiFileUtils.extension(file.name).toLowerCase();
      if (!widget.allowedExtensions!.contains(ext)) {
        return widget.labels.typeNotAllowed(ext);
      }
    }
    // Size check
    if (widget.maxFileSize != null && file.size > widget.maxFileSize!) {
      return widget.labels.exceedsLimit(
        OiFileUtils.formatSize(widget.maxFileSize!),
      );
    }
    return null;
  }
}
