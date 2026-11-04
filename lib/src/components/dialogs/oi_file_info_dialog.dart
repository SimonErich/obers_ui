import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_file_icon.dart';
import 'package:obers_ui/src/components/display/oi_file_preview.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_scheme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_file_node_data.dart';
import 'package:obers_ui/src/utils/file_utils.dart';

/// The texts of an [OiFileInfoDialog], in English by default; pass
/// translations to localize the dialog.
///
/// {@category Components}
class OiFileInfoDialogLabels {
  /// Creates an [OiFileInfoDialogLabels].
  const OiFileInfoDialogLabels({
    this.folder = 'Folder',
    this.size = 'Size',
    this.location = 'Location',
    this.created = 'Created',
    this.modified = 'Modified',
    this.items = 'Items',
    this.close = 'Close',
    this.dialog = 'File info dialog',
    this.fileTypeName = OiFileUtils.fileTypeName,
    this.formatDate = englishFormatDate,
  });

  /// "March 5, 2026 at 14:30": the default [formatDate].
  static String englishFormatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year} at '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Type shown for a folder.
  final String folder;

  /// Label of the size row.
  final String size;

  /// Label of the location row.
  final String location;

  /// Label of the created row.
  final String created;

  /// Label of the modified row.
  final String modified;

  /// Label of a folder's item count row.
  final String items;

  /// Label of the close button.
  final String close;

  /// Screen-reader label of the dialog.
  final String dialog;

  /// Type shown for a file, by its extension.
  final String Function(String extension) fileTypeName;

  /// Formats the created and modified dates.
  final String Function(DateTime date) formatDate;
}

/// A dialog showing detailed metadata about a file or folder.
///
/// Displays name, type, size, location, created/modified dates, and custom
/// metadata.
///
/// {@category Components}
class OiFileInfoDialog extends StatelessWidget {
  /// Creates an [OiFileInfoDialog].
  const OiFileInfoDialog({
    required this.file,
    this.onClose,
    this.extraMetadata,
    this.labels = const OiFileInfoDialogLabels(),
    super.key,
  });

  /// The file to show info for.
  final OiFileNodeData file;

  /// Called when the dialog is closed.
  final VoidCallback? onClose;

  /// Additional key-value metadata to display.
  final Map<String, String>? extraMetadata;

  /// The dialog's texts; pass translations to localize it.
  final OiFileInfoDialogLabels labels;

  bool get _isImage {
    final ext = file.resolvedExtension.toLowerCase();
    return const {'png', 'jpg', 'jpeg', 'gif', 'svg', 'webp'}.contains(ext);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Semantics(
      label: labels.dialog,
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with preview/icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isImage || file.thumbnailUrl != null)
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: OiFilePreview(file: file, width: 80, height: 80),
                  )
                else
                  OiFileIcon(
                    fileName: file.name,
                    mimeType: file.mimeType,
                    size: OiFileIconSize.xl,
                  ),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colors.text,
                        ),
                      ),
                      SizedBox(height: spacing.xs),
                      Text(
                        file.folder
                            ? labels.folder
                            : labels.fileTypeName(file.resolvedExtension),
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textSubtle,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.md),
            // Divider
            Container(height: 1, color: colors.borderSubtle),
            SizedBox(height: spacing.md),
            // Info rows
            if (!file.folder && file.size != null)
              _InfoRow(
                label: labels.size,
                value: file.formattedSize,
                colors: colors,
              ),
            if (file.parentId != null)
              _InfoRow(
                label: labels.location,
                value: file.parentId!,
                colors: colors,
                copyable: true,
              ),
            if (file.created != null)
              _InfoRow(
                label: labels.created,
                value: labels.formatDate(file.created!),
                colors: colors,
              ),
            if (file.modified != null)
              _InfoRow(
                label: labels.modified,
                value: labels.formatDate(file.modified!),
                colors: colors,
              ),
            if (file.folder && file.itemCount != null)
              _InfoRow(
                label: labels.items,
                value: '${file.itemCount}',
                colors: colors,
              ),
            // Extra metadata
            if (extraMetadata != null && extraMetadata!.isNotEmpty) ...[
              SizedBox(height: spacing.sm),
              Container(height: 1, color: colors.borderSubtle),
              SizedBox(height: spacing.sm),
              for (final entry in extraMetadata!.entries)
                _InfoRow(label: entry.key, value: entry.value, colors: colors),
            ],
            SizedBox(height: spacing.lg),
            // Close button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [OiButton.ghost(label: labels.close, onTap: onClose)],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.colors,
    this.copyable = false,
  });

  final String label;
  final String value;
  final OiColorScheme colors;
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Padding(
      padding: EdgeInsets.only(bottom: spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: colors.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12, color: colors.text),
            ),
          ),
        ],
      ),
    );
  }
}
