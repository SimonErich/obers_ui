part of '../oi_field_display.dart';

String _formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}

extension _OiFieldDisplayAssetContent on OiFieldDisplay {
  Widget _buildFileDisplay(BuildContext context) {
    final colors = context.colors;
    String filename;
    String? sizeLabel;

    if (value is Map) {
      final map = value as Map;
      filename = (map['name'] ?? '').toString();
      if (map.containsKey('size') && map['size'] is num) {
        sizeLabel = _formatFileSize((map['size'] as num).toInt());
      }
    } else {
      filename = _valueString.split('/').last.split(r'\').last;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OiIcon.decorative(
          icon: OiIcons.layoutGrid,
          color: colors.textMuted,
          size: 16,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: OiLabel.small(
            filename,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (sizeLabel != null) ...[
          const SizedBox(width: 6),
          OiLabel.small(sizeLabel, color: colors.textMuted),
        ],
      ],
    );
  }

  Widget _buildImageDisplay(BuildContext context) {
    return OiImage(
      src: _valueString,
      alt: label.isEmpty ? 'Image' : label,
      width: 64,
      height: 64,
      fit: BoxFit.cover,
    );
  }

  Widget _buildJsonDisplay(BuildContext context) {
    String formatted;
    try {
      final encoded = value is String ? jsonDecode(value as String) : value;
      formatted = const JsonEncoder.withIndent('  ').convert(encoded);
    } on Exception catch (_) {
      formatted = _valueString;
    }

    return OiCodeBlock(
      code: formatted,
      language: 'json',
      showCopyButton: false,
    );
  }
}
